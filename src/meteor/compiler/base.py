from meteor.compiler.types import *
from meteor.grammar import *
import meteor.compiler.llvmlite_custom

RET_VAR = 'ret_var'

# ============================================================================
# Memory Management Constants (RFC-001)
# ============================================================================

# Object Header Field Indices
HEADER_STRONG_RC = 0   # Strong reference count (u32)
HEADER_WEAK_RC = 1     # Weak reference count (u32)
HEADER_FLAGS = 2       # Flags byte (u8)
HEADER_TYPE_TAG = 3    # Type tag (u8)
HEADER_RESERVED = 4    # Reserved for alignment (u16)

# Type Tags for Runtime Type Information
TYPE_TAG_UNKNOWN = 0
TYPE_TAG_INT = 1
TYPE_TAG_FLOAT = 2
TYPE_TAG_BOOL = 3
TYPE_TAG_STR = 4
TYPE_TAG_BIGINT = 5
TYPE_TAG_DECIMAL = 6
TYPE_TAG_LIST = 7
TYPE_TAG_TUPLE = 8
TYPE_TAG_DICT = 9
TYPE_TAG_CLASS = 10
TYPE_TAG_FUNC = 11
TYPE_TAG_CHANNEL = 12

# Object Flags
FLAG_NONE = 0x00
FLAG_IS_FROZEN = 0x01   # Bit 0: Object is immutable (use atomic RC ops)
FLAG_IS_ZOMBIE = 0x02   # Bit 1: Object payload destroyed, header alive for weak refs

# Object Header Type Name
OBJECT_HEADER = 'meteor.header'
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
