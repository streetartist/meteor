from llvmlite import ir

import meteor.compiler.llvmlite_custom
from meteor.compiler.base import NUM_TYPES, llvm_type_map, type_map
from meteor.grammar import *
from meteor.utils import error

# TODO: Determine size using a comparison function
int_types = ('i1', 'i8', 'i16', 'i32', 'i64', 'i128')
float_types = ('float', 'double')


def is_bigint_type(typ):
    """Check if a type is bigint"""
    if isinstance(typ, ir.PointerType):
        return getattr(typ.pointee, 'name', '') == 'bigint'
    return getattr(typ, 'name', '') == 'bigint'


def is_decimal_type(typ):
    """Check if a type is decimal"""
    if isinstance(typ, ir.PointerType):
        return getattr(typ.pointee, 'name', '') == 'decimal'
    return getattr(typ, 'name', '') == 'decimal'


def is_number_type(typ):
    """Check if a type is number"""
    if isinstance(typ, ir.PointerType):
        return getattr(typ.pointee, 'name', '') == 'number'
    return getattr(typ, 'name', '') == 'number'


def is_int_type(typ):
    """Check if a type is an integer type"""
    return isinstance(typ, ir.IntType)


def int_to_bigint(self, int_val):
    """Convert an int value to a bigint"""
    bigint_struct = type_map[BIGINT]
    bigint_ptr = self.builder.alloca(bigint_struct, name="int_to_bigint")

    # Create digits array
    u64_array_ptr = self.create_array(type_map[UINT64])

    # Check sign
    zero = ir.Constant(type_map[INT], 0)
    is_negative = self.builder.icmp_signed(LESS_THAN, int_val, zero)
    abs_val = self.builder.select(is_negative, self.builder.neg(int_val), int_val)

    # Append absolute value as single digit
    append_func = self.module.get_global('i64.array.append')
    self.builder.call(append_func, [u64_array_ptr, abs_val])

    # Store sign
    sign_ptr = self.builder.gep(bigint_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    self.builder.store(is_negative, sign_ptr)

    # Store digits
    digits_ptr = self.builder.gep(bigint_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 1)])
    self.builder.store(u64_array_ptr, digits_ptr)

    return bigint_ptr


def int_to_decimal(self, int_val):
    """Convert an int value to a decimal (int -> decimal with exponent 0)"""
    decimal_struct = type_map[DECIMAL]
    malloc_func = self.module.get_global('malloc')

    # Allocate decimal on heap
    dec_mem = self.builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    decimal_ptr = self.builder.bitcast(dec_mem, decimal_struct.as_pointer())

    # Convert int to bigint for mantissa
    bigint_ptr = int_to_bigint(self, int_val)

    # Store mantissa (bigint pointer)
    mantissa_ptr = self.builder.gep(decimal_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    self.builder.store(bigint_ptr, mantissa_ptr)

    # Store exponent = 0
    exp_ptr = self.builder.gep(decimal_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 1)])
    self.builder.store(ir.Constant(type_map[INT64], 0), exp_ptr)

    return decimal_ptr


def float_to_decimal(self, float_val):
    """Convert a float/double value to a decimal"""
    decimal_struct = type_map[DECIMAL]
    bigint_struct = type_map[BIGINT]
    malloc_func = self.module.get_global('malloc')
    append_func = self.module.get_global('i64.array.append')

    # Allocate decimal on heap
    dec_mem = self.builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    decimal_ptr = self.builder.bitcast(dec_mem, decimal_struct.as_pointer())

    # Allocate bigint for mantissa
    bigint_ptr = self.builder.alloca(bigint_struct, name="float_to_bigint")
    u64_array_ptr = self.create_array(type_map[UINT64])

    # Convert float to i64 mantissa with fixed precision (6 decimal places)
    # mantissa = (int)(float_val * 1000000)
    scale = ir.Constant(ir.DoubleType(), 1000000.0)
    if isinstance(float_val.type, ir.FloatType):
        float_val = self.builder.fpext(float_val, ir.DoubleType())
    scaled = self.builder.fmul(float_val, scale)
    mantissa_i64 = self.builder.fptosi(scaled, type_map[INT64])

    # Check sign
    zero_i64 = ir.Constant(type_map[INT64], 0)
    is_negative = self.builder.icmp_signed(LESS_THAN, mantissa_i64, zero_i64)
    abs_mantissa = self.builder.select(is_negative, self.builder.neg(mantissa_i64), mantissa_i64)

    # Store mantissa digit
    self.builder.call(append_func, [u64_array_ptr, abs_mantissa])

    # Store sign in bigint
    sign_ptr = self.builder.gep(bigint_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    self.builder.store(is_negative, sign_ptr)

    # Store digits in bigint
    digits_ptr = self.builder.gep(bigint_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 1)])
    self.builder.store(u64_array_ptr, digits_ptr)

    # Store mantissa (bigint pointer) in decimal
    mantissa_ptr = self.builder.gep(decimal_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    self.builder.store(bigint_ptr, mantissa_ptr)

    # Store exponent = -6 (because we scaled by 10^6)
    exp_ptr = self.builder.gep(decimal_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 1)])
    self.builder.store(ir.Constant(type_map[INT64], -6), exp_ptr)

    return decimal_ptr


