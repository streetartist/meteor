# gone/llvmgen.py
'''
Project 5 : Generate LLVM
=========================
In this project, you're going to translate the intermediate code
into LLVM IR.    Once you're done, your code will be runnable.  It
is strongly advised that you do *all* of the steps of Exercise 5
prior to starting this project.   Don't rush into it.

For Project 5, you are going to emit all of the LLVM instructions into
a single function main().  This is a temporary shim to get things to
work before we implement further support for user-defined functions later.

Further instructions are contained in the comments below.
'''
from collections import ChainMap
from functools import partialmethod

# LLVM imports. Don't change this.

from llvmlite.ir import (
    Module, IRBuilder, Function, IntType, DoubleType, VoidType, Constant,
    GlobalVariable, FunctionType
    )

# Declare the LLVM type objects that you want to use for the low-level
# in our intermediate code.  Basically, you're going to need to
# declare the integer, float, and char types here.  These correspond
# to the types being used the intermediate code being created by
# the ircode.py file.

int_type    = IntType(32)         # 32-bit integer
float_type  = DoubleType()        # 64-bit float
byte_type   = IntType(8)          # 8-bit integer

void_type   = VoidType()          # Void type.  This is a special type
                                  # used for internal functions returning
                                  # no value

LLVM_TYPE_MAPPING = {
    'I': int_type,
    'F': float_type,
    'B': byte_type,
    None: void_type
}

# The following class is going to generate the LLVM instruction stream.
# The basic features of this class are going to mirror the experiments
# you tried in Exercise 5.  The execution model is somewhat similar
# to the visitor class.
#
# Given a sequence of instruction tuples such as this:
#
#         code = [
#              ('MOVI', 1, 'R1'),
#              ('MOVI', 2, 'R2')
#              ('ADDI', 'R1', 'R2', 'R3')
#              ('PRINTI', 'R3')
#              ...
#         ]
#
#    The class executes methods self.emit_opcode(args).  For example:
#
#             self.emit_MOVI(1, 'R1')
#             self.emit_MOVI(2, 'R2')
#             self.emit_ADDI('R1', 'R2', 'R3')
#             self.emit_PRINTI('R3')
#
#    Internally, you'll need to track variables, constants and other
#    objects being created.  Use a Python dictionary to emulate
#    storage.

