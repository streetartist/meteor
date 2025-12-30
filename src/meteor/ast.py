from meteor.grammar import *


class AST(object):
    def __str__(self) -> str:
        return '(' + ' '.join(str(value) for key, value in sorted(self.__dict__.items()) if not key.startswith("__") and key != 'read_only' and key != 'line_num' and value is not None) + ')'

    __repr__ = __str__


class Compound(AST):
    def __init__(self):
        self.children = []

    def __str__(self) -> str:
        return '\n'.join(str(child) for child in self.children)

    __repr__ = __str__


class Program(AST):
    def __init__(self, block: Compound):
        self.block = block

    def __str__(self) -> str:
        return '\n'.join(str(child) for child in self.block.children)

    __repr__ = __str__


class VarDecl(AST):
    def __init__(self, value, type_node, line_num, read_only=False):
        self.value = value
        self.type = type_node
        self.read_only = read_only
        self.line_num = line_num


class Var(AST):
    def __init__(self, value, line_num, read_only=False):
        self.value = value
        self.read_only = read_only
        self.line_num = line_num

    def __str__(self) -> str:
        return ' '.join(str(value) for key, value in sorted(self.__dict__.items()) if not key.startswith("__") and key != 'read_only' and key != 'line_num')

    __repr__ = __str__


class FuncDecl(AST):
    def __init__(self, name, return_type, parameters, body, line_num, parameter_defaults=None, varargs=None):
        self.name = name
        self.return_type = return_type
        self.parameters = parameters
        self.parameter_defaults = parameter_defaults or {}
        self.varargs = varargs
        self.body = body
        self.line_num = line_num

    # def __str__(self) -> str:
    # 	return '<{name}:{type} ({params})>'.format(name=self.name, type=self.return_type.value, params=', '.join('{}:{}'.format(key, value.value) for key, value in self.parameters.items()))
    #
    # __repr__ = __str__


class ExternFuncDecl(AST):
    def __init__(self, name, return_type, parameters, line_num, varargs=None):
        self.name = name
        self.return_type = return_type
        self.parameters = parameters
        self.varargs = varargs
        self.line_num = line_num


class AnonymousFunc(AST):
    def __init__(self, return_type, parameters, body, line_num, parameter_defaults=None, varargs=None):
        self.return_type = return_type
        self.parameters = parameters
        self.parameter_defaults = parameter_defaults or {}
        self.varargs = varargs
        self.body = body
        self.line_num = line_num

    # def __str__(self) -> str:
    # 	return '<Anonymous:{type} ({params})>'.format(type=self.return_type.value, params=', '.join('{}:{}'.format(key, value.value) for key, value in self.parameters.items()))
    #
    # __repr__ = __str__


class FuncCall(AST):
    def __init__(self, name, arguments, line_num, named_arguments=None):
        self.name = name
        self.arguments = arguments
        self.named_arguments = named_arguments or {}
        self.line_num = line_num


class MethodCall(AST):
    def __init__(self, obj, name, arguments, line_num, named_arguments=None):
        self.obj = obj
        self.name = name
        self.arguments = arguments
        self.named_arguments = named_arguments or {}
        self.line_num = line_num


class Return(AST):
    def __init__(self, value, line_num):
        self.value = value
        self.line_num = line_num


class EnumDeclaration(AST):
    def __init__(self, name, fields, line_num):
        self.name = name
        self.fields = fields
        self.line_num = line_num


class ClassDeclaration(AST):
    def __init__(self, name, base=None, methods=None, fields=None, defaults=None, instance_fields=None):
        self.name = name
        self.base = base
        self.methods = methods
        self.fields = fields
        self.defaults = defaults
        self.instance_fields = instance_fields


class Assign(AST):
    def __init__(self, left, op, right, line_num):
        self.left = left
        self.op = op
        self.right = right
        self.line_num = line_num


class OpAssign(AST):
    def __init__(self, left, op, right, line_num):
        self.left = left
        self.op = op
        self.right = right
        self.line_num = line_num