def bigint_to_decimal(self, bigint_val):
    """Convert a bigint to a decimal (bigint -> decimal with exponent 0)"""
    decimal_struct = type_map[DECIMAL]
    malloc_func = self.module.get_global('malloc')

    # Allocate decimal on heap
    dec_mem = self.builder.call(malloc_func, [ir.Constant(type_map[INT], 16)])
    decimal_ptr = self.builder.bitcast(dec_mem, decimal_struct.as_pointer())

    # Get bigint pointer (if not already a pointer, alloca and store)
    if not isinstance(bigint_val.type, ir.PointerType):
        bigint_ptr = self.builder.alloca(bigint_val.type, name="bigint_tmp")
        self.builder.store(bigint_val, bigint_ptr)
    else:
        bigint_ptr = bigint_val

    # Store mantissa (bigint pointer)
    mantissa_ptr = self.builder.gep(decimal_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 0)])
    self.builder.store(bigint_ptr, mantissa_ptr)

    # Store exponent = 0
    exp_ptr = self.builder.gep(decimal_ptr, [ir.Constant(type_map[INT32], 0), ir.Constant(type_map[INT32], 1)])
    self.builder.store(ir.Constant(type_map[INT64], 0), exp_ptr)

    return decimal_ptr


def is_float_type(typ):
    """Check if a type is a float type"""
    return isinstance(typ, (ir.FloatType, ir.DoubleType))


def number_to_decimal(self, num_val):
    """Convert number to decimal using runtime dispatch"""
    # Get pointer to number
    if not isinstance(num_val.type, ir.PointerType):
        num_ptr = self.builder.alloca(num_val.type, name="num_tmp")
        self.builder.store(num_val, num_ptr)
    else:
        num_ptr = num_val

    # Call runtime conversion function
    conv_func = self.module.get_global('number_to_decimal')
    return self.builder.call(conv_func, [num_ptr], 'num_to_dec')


def hasFunction(self, func_name):
    for func in self.module.functions:
        if func.name == func_name:
            return True

    return False


def userdef_unary_str(op, expr):
    # Check first if it's an built in type, then user defined type
    type_name = expr.type.name if hasattr(expr.type, 'name') else str(expr.type)
    return OPERATOR + '.' + op + '.' + type_name


def userdef_binary_str(op, left, right):
    # Check first if it's a type, then if it's an built in type, then user defined type
    ltype_name = str(left) if not hasattr(left, 'type') else (str(left.type) if not hasattr(left.type, 'name') else left.type.name)
    rtype_name = str(right) if not hasattr(right, 'type') else (str(right.type) if not hasattr(right.type, 'name') else right.type.name)
    return OPERATOR + '.' + op + '.' + ltype_name + '.' + rtype_name


def unary_op(self, node):
    op = node.op
    expr = self.visit(node.expr)
    if hasFunction(self, userdef_unary_str(op, expr)) and \
       self.current_function.name != userdef_unary_str(op, expr):
        return self.builder.call(self.module.get_global(userdef_unary_str(op, expr)),
                                 [expr], "unop")
    elif op == MINUS:
        if isinstance(expr.type, ir.IntType):
            return self.builder.neg(expr)
        elif isinstance(expr.type, (ir.FloatType, ir.DoubleType)):
            return self.builder.fsub(ir.Constant(ir.DoubleType(), 0), expr)
        elif getattr(expr.type, 'name', '') == 'bigint':
            if not isinstance(expr.type, ir.PointerType):
                tmp = self.builder.alloca(expr.type)
                self.builder.store(expr, tmp)
                ptr = tmp
            else:
                ptr = expr
            return self.builder.call(self.module.get_global('bigint_neg'), [ptr], 'bigint_neg_tmp')
    elif op == NOT:
        if isinstance(expr.type, ir.IntType) and str(expr.type).split("i")[1] == '1':
            return self.builder.not_(expr)
    elif op == BINARY_ONES_COMPLIMENT:
        if isinstance(expr.type, ir.IntType):
            return self.builder.not_(expr)
    else:
        error('file={} line={}: Unknown operator {} for {}'.format(
            self.file_name,
            node.line_num,
            op,
            expr
        ))


