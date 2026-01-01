from llvmlite import ir

import meteor.compiler.llvmlite_custom
from meteor.compiler.base import type_map
from meteor.grammar import *

ARRAY_INITIAL_CAPACITY = ir.Constant(type_map[INT], 16)

zero = ir.Constant(type_map[INT], 0)
one = ir.Constant(type_map[INT], 1)
two = ir.Constant(type_map[INT], 2)
eight = ir.Constant(type_map[INT], 8)
ten = ir.Constant(type_map[INT], 10)
zero_32 = ir.Constant(type_map[INT32], 0)
one_32 = ir.Constant(type_map[INT32], 1)
two_32 = ir.Constant(type_map[INT32], 2)

# BigInt field indices (after adding header)
BIGINT_HEADER = ir.Constant(type_map[INT32], 0)
BIGINT_SIGN = ir.Constant(type_map[INT32], 1)
BIGINT_DIGITS = ir.Constant(type_map[INT32], 2)

# Decimal field indices (after adding header)
DECIMAL_HEADER = ir.Constant(type_map[INT32], 0)
DECIMAL_MANTISSA = ir.Constant(type_map[INT32], 1)
DECIMAL_EXPONENT = ir.Constant(type_map[INT32], 2)

# Dynamic array field indices (after adding header)
ARRAY_HEADER = ir.Constant(type_map[INT32], 0)
ARRAY_SIZE = ir.Constant(type_map[INT32], 1)
ARRAY_CAPACITY = ir.Constant(type_map[INT32], 2)
ARRAY_DATA = ir.Constant(type_map[INT32], 3)

array_types = [type_map[INT]]


def define_builtins(self):
    # Dynamic array with object header for RC
    # Layout: { header, size, capacity, data* }
    # 0: meteor.header (for RC)
    # 1: int size
    # 2: int capacity
    # 3: int *data
    from meteor.compiler.base import OBJECT_HEADER

    # First define object header (needed for array)
    define_object_header(self)
    header_struct = self.search_scopes(OBJECT_HEADER)

    str_struct = self.module.context.get_identified_type('i64.array')
    str_struct.name = 'i64.array'
    str_struct.type = CLASS
    str_struct.set_body(header_struct, type_map[INT], type_map[INT], type_map[INT].as_pointer())

    self.define('str', str_struct)
    self.define('i64.array', str_struct)
    str_struct_ptr = str_struct.as_pointer()
    self.define('str_ptr', str_struct_ptr)
    type_map[STR] = str_struct
    
    define_new_types(self)

    lint = type_map[INT]

    dynamic_array_init(self, str_struct_ptr, lint)
    dynamic_array_double_if_full(self, str_struct_ptr, lint)
    dynamic_array_append(self, str_struct_ptr, lint)
    dynamic_array_get(self, str_struct_ptr, lint)
    dynamic_array_set(self, str_struct_ptr, lint)
    dynamic_array_length(self, str_struct_ptr, lint)

    define_create_range(self, str_struct_ptr, lint)

    define_int_to_str(self, str_struct_ptr)
    define_bool_to_str(self, str_struct_ptr)
    define_print(self, str_struct_ptr)
    
    # New Types Printing
    define_print_bigint(self)
    define_print_decimal(self)
    define_print_number(self)
    define_print_dynamic(self)
    
    # Memory Management
    define_free_bigint(self)

    # Declare mi_version for mimalloc DLL initialization
    mi_version_type = ir.FunctionType(type_map[INT32], [])
    ir.Function(self.module, mi_version_type, 'mi_version')

    # RFC-001 Memory Management Runtime
    # Note: define_object_header already called above for array structure
    define_mutex_type(self)     # Mutex for synchronization
    define_channel_type(self)  # Channel for concurrency
    define_spawn_runtime(self)  # Thread spawning
    define_join_runtime(self)   # Thread join
    define_atomic_ops(self)     # Atomic operations
    define_mutex_ops(self)      # Mutex operations
    define_channel_create(self)  # Channel creation
    define_channel_send(self)   # Channel send
    define_channel_recv(self)   # Channel recv (blocking)
    define_channel_try_recv(self)  # Channel try_recv (non-blocking)
    define_meteor_destroy(self)  # Must be before retain/release
    define_meteor_retain(self)
    define_meteor_release(self)
    define_meteor_weak_retain(self)
    define_meteor_weak_release(self)
    define_meteor_weak_upgrade(self)
    define_meteor_alloc(self)
    define_meteor_freeze(self)

    # Arithmetic
    define_bigint_add(self)
    define_bigint_neg(self)
    define_bigint_cmp(self)
    define_bigint_sub(self)
    define_bigint_mul_naive(self)  # O(n^2) base case
    define_bigint_split_low(self)   # Helper for Karatsuba
    define_bigint_split_high(self)  # Helper for Karatsuba
    define_bigint_shift_left(self)  # Helper for Karatsuba
    define_bigint_mul(self)         # Karatsuba multiplication
    define_bigint_div(self)
    define_bigint_mod(self)


    # Decimal Arithmetic
    define_decimal_add(self)
    define_decimal_sub(self)
    define_decimal_mul(self)
    define_decimal_neg(self)

    # Number conversions
    define_number_to_decimal(self)

    # Input
    define_input(self)

    # String to number conversion
    define_number_func(self)


def _normalize_type_name(array_type):
    """Normalize type name for class types (e.g., '%"Header"' -> 'Header')"""
    type_str = str(array_type)
    # Strip pointer symbols to get the underlying type name
    while type_str.endswith('*'):
        type_str = type_str[:-1].strip()
    if type_str.startswith('%"') and type_str.endswith('"'):
        return type_str[2:-1]
    elif type_str.startswith('%'):
        return type_str[1:]
    return type_str


def create_dynamic_array_methods(self, array_type):
    if array_type in array_types:
        return
    type_name = _normalize_type_name(array_type)
    array = self.search_scopes('{}.array'.format(type_name))
    array_ptr = array.as_pointer()

    current_block = self.builder.block

    dynamic_array_init(self, array_ptr, array_type)
    dynamic_array_double_if_full(self, array_ptr, array_type)
    dynamic_array_append(self, array_ptr, array_type)
    dynamic_array_get(self, array_ptr, array_type)
    dynamic_array_set(self, array_ptr, array_type)
    dynamic_array_length(self, array_ptr, array_type)
    dynamic_array_destroy(self, array_ptr, array_type, type_name)

    array_types.append(array_type)

    self.position_at_end(current_block)


def define_create_range(self, dyn_array_ptr, array_type):
    create_range_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr, type_map[INT], type_map[INT]])
    create_range = ir.Function(self.module, create_range_type, '@create_range')
    create_range_entry = create_range.append_basic_block('entry')
    builder = ir.IRBuilder(create_range_entry)
    self.builder = builder
    create_range_test = create_range.append_basic_block('test')
    create_range_body = create_range.append_basic_block('body')
    create_range_exit = create_range.append_basic_block('exit')

    builder.position_at_end(create_range_entry)
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(create_range.args[0], array_ptr)
    start_ptr = builder.alloca(type_map[INT])
    builder.store(create_range.args[1], start_ptr)
    stop_ptr = builder.alloca(type_map[INT])
    builder.store(create_range.args[2], stop_ptr)

    num_ptr = builder.alloca(type_map[INT])
    builder.store(builder.load(start_ptr), num_ptr)
    builder.branch(create_range_test)

    builder.position_at_end(create_range_test)
    cond = builder.icmp_signed(LESS_THAN, builder.load(num_ptr), builder.load(stop_ptr))
    builder.cbranch(cond, create_range_body, create_range_exit)

    builder.position_at_end(create_range_body)
    builder.call(self.module.get_global('{}.array.append'.format(_normalize_type_name(array_type))), [builder.load(array_ptr), builder.load(num_ptr)])
    builder.store(builder.add(one, builder.load(num_ptr)), num_ptr)

    builder.branch(create_range_test)

    builder.position_at_end(create_range_exit)
    builder.ret_void()


def dynamic_array_init(self, dyn_array_ptr, array_type):
    # START
    type_name = _normalize_type_name(array_type)
    dyn_array_init_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr])
    dyn_array_init = ir.Function(self.module, dyn_array_init_type, '{}.array.init'.format(type_name))
    dyn_array_init.args[0].name = 'self'
    dyn_array_init_entry = dyn_array_init.append_basic_block('entry')
    builder = ir.IRBuilder(dyn_array_init_entry)
    self.builder = builder
    dyn_array_init_exit = dyn_array_init.append_basic_block('exit')
    builder.position_at_end(dyn_array_init_entry)
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(dyn_array_init.args[0], array_ptr)

    # BODY
    size_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_SIZE], inbounds=True)
    builder.store(zero, size_ptr)

    capacity_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_CAPACITY], inbounds=True)
    builder.store(ARRAY_INITIAL_CAPACITY, capacity_ptr)

    data_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_DATA], inbounds=True)
    # For 1-based indexing, we need (capacity + 1) elements: data[0] is unused, data[1] to data[capacity] are used
    capacity_plus_one = builder.add(builder.load(capacity_ptr), one)
    size_of = builder.mul(capacity_plus_one, eight)
    mem_alloc = builder.call(self.module.get_global('malloc'), [size_of])
    mem_alloc = builder.bitcast(mem_alloc, array_type.as_pointer())
    builder.store(mem_alloc, data_ptr)

    # Initialize header strong_rc to 1 and type_tag
    from meteor.compiler.base import HEADER_STRONG_RC, HEADER_TYPE_TAG, TYPE_TAG_STR, TYPE_TAG_LIST
    header_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_HEADER], inbounds=True)
    rc_ptr = builder.gep(header_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)], inbounds=True)
    builder.store(ir.Constant(type_map[UINT32], 1), rc_ptr)

    # Set type_tag: TYPE_TAG_STR for i64.array (strings), TYPE_TAG_LIST for other arrays
    type_tag_ptr = builder.gep(header_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_TYPE_TAG)], inbounds=True)
    # Check if this is a string array (i64.array) or other array type
    if type_name == 'i64':
        builder.store(ir.Constant(type_map[UINT8], TYPE_TAG_STR), type_tag_ptr)
    else:
        builder.store(ir.Constant(type_map[UINT8], TYPE_TAG_LIST), type_tag_ptr)

    builder.branch(dyn_array_init_exit)

    # CLOSE
    builder.position_at_end(dyn_array_init_exit)
    builder.ret_void()


def dynamic_array_double_if_full(self, dyn_array_ptr, array_type):
    # START
    dyn_array_double_capacity_if_full_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr])
    dyn_array_double_capacity_if_full = ir.Function(self.module, dyn_array_double_capacity_if_full_type, '{}.array.double_capacity_if_full'.format(_normalize_type_name(array_type)))
    dyn_array_double_capacity_if_full.args[0].name = 'self'
    dyn_array_double_capacity_if_full_entry = dyn_array_double_capacity_if_full.append_basic_block('entry')
    builder = ir.IRBuilder(dyn_array_double_capacity_if_full_entry)
    self.builder = builder
    dyn_array_double_capacity_if_full_exit = dyn_array_double_capacity_if_full.append_basic_block('exit')
    dyn_array_double_capacity_block = dyn_array_double_capacity_if_full.append_basic_block('double_capacity')
    builder.position_at_end(dyn_array_double_capacity_if_full_entry)
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(dyn_array_double_capacity_if_full.args[0], array_ptr)

    # BODY
    size_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_SIZE], inbounds=True)
    size_val = builder.load(size_ptr)

    capacity_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_CAPACITY], inbounds=True)
    capacity_val = builder.load(capacity_ptr)

    data_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_DATA], inbounds=True)

    compare_size_to_capactiy = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, size_val, capacity_val)

    builder.cbranch(compare_size_to_capactiy, dyn_array_double_capacity_block, dyn_array_double_capacity_if_full_exit)

    builder.position_at_end(dyn_array_double_capacity_block)

    capacity_val = builder.mul(capacity_val, two)
    builder.store(capacity_val, capacity_ptr)
    capacity_val = builder.load(capacity_ptr)
    # For 1-based indexing, allocate (capacity + 1) * 8 bytes
    capacity_plus_one = builder.add(capacity_val, one)
    size_of = builder.mul(capacity_plus_one, eight)

    data_ptr_8 = builder.bitcast(builder.load(data_ptr), type_map[INT8].as_pointer())
    re_alloc = builder.call(self.module.get_global('realloc'), [data_ptr_8, size_of])
    re_alloc = builder.bitcast(re_alloc, array_type.as_pointer())
    builder.store(re_alloc, data_ptr)

    builder.branch(dyn_array_double_capacity_if_full_exit)

    # CLOSE
    builder.position_at_end(dyn_array_double_capacity_if_full_exit)
    builder.ret_void()


def dynamic_array_append(self, dyn_array_ptr, array_type):
    # START
    type_name = _normalize_type_name(array_type)
    dyn_array_append_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr, array_type])
    dyn_array_append = ir.Function(self.module, dyn_array_append_type, '{}.array.append'.format(type_name))
    dyn_array_append.args[0].name = 'self'
    dyn_array_append_entry = dyn_array_append.append_basic_block('entry')
    builder = ir.IRBuilder(dyn_array_append_entry)
    self.builder = builder
    dyn_array_append_exit = dyn_array_append.append_basic_block('exit')
    builder.position_at_end(dyn_array_append_entry)
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(dyn_array_append.args[0], array_ptr)
    value_ptr = builder.alloca(array_type)
    builder.store(dyn_array_append.args[1], value_ptr)

    # BODY
    builder.call(self.module.get_global('{}.array.double_capacity_if_full'.format(type_name)), [builder.load(array_ptr)])

    size_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_SIZE], inbounds=True)
    size_val = builder.load(size_ptr)

    # Store element at current size index (0-based: element goes at index size)
    data_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_DATA], inbounds=True)
    data_element_ptr = builder.gep(builder.load(data_ptr), [size_val], inbounds=True)

    elem_val = builder.load(value_ptr)

    # For managed types (class pointers), call rc_retain
    if isinstance(array_type, ir.PointerType):
        retain_func = self.module.get_global('meteor_retain')
        if retain_func:
            from meteor.compiler.base import OBJECT_HEADER
            header_struct = self.search_scopes(OBJECT_HEADER)
            if header_struct:
                pointee = array_type.pointee
                # Check if element is a class type (header at -16) or array (header at 0)
                is_class = hasattr(pointee, 'methods') or (
                    hasattr(pointee, 'name') and
                    self.search_scopes(pointee.name) is not None and
                    hasattr(self.search_scopes(pointee.name), 'methods')
                )
                # Null check before retain
                null_ptr = ir.Constant(array_type, None)
                is_not_null = builder.icmp_unsigned('!=', elem_val, null_ptr)

                retain_block = dyn_array_append.append_basic_block('retain')
                store_block = dyn_array_append.append_basic_block('store')

                builder.cbranch(is_not_null, retain_block, store_block)

                builder.position_at_end(retain_block)
                if is_class:
                    i8_ptr = builder.bitcast(elem_val, ir.IntType(8).as_pointer())
                    header_ptr = builder.gep(i8_ptr, [ir.Constant(type_map[INT], -16)])
                    header_ptr = builder.bitcast(header_ptr, header_struct.as_pointer())
                else:
                    header_ptr = builder.bitcast(elem_val, header_struct.as_pointer())
                builder.call(retain_func, [header_ptr])
                builder.branch(store_block)

                builder.position_at_end(store_block)

    builder.store(elem_val, data_element_ptr)

    # Then increment size
    new_size = builder.add(size_val, one)
    builder.store(new_size, size_ptr)

    builder.branch(dyn_array_append_exit)

    # CLOSE
    self.define('{}.array.append'.format(_normalize_type_name(array_type)), dyn_array_append)
    builder.position_at_end(dyn_array_append_exit)
    builder.ret_void()


def dynamic_array_get(self, dyn_array_ptr, array_type):
    # START
    dyn_array_get_type = ir.FunctionType(array_type, [dyn_array_ptr, type_map[INT]])
    dyn_array_get = ir.Function(self.module, dyn_array_get_type, '{}.array.get'.format(_normalize_type_name(array_type)))
    dyn_array_get.args[0].name = 'self'
    dyn_array_get_entry = dyn_array_get.append_basic_block('entry')
    builder = ir.IRBuilder(dyn_array_get_entry)
    self.builder = builder
    dyn_array_get_exit = dyn_array_get.append_basic_block('exit')
    dyn_array_get_index_out_of_bounds = dyn_array_get.append_basic_block('index_out_of_bounds')
    dyn_array_get_is_index_less_than_zero = dyn_array_get.append_basic_block('is_index_less_than_zero')
    dyn_array_get_negative_index = dyn_array_get.append_basic_block('negative_index')
    dyn_array_get_block = dyn_array_get.append_basic_block('get')
    builder.position_at_end(dyn_array_get_entry)
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(dyn_array_get.args[0], array_ptr)
    index_ptr = builder.alloca(type_map[INT])
    builder.store(dyn_array_get.args[1], index_ptr)

    # BODY
    index_val = builder.load(index_ptr)
    size_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_SIZE], inbounds=True)
    size_val = builder.load(size_ptr)

    compare_index_to_size = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, index_val, size_val)

    builder.cbranch(compare_index_to_size, dyn_array_get_index_out_of_bounds, dyn_array_get_is_index_less_than_zero)

    builder.position_at_end(dyn_array_get_index_out_of_bounds)
    
        

    # Correct approach:
    builder.call(self.module.get_global('exit'), [one_32])
    builder.unreachable()

    builder.position_at_end(dyn_array_get_is_index_less_than_zero)

    compare_index_to_zero = builder.icmp_signed(LESS_THAN, index_val, zero)

    builder.cbranch(compare_index_to_zero, dyn_array_get_negative_index, dyn_array_get_block)

    builder.position_at_end(dyn_array_get_negative_index)

    add = builder.add(size_val, index_val)
    builder.store(add, index_ptr)
    builder.branch(dyn_array_get_block)

    builder.position_at_end(dyn_array_get_block)

    data_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_DATA], inbounds=True)

    # Load index (may have been modified for negative index) - 0-based storage
    index_val = builder.load(index_ptr)
    data_element_ptr = builder.gep(builder.load(data_ptr), [index_val], inbounds=True)

    builder.branch(dyn_array_get_exit)

    # CLOSE
    self.define('{}.array.get'.format(_normalize_type_name(array_type)), dyn_array_get)
    builder.position_at_end(dyn_array_get_exit)
    builder.ret(builder.load(data_element_ptr))


def dynamic_array_set(self, dyn_array_ptr, array_type):
    # START
    dyn_array_set_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr, type_map[INT], array_type])
    dyn_array_set = ir.Function(self.module, dyn_array_set_type, '{}.array.set'.format(_normalize_type_name(array_type)))
    dyn_array_set.args[0].name = 'self'
    dyn_array_set_entry = dyn_array_set.append_basic_block('entry')
    builder = ir.IRBuilder(dyn_array_set_entry)
    self.builder = builder
    dyn_array_set_exit = dyn_array_set.append_basic_block('exit')
    dyn_array_set_index_out_of_bounds = dyn_array_set.append_basic_block('index_out_of_bounds')
    dyn_array_set_is_index_less_than_zero = dyn_array_set.append_basic_block('is_index_less_than_zero')
    dyn_array_set_negative_index = dyn_array_set.append_basic_block('negative_index')
    dyn_array_set_block = dyn_array_set.append_basic_block('set')
    builder.position_at_end(dyn_array_set_entry)
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(dyn_array_set.args[0], array_ptr)
    index_ptr = builder.alloca(type_map[INT])
    builder.store(dyn_array_set.args[1], index_ptr)
    value_ptr = builder.alloca(array_type)
    builder.store(dyn_array_set.args[2], value_ptr)

    # BODY
    index_val = builder.load(index_ptr)

    size_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_SIZE], inbounds=True)
    size_val = builder.load(size_ptr)

    compare_index_to_size = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, index_val, size_val)

    builder.cbranch(compare_index_to_size, dyn_array_set_index_out_of_bounds, dyn_array_set_is_index_less_than_zero)

    builder.position_at_end(dyn_array_set_index_out_of_bounds)
    self.print_string('Array index out of bounds')
    builder.call(self.module.get_global('exit'), [one_32])
    builder.unreachable()

    builder.position_at_end(dyn_array_set_is_index_less_than_zero)

    compare_index_to_zero = builder.icmp_signed(LESS_THAN, index_val, zero)

    builder.cbranch(compare_index_to_zero, dyn_array_set_negative_index, dyn_array_set_block)

    builder.position_at_end(dyn_array_set_negative_index)

    add = builder.add(size_val, index_val)
    builder.store(add, index_ptr)
    builder.branch(dyn_array_set_block)

    builder.position_at_end(dyn_array_set_block)

    data_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_DATA], inbounds=True)

    # Load index (may have been modified for negative index) - 0-based storage
    index_val = builder.load(index_ptr)
    data_element_ptr = builder.gep(builder.load(data_ptr), [index_val], inbounds=True)

    builder.store(builder.load(value_ptr), data_element_ptr)

    builder.branch(dyn_array_set_exit)

    # CLOSE
    self.define('{}.array.set'.format(_normalize_type_name(array_type)), dyn_array_set)
    builder.position_at_end(dyn_array_set_exit)
    builder.ret_void()


def dynamic_array_length(self, dyn_array_ptr, array_type):
    # START
    dyn_array_length_type = ir.FunctionType(type_map[INT], [dyn_array_ptr])
    dyn_array_length = ir.Function(self.module, dyn_array_length_type, '{}.array.length'.format(_normalize_type_name(array_type)))
    dyn_array_length.args[0].name = 'self'
    dyn_array_length_entry = dyn_array_length.append_basic_block('entry')
    builder = ir.IRBuilder(dyn_array_length_entry)
    self.builder = builder
    builder.position_at_end(dyn_array_length_entry)
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(dyn_array_length.args[0], array_ptr)

    size_ptr = builder.gep(builder.load(array_ptr), [zero_32, ARRAY_SIZE], inbounds=True)

    # CLOSE
    self.define('{}.array.length'.format(_normalize_type_name(array_type)), dyn_array_length)
    builder.ret(builder.load(size_ptr))

# TODO: add the following functions for dynamic array
# extend(iterable)
# insert(item, index)
# remove(item)
# pop([index])
# clear()
# index(x[, start[, end]])
# count(item)
# sort(key=None, reverse=False)
# reverse()


def dynamic_array_destroy(self, dyn_array_ptr, array_type, type_name):
    """Generate destructor for array that releases elements if they are managed types."""
    from meteor.compiler.base import OBJECT_HEADER

    # Create destroy function: void TypeName.array.destroy(TypeName.array* self)
    func_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr])
    func_name = '{}.array.destroy'.format(type_name)
    func = ir.Function(self.module, func_type, func_name)
    func.linkage = 'internal'
    func.args[0].name = 'self'

    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(func.args[0], array_ptr)

    # Check if element type is a managed type (pointer to class or array)
    is_managed_element = False
    if isinstance(array_type, ir.PointerType):
        pointee = array_type.pointee
        if hasattr(pointee, 'name'):
            # Check for class types or nested arrays
            if hasattr(pointee, 'methods') or pointee.name.endswith('.array'):
                is_managed_element = True
            # Also check if we can find the class definition
            class_def = self.search_scopes(pointee.name)
            if class_def is not None and hasattr(class_def, 'methods'):
                is_managed_element = True

    exit_block = func.append_basic_block('exit')

    if is_managed_element:
        # Need to release each element before freeing data
        loop_cond = func.append_basic_block('loop_cond')
        loop_body = func.append_basic_block('loop_body')
        free_data = func.append_basic_block('free_data')

        # Get size and data pointer
        arr = builder.load(array_ptr)
        size_ptr = builder.gep(arr, [zero_32, ARRAY_SIZE], inbounds=True)
        size = builder.load(size_ptr)
        data_ptr_ptr = builder.gep(arr, [zero_32, ARRAY_DATA], inbounds=True)
        data_ptr = builder.load(data_ptr_ptr)

        # Loop index
        i_ptr = builder.alloca(type_map[INT])
        builder.store(zero, i_ptr)
        builder.branch(loop_cond)

        # Loop condition: i < size
        builder.position_at_end(loop_cond)
        i = builder.load(i_ptr)
        cond = builder.icmp_signed('<', i, size)
        builder.cbranch(cond, loop_body, free_data)

        # Loop body: release element[i]
        builder.position_at_end(loop_body)
        i = builder.load(i_ptr)
        elem_ptr = builder.gep(data_ptr, [i], inbounds=True)
        elem = builder.load(elem_ptr)

        # Null check before release
        null_ptr = ir.Constant(array_type, None)
        is_not_null = builder.icmp_unsigned('!=', elem, null_ptr)

        release_block = func.append_basic_block('release_elem')
        next_block = func.append_basic_block('next_iter')

        builder.cbranch(is_not_null, release_block, next_block)

        builder.position_at_end(release_block)
        # Call meteor_release on element
        release_func = self.module.get_global('meteor_release')
        if release_func:
            header_struct = self.search_scopes(OBJECT_HEADER)
            if header_struct:
                pointee = array_type.pointee
                # For class types, header is 16 bytes before data
                if hasattr(pointee, 'methods') or (hasattr(pointee, 'name') and
                    self.search_scopes(pointee.name) is not None and
                    hasattr(self.search_scopes(pointee.name), 'methods')):
                    i8_ptr = builder.bitcast(elem, ir.IntType(8).as_pointer())
                    header_ptr = builder.gep(i8_ptr, [ir.Constant(type_map[INT], -16)])
                    header_ptr = builder.bitcast(header_ptr, header_struct.as_pointer())
                else:
                    # For arrays, header is at offset 0
                    header_ptr = builder.bitcast(elem, header_struct.as_pointer())
                builder.call(release_func, [header_ptr])
        builder.branch(next_block)

        builder.position_at_end(next_block)
        next_i = builder.add(i, one)
        builder.store(next_i, i_ptr)
        builder.branch(loop_cond)

        # Free data pointer
        builder.position_at_end(free_data)
        free_func = self.module.get_global('free')
        if free_func:
            data_i8 = builder.bitcast(data_ptr, type_map[INT8].as_pointer())
            builder.call(free_func, [data_i8])
        builder.branch(exit_block)
    else:
        # No managed elements, just free data
        arr = builder.load(array_ptr)
        data_ptr_ptr = builder.gep(arr, [zero_32, ARRAY_DATA], inbounds=True)
        data_ptr = builder.load(data_ptr_ptr)
        free_func = self.module.get_global('free')
        if free_func:
            data_i8 = builder.bitcast(data_ptr, type_map[INT8].as_pointer())
            builder.call(free_func, [data_i8])
        builder.branch(exit_block)

    builder.position_at_end(exit_block)
    builder.ret_void()

    self.define(func_name, func)


