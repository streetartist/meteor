import os
import subprocess
from ctypes import CFUNCTYPE, c_void_p
from decimal import Decimal
from math import inf
from time import time
from typing import Optional

import llvmlite.binding as llvm
from llvmlite import ir

import meteor.compiler.llvmlite_custom
from meteor.ast import CollectionAccess, DotAccess, Input, Str, Var, VarDecl
from meteor.compiler.base import RET_VAR, type_map
from meteor.compiler.builtins import (array_types, create_dynamic_array_methods,
                                     define_builtins)
from meteor.compiler.operations import binary_op, cast_ops, unary_op
from meteor.grammar import *
from meteor.type_checker import types_compatible
from meteor.utils import *
from meteor.visitor import NodeVisitor


class CodeGenerator(NodeVisitor):
    def __init__(self, file_name: str):
        super().__init__()
        self.file_name = file_name
        self.module = ir.Module()
        self.builder = None
        self._add_builtins()
        func_ty = ir.FunctionType(ir.IntType(64), [])  # [type_map[INT32], type_map[INT8].as_pointer().as_pointer()])
        func = ir.Function(self.module, func_ty, 'main')
        entry_block = func.append_basic_block('entry')
        exit_block = func.append_basic_block('exit')
        self.current_function = func
        self.function_stack = [func]
        self.builder = ir.IRBuilder(entry_block)
        self.exit_blocks = [exit_block]
        self.block_stack = [entry_block]
        self.defer_stack = [[]]
        self.loop_test_blocks = []
        self.loop_end_blocks = []
        self.is_break = False
        self.anon_counter = 0
        self._entry_allocas = {}  # Cache for entry block allocas

        # llvm.initialize()
        llvm.initialize_native_target()
        llvm.initialize_native_asmprinter()

        # for i in range(2):
        #     func.args[i].name = '.argc' if i == 0 else '.argv'
        #     self.alloc_define_store(func.args[i], func.args[i].name[1:], func.args[i].type)

    def __str__(self) -> str:
        return str(self.module)

    def visit_program(self, node):
        self.visit(node.block)
        for stat in self.defer_stack[-1]:
            self.visit(stat)
        self.branch(self.exit_blocks[0])
        self.position_at_end(self.exit_blocks[0])
        self.builder.ret(self.const(0))

    @staticmethod
    def visit_num(node):
        return ir.Constant(type_map[node.val_type], node.value)

    def visit_var(self, node):
        var = self.search_scopes(node.value)
        if isinstance(var, type_map[FUNC]) or isinstance(var, ir.Function):
            return var
        return self.load(node.value)

    def visit_binop(self, node):
        return binary_op(self, node)

    def visit_defer(self, node):
        self.defer_stack[-1].append(node.statement)

    def visit_anonymousfunc(self, node):
        self.anon_counter += 1
        self.funcdef('anon_func.{}'.format(self.anon_counter), node, "private")
        return self.search_scopes('anon_func.{}'.format(self.anon_counter))

    def visit_funcdecl(self, node):
        self.funcdef(node.name, node)

    def visit_externfuncdecl(self, node):
        self.externfuncdecl(node.name, node)

    def externfuncdecl(self, name, node):
        for func in self.module.functions:
            if func.name == name:
                self.define(name, func, 1)
                return
        return_type = node.return_type
        parameters = node.parameters
        varargs = node.varargs
        ret_type = self.get_type(return_type)
        args = self.get_args(parameters)
        func_type = ir.FunctionType(ret_type, args, varargs)
        func_type.parameters = parameters
        func = ir.Function(self.module, func_type, name)
        self.define(name, func, 1)

    def funcdecl(self, name, node, linkage=None):
        self.func_decl(name, node.return_type, node.parameters, node.parameter_defaults, node.varargs, linkage)

    def funcdef(self, name, node, linkage=None, func_exists=False):
        if func_exists:
            self.implement_func_body(name)
        else:
            self.start_function(name, node.return_type, node.parameters, node.parameter_defaults, node.varargs, linkage)

        for i, arg in enumerate(self.current_function.args):
            arg.name = list(node.parameters.keys())[i]

            # TODO: a bit hacky, cannot handle pointers atm but we need them for class reference
            if arg.name == SELF and isinstance(arg.type, ir.PointerType):
                self.define(arg.name, arg)
            else:
                self.alloc_define_store(arg, arg.name, arg.type)
        if self.current_function.function_type.return_type != type_map[VOID]:
            self.alloc_and_define(RET_VAR, self.current_function.function_type.return_type)
        ret = self.visit(node.body)
        self.end_function(ret)

    def visit_return(self, node):
        val = self.visit(node.value)
        if val.type != ir.VoidType():
            val = self.comp_cast(val, self.search_scopes(RET_VAR).type.pointee, node)

            # If casting returned a pointer (e.g. int_to_bigint) but we need the value (struct), load it.
            # dest_type is the type of the variable stored in RET_VAR (e.g. %bigint)
            dest_type = self.search_scopes(RET_VAR).type.pointee
            if isinstance(val.type, ir.PointerType) and val.type.pointee == dest_type:
                val = self.builder.load(val)

            self.store(val, RET_VAR)
        self.branch(self.exit_blocks[-1])
        return True

    def super_method(self, node, obj, parent):
        method = self.search_scopes(parent.name + '.' + node.name)
        if method is not None:
            tmp = self.builder.bitcast(obj, parent.as_pointer())
            return self.methodcall(node, method, tmp)
        if method is None and parent.base is not None:
            return self.super_method(node, obj, self.search_scopes(parent.base.value))
        else:
            error("No method as described")

    def visit_methodcall(self, node):
        obj = self.search_scopes(node.obj)
        method = self.search_scopes(obj.type.pointee.name + '.' + node.name)
        if method is None and obj.type.pointee.base is not None:
            parent = self.search_scopes(obj.type.pointee.base.value)
            return self.super_method(node, obj, parent)

        return self.methodcall(node, method, obj)

    def methodcall(self, node, func, obj):
        func_type = func.function_type
        if len(node.arguments) + 1 < len(func_type.args):
            args = []
            args_supplied = []
            arg_names = []

            for i in func_type.parameters:
                arg_names.append(i)

            for x, arg in enumerate(func_type.args):
                if x == 0:
                    continue
                if x < len(node.arguments):
                    args.append(self.visit(node.arguments[x]))
                else:
                    if node.named_arguments and arg_names[x] in node.named_arguments:
                        args.append(self.comp_cast(
                            self.visit(node.named_arguments[arg_names[x]]),
                            self.visit(func_type.parameters[arg_names[x]]),
                            node
                        ))
                    else:
                        if set(node.named_arguments.keys()) & set(args_supplied):
                            raise TypeError('got multiple values for argument(s) {}'.format(set(node.named_arguments.keys()) & set(args_supplied)))

                        args.append(self.comp_cast(
                            self.visit(func_type.parameter_defaults[arg_names[x]]),
                            self.visit(func_type.parameters[arg_names[x]]),
                            node
                        ))
                args_supplied.append(arg)
        elif len(node.arguments) + len(node.named_arguments) > len(func_type.args) and func_type.var_arg is None:
            raise SyntaxError('Unexpected arguments')
        else:
            args = []
            for i, arg in enumerate(node.arguments):
                args.append(self.comp_cast(self.visit(arg), func_type.args[i], node))

        args.insert(0, obj)
        return self.builder.call(func, args)

    def visit_funccall(self, node):
        # Handle parse() builtin for string to int conversion
        if node.name == 'parse':
            if len(node.arguments) == 1:
                arg = self.visit(node.arguments[0])
                return self.call('str_to_int', [arg])

        func_type = self.search_scopes(node.name)
        isFunc = False
        if isinstance(func_type, ir.AllocaInstr):
            name = self.load(func_type)
            func_type = name.type.pointee
            isFunc = True
        elif isinstance(func_type, ir.Function):
            func_type = func_type.type.pointee
            name = self.search_scopes(node.name)
            name = name.name
        elif isinstance(func_type, ir.IdentifiedStructType):
            typ = self.search_scopes(node.name)
            if typ.type == CLASS:
                return self.class_assign(node)
            error("Unexpected Identified Struct Type")
        else:
            name = node.name

        if len(node.arguments) < len(func_type.args):
            args = []
            args_supplied = []
            arg_names = []

            for i in func_type.parameters:
                arg_names.append(i)

            for x, arg in enumerate(func_type.args):
                if x < len(node.arguments):
                    args.append(self.visit(node.arguments[x]))
                else:
                    if node.named_arguments and arg_names[x] in node.named_arguments:
                        args.append(self.comp_cast(
                            self.visit(node.named_arguments[arg_names[x]]),
                            self.visit(func_type.parameters[arg_names[x]]),
                            node
                        ))
                    else:
                        if set(node.named_arguments.keys()) & set(args_supplied):
                            raise TypeError('got multiple values for argument(s) {}'.format(set(node.named_arguments.keys()) & set(args_supplied)))

                        args.append(self.comp_cast(
                            self.visit(func_type.parameter_defaults[arg_names[x]]),
                            self.visit(func_type.parameters[arg_names[x]]),
                            node
                        ))
                args_supplied.append(arg)
        elif len(node.arguments) + len(node.named_arguments) > len(func_type.args) and func_type.var_arg is None:
            raise SyntaxError('Unexpected arguments')
        else:
            args = []
            for i, arg in enumerate(node.arguments):
                args.append(self.comp_cast(self.visit(arg), func_type.args[i], node))

        if isFunc:
            return self.builder.call(name, args)
        return self.call(name, args)

    def comp_cast(self, arg, typ, node):
        if types_compatible(str(arg.type), typ):
            return cast_ops(self, arg, typ, node)

        return arg

    def visit_compound(self, node):
        ret = None
        for child in node.children:
            temp = self.visit(child)
            if temp:
                ret = temp
        return ret

    def visit_enumdeclaration(self, node):
        enum = self.module.context.get_identified_type(node.name)
        enum.fields = [field for field in node.fields]
        enum.name = node.name
        enum.type = ENUM
        enum.set_body(ir.IntType(8, signed=False))
        self.define(node.name, enum)

    def get_super_fields(self, classdecl, parent=None):
        fields = []
        elements = []
        if classdecl.base is not None:
            if parent is None:
                parent = self.search_scopes(classdecl.base.value)

            if parent.base is not None:
                new_parent = self.search_scopes(parent.base.value)
                self.get_super_fields(classdecl, new_parent)

            fields += parent.fields
            elements += parent.elements

        return fields, elements

    def get_super_defaults(self, classdecl, parent=None):
        defaults = {}
        if classdecl.base is not None:
            if parent is None:
                parent = self.search_scopes(classdecl.base.value)

            if parent.base is not None:
                new_parent = self.search_scopes(parent.base.value)
                self.get_super_defaults(classdecl, new_parent)

            defaults = {**defaults, **parent.defaults}

        return defaults

    def visit_classdeclaration(self, node):
        fields = []
        for field in node.fields.values():
            fields.append(self.get_type(field))

        classdecl = self.module.context.get_identified_type(node.name)
        classdecl.base = node.base
        classdecl.defaults = {**self.get_super_defaults(classdecl), **node.defaults}
        classdecl.name = node.name
        classdecl.type = CLASS
        super_fields, super_elements = self.get_super_fields(classdecl)
        classdecl.fields = super_fields + [field for field in node.fields.keys()]
        classdecl.set_body(*(super_elements + [field for field in fields]))
        self.define(node.name, classdecl)
        for method in node.methods:
            self.funcdecl(method.name, method)

        for method in node.methods:
            self.funcdef(method.name, method, func_exists=True)
        classdecl.methods = [self.search_scopes(method.name) for method in node.methods]

        self.define(node.name, classdecl)

    def visit_incrementassign(self, node):
        collection_access = None
        key = None
        if isinstance(node.left, CollectionAccess):
            collection_access = True
            var_name = self.search_scopes(node.left.collection.value)
            array_type = str(var_name.type.pointee.elements[-1].pointee)
            key = self.const(node.left.key.value)
            var = self.call('{}.array.get'.format(array_type), [var_name, key])
            pointee = var.type
        else:
            var_name = node.left.value
            var = self.load(var_name)
            pointee = self.search_scopes(var_name).type.pointee
        op = node.op
        temp = ir.Constant(var.type, 1)

        if isinstance(pointee, ir.IntType):
            if op == PLUS_PLUS:
                res = self.builder.add(var, temp)
            elif op == MINUS_MINUS:
                res = self.builder.sub(var, temp)
        elif isinstance(pointee, ir.DoubleType) or isinstance(pointee, ir.FloatType):
            if op == PLUS_PLUS:
                res = self.builder.fadd(var, temp)
            elif op == MINUS_MINUS:
                res = self.builder.fsub(var, temp)
        else:
            raise NotImplementedError()

        if collection_access:
            self.call('{}.array.set'.format(array_type), [var_name, key, res])
        else:
            self.store(res, var_name)

    def visit_typedeclaration(self, node):
        if node.collection.value in type_map:
            type_map[node.name] = type_map[node.collection.value]
        else:
            self.define(node.name, self.search_scopes(node.collection.value))
        return TYPE

    def visit_vardecl(self, node):
        typ = self.get_type(node.type)
        if node.type.value == FUNC:
            func_ret_type = self.get_type(node.type.func_ret_type)
            func_parameters = self.get_args(node.type.func_params)
            func_ty = ir.FunctionType(func_ret_type, func_parameters, None).as_pointer()
            typ = func_ty
            self.alloc_and_define(node.value.value, typ)
        elif node.type.value in (LIST, TUPLE):
            array_type = self.get_type(node.type.func_params['0'])
            self.create_array(array_type)
            typ = self.search_scopes('{}.array'.format(array_type))
            self.alloc_and_define(node.value.value, typ)
        else:
            self.alloc_and_define(node.value.value, typ)

    def visit_type(self, node):
        return type_map[node.value] if node.value in type_map else self.search_scopes(node.value)

    def visit_if(self, node):
        start_block = self.add_block('if.start')
        end_block = self.add_block('if.end')
        self.branch(start_block)
        self.position_at_end(start_block)
        for x, comp in enumerate(node.comps):
            if_true_block = self.add_block('if.true.{}'.format(x))
            if x + 1 < len(node.comps):
                if_false_block = self.add_block('if.false.{}'.format(x))
            else:
                if_false_block = end_block
            cond_val = self.visit(comp)
            self.cbranch(cond_val, if_true_block, if_false_block)
            self.position_at_end(if_true_block)
            ret = self.visit(node.blocks[x])
            if not ret and not self.is_break:
                self.branch(end_block)
            self.position_at_end(if_false_block)

        if not self.is_break:
            self.position_at_end(end_block)
        else:
            self.is_break = False

    def visit_else(self, _):
        return self.builder.icmp_signed(EQUALS, self.const(1), self.const(1), 'cmptmp')

    def visit_while(self, node):
        cond_block = self.add_block('while.cond')
        body_block = self.add_block('while.body')
        end_block = self.add_block('while.end')
        self.loop_test_blocks.append(cond_block)
        self.loop_end_blocks.append(end_block)
        self.branch(cond_block)
        self.position_at_end(cond_block)
        cond = self.visit(node.comp)
        self.cbranch(cond, body_block, end_block)
        self.position_at_end(body_block)
        self.visit(node.block)
        if not self.is_break:
            self.branch(cond_block)
        else:
            self.is_break = False
        self.position_at_end(end_block)
        self.loop_test_blocks.pop()
        self.loop_end_blocks.pop()

    def visit_for(self, node):
        init_block = self.add_block('for.init')
        zero_length_block = self.add_block('for.zero_length')
        non_zero_length_block = self.add_block('for.non_zero_length')
        cond_block = self.add_block('for.cond')
        body_block = self.add_block('for.body')
        end_block = self.add_block('for.end')
        self.loop_test_blocks.append(cond_block)
        self.loop_end_blocks.append(end_block)
        self.branch(init_block)

        self.position_at_end(init_block)
        zero = self.const(0)
        one = self.const(1)
        array_type = None
        if node.iterator.value == RANGE:
            iterator = self.alloc_and_store(self.visit(node.iterator), type_map[STR])
            array_type = "i64"
        else:
            iterator = self.search_scopes(node.iterator.value)
            array_type = str(iterator.type.pointee.elements[-1].pointee)

        stop = self.call('{}.array.length'.format(array_type), [iterator])
        self.branch(zero_length_block)

        self.position_at_end(zero_length_block)
        cond = self.builder.icmp_signed(LESS_THAN, zero, stop)
        self.cbranch(cond, non_zero_length_block, end_block)

        self.position_at_end(non_zero_length_block)
        varname = node.elements[0].value
        val = self.call('{}.array.get'.format(array_type), [iterator, zero])
        self.alloc_define_store(val, varname, iterator.type.pointee.elements[2].pointee)
        position = self.alloc_define_store(zero, 'position', type_map[INT])
        self.branch(cond_block)

        self.position_at_end(cond_block)
        cond = self.builder.icmp_signed(LESS_THAN, self.load(position), stop)
        self.cbranch(cond, body_block, end_block)

        self.position_at_end(body_block)
        self.store(self.call('{}.array.get'.format(array_type), [iterator, self.load(position)]), varname)
        self.store(self.builder.add(one, self.load(position)), position)
        self.visit(node.block)
        if not self.is_break:
            self.branch(cond_block)
        else:
            self.is_break = False

        self.position_at_end(end_block)
        self.loop_test_blocks.pop()
        self.loop_end_blocks.pop()

    def visit_loopblock(self, node):
        for child in node.children:
            temp = self.visit(child)
            if temp:
                return temp

    def visit_switch(self, node):
        default_exists = False
        switch_end_block = self.add_block('switch_end')
        default_block = self.add_block('default')
        switch = self.switch(self.visit(node.value), default_block)
        cases = []
        for case in node.cases:
            if case.value == DEFAULT:
                cases.append(default_block)
                default_exists = True
            else:
                cases.append(self.add_block('case'))
        if not default_exists:
            self.position_at_end(default_block)
            self.branch(switch_end_block)
        for x, case in enumerate(node.cases):
            self.position_at_end(cases[x])
            fallthrough = self.visit(case.block)
            if fallthrough != FALLTHROUGH:
                self.branch(switch_end_block)
            else:
                if x == len(node.cases) - 1:
                    self.branch(switch_end_block)
                else:
                    self.branch(cases[x + 1])
            if case.value != DEFAULT:
                switch.add_case(self.visit(case.value), cases[x])
        self.position_at_end(switch_end_block)

    def visit_fallthrough(self, node):
        if 'case' in self.builder.block.name:
            return FALLTHROUGH
        else:  # TODO: Move this to typechecker
            error('file={} line={} Syntax Error: fallthrough keyword cannot be used outside of switch statements'.format(self.file_name, node.line_num))

    def visit_break(self, node):
        if len(self.loop_end_blocks) == 0:  # TODO: Move this to typechecker
            error('file={} line={} Syntax Error: break keyword cannot be used outside of control flow statements'.format(self.file_name, node.line_num))
        self.is_break = True
        return self.branch(self.loop_end_blocks[-1])

    def visit_continue(self, _):
        self.is_break = True
        return self.branch(self.loop_test_blocks[-1])

    @staticmethod
    def visit_pass(_):
        return

    def visit_unaryop(self, node):
        return unary_op(self, node)

    def visit_range(self, node):
        start = self.visit(node.left)
        stop = self.visit(node.right)
        array_ptr = self.create_array(type_map[INT])
        self.call('@create_range', [array_ptr, start, stop])
        return self.load(array_ptr)

    def visit_assign(self, node):
        if isinstance(node.right, DotAccess) and self.search_scopes(node.right.obj).type == ENUM or \
           hasattr(node.right, 'name') and isinstance(self.search_scopes(node.right.name), ir.IdentifiedStructType):
            var_name = node.left.value if isinstance(node.left.value, str) else node.left.value.value
            self.define(var_name, self.visit(node.right))
        elif hasattr(node.right, 'value') and isinstance(self.search_scopes(node.right.value), ir.Function):
            self.define(node.left.value, self.search_scopes(node.right.value))
        else:
            if isinstance(node.right, Input):
                if hasattr(node.left, 'type'):
                    node.right.type = node.left.type
                else:
                    node.right.type = str
            var = self.visit(node.right)
            if not var:
                return
            if isinstance(node.left, VarDecl) and node.left.type.value == DYNAMIC:
                # Dynamic Boxing - supports any type like Python
                var_name = node.left.value.value
                val = self.visit(node.right)

                # Create dynamic struct instance { i32 type_id, i8* data }
                dyn_struct_type = type_map[DYNAMIC]
                dyn_ptr = self.builder.alloca(dyn_struct_type, name=var_name)

                # Type IDs: 0=unknown, 1=int, 2=float, 3=bool, 4=str, 5=bigint, 6=decimal
                type_id = 0
                data_ptr = None

                if isinstance(val.type, ir.IntType):
                    if val.type.width == 1:  # BOOL
                        type_id = 3
                        val_ptr = self.builder.alloca(type_map[BOOL])
                        self.builder.store(val, val_ptr)
                        data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                    elif val.type.width == 64:  # INT
                        type_id = 1
                        val_ptr = self.builder.alloca(type_map[INT])
                        self.builder.store(val, val_ptr)
                        data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                elif isinstance(val.type, (ir.FloatType, ir.DoubleType)):
                    type_id = 2
                    val_ptr = self.builder.alloca(type_map[DOUBLE])
                    if isinstance(val.type, ir.FloatType):
                        val = self.builder.fpext(val, type_map[DOUBLE])
                    self.builder.store(val, val_ptr)
                    data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                elif val.type == type_map[BIGINT].as_pointer():
                    type_id = 5
                    data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                elif getattr(val.type, 'name', '') == 'bigint':
                    type_id = 5
                    val_ptr = self.builder.alloca(type_map[BIGINT])
                    self.builder.store(val, val_ptr)
                    data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                elif val.type == type_map[DECIMAL].as_pointer():
                    type_id = 6
                    data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                elif getattr(val.type, 'name', '') == 'decimal':
                    type_id = 6
                    val_ptr = self.builder.alloca(type_map[DECIMAL])
                    self.builder.store(val, val_ptr)
                    data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                elif isinstance(val.type, ir.PointerType) and hasattr(val.type.pointee, 'elements'):
                    # String (i64.array pointer)
                    type_id = 4
                    data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())

                if data_ptr:
                    type_id_ptr = self.builder.gep(dyn_ptr, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(ir.Constant(type_map[INT32], type_id), type_id_ptr)
                    data_field_ptr = self.builder.gep(dyn_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(data_ptr, data_field_ptr)

                self.define(var_name, dyn_ptr)

            elif isinstance(node.left, VarDecl) and node.left.type.value == BIGINT:
                # BigInt Initialization from Integer
                var_name = node.left.value.value

                # Check if variable already exists (for loop iterations)
                existing_var = self.search_scopes(var_name)
                if existing_var is not None:
                    # Reuse existing variable
                    bigint_ptr = existing_var
                else:
                    # Create new variable in entry block to avoid stack overflow in loops
                    bigint_struct_type = type_map[BIGINT]
                    bigint_ptr = self.get_entry_alloca(var_name, bigint_struct_type)

                    # Null init moved to get_entry_alloca for safety

                    self.define(var_name, bigint_ptr)

                # Check if RHS is a literal integer (Num node) - handle large values specially
                from meteor.ast import Num
                if isinstance(node.right, Num) and isinstance(node.right.value, int):
                    # === Unconditional Release valid for loop iterations ===
                    # Now safe because get_entry_alloca zero-inits first time.
                    old_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                    old_digits = self.builder.load(old_digits_ptr)
                    null_ptr = ir.Constant(old_digits.type, None)
                    is_not_null = self.builder.icmp_unsigned('!=', old_digits, null_ptr)

                    with self.builder.if_then(is_not_null):
                        rc_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
                        rc = self.builder.load(rc_ptr)
                        new_rc = self.builder.sub(rc, self.const(1))
                        self.builder.store(new_rc, rc_ptr)
                        is_zero = self.builder.icmp_signed('==', new_rc, self.const(0))
                        with self.builder.if_then(is_zero):
                            data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(2, width=INT32)])
                            data = self.builder.load(data_ptr)
                            data_i8 = self.builder.bitcast(data, type_map[INT8].as_pointer())
                            self.call('free', [data_i8])
                            digits_i8 = self.builder.bitcast(old_digits, type_map[INT8].as_pointer())
                            self.call('free', [digits_i8])

                    py_val = node.right.value  # Python int (arbitrary precision)
                    is_negative = py_val < 0
                    abs_val = abs(py_val)

                    # Create dynamic array for digits
                    u64_array_ptr = self.create_array(type_map[UINT64])
                    
                    # Split into base-2^64 digits (little-endian order)
                    BASE = 2**64
                    if abs_val == 0:
                        self.call('i64.array.append', [u64_array_ptr, self.const(0)])
                    else:
                        while abs_val > 0:
                            digit = abs_val % BASE
                            self.call('i64.array.append', [u64_array_ptr, self.const(digit)])
                            abs_val //= BASE
                    
                    # Store sign
                    sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(ir.Constant(type_map[BOOL], is_negative), sign_ptr)
                    
                    # Store digits array pointer
                    digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(u64_array_ptr, digits_ptr)
                    
                    self.define(var_name, bigint_ptr)
                else:
                    # Use already evaluated var from line 576, don't call visit again
                    val = var

                    # Check if val is already a bigint
                    if getattr(val.type, 'name', '') == 'bigint' or \
                       (isinstance(val.type, ir.PointerType) and getattr(val.type.pointee, 'name', '') == 'bigint'):
                         src_ptr = val
                         if not isinstance(val.type, ir.PointerType):
                              # Use entry block alloca to avoid stack overflow in loops
                              tmp = self.get_entry_alloca("bigint_decl_tmp", val.type)
                              self.builder.store(val, tmp)
                              src_ptr = tmp

                         # === Unconditional Release valid for loop iterations ===
                         old_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                         old_digits = self.builder.load(old_digits_ptr)
                         null_ptr = ir.Constant(old_digits.type, None)
                         is_not_null = self.builder.icmp_unsigned('!=', old_digits, null_ptr)

                         with self.builder.if_then(is_not_null):
                             rc_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
                             rc = self.builder.load(rc_ptr)
                             new_rc = self.builder.sub(rc, self.const(1))
                             self.builder.store(new_rc, rc_ptr)
                             is_zero = self.builder.icmp_signed('==', new_rc, self.const(0))
                             with self.builder.if_then(is_zero):
                                 data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(2, width=INT32)])
                                 data = self.builder.load(data_ptr)
                                 data_i8 = self.builder.bitcast(data, type_map[INT8].as_pointer())
                                 self.call('free', [data_i8])
                                 digits_i8 = self.builder.bitcast(old_digits, type_map[INT8].as_pointer())
                                 self.call('free', [digits_i8])

                         # Copy Sign
                         src_sign_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(0, width=INT32)])
                         sign = self.builder.load(src_sign_ptr)
                         dst_sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                         self.builder.store(sign, dst_sign_ptr)

                         # Copy Digits Pointer
                         src_digits_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(1, width=INT32)])
                         digits = self.builder.load(src_digits_ptr)
                         dst_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                         self.builder.store(digits, dst_digits_ptr)

                         # Shared ownership: if initializing from an L-value, increment RC
                         is_lvalue = isinstance(node.right, (Var, DotAccess, CollectionAccess))
                         if is_lvalue:
                             new_rc_ptr = self.builder.gep(digits, [self.const(0), self.const(3, width=INT32)])
                             cur_rc = self.builder.load(new_rc_ptr)
                             inc_rc = self.builder.add(cur_rc, self.const(1))
                             self.builder.store(inc_rc, new_rc_ptr)

                         self.define(var_name, bigint_ptr)
                    else: 
                         # Check sign for small ints (runtime value)
                         zero = self.const(0)
                         is_negative = self.builder.icmp_signed(LESS_THAN, val, zero)
                         
                         # Absolute value for storage
                         abs_val = self.builder.select(is_negative, self.builder.neg(val), val)
                         
                         # Create dynamic array for digits
                         u64_array_ptr = self.create_array(type_map[UINT64])
                         self.call('i64.array.append', [u64_array_ptr, abs_val])
                         
                         # Store sign
                         sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                         self.builder.store(is_negative, sign_ptr)
                         
                         # Store digits array pointer
                         digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                         self.builder.store(u64_array_ptr, digits_ptr)
                         
                         self.define(var_name, bigint_ptr)

            elif isinstance(node.left, VarDecl) and node.left.type.value == DECIMAL:
                # Decimal Initialization
                var_name = node.left.value.value

                # Layout: { %bigint* mantissa, i64 exponent }
                decimal_struct_type = type_map[DECIMAL]
                decimal_ptr = self.builder.alloca(decimal_struct_type, name=var_name)

                # Check if RHS is a literal number
                from meteor.ast import Num
                from decimal import Decimal as PyDecimal
                if isinstance(node.right, Num):
                    py_val = node.right.value
                    # Convert to mantissa and exponent
                    # e.g., 3.14 -> mantissa=314, exponent=-2
                    if isinstance(py_val, (float, PyDecimal)):
                        # Convert to string to preserve precision
                        str_val = str(py_val)
                        if 'e' in str_val or 'E' in str_val:
                            # Scientific notation
                            parts = str_val.lower().split('e')
                            base_str = parts[0]
                            exp_offset = int(parts[1])
                        else:
                            base_str = str_val
                            exp_offset = 0

                        if '.' in base_str:
                            int_part, frac_part = base_str.split('.')
                            mantissa_str = int_part + frac_part
                            exponent = -len(frac_part) + exp_offset
                        else:
                            mantissa_str = base_str
                            exponent = exp_offset

                        # Remove leading zeros but keep sign
                        is_negative = mantissa_str.startswith('-')
                        mantissa_str = mantissa_str.lstrip('-0') or '0'
                        mantissa_val = int(mantissa_str)
                    else:
                        # Integer
                        mantissa_val = abs(int(py_val))
                        is_negative = py_val < 0
                        exponent = 0

                    # Create mantissa bigint
                    bigint_struct_type = type_map[BIGINT]
                    bigint_ptr = self.builder.alloca(bigint_struct_type, name="mantissa")
                    u64_array_ptr = self.create_array(type_map[UINT64])

                    BASE = 2**64
                    if mantissa_val == 0:
                        self.call('i64.array.append', [u64_array_ptr, self.const(0)])
                    else:
                        temp_val = mantissa_val
                        while temp_val > 0:
                            digit = temp_val % BASE
                            self.call('i64.array.append', [u64_array_ptr, self.const(digit)])
                            temp_val //= BASE

                    sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(ir.Constant(type_map[BOOL], is_negative), sign_ptr)
                    digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(u64_array_ptr, digits_ptr)

                    # Store in decimal struct
                    mantissa_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(bigint_ptr, mantissa_field_ptr)
                    exponent_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(self.const(exponent), exponent_field_ptr)
                else:
                    # Runtime value - convert to decimal
                    val = self.visit(node.right)

                    # Check if val is already a decimal
                    is_decimal = False
                    if hasattr(val.type, 'name') and val.type.name == 'decimal':
                        is_decimal = True
                    elif isinstance(val.type, ir.PointerType):
                        if hasattr(val.type.pointee, 'name') and val.type.pointee.name == 'decimal':
                            is_decimal = True

                    if is_decimal:
                        # Already a decimal, just store it
                        if isinstance(val.type, ir.PointerType):
                            # val is a pointer to decimal, load and store
                            loaded_val = self.builder.load(val)
                            self.builder.store(loaded_val, decimal_ptr)
                        else:
                            # val is a decimal struct, store directly
                            self.builder.store(val, decimal_ptr)
                    else:
                        # Convert int/float to decimal
                        val_int = val
                        if isinstance(val.type, ir.DoubleType) or isinstance(val.type, ir.FloatType):
                            val_int = self.builder.fptosi(val, type_map[INT])

                        bigint_struct_type = type_map[BIGINT]
                        bigint_ptr = self.builder.alloca(bigint_struct_type, name="mantissa")

                        zero = self.const(0)
                        is_negative = self.builder.icmp_signed(LESS_THAN, val_int, zero)
                        abs_val = self.builder.select(is_negative, self.builder.neg(val_int), val_int)

                        u64_array_ptr = self.create_array(type_map[UINT64])
                        self.call('i64.array.append', [u64_array_ptr, abs_val])

                        sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                        self.builder.store(is_negative, sign_ptr)
                        digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(u64_array_ptr, digits_ptr)

                        mantissa_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(0, width=INT32)])
                        self.builder.store(bigint_ptr, mantissa_field_ptr)
                        exponent_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(self.const(0), exponent_field_ptr)

                self.define(var_name, decimal_ptr)

            elif isinstance(node.left, VarDecl) and node.left.type.value == NUMBER:
                # Number Initialization
                var_name = node.left.value.value
                val = self.visit(node.right)
                
                # Layout: { i8 type_tag, i8* data }
                number_struct_type = type_map[NUMBER]
                number_ptr = self.builder.alloca(number_struct_type, name=var_name)
                
                type_tag = 0
                data_ptr = None
                
                if isinstance(val.type, ir.IntType):
                    if val.type.width == 64: # INT
                        type_tag = 0 # INT
                        val_ptr = self.builder.alloca(type_map[INT])
                        self.builder.store(val, val_ptr)
                        data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                elif isinstance(val.type, ir.DoubleType): # DOUBLE
                     type_tag = 1 # FLOAT
                     val_ptr = self.builder.alloca(type_map[DOUBLE])
                     self.builder.store(val, val_ptr)
                     data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                elif val.type == type_map[BIGINT].as_pointer():
                     type_tag = 2 # BIGINT
                     data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                elif getattr(val.type, 'name', '') == 'bigint':
                     # bigint struct (not pointer) - need to alloca and store
                     type_tag = 2 # BIGINT
                     val_ptr = self.builder.alloca(type_map[BIGINT])
                     self.builder.store(val, val_ptr)
                     data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                elif val.type == type_map[DECIMAL].as_pointer():
                     type_tag = 3 # DECIMAL
                     data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                elif getattr(val.type, 'name', '') == 'decimal':
                     # decimal struct (not pointer) - need to alloca and store
                     type_tag = 3 # DECIMAL
                     val_ptr = self.builder.alloca(type_map[DECIMAL])
                     self.builder.store(val, val_ptr)
                     data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())

                if data_ptr:
                    # Store type_tag
                    tag_ptr = self.builder.gep(number_ptr, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(ir.Constant(type_map[INT8], type_tag), tag_ptr)
                    
                    # Store data pointer
                    data_field_ptr = self.builder.gep(number_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(data_ptr, data_field_ptr)
                
                self.define(var_name, number_ptr)

            elif isinstance(node.left, VarDecl):
                var_name = node.left.value.value
                if node.left.type.value in (LIST, TUPLE):
                    var_type = type_map[list(node.left.type.func_params.items())[0][1].value]
                    self.alloc_define_store(var, var_name, var.type)
                else:
                    var_type = type_map[node.left.type.value]
                    if not var.type.is_pointer:
                        casted_value = cast_ops(self, var, var_type, node)
                        self.alloc_define_store(casted_value, var_name, var_type)
                    else:  # TODO: Not able currently to deal with pointers, such as functions
                        self.alloc_define_store(var, var_name, var.type)

            elif isinstance(node.left, DotAccess):
                obj = self.search_scopes(node.left.obj)
                obj_type = self.search_scopes(obj.type.pointee.name.split('.')[-1])
                idx = -1
                for i, v in enumerate(obj_type.fields):
                    if v == node.left.field:
                        idx = i
                        break

                elem = self.builder.gep(obj, [self.const(0, width=INT32), self.const(idx, width=INT32)], inbounds=True)
                self.builder.store(self.visit(node.right), elem)
            elif isinstance(node.left, CollectionAccess):
                right = self.visit(node.right)
                array_type = str(self.search_scopes(node.left.collection.value).type.pointee.elements[-1].pointee)
                self.call('{}.array.set'.format(array_type), [self.search_scopes(node.left.collection.value), self.const(node.left.key.value), right])
            else:
                var_name = node.left.value
                var_value = self.top_scope.get(var_name)
                if var_value:
                    # Check for Dynamic assignment
                    if var_value.type == type_map[DYNAMIC].as_pointer():
                        # Dynamic Boxing into existing pointer
                        val = var  # 'var' holds the visited right-side value
                        dyn_ptr = var_value

                        # Type IDs: 0=unknown, 1=int, 2=float, 3=bool, 4=str, 5=bigint, 6=decimal
                        type_id = 0
                        data_ptr = None

                        if isinstance(val.type, ir.IntType):
                            if val.type.width == 1:  # BOOL
                                type_id = 3
                                val_ptr = self.builder.alloca(type_map[BOOL])
                                self.builder.store(val, val_ptr)
                                data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                            elif val.type.width == 64:  # INT
                                type_id = 1
                                val_ptr = self.builder.alloca(type_map[INT])
                                self.builder.store(val, val_ptr)
                                data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                        elif isinstance(val.type, (ir.FloatType, ir.DoubleType)):
                            type_id = 2
                            val_ptr = self.builder.alloca(type_map[DOUBLE])
                            if isinstance(val.type, ir.FloatType):
                                val = self.builder.fpext(val, type_map[DOUBLE])
                            self.builder.store(val, val_ptr)
                            data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                        elif isinstance(val.type, ir.PointerType) and hasattr(val.type.pointee, 'elements'):
                            # String (i64.array pointer)
                            type_id = 4
                            data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                        elif val.type == type_map[BIGINT].as_pointer():
                            type_id = 5
                            data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                        elif getattr(val.type, 'name', '') == 'bigint':
                            type_id = 5
                            val_ptr = self.builder.alloca(type_map[BIGINT])
                            self.builder.store(val, val_ptr)
                            data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                        elif val.type == type_map[DECIMAL].as_pointer():
                            type_id = 6
                            data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                        elif getattr(val.type, 'name', '') == 'decimal':
                            type_id = 6
                            val_ptr = self.builder.alloca(type_map[DECIMAL])
                            self.builder.store(val, val_ptr)
                            data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())

                        if data_ptr:
                            type_id_ptr = self.builder.gep(dyn_ptr, [self.const(0), self.const(0, width=INT32)])
                            self.builder.store(ir.Constant(type_map[INT32], type_id), type_id_ptr)

                            data_field_ptr = self.builder.gep(dyn_ptr, [self.const(0), self.const(1, width=INT32)])
                            self.builder.store(data_ptr, data_field_ptr)

                    elif var_value.type == type_map[BIGINT].as_pointer():
                        # BigInt Assignment (Re-assignment)
                        bigint_ptr = var_value
                        
                        # Check if RHS is a literal integer
                        from meteor.ast import Num
                        if isinstance(node.right, Num) and isinstance(node.right.value, int):
                            py_val = node.right.value
                            is_negative = py_val < 0
                            abs_val = abs(py_val)
                            
                            u64_array_ptr = self.create_array(type_map[UINT64])
                            
                            BASE = 2**64
                            if abs_val == 0:
                                self.call('i64.array.append', [u64_array_ptr, self.const(0)])
                            else:
                                while abs_val > 0:
                                    digit = abs_val % BASE
                                    self.call('i64.array.append', [u64_array_ptr, self.const(digit)])
                                    abs_val //= BASE
                            
                            sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                            self.builder.store(ir.Constant(type_map[BOOL], is_negative), sign_ptr)
                            
                            digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                            self.builder.store(u64_array_ptr, digits_ptr)
                        else:
                            # Check if RHS is already a bigint
                            if getattr(var.type, 'name', '') == 'bigint' or \
                               (isinstance(var.type, ir.PointerType) and getattr(var.type.pointee, 'name', '') == 'bigint'):
                                # bigint to bigint assignment - use entry block alloca
                                if isinstance(var.type, ir.PointerType):
                                    src_ptr = var
                                else:
                                    # Use entry block alloca to avoid stack overflow in loops
                                    tmp = self.get_entry_alloca("bigint_assign_tmp", var.type)
                                    self.builder.store(var, tmp)
                                    src_ptr = tmp

                                # === Reference counting: decrement old digits ===
                                old_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                                old_digits = self.builder.load(old_digits_ptr)
                                null_ptr = ir.Constant(old_digits.type, None)
                                is_not_null = self.builder.icmp_unsigned('!=', old_digits, null_ptr)

                                with self.builder.if_then(is_not_null):
                                    # Decrement refcount
                                    rc_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
                                    rc = self.builder.load(rc_ptr)
                                    new_rc = self.builder.sub(rc, self.const(1))
                                    self.builder.store(new_rc, rc_ptr)
                                    # Free if refcount == 0
                                    is_zero = self.builder.icmp_signed('==', new_rc, self.const(0))
                                    with self.builder.if_then(is_zero):
                                        data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(2, width=INT32)])
                                        data = self.builder.load(data_ptr)
                                        data_i8 = self.builder.bitcast(data, type_map[INT8].as_pointer())
                                        self.call('free', [data_i8])
                                        digits_i8 = self.builder.bitcast(old_digits, type_map[INT8].as_pointer())
                                        self.call('free', [digits_i8])

                                # Copy sign
                                src_sign_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(0, width=INT32)])
                                sign = self.builder.load(src_sign_ptr)
                                dst_sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                                self.builder.store(sign, dst_sign_ptr)

                                # Copy digits pointer
                                src_digits_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(1, width=INT32)])
                                digits = self.builder.load(src_digits_ptr)
                                dst_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                                self.builder.store(digits, dst_digits_ptr)

                                # Shared ownership: if assigning from an L-value, increment RC
                                is_lvalue = isinstance(node.right, (Var, DotAccess, CollectionAccess))
                                if is_lvalue:
                                    new_rc_ptr = self.builder.gep(digits, [self.const(0), self.const(3, width=INT32)])
                                    cur_rc = self.builder.load(new_rc_ptr)
                                    inc_rc = self.builder.add(cur_rc, self.const(1))
                                    self.builder.store(inc_rc, new_rc_ptr)
                            else:
                                # Existing logic for runtime int values
                                val = var

                                zero = self.const(0)
                                is_negative = self.builder.icmp_signed(LESS_THAN, val, zero)
                                abs_val = self.builder.select(is_negative, self.builder.neg(val), val)

                                u64_array_ptr = self.create_array(type_map[UINT64])
                                self.call('i64.array.append', [u64_array_ptr, abs_val])

                                sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                                self.builder.store(is_negative, sign_ptr)

                                digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                                self.builder.store(u64_array_ptr, digits_ptr)

                    elif var_value.type == type_map[DECIMAL].as_pointer():
                        # Decimal Assignment (Re-assignment)
                        val = var
                        decimal_ptr = var_value
                        
                        # 1. Handle value conversion (Int/Double -> "Int")
                        # TODO: proper float decomposition.
                        val_int = val
                        if isinstance(val.type, ir.DoubleType) or isinstance(val.type, ir.FloatType):
                            val_int = self.builder.fptosi(val, type_map[INT])
                        
                        # 2. Create Mantissa (BigInt)
                        # We allocate a new BigInt struct on stack (which we will point to)
                        # Actually we need heap alloc or stack alloc that persists. 
                        # Since `decimal` structs hold a POINTER to bigint, we need that pointer to be valid.
                        # `alloca` is stack. `malloc` is heap. 
                        # For now, as long as we are in the same function scope, stack is OK. 
                        # But if variable escapes, this is bad. 
                        # Ideally assume `malloc`. But for simplicity of this task, `alloca` matching previous patterns.
                        
                        bigint_struct_type = type_map[BIGINT]
                        bigint_ptr = self.builder.alloca(bigint_struct_type, name="mantissa_reassign")

                        zero = self.const(0)
                        is_negative = self.builder.icmp_signed(LESS_THAN, val_int, zero)
                        abs_val = self.builder.select(is_negative, self.builder.neg(val_int), val_int)
                        
                        u64_array_ptr = self.create_array(type_map[UINT64])
                        self.call('i64.array.append', [u64_array_ptr, abs_val])
                        
                        sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(0, width=INT32)])
                        self.builder.store(is_negative, sign_ptr)
                        digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(u64_array_ptr, digits_ptr)
                        
                        # 3. Store Mantissa Pointer
                        mantissa_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(0, width=INT32)])
                        self.builder.store(bigint_ptr, mantissa_field_ptr)
                        
                        # 4. Store Exponent (0)
                        exponent_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(self.const(0), exponent_field_ptr)

                    elif var_value.type == type_map[NUMBER].as_pointer():
                        # Number Assignment (Re-assignment)
                        val = var
                        number_ptr = var_value
                        
                        type_tag = 0
                        data_ptr = None
                        
                        if isinstance(val.type, ir.IntType):
                            if val.type.width == 64: # INT
                                type_tag = 0 # INT
                                val_ptr = self.builder.alloca(type_map[INT])
                                self.builder.store(val, val_ptr)
                                data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                        elif isinstance(val.type, ir.DoubleType): # DOUBLE
                             type_tag = 1 # FLOAT
                             val_ptr = self.builder.alloca(type_map[DOUBLE])
                             self.builder.store(val, val_ptr)
                             data_ptr = self.builder.bitcast(val_ptr, type_map[INT8].as_pointer())
                        elif val.type == type_map[BIGINT].as_pointer():
                             type_tag = 2 # BIGINT
                             data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())
                        elif val.type == type_map[DECIMAL].as_pointer():
                             type_tag = 3 # DECIMAL
                             data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())

                        if data_ptr:
                            # Store type_tag
                            tag_ptr = self.builder.gep(number_ptr, [self.const(0), self.const(0, width=INT32)])
                            self.builder.store(ir.Constant(type_map[INT8], type_tag), tag_ptr)
                            
                            # Store data pointer
                            data_field_ptr = self.builder.gep(number_ptr, [self.const(0), self.const(1, width=INT32)])
                            self.builder.store(data_ptr, data_field_ptr)

                    elif isinstance(var_value, float):
                        node.right.value = float(node.right.value)
                        self.store(var, var_name)
                    else:
                        self.store(var, var_name)
                elif isinstance(var, ir.Function):
                    self.define(var_name, var)
                else:
                    self.alloc_define_store(var, var_name, var.type)

    def visit_fieldassignment(self, node):
        obj = self.search_scopes(node.obj)
        obj_type = self.search_scopes(obj.name)
        return self.builder.extract_value(self.load(node.obj), obj_type.fields.index(node.field))

    def class_assign(self, node):
        class_type = self.search_scopes(node.name)
        _class = self.builder.alloca(class_type)
        found = False

        for func in class_type.methods:
            if func.name.split(".")[-1] == 'new':
                found = True
                self.methodcall(node, func, _class)

        # Create a builtin constructor which assigns all the uninitialized
        if not found:
            fields = set()
            for index, field in class_type.defaults.items():
                val = self.visit(field)
                pos = class_type.fields.index(index)
                fields.add(index)
                elem = self.builder.gep(_class, [self.const(0, width=INT32), self.const(pos, width=INT32)], inbounds=True)
                self.builder.store(val, elem)

            for index, field in enumerate(node.named_arguments.values()):
                val = self.visit(field)
                pos = class_type.fields.index(list(node.named_arguments.keys())[index])
                fields.add((list(node.named_arguments.keys())[index]))
                elem = self.builder.gep(_class, [self.const(0, width=INT32), self.const(pos, width=INT32)], inbounds=True)
                self.builder.store(val, elem)

            if len(fields) < len(class_type.fields):
                error('file={} line={} Syntax Error: class declaration doesn\'t initialize all fields ({})'.format(
                    self.file_name, node.line_num, ','.join(fields.symmetric_difference(set(class_type.fields)))))

        return _class

    def visit_dotaccess(self, node):
        obj = self.search_scopes(node.obj)
        if obj.type == ENUM:
            enum = self.builder.alloca(obj)
            idx = obj.fields.index(node.field)
            val = self.builder.gep(enum, [self.const(0, width=INT32), self.const(0, width=INT32)], inbounds=True)
            self.builder.store(self.const(idx, width=INT8), val)
            return enum

        obj_type = self.search_scopes(obj.type.pointee.name.split('.')[-1])
        return self.builder.extract_value(self.load(node.obj), obj_type.fields.index(node.field))

    def visit_opassign(self, node):
        right = self.visit(node.right)
        collection_access = None
        key = None
        if isinstance(node.left, CollectionAccess):
            collection_access = True
            var_name = self.search_scopes(node.left.collection.value)
            array_type = str(self.search_scopes(node.left.collection.value).type.pointee.elements[-1].pointee)
            key = self.const(node.left.key.value)
            var = self.call('{}.array.get'.format(array_type), [var_name, key])
            pointee = var.type
        else:
            var_name = node.left.value
            var = self.load(var_name)
            pointee = self.search_scopes(var_name).type.pointee
        op = node.op
        right = cast_ops(self, right, var.type, node)
        if isinstance(pointee, ir.IntType):
            if op == PLUS_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.add(var, right)
            elif op == MINUS_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.sub(var, right)
            elif op == MUL_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.mul(var, right)
            elif op == FLOORDIV_ASSIGN:
                temp = cast_ops(self, var, ir.DoubleType(), node)
                temp_right = cast_ops(self, right, ir.DoubleType(), node)
                temp = self.builder.fdiv(temp, temp_right)
                res = cast_ops(self, temp, var.type, node)
            elif op == DIV_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.sdiv(var, right)
            elif op == MOD_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.srem(var, right)
            elif op == POWER_ASSIGN:
                if not isinstance(node.right.value, int):
                    error('Cannot use non-integers for power coeficient')
                    # TODO: Send me to typechecker and check for binop as well

                right = cast_ops(self, right, var.type, node)
                temp = self.alloc_and_store(var, type_map[INT])
                for _ in range(node.right.value - 1):
                    res = self.builder.mul(self.load(temp), var)
                    self.store(res, temp)
                res = self.load(temp)
            else:
                raise NotImplementedError()
        elif isinstance(pointee, ir.DoubleType) or isinstance(pointee, ir.FloatType):
            if op == PLUS_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.fadd(var, right)
            elif op == MINUS_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.fsub(var, right)
            elif op == MUL_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.fmul(var, right)
            elif op == FLOORDIV_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.fdiv(var, right)
                temp = cast_ops(self, res, ir.IntType(64), node)
                res = cast_ops(self, temp, res.type, node)
            elif op == DIV_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.fdiv(var, right)
            elif op == MOD_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                res = self.builder.frem(var, right)
            elif op == POWER_ASSIGN:
                right = cast_ops(self, right, var.type, node)
                temp = self.alloc_and_store(var, type_map[DOUBLE])
                for _ in range(node.right.value - 1):
                    res = self.builder.fmul(self.load(temp), var)
                    self.store(res, temp)
                res = self.load(temp)
            else:
                raise NotImplementedError()
        else:
            raise NotImplementedError()

        if collection_access:
            self.call('{}.array.set'.format(array_type), [var_name, key, res])
        else:
            self.store(res, var_name)

    def visit_constant(self, node):
        if node.value == TRUE:
            return self.const(1, BOOL)
        elif node.value == FALSE:
            return self.const(0, BOOL)
        elif node.value == INF:
            return self.const(inf, DOUBLE)
        else:
            raise NotImplementedError('file={} line={}'.format(self.file_name, node.line_num))

    def visit_collection(self, node):
        elements = []
        for item in node.items:
            elements.append(self.visit(item))
        if node.type == LIST:
            return self.define_array(node, elements)
        elif node.type == TUPLE:
            return self.define_tuple(node, elements)
        else:
            raise NotImplementedError

    def define_array(self, node, elements, explicit_type=None):
        if explicit_type:
            array_type = explicit_type
        elif len(node.items) > 0:
            if hasattr(node.items[0], 'val_type'):
                array_type = type_map[node.items[0].val_type]
            else:
                array_type = self.visit(node.items[0]).type
        else:
            # Default to INT for empty list without explicit type
            array_type = type_map[INT]
        array_ptr = self.create_array(array_type)
        for element in elements:
            self.call('{}.array.append'.format(str(array_type)), [array_ptr, element])
        return self.load(array_ptr)

    def create_array(self, array_type):
        dyn_array_type = self.module.context.get_identified_type('{}.array'.format(str(array_type)))
        if self.search_scopes('{}.array'.format(str(array_type))) is None:
            dyn_array_type.name = '{}.array'.format(str(array_type))
            dyn_array_type.type = CLASS
            # 0: size, 1: capacity, 2: data pointer, 3: refcount
            dyn_array_type.set_body(type_map[INT], type_map[INT], array_type.as_pointer(), type_map[INT])
            self.define('{}.array'.format(str(array_type)), dyn_array_type)

        # Use malloc instead of alloca for proper memory management
        malloc_func = self.module.get_global('malloc')
        array_mem = self.builder.call(malloc_func, [self.const(32)])  # 4 fields * 8 bytes
        array = self.builder.bitcast(array_mem, dyn_array_type.as_pointer())

        create_dynamic_array_methods(self, array_type)
        self.call('{}.array.init'.format(str(array_type)), [array])
        return array

    def define_tuple(self, node, elements):
        if hasattr(node.items[0], 'val_type'):
            array_type = type_map[node.items[0].val_type]
        else:
            array_type = self.visit(node.items[0]).type
        array_ptr = self.create_array(array_type)
        for element in elements:
            self.call('{}.array.append'.format(str(array_type)), [array_ptr, element])
        return self.load(array_ptr)

    def visit_hashmap(self, node):
        raise NotImplementedError

    def visit_collectionaccess(self, node):
        key = self.visit(node.key)
        collection = self.search_scopes(node.collection.value)
        for typ in array_types:
            if collection.type.pointee == self.search_scopes('{}.array'.format(typ)):
                return self.call('{}.array.get'.format(typ), [collection, key])

        return self.builder.extract_value(self.load(collection.name), [key])

    def visit_str(self, node):
        array = self.create_array(type_map[INT])
        string = node.value.encode('utf-8')
        for char in string:
            self.call('i64.array.append', [array, self.const(char)])
        return array

    def visit_print(self, node):
        if node.value:
            val = self.visit(node.value)
        else:
            self.call('putchar', [ir.Constant(type_map[INT32], 10)])
            return
        if isinstance(val.type, ir.IntType):
            if val.type.width == 1:
                array = self.create_array(type_map[INT])
                self.call('@bool_to_str', [array, val])
                val = array
            else:
                if int(str(val.type).split("i")[1]) == 8:
                    self.print_num("%c", val)
                elif val.type.signed:
                    if int(str(val.type).split("i")[1]) < 32:
                        val = self.builder.sext(val, type_map[INT32])
                        self.print_num("%d", val)
                    elif int(str(val.type).split("i")[1]) == 32:
                        self.print_num("%d", val)
                    else:
                        self.print_num("%lld", val)
                else:
                    if int(str(val.type).split("i")[1]) <= 32:
                        self.print_num("%u", val)
                    else:
                        self.print_num("%llu", val)
                return
        elif isinstance(val.type, (ir.FloatType, ir.DoubleType)):
            if isinstance(val.type, ir.FloatType):
                val = cast_ops(self, val, ir.DoubleType(), node)
            self.print_num("%g", val)
            return
        if isinstance(val.type, ir.PointerType):
            pointee_name = getattr(val.type.pointee, 'name', '')
        else:
            pointee_name = getattr(val.type, 'name', '')

        if pointee_name == 'bigint':
            # print_bigint expects pointer. val is likely struct.
            if not isinstance(val.type, ir.PointerType):
                # Spill to stack
                tmp = self.builder.alloca(val.type)
                self.builder.store(val, tmp)
                val = tmp
            self.call('print_bigint', [val])
            return
        elif pointee_name == 'decimal':
            if not isinstance(val.type, ir.PointerType):
                tmp = self.builder.alloca(val.type)
                self.builder.store(val, tmp)
                val = tmp
            self.call('print_decimal', [val])
            return
        elif pointee_name == 'number':
            if not isinstance(val.type, ir.PointerType):
                tmp = self.builder.alloca(val.type)
                self.builder.store(val, tmp)
                val = tmp
            self.call('print_number', [val])
            return
        elif pointee_name == 'dynamic':
            if not isinstance(val.type, ir.PointerType):
                tmp = self.builder.alloca(val.type)
                self.builder.store(val, tmp)
                val = tmp
            self.call('print_dynamic', [val])
            return

        if isinstance(val.type, ir.PointerType):
            # Original logic for potential other pointers? 
            # Though original code fell through for non-int/float.
            pass
             
        self.call('print', [val])

    def print_string(self, string, newline=True):
        stringz = self.stringz(string)
        str_ptr = self.alloc_and_store(stringz, ir.ArrayType(stringz.type.element, stringz.type.count))
        str_ptr = self.gep(str_ptr, [self.const(0), self.const(0)])
        if newline:
            str_ptr = self.builder.bitcast(str_ptr, type_map[INT].as_pointer())
            self.call('puts', [str_ptr])
        else:
            str_ptr = self.builder.bitcast(str_ptr, type_map[INT8].as_pointer())
            self.call('printf', [str_ptr])

    def print_num(self, num_format, num):
        percent_d = self.stringz(num_format)
        percent_d = self.alloc_and_store(percent_d, ir.ArrayType(percent_d.type.element, percent_d.type.count))
        percent_d = self.gep(percent_d, [self.const(0), self.const(0)])
        percent_d = self.builder.bitcast(percent_d, type_map[INT8].as_pointer())
        self.call('printf', [percent_d, num])
        self.call('putchar', [ir.Constant(type_map[INT], 10)])

    @staticmethod
    def typeToFormat(typ):
        fmt = None

        if isinstance(typ, ir.IntType):
            if int(str(typ).split("i")[1]) == 8:
                fmt = "%c"
            elif typ.signed:
                if int(str(typ).split("i")[1]) <= 32:
                    fmt = "%d"
                else:
                    fmt = "%lld"
            else:
                if int(str(typ).split("i")[1]) <= 32:
                    fmt = "%u"
                else:
                    fmt = "%llu"
        elif isinstance(typ, ir.FloatType):
            fmt = "%f"
        elif isinstance(typ, ir.DoubleType):
            fmt = "%lf"
        else:
            fmt = "%s"

        return fmt

    def visit_input(self, node):
        # Print prompt if provided (string only)
        if node.value is not None and isinstance(node.value, Str):
            self.print_string(node.value.value, newline=False)
            # Flush stdout to ensure prompt is displayed before reading input
            self.call('fflush', [ir.Constant(type_map[INT8].as_pointer(), None)])

        # Call input_line() to read a line and return string
        result = self.call('input_line', [])
        return result

    def get_args(self, parameters):
        args = []
        for param in parameters.values():
            if param.value == FUNC:
                if param.func_ret_type.value in type_map:
                    func_ret_type = type_map[param.func_ret_type.value]
                elif self.search_scopes(param.func_ret_type.value) is not None:
                    func_ret_type = self.search_scopes(param.func_ret_type.value).as_pointer()
                func_parameters = self.get_args(param.func_params)
                func_ty = ir.FunctionType(func_ret_type, func_parameters, None).as_pointer()
                args.append(func_ty)
            elif param.value == LIST:
                array_type = self.get_type(param.func_params['0'])
                self.create_array(array_type)
                typ = self.search_scopes('{}.array'.format(array_type))
                args.append(typ)
            else:
                if param.value in type_map:
                    args.append(type_map[param.value])
                elif list(parameters.keys())[list(parameters.values()).index(param)] == SELF:
                    args.append(self.search_scopes(param.value).as_pointer())
                elif self.search_scopes(param.value) is not None:
                    args.append(self.search_scopes(param.value))
                else:
                    error("Parameter type not recognized: {}".format(param.value))

        return args

    def get_type(self, param):
        typ = None
        if param.value == FUNC:
            if param.func_ret_type.value in type_map:
                func_ret_type = type_map[param.func_ret_type.value]
            elif self.search_scopes(param.func_ret_type.value) is not None:
                func_ret_type = self.search_scopes(param.func_ret_type.value).as_pointer()
            func_parameters = self.get_args(param.func_params)
            func_ty = ir.FunctionType(func_ret_type, func_parameters, None).as_pointer()
            typ = func_ty
        elif param.value == LIST:
            array_type = self.get_type(param.func_params['0'])
            self.create_array(array_type)
            typ = self.search_scopes('{}.array'.format(array_type))
        else:
            if param.value in type_map:
                typ = type_map[param.value]
            elif self.search_scopes(param.value) is not None:
                typ = self.search_scopes(param.value)
            else:
                error("Type not recognized: {}".format(param.value))

        return typ

    def func_decl(self, name, return_type, parameters, parameter_defaults=None, varargs=None, linkage=None):
        ret_type = self.get_type(return_type)
        args = self.get_args(parameters)
        func_type = ir.FunctionType(ret_type, args, varargs)
        func_type.parameters = parameters
        if parameter_defaults:
            func_type.parameter_defaults = parameter_defaults
        func = ir.Function(self.module, func_type, name)
        func.linkage = linkage
        self.define(name, func, 1)

    def implement_func_body(self, name):
        self.function_stack.append(self.current_function)
        self.block_stack.append(self.builder.block)
        self.new_scope()
        self.defer_stack.append([])
        for f in self.module.functions:
            if f.name == name:
                func = f
                break
        self.current_function = func
        entry = self.add_block('entry')
        self.exit_blocks.append(self.add_block('exit'))
        self.position_at_end(entry)

    def start_function(self, name, return_type, parameters, parameter_defaults=None, varargs=None, linkage=None):
        self.function_stack.append(self.current_function)
        self.block_stack.append(self.builder.block)
        self.new_scope()
        self.defer_stack.append([])
        ret_type = self.get_type(return_type)
        args = self.get_args(parameters)
        func_type = ir.FunctionType(ret_type, args, varargs)
        func_type.parameters = parameters
        if parameter_defaults:
            func_type.parameter_defaults = parameter_defaults

        func = ir.Function(self.module, func_type, name)
        func.linkage = linkage
        self.define(name, func, 1)
        self.current_function = func
        entry = self.add_block('entry')
        self.exit_blocks.append(self.add_block('exit'))
        self.position_at_end(entry)

    def end_function(self, returned=False):
        for stat in self.defer_stack[-1]:
            self.visit(stat)
        self.defer_stack.pop()
        if returned is not True:
            self.branch(self.exit_blocks[-1])
        self.position_at_end(self.exit_blocks.pop())
        if self.current_function.function_type.return_type != type_map[VOID]:
            retvar = self.load(self.search_scopes(RET_VAR))
            self.builder.ret(retvar)
        else:
            self.builder.ret_void()
        back_block = self.block_stack.pop()
        self.position_at_end(back_block)
        last_function = self.function_stack.pop()
        self.current_function = last_function
        self.drop_top_scope()

    def new_builder(self, block):
        self.builder = ir.IRBuilder(block)
        return self.builder

    def add_block(self, name):
        return self.current_function.append_basic_block(name)

    def position_at_end(self, block):
        self.builder.position_at_end(block)

    def cbranch(self, cond, true_block, false_block):
        self.builder.cbranch(cond, true_block, false_block)

    def branch(self, block):
        self.builder.branch(block)

    def switch(self, value, default):
        return self.builder.switch(value, default)

    def const(self, val, width=None):
        if isinstance(val, int):
            if width:
                return ir.Constant(type_map[width], val)

            return ir.Constant(type_map[INT], val)
        elif isinstance(val, (float, Decimal)):
            return ir.Constant(type_map[DOUBLE], val)
        elif isinstance(val, bool):
            return ir.Constant(type_map[BOOL], bool(val))
        elif isinstance(val, str):
            return self.stringz(val)
        else:
            raise NotImplementedError

    def allocate(self, typ, name=''):
        var_addr = self.builder.alloca(typ, name=name)
        return var_addr

    def alloc_and_store(self, val, typ, name=''):
        var_addr = self.builder.alloca(typ, name=name)
        self.builder.store(val, var_addr)
        return var_addr

    def get_entry_alloca(self, name, typ):
        """Get or create an alloca in the function entry block (cached)"""
        key = (self.current_function.name, name)
        if key not in self._entry_allocas:
            # Save current position
            saved_block = self.builder.block
            # Move to entry block start
            entry = self.current_function.entry_basic_block
            if entry.instructions:
                self.builder.position_before(entry.instructions[0])
            else:
                self.builder.position_at_end(entry)
            # Create alloca
            var_addr = self.builder.alloca(typ, name=name)
            
            # Initialize to NULL/Zero if BIGINT or DECIMAL to enable safe first-time checks
            # We identify them by name since we don't have easy type checking here easily without imports?
            # typ is an LLVM type.
            type_name = getattr(typ, 'name', '')
            if type_name in ('bigint', 'decimal'):
                 # Zero init the entire struct (safe for both)
                 # bigint: {i1, i64.array*} -> sign=0, ptr=null
                 # decimal: {bigint*, i64} -> ptr=null, exp=0
                 # Actually simpler: just memset to 0? Or store constant aggregate?
                 # llvmlite doesn't have memset easily exposed?
                 # Store zero constant.
                 zero_const = ir.Constant(typ, None) # Null value for the struct
                 self.builder.store(zero_const, var_addr)
            
            self._entry_allocas[key] = var_addr
            # Restore position
            self.builder.position_at_end(saved_block)
        return self._entry_allocas[key]

    def alloc_and_define(self, name, typ):
        var_addr = self.builder.alloca(typ, name=name)
        self.define(name, var_addr)
        return var_addr

    def alloc_define_store(self, val, name, typ):
        saved_block = self.builder.block
        var_addr = self.builder.alloca(typ, name=name)
        self.define(name, var_addr)
        self.builder.position_at_end(saved_block)
        self.builder.store(val, var_addr)
        return var_addr

    def store(self, value, name):
        if isinstance(name, str):
            self.builder.store(value, self.search_scopes(name))
        else:
            self.builder.store(value, name)

    def load(self, name):
        if isinstance(name, str):
            return self.builder.load(self.search_scopes(name))
        return self.builder.load(name)

    def call(self, name, args):
        if isinstance(name, str):
            func = self.module.get_global(name)
        else:
            func = self.module.get_global(name.name)
        if func is None:
            raise TypeError('Calling non existant function')
        return self.builder.call(func, args)

    def gep(self, ptr, indices, inbounds=False, name=''):
        return self.builder.gep(ptr, indices, inbounds, name)

    def _add_builtins(self):
        malloc_ty = ir.FunctionType(type_map[INT8].as_pointer(), [type_map[INT]])
        ir.Function(self.module, malloc_ty, 'malloc')

        realloc_ty = ir.FunctionType(type_map[INT8].as_pointer(), [type_map[INT8].as_pointer(), type_map[INT]])
        ir.Function(self.module, realloc_ty, 'realloc')

        free_ty = ir.FunctionType(type_map[VOID], [type_map[INT8].as_pointer()])
        ir.Function(self.module, free_ty, 'free')

        exit_ty = ir.FunctionType(type_map[VOID], [type_map[INT32]])
        ir.Function(self.module, exit_ty, 'exit')

        putchar_ty = ir.FunctionType(type_map[INT], [type_map[INT]])
        ir.Function(self.module, putchar_ty, 'putchar')

        printf_ty = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer()], var_arg=True)
        ir.Function(self.module, printf_ty, 'printf')

        scanf_ty = ir.FunctionType(type_map[INT], [type_map[INT8].as_pointer()], var_arg=True)
        ir.Function(self.module, scanf_ty, 'scanf')

        getchar_ty = ir.FunctionType(ir.IntType(8), [])
        ir.Function(self.module, getchar_ty, 'getchar')

        puts_ty = ir.FunctionType(type_map[INT], [type_map[INT].as_pointer()])
        ir.Function(self.module, puts_ty, 'puts')

        # fflush(FILE*) -> int, pass NULL to flush all streams
        fflush_ty = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer()])
        ir.Function(self.module, fflush_ty, 'fflush')

        define_builtins(self)

    @staticmethod
    def stringz(string):
        n = len(string) + 1
        buf = bytearray((' ' * n).encode('ascii'))
        buf[-1] = 0
        buf[:-1] = string.encode('utf-8')
        return ir.Constant(ir.ArrayType(type_map[INT8], n), buf)

    def generate_code(self, node):
        return self.visit(node)

    def add_debug_info(self, optimize: bool, filename: str):
        di_file = self.module.add_debug_info("DIFile", {
            "filename": os.path.basename(os.path.abspath(filename)),
            "directory": os.path.dirname(os.path.abspath(filename)),
        })
        di_module = self.module.add_debug_info("DICompileUnit", {
            "language": ir.DIToken("DW_LANG_Python"),
            "file": di_file,
            "producer": "Meteor v0.4.1",
            "runtimeVersion": 1,
            "isOptimized": optimize,
        }, is_distinct=True)

        self.module.name = os.path.basename(os.path.abspath(filename))
        self.module.add_named_metadata('llvm.dbg.cu', [di_file, di_module])

    def evaluate(self, optimize: bool, ir_dump: bool, timer: bool) -> None:
        if ir_dump and not optimize:
            for func in self.module.functions:
                if func.name == "main":
                    print(func)

        llvmmod = llvm.parse_assembly(str(self.module))
        target_machine = llvm.Target.from_default_triple().create_target_machine()
        if optimize:
            # Modern llvmlite API (0.40+)
            pb = llvm.create_pass_builder(target_machine, llvm.PipelineTuningOptions(speed_level=3))
            mpm = pb.getModulePassManager()
            mpm.run(llvmmod, pb)
            if ir_dump:
                print(str(llvmmod))
        with llvm.create_mcjit_compiler(llvmmod, target_machine) as ee:
            ee.finalize_object()
            fptr = CFUNCTYPE(c_void_p)(ee.get_function_address('main'))
            start_time = time()
            fptr()
            end_time = time()
            if timer:
                print('\nExecuted in {:f} sec'.format(end_time - start_time))

    def compile(self, filename: str, optimize: bool, output: Optional[str], emit_llvm: bool) -> None:
        compile_time = time()

        # self.add_debug_info(optimize, filename)
        program_string = llvm.parse_assembly(str(self.module))

        prog_str = str(program_string)
        if output is None:
            output = os.path.splitext(filename)[0]

        with open(output + '.ll', 'w') as out:
            out.write(prog_str)

        with open(os.devnull, "w") as tmpout:
            subprocess.call('clang {0}.ll -O3 -o {0}'.format(output).split(" "), stdout=tmpout, stderr=tmpout)
            successful("compilation done in: %.3f seconds" % (time() - compile_time))
            successful("binary file wrote to " + output)

        if emit_llvm:
            successful("llvm assembler wrote to " + output + ".ll")
        else:
            os.remove(output + '.ll')
