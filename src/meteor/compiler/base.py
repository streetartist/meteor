from meteor.compiler.types import *
from meteor.grammar import *
import meteor.compiler.llvmlite_custom

RET_VAR = 'ret_var'
NUM_TYPES = (ir.IntType, ir.DoubleType, ir.FloatType)
main_module = ir.Module()

type_map = {
    BOOL: ir.IntType(1, signed=False),
    INT: ir.IntType(64),
    INT8: ir.IntType(8),
    INT16: ir.IntType(16),
    INT32: ir.IntType(32),
    INT64: ir.IntType(64),
    INT128: ir.IntType(128),
    UINT: ir.IntType(64, signed=False),
    UINT8: ir.IntType(8, signed=False),
    UINT16: ir.IntType(16, signed=False),
    UINT32: ir.IntType(32, signed=False),
    UINT64: ir.IntType(64, signed=False),
    UINT128: ir.IntType(128, signed=False),
    DOUBLE: ir.DoubleType(),
    FLOAT: ir.FloatType(),
    FUNC: ir.FunctionType,
    VOID: ir.VoidType(),
    BIGINT: None,
    DECIMAL: None,
    NUMBER: None,
    DYNAMIC: None,
}

llvm_type_map = {
    "u1": ir.IntType(1, signed=False),
    "u8": ir.IntType(8, signed=False),
    "u16": ir.IntType(16, signed=False),
    "u32": ir.IntType(32, signed=False),
    "u64": ir.IntType(64, signed=False),
    "u128": ir.IntType(128, signed=False),
    "i1": ir.IntType(1),
    "i8": ir.IntType(8),
    "i16": ir.IntType(16),
    "i32": ir.IntType(32),
    "i64": ir.IntType(64),
    "i128": ir.IntType(128),
    "double": ir.DoubleType(),
    "float": ir.FloatType(),
}