def define_print(self, dyn_array_ptr):
    # START
    func_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr])
    func = ir.Function(self.module, func_type, 'print')
    entry_block = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry_block)
    self.builder = builder
    builder.position_at_end(entry_block)
    zero_length_check_block = func.append_basic_block('zero_length_check')
    non_zero_length_block = func.append_basic_block('non_zero_length')
    cond_block = func.append_basic_block('check_if_done')
    body_block = func.append_basic_block('print_it')
    exit_block = func.append_basic_block('exit')
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(func.args[0], array_ptr)

    # BODY
    builder.position_at_end(entry_block)
    length = builder.call(self.module.get_global('i64.array.length'), [builder.load(array_ptr)])
    builder.branch(zero_length_check_block)

    builder.position_at_end(zero_length_check_block)
    cond = builder.icmp_signed(LESS_THAN_OR_EQUAL_TO, zero, length)
    builder.cbranch(cond, non_zero_length_block, exit_block)

    builder.position_at_end(non_zero_length_block)
    position_ptr = builder.alloca(type_map[INT])
    builder.store(zero, position_ptr)
    builder.branch(cond_block)

    builder.position_at_end(cond_block)
    cond = builder.icmp_signed(LESS_THAN, builder.load(position_ptr), length)
    builder.cbranch(cond, body_block, exit_block)

    builder.position_at_end(body_block)
    char = builder.call(self.module.get_global('i64.array.get'), [builder.load(array_ptr), builder.load(position_ptr)])
    builder.call(self.module.get_global('putchar'), [char])
    add_one = builder.add(one, builder.load(position_ptr))
    builder.store(add_one, position_ptr)
    builder.branch(cond_block)

    # CLOSE
    builder.position_at_end(exit_block)
    builder.call(self.module.get_global('putchar'), [ten])
    builder.ret_void()


def define_print_bigint(self):
    # print_bigint(bigint*) - rewritten to use 1-based memory access (matching append)
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(type_map[VOID], [bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'print_bigint')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    bigint_ptr = func.args[0]

    # Get sign (index 1 after header)
    sign_ptr = builder.gep(bigint_ptr, [zero_32, BIGINT_SIGN])
    sign_val = builder.load(sign_ptr)

    # Get digits array (index 2 after header)
    digits_ptr_ptr = builder.gep(bigint_ptr, [zero_32, BIGINT_DIGITS])
    digits_array = builder.load(digits_ptr_ptr)

    # RFC-001: NULL check for Use-After-Move detection
    null_ptr = ir.Constant(digits_array.type, None)
    is_null = builder.icmp_unsigned('==', digits_array, null_ptr)

    null_block = func.append_basic_block('null_error')
    valid_block = func.append_basic_block('valid')
    builder.cbranch(is_null, null_block, valid_block)

    # NULL block: print error and exit
    builder.position_at_end(null_block)
    # Declare fprintf/stderr for error output
    fprintf = self.module.globals.get('fprintf')
    if not fprintf:
        fprintf_type = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer(), type_map[INT8].as_pointer()], var_arg=True)
        fprintf = ir.Function(self.module, fprintf_type, 'fprintf')
    stderr_ptr = self.module.globals.get('__stderrp') or self.module.globals.get('stderr')

    # Use printf as fallback
    printf_fallback = self.module.globals.get('printf')
    if not printf_fallback:
        printf_type = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer()], var_arg=True)
        printf_fallback = ir.Function(self.module, printf_type, 'printf')

    err_msg = "Error: Use-After-Move - accessing moved variable!\n\0"
    err_str = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], len(err_msg)), name="uam_err_msg")
    if not err_str.initializer:
        err_str.initializer = ir.Constant(ir.ArrayType(type_map[INT8], len(err_msg)), bytearray(err_msg.encode('utf-8')))
        err_str.global_constant = True
    builder.call(printf_fallback, [builder.bitcast(err_str, type_map[INT8].as_pointer())])

    # Call exit(1)
    exit_func = self.module.globals.get('exit')
    if not exit_func:
        exit_type = ir.FunctionType(type_map[VOID], [type_map[INT32]])
        exit_func = ir.Function(self.module, exit_type, 'exit')
    builder.call(exit_func, [ir.Constant(type_map[INT32], 1)])
    builder.unreachable()

    # Continue with valid block
    builder.position_at_end(valid_block)

    # Declare printf if not exists
    printf = self.module.globals.get('printf')
    if not printf:
        printf_type = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer()], var_arg=True)
        printf = ir.Function(self.module, printf_type, 'printf')

    # Print sign if negative
    neg_block = func.append_basic_block('print_neg')
    pos_block = func.append_basic_block('print_pos')
    merge_block = func.append_basic_block('print_value')

    is_neg = builder.icmp_unsigned('!=', sign_val, ir.Constant(type_map[BOOL], 0))
    builder.cbranch(is_neg, neg_block, pos_block)

    builder.position_at_end(neg_block)
    minus_str = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 2), name="minus_str")
    if not minus_str.initializer:
        minus_str.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 2), bytearray(b"-\00"))
        minus_str.global_constant = True
    builder.call(printf, [builder.bitcast(minus_str, type_map[INT8].as_pointer())])
    builder.branch(merge_block)

    builder.position_at_end(pos_block)
    builder.branch(merge_block)

    builder.position_at_end(merge_block)

    # Get number of digits (direct access to size field)
    num_digits_ptr = builder.gep(digits_array, [zero_32, ARRAY_SIZE])
    num_digits = builder.load(num_digits_ptr)

    # Get data pointer for 1-based access
    src_data_ptr_ptr = builder.gep(digits_array, [zero_32, ARRAY_DATA])
    src_data_ptr = builder.load(src_data_ptr_ptr)

    # If single digit, print as decimal number (0-based: first element at index 0)
    is_single = builder.icmp_signed('==', num_digits, one)

    single_block = func.append_basic_block('single_digit')
    multi_block = func.append_basic_block('multi_digit')
    end_block = func.append_basic_block('end')

    builder.cbranch(is_single, single_block, multi_block)

    # Single digit: print as decimal (0-based: first element at index 0)
    builder.position_at_end(single_block)
    first_digit_ptr = builder.gep(src_data_ptr, [zero])  # 0-based index
    first_digit = builder.load(first_digit_ptr)
    fmt_str = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 6), name="fmt_bigint")
    if not fmt_str.initializer:
        fmt_str.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 6), bytearray(b"%llu\n\00"))
        fmt_str.global_constant = True
    builder.call(printf, [builder.bitcast(fmt_str, type_map[INT8].as_pointer()), first_digit])
    builder.branch(end_block)

    # Multi-digit: convert to decimal using repeated division by 10^9
    # Using 10^9 instead of 10^19 to avoid 128-bit overflow in carry * MOD_CONST
    builder.position_at_end(multi_block)
    
    # Constants for division by 10^9 (1000000000)
    # 2^64 / 10^9 = 18446744073
    # 2^64 % 10^9 = 709551616
    div_const_g = ir.GlobalVariable(self.module, type_map[INT64], name="BIGINT_DIV_CONST_1E9")
    if not div_const_g.initializer:
        div_const_g.initializer = ir.Constant(type_map[INT64], 18446744073) # Floor(2^64 / 10^9)
        div_const_g.global_constant = True

    DIV_CONST = builder.load(div_const_g)
    # MOD_CONST = 2^64 % 10^9
    MOD_CONST = ir.Constant(type_map[INT64], 709551616)
    BASE_DIVISOR = ir.Constant(type_map[INT64], 1000000000)

    # Create arrays using append (which works correctly)
    append_func = self.module.get_global('i64.array.append')
    decimal_digits = self.create_array(type_map[INT64])
    work_array = self.create_array(type_map[INT64])

    # Copy loop using 0-based access (index 0 to num_digits-1)
    copy_cond = func.append_basic_block('copy_cond')
    copy_body = func.append_basic_block('copy_body')
    copy_end = func.append_basic_block('copy_end')

    copy_idx = builder.alloca(type_map[INT])
    builder.store(zero, copy_idx)  # Start from 0 (0-based)
    builder.branch(copy_cond)

    builder.position_at_end(copy_cond)
    idx_val = builder.load(copy_idx)
    copy_cont = builder.icmp_signed('<', idx_val, num_digits)  # < num_digits
    builder.cbranch(copy_cont, copy_body, copy_end)

    builder.position_at_end(copy_body)
    # 0-based access to source array
    src_elem_ptr = builder.gep(src_data_ptr, [idx_val])
    digit_val = builder.load(src_elem_ptr)
    builder.call(append_func, [work_array, digit_val])
    builder.store(builder.add(idx_val, one), copy_idx)
    builder.branch(copy_cond)

    builder.position_at_end(copy_end)

    # Pre-allocate variables for division loop (must be outside loop)
    carry = builder.alloca(type_map[INT64])
    div_idx = builder.alloca(type_map[INT])
    work_len_slot = builder.alloca(type_map[INT])

    # Division loop: while work_array is not zero
    div_loop = func.append_basic_block('div_loop')
    div_check_zero = func.append_basic_block('div_check_zero')
    div_body = func.append_basic_block('div_body')
    div_end = func.append_basic_block('div_end')

    builder.branch(div_loop)

    builder.position_at_end(div_loop)
    # Get work_array length (direct access to size field)
    work_size_ptr = builder.gep(work_array, [zero_32, ARRAY_SIZE])
    work_len = builder.load(work_size_ptr)
    builder.store(work_len, work_len_slot)

    is_empty = builder.icmp_signed('==', work_len, zero)
    builder.cbranch(is_empty, div_end, div_check_zero)

    builder.position_at_end(div_check_zero)
    # Get work_array data pointer for 0-based access
    work_data_ptr_ptr = builder.gep(work_array, [zero_32, ARRAY_DATA])
    work_data_ptr = builder.load(work_data_ptr_ptr)

    # Check if highest digit is zero (0-based: highest at index work_len-1)
    high_idx = builder.sub(work_len, one)
    high_digit_ptr = builder.gep(work_data_ptr, [high_idx])
    high_digit = builder.load(high_digit_ptr)
    is_all_zero = builder.icmp_unsigned('==', high_digit, ir.Constant(type_map[INT64], 0))

    # If highest is zero and length is 1, we're done
    is_one = builder.icmp_signed('==', work_len, one)
    should_stop = builder.and_(is_all_zero, is_one)
    builder.cbranch(should_stop, div_end, div_body)

    builder.position_at_end(div_body)
    # Initialize carry to 0
    builder.store(ir.Constant(type_map[INT64], 0), carry)

    # Get current length and initialize div_idx to len-1 (0-based: from len-1 down to 0)
    cur_len = builder.load(work_len_slot)
    last_idx = builder.sub(cur_len, one)
    builder.store(last_idx, div_idx)

    div_inner_cond = func.append_basic_block('div_inner_cond')
    div_inner_body = func.append_basic_block('div_inner_body')
    div_inner_end = func.append_basic_block('div_inner_end')

    builder.branch(div_inner_cond)

    builder.position_at_end(div_inner_cond)
    i_val = builder.load(div_idx)
    inner_cont = builder.icmp_signed('>=', i_val, zero)  # 0-based: >= 0
    builder.cbranch(inner_cont, div_inner_body, div_inner_end)

    builder.position_at_end(div_inner_body)
    # Get work_array data pointer again (for SSA correctness)
    work_data_ptr_ptr2 = builder.gep(work_array, [zero_32, ARRAY_DATA])
    work_data_ptr2 = builder.load(work_data_ptr_ptr2)

    # Get current digit using 0-based access
    cur_digit_ptr = builder.gep(work_data_ptr2, [i_val])
    cur_digit = builder.load(cur_digit_ptr)
    carry_val = builder.load(carry)

    # Compute: (carry * 2^64 + digit) / 10^9 and % 10^9
    # q1 = carry * DIV_CONST
    q1 = builder.mul(carry_val, DIV_CONST)

    # partial = carry * MOD_CONST (safe: max ~7e17, fits 64 bits)
    partial = builder.mul(carry_val, MOD_CONST)

    # temp = partial + cur_digit (Check for overflow!)
    temp = builder.add(partial, cur_digit)
    is_overflow = builder.icmp_unsigned('<', temp, cur_digit)

    # q2 = temp / BASE_DIVISOR
    q2 = builder.udiv(temp, BASE_DIVISOR)
    # rem = temp % BASE_DIVISOR
    rem = builder.urem(temp, BASE_DIVISOR)

    # Adjustment if overflow occurred:
    extra_q = builder.select(is_overflow, DIV_CONST, ir.Constant(type_map[INT64], 0))
    rem_adj = builder.select(is_overflow, MOD_CONST, ir.Constant(type_map[INT64], 0))

    # rem_sum = rem + rem_adj
    rem_sum = builder.add(rem, rem_adj)

    # new_carry = rem_sum % BASE_DIVISOR
    new_carry = builder.urem(rem_sum, BASE_DIVISOR)

    # Correction to quotient: rem_sum / BASE_DIVISOR
    rem_carry_q = builder.udiv(rem_sum, BASE_DIVISOR)

    # new_digit = q1 + q2 + extra_q + rem_carry_q
    new_digit = builder.add(q1, q2)
    new_digit = builder.add(new_digit, extra_q)
    new_digit = builder.add(new_digit, rem_carry_q)

    # Store new_digit using direct 0-based access
    builder.store(new_digit, cur_digit_ptr)
    builder.store(new_carry, carry)

    builder.store(builder.sub(i_val, one), div_idx)
    builder.branch(div_inner_cond)

    builder.position_at_end(div_inner_end)
    # The carry is now the remainder (one decimal digit)
    final_carry = builder.load(carry)
    builder.call(append_func, [decimal_digits, final_carry])
    
    # Trim leading zeros from work_array
    trim_cond = func.append_basic_block('trim_cond')
    trim_body = func.append_basic_block('trim_body')
    trim_end = func.append_basic_block('trim_end')

    builder.branch(trim_cond)

    builder.position_at_end(trim_cond)
    # Get current work_array length (direct access)
    trim_size_ptr = builder.gep(work_array, [zero_32, ARRAY_SIZE])
    cur_work_len = builder.load(trim_size_ptr)
    has_elements = builder.icmp_signed('>', cur_work_len, zero)
    builder.cbranch(has_elements, trim_body, trim_end)

    builder.position_at_end(trim_body)
    # Get top element using 0-based access (top at index cur_work_len-1)
    trim_data_ptr_ptr = builder.gep(work_array, [zero_32, ARRAY_DATA])
    trim_data_ptr = builder.load(trim_data_ptr_ptr)
    top_idx = builder.sub(cur_work_len, one)
    top_val_ptr = builder.gep(trim_data_ptr, [top_idx])  # 0-based
    top_val = builder.load(top_val_ptr)

    is_zero_top = builder.icmp_unsigned('==', top_val, ir.Constant(type_map[INT64], 0))
    has_more = builder.icmp_signed('>', cur_work_len, one)
    should_trim = builder.and_(is_zero_top, has_more)

    trim_do = func.append_basic_block('trim_do')
    builder.cbranch(should_trim, trim_do, trim_end)

    builder.position_at_end(trim_do)
    # Decrement length (simple "pop" by reducing size field)
    new_size = builder.sub(cur_work_len, one)
    builder.store(new_size, trim_size_ptr)
    builder.branch(trim_cond)

    builder.position_at_end(trim_end)
    builder.branch(div_loop)

    builder.position_at_end(div_end)

    # Print decimal digits in reverse order (they were collected low to high)
    # Get decimal_digits length (direct access)
    dec_size_ptr = builder.gep(decimal_digits, [zero_32, ARRAY_SIZE])
    dec_len = builder.load(dec_size_ptr)

    # Handle edge case: if no digits, print 0
    has_dec = builder.icmp_signed('>', dec_len, zero)
    print_zero = func.append_basic_block('print_zero')
    print_digits = func.append_basic_block('print_digits')

    builder.cbranch(has_dec, print_digits, print_zero)

    builder.position_at_end(print_zero)
    zero_fmt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 3), name="fmt_zero")
    if not zero_fmt.initializer:
        zero_fmt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 3), bytearray(b"0\n\00"))
        zero_fmt.global_constant = True
    builder.call(printf, [builder.bitcast(zero_fmt, type_map[INT8].as_pointer())])
    builder.branch(end_block)

    builder.position_at_end(print_digits)
    # Print each decimal digit (high to low = reverse order)
    dec_fmt_first = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 5), name="fmt_dec_first")
    if not dec_fmt_first.initializer:
        dec_fmt_first.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 5), bytearray(b"%llu\00"))
        dec_fmt_first.global_constant = True
        
    dec_fmt_pad = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 7), name="fmt_dec_pad")
    if not dec_fmt_pad.initializer:
        dec_fmt_pad.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 7), bytearray(b"%09llu\00"))
        dec_fmt_pad.global_constant = True

    print_idx = builder.alloca(type_map[INT])
    last_dec_idx = builder.sub(dec_len, one)
    builder.store(last_dec_idx, print_idx)  # 0-based: start from dec_len-1

    print_dec_cond = func.append_basic_block('print_dec_cond')
    print_dec_body = func.append_basic_block('print_dec_body')
    print_dec_finish = func.append_basic_block('print_dec_finish')

    builder.branch(print_dec_cond)

    builder.position_at_end(print_dec_cond)
    p_idx = builder.load(print_idx)
    p_cont = builder.icmp_signed('>=', p_idx, zero)  # 0-based: >= 0
    builder.cbranch(p_cont, print_dec_body, print_dec_finish)

    builder.position_at_end(print_dec_body)
    # Get decimal digit using 0-based access
    dec_data_ptr_ptr = builder.gep(decimal_digits, [zero_32, ARRAY_DATA])
    dec_data_ptr = builder.load(dec_data_ptr_ptr)
    
    d_val_ptr = builder.gep(dec_data_ptr, [p_idx])
    d_val = builder.load(d_val_ptr)
    
    # Check if this is the first block (MSB) -> p_idx == dec_len-1
    is_first_block = builder.icmp_signed('==', p_idx, last_dec_idx)
    
    print_first_blk = func.append_basic_block('print_first_blk')
    print_pad_blk = func.append_basic_block('print_pad_blk')
    print_cont_blk = func.append_basic_block('print_cont_blk')
    
    builder.cbranch(is_first_block, print_first_blk, print_pad_blk)
    
    builder.position_at_end(print_first_blk)
    builder.call(printf, [builder.bitcast(dec_fmt_first, type_map[INT8].as_pointer()), d_val])
    builder.branch(print_cont_blk)
    
    builder.position_at_end(print_pad_blk)
    builder.call(printf, [builder.bitcast(dec_fmt_pad, type_map[INT8].as_pointer()), d_val])
    builder.branch(print_cont_blk)
    
    builder.position_at_end(print_cont_blk)
    builder.store(builder.sub(p_idx, one), print_idx)
    builder.branch(print_dec_cond)

    builder.position_at_end(print_dec_finish)
    # Free temporary arrays: work_array, decimal_digits
    # They are i64.array not bigint. Need to free them manually.
    # work_array and decimal_digits are pointers to array struct (returned by create_array)

    free_func = self.module.get_global('free')
    if not free_func:
        free_type = ir.FunctionType(type_map[VOID], [type_map[INT8].as_pointer()])
        free_func = ir.Function(self.module, free_type, 'free')

    # Free work_array data
    wa_data_ptr_ptr = builder.gep(work_array, [zero_32, ARRAY_DATA])
    wa_data_ptr = builder.load(wa_data_ptr_ptr)
    wa_data_i8 = builder.bitcast(wa_data_ptr, type_map[INT8].as_pointer())
    builder.call(free_func, [wa_data_i8])

    # Free work_array struct
    wa_i8 = builder.bitcast(work_array, type_map[INT8].as_pointer())
    builder.call(free_func, [wa_i8])

    # Free decimal_digits data
    dd_data_ptr_ptr = builder.gep(decimal_digits, [zero_32, ARRAY_DATA])
    dd_data_ptr = builder.load(dd_data_ptr_ptr)
    dd_data_i8 = builder.bitcast(dd_data_ptr, type_map[INT8].as_pointer())
    builder.call(free_func, [dd_data_i8])

    # Free decimal_digits struct
    dd_i8 = builder.bitcast(decimal_digits, type_map[INT8].as_pointer())
    builder.call(free_func, [dd_i8])

    # Print newline
    nl_str = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 2), name="nl_str")
    if not nl_str.initializer:
        nl_str.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 2), bytearray(b"\n\00"))
        nl_str.global_constant = True
    builder.call(printf, [builder.bitcast(nl_str, type_map[INT8].as_pointer())])
    builder.branch(end_block)

    builder.position_at_end(end_block)
    builder.ret_void()


