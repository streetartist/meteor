# gone/ircode.py
'''
Project 4
=========
In this project, you are going to turn the AST into an intermediate
machine code based on 3-address code. There are a few important parts
you'll need to make this work.  Please read carefully before
beginning:

A "Virtual" Machine
===================
A CPU typically consists of registers and a small set of basic opcodes
for performing mathematical calculations, loading/storing values from
memory, and basic control flow (branches, jumps, etc.).  For example,
suppose you want to evaluate an operation like this:

    a = 2 + 3 * 4 - 5

On a CPU, it might be decomposed into low-level instructions like this:

    MOVI   #2, R1
    MOVI   #3, R2
    MOVI   #4, R3
    MULI   R2, R3, R4
    ADDI   R4, R1, R5
    MOVI   #5, R6
    SUBI   R5, R6, R7
    STOREI R7, "a"

Each instruction represents a single operation such as add, multiply, etc.
There are always two input operands and a destination.

CPUs also feature a small set of core datatypes such as integers,
bytes, and floats. There are dedicated instructions for each type.
For example:

    ADDI   R1, R2, R3        ; Integer add
    ADDF   R4, R5, R6        ; Float add

There is often a disconnect between the types used in the source
programming language and the generated IRCode.  For example, a target
machine might only have integers and floats.  To represent a value
such as a boolean, you have to represent it as one of the native types
such as an integer.   This is an implementation detail that users
won't worry about (they'll never see it, but you'll have to worry
about it in the compiler).

Here is an instruction set specification for our IRCode:

    MOVI   value, target       ;  Load a literal integer
    VARI   name                ;  Declare an integer variable
    ALLOCI name                ;  Allocate an integer variabe on the stack
    LOADI  name, target        ;  Load an integer from a variable
    STOREI target, name        ;  Store an integer into a variable
    ADDI   r1, r2, target      ;  target = r1 + r2
    SUBI   r1, r2, target      ;  target = r1 - r2
    MULI   r1, r2, target      ;  target = r1 * r2
    DIVI   r1, r2, target      ;  target = r1 / r2
    PRINTI source              ;  print source  (debugging)
    CMPI   op, r1, r2, target  ;  Compare r1 op r2 -> target
    AND    r1, r2, target      :  target = r1 & r2
    OR     r1, r2, target      :  target = r1 | r2
    XOR    r1, r2, target      :  target = r1 ^ r2
    ITOF   r1, target          ;  target = float(r1)

    MOVF   value, target       ;  Load a literal float
    VARF   name                ;  Declare a float variable
    ALLOCF name                ;  Allocate a float variable on the stack
    LOADF  name, target        ;  Load a float from a variable
    STOREF target, name        ;  Store a float into a variable
    ADDF   r1, r2, target      ;  target = r1 + r2
    SUBF   r1, r2, target      ;  target = r1 - r2
    MULF   r1, r2, target      ;  target = r1 * r2
    DIVF   r1, r2, target      ;  target = r1 / r2
    PRINTF source              ;  print source (debugging)
    CMPF   op, r1, r2, target  ;  r1 op r2 -> target
    FTOI   r1, target          ;  target = int(r1)

    MOVB   value, target       ; Load a literal byte
    VARB   name                ; Declare a byte variable
    ALLOCB name                ; Allocate a byte variable
    LOADB  name, target        ; Load a byte from a variable
    STOREB target, name        ; Store a byte into a variable
    PRINTB source              ; print source (debugging)
    BTOI   r1, target          ; Convert a byte to an integer
    ITOB   r2, target          ; Truncate an integer to a byte
    CMPB   op, r1, r2, target  ; r1 op r2 -> target

There are also some control flow instructions

    LABEL  name                  ; Declare a label
    BRANCH label                 ; Unconditionally branch to label
    CBRANCH test, label1, label2 ; Conditional branch to label1 or label2 depending on test being 0 or not
    CALL   name, arg0, arg1, ... argN, target    ; Call a function name(arg0, ... argn) -> target
    RET    r1                    ; Return a result from a function

Single Static Assignment
========================
On a real CPU, there are a limited number of CPU registers.
In our virtual memory, we're going to assume that the CPU
has an infinite number of registers available.  Moreover,
we'll assume that each register can only be assigned once.
This particular style is known as Static Single Assignment (SSA).
As you generate instructions, you'll keep a running counter
that increments each time you need a temporary variable.
The example in the previous section illustrates this.

Your Task
=========
Your task is as follows: Write a AST Visitor() class that takes a
program and flattens it to a single sequence of SSA code instructions
represented as tuples of the form

       (operation, operands, ..., destination)

Testing
=======
The files Tests/irtest0-5.g contain some input text along with
sample output. Work through each file to complete the project.
'''

from collections import ChainMap
from . import ast

IR_TYPE_MAPPING = {
    'int': 'I',
    'float': 'F',
    'char': 'B',
    'bool': 'I'
}

