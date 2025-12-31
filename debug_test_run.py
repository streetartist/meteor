import sys
import traceback
sys.path.insert(0, 'src')
from meteor.lexer import Lexer
from meteor.parser import Parser
from meteor.type_checker import Preprocessor
from meteor.compiler.code_generator import CodeGenerator

# Load code from file
with open('tests/meteor/error_try.met', 'r') as f:
    code = f.read()

try:
    lexer = Lexer(code, 'test')
    parser = Parser(lexer)
    tree = parser.parse()
    # print('Parsing OK')

    preprocessor = Preprocessor('test')
    preprocessor.check(tree)
    # print('Type checking OK')

    with open('ast_dump.txt', 'w') as f:
        f.write(str(tree))
    
    codegen = CodeGenerator('test')
    codegen.generate_code(tree)
    with open('ir_dump.ll', 'w') as f:
        f.write(str(codegen.module))
    with open('globals_dump.txt', 'w') as f:
        for name, g in codegen.module.globals.items():
            f.write(f"--- {name} ---\n")
            f.write(str(g))
            f.write("\n")
    import llvmlite.binding as llvm
    # llvm.initialize()
    llvm.initialize_native_target()
    llvm.initialize_native_asmprinter()
    
    llvm_ir = str(codegen.module)
    try:
        mod = llvm.parse_assembly(llvm_ir)
        mod.verify()
        print('LLVM Verify OK')
    except Exception as e:
        print('LLVM Verify FAILED')
        print(e)
        
    print('Code generation OK')
    
    # Run? 
    # Usually generate_code produces valid IR. The crash happens during generation (builder.store).
except Exception as e:
    with open('debug_error.txt', 'w') as f:
        f.write(str(e))
        f.write('\n')
        traceback.print_exc(file=f)
    print("Error written to debug_error.txt")