def define_print_decimal(self):
    """Print decimal in standard scientific notation: X.XXXeN (omit eN if N=0)
    Example: 3.14 -> "3.14", 0.00314 -> "3.14e-3", 31400 -> "3.14e4"
    """
    decimal_struct = type_map[DECIMAL]
    func_type = ir.FunctionType(type_map[VOID], [decimal_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'print_decimal')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    decimal_ptr = func.args[0]

    # Declare printf
    printf = self.module.globals.get('printf')
    if not printf:
        printf_type = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer()], var_arg=True)
        printf = ir.Function(self.module, printf_type, 'printf')

    # Get helper functions
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    malloc_func = self.module.get_global('malloc')
    u64_array_type = self.module.context.get_identified_type('i64.array')

    # Constants
    TEN = ir.Constant(type_map[INT64], 10)
    DIV_CONST = ir.Constant(type_map[INT64], 1844674407370955161)
    MOD_CONST = ir.Constant(type_map[INT64], 6)

    # === All alloca in entry block ===
    copy_idx = builder.alloca(type_map[INT], name="copy_idx")
    div_idx = builder.alloca(type_map[INT], name="div_idx")
    carry = builder.alloca(type_map[INT64], name="carry")
    print_idx = builder.alloca(type_map[INT], name="print_idx")
    work_len_slot = builder.alloca(type_map[INT], name="work_len_slot")
    adjusted_exp_slot = builder.alloca(type_map[INT64], name="adjusted_exp_slot")

    # === Create ALL basic blocks upfront ===
    zero_block = func.append_basic_block('zero_block')
    nonzero_block = func.append_basic_block('nonzero_block')
    copy_cond = func.append_basic_block('copy_cond')
    copy_body = func.append_basic_block('copy_body')
    copy_end = func.append_basic_block('copy_end')
    div_loop = func.append_basic_block('div_loop')
    div_check_zero = func.append_basic_block('div_check_zero')
    div_body = func.append_basic_block('div_body')
    div_end = func.append_basic_block('div_end')
    print_zero = func.append_basic_block('print_zero')
    print_digits = func.append_basic_block('print_digits')
    neg_block = func.append_basic_block('neg_block')
    after_sign = func.append_basic_block('after_sign')
    print_first = func.append_basic_block('print_first')
    check_more = func.append_basic_block('check_more')
    print_dot = func.append_basic_block('print_dot')
    frac_cond = func.append_basic_block('frac_cond')
    frac_body = func.append_basic_block('frac_body')
    frac_end = func.append_basic_block('frac_end')
    check_exp = func.append_basic_block('check_exp')
    print_exp = func.append_basic_block('print_exp')
    skip_exp = func.append_basic_block('skip_exp')
    end_block = func.append_basic_block('end_block')

    # === Entry block: setup ===
    mantissa_ptr_ptr = builder.gep(decimal_ptr, [zero_32, DECIMAL_MANTISSA])
    mantissa_ptr = builder.load(mantissa_ptr_ptr)
    exponent_ptr = builder.gep(decimal_ptr, [zero_32, DECIMAL_EXPONENT])
    exponent_val = builder.load(exponent_ptr)

    sign_ptr = builder.gep(mantissa_ptr, [zero_32, BIGINT_SIGN])
    sign_val = builder.load(sign_ptr)
    digits_ptr_ptr = builder.gep(mantissa_ptr, [zero_32, BIGINT_DIGITS])
    digits_array = builder.load(digits_ptr_ptr)

    # Get length of bigint digits
    len_ptr = builder.gep(digits_array, [zero_32, ARRAY_SIZE])
    num_u64 = builder.load(len_ptr)

    # Check if mantissa is zero
    is_empty = builder.icmp_signed('==', num_u64, zero)
    builder.cbranch(is_empty, zero_block, nonzero_block)

    # === zero_block ===
    builder.position_at_end(zero_block)
    zero_fmt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 3), name="dec_zero_fmt")
    if not zero_fmt.initializer:
        zero_fmt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 3), bytearray(b"0\n\00"))
        zero_fmt.global_constant = True
    builder.call(printf, [builder.bitcast(zero_fmt, type_map[INT8].as_pointer())])
    builder.branch(end_block)

    # === nonzero_block: allocate work arrays ===
    builder.position_at_end(nonzero_block)
    # Allocate work_array for division
    work_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    work_array = builder.bitcast(work_mem, u64_array_type.as_pointer())
    builder.call(init_func, [work_array])

    # Allocate decimal_digits to store result
    dec_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    decimal_digits = builder.bitcast(dec_mem, u64_array_type.as_pointer())
    builder.call(init_func, [decimal_digits])

    builder.store(zero, copy_idx)
    builder.branch(copy_cond)

    # === copy_cond: copy bigint digits to work_array ===
    builder.position_at_end(copy_cond)
    c_idx = builder.load(copy_idx)
    c_cont = builder.icmp_signed('<', c_idx, num_u64)
    builder.cbranch(c_cont, copy_body, copy_end)

    # === copy_body ===
    builder.position_at_end(copy_body)
    src_data_ptr_ptr = builder.gep(digits_array, [zero_32, ARRAY_DATA])
    src_data_ptr = builder.load(src_data_ptr_ptr)
    src_idx = builder.add(c_idx, one)  # 1-based
    src_val_ptr = builder.gep(src_data_ptr, [src_idx])
    src_val = builder.load(src_val_ptr)
    builder.call(append_func, [work_array, src_val])
    builder.store(builder.add(c_idx, one), copy_idx)
    builder.branch(copy_cond)

    # === copy_end: start division loop ===
    builder.position_at_end(copy_end)
    work_len_ptr = builder.gep(work_array, [zero_32, ARRAY_SIZE])
    init_work_len = builder.load(work_len_ptr)
    builder.store(init_work_len, work_len_slot)
    builder.branch(div_loop)

    # === div_loop: check if work_array is empty ===
    builder.position_at_end(div_loop)
    work_len = builder.load(work_len_slot)
    is_work_empty = builder.icmp_signed('==', work_len, zero)
    builder.cbranch(is_work_empty, div_end, div_check_zero)

    # === div_check_zero: check if highest digit is zero ===
    builder.position_at_end(div_check_zero)
    work_data_ptr_ptr = builder.gep(work_array, [zero_32, ARRAY_DATA])
    work_data_ptr = builder.load(work_data_ptr_ptr)
    high_digit_ptr = builder.gep(work_data_ptr, [work_len])
    high_digit = builder.load(high_digit_ptr)
    is_all_zero = builder.icmp_unsigned('==', high_digit, ir.Constant(type_map[INT64], 0))
    is_one = builder.icmp_signed('==', work_len, one)
    should_stop = builder.and_(is_all_zero, is_one)
    builder.cbranch(should_stop, div_end, div_body)

    # === div_body: divide by 10 ===
    builder.position_at_end(div_body)
    builder.store(ir.Constant(type_map[INT64], 0), carry)
    cur_len = builder.load(work_len_slot)
    builder.store(cur_len, div_idx)

    div_inner_cond = func.append_basic_block('div_inner_cond')
    div_inner_body = func.append_basic_block('div_inner_body')
    div_inner_end = func.append_basic_block('div_inner_end')
    builder.branch(div_inner_cond)

    # === div_inner_cond ===
    builder.position_at_end(div_inner_cond)
    i_val = builder.load(div_idx)
    inner_cont = builder.icmp_signed('>=', i_val, one)
    builder.cbranch(inner_cont, div_inner_body, div_inner_end)

    # === div_inner_body: compute (carry * 2^64 + digit) / 10 ===
    builder.position_at_end(div_inner_body)
    work_data_ptr_ptr2 = builder.gep(work_array, [zero_32, ARRAY_DATA])
    work_data_ptr2 = builder.load(work_data_ptr_ptr2)
    cur_digit_ptr = builder.gep(work_data_ptr2, [i_val])
    cur_digit = builder.load(cur_digit_ptr)
    carry_val = builder.load(carry)

    q1 = builder.mul(carry_val, DIV_CONST)
    partial = builder.mul(carry_val, MOD_CONST)
    temp = builder.add(partial, cur_digit)
    is_overflow = builder.icmp_unsigned('<', temp, cur_digit)
    q2 = builder.udiv(temp, TEN)
    rem = builder.urem(temp, TEN)
    extra_q = builder.select(is_overflow, DIV_CONST, ir.Constant(type_map[INT64], 0))
    rem_adj = builder.select(is_overflow, MOD_CONST, ir.Constant(type_map[INT64], 0))
    rem_sum = builder.add(rem, rem_adj)
    new_carry = builder.urem(rem_sum, TEN)
    rem_carry_q = builder.udiv(rem_sum, TEN)
    new_digit = builder.add(q1, q2)
    new_digit = builder.add(new_digit, extra_q)
    new_digit = builder.add(new_digit, rem_carry_q)

    builder.store(new_digit, cur_digit_ptr)
    builder.store(new_carry, carry)
    builder.store(builder.sub(i_val, one), div_idx)
    builder.branch(div_inner_cond)

    # === div_inner_end: store remainder and trim ===
    builder.position_at_end(div_inner_end)
    final_carry = builder.load(carry)
    builder.call(append_func, [decimal_digits, final_carry])

    # Trim leading zeros
    trim_cond = func.append_basic_block('trim_cond')
    trim_body = func.append_basic_block('trim_body')
    trim_do = func.append_basic_block('trim_do')
    trim_end = func.append_basic_block('trim_end')
    builder.branch(trim_cond)

    builder.position_at_end(trim_cond)
    trim_size_ptr = builder.gep(work_array, [zero_32, ARRAY_SIZE])
    cur_work_len = builder.load(trim_size_ptr)
    has_elements = builder.icmp_signed('>', cur_work_len, zero)
    builder.cbranch(has_elements, trim_body, trim_end)

    builder.position_at_end(trim_body)
    trim_data_ptr_ptr = builder.gep(work_array, [zero_32, ARRAY_DATA])
    trim_data_ptr = builder.load(trim_data_ptr_ptr)
    top_val_ptr = builder.gep(trim_data_ptr, [cur_work_len])
    top_val = builder.load(top_val_ptr)
    is_zero_top = builder.icmp_unsigned('==', top_val, ir.Constant(type_map[INT64], 0))
    has_more = builder.icmp_signed('>', cur_work_len, one)
    should_trim = builder.and_(is_zero_top, has_more)
    builder.cbranch(should_trim, trim_do, trim_end)

    builder.position_at_end(trim_do)
    new_size = builder.sub(cur_work_len, one)
    builder.store(new_size, trim_size_ptr)
    builder.branch(trim_cond)

    builder.position_at_end(trim_end)
    new_work_len = builder.load(trim_size_ptr)
    builder.store(new_work_len, work_len_slot)
    builder.branch(div_loop)

    # === div_end: done converting, now print ===
    builder.position_at_end(div_end)
    dec_size_ptr = builder.gep(decimal_digits, [zero_32, ARRAY_SIZE])
    dec_len = builder.load(dec_size_ptr)
    has_dec = builder.icmp_signed('>', dec_len, zero)
    builder.cbranch(has_dec, print_digits, print_zero)

    # === print_zero ===
    builder.position_at_end(print_zero)
    builder.call(printf, [builder.bitcast(zero_fmt, type_map[INT8].as_pointer())])
    builder.branch(end_block)

    # === print_digits: calculate adjusted exponent and print ===
    builder.position_at_end(print_digits)
    # adjusted_exp = exponent + dec_len - 1
    dec_len_64 = builder.sext(dec_len, type_map[INT64])
    adj_exp = builder.add(exponent_val, builder.sub(dec_len_64, ir.Constant(type_map[INT64], 1)))
    builder.store(adj_exp, adjusted_exp_slot)

    # Check sign
    builder.cbranch(sign_val, neg_block, after_sign)

    # === neg_block ===
    builder.position_at_end(neg_block)
    minus_fmt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 2), name="dec_minus_fmt")
    if not minus_fmt.initializer:
        minus_fmt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 2), bytearray(b"-\00"))
        minus_fmt.global_constant = True
    builder.call(printf, [builder.bitcast(minus_fmt, type_map[INT8].as_pointer())])
    builder.branch(after_sign)

    # === after_sign: print first digit ===
    builder.position_at_end(after_sign)
    builder.store(dec_len, print_idx)  # Start from highest (dec_len, 1-based)
    builder.branch(print_first)

    # === print_first: print first digit ===
    builder.position_at_end(print_first)
    p_idx = builder.load(print_idx)
    dec_data_ptr_ptr = builder.gep(decimal_digits, [zero_32, ARRAY_DATA])
    dec_data_ptr = builder.load(dec_data_ptr_ptr)
    first_val_ptr = builder.gep(dec_data_ptr, [p_idx])
    first_val = builder.load(first_val_ptr)

    digit_fmt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 5), name="dec_digit_fmt")
    if not digit_fmt.initializer:
        digit_fmt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 5), bytearray(b"%llu\00"))
        digit_fmt.global_constant = True
    builder.call(printf, [builder.bitcast(digit_fmt, type_map[INT8].as_pointer()), first_val])

    builder.store(builder.sub(p_idx, one), print_idx)
    builder.branch(check_more)

    # === check_more: check if more digits ===
    builder.position_at_end(check_more)
    remaining = builder.load(print_idx)
    has_more_digits = builder.icmp_signed('>=', remaining, one)
    builder.cbranch(has_more_digits, print_dot, check_exp)

    # === print_dot: print decimal point ===
    builder.position_at_end(print_dot)
    dot_fmt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 2), name="dec_dot_fmt")
    if not dot_fmt.initializer:
        dot_fmt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 2), bytearray(b".\00"))
        dot_fmt.global_constant = True
    builder.call(printf, [builder.bitcast(dot_fmt, type_map[INT8].as_pointer())])
    builder.branch(frac_cond)

    # === frac_cond: print remaining digits ===
    builder.position_at_end(frac_cond)
    f_idx = builder.load(print_idx)
    f_cont = builder.icmp_signed('>=', f_idx, one)
    builder.cbranch(f_cont, frac_body, frac_end)

    # === frac_body ===
    builder.position_at_end(frac_body)
    dec_data_ptr_ptr2 = builder.gep(decimal_digits, [zero_32, ARRAY_DATA])
    dec_data_ptr2 = builder.load(dec_data_ptr_ptr2)
    frac_val_ptr = builder.gep(dec_data_ptr2, [f_idx])
    frac_val = builder.load(frac_val_ptr)
    builder.call(printf, [builder.bitcast(digit_fmt, type_map[INT8].as_pointer()), frac_val])
    builder.store(builder.sub(f_idx, one), print_idx)
    builder.branch(frac_cond)

    # === frac_end ===
    builder.position_at_end(frac_end)
    builder.branch(check_exp)

    # === check_exp: print exponent if non-zero ===
    builder.position_at_end(check_exp)
    final_exp = builder.load(adjusted_exp_slot)
    exp_is_zero = builder.icmp_signed('==', final_exp, ir.Constant(type_map[INT64], 0))
    builder.cbranch(exp_is_zero, skip_exp, print_exp)

    # === print_exp ===
    builder.position_at_end(print_exp)
    exp_fmt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 6), name="dec_exp_fmt")
    if not exp_fmt.initializer:
        exp_fmt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 6), bytearray(b"e%lld\00"))
        exp_fmt.global_constant = True
    builder.call(printf, [builder.bitcast(exp_fmt, type_map[INT8].as_pointer()), final_exp])
    builder.branch(skip_exp)

    # === skip_exp: print newline ===
    builder.position_at_end(skip_exp)
    nl_fmt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 2), name="dec_nl_fmt")
    if not nl_fmt.initializer:
        nl_fmt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 2), bytearray(b"\n\00"))
        nl_fmt.global_constant = True
    builder.call(printf, [builder.bitcast(nl_fmt, type_map[INT8].as_pointer())])
    builder.branch(end_block)

    # === end_block ===
    builder.position_at_end(end_block)
    builder.ret_void()


def define_print_number(self):
    # Runtime dispatch based on tag
    number_struct = type_map[NUMBER]
    func_type = ir.FunctionType(type_map[VOID], [number_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'print_number')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    num_ptr = func.args[0]
    # Number: { header, type_tag, data } - tag is at index 1
    tag_ptr = builder.gep(num_ptr, [zero_32, one_32])
    tag = builder.load(tag_ptr)
    
    # Switch on tag
    # 0: int, 1: float, 2: bigint, 3: decimal
    
    int_block = func.append_basic_block('case_int')
    float_block = func.append_basic_block('case_float')
    bigint_block = func.append_basic_block('case_bigint')
    decimal_block = func.append_basic_block('case_decimal')
    end_block = func.append_basic_block('end')
    
    switch = builder.switch(tag, end_block)
    switch.add_case(ir.Constant(type_map[INT8], 0), int_block)
    switch.add_case(ir.Constant(type_map[INT8], 1), float_block)
    switch.add_case(ir.Constant(type_map[INT8], 2), bigint_block)
    switch.add_case(ir.Constant(type_map[INT8], 3), decimal_block)
    
    # Case Int
    builder.position_at_end(int_block)
    # Number: { header, type_tag, data } - data at index 2
    data_field_ptr = builder.gep(num_ptr, [zero_32, two_32])
    data_ptr = builder.load(data_field_ptr)
    int_ptr = builder.bitcast(data_ptr, type_map[INT].as_pointer())
    val_int = builder.load(int_ptr)
    # Using printf manually? or reusing print_num logic? 
    # We can't reuse CodeGenerator methods here easily.
    # We will declare external printf.
    printf = self.module.globals.get('printf')
    if not printf:
        top_func_type = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer()], var_arg=True)
        printf = ir.Function(self.module, top_func_type, 'printf')
    
    # Format string "%lld\n" (allocating global string)
    # Actually, let's keep it simple: cast to generic printing or just use the simplest path.
    # Issue: creating global strings inside a function builder is annoying.
    # Let's assume we can use `print_bigint` style? No, int is primitive.
    
    # HACK: Create a temp array, put int in it, print array? 'd' again?
    # Better: Use `i64_to_str` -> print(str).
    # We have `define_int_to_str(self, str_struct_ptr)`.
    # But that defines the function.
    # We can CALL `int_to_str`.
    # But `int_to_str` might not be exposed as global func name?
    # builtins.py says: `define_int_to_str`. It creates function `int_to_str`.
    # YES.
    
    # So: int -> string -> print(string).
    # string in Meteor is `i64.array`.
    
    # Case Int Implementation:
    # str_array = create_array(INT)
    # int_to_str(str_array, val_int)
    # print(str_array)
    
    # We need to create array. `i64.array.init` etc.
    # This is getting complex to instantiate manually in IR.
    
    # Fallback: Just use `printf`.
    # Global string creation:
    # We need a "%lld" string.
    
    fmt_str = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 6), name="fmt_lld")
    if not fmt_str.initializer:
        fmt_str.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 6), bytearray(b"%lld\n\00"))
        fmt_str.global_constant = True
        
    builder.call(printf, [builder.bitcast(fmt_str, type_map[INT8].as_pointer()), val_int])
    builder.branch(end_block)
    
    # Case Float
    builder.position_at_end(float_block)
    # data at index 2
    data_field_ptr = builder.gep(num_ptr, [zero_32, two_32])
    data_ptr = builder.load(data_field_ptr)
    dbl_ptr = builder.bitcast(data_ptr, type_map[DOUBLE].as_pointer())
    val_dbl = builder.load(dbl_ptr)
    
    fmt_str_f = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 4), name="fmt_f")
    if not fmt_str_f.initializer:
        fmt_str_f.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 4), bytearray(b"%g\n\00"))
        fmt_str_f.global_constant = True

    builder.call(printf, [builder.bitcast(fmt_str_f, type_map[INT8].as_pointer()), val_dbl])
    builder.branch(end_block)

    # Case BigInt
    builder.position_at_end(bigint_block)
    # data at index 2
    data_field_ptr = builder.gep(num_ptr, [zero_32, two_32])
    data_ptr = builder.load(data_field_ptr)
    # Here data_ptr matches bigint* layout (it was bitcasted from bigint*)
    # So we can just cast it back and call print_bigint
    # Wait, in assignment: `data_ptr = builder.bitcast(val, i8*)`. `val` was pointer to bigint struct? 
    # In `code_generator`: `data_ptr = self.builder.bitcast(val, type_map[INT8].as_pointer())` where val IS pointer to bigint.
    # So yes, bitcast back.
    bigint_ptr = builder.bitcast(data_ptr, type_map[BIGINT].as_pointer())
    builder.call(self.module.get_global('print_bigint'), [bigint_ptr])
    builder.branch(end_block)

    # Case Decimal
    builder.position_at_end(decimal_block)
    # data at index 2
    data_field_ptr = builder.gep(num_ptr, [zero_32, two_32])
    data_ptr = builder.load(data_field_ptr)
    decimal_ptr = builder.bitcast(data_ptr, type_map[DECIMAL].as_pointer())
    builder.call(self.module.get_global('print_decimal'), [decimal_ptr])
    builder.branch(end_block)

    builder.position_at_end(end_block)
    builder.ret_void()


def define_bigint_add(self):
    # bigint_add(bigint*, bigint*) -> bigint*
    # Returns pointer to new bigint.
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_add')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    a_ptr = func.args[0]
    b_ptr = func.args[1]
    
    # Check signs? For MVP assume explicit positive addition logic for now. 
    # Logic: c = a + b
    
    # 1. Allocate Result BigInt
    res_ptr = builder.alloca(bigint_struct, name="res")
    
    # 2. Get Arrays (BigInt: { header, sign, digits* } - digits at index 2)
    # a.digits
    a_digits_ptr_ptr = builder.gep(a_ptr, [zero_32, two_32])
    a_digits = builder.load(a_digits_ptr_ptr)
    # b.digits
    b_digits_ptr_ptr = builder.gep(b_ptr, [zero_32, two_32])
    b_digits = builder.load(b_digits_ptr_ptr)
    
    # 3. Create Result Array (Heap Allocated)
    # Using malloc to ensure the array struct persists after return.
    # sizeof(i64.array) = 8 (size) + 8 (capacity) + 8 (ptr) = 24 bytes
    malloc_func = self.module.get_global('malloc')
    if not malloc_func:
        char_ptr = type_map[INT8].as_pointer()
        malloc_type = ir.FunctionType(char_ptr, [type_map[INT]])
        malloc_func = ir.Function(self.module, malloc_type, 'malloc')
        
    res_digits_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    u64_array_type = self.module.context.get_identified_type('i64.array')
    res_digits = builder.bitcast(res_digits_mem, u64_array_type.as_pointer())
    
    # Initialize
    init_func = self.module.get_global('i64.array.init')
    builder.call(init_func, [res_digits])
    
    # 4. Addition Loop
    # We'll use a simple loop over the max length. 
    # Get lengths
    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    append_func = self.module.get_global('i64.array.append')

    idx_ptr = builder.alloca(type_map[INT64], name="idx")
    builder.store(zero, idx_ptr)
    carry_ptr = builder.alloca(type_map[INT64], name="carry")
    builder.store(zero, carry_ptr)

    # Allocate val_a and val_b at entry (not in loop!)
    val_a_ptr = builder.alloca(type_map[INT64], name="val_a")
    val_b_ptr = builder.alloca(type_map[INT64], name="val_b")

    len_a = builder.call(len_func, [a_digits])
    len_b = builder.call(len_func, [b_digits])
    
    cond_block = func.append_basic_block('cond')
    body_block = func.append_basic_block('body')
    end_block = func.append_basic_block('end')
    
    builder.branch(cond_block)
    
    # Condition: idx < len_a || idx < len_b || carry != 0
    builder.position_at_end(cond_block)
    idx = builder.load(idx_ptr)
    carry = builder.load(carry_ptr)
    
    # Restoring c1 which was deleted inadvertently
    c1 = builder.icmp_signed(LESS_THAN, idx, len_a)
    c2 = builder.icmp_signed(LESS_THAN, idx, len_b)
    c3 = builder.icmp_signed(NOT_EQUALS, carry, zero)
    cond = builder.or_(builder.or_(c1, c2), c3)
    

    builder.cbranch(cond, body_block, end_block)
    
    # Body
    builder.position_at_end(body_block)

    # val_a = (idx < len_a) ? a[idx] : 0
    builder.store(zero, val_a_ptr)
    with builder.if_then(c1):
        val = builder.call(get_func, [a_digits, idx])
        builder.store(val, val_a_ptr)

    # val_b = (idx < len_b) ? b[idx] : 0
    builder.store(zero, val_b_ptr)
    with builder.if_then(c2):
        val = builder.call(get_func, [b_digits, idx])
        builder.store(val, val_b_ptr)
        
    # sum = val_a + val_b + carry
    val_a_loaded = builder.load(val_a_ptr)
    val_b_loaded = builder.load(val_b_ptr)
    carry_loaded = builder.load(carry_ptr)
    
    sum_1 = builder.add(val_a_loaded, val_b_loaded)
    carry_1 = builder.icmp_unsigned(LESS_THAN, sum_1, val_a_loaded)
    
    total_sum = builder.add(sum_1, carry_loaded)
    carry_2 = builder.icmp_unsigned(LESS_THAN, total_sum, sum_1)
    
    total_carry_i1 = builder.or_(carry_1, carry_2)
    total_carry = builder.zext(total_carry_i1, type_map[INT64])
    builder.store(total_carry, carry_ptr)
    
    builder.call(append_func, [res_digits, total_sum])
    
    builder.store(builder.add(idx, one), idx_ptr)
    builder.branch(cond_block)
    
    # End
    builder.position_at_end(end_block)
    
    # Assign digits to result
    res_digits_ptr = builder.gep(res_ptr, [zero_32, BIGINT_DIGITS])
    builder.store(res_digits, res_digits_ptr)

    # Sign (positive)
    res_sign_ptr = builder.gep(res_ptr, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), res_sign_ptr)
    
    res_val = builder.load(res_ptr)
    builder.ret(res_val)

    # Dead code removed




def define_bigint_neg(self):
    # bigint_neg(bigint*) -> bigint*
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_neg')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    val_ptr = func.args[0]
    
    # helper functions
    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    
    # Allocate Result
    res_ptr = builder.alloca(bigint_struct, name="res")
    
    # Malloc array for result
    malloc_func = self.module.get_global('malloc')
    res_digits_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    u64_array_type = self.module.context.get_identified_type('i64.array')
    res_digits = builder.bitcast(res_digits_mem, u64_array_type.as_pointer())
    builder.call(init_func, [res_digits])
    
    # Copy sign and flip
    sign_ptr = builder.gep(val_ptr, [zero_32, BIGINT_SIGN])
    sign_val = builder.load(sign_ptr)
    new_sign = builder.not_(sign_val)

    res_sign_ptr = builder.gep(res_ptr, [zero_32, BIGINT_SIGN])
    builder.store(new_sign, res_sign_ptr)

    # Copy Digits
    digits_ptr_ptr = builder.gep(val_ptr, [zero_32, BIGINT_DIGITS])
    digits = builder.load(digits_ptr_ptr)
    
    num_digits = builder.call(len_func, [digits])
    
    # Copy loop
    idx_ptr = builder.alloca(type_map[INT])
    builder.store(zero, idx_ptr)
    
    cond_block = func.append_basic_block('cond')
    body_block = func.append_basic_block('body')
    end_block = func.append_basic_block('end')
    
    builder.branch(cond_block)
    
    builder.position_at_end(cond_block)
    idx = builder.load(idx_ptr)
    cond = builder.icmp_signed(LESS_THAN, idx, num_digits)
    builder.cbranch(cond, body_block, end_block)
    
    builder.position_at_end(body_block)
    val = builder.call(get_func, [digits, idx])
    builder.call(append_func, [res_digits, val])
    builder.store(builder.add(idx, one), idx_ptr)
    builder.branch(cond_block)
    
    builder.position_at_end(end_block)
    
    res_digits_ptr = builder.gep(res_ptr, [zero_32, two_32])  # digits at index 2
    builder.store(res_digits, res_digits_ptr)
    
    builder.ret(builder.load(res_ptr))


