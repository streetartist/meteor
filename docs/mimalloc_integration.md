# Mimalloc Integration Guide

## Overview

This document records the experience of integrating mimalloc (Microsoft's high-performance memory allocator) into the Meteor compiler.

## Key Findings

### Windows Integration Methods

Mimalloc provides two integration approaches on Windows:

1. **Dynamic Override (DLL mode)** - Recommended
   - Uses `mimalloc.dll` + `mimalloc.dll.lib`
   - Requires `mimalloc-redirect.dll` in the same directory
   - Auto-initializes via `DllMain`

2. **Static Override**
   - Uses `mimalloc.lib` static library
   - Requires TLS callbacks for initialization
   - May not work correctly with clang-compiled LLVM IR

### Critical Requirements

1. **DLL Initialization**: Call `mi_version()` to ensure the DLL is loaded
2. **Redirect DLL**: `mimalloc-redirect.dll` must be alongside `mimalloc.dll`
3. **No Mixing**: Never mix `malloc`/`free` with `mi_malloc`/`mi_free`

## Implementation

### Compile Mode

Modified `code_generator.py` to:

1. Link with `mimalloc.dll.lib` instead of static library
2. Copy DLLs to output directory
3. Call `mi_version()` at program start

```python
# code_generator.py - compile method
mimalloc_dir = 'D:/Project/mimalloc/out/shared/Release'
mimalloc_lib = f'{mimalloc_dir}/mimalloc.dll.lib'
if os.path.exists(mimalloc_lib):
    cmd = ['clang', f'{output}.ll', '-O3', '-o', output, mimalloc_lib]
    # Copy DLLs to output directory
    for dll in ['mimalloc.dll', 'mimalloc-redirect.dll']:
        shutil.copy2(f'{mimalloc_dir}/{dll}', output_dir)
```

### JIT Mode

JIT mode uses system malloc but needs `mi_version` symbol:

```python
# code_generator.py - evaluate method
def dummy_mi_version():
    return 0
MI_VERSION_FUNC = ctypes.CFUNCTYPE(ctypes.c_int)
mi_version_callback = MI_VERSION_FUNC(dummy_mi_version)
self._mi_version_callback = mi_version_callback
llvm.add_symbol('mi_version', ctypes.cast(mi_version_callback, ctypes.c_void_p).value)
```

### Builtins Declaration

Added `mi_version` declaration in `builtins.py`:

```python
mi_version_type = ir.FunctionType(type_map[INT32], [])
ir.Function(self.module, mi_version_type, 'mi_version')
```

## Troubleshooting

### Segmentation Fault with Static Library

**Problem**: Using `mimalloc.lib` (static) causes segfaults.

**Cause**: Static library uses TLS callbacks (`.CRT$XLB` section) for initialization, which may not trigger correctly when linking clang-compiled LLVM IR.

**Solution**: Use DLL mode (`mimalloc.dll.lib`) instead.

### JIT Mode Crashes

**Problem**: JIT mode crashes when `mi_version` is called.

**Cause**: Symbol not resolved in JIT execution engine.

**Solution**: Provide a dummy `mi_version` callback via `llvm.add_symbol()`.

### Mixing Allocators

**Problem**: Memory corruption or segfaults.

**Cause**: Memory allocated with `mi_malloc` freed with `free` (or vice versa).

**Solution**: Use transparent replacement (DLL mode) where all `malloc`/`free` calls are redirected to mimalloc.

## File Changes

| File | Changes |
|------|---------|
| `builtins.py:87-89` | Declare `mi_version` function |
| `code_generator.py:40-43` | Call `mi_version()` at main entry |
| `code_generator.py:2831-2844` | Link mimalloc DLL, copy DLLs |
| `code_generator.py:2806-2813` | JIT dummy `mi_version` symbol |

## References

- [mimalloc GitHub](https://github.com/microsoft/mimalloc)
- mimalloc readme: Windows override section
- mimalloc source: `src/prim/windows/prim.c` for initialization details