def binary_op(self, node):
    op = node.op
    left = self.visit(node.left)
    right = self.visit(node.right)

    if hasFunction(self, userdef_binary_str(op, left, right)):
        return self.builder.call(self.module.get_global(userdef_binary_str(op, left, right)),
                                 (left, right), "binop")
    elif op == CAST:
        return cast_ops(self, left, right, node)
    elif op in (IS, IS_NOT):
        return is_ops(self, op, left, right, node)
    elif isinstance(left.type, ir.IntType) and isinstance(right.type, ir.IntType):
        return int_ops(self, op, left, right, node)
    elif type(left.type) in NUM_TYPES and type(right.type) in NUM_TYPES:
        if isinstance(left.type, ir.IntType):
            left = cast_ops(self, left, right.type, node)
        elif isinstance(right.type, ir.IntType):
            right = cast_ops(self, right, left.type, node)
        return float_ops(self, op, left, right, node)
    elif is_enum(left.type) and is_enum(right.type):
        return enum_ops(self, op, left, right, node)
    elif (is_bigint_type(left.type) or is_bigint_type(right.type)) and \
         not is_decimal_type(left.type) and not is_decimal_type(right.type):
        # Handle bigint operations, including mixed bigint/int
        # But NOT if one operand is decimal (decimal takes priority)
        # Convert int to bigint if needed
        if is_bigint_type(left.type) and is_int_type(right.type):
            right = int_to_bigint(self, right)
        elif is_int_type(left.type) and is_bigint_type(right.type):
            left = int_to_bigint(self, left)

        # Get pointers for bigint operations - use entry block alloca to avoid stack overflow in loops
        if not isinstance(left.type, ir.PointerType):
            tmp_left = self.get_entry_alloca("bigint_op_left", type_map[BIGINT])
            self.builder.store(left, tmp_left)
            left_ptr = tmp_left
        else:
            left_ptr = left

        if not isinstance(right.type, ir.PointerType):
            tmp_right = self.get_entry_alloca("bigint_op_right", type_map[BIGINT])
            self.builder.store(right, tmp_right)
            right_ptr = tmp_right
        else:
            right_ptr = right

        if op == PLUS:
            return self.builder.call(self.module.get_global('bigint_add'), [left_ptr, right_ptr], 'bigint_add_tmp')
        elif op == MINUS:
            return self.builder.call(self.module.get_global('bigint_sub'), [left_ptr, right_ptr], 'bigint_sub_tmp')
        elif op == MUL:
            return self.builder.call(self.module.get_global('bigint_mul'), [left_ptr, right_ptr], 'bigint_mul_tmp')
        elif op == FLOORDIV:
            return self.builder.call(self.module.get_global('bigint_div'), [left_ptr, right_ptr], 'bigint_div_tmp')
        elif op == MOD:
            return self.builder.call(self.module.get_global('bigint_mod'), [left_ptr, right_ptr], 'bigint_mod_tmp')
        elif op in (EQUALS, NOT_EQUALS, LESS_THAN, LESS_THAN_OR_EQUAL_TO, GREATER_THAN, GREATER_THAN_OR_EQUAL_TO):
            cmp_res = self.builder.call(self.module.get_global('bigint_cmp'), [left_ptr, right_ptr], 'bigint_cmp_res')
            zero = ir.Constant(type_map[INT32], 0)
            if op == EQUALS:
                res = self.builder.icmp_signed(EQUALS, cmp_res, zero)
            elif op == NOT_EQUALS:
                res = self.builder.icmp_signed(NOT_EQUALS, cmp_res, zero)
            elif op == LESS_THAN:
                res = self.builder.icmp_signed(LESS_THAN, cmp_res, zero)
            elif op == LESS_THAN_OR_EQUAL_TO:
                res = self.builder.icmp_signed(LESS_THAN_OR_EQUAL_TO, cmp_res, zero)
            elif op == GREATER_THAN:
                res = self.builder.icmp_signed(GREATER_THAN, cmp_res, zero)
            elif op == GREATER_THAN_OR_EQUAL_TO:
                res = self.builder.icmp_signed(GREATER_THAN_OR_EQUAL_TO, cmp_res, zero)
            return self.builder.zext(res, type_map[BOOL])
    elif is_number_type(left.type) or is_number_type(right.type):
        # Handle number type - convert to decimal for operations
        if is_number_type(left.type):
            left = number_to_decimal(self, left)
        if is_number_type(right.type):
            right = number_to_decimal(self, right)
        # Now both are decimal, fall through to decimal operations
        # Convert other operand to decimal if needed
        if not is_decimal_type(left.type) and is_int_type(left.type):
            left = int_to_decimal(self, left)
        elif not is_decimal_type(left.type) and is_float_type(left.type):
            left = float_to_decimal(self, left)
        elif not is_decimal_type(left.type) and is_bigint_type(left.type):
            left = bigint_to_decimal(self, left)
        if not is_decimal_type(right.type) and is_int_type(right.type):
            right = int_to_decimal(self, right)
        elif not is_decimal_type(right.type) and is_float_type(right.type):
            right = float_to_decimal(self, right)
        elif not is_decimal_type(right.type) and is_bigint_type(right.type):
            right = bigint_to_decimal(self, right)

        # Get pointers for decimal operations
        left_ptr = left
        right_ptr = right

        if op == PLUS:
            return self.builder.call(self.module.get_global('decimal_add'), [left_ptr, right_ptr], 'decimal_add_tmp')
        elif op == MINUS:
            return self.builder.call(self.module.get_global('decimal_sub'), [left_ptr, right_ptr], 'decimal_sub_tmp')
        elif op == MUL:
            return self.builder.call(self.module.get_global('decimal_mul'), [left_ptr, right_ptr], 'decimal_mul_tmp')
        else:
            error('file={} line={}: Unsupported operator {} for number'.format(
                self.file_name, node.line_num, op))
    elif is_decimal_type(left.type) or is_decimal_type(right.type):
        # Handle decimal operations with auto type conversion
        # Convert int/float/bigint to decimal if needed
        if is_decimal_type(left.type) and is_int_type(right.type):
            right = int_to_decimal(self, right)
        elif is_int_type(left.type) and is_decimal_type(right.type):
            left = int_to_decimal(self, left)
        elif is_decimal_type(left.type) and is_float_type(right.type):
            right = float_to_decimal(self, right)
        elif is_float_type(left.type) and is_decimal_type(right.type):
            left = float_to_decimal(self, left)
        elif is_decimal_type(left.type) and is_bigint_type(right.type):
            right = bigint_to_decimal(self, right)
        elif is_bigint_type(left.type) and is_decimal_type(right.type):
            left = bigint_to_decimal(self, left)

        # Get pointers for decimal operations
        if not isinstance(left.type, ir.PointerType):
            tmp_left = self.builder.alloca(left.type)
            self.builder.store(left, tmp_left)
            left_ptr = tmp_left
        else:
            left_ptr = left

        if not isinstance(right.type, ir.PointerType):
            tmp_right = self.builder.alloca(right.type)
            self.builder.store(right, tmp_right)
            right_ptr = tmp_right
        else:
            right_ptr = right

        if op == PLUS:
            return self.builder.call(self.module.get_global('decimal_add'), [left_ptr, right_ptr], 'decimal_add_tmp')
        elif op == MINUS:
            return self.builder.call(self.module.get_global('decimal_sub'), [left_ptr, right_ptr], 'decimal_sub_tmp')
        elif op == MUL:
            return self.builder.call(self.module.get_global('decimal_mul'), [left_ptr, right_ptr], 'decimal_mul_tmp')
        elif op == FLOORDIV:
            return self.builder.call(self.module.get_global('decimal_div'), [left_ptr, right_ptr], 'decimal_div_tmp')
        else:
            error('file={} line={}: Unsupported operator {} for decimal'.format(
                self.file_name, node.line_num, op))
    else:
        error('file={} line={}: Unknown operator {} for {} and {}'.format(
            self.file_name,
            node.line_num,
            op, node.left, node.right
        ))