def define_bigint_cmp(self):
    # bigint_cmp(bigint*, bigint*) -> i32
    # -1: a < b
    #  0: a == b
    #  1: a > b
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(type_map[INT32], [bigint_struct.as_pointer(), bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_cmp')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    a_ptr = func.args[0]
    b_ptr = func.args[1]
    
    # helper functions
    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    
    # 1. Check signs
    a_sign_ptr = builder.gep(a_ptr, [zero_32, BIGINT_SIGN])
    a_sign = builder.load(a_sign_ptr) # 1 = neg, 0 = pos
    b_sign_ptr = builder.gep(b_ptr, [zero_32, BIGINT_SIGN])
    b_sign = builder.load(b_sign_ptr)
    
    # If a is neg (1) and b is pos (0) -> -1
    # If a is pos (0) and b is neg (1) -> 1
    
    ret_neg = ir.Constant(type_map[INT32], -1)
    ret_pos = ir.Constant(type_map[INT32], 1)
    ret_zero = ir.Constant(type_map[INT32], 0)
    
    diff_signs_block = func.append_basic_block('diff_signs')
    same_signs_block = func.append_basic_block('same_signs')
    
    signs_diff = builder.icmp_unsigned(NOT_EQUALS, a_sign, b_sign)
    builder.cbranch(signs_diff, diff_signs_block, same_signs_block)
    
    # Different Signs
    builder.position_at_end(diff_signs_block)
    # If a_sign is True (neg), then a < b (return -1)
    # Else a is pos, b is neg, a > b (return 1)
    res_diff = builder.select(a_sign, ret_neg, ret_pos)
    builder.ret(res_diff)
    
    # Same Signs
    builder.position_at_end(same_signs_block)

    # Compare Magnitudes and Lengths
    a_digits = builder.load(builder.gep(a_ptr, [zero_32, two_32]))  # digits at index 2
    b_digits = builder.load(builder.gep(b_ptr, [zero_32, two_32]))  # digits at index 2
    
    len_a = builder.call(len_func, [a_digits])
    len_b = builder.call(len_func, [b_digits])
    
    len_diff = builder.icmp_signed(NOT_EQUALS, len_a, len_b)
    len_check_block = func.append_basic_block('len_check')
    digits_check_block = func.append_basic_block('digits_check')
    
    builder.cbranch(len_diff, len_check_block, digits_check_block)
    
    builder.position_at_end(len_check_block)
    # Different lengths.
    # If both positive: longer is larger.
    # If both negative: longer is smaller.
    
    # We know signs are same. a_sign tells us if they are negative.
    
    a_longer = builder.icmp_signed(GREATER_THAN, len_a, len_b)
    
    # result if positive: a_longer ? 1 : -1
    res_len_pos = builder.select(a_longer, ret_pos, ret_neg)
    # result if negative: a_longer ? -1 : 1
    res_len_neg = builder.select(a_longer, ret_neg, ret_pos)
    
    res_len = builder.select(a_sign, res_len_neg, res_len_pos)
    builder.ret(res_len)
    
    builder.position_at_end(digits_check_block)
    # Same sign, same length. Compare digits from high to low.
    
    loop_cond = func.append_basic_block('loop_cond')
    loop_body = func.append_basic_block('loop_body')
    loop_end = func.append_basic_block('loop_end') # equal
    
    idx_ptr = builder.alloca(type_map[INT])
    # Start from len - 1
    start_idx = builder.sub(len_a, one)
    builder.store(start_idx, idx_ptr)
    
    builder.branch(loop_cond)
    
    builder.position_at_end(loop_cond)
    curr_idx = builder.load(idx_ptr)
    has_more = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, curr_idx, zero)
    builder.cbranch(has_more, loop_body, loop_end)
    
    builder.position_at_end(loop_body)
    digit_a = builder.call(get_func, [a_digits, curr_idx])
    digit_b = builder.call(get_func, [b_digits, curr_idx])
    
    digits_neq = builder.icmp_unsigned(NOT_EQUALS, digit_a, digit_b)
    digits_diff_block = func.append_basic_block('digits_diff')
    continue_block = func.append_basic_block('continue')
    
    builder.cbranch(digits_neq, digits_diff_block, continue_block)
    
    builder.position_at_end(digits_diff_block)
    # Found difference.
    a_greater = builder.icmp_unsigned(GREATER_THAN, digit_a, digit_b)
    
    # If positive: a_greater ? 1 : -1
    res_dig_pos = builder.select(a_greater, ret_pos, ret_neg)
    # If negative: a_greater ? -1 : 1
    res_dig_neg = builder.select(a_greater, ret_neg, ret_pos)
    
    res_dig = builder.select(a_sign, res_dig_neg, res_dig_pos)
    builder.ret(res_dig)
    
    builder.position_at_end(continue_block)
    builder.store(builder.sub(curr_idx, one), idx_ptr)
    builder.branch(loop_cond)
    
    builder.position_at_end(loop_end)
    # All equal
    builder.ret(ret_zero)


def define_bigint_sub(self):
    # bigint_sub(bigint*, bigint*) -> bigint*
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_sub')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    a_ptr = func.args[0]
    b_ptr = func.args[1]
    
    # helper functions
    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    add_func = self.module.get_global('bigint_add') # Handles add of magnitudes essentially

    # helpers
    zero_i32 = ir.Constant(type_map[INT32], 0)
    one_i32 = ir.Constant(type_map[INT32], 1)
    u64_array_type = self.module.context.get_identified_type('i64.array')

    # 1. Check signs
    a_sign_ptr = builder.gep(a_ptr, [zero_32, BIGINT_SIGN])
    a_sign = builder.load(a_sign_ptr)
    b_sign_ptr = builder.gep(b_ptr, [zero_32, BIGINT_SIGN])
    b_sign = builder.load(b_sign_ptr)
    
    signs_diff_block = func.append_basic_block('signs_diff')
    signs_same_block = func.append_basic_block('signs_same')
    
    signs_neq = builder.icmp_unsigned(NOT_EQUALS, a_sign, b_sign)
    builder.cbranch(signs_neq, signs_diff_block, signs_same_block)
    
    # --- Different Signs ---
    builder.position_at_end(signs_diff_block)
    # result = |a| + |b|. Sign depends on a.
    # bigint_add computes |a| + |b| and returns positive result.
    res_add = builder.call(add_func, [a_ptr, b_ptr])
    
    # res_add is a struct Value. Need to store to modify.
    res_add_ptr = builder.alloca(bigint_struct)
    builder.store(res_add, res_add_ptr)
    
    # Modification: if a is neg, res is neg.
    res_add_sign_ptr = builder.gep(res_add_ptr, [zero_32, BIGINT_SIGN])
    builder.store(a_sign, res_add_sign_ptr)
    
    builder.ret(builder.load(res_add_ptr))
    
    # --- Same Signs ---
    builder.position_at_end(signs_same_block)

    # Compare Magnitudes
    a_digits = builder.load(builder.gep(a_ptr, [zero_32, two_32]))  # digits at index 2
    b_digits = builder.load(builder.gep(b_ptr, [zero_32, two_32]))  # digits at index 2
    
    len_a = builder.call(len_func, [a_digits])
    len_b = builder.call(len_func, [b_digits])
    
    # Determine swap
    x_ptr_mem = builder.alloca(bigint_struct.as_pointer())
    y_ptr_mem = builder.alloca(bigint_struct.as_pointer())
    swapped_mem = builder.alloca(type_map[BOOL])
    
    builder.store(a_ptr, x_ptr_mem)
    builder.store(b_ptr, y_ptr_mem)
    builder.store(ir.Constant(type_map[BOOL], 0), swapped_mem)
    
    # Compare lengths
    len_diff = builder.icmp_signed(NOT_EQUALS, len_a, len_b)
    
    len_check = func.append_basic_block('len_check')
    digits_check = func.append_basic_block('digits_check')
    set_x_y = func.append_basic_block('set_x_y')
    
    builder.cbranch(len_diff, len_check, digits_check)
    
    builder.position_at_end(len_check)
    l_b_gt = builder.icmp_signed(GREATER_THAN, len_b, len_a)
    builder.store(l_b_gt, swapped_mem)
    builder.branch(set_x_y)
    
    builder.position_at_end(digits_check)
    # Same length. Loop high to low.
    
    d_loop_cond = func.append_basic_block('d_loop_cond')
    d_loop_body = func.append_basic_block('d_loop_body')
    d_loop_end = func.append_basic_block('d_loop_end')
    
    d_idx = builder.alloca(type_map[INT])
    builder.store(builder.sub(len_a, one), d_idx)
    
    builder.branch(d_loop_cond)
    
    builder.position_at_end(d_loop_cond)
    d_i = builder.load(d_idx)
    d_cont = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, d_i, zero)
    builder.cbranch(d_cont, d_loop_body, d_loop_end)
    
    builder.position_at_end(d_loop_body)
    val_a = builder.call(get_func, [a_digits, d_i])
    val_b = builder.call(get_func, [b_digits, d_i])
    
    vals_neq = builder.icmp_unsigned(NOT_EQUALS, val_a, val_b)
    
    d_diff = func.append_basic_block('d_diff')
    d_next = func.append_basic_block('d_next')
    
    builder.cbranch(vals_neq, d_diff, d_next)
    
    builder.position_at_end(d_diff)
    b_gt_a = builder.icmp_unsigned(GREATER_THAN, val_b, val_a)
    builder.store(b_gt_a, swapped_mem)
    builder.branch(set_x_y)
    
    builder.position_at_end(d_next)
    builder.store(builder.sub(d_i, one), d_idx)
    builder.branch(d_loop_cond)
    
    builder.position_at_end(d_loop_end)
    # Equal. swapped = false. result = 0.
    builder.branch(set_x_y)
    
    builder.position_at_end(set_x_y)
    is_swapped = builder.load(swapped_mem)
    
    select_x = builder.select(is_swapped, b_ptr, a_ptr)
    select_y = builder.select(is_swapped, a_ptr, b_ptr)
    
    builder.store(select_x, x_ptr_mem)
    builder.store(select_y, y_ptr_mem)
    
    x_final = builder.load(x_ptr_mem)
    y_final = builder.load(y_ptr_mem)
    
    x_digits = builder.load(builder.gep(x_final, [zero_32, two_32]))  # digits at index 2
    y_digits = builder.load(builder.gep(y_final, [zero_32, two_32]))  # digits at index 2
    len_x = builder.call(len_func, [x_digits])
    len_y = builder.call(len_func, [y_digits])
    
    # Algorithm: |x| - |y|
    
    # 1. Allocate Result
    res_sub_ptr = builder.alloca(bigint_struct)
    
    malloc_func = self.module.get_global('malloc')
    res_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    res_digits = builder.bitcast(res_mem, u64_array_type.as_pointer())
    builder.call(init_func, [res_digits])
    
    # Loop over x digits
    
    sub_loop_cond = func.append_basic_block('sub_loop_cond')
    sub_loop_body = func.append_basic_block('sub_loop_body')
    sub_loop_end = func.append_basic_block('sub_loop_end')
    
    i_ptr = builder.alloca(type_map[INT])
    builder.store(zero, i_ptr)
    borrow_ptr = builder.alloca(type_map[INT64])
    builder.store(ir.Constant(type_map[INT64], 0), borrow_ptr)
    # Allocate dy_ptr at entry (not in loop!)
    dy_ptr = builder.alloca(type_map[INT64])
    
    builder.branch(sub_loop_cond)
    
    builder.position_at_end(sub_loop_cond)
    i = builder.load(i_ptr)
    cond = builder.icmp_signed(LESS_THAN, i, len_x)
    builder.cbranch(cond, sub_loop_body, sub_loop_end)
    
    builder.position_at_end(sub_loop_body)

    dx = builder.call(get_func, [x_digits, i])

    # Initialize dy_ptr (reuse alloca from entry)
    builder.store(ir.Constant(type_map[INT64], 0), dy_ptr)
    
    has_y = builder.icmp_signed(LESS_THAN, i, len_y)
    with builder.if_then(has_y):
        val = builder.call(get_func, [y_digits, i])
        builder.store(val, dy_ptr)
        
    dy = builder.load(dy_ptr)
    borrow = builder.load(borrow_ptr)
    
    # diff = dx - dy - borrow
    sub1 = builder.sub(dx, dy)
    borrow1 = builder.icmp_unsigned(LESS_THAN, dx, dy)
    
    diff = builder.sub(sub1, borrow)
    borrow2 = builder.icmp_unsigned(LESS_THAN, sub1, borrow)
    
    new_borrow_i1 = builder.or_(borrow1, borrow2)
    new_borrow = builder.zext(new_borrow_i1, type_map[INT64])
    
    builder.store(new_borrow, borrow_ptr)
    builder.call(append_func, [res_digits, diff])
    
    builder.store(builder.add(i, one), i_ptr)
    builder.branch(sub_loop_cond)
    
    builder.position_at_end(sub_loop_end)
    
    # Strip leading zeros
    trim_cond = func.append_basic_block('trim_cond')
    trim_body = func.append_basic_block('trim_body')
    trim_end = func.append_basic_block('trim_end')
    
    builder.branch(trim_cond)
    
    builder.position_at_end(trim_cond)
    cur_len = builder.call(len_func, [res_digits])
    can_trim = builder.icmp_signed(GREATER_THAN, cur_len, one)
    
    check_zero_block = func.append_basic_block('check_zero')
    
    builder.cbranch(can_trim, check_zero_block, trim_end)
    
    builder.position_at_end(check_zero_block)
    last_idx = builder.sub(cur_len, one)
    last_val = builder.call(get_func, [res_digits, last_idx])
    is_zero = builder.icmp_unsigned(EQUALS, last_val, ir.Constant(type_map[INT64], 0))
    builder.cbranch(is_zero, trim_body, trim_end)
    
    builder.position_at_end(trim_body)
    size_ptr = builder.gep(res_digits, [zero_32, ARRAY_SIZE])
    new_size = builder.sub(cur_len, one)
    builder.store(new_size, size_ptr)
    builder.branch(trim_cond)
    
    builder.position_at_end(trim_end)
    
    res_digits_res_ptr = builder.gep(res_sub_ptr, [zero_32, BIGINT_DIGITS])
    builder.store(res_digits, res_digits_res_ptr)

    final_sign_ptr = builder.gep(res_sub_ptr, [zero_32, BIGINT_SIGN])
    
    sign_if_swapped = builder.not_(a_sign)
    sign_if_not = a_sign
    
    final_sign = builder.select(is_swapped, sign_if_swapped, sign_if_not)
    builder.store(final_sign, final_sign_ptr)
    
    # Special case: if result is 0, sign should be 0 (pos)
    r_len = builder.call(len_func, [res_digits])
    r_is_one = builder.icmp_signed(EQUALS, r_len, one)
    r_val = builder.call(get_func, [res_digits, zero])
    r_is_zero_val = builder.icmp_unsigned(EQUALS, r_val, ir.Constant(type_map[INT64], 0))
    is_result_zero = builder.and_(r_is_one, r_is_zero_val)
    
    with builder.if_then(is_result_zero):
        builder.store(ir.Constant(type_map[BOOL], 0), final_sign_ptr)

    builder.ret(builder.load(res_sub_ptr))


def define_free_bigint(self):
    # free_bigint(bigint*)
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(type_map[VOID], [bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'free_bigint')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    bigint_ptr = func.args[0]
    
    # Check if pointer is null
    null_ptr = ir.Constant(bigint_struct.as_pointer(), None)
    is_null = builder.icmp_unsigned(EQUALS, bigint_ptr, null_ptr)
    
    not_null_block = func.append_basic_block('not_null')
    end_block = func.append_basic_block('end')
    
    builder.cbranch(is_null, end_block, not_null_block)
    
    builder.position_at_end(not_null_block)
    
    # Get digits pointer (BigInt: { header, sign, digits* } - digits at index 2)
    digits_ptr_ptr = builder.gep(bigint_ptr, [zero_32, two_32])
    digits = builder.load(digits_ptr_ptr)
    
    # Check if digits is null
    u64_array_type = self.module.context.get_identified_type('i64.array')
    digits_null_ptr = ir.Constant(u64_array_type.as_pointer(), None)
    digits_not_null = builder.icmp_unsigned(NOT_EQUALS, digits, digits_null_ptr)
    
    free_digits_block = func.append_basic_block('free_digits')
    
    builder.cbranch(digits_not_null, free_digits_block, end_block)
    
    builder.position_at_end(free_digits_block)

    # Check RefCount from header (Array: { header, size, capacity, data })
    # Header is at index 0, strong_rc is at HEADER_STRONG_RC (0) within header
    from meteor.compiler.base import HEADER_STRONG_RC
    header_ptr = builder.gep(digits, [zero_32, ARRAY_HEADER], inbounds=True)
    rc_ptr = builder.gep(header_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)], inbounds=True)
    rc = builder.load(rc_ptr)
    new_rc = builder.sub(rc, ir.Constant(type_map[UINT32], 1))
    builder.store(new_rc, rc_ptr)
    
    should_free = builder.icmp_signed(EQUALS, new_rc, zero)
    
    do_free_block = func.append_basic_block('do_free')
    
    builder.cbranch(should_free, do_free_block, end_block)
    
    builder.position_at_end(do_free_block)
    
    # Free data
    data_ptr_ptr = builder.gep(digits, [zero_32, ARRAY_DATA])
    data_ptr = builder.load(data_ptr_ptr)
    data_i8 = builder.bitcast(data_ptr, type_map[INT8].as_pointer())
    
    malloc_func = self.module.get_global('malloc') # Ensure malloc is known to get free context? 
    # Use 'free'
    free_func = self.module.get_global('free')
    if not free_func:
        free_type = ir.FunctionType(type_map[VOID], [type_map[INT8].as_pointer()])
        free_func = ir.Function(self.module, free_type, 'free')
        
    builder.call(free_func, [data_i8])
    
    # Free array struct
    digits_i8 = builder.bitcast(digits, type_map[INT8].as_pointer())
    builder.call(free_func, [digits_i8])
    
    builder.branch(end_block)
    
    builder.position_at_end(end_block)
    builder.ret_void()


def define_bigint_mul_naive(self):
    # bigint_mul_naive(bigint*, bigint*) -> bigint*
    # O(n^2) naive multiplication - used as base case for Karatsuba
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_mul_naive')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    a_ptr = func.args[0]
    b_ptr = func.args[1]
    
    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    set_func = self.module.get_global('i64.array.set')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    
    # Constants
    zero = ir.Constant(type_map[INT], 0)
    one = ir.Constant(type_map[INT], 1)
    
    # 1. Sign
    a_sign = builder.load(builder.gep(a_ptr, [zero_32, BIGINT_SIGN]))
    b_sign = builder.load(builder.gep(b_ptr, [zero_32, BIGINT_SIGN]))
    res_sign = builder.xor(a_sign, b_sign)
    
    # 2. Digits
    a_digits = builder.load(builder.gep(a_ptr, [zero_32, BIGINT_DIGITS]))
    b_digits = builder.load(builder.gep(b_ptr, [zero_32, BIGINT_DIGITS]))
    len_a = builder.call(len_func, [a_digits])
    len_b = builder.call(len_func, [b_digits])
    
    # Result
    res_mul_ptr = builder.alloca(bigint_struct)
    malloc_func = self.module.get_global('malloc')
    res_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    u64_array_type = self.module.context.get_identified_type('i64.array')
    res_digits = builder.bitcast(res_mem, u64_array_type.as_pointer())
    builder.call(init_func, [res_digits])
    
    # Pre-allocate result array with (len_a + len_b) zeros
    max_len = builder.add(len_a, len_b)
    
    fill_cond = func.append_basic_block('fill_cond')
    fill_body = func.append_basic_block('fill_body')
    fill_end = func.append_basic_block('fill_end')
    
    fill_idx = builder.alloca(type_map[INT])
    builder.store(zero, fill_idx)
    
    builder.branch(fill_cond)
    builder.position_at_end(fill_cond)
    curr_fill = builder.load(fill_idx)
    should_fill = builder.icmp_signed(LESS_THAN, curr_fill, max_len)
    builder.cbranch(should_fill, fill_body, fill_end)
    
    builder.position_at_end(fill_body)
    builder.call(append_func, [res_digits, ir.Constant(type_map[INT64], 0)])
    builder.store(builder.add(curr_fill, one), fill_idx)
    builder.branch(fill_cond)
    
    builder.position_at_end(fill_end)
    
    # Double Loop
    i_ptr = builder.alloca(type_map[INT])
    builder.store(zero, i_ptr)

    # Allocate carry_ptr and j_ptr at entry (not in loop!)
    carry_ptr = builder.alloca(type_map[INT128])
    j_ptr = builder.alloca(type_map[INT])

    outer_cond = func.append_basic_block('outer_cond')
    outer_body = func.append_basic_block('outer_body')
    outer_end = func.append_basic_block('outer_end')
    # Create inner loop blocks outside the outer loop!
    inner_cond = func.append_basic_block('inner_cond')
    inner_body = func.append_basic_block('inner_body')
    inner_end = func.append_basic_block('inner_end')
    
    builder.branch(outer_cond)
    
    builder.position_at_end(outer_cond)
    i = builder.load(i_ptr)
    outer_valid = builder.icmp_signed(LESS_THAN, i, len_a)
    builder.cbranch(outer_valid, outer_body, outer_end)
    
    builder.position_at_end(outer_body)

    da = builder.call(get_func, [a_digits, i])
    da_128 = builder.zext(da, type_map[INT128])

    # Initialize carry = 0 for this row (reuse alloca from entry)
    builder.store(ir.Constant(type_map[INT128], 0), carry_ptr)
    builder.store(zero, j_ptr)

    builder.branch(inner_cond)
    
    builder.position_at_end(inner_cond)
    j = builder.load(j_ptr)
    inner_valid = builder.icmp_signed(LESS_THAN, j, len_b)
    builder.cbranch(inner_valid, inner_body, inner_end)
    
    builder.position_at_end(inner_body)
    
    db = builder.call(get_func, [b_digits, j])
    db_128 = builder.zext(db, type_map[INT128])
    
    # idx = i + j
    idx = builder.add(i, j)
    
    # res[idx]
    existing = builder.call(get_func, [res_digits, idx])
    existing_128 = builder.zext(existing, type_map[INT128])
    
    # prod = da * db
    prod = builder.mul(da_128, db_128)
    
    # sum = prod + existing + carry
    carry = builder.load(carry_ptr)
    sum1 = builder.add(prod, existing_128)
    sum_total = builder.add(sum1, carry)
    
    # new_digit (lo 64)
    new_digit = builder.trunc(sum_total, type_map[INT64])
    builder.call(set_func, [res_digits, idx, new_digit])
    
    # new_carry (hi 64)
    shift_const = ir.Constant(type_map[INT128], 64)
    new_carry = builder.lshr(sum_total, shift_const)
    builder.store(new_carry, carry_ptr)
    
    builder.store(builder.add(j, one), j_ptr)
    builder.branch(inner_cond)
    
    builder.position_at_end(inner_end)
    
    # Store final carry to res[i + len_b]
    final_carry = builder.load(carry_ptr)
    final_carry_64 = builder.trunc(final_carry, type_map[INT64])
    
    idx_final = builder.add(i, len_b)
    builder.call(set_func, [res_digits, idx_final, final_carry_64])
    
    builder.store(builder.add(i, one), i_ptr)
    builder.branch(outer_cond)
    
    builder.position_at_end(outer_end)
    
    # Trim logic (standard copy paste or refactor? Copy paste for now)
    trim_cond = func.append_basic_block('trim_cond')
    trim_body = func.append_basic_block('trim_body')
    trim_end = func.append_basic_block('trim_end')
    
    builder.branch(trim_cond)
    
    builder.position_at_end(trim_cond)
    cur_len = builder.call(len_func, [res_digits])
    can_trim = builder.icmp_signed(GREATER_THAN, cur_len, one)
    
    check_zero_block = func.append_basic_block('check_zero')
    builder.cbranch(can_trim, check_zero_block, trim_end)
    
    builder.position_at_end(check_zero_block)
    last_idx = builder.sub(cur_len, one)
    last_val = builder.call(get_func, [res_digits, last_idx])
    is_zero = builder.icmp_unsigned(EQUALS, last_val, ir.Constant(type_map[INT64], 0))
    builder.cbranch(is_zero, trim_body, trim_end)
    
    builder.position_at_end(trim_body)
    size_ptr = builder.gep(res_digits, [zero_32, ARRAY_SIZE])
    new_size = builder.sub(cur_len, one)
    builder.store(new_size, size_ptr)
    builder.branch(trim_cond)
    
    builder.position_at_end(trim_end)
    
    # Store results
    res_digits_res_ptr = builder.gep(res_mul_ptr, [zero_32, BIGINT_DIGITS])
    builder.store(res_digits, res_digits_res_ptr)

    final_sign_ptr = builder.gep(res_mul_ptr, [zero_32, BIGINT_SIGN])
    builder.store(res_sign, final_sign_ptr)
    
    # If result is zero, sign pos
    r_len = builder.call(len_func, [res_digits])
    r_is_one = builder.icmp_signed(EQUALS, r_len, one)
    r_val = builder.call(get_func, [res_digits, zero])
    r_is_zero_val = builder.icmp_unsigned(EQUALS, r_val, ir.Constant(type_map[INT64], 0))
    is_result_zero = builder.and_(r_is_one, r_is_zero_val)
    
    with builder.if_then(is_result_zero):
        builder.store(ir.Constant(type_map[BOOL], 0), final_sign_ptr)

    builder.ret(builder.load(res_mul_ptr))


def define_bigint_split_low(self):
    """Split bigint and return low m digits"""
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), type_map[INT]])
    func = ir.Function(self.module, func_type, 'bigint_split_low')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    src_ptr = func.args[0]
    m = func.args[1]

    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    malloc_func = self.module.get_global('malloc')

    # Get source digits
    src_digits = builder.load(builder.gep(src_ptr, [zero_32, two_32]))  # digits at index 2
    src_len = builder.call(len_func, [src_digits])

    # Result
    res_ptr = builder.alloca(bigint_struct)
    u64_array_type = self.module.context.get_identified_type('i64.array')
    res_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    res_digits = builder.bitcast(res_mem, u64_array_type.as_pointer())
    builder.call(init_func, [res_digits])

    # Copy min(m, src_len) digits
    copy_len = builder.select(builder.icmp_signed('<', m, src_len), m, src_len)

    # Loop to copy
    idx_ptr = builder.alloca(type_map[INT])
    builder.store(zero, idx_ptr)

    cond_block = func.append_basic_block('cond')
    body_block = func.append_basic_block('body')
    end_block = func.append_basic_block('end')

    builder.branch(cond_block)
    builder.position_at_end(cond_block)
    idx = builder.load(idx_ptr)
    cond = builder.icmp_signed('<', idx, copy_len)
    builder.cbranch(cond, body_block, end_block)

    builder.position_at_end(body_block)
    val = builder.call(get_func, [src_digits, idx])
    builder.call(append_func, [res_digits, val])
    builder.store(builder.add(idx, one), idx_ptr)
    builder.branch(cond_block)

    builder.position_at_end(end_block)

    # If result is empty, add a zero
    res_len = builder.call(len_func, [res_digits])
    is_empty = builder.icmp_signed('==', res_len, zero)
    with builder.if_then(is_empty):
        builder.call(append_func, [res_digits, ir.Constant(type_map[INT64], 0)])

    # Copy sign
    src_sign = builder.load(builder.gep(src_ptr, [zero_32, BIGINT_SIGN]))
    builder.store(src_sign, builder.gep(res_ptr, [zero_32, BIGINT_SIGN]))
    builder.store(res_digits, builder.gep(res_ptr, [zero_32, BIGINT_DIGITS]))

    builder.ret(builder.load(res_ptr))


def define_bigint_split_high(self):
    """Split bigint and return high digits (from position m onwards)"""
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), type_map[INT]])
    func = ir.Function(self.module, func_type, 'bigint_split_high')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    src_ptr = func.args[0]
    m = func.args[1]

    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    malloc_func = self.module.get_global('malloc')

    # Get source digits
    src_digits = builder.load(builder.gep(src_ptr, [zero_32, two_32]))  # digits at index 2
    src_len = builder.call(len_func, [src_digits])

    # Result
    res_ptr = builder.alloca(bigint_struct)
    u64_array_type = self.module.context.get_identified_type('i64.array')
    res_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    res_digits = builder.bitcast(res_mem, u64_array_type.as_pointer())
    builder.call(init_func, [res_digits])

    # Copy digits from m to src_len
    idx_ptr = builder.alloca(type_map[INT])
    builder.store(m, idx_ptr)

    cond_block = func.append_basic_block('cond')
    body_block = func.append_basic_block('body')
    end_block = func.append_basic_block('end')

    builder.branch(cond_block)
    builder.position_at_end(cond_block)
    idx = builder.load(idx_ptr)
    cond = builder.icmp_signed('<', idx, src_len)
    builder.cbranch(cond, body_block, end_block)

    builder.position_at_end(body_block)
    val = builder.call(get_func, [src_digits, idx])
    builder.call(append_func, [res_digits, val])
    builder.store(builder.add(idx, one), idx_ptr)
    builder.branch(cond_block)

    builder.position_at_end(end_block)

    # If result is empty, add a zero
    res_len = builder.call(len_func, [res_digits])
    is_empty = builder.icmp_signed('==', res_len, zero)
    with builder.if_then(is_empty):
        builder.call(append_func, [res_digits, ir.Constant(type_map[INT64], 0)])

    # Copy sign
    src_sign = builder.load(builder.gep(src_ptr, [zero_32, BIGINT_SIGN]))
    builder.store(src_sign, builder.gep(res_ptr, [zero_32, BIGINT_SIGN]))
    builder.store(res_digits, builder.gep(res_ptr, [zero_32, BIGINT_DIGITS]))

    builder.ret(builder.load(res_ptr))


def define_bigint_shift_left(self):
    """Shift bigint left by m digits (multiply by B^m)"""
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), type_map[INT]])
    func = ir.Function(self.module, func_type, 'bigint_shift_left')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    src_ptr = func.args[0]
    m = func.args[1]

    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    malloc_func = self.module.get_global('malloc')

    # Get source digits
    src_digits = builder.load(builder.gep(src_ptr, [zero_32, two_32]))  # digits at index 2
    src_len = builder.call(len_func, [src_digits])

    # Result
    res_ptr = builder.alloca(bigint_struct)
    u64_array_type = self.module.context.get_identified_type('i64.array')
    res_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    res_digits = builder.bitcast(res_mem, u64_array_type.as_pointer())
    builder.call(init_func, [res_digits])

    # First add m zeros
    zero_idx_ptr = builder.alloca(type_map[INT])
    builder.store(zero, zero_idx_ptr)

    zero_cond = func.append_basic_block('zero_cond')
    zero_body = func.append_basic_block('zero_body')
    zero_end = func.append_basic_block('zero_end')

    builder.branch(zero_cond)
    builder.position_at_end(zero_cond)
    zero_idx = builder.load(zero_idx_ptr)
    zero_cond_val = builder.icmp_signed('<', zero_idx, m)
    builder.cbranch(zero_cond_val, zero_body, zero_end)

    builder.position_at_end(zero_body)
    builder.call(append_func, [res_digits, ir.Constant(type_map[INT64], 0)])
    builder.store(builder.add(zero_idx, one), zero_idx_ptr)
    builder.branch(zero_cond)

    builder.position_at_end(zero_end)

    # Then copy source digits
    copy_idx_ptr = builder.alloca(type_map[INT])
    builder.store(zero, copy_idx_ptr)

    copy_cond = func.append_basic_block('copy_cond')
    copy_body = func.append_basic_block('copy_body')
    copy_end = func.append_basic_block('copy_end')

    builder.branch(copy_cond)
    builder.position_at_end(copy_cond)
    copy_idx = builder.load(copy_idx_ptr)
    copy_cond_val = builder.icmp_signed('<', copy_idx, src_len)
    builder.cbranch(copy_cond_val, copy_body, copy_end)

    builder.position_at_end(copy_body)
    val = builder.call(get_func, [src_digits, copy_idx])
    builder.call(append_func, [res_digits, val])
    builder.store(builder.add(copy_idx, one), copy_idx_ptr)
    builder.branch(copy_cond)

    builder.position_at_end(copy_end)

    # Copy sign
    src_sign = builder.load(builder.gep(src_ptr, [zero_32, BIGINT_SIGN]))
    builder.store(src_sign, builder.gep(res_ptr, [zero_32, BIGINT_SIGN]))
    builder.store(res_digits, builder.gep(res_ptr, [zero_32, BIGINT_DIGITS]))

    builder.ret(builder.load(res_ptr))


