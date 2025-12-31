from llvmlite import ir

int8 = ir.IntType(8)
struct_type = ir.LiteralStructType([int8])

tag = ir.Constant(int8, 1)
const_struct = ir.Constant(struct_type, [tag])

print("Struct:", const_struct)
print("Fields:", const_struct.constant)
print("Field 0:", const_struct.constant[0])
print("Field 0 type:", type(const_struct.constant[0]))
