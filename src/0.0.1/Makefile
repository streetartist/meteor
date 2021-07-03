# Makefile for creating a shared-library version of the Gone runtime.
# This is used if you're going to run Gone programs as a JIT. 
# See the file gone/run.py

osx::
	gcc -bundle -undefined dynamic_lookup gonert.c -o gonert.so

linux::
	gcc -shared -fPIC gonert.c -o gonert.so

# Prerequisite: cl.exe on path configured for x64, run "vcvarsall.bat x64".

win::
	cl /LD gonert.c /link /out:gonert.dll