class IncrementAssign(AST):
    def __init__(self, left, op, line_num):
        self.left = left
        self.op = op
        self.line_num = line_num


class If(AST):
    def __init__(self, op, comps, blocks, indent_level, line_num):
        self.op = op
        self.comps = comps
        self.blocks = blocks
        self.indent_level = indent_level
        self.line_num = line_num


class Else(AST):
    pass


class While(AST):
    def __init__(self, op, comp, block, line_num):
        self.op = op
        self.comp = comp
        self.block = block
        self.line_num = line_num


class For(AST):
    def __init__(self, iterator, block, elements, line_num):
        self.iterator = iterator
        self.block = block
        self.elements = elements
        self.line_num = line_num


class LoopBlock(AST):
    def __init__(self):
        self.children = []

    def __str__(self) -> str:
        return '\n'.join(str(child) for child in self.children)

    __repr__ = __str__


class Switch(AST):
    def __init__(self, value, cases, line_num):
        self.value = value
        self.cases = cases
        self.line_num = line_num


class Case(AST):
    def __init__(self, value, block, line_num):
        self.value = value
        self.block = block
        self.line_num = line_num


class Break(AST):
    def __init__(self, line_num):
        self.line_num = line_num

    def __str__(self) -> str:
        return BREAK

    __repr__ = __str__


class Fallthrough(AST):
    def __init__(self, line_num):
        self.line_num = line_num

    def __str__(self) -> str:
        return FALLTHROUGH

    __repr__ = __str__


class Continue(AST):
    def __init__(self, line_num):
        self.line_num = line_num

    def __str__(self) -> str:
        return CONTINUE

    __repr__ = __str__


class Pass(AST):
    def __init__(self, line_num):
        self.line_num = line_num

    def __str__(self) -> str:
        return CONTINUE

    __repr__ = __str__


class Defer(AST):
    def __init__(self, line_num, statement):
        self.line_num = line_num
        self.statement = statement

    def __str__(self) -> str:
        return DEFER

    __repr__ = __str__


class BinOp(AST):
    def __init__(self, left, op, right, line_num):
        self.left = left
        self.op = op
        self.right = right
        self.line_num = line_num


class UnaryOp(AST):
    def __init__(self, op, expr, line_num):
        self.op = op
        self.expr = expr
        self.line_num = line_num


class Range(AST):
    def __init__(self, left, right, line_num):
        self.left = left
        self.right = right
        self.value = RANGE
        self.line_num = line_num


class CollectionAccess(AST):
    def __init__(self, collection, key, line_num):
        self.collection = collection
        self.key = key
        self.line_num = line_num


class DotAccess(AST):
    def __init__(self, obj, field, line_num):
        self.obj = obj
        self.field = field
        self.line_num = line_num


class Type(AST):
    def __init__(self, value, line_num, func_params=None, func_ret_type=None):
        self.value = value
        self.func_params = func_params
        self.func_ret_type = func_ret_type
        self.line_num = line_num


class TypeDeclaration(AST):
    def __init__(self, name, collection, line_num):
        self.name = name
        self.collection = collection
        self.line_num = line_num


class Void(AST):
    value = VOID


class Constant(AST):
    def __init__(self, value, line_num):
        self.value = value
        self.line_num = line_num


class Num(AST):
    def __init__(self, value, val_type, line_num):
        self.value = value
        self.val_type = val_type
        self.line_num = line_num


class Str(AST):
    def __init__(self, value, line_num):
        self.value = value
        self.line_num = line_num


class Collection(AST):
    def __init__(self, collection_type, line_num, read_only, *items):
        self.type = collection_type
        self.read_only = read_only
        self.read_only = read_only
        self.items = items
        self.line_num = line_num


class HashMap(AST):
    def __init__(self, items, line_num):
        self.items = items
        self.line_num = line_num


class Print(AST):
    def __init__(self, value, line_num):
        self.value = value
        self.line_num = line_num


class Input(AST):
    def __init__(self, value, line_num):
        self.value = value
        self.line_num = line_num
