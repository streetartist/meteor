from decimal import Decimal
from enum import Enum

from meteor.ast import Type
from meteor.compiler.base import *


class Symbol(object):
    def __init__(self, name, symbol_type=None):
        self.name = name
        self.type = symbol_type


class BuiltinTypeSymbol(Symbol):
    def __init__(self, name, llvm_type=None, func=None):
        super().__init__(name)
        self.llvm_type = llvm_type
        self.func = func

    def type(self):
        return self.llvm_type.type()

    def __str__(self) -> str:
        return self.name

    __repr__ = __str__


ANY_BUILTIN = BuiltinTypeSymbol(ANY)
INT_BUILTIN = BuiltinTypeSymbol(INT, Int)
INT8_BUILTIN = BuiltinTypeSymbol(INT8, Int8)
INT16_BUILTIN = BuiltinTypeSymbol(INT16, Int16)
INT32_BUILTIN = BuiltinTypeSymbol(INT32, Int32)
INT64_BUILTIN = BuiltinTypeSymbol(INT64, Int64)
INT128_BUILTIN = BuiltinTypeSymbol(INT128, Int128)
UINT_BUILTIN = BuiltinTypeSymbol(UINT, UInt)
UINT8_BUILTIN = BuiltinTypeSymbol(UINT8, UInt8)
UINT16_BUILTIN = BuiltinTypeSymbol(UINT16, UInt16)
UINT32_BUILTIN = BuiltinTypeSymbol(UINT32, UInt32)
UINT64_BUILTIN = BuiltinTypeSymbol(UINT64, UInt64)
UINT128_BUILTIN = BuiltinTypeSymbol(UINT128, UInt128)
DOUBLE_BUILTIN = BuiltinTypeSymbol(DOUBLE, Double)
FLOAT_BUILTIN = BuiltinTypeSymbol(FLOAT, Float)
COMPLEX_BUILTIN = BuiltinTypeSymbol(COMPLEX, Complex)
BOOL_BUILTIN = BuiltinTypeSymbol(BOOL, Bool)
STR_BUILTIN = BuiltinTypeSymbol(STR, Str)
LIST_BUILTIN = BuiltinTypeSymbol(LIST, List)
TUPLE_BUILTIN = BuiltinTypeSymbol(TUPLE, Tuple)
DICT_BUILTIN = BuiltinTypeSymbol(DICT, Dict)
ENUM_BUILTIN = BuiltinTypeSymbol(ENUM, Enum)
FUNC_BUILTIN = BuiltinTypeSymbol(FUNC, Func)
CLASS_BUILTIN = BuiltinTypeSymbol(CLASS, Class)
BIGINT_BUILTIN = BuiltinTypeSymbol(BIGINT, None) # TODO: Define BigInt type class in types.py?
DECIMAL_BUILTIN = BuiltinTypeSymbol(DECIMAL, None)
NUMBER_BUILTIN = BuiltinTypeSymbol(NUMBER, None)
DYNAMIC_BUILTIN = BuiltinTypeSymbol(DYNAMIC, None)


class VarSymbol(Symbol):
    def __init__(self, name, var_type, read_only=False):
        super().__init__(name, var_type)
        self.accessed = False
        self.val_assigned = False
        self.read_only = read_only

    def __str__(self) -> str:
        return '<{name}:{type}>'.format(name=self.name, type=self.type)

    __repr__ = __str__


class EnumSymbol(Symbol):
    def __init__(self, name, fields):
        super().__init__(name)
        self.fields = fields
        self.accessed = False
        self.val_assigned = False

    def __str__(self) -> str:
        return ENUM


class ClassSymbol(Symbol):
    def __init__(self, name, base, fields, methods):
        super().__init__(name)
        self.base = base
        self.fields = fields
        self.methods = methods
        self.accessed = False
        self.val_assigned = False
        self.traits = []  # List of trait names this class implements


