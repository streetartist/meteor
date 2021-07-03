# gone/checker.py
'''
*** Do not start this project until you have fully completed Exercise 3. ***

Overview
--------
In this project you need to perform semantic checks on your program.
This problem is multifaceted and complicated.  To make it somewhat
less brain exploding, you need to take it slow and in small parts.
The basic gist of what you need to do is as follows:

1.  Names and symbols:

    All identifiers must be defined before they are used.  This
    includes variables, constants, and typenames.  For example, this
    kind of code generates an error:

       a = 3;              // Error. 'a' not defined.
       var a int;

2.  Types of literals and constants

    All literal symbols are implicitly typed and must be assigned a
    type of "int", "float", or "char".  This type is used to set
    the type of constants.  For example:

       const a = 42;         // Type "int"
       const b = 4.2;        // Type "float"
       const c = 'a';        // Type "char""

3.  Operator type checking

    Binary operators only operate on operands of a compatible type.
    Otherwise, you get a type error.  For example:

        var a int = 2;
        var b float = 3.14;

        var c int = a + 3;    // OK
        var d int = a + b;    // Error.  int + float
        var e int = b + 4.5;  // Error.  int = float

    In addition, you need to make sure that only supported
    operators are allowed.  For example:

        var a char = 'a';        // OK
        var b char = 'a' + 'b';  // Error (unsupported op +)

4.  Assignment.

    The left and right hand sides of an assignment operation must be
    declared as the same type.

        var a int;
        a = 4 + 5;     // OK
        a = 4.5;       // Error. int = float

    Values can only be assigned to variable declarations, not
    to constants.

        var a int;
        const b = 42;

        a = 37;        // OK
        b = 37;        // Error. b is const

Implementation Strategy:
------------------------
You're going to use the NodeVisitor class defined in gone/ast.py to
walk the parse tree.   You will be defining various methods for
different AST node types.  For example, if you have a node BinOp,
you'll write a method like this:

      def visit_BinOp(self, node):
          ...

To start, make each method simply print out a message:

      def visit_BinOp(self, node):
          print('visit_BinOp:', node)
          self.visit(node.left)
          self.visit(node.right)

This will at least tell you that the method is firing.  Try some
simple code examples and make sure that all of your methods
are actually running when you walk the parse tree.

Testing
-------
The files Tests/checktest0-7.g contain different things you need
to check for.  Specific instructions are given in each test file.

General thoughts and tips
-------------------------
The main thing you need to be thinking about with checking is program
correctness.  Does this statement or operation that you're looking at
in the parse tree make sense?  If not, some kind of error needs to be
generated.  Use your own experiences as a programmer as a guide (think
about what would cause an error in your favorite programming
language).

One challenge is going to be the management of many fiddly details.
You've got to track symbols, types, and different sorts of capabilities.
It's not always clear how to best organize all of that.  So, expect to
fumble around a bit at first.
'''

from collections import ChainMap
from .errors import error
from .ast import *
from .typesys import Type, FloatType, IntType, CharType, BoolType