OP_CODES = ChainMap(
    {
        'mov': 'MOV',
        '+': 'ADD',
        '-': 'SUB',
        '*': 'MUL',
        '/': 'DIV',
        '&&': 'AND',
        '||': 'OR',
        'print': 'PRINT',
        'store': 'STORE',
        'var': 'VAR',
        'alloc': 'ALLOC', # Local allocation (inside functions)
        'load': 'LOAD',
        'label': 'LABEL',
        'cbranch': 'CBRANCH', # Conditional branch
        'branch': 'BRANCH', # Unconditional branch,
        'call': 'CALL',
        'ret': 'RET'
    },
    dict.fromkeys(['<', '>', '<=', '>=', '==', '!='], "CMP")
)

def get_op_code(operation, type_name=None):
    op_code = OP_CODES[operation]
    suffix = "" if not type_name else IR_TYPE_MAPPING[type_name]

    return f"{op_code}{suffix}"


class Function():
    """This represents a function with its list of IR instructions"""

    def __init__(self, func_name, parameters, return_type):
        self.name = func_name
        self.parameters = parameters
        self.return_type = return_type

        self.code = []

    def append(self, ir_instruction):
        self.code.append(ir_instruction)

    def __iter__(self):
        return self.code.__iter__()

    def __repr__(self):
        params = [f"{pname}:{ptype}" for pname, ptype in self.parameters]
        return f"{self.name}({params}) -> {self.return_type}"


