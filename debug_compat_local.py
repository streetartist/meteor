
class Symbol(object):
    def __init__(self, name, type=None):
        self.name = name
        self.type = type
    def __str__(self) -> str:
        return self.name

class UnionSymbol(Symbol):
    def __init__(self, success_type, error_type):
        super().__init__("{} ! {}".format(success_type.name, error_type.name))
        self.success_type = success_type
        self.error_type = error_type

def types_compatible(left_type, right_type) -> bool:
    l_type = str(left_type)
    r_type = str(right_type)
    print(f"Comparing '{l_type}' with '{r_type}'")
    
    if l_type == r_type:
        return True
        
    if '!' in r_type:
        print(f"Found '!' in {r_type}")
        parts = r_type.split('!')
        success_part = parts[0].strip()
        print(f"Checking success part: '{success_part}'")
        
        # Recursive check
        # We simulate recursion by creating a Symbol or just passing string
        # Since types_compatible converts to str at start, passing string is fine
        if types_compatible(left_type, success_part):
            print("Compatible with success part")
            return True
            
    return False

int_sym = Symbol("int")
error_sym = Symbol("MyError")
union_sym = UnionSymbol(int_sym, error_sym)

print(f"Union str: '{str(union_sym)}'")
res = types_compatible(int_sym, union_sym)
print(f"Result: {res}")
