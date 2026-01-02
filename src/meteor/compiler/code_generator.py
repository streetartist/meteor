import os
import subprocess
import ctypes
from ctypes import CFUNCTYPE, c_void_p
from decimal import Decimal
from math import inf
from time import time
from typing import Optional

import llvmlite.binding as llvm
from llvmlite import ir

import meteor.compiler.llvmlite_custom
from meteor.ast import Collection, CollectionAccess, DotAccess, Input, Str, Var, VarDecl, UnionType, Raise, ErrorPropagation, NullableType, NullUnwrap
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

        # Call mi_version() to ensure mimalloc DLL is initialized
        mi_version_func = self.module.get_global('mi_version')
        if mi_version_func:
            self.builder.call(mi_version_func, [])

        self.exit_blocks = [exit_block]
        self.block_stack = [entry_block]
        self.defer_stack = [[]]
        self.loop_test_blocks = []
        self.loop_end_blocks = []
        self.catch_stack = []  # Stack of {'landing_pad': block}
        self.is_break = False
        self.anon_counter = 0
        self._entry_allocas = {}  # Cache for entry block allocas
        self.managed_vars_stack = [[]]  # Stack of managed variables per scope for RC cleanup
        self.link_libs = []  # C libraries to link
        self.spawn_counter = 0  # Counter for unique spawn wrapper names

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

    def visit_nullunwrap(self, node):
        """Handle null unwrap operator (postfix !).
        
        Extracts the inner value from nullable struct {i1, T}.
        For now, no runtime null check (could add panic later).
        """
        val = self.visit(node.expr)
        
        # Check if it's a nullable struct {i1, T}
        if isinstance(val.type, ir.LiteralStructType) and len(val.type.elements) == 2:
            if isinstance(val.type.elements[0], ir.IntType) and val.type.elements[0].width == 1:
                # Extract the inner value (index 1)
                inner_val = self.builder.extract_value(val, 1, name='unwrapped')
                return inner_val
        
        # If not a nullable type, just return the value as-is
        return val

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
        param_modes = getattr(node, 'param_modes', {})
        if func_exists:
            self.implement_func_body(name)
        else:
            self.start_function(name, node.return_type, node.parameters, node.parameter_defaults, node.varargs, linkage, param_modes)
        for i, arg in enumerate(self.current_function.args):
            arg.name = list(node.parameters.keys())[i]
            mode = param_modes.get(arg.name, 'borrow')

            if arg.name == SELF and isinstance(arg.type, ir.PointerType):
                # Allocate and store self like other parameters
                # This ensures load(self) returns Response*, not Response
                self.alloc_define_store_simple(arg, arg.name, arg.type)
            elif mode == 'escape':
                # Escape mode: retain the argument (it may be stored in heap)
                self.alloc_define_store(arg, arg.name, arg.type)
            elif mode == 'owned':
                # Owned mode: caller transferred ownership
                # Don't retain (ownership already transferred), but register for cleanup
                var_addr = self.builder.alloca(arg.type, name=arg.name)
                self.define(arg.name, var_addr)
                self.builder.store(arg, var_addr)
                # Register for cleanup at function end (will release)
                if self.is_managed_type(arg.type):
                    self.register_managed_var(arg.name, var_addr)
            elif mode == 'ref':
                # Ref mode: arg is already a pointer to the variable (Object**)
                # Define directly without allocating - allows modifying caller's variable
                self.define(arg.name, arg)
            else:
                # Borrow mode: simple alloc, no RC
                self.alloc_define_store_simple(arg, arg.name, arg.type)
        if self.current_function.function_type.return_type != type_map[VOID]:
            self.alloc_and_define(RET_VAR, self.current_function.function_type.return_type)
        ret = self.visit(node.body)
        self.end_function(ret)

    def visit_return(self, node):
        val = self.visit(node.value)
        if val.type != ir.VoidType():
            ret_var = self.search_scopes(RET_VAR)
            dest_type = ret_var.type.pointee

            # Check for Union Type (Tagged Union) {i8, T, E}
            # We assume a literal struct with 3 elements and first is i8 is a tagged union for now
            if isinstance(dest_type, ir.LiteralStructType) and len(dest_type.elements) == 3 and dest_type.elements[0] == type_map[INT8]:
                if val.type == dest_type:
                     # Direct assignment (propagating union)
                     self.store(val, RET_VAR)
                elif val.type == dest_type.elements[1] or (hasattr(val.type, 'pointee') and val.type.pointee == dest_type.elements[1]):
                     # Success value - Pack {0, val, undef}
                     tag_ptr = self.builder.gep(ret_var, [self.const(0), self.const(0, width=INT32)])
                     self.builder.store(self.const(0, width=INT8), tag_ptr)
                     val_ptr = self.builder.gep(ret_var, [self.const(0), self.const(1, width=INT32)])
                     if isinstance(val.type, ir.PointerType) and not isinstance(dest_type.elements[1], ir.PointerType):
                         val = self.builder.load(val)
                     self.builder.store(val, val_ptr)
                elif val.type == dest_type.elements[2] or (hasattr(val.type, 'pointee') and val.type.pointee == dest_type.elements[2]):
                     # Error value - Pack {1, undef, err}
                     tag_ptr = self.builder.gep(ret_var, [self.const(0), self.const(0, width=INT32)])
                     self.builder.store(self.const(1, width=INT8), tag_ptr)
                     err_ptr = self.builder.gep(ret_var, [self.const(0), self.const(2, width=INT32)])
                     self.builder.store(val, err_ptr)
                else:
                     # Attempt fallback cast
                     val = self.comp_cast(val, dest_type, node)
                     self.store(val, RET_VAR)
            # Check for Nullable Type {i1, T}
            elif isinstance(dest_type, ir.LiteralStructType) and len(dest_type.elements) == 2 and isinstance(dest_type.elements[0], ir.IntType) and dest_type.elements[0].width == 1:
                inner_type = dest_type.elements[1]
                # Check if returning null (i8* null pointer)
                is_null_ptr = isinstance(val.type, ir.PointerType) and str(val.type) == 'i8*'
                if is_null_ptr:
                    # Pack {1, undef} - is_null = true
                    is_null_ptr = self.builder.gep(ret_var, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(ir.Constant(ir.IntType(1), 1), is_null_ptr)
                    # Leave value as undef (don't store anything)
                elif val.type == dest_type:
                    # Direct assignment (already a nullable struct)
                    self.store(val, RET_VAR)
                elif val.type == inner_type or (hasattr(val.type, 'pointee') and val.type.pointee == inner_type):
                    # Pack {0, val} - is_null = false, has value
                    is_null_ptr = self.builder.gep(ret_var, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(ir.Constant(ir.IntType(1), 0), is_null_ptr)
                    val_ptr = self.builder.gep(ret_var, [self.const(0), self.const(1, width=INT32)])
                    if isinstance(val.type, ir.PointerType) and not isinstance(inner_type, ir.PointerType):
                        val = self.builder.load(val)
                    self.builder.store(val, val_ptr)
                else:
                    # Attempt fallback cast
                    val = self.comp_cast(val, dest_type, node)
                    self.store(val, RET_VAR)
            else:
                val = self.comp_cast(val, dest_type, node)
                # If casting returned a pointer (e.g. int_to_bigint) but we need the value (struct), load it.
                if isinstance(val.type, ir.PointerType) and val.type.pointee == dest_type:
                    val = self.builder.load(val)
                self.store(val, RET_VAR)

        # Release scope variables before returning (exclude return value)
        # Retain the return value first to prevent it from being freed
        if val.type != ir.VoidType() and self.is_managed_type(val.type):
            self.rc_retain(val)
        self.release_scope_variables()

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
        """Handle method calls, C function calls, and module function calls.

        Cases handled:
        1. C namespace calls: c.meteor_http_server_create()
        2. Module function calls: http.server.create_server()
        3. Method calls on variables: server.listen()
        4. Method calls on field results: self.headers.length()
        5. Chain calls: server.bind().get()
        """
        from meteor.ast import DotAccess

        # Case 1: C namespace call (e.g., c.meteor_http_server_create())
        if node.obj == 'c':
            return self._call_c_function(node)

        # Case 2: DotAccess object (e.g., http.server.create_server() or self.headers.length())
        if isinstance(node.obj, DotAccess):
            return self._handle_dotaccess_methodcall(node)

        # Case 3: Simple variable method call (e.g., server.listen())
        obj = self.search_scopes(node.obj)
        if obj is None:
            # Try as direct function call
            if node.name in self.module.globals:
                args = [self.visit(arg) for arg in node.arguments]
                return self.call(node.name, args)
            error(f"Unknown variable or namespace: {node.obj}")

        # Case 4: Module alias call (e.g., mu.abs where mu is imported module)
        if isinstance(obj, dict) and '__module__' in obj:
            return self._call_module_function(node, obj)

        # Case 5: Method call on object
        return self._call_method_on_object(node, obj)

    def _call_c_function(self, node):
        """Call a C function (e.g., c.meteor_http_server_create())."""
        func_name = node.name
        func = self.module.get_global(func_name)
        if func is None:
            error(f"C function not found: {func_name}")

        return self._call_c_func_ptr(func, node.arguments)

    def _call_c_func_ptr(self, func, arg_nodes):
        """Call a C function pointer with arguments, handling type coercion and memory cleanup."""
        # Convert arguments with type coercion for C interop
        args = []
        cleanup_ptrs = []  # Keep track of C string pointers that need to be freed
        temp_managed_args = []  # Track temporary managed values to release
        func_arg_types = func.function_type.args
        for i, arg_node in enumerate(arg_nodes):
            arg = self.visit(arg_node)
            # Track temporary managed values
            if self._is_temp_managed_value(arg, arg_node):
                temp_managed_args.append(arg)
            # Get expected type if available
            expected_type = func_arg_types[i] if i < len(func_arg_types) else None
            if expected_type is not None:
                new_arg, needs_free = self._coerce_c_arg_with_cleanup(arg, expected_type)
                arg = new_arg
                if needs_free:
                    cleanup_ptrs.append(arg)
            args.append(arg)

        result = self.builder.call(func, args)

        # Cleanup temporary C strings
        if cleanup_ptrs:
            free_func = self.module.get_global('free')
            if not free_func:
                 # Define free if not exists (should be defined by _define_stdlib_h or similar)
                 void_ty = type_map[VOID]
                 void_ptr = type_map[INT8].as_pointer()
                 func_ty = ir.FunctionType(void_ty, [void_ptr])
                 free_func = ir.Function(self.module, func_ty, 'free')

            for ptr in cleanup_ptrs:
                self.builder.call(free_func, [ptr])

        # Release temporary managed values
        for temp_arg in temp_managed_args:
            self.rc_release(temp_arg)

        return result

    def _coerce_c_arg_with_cleanup(self, arg, expected_type):
        """Coerce an argument to match the expected C type, returning (arg, needs_free)."""
        expected_str = str(expected_type)
        arg_type_str = str(arg.type)

        # Convert Meteor string to C string if needed
        if expected_str == 'i8*':
            if hasattr(arg.type, 'pointee') and hasattr(arg.type.pointee, 'name'):
                if arg.type.pointee.name == 'i64.array':
                    cstr = self._convert_meteor_string_to_cstr(arg)
                    return cstr, True  # True means this pointer needs to be freed

        # Convert integer types
        if isinstance(expected_type, ir.IntType) and isinstance(arg.type, ir.IntType):
            if expected_type.width != arg.type.width:
                if expected_type.width < arg.type.width:
                    return self.builder.trunc(arg, expected_type), False
                else:
                    return self.builder.sext(arg, expected_type), False

        return arg, False

    def _handle_dotaccess_methodcall(self, node):
        """Handle method call on DotAccess result."""
        from meteor.ast import DotAccess

        # Build full path to check for module function
        def build_path(n):
            if isinstance(n, DotAccess):
                return f"{build_path(n.obj)}.{n.field}"
            return n

        full_path = build_path(node.obj)

        # Check if it's a C namespace call (e.g., c.something.func())
        if full_path.startswith('c.'):
            func_name = node.name
            func = self.module.get_global(func_name)
            if func is not None:
                return self._call_c_func_ptr(func, node.arguments)

        # Check if full path + method is a module function
        full_func_path = f"{full_path}.{node.name}"
        func = self.search_scopes(full_func_path)
        if func is not None and isinstance(func, ir.Function):
            args = [self.visit(arg) for arg in node.arguments]
            return self.builder.call(func, args)

        # Check if method exists in module globals
        if node.name in self.module.globals:
            func = self.module.get_global(node.name)
            if isinstance(func, ir.Function):
                args = [self.visit(arg) for arg in node.arguments]
                return self.builder.call(func, args)

        # Try to evaluate DotAccess as field access
        obj = self.visit(node.obj)

        # Handle C namespace marker
        if isinstance(obj, dict) and obj.get('__c_namespace__'):
            c_func_name = obj['__name__']
            func = self.module.get_global(c_func_name)
            if func is None:
                error(f"C function not found: {c_func_name}")
            return self._call_c_func_ptr(func, node.arguments)

        # Handle module dict
        if isinstance(obj, dict) and '__module__' in obj:
            return self._call_module_function(node, obj)

        # Handle function reference
        if isinstance(obj, ir.Function):
            args = [self.visit(arg) for arg in node.arguments]
            return self.builder.call(obj, args)

        # It's a field access result - call method on it
        if obj is not None and hasattr(obj, 'type'):
            return self._call_method_on_value(node, obj)

        error(f"Cannot call method on: {full_path}")

    def _call_module_function(self, node, module_dict):
        """Call a function from an imported module."""
        func_name = node.name
        # Try direct lookup
        func = self.module.get_global(func_name)
        if func is not None:
            args = [self.visit(arg) for arg in node.arguments]
            return self.builder.call(func, args)
        # Try with module prefix
        module_info = module_dict['__module__']
        module_name = module_info.name if hasattr(module_info, 'name') else str(module_info)
        func = self.search_scopes(f"{module_name}.{func_name}")
        if func is not None:
            args = [self.visit(arg) for arg in node.arguments]
            if isinstance(func, ir.Function):
                return self.builder.call(func, args)
        error(f"Function '{func_name}' not found in module")

    def _call_method_on_object(self, node, obj):
        """Call a method on an object variable."""
        type_name = self._get_type_name(obj)
        method = self.search_scopes(f"{type_name}.{node.name}")

        # Check for base class method
        if method is None:
            obj_type = self.search_scopes(type_name.split('.')[-1])
            if obj_type is not None and hasattr(obj_type, 'base') and obj_type.base is not None:
                parent = self.search_scopes(obj_type.base.value)
                return self.super_method(node, obj, parent)

        # Check if it's a function field
        if method is None:
            obj_type = self.search_scopes(type_name.split('.')[-1])
            if obj_type is not None and hasattr(obj_type, 'fields') and node.name in obj_type.fields:
                return self._call_function_field(node, obj, obj_type)

        if method is None:
            error(f"Method '{node.name}' not found on type '{type_name}'")

        # Load obj if it's a pointer-to-pointer
        if hasattr(obj.type, 'pointee') and hasattr(obj.type.pointee, 'pointee'):
            obj = self.builder.load(obj)

        result = self.methodcall(node, method, obj)

        # Move semantics for channel.send
        if type_name == 'meteor.channel' and node.name == 'send':
            self._handle_channel_send_move(node)

        return result

    def _call_method_on_value(self, node, obj):
        """Call a method on a value (result of expression)."""
        type_name = self._get_type_name_from_value(obj)
        method = self.search_scopes(f"{type_name}.{node.name}")

        if method is None:
            # Try without module prefix
            simple_name = type_name.split('.')[-1]
            method = self.search_scopes(f"{simple_name}.{node.name}")

        if method is None:
            error(f"Method '{node.name}' not found on type '{type_name}'")

        # Load if needed
        if hasattr(obj.type, 'pointee') and hasattr(obj.type.pointee, 'pointee'):
            obj = self.builder.load(obj)

        return self.methodcall(node, method, obj)

    def _get_type_name(self, obj):
        """Get type name from an object pointer."""
        if not hasattr(obj, 'type') or not hasattr(obj.type, 'pointee'):
            return str(obj.type) if hasattr(obj, 'type') else 'unknown'

        pointee = obj.type.pointee
        if hasattr(pointee, 'name'):
            return pointee.name
        type_str = str(pointee)
        if type_str.startswith('%"'):
            return type_str.split('"')[1]
        elif type_str.startswith('%'):
            return type_str[1:]
        return type_str

    def _is_temp_string(self, val, ast_node):
        """Check if a value is a temporary string (not from variable load)."""
        from meteor.ast import Str, BinOp, Var, DotAccess, CollectionAccess, FuncCall, MethodCall
        
        # String literals are temporary
        if isinstance(ast_node, Str):
            return True
        # String concatenation results are temporary
        if isinstance(ast_node, BinOp):
            return True
        # Function/Method calls return temporaries
        if isinstance(ast_node, (FuncCall, MethodCall)):
            return True
            
        # Variables are NOT temporary
        if isinstance(ast_node, (Var, DotAccess, CollectionAccess)):
            return False
            
        # Fallback to existing logic
        if hasattr(val, 'type') and hasattr(val.type, 'pointee'):
            if hasattr(val.type.pointee, 'name') and val.type.pointee.name == 'i64.array':
                # If it came from a load, it's a variable reference
                if hasattr(val, 'opname') and val.opname == 'load':
                    return False
                return True
        return False

    def _is_temp_managed_value(self, val, ast_node):
        """Check if a value is a temporary managed type (class instance, not from variable)."""
        from meteor.ast import Str, BinOp, FuncCall
        # Class constructor calls are temporary
        if isinstance(ast_node, FuncCall):
            # Check if it's a class constructor
            class_type = self.search_scopes(ast_node.name)
            if class_type is not None and hasattr(class_type, 'type') and class_type.type == CLASS:
                return True
        # String literals and concatenations
        if isinstance(ast_node, (Str, BinOp)):
            return True
        # Check if it's a managed type but not from a load instruction
        if hasattr(val, 'type') and hasattr(val.type, 'pointee'):
            pointee = val.type.pointee
            if hasattr(pointee, 'name'):
                # String type
                if pointee.name == 'i64.array':
                    if hasattr(val, 'opname') and val.opname == 'load':
                        return False
                    return True
                # Class type
                class_def = self.search_scopes(pointee.name)
                if class_def is not None and hasattr(class_def, 'methods'):
                    if hasattr(val, 'opname') and val.opname == 'load':
                        return False
                    return True
        return False

    def _get_type_name_from_value(self, obj):
        """Get type name from a value."""
        if hasattr(obj.type, 'pointee'):
            pointee = obj.type.pointee
        else:
            pointee = obj.type

        if hasattr(pointee, 'name'):
            return pointee.name
        type_str = str(pointee)
        if type_str.startswith('%"'):
            return type_str.split('"')[1]
        elif type_str.startswith('%'):
            return type_str[1:]
        return type_str

    def _call_function_field(self, node, obj, obj_type):
        """Call a function stored in a field."""
        field_idx = obj_type.fields.index(node.name)
        if hasattr(obj.type, 'pointee') and hasattr(obj.type.pointee, 'pointee'):
            obj = self.builder.load(obj)
        field_ptr = self.builder.gep(obj, [self.const(0, width=INT32), self.const(field_idx, width=INT32)])
        func_ptr = self.builder.load(field_ptr)
        args = [self.visit(arg) for arg in node.arguments]
        return self.builder.call(func_ptr, args)

    def _handle_channel_send_move(self, node):
        """Handle move semantics for channel.send."""
        for arg_node in node.arguments:
            if hasattr(arg_node, 'value'):
                var_ptr = self.search_scopes(arg_node.value)
                if var_ptr and hasattr(var_ptr, 'type') and hasattr(var_ptr.type, 'pointee'):
                    null_val = ir.Constant(var_ptr.type.pointee, None)
                    self.builder.store(null_val, var_ptr)

    def methodcall(self, node, func, obj):
        func_type = func.function_type
        temp_managed_args = []  # Track temporary managed arguments to release after call

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
                    arg_val = self.visit(node.arguments[x])
                    # Track temporary managed values (strings, class instances)
                    if self._is_temp_managed_value(arg_val, node.arguments[x]):
                        temp_managed_args.append(arg_val)
                    args.append(arg_val)
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
                # func_type.args includes 'self' at index 0, so use i+1 for user arguments
                target_type = func_type.args[i+1] if i+1 < len(func_type.args) else func_type.args[i]
                arg_val = self.visit(arg)
                # Track temporary managed values
                if self._is_temp_managed_value(arg_val, arg):
                    temp_managed_args.append(arg_val)
                args.append(self.comp_cast(arg_val, target_type, node))

        args.insert(0, obj)
        result = self.builder.call(func, args)

        # Release temporary managed arguments after call
        for temp_arg in temp_managed_args:
            self.rc_release(temp_arg)

        return result

    def visit_funccall(self, node):
        # Handle parse() builtin for string to int conversion
        if node.name == 'parse':
            if len(node.arguments) == 1:
                arg = self.visit(node.arguments[0])
                return self.call('str_to_int', [arg])

        # Handle freeze() builtin - convert object to frozen (immutable)
        if node.name == 'freeze':
            if len(node.arguments) == 1:
                arg = self.visit(node.arguments[0])
                # If arg is a value (not pointer), we need to get its address
                if isinstance(arg.type, ir.PointerType):
                    obj_ptr = arg
                else:
                    # Store to temp and get pointer
                    tmp = self.builder.alloca(arg.type, name="freeze_tmp")
                    self.builder.store(arg, tmp)
                    obj_ptr = tmp
                # Get object header and call meteor_freeze
                header = self.get_object_header(obj_ptr)
                self.call('meteor_freeze', [header])
                return arg  # Return same object (now frozen)

        func_type = self.search_scopes(node.name)
        func_symbol = func_type  # Save original for param_modes lookup
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
            # Try to get function from module (for C stdlib functions)
            name = node.name
            llvm_func = self.module.get_global(name)
            if llvm_func and isinstance(llvm_func, ir.Function):
                func_type = llvm_func.type.pointee
            else:
                error("Function not found: {}".format(name))

        if len(node.arguments) < len(func_type.args):
            args = []
            args_supplied = []
            arg_names = []
            temp_managed_args = []  # Track temporary managed values

            for i in func_type.parameters:
                arg_names.append(i)

            for x, arg in enumerate(func_type.args):
                if x < len(node.arguments):
                    arg_val = self.visit(node.arguments[x])
                    if self._is_temp_managed_value(arg_val, node.arguments[x]):
                        temp_managed_args.append(arg_val)
                    args.append(arg_val)
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
            temp_managed_args = []  # Track temporary managed values
            param_names = list(func_type.parameters.keys()) if hasattr(func_type, 'parameters') else []
            param_modes = getattr(func_type, 'param_modes', {})
            for i, arg in enumerate(node.arguments):
                # Check if this is a ref parameter - pass address instead of value
                if i < len(param_names) and param_modes.get(param_names[i]) == 'ref':
                    # For ref mode, pass the address of the variable
                    if hasattr(arg, 'value'):
                        var_ptr = self.search_scopes(arg.value)
                        if var_ptr:
                            args.append(var_ptr)
                            continue
                arg_val = self.visit(arg)
                if self._is_temp_managed_value(arg_val, arg):
                    temp_managed_args.append(arg_val)
                args.append(self.comp_cast(arg_val, func_type.args[i], node))

        if isFunc:
            result = self.builder.call(name, args)
            # Release temporary managed arguments
            for temp_arg in temp_managed_args:
                self.rc_release(temp_arg)
            return result

        result = self.call(name, args)

        # Release temporary managed arguments
        for temp_arg in temp_managed_args:
            self.rc_release(temp_arg)

        # Move semantics: null out owned arguments after call
        # param_modes is stored in func_symbol (FuncSymbol), not func_type (ir.FunctionType)
        if hasattr(func_symbol, 'param_modes') and func_symbol.param_modes:
            param_names = list(func_symbol.parameters.keys()) if hasattr(func_symbol, 'parameters') else []
            for i, arg_node in enumerate(node.arguments):
                if i < len(param_names):
                    param_name = param_names[i]
                    if func_symbol.param_modes.get(param_name) == 'owned':
                        # Null out the local variable
                        if hasattr(arg_node, 'value'):
                            var_ptr = self.search_scopes(arg_node.value)
                            if var_ptr and hasattr(var_ptr, 'type'):
                                null_val = ir.Constant(var_ptr.type.pointee, None)
                                self.builder.store(null_val, var_ptr)

        return result

    def visit_import(self, node):
        """Handle regular import statement.

        Loads and compiles the imported module, making its exports available.
        """
        from meteor.module_resolver import ModuleResolver, ModuleLoader
        from meteor.ast import (
            PublicDecl,
            FuncDecl,
            ExternFuncDecl,
            ClassDeclaration,
            EnumDeclaration,
            TraitDeclaration,
            ErrorDeclaration,
            CImport,
        )

        # Initialize resolver if not already done
        if not hasattr(self, '_module_resolver'):
            import os
            project_root = os.path.dirname(self.file_name) if self.file_name else '.'
            self._module_resolver = ModuleResolver(project_root)
            self._module_loader = ModuleLoader(self._module_resolver)
            self._loaded_modules = {}
            self._compiled_funcs = set()

        module_name = node.module_name
        alias = node.alias if node.alias else module_name.split('.')[-1]

        # Skip if already loaded
        if module_name in self._loaded_modules:
            return

        try:
            info, module_ast = self._module_loader.load(module_name, self.file_name)
            self._loaded_modules[module_name] = info

            if module_ast is not None:
                # Pass 1: bring in any C imports needed by the module
                for child in module_ast.block.children:
                    if isinstance(child, CImport):
                        self.visit(child)

                # Pass 2: register/export public types (classes/enums/traits/errors)
                for child in module_ast.block.children:
                    if isinstance(child, PublicDecl):
                        decl = child.declaration
                        if isinstance(decl, (ClassDeclaration, EnumDeclaration, TraitDeclaration, ErrorDeclaration)):
                            self.visit(child)
                            # Also register with full module path (e.g., http.server.Request)
                            type_obj = self.search_scopes(decl.name)
                            if type_obj is not None:
                                full_name = f"{module_name}.{decl.name}"
                                self.define(full_name, type_obj)

                # Pass 3: compile all public functions from module
                for child in module_ast.block.children:
                    if isinstance(child, PublicDecl):
                        decl = child.declaration
                        if isinstance(decl, FuncDecl):
                            func_key = f"{module_name}.{decl.name}"
                            if func_key not in self._compiled_funcs:
                                self._compiled_funcs.add(func_key)
                                self.visit(decl)

            self.define(alias, {'__module__': info, '__exports__': info.exports})
        except ImportError as e:
            error(f"file={self.file_name} line={node.line_num}: {e}")

    def visit_fromimport(self, node):
        """Handle from...import statement.

        Imports specific symbols from a module into current namespace.
        """
        from meteor.module_resolver import ModuleResolver, ModuleLoader
        from meteor.ast import (
            PublicDecl,
            FuncDecl,
            ExternFuncDecl,
            ClassDeclaration,
            EnumDeclaration,
            TraitDeclaration,
            ErrorDeclaration,
            CImport,
        )

        # Initialize resolver if not already done
        if not hasattr(self, '_module_resolver'):
            import os
            project_root = os.path.dirname(self.file_name) if self.file_name else '.'
            self._module_resolver = ModuleResolver(project_root)
            self._module_loader = ModuleLoader(self._module_resolver)
            self._loaded_modules = {}
            self._compiled_funcs = set()

        module_name = node.module_name

        try:
            info, module_ast = self._module_loader.load(module_name, self.file_name)
            self._loaded_modules[module_name] = info

            if module_ast is None:
                return  # Already loaded

            # Get list of symbols to import
            if node.imports == '*':
                symbols_to_import = list(info.exports.keys())
            else:
                symbols_to_import = [item.name for item in node.imports]

            # First pass: compile all extern declarations and C imports
            for child in module_ast.block.children:
                if isinstance(child, (ExternFuncDecl, CImport)):
                    self.visit(child)

            # Second pass: compile exported types that are requested
            for child in module_ast.block.children:
                if isinstance(child, PublicDecl):
                    decl = child.declaration
                    if isinstance(decl, (ClassDeclaration, EnumDeclaration, TraitDeclaration, ErrorDeclaration)) and decl.name in symbols_to_import:
                        self.visit(child)

            # Third pass: compile pub functions
            for child in module_ast.block.children:
                if isinstance(child, PublicDecl):
                    decl = child.declaration
                    if isinstance(decl, FuncDecl) and decl.name in symbols_to_import:
                        func_key = f"{module_name}.{decl.name}"
                        if func_key not in self._compiled_funcs:
                            self._compiled_funcs.add(func_key)
                            self.visit(decl)

        except ImportError as e:
            error(f"file={self.file_name} line={node.line_num}: {e}")

    def visit_publicdecl(self, node):
        """Handle public declaration.

        Compiles the inner declaration and marks it as public.
        """
        return self.visit(node.declaration)

    def visit_moduledecl(self, node):
        """Handle module declaration.

        Module declarations are metadata only, no code generation needed.
        """
        pass

    def visit_importitem(self, node):
        """Handle import item - no code generation needed."""
        pass

    def visit_cimport(self, node):
        """Handle C header import using libclang."""
        # Store link libraries for later use in evaluate/compile
        self.link_libs.extend(node.link_libs)
        self.parse_c_header(node.header_file, node.link_libs, node.include_paths, node.namespace)

    def visit_spawn(self, node):
        """Generate code for spawn statement.

        spawn worker(data) creates a new thread to execute worker(data).

        Implementation:
        1. Create argument struct to pass data to thread
        2. Create wrapper function for pthread compatibility
        3. Call meteor_spawn runtime function
        """
        func_call = node.func_call
        func_name = func_call.name
        func = self.search_scopes(func_name)

        if func is None:
            error(f"file={self.file_name} line={node.line_num} Unknown function: {func_name}")

        i8_ptr = type_map[INT8].as_pointer()

        # Evaluate arguments
        args = [self.visit(arg) for arg in func_call.arguments]

        if len(args) == 0:
            # No arguments - simple case
            func_ptr = self.builder.bitcast(func, i8_ptr)
            null_ptr = ir.Constant(i8_ptr, None)
            spawn_func = self.module.get_global('meteor_spawn')
            return self.builder.call(spawn_func, [func_ptr, null_ptr])

        # Create argument struct type
        arg_types = [arg.type for arg in args]
        arg_struct_type = ir.LiteralStructType(arg_types)

        # Allocate argument struct on HEAP (not stack) so it survives after spawn returns
        malloc_func = self.module.get_global('malloc')
        struct_size = ir.Constant(type_map[INT64], sum(8 for _ in args))  # Approximate size
        arg_mem = self.builder.call(malloc_func, [struct_size])
        arg_struct_ptr = self.builder.bitcast(arg_mem, arg_struct_type.as_pointer())
        for i, arg in enumerate(args):
            ptr = self.builder.gep(arg_struct_ptr, [
                ir.Constant(type_map[INT32], 0),
                ir.Constant(type_map[INT32], i)
            ], inbounds=True)
            self.builder.store(arg, ptr)

        # Create unique wrapper function name using counter
        self.spawn_counter += 1
        wrapper_name = f"__spawn_wrapper_{func_name}_{self.spawn_counter}"

        # Create wrapper function
        # Windows: DWORD WINAPI ThreadProc(LPVOID) - returns i32
        # Unix: void* thread_func(void*) - returns i8*
        import sys
        if sys.platform == 'win32':
            wrapper_ret_type = type_map[INT32]
        else:
            wrapper_ret_type = i8_ptr

        wrapper_type = ir.FunctionType(wrapper_ret_type, [i8_ptr])
        wrapper_func = ir.Function(self.module, wrapper_type, wrapper_name)
        wrapper_func.linkage = 'internal'

        # Build wrapper function body
        entry = wrapper_func.append_basic_block('entry')
        wrapper_builder = ir.IRBuilder(entry)

        # Cast void* back to argument struct pointer
        raw_arg = wrapper_func.args[0]
        struct_ptr = wrapper_builder.bitcast(raw_arg, arg_struct_type.as_pointer())

        # Load arguments from struct
        call_args = []
        for i in range(len(args)):
            ptr = wrapper_builder.gep(struct_ptr, [
                ir.Constant(type_map[INT32], 0),
                ir.Constant(type_map[INT32], i)
            ], inbounds=True)
            call_args.append(wrapper_builder.load(ptr))

        # Call the actual function
        wrapper_builder.call(func, call_args)

        # Return appropriate type
        import sys
        if sys.platform == 'win32':
            wrapper_builder.ret(ir.Constant(type_map[INT32], 0))
        else:
            wrapper_builder.ret(ir.Constant(i8_ptr, None))

        # Call meteor_spawn with wrapper and packed args
        wrapper_ptr = self.builder.bitcast(wrapper_func, i8_ptr)
        arg_ptr = self.builder.bitcast(arg_struct_ptr, i8_ptr)

        spawn_func = self.module.get_global('meteor_spawn')
        thread_handle = self.builder.call(spawn_func, [wrapper_ptr, arg_ptr])

        # Memory fence to ensure thread creation is visible
        self.builder.fence('seq_cst')

        return thread_handle

    def visit_join(self, node):
        """Wait for a thread to complete."""
        handle = self.visit(node.handle_expr)
        join_func = self.module.get_global('meteor_join')
        self.builder.call(join_func, [handle])

    def comp_cast(self, arg, typ, node):
        # Auto-convert C string (i8*) to Meteor string (i64.array*)
        if arg.type == type_map[INT8].as_pointer():
            # Check if target type expects a Meteor string
            typ_str = str(typ)
            if 'i64.array' in typ_str:
                return self._convert_cstr_to_meteor_string(arg)

        if types_compatible(str(arg.type), typ):
            return cast_ops(self, arg, typ, node)

        return arg

    def visit_compound(self, node):
        ret = None
        for child in node.children:
            temp = self.visit(child)
            if temp:
                ret = temp
            # Stop generating code if current block is terminated (unreachable code)
            if hasattr(self, 'builder') and self.builder.block and self.builder.block.is_terminated:
                break
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
        for field_name, field in node.fields.items():
            field_type = self.get_type(field)
            fields.append(field_type)

        classdecl = self.module.context.get_identified_type(node.name)
        classdecl.base = node.base
        classdecl.defaults = {**self.get_super_defaults(classdecl), **node.defaults}
        classdecl.name = node.name
        classdecl.type = CLASS
        super_fields, super_elements = self.get_super_fields(classdecl)
        classdecl.fields = super_fields + [field for field in node.fields.keys()]
        classdecl.set_body(*(super_elements + [field for field in fields]))
        # Store weak fields info for RC handling
        classdecl.weak_fields = getattr(node, 'weak_fields', set())
        self.define(node.name, classdecl)
        for method in node.methods:
            self.funcdecl(method.name, method)

        for method in node.methods:
            self.funcdef(method.name, method, func_exists=True)
        classdecl.methods = [self.search_scopes(method.name) for method in node.methods]

        # Generate destructor function for this class
        self._generate_class_destructor(node.name, classdecl)

        self.define(node.name, classdecl)

    def visit_traitdeclaration(self, node):
        """Generate code for a trait declaration.
        
        Traits are metadata only - abstract methods generate nothing,
        default method implementations are compiled as regular functions.
        """
        # Compile default method implementations only
        for method_name, method in node.methods.items():
            if method.body is not None:
                # Default implementation - compile as a function
                self.funcdef(method.name, method)
        # No need to store trait info in LLVM - it's type-checking metadata

    def visit_implblock(self, node):
        """Generate code for an impl block.
        
        When a trait is implemented for a class, we compile all the methods
        as class methods. This enables static dispatch (monomorphization).
        """
        # Skip if no methods to compile
        if not node.methods:
            return
            
        # Get the class type
        class_type = self.search_scopes(node.class_name)
        
        # Compile all impl methods as class methods
        for method_name, method in node.methods.items():
            self.funcdecl(method.name, method)
        
        for method_name, method in node.methods.items():
            self.funcdef(method.name, method, func_exists=True)
        
        # Add methods to class if it exists
        if hasattr(class_type, 'methods'):
            impl_methods = [self.search_scopes(m.name) for m in node.methods.values()]
            class_type.methods = class_type.methods + impl_methods

    def visit_errordeclaration(self, node):
        """Generate code for an error enum declaration.
        
        Error enums are similar to regular enums but used for error handling.
        We store them as tagged integers.
        """
        # Create an enum-like structure for the error type
        error_type = self.module.context.get_identified_type(node.name)
        error_type.name = node.name
        error_type.type = ENUM
        error_type.fields = node.variants
        # Error value is just a single i8 tag
        error_type.set_body(type_map[INT8])
        self.define(node.name, error_type)

    def visit_raise(self, node):
        """Generate code for a raise statement."""
        error_val = self.visit(node.error_value)
        
        # Check for active catch block
        if self.catch_stack:
             store_ptr = self.catch_stack[-1]['storage']
             # Check type match/load if needed (error_val might be pointer, store needs value if alloca is {i8})
             # error_val should be matching type.
             # visit(node.error_value) returns value or pointer to i8?
             # visit_dotaccess returns pointer to { i8 ... }.
             
             # If error_val is pointer to struct, load it?
             # My logic in visit_dotaccess returns pointer to struct.
             # exception_store is alloca {i8}.
             
             # If error_val is pointer to {i8}, load it?
             if isinstance(error_val.type, ir.PointerType) and \
                isinstance(error_val.type.pointee, ir.IdentifiedStructType) and \
                len(error_val.type.pointee.elements) == 1 and \
                error_val.type.pointee.elements[0] == type_map[INT8]:
                    val_struct = self.builder.load(error_val)
                    tag = self.builder.extract_value(val_struct, 0)
                    
                    tag_store = self.builder.gep(store_ptr, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(tag, tag_store)
                    
             elif isinstance(error_val.type, ir.IdentifiedStructType):
                    # Extract tag
                    # tag = self.builder.extract_value(error_val, 0)
                    val = None
                    if isinstance(error_val, ir.Constant) and isinstance(error_val.constant, (list, tuple)):
                         val = error_val.constant[0]
                    else:
                         val = self.builder.extract_value(error_val, 0)
                    tag_store = self.builder.gep(store_ptr, [self.const(0), self.const(0, width=INT32)])
                    self.builder.store(val, tag_store)
             else:
                    # Fallback
                    self.builder.store(error_val, store_ptr)

             self.branch(self.catch_stack[-1]['landing_pad'])
             return True
             
        # Store in return variable as error {1, undef, error}
        if hasattr(self, 'current_function'): # Access RET_VAR via scope
            ret_var = self.search_scopes(RET_VAR)
            if ret_var:
                 tag_ptr = self.builder.gep(ret_var, [self.const(0), self.const(0, width=INT32)])
                 self.builder.store(self.const(1, width=INT8), tag_ptr)
                 
                 err_ptr = self.builder.gep(ret_var, [self.const(0), self.const(2, width=INT32)])
                 
                 # Check if error_val is pointer to what we need
                 if isinstance(error_val.type, ir.PointerType) and error_val.type.pointee == err_ptr.type.pointee:
                     error_val = self.builder.load(error_val)
                     
                 self.builder.store(error_val, err_ptr)
                 self.branch(self.exit_blocks[-1])
            else:
                 # Void function uncaught raise
                 self.branch(self.exit_blocks[-1])

        return True

    def visit_trystatement(self, node):
        """Generate code for a try/catch statement."""
        # Blocks
        try_body = self.add_block('try.body')
        try_landing = self.add_block('try.landing')
        try_end = self.add_block('try.end')
        
        # Exception storage for this try block (Union Error Type {i8})
        # We assume all errors are currently simple Enums (i8 tag inside struct)
        # So we allocate {i8}
        error_struct_type = ir.LiteralStructType([type_map[INT8]])
        exception_store = self.builder.alloca(error_struct_type, name='exception_store')
        
        # Push landing pad and storage to stack
        self.catch_stack.append({
            'landing_pad': try_landing,
            'storage': exception_store
        })
        
        # 1. Generate Try Body
        self.branch(try_body)
        self.position_at_end(try_body)
        self.visit(node.try_block)
        
        # If try finishes successfully, jump to end
        if not self.is_break and not self.builder.block.is_terminated:
             self.branch(try_end)
             
        # Pop stack
        self.catch_stack.pop()
        
        # 2. Generate Landing Pad (Catch Dispatcher)
        self.position_at_end(try_landing)

        # RFC-001: Unwind safety - release all active managed variables
        self.release_scope_variables()

        # Load exception from local storage
        current_error = self.builder.load(exception_store)
        
        # Dispatch to catch clauses
        next_check_block = None
        
        for i, clause in enumerate(node.catch_clauses):
             # Block for this catch body
             catch_body_block = self.add_block(f'catch.body.{i}')
             # Block for next check (if mismatch)
             next_check_block = self.add_block(f'catch.next.{i}')
             
             # Check match
             target_error = self.visit(clause.error_pattern)
             
             # Extract tag from target_error (Enum Value)
             if isinstance(target_error, ir.Constant) and isinstance(target_error.constant, (list, tuple)):
                 # Constant folding optimization
                 target_error = target_error.constant[0]
             else:
                 # If target_error is a pointer, load it first
                 if isinstance(target_error.type, ir.PointerType):
                     target_error = self.builder.load(target_error)
                 # Fallback: extract instruction
                 target_error = self.builder.extract_value(target_error, 0)
             
             # Extract i8 from current_error (which is {i8})
             current_error_val = self.builder.extract_value(current_error, 0)
             
             # Compare current_error_val == target_error
             is_match = self.builder.icmp_unsigned(EQUALS, current_error_val, target_error)
             self.cbranch(is_match, catch_body_block, next_check_block)
             
             # Generate Catch Body
             self.position_at_end(catch_body_block)
             self.visit(clause.body)
             if not self.is_break and not self.builder.block.is_terminated:
                 self.branch(try_end)
             self.is_break = False # Reset break flag for local scope
             
             # Move to next check
             self.position_at_end(next_check_block)

        # If no catch matched (re-throw)
        if self.catch_stack:
             # Propagate to outer try
             # Store current error to outer storage
             outer_store = self.catch_stack[-1]['storage']
             self.builder.store(current_error, outer_store)
             self.branch(self.catch_stack[-1]['landing_pad'])
        else:
             # Propagate to function exit
             # Requires RET_VAR to exist if we are propagating out of function
             ret_var = self.search_scopes(RET_VAR)
             if ret_var: # If non-void function
                 tag_ptr = self.builder.gep(ret_var, [self.const(0), self.const(0, width=INT32)])
                 self.builder.store(self.const(1, width=INT8), tag_ptr)
                 
                 err_ptr = self.builder.gep(ret_var, [self.const(0), self.const(2, width=INT32)])
                 self.builder.store(current_error, err_ptr)
                 self.branch(self.exit_blocks[-1])
             else:
                 # Void function with uncaught exception? 
                 # This is a runtime crash in most languages. 
                 # For now, just return/exit (swallowing error if void) or printf("Uncaught Exception")?
                 # Ignoring strictly for now or just returning.
                 self.branch(self.exit_blocks[-1])
             
        # 3. Try End
        self.position_at_end(try_end)
        
    def visit_errorpropagation(self, node):
        """Generate code for error propagation (?) operator.
        
        If expr returns error tag, return error from CURRENT function (propagate).
        Else, unwrap and use success value.
        """
        val = self.visit(node.expr)
        
        # Handle if val is value or pointer
        if isinstance(val.type, ir.LiteralStructType):
            val_ptr = self.builder.alloca(val.type)
            self.builder.store(val, val_ptr)
        else:
            val_ptr = val
            
        # Check tag (index 0)
        tag_ptr = self.builder.gep(val_ptr, [self.const(0), self.const(0, width=INT32)])
        tag = self.builder.load(tag_ptr)
        
        # Create blocks
        error_block = self.add_block('prop.error')
        success_block = self.add_block('prop.success')
        
        cond = self.builder.icmp_unsigned(EQUALS, tag, self.const(1, width=INT8))
        self.cbranch(cond, error_block, success_block)
        
        # Error Block: Propagate error
        self.position_at_end(error_block)
        
        # Load error from val
        err_val_ptr = self.builder.gep(val_ptr, [self.const(0), self.const(2, width=INT32)])
        err_val = self.builder.load(err_val_ptr)
        
        # Check for active catch block
        if self.catch_stack:
             store_ptr = self.catch_stack[-1]['storage']
             
             # Extract tag from err_val (which is %MyError matching {i8})
             tag = self.builder.extract_value(err_val, 0)
             tag_store = self.builder.gep(store_ptr, [self.const(0), self.const(0, width=INT32)])
             self.builder.store(tag, tag_store)
             
             self.branch(self.catch_stack[-1]['landing_pad'])
        else:
            ret_var = self.search_scopes(RET_VAR)
            # Store to current function return: {1, undef, err}
            ret_tag_ptr = self.builder.gep(ret_var, [self.const(0), self.const(0, width=INT32)])
            self.builder.store(self.const(1, width=INT8), ret_tag_ptr)
            ret_err_ptr = self.builder.gep(ret_var, [self.const(0), self.const(2, width=INT32)])
            self.builder.store(err_val, ret_err_ptr)
            self.branch(self.exit_blocks[-1])
        
        # Success Block: Unwrap value
        self.position_at_end(success_block)
        
        # Load result
        res_val_ptr = self.builder.gep(val_ptr, [self.const(0), self.const(1, width=INT32)])
        return self.builder.load(res_val_ptr)

    def visit_incrementassign(self, node):
        collection_access = None
        key = None
        if isinstance(node.left, CollectionAccess):
            collection_access = True
            var_name = self.search_scopes(node.left.collection.value)
            pointee = var_name.type.pointee
            # Data pointer is at index 3: { header, size, capacity, data* }
            data_ptr_elem = pointee.elements[3]
            if hasattr(data_ptr_elem, 'pointee'):
                array_type = str(data_ptr_elem.pointee)
            else:
                struct_name = getattr(pointee, 'name', str(pointee))
                if '.array' in struct_name:
                    array_type = struct_name.replace('.array', '')
                else:
                    array_type = str(data_ptr_elem)
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
        # Handle NullableType which doesn't have .value attribute
        if isinstance(node.type, NullableType):
            self.alloc_and_define(node.value.value, typ)
        elif node.type.value == FUNC:
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

    def visit_nullabletype(self, node):
        """Handle nullable type annotation (e.g., int?, str?).
        
        Returns the LLVM struct type { i1 is_null, T value }.
        """
        inner_type = self.get_type(node.inner_type)
        nullable_struct = ir.LiteralStructType([ir.IntType(1), inner_type])
        return nullable_struct

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
            # Push a new managed vars list for this block (but NOT a new variable scope)
            self.managed_vars_stack.append([])
            ret = self.visit(node.blocks[x])
            # Release managed variables created in this block
            # Use set_null=True to prevent double-release in loops
            if not self.builder.block.is_terminated:
                self.release_scope_variables(set_null=True)
                if not self.is_break:
                    self.branch(end_block)
            # Pop the managed vars list
            self.managed_vars_stack.pop()
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
        # Note: We do NOT push a new managed_vars_stack for loop iterations.
        # Class variables declared in loops use entry block allocas with NULL init.
        # The alloc_define_store function handles releasing old values before storing new ones.
        # At function exit, release_scope_variables will clean up all managed vars.
        self.visit(node.block)
        # Branch back to condition or to end (for break)
        if not self.builder.block.is_terminated:
            if not self.is_break:
                self.branch(cond_block)
            else:
                self.branch(end_block)
        if self.is_break:
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
            iterator = self.visit(node.iterator)
            array_type = "i64"
        else:
            iterator_ptr = self.search_scopes(node.iterator.value)
            iterator = self.load(iterator_ptr)
            array_type = str(iterator.type.pointee.elements[-1].pointee)

        stop = self.call('{}.array.length'.format(array_type), [iterator])
        self.branch(zero_length_block)

        self.position_at_end(zero_length_block)
        cond = self.builder.icmp_signed(LESS_THAN, zero, stop)
        self.cbranch(cond, non_zero_length_block, end_block)

        self.position_at_end(non_zero_length_block)
        varname = node.elements[0].value
        val = self.call('{}.array.get'.format(array_type), [iterator, zero])
        # Array: { header, size, capacity, data* } - data at index 3
        self.alloc_define_store(val, varname, iterator.type.pointee.elements[3].pointee)
        position = self.alloc_define_store(zero, 'position', type_map[INT])
        # Store stop in memory to ensure it's available across basic blocks
        stop_ptr = self.alloc_define_store(stop, 'stop', type_map[INT])
        self.branch(cond_block)

        self.position_at_end(cond_block)
        cond = self.builder.icmp_signed(LESS_THAN, self.load(position), self.load(stop_ptr))
        self.cbranch(cond, body_block, end_block)

        self.position_at_end(body_block)
        # Note: We do NOT push a new managed_vars_stack for loop iterations.
        # Class variables declared in loops use entry block allocas with NULL init.
        # The alloc_define_store function handles releasing old values before storing new ones.
        self.store(self.call('{}.array.get'.format(array_type), [iterator, self.load(position)]), varname)
        self.store(self.builder.add(one, self.load(position)), position)
        self.visit(node.block)
        # Branch back to condition or to end (for break)
        if not self.builder.block.is_terminated:
            if not self.is_break:
                self.branch(cond_block)
            else:
                self.branch(end_block)
        if self.is_break:
            self.is_break = False

        self.position_at_end(end_block)
        self.loop_test_blocks.pop()
        self.loop_end_blocks.pop()

    def visit_loopblock(self, node):
        ret = None
        for child in node.children:
            temp = self.visit(child)
            if temp:
                ret = temp
            # Stop generating code if current block is terminated (unreachable code)
            if hasattr(self, 'builder') and self.builder.block and self.builder.block.is_terminated:
                break
        return ret

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
        # Release managed variables in current scope before breaking
        # Don't need set_null=True for break since we're exiting the loop
        self.release_scope_variables()
        self.is_break = True
        return self.branch(self.loop_end_blocks[-1])

    def visit_continue(self, _):
        # Release managed variables in current scope before continuing
        # Use set_null=True to prevent double-release on next loop iteration
        self.release_scope_variables(set_null=True)
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
        return array_ptr

    def visit_assign(self, node):
        if hasattr(node.right, 'value') and isinstance(self.search_scopes(node.right.value), ir.Function):
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
                    # BigInt: { header, sign, digits } - digits at index 2
                    old_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                    old_digits = self.builder.load(old_digits_ptr)
                    null_ptr = ir.Constant(old_digits.type, None)
                    is_not_null = self.builder.icmp_unsigned('!=', old_digits, null_ptr)

                    with self.builder.if_then(is_not_null):
                        # Array: { header, size, capacity, data } - RC in header at index 0
                        from meteor.compiler.base import HEADER_STRONG_RC
                        header_ptr = self.builder.gep(old_digits, [self.const(0), self.const(0, width=INT32)])
                        rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                        rc = self.builder.load(rc_ptr)
                        new_rc = self.builder.sub(rc, ir.Constant(type_map[UINT32], 1))
                        self.builder.store(new_rc, rc_ptr)
                        is_zero = self.builder.icmp_unsigned('==', new_rc, ir.Constant(type_map[UINT32], 0))
                        with self.builder.if_then(is_zero):
                            # data at index 3
                            data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
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
                        self.call('i64.array.append', [u64_array_ptr, ir.Constant(type_map[UINT64], 0)])
                    else:
                        while abs_val > 0:
                            digit = abs_val % BASE
                            self.call('i64.array.append', [u64_array_ptr, ir.Constant(type_map[UINT64], digit)])
                            abs_val //= BASE
                    
                    # Store sign (BigInt: { header, sign, digits } - sign at index 1)
                    sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(ir.Constant(type_map[BOOL], is_negative), sign_ptr)

                    # Store digits array pointer (digits at index 2)
                    digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
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
                         # BigInt: { header, sign, digits } - digits at index 2
                         old_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                         old_digits = self.builder.load(old_digits_ptr)
                         null_ptr = ir.Constant(old_digits.type, None)
                         is_not_null = self.builder.icmp_unsigned('!=', old_digits, null_ptr)

                         with self.builder.if_then(is_not_null):
                             # Array: { header, size, capacity, data } - RC in header
                             from meteor.compiler.base import HEADER_STRONG_RC
                             header_ptr = self.builder.gep(old_digits, [self.const(0), self.const(0, width=INT32)])
                             rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                             rc = self.builder.load(rc_ptr)
                             new_rc = self.builder.sub(rc, ir.Constant(type_map[UINT32], 1))
                             self.builder.store(new_rc, rc_ptr)
                             is_zero = self.builder.icmp_unsigned('==', new_rc, ir.Constant(type_map[UINT32], 0))
                             with self.builder.if_then(is_zero):
                                 # data at index 3
                                 data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
                                 data = self.builder.load(data_ptr)
                                 data_i8 = self.builder.bitcast(data, type_map[INT8].as_pointer())
                                 self.call('free', [data_i8])
                                 digits_i8 = self.builder.bitcast(old_digits, type_map[INT8].as_pointer())
                                 self.call('free', [digits_i8])

                         # Copy Sign (sign at index 1)
                         src_sign_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(1, width=INT32)])
                         sign = self.builder.load(src_sign_ptr)
                         dst_sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                         self.builder.store(sign, dst_sign_ptr)

                         # Copy Digits Pointer (digits at index 2)
                         src_digits_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(2, width=INT32)])
                         digits = self.builder.load(src_digits_ptr)
                         dst_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                         self.builder.store(digits, dst_digits_ptr)

                         # Shared ownership: if initializing from an L-value, increment RC
                         is_lvalue = isinstance(node.right, (Var, DotAccess, CollectionAccess))
                         if is_lvalue:
                             # RC in header at index 0
                             from meteor.compiler.base import HEADER_STRONG_RC
                             header_ptr = self.builder.gep(digits, [self.const(0), self.const(0, width=INT32)])
                             new_rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                             cur_rc = self.builder.load(new_rc_ptr)
                             inc_rc = self.builder.add(cur_rc, ir.Constant(type_map[UINT32], 1))
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
                         
                         # Store sign (BigInt: { header, sign, digits } - sign at index 1)
                         sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                         self.builder.store(is_negative, sign_ptr)

                         # Store digits array pointer (digits at index 2)
                         digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
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

                    # BigInt: { header, sign, digits } - sign at index 1, digits at index 2
                    sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(ir.Constant(type_map[BOOL], is_negative), sign_ptr)
                    digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                    self.builder.store(u64_array_ptr, digits_ptr)

                    # Decimal: { header, mantissa, exponent } - mantissa at index 1, exponent at index 2
                    mantissa_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(1, width=INT32)])
                    self.builder.store(bigint_ptr, mantissa_field_ptr)
                    exponent_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(2, width=INT32)])
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

                        # BigInt: { header, sign, digits } - sign at index 1, digits at index 2
                        sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(is_negative, sign_ptr)
                        digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                        self.builder.store(u64_array_ptr, digits_ptr)

                        # Decimal: { header, mantissa, exponent } - mantissa at index 1, exponent at index 2
                        mantissa_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(bigint_ptr, mantissa_field_ptr)
                        exponent_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(2, width=INT32)])
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
                    var_type = self.get_type(node.left.type)
                    if not var.type.is_pointer:
                        casted_value = cast_ops(self, var, var_type, node)
                        self.alloc_define_store(casted_value, var_name, var_type)
                    else:  # TODO: Not able currently to deal with pointers, such as functions
                        self.alloc_define_store(var, var_name, var.type)

            elif isinstance(node.left, DotAccess):
                obj = self.search_scopes(node.left.obj)
                # Handle _TypedPointerType which doesn't have 'name' attribute
                pointee = obj.type.pointee

                # Check if obj is pointer-to-pointer (alloca'd class variable)
                # If so, load it first to get the actual struct pointer
                if hasattr(pointee, 'pointee'):
                    # obj is Thing**, load to get Thing*
                    loaded_obj = self.builder.load(obj)
                    actual_pointee = pointee.pointee
                else:
                    loaded_obj = obj
                    actual_pointee = pointee

                # Get type name from the actual struct type
                if hasattr(actual_pointee, 'name'):
                    type_name = actual_pointee.name.split('.')[-1]
                else:
                    type_str = str(actual_pointee)
                    if type_str.startswith('%"'):
                        type_name = type_str.split('"')[1].split('.')[-1]
                    elif type_str.startswith('%'):
                        type_name = type_str[1:].split('.')[-1]
                    else:
                        type_name = type_str.split('.')[-1]

                obj_type = self.search_scopes(type_name)
                idx = -1
                for i, v in enumerate(obj_type.fields):
                    if v == node.left.field:
                        idx = i
                        break

                elem = self.builder.gep(loaded_obj, [self.const(0, width=INT32), self.const(idx, width=INT32)], inbounds=True)

                # Handle empty list assignment with type inference from field type
                is_empty_list = isinstance(node.right, Collection) and len(node.right.items) == 0 and node.right.type == LIST
                if is_empty_list:
                    # Get expected type from field (elem.type is T**, elem.type.pointee is T*)
                    expected_ptr_type = elem.type.pointee
                    # For array fields, the type is like %"Header.array"*
                    if hasattr(expected_ptr_type, 'pointee'):
                        expected_struct = expected_ptr_type.pointee
                        if hasattr(expected_struct, 'name') and '.array' in expected_struct.name:
                            # Extract element type name (e.g., '%"Header".array' -> 'Header')
                            elem_type_name = expected_struct.name.replace('.array', '')
                            # Remove LLVM type prefix and quotes
                            elem_type_name = elem_type_name.lstrip('%').strip('"')
                            elem_type = self.search_scopes(elem_type_name)
                            if elem_type is not None:
                                # Create array with the struct type (not pointer)
                                val = self.define_array(node.right, [], explicit_type=elem_type)
                            else:
                                val = self.visit(node.right)
                        else:
                            val = self.visit(node.right)
                    else:
                        val = self.visit(node.right)
                else:
                    val = self.visit(node.right)

                # Auto-convert C string (i8*) to Meteor string (i64.array*) for string fields
                if val.type == type_map[INT8].as_pointer():
                    # Check if target field expects a Meteor string (i64.array*)
                    expected_type = elem.type.pointee
                    if hasattr(expected_type, 'pointee'):
                        inner_type = expected_type.pointee
                        if hasattr(inner_type, 'name') and inner_type.name == 'i64.array':
                            val = self._convert_cstr_to_meteor_string(val)

                # If val is a pointer to a struct and elem expects the struct value, load it
                if isinstance(val.type, ir.PointerType) and not isinstance(elem.type.pointee, ir.PointerType):
                    if hasattr(val.type.pointee, 'name') and hasattr(elem.type.pointee, 'name'):
                        val = self.builder.load(val)

                # Check frozen before writing to field
                self.check_frozen_write(loaded_obj)

                # Check if this is a weak field and handle RC accordingly
                is_weak_field = hasattr(obj_type, 'weak_fields') and node.left.field in obj_type.weak_fields
                if is_weak_field and self.is_managed_type(elem.type.pointee):
                    # Weak field: use weak_retain instead of retain
                    # Release old value first
                    old_val = self.builder.load(elem)
                    null_ptr = ir.Constant(old_val.type, None)
                    is_not_null = self.builder.icmp_unsigned('!=', old_val, null_ptr)
                    with self.builder.if_then(is_not_null):
                        self.rc_weak_release(old_val)
                    self.rc_weak_retain(val)
                    self.builder.store(val, elem)
                elif self.is_managed_type(elem.type.pointee):
                    # Strong field: release old value, retain new, then store
                    old_val = self.builder.load(elem)
                    null_ptr = ir.Constant(old_val.type, None)
                    is_not_null = self.builder.icmp_unsigned('!=', old_val, null_ptr)
                    with self.builder.if_then(is_not_null):
                        self.rc_release(old_val)
                    self.rc_retain(val)
                    self.builder.store(val, elem)
                    # Release temporary value after assignment (retain already increased RC)
                    if self._is_temp_managed_value(val, node.right):
                        self.rc_release(val)
                else:
                    self.builder.store(val, elem)
            elif isinstance(node.left, CollectionAccess):
                right = self.visit(node.right)
                collection_var = self.search_scopes(node.left.collection.value)
                pointee = collection_var.type.pointee
                # Data pointer is at index 3: { header, size, capacity, data* }
                data_ptr_elem = pointee.elements[3]
                if hasattr(data_ptr_elem, 'pointee'):
                    array_type = str(data_ptr_elem.pointee)
                else:
                    # Fallback: extract from struct name (e.g., "double.array" -> "double")
                    struct_name = getattr(pointee, 'name', str(pointee))
                    if '.array' in struct_name:
                        array_type = struct_name.replace('.array', '')
                    else:
                        array_type = str(data_ptr_elem)
                self.call('{}.array.set'.format(array_type), [collection_var, self.const(node.left.key.value), right])
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
                            
                            # === Release old digits before creating new ===
                            # BigInt: { header, sign, digits } - digits at index 2
                            old_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                            old_digits = self.builder.load(old_digits_ptr)
                            null_ptr = ir.Constant(old_digits.type, None)
                            is_not_null = self.builder.icmp_unsigned('!=', old_digits, null_ptr)

                            with self.builder.if_then(is_not_null):
                                from meteor.compiler.base import HEADER_STRONG_RC
                                header_ptr = self.builder.gep(old_digits, [self.const(0), self.const(0, width=INT32)])
                                rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                                rc = self.builder.load(rc_ptr)
                                new_rc = self.builder.sub(rc, ir.Constant(type_map[UINT32], 1))
                                self.builder.store(new_rc, rc_ptr)
                                is_zero = self.builder.icmp_unsigned('==', new_rc, ir.Constant(type_map[UINT32], 0))
                                with self.builder.if_then(is_zero):
                                    data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
                                    data = self.builder.load(data_ptr)
                                    data_i8 = self.builder.bitcast(data, type_map[INT8].as_pointer())
                                    self.call('free', [data_i8])
                                    digits_i8 = self.builder.bitcast(old_digits, type_map[INT8].as_pointer())
                                    self.call('free', [digits_i8])
                            
                            u64_array_ptr = self.create_array(type_map[UINT64])
                            
                            BASE = 2**64
                            if abs_val == 0:
                                self.call('i64.array.append', [u64_array_ptr, self.const(0)])
                            else:
                                while abs_val > 0:
                                    digit = abs_val % BASE
                                    self.call('i64.array.append', [u64_array_ptr, self.const(digit)])
                                    abs_val //= BASE
                            
                            sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                            self.builder.store(ir.Constant(type_map[BOOL], is_negative), sign_ptr)

                            digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
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
                                # BigInt: { header, sign, digits } - digits at index 2
                                old_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                                old_digits = self.builder.load(old_digits_ptr)
                                null_ptr = ir.Constant(old_digits.type, None)
                                is_not_null = self.builder.icmp_unsigned('!=', old_digits, null_ptr)

                                with self.builder.if_then(is_not_null):
                                    # Decrement refcount - RC in header
                                    from meteor.compiler.base import HEADER_STRONG_RC
                                    header_ptr = self.builder.gep(old_digits, [self.const(0), self.const(0, width=INT32)])
                                    rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                                    rc = self.builder.load(rc_ptr)
                                    new_rc = self.builder.sub(rc, ir.Constant(type_map[UINT32], 1))
                                    self.builder.store(new_rc, rc_ptr)
                                    # Free if refcount == 0
                                    is_zero = self.builder.icmp_unsigned('==', new_rc, ir.Constant(type_map[UINT32], 0))
                                    with self.builder.if_then(is_zero):
                                        # data at index 3
                                        data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
                                        data = self.builder.load(data_ptr)
                                        data_i8 = self.builder.bitcast(data, type_map[INT8].as_pointer())
                                        self.call('free', [data_i8])
                                        digits_i8 = self.builder.bitcast(old_digits, type_map[INT8].as_pointer())
                                        self.call('free', [digits_i8])

                                # Copy sign (sign at index 1)
                                src_sign_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(1, width=INT32)])
                                sign = self.builder.load(src_sign_ptr)
                                dst_sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                                self.builder.store(sign, dst_sign_ptr)

                                # Copy digits pointer (digits at index 2)
                                src_digits_ptr = self.builder.gep(src_ptr, [self.const(0), self.const(2, width=INT32)])
                                digits = self.builder.load(src_digits_ptr)
                                dst_digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                                self.builder.store(digits, dst_digits_ptr)

                                # Shared ownership: if assigning from an L-value, increment RC
                                is_lvalue = isinstance(node.right, (Var, DotAccess, CollectionAccess))
                                if is_lvalue:
                                    # RC in header
                                    from meteor.compiler.base import HEADER_STRONG_RC
                                    header_ptr = self.builder.gep(digits, [self.const(0), self.const(0, width=INT32)])
                                    new_rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                                    cur_rc = self.builder.load(new_rc_ptr)
                                    inc_rc = self.builder.add(cur_rc, ir.Constant(type_map[UINT32], 1))
                                    self.builder.store(inc_rc, new_rc_ptr)
                            else:
                                # Existing logic for runtime int values
                                val = var

                                zero = self.const(0)
                                is_negative = self.builder.icmp_signed(LESS_THAN, val, zero)
                                abs_val = self.builder.select(is_negative, self.builder.neg(val), val)

                                u64_array_ptr = self.create_array(type_map[UINT64])
                                self.call('i64.array.append', [u64_array_ptr, abs_val])

                                # BigInt: { header, sign, digits } - sign at index 1, digits at index 2
                                sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                                self.builder.store(is_negative, sign_ptr)

                                digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                                self.builder.store(u64_array_ptr, digits_ptr)

                    elif var_value.type == type_map[DECIMAL].as_pointer():
                        # Decimal Assignment (Re-assignment)
                        val = var
                        decimal_ptr = var_value
                        
                        # === Release old mantissa before creating new ===
                        # Decimal: { header, mantissa, exponent } - mantissa at index 1
                        old_mantissa_ptr_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(1, width=INT32)])
                        old_mantissa_ptr = self.builder.load(old_mantissa_ptr_ptr)
                        null_ptr = ir.Constant(old_mantissa_ptr.type, None)
                        is_not_null = self.builder.icmp_unsigned('!=', old_mantissa_ptr, null_ptr)

                        with self.builder.if_then(is_not_null):
                            # Release old mantissa's digits array
                            # BigInt: { header, sign, digits } - digits at index 2
                            old_digits_ptr = self.builder.gep(old_mantissa_ptr, [self.const(0), self.const(2, width=INT32)])
                            old_digits = self.builder.load(old_digits_ptr)
                            digits_null = ir.Constant(old_digits.type, None)
                            digits_not_null = self.builder.icmp_unsigned('!=', old_digits, digits_null)
                            
                            with self.builder.if_then(digits_not_null):
                                from meteor.compiler.base import HEADER_STRONG_RC
                                header_ptr = self.builder.gep(old_digits, [self.const(0), self.const(0, width=INT32)])
                                rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                                rc = self.builder.load(rc_ptr)
                                new_rc = self.builder.sub(rc, ir.Constant(type_map[UINT32], 1))
                                self.builder.store(new_rc, rc_ptr)
                                is_zero = self.builder.icmp_unsigned('==', new_rc, ir.Constant(type_map[UINT32], 0))
                                with self.builder.if_then(is_zero):
                                    data_ptr = self.builder.gep(old_digits, [self.const(0), self.const(3, width=INT32)])
                                    data = self.builder.load(data_ptr)
                                    data_i8 = self.builder.bitcast(data, type_map[INT8].as_pointer())
                                    self.call('free', [data_i8])
                                    digits_i8 = self.builder.bitcast(old_digits, type_map[INT8].as_pointer())
                                    self.call('free', [digits_i8])
                        
                        # 1. Handle value conversion (Int/Double -> "Int")
                        val_int = val
                        if isinstance(val.type, ir.DoubleType) or isinstance(val.type, ir.FloatType):
                            val_int = self.builder.fptosi(val, type_map[INT])
                        
                        # 2. Create Mantissa (BigInt)
                        bigint_struct_type = type_map[BIGINT]
                        bigint_ptr = self.builder.alloca(bigint_struct_type, name="mantissa_reassign")

                        zero = self.const(0)
                        is_negative = self.builder.icmp_signed(LESS_THAN, val_int, zero)
                        abs_val = self.builder.select(is_negative, self.builder.neg(val_int), val_int)
                        
                        u64_array_ptr = self.create_array(type_map[UINT64])
                        self.call('i64.array.append', [u64_array_ptr, abs_val])
                        
                        # BigInt: { header, sign, digits } - sign at index 1, digits at index 2
                        sign_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(is_negative, sign_ptr)
                        digits_ptr = self.builder.gep(bigint_ptr, [self.const(0), self.const(2, width=INT32)])
                        self.builder.store(u64_array_ptr, digits_ptr)
                        
                        # 3. Store Mantissa Pointer (Decimal: { header, mantissa, exponent } - index 1)
                        mantissa_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(1, width=INT32)])
                        self.builder.store(bigint_ptr, mantissa_field_ptr)
                        
                        # 4. Store Exponent (0) (Decimal: exponent at index 2)
                        exponent_field_ptr = self.builder.gep(decimal_ptr, [self.const(0), self.const(2, width=INT32)])
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
                        # For managed types (classes, arrays), use rc_assign for proper RC handling
                        if hasattr(var_value, 'type') and hasattr(var_value.type, 'pointee'):
                            if self.is_managed_type(var_value.type.pointee):
                                # If assigning from a variable (not temp), retain the new value
                                # Temp values already have RC=1, but variable refs need retain
                                # Note: CollectionAccess already retains in visit_collectionaccess
                                is_from_variable = isinstance(node.right, (Var, DotAccess))
                                if is_from_variable:
                                    self.rc_retain(var)
                                # rc_assign handles: null check on old, release old, store new
                                self.rc_assign(var_value, var)
                            else:
                                # Cast if types don't match (e.g., C function returning double to int variable)
                                target_type = var_value.type.pointee
                                if var.type != target_type:
                                    var = cast_ops(self, var, target_type, node)
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
        """Create a class instance with heap allocation and object header.
        
        Memory layout: [Object Header (16 bytes)][Class Fields]
        Object Header contains:
            - strong_rc (u32): Strong reference count, starts at 1
            - weak_rc (u32): Weak reference count
            - flags (u8): Object flags (frozen, zombie, etc.)
            - type_tag (u8): Type tag for runtime type info
            - reserved (u16 + u32): Padding for alignment
        
        The returned pointer points to the class data (after header).
        Reference counting is managed through meteor_retain/meteor_release.
        """
        from meteor.compiler.base import OBJECT_HEADER, TYPE_TAG_CLASS

        class_type = self.search_scopes(node.name)

        # Ensure destructor is generated for this class type
        if not hasattr(class_type, 'destructor'):
            self._generate_class_destructor(node.name, class_type)

        # Calculate size: object header (16 bytes) + class fields
        header_size = 16  # 4 + 4 + 1 + 1 + 2 + padding
        class_size = self.get_type_size(class_type)
        total_size = header_size + class_size

        # Allocate memory using malloc
        malloc_func = self.module.get_global('malloc')
        raw_mem = self.builder.call(malloc_func, [self.const(total_size)])

        # Initialize object header
        header_struct = self.search_scopes(OBJECT_HEADER)
        if header_struct:
            header_ptr = self.builder.bitcast(raw_mem, header_struct.as_pointer())
            # strong_rc = 1 (object starts with 1 owner)
            rc_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(0, width=INT32)])
            self.builder.store(self.const(1, width=UINT32), rc_ptr)
            # weak_rc = 0
            weak_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(1, width=INT32)])
            self.builder.store(self.const(0, width=UINT32), weak_ptr)
            # flags = 0
            flags_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(2, width=INT32)])
            self.builder.store(self.const(0, width=UINT8), flags_ptr)
            # type_tag = TYPE_TAG_CLASS
            tag_ptr = self.builder.gep(header_ptr, [self.const(0), self.const(3, width=INT32)])
            self.builder.store(self.const(TYPE_TAG_CLASS, width=UINT8), tag_ptr)

        # Get pointer to class data (after header)
        data_ptr = self.builder.gep(raw_mem, [self.const(header_size)])
        _class = self.builder.bitcast(data_ptr, class_type.as_pointer())

        # Initialize all pointer fields to NULL to prevent garbage pointers
        for i, field_name in enumerate(class_type.fields):
            field_type = class_type.elements[i]
            if isinstance(field_type, ir.PointerType):
                elem = self.builder.gep(_class, [self.const(0, width=INT32), self.const(i, width=INT32)], inbounds=True)
                null_val = ir.Constant(field_type, None)
                self.builder.store(null_val, elem)

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
                # Convert value to target field type if needed
                target_type = class_type.elements[pos]
                if val.type != target_type:
                    # Handle bigint conversion
                    if getattr(target_type, 'name', '') == 'bigint' and isinstance(val.type, ir.IntType):
                        from meteor.compiler.operations import int_to_bigint
                        val = int_to_bigint(self, val)
                        val = self.builder.load(val)
                    elif isinstance(target_type, ir.IntType) and isinstance(val.type, ir.IntType):
                        if target_type.width > val.type.width:
                            val = self.builder.sext(val, target_type)
                        else:
                            val = self.builder.trunc(val, target_type)
                    elif hasattr(target_type, 'pointee'):
                        val = self.builder.bitcast(val, target_type)
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
        """Handle dot access for field access, enum variants, and module namespaces.

        Cases handled:
        1. Module namespace access: http.server.Request
        2. C namespace access: c.MeteorHttpServer (returns marker for C type)
        3. Enum variant access: HttpMethod.GET
        4. Field access: self.headers, req.path
        """
        from meteor.ast import DotAccess as DotAccessAST

        # Helper to build full path from nested DotAccess
        def build_path(n):
            if isinstance(n, DotAccessAST):
                return f"{build_path(n.obj)}.{n.field}"
            return n  # It's a string (variable name)

        full_path = f"{build_path(node.obj)}.{node.field}"
        base_name = build_path(node.obj) if isinstance(node.obj, DotAccessAST) else node.obj

        # Case 1: C namespace access (e.g., c.MeteorHttpServer)
        if base_name == 'c':
            # Return a marker dict for C namespace reference
            return {'__c_namespace__': True, '__name__': node.field}

        # Case 2: Try to find full path as type/function (e.g., http.server.Request)
        typ = self.search_scopes(full_path)
        if typ is not None:
            # Check if it's an enum type - return the type itself
            if hasattr(typ, 'type') and typ.type == ENUM:
                return typ
            # Check if it's a function
            if isinstance(typ, ir.Function):
                return typ
            # It's a type reference
            return typ

        # Case 3: Try to find base as enum and field as variant
        base_obj = self.search_scopes(base_name)
        if base_obj is not None:
            # Check if it's an enum type
            if hasattr(base_obj, 'type') and base_obj.type == ENUM:
                enum = self.builder.alloca(base_obj)
                idx = base_obj.fields.index(node.field)
                val = self.builder.gep(enum, [self.const(0, width=INT32), self.const(0, width=INT32)], inbounds=True)
                self.builder.store(self.const(idx, width=INT8), val)
                return enum
            # Check if it's a module dict
            if isinstance(base_obj, dict) and '__module__' in base_obj:
                # Module function/type access
                func = self.module.get_global(node.field)
                if func is not None:
                    return func
                # Try with module prefix
                module_name = base_obj['__module__'].name if hasattr(base_obj['__module__'], 'name') else str(base_obj['__module__'])
                func = self.search_scopes(f"{module_name}.{node.field}")
                if func is not None:
                    return func

        # Case 4: Field access on object
        # First, try to get the object value
        if isinstance(node.obj, str):
            obj = self.search_scopes(node.obj)
        elif hasattr(node.obj, 'value') and isinstance(node.obj.value, DotAccessAST):
             # Handle wrapped DotAccess (legacy compatibility)
             obj = self.visit(node.obj.value)
        else:
            # Visit any other AST node (DotAccessAST, NullUnwrap, Call, Var, etc.)
            obj = self.visit(node.obj)

        if obj is None:
            error(f"Unknown identifier: {base_name}")

        # Handle dict markers (shouldn't reach here normally)
        if isinstance(obj, dict):
            error(f"Cannot access field '{node.field}' on module namespace")

        # Get the actual struct type (may need to dereference pointer)
        if not hasattr(obj, 'type'):
            error(f"Cannot access field on non-object: {base_name}")

        return self._access_field(obj, node.obj, node.field)

    def _access_field(self, obj, obj_node, field_name):
        """Helper to access a field on an object."""
        # Get the actual struct type (may need to dereference pointer)
        if not hasattr(obj.type, 'pointee'):
            error(f"Cannot access field on non-pointer type: {obj.type}")

        pointee = obj.type.pointee
        # If pointee is also a pointer, get its pointee
        if hasattr(pointee, 'pointee'):
            actual_type = pointee.pointee
        else:
            actual_type = pointee

        # Get type from scope
        obj_type = self._get_obj_type(actual_type)
        if obj_type is None:
            error(f"Cannot find type for field access")

        # Load the object - may need double load for pointer-to-pointer
        if isinstance(obj_node, str):
            loaded = self.load(obj_node)
        else:
            loaded = obj
        if hasattr(loaded.type, 'pointee'):
            loaded = self.builder.load(loaded)

        if not hasattr(obj_type, 'fields') or field_name not in obj_type.fields:
            error(f"Field '{field_name}' not found on type")

        field_idx = obj_type.fields.index(field_name)
        result = self.builder.extract_value(loaded, field_idx)

        # Check if accessing a weak field - need to upgrade
        is_weak = hasattr(obj_type, 'weak_fields') and field_name in obj_type.weak_fields
        if is_weak and hasattr(result.type, 'pointee'):
            result = self.rc_weak_upgrade(result)

        return result

    def _get_obj_type(self, actual_type):
        """Get the type object from scope for a given LLVM type."""
        if hasattr(actual_type, 'name') and actual_type.name:
            type_name = actual_type.name
            return self.search_scopes(type_name)
        elif hasattr(actual_type, 'fields'):
            return actual_type
        else:
            type_str = str(actual_type)
            if type_str.startswith('%"') and type_str.endswith('"'):
                type_name = type_str[2:-1]
            elif type_str.startswith('%"'):
                type_name = type_str.split('"')[1]
            elif type_str.startswith('%'):
                type_name = type_str[1:]
            else:
                type_name = type_str
            return self.search_scopes(type_name)

    def visit_opassign(self, node):
        right = self.visit(node.right)
        collection_access = None
        key = None
        if isinstance(node.left, CollectionAccess):
            collection_access = True
            var_name = self.search_scopes(node.left.collection.value)
            pointee = var_name.type.pointee
            # Data pointer is at index 3: { header, size, capacity, data* }
            data_ptr_elem = pointee.elements[3]
            if hasattr(data_ptr_elem, 'pointee'):
                array_type = str(data_ptr_elem.pointee)
            else:
                struct_name = getattr(pointee, 'name', str(pointee))
                if '.array' in struct_name:
                    array_type = struct_name.replace('.array', '')
                else:
                    array_type = str(data_ptr_elem)
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
        elif node.value == NULL:
            # Return a null pointer (i8*)
            return ir.Constant(type_map[INT8].as_pointer(), None)
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

    def _normalize_type_name(self, array_type):
        """Normalize type name for class types (e.g., '%"Header"' -> 'Header')"""
        type_str = str(array_type)
        # Strip pointer symbols to get the underlying type name
        while type_str.endswith('*'):
            type_str = type_str[:-1].strip()
        if type_str.startswith('%"') and type_str.endswith('"'):
            return type_str[2:-1]
        elif type_str.startswith('%'):
            return type_str[1:]
        return type_str

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
        type_name = self._normalize_type_name(array_type)
        for element in elements:
            self.call('{}.array.append'.format(type_name), [array_ptr, element])
        return array_ptr

    def create_array(self, array_type):
        from meteor.compiler.base import OBJECT_HEADER
        # Normalize type name for class types
        type_str = self._normalize_type_name(array_type)
        element_type = array_type
        # Store heap-allocated class instances by pointer inside dynamic arrays
        if hasattr(array_type, 'type') and array_type.type == CLASS:
            element_type = array_type.as_pointer()
        array_type_name = '{}.array'.format(type_str)
        existing_type = self.search_scopes(array_type_name)
        if existing_type is not None:
            dyn_array_type = existing_type
        else:
            dyn_array_type = self.module.context.get_identified_type(array_type_name)
            dyn_array_type.name = array_type_name
            dyn_array_type.type = CLASS
            # 0: header, 1: size, 2: capacity, 3: data pointer
            header_struct = self.search_scopes(OBJECT_HEADER)
            dyn_array_type.set_body(header_struct, type_map[INT], type_map[INT], element_type.as_pointer())
            self.define(array_type_name, dyn_array_type)

        # Use malloc instead of alloca for proper memory management
        # header(16) + size(8) + capacity(8) + data*(8) = 40 bytes
        malloc_func = self.module.get_global('malloc')
        array_mem = self.builder.call(malloc_func, [self.const(40)])
        array = self.builder.bitcast(array_mem, dyn_array_type.as_pointer())

        create_dynamic_array_methods(self, element_type)
        self.call('{}.init'.format(array_type_name), [array])
        return array

    def define_tuple(self, node, elements):
        if hasattr(node.items[0], 'val_type'):
            array_type = type_map[node.items[0].val_type]
        else:
            array_type = self.visit(node.items[0]).type
        array_ptr = self.create_array(array_type)
        type_name = self._normalize_type_name(array_type)
        for element in elements:
            self.call('{}.array.append'.format(type_name), [array_ptr, element])
        return array_ptr

    def visit_hashmap(self, node):
        raise NotImplementedError

    def visit_collectionaccess(self, node):
        key = self.visit(node.key)

        # Handle DotAccess (e.g., self.headers[i])
        if isinstance(node.collection, DotAccess):
            collection = self.visit(node.collection)
        else:
            collection = self.search_scopes(node.collection.value)

        # Check if this is a dynamic array
        # collection.type is %"X.array"** (AllocaInstr stores pointer to array struct)
        # collection.type.pointee is %"X.array"* (pointer to array struct)
        # collection.type.pointee.pointee is %"X.array" (the struct itself)
        for typ in array_types:
            type_name = self._normalize_type_name(typ)
            array_struct = self.search_scopes('{}.array'.format(type_name))
            if array_struct is None:
                continue
            # Check if pointee.pointee matches (for alloca storing pointer)
            if (hasattr(collection.type, 'pointee') and 
                hasattr(collection.type.pointee, 'pointee') and
                collection.type.pointee.pointee == array_struct):
                # Load the pointer and call get
                arr_ptr = self.load(collection)
                result = self.call('{}.array.get'.format(type_name), [arr_ptr, key])
                # IMPORTANT: Retain the object when extracting from array
                # This prevents use-after-free when the variable is later reassigned
                if self.is_managed_type(result.type):
                    self.rc_retain(result)
                return result
            # Also check direct pointee match (for when collection is already a pointer)
            elif (hasattr(collection.type, 'pointee') and
                  collection.type.pointee == array_struct):
                result = self.call('{}.array.get'.format(type_name), [collection, key])
                # IMPORTANT: Retain the object when extracting from array
                if self.is_managed_type(result.type):
                    self.rc_retain(result)
                return result

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

    def get_args(self, parameters, param_modes=None):
        from meteor.ast import DotAccess as DotAccessAST
        args = []
        if parameters is None:
            return args
        if param_modes is None:
            param_modes = {}
        param_names = list(parameters.keys())
        for idx, param in enumerate(parameters.values()):
            param_name = param_names[idx] if idx < len(param_names) else None
            is_ref = param_modes.get(param_name) == 'ref'

            # Handle NullableType which wraps another type
            if isinstance(param, NullableType):
                inner_type = self.get_type(param.inner_type)
                nullable_struct = ir.LiteralStructType([ir.IntType(1), inner_type])
                args.append(nullable_struct)
                continue

            # Handle untyped parameters (param.value is None or empty)
            if not hasattr(param, 'value') or param.value is None or param.value == '':
                args.append(type_map[INT8].as_pointer())
                continue


            # Handle DotAccess type (e.g., http.server.Request)
            if isinstance(param.value, DotAccessAST):
                def build_path(n):
                    if isinstance(n, DotAccessAST):
                        return f"{build_path(n.obj)}.{n.field}"
                    return n
                full_path = build_path(param.value)
                typ = self.search_scopes(full_path)
                if typ is None:
                    # Try simple name
                    simple_name = param.value.field
                    typ = self.search_scopes(simple_name)
                if typ is not None:
                    if hasattr(typ, 'type') and typ.type in (CLASS, ENUM):
                        args.append(typ.as_pointer())
                    else:
                        args.append(typ)
                else:
                    from meteor.utils import warning
                    warning(f"Type not recognized: '{full_path}', using generic pointer")
                    args.append(type_map[INT8].as_pointer())
                continue

            if param.value == FUNC:
                if param.func_ret_type is None:
                    func_ret_type = type_map[VOID]
                elif param.func_ret_type.value in type_map:
                    func_ret_type = type_map[param.func_ret_type.value]
                elif self.search_scopes(param.func_ret_type.value) is not None:
                    func_ret_type = self.search_scopes(param.func_ret_type.value).as_pointer()
                else:
                    func_ret_type = type_map[VOID]
                func_parameters = self.get_args(param.func_params)
                func_ty = ir.FunctionType(func_ret_type, func_parameters, None).as_pointer()
                args.append(func_ty)
            elif param.value == LIST:
                array_type = self.get_type(param.func_params['0'])
                self.create_array(array_type)
                typ = self.search_scopes('{}.array'.format(array_type))
                # List types are always passed as pointers
                args.append(typ.as_pointer())
            elif param.value == STR:
                # Strings are represented as i64.array pointers
                self.create_array(type_map[INT])
                typ = self.search_scopes('i64.array')
                args.append(typ.as_pointer())
            else:
                if param.value in type_map:
                    typ = type_map[param.value]
                    # For ref mode, wrap in pointer
                    if is_ref:
                        args.append(typ.as_pointer())
                    else:
                        args.append(typ)
                elif list(parameters.keys())[list(parameters.values()).index(param)] == SELF:
                    args.append(self.search_scopes(param.value).as_pointer())
                elif self.search_scopes(param.value) is not None:
                    # Check if it's a class or enum type - these are passed by pointer
                    typ = self.search_scopes(param.value)
                    if hasattr(typ, 'type') and typ.type in (CLASS, ENUM):
                        args.append(typ.as_pointer())
                    elif is_ref:
                        # For ref mode, wrap in pointer
                        args.append(typ.as_pointer())
                    else:
                        args.append(typ)
                else:
                    # Unknown type - default to i8* (generic pointer)
                    from meteor.utils import warning
                    warning("Parameter type not recognized: '{}', using generic pointer".format(param.value))
                    args.append(type_map[INT8].as_pointer())

        return args

    def _resolve_dotaccess_type(self, dot_access):
        """Resolve a DotAccess node to a type."""
        from meteor.ast import DotAccess as DotAccessAST

        def build_path(n):
            if isinstance(n, DotAccessAST):
                return f"{build_path(n.obj)}.{n.field}"
            return n

        full_path = build_path(dot_access)

        # Try full path first
        typ = self.search_scopes(full_path)
        if typ is not None:
            return self._ensure_class_pointer(typ)

        # Try simple name as fallback
        simple_name = dot_access.field if hasattr(dot_access, 'field') else full_path.split('.')[-1]
        typ = self.search_scopes(simple_name)
        if typ is not None:
            return self._ensure_class_pointer(typ)

        return None

    def _ensure_class_pointer(self, typ):
        """Ensure class types are returned as pointers."""
        # Check if it's a class definition object
        if hasattr(typ, 'type') and typ.type == CLASS:
            return typ.as_pointer()
        # Check if it's an LLVM IdentifiedStructType (class struct)
        if isinstance(typ, ir.IdentifiedStructType):
            return typ.as_pointer()
        return typ

    def get_type(self, param):
        from meteor.ast import DotAccess as DotAccessAST
        typ = None

        # Handle DotAccess type (e.g., http.server.Request)
        if hasattr(param, 'value') and isinstance(param.value, DotAccessAST):
            typ = self._resolve_dotaccess_type(param.value)
            if typ is not None:
                return typ
            # Build path for error message
            def build_path(n):
                if isinstance(n, DotAccessAST):
                    return f"{build_path(n.obj)}.{n.field}"
                return n
            error(f"Type not recognized: {build_path(param.value)}")

        if isinstance(param, UnionType):
            # Tagged union { i8 tag, T success, E error }
            # tag: 0 = success, 1 = error
            success_type = self.get_type(param.success_type)
            error_type = self.get_type(param.error_type)
            union_struct = ir.LiteralStructType([type_map[INT8], success_type, error_type])
            return union_struct
        
        if isinstance(param, NullableType):
            # Nullable type: { i1 is_null, T value }
            # is_null: 0 = has value, 1 = is null
            inner_type = self.get_type(param.inner_type)
            nullable_struct = ir.LiteralStructType([ir.IntType(1), inner_type])
            return nullable_struct
            
        if param.value == FUNC:
            if param.func_ret_type is None:
                func_ret_type = type_map[VOID]
            elif hasattr(param.func_ret_type, 'value') and isinstance(param.func_ret_type.value, DotAccessAST):
                # Handle DotAccess return type (e.g., http.server.Response)
                func_ret_type = self._resolve_dotaccess_type(param.func_ret_type.value)
                if func_ret_type is None:
                    func_ret_type = type_map[VOID]
            elif param.func_ret_type.value in type_map:
                func_ret_type = type_map[param.func_ret_type.value]
            elif self.search_scopes(param.func_ret_type.value) is not None:
                typ_found = self.search_scopes(param.func_ret_type.value)
                if hasattr(typ_found, 'type') and typ_found.type == CLASS:
                    func_ret_type = typ_found.as_pointer()
                else:
                    func_ret_type = typ_found
            else:
                func_ret_type = type_map[VOID]
            func_parameters = self.get_args(param.func_params)
            func_ty = ir.FunctionType(func_ret_type, func_parameters, None).as_pointer()
            typ = func_ty
        elif param.value == LIST:
            array_type = self.get_type(param.func_params['0'])
            self.create_array(array_type)
            # Return pointer type to match create_array return type
            type_name = self._normalize_type_name(array_type)
            typ = self.search_scopes('{}.array'.format(type_name)).as_pointer()
        elif param.value == STR:
            # Strings are represented as i64.array pointers
            self.create_array(type_map[INT])
            typ = self.search_scopes('i64.array').as_pointer()
        else:
            if param.value in type_map:
                typ = type_map[param.value]
            elif self.search_scopes(param.value) is not None:
                typ = self._ensure_class_pointer(self.search_scopes(param.value))
            elif param.value.startswith('c.'):
                # C imported types (e.g., c.MeteorHttpServer) are opaque pointers
                typ = type_map[INT8].as_pointer()
            elif '.' in param.value:
                # Try to find the type by its simple name (last part after dot)
                # e.g., http.server.Response -> Response
                simple_name = param.value.split('.')[-1]
                if self.search_scopes(simple_name) is not None:
                    typ = self._ensure_class_pointer(self.search_scopes(simple_name))
                else:
                    error("Type not recognized: {}".format(param.value))
            else:
                error("Type not recognized: {}".format(param.value))

        return typ

    def func_decl(self, name, return_type, parameters, parameter_defaults=None, varargs=None, linkage=None, param_modes=None):
        ret_type = self.get_type(return_type)
        args = self.get_args(parameters, param_modes)
        func_type = ir.FunctionType(ret_type, args, varargs)
        func_type.parameters = parameters
        if parameter_defaults:
            func_type.parameter_defaults = parameter_defaults
        if param_modes:
            func_type.param_modes = param_modes
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

    def start_function(self, name, return_type, parameters, parameter_defaults=None, varargs=None, linkage=None, param_modes=None):
        self.function_stack.append(self.current_function)
        self.block_stack.append(self.builder.block)
        self.new_scope()
        self.defer_stack.append([])
        ret_type = self.get_type(return_type)
        args = self.get_args(parameters, param_modes)
        func_type = ir.FunctionType(ret_type, args, varargs)
        func_type.parameters = parameters
        if parameter_defaults:
            func_type.parameter_defaults = parameter_defaults
        if param_modes:
            func_type.param_modes = param_modes

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
        
        # Release managed variables BEFORE returning, while still in current function
        # Only release if we didn't already release in visit_return
        if returned is not True:
            self.release_scope_variables()
        
        if self.current_function.function_type.return_type != type_map[VOID]:
            retvar = self.load(self.search_scopes(RET_VAR))
            self.builder.ret(retvar)
        else:
            self.builder.ret_void()
        back_block = self.block_stack.pop()
        self.position_at_end(back_block)
        last_function = self.function_stack.pop()
        self.current_function = last_function
        # Pop managed vars without releasing (already released above)
        if self.managed_vars_stack:
            self.managed_vars_stack.pop()
        super(CodeGenerator, self).drop_top_scope()

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

    # ========================================================================
    # Memory Management Helpers (RFC-001)
    # ========================================================================

    def get_type_size(self, llvm_type):
        """Get the size of an LLVM type in bytes."""
        # Estimate size based on type
        if isinstance(llvm_type, ir.IntType):
            return llvm_type.width // 8
        elif isinstance(llvm_type, ir.FloatType):
            return 4
        elif isinstance(llvm_type, ir.DoubleType):
            return 8
        elif isinstance(llvm_type, ir.PointerType):
            return 8  # 64-bit pointers
        elif isinstance(llvm_type, ir.ArrayType):
            return llvm_type.count * self.get_type_size(llvm_type.element)
        elif isinstance(llvm_type, (ir.LiteralStructType, ir.IdentifiedStructType)):
            total = 0
            if hasattr(llvm_type, 'elements'):
                for elem in llvm_type.elements:
                    total += self.get_type_size(elem)
            return max(total, 8)  # Minimum 8 bytes
        else:
            return 8  # Default to 8 bytes

    def _generate_class_destructor(self, class_name, class_type):
        """Generate a destructor function for a class that releases all managed fields.
        
        The destructor is called when the object's RC reaches 0, before freeing memory.
        It iterates through all fields and calls rc_release on managed types.
        """
        from meteor.compiler.base import OBJECT_HEADER
        
        # Save current builder state
        saved_function = self.current_function
        saved_block = self.builder.block if hasattr(self.builder, 'block') and self.builder.block else None
        
        # Create destructor function: void __destroy_ClassName__(ClassName* obj)
        destructor_name = f'__destroy_{class_name}__'
        class_ptr_type = class_type.as_pointer()
        func_type = ir.FunctionType(type_map[VOID], [class_ptr_type])
        destructor = ir.Function(self.module, func_type, destructor_name)
        destructor.linkage = 'internal'
        
        entry_block = destructor.append_basic_block('entry')
        exit_block = destructor.append_basic_block('exit')
        
        builder = ir.IRBuilder(entry_block)
        obj_ptr = destructor.args[0]
        
        # Null check
        null_ptr = ir.Constant(class_ptr_type, None)
        is_null = builder.icmp_unsigned('==', obj_ptr, null_ptr)
        not_null_block = destructor.append_basic_block('not_null')
        builder.cbranch(is_null, exit_block, not_null_block)
        
        builder.position_at_end(not_null_block)
        
        # Call user-defined destroy() method if it exists
        user_destroy_name = f'{class_name}.destroy'
        try:
            user_destroy = self.module.get_global(user_destroy_name)
            if user_destroy is not None:
                builder.call(user_destroy, [obj_ptr])
        except KeyError:
            # No user-defined destroy method, that's fine - we'll still release managed fields
            pass
        
        # Iterate through all fields and release managed ones
        for i, field_name in enumerate(class_type.fields):
            field_type = class_type.elements[i]
            
            # Check if this is a managed type (pointer to class, array, string, etc.)
            if isinstance(field_type, ir.PointerType):
                pointee = field_type.pointee
                is_managed = False
                
                # Check for arrays
                if hasattr(pointee, 'name') and pointee.name.endswith('.array'):
                    is_managed = True
                # Check for class types
                elif isinstance(pointee, ir.IdentifiedStructType) and hasattr(pointee, 'methods'):
                    is_managed = True
                
                if is_managed:
                    # Get field pointer
                    field_ptr = builder.gep(obj_ptr, [ir.Constant(type_map[INT32], 0), 
                                                       ir.Constant(type_map[INT32], i)], inbounds=True)
                    field_val = builder.load(field_ptr)
                    
                    # Null check for field
                    field_null = ir.Constant(field_type, None)
                    field_is_null = builder.icmp_unsigned('==', field_val, field_null)
                    
                    release_block = destructor.append_basic_block(f'release_{field_name}')
                    continue_block = destructor.append_basic_block(f'continue_{field_name}')
                    
                    builder.cbranch(field_is_null, continue_block, release_block)
                    
                    builder.position_at_end(release_block)
                    
                    # Get header and call meteor_release
                    header_struct = self.search_scopes(OBJECT_HEADER)
                    if header_struct:
                        release_func = self.module.get_global('meteor_release')
                        if release_func:
                            # For class fields, header is 16 bytes before data
                            if isinstance(pointee, ir.IdentifiedStructType) and hasattr(pointee, 'methods'):
                                i8_ptr = builder.bitcast(field_val, ir.IntType(8).as_pointer())
                                header_ptr = builder.gep(i8_ptr, [ir.Constant(type_map[INT], -16)])
                                header_ptr = builder.bitcast(header_ptr, header_struct.as_pointer())
                            else:
                                # For arrays, header is at offset 0
                                header_ptr = builder.bitcast(field_val, header_struct.as_pointer())
                            builder.call(release_func, [header_ptr])
                    
                    builder.branch(continue_block)
                    builder.position_at_end(continue_block)
        
        builder.branch(exit_block)
        
        builder.position_at_end(exit_block)
        builder.ret_void()
        
        # Store destructor reference in class type
        class_type.destructor = destructor
        self.define(destructor_name, destructor)
        
        # Restore builder state
        self.current_function = saved_function
        if saved_block:
            self.builder.position_at_end(saved_block)

    def is_managed_type(self, llvm_type):
        """Check if a type requires reference counting.
        Types with object headers are managed: arrays and classes.
        Note: bigint and decimal have their own special handling in visit_assign.
        """
        if not isinstance(llvm_type, ir.PointerType):
            return False
        pointee = llvm_type.pointee
        if hasattr(pointee, 'name'):
            # Arrays have object headers
            if pointee.name.endswith('.array'):
                return True
            # Check if we can find the class by name
            class_def = self.search_scopes(pointee.name)
            if class_def is not None and hasattr(class_def, 'methods'):
                return True
        # Check if it's a class type (IdentifiedStructType with methods)
        if isinstance(pointee, ir.IdentifiedStructType):
            if hasattr(pointee, 'methods'):
                return True
        return False

    def is_class_type(self, llvm_type):
        """Check if a type is a class type (has object header at -16 bytes offset).
        This is distinct from is_managed_type because class headers are at negative offset.
        """
        if not isinstance(llvm_type, ir.PointerType):
            return False
        pointee = llvm_type.pointee
        if isinstance(pointee, ir.IdentifiedStructType):
            if hasattr(pointee, 'methods'):
                return True
        return False

    def get_object_header(self, obj_ptr):
        """Get the object header pointer from a managed object.
        For class instances, the header is 16 bytes before the class data.
        For other types (bigint, decimal, arrays), header is at offset 0.
        """
        from meteor.compiler.base import OBJECT_HEADER
        header_struct = self.search_scopes(OBJECT_HEADER)
        if not header_struct:
            return obj_ptr

        # Check if this is a class type (pointer to IdentifiedStructType with methods)
        obj_type = obj_ptr.type
        if hasattr(obj_type, 'pointee'):
            pointee = obj_type.pointee
            if isinstance(pointee, ir.IdentifiedStructType) and hasattr(pointee, 'methods'):
                # Class instance: header is 16 bytes before the class data
                # Cast to i8*, subtract 16, then cast to header*
                i8_ptr = self.builder.bitcast(obj_ptr, ir.IntType(8).as_pointer())
                header_ptr = self.builder.gep(i8_ptr, [self.const(-16)])
                return self.builder.bitcast(header_ptr, header_struct.as_pointer())

        # For other managed types (bigint, decimal, arrays), header is at offset 0
        return self.builder.bitcast(obj_ptr, header_struct.as_pointer())

    def rc_retain(self, obj_ptr):
        """Call meteor_retain on an object."""
        retain_func = self.module.get_global('meteor_retain')
        if retain_func and obj_ptr:
            header = self.get_object_header(obj_ptr)
            self.builder.call(retain_func, [header])

    def rc_release(self, obj_ptr):
        """Call meteor_release on an object with null check.
        For class types, calls destructor before release if RC will become 0.
        
        Memory management flow:
        1. Null check - skip if pointer is NULL
        2. For class types with destructors:
           a. Check if RC == 1 (will become 0)
           b. If so, call destructor first to release managed fields
           c. Then call meteor_release (which frees header+data)
        3. For other managed types: just call meteor_release
        """
        from meteor.compiler.base import HEADER_STRONG_RC
        
        release_func = self.module.get_global('meteor_release')
        if release_func and obj_ptr:
            # Add null check before getting header
            null_ptr = ir.Constant(obj_ptr.type, None)
            is_null = self.builder.icmp_unsigned('==', obj_ptr, null_ptr)

            release_block = self.add_block('rc_release')
            continue_block = self.add_block('rc_release_continue')

            self.builder.cbranch(is_null, continue_block, release_block)

            self.builder.position_at_end(release_block)
            
            # Check if this is a class type with a destructor
            obj_type = obj_ptr.type
            if hasattr(obj_type, 'pointee'):
                pointee = obj_type.pointee
                
                # Try to find the class definition by name if pointee doesn't have methods
                class_def = None
                if hasattr(pointee, 'name'):
                    class_def = self.search_scopes(pointee.name)
                
                has_methods = hasattr(pointee, 'methods') or (class_def is not None and hasattr(class_def, 'methods'))
                
                if isinstance(pointee, ir.IdentifiedStructType) and has_methods:
                    # Use class_def if available, otherwise pointee
                    actual_class = class_def if class_def is not None and hasattr(class_def, 'destructor') else pointee
                    
                    # Ensure destructor is generated
                    if not hasattr(actual_class, 'destructor'):
                        class_name = pointee.name if hasattr(pointee, 'name') else str(pointee)
                        self._generate_class_destructor(class_name, actual_class)
                    
                    if hasattr(actual_class, 'destructor'):
                        # Get header to check RC
                        header = self.get_object_header(obj_ptr)
                        rc_ptr = self.builder.gep(header, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                        rc = self.builder.load(rc_ptr)
                        
                        # If RC == 1, it will become 0 after release, so call destructor first
                        is_one = self.builder.icmp_unsigned('==', rc, ir.Constant(type_map[UINT32], 1))
                        
                        destroy_block = self.add_block('rc_destroy')
                        release_only_block = self.add_block('rc_release_only')
                        
                        self.builder.cbranch(is_one, destroy_block, release_only_block)
                        
                        # Call destructor before release
                        self.builder.position_at_end(destroy_block)
                        self.builder.call(actual_class.destructor, [obj_ptr])
                        header2 = self.get_object_header(obj_ptr)
                        self.builder.call(release_func, [header2])
                        self.builder.branch(continue_block)
                        
                        # Just release without destructor
                        self.builder.position_at_end(release_only_block)
                        header3 = self.get_object_header(obj_ptr)
                        self.builder.call(release_func, [header3])
                        self.builder.branch(continue_block)
                    else:
                        # No destructor generated (should not happen), just release
                        header = self.get_object_header(obj_ptr)
                        self.builder.call(release_func, [header])
                        self.builder.branch(continue_block)
                else:
                    # Check if this is an array type with elements that need releasing
                    if hasattr(pointee, 'name') and pointee.name.endswith('.array'):
                        # Get the element type name from array type name (e.g., "Header.array" -> "Header")
                        array_type_name = pointee.name
                        elem_type_name = array_type_name.rsplit('.array', 1)[0]

                        # Check if element type is a managed type (class or nested array)
                        # Primitive types like i64, i32, etc. don't need element release
                        elem_is_managed = False
                        if elem_type_name not in ('i64', 'i32', 'i8', 'u64', 'u32', 'u8', 'f64', 'f32', 'bool'):
                            elem_type_def = self.search_scopes(elem_type_name)
                            if elem_type_def is not None and hasattr(elem_type_def, 'methods'):
                                elem_is_managed = True
                            elif elem_type_name.endswith('.array'):
                                elem_is_managed = True

                        if elem_is_managed:
                            # Get the array destroy function
                            destroy_func_name = f'{array_type_name}.destroy'
                            destroy_func = self.module.get_global(destroy_func_name) if destroy_func_name in self.module.globals else None

                            if destroy_func:
                                # Check RC before calling destructor
                                header = self.get_object_header(obj_ptr)
                                rc_ptr = self.builder.gep(header, [self.const(0), self.const(HEADER_STRONG_RC, width=INT32)])
                                rc = self.builder.load(rc_ptr)

                                is_one = self.builder.icmp_unsigned('==', rc, ir.Constant(type_map[UINT32], 1))

                                destroy_block = self.add_block('rc_array_destroy')
                                release_only_block = self.add_block('rc_array_release_only')

                                self.builder.cbranch(is_one, destroy_block, release_only_block)

                                # Call array destructor before release
                                self.builder.position_at_end(destroy_block)
                                self.builder.call(destroy_func, [obj_ptr])
                                header2 = self.get_object_header(obj_ptr)
                                self.builder.call(release_func, [header2])
                                self.builder.branch(continue_block)

                                # Just release without destructor
                                self.builder.position_at_end(release_only_block)
                                header3 = self.get_object_header(obj_ptr)
                                self.builder.call(release_func, [header3])
                                self.builder.branch(continue_block)
                            else:
                                # No destroy function, just release
                                header = self.get_object_header(obj_ptr)
                                self.builder.call(release_func, [header])
                                self.builder.branch(continue_block)
                        else:
                            # Primitive element type (like i64 for strings), just release
                            header = self.get_object_header(obj_ptr)
                            self.builder.call(release_func, [header])
                            self.builder.branch(continue_block)
                    else:
                        # Not a class or array, just release
                        header = self.get_object_header(obj_ptr)
                        self.builder.call(release_func, [header])
                        self.builder.branch(continue_block)
            else:
                header = self.get_object_header(obj_ptr)
                self.builder.call(release_func, [header])
                self.builder.branch(continue_block)

            self.builder.position_at_end(continue_block)

    def rc_weak_retain(self, obj_ptr):
        """Call meteor_weak_retain on an object."""
        func = self.module.get_global('meteor_weak_retain')
        if func and obj_ptr:
            header = self.get_object_header(obj_ptr)
            self.builder.call(func, [header])

    def rc_weak_release(self, obj_ptr):
        """Call meteor_weak_release on an object."""
        func = self.module.get_global('meteor_weak_release')
        if func and obj_ptr:
            header = self.get_object_header(obj_ptr)
            self.builder.call(func, [header])

    def rc_weak_upgrade(self, obj_ptr):
        """Call meteor_weak_upgrade to safely access a weak reference.
        Returns the upgraded pointer (or NULL if zombie).
        """
        func = self.module.get_global('meteor_weak_upgrade')
        if func and obj_ptr:
            header = self.get_object_header(obj_ptr)
            return self.builder.call(func, [header])
        return obj_ptr

    def check_frozen_write(self, obj_ptr):
        """Check if object is frozen and abort if trying to write.
        Generates runtime check for IS_FROZEN flag.
        """
        from meteor.compiler.base import OBJECT_HEADER, HEADER_FLAGS, FLAG_IS_FROZEN

        if not self.is_managed_type(obj_ptr.type):
            return

        header = self.get_object_header(obj_ptr)
        header_struct = self.search_scopes(OBJECT_HEADER)
        if not header_struct:
            return

        # Load flags
        flags_ptr = self.builder.gep(header, [self.const(0), self.const(HEADER_FLAGS, width=INT32)])
        flags = self.builder.load(flags_ptr)

        # Check IS_FROZEN
        frozen_mask = ir.Constant(type_map[UINT8], FLAG_IS_FROZEN)
        is_frozen = self.builder.and_(flags, frozen_mask)
        is_frozen_bool = self.builder.icmp_unsigned('!=', is_frozen, ir.Constant(type_map[UINT8], 0))

        # If frozen, call abort (simplified - real impl should raise error)
        frozen_block = self.add_block('frozen.abort')
        continue_block = self.add_block('frozen.continue')
        self.builder.cbranch(is_frozen_bool, frozen_block, continue_block)

        self.builder.position_at_end(frozen_block)
        try:
            abort_func = self.module.get_global('abort')
        except KeyError:
            abort_type = ir.FunctionType(type_map[VOID], [])
            abort_func = ir.Function(self.module, abort_type, 'abort')
        self.builder.call(abort_func, [])
        self.builder.unreachable()

        self.builder.position_at_end(continue_block)

    def rc_assign(self, target_ptr, new_value):
        """RC-safe assignment: release old, store new (no retain for new allocations).
        
        This is used for reassigning managed type variables.
        The new value is assumed to already have RC=1 from allocation.
        We only release the old value before storing the new one.
        
        For copying from another variable (where we want to share ownership),
        the caller should call rc_retain on new_value first.
        """
        if not self.is_managed_type(target_ptr.type.pointee):
            self.builder.store(new_value, target_ptr)
            return

        release_func = self.module.get_global('meteor_release')

        if not release_func:
            # Fallback to simple store if RC functions not available
            self.builder.store(new_value, target_ptr)
            return

        # Load old value and release it (with null check)
        old_value = self.builder.load(target_ptr)
        
        # Null check for old value before release
        null_ptr = ir.Constant(old_value.type, None)
        is_not_null = self.builder.icmp_unsigned('!=', old_value, null_ptr)
        
        with self.builder.if_then(is_not_null):
            self.rc_release(old_value)

        # Store new value (new allocations already have RC=1)
        self.builder.store(new_value, target_ptr)

    def register_managed_var(self, name, var_ptr):
        """Register a managed variable for scope cleanup."""
        if var_ptr and hasattr(var_ptr, 'type'):
            if hasattr(var_ptr.type, 'pointee'):
                if self.is_managed_type(var_ptr.type.pointee):
                    self.managed_vars_stack[-1].append((name, var_ptr))

    def release_scope_variables(self, exclude=None, set_null=False):
        """Release all managed variables in current scope.
        
        Args:
            exclude: Optional value to skip releasing
            set_null: If True, set the variable pointer to NULL after release.
                     This is needed for continue/break in loops to prevent
                     double-release on next iteration.
        """
        # Skip if no builder or no current block
        if not hasattr(self, 'builder') or self.builder is None:
            return
        if not hasattr(self.builder, 'block') or self.builder.block is None:
            return
        # Skip if block is already terminated
        if self.builder.block.is_terminated:
            return
        release_func = self.module.get_global('meteor_release')
        if not release_func:
            return
        if not self.managed_vars_stack or not self.managed_vars_stack[-1]:
            return
        for name, var_ptr in self.managed_vars_stack[-1]:
            val = self.builder.load(var_ptr)
            if exclude is not None and val == exclude:
                continue
            # Call release directly - the runtime function handles NULL
            self.rc_release(val)
            # Set to NULL after release to prevent double-release in loops
            if set_null:
                null_val = ir.Constant(val.type, None)
                self.builder.store(null_val, var_ptr)

    def new_scope(self):
        """Override to also push managed vars stack."""
        super().new_scope()
        self.managed_vars_stack.append([])

    def drop_top_scope(self):
        """Override to release managed vars before dropping scope."""
        self.release_scope_variables()
        self.managed_vars_stack.pop()
        super().drop_top_scope()

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
        # Initialize pointer types to null to avoid garbage in RC operations
        if isinstance(typ, ir.PointerType):
            null_val = ir.Constant(typ, None)
            self.builder.store(null_val, var_addr)
            # Register managed types for scope cleanup
            # Skip ret_var - return value lifetime is managed by caller, not current scope
            if self.is_managed_type(typ) and name != RET_VAR:
                self.register_managed_var(name, var_addr)
        return var_addr

    def alloc_define_store_simple(self, val, name, typ):
        """Allocate, define and store without RC management.
        Used for function parameters where caller owns the reference.
        """
        var_addr = self.builder.alloca(typ, name=name)
        self.define(name, var_addr)
        self.builder.store(val, var_addr)
        return var_addr

    def alloc_define_store(self, val, name, typ):
        """Allocate, define and store a value with proper RC management.
        
        For managed types (classes, arrays), this method:
        1. Uses entry block alloca to avoid stack overflow in loops
        2. Initializes pointer to NULL on first use
        3. Releases old value before storing new one (for loop iterations)
        4. Registers variable for scope cleanup
        
        This is the primary method for declaring class variables in loops.
        """
        # Check if variable already exists (loop re-iteration case)
        existing_var = self.search_scopes(name)
        
        # Only handle as existing LLVM variable if it's an ir.Value (not a dict from module import)
        # For managed types, always generate code to release old value before storing new
        # This handles both first declaration and loop re-iteration cases correctly
        if existing_var is not None and self.is_managed_type(typ) and isinstance(existing_var, ir.Value):
            # Variable already declared - this is a loop re-iteration
            # Release old value and store new one
            old_val = self.builder.load(existing_var)
            
            # Null check before release
            null_ptr = ir.Constant(old_val.type, None)
            is_not_null = self.builder.icmp_unsigned('!=', old_val, null_ptr)
            
            with self.builder.if_then(is_not_null):
                self.rc_release(old_val)
            
            self.builder.store(val, existing_var)
            return existing_var
        
        # For managed types, use entry block alloca to handle loops properly
        if self.is_managed_type(typ):
            # Create alloca in entry block
            entry_block = self.current_function.entry_basic_block
            saved_block = self.builder.block
            
            if entry_block.instructions:
                self.builder.position_before(entry_block.instructions[0])
            else:
                self.builder.position_at_end(entry_block)
            
            var_addr = self.builder.alloca(typ, name=name)
            # Initialize to NULL for safe first-time check
            null_val = ir.Constant(typ, None)
            self.builder.store(null_val, var_addr)
            
            self.builder.position_at_end(saved_block)
            self.define(name, var_addr)
            
            # Register for scope cleanup
            self.register_managed_var(name, var_addr)
            
            # Generate code to release old value before storing new (handles loop re-iteration)
            # On first iteration, var_addr contains NULL so release will be skipped
            old_val = self.builder.load(var_addr)
            null_ptr = ir.Constant(typ, None)
            is_not_null = self.builder.icmp_unsigned('!=', old_val, null_ptr)
            
            with self.builder.if_then(is_not_null):
                self.rc_release(old_val)
            
            # Store the value (new objects from class_assign already have RC=1)
            self.builder.store(val, var_addr)
            return var_addr
        
        # Non-managed types: simple alloca in entry block
        entry_block = self.current_function.entry_basic_block
        saved_block = self.builder.block

        if entry_block.instructions:
            self.builder.position_before(entry_block.instructions[0])
        else:
            self.builder.position_at_end(entry_block)

        var_addr = self.builder.alloca(typ, name=name)
        self.define(name, var_addr)

        self.builder.position_at_end(saved_block)

        self.builder.store(val, var_addr)
        return var_addr

    def store(self, value, name):
        if isinstance(name, str):
            target_ptr = self.search_scopes(name)
        else:
            target_ptr = name

        # Check if this is a managed type that needs RC
        if hasattr(target_ptr, 'type') and hasattr(target_ptr.type, 'pointee'):
            if self.is_managed_type(target_ptr.type.pointee):
                self.rc_assign(target_ptr, value)
                return

        self.builder.store(value, target_ptr)

    def load(self, name):
        if isinstance(name, str):
            ptr = self.search_scopes(name)
        else:
            ptr = name

        val = self.builder.load(ptr)

        # RFC-001: Runtime NULL Check for Use-After-Move detection
        # Only check Meteor managed types (classes with object headers), not raw C pointers
        # C functions can legitimately return NULL which should be checked with == null
        if isinstance(val.type, ir.PointerType):
            # Check if this is a managed Meteor type (has object header)
            if self.is_managed_type(val.type.pointee):
                null_ptr = ir.Constant(val.type, None)
                is_null = self.builder.icmp_unsigned('==', val, null_ptr)

                with self.builder.if_then(is_null):
                    # Print error message before abort
                    self.print_string("Error: Use-After-Move detected!", newline=True)
                    # Call abort
                    abort_func = self.module.get_global('abort')
                    if abort_func:
                        self.builder.call(abort_func, [])
                    self.builder.unreachable()

        return val

    def call(self, name, args):
        if isinstance(name, str):
            func = self.module.get_global(name)
        else:
            func = self.module.get_global(name.name)
        if func is None:
            raise TypeError('Calling non existant function')

        # Convert argument types to match function signature
        converted_args = []
        func_arg_types = func.function_type.args
        for i, arg in enumerate(args):
            if i < len(func_arg_types):
                expected_type = func_arg_types[i]
                if arg.type != expected_type:
                    # Meteor string (i64.array*) to C char* conversion
                    if (isinstance(arg.type, ir.PointerType) and
                        isinstance(expected_type, ir.PointerType) and
                        isinstance(expected_type.pointee, ir.IntType) and
                        expected_type.pointee.width == 8 and
                        hasattr(arg.type.pointee, 'name') and
                        'array' in str(arg.type.pointee)):
                        arg = self._convert_meteor_string_to_cstr(arg)
                    # Integer type conversion
                    elif isinstance(arg.type, ir.IntType) and isinstance(expected_type, ir.IntType):
                        if arg.type.width > expected_type.width:
                            arg = self.builder.trunc(arg, expected_type)
                        else:
                            arg = self.builder.sext(arg, expected_type)
                    # Float/Double conversion
                    elif isinstance(arg.type, (ir.FloatType, ir.DoubleType)) and isinstance(expected_type, (ir.FloatType, ir.DoubleType)):
                        if isinstance(arg.type, ir.FloatType) and isinstance(expected_type, ir.DoubleType):
                            arg = self.builder.fpext(arg, expected_type)
                        elif isinstance(arg.type, ir.DoubleType) and isinstance(expected_type, ir.FloatType):
                            arg = self.builder.fptrunc(arg, expected_type)
            converted_args.append(arg)

        return self.builder.call(func, converted_args)

    def _convert_meteor_string_to_cstr(self, meteor_str):
        """Convert Meteor string (i64.array*) to C string (i8*)."""
        i32 = ir.IntType(32)
        # i64.array structure: {header, size, capacity, data*}
        # Get size (index 1)
        size_ptr = self.builder.gep(meteor_str, [ir.Constant(i32, 0), ir.Constant(i32, 1)])
        size = self.builder.load(size_ptr)

        # Get data pointer (index 3)
        data_ptr_ptr = self.builder.gep(meteor_str, [ir.Constant(i32, 0), ir.Constant(i32, 3)])
        data_ptr = self.builder.load(data_ptr_ptr)

        # Allocate C string buffer (size + 1 for null terminator)
        size_plus_one = self.builder.add(size, self.const(1))
        cstr = self.builder.call(self.module.get_global('malloc'), [size_plus_one])

        # Copy characters (truncate i64 to i8)
        i_ptr = self.builder.alloca(type_map[INT])
        self.builder.store(self.const(0), i_ptr)

        loop_cond_block = self.current_function.append_basic_block('str_conv_cond')
        loop_body_block = self.current_function.append_basic_block('str_conv_body')
        end_block = self.current_function.append_basic_block('str_conv_end')

        self.builder.branch(loop_cond_block)
        self.builder.position_at_end(loop_cond_block)

        i = self.builder.load(i_ptr)
        cond = self.builder.icmp_signed('<', i, size)
        self.builder.cbranch(cond, loop_body_block, end_block)

        self.builder.position_at_end(loop_body_block)
        i = self.builder.load(i_ptr)
        char_ptr = self.builder.gep(data_ptr, [i])
        char_i64 = self.builder.load(char_ptr)
        char_i8 = self.builder.trunc(char_i64, ir.IntType(8))
        dst_ptr = self.builder.gep(cstr, [i])
        self.builder.store(char_i8, dst_ptr)
        next_i = self.builder.add(i, self.const(1))
        self.builder.store(next_i, i_ptr)
        self.builder.branch(loop_cond_block)

        self.builder.position_at_end(end_block)

        # Add null terminator
        null_ptr = self.builder.gep(cstr, [size])
        self.builder.store(ir.Constant(ir.IntType(8), 0), null_ptr)

        return cstr

    def _convert_cstr_to_meteor_string(self, cstr):
        """Convert C string (i8*) to Meteor string (i64.array*)."""
        i32 = ir.IntType(32)

        # Ensure strlen is declared
        if 'strlen' not in self.module.globals:
            strlen_ty = ir.FunctionType(type_map[INT], [type_map[INT8].as_pointer()])
            ir.Function(self.module, strlen_ty, 'strlen')

        # Get string length using strlen
        strlen_func = self.module.get_global('strlen')
        length = self.builder.call(strlen_func, [cstr])

        # Create new Meteor string array
        str_array = self.create_array(type_map[INT])

        # Copy characters from C string to Meteor string
        i_ptr = self.builder.alloca(type_map[INT])
        self.builder.store(self.const(0), i_ptr)

        loop_cond_block = self.current_function.append_basic_block('cstr_conv_cond')
        loop_body_block = self.current_function.append_basic_block('cstr_conv_body')
        end_block = self.current_function.append_basic_block('cstr_conv_end')

        self.builder.branch(loop_cond_block)
        self.builder.position_at_end(loop_cond_block)

        i = self.builder.load(i_ptr)
        cond = self.builder.icmp_signed('<', i, length)
        self.builder.cbranch(cond, loop_body_block, end_block)

        self.builder.position_at_end(loop_body_block)
        i = self.builder.load(i_ptr)
        # Get char from C string (i8)
        char_ptr = self.builder.gep(cstr, [i])
        char_i8 = self.builder.load(char_ptr)
        # Extend to i64 for Meteor string
        char_i64 = self.builder.zext(char_i8, type_map[INT])
        # Append to Meteor string
        append_func = self.module.get_global('i64.array.append')
        self.builder.call(append_func, [str_array, char_i64])
        # Increment counter
        next_i = self.builder.add(i, self.const(1))
        self.builder.store(next_i, i_ptr)
        self.builder.branch(loop_cond_block)

        self.builder.position_at_end(end_block)

        return str_array

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

        abort_ty = ir.FunctionType(type_map[VOID], [])
        ir.Function(self.module, abort_ty, 'abort')

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

    def parse_c_header(self, header_file, link_libs=None, include_paths=None, namespace=None):
        """Parse C header file and register functions.

        Uses libclang if available, otherwise falls back to predefined mappings.
        """
        if link_libs is None:
            link_libs = []
        if include_paths is None:
            include_paths = []

        # Store namespace for later use
        self._c_namespace = namespace

        # Try to use libclang for parsing
        try:
            self._parse_c_header_clang(header_file, include_paths, namespace)
        except (ImportError, Exception) as e:
            # Fallback to predefined header mappings if libclang unavailable
            self._parse_c_header_fallback(header_file)

    def _parse_c_header_clang(self, header_file, include_paths=None, namespace=None):
        """Parse C header using libclang."""
        import clang.cindex
        # Try common libclang paths on Windows
        import os
        if os.name == 'nt':
            libclang_paths = [
                r"D:\Program Files\LLVM\bin\libclang.dll",
                r"C:\Program Files\LLVM\bin\libclang.dll",
                r"C:\Program Files (x86)\LLVM\bin\libclang.dll",
            ]
            for path in libclang_paths:
                if os.path.exists(path):
                    clang.cindex.Config.set_library_file(path)
                    break
        from clang.cindex import Index, CursorKind

        if include_paths is None:
            include_paths = []

        # Build clang args
        args = ['-x', 'c']
        for path in include_paths:
            args.append('-I' + path)

        index = Index.create()
        # Create virtual source file with #include
        code = '#include <{}>'.format(header_file)
        tu = index.parse('temp.c', args=args, unsaved_files=[('temp.c', code)])

        for cursor in tu.cursor.get_children():
            if cursor.kind == CursorKind.FUNCTION_DECL:
                self._register_c_function(cursor, namespace)

    def _register_c_function(self, cursor, namespace=None):
        """Register a C function from clang cursor."""
        from clang.cindex import TypeKind

        name = cursor.spelling
        ret_type = self._clang_type_to_llvm(cursor.result_type)
        arg_types = [self._clang_type_to_llvm(arg.type) for arg in cursor.get_arguments()]

        func_type = ir.FunctionType(ret_type, arg_types)
        if name not in self.module.globals:
            ir.Function(self.module, func_type, name)

    def _clang_type_to_llvm(self, clang_type):
        """Convert clang type to LLVM type."""
        from clang.cindex import TypeKind

        kind = clang_type.kind

        # Handle typedef and elaborated types by getting the canonical (underlying) type
        if kind in (TypeKind.TYPEDEF, TypeKind.ELABORATED):
            canonical = clang_type.get_canonical()
            return self._clang_type_to_llvm(canonical)

        if kind == TypeKind.VOID:
            return type_map[VOID]
        elif kind == TypeKind.INT:
            return type_map[INT32]
        elif kind == TypeKind.LONG:
            return type_map[INT]
        elif kind == TypeKind.DOUBLE:
            return type_map[DOUBLE]
        elif kind == TypeKind.FLOAT:
            return type_map[FLOAT]
        elif kind == TypeKind.POINTER:
            return type_map[INT8].as_pointer()
        else:
            return type_map[INT]  # Default fallback

    def _parse_c_header_fallback(self, header_file):
        """Fallback: use predefined C header mappings."""
        # Common C headers and their functions
        c_headers = {
            'math.h': self._define_math_h,
            'stdio.h': self._define_stdio_h,
            'stdlib.h': self._define_stdlib_h,
            'string.h': self._define_string_h,
            'time.h': self._define_time_h,
        }

        # Extract base name from header path
        import os
        base_name = os.path.basename(header_file)

        if base_name in c_headers:
            c_headers[base_name]()

    def _define_math_h(self):
        """Define math.h functions."""
        double_ty = type_map[DOUBLE]

        # Single-argument double functions
        single_arg_funcs = ['cos', 'sin', 'tan', 'acos', 'asin', 'atan',
                           'cosh', 'sinh', 'tanh', 'exp', 'log', 'log10',
                           'log2', 'sqrt', 'cbrt', 'ceil', 'floor', 'round',
                           'trunc', 'fabs']
        for func_name in single_arg_funcs:
            if func_name not in self.module.globals:
                func_ty = ir.FunctionType(double_ty, [double_ty])
                ir.Function(self.module, func_ty, func_name)

        # Two-argument double functions
        if 'pow' not in self.module.globals:
            func_ty = ir.FunctionType(double_ty, [double_ty, double_ty])
            ir.Function(self.module, func_ty, 'pow')

        if 'atan2' not in self.module.globals:
            func_ty = ir.FunctionType(double_ty, [double_ty, double_ty])
            ir.Function(self.module, func_ty, 'atan2')

        # abs for integers
        int_ty = type_map[INT32]
        if 'abs' not in self.module.globals:
            func_ty = ir.FunctionType(int_ty, [int_ty])
            ir.Function(self.module, func_ty, 'abs')

    def _define_stdio_h(self):
        """Define stdio.h functions."""
        int_ty = type_map[INT32]
        char_ptr = type_map[INT8].as_pointer()

        # printf(const char* format, ...) -> int
        if 'printf' not in self.module.globals:
            func_ty = ir.FunctionType(int_ty, [char_ptr], var_arg=True)
            ir.Function(self.module, func_ty, 'printf')

        # puts(const char* s) -> int
        if 'puts' not in self.module.globals:
            func_ty = ir.FunctionType(int_ty, [char_ptr])
            ir.Function(self.module, func_ty, 'puts')

    def _define_stdlib_h(self):
        """Define stdlib.h functions."""
        int_ty = type_map[INT32]
        long_ty = type_map[INT]
        void_ty = type_map[VOID]
        void_ptr = type_map[INT8].as_pointer()

        # malloc(size_t size) -> void*
        if 'malloc' not in self.module.globals:
            func_ty = ir.FunctionType(void_ptr, [long_ty])
            ir.Function(self.module, func_ty, 'malloc')

        # free(void* ptr)
        if 'free' not in self.module.globals:
            func_ty = ir.FunctionType(void_ty, [void_ptr])
            ir.Function(self.module, func_ty, 'free')

        # atoi(const char* str) -> int
        if 'atoi' not in self.module.globals:
            func_ty = ir.FunctionType(int_ty, [type_map[INT8].as_pointer()])
            ir.Function(self.module, func_ty, 'atoi')

    def _define_string_h(self):
        """Define string.h functions."""
        long_ty = type_map[INT]
        int_ty = type_map[INT32]
        char_ptr = type_map[INT8].as_pointer()

        # strlen(const char* s) -> size_t
        if 'strlen' not in self.module.globals:
            func_ty = ir.FunctionType(long_ty, [char_ptr])
            ir.Function(self.module, func_ty, 'strlen')

        # strcmp(const char* s1, const char* s2) -> int
        if 'strcmp' not in self.module.globals:
            func_ty = ir.FunctionType(int_ty, [char_ptr, char_ptr])
            ir.Function(self.module, func_ty, 'strcmp')

        # strcpy(char* dest, const char* src) -> char*
        if 'strcpy' not in self.module.globals:
            func_ty = ir.FunctionType(char_ptr, [char_ptr, char_ptr])
            ir.Function(self.module, func_ty, 'strcpy')

    def _define_time_h(self):
        """Define time.h functions."""
        long_ty = type_map[INT]
        void_ptr = type_map[INT8].as_pointer()

        # time(time_t* t) -> time_t
        if 'time' not in self.module.globals:
            func_ty = ir.FunctionType(long_ty, [void_ptr])
            ir.Function(self.module, func_ty, 'time')

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

        # Load custom C libraries for JIT
        self._loaded_libs = []
        for lib_path in self.link_libs:
            try:
                # Handle both full paths and library names
                if os.path.exists(lib_path + '.dll'):
                    lib = ctypes.CDLL(lib_path + '.dll')
                elif os.path.exists(lib_path):
                    lib = ctypes.CDLL(lib_path)
                else:
                    # Try as system library
                    lib = ctypes.CDLL(lib_path)
                self._loaded_libs.append(lib)
            except OSError as e:
                print(f"Warning: Could not load library {lib_path}: {e}")

        # Provide mi_version symbol for JIT mode (returns dummy value)
        def dummy_mi_version():
            return 0
        MI_VERSION_FUNC = ctypes.CFUNCTYPE(ctypes.c_int)
        mi_version_callback = MI_VERSION_FUNC(dummy_mi_version)
        # Keep reference to prevent garbage collection
        self._mi_version_callback = mi_version_callback
        llvm.add_symbol('mi_version', ctypes.cast(mi_version_callback, ctypes.c_void_p).value)

        module_str = str(self.module)
        llvmmod = llvm.parse_assembly(module_str)
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
            # Link with mimalloc DLL for better memory allocation performance
            mimalloc_dir = 'D:/Project/mimalloc/out/shared/Release'
            mimalloc_lib = f'{mimalloc_dir}/mimalloc.dll.lib'

            # Build command with all libraries
            cmd = ['clang', f'{output}.ll', '-O3', '-o', output]

            # Add mimalloc if available
            if os.path.exists(mimalloc_lib):
                cmd.append(mimalloc_lib)
                # Copy DLLs to output directory
                output_dir = os.path.dirname(os.path.abspath(output)) or '.'
                import shutil
                for dll in ['mimalloc.dll', 'mimalloc-redirect.dll']:
                    src = f'{mimalloc_dir}/{dll}'
                    dst = f'{output_dir}/{dll}'
                    if os.path.exists(src) and not os.path.exists(dst):
                        shutil.copy2(src, dst)

            # Add custom C libraries from @link directives
            output_dir = os.path.dirname(os.path.abspath(output)) or '.'
            import shutil
            for lib_path in self.link_libs:
                # Try to find the library (.lib for linking, .dll for runtime)
                lib_file = lib_path + '.lib'
                dll_file = lib_path + '.dll'
                if os.path.exists(lib_file):
                    cmd.append(lib_file)
                    # Copy DLL to output directory for runtime
                    if os.path.exists(dll_file):
                        dll_name = os.path.basename(dll_file)
                        dst = os.path.join(output_dir, dll_name)
                        if not os.path.exists(dst):
                            shutil.copy2(dll_file, dst)
                elif os.path.exists(lib_path):
                    cmd.append(lib_path)

            result = subprocess.call(cmd, stdout=tmpout, stderr=subprocess.PIPE)
            successful("compilation done in: %.3f seconds" % (time() - compile_time))
            successful("binary file wrote to " + output)

        if emit_llvm:
            successful("llvm assembler wrote to " + output + ".ll")
        else:
            os.remove(output + '.ll')