class CheckProgramVisitor(NodeVisitor):
    '''
    Program checking class.   This class uses the visitor pattern as described
    in ast.py.   You need to define methods of the form visit_NodeName()
    for each kind of AST node that you want to process.  You may need to
    adjust the method names here if you've picked different AST node names.
    '''
    def __init__(self):
        # Initialize the symbol table
        self.symbols = { }

        # Temporal symbols table to save the global symbols when checking
        # a function definition
        self.temp_symbols = { }

        # Here we save the expected return type when checking a function
        self.expected_ret_type = None

        # And here we save the observed return type when checking a function
        # Since a function may have more than one return point, we save a set
        # of types
        self.current_ret_type = set()

        # A table of function definitions
        self.functions = { }

        # Put the builtin type names in the symbol table
        # self.symbols.update(builtin_types)
        self.keywords = {t.name for t in Type.__subclasses__()}

    def visit_VarDeclaration(self, node):
        # Here we must update the symbols table with the new symbol
        node.type = None

        # Before anything, if we are declaring a variable with a name that is
        # a typename, then we must fail
        if node.name in self.keywords:
            error(node.lineno, f"Name '{node.name}' is not a legal name for variable declaration")
            return

        if node.name not in self.symbols:
            # First check that the datatype node is correct
            self.visit(node.datatype)

            if node.datatype.type:
                # Before finishing, this var declaration may have an expression
                # to initialize it. If so, we must visit the node, and check
                # type errors
                if node.value:
                    self.visit(node.value)

                    if node.value.type: # If value has no type, then there was a previous error
                        if node.value.type == node.datatype.type:
                            # Great, the value type matches the variable type
                            # declaration
                            node.type = node.datatype.type
                            self.symbols[node.name] = node
                        else:
                            error(node.lineno,
                                  f"Declaring variable '{node.name}' of type '{node.datatype.type.name}' but assigned expression of type '{node.value.type.name}'")
                else:
                    # There is no initialization, so we have everything needed
                    # to save it into our symbols table
                    node.type = node.datatype.type
                    self.symbols[node.name] = node
            else:
                error(node.lineno, f"Unknown type '{node.datatype.name}'")
        else:
            prev_lineno = self.symbols[node.name].lineno
            error(node.lineno, f"Name '{node.name}' has already been defined at line {prev_lineno}")

    def visit_ConstDeclaration(self, node):
        # For a declaration, you'll need to check that it isn't already defined.
        # You'll put the declaration into the symbol table so that it can be looked up later
        if node.name not in self.symbols:
            # First visit value node to extract its type
            self.visit(node.value)
            node.type = node.value.type
            self.symbols[node.name] = node
        else:
            prev_lineno = self.symbols[node.name].lineno
            error(node.lineno, f"Name '{node.name}' has already been defined at line {prev_lineno}")

    def visit_IntegerLiteral(self, node):
        # For literals, you'll need to assign a type to the node and allow it to
        # propagate.  This type will work it's way through various operators
        node.type = IntType

    def visit_FloatLiteral(self, node):
        node.type = FloatType

    def visit_CharLiteral(self, node):
        node.type = CharType

    def visit_BoolLiteral(self, node):
        node.type = BoolType

    def visit_PrintStatement(self, node):
        self.visit(node.value)

    def visit_IfStatement(self, node):
        self.visit(node.condition)

        cond_type = node.condition.type
        if cond_type:
            if issubclass(node.condition.type, BoolType):
                self.visit(node.true_block)
                self.visit(node.false_block)
            else:
                error(node.lineno, f"'Condition must be of type 'bool' but got type '{cond_type.name}'")

    def visit_WhileStatement(self, node):
        self.visit(node.condition)

        cond_type = node.condition.type
        if cond_type:
            if issubclass(node.condition.type, BoolType):
                self.visit(node.body)
            else:
                error(node.lineno, f"'Condition must be of type 'bool' but got type '{cond_type.name}'")

    def visit_BinOp(self, node):
        # For operators, you need to visit each operand separately.  You'll
        # then need to make sure the types and operator are all compatible.
        self.visit(node.left)
        self.visit(node.right)

        node.type = None
        # Perform various checks here
        if node.left.type and node.right.type:
            op_type = node.left.type.binop_type(node.op, node.right.type)
            if not op_type:
                left_tname = node.left.type.name
                right_tname = node.right.type.name
                error(node.lineno, f"Binary operation '{left_tname} {node.op} {right_tname}' not supported")

            node.type = op_type

    def visit_UnaryOp(self, node):
        # Check and propagate the type of the only operand
        self.visit(node.right)

        node.type = None
        if node.right.type:
            op_type = node.right.type.unaryop_type(node.op)
            if not op_type:
                right_tname = node.right.type.name
                error(node.lineno, f"Unary operation '{node.op} {right_tname}' not supported")

            node.type = op_type

    def visit_WriteLocation(self, node):
        # First visit the location definition to check that it is a valid
        # location
        self.visit(node.location)
        # Visit the value, to also get type information
        self.visit(node.value)

        node.type = None
        if node.location.type and node.value.type:
            loc_name = node.location.name

            if isinstance(self.symbols[loc_name], ConstDeclaration):
                # Basically, if we are writting a to a location that was
                # declared as a constant, then this is an error
                error(node.lineno, f"Cannot write to constant '{loc_name}'")
                return

            # If both have type information, then the type checking worked on
            # both branches
            if node.location.type == node.value.type:
                # Propagate the type
                node.type = node.value.type
            else:
                error(node.lineno,
                      f"Cannot assign type '{node.value.type.name}' to variable '{node.location.name}' of type '{node.location.type.name}'")

    def visit_ReadLocation(self, node):
        # Associate a type name such as "int" with a Type object
        self.visit(node.location)
        node.type = node.location.type

    def visit_SimpleLocation(self, node):
        if node.name not in self.symbols:
            node.type = None
            error(node.lineno, f"Name '{node.name}' was not defined")
        else:
            node.type = self.symbols[node.name].type

    def visit_SimpleType(self, node):
        # Associate a type name such as "int" with a Type object
        node.type = Type.get_by_name(node.name)
        if node.type is None:
            error(node.lineno, f"Invalid type '{node.name}'")

    def visit_FuncParameter(self, node):
        self.visit(node.datatype)
        node.type = node.datatype.type

    def visit_ReturnStatement(self, node):
        self.visit(node.value)
        # Propagate return value type as a special property ret_type, only
        # to be checked at function declaration checking
        if self.expected_ret_type:
            self.current_ret_type.add(node.value.type)
            if node.value.type and node.value.type != self.expected_ret_type:
                error(node.lineno, f"Function returns '{self.expected_ret_type.name}' but return statement value is of type '{node.value.type.name}'")
        else:
            error(node.lineno, "Return statement must be within a function")

    def visit_FuncDeclaration(self, node):
        if node.name in self.functions:
            prev_def = self.functions[node.name].lineno
            error(node.lineno, f"Function '{node.name}' already defined at line {prev_def}")

        self.visit(node.params)

        param_types_ok = all((param.type is not None for param in node.params))
        param_names = [param.name for param in node.params]
        param_names_ok = len(param_names) == len(set(param_names))
        if not param_names_ok:
            error(node.lineno, "Duplicate parameter names at function definition")

        self.visit(node.datatype)
        ret_type_ok = node.datatype.type is not None

        # Before visiting the function, body, we must change the symbol table
        # to a new one
        if self.temp_symbols:
            error(node.lineno, f"Illegal nested function declaration '{node.name}'")
        else:
            self.temp_symbols = self.symbols
            self.symbols = ChainMap(
                {param.name: param for param in node.params},
                self.temp_symbols
            )

            # Add the function to the available functions so recursive calls work
            self.functions[node.name] = node

            # Set the expected return value to observe
            self.expected_ret_type = node.datatype.type

            self.visit(node.body)

            if not self.current_ret_type:
                error(node.lineno, f"Function '{node.name}' has no return statement")
            elif self.current_ret_type != {self.expected_ret_type}:
                wrong_types = ", ".join(map(str, self.current_ret_type - {self.expected_ret_type}))
                error(node.lineno,
                      f"Function '{node.name}' returns more types than expected!")

            self.symbols = self.temp_symbols
            self.temp_symbols = { }
            self.expected_ret_type = None
            self.current_ret_type = set()

    def visit_FuncCall(self, node):
        if node.name not in self.functions:
            error(node.lineno, f"Function '{node.name}' is not declared")
        else:
            # We must check that the argument list matches the function
            # parameters definition
            self.visit(node.arguments)

            arg_types = tuple([arg.type.name for arg in node.arguments])
            func = self.functions[node.name]
            expected_types = tuple([param.type.name for param in func.params])
            if arg_types != expected_types:
                error(node.lineno, f"Function '{node.name}' expects {expected_types}, but was called with {arg_types}")

            # The type of the function call is the return type of the function
            node.type = func.datatype.type

# ----------------------------------------------------------------------
#                       DO NOT MODIFY ANYTHING BELOW
# ----------------------------------------------------------------------

def check_program(ast):
    '''
    Check the supplied program (in the form of an AST)
    '''
    checker = CheckProgramVisitor()
    checker.visit(ast)

def main():
    '''
    Main program. Used for testing
    '''
    import sys
    from .parser import parse

    if len(sys.argv) < 2:
        sys.stderr.write('Usage: python3 -m gone.checker filename\n')
        raise SystemExit(1)

    ast = parse(open(sys.argv[1]).read())
    check_program(ast)
    if '--show-types' in sys.argv:
        for depth, node in flatten(ast):
            print('%s: %s%s type: %s' % (getattr(node, 'lineno', None), ' '*(4*depth), node,
                                         getattr(node, 'type', None)))

if __name__ == '__main__':
    main()