class GenerateCode(ast.NodeVisitor):
    '''
    Node visitor class that creates 3-address encoded instruction sequences.
    '''
    def __init__(self):
        # counter for registers
        self.register_count = 0

        # counter for block labels
        self.label_count = 0

        # Special function to collect all global statements
        init_function = Function("__gone_init", [], IR_TYPE_MAPPING['int'])

        self.functions = [ init_function ]

        # The generated code (list of tuples)
        self.code = init_function.code

        # This flag indicates if the current code being visited is in global
        # scope, or not
        self.global_scope = True

    def new_register(self):
         '''
         Creates a new temporary register
         '''
         self.register_count += 1
         return f'R{self.register_count}'

    def new_label(self):
        self.label_count += 1
        return f"L{self.label_count}"

    # You must implement visit_Nodename methods for all of the other
    # AST nodes.  In your code, you will need to make instructions
    # and append them to the self.code list.
    #
    # A few sample methods follow.  You may have to adjust depending
    # on the names and structure of your AST nodes.

    def visit_IntegerLiteral(self, node):
        target = self.new_register()
        op_code = get_op_code('mov', 'int')
        self.code.append((op_code, node.value, target))
        # Save the name of the register where the value was placed
        node.register = target

    def visit_FloatLiteral(self, node):
        target = self.new_register()
        op_code = get_op_code('mov', 'float')
        self.code.append((op_code, node.value, target))
        node.register = target

    def visit_CharLiteral(self, node):
        target = self.new_register()
        op_code = get_op_code('mov', 'char')
        # We treat chars as their ascii value
        self.code.append((op_code, ord(node.value), target))
        # This is just to remember where the literal was put in
        node.register = target

    def visit_BoolLiteral(self, node):
        target = self.new_register()
        op_code = get_op_code('mov', 'bool')
        # We treat chars as their ascii value
        value = 1 if node.value == "true" else 0
        self.code.append((op_code, value, target))
        # This is just to remember where the literal was put in
        node.register = target

    def visit_BinOp(self, node):
        self.visit(node.left)
        self.visit(node.right)
        operator = node.op

        op_code = get_op_code(operator, node.left.type.name)

        target = self.new_register()
        if op_code.startswith('CMP'):
            inst = (op_code, operator, node.left.register, node.right.register, target)
        else:
            inst = (op_code, node.left.register, node.right.register, target)

        self.code.append(inst)
        node.register = target

    def visit_UnaryOp(self, node):
        self.visit(node.right)
        operator = node.op

        if operator == "-":
            sub_op_code = get_op_code(operator, node.type.name)
            mov_op_code = get_op_code('mov', node.type.name)

            # To account for the fact that the machine code does not support
            # unary operations, we must load a 0 into a new register first
            zero_target = self.new_register()
            zero_inst = (mov_op_code, 0, zero_target)
            self.code.append(zero_inst)

            target = self.new_register()
            inst = (sub_op_code, zero_target, node.right.register, target)
            self.code.append(inst)
            node.register = target
        elif operator == "!":
            # This is the boolean NOT operator
            mov_op_code = get_op_code('mov', node.type.name)
            one_target = self.new_register()
            one_inst = (mov_op_code, 1, one_target)
            self.code.append(one_inst)

            target = self.new_register()
            inst = ('XOR', one_target, node.right.register, target)
            self.code.append(inst)
            node.register = target
        else:
            # The plus unary operator produces no extra code
            node.register = node.right.register

    # CHALLENGE:  Figure out some more sane way to refactor the above code

    def visit_PrintStatement(self, node):
        self.visit(node.value)
        op_code = get_op_code('print', node.value.type.name)
        inst = (op_code, node.value.register)
        self.code.append(inst)

    def visit_ReadLocation(self, node):
        op_code = get_op_code('load', node.location.type.name)
        register = self.new_register()
        inst = (op_code, node.location.name, register)
        self.code.append(inst)
        node.register = register

    def visit_WriteLocation(self, node):
        self.visit(node.value)
        op_code = get_op_code('store', node.location.type.name)
        inst = (op_code, node.value.register, node.location.name)
        self.code.append(inst)

    def visit_ConstDeclaration(self, node):
        self.visit(node.value)

        # First we must declare the variable
        op_code = get_op_code('var', node.type.name)
        inst = (op_code, node.name)
        self.code.append(inst)

        op_code = get_op_code('store', node.type.name)
        inst = (op_code, node.value.register, node.name)
        self.code.append(inst)

    def visit_VarDeclaration(self, node):
        self.visit(node.datatype)

        # The variable declaration depends on the scope
        op_code = get_op_code('var' if self.global_scope else 'alloc', node.type.name)
        def_inst = (op_code, node.name)

        if node.value:
            self.visit(node.value)
            self.code.append(def_inst)
            op_code = get_op_code('store', node.type.name)
            inst = (op_code, node.value.register, node.name)
            self.code.append(inst)
        else:
            self.code.append(def_inst)

    def visit_IfStatement(self, node):
        self.visit(node.condition)

        # Generate labels for both branches
        f_label = self.new_label()
        t_label = self.new_label()
        merge_label = self.new_label()
        lbl_op_code = get_op_code('label')

        # Insert the CBRANCH instruction
        cbranch_op_code = get_op_code('cbranch')
        self.code.append((cbranch_op_code, node.condition.register, t_label, f_label))

        # Now, the code for the true branch
        self.code.append((lbl_op_code, t_label))
        self.visit(node.true_block)
        # And we must go to the merge label
        branch_op_code = get_op_code('branch')
        self.code.append((branch_op_code, merge_label))

        # Generate label for false block
        self.code.append((lbl_op_code, f_label))
        self.visit(node.false_block)
        self.code.append((branch_op_code, merge_label))

        # Now we insert the merge label
        self.code.append((lbl_op_code, merge_label))

    def visit_WhileStatement(self, node):
        # Generate labels for while handling
        top_label = self.new_label() # This label is before the condition evaluation
        start_label = self.new_label() # This label is just after the condition
        merge_label = self.new_label() # This label is for exiting the loop
        lbl_op_code = get_op_code('label')
        branch_op_code = get_op_code('branch')

        # Insert the CBRANCH instruction
        # This is required because LLVM requires that each block ends with a
        # BRANCH
        self.code.append((branch_op_code, top_label))
        # Now begins the block with the CBRANCH
        self.code.append((lbl_op_code, top_label))
        self.visit(node.condition) # Generate the CMP instruction
        cbranch_op_code = get_op_code('cbranch')
        self.code.append((cbranch_op_code, node.condition.register, start_label, merge_label))

        # Now, the code for the true branch
        self.code.append((lbl_op_code, start_label))
        self.visit(node.body)
        # And we must go to the merge label

        self.code.append((branch_op_code, top_label))

        # Now we insert the merge label
        self.code.append((lbl_op_code, merge_label))

    def visit_FuncDeclaration(self, node):
        # Generate a new function object to collect the code
        func = Function(node.name,
                        [(p.name, IR_TYPE_MAPPING[p.datatype.type.name])
                         for p in node.params],
                        IR_TYPE_MAPPING[node.datatype.type.name])
        self.functions.append(func)

        if func.name == "main":
            func.name = "__gone_main"

        # And switch the current function to the new one
        old_code = self.code
        self.code = func.code

        # Now, generate the new function code
        self.global_scope = False # Turn off global scope
        self.visit(node.body)
        self.global_scope = True # Turn back on global scope

        # And, finally, switch back to the original function we were at
        self.code = old_code

    def visit_FuncCall(self, node):
        self.visit(node.arguments)
        target = self.new_register()
        op_code = get_op_code('call')
        registers = [arg.register for arg in node.arguments]
        self.code.append((op_code, node.name, *registers, target))
        node.register = target

    def visit_ReturnStatement(self, node):
        self.visit(node.value)
        op_code = get_op_code('ret')
        self.code.append((op_code, node.value.register))
        node.register = node.value.register

# ----------------------------------------------------------------------
#                          TESTING/MAIN PROGRAM
#
# Note: Some changes will be required in later projects.
# ----------------------------------------------------------------------

def compile_ircode(source):
    '''
    Generate intermediate code from source.
    '''
    from .parser import parse
    from .checker import check_program
    from .errors import errors_reported

    ast = parse(source)
    check_program(ast)

    # If no errors occurred, generate code
    if not errors_reported():
        gen = GenerateCode()
        gen.visit(ast)
        return gen.functions
    else:
        return []

def main():
    import sys

    if len(sys.argv) != 2:
        sys.stderr.write("Usage: python3 -m gone.ircode filename\n")
        raise SystemExit(1)

    source = open(sys.argv[1]).read()
    code = compile_ircode(source)

    for f in code :
        print(f'{"::"*5} {f} {"::"*5}')
        for instruction in f.code:
            print(instruction)
        print("*"*30)

if __name__ == '__main__':
    main()