def define_bigint_mul(self):
    """Karatsuba multiplication with fallback to naive for small numbers"""
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_mul')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    a_ptr = func.args[0]
    b_ptr = func.args[1]

    len_func = self.module.get_global('i64.array.length')
    naive_func = self.module.get_global('bigint_mul_naive')
    add_func = self.module.get_global('bigint_add')
    sub_func = self.module.get_global('bigint_sub')
    split_low_func = self.module.get_global('bigint_split_low')
    split_high_func = self.module.get_global('bigint_split_high')
    shift_func = self.module.get_global('bigint_shift_left')

    # Get lengths
    a_digits = builder.load(builder.gep(a_ptr, [zero_32, two_32]))  # digits at index 2
    b_digits = builder.load(builder.gep(b_ptr, [zero_32, two_32]))  # digits at index 2
    len_a = builder.call(len_func, [a_digits])
    len_b = builder.call(len_func, [b_digits])

    # Threshold for using naive multiplication
    threshold = ir.Constant(type_map[INT], 32)

    # If both are small, use naive
    a_small = builder.icmp_signed('<', len_a, threshold)
    b_small = builder.icmp_signed('<', len_b, threshold)
    use_naive = builder.and_(a_small, b_small)

    naive_block = func.append_basic_block('naive')
    karatsuba_block = func.append_basic_block('karatsuba')

    builder.cbranch(use_naive, naive_block, karatsuba_block)

    # Naive path
    builder.position_at_end(naive_block)
    naive_result = builder.call(naive_func, [a_ptr, b_ptr])
    builder.ret(naive_result)

    # Karatsuba path
    builder.position_at_end(karatsuba_block)

    # m = max(len_a, len_b) / 2
    max_len = builder.select(builder.icmp_signed('>', len_a, len_b), len_a, len_b)
    m = builder.sdiv(max_len, two)

    # Split a and b
    # a = a1 * B^m + a0
    # b = b1 * B^m + b0
    a0_tmp = builder.alloca(bigint_struct)
    a1_tmp = builder.alloca(bigint_struct)
    b0_tmp = builder.alloca(bigint_struct)
    b1_tmp = builder.alloca(bigint_struct)

    a0_val = builder.call(split_low_func, [a_ptr, m])
    builder.store(a0_val, a0_tmp)
    a1_val = builder.call(split_high_func, [a_ptr, m])
    builder.store(a1_val, a1_tmp)
    b0_val = builder.call(split_low_func, [b_ptr, m])
    builder.store(b0_val, b0_tmp)
    b1_val = builder.call(split_high_func, [b_ptr, m])
    builder.store(b1_val, b1_tmp)

    # z0 = a0 * b0
    # z2 = a1 * b1
    # z1 = (a0 + a1) * (b0 + b1) - z0 - z2
    z0_tmp = builder.alloca(bigint_struct)
    z2_tmp = builder.alloca(bigint_struct)

    z0_val = builder.call(func, [a0_tmp, b0_tmp])  # Recursive call
    builder.store(z0_val, z0_tmp)
    z2_val = builder.call(func, [a1_tmp, b1_tmp])  # Recursive call
    builder.store(z2_val, z2_tmp)

    # a0 + a1
    a_sum_tmp = builder.alloca(bigint_struct)
    a_sum_val = builder.call(add_func, [a0_tmp, a1_tmp])
    builder.store(a_sum_val, a_sum_tmp)

    # b0 + b1
    b_sum_tmp = builder.alloca(bigint_struct)
    b_sum_val = builder.call(add_func, [b0_tmp, b1_tmp])
    builder.store(b_sum_val, b_sum_tmp)

    # (a0 + a1) * (b0 + b1)
    z1_prod_tmp = builder.alloca(bigint_struct)
    z1_prod_val = builder.call(func, [a_sum_tmp, b_sum_tmp])  # Recursive call
    builder.store(z1_prod_val, z1_prod_tmp)

    # z1 = z1_prod - z0 - z2
    z1_sub1_tmp = builder.alloca(bigint_struct)
    z1_sub1_val = builder.call(sub_func, [z1_prod_tmp, z0_tmp])
    builder.store(z1_sub1_val, z1_sub1_tmp)

    z1_tmp = builder.alloca(bigint_struct)
    z1_val = builder.call(sub_func, [z1_sub1_tmp, z2_tmp])
    builder.store(z1_val, z1_tmp)

    # result = z2 * B^(2m) + z1 * B^m + z0
    m2 = builder.mul(m, two)

    z2_shifted_tmp = builder.alloca(bigint_struct)
    z2_shifted_val = builder.call(shift_func, [z2_tmp, m2])
    builder.store(z2_shifted_val, z2_shifted_tmp)

    z1_shifted_tmp = builder.alloca(bigint_struct)
    z1_shifted_val = builder.call(shift_func, [z1_tmp, m])
    builder.store(z1_shifted_val, z1_shifted_tmp)

    # z2_shifted + z1_shifted
    sum1_tmp = builder.alloca(bigint_struct)
    sum1_val = builder.call(add_func, [z2_shifted_tmp, z1_shifted_tmp])
    builder.store(sum1_val, sum1_tmp)

    # sum1 + z0
    result_val = builder.call(add_func, [sum1_tmp, z0_tmp])

    # Free ALL temporaries before returning
    free_func = self.module.get_global('free_bigint')
    
    # List of temps to free:
    # a0_tmp, a1_tmp, b0_tmp, b1_tmp
    # z0_tmp, z2_tmp
    # a_sum_tmp, b_sum_tmp
    # z1_prod_tmp (z1_raw)
    # z1_sub1_tmp, z1_tmp
    # z2_shifted_tmp, z1_shifted_tmp
    # sum1_tmp
    
    # Note: z0_val was stored in z0_tmp. z0_val IS the result pointer (assuming struct pointer semantics? No, struct value)
    # bigint_mul returns struct value.
    # We stored it in alloca `z0_tmp`.
    # When we free `z0_tmp`, we pass the pointer to the struct.
    # free_bigint takes `bigint*`. Correct.
    
    builder.call(free_func, [a0_tmp])
    builder.call(free_func, [a1_tmp])
    builder.call(free_func, [b0_tmp])
    builder.call(free_func, [b1_tmp])
    
    builder.call(free_func, [z0_tmp])
    builder.call(free_func, [z2_tmp])
    
    builder.call(free_func, [a_sum_tmp])
    builder.call(free_func, [b_sum_tmp])
    
    builder.call(free_func, [z1_prod_tmp])
    
    builder.call(free_func, [z1_sub1_tmp])
    builder.call(free_func, [z1_tmp])
    
    builder.call(free_func, [z2_shifted_tmp])
    builder.call(free_func, [z1_shifted_tmp])
    
    builder.call(free_func, [sum1_tmp])

    builder.ret(result_val)


def define_bigint_div(self):
    # bigint_div(bigint*, bigint*) -> bigint*
    # Truncated division
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_div')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    a_ptr = func.args[0]
    b_ptr = func.args[1]

    # helper functions
    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    set_func = self.module.get_global('i64.array.set')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    cmp_func = self.module.get_global('bigint_cmp')
    sub_func = self.module.get_global('bigint_sub')

    zero = ir.Constant(type_map[INT], 0)
    one = ir.Constant(type_map[INT], 1)
    u64_array_type = self.module.context.get_identified_type('i64.array')

    # 0. Check Divisor 0
    b_digits_ptr = builder.gep(b_ptr, [zero_32, two_32])  # digits at index 2
    b_digits = builder.load(b_digits_ptr)
    b_len = builder.call(len_func, [b_digits])
    # if len is 1 and val is 0 -> Error
    is_one = builder.icmp_signed(EQUALS, b_len, one)
    val0 = builder.call(get_func, [b_digits, zero])
    is_z = builder.icmp_unsigned(EQUALS, val0, ir.Constant(type_map[INT64], 0))
    is_div_zero = builder.and_(is_one, is_z)

    div_zero_block = func.append_basic_block('div_zero')
    start_div_block = func.append_basic_block('start_div')

    builder.cbranch(is_div_zero, div_zero_block, start_div_block)

    builder.position_at_end(div_zero_block)
    self.print_string("Division by zero")
    builder.call(self.module.get_global('exit'), [ir.Constant(type_map[INT32], 1)])
    builder.unreachable()
    
    builder.position_at_end(start_div_block)
    
    # 1. Signs
    a_sign = builder.load(builder.gep(a_ptr, [zero_32, BIGINT_SIGN]))
    b_sign = builder.load(builder.gep(b_ptr, [zero_32, BIGINT_SIGN]))
    res_sign = builder.xor(a_sign, b_sign)

    # 2. Magnitudes setup
    # Make a copy of b with sign 0 (b_abs)
    # bigint is { header, sign, digits* }.
    # We can make b_abs share the array of b, but force sign 0.

    b_abs = builder.alloca(bigint_struct)
    b_abs_sign = builder.gep(b_abs, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), b_abs_sign)
    b_abs_digits = builder.gep(b_abs, [zero_32, BIGINT_DIGITS])
    builder.store(b_digits, b_abs_digits)

    # R starts as 0 (positive)
    r_ptr = builder.alloca(bigint_struct)
    r_sign = builder.gep(r_ptr, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), r_sign)
    r_digits_slot = builder.gep(r_ptr, [zero_32, BIGINT_DIGITS])

    malloc_func = self.module.get_global('malloc')
    r_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    r_digits = builder.bitcast(r_mem, u64_array_type.as_pointer())
    builder.call(init_func, [r_digits])
    builder.call(append_func, [r_digits, ir.Constant(type_map[INT64], 0)])
    builder.store(r_digits, r_digits_slot)
    
    # Q starts as 0
    q_ptr = builder.alloca(bigint_struct)
    q_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    q_digits = builder.bitcast(q_mem, u64_array_type.as_pointer())
    builder.call(init_func, [q_digits])
    
    q_digits_slot = builder.gep(q_ptr, [zero_32, BIGINT_DIGITS])
    builder.store(q_digits, q_digits_slot)
    q_sign_ptr = builder.gep(q_ptr, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), q_sign_ptr) # Final sign applied at end

    # Pre-allocate Q with len_a zeros
    a_digits = builder.load(builder.gep(a_ptr, [zero_32, BIGINT_DIGITS]))
    len_a = builder.call(len_func, [a_digits])
    
    # Loop fill Q
    fill_q_cond = func.append_basic_block('fill_q_cond')
    fill_q_body = func.append_basic_block('fill_q_body')
    fill_q_end = func.append_basic_block('fill_q_end')
    
    fill_i = builder.alloca(type_map[INT])
    builder.store(zero, fill_i)
    builder.branch(fill_q_cond)
    builder.position_at_end(fill_q_cond)
    fv = builder.load(fill_i)
    fc = builder.icmp_signed(LESS_THAN, fv, len_a)
    builder.cbranch(fc, fill_q_body, fill_q_end)
    builder.position_at_end(fill_q_body)
    builder.call(append_func, [q_digits, ir.Constant(type_map[INT64], 0)])
    builder.store(builder.add(fv, one), fill_i)
    builder.branch(fill_q_cond)
    builder.position_at_end(fill_q_end)
    
    # Loop over bits of a
    bit_i = builder.alloca(type_map[INT])
    # Allocate rl_carry and shift_i at entry (not in loop!)
    rl_carry = builder.alloca(type_map[INT64])
    shift_i = builder.alloca(type_map[INT])
    # total_bits = len_a * 64
    total_bits = builder.mul(len_a, ir.Constant(type_map[INT], 64))
    builder.store(builder.sub(total_bits, one), bit_i)
    
    loop_cond = func.append_basic_block('loop_div_cond')
    loop_body = func.append_basic_block('loop_div_body')
    loop_end = func.append_basic_block('loop_div_end')
    # Create shift_loop blocks outside the loop!
    shift_loop_cond = func.append_basic_block('shift_loop_cond')
    shift_loop_body = func.append_basic_block('shift_loop_body')
    shift_loop_end = func.append_basic_block('shift_loop_end')
    
    builder.branch(loop_cond)
    
    builder.position_at_end(loop_cond)
    bi = builder.load(bit_i)
    bvalid = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, bi, zero)
    builder.cbranch(bvalid, loop_body, loop_end)
    
    builder.position_at_end(loop_body)
    
    # Get bit(a, bi)
    digit_idx = builder.sdiv(bi, ir.Constant(type_map[INT], 64))
    bit_off = builder.srem(bi, ir.Constant(type_map[INT], 64))
    
    val_digit = builder.call(get_func, [a_digits, digit_idx])
    # bit = (val >> off) & 1
    # Note: bit_off is i64 but shift operand should be same type or casted. 
    # int ops wrapper uses same types.
    bit_off_64 = builder.trunc(bit_off, type_map[INT64]) 
    shifted = builder.lshr(val_digit, bit_off_64)
    bit_val = builder.and_(shifted, ir.Constant(type_map[INT64], 1))
    
    # Update R = (R << 1) | bit_val

    # Shift R left by 1
    rl_digits = builder.load(r_digits_slot)
    rl_len = builder.call(len_func, [rl_digits])

    # Initialize rl_carry and shift_i (reuse alloca from entry)
    builder.store(bit_val, rl_carry) # Initial carry is bit_val
    builder.store(zero, shift_i)

    builder.branch(shift_loop_cond)
    
    builder.position_at_end(shift_loop_cond)
    s_i = builder.load(shift_i)
    s_valid = builder.icmp_signed(LESS_THAN, s_i, rl_len)
    builder.cbranch(s_valid, shift_loop_body, shift_loop_end)
    
    builder.position_at_end(shift_loop_body)
    
    r_d = builder.call(get_func, [rl_digits, s_i])
    # new_d = (r_d << 1) | carry
    c_val = builder.load(rl_carry)
    
    r_d_sh = builder.shl(r_d, ir.Constant(type_map[INT64], 1))
    new_d = builder.or_(r_d_sh, c_val)
    
    # next_carry = r_d >> 63
    next_c = builder.lshr(r_d, ir.Constant(type_map[INT64], 63))
    
    builder.call(set_func, [rl_digits, s_i, new_d])
    builder.store(next_c, rl_carry)
    
    builder.store(builder.add(s_i, one), shift_i)
    builder.branch(shift_loop_cond)
    
    builder.position_at_end(shift_loop_end)
    
    # If carry left, append
    final_c = builder.load(rl_carry)
    has_c = builder.icmp_unsigned(NOT_EQUALS, final_c, ir.Constant(type_map[INT64], 0))
    with builder.if_then(has_c):
        builder.call(append_func, [rl_digits, final_c])
        
    # Check if R >= b_abs
    # Note: R is r_ptr
    cmp_res = builder.call(cmp_func, [r_ptr, b_abs])
    ge_res = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, cmp_res, ir.Constant(type_map[INT32], 0))
    
    sub_block = func.append_basic_block('sub_block')
    next_iter = func.append_basic_block('next_iter')
    
    builder.cbranch(ge_res, sub_block, next_iter)
    
    builder.position_at_end(sub_block)
    # R = R - b_abs
    # Helper: R -= B.
    # Note: bigint_sub returns new struct.
    sub_res_struct = builder.call(sub_func, [r_ptr, b_abs])
    
    # We need to update r_ptr content.
    # r_ptr -> {sign, digits_ptr}
    # sub_res -> {sign, digits_ptr}
    # Just extract digits ptr from sub_res and store in r_ptr?
    # Yes, since r_ptr is allocated on stack, we just update fields.
    
    # Store sub_res to stack to access fields
    temp_res = builder.alloca(bigint_struct)
    builder.store(sub_res_struct, temp_res)

    temp_digits = builder.load(builder.gep(temp_res, [zero_32, BIGINT_DIGITS]))
    temp_sign = builder.load(builder.gep(temp_res, [zero_32, BIGINT_SIGN]))

    # Free old R contents before overwriting
    free_bg = self.module.get_global('free_bigint')
    builder.call(free_bg, [r_ptr])
    
    builder.store(temp_digits, r_digits_slot) # Update R digits
    builder.store(temp_sign, r_sign) # Should remain 0
    
    # Set bit in Q
    # Q[digit_idx] |= (1 << bit_off)
    q_d = builder.call(get_func, [q_digits, digit_idx])
    mask = builder.shl(ir.Constant(type_map[INT64], 1), bit_off_64)
    q_new = builder.or_(q_d, mask)
    builder.call(set_func, [q_digits, digit_idx, q_new])
    
    builder.branch(next_iter)
    
    builder.position_at_end(next_iter)
    builder.store(builder.sub(bi, one), bit_i)
    builder.branch(loop_cond)
    
    builder.position_at_end(loop_end)
    
    # Trim Q logic 
    trim_cond = func.append_basic_block('div_trim_cond')
    trim_body = func.append_basic_block('div_trim_body')
    trim_end = func.append_basic_block('div_trim_end')
    
    builder.branch(trim_cond)
    
    builder.position_at_end(trim_cond)
    cur_len = builder.call(len_func, [q_digits])
    can_trim = builder.icmp_signed(GREATER_THAN, cur_len, one)
    check_zero_block = func.append_basic_block('div_check_zero')
    builder.cbranch(can_trim, check_zero_block, trim_end)
    builder.position_at_end(check_zero_block)
    last_idx = builder.sub(cur_len, one)
    last_val = builder.call(get_func, [q_digits, last_idx])
    is_zero = builder.icmp_unsigned(EQUALS, last_val, ir.Constant(type_map[INT64], 0))
    builder.cbranch(is_zero, trim_body, trim_end)
    builder.position_at_end(trim_body)
    size_ptr = builder.gep(q_digits, [zero_32, ARRAY_SIZE])
    new_size = builder.sub(cur_len, one)
    builder.store(new_size, size_ptr)
    builder.branch(trim_cond)
    
    builder.position_at_end(trim_end)
    
    # Store Q sign
    builder.store(res_sign, q_sign_ptr)
    
    # If Q is zero, sign 0
    r_len = builder.call(len_func, [q_digits])
    r_is_one = builder.icmp_signed(EQUALS, r_len, one)
    r_val = builder.call(get_func, [q_digits, zero])
    r_is_zero_val = builder.icmp_unsigned(EQUALS, r_val, ir.Constant(type_map[INT64], 0))
    is_result_zero = builder.and_(r_is_one, r_is_zero_val)
    with builder.if_then(is_result_zero):
        builder.store(ir.Constant(type_map[BOOL], 0), q_sign_ptr)

    # Free R (remainder) as it is temporary in div (we return Q)
    free_bg = self.module.get_global('free_bigint')
    builder.call(free_bg, [r_ptr])

    builder.ret(builder.load(q_ptr))


def define_bigint_mod(self):
    # bigint_mod(bigint*, bigint*) -> bigint*
    # Identical to div but returns R logic.
    # Logic duplication for simplicity in this context.
    # Note: R sign should be a.sign (Truncated division remainder).
    
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(bigint_struct, [bigint_struct.as_pointer(), bigint_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'bigint_mod')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder
    
    a_ptr = func.args[0]
    b_ptr = func.args[1]
    
    # Reuse all setup... I'll Copy-Paste logic from div, but at end return R.
    # And R sign checks.
    
    # helper functions
    len_func = self.module.get_global('i64.array.length')
    get_func = self.module.get_global('i64.array.get')
    set_func = self.module.get_global('i64.array.set')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    cmp_func = self.module.get_global('bigint_cmp')
    sub_func = self.module.get_global('bigint_sub')
    
    zero = ir.Constant(type_map[INT], 0)
    one = ir.Constant(type_map[INT], 1)
    u64_array_type = self.module.context.get_identified_type('i64.array')

    # 0. Check Divisor 0
    b_digits_ptr = builder.gep(b_ptr, [zero_32, two_32])  # digits at index 2
    b_digits = builder.load(b_digits_ptr)
    b_len = builder.call(len_func, [b_digits])
    is_one = builder.icmp_signed(EQUALS, b_len, one)
    val0 = builder.call(get_func, [b_digits, zero])
    is_z = builder.icmp_unsigned(EQUALS, val0, ir.Constant(type_map[INT64], 0))
    is_div_zero = builder.and_(is_one, is_z)

    div_zero_block = func.append_basic_block('div_zero')
    start_div_block = func.append_basic_block('start_div')

    builder.cbranch(is_div_zero, div_zero_block, start_div_block)

    builder.position_at_end(div_zero_block)
    self.print_string("Modulo by zero")
    builder.call(self.module.get_global('exit'), [ir.Constant(type_map[INT32], 1)])
    builder.unreachable()
    
    builder.position_at_end(start_div_block)
    
    # 1. Signs
    a_sign = builder.load(builder.gep(a_ptr, [zero_32, BIGINT_SIGN]))
    # mod sign matches a_sign
    res_sign = a_sign

    # 2. Magnitudes setup
    b_abs = builder.alloca(bigint_struct)
    b_abs_sign = builder.gep(b_abs, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), b_abs_sign)
    b_abs_digits = builder.gep(b_abs, [zero_32, BIGINT_DIGITS])
    builder.store(b_digits, b_abs_digits)

    r_ptr = builder.alloca(bigint_struct)
    r_sign = builder.gep(r_ptr, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), r_sign)
    r_digits_slot = builder.gep(r_ptr, [zero_32, BIGINT_DIGITS])

    malloc_func = self.module.get_global('malloc')
    r_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    r_digits = builder.bitcast(r_mem, u64_array_type.as_pointer())
    builder.call(init_func, [r_digits])
    builder.call(append_func, [r_digits, ir.Constant(type_map[INT64], 0)])
    builder.store(r_digits, r_digits_slot)
    
    q_digits = r_digits # Dummy for shared code structure if needed
    
    # Pre-allocate a_digits
    a_digits = builder.load(builder.gep(a_ptr, [zero_32, two_32]))  # digits at index 2
    len_a = builder.call(len_func, [a_digits])
    
    # Loop over bits of a
    bit_i = builder.alloca(type_map[INT])
    # Allocate rl_carry and shift_i at entry (not in loop!)
    rl_carry = builder.alloca(type_map[INT64])
    shift_i = builder.alloca(type_map[INT])
    total_bits = builder.mul(len_a, ir.Constant(type_map[INT], 64))
    builder.store(builder.sub(total_bits, one), bit_i)
    
    loop_cond = func.append_basic_block('loop_mod_cond')
    loop_body = func.append_basic_block('loop_mod_body')
    loop_end = func.append_basic_block('loop_mod_end')
    # Create shift_loop blocks outside the loop!
    shift_loop_cond = func.append_basic_block('shift_loop_cond')
    shift_loop_body = func.append_basic_block('shift_loop_body')
    shift_loop_end = func.append_basic_block('shift_loop_end')
    
    builder.branch(loop_cond)
    
    builder.position_at_end(loop_cond)
    bi = builder.load(bit_i)
    bvalid = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, bi, zero)
    builder.cbranch(bvalid, loop_body, loop_end)
    
    builder.position_at_end(loop_body)
    
    digit_idx = builder.sdiv(bi, ir.Constant(type_map[INT], 64))
    bit_off = builder.srem(bi, ir.Constant(type_map[INT], 64))
    
    val_digit = builder.call(get_func, [a_digits, digit_idx])
    bit_off_64 = builder.trunc(bit_off, type_map[INT64]) 
    shifted = builder.lshr(val_digit, bit_off_64)
    bit_val = builder.and_(shifted, ir.Constant(type_map[INT64], 1))
    
    # Update R = (R << 1) | bit_val
    rl_digits = builder.load(r_digits_slot)
    rl_len = builder.call(len_func, [rl_digits])

    # Initialize rl_carry and shift_i (reuse alloca from entry)
    builder.store(bit_val, rl_carry)
    builder.store(zero, shift_i)

    builder.branch(shift_loop_cond)
    
    builder.position_at_end(shift_loop_cond)
    s_i = builder.load(shift_i)
    s_valid = builder.icmp_signed(LESS_THAN, s_i, rl_len)
    builder.cbranch(s_valid, shift_loop_body, shift_loop_end)
    
    builder.position_at_end(shift_loop_body)
    r_d = builder.call(get_func, [rl_digits, s_i])
    c_val = builder.load(rl_carry)
    r_d_sh = builder.shl(r_d, ir.Constant(type_map[INT64], 1))
    new_d = builder.or_(r_d_sh, c_val)
    next_c = builder.lshr(r_d, ir.Constant(type_map[INT64], 63))
    builder.call(set_func, [rl_digits, s_i, new_d])
    builder.store(next_c, rl_carry)
    builder.store(builder.add(s_i, one), shift_i)
    builder.branch(shift_loop_cond)
    builder.position_at_end(shift_loop_end)
    
    final_c = builder.load(rl_carry)
    has_c = builder.icmp_unsigned(NOT_EQUALS, final_c, ir.Constant(type_map[INT64], 0))
    with builder.if_then(has_c):
        builder.call(append_func, [rl_digits, final_c])
        
    cmp_res = builder.call(cmp_func, [r_ptr, b_abs])
    ge_res = builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, cmp_res, ir.Constant(type_map[INT32], 0))
    
    sub_block = func.append_basic_block('sub_block')
    next_iter = func.append_basic_block('next_iter')
    
    builder.cbranch(ge_res, sub_block, next_iter)
    
    builder.position_at_end(sub_block)
    sub_res_struct = builder.call(sub_func, [r_ptr, b_abs])
    
    temp_res = builder.alloca(bigint_struct)
    builder.store(sub_res_struct, temp_res)
    temp_digits = builder.load(builder.gep(temp_res, [zero_32, BIGINT_DIGITS]))
    temp_sign = builder.load(builder.gep(temp_res, [zero_32, BIGINT_SIGN]))

    # Free old R contents before overwriting
    free_bg = self.module.get_global('free_bigint')
    builder.call(free_bg, [r_ptr])
    
    builder.store(temp_digits, r_digits_slot)
    builder.store(temp_sign, r_sign)
    
    builder.branch(next_iter)
    
    builder.position_at_end(next_iter)
    builder.store(builder.sub(bi, one), bit_i)
    builder.branch(loop_cond)
    
    builder.position_at_end(loop_end)

    # Load the final digits pointer (must reload here, not use value from loop body)
    rl_digits = builder.load(r_digits_slot)

    # Store R sign
    builder.store(res_sign, r_sign)
    
    r_len = builder.call(len_func, [rl_digits])
    r_is_one = builder.icmp_signed(EQUALS, r_len, one)
    r_val = builder.call(get_func, [rl_digits, zero])
    r_is_zero_val = builder.icmp_unsigned(EQUALS, r_val, ir.Constant(type_map[INT64], 0))
    is_result_zero = builder.and_(r_is_one, r_is_zero_val)
    with builder.if_then(is_result_zero):
        builder.store(ir.Constant(type_map[BOOL], 0), r_sign)

    builder.ret(builder.load(r_ptr))
def define_new_types(self):
    # BIGINT: { header: meteor.header, sign: i1, digits: [u64] }
    from meteor.compiler.base import OBJECT_HEADER
    header_struct = self.search_scopes(OBJECT_HEADER)

    bigint_struct = self.module.context.get_identified_type('bigint')
    bigint_struct.name = 'bigint'
    bigint_struct.type = CLASS

    # Reusing i64.array for simplicity as the digit storage backend
    digit_array_type = self.module.context.get_identified_type('i64.array')

    # New layout with object header
    bigint_struct.set_body(header_struct, ir.IntType(1), digit_array_type.as_pointer())
    self.define('bigint', bigint_struct)
    type_map[BIGINT] = bigint_struct

    # DECIMAL: { header: meteor.header, mantissa: bigint*, exponent: i64 }
    decimal_struct = self.module.context.get_identified_type('decimal')
    decimal_struct.name = 'decimal'
    decimal_struct.type = CLASS
    decimal_struct.set_body(header_struct, bigint_struct.as_pointer(), type_map[INT64])
    self.define('decimal', decimal_struct)
    type_map[DECIMAL] = decimal_struct

    # DYNAMIC: { header: meteor.header, type_id: i32, data: i8* }
    dynamic_struct = self.module.context.get_identified_type('dynamic')
    dynamic_struct.name = 'dynamic'
    dynamic_struct.type = CLASS
    dynamic_struct.set_body(header_struct, ir.IntType(32), ir.IntType(8).as_pointer())
    self.define('dynamic', dynamic_struct)
    type_map[DYNAMIC] = dynamic_struct

    # NUMBER: { header: meteor.header, type_tag: i8, data: i8* }
    # 0=int, 1=float, 2=bigint, 3=decimal
    number_struct = self.module.context.get_identified_type('number')
    number_struct.name = 'number'
    number_struct.type = CLASS
    number_struct.set_body(header_struct, ir.IntType(8), ir.IntType(8).as_pointer())
    self.define('number', number_struct)
    type_map[NUMBER] = number_struct


def define_int_to_str(self, dyn_array_ptr):
    # START
    func_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr, type_map[INT]])
    func = ir.Function(self.module, func_type, '@int_to_str')
    entry_block = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry_block)
    self.builder = builder
    builder.position_at_end(entry_block)
    exit_block = func.append_basic_block('exit')
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(func.args[0], array_ptr)
    n_addr = builder.alloca(type_map[INT])
    builder.store(func.args[1], n_addr)
    x_addr = builder.alloca(type_map[INT])

    # BODY
    fourtyeight = ir.Constant(type_map[INT], 48)

    div_ten = builder.sdiv(builder.load(n_addr), ten)
    greater_than_zero = builder.icmp_signed(GREATER_THAN, div_ten, zero)
    mod_ten = builder.srem(builder.trunc(builder.load(n_addr), type_map[INT]), ten)
    builder.store(mod_ten, x_addr)
    with builder.if_then(greater_than_zero):
        builder.call(self.module.get_global('@int_to_str'), [builder.load(array_ptr), div_ten])

    char = builder.add(fourtyeight, builder.load(x_addr))
    builder.call(self.module.get_global('i64.array.append'), [builder.load(array_ptr), char])
    builder.branch(exit_block)

    # CLOSE
    builder.position_at_end(exit_block)
    builder.ret_void()