class GenerateLLVM(object):
    def __init__(self):
        # Perform the basic LLVM initialization.  You need the following parts:
        #
        #    1.  A top-level Module object
        #    2.  A Function instance in which to insert code
        #    3.  A Builder instance to generate instructions
        #
        # Note: For project 5, we don't have any user-defined
        # functions so we're just going to emit all LLVM code into a top
        # level function void main() { ... }.   This will get changed later.

        self.module = Module('module')

        # All globals variables and function definitions go here
        self.globals = { }

        self.blocks = { }

        # Initialize the runtime library functions (see below)
        self.declare_runtime_library()


    def declare_runtime_library(self):
        # Certain functions such as I/O and string handling are often easier
        # to implement in an external C library.  This method should make
        # the LLVM declarations for any runtime functions to be used
        # during code generation.    Please note that runtime function
        # functions are implemented in C in a separate file gonert.c

        self.runtime = {}

        # Declare printing functions
        self.runtime['_print_int'] = Function(self.module,
                                              FunctionType(void_type, [int_type]),
                                              name="_print_int")

        self.runtime['_print_float'] = Function(self.module,
                                                FunctionType(void_type, [float_type]),
                                                name="_print_float")

        self.runtime['_print_byte'] = Function(self.module,
                                                FunctionType(void_type, [byte_type]),
                                                name="_print_byte")

    def generate_code(self, ir_function):
        # Given a sequence of SSA intermediate code tuples, generate LLVM
        # instructions using the current builder (self.builder).  Each
        # opcode tuple (opcode, args) is dispatched to a method of the
        # form self.emit_opcode(args)
        # print(ir_function)
        self.function = Function(self.module,
                                 FunctionType(
                                     LLVM_TYPE_MAPPING[ir_function.return_type],
                                     [LLVM_TYPE_MAPPING[ptype] for _, ptype in ir_function.parameters]
                                 ),
                                 name=ir_function.name)

        self.block = self.function.append_basic_block('entry')
        self.builder = IRBuilder(self.block)

        # Save the function as a global to be referenced later on another
        # function
        self.globals[ir_function.name] = self.function

        # All local variables are stored here
        self.locals = { }

        self.vars = ChainMap(self.locals, self.globals)

        # Dictionary that holds all of the temporary registers created in
        # the intermediate code.
        self.temps = { }

        # Setup the function parameters
        for n, (pname, ptype) in enumerate(ir_function.parameters):
            self.vars[pname] = self.builder.alloca(LLVM_TYPE_MAPPING[ptype], name=pname)
            self.builder.store(self.function.args[n], self.vars[pname])

        # Allocate the return value and return_block
        if ir_function.return_type:
            self.vars['return'] = self.builder.alloca(
                LLVM_TYPE_MAPPING[ir_function.return_type], name='return')
        self.return_block = self.function.append_basic_block('return')

        for opcode, *args in ir_function.code:
            if hasattr(self, 'emit_'+opcode):
                getattr(self, 'emit_'+opcode)(*args)
            else:
                print('Warning: No emit_'+opcode+'() method')

        if not self.block.is_terminated:
            self.builder.branch(self.return_block)

        self.builder.position_at_end(self.return_block)
        self.builder.ret(self.builder.load(self.vars['return'], 'return'))

    def get_block(self, block_name):
        block = self.blocks.get(block_name)
        if block is None:
            block = self.function.append_basic_block(block_name)
            self.blocks[block_name] = block

        return block

    # ----------------------------------------------------------------------
    # Opcode implementation.   You must implement the opcodes.  A few
    # sample opcodes have been given to get you started.
    # ----------------------------------------------------------------------

    # Creation of literal values.  Simply define as LLVM constants.
    def emit_MOV(self, value, target, val_type):
        self.temps[target] = Constant(val_type, value)

    emit_MOVI = partialmethod(emit_MOV, val_type=int_type)
    emit_MOVF = partialmethod(emit_MOV, val_type=float_type)
    emit_MOVB = partialmethod(emit_MOV, val_type=byte_type)

    # Allocation of GLOBAL variables.  Declare as global variables and set to
    # a sensible initial value.
    def emit_VAR(self, name, var_type):
        var = GlobalVariable(self.module, var_type, name=name)
        var.initializer = Constant(var_type, 0)
        self.globals[name] = var

    emit_VARI = partialmethod(emit_VAR, var_type=int_type)
    emit_VARF = partialmethod(emit_VAR, var_type=float_type)
    emit_VARB = partialmethod(emit_VAR, var_type=byte_type)

    # Allocation of LOCAL variables.  Declare as local variables and set to
    # a sensible initial value.
    def emit_ALLOC(self, name, var_type):
        self.locals[name] = self.builder.alloca(var_type, name=name)

    emit_ALLOCI = partialmethod(emit_ALLOC, var_type=int_type)
    emit_ALLOCF = partialmethod(emit_ALLOC, var_type=float_type)
    emit_ALLOCB = partialmethod(emit_ALLOC, var_type=byte_type)

    # Load/store instructions for variables.  Load needs to pull a
    # value from a global variable and store in a temporary. Store
    # goes in the opposite direction.
    def emit_LOADI(self, name, target):
        self.temps[target] = self.builder.load(self.vars[name], name=target)

    emit_LOADF = emit_LOADI
    emit_LOADB = emit_LOADI

    def emit_STOREI(self, source, target):
        self.builder.store(self.temps[source], self.vars[target])

    emit_STOREF = emit_STOREI
    emit_STOREB = emit_STOREI

    # Binary + operator
    def emit_ADDI(self, left, right, target):
        self.temps[target] = self.builder.add(self.temps[left], self.temps[right], name=target)

    def emit_ADDF(self, left, right, target):
        self.temps[target] = self.builder.fadd(self.temps[left], self.temps[right], name=target)

    # Binary - operator
    def emit_SUBI(self, left, right, target):
        self.temps[target] = self.builder.sub(self.temps[left], self.temps[right], name=target)

    def emit_SUBF(self, left, right, target):
        self.temps[target] = self.builder.fsub(self.temps[left], self.temps[right], name=target)

    # Binary * operator
    def emit_MULI(self, left, right, target):
        self.temps[target] = self.builder.mul(self.temps[left], self.temps[right], name=target)

    def emit_MULF(self, left, right, target):
        self.temps[target] = self.builder.fmul(self.temps[left], self.temps[right], name=target)

    # Binary / operator
    def emit_DIVI(self, left, right, target):
        self.temps[target] = self.builder.sdiv(self.temps[left], self.temps[right], name=target)

    def emit_DIVF(self, left, right, target):
        self.temps[target] = self.builder.fdiv(self.temps[left], self.temps[right], name=target)

    # Print statements
    def emit_PRINT(self, source, runtime_name):
        self.builder.call(self.runtime[runtime_name], [self.temps[source]])

    emit_PRINTI = partialmethod(emit_PRINT, runtime_name="_print_int")
    emit_PRINTF = partialmethod(emit_PRINT, runtime_name="_print_float")
    emit_PRINTB = partialmethod(emit_PRINT, runtime_name="_print_byte")

    def emit_CMPI(self, operator, left, right, target):
        tmp = self.builder.icmp_signed(operator, self.temps[left], self.temps[right], 'tmp')
        # LLVM compares produce a 1-bit integer as a result.  Since our IRcode using integers
        # for bools, need to sign-extend the result up to the normal int_type to continue
        # with further processing (otherwise you'll get a LLVM type error).
        self.temps[target] = self.builder.zext(tmp, int_type, target)

    def emit_CMPF(self, operator, left, right, target):
        tmp = self.builder.fcmp_ordered(operator, self.temps[left], self.temps[right], 'tmp')
        self.temps[target] = self.builder.zext(tmp, int_type, target)

    emit_CMPB = emit_CMPI

    # Logical ops
    def emit_AND(self, left, right, target):
        self.temps[target] = self.builder.and_(self.temps[left], self.temps[right], target)

    def emit_OR(self, left, right, target):
        self.temps[target] = self.builder.or_(self.temps[left], self.temps[right], target)

    def emit_XOR(self, left, right, target):
        self.temps[target] = self.builder.xor(self.temps[left], self.temps[right], target)

    def emit_LABEL(self, lbl_name):
        self.block = self.get_block(lbl_name)
        self.builder.position_at_end(self.block)

    def emit_BRANCH(self, dst_label):
        if not self.block.is_terminated:
            self.builder.branch(self.get_block(dst_label))

    def emit_CBRANCH(self, test_target, true_label, false_label):
        true_block = self.get_block(true_label)
        false_block = self.get_block(false_label)
        testvar = self.temps[test_target]
        self.builder.cbranch(self.builder.trunc(testvar, IntType(1)), true_block, false_block)

    def emit_RET(self, register):
        self.builder.store(self.temps[register], self.vars['return'])
        self.builder.branch(self.return_block)

    def emit_CALL(self, func_name, *registers):
        # print(self.globals)
        args = [self.temps[r] for r in registers[:-1]]
        target = registers[-1]
        self.temps[target] = self.builder.call(self.globals[func_name], args)


#######################################################################
#                      TESTING/MAIN PROGRAM
#######################################################################

def compile_llvm(source):
    from .ircode import compile_ircode

    # Make the low-level code generator
    generator = GenerateLLVM()

    # Compile intermediate code
    ir_functions = compile_ircode(source)
    for ir_func in ir_functions:
        # Generates LLVM low level code for a given IR-code Function
        generator.generate_code(ir_func)

    # Generate low-level code
    # generator.generate_code(code)
    return str(generator.module)

def main():
    import sys

    if len(sys.argv) != 2:
        sys.stderr.write("Usage: python3 -m gone.llvmgen filename\n")
        raise SystemExit(1)

    source = open(sys.argv[1]).read()
    llvm_code = compile_llvm(source)
    print(llvm_code)

if __name__ == '__main__':
    main()






