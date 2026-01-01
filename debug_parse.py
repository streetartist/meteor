import sys
sys.path.insert(0, 'src')
from meteor.lexer import Lexer
from meteor.parser import Parser
from meteor.type_checker import Preprocessor

# Simple test case with import
code = '''import http.server

def mymain()
    server = 123
    server.bind()
'''

lexer = Lexer(code, 'test.met')
parser = Parser(lexer)
tree = parser.parse()

print('=== Parse tree ===')
for stmt in tree.block.children:
    print(f'{type(stmt).__name__}: ', end='')
    if hasattr(stmt, 'module'):
        print(f'module={stmt.module}', end='')
    if hasattr(stmt, 'items'):
        print(f' items={stmt.items}', end='')
    if hasattr(stmt, 'name'):
        print(f'name={stmt.name}', end='')
    for attr in dir(stmt):
        if not attr.startswith('_'):
            print(f' {attr}={getattr(stmt, attr)}', end='')
    print()

lexer = Lexer(code, 'test.met')
parser = Parser(lexer)
tree = parser.parse()

print('=== Parse tree ===')
for stmt in tree.block.children:
    print(f'{type(stmt).__name__}: ', end='')
    if hasattr(stmt, 'module'):
        print(f'module={stmt.module}')
    elif hasattr(stmt, 'name'):
        print(f'name={stmt.name}')
    else:
        print()

print('\n=== Type checking ===')
checker = Preprocessor('test.met')
try:
    checker.check(tree)
    print('Type check passed!')
except Exception as e:
    print(f'Type check error: {e}')
