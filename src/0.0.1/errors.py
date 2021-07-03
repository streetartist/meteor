# gone/errors.py
'''
Compiler error handling support.

One of the most important (and annoying) parts of writing a compiler
is reliable reporting of error messages back to the user.  This file
defines some generic functionality for dealing with errors throughout
the compiler project.  You might want to expand this with additional
capabilities for the purposes of unit testing.

To report errors in your compiler, use the error() function. For example:

       error(lineno, 'Some kind of compiler error message')

where lineno is the line number on which the error occurred.   If your
compiler supports multiple source files, add the filename keyword argument.

       error(lineno, 'Some kind of error message', filename='foo.src')

The utility function errors_reported() returns the total number of
errors reported so far.  Different stages of the compiler might use
this to decide whether or not to keep processing or not.

Use clear_errors() to clear the total number of errors.
'''

import sys

_num_errors = 0

def error(lineno, message, filename=None):
    '''
    Report a compiler error to all subscribers
    '''
    global _num_errors
    if not filename:
        errmsg = "{}: {}".format(lineno, message)
    else:
        errmsg = "{}:{}: {}".format(filename,lineno,message)

    print(errmsg, file=sys.stderr)
    _num_errors += 1

def errors_reported():
    '''
    Return number of errors reported
    '''
    return _num_errors

def clear_errors():
    '''
    Clear the total number of errors reported.
    '''
    global _num_errors
    _num_errors = 0
