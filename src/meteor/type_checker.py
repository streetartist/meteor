from typing import Iterator, Union, List, Tuple, Any

from meteor.ast import Collection, CollectionAccess, DotAccess, Range, Var, VarDecl, AST
from meteor.grammar import *
from meteor.utils import error, warning
from meteor.visitor import (BuiltinTypeSymbol, ClassSymbol, CollectionSymbol,
                           EnumSymbol, FuncSymbol, NodeVisitor,
                           TypeSymbol, VarSymbol)


def flatten(container: Union[List[Any], Tuple[Any, ...]]) -> Iterator[list]:
    for i in container:
        if isinstance(i, (list, tuple)):
            for j in flatten(i):
                if j:
                    yield j
        elif i:
            yield i


# TODO: Please improve me in a less hacky way
def types_compatible(left_type: AST, right_type: AST) -> bool:
    l_type = str(left_type)
    r_type = str(right_type)
    int_type = ('i8', 'i16', 'i32', 'i64', 'int8', 'int16', 'int32', 'int64', 'int')
    float_type = ('float', 'double')
    num_type = int_type + float_type
    # bigint can be mixed with int types
    bigint_compatible = ('bigint', '%"bigint"') + int_type
    if (l_type == r_type) or \
       (l_type in num_type and r_type in num_type) or \
       (l_type in bigint_compatible and r_type in bigint_compatible):
        return True

    return False


