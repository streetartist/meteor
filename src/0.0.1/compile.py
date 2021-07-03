# gone/compile.py
#
# Project 5:
# ----------
# Compiles Gone code to a standalone executable using Clang.  This
# requires the clang compiler to be installed on your machine.  You
# might have to fiddle with some of the path settings and other details
# to make this work.
#
# Note: A minor change is required in Project 8.  See note in the code below.

import subprocess
import sys
import os.path
import tempfile

from .llvmgen import compile_llvm
from .errors import errors_reported

# Name of the runtime library
_rtlib = os.path.join(os.path.dirname(__file__), 'gonert.c')

# clang installation
CLANG = 'clang'

def main():
    if len(sys.argv) != 2:
        sys.stderr.write("Usage: python3 -m gone.compile filename\n")
        raise SystemExit(1)

    source = open(sys.argv[1]).read()
    llvm_code = compile_llvm(source)
    if not errors_reported():
        with tempfile.NamedTemporaryFile(suffix='.ll') as f:
            f.write(llvm_code.encode('utf-8'))
            f.flush()
            # Use this for Projects 5-7
            # subprocess.check_output([CLANG,  f.name, _rtlib])

            # Use this version when you get to Project 8
            subprocess.check_output([CLANG, '-DNEED_MAIN', f.name, _rtlib])

if __name__ == '__main__':
    main()
