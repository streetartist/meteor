import sys
sys.path.insert(0, 'src')
from meteor.visitor import UnionSymbol, Symbol
from meteor.type_checker import types_compatible

# Mock symbols
int_sym = Symbol("int")
error_sym = Symbol("MyError")
union_sym = UnionSymbol(int_sym, error_sym)

print(f"Union Name: {union_sym.name}")
print(f"Int Name: {int_sym.name}")

# Test compatibility
res = types_compatible(int_sym, union_sym)
print(f"types_compatible(int, int ! MyError) = {res}")

if not res:
    print("FAILED compatibility check")
    sys.exit(1)
else:
    print("PASSED compatibility check")