class Preprocessor(NodeVisitor):
    def __init__(self, file_name: str):
        super().__init__()
        self.file_name = file_name
        self.return_flag = False

    def check(self, node) -> BuiltinTypeSymbol:
        res = self.visit(node)
        if self.unvisited_symbols:
            sym_list = []
            for sym_name in self.unvisited_symbols:
                if "." in sym_name:
                    continue
                sym_list.append(sym_name)
            if len(sym_list):
                warning('Unused variables ({})'.format(','.join(sym_name for sym_name in sym_list)))
        return res

    def visit_program(self, node):
        return self.visit(node.block)

    def visit_if(self, node):
        blocks = []
        for x, block in enumerate(node.blocks):
            self.visit(node.comps[x])
            blocks.append(self.visit(block))
        return blocks

    def visit_else(self, node):
        pass

    def visit_while(self, node):
        self.visit(node.comp)
        self.visit(node.block)

    def visit_for(self, node):
        for element in node.elements:
            elem_type = self.visit(node.iterator)
            if isinstance(elem_type, CollectionSymbol):
                elem_type = elem_type.item_types
            elif isinstance(elem_type, tuple):
                # Ranges return tuples
                elem_type = elem_type[1]

            var_sym = VarSymbol(element.value, elem_type)
            var_sym.val_assigned = True
            self.define(var_sym.name, var_sym)
        self.visit(node.block)

    def visit_loopblock(self, node):
        results = []
        for child in node.children:
            results.append(self.visit(child))
        return results

    def visit_switch(self, node):
        switch_var = self.visit(node.value)
        for case in node.cases:
            case_type = self.visit(case)
            if case_type != DEFAULT and case_type is not switch_var.type:
                error('file={} line={}: Types in switch do not match case'.format(self.file_name, node.line_num))

    def visit_case(self, node):
        if node.value == DEFAULT:
            case_type = DEFAULT
        else:
            case_type = self.visit(node.value)
        self.visit(node.block)
        return case_type

    def visit_fallthrough(self, node):
        pass

    def visit_break(self, node):
        pass

    def visit_continue(self, node):
        pass

    def visit_constant(self, node):
        if node.value == TRUE or node.value == FALSE:
            return self.search_scopes(BOOL)
        elif node.value == INF:
            return self.search_scopes(DOUBLE)

        return NotImplementedError

    def visit_num(self, node):
        return self.infer_type(node.value)

    def visit_str(self, node):
        return self.infer_type(node.value)

    def visit_type(self, node):
        typ = self.search_scopes(node.value)
        if typ is self.search_scopes(FUNC):
            typ.return_type = self.visit(node.func_ret_type)
        return typ

    def visit_assign(self, node):  # TODO clean up this mess of a function
        collection_type = None
        field_assignment = None
        collection_assignment = None
        if isinstance(node.left, VarDecl):
            var_name = node.left.value.value
            value = self.infer_type(node.left.type)
            value.accessed = True
            if isinstance(node.right, Collection) or isinstance(node.right, Range):
                _, collection_type = self.visit(node.right)

            if value.name in (TUPLE, LIST) and (not isinstance(node.right, Range) and node.right.type != value.name):
                error('file={} line={}: Contradicting {}-{} declaration'.format(self.file_name, node.line_num, value.name, node.right.type))
        elif hasattr(node.right, 'name') and isinstance(self.search_scopes(node.right.name), (EnumSymbol, ClassSymbol)):
            var_name = node.left.value
            value = self.search_scopes(node.right.name)
            value.accessed = True
        elif isinstance(node.right, Collection) or isinstance(node.right, Range):
            var_name = node.left.value
            value, collection_type = self.visit(node.right)
        elif isinstance(node.left, DotAccess):
            field_assignment = True
            var_name = self.visit(node.left)
            value = self.visit(node.right)
        elif isinstance(node.right, DotAccess):
            var_name = node.left.value
            value = self.search_scopes(node.right.obj)
            value.accessed = True
            value = self.infer_type(value)
        elif isinstance(node.left, CollectionAccess):
            collection_assignment = True
            var_name = node.left.collection.value
            value = self.visit(node.right)
        else:
            var_name = node.left.value
            value = self.visit(node.right)
            if isinstance(value, VarSymbol):
                value = value.type
        lookup_var = self.search_scopes(var_name)
        if not lookup_var:
            if collection_type:
                col_sym = CollectionSymbol(var_name, value, collection_type)
                col_sym.val_assigned = True
                self.define(var_name, col_sym)
            elif field_assignment:
                if var_name is value:
                    return
                else:
                    error('file={} line={} Type Error: What are you trying to do?!?! (fix this message)'.format(self.file_name, node.line_num))
            elif isinstance(value, FuncSymbol):
                value.name = var_name
                self.define(var_name, value)
            elif hasattr(value, 'name') and value.name == FUNC:
                var = self.visit(node.right)
                if isinstance(var, FuncSymbol):
                    self.define(var_name, var)
                elif isinstance(var, BuiltinTypeSymbol):
                    self.define(var_name, var.func)
                else:
                    val_info = self.search_scopes(node.right.value)
                    func_sym = FuncSymbol(var_name, val_info.type.return_type, val_info.parameters, val_info.body, val_info.parameter_defaults)
                    self.define(var_name, func_sym)
            else:
                var_sym = VarSymbol(var_name, value, node.left.read_only)
                var_sym.val_assigned = True
                self.define(var_name, var_sym)
        else:
            if isinstance(node.left, VarDecl):
                error('file={} line={}: Cannot redefine the type of a declared variable: {}'.format(self.file_name, node.line_num, var_name))

            if collection_assignment:
                col = self.search_scopes(node.left.collection.value)
                if col.type.name == TUPLE:
                    error('file={} line={}: Cannot change the elements of a tuple: {}'.format(self.file_name, node.line_num, var_name))
                elif lookup_var.item_types == value:
                    return
            if lookup_var.read_only:
                error('file={} line={}: Cannot change the value of a variable declared constant: {}'.format(self.file_name, node.line_num, var_name))

            lookup_var.val_assigned = True
            if lookup_var.type == self.search_scopes(DYNAMIC):
                return
            if lookup_var.type == self.search_scopes(DYNAMIC):
                return
            if lookup_var.type == self.search_scopes(BIGINT) and value == self.search_scopes(INT):
                return
            if lookup_var.type == self.search_scopes(DECIMAL) and value in (self.search_scopes(DOUBLE), self.search_scopes(FLOAT), self.search_scopes(INT)):
                return
            if lookup_var.type == self.search_scopes(NUMBER) and value in (self.search_scopes(INT), self.search_scopes(DOUBLE), self.search_scopes(FLOAT), self.search_scopes(BIGINT), self.search_scopes(DECIMAL)):
                return
            if lookup_var.type in (self.search_scopes(DOUBLE), self.search_scopes(FLOAT)):
                if value in (self.search_scopes(INT), self.search_scopes(DOUBLE), self.search_scopes(FLOAT)):
                    return
            if lookup_var.type is value:
                return
            if hasattr(value, 'type') and lookup_var.type is value.type:
                return
            if isinstance(value, TypeSymbol):
                value.accessed = True
                if value.type is self.search_scopes(FUNC):
                    if value.type.return_type == lookup_var.type:
                        return
            if hasattr(value, 'value'):
                if value.value == lookup_var.type.name:
                    return
            error('file={} line={} Type Error: Not good things happening (fix this message)'.format(self.file_name, node.line_num))

    def visit_opassign(self, node):
        left = self.visit(node.left)
        right = self.visit(node.right)
        left_type = self.infer_type(left)
        right_type = self.infer_type(right)
        any_type = self.search_scopes(ANY)
        if types_compatible(left_type, right_type) or left_type is any_type or right_type is any_type:
            return left_type
        else:
            error('file={} line={}: Things that should not be happening ARE happening (fix this message)'.format(self.file_name, node.line_num))

    def visit_incrementassign(self, node):
        left = self.visit(node.left)
        left_type = self.infer_type(left)
        any_type = self.search_scopes(ANY)
        if left_type in (self.search_scopes(DOUBLE), self.search_scopes(FLOAT), self.search_scopes(INT)) \
           or left_type is any_type:
            return left_type
        else:
            error('file={} line={}: Things that should not be happening ARE happening (fix this message)'.format(self.file_name, node.line_num))

    def visit_fieldassignment(self, node):
        obj = self.search_scopes(node.obj)
        return self.visit(obj.type.fields[node.field])

    def visit_var(self, node):
        var_name = node.value
        val = self.search_scopes(var_name)
        if val is None:
            error('file={} line={}: Name Error: {}'.format(self.file_name, node.line_num, repr(var_name)))
        else:
            if not val.val_assigned:
                error('file={} line={}: {} is being accessed before it was defined'.format(self.file_name, node.line_num, var_name))
            val.accessed = True
            return val

    def visit_binop(self, node):
        if node.op == CAST or node.op in (IS, IS_NOT):
            self.visit(node.left)
            if node.right.value not in TYPES and not isinstance(self.search_scopes(node.right.value), (EnumSymbol, ClassSymbol)):
                error('file={} line={}: type expected for operation {}, got {} : {}'.format(self.file_name, node.line_num, node.op, node.left, node.right))
            return self.infer_type(self.visit(node.right))
        else:
            left = self.visit(node.left)
            right = self.visit(node.right)
            left_type = self.infer_type(left)
            right_type = self.infer_type(right)
            any_type = self.search_scopes(ANY)
            if types_compatible(left_type, right_type) or left_type is any_type or right_type is any_type:
                return left_type
            else:
                error('file={} line={}: types do not match for operation {}, got {} : {}'.format(self.file_name, node.line_num, node.op, left, right))

    def visit_unaryop(self, node):
        return self.visit(node.expr)

    def visit_range(self, node):
        left = self.visit(node.left)
        right = self.visit(node.right)
        left_type = self.infer_type(left)
        right_type = self.infer_type(right)
        any_type = self.search_scopes(ANY)

        if left_type in (self.search_scopes(INT), self.search_scopes(DOUBLE), self.search_scopes(FLOAT)) and right_type in (self.search_scopes(INT), self.search_scopes(DOUBLE), self.search_scopes(FLOAT)):
            return self.search_scopes(LIST), left_type
        elif right_type is left_type or left_type is any_type or right_type is any_type:
            return self.search_scopes(LIST), left_type
        else:
            error('file={} line={}: Please don\'t do what you just did there ever again. It bad (fix this message)'.format(self.file_name, node.line_num))

    def visit_compound(self, node):
        results = []
        for child in node.children:
            result = self.visit(child)
            if result:
                results.append(result)
        return results

    def visit_typedeclaration(self, node):
        typ = TypeSymbol(node.name, self.search_scopes(node.collection.value))
        self.define(typ.name, typ)

    def visit_externfuncdecl(self, node):
        func_name = node.name
        func_type = self.search_scopes(node.return_type.value)

        if self.search_scopes(func_name) is not None:
            error('file={} line={}: Cannot redefine a declared function: {}'.format(self.file_name, node.line_num, func_name))

        if func_type and func_type.name == FUNC:
            func_type.func = FuncSymbol(ANON, self.visit(node.return_type.func_ret_type), node.parameters, node.body, node.parameter_defaults)

        self.define(func_name, FuncSymbol(func_name, func_type, node.parameters, None))
        self.new_scope()
        if node.varargs:
            varargs_type = self.search_scopes(LIST)
            varargs_type.type = node.varargs[1].value
            varargs = CollectionSymbol(node.varargs[0], varargs_type, self.search_scopes(node.varargs[1].value))
            varargs.val_assigned = True
            self.define(varargs.name, varargs)
        for k, v in node.parameters.items():
            var_type = self.search_scopes(v.value)
            if var_type is self.search_scopes(FUNC):
                sym = FuncSymbol(k, v.func_ret_type, None, None)
            elif isinstance(var_type, TypeSymbol):
                var_type.accessed = True
                if var_type.type is self.search_scopes(FUNC):
                    sym = FuncSymbol(k, var_type.type.return_type, None, None)
                else:
                    raise NotImplementedError
            else:
                sym = VarSymbol(k, var_type)
            sym.val_assigned = True
            self.define(sym.name, sym)

        func_symbol = FuncSymbol(func_name, func_type, node.parameters, None)
        self.define(func_name, func_symbol, 1)
        self.drop_top_scope()

    def visit_funcdecl(self, node):
        func_name = node.name
        func_type = self.search_scopes(node.return_type.value)

        if self.search_scopes(func_name) is not None:
            error('file={} line={}: Cannot redefine a declared function: {}'.format(self.file_name, node.line_num, func_name))

        if func_type and func_type.name == FUNC:
            func_type.func = FuncSymbol(ANON, self.visit(node.return_type.func_ret_type), node.parameters, node.body, node.parameter_defaults)

        self.define(func_name, FuncSymbol(func_name, func_type, node.parameters, node.body, node.parameter_defaults))
        self.new_scope()
        if node.varargs:
            varargs_type = self.search_scopes(LIST)
            varargs_type.type = node.varargs[1].value
            varargs = CollectionSymbol(node.varargs[0], varargs_type, self.search_scopes(node.varargs[1].value))
            varargs.val_assigned = True
            self.define(varargs.name, varargs)
        for k, v in node.parameters.items():
            var_type = self.search_scopes(v.value)
            if var_type is self.search_scopes(FUNC):
                sym = FuncSymbol(k, v.func_ret_type, v.func_params, None)
            elif isinstance(var_type, TypeSymbol):
                var_type.accessed = True
                if var_type.type is self.search_scopes(FUNC):
                    sym = FuncSymbol(k, var_type.type.return_type, v.func_params, None)
                else:
                    raise NotImplementedError
            else:
                sym = VarSymbol(k, var_type)
            sym.val_assigned = True
            self.define(sym.name, sym)
        return_types = self.visit(node.body)
        return_types = list(flatten(return_types))
        if self.return_flag:
            self.return_flag = False
            for ret_type in return_types:
                infered_type = self.infer_type(ret_type)
                if infered_type is not func_type and not types_compatible(infered_type, func_type):
                    error('file={} line={}: The actual return type does not match the declared return type: {}'.format(self.file_name, node.line_num, func_name))
        elif func_type is not None:
            error('file={} line={}: No return value was specified for function: {}'.format(self.file_name, node.line_num, func_name))
        func_symbol = FuncSymbol(func_name, func_type, node.parameters, node.body, node.parameter_defaults)
        self.define(func_name, func_symbol, 1)
        self.drop_top_scope()

    def visit_anonymousfunc(self, node):
        func_type = self.search_scopes(node.return_type.value)
        self.new_scope()
        for k, v in node.parameters.items():
            var_type = self.search_scopes(v.value)
            if var_type is self.search_scopes(FUNC):
                sym = FuncSymbol(k, v.func_ret_type, None, None)
            else:
                sym = VarSymbol(k, var_type)
            sym.val_assigned = True
            self.define(sym.name, sym)
        func_symbol = FuncSymbol(ANON, func_type, node.parameters, node.body)
        return_var_type = self.visit(func_symbol.body)
        return_var_type = list(flatten(return_var_type))
        for ret_type in return_var_type:
            if self.infer_type(ret_type) is not func_type:
                error('file={} line={}: The actual return type does not match the declared return type'.format(self.file_name, node.line_num))
        self.drop_top_scope()
        return func_symbol

    def visit_funccall(self, node):
        func_name = node.name
        func = self.search_scopes(func_name)
        parameters = None
        parameter_defaults = None
        if isinstance(func, (ClassSymbol, EnumSymbol)):
            parameters = func.fields
            parameter_defaults = func.fields
        else:
            parameters = func.parameters
            parameter_defaults = func.parameter_defaults

        for x, param in enumerate(parameters.values()):
            if x < len(node.arguments):
                var = self.visit(node.arguments[x])
                param_ss = self.search_scopes(param.value)
                # TODO: Hacky stuff, first line is made to bypass checks for first-class functions, to fix
                if not isinstance(var, FuncSymbol) and (var.type is not None and not types_compatible(var, param_ss) and (param_ss != self.search_scopes(ANY) and param.value != var.name and param.value != var.type.name)):
                    raise TypeError  # TODO: Make this an actual error
            else:
                func_param_keys = list(parameters.keys())
                if func_param_keys[x] not in node.named_arguments.keys() and func_param_keys[x] not in parameter_defaults.keys():
                    error('file={} line={}: Missing arguments to function: {}'.format(self.file_name, node.line_num, repr(func_name)))
                else:
                    if func_param_keys[x] in node.named_arguments.keys():
                        if not types_compatible(param.value, self.visit(node.named_arguments[func_param_keys[x]]).name):
                            raise TypeError
        if func is None:
            error('file={} line={}: Name Error: {}'.format(self.file_name, node.line_num, repr(func_name)))
        else:
            func.accessed = True
            return func.type

    def visit_methodcall(self, node):  # TODO: Finish this, make Symbols for Classes and Methods
        # TODO: hardcoded error for tuple methods, thing of a better way to do it
        if isinstance(self.search_scopes(node.obj), CollectionSymbol) and self.search_scopes(node.obj).type.name == TUPLE:
            if node.name in ('set', 'append'):
                error('file={} line={}: Immutable Error: cannot use `{}` method'.format(self.file_name, node.line_num, node.name))

        # method_name = node.name
        # method = self.search_scopes("{}.{}".format(self.search_scopes(node.obj).type.name, method_name))
        # for x, param in enumerate(method.parameters.values()):
        #     if x < len(node.arguments):
        #         var = self.visit(node.arguments[x])
        #         param_ss = self.search_scopes(param.value)
        #         if param_ss != self.search_scopes(ANY) and param.value != var.name and param.value != var.type.name:
        #             raise TypeError
        #     else:
        #         method_param_keys = list(method.parameters.keys())
        #         if method_param_keys[x] not in node.named_arguments.keys() and method_param_keys[x] not in method.parameter_defaults.keys():
        #             raise TypeError('Missing arguments to method')
        #         else:
        #             if method_param_keys[x] in node.named_arguments.keys():
        #                 if param.value != self.visit(node.named_arguments[method_param_keys[x]]).name:
        #                     raise TypeError
        # if method is None:
        #     error('file={} line={}: Name Error: {}'.format(self.file_name, node.line_num, repr(method_name)))
        # else:
        #     method.accessed = True
        #     return method.return_type

    def visit_enumdeclaration(self, node):
        sym = EnumSymbol(node.name, node.fields)
        self.define(sym.name, sym)

    def parent_class(self, class_symbol, parent):
        new_fields = parent.fields
        new_fields.update(class_symbol.fields)
        class_symbol.fields = new_fields
        class_symbol.methods = parent.methods + class_symbol.methods

        if parent.base is not None:
            self.parent_class(class_symbol, self.search_scopes(parent.base.value))

    def visit_classdeclaration(self, node):
        class_methods = [FuncSymbol(method.name, method.return_type, method.parameters, method.body) for method in node.methods]
        sym = ClassSymbol(node.name, node.base, node.fields, class_methods)
        for method in class_methods:
            self.define(method.name, method)

        if node.base is not None:
            parent = self.search_scopes(node.base.value)
            parent.accessed = True
            self.parent_class(sym, self.search_scopes(node.base.value))

        self.define(sym.name, sym)

    def visit_return(self, node):
        res = self.visit(node.value)
        self.return_flag = True
        return res

    def visit_pass(self, node):
        pass

    def visit_defer(self, node):  # TODO: Implement me please
        pass

    def visit_vardecl(self, node):
        type_name = node.type.value
        type_symbol = self.search_scopes(type_name)
        var_name = node.value.value
        if type_name in (LIST, TUPLE):
            var_symbol = CollectionSymbol(var_name, type_symbol, node.type.func_params['0'].value)
            var_symbol.read_only = type_name == TUPLE
        else:
            var_symbol = VarSymbol(var_name, type_symbol)
        self.define(var_symbol.name, var_symbol)

    def visit_collection(self, node):
        types = []
        for item in node.items:
            types.append(self.visit(item))
        if types[1:] == types[:-1]:
            if not types:
                return self.search_scopes(node.type), self.search_scopes(ANY)

            return self.search_scopes(node.type), types[0]

        return self.search_scopes(node.type), self.search_scopes(ANY)

    def visit_dotaccess(self, node):
        obj = self.search_scopes(node.obj)
        obj.accessed = True
        if isinstance(obj, EnumSymbol):
            return obj
        elif node.field not in obj.type.fields:
            error('file={} line={}: Invalid property {} of variable {}'.format(
                self.file_name, node.line_num, node.field, node.obj))
        return self.visit(obj.type.fields[node.field])

    def visit_hashmap(self, node):
        for key in node.items.keys():
            value = self.search_scopes(key)
            if value:
                value.accessed = True
        return self.search_scopes(DICT)

    def visit_collectionaccess(self, node):
        collection = self.search_scopes(node.collection.value)
        collection.accessed = True
        if isinstance(node.key, Var):
            key = self.infer_type(node.key.value)
        else:
            key = self.visit(node.key)
        if collection.type is self.search_scopes(LIST) or collection.type is self.search_scopes(TUPLE) or collection.type is self.search_scopes(SET):
            if key is not self.search_scopes(INT) and key.type is not self.search_scopes(INT):
                error('file={} line={}: Something something error... huh? (fix this message)'.format(self.file_name, node.line_num))
            return collection.item_types
        elif collection.type is self.search_scopes(DICT) or collection.type is self.search_scopes(ENUM):
            if key is not self.search_scopes(STR) and key.type is not self.search_scopes(STR):
                error('file={} line={}: Dude....... don\'t (fix this message)'.format(self.file_name, node.line_num))
            return self.search_scopes(ANY)
        else:
            error('file={} line={}: WHY? (fix this message)'.format(self.file_name, node.line_num))

    def visit_print(self, node):
        if node.value:
            self.visit(node.value)

    def visit_input(self, node):
        self.visit(node.value)
