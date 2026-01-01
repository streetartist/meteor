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
    def __init__(self, name, return_type, parameters, body, line_num, parameter_defaults=None, varargs=None, param_modes=None):
        self.name = name
        self.return_type = return_type
        self.parameters = parameters
        self.parameter_defaults = parameter_defaults or {}
        self.param_modes = param_modes or {}
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
    def __init__(self, name, base=None, methods=None, fields=None, defaults=None, instance_fields=None, weak_fields=None):
        self.name = name
        self.base = base
        self.methods = methods
        self.fields = fields
        self.defaults = defaults
        self.instance_fields = instance_fields
        self.weak_fields = weak_fields or set()  # RFC-001: weak reference fields


class TraitDeclaration(AST):
    """Trait definition with abstract and default methods.
    
    Example:
        trait Drawable
            def draw(self)           # abstract method
            def describe(self)       # default implementation
                print("drawable")
    """
    def __init__(self, name, methods, line_num):
        self.name = name
        self.methods = methods  # dict: name -> (FuncDecl or None for abstract)
        self.line_num = line_num


class ImplBlock(AST):
    """Implementation of a trait for a class.
    
    Example:
        impl Drawable for Circle
            def draw(self)
                print("circle")
    """
    def __init__(self, trait_name, class_name, methods, line_num):
        self.trait_name = trait_name
        self.class_name = class_name
        self.methods = methods  # dict: name -> FuncDecl
        self.line_num = line_num


class ErrorDeclaration(AST):
    """Error enum declaration.
    
    Example:
        error IOError
            NotFound
            PermissionDenied
    """
    def __init__(self, name, variants, line_num):
        self.name = name
        self.variants = variants  # list of variant names
        self.line_num = line_num


class UnionType(AST):
    """Union return type for error handling.
    
    Example:
        def read_file(path: str) -> str ! IOError
    """
    def __init__(self, success_type, error_type, line_num):
        self.success_type = success_type
        self.error_type = error_type
        self.line_num = line_num


class Raise(AST):
    """Raise an error value.

    Example:
        raise IOError.NotFound
    """
    def __init__(self, error_value, line_num):
        self.error_value = error_value
        self.line_num = line_num


class NullableType(AST):
    """Nullable type wrapper.
    
    Example:
        x: int?  # x can be int or null
        name: str?  # name can be str or null
    """
    def __init__(self, inner_type, line_num):
        self.inner_type = inner_type  # The wrapped type
        self.line_num = line_num


class Import(AST):
    """Import a Meteor module.

    Examples:
        import math                    # Import entire module
        import math.vector             # Import submodule (maps to math/vector.met)
        import math as m               # Import with alias
    """
    def __init__(self, module_name, line_num, alias=None):
        self.module_name = module_name  # e.g., "math.vector"
        self.alias = alias              # e.g., "m" for "import math as m"
        self.line_num = line_num


class FromImport(AST):
    """Import specific symbols from a module.

    Examples:
        from math import sin, cos      # Import specific functions
        from math import sin as sine   # Import with alias
        from math import *             # Import all public symbols
    """
    def __init__(self, module_name, imports, line_num):
        self.module_name = module_name  # e.g., "math"
        self.imports = imports          # list of ImportItem or '*'
        self.line_num = line_num


class ImportItem(AST):
    """Single import item with optional alias.

    Example:
        sin as sine  ->  ImportItem("sin", "sine")
    """
    def __init__(self, name, alias=None, line_num=0):
        self.name = name
        self.alias = alias
        self.line_num = line_num


class CImport(AST):
    """Import a C header file.

    Example:
        @link("m")
        @include("/usr/local/include")
        import c "math.h"
    """
    def __init__(self, header_file, link_libs, include_paths, line_num, namespace=None):
        self.header_file = header_file      # e.g. "math.h"
        self.link_libs = link_libs          # e.g. ["m"]
        self.include_paths = include_paths  # e.g. ["/usr/local/include"]
        self.namespace = namespace          # e.g. "math" (derived from header)
        self.line_num = line_num


class Spawn(AST):
    """Spawn a new thread to execute a function.

    Example:
        spawn worker(data)
    """
    def __init__(self, func_call, line_num):
        self.func_call = func_call
        self.line_num = line_num


class Join(AST):
    """Wait for a thread to complete.

    Example:
        join(handle)
    """
    def __init__(self, handle_expr, line_num):
        self.handle_expr = handle_expr
        self.line_num = line_num


class TryStatement(AST):
    """Try/catch block for error handling.
    
    Example:
        try
            x = may_fail()
        catch IOError.NotFound
            print("Not found")
    """
    def __init__(self, try_block, catch_clauses, line_num):
        self.try_block = try_block
        self.catch_clauses = catch_clauses  # list of CatchClause
        self.line_num = line_num


class CatchClause(AST):
    """Catch clause with error pattern and handler body."""
    def __init__(self, error_pattern, body, line_num):
        self.error_pattern = error_pattern  # e.g., IOError.NotFound or just IOError
        self.body = body
        self.line_num = line_num


class ErrorPropagation(AST):
    """Error propagation with ? operator.
    
    Example:
        content = read_file("test.txt")?
    """
    def __init__(self, expr, line_num):
        self.expr = expr
        self.line_num = line_num


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
    def __init__(self, value, line_num, func_params=None, func_ret_type=None, is_frozen=False):
        self.value = value
        self.func_params = func_params
        self.func_ret_type = func_ret_type
        self.line_num = line_num
        self.is_frozen = is_frozen  # RFC-001: frozen type modifier


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


class PublicDecl(AST):
    """Public visibility wrapper for declarations.

    Example:
        pub def calculate(): ...
        pub class Calculator: ...
    """
    def __init__(self, declaration, line_num):
        self.declaration = declaration
        self.line_num = line_num


class ModuleDecl(AST):
    """Module declaration (optional, for explicit module naming).

    Example:
        module math.vector
    """
    def __init__(self, name, line_num):
        self.name = name
        self.line_num = line_num