def is_enum(typ):
    if typ.is_pointer:
        typ = typ.pointee
    return hasattr(typ, 'type') and typ.type == ENUM


def is_ops(self, op, left, right, node):
    orig = str(left.type)
    compare = str(right)
    if op == IS:
        return self.const(orig == compare, BOOL)
    elif op == IS_NOT:
        return self.const(orig != compare, BOOL)
    else:
        raise SyntaxError('Unknown identity operator', node.op)


def enum_ops(self, op, left, right, node):
    if left.type.is_pointer:
        left = self.builder.load(left)
    if right.type.is_pointer:
        right = self.builder.load(right)

    if op == EQUALS:
        left_val = self.builder.extract_value(left, 0)
        right_val = self.builder.extract_value(right, 0)
        return self.builder.icmp_unsigned(op, left_val, right_val, 'cmptmp')
    else:
        raise SyntaxError('Unknown binary operator', node.op)


def int_ops(self, op, left, right, node):
    # Cast values if they're different but compatible
    if str(left.type) in int_types and \
       str(right.type) in int_types and \
       str(left.type) != str(right.type):
        width_left = int(str(left.type).split("i")[1])
        width_right = int(str(right.type).split("i")[1])
        if width_left > width_right:
            right = cast_ops(self, right, left.type, node)
        else:
            left = cast_ops(self, left, right.type, node)

    if op == PLUS:
        return self.builder.add(left, right, 'addtmp')
    elif op == MINUS:
        return self.builder.sub(left, right, 'subtmp')
    elif op == MUL:
        return self.builder.mul(left, right, 'multmp')
    elif op == FLOORDIV:
        if left.type.signed:
            return self.builder.sdiv(left, right, 'divtmp')
        else:
            return self.builder.udiv(left, right, 'divtmp')
    elif op == DIV:
        return (self.builder.fdiv(cast_ops(self, left, type_map[DOUBLE], node),
                                  cast_ops(self, right, type_map[DOUBLE], node), 'fdivtmp'))
    elif op == MOD:
        if left.type.signed:
            return self.builder.srem(left, right, 'modtmp')
        else:
            return self.builder.urem(left, right, 'modtmp')
    elif op == POWER:
        temp = self.builder.alloca(type_map[INT])
        self.builder.store(left, temp)
        for _ in range(node.right.value - 1):
            res = self.builder.mul(self.builder.load(temp), left)
            self.builder.store(res, temp)
        return self.builder.load(temp)
    elif op == AND:
        return self.builder.and_(left, right)
    elif op == OR:
        return self.builder.or_(left, right)
    elif op == XOR:
        return self.builder.xor(left, right)
    elif op == ARITHMATIC_LEFT_SHIFT or op == BINARY_LEFT_SHIFT:
        return self.builder.shl(left, right)
    elif op == ARITHMATIC_RIGHT_SHIFT:
        return self.builder.ashr(left, right)
    elif op == BINARY_RIGHT_SHIFT:
        return self.builder.lshr(left, right)
    elif op in (EQUALS, NOT_EQUALS, LESS_THAN, LESS_THAN_OR_EQUAL_TO, GREATER_THAN, GREATER_THAN_OR_EQUAL_TO):
        if left.type.signed:
            cmp_res = self.builder.icmp_signed(op, left, right, 'cmptmp')
        else:
            cmp_res = self.builder.icmp_unsigned(op, left, right, 'cmptmp')
        return self.builder.uitofp(cmp_res, type_map[BOOL], 'booltmp')
    else:
        raise SyntaxError('Unknown binary operator', node.op)


