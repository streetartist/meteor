import sys
sys.path.insert(0, 'src')
from meteor.lexer import Lexer
from meteor.parser import Parser

# Test enum access
tests = [
    'if x == 0; y = Foo.BAR',
    'req.method = HttpMethod.GET',
]

for code in tests:
    lexer = Lexer(code + '\n', 'test.met')
    parser = Parser(lexer)
    try:
        tree = parser.parse()
        print(f'OK: {code}')
    except Exception as e:
        print(f'FAIL: {code} -> {e}')
