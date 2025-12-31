import sys
import traceback
sys.path.insert(0, 'src')

code = """
error MyError
    Fail

def process(x: int) -> int ! MyError
    return x

process(1)
"""

from meteor.lexer import Lexer
from meteor.parser import Parser
from meteor.type_checker import Preprocessor
from meteor.compiler.code_generator import CodeGenerator

try:
    lexer = Lexer(code, 'test')
    parser = Parser(lexer)
    tree = parser.parse()
    print('Parsing OK')

    preprocessor = Preprocessor('test')
    preprocessor.check(tree)
    print('Type checking OK')

    codegen = CodeGenerator('test')
    codegen.generate_code(tree)
    print('Code generation OK')
except Exception:
    traceback.print_exc()