def float_ops(self, op, left, right, node):
    # Cast values if they're different but compatible
    if str(left.type) in float_types and \
       str(right.type) in float_types and \
       str(left.type) != str(right.type):  # Do a more general approach for size comparisons
        width_left = 0 if str(left.type) == 'float' else 1
        width_right = 0 if str(right.type) == 'float' else 1
        if width_left > width_right:
            right = cast_ops(self, right, left.type, node)
        else:
            left = cast_ops(self, left, right.type, node)

    if op == PLUS:
        return self.builder.fadd(left, right, 'faddtmp')
    elif op == MINUS:
        return self.builder.fsub(left, right, 'fsubtmp')
    elif op == MUL:
        return self.builder.fmul(left, right, 'fmultmp')
    elif op == FLOORDIV:
        return (self.builder.sdiv(cast_ops(self, left, ir.IntType(64), node),
                                  cast_ops(self, right, ir.IntType(64), node), 'ffloordivtmp'))
    elif op == DIV:
        return self.builder.fdiv(left, right, 'fdivtmp')
    elif op == MOD:
        return self.builder.frem(left, right, 'fmodtmp')
    elif op == POWER:
        temp = self.builder.alloca(type_map[DOUBLE])
        self.builder.store(left, temp)
        for _ in range(node.right.value - 1):
            res = self.builder.fmul(self.builder.load(temp), left)
            self.builder.store(res, temp)
        return self.builder.load(temp)
    elif op in (NOT_EQUALS):
        cmp_res = self.builder.fcmp_unordered(op, left, right, 'cmptmp')
        return self.builder.uitofp(cmp_res, type_map[BOOL], 'booltmp')
    elif op in (EQUALS, LESS_THAN, LESS_THAN_OR_EQUAL_TO, GREATER_THAN, GREATER_THAN_OR_EQUAL_TO):
        cmp_res = self.builder.fcmp_ordered(op, left, right, 'cmptmp')
        return self.builder.uitofp(cmp_res, type_map[BOOL], 'booltmp')
    else:
        raise SyntaxError('Unknown binary operator', node.op)