def define_bool_to_str(self, dyn_array_ptr):
    # START
    func_type = ir.FunctionType(type_map[VOID], [dyn_array_ptr, type_map[BOOL]])
    func = ir.Function(self.module, func_type, '@bool_to_str')
    entry_block = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry_block)
    self.builder = builder
    exit_block = func.append_basic_block('exit')
    array_ptr = builder.alloca(dyn_array_ptr)
    builder.store(func.args[0], array_ptr)

    # BODY
    equalszero = builder.icmp_signed(EQUALS, func.args[1], ir.Constant(type_map[BOOL], 0))
    dyn_array_append = self.module.get_global('i64.array.append')

    with builder.if_else(equalszero) as (then, otherwise):
        with then:
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 102)])
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 97)])
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 108)])
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 115)])
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 101)])
        with otherwise:
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 116)])
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 114)])
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 117)])
            builder.call(dyn_array_append, [builder.load(array_ptr), ir.Constant(type_map[INT], 101)])

    builder.branch(exit_block)

    # CLOSE
    builder.position_at_end(exit_block)
    builder.ret_void()


def define_decimal_neg(self):
    """Negate a decimal: result = -a"""
    decimal_struct = type_map[DECIMAL]
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(decimal_struct, [decimal_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'decimal_neg')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    a_ptr = func.args[0]

    # Get bigint_neg function
    bigint_neg = self.module.get_global('bigint_neg')
    malloc_func = self.module.get_global('malloc')

    # Get mantissa and exponent from a
    a_mantissa_ptr_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_MANTISSA])
    a_mantissa_ptr = builder.load(a_mantissa_ptr_ptr)
    a_exp_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_EXPONENT])
    a_exp = builder.load(a_exp_ptr)

    # Negate mantissa
    neg_mantissa = builder.call(bigint_neg, [a_mantissa_ptr])

    # Allocate result
    res_ptr = builder.alloca(decimal_struct)

    # Store negated mantissa on heap
    neg_mantissa_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 24)])
    neg_mantissa_ptr = builder.bitcast(neg_mantissa_mem, bigint_struct.as_pointer())
    builder.store(neg_mantissa, neg_mantissa_ptr)

    res_mantissa_ptr = builder.gep(res_ptr, [zero_32, DECIMAL_MANTISSA])
    builder.store(neg_mantissa_ptr, res_mantissa_ptr)

    # Copy exponent
    res_exp_ptr = builder.gep(res_ptr, [zero_32, DECIMAL_EXPONENT])
    builder.store(a_exp, res_exp_ptr)

    builder.ret(builder.load(res_ptr))


def define_decimal_mul(self):
    """Multiply two decimals: result = a * b
    result.mantissa = a.mantissa * b.mantissa
    result.exponent = a.exponent + b.exponent
    """
    decimal_struct = type_map[DECIMAL]
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(decimal_struct, [decimal_struct.as_pointer(), decimal_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'decimal_mul')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    a_ptr = func.args[0]
    b_ptr = func.args[1]

    # Get bigint_mul function
    bigint_mul = self.module.get_global('bigint_mul')
    malloc_func = self.module.get_global('malloc')

    # Get mantissa and exponent from a
    a_mantissa_ptr_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_MANTISSA])
    a_mantissa_ptr = builder.load(a_mantissa_ptr_ptr)
    a_exp_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_EXPONENT])
    a_exp = builder.load(a_exp_ptr)

    # Get mantissa and exponent from b
    b_mantissa_ptr_ptr = builder.gep(b_ptr, [zero_32, DECIMAL_MANTISSA])
    b_mantissa_ptr = builder.load(b_mantissa_ptr_ptr)
    b_exp_ptr = builder.gep(b_ptr, [zero_32, DECIMAL_EXPONENT])
    b_exp = builder.load(b_exp_ptr)

    # Multiply mantissas
    res_mantissa = builder.call(bigint_mul, [a_mantissa_ptr, b_mantissa_ptr])

    # Add exponents
    res_exp = builder.add(a_exp, b_exp)

    # Allocate result
    res_ptr = builder.alloca(decimal_struct)

    # Allocate result mantissa on heap
    res_mantissa_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    res_mantissa_ptr = builder.bitcast(res_mantissa_mem, bigint_struct.as_pointer())
    builder.store(res_mantissa, res_mantissa_ptr)

    res_mantissa_slot = builder.gep(res_ptr, [zero_32, DECIMAL_MANTISSA])
    builder.store(res_mantissa_ptr, res_mantissa_slot)

    # Store result exponent
    res_exp_slot = builder.gep(res_ptr, [zero_32, DECIMAL_EXPONENT])
    builder.store(res_exp, res_exp_slot)

    builder.ret(builder.load(res_ptr))


def define_decimal_add(self):
    """Add two decimals: result = a + b
    Algorithm:
    1. Align exponents to min(a.exp, b.exp)
    2. Multiply mantissa with larger exp by 10^diff
    3. Add mantissas
    """
    decimal_struct = type_map[DECIMAL]
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(decimal_struct, [decimal_struct.as_pointer(), decimal_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'decimal_add')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    a_ptr = func.args[0]
    b_ptr = func.args[1]

    # Get helper functions
    bigint_add = self.module.get_global('bigint_add')
    bigint_mul = self.module.get_global('bigint_mul')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    malloc_func = self.module.get_global('malloc')
    u64_array_type = self.module.context.get_identified_type('i64.array')

    # Get mantissa and exponent from a
    a_mantissa_ptr_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_MANTISSA])
    a_mantissa_ptr = builder.load(a_mantissa_ptr_ptr)
    a_exp_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_EXPONENT])
    a_exp = builder.load(a_exp_ptr)

    # Get mantissa and exponent from b
    b_mantissa_ptr_ptr = builder.gep(b_ptr, [zero_32, DECIMAL_MANTISSA])
    b_mantissa_ptr = builder.load(b_mantissa_ptr_ptr)
    b_exp_ptr = builder.gep(b_ptr, [zero_32, DECIMAL_EXPONENT])
    b_exp = builder.load(b_exp_ptr)

    # Compare exponents
    a_exp_lt_b = builder.icmp_signed(LESS_THAN, a_exp, b_exp)
    a_exp_gt_b = builder.icmp_signed(GREATER_THAN, a_exp, b_exp)

    # Allocate pointers for adjusted mantissas
    adj_a_ptr = builder.alloca(bigint_struct.as_pointer())
    adj_b_ptr = builder.alloca(bigint_struct.as_pointer())
    res_exp_ptr = builder.alloca(type_map[INT64])

    # Initialize with original values
    builder.store(a_mantissa_ptr, adj_a_ptr)
    builder.store(b_mantissa_ptr, adj_b_ptr)
    builder.store(a_exp, res_exp_ptr)

    # Branch based on exponent comparison
    adjust_b_block = func.append_basic_block('adjust_b')
    adjust_a_block = func.append_basic_block('adjust_a')
    do_add_block = func.append_basic_block('do_add')

    builder.cbranch(a_exp_lt_b, adjust_b_block, adjust_a_block)

    # Case: a.exp < b.exp - multiply b by 10^(b.exp - a.exp)
    builder.position_at_end(adjust_b_block)
    diff_b = builder.sub(b_exp, a_exp)
    builder.store(a_exp, res_exp_ptr)

    # Create bigint for 10
    ten_bigint_ptr = builder.alloca(bigint_struct)
    ten_digits_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    ten_digits = builder.bitcast(ten_digits_mem, u64_array_type.as_pointer())
    builder.call(init_func, [ten_digits])
    builder.call(append_func, [ten_digits, ir.Constant(type_map[INT64], 10)])
    ten_sign_ptr = builder.gep(ten_bigint_ptr, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), ten_sign_ptr)
    ten_digits_ptr = builder.gep(ten_bigint_ptr, [zero_32, BIGINT_DIGITS])
    builder.store(ten_digits, ten_digits_ptr)

    # Multiply b by 10^diff using loop
    b_adj_ptr = builder.alloca(bigint_struct.as_pointer())
    builder.store(b_mantissa_ptr, b_adj_ptr)

    loop_i_b = builder.alloca(type_map[INT64])
    builder.store(ir.Constant(type_map[INT64], 0), loop_i_b)

    loop_cond_b = func.append_basic_block('loop_cond_b')
    loop_body_b = func.append_basic_block('loop_body_b')
    loop_end_b = func.append_basic_block('loop_end_b')

    builder.branch(loop_cond_b)

    builder.position_at_end(loop_cond_b)
    i_b = builder.load(loop_i_b)
    cont_b = builder.icmp_signed(LESS_THAN, i_b, diff_b)
    builder.cbranch(cont_b, loop_body_b, loop_end_b)

    builder.position_at_end(loop_body_b)
    cur_b = builder.load(b_adj_ptr)
    new_b = builder.call(bigint_mul, [cur_b, ten_bigint_ptr])
    new_b_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    new_b_ptr = builder.bitcast(new_b_mem, bigint_struct.as_pointer())
    builder.store(new_b, new_b_ptr)
    builder.store(new_b_ptr, b_adj_ptr)
    builder.store(builder.add(i_b, ir.Constant(type_map[INT64], 1)), loop_i_b)
    builder.branch(loop_cond_b)

    builder.position_at_end(loop_end_b)
    builder.store(builder.load(b_adj_ptr), adj_b_ptr)
    builder.branch(do_add_block)

    # Case: a.exp >= b.exp
    builder.position_at_end(adjust_a_block)
    need_adjust_a = func.append_basic_block('need_adjust_a')
    no_adjust = func.append_basic_block('no_adjust')

    builder.cbranch(a_exp_gt_b, need_adjust_a, no_adjust)

    # a.exp > b.exp - multiply a by 10^(a.exp - b.exp)
    builder.position_at_end(need_adjust_a)
    diff_a = builder.sub(a_exp, b_exp)
    builder.store(b_exp, res_exp_ptr)

    ten_bigint_ptr2 = builder.alloca(bigint_struct)
    ten_digits_mem2 = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    ten_digits2 = builder.bitcast(ten_digits_mem2, u64_array_type.as_pointer())
    builder.call(init_func, [ten_digits2])
    builder.call(append_func, [ten_digits2, ir.Constant(type_map[INT64], 10)])
    ten_sign_ptr2 = builder.gep(ten_bigint_ptr2, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), ten_sign_ptr2)
    ten_digits_ptr2 = builder.gep(ten_bigint_ptr2, [zero_32, BIGINT_DIGITS])
    builder.store(ten_digits2, ten_digits_ptr2)

    a_adj_ptr = builder.alloca(bigint_struct.as_pointer())
    builder.store(a_mantissa_ptr, a_adj_ptr)

    loop_i_a = builder.alloca(type_map[INT64])
    builder.store(ir.Constant(type_map[INT64], 0), loop_i_a)

    loop_cond_a = func.append_basic_block('loop_cond_a')
    loop_body_a = func.append_basic_block('loop_body_a')
    loop_end_a = func.append_basic_block('loop_end_a')

    builder.branch(loop_cond_a)

    builder.position_at_end(loop_cond_a)
    i_a = builder.load(loop_i_a)
    cont_a = builder.icmp_signed(LESS_THAN, i_a, diff_a)
    builder.cbranch(cont_a, loop_body_a, loop_end_a)

    builder.position_at_end(loop_body_a)
    cur_a = builder.load(a_adj_ptr)
    new_a = builder.call(bigint_mul, [cur_a, ten_bigint_ptr2])
    new_a_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    new_a_ptr = builder.bitcast(new_a_mem, bigint_struct.as_pointer())
    builder.store(new_a, new_a_ptr)
    builder.store(new_a_ptr, a_adj_ptr)
    builder.store(builder.add(i_a, ir.Constant(type_map[INT64], 1)), loop_i_a)
    builder.branch(loop_cond_a)

    builder.position_at_end(loop_end_a)
    builder.store(builder.load(a_adj_ptr), adj_a_ptr)
    builder.branch(do_add_block)

    # No adjustment needed
    builder.position_at_end(no_adjust)
    builder.branch(do_add_block)

    # Do the addition
    builder.position_at_end(do_add_block)
    final_a = builder.load(adj_a_ptr)
    final_b = builder.load(adj_b_ptr)
    final_exp = builder.load(res_exp_ptr)

    res_mantissa = builder.call(bigint_add, [final_a, final_b])

    # Allocate result mantissa on heap
    res_mantissa_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    res_mantissa_store = builder.bitcast(res_mantissa_mem, bigint_struct.as_pointer())
    builder.store(res_mantissa, res_mantissa_store)

    res_ptr = builder.alloca(decimal_struct)
    res_mantissa_slot = builder.gep(res_ptr, [zero_32, DECIMAL_MANTISSA])
    builder.store(res_mantissa_store, res_mantissa_slot)

    res_exp_slot = builder.gep(res_ptr, [zero_32, DECIMAL_EXPONENT])
    builder.store(final_exp, res_exp_slot)

    builder.ret(builder.load(res_ptr))


def define_decimal_sub(self):
    """Subtract two decimals: result = a - b
    Algorithm:
    1. Align exponents to min(a.exp, b.exp)
    2. Multiply mantissa with larger exp by 10^diff
    3. Subtract mantissas
    """
    decimal_struct = type_map[DECIMAL]
    bigint_struct = type_map[BIGINT]
    func_type = ir.FunctionType(decimal_struct, [decimal_struct.as_pointer(), decimal_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'decimal_sub')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    a_ptr = func.args[0]
    b_ptr = func.args[1]

    # Get helper functions
    bigint_sub = self.module.get_global('bigint_sub')
    bigint_mul = self.module.get_global('bigint_mul')
    append_func = self.module.get_global('i64.array.append')
    init_func = self.module.get_global('i64.array.init')
    malloc_func = self.module.get_global('malloc')
    u64_array_type = self.module.context.get_identified_type('i64.array')

    # Get mantissa and exponent from a
    a_mantissa_ptr_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_MANTISSA])
    a_mantissa_ptr = builder.load(a_mantissa_ptr_ptr)
    a_exp_ptr = builder.gep(a_ptr, [zero_32, DECIMAL_EXPONENT])
    a_exp = builder.load(a_exp_ptr)

    # Get mantissa and exponent from b
    b_mantissa_ptr_ptr = builder.gep(b_ptr, [zero_32, DECIMAL_MANTISSA])
    b_mantissa_ptr = builder.load(b_mantissa_ptr_ptr)
    b_exp_ptr = builder.gep(b_ptr, [zero_32, DECIMAL_EXPONENT])
    b_exp = builder.load(b_exp_ptr)

    # Compare exponents
    a_exp_lt_b = builder.icmp_signed(LESS_THAN, a_exp, b_exp)
    a_exp_gt_b = builder.icmp_signed(GREATER_THAN, a_exp, b_exp)

    # Allocate pointers for adjusted mantissas
    adj_a_ptr = builder.alloca(bigint_struct.as_pointer())
    adj_b_ptr = builder.alloca(bigint_struct.as_pointer())
    res_exp_ptr = builder.alloca(type_map[INT64])

    # Initialize with original values
    builder.store(a_mantissa_ptr, adj_a_ptr)
    builder.store(b_mantissa_ptr, adj_b_ptr)
    builder.store(a_exp, res_exp_ptr)

    # Branch based on exponent comparison
    adjust_b_block = func.append_basic_block('adjust_b')
    adjust_a_block = func.append_basic_block('adjust_a')
    do_sub_block = func.append_basic_block('do_sub')

    builder.cbranch(a_exp_lt_b, adjust_b_block, adjust_a_block)

    # Case: a.exp < b.exp - multiply b by 10^(b.exp - a.exp)
    builder.position_at_end(adjust_b_block)
    diff_b = builder.sub(b_exp, a_exp)
    builder.store(a_exp, res_exp_ptr)

    # Create bigint for 10
    ten_bigint_ptr = builder.alloca(bigint_struct)
    ten_digits_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    ten_digits = builder.bitcast(ten_digits_mem, u64_array_type.as_pointer())
    builder.call(init_func, [ten_digits])
    builder.call(append_func, [ten_digits, ir.Constant(type_map[INT64], 10)])
    ten_sign_ptr = builder.gep(ten_bigint_ptr, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), ten_sign_ptr)
    ten_digits_ptr = builder.gep(ten_bigint_ptr, [zero_32, BIGINT_DIGITS])
    builder.store(ten_digits, ten_digits_ptr)

    # Multiply b by 10^diff using loop
    b_adj_ptr = builder.alloca(bigint_struct.as_pointer())
    builder.store(b_mantissa_ptr, b_adj_ptr)

    loop_i_b = builder.alloca(type_map[INT64])
    builder.store(ir.Constant(type_map[INT64], 0), loop_i_b)

    loop_cond_b = func.append_basic_block('loop_cond_b')
    loop_body_b = func.append_basic_block('loop_body_b')
    loop_end_b = func.append_basic_block('loop_end_b')

    builder.branch(loop_cond_b)

    builder.position_at_end(loop_cond_b)
    i_b = builder.load(loop_i_b)
    cont_b = builder.icmp_signed(LESS_THAN, i_b, diff_b)
    builder.cbranch(cont_b, loop_body_b, loop_end_b)

    builder.position_at_end(loop_body_b)
    cur_b = builder.load(b_adj_ptr)
    new_b = builder.call(bigint_mul, [cur_b, ten_bigint_ptr])
    new_b_ptr = builder.alloca(bigint_struct)
    builder.store(new_b, new_b_ptr)
    builder.store(new_b_ptr, b_adj_ptr)
    builder.store(builder.add(i_b, ir.Constant(type_map[INT64], 1)), loop_i_b)
    builder.branch(loop_cond_b)

    builder.position_at_end(loop_end_b)
    builder.store(builder.load(b_adj_ptr), adj_b_ptr)
    builder.branch(do_sub_block)

    # Case: a.exp >= b.exp
    builder.position_at_end(adjust_a_block)
    # Check if a.exp > b.exp
    need_adjust_a = func.append_basic_block('need_adjust_a')
    no_adjust = func.append_basic_block('no_adjust')

    builder.cbranch(a_exp_gt_b, need_adjust_a, no_adjust)

    # a.exp > b.exp - multiply a by 10^(a.exp - b.exp)
    builder.position_at_end(need_adjust_a)
    diff_a = builder.sub(a_exp, b_exp)
    builder.store(b_exp, res_exp_ptr)

    # Create bigint for 10
    ten_bigint_ptr2 = builder.alloca(bigint_struct)
    ten_digits_mem2 = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    ten_digits2 = builder.bitcast(ten_digits_mem2, u64_array_type.as_pointer())
    builder.call(init_func, [ten_digits2])
    builder.call(append_func, [ten_digits2, ir.Constant(type_map[INT64], 10)])
    ten_sign_ptr2 = builder.gep(ten_bigint_ptr2, [zero_32, BIGINT_SIGN])
    builder.store(ir.Constant(type_map[BOOL], 0), ten_sign_ptr2)
    ten_digits_ptr2 = builder.gep(ten_bigint_ptr2, [zero_32, BIGINT_DIGITS])
    builder.store(ten_digits2, ten_digits_ptr2)

    # Multiply a by 10^diff using loop
    a_adj_ptr = builder.alloca(bigint_struct.as_pointer())
    builder.store(a_mantissa_ptr, a_adj_ptr)

    loop_i_a = builder.alloca(type_map[INT64])
    builder.store(ir.Constant(type_map[INT64], 0), loop_i_a)

    loop_cond_a = func.append_basic_block('loop_cond_a')
    loop_body_a = func.append_basic_block('loop_body_a')
    loop_end_a = func.append_basic_block('loop_end_a')

    builder.branch(loop_cond_a)

    builder.position_at_end(loop_cond_a)
    i_a = builder.load(loop_i_a)
    cont_a = builder.icmp_signed(LESS_THAN, i_a, diff_a)
    builder.cbranch(cont_a, loop_body_a, loop_end_a)

    builder.position_at_end(loop_body_a)
    cur_a = builder.load(a_adj_ptr)
    new_a = builder.call(bigint_mul, [cur_a, ten_bigint_ptr2])
    new_a_ptr = builder.alloca(bigint_struct)
    builder.store(new_a, new_a_ptr)
    builder.store(new_a_ptr, a_adj_ptr)
    builder.store(builder.add(i_a, ir.Constant(type_map[INT64], 1)), loop_i_a)
    builder.branch(loop_cond_a)

    builder.position_at_end(loop_end_a)
    builder.store(builder.load(a_adj_ptr), adj_a_ptr)
    builder.branch(do_sub_block)

    # No adjustment needed (exponents equal)
    builder.position_at_end(no_adjust)
    builder.branch(do_sub_block)

    # Do the subtraction
    builder.position_at_end(do_sub_block)
    final_a = builder.load(adj_a_ptr)
    final_b = builder.load(adj_b_ptr)
    final_exp = builder.load(res_exp_ptr)

    # Subtract mantissas
    res_mantissa = builder.call(bigint_sub, [final_a, final_b])

    # Allocate result mantissa on heap
    res_mantissa_mem = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    res_mantissa_store = builder.bitcast(res_mantissa_mem, bigint_struct.as_pointer())
    builder.store(res_mantissa, res_mantissa_store)

    # Allocate result decimal
    res_ptr = builder.alloca(decimal_struct)

    res_mantissa_slot = builder.gep(res_ptr, [zero_32, DECIMAL_MANTISSA])
    builder.store(res_mantissa_store, res_mantissa_slot)

    # Store result exponent
    res_exp_slot = builder.gep(res_ptr, [zero_32, DECIMAL_EXPONENT])
    builder.store(final_exp, res_exp_slot)

    builder.ret(builder.load(res_ptr))