class TraitSymbol(Symbol):
    """Symbol for a trait definition."""
    def __init__(self, name, methods):
        super().__init__(name)
        self.methods = methods  # dict: method_name -> FuncSymbol or None (abstract)
        self.accessed = False
        self.val_assigned = False

    def __str__(self) -> str:
        return '<trait {}>'.format(self.name)


class ImplSymbol(Symbol):
    """Symbol for a trait implementation on a class."""
    def __init__(self, trait_name, class_name, methods):
        super().__init__("{}_for_{}".format(trait_name, class_name))
        self.trait_name = trait_name
        self.class_name = class_name
        self.methods = methods  # dict: method_name -> FuncSymbol
        self.accessed = False
        self.val_assigned = False

class ErrorSymbol(Symbol):
    """Symbol for an error enum definition."""
    def __init__(self, name, variants):
        super().__init__(name)
        self.variants = variants  # list of variant names
        self.accessed = False
        self.val_assigned = False

    def __str__(self) -> str:
        return '<error {}>'.format(self.name)


class UnionSymbol(Symbol):
    """Symbol for a union type (Success ! Error)."""
    def __init__(self, success_type, error_type):
        super().__init__("{} ! {}".format(success_type.name, error_type.name))
        self.success_type = success_type
        self.error_type = error_type
        self.accessed = False
        self.val_assigned = False


class ModuleSymbol(Symbol):
    """Symbol for an imported module.

    Tracks module metadata and exported symbols.
    """
    def __init__(self, name, file_path=None, exports=None):
        super().__init__(name)
        self.file_path = file_path      # Physical path to module file
        self.exports = exports or {}    # Dict of exported symbols
        self.is_loaded = False          # Whether module has been loaded
        self.accessed = False
        self.val_assigned = False
        self.read_only = True           # Modules are read-only

    def __str__(self) -> str:
        return '<module {}>'.format(self.name)

class CollectionSymbol(Symbol):
    def __init__(self, name, var_type, item_types):
        super().__init__(name, var_type)
        self.item_types = item_types
        self.accessed = False
        self.val_assigned = False
        self.read_only = False


class FuncSymbol(Symbol):
    def __init__(self, name, return_type, parameters, body, parameter_defaults={}, param_modes={}):
        super().__init__(name, return_type)
        self.parameters = parameters
        self.parameter_defaults = parameter_defaults
        self.param_modes = param_modes  # RFC-001: Track parameter modes (borrow/escape/owned/ref)
        self.body = body
        self.accessed = False
        self.val_assigned = True

    def __str__(self) -> str:
        return '<{name}:{type} ({params})>'.format(name=self.name, type=self.type, params=', '.join(
            '{}:{}'.format(key, value.value) for key, value in self.parameters.items()))

    __repr__ = __str__


class TypeSymbol(Symbol):
    def __init__(self, name, types):
        super().__init__(name, types)
        self.accessed = False

    def __str__(self) -> str:
        return '<{name}:{type}>'.format(name=self.name, type=self.type)

    __repr__ = __str__


class BuiltinFuncSymbol(Symbol):
    def __init__(self, name, return_type, parameters, body):
        super().__init__(name, return_type)
        self.parameters = parameters
        self.body = body
        self.accessed = False
        self.val_assigned = True

    def __str__(self) -> str:
        return '<{name}:{type} ({params})>'.format(name=self.name, type=self.type, params=', '.join(
            '{}:{}'.format(key, value.value) for key, value in self.parameters.items()))

    __repr__ = __str__


