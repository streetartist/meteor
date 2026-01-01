import sys
sys.path.insert(0, 'src')
from meteor.lexer import Lexer
from meteor.parser import Parser
from meteor.type_checker import Preprocessor
from meteor.compiler.code_generator import CodeGenerator
from llvmlite import binding as llvm

# Read from file instead
with open('tests/meteor/str_func_test.met', 'r', encoding='utf-8') as f:
    code = f.read()

lexer = Lexer(code, 'test')
parser = Parser(lexer)
prog = parser.parse()
symtab_builder = Preprocessor('test')
symtab_builder.check(prog)
gen = CodeGenerator('test')
gen.generate_code(prog)

# Find main function in the IR
ir_str = str(gen.module)
lines = ir_str.split('\n')
for i, line in enumerate(lines):
    if 'define' in line and '@"main"' in line:
        for j in range(i, min(i+30, len(lines))):
            print(f"{j}: {lines[j]}")
            if lines[j].strip() == '}':
                break
        break