def define_number_to_decimal(self):
    """Convert number to decimal at runtime based on tag"""
    number_struct = type_map[NUMBER]
    decimal_struct = type_map[DECIMAL]
    bigint_struct = type_map[BIGINT]

    func_type = ir.FunctionType(decimal_struct.as_pointer(), [number_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'number_to_decimal')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    num_ptr = func.args[0]

    # Get helper functions
    malloc_func = self.module.get_global('malloc')
    init_func = self.module.get_global('i64.array.init')
    append_func = self.module.get_global('i64.array.append')
    u64_array_type = self.module.context.get_identified_type('i64.array')

    # Get tag and data (Number: { header, type_tag, data })
    tag_ptr = builder.gep(num_ptr, [zero_32, one_32])
    tag = builder.load(tag_ptr)
    data_ptr_ptr = builder.gep(num_ptr, [zero_32, two_32])  # data is at index 2
    data_ptr = builder.load(data_ptr_ptr)

    # Create basic blocks for switch
    case_int = func.append_basic_block('case_int')
    case_float = func.append_basic_block('case_float')
    case_bigint = func.append_basic_block('case_bigint')
    case_decimal = func.append_basic_block('case_decimal')
    end_block = func.append_basic_block('end')

    # Result pointer (alloca in entry)
    result_ptr = builder.alloca(decimal_struct.as_pointer(), name="result")

    # Switch on tag
    switch = builder.switch(tag, case_int)
    switch.add_case(ir.Constant(type_map[INT8], 0), case_int)
    switch.add_case(ir.Constant(type_map[INT8], 1), case_float)
    switch.add_case(ir.Constant(type_map[INT8], 2), case_bigint)
    switch.add_case(ir.Constant(type_map[INT8], 3), case_decimal)

    # Case INT: convert int to decimal
    builder.position_at_end(case_int)
    int_ptr = builder.bitcast(data_ptr, type_map[INT].as_pointer())
    int_val = builder.load(int_ptr)

    # Allocate decimal
    dec_mem_int = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    dec_ptr_int = builder.bitcast(dec_mem_int, decimal_struct.as_pointer())

    # Create bigint for mantissa (heap allocated)
    bigint_mem_int = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    bigint_ptr_int = builder.bitcast(bigint_mem_int, bigint_struct.as_pointer())
    u64_arr_int = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    u64_arr_int = builder.bitcast(u64_arr_int, u64_array_type.as_pointer())
    builder.call(init_func, [u64_arr_int])

    # Check sign and get absolute value
    is_neg_int = builder.icmp_signed(LESS_THAN, int_val, ir.Constant(type_map[INT], 0))
    abs_int = builder.select(is_neg_int, builder.neg(int_val), int_val)
    builder.call(append_func, [u64_arr_int, abs_int])

    # Store sign and digits in bigint
    sign_ptr_int = builder.gep(bigint_ptr_int, [zero_32, BIGINT_SIGN])
    builder.store(is_neg_int, sign_ptr_int)
    digits_ptr_int = builder.gep(bigint_ptr_int, [zero_32, BIGINT_DIGITS])
    builder.store(u64_arr_int, digits_ptr_int)

    # Store mantissa and exponent in decimal
    mant_slot_int = builder.gep(dec_ptr_int, [zero_32, DECIMAL_MANTISSA])
    builder.store(bigint_ptr_int, mant_slot_int)
    exp_slot_int = builder.gep(dec_ptr_int, [zero_32, DECIMAL_EXPONENT])
    builder.store(ir.Constant(type_map[INT64], 0), exp_slot_int)

    builder.store(dec_ptr_int, result_ptr)
    builder.branch(end_block)

    # Case FLOAT: convert float to decimal
    builder.position_at_end(case_float)
    dbl_ptr = builder.bitcast(data_ptr, type_map[DOUBLE].as_pointer())
    dbl_val = builder.load(dbl_ptr)

    # Scale by 10^6
    scale = ir.Constant(ir.DoubleType(), 1000000.0)
    scaled = builder.fmul(dbl_val, scale)
    mant_i64 = builder.fptosi(scaled, type_map[INT64])

    # Allocate decimal
    dec_mem_flt = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    dec_ptr_flt = builder.bitcast(dec_mem_flt, decimal_struct.as_pointer())

    # Create bigint (heap allocated)
    bigint_mem_flt = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    bigint_ptr_flt = builder.bitcast(bigint_mem_flt, bigint_struct.as_pointer())
    u64_arr_flt = builder.call(malloc_func, [ir.Constant(type_map[INT], 32)])
    u64_arr_flt = builder.bitcast(u64_arr_flt, u64_array_type.as_pointer())
    builder.call(init_func, [u64_arr_flt])

    is_neg_flt = builder.icmp_signed(LESS_THAN, mant_i64, ir.Constant(type_map[INT64], 0))
    abs_flt = builder.select(is_neg_flt, builder.neg(mant_i64), mant_i64)
    builder.call(append_func, [u64_arr_flt, abs_flt])

    sign_ptr_flt = builder.gep(bigint_ptr_flt, [zero_32, BIGINT_SIGN])
    builder.store(is_neg_flt, sign_ptr_flt)
    digits_ptr_flt = builder.gep(bigint_ptr_flt, [zero_32, BIGINT_DIGITS])
    builder.store(u64_arr_flt, digits_ptr_flt)

    mant_slot_flt = builder.gep(dec_ptr_flt, [zero_32, DECIMAL_MANTISSA])
    builder.store(bigint_ptr_flt, mant_slot_flt)
    exp_slot_flt = builder.gep(dec_ptr_flt, [zero_32, DECIMAL_EXPONENT])
    builder.store(ir.Constant(type_map[INT64], -6), exp_slot_flt)

    builder.store(dec_ptr_flt, result_ptr)
    builder.branch(end_block)

    # Case BIGINT: convert bigint to decimal (exponent = 0)
    builder.position_at_end(case_bigint)
    bigint_src = builder.bitcast(data_ptr, bigint_struct.as_pointer())

    dec_mem_big = builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    dec_ptr_big = builder.bitcast(dec_mem_big, decimal_struct.as_pointer())

    mant_slot_big = builder.gep(dec_ptr_big, [zero_32, DECIMAL_MANTISSA])
    builder.store(bigint_src, mant_slot_big)
    exp_slot_big = builder.gep(dec_ptr_big, [zero_32, DECIMAL_EXPONENT])
    builder.store(ir.Constant(type_map[INT64], 0), exp_slot_big)

    builder.store(dec_ptr_big, result_ptr)
    builder.branch(end_block)

    # Case DECIMAL: already decimal, just return
    builder.position_at_end(case_decimal)
    dec_src = builder.bitcast(data_ptr, decimal_struct.as_pointer())
    builder.store(dec_src, result_ptr)
    builder.branch(end_block)

    # End block: return result
    builder.position_at_end(end_block)
    final_result = builder.load(result_ptr)
    builder.ret(final_result)


def define_print_dynamic(self):
    """Print dynamic type based on type_id"""
    dynamic_struct = type_map[DYNAMIC]
    func_type = ir.FunctionType(type_map[VOID], [dynamic_struct.as_pointer()])
    func = ir.Function(self.module, func_type, 'print_dynamic')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    self.builder = builder

    dyn_ptr = func.args[0]

    # Get printf
    printf = self.module.globals.get('printf')
    if not printf:
        printf_type = ir.FunctionType(type_map[INT32], [type_map[INT8].as_pointer()], var_arg=True)
        printf = ir.Function(self.module, printf_type, 'printf')

    # Get type_id and data (Dynamic: { header, type_id, data })
    type_id_ptr = builder.gep(dyn_ptr, [zero_32, one_32])
    type_id = builder.load(type_id_ptr)
    data_ptr_ptr = builder.gep(dyn_ptr, [zero_32, two_32])  # data is at index 2
    data_ptr = builder.load(data_ptr_ptr)

    # Create blocks for switch
    case_int = func.append_basic_block('case_int')
    case_float = func.append_basic_block('case_float')
    case_bool = func.append_basic_block('case_bool')
    case_str = func.append_basic_block('case_str')
    case_bigint = func.append_basic_block('case_bigint')
    case_decimal = func.append_basic_block('case_decimal')
    case_unknown = func.append_basic_block('case_unknown')
    end_block = func.append_basic_block('end')

    # Switch on type_id
    switch = builder.switch(type_id, case_unknown)
    switch.add_case(ir.Constant(type_map[INT32], 1), case_int)
    switch.add_case(ir.Constant(type_map[INT32], 2), case_float)
    switch.add_case(ir.Constant(type_map[INT32], 3), case_bool)
    switch.add_case(ir.Constant(type_map[INT32], 4), case_str)
    switch.add_case(ir.Constant(type_map[INT32], 5), case_bigint)
    switch.add_case(ir.Constant(type_map[INT32], 6), case_decimal)

    # Case INT
    builder.position_at_end(case_int)
    int_ptr = builder.bitcast(data_ptr, type_map[INT].as_pointer())
    int_val = builder.load(int_ptr)
    fmt_int = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 6), name="dyn_fmt_int")
    if not fmt_int.initializer:
        fmt_int.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 6), bytearray(b"%lld\n\00"))
        fmt_int.global_constant = True
    builder.call(printf, [builder.bitcast(fmt_int, type_map[INT8].as_pointer()), int_val])
    builder.branch(end_block)

    # Case FLOAT
    builder.position_at_end(case_float)
    dbl_ptr = builder.bitcast(data_ptr, type_map[DOUBLE].as_pointer())
    dbl_val = builder.load(dbl_ptr)
    fmt_flt = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 4), name="dyn_fmt_flt")
    if not fmt_flt.initializer:
        fmt_flt.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 4), bytearray(b"%g\n\00"))
        fmt_flt.global_constant = True
    builder.call(printf, [builder.bitcast(fmt_flt, type_map[INT8].as_pointer()), dbl_val])
    builder.branch(end_block)

    # Case BOOL
    builder.position_at_end(case_bool)
    bool_ptr = builder.bitcast(data_ptr, type_map[BOOL].as_pointer())
    bool_val = builder.load(bool_ptr)
    fmt_true = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 6), name="dyn_fmt_true")
    if not fmt_true.initializer:
        fmt_true.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 6), bytearray(b"true\n\00"))
        fmt_true.global_constant = True
    fmt_false = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 7), name="dyn_fmt_false")
    if not fmt_false.initializer:
        fmt_false.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 7), bytearray(b"false\n\00"))
        fmt_false.global_constant = True
    bool_cmp = builder.icmp_unsigned('!=', bool_val, ir.Constant(type_map[BOOL], 0))
    true_block = func.append_basic_block('print_true')
    false_block = func.append_basic_block('print_false')
    builder.cbranch(bool_cmp, true_block, false_block)
    builder.position_at_end(true_block)
    builder.call(printf, [builder.bitcast(fmt_true, type_map[INT8].as_pointer())])
    builder.branch(end_block)
    builder.position_at_end(false_block)
    builder.call(printf, [builder.bitcast(fmt_false, type_map[INT8].as_pointer())])
    builder.branch(end_block)

    # Case STR
    builder.position_at_end(case_str)
    print_func = self.module.get_global('print')
    str_ptr = builder.bitcast(data_ptr, type_map[STR].as_pointer())
    builder.call(print_func, [str_ptr])
    builder.branch(end_block)

    # Case BIGINT
    builder.position_at_end(case_bigint)
    bigint_ptr = builder.bitcast(data_ptr, type_map[BIGINT].as_pointer())
    builder.call(self.module.get_global('print_bigint'), [bigint_ptr])
    builder.branch(end_block)

    # Case DECIMAL
    builder.position_at_end(case_decimal)
    decimal_ptr = builder.bitcast(data_ptr, type_map[DECIMAL].as_pointer())
    builder.call(self.module.get_global('print_decimal'), [decimal_ptr])
    builder.branch(end_block)

    # Case UNKNOWN
    builder.position_at_end(case_unknown)
    fmt_unk = ir.GlobalVariable(self.module, ir.ArrayType(type_map[INT8], 11), name="dyn_fmt_unk")
    if not fmt_unk.initializer:
        fmt_unk.initializer = ir.Constant(ir.ArrayType(type_map[INT8], 11), bytearray(b"<dynamic>\n\00"))
        fmt_unk.global_constant = True
    builder.call(printf, [builder.bitcast(fmt_unk, type_map[INT8].as_pointer())])
    builder.branch(end_block)

    # End block
    builder.position_at_end(end_block)
    builder.ret_void()


def define_input(self):
    """Define input function that reads a line from stdin and returns a string."""
    str_struct = type_map[STR]
    str_struct_ptr = str_struct.as_pointer()

    # Declare getchar (returns i8 in llvmlite)
    getchar = self.module.globals.get('getchar')
    if not getchar:
        getchar_type = ir.FunctionType(type_map[INT8], [])
        getchar = ir.Function(self.module, getchar_type, 'getchar')

    # Declare malloc
    malloc = self.module.globals.get('malloc')
    if not malloc:
        malloc_type = ir.FunctionType(type_map[INT8].as_pointer(), [type_map[INT]])
        malloc = ir.Function(self.module, malloc_type, 'malloc')

    # Create input_line function: () -> str*
    func_type = ir.FunctionType(str_struct_ptr, [])
    func = ir.Function(self.module, func_type, 'input_line')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    # Allocate string struct on heap (3 * i64 = 24 bytes)
    struct_size = ir.Constant(type_map[INT], 32)
    result_mem = builder.call(malloc, [struct_size])
    result = builder.bitcast(result_mem, str_struct_ptr)

    # Get pointers to struct fields (Array: { header, size, capacity, data })
    size_ptr = builder.gep(result, [zero, ARRAY_SIZE], inbounds=True)
    cap_ptr = builder.gep(result, [zero, ARRAY_CAPACITY], inbounds=True)
    data_ptr_ptr = builder.gep(result, [zero, ARRAY_DATA], inbounds=True)

    # Initialize: size=0, capacity=256, data=malloc(256*8)
    initial_cap = ir.Constant(type_map[INT], 256)
    builder.store(zero, size_ptr)
    builder.store(initial_cap, cap_ptr)

    data_mem = builder.call(malloc, [builder.mul(initial_cap, eight)])
    data_ptr = builder.bitcast(data_mem, type_map[INT].as_pointer())
    builder.store(data_ptr, data_ptr_ptr)

    # Allocate local variable for current char
    ch_ptr = builder.alloca(type_map[INT8])

    # Create blocks
    loop_block = func.append_basic_block('loop')
    store_block = func.append_basic_block('store')
    done_block = func.append_basic_block('done')

    builder.branch(loop_block)

    # Loop block: read char and check if done
    builder.position_at_end(loop_block)
    ch = builder.call(getchar, [])
    builder.store(ch, ch_ptr)

    # Check for newline (10) or EOF (-1)
    is_newline = builder.icmp_signed('==', ch, ir.Constant(type_map[INT8], 10))
    is_eof = builder.icmp_signed('==', ch, ir.Constant(type_map[INT8], -1))
    is_done = builder.or_(is_newline, is_eof)
    builder.cbranch(is_done, done_block, store_block)

    # Store block: store char using 1-based index (like append)
    builder.position_at_end(store_block)
    cur_size = builder.load(size_ptr)
    new_size = builder.add(cur_size, one)
    builder.store(new_size, size_ptr)

    cur_data = builder.load(data_ptr_ptr)
    stored_ch = builder.load(ch_ptr)
    ch_i64 = builder.sext(stored_ch, type_map[INT])

    elem_ptr = builder.gep(cur_data, [new_size], inbounds=True)
    builder.store(ch_i64, elem_ptr)

    builder.branch(loop_block)

    # Done block: return result
    builder.position_at_end(done_block)
    builder.ret(result)


def define_number_func(self):
    """Define number() function that converts string to int."""
    str_struct = type_map[STR]
    str_struct_ptr = str_struct.as_pointer()

    # Create number function: (str*) -> i64
    func_type = ir.FunctionType(type_map[INT], [str_struct_ptr])
    func = ir.Function(self.module, func_type, 'str_to_int')
    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    str_ptr = func.args[0]

    # Get size and data pointer (Array: { header, size, capacity, data })
    size_ptr = builder.gep(str_ptr, [zero, ARRAY_SIZE], inbounds=True)
    data_ptr_ptr = builder.gep(str_ptr, [zero, ARRAY_DATA], inbounds=True)
    size = builder.load(size_ptr)
    data_ptr = builder.load(data_ptr_ptr)

    # Initialize result and index
    result_ptr = builder.alloca(type_map[INT])
    builder.store(zero, result_ptr)
    idx_ptr = builder.alloca(type_map[INT])
    builder.store(one, idx_ptr)  # 1-based index
    neg_ptr = builder.alloca(type_map[INT])
    builder.store(zero, neg_ptr)

    # Create blocks
    check_neg = func.append_basic_block('check_neg')
    loop_block = func.append_basic_block('loop')
    body_block = func.append_basic_block('body')
    done_block = func.append_basic_block('done')

    builder.branch(check_neg)

    # Check for negative sign
    builder.position_at_end(check_neg)
    first_char_ptr = builder.gep(data_ptr, [one], inbounds=True)
    first_char = builder.load(first_char_ptr)
    is_neg = builder.icmp_signed('==', first_char, ir.Constant(type_map[INT], 45))  # '-'
    with builder.if_then(is_neg):
        builder.store(one, neg_ptr)
        builder.store(two, idx_ptr)
    builder.branch(loop_block)

    # Loop
    builder.position_at_end(loop_block)
    idx = builder.load(idx_ptr)
    cond = builder.icmp_signed('<=', idx, size)
    builder.cbranch(cond, body_block, done_block)

    # Body: result = result * 10 + (char - '0')
    builder.position_at_end(body_block)
    char_ptr = builder.gep(data_ptr, [idx], inbounds=True)
    char_val = builder.load(char_ptr)
    digit = builder.sub(char_val, ir.Constant(type_map[INT], 48))  # '0' = 48

    cur_result = builder.load(result_ptr)
    new_result = builder.mul(cur_result, ten)
    new_result = builder.add(new_result, digit)
    builder.store(new_result, result_ptr)

    new_idx = builder.add(idx, one)
    builder.store(new_idx, idx_ptr)
    builder.branch(loop_block)

    # Done: apply negative if needed
    builder.position_at_end(done_block)
    final_result = builder.load(result_ptr)
    is_negative = builder.icmp_signed('!=', builder.load(neg_ptr), zero)
    neg_result = builder.sub(zero, final_result)
    result = builder.select(is_negative, neg_result, final_result)
    builder.ret(result)


# ============================================================================
# Memory Management Runtime Functions (RFC-001)
# ============================================================================

def define_object_header(self):
    """Define unified object header structure for RC memory management.

    Layout (16 bytes on 64-bit):
    - strong_rc: u32 [0] - Strong reference count
    - weak_rc: u32 [1] - Weak reference count
    - flags: u8 [2] - Bit 0: IS_FROZEN, Bit 1: IS_ZOMBIE
    - type_tag: u8 [3] - Runtime type information
    - reserved: u16 [4] - Alignment padding
    """
    from meteor.compiler.base import OBJECT_HEADER

    header_struct = self.module.context.get_identified_type(OBJECT_HEADER)
    header_struct.name = OBJECT_HEADER
    header_struct.set_body(
        type_map[UINT32],   # strong_rc
        type_map[UINT32],   # weak_rc
        type_map[UINT8],    # flags
        type_map[UINT8],    # type_tag
        type_map[UINT16]    # reserved
    )

    self.define(OBJECT_HEADER, header_struct)
    return header_struct


def define_mutex_type(self):
    """Define Mutex structure for thread synchronization."""
    import sys
    i8_ptr = type_map[INT8].as_pointer()

    mutex_struct = self.module.context.get_identified_type('meteor.mutex')
    # On Windows: CRITICAL_SECTION (40 bytes), on Unix: pthread_mutex_t
    mutex_struct.set_body(i8_ptr)  # Pointer to OS mutex
    self.define('meteor.mutex', mutex_struct)
    return mutex_struct


def define_channel_type(self):
    """Define Channel structure for CSP-style concurrency.

    Layout:
    - header: meteor.header (for RC)
    - mutex: i8* (pthread_mutex_t pointer)
    - cond: i8* (pthread_cond_t pointer)
    - queue: i8** (circular buffer of void pointers)
    - capacity: i64
    - head: i64
    - tail: i64
    - count: i64
    """
    from meteor.compiler.base import OBJECT_HEADER

    header_struct = self.search_scopes(OBJECT_HEADER)
    channel_struct = self.module.context.get_identified_type('meteor.channel')
    channel_struct.set_body(
        header_struct,              # header
        type_map[INT8].as_pointer(), # mutex
        type_map[INT8].as_pointer(), # cond
        type_map[INT8].as_pointer().as_pointer(), # queue
        type_map[INT64],            # capacity
        type_map[INT64],            # head
        type_map[INT64],            # tail
        type_map[INT64]             # count
    )
    self.define('meteor.channel', channel_struct)
    return channel_struct


def define_spawn_runtime(self):
    """Define spawn runtime function for creating threads.
    i64 meteor_spawn(void* func_ptr, void* arg)
    Returns thread handle.

    Uses Windows CreateThread API on Windows, pthread_create on Unix.
    """
    import sys
    i8_ptr = type_map[INT8].as_pointer()

    if sys.platform == 'win32':
        # Windows: CreateThread
        # HANDLE CreateThread(LPSECURITY_ATTRIBUTES, SIZE_T, LPTHREAD_START_ROUTINE, LPVOID, DWORD, LPDWORD)
        create_thread_type = ir.FunctionType(
            i8_ptr,  # HANDLE (void*)
            [i8_ptr, type_map[INT64], i8_ptr, i8_ptr, type_map[INT32], type_map[INT32].as_pointer()]
        )
        try:
            create_thread = self.module.get_global('CreateThread')
        except KeyError:
            create_thread = ir.Function(self.module, create_thread_type, 'CreateThread')

        # meteor_spawn wrapper
        func_type = ir.FunctionType(type_map[INT64], [i8_ptr, i8_ptr])
        func = ir.Function(self.module, func_type, 'meteor_spawn')
        func.linkage = 'internal'

        entry = func.append_basic_block('entry')
        builder = ir.IRBuilder(entry)

        func_ptr = func.args[0]
        arg_ptr = func.args[1]

        # Call CreateThread(NULL, 0, func_ptr, arg_ptr, 0, NULL)
        null_ptr = ir.Constant(i8_ptr, None)
        zero_64 = ir.Constant(type_map[INT64], 0)
        zero_32 = ir.Constant(type_map[INT32], 0)
        null_dword_ptr = ir.Constant(type_map[INT32].as_pointer(), None)

        handle = builder.call(create_thread, [null_ptr, zero_64, func_ptr, arg_ptr, zero_32, null_dword_ptr])
        result = builder.ptrtoint(handle, type_map[INT64])
        builder.ret(result)
    else:
        # Unix: pthread_create
        pthread_t = type_map[INT64]
        pthread_create_type = ir.FunctionType(
            type_map[INT32],
            [pthread_t.as_pointer(), i8_ptr, i8_ptr, i8_ptr]
        )
        try:
            pthread_create = self.module.get_global('pthread_create')
        except KeyError:
            pthread_create = ir.Function(self.module, pthread_create_type, 'pthread_create')

        # meteor_spawn wrapper
        func_type = ir.FunctionType(type_map[INT64], [i8_ptr, i8_ptr])
        func = ir.Function(self.module, func_type, 'meteor_spawn')
        func.linkage = 'internal'

        entry = func.append_basic_block('entry')
        builder = ir.IRBuilder(entry)

        func_ptr = func.args[0]
        arg_ptr = func.args[1]

        # Allocate thread handle
        thread_handle = builder.alloca(type_map[INT64])

        # Call pthread_create
        null_ptr = ir.Constant(i8_ptr, None)
        result = builder.call(pthread_create, [thread_handle, null_ptr, func_ptr, arg_ptr])

        # Return thread handle
        handle = builder.load(thread_handle)
        builder.ret(handle)


def define_join_runtime(self):
    """Define join runtime function for waiting on threads.
    void meteor_join(i64 thread_handle)
    """
    import sys
    i8_ptr = type_map[INT8].as_pointer()

    func_type = ir.FunctionType(type_map[VOID], [type_map[INT64]])
    func = ir.Function(self.module, func_type, 'meteor_join')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    thread_handle = func.args[0]

    if sys.platform == 'win32':
        # Windows: WaitForSingleObject(handle, INFINITE)
        wait_type = ir.FunctionType(type_map[INT32], [i8_ptr, type_map[INT32]])
        if 'WaitForSingleObject' not in self.module.globals:
            ir.Function(self.module, wait_type, 'WaitForSingleObject')
        wait_func = self.module.get_global('WaitForSingleObject')

        handle_ptr = builder.inttoptr(thread_handle, i8_ptr)
        infinite = ir.Constant(type_map[INT32], 0xFFFFFFFF)
        builder.call(wait_func, [handle_ptr, infinite])

        # CloseHandle
        close_type = ir.FunctionType(type_map[INT32], [i8_ptr])
        if 'CloseHandle' not in self.module.globals:
            ir.Function(self.module, close_type, 'CloseHandle')
        close_func = self.module.get_global('CloseHandle')
        builder.call(close_func, [handle_ptr])
    else:
        # Unix: pthread_join
        join_type = ir.FunctionType(type_map[INT32], [type_map[INT64], i8_ptr.as_pointer()])
        if 'pthread_join' not in self.module.globals:
            ir.Function(self.module, join_type, 'pthread_join')
        join_func = self.module.get_global('pthread_join')

        null_ptr = ir.Constant(i8_ptr.as_pointer(), None)
        builder.call(join_func, [thread_handle, null_ptr])

    builder.ret_void()


def define_atomic_ops(self):
    """Define atomic operations for thread-safe memory access."""
    i64 = type_map[INT64]
    i64_ptr = i64.as_pointer()

    # atomic_load(ptr) -> i64
    load_type = ir.FunctionType(i64, [i64_ptr])
    load_func = ir.Function(self.module, load_type, 'atomic_load')
    load_func.linkage = 'internal'
    entry = load_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    val = builder.load(load_func.args[0])
    val.set_metadata('atomic', self.module.add_metadata([]))
    builder.fence('seq_cst')
    builder.ret(val)

    # atomic_store(ptr, val)
    store_type = ir.FunctionType(type_map[VOID], [i64_ptr, i64])
    store_func = ir.Function(self.module, store_type, 'atomic_store')
    store_func.linkage = 'internal'
    entry = store_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    builder.fence('seq_cst')
    builder.store(store_func.args[1], store_func.args[0])
    builder.ret_void()

    # atomic_add(ptr, val) -> i64 (returns old value)
    add_type = ir.FunctionType(i64, [i64_ptr, i64])
    add_func = ir.Function(self.module, add_type, 'atomic_add')
    add_func.linkage = 'internal'
    entry = add_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    old_val = builder.atomic_rmw('add', add_func.args[0], add_func.args[1], 'seq_cst')
    builder.ret(old_val)

    # atomic_sub(ptr, val) -> i64 (returns old value)
    sub_type = ir.FunctionType(i64, [i64_ptr, i64])
    sub_func = ir.Function(self.module, sub_type, 'atomic_sub')
    sub_func.linkage = 'internal'
    entry = sub_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    old_val = builder.atomic_rmw('sub', sub_func.args[0], sub_func.args[1], 'seq_cst')
    builder.ret(old_val)

    # atomic_cas(ptr, expected, desired) -> i64 (returns old value)
    cas_type = ir.FunctionType(i64, [i64_ptr, i64, i64])
    cas_func = ir.Function(self.module, cas_type, 'atomic_cas')
    cas_func.linkage = 'internal'
    entry = cas_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    result = builder.cmpxchg(cas_func.args[0], cas_func.args[1], cas_func.args[2], 'seq_cst', 'seq_cst')
    old_val = builder.extract_value(result, 0)
    builder.ret(old_val)


def define_mutex_ops(self):
    """Define mutex operations for thread synchronization."""
    import sys
    i8_ptr = type_map[INT8].as_pointer()
    mutex_struct = self.search_scopes('meteor.mutex')
    mutex_ptr = mutex_struct.as_pointer()

    if sys.platform == 'win32':
        _define_mutex_ops_windows(self, mutex_ptr, i8_ptr)
    else:
        _define_mutex_ops_unix(self, mutex_ptr, i8_ptr)


def _define_mutex_ops_windows(self, mutex_ptr, i8_ptr):
    """Windows mutex using CRITICAL_SECTION."""
    # InitializeCriticalSection, EnterCriticalSection, LeaveCriticalSection, DeleteCriticalSection

    # mutex_create() -> mutex*
    create_type = ir.FunctionType(mutex_ptr, [])
    create_func = ir.Function(self.module, create_type, 'mutex_create')
    create_func.linkage = 'internal'
    entry = create_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    # Allocate CRITICAL_SECTION (40 bytes on x64)
    malloc_func = self.module.get_global('malloc')
    cs_mem = builder.call(malloc_func, [ir.Constant(type_map[INT64], 48)])

    # Initialize
    init_type = ir.FunctionType(type_map[VOID], [i8_ptr])
    if 'InitializeCriticalSection' not in self.module.globals:
        ir.Function(self.module, init_type, 'InitializeCriticalSection')
    init_func = self.module.get_global('InitializeCriticalSection')
    builder.call(init_func, [cs_mem])

    # Store in mutex struct
    mutex_mem = builder.call(malloc_func, [ir.Constant(type_map[INT64], 8)])
    mutex = builder.bitcast(mutex_mem, mutex_ptr)
    ptr = builder.gep(mutex, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    builder.store(cs_mem, ptr)
    builder.ret(mutex)

    # mutex_lock(mutex*)
    lock_type = ir.FunctionType(type_map[VOID], [mutex_ptr])
    lock_func = ir.Function(self.module, lock_type, 'mutex_lock')
    lock_func.linkage = 'internal'
    entry = lock_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    ptr = builder.gep(lock_func.args[0], [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    cs = builder.load(ptr)
    enter_type = ir.FunctionType(type_map[VOID], [i8_ptr])
    if 'EnterCriticalSection' not in self.module.globals:
        ir.Function(self.module, enter_type, 'EnterCriticalSection')
    enter_func = self.module.get_global('EnterCriticalSection')
    builder.call(enter_func, [cs])
    builder.ret_void()

    # mutex_unlock(mutex*)
    unlock_type = ir.FunctionType(type_map[VOID], [mutex_ptr])
    unlock_func = ir.Function(self.module, unlock_type, 'mutex_unlock')
    unlock_func.linkage = 'internal'
    entry = unlock_func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)
    ptr = builder.gep(unlock_func.args[0], [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    cs = builder.load(ptr)
    leave_type = ir.FunctionType(type_map[VOID], [i8_ptr])
    if 'LeaveCriticalSection' not in self.module.globals:
        ir.Function(self.module, leave_type, 'LeaveCriticalSection')
    leave_func = self.module.get_global('LeaveCriticalSection')
    builder.call(leave_func, [cs])
    builder.ret_void()


def _define_mutex_ops_unix(self, mutex_ptr, i8_ptr):
    """Unix mutex using pthread_mutex."""
    # Similar implementation for pthread
    pass


def define_channel_create(self):
    """Create a new channel with circular buffer queue and synchronization.
    meteor.channel* channel_create(i64 capacity)
    """
    channel_struct = self.search_scopes('meteor.channel')
    channel_ptr = channel_struct.as_pointer()
    i8_ptr = type_map[INT8].as_pointer()
    i8_ptr_ptr = i8_ptr.as_pointer()

    func_type = ir.FunctionType(channel_ptr, [type_map[INT64]])
    func = ir.Function(self.module, func_type, 'channel_create')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    capacity = func.args[0]
    malloc_func = self.module.get_global('malloc')
    null_ptr = ir.Constant(i8_ptr, None)

    # Declare pthread_mutex_init and pthread_cond_init
    mutex_init_type = ir.FunctionType(type_map[INT32], [i8_ptr, i8_ptr])
    cond_init_type = ir.FunctionType(type_map[INT32], [i8_ptr, i8_ptr])
    try:
        mutex_init = self.module.get_global('pthread_mutex_init')
    except KeyError:
        mutex_init = ir.Function(self.module, mutex_init_type, 'pthread_mutex_init')
    try:
        cond_init = self.module.get_global('pthread_cond_init')
    except KeyError:
        cond_init = ir.Function(self.module, cond_init_type, 'pthread_cond_init')

    # Allocate channel struct
    channel_size = ir.Constant(type_map[INT64], 80)
    raw_mem = builder.call(malloc_func, [channel_size])
    channel = builder.bitcast(raw_mem, channel_ptr)

    # Allocate and init mutex (index 1) - pthread_mutex_t is ~40 bytes
    mutex_size = ir.Constant(type_map[INT64], 48)
    mutex_mem = builder.call(malloc_func, [mutex_size])
    mutex_ptr = builder.gep(channel, [zero_32, ir.Constant(type_map[INT32], 1)])
    builder.store(mutex_mem, mutex_ptr)
    builder.call(mutex_init, [mutex_mem, null_ptr])

    # Allocate and init cond (index 2) - pthread_cond_t is ~48 bytes
    cond_size = ir.Constant(type_map[INT64], 48)
    cond_mem = builder.call(malloc_func, [cond_size])
    cond_ptr = builder.gep(channel, [zero_32, ir.Constant(type_map[INT32], 2)])
    builder.store(cond_mem, cond_ptr)
    builder.call(cond_init, [cond_mem, null_ptr])

    # Allocate queue array (capacity * sizeof(void*))
    ptr_size = ir.Constant(type_map[INT64], 8)
    queue_size = builder.mul(capacity, ptr_size)
    queue_mem = builder.call(malloc_func, [queue_size])
    queue_ptr = builder.bitcast(queue_mem, i8_ptr_ptr)

    # Store queue pointer (index 3)
    queue_field = builder.gep(channel, [zero_32, ir.Constant(type_map[INT32], 3)])
    builder.store(queue_ptr, queue_field)

    # Initialize capacity (index 4)
    cap_ptr = builder.gep(channel, [zero_32, ir.Constant(type_map[INT32], 4)])
    builder.store(capacity, cap_ptr)

    # Initialize head, tail, count to 0
    head_ptr = builder.gep(channel, [zero_32, ir.Constant(type_map[INT32], 5)])
    builder.store(ir.Constant(type_map[INT64], 0), head_ptr)

    tail_ptr = builder.gep(channel, [zero_32, ir.Constant(type_map[INT32], 6)])
    builder.store(ir.Constant(type_map[INT64], 0), tail_ptr)

    count_ptr = builder.gep(channel, [zero_32, ir.Constant(type_map[INT32], 7)])
    builder.store(ir.Constant(type_map[INT64], 0), count_ptr)

    builder.ret(channel)


def define_channel_send(self):
    """Send a value to channel with mutex synchronization.
    void channel_send(meteor.channel* ch, i8* value)

    Thread-safe: locks mutex, stores value, signals cond, unlocks.
    """
    channel_struct = self.search_scopes('meteor.channel')
    channel_ptr = channel_struct.as_pointer()
    i8_ptr = type_map[INT8].as_pointer()

    func_type = ir.FunctionType(type_map[VOID], [channel_ptr, i8_ptr])
    func = ir.Function(self.module, func_type, 'channel_send')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    ch = func.args[0]
    value = func.args[1]

    # Declare pthread functions
    lock_type = ir.FunctionType(type_map[INT32], [i8_ptr])
    signal_type = ir.FunctionType(type_map[INT32], [i8_ptr])
    try:
        mutex_lock = self.module.get_global('pthread_mutex_lock')
    except KeyError:
        mutex_lock = ir.Function(self.module, lock_type, 'pthread_mutex_lock')
    try:
        mutex_unlock = self.module.get_global('pthread_mutex_unlock')
    except KeyError:
        mutex_unlock = ir.Function(self.module, lock_type, 'pthread_mutex_unlock')
    try:
        cond_signal = self.module.get_global('pthread_cond_signal')
    except KeyError:
        cond_signal = ir.Function(self.module, signal_type, 'pthread_cond_signal')

    # Load mutex pointer (index 1)
    mutex_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 1)])
    mutex = builder.load(mutex_ptr_ptr)

    # Lock mutex
    builder.call(mutex_lock, [mutex])

    # Load queue, capacity, tail
    queue_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 3)])
    queue = builder.load(queue_ptr_ptr)
    cap_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 4)])
    capacity = builder.load(cap_ptr)
    tail_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 6)])
    tail = builder.load(tail_ptr)

    # Store value at queue[tail]
    slot_ptr = builder.gep(queue, [tail])
    builder.store(value, slot_ptr)

    # tail = (tail + 1) % capacity
    tail_plus_one = builder.add(tail, ir.Constant(type_map[INT64], 1))
    new_tail = builder.urem(tail_plus_one, capacity)
    builder.store(new_tail, tail_ptr)

    # count++
    count_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 7)])
    count = builder.load(count_ptr)
    new_count = builder.add(count, ir.Constant(type_map[INT64], 1))
    builder.store(new_count, count_ptr)

    # Signal waiting receivers
    cond_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 2)])
    cond = builder.load(cond_ptr_ptr)
    builder.call(cond_signal, [cond])

    # Unlock mutex
    builder.call(mutex_unlock, [mutex])

    builder.ret_void()