class NodeVisitor(object):
    def __init__(self):
        self._scope = [{}]
        self._init_builtins()

    def _init_builtins(self):
        self.define(ANY, ANY_BUILTIN)
        self.define(INT, INT_BUILTIN)
        self.define(INT8, INT8_BUILTIN)
        self.define(INT16, INT16_BUILTIN)
        self.define(INT32, INT32_BUILTIN)
        self.define(INT64, INT64_BUILTIN)
        self.define(INT128, INT128_BUILTIN)
        self.define(UINT, UINT_BUILTIN)
        self.define(UINT8, UINT8_BUILTIN)
        self.define(UINT16, UINT16_BUILTIN)
        self.define(UINT32, UINT32_BUILTIN)
        self.define(UINT64, UINT64_BUILTIN)
        self.define(UINT128, UINT128_BUILTIN)
        self.define(DOUBLE, DOUBLE_BUILTIN)
        self.define(FLOAT, FLOAT_BUILTIN)
        self.define(COMPLEX, COMPLEX_BUILTIN)
        self.define(BOOL, BOOL_BUILTIN)
        self.define(STR, STR_BUILTIN)
        self.define(LIST, LIST_BUILTIN)
        self.define(TUPLE, TUPLE_BUILTIN)
        self.define(DICT, DICT_BUILTIN)
        self.define(ENUM, ENUM_BUILTIN)
        self.define(FUNC, FUNC_BUILTIN)
        self.define(FUNC, FUNC_BUILTIN)
        self.define(CLASS, CLASS_BUILTIN)
        self.define(BIGINT, BIGINT_BUILTIN)
        self.define(DECIMAL, DECIMAL_BUILTIN)
        self.define(NUMBER, NUMBER_BUILTIN)
        self.define(DYNAMIC, DYNAMIC_BUILTIN)

    def visit(self, node):
        method_name = 'visit_' + type(node).__name__.lower()
        visitor = getattr(self, method_name, self.generic_visit)
        return visitor(node)

    @staticmethod
    def generic_visit(node):
        raise Exception('No visit_{} method'.format(type(node).__name__.lower()))

    @property
    def top_scope(self):
        return self._scope[-1] if len(self._scope) >= 1 else None

    @property
    def second_scope(self):
        return self._scope[-2] if len(self._scope) >= 2 else None

    def search_scopes(self, name, level=None):
        if name in (None, []):
            return None
        if level:
            if name in self._scope[level]:
                return self._scope[level][name]
        else:
            for scope in reversed(self._scope):
                if name in scope:
                    return scope[name]

    def define(self, key, value, level=0):
        level = (len(self._scope) - level) - 1
        self._scope[level][key] = value

    def new_scope(self):
        self._scope.append({})

    def drop_top_scope(self):
        self._scope.pop()

    @property
    def symbols(self):
        return [value for scope in self._scope for value in scope.values()]

    @property
    def keys(self):
        return [key for scope in self._scope for key in scope.keys()]

    @property
    def items(self):
        return [(key, value) for scope in self._scope for key, value in scope.items()]

    @property
    def unvisited_symbols(self):
        return [sym_name for sym_name, sym_val in self.items if
                not isinstance(sym_val, (BuiltinTypeSymbol, BuiltinFuncSymbol)) and not
                sym_val.accessed and sym_name != '_']

    def infer_type(self, value):
        if isinstance(value, BuiltinTypeSymbol):
            return value
        if isinstance(value, FuncSymbol):
            return self.search_scopes(FUNC)
        if isinstance(value, VarSymbol):
            return value.type
        if isinstance(value, Type):
            return self.search_scopes(value.value)
        if isinstance(value, int):
            return self.search_scopes(INT)
        if isinstance(value, Decimal):
            return self.search_scopes(DOUBLE)
        if isinstance(value, float):
            return self.search_scopes(FLOAT)
        if isinstance(value, complex):
            return self.search_scopes(COMPLEX)
        if isinstance(value, str):
            return self.search_scopes(STR)
        if isinstance(value, EnumSymbol):
            return self.search_scopes(ENUM)
        if isinstance(value, ClassSymbol):
            return self.search_scopes(CLASS)
        if isinstance(value, bool):
            return self.search_scopes(BOOL)
        if isinstance(value, list):
            return self.search_scopes(TUPLE)
        if isinstance(value, dict):
            return self.search_scopes(DICT)
        if isinstance(value, Enum):
            return self.search_scopes(ENUM)
        if callable(value):
            return self.search_scopes(FUNC)
        raise TypeError('Type not recognized: {}'.format(value))