def cast_ops(self, left, right, node):
    orig_type = str(left.type)
    cast_type = str(right)

    # Extract type name for identified types like %"decimal"
    if hasattr(right, 'name'):
        cast_type_name = right.name
    else:
        cast_type_name = cast_type

    if cast_type in int_types and \
       orig_type in int_types and \
       cast_type == orig_type:
        left.type.signed = right.signed
        return left

    elif orig_type == cast_type:  # cast to the same type
        return left

    elif cast_type in int_types:  # int
        if orig_type in float_types:  # from float
            if right.signed:
                return self.builder.fptosi(left, llvm_type_map[cast_type])
            else:
                return self.builder.fptoui(left, llvm_type_map[cast_type])
        elif orig_type in int_types:  # from signed int
            width_cast = int(cast_type.split("i")[1])
            width_orig = int(orig_type.split("i")[1])
            if width_cast > width_orig:
                if left.type.signed:
                    return self.builder.sext(left, llvm_type_map[cast_type])
                else:
                    return self.builder.zext(left, llvm_type_map[cast_type])
            elif width_orig > width_cast:
                return self.builder.trunc(left, llvm_type_map[cast_type])

    elif cast_type in float_types:  # float
        if orig_type in int_types:  # from signed int
            if left.type.signed:
                return self.builder.sitofp(left, type_map[cast_type])
            else:
                return self.builder.uitofp(left, type_map[cast_type])
        elif orig_type in float_types:  # from float
            if cast_type == 'double' and orig_type == 'float':
                return self.builder.fpext(left, llvm_type_map[cast_type])
            elif cast_type == 'float' and orig_type == 'double':
                return self.builder.fptrunc(left, llvm_type_map[cast_type])

    elif cast_type_name == 'decimal':
        # Cast to decimal
        if orig_type in int_types:
            return int_to_decimal(self, left)
        elif orig_type in float_types:
            return float_to_decimal(self, left)
        elif orig_type == 'bigint' or (isinstance(left.type, ir.PointerType) and getattr(left.type.pointee, 'name', '') == 'bigint'):
            return bigint_to_decimal(self, left)
        elif orig_type == 'decimal' or (isinstance(left.type, ir.PointerType) and getattr(left.type.pointee, 'name', '') == 'decimal'):
            return left  # already decimal

    elif cast_type_name == 'bigint':
        # Cast to bigint
        if orig_type in int_types:
            return int_to_bigint(self, left)
        elif orig_type == 'bigint' or (isinstance(left.type, ir.PointerType) and getattr(left.type.pointee, 'name', '') == 'bigint'):
            return left  # already bigint

    elif cast_type == str(type_map[STR]):
        raise NotImplementedError

    elif cast_type in (ANY, FUNC, CLASS, ENUM, DICT, LIST, TUPLE):
        raise TypeError('file={} line={}: Cannot cast from {} to type {}'.format(
            self.file_name,
            node.line_num,
            orig_type,
            cast_type
        ))

    raise TypeError('file={} line={}: Unknown cast from {} to {}'.format(
        self.file_name,
        node.line_num,
        orig_type,
        cast_type
    ))