def define_channel_recv(self):
    """Receive a value from channel with blocking wait.
    i8* channel_recv(meteor.channel* ch)

    Thread-safe: locks mutex, waits if empty, receives value, unlocks.
    """
    channel_struct = self.search_scopes('meteor.channel')
    channel_ptr = channel_struct.as_pointer()
    i8_ptr = type_map[INT8].as_pointer()

    func_type = ir.FunctionType(i8_ptr, [channel_ptr])
    func = ir.Function(self.module, func_type, 'channel_recv')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    wait_loop = func.append_basic_block('wait_loop')
    recv_block = func.append_basic_block('recv')

    builder = ir.IRBuilder(entry)
    ch = func.args[0]

    # Declare pthread functions
    lock_type = ir.FunctionType(type_map[INT32], [i8_ptr])
    wait_type = ir.FunctionType(type_map[INT32], [i8_ptr, i8_ptr])
    try:
        mutex_lock = self.module.get_global('pthread_mutex_lock')
    except KeyError:
        mutex_lock = ir.Function(self.module, lock_type, 'pthread_mutex_lock')
    try:
        mutex_unlock = self.module.get_global('pthread_mutex_unlock')
    except KeyError:
        mutex_unlock = ir.Function(self.module, lock_type, 'pthread_mutex_unlock')
    try:
        cond_wait = self.module.get_global('pthread_cond_wait')
    except KeyError:
        cond_wait = ir.Function(self.module, wait_type, 'pthread_cond_wait')

    # Load mutex and cond pointers
    mutex_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 1)])
    mutex = builder.load(mutex_ptr_ptr)
    cond_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 2)])
    cond = builder.load(cond_ptr_ptr)

    # Lock mutex
    builder.call(mutex_lock, [mutex])
    builder.branch(wait_loop)

    # Wait loop: while count == 0, wait on cond
    builder.position_at_end(wait_loop)
    count_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 7)])
    count = builder.load(count_ptr)
    is_empty = builder.icmp_unsigned(EQUALS, count, ir.Constant(type_map[INT64], 0))

    # Create a do_wait block for the cond_wait call
    do_wait = func.append_basic_block('do_wait')
    builder.cbranch(is_empty, do_wait, recv_block)

    # do_wait: call cond_wait and loop back
    builder.position_at_end(do_wait)
    builder.call(cond_wait, [cond, mutex])
    builder.branch(wait_loop)

    # Recv block
    builder.position_at_end(recv_block)

    # Load queue, capacity, head
    queue_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 3)])
    queue = builder.load(queue_ptr_ptr)
    cap_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 4)])
    capacity = builder.load(cap_ptr)
    head_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 5)])
    head = builder.load(head_ptr)

    # Load value from queue[head]
    slot_ptr = builder.gep(queue, [head])
    value = builder.load(slot_ptr)

    # head = (head + 1) % capacity
    head_plus_one = builder.add(head, ir.Constant(type_map[INT64], 1))
    new_head = builder.urem(head_plus_one, capacity)
    builder.store(new_head, head_ptr)

    # count--
    count2 = builder.load(count_ptr)
    new_count = builder.sub(count2, ir.Constant(type_map[INT64], 1))
    builder.store(new_count, count_ptr)

    # Unlock mutex
    builder.call(mutex_unlock, [mutex])

    builder.ret(value)


def define_channel_try_recv(self):
    """Non-blocking receive from channel.
    {i8*, i1} channel_try_recv(meteor.channel* ch)

    Returns {value, success}. If channel empty, returns {null, false}.
    """
    channel_struct = self.search_scopes('meteor.channel')
    channel_ptr = channel_struct.as_pointer()
    i8_ptr = type_map[INT8].as_pointer()

    # Return type: {i8*, i1}
    result_type = ir.LiteralStructType([i8_ptr, type_map[BOOL]])

    func_type = ir.FunctionType(result_type, [channel_ptr])
    func = ir.Function(self.module, func_type, 'channel_try_recv')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    empty_block = func.append_basic_block('empty')
    recv_block = func.append_basic_block('recv')

    builder = ir.IRBuilder(entry)
    ch = func.args[0]
    null_ptr = ir.Constant(i8_ptr, None)

    # Declare pthread functions
    lock_type = ir.FunctionType(type_map[INT32], [i8_ptr])
    try:
        mutex_lock = self.module.get_global('pthread_mutex_lock')
    except KeyError:
        mutex_lock = ir.Function(self.module, lock_type, 'pthread_mutex_lock')
    try:
        mutex_unlock = self.module.get_global('pthread_mutex_unlock')
    except KeyError:
        mutex_unlock = ir.Function(self.module, lock_type, 'pthread_mutex_unlock')

    # Load mutex
    mutex_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 1)])
    mutex = builder.load(mutex_ptr_ptr)

    # Lock mutex
    builder.call(mutex_lock, [mutex])

    # Check if empty
    count_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 7)])
    count = builder.load(count_ptr)
    is_empty = builder.icmp_unsigned(EQUALS, count, ir.Constant(type_map[INT64], 0))
    builder.cbranch(is_empty, empty_block, recv_block)

    # Empty: unlock and return {null, false}
    builder.position_at_end(empty_block)
    builder.call(mutex_unlock, [mutex])
    empty_result = ir.Constant(result_type, [ir.Constant(i8_ptr, None),
                                              ir.Constant(type_map[BOOL], 0)])
    builder.ret(empty_result)

    # Recv: get value
    builder.position_at_end(recv_block)
    queue_ptr_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 3)])
    queue = builder.load(queue_ptr_ptr)
    cap_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 4)])
    capacity = builder.load(cap_ptr)
    head_ptr = builder.gep(ch, [zero_32, ir.Constant(type_map[INT32], 5)])
    head = builder.load(head_ptr)

    slot_ptr = builder.gep(queue, [head])
    value = builder.load(slot_ptr)

    # Update head and count
    head_plus_one = builder.add(head, ir.Constant(type_map[INT64], 1))
    new_head = builder.urem(head_plus_one, capacity)
    builder.store(new_head, head_ptr)

    new_count = builder.sub(count, ir.Constant(type_map[INT64], 1))
    builder.store(new_count, count_ptr)

    # Unlock and return {value, true}
    builder.call(mutex_unlock, [mutex])
    result = builder.insert_value(ir.Constant(result_type, ir.Undefined), value, 0)
    result = builder.insert_value(result, ir.Constant(type_map[BOOL], 1), 1)
    builder.ret(result)


def define_meteor_retain(self):
    """Define retain function for incrementing strong reference count.
    void meteor_retain(meteor.header* obj)
    Supports atomic operations for frozen objects.
    """
    from meteor.compiler.base import OBJECT_HEADER, HEADER_STRONG_RC, HEADER_FLAGS, FLAG_IS_FROZEN

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(type_map[VOID], [header_ptr])
    func = ir.Function(self.module, func_type, 'meteor_retain')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    do_inc = func.append_basic_block('do_inc')
    frozen_inc = func.append_basic_block('frozen_inc')
    normal_inc = func.append_basic_block('normal_inc')
    exit_block = func.append_basic_block('exit')

    builder = ir.IRBuilder(entry)
    obj_ptr = func.args[0]

    # Null check
    null_ptr = ir.Constant(header_ptr, None)
    is_null = builder.icmp_unsigned(EQUALS, obj_ptr, null_ptr)
    builder.cbranch(is_null, exit_block, do_inc)

    # Check IS_FROZEN flag
    builder.position_at_end(do_inc)
    flags_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_FLAGS)])
    flags = builder.load(flags_ptr)
    frozen_mask = ir.Constant(type_map[UINT8], FLAG_IS_FROZEN)
    is_frozen = builder.and_(flags, frozen_mask)
    is_frozen_bool = builder.icmp_unsigned(NOT_EQUALS, is_frozen, ir.Constant(type_map[UINT8], 0))
    builder.cbranch(is_frozen_bool, frozen_inc, normal_inc)

    # Frozen: use atomic increment
    builder.position_at_end(frozen_inc)
    rc_ptr_f = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)])
    builder.atomic_rmw('add', rc_ptr_f, ir.Constant(type_map[UINT32], 1), 'seq_cst')
    builder.branch(exit_block)

    # Normal: use regular increment
    builder.position_at_end(normal_inc)
    rc_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)])
    rc = builder.load(rc_ptr)
    new_rc = builder.add(rc, ir.Constant(type_map[UINT32], 1))
    builder.store(new_rc, rc_ptr)
    builder.branch(exit_block)

    builder.position_at_end(exit_block)
    builder.ret_void()


def define_meteor_release(self):
    """Define release function for decrementing strong reference count.
    void meteor_release(meteor.header* obj)
    Supports atomic operations for frozen objects.
    """
    from meteor.compiler.base import (OBJECT_HEADER, HEADER_STRONG_RC,
                                       HEADER_WEAK_RC, HEADER_FLAGS, FLAG_IS_ZOMBIE, FLAG_IS_FROZEN)

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(type_map[VOID], [header_ptr])
    func = ir.Function(self.module, func_type, 'meteor_release')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    do_dec = func.append_basic_block('do_dec')
    frozen_dec = func.append_basic_block('frozen_dec')
    normal_dec = func.append_basic_block('normal_dec')
    check_zero = func.append_basic_block('check_zero')
    do_destroy = func.append_basic_block('do_destroy')
    check_weak = func.append_basic_block('check_weak')
    do_free = func.append_basic_block('do_free')
    exit_block = func.append_basic_block('exit')

    builder = ir.IRBuilder(entry)
    obj_ptr = func.args[0]

    # Null check
    null_ptr = ir.Constant(header_ptr, None)
    is_null = builder.icmp_unsigned(EQUALS, obj_ptr, null_ptr)
    builder.cbranch(is_null, exit_block, do_dec)

    # Check IS_FROZEN flag
    builder.position_at_end(do_dec)
    flags_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_FLAGS)])
    flags = builder.load(flags_ptr)
    frozen_mask = ir.Constant(type_map[UINT8], FLAG_IS_FROZEN)
    is_frozen = builder.and_(flags, frozen_mask)
    is_frozen_bool = builder.icmp_unsigned(NOT_EQUALS, is_frozen, ir.Constant(type_map[UINT8], 0))
    builder.cbranch(is_frozen_bool, frozen_dec, normal_dec)

    # Frozen: use atomic decrement
    builder.position_at_end(frozen_dec)
    rc_ptr_f = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)])
    old_rc_f = builder.atomic_rmw('sub', rc_ptr_f, ir.Constant(type_map[UINT32], 1), 'seq_cst')
    new_rc_f = builder.sub(old_rc_f, ir.Constant(type_map[UINT32], 1))
    builder.branch(check_zero)

    # Normal: use regular decrement
    builder.position_at_end(normal_dec)
    rc_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)])
    rc = builder.load(rc_ptr)
    new_rc_n = builder.sub(rc, ir.Constant(type_map[UINT32], 1))
    builder.store(new_rc_n, rc_ptr)
    builder.branch(check_zero)

    # Check if RC reached zero (use phi node)
    builder.position_at_end(check_zero)
    new_rc = builder.phi(type_map[UINT32])
    new_rc.add_incoming(new_rc_f, frozen_dec)
    new_rc.add_incoming(new_rc_n, normal_dec)
    is_zero = builder.icmp_unsigned(EQUALS, new_rc, ir.Constant(type_map[UINT32], 0))
    builder.cbranch(is_zero, do_destroy, exit_block)

    # Destroy payload before setting zombie flag
    builder.position_at_end(do_destroy)
    destroy_func = self.module.get_global('meteor_destroy')
    if destroy_func:
        builder.call(destroy_func, [obj_ptr])

    # Set IS_ZOMBIE flag
    flags_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_FLAGS)])
    old_flags = builder.load(flags_ptr)
    new_flags = builder.or_(old_flags, ir.Constant(type_map[UINT8], FLAG_IS_ZOMBIE))
    builder.store(new_flags, flags_ptr)
    builder.branch(check_weak)

    # Check if weak_rc is also zero
    builder.position_at_end(check_weak)
    weak_rc_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_WEAK_RC)])
    weak_rc = builder.load(weak_rc_ptr)
    weak_is_zero = builder.icmp_unsigned(EQUALS, weak_rc, ir.Constant(type_map[UINT32], 0))
    builder.cbranch(weak_is_zero, do_free, exit_block)

    # Free the header
    builder.position_at_end(do_free)
    free_func = self.module.get_global('free')
    if not free_func:
        free_type = ir.FunctionType(type_map[VOID], [type_map[INT8].as_pointer()])
        free_func = ir.Function(self.module, free_type, 'free')
    obj_i8 = builder.bitcast(obj_ptr, type_map[INT8].as_pointer())
    builder.call(free_func, [obj_i8])
    builder.branch(exit_block)

    builder.position_at_end(exit_block)
    builder.ret_void()


def define_meteor_weak_retain(self):
    """Increment weak reference count."""
    from meteor.compiler.base import OBJECT_HEADER, HEADER_WEAK_RC

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(type_map[VOID], [header_ptr])
    func = ir.Function(self.module, func_type, 'meteor_weak_retain')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    not_null = func.append_basic_block('not_null')
    exit_block = func.append_basic_block('exit')

    builder = ir.IRBuilder(entry)
    obj_ptr = func.args[0]

    null_ptr = ir.Constant(header_ptr, None)
    is_null = builder.icmp_unsigned(EQUALS, obj_ptr, null_ptr)
    builder.cbranch(is_null, exit_block, not_null)

    builder.position_at_end(not_null)
    weak_rc_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_WEAK_RC)])
    weak_rc = builder.load(weak_rc_ptr)
    new_weak_rc = builder.add(weak_rc, ir.Constant(type_map[UINT32], 1))
    builder.store(new_weak_rc, weak_rc_ptr)
    builder.branch(exit_block)

    builder.position_at_end(exit_block)
    builder.ret_void()


def define_meteor_weak_release(self):
    """Decrement weak reference count. Free header if zombie and weak_rc==0."""
    from meteor.compiler.base import (OBJECT_HEADER, HEADER_WEAK_RC,
                                       HEADER_FLAGS, FLAG_IS_ZOMBIE)

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(type_map[VOID], [header_ptr])
    func = ir.Function(self.module, func_type, 'meteor_weak_release')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    not_null = func.append_basic_block('not_null')
    check_free = func.append_basic_block('check_free')
    do_free = func.append_basic_block('do_free')
    exit_block = func.append_basic_block('exit')

    builder = ir.IRBuilder(entry)
    obj_ptr = func.args[0]

    null_ptr = ir.Constant(header_ptr, None)
    is_null = builder.icmp_unsigned(EQUALS, obj_ptr, null_ptr)
    builder.cbranch(is_null, exit_block, not_null)

    builder.position_at_end(not_null)
    weak_rc_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_WEAK_RC)])
    weak_rc = builder.load(weak_rc_ptr)
    new_weak_rc = builder.sub(weak_rc, ir.Constant(type_map[UINT32], 1))
    builder.store(new_weak_rc, weak_rc_ptr)
    builder.branch(check_free)

    # Check if zombie and weak_rc == 0
    builder.position_at_end(check_free)
    flags_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_FLAGS)])
    flags = builder.load(flags_ptr)
    is_zombie = builder.and_(flags, ir.Constant(type_map[UINT8], FLAG_IS_ZOMBIE))
    is_zombie_bool = builder.icmp_unsigned(NOT_EQUALS, is_zombie, ir.Constant(type_map[UINT8], 0))
    weak_is_zero = builder.icmp_unsigned(EQUALS, new_weak_rc, ir.Constant(type_map[UINT32], 0))
    should_free = builder.and_(is_zombie_bool, weak_is_zero)
    builder.cbranch(should_free, do_free, exit_block)

    builder.position_at_end(do_free)
    free_func = self.module.get_global('free')
    obj_i8 = builder.bitcast(obj_ptr, type_map[INT8].as_pointer())
    builder.call(free_func, [obj_i8])
    builder.branch(exit_block)

    builder.position_at_end(exit_block)
    builder.ret_void()


def define_meteor_weak_upgrade(self):
    """Try to upgrade weak reference to strong reference.
    Returns NULL if object is zombie, otherwise increments strong_rc.
    """
    from meteor.compiler.base import (OBJECT_HEADER, HEADER_STRONG_RC,
                                       HEADER_FLAGS, FLAG_IS_ZOMBIE)

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(header_ptr, [header_ptr])
    func = ir.Function(self.module, func_type, 'meteor_weak_upgrade')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    not_null = func.append_basic_block('not_null')
    do_retain = func.append_basic_block('do_retain')
    ret_null = func.append_basic_block('ret_null')
    exit_block = func.append_basic_block('exit')

    builder = ir.IRBuilder(entry)
    obj_ptr = func.args[0]

    null_ptr = ir.Constant(header_ptr, None)
    is_null = builder.icmp_unsigned(EQUALS, obj_ptr, null_ptr)
    builder.cbranch(is_null, ret_null, not_null)

    builder.position_at_end(not_null)
    flags_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_FLAGS)])
    flags = builder.load(flags_ptr)
    is_zombie = builder.and_(flags, ir.Constant(type_map[UINT8], FLAG_IS_ZOMBIE))
    is_zombie_bool = builder.icmp_unsigned(NOT_EQUALS, is_zombie, ir.Constant(type_map[UINT8], 0))
    builder.cbranch(is_zombie_bool, ret_null, do_retain)

    builder.position_at_end(do_retain)
    rc_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)])
    rc = builder.load(rc_ptr)
    new_rc = builder.add(rc, ir.Constant(type_map[UINT32], 1))
    builder.store(new_rc, rc_ptr)
    builder.branch(exit_block)

    builder.position_at_end(ret_null)
    builder.branch(exit_block)

    builder.position_at_end(exit_block)
    result = builder.phi(header_ptr)
    result.add_incoming(obj_ptr, do_retain)
    result.add_incoming(null_ptr, ret_null)
    builder.ret(result)


def define_meteor_destroy(self):
    """Type-specific destructor - releases internal data based on type_tag.
    
    For arrays (type_tag == TYPE_TAG_LIST): free the data pointer.
    For classes (type_tag == TYPE_TAG_CLASS): do nothing (class destructors handle this).
    For other types: type-specific handling.
    
    Array layout: { header(16), size(8), capacity(8), data(ptr) }
    - Data is at offset 32 bytes from start
    
    Class layout: { header(16), [class fields] }
    - No internal data pointer to free (destructor handles field cleanup)
    """
    from meteor.compiler.base import OBJECT_HEADER, HEADER_TYPE_TAG, TYPE_TAG_CLASS, TYPE_TAG_LIST

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(type_map[VOID], [header_ptr])
    func = ir.Function(self.module, func_type, 'meteor_destroy')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    check_array = func.append_basic_block('check_array')
    free_array_data = func.append_basic_block('free_array_data')
    exit_block = func.append_basic_block('exit')

    builder = ir.IRBuilder(entry)
    obj_ptr = func.args[0]

    # Null check
    null_ptr = ir.Constant(header_ptr, None)
    is_null = builder.icmp_unsigned('==', obj_ptr, null_ptr)
    not_null_block = func.append_basic_block('not_null')
    builder.cbranch(is_null, exit_block, not_null_block)
    
    builder.position_at_end(not_null_block)
    
    # Load type_tag from header
    type_tag_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_TYPE_TAG)])
    type_tag = builder.load(type_tag_ptr)
    
    # For CLASS types, skip destruction (class destructors handle this separately)
    is_class = builder.icmp_unsigned('==', type_tag, ir.Constant(type_map[UINT8], TYPE_TAG_CLASS))
    builder.cbranch(is_class, exit_block, check_array)
    
    # Check if it's an array type (LIST, STR, etc.)
    builder.position_at_end(check_array)
    is_array = builder.icmp_unsigned('==', type_tag, ir.Constant(type_map[UINT8], TYPE_TAG_LIST))
    # Also check for STR (which uses TYPE_TAG_STR = 4)
    is_str = builder.icmp_unsigned('==', type_tag, ir.Constant(type_map[UINT8], 4))  # TYPE_TAG_STR
    is_array_or_str = builder.or_(is_array, is_str)
    builder.cbranch(is_array_or_str, free_array_data, exit_block)
    
    # Free array data pointer
    builder.position_at_end(free_array_data)
    
    # Cast header* to i8*
    i8_ptr = builder.bitcast(obj_ptr, type_map[INT8].as_pointer())
    
    # Data is at offset 16 (header) + 8 (size) + 8 (capacity) = 32 bytes
    data_offset = ir.Constant(type_map[INT], 32)
    data_ptr_ptr = builder.gep(i8_ptr, [data_offset])
    data_ptr_ptr = builder.bitcast(data_ptr_ptr, type_map[INT8].as_pointer().as_pointer())
    
    # Load the data pointer
    data_ptr = builder.load(data_ptr_ptr)
    
    # Free the data if not null
    data_null = ir.Constant(type_map[INT8].as_pointer(), None)
    data_is_null = builder.icmp_unsigned('==', data_ptr, data_null)
    
    do_free = func.append_basic_block('do_free')
    builder.cbranch(data_is_null, exit_block, do_free)
    
    builder.position_at_end(do_free)
    free_func = self.module.get_global('free')
    builder.call(free_func, [data_ptr])
    builder.branch(exit_block)

    builder.position_at_end(exit_block)
    builder.ret_void()


def define_meteor_alloc(self):
    """Allocate memory with object header initialized.
    meteor.header* meteor_alloc(i64 size, u8 type_tag)
    """
    from meteor.compiler.base import (OBJECT_HEADER, HEADER_STRONG_RC,
                                       HEADER_WEAK_RC, HEADER_FLAGS,
                                       HEADER_TYPE_TAG, FLAG_NONE)

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(header_ptr, [type_map[INT], type_map[UINT8]])
    func = ir.Function(self.module, func_type, 'meteor_alloc')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    size = func.args[0]
    type_tag = func.args[1]

    # Add header size (16 bytes)
    header_size = ir.Constant(type_map[INT], 16)
    total_size = builder.add(size, header_size)

    # Call malloc
    malloc_func = self.module.get_global('malloc')
    mem = builder.call(malloc_func, [total_size])
    obj_ptr = builder.bitcast(mem, header_ptr)

    # Initialize header: strong_rc = 1
    rc_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_STRONG_RC)])
    builder.store(ir.Constant(type_map[UINT32], 1), rc_ptr)

    # weak_rc = 0
    weak_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_WEAK_RC)])
    builder.store(ir.Constant(type_map[UINT32], 0), weak_ptr)

    # flags = 0
    flags_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_FLAGS)])
    builder.store(ir.Constant(type_map[UINT8], FLAG_NONE), flags_ptr)

    # type_tag
    tag_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_TYPE_TAG)])
    builder.store(type_tag, tag_ptr)

    builder.ret(obj_ptr)


def define_meteor_freeze(self):
    """Freeze an object (set IS_FROZEN flag).
    meteor.header* meteor_freeze(meteor.header* obj)
    """
    from meteor.compiler.base import OBJECT_HEADER, HEADER_FLAGS, FLAG_IS_FROZEN

    header_struct = self.search_scopes(OBJECT_HEADER)
    header_ptr = header_struct.as_pointer()

    func_type = ir.FunctionType(header_ptr, [header_ptr])
    func = ir.Function(self.module, func_type, 'meteor_freeze')
    func.linkage = 'internal'

    entry = func.append_basic_block('entry')
    builder = ir.IRBuilder(entry)

    obj_ptr = func.args[0]

    # Set IS_FROZEN flag
    flags_ptr = builder.gep(obj_ptr, [zero_32, ir.Constant(type_map[INT32], HEADER_FLAGS)])
    old_flags = builder.load(flags_ptr)
    new_flags = builder.or_(old_flags, ir.Constant(type_map[UINT8], FLAG_IS_FROZEN))
    builder.store(new_flags, flags_ptr)

    builder.ret(obj_ptr)
