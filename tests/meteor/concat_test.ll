; ModuleID = '<string>'
source_filename = "<string>"
target triple = "unknown-unknown-unknown"

%i64.array = type { %meteor.header, i64, i64, ptr }
%meteor.header = type { i32, i32, i8, i8, i16 }
%bigint = type { %meteor.header, i1, ptr }
%decimal = type { %meteor.header, ptr, i64 }
%number = type { %meteor.header, i8, ptr }
%dynamic = type { %meteor.header, i32, ptr }
%meteor.mutex = type { ptr }
%meteor.channel = type { %meteor.header, ptr, ptr, ptr, i64, i64, i64, i64 }

@uam_err_msg = constant [51 x i8] c"Error: Use-After-Move - accessing moved variable!\0A\00"
@minus_str = constant [2 x i8] c"-\00"
@fmt_bigint = constant [6 x i8] c"%llu\0A\00"
@BIGINT_DIV_CONST_1E9 = constant i64 18446744073
@fmt_zero = constant [3 x i8] c"0\0A\00"
@fmt_dec_first = constant [5 x i8] c"%llu\00"
@fmt_dec_pad = constant [7 x i8] c"%09llu\00"
@nl_str = constant [2 x i8] c"\0A\00"
@dec_zero_fmt = constant [3 x i8] c"0\0A\00"
@dec_minus_fmt = constant [2 x i8] c"-\00"
@dec_digit_fmt = constant [5 x i8] c"%llu\00"
@dec_dot_fmt = constant [2 x i8] c".\00"
@dec_exp_fmt = constant [6 x i8] c"e%lld\00"
@dec_nl_fmt = constant [2 x i8] c"\0A\00"
@fmt_lld = constant [6 x i8] c"%lld\0A\00"
@fmt_f = constant [4 x i8] c"%g\0A\00"
@dyn_fmt_int = constant [6 x i8] c"%lld\0A\00"
@dyn_fmt_flt = constant [4 x i8] c"%g\0A\00"
@dyn_fmt_true = constant [6 x i8] c"true\0A\00"
@dyn_fmt_false = constant [7 x i8] c"false\0A\00"
@dyn_fmt_unk = constant [11 x i8] c"<dynamic>\0A\00"

declare ptr @malloc(i64)

declare ptr @realloc(ptr, i64)

declare void @free(ptr)

declare void @exit(i32)

declare void @abort()

declare i64 @putchar(i64)

declare i32 @printf(ptr, ...)

declare i64 @scanf(ptr, ...)

declare i8 @getchar()

declare i64 @puts(ptr)

declare i32 @fflush(ptr)

define void @i64.array.init(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %i64.array, ptr %.5, i32 0, i32 1
  store i64 0, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %i64.array, ptr %.8, i32 0, i32 2
  store i64 16, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %i64.array, ptr %.11, i32 0, i32 3
  %.13 = load i64, ptr %.9, align 4
  %.14 = add i64 %.13, 1
  %.15 = mul i64 %.14, 8
  %.16 = call ptr @malloc(i64 %.15)
  %.17 = bitcast ptr %.16 to ptr
  store ptr %.17, ptr %.12, align 8
  %.19 = load ptr, ptr %.3, align 8
  %.20 = getelementptr inbounds %i64.array, ptr %.19, i32 0, i32 0
  %.21 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 0
  store i32 1, ptr %.21, align 4
  %.23 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 3
  store i8 4, ptr %.23, align 1
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define void @i64.array.double_capacity_if_full(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %i64.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %i64.array, ptr %.8, i32 0, i32 2
  %.10 = load i64, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %i64.array, ptr %.11, i32 0, i32 3
  %.13 = icmp sge i64 %.7, %.10
  br i1 %.13, label %double_capacity, label %exit

exit:                                             ; preds = %double_capacity, %entry
  ret void

double_capacity:                                  ; preds = %entry
  %.15 = mul i64 %.10, 2
  store i64 %.15, ptr %.9, align 4
  %.17 = load i64, ptr %.9, align 4
  %.18 = add i64 %.17, 1
  %.19 = mul i64 %.18, 8
  %.20 = load ptr, ptr %.12, align 8
  %.21 = bitcast ptr %.20 to ptr
  %.22 = call ptr @realloc(ptr %.21, i64 %.19)
  %.23 = bitcast ptr %.22 to ptr
  store ptr %.23, ptr %.12, align 8
  br label %exit
}

define void @i64.array.append(ptr %self, i64 %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca i64, align 8
  store i64 %.2, ptr %.6, align 4
  %.8 = load ptr, ptr %.4, align 8
  call void @i64.array.double_capacity_if_full(ptr %.8)
  %.10 = load ptr, ptr %.4, align 8
  %.11 = getelementptr inbounds %i64.array, ptr %.10, i32 0, i32 1
  %.12 = load i64, ptr %.11, align 4
  %.13 = load ptr, ptr %.4, align 8
  %.14 = getelementptr inbounds %i64.array, ptr %.13, i32 0, i32 3
  %.15 = load ptr, ptr %.14, align 8
  %.16 = getelementptr inbounds i64, ptr %.15, i64 %.12
  %.17 = load i64, ptr %.6, align 4
  store i64 %.17, ptr %.16, align 4
  %.19 = add i64 %.12, 1
  store i64 %.19, ptr %.11, align 4
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define i64 @i64.array.get(ptr %self, i64 %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca i64, align 8
  store i64 %.2, ptr %.6, align 4
  %.8 = load i64, ptr %.6, align 4
  %.9 = load ptr, ptr %.4, align 8
  %.10 = getelementptr inbounds %i64.array, ptr %.9, i32 0, i32 1
  %.11 = load i64, ptr %.10, align 4
  %.12 = icmp sge i64 %.8, %.11
  br i1 %.12, label %index_out_of_bounds, label %is_index_less_than_zero

exit:                                             ; preds = %get
  %.27 = load i64, ptr %.25, align 4
  ret i64 %.27

index_out_of_bounds:                              ; preds = %entry
  call void @exit(i32 1)
  unreachable

is_index_less_than_zero:                          ; preds = %entry
  %.16 = icmp slt i64 %.8, 0
  br i1 %.16, label %negative_index, label %get

negative_index:                                   ; preds = %is_index_less_than_zero
  %.18 = add i64 %.11, %.8
  store i64 %.18, ptr %.6, align 4
  br label %get

get:                                              ; preds = %negative_index, %is_index_less_than_zero
  %.21 = load ptr, ptr %.4, align 8
  %.22 = getelementptr inbounds %i64.array, ptr %.21, i32 0, i32 3
  %.23 = load i64, ptr %.6, align 4
  %.24 = load ptr, ptr %.22, align 8
  %.25 = getelementptr inbounds i64, ptr %.24, i64 %.23
  br label %exit
}

define void @i64.array.set(ptr %self, i64 %.2, i64 %.3) {
entry:
  %.5 = alloca ptr, align 8
  store ptr %self, ptr %.5, align 8
  %.7 = alloca i64, align 8
  store i64 %.2, ptr %.7, align 4
  %.9 = alloca i64, align 8
  store i64 %.3, ptr %.9, align 4
  %.11 = load i64, ptr %.7, align 4
  %.12 = load ptr, ptr %.5, align 8
  %.13 = getelementptr inbounds %i64.array, ptr %.12, i32 0, i32 1
  %.14 = load i64, ptr %.13, align 4
  %.15 = icmp sge i64 %.11, %.14
  br i1 %.15, label %index_out_of_bounds, label %is_index_less_than_zero

exit:                                             ; preds = %set
  ret void

index_out_of_bounds:                              ; preds = %entry
  %.17 = alloca [26 x i8], align 1
  store [26 x i8] c"Array index out of bounds\00", ptr %.17, align 1
  %.19 = getelementptr [26 x i8], ptr %.17, i64 0, i64 0
  %.20 = bitcast ptr %.19 to ptr
  %.21 = call i64 @puts(ptr %.20)
  call void @exit(i32 1)
  unreachable

is_index_less_than_zero:                          ; preds = %entry
  %.24 = icmp slt i64 %.11, 0
  br i1 %.24, label %negative_index, label %set

negative_index:                                   ; preds = %is_index_less_than_zero
  %.26 = add i64 %.14, %.11
  store i64 %.26, ptr %.7, align 4
  br label %set

set:                                              ; preds = %negative_index, %is_index_less_than_zero
  %.29 = load ptr, ptr %.5, align 8
  %.30 = getelementptr inbounds %i64.array, ptr %.29, i32 0, i32 3
  %.31 = load i64, ptr %.7, align 4
  %.32 = load ptr, ptr %.30, align 8
  %.33 = getelementptr inbounds i64, ptr %.32, i64 %.31
  %.34 = load i64, ptr %.9, align 4
  store i64 %.34, ptr %.33, align 4
  br label %exit
}

define i64 @i64.array.length(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %i64.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  ret i64 %.7
}

define void @"@create_range"(ptr %.1, i64 %.2, i64 %.3) {
entry:
  %.5 = alloca ptr, align 8
  store ptr %.1, ptr %.5, align 8
  %.7 = alloca i64, align 8
  store i64 %.2, ptr %.7, align 4
  %.9 = alloca i64, align 8
  store i64 %.3, ptr %.9, align 4
  %.11 = alloca i64, align 8
  %.12 = load i64, ptr %.7, align 4
  store i64 %.12, ptr %.11, align 4
  br label %test

test:                                             ; preds = %body, %entry
  %.15 = load i64, ptr %.11, align 4
  %.16 = load i64, ptr %.9, align 4
  %.17 = icmp slt i64 %.15, %.16
  br i1 %.17, label %body, label %exit

body:                                             ; preds = %test
  %.19 = load ptr, ptr %.5, align 8
  %.20 = load i64, ptr %.11, align 4
  call void @i64.array.append(ptr %.19, i64 %.20)
  %.22 = load i64, ptr %.11, align 4
  %.23 = add i64 1, %.22
  store i64 %.23, ptr %.11, align 4
  br label %test

exit:                                             ; preds = %test
  ret void
}

define void @"@int_to_str"(ptr %.1, i64 %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %.1, ptr %.4, align 8
  %.6 = alloca i64, align 8
  store i64 %.2, ptr %.6, align 4
  %.8 = alloca i64, align 8
  %.9 = load i64, ptr %.6, align 4
  %.10 = sdiv i64 %.9, 10
  %.11 = icmp sgt i64 %.10, 0
  %.12 = load i64, ptr %.6, align 4
  %.13 = srem i64 %.12, 10
  store i64 %.13, ptr %.8, align 4
  br i1 %.11, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif
  ret void

entry.if:                                         ; preds = %entry
  %.16 = load ptr, ptr %.4, align 8
  call void @"@int_to_str"(ptr %.16, i64 %.10)
  br label %entry.endif

entry.endif:                                      ; preds = %entry.if, %entry
  %.19 = load i64, ptr %.8, align 4
  %.20 = add i64 48, %.19
  %.21 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.21, i64 %.20)
  br label %exit
}

define void @"@bool_to_str"(ptr %.1, i1 %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %.1, ptr %.4, align 8
  %.6 = icmp eq i1 %.2, false
  br i1 %.6, label %entry.if, label %entry.else

exit:                                             ; preds = %entry.endif
  ret void

entry.if:                                         ; preds = %entry
  %.8 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.8, i64 102)
  %.10 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.10, i64 97)
  %.12 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.12, i64 108)
  %.14 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.14, i64 115)
  %.16 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.16, i64 101)
  br label %entry.endif

entry.else:                                       ; preds = %entry
  %.19 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.19, i64 116)
  %.21 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.21, i64 114)
  %.23 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.23, i64 117)
  %.25 = load ptr, ptr %.4, align 8
  call void @i64.array.append(ptr %.25, i64 101)
  br label %entry.endif

entry.endif:                                      ; preds = %entry.else, %entry.if
  br label %exit
}

define void @print(ptr %.1) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %.1, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  br label %zero_length_check

zero_length_check:                                ; preds = %entry
  %.8 = icmp sle i64 0, %.6
  br i1 %.8, label %non_zero_length, label %exit

non_zero_length:                                  ; preds = %zero_length_check
  %.10 = alloca i64, align 8
  store i64 0, ptr %.10, align 4
  br label %check_if_done

check_if_done:                                    ; preds = %print_it, %non_zero_length
  %.13 = load i64, ptr %.10, align 4
  %.14 = icmp slt i64 %.13, %.6
  br i1 %.14, label %print_it, label %exit

print_it:                                         ; preds = %check_if_done
  %.16 = load ptr, ptr %.3, align 8
  %.17 = load i64, ptr %.10, align 4
  %.18 = call i64 @i64.array.get(ptr %.16, i64 %.17)
  %.19 = call i64 @putchar(i64 %.18)
  %.20 = load i64, ptr %.10, align 4
  %.21 = add i64 1, %.20
  store i64 %.21, ptr %.10, align 4
  br label %check_if_done

exit:                                             ; preds = %check_if_done, %zero_length_check
  %.24 = call i64 @putchar(i64 10)
  ret void
}

define void @print_bigint(ptr %.1) {
entry:
  %.3 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.4 = load i1, ptr %.3, align 1
  %.5 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %null_error, label %valid

null_error:                                       ; preds = %entry
  %.9 = bitcast ptr @uam_err_msg to ptr
  %.10 = call i32 (ptr, ...) @printf(ptr %.9)
  call void @exit(i32 1)
  unreachable

valid:                                            ; preds = %entry
  %.13 = icmp ne i1 %.4, false
  br i1 %.13, label %print_neg, label %print_pos

print_neg:                                        ; preds = %valid
  %.15 = bitcast ptr @minus_str to ptr
  %.16 = call i32 (ptr, ...) @printf(ptr %.15)
  br label %print_value

print_pos:                                        ; preds = %valid
  br label %print_value

print_value:                                      ; preds = %print_pos, %print_neg
  %.19 = getelementptr %i64.array, ptr %.6, i32 0, i32 1
  %.20 = load i64, ptr %.19, align 4
  %.21 = getelementptr %i64.array, ptr %.6, i32 0, i32 3
  %.22 = load ptr, ptr %.21, align 8
  %.23 = icmp eq i64 %.20, 1
  br i1 %.23, label %single_digit, label %multi_digit

single_digit:                                     ; preds = %print_value
  %.25 = getelementptr i64, ptr %.22, i64 0
  %.26 = load i64, ptr %.25, align 4
  %.27 = bitcast ptr @fmt_bigint to ptr
  %.28 = call i32 (ptr, ...) @printf(ptr %.27, i64 %.26)
  br label %end

multi_digit:                                      ; preds = %print_value
  %.30 = load i64, ptr @BIGINT_DIV_CONST_1E9, align 4
  %.31 = call ptr @malloc(i64 40)
  %.32 = bitcast ptr %.31 to ptr
  call void @i64.array.init(ptr %.32)
  %.34 = call ptr @malloc(i64 40)
  %.35 = bitcast ptr %.34 to ptr
  call void @i64.array.init(ptr %.35)
  %.37 = alloca i64, align 8
  store i64 0, ptr %.37, align 4
  br label %copy_cond

end:                                              ; preds = %print_dec_finish, %print_zero, %single_digit
  ret void

copy_cond:                                        ; preds = %copy_body, %multi_digit
  %.40 = load i64, ptr %.37, align 4
  %.41 = icmp slt i64 %.40, %.20
  br i1 %.41, label %copy_body, label %copy_end

copy_body:                                        ; preds = %copy_cond
  %.43 = getelementptr i64, ptr %.22, i64 %.40
  %.44 = load i64, ptr %.43, align 4
  call void @i64.array.append(ptr %.35, i64 %.44)
  %.46 = add i64 %.40, 1
  store i64 %.46, ptr %.37, align 4
  br label %copy_cond

copy_end:                                         ; preds = %copy_cond
  %.49 = alloca i64, align 8
  %.50 = alloca i64, align 8
  %.51 = alloca i64, align 8
  br label %div_loop

div_loop:                                         ; preds = %trim_end, %copy_end
  %.53 = getelementptr %i64.array, ptr %.35, i32 0, i32 1
  %.54 = load i64, ptr %.53, align 4
  store i64 %.54, ptr %.51, align 4
  %.56 = icmp eq i64 %.54, 0
  br i1 %.56, label %div_end, label %div_check_zero

div_check_zero:                                   ; preds = %div_loop
  %.58 = getelementptr %i64.array, ptr %.35, i32 0, i32 3
  %.59 = load ptr, ptr %.58, align 8
  %.60 = sub i64 %.54, 1
  %.61 = getelementptr i64, ptr %.59, i64 %.60
  %.62 = load i64, ptr %.61, align 4
  %.63 = icmp eq i64 %.62, 0
  %.64 = icmp eq i64 %.54, 1
  %.65 = and i1 %.63, %.64
  br i1 %.65, label %div_end, label %div_body

div_body:                                         ; preds = %div_check_zero
  store i64 0, ptr %.49, align 4
  %.68 = load i64, ptr %.51, align 4
  %.69 = sub i64 %.68, 1
  store i64 %.69, ptr %.50, align 4
  br label %div_inner_cond

div_end:                                          ; preds = %div_check_zero, %div_loop
  %.119 = getelementptr %i64.array, ptr %.32, i32 0, i32 1
  %.120 = load i64, ptr %.119, align 4
  %.121 = icmp sgt i64 %.120, 0
  br i1 %.121, label %print_digits, label %print_zero

div_inner_cond:                                   ; preds = %div_inner_body, %div_body
  %.72 = load i64, ptr %.50, align 4
  %.73 = icmp sge i64 %.72, 0
  br i1 %.73, label %div_inner_body, label %div_inner_end

div_inner_body:                                   ; preds = %div_inner_cond
  %.75 = getelementptr %i64.array, ptr %.35, i32 0, i32 3
  %.76 = load ptr, ptr %.75, align 8
  %.77 = getelementptr i64, ptr %.76, i64 %.72
  %.78 = load i64, ptr %.77, align 4
  %.79 = load i64, ptr %.49, align 4
  %.80 = mul i64 %.79, %.30
  %.81 = mul i64 %.79, 709551616
  %.82 = add i64 %.81, %.78
  %.83 = icmp ult i64 %.82, %.78
  %.84 = udiv i64 %.82, 1000000000
  %.85 = urem i64 %.82, 1000000000
  %.86 = select i1 %.83, i64 %.30, i64 0
  %.87 = select i1 %.83, i64 709551616, i64 0
  %.88 = add i64 %.85, %.87
  %.89 = urem i64 %.88, 1000000000
  %.90 = udiv i64 %.88, 1000000000
  %.91 = add i64 %.80, %.84
  %.92 = add i64 %.91, %.86
  %.93 = add i64 %.92, %.90
  store i64 %.93, ptr %.77, align 4
  store i64 %.89, ptr %.49, align 4
  %.96 = sub i64 %.72, 1
  store i64 %.96, ptr %.50, align 4
  br label %div_inner_cond

div_inner_end:                                    ; preds = %div_inner_cond
  %.99 = load i64, ptr %.49, align 4
  call void @i64.array.append(ptr %.32, i64 %.99)
  br label %trim_cond

trim_cond:                                        ; preds = %trim_do, %div_inner_end
  %.102 = getelementptr %i64.array, ptr %.35, i32 0, i32 1
  %.103 = load i64, ptr %.102, align 4
  %.104 = icmp sgt i64 %.103, 0
  br i1 %.104, label %trim_body, label %trim_end

trim_body:                                        ; preds = %trim_cond
  %.106 = getelementptr %i64.array, ptr %.35, i32 0, i32 3
  %.107 = load ptr, ptr %.106, align 8
  %.108 = sub i64 %.103, 1
  %.109 = getelementptr i64, ptr %.107, i64 %.108
  %.110 = load i64, ptr %.109, align 4
  %.111 = icmp eq i64 %.110, 0
  %.112 = icmp sgt i64 %.103, 1
  %.113 = and i1 %.111, %.112
  br i1 %.113, label %trim_do, label %trim_end

trim_end:                                         ; preds = %trim_body, %trim_cond
  br label %div_loop

trim_do:                                          ; preds = %trim_body
  %.115 = sub i64 %.103, 1
  store i64 %.115, ptr %.102, align 4
  br label %trim_cond

print_zero:                                       ; preds = %div_end
  %.123 = bitcast ptr @fmt_zero to ptr
  %.124 = call i32 (ptr, ...) @printf(ptr %.123)
  br label %end

print_digits:                                     ; preds = %div_end
  %.126 = alloca i64, align 8
  %.127 = sub i64 %.120, 1
  store i64 %.127, ptr %.126, align 4
  br label %print_dec_cond

print_dec_cond:                                   ; preds = %print_cont_blk, %print_digits
  %.130 = load i64, ptr %.126, align 4
  %.131 = icmp sge i64 %.130, 0
  br i1 %.131, label %print_dec_body, label %print_dec_finish

print_dec_body:                                   ; preds = %print_dec_cond
  %.133 = getelementptr %i64.array, ptr %.32, i32 0, i32 3
  %.134 = load ptr, ptr %.133, align 8
  %.135 = getelementptr i64, ptr %.134, i64 %.130
  %.136 = load i64, ptr %.135, align 4
  %.137 = icmp eq i64 %.130, %.127
  br i1 %.137, label %print_first_blk, label %print_pad_blk

print_dec_finish:                                 ; preds = %print_dec_cond
  %.148 = getelementptr %i64.array, ptr %.35, i32 0, i32 3
  %.149 = load ptr, ptr %.148, align 8
  %.150 = bitcast ptr %.149 to ptr
  call void @free(ptr %.150)
  %.152 = bitcast ptr %.35 to ptr
  call void @free(ptr %.152)
  %.154 = getelementptr %i64.array, ptr %.32, i32 0, i32 3
  %.155 = load ptr, ptr %.154, align 8
  %.156 = bitcast ptr %.155 to ptr
  call void @free(ptr %.156)
  %.158 = bitcast ptr %.32 to ptr
  call void @free(ptr %.158)
  %.160 = bitcast ptr @nl_str to ptr
  %.161 = call i32 (ptr, ...) @printf(ptr %.160)
  br label %end

print_first_blk:                                  ; preds = %print_dec_body
  %.139 = bitcast ptr @fmt_dec_first to ptr
  %.140 = call i32 (ptr, ...) @printf(ptr %.139, i64 %.136)
  br label %print_cont_blk

print_pad_blk:                                    ; preds = %print_dec_body
  %.142 = bitcast ptr @fmt_dec_pad to ptr
  %.143 = call i32 (ptr, ...) @printf(ptr %.142, i64 %.136)
  br label %print_cont_blk

print_cont_blk:                                   ; preds = %print_pad_blk, %print_first_blk
  %.145 = sub i64 %.130, 1
  store i64 %.145, ptr %.126, align 4
  br label %print_dec_cond
}

declare i32 @fprintf(ptr, ptr, ...)

define void @print_decimal(ptr %.1) {
entry:
  %copy_idx = alloca i64, align 8
  %div_idx = alloca i64, align 8
  %carry = alloca i64, align 8
  %print_idx = alloca i64, align 8
  %work_len_slot = alloca i64, align 8
  %adjusted_exp_slot = alloca i64, align 8
  %.3 = getelementptr %decimal, ptr %.1, i32 0, i32 1
  %.4 = load ptr, ptr %.3, align 8
  %.5 = getelementptr %decimal, ptr %.1, i32 0, i32 2
  %.6 = load i64, ptr %.5, align 4
  %.7 = getelementptr %bigint, ptr %.4, i32 0, i32 1
  %.8 = load i1, ptr %.7, align 1
  %.9 = getelementptr %bigint, ptr %.4, i32 0, i32 2
  %.10 = load ptr, ptr %.9, align 8
  %.11 = getelementptr %i64.array, ptr %.10, i32 0, i32 1
  %.12 = load i64, ptr %.11, align 4
  %.13 = icmp eq i64 %.12, 0
  br i1 %.13, label %zero_block, label %nonzero_block

zero_block:                                       ; preds = %entry
  %.15 = bitcast ptr @dec_zero_fmt to ptr
  %.16 = call i32 (ptr, ...) @printf(ptr %.15)
  br label %end_block

nonzero_block:                                    ; preds = %entry
  %.18 = call ptr @malloc(i64 32)
  %.19 = bitcast ptr %.18 to ptr
  call void @i64.array.init(ptr %.19)
  %.21 = call ptr @malloc(i64 32)
  %.22 = bitcast ptr %.21 to ptr
  call void @i64.array.init(ptr %.22)
  store i64 0, ptr %copy_idx, align 4
  br label %copy_cond

copy_cond:                                        ; preds = %copy_body, %nonzero_block
  %.26 = load i64, ptr %copy_idx, align 4
  %.27 = icmp slt i64 %.26, %.12
  br i1 %.27, label %copy_body, label %copy_end

copy_body:                                        ; preds = %copy_cond
  %.29 = getelementptr %i64.array, ptr %.10, i32 0, i32 3
  %.30 = load ptr, ptr %.29, align 8
  %.31 = add i64 %.26, 1
  %.32 = getelementptr i64, ptr %.30, i64 %.31
  %.33 = load i64, ptr %.32, align 4
  call void @i64.array.append(ptr %.19, i64 %.33)
  %.35 = add i64 %.26, 1
  store i64 %.35, ptr %copy_idx, align 4
  br label %copy_cond

copy_end:                                         ; preds = %copy_cond
  %.38 = getelementptr %i64.array, ptr %.19, i32 0, i32 1
  %.39 = load i64, ptr %.38, align 4
  store i64 %.39, ptr %work_len_slot, align 4
  br label %div_loop

div_loop:                                         ; preds = %trim_end, %copy_end
  %.42 = load i64, ptr %work_len_slot, align 4
  %.43 = icmp eq i64 %.42, 0
  br i1 %.43, label %div_end, label %div_check_zero

div_check_zero:                                   ; preds = %div_loop
  %.45 = getelementptr %i64.array, ptr %.19, i32 0, i32 3
  %.46 = load ptr, ptr %.45, align 8
  %.47 = getelementptr i64, ptr %.46, i64 %.42
  %.48 = load i64, ptr %.47, align 4
  %.49 = icmp eq i64 %.48, 0
  %.50 = icmp eq i64 %.42, 1
  %.51 = and i1 %.49, %.50
  br i1 %.51, label %div_end, label %div_body

div_body:                                         ; preds = %div_check_zero
  store i64 0, ptr %carry, align 4
  %.54 = load i64, ptr %work_len_slot, align 4
  store i64 %.54, ptr %div_idx, align 4
  br label %div_inner_cond

div_end:                                          ; preds = %div_check_zero, %div_loop
  %.105 = getelementptr %i64.array, ptr %.22, i32 0, i32 1
  %.106 = load i64, ptr %.105, align 4
  %.107 = icmp sgt i64 %.106, 0
  br i1 %.107, label %print_digits, label %print_zero

print_zero:                                       ; preds = %div_end
  %.109 = bitcast ptr @dec_zero_fmt to ptr
  %.110 = call i32 (ptr, ...) @printf(ptr %.109)
  br label %end_block

print_digits:                                     ; preds = %div_end
  %.112 = sub i64 %.106, 1
  %.113 = add i64 %.6, %.112
  store i64 %.113, ptr %adjusted_exp_slot, align 4
  br i1 %.8, label %neg_block, label %after_sign

neg_block:                                        ; preds = %print_digits
  %.116 = bitcast ptr @dec_minus_fmt to ptr
  %.117 = call i32 (ptr, ...) @printf(ptr %.116)
  br label %after_sign

after_sign:                                       ; preds = %neg_block, %print_digits
  store i64 %.106, ptr %print_idx, align 4
  br label %print_first

print_first:                                      ; preds = %after_sign
  %.121 = load i64, ptr %print_idx, align 4
  %.122 = getelementptr %i64.array, ptr %.22, i32 0, i32 3
  %.123 = load ptr, ptr %.122, align 8
  %.124 = getelementptr i64, ptr %.123, i64 %.121
  %.125 = load i64, ptr %.124, align 4
  %.126 = bitcast ptr @dec_digit_fmt to ptr
  %.127 = call i32 (ptr, ...) @printf(ptr %.126, i64 %.125)
  %.128 = sub i64 %.121, 1
  store i64 %.128, ptr %print_idx, align 4
  br label %check_more

check_more:                                       ; preds = %print_first
  %.131 = load i64, ptr %print_idx, align 4
  %.132 = icmp sge i64 %.131, 1
  br i1 %.132, label %print_dot, label %check_exp

print_dot:                                        ; preds = %check_more
  %.134 = bitcast ptr @dec_dot_fmt to ptr
  %.135 = call i32 (ptr, ...) @printf(ptr %.134)
  br label %frac_cond

frac_cond:                                        ; preds = %frac_body, %print_dot
  %.137 = load i64, ptr %print_idx, align 4
  %.138 = icmp sge i64 %.137, 1
  br i1 %.138, label %frac_body, label %frac_end

frac_body:                                        ; preds = %frac_cond
  %.140 = getelementptr %i64.array, ptr %.22, i32 0, i32 3
  %.141 = load ptr, ptr %.140, align 8
  %.142 = getelementptr i64, ptr %.141, i64 %.137
  %.143 = load i64, ptr %.142, align 4
  %.144 = bitcast ptr @dec_digit_fmt to ptr
  %.145 = call i32 (ptr, ...) @printf(ptr %.144, i64 %.143)
  %.146 = sub i64 %.137, 1
  store i64 %.146, ptr %print_idx, align 4
  br label %frac_cond

frac_end:                                         ; preds = %frac_cond
  br label %check_exp

check_exp:                                        ; preds = %frac_end, %check_more
  %.150 = load i64, ptr %adjusted_exp_slot, align 4
  %.151 = icmp eq i64 %.150, 0
  br i1 %.151, label %skip_exp, label %print_exp

print_exp:                                        ; preds = %check_exp
  %.153 = bitcast ptr @dec_exp_fmt to ptr
  %.154 = call i32 (ptr, ...) @printf(ptr %.153, i64 %.150)
  br label %skip_exp

skip_exp:                                         ; preds = %print_exp, %check_exp
  %.156 = bitcast ptr @dec_nl_fmt to ptr
  %.157 = call i32 (ptr, ...) @printf(ptr %.156)
  br label %end_block

end_block:                                        ; preds = %skip_exp, %print_zero, %zero_block
  ret void

div_inner_cond:                                   ; preds = %div_inner_body, %div_body
  %.57 = load i64, ptr %div_idx, align 4
  %.58 = icmp sge i64 %.57, 1
  br i1 %.58, label %div_inner_body, label %div_inner_end

div_inner_body:                                   ; preds = %div_inner_cond
  %.60 = getelementptr %i64.array, ptr %.19, i32 0, i32 3
  %.61 = load ptr, ptr %.60, align 8
  %.62 = getelementptr i64, ptr %.61, i64 %.57
  %.63 = load i64, ptr %.62, align 4
  %.64 = load i64, ptr %carry, align 4
  %.65 = mul i64 %.64, 1844674407370955161
  %.66 = mul i64 %.64, 6
  %.67 = add i64 %.66, %.63
  %.68 = icmp ult i64 %.67, %.63
  %.69 = udiv i64 %.67, 10
  %.70 = urem i64 %.67, 10
  %.71 = select i1 %.68, i64 1844674407370955161, i64 0
  %.72 = select i1 %.68, i64 6, i64 0
  %.73 = add i64 %.70, %.72
  %.74 = urem i64 %.73, 10
  %.75 = udiv i64 %.73, 10
  %.76 = add i64 %.65, %.69
  %.77 = add i64 %.76, %.71
  %.78 = add i64 %.77, %.75
  store i64 %.78, ptr %.62, align 4
  store i64 %.74, ptr %carry, align 4
  %.81 = sub i64 %.57, 1
  store i64 %.81, ptr %div_idx, align 4
  br label %div_inner_cond

div_inner_end:                                    ; preds = %div_inner_cond
  %.84 = load i64, ptr %carry, align 4
  call void @i64.array.append(ptr %.22, i64 %.84)
  br label %trim_cond

trim_cond:                                        ; preds = %trim_do, %div_inner_end
  %.87 = getelementptr %i64.array, ptr %.19, i32 0, i32 1
  %.88 = load i64, ptr %.87, align 4
  %.89 = icmp sgt i64 %.88, 0
  br i1 %.89, label %trim_body, label %trim_end

trim_body:                                        ; preds = %trim_cond
  %.91 = getelementptr %i64.array, ptr %.19, i32 0, i32 3
  %.92 = load ptr, ptr %.91, align 8
  %.93 = getelementptr i64, ptr %.92, i64 %.88
  %.94 = load i64, ptr %.93, align 4
  %.95 = icmp eq i64 %.94, 0
  %.96 = icmp sgt i64 %.88, 1
  %.97 = and i1 %.95, %.96
  br i1 %.97, label %trim_do, label %trim_end

trim_do:                                          ; preds = %trim_body
  %.99 = sub i64 %.88, 1
  store i64 %.99, ptr %.87, align 4
  br label %trim_cond

trim_end:                                         ; preds = %trim_body, %trim_cond
  %.102 = load i64, ptr %.87, align 4
  store i64 %.102, ptr %work_len_slot, align 4
  br label %div_loop
}

define void @print_number(ptr %.1) {
entry:
  %.3 = getelementptr %number, ptr %.1, i32 0, i32 1
  %.4 = load i8, ptr %.3, align 1
  switch i8 %.4, label %end [
    i8 0, label %case_int
    i8 1, label %case_float
    i8 2, label %case_bigint
    i8 3, label %case_decimal
  ]

case_int:                                         ; preds = %entry
  %.6 = getelementptr %number, ptr %.1, i32 0, i32 2
  %.7 = load ptr, ptr %.6, align 8
  %.8 = bitcast ptr %.7 to ptr
  %.9 = load i64, ptr %.8, align 4
  %.10 = bitcast ptr @fmt_lld to ptr
  %.11 = call i32 (ptr, ...) @printf(ptr %.10, i64 %.9)
  br label %end

case_float:                                       ; preds = %entry
  %.13 = getelementptr %number, ptr %.1, i32 0, i32 2
  %.14 = load ptr, ptr %.13, align 8
  %.15 = bitcast ptr %.14 to ptr
  %.16 = load double, ptr %.15, align 8
  %.17 = bitcast ptr @fmt_f to ptr
  %.18 = call i32 (ptr, ...) @printf(ptr %.17, double %.16)
  br label %end

case_bigint:                                      ; preds = %entry
  %.20 = getelementptr %number, ptr %.1, i32 0, i32 2
  %.21 = load ptr, ptr %.20, align 8
  %.22 = bitcast ptr %.21 to ptr
  call void @print_bigint(ptr %.22)
  br label %end

case_decimal:                                     ; preds = %entry
  %.25 = getelementptr %number, ptr %.1, i32 0, i32 2
  %.26 = load ptr, ptr %.25, align 8
  %.27 = bitcast ptr %.26 to ptr
  call void @print_decimal(ptr %.27)
  br label %end

end:                                              ; preds = %case_decimal, %case_bigint, %case_float, %case_int, %entry
  ret void
}

define void @print_dynamic(ptr %.1) {
entry:
  %.3 = getelementptr %dynamic, ptr %.1, i32 0, i32 1
  %.4 = load i32, ptr %.3, align 4
  %.5 = getelementptr %dynamic, ptr %.1, i32 0, i32 2
  %.6 = load ptr, ptr %.5, align 8
  switch i32 %.4, label %case_unknown [
    i32 1, label %case_int
    i32 2, label %case_float
    i32 3, label %case_bool
    i32 4, label %case_str
    i32 5, label %case_bigint
    i32 6, label %case_decimal
  ]

case_int:                                         ; preds = %entry
  %.8 = bitcast ptr %.6 to ptr
  %.9 = load i64, ptr %.8, align 4
  %.10 = bitcast ptr @dyn_fmt_int to ptr
  %.11 = call i32 (ptr, ...) @printf(ptr %.10, i64 %.9)
  br label %end

case_float:                                       ; preds = %entry
  %.13 = bitcast ptr %.6 to ptr
  %.14 = load double, ptr %.13, align 8
  %.15 = bitcast ptr @dyn_fmt_flt to ptr
  %.16 = call i32 (ptr, ...) @printf(ptr %.15, double %.14)
  br label %end

case_bool:                                        ; preds = %entry
  %.18 = bitcast ptr %.6 to ptr
  %.19 = load i1, ptr %.18, align 1
  %.20 = icmp ne i1 %.19, false
  br i1 %.20, label %print_true, label %print_false

case_str:                                         ; preds = %entry
  %.28 = bitcast ptr %.6 to ptr
  call void @print(ptr %.28)
  br label %end

case_bigint:                                      ; preds = %entry
  %.31 = bitcast ptr %.6 to ptr
  call void @print_bigint(ptr %.31)
  br label %end

case_decimal:                                     ; preds = %entry
  %.34 = bitcast ptr %.6 to ptr
  call void @print_decimal(ptr %.34)
  br label %end

case_unknown:                                     ; preds = %entry
  %.37 = bitcast ptr @dyn_fmt_unk to ptr
  %.38 = call i32 (ptr, ...) @printf(ptr %.37)
  br label %end

end:                                              ; preds = %print_false, %print_true, %case_unknown, %case_decimal, %case_bigint, %case_str, %case_float, %case_int
  ret void

print_true:                                       ; preds = %case_bool
  %.22 = bitcast ptr @dyn_fmt_true to ptr
  %.23 = call i32 (ptr, ...) @printf(ptr %.22)
  br label %end

print_false:                                      ; preds = %case_bool
  %.25 = bitcast ptr @dyn_fmt_false to ptr
  %.26 = call i32 (ptr, ...) @printf(ptr %.25)
  br label %end
}

define void @free_bigint(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %end, label %not_null

not_null:                                         ; preds = %entry
  %.5 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp ne ptr %.6, null
  br i1 %.7, label %free_digits, label %end

end:                                              ; preds = %do_free, %free_digits, %not_null, %entry
  ret void

free_digits:                                      ; preds = %not_null
  %.9 = getelementptr inbounds %i64.array, ptr %.6, i32 0, i32 0
  %.10 = getelementptr inbounds %meteor.header, ptr %.9, i32 0, i32 0
  %.11 = load i32, ptr %.10, align 4
  %.12 = sub i32 %.11, 1
  store i32 %.12, ptr %.10, align 4
  %.14 = icmp eq i32 %.12, 0
  br i1 %.14, label %do_free, label %end

do_free:                                          ; preds = %free_digits
  %.16 = getelementptr %i64.array, ptr %.6, i32 0, i32 3
  %.17 = load ptr, ptr %.16, align 8
  %.18 = bitcast ptr %.17 to ptr
  call void @free(ptr %.18)
  %.20 = bitcast ptr %.6 to ptr
  call void @free(ptr %.20)
  br label %end
}

declare i32 @mi_version()

declare ptr @CreateThread(ptr, i64, ptr, ptr, i32, ptr)

define internal i64 @meteor_spawn(ptr %.1, ptr %.2) {
entry:
  %.4 = call ptr @CreateThread(ptr null, i64 0, ptr %.1, ptr %.2, i32 0, ptr null)
  %.5 = ptrtoint ptr %.4 to i64
  ret i64 %.5
}

define internal void @meteor_join(i64 %.1) {
entry:
  %.3 = inttoptr i64 %.1 to ptr
  %.4 = call i32 @WaitForSingleObject(ptr %.3, i32 -1)
  %.5 = call i32 @CloseHandle(ptr %.3)
  ret void
}

declare i32 @WaitForSingleObject(ptr, i32)

declare i32 @CloseHandle(ptr)

define internal i64 @atomic_load(ptr %.1) {
entry:
  %.3 = load i64, ptr %.1, align 4, !atomic !0
  fence seq_cst
  ret i64 %.3
}

define internal void @atomic_store(ptr %.1, i64 %.2) {
entry:
  fence seq_cst
  store i64 %.2, ptr %.1, align 4
  ret void
}

define internal i64 @atomic_add(ptr %.1, i64 %.2) {
entry:
  %.4 = atomicrmw add ptr %.1, i64 %.2 seq_cst, align 8
  ret i64 %.4
}

define internal i64 @atomic_sub(ptr %.1, i64 %.2) {
entry:
  %.4 = atomicrmw sub ptr %.1, i64 %.2 seq_cst, align 8
  ret i64 %.4
}

define internal i64 @atomic_cas(ptr %.1, i64 %.2, i64 %.3) {
entry:
  %.5 = cmpxchg ptr %.1, i64 %.2, i64 %.3 seq_cst seq_cst, align 8
  %.6 = extractvalue { i64, i1 } %.5, 0
  ret i64 %.6
}

define internal ptr @mutex_create() {
entry:
  %.2 = call ptr @malloc(i64 48)
  call void @InitializeCriticalSection(ptr %.2)
  %.4 = call ptr @malloc(i64 8)
  %.5 = bitcast ptr %.4 to ptr
  %.6 = getelementptr %meteor.mutex, ptr %.5, i32 0, i32 0
  store ptr %.2, ptr %.6, align 8
  ret ptr %.5
}

declare void @InitializeCriticalSection(ptr)

define internal void @mutex_lock(ptr %.1) {
entry:
  %.3 = getelementptr %meteor.mutex, ptr %.1, i32 0, i32 0
  %.4 = load ptr, ptr %.3, align 8
  call void @EnterCriticalSection(ptr %.4)
  ret void
}

declare void @EnterCriticalSection(ptr)

define internal void @mutex_unlock(ptr %.1) {
entry:
  %.3 = getelementptr %meteor.mutex, ptr %.1, i32 0, i32 0
  %.4 = load ptr, ptr %.3, align 8
  call void @LeaveCriticalSection(ptr %.4)
  ret void
}

declare void @LeaveCriticalSection(ptr)

define internal ptr @channel_create(i64 %.1) {
entry:
  %.3 = call ptr @malloc(i64 80)
  %.4 = bitcast ptr %.3 to ptr
  %.5 = call ptr @malloc(i64 48)
  %.6 = getelementptr %meteor.channel, ptr %.4, i32 0, i32 1
  store ptr %.5, ptr %.6, align 8
  %.8 = call i32 @pthread_mutex_init(ptr %.5, ptr null)
  %.9 = call ptr @malloc(i64 48)
  %.10 = getelementptr %meteor.channel, ptr %.4, i32 0, i32 2
  store ptr %.9, ptr %.10, align 8
  %.12 = call i32 @pthread_cond_init(ptr %.9, ptr null)
  %.13 = mul i64 %.1, 8
  %.14 = call ptr @malloc(i64 %.13)
  %.15 = bitcast ptr %.14 to ptr
  %.16 = getelementptr %meteor.channel, ptr %.4, i32 0, i32 3
  store ptr %.15, ptr %.16, align 8
  %.18 = getelementptr %meteor.channel, ptr %.4, i32 0, i32 4
  store i64 %.1, ptr %.18, align 4
  %.20 = getelementptr %meteor.channel, ptr %.4, i32 0, i32 5
  store i64 0, ptr %.20, align 4
  %.22 = getelementptr %meteor.channel, ptr %.4, i32 0, i32 6
  store i64 0, ptr %.22, align 4
  %.24 = getelementptr %meteor.channel, ptr %.4, i32 0, i32 7
  store i64 0, ptr %.24, align 4
  ret ptr %.4
}

declare i32 @pthread_mutex_init(ptr, ptr)

declare i32 @pthread_cond_init(ptr, ptr)

define internal void @channel_send(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 1
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i32 @pthread_mutex_lock(ptr %.5)
  %.7 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 3
  %.8 = load ptr, ptr %.7, align 8
  %.9 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 4
  %.10 = load i64, ptr %.9, align 4
  %.11 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 6
  %.12 = load i64, ptr %.11, align 4
  %.13 = getelementptr ptr, ptr %.8, i64 %.12
  store ptr %.2, ptr %.13, align 8
  %.15 = add i64 %.12, 1
  %.16 = urem i64 %.15, %.10
  store i64 %.16, ptr %.11, align 4
  %.18 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 7
  %.19 = load i64, ptr %.18, align 4
  %.20 = add i64 %.19, 1
  store i64 %.20, ptr %.18, align 4
  %.22 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 2
  %.23 = load ptr, ptr %.22, align 8
  %.24 = call i32 @pthread_cond_signal(ptr %.23)
  %.25 = call i32 @pthread_mutex_unlock(ptr %.5)
  ret void
}

declare i32 @pthread_mutex_lock(ptr)

declare i32 @pthread_mutex_unlock(ptr)

declare i32 @pthread_cond_signal(ptr)

define internal ptr @channel_recv(ptr %.1) {
entry:
  %.3 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 1
  %.4 = load ptr, ptr %.3, align 8
  %.5 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 2
  %.6 = load ptr, ptr %.5, align 8
  %.7 = call i32 @pthread_mutex_lock(ptr %.4)
  br label %wait_loop

wait_loop:                                        ; preds = %do_wait, %entry
  %.9 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 7
  %.10 = load i64, ptr %.9, align 4
  %.11 = icmp eq i64 %.10, 0
  br i1 %.11, label %do_wait, label %recv

recv:                                             ; preds = %wait_loop
  %.15 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 3
  %.16 = load ptr, ptr %.15, align 8
  %.17 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 4
  %.18 = load i64, ptr %.17, align 4
  %.19 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 5
  %.20 = load i64, ptr %.19, align 4
  %.21 = getelementptr ptr, ptr %.16, i64 %.20
  %.22 = load ptr, ptr %.21, align 8
  %.23 = add i64 %.20, 1
  %.24 = urem i64 %.23, %.18
  store i64 %.24, ptr %.19, align 4
  %.26 = load i64, ptr %.9, align 4
  %.27 = sub i64 %.26, 1
  store i64 %.27, ptr %.9, align 4
  %.29 = call i32 @pthread_mutex_unlock(ptr %.4)
  ret ptr %.22

do_wait:                                          ; preds = %wait_loop
  %.13 = call i32 @pthread_cond_wait(ptr %.6, ptr %.4)
  br label %wait_loop
}

declare i32 @pthread_cond_wait(ptr, ptr)

define internal { ptr, i1 } @channel_try_recv(ptr %.1) {
entry:
  %.3 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 1
  %.4 = load ptr, ptr %.3, align 8
  %.5 = call i32 @pthread_mutex_lock(ptr %.4)
  %.6 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 7
  %.7 = load i64, ptr %.6, align 4
  %.8 = icmp eq i64 %.7, 0
  br i1 %.8, label %empty, label %recv

empty:                                            ; preds = %entry
  %.10 = call i32 @pthread_mutex_unlock(ptr %.4)
  ret { ptr, i1 } zeroinitializer

recv:                                             ; preds = %entry
  %.12 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 3
  %.13 = load ptr, ptr %.12, align 8
  %.14 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 4
  %.15 = load i64, ptr %.14, align 4
  %.16 = getelementptr %meteor.channel, ptr %.1, i32 0, i32 5
  %.17 = load i64, ptr %.16, align 4
  %.18 = getelementptr ptr, ptr %.13, i64 %.17
  %.19 = load ptr, ptr %.18, align 8
  %.20 = add i64 %.17, 1
  %.21 = urem i64 %.20, %.15
  store i64 %.21, ptr %.16, align 4
  %.23 = sub i64 %.7, 1
  store i64 %.23, ptr %.6, align 4
  %.25 = call i32 @pthread_mutex_unlock(ptr %.4)
  %.26 = insertvalue { ptr, i1 } undef, ptr %.19, 0
  %.27 = insertvalue { ptr, i1 } %.26, i1 true, 1
  ret { ptr, i1 } %.27
}

define internal void @meteor_destroy(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

check_array:                                      ; preds = %not_null
  %.9 = icmp eq i8 %.6, 7
  %.10 = icmp eq i8 %.6, 4
  %.11 = or i1 %.9, %.10
  br i1 %.11, label %free_array_data, label %exit

free_array_data:                                  ; preds = %check_array
  %.13 = bitcast ptr %.1 to ptr
  %.14 = getelementptr i8, ptr %.13, i64 32
  %.15 = bitcast ptr %.14 to ptr
  %.16 = load ptr, ptr %.15, align 8
  %.17 = icmp eq ptr %.16, null
  br i1 %.17, label %exit, label %do_free

exit:                                             ; preds = %do_free, %not_null, %free_array_data, %check_array, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr %meteor.header, ptr %.1, i32 0, i32 3
  %.6 = load i8, ptr %.5, align 1
  %.7 = icmp eq i8 %.6, 10
  br i1 %.7, label %exit, label %check_array

do_free:                                          ; preds = %free_array_data
  call void @free(ptr %.16)
  br label %exit
}

define internal void @meteor_retain(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %do_inc

do_inc:                                           ; preds = %entry
  %.5 = getelementptr %meteor.header, ptr %.1, i32 0, i32 2
  %.6 = load i8, ptr %.5, align 1
  %.7 = and i8 %.6, 1
  %.8 = icmp ne i8 %.7, 0
  br i1 %.8, label %frozen_inc, label %normal_inc

frozen_inc:                                       ; preds = %do_inc
  %.10 = getelementptr %meteor.header, ptr %.1, i32 0, i32 0
  %.11 = atomicrmw add ptr %.10, i32 1 seq_cst, align 4
  br label %exit

normal_inc:                                       ; preds = %do_inc
  %.13 = getelementptr %meteor.header, ptr %.1, i32 0, i32 0
  %.14 = load i32, ptr %.13, align 4
  %.15 = add i32 %.14, 1
  store i32 %.15, ptr %.13, align 4
  br label %exit

exit:                                             ; preds = %normal_inc, %frozen_inc, %entry
  ret void
}

define internal void @meteor_release(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %do_dec

do_dec:                                           ; preds = %entry
  %.5 = getelementptr %meteor.header, ptr %.1, i32 0, i32 2
  %.6 = load i8, ptr %.5, align 1
  %.7 = and i8 %.6, 1
  %.8 = icmp ne i8 %.7, 0
  br i1 %.8, label %frozen_dec, label %normal_dec

frozen_dec:                                       ; preds = %do_dec
  %.10 = getelementptr %meteor.header, ptr %.1, i32 0, i32 0
  %.11 = atomicrmw sub ptr %.10, i32 1 seq_cst, align 4
  %.12 = sub i32 %.11, 1
  br label %check_zero

normal_dec:                                       ; preds = %do_dec
  %.14 = getelementptr %meteor.header, ptr %.1, i32 0, i32 0
  %.15 = load i32, ptr %.14, align 4
  %.16 = sub i32 %.15, 1
  store i32 %.16, ptr %.14, align 4
  br label %check_zero

check_zero:                                       ; preds = %normal_dec, %frozen_dec
  %.19 = phi i32 [ %.12, %frozen_dec ], [ %.16, %normal_dec ]
  %.20 = icmp eq i32 %.19, 0
  br i1 %.20, label %do_destroy, label %exit

do_destroy:                                       ; preds = %check_zero
  call void @meteor_destroy(ptr %.1)
  %.23 = getelementptr %meteor.header, ptr %.1, i32 0, i32 2
  %.24 = load i8, ptr %.23, align 1
  %.25 = or i8 %.24, 2
  store i8 %.25, ptr %.23, align 1
  br label %check_weak

check_weak:                                       ; preds = %do_destroy
  %.28 = getelementptr %meteor.header, ptr %.1, i32 0, i32 1
  %.29 = load i32, ptr %.28, align 4
  %.30 = icmp eq i32 %.29, 0
  br i1 %.30, label %do_free, label %exit

do_free:                                          ; preds = %check_weak
  %.32 = bitcast ptr %.1 to ptr
  call void @free(ptr %.32)
  br label %exit

exit:                                             ; preds = %do_free, %check_weak, %check_zero, %entry
  ret void
}

define internal void @meteor_weak_retain(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

not_null:                                         ; preds = %entry
  %.5 = getelementptr %meteor.header, ptr %.1, i32 0, i32 1
  %.6 = load i32, ptr %.5, align 4
  %.7 = add i32 %.6, 1
  store i32 %.7, ptr %.5, align 4
  br label %exit

exit:                                             ; preds = %not_null, %entry
  ret void
}

define internal void @meteor_weak_release(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

not_null:                                         ; preds = %entry
  %.5 = getelementptr %meteor.header, ptr %.1, i32 0, i32 1
  %.6 = load i32, ptr %.5, align 4
  %.7 = sub i32 %.6, 1
  store i32 %.7, ptr %.5, align 4
  br label %check_free

check_free:                                       ; preds = %not_null
  %.10 = getelementptr %meteor.header, ptr %.1, i32 0, i32 2
  %.11 = load i8, ptr %.10, align 1
  %.12 = and i8 %.11, 2
  %.13 = icmp ne i8 %.12, 0
  %.14 = icmp eq i32 %.7, 0
  %.15 = and i1 %.13, %.14
  br i1 %.15, label %do_free, label %exit

do_free:                                          ; preds = %check_free
  %.17 = bitcast ptr %.1 to ptr
  call void @free(ptr %.17)
  br label %exit

exit:                                             ; preds = %do_free, %check_free, %entry
  ret void
}

define internal ptr @meteor_weak_upgrade(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %ret_null, label %not_null

not_null:                                         ; preds = %entry
  %.5 = getelementptr %meteor.header, ptr %.1, i32 0, i32 2
  %.6 = load i8, ptr %.5, align 1
  %.7 = and i8 %.6, 2
  %.8 = icmp ne i8 %.7, 0
  br i1 %.8, label %ret_null, label %do_retain

do_retain:                                        ; preds = %not_null
  %.10 = getelementptr %meteor.header, ptr %.1, i32 0, i32 0
  %.11 = load i32, ptr %.10, align 4
  %.12 = add i32 %.11, 1
  store i32 %.12, ptr %.10, align 4
  br label %exit

ret_null:                                         ; preds = %not_null, %entry
  br label %exit

exit:                                             ; preds = %ret_null, %do_retain
  %.16 = phi ptr [ %.1, %do_retain ], [ null, %ret_null ]
  ret ptr %.16
}

define internal ptr @meteor_alloc(i64 %.1, i8 %.2) {
entry:
  %.4 = add i64 %.1, 16
  %.5 = call ptr @malloc(i64 %.4)
  %.6 = bitcast ptr %.5 to ptr
  %.7 = getelementptr %meteor.header, ptr %.6, i32 0, i32 0
  store i32 1, ptr %.7, align 4
  %.9 = getelementptr %meteor.header, ptr %.6, i32 0, i32 1
  store i32 0, ptr %.9, align 4
  %.11 = getelementptr %meteor.header, ptr %.6, i32 0, i32 2
  store i8 0, ptr %.11, align 1
  %.13 = getelementptr %meteor.header, ptr %.6, i32 0, i32 3
  store i8 %.2, ptr %.13, align 1
  ret ptr %.6
}

define internal ptr @meteor_freeze(ptr %.1) {
entry:
  %.3 = getelementptr %meteor.header, ptr %.1, i32 0, i32 2
  %.4 = load i8, ptr %.3, align 1
  %.5 = or i8 %.4, 1
  store i8 %.5, ptr %.3, align 1
  ret ptr %.1
}

define %bigint @bigint_add(ptr %.1, ptr %.2) {
entry:
  %res = alloca %bigint, align 8
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.7 = load ptr, ptr %.6, align 8
  %.8 = call ptr @malloc(i64 32)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  %idx = alloca i64, align 8
  store i64 0, ptr %idx, align 4
  %carry = alloca i64, align 8
  store i64 0, ptr %carry, align 4
  %val_a = alloca i64, align 8
  %val_b = alloca i64, align 8
  %.13 = call i64 @i64.array.length(ptr %.5)
  %.14 = call i64 @i64.array.length(ptr %.7)
  br label %cond

cond:                                             ; preds = %body.endif.endif, %entry
  %.16 = load i64, ptr %idx, align 4
  %.17 = load i64, ptr %carry, align 4
  %.18 = icmp slt i64 %.16, %.13
  %.19 = icmp slt i64 %.16, %.14
  %.20 = icmp ne i64 %.17, 0
  %.21 = or i1 %.18, %.19
  %.22 = or i1 %.21, %.20
  br i1 %.22, label %body, label %end

body:                                             ; preds = %cond
  store i64 0, ptr %val_a, align 4
  br i1 %.18, label %body.if, label %body.endif

end:                                              ; preds = %cond
  %.48 = getelementptr %bigint, ptr %res, i32 0, i32 2
  store ptr %.9, ptr %.48, align 8
  %.50 = getelementptr %bigint, ptr %res, i32 0, i32 1
  store i1 false, ptr %.50, align 1
  %.52 = load %bigint, ptr %res, align 8
  ret %bigint %.52

body.if:                                          ; preds = %body
  %.26 = call i64 @i64.array.get(ptr %.5, i64 %.16)
  store i64 %.26, ptr %val_a, align 4
  br label %body.endif

body.endif:                                       ; preds = %body.if, %body
  store i64 0, ptr %val_b, align 4
  br i1 %.19, label %body.endif.if, label %body.endif.endif

body.endif.if:                                    ; preds = %body.endif
  %.31 = call i64 @i64.array.get(ptr %.7, i64 %.16)
  store i64 %.31, ptr %val_b, align 4
  br label %body.endif.endif

body.endif.endif:                                 ; preds = %body.endif.if, %body.endif
  %.34 = load i64, ptr %val_a, align 4
  %.35 = load i64, ptr %val_b, align 4
  %.36 = load i64, ptr %carry, align 4
  %.37 = add i64 %.34, %.35
  %.38 = icmp ult i64 %.37, %.34
  %.39 = add i64 %.37, %.36
  %.40 = icmp ult i64 %.39, %.37
  %.41 = or i1 %.38, %.40
  %.42 = zext i1 %.41 to i64
  store i64 %.42, ptr %carry, align 4
  call void @i64.array.append(ptr %.9, i64 %.39)
  %.45 = add i64 %.16, 1
  store i64 %.45, ptr %idx, align 4
  br label %cond
}

define %bigint @bigint_neg(ptr %.1) {
entry:
  %res = alloca %bigint, align 8
  %.3 = call ptr @malloc(i64 32)
  %.4 = bitcast ptr %.3 to ptr
  call void @i64.array.init(ptr %.4)
  %.6 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.7 = load i1, ptr %.6, align 1
  %.8 = xor i1 %.7, true
  %.9 = getelementptr %bigint, ptr %res, i32 0, i32 1
  store i1 %.8, ptr %.9, align 1
  %.11 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.12 = load ptr, ptr %.11, align 8
  %.13 = call i64 @i64.array.length(ptr %.12)
  %.14 = alloca i64, align 8
  store i64 0, ptr %.14, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %.17 = load i64, ptr %.14, align 4
  %.18 = icmp slt i64 %.17, %.13
  br i1 %.18, label %body, label %end

body:                                             ; preds = %cond
  %.20 = call i64 @i64.array.get(ptr %.12, i64 %.17)
  call void @i64.array.append(ptr %.4, i64 %.20)
  %.22 = add i64 %.17, 1
  store i64 %.22, ptr %.14, align 4
  br label %cond

end:                                              ; preds = %cond
  %.25 = getelementptr %bigint, ptr %res, i32 0, i32 2
  store ptr %.4, ptr %.25, align 8
  %.27 = load %bigint, ptr %res, align 8
  ret %bigint %.27
}

define i32 @bigint_cmp(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.5 = load i1, ptr %.4, align 1
  %.6 = getelementptr %bigint, ptr %.2, i32 0, i32 1
  %.7 = load i1, ptr %.6, align 1
  %.8 = icmp ne i1 %.5, %.7
  br i1 %.8, label %diff_signs, label %same_signs

diff_signs:                                       ; preds = %entry
  %.10 = select i1 %.5, i32 -1, i32 1
  ret i32 %.10

same_signs:                                       ; preds = %entry
  %.12 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.13 = load ptr, ptr %.12, align 8
  %.14 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.15 = load ptr, ptr %.14, align 8
  %.16 = call i64 @i64.array.length(ptr %.13)
  %.17 = call i64 @i64.array.length(ptr %.15)
  %.18 = icmp ne i64 %.16, %.17
  br i1 %.18, label %len_check, label %digits_check

len_check:                                        ; preds = %same_signs
  %.20 = icmp sgt i64 %.16, %.17
  %.21 = select i1 %.20, i32 1, i32 -1
  %.22 = select i1 %.20, i32 -1, i32 1
  %.23 = select i1 %.5, i32 %.22, i32 %.21
  ret i32 %.23

digits_check:                                     ; preds = %same_signs
  %.25 = alloca i64, align 8
  %.26 = sub i64 %.16, 1
  store i64 %.26, ptr %.25, align 4
  br label %loop_cond

loop_cond:                                        ; preds = %continue, %digits_check
  %.29 = load i64, ptr %.25, align 4
  %.30 = icmp sge i64 %.29, 0
  br i1 %.30, label %loop_body, label %loop_end

loop_body:                                        ; preds = %loop_cond
  %.32 = call i64 @i64.array.get(ptr %.13, i64 %.29)
  %.33 = call i64 @i64.array.get(ptr %.15, i64 %.29)
  %.34 = icmp ne i64 %.32, %.33
  br i1 %.34, label %digits_diff, label %continue

loop_end:                                         ; preds = %loop_cond
  ret i32 0

digits_diff:                                      ; preds = %loop_body
  %.36 = icmp ugt i64 %.32, %.33
  %.37 = select i1 %.36, i32 1, i32 -1
  %.38 = select i1 %.36, i32 -1, i32 1
  %.39 = select i1 %.5, i32 %.38, i32 %.37
  ret i32 %.39

continue:                                         ; preds = %loop_body
  %.41 = sub i64 %.29, 1
  store i64 %.41, ptr %.25, align 4
  br label %loop_cond
}

define %bigint @bigint_sub(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.5 = load i1, ptr %.4, align 1
  %.6 = getelementptr %bigint, ptr %.2, i32 0, i32 1
  %.7 = load i1, ptr %.6, align 1
  %.8 = icmp ne i1 %.5, %.7
  br i1 %.8, label %signs_diff, label %signs_same

signs_diff:                                       ; preds = %entry
  %.10 = call %bigint @bigint_add(ptr %.1, ptr %.2)
  %.11 = alloca %bigint, align 8
  store %bigint %.10, ptr %.11, align 8
  %.13 = getelementptr %bigint, ptr %.11, i32 0, i32 1
  store i1 %.5, ptr %.13, align 1
  %.15 = load %bigint, ptr %.11, align 8
  ret %bigint %.15

signs_same:                                       ; preds = %entry
  %.17 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.18 = load ptr, ptr %.17, align 8
  %.19 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.20 = load ptr, ptr %.19, align 8
  %.21 = call i64 @i64.array.length(ptr %.18)
  %.22 = call i64 @i64.array.length(ptr %.20)
  %.23 = alloca ptr, align 8
  %.24 = alloca ptr, align 8
  %.25 = alloca i1, align 1
  store ptr %.1, ptr %.23, align 8
  store ptr %.2, ptr %.24, align 8
  store i1 false, ptr %.25, align 1
  %.29 = icmp ne i64 %.21, %.22
  br i1 %.29, label %len_check, label %digits_check

len_check:                                        ; preds = %signs_same
  %.31 = icmp sgt i64 %.22, %.21
  store i1 %.31, ptr %.25, align 1
  br label %set_x_y

digits_check:                                     ; preds = %signs_same
  %.34 = alloca i64, align 8
  %.35 = sub i64 %.21, 1
  store i64 %.35, ptr %.34, align 4
  br label %d_loop_cond

set_x_y:                                          ; preds = %d_diff, %d_loop_end, %len_check
  %.52 = load i1, ptr %.25, align 1
  %.53 = select i1 %.52, ptr %.2, ptr %.1
  %.54 = select i1 %.52, ptr %.1, ptr %.2
  store ptr %.53, ptr %.23, align 8
  store ptr %.54, ptr %.24, align 8
  %.57 = load ptr, ptr %.23, align 8
  %.58 = load ptr, ptr %.24, align 8
  %.59 = getelementptr %bigint, ptr %.57, i32 0, i32 2
  %.60 = load ptr, ptr %.59, align 8
  %.61 = getelementptr %bigint, ptr %.58, i32 0, i32 2
  %.62 = load ptr, ptr %.61, align 8
  %.63 = call i64 @i64.array.length(ptr %.60)
  %.64 = call i64 @i64.array.length(ptr %.62)
  %.65 = alloca %bigint, align 8
  %.66 = call ptr @malloc(i64 32)
  %.67 = bitcast ptr %.66 to ptr
  call void @i64.array.init(ptr %.67)
  %.69 = alloca i64, align 8
  store i64 0, ptr %.69, align 4
  %.71 = alloca i64, align 8
  store i64 0, ptr %.71, align 4
  %.73 = alloca i64, align 8
  br label %sub_loop_cond

d_loop_cond:                                      ; preds = %d_next, %digits_check
  %.38 = load i64, ptr %.34, align 4
  %.39 = icmp sge i64 %.38, 0
  br i1 %.39, label %d_loop_body, label %d_loop_end

d_loop_body:                                      ; preds = %d_loop_cond
  %.41 = call i64 @i64.array.get(ptr %.18, i64 %.38)
  %.42 = call i64 @i64.array.get(ptr %.20, i64 %.38)
  %.43 = icmp ne i64 %.41, %.42
  br i1 %.43, label %d_diff, label %d_next

d_loop_end:                                       ; preds = %d_loop_cond
  br label %set_x_y

d_diff:                                           ; preds = %d_loop_body
  %.45 = icmp ugt i64 %.42, %.41
  store i1 %.45, ptr %.25, align 1
  br label %set_x_y

d_next:                                           ; preds = %d_loop_body
  %.48 = sub i64 %.38, 1
  store i64 %.48, ptr %.34, align 4
  br label %d_loop_cond

sub_loop_cond:                                    ; preds = %sub_loop_body.endif, %set_x_y
  %.75 = load i64, ptr %.69, align 4
  %.76 = icmp slt i64 %.75, %.63
  br i1 %.76, label %sub_loop_body, label %sub_loop_end

sub_loop_body:                                    ; preds = %sub_loop_cond
  %.78 = call i64 @i64.array.get(ptr %.60, i64 %.75)
  store i64 0, ptr %.73, align 4
  %.80 = icmp slt i64 %.75, %.64
  br i1 %.80, label %sub_loop_body.if, label %sub_loop_body.endif

sub_loop_end:                                     ; preds = %sub_loop_cond
  br label %trim_cond

sub_loop_body.if:                                 ; preds = %sub_loop_body
  %.82 = call i64 @i64.array.get(ptr %.62, i64 %.75)
  store i64 %.82, ptr %.73, align 4
  br label %sub_loop_body.endif

sub_loop_body.endif:                              ; preds = %sub_loop_body.if, %sub_loop_body
  %.85 = load i64, ptr %.73, align 4
  %.86 = load i64, ptr %.71, align 4
  %.87 = sub i64 %.78, %.85
  %.88 = icmp ult i64 %.78, %.85
  %.89 = sub i64 %.87, %.86
  %.90 = icmp ult i64 %.87, %.86
  %.91 = or i1 %.88, %.90
  %.92 = zext i1 %.91 to i64
  store i64 %.92, ptr %.71, align 4
  call void @i64.array.append(ptr %.67, i64 %.89)
  %.95 = add i64 %.75, 1
  store i64 %.95, ptr %.69, align 4
  br label %sub_loop_cond

trim_cond:                                        ; preds = %trim_body, %sub_loop_end
  %.99 = call i64 @i64.array.length(ptr %.67)
  %.100 = icmp sgt i64 %.99, 1
  br i1 %.100, label %check_zero, label %trim_end

trim_body:                                        ; preds = %check_zero
  %.106 = getelementptr %i64.array, ptr %.67, i32 0, i32 1
  %.107 = sub i64 %.99, 1
  store i64 %.107, ptr %.106, align 4
  br label %trim_cond

trim_end:                                         ; preds = %check_zero, %trim_cond
  %.110 = getelementptr %bigint, ptr %.65, i32 0, i32 2
  store ptr %.67, ptr %.110, align 8
  %.112 = getelementptr %bigint, ptr %.65, i32 0, i32 1
  %.113 = xor i1 %.5, true
  %.114 = select i1 %.52, i1 %.113, i1 %.5
  store i1 %.114, ptr %.112, align 1
  %.116 = call i64 @i64.array.length(ptr %.67)
  %.117 = icmp eq i64 %.116, 1
  %.118 = call i64 @i64.array.get(ptr %.67, i64 0)
  %.119 = icmp eq i64 %.118, 0
  %.120 = and i1 %.117, %.119
  br i1 %.120, label %trim_end.if, label %trim_end.endif

check_zero:                                       ; preds = %trim_cond
  %.102 = sub i64 %.99, 1
  %.103 = call i64 @i64.array.get(ptr %.67, i64 %.102)
  %.104 = icmp eq i64 %.103, 0
  br i1 %.104, label %trim_body, label %trim_end

trim_end.if:                                      ; preds = %trim_end
  store i1 false, ptr %.112, align 1
  br label %trim_end.endif

trim_end.endif:                                   ; preds = %trim_end.if, %trim_end
  %.124 = load %bigint, ptr %.65, align 8
  ret %bigint %.124
}

define %bigint @bigint_mul_naive(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.5 = load i1, ptr %.4, align 1
  %.6 = getelementptr %bigint, ptr %.2, i32 0, i32 1
  %.7 = load i1, ptr %.6, align 1
  %.8 = xor i1 %.5, %.7
  %.9 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.10 = load ptr, ptr %.9, align 8
  %.11 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.12 = load ptr, ptr %.11, align 8
  %.13 = call i64 @i64.array.length(ptr %.10)
  %.14 = call i64 @i64.array.length(ptr %.12)
  %.15 = alloca %bigint, align 8
  %.16 = call ptr @malloc(i64 32)
  %.17 = bitcast ptr %.16 to ptr
  call void @i64.array.init(ptr %.17)
  %.19 = add i64 %.13, %.14
  %.20 = alloca i64, align 8
  store i64 0, ptr %.20, align 4
  br label %fill_cond

fill_cond:                                        ; preds = %fill_body, %entry
  %.23 = load i64, ptr %.20, align 4
  %.24 = icmp slt i64 %.23, %.19
  br i1 %.24, label %fill_body, label %fill_end

fill_body:                                        ; preds = %fill_cond
  call void @i64.array.append(ptr %.17, i64 0)
  %.27 = add i64 %.23, 1
  store i64 %.27, ptr %.20, align 4
  br label %fill_cond

fill_end:                                         ; preds = %fill_cond
  %.30 = alloca i64, align 8
  store i64 0, ptr %.30, align 4
  %.32 = alloca i128, align 8
  %.33 = alloca i64, align 8
  br label %outer_cond

outer_cond:                                       ; preds = %inner_end, %fill_end
  %.35 = load i64, ptr %.30, align 4
  %.36 = icmp slt i64 %.35, %.13
  br i1 %.36, label %outer_body, label %outer_end

outer_body:                                       ; preds = %outer_cond
  %.38 = call i64 @i64.array.get(ptr %.10, i64 %.35)
  %.39 = zext i64 %.38 to i128
  store i128 0, ptr %.32, align 4
  store i64 0, ptr %.33, align 4
  br label %inner_cond

outer_end:                                        ; preds = %outer_cond
  br label %trim_cond

inner_cond:                                       ; preds = %inner_body, %outer_body
  %.43 = load i64, ptr %.33, align 4
  %.44 = icmp slt i64 %.43, %.14
  br i1 %.44, label %inner_body, label %inner_end

inner_body:                                       ; preds = %inner_cond
  %.46 = call i64 @i64.array.get(ptr %.12, i64 %.43)
  %.47 = zext i64 %.46 to i128
  %.48 = add i64 %.35, %.43
  %.49 = call i64 @i64.array.get(ptr %.17, i64 %.48)
  %.50 = zext i64 %.49 to i128
  %.51 = mul i128 %.39, %.47
  %.52 = load i128, ptr %.32, align 4
  %.53 = add i128 %.51, %.50
  %.54 = add i128 %.53, %.52
  %.55 = trunc i128 %.54 to i64
  call void @i64.array.set(ptr %.17, i64 %.48, i64 %.55)
  %.57 = lshr i128 %.54, 64
  store i128 %.57, ptr %.32, align 4
  %.59 = add i64 %.43, 1
  store i64 %.59, ptr %.33, align 4
  br label %inner_cond

inner_end:                                        ; preds = %inner_cond
  %.62 = load i128, ptr %.32, align 4
  %.63 = trunc i128 %.62 to i64
  %.64 = add i64 %.35, %.14
  call void @i64.array.set(ptr %.17, i64 %.64, i64 %.63)
  %.66 = add i64 %.35, 1
  store i64 %.66, ptr %.30, align 4
  br label %outer_cond

trim_cond:                                        ; preds = %trim_body, %outer_end
  %.70 = call i64 @i64.array.length(ptr %.17)
  %.71 = icmp sgt i64 %.70, 1
  br i1 %.71, label %check_zero, label %trim_end

trim_body:                                        ; preds = %check_zero
  %.77 = getelementptr %i64.array, ptr %.17, i32 0, i32 1
  %.78 = sub i64 %.70, 1
  store i64 %.78, ptr %.77, align 4
  br label %trim_cond

trim_end:                                         ; preds = %check_zero, %trim_cond
  %.81 = getelementptr %bigint, ptr %.15, i32 0, i32 2
  store ptr %.17, ptr %.81, align 8
  %.83 = getelementptr %bigint, ptr %.15, i32 0, i32 1
  store i1 %.8, ptr %.83, align 1
  %.85 = call i64 @i64.array.length(ptr %.17)
  %.86 = icmp eq i64 %.85, 1
  %.87 = call i64 @i64.array.get(ptr %.17, i64 0)
  %.88 = icmp eq i64 %.87, 0
  %.89 = and i1 %.86, %.88
  br i1 %.89, label %trim_end.if, label %trim_end.endif

check_zero:                                       ; preds = %trim_cond
  %.73 = sub i64 %.70, 1
  %.74 = call i64 @i64.array.get(ptr %.17, i64 %.73)
  %.75 = icmp eq i64 %.74, 0
  br i1 %.75, label %trim_body, label %trim_end

trim_end.if:                                      ; preds = %trim_end
  store i1 false, ptr %.83, align 1
  br label %trim_end.endif

trim_end.endif:                                   ; preds = %trim_end.if, %trim_end
  %.93 = load %bigint, ptr %.15, align 8
  ret %bigint %.93
}

define %bigint @bigint_split_low(ptr %.1, i64 %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = alloca %bigint, align 8
  %.8 = call ptr @malloc(i64 32)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  %.11 = icmp slt i64 %.2, %.6
  %.12 = select i1 %.11, i64 %.2, i64 %.6
  %.13 = alloca i64, align 8
  store i64 0, ptr %.13, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %.16 = load i64, ptr %.13, align 4
  %.17 = icmp slt i64 %.16, %.12
  br i1 %.17, label %body, label %end

body:                                             ; preds = %cond
  %.19 = call i64 @i64.array.get(ptr %.5, i64 %.16)
  call void @i64.array.append(ptr %.9, i64 %.19)
  %.21 = add i64 %.16, 1
  store i64 %.21, ptr %.13, align 4
  br label %cond

end:                                              ; preds = %cond
  %.24 = call i64 @i64.array.length(ptr %.9)
  %.25 = icmp eq i64 %.24, 0
  br i1 %.25, label %end.if, label %end.endif

end.if:                                           ; preds = %end
  call void @i64.array.append(ptr %.9, i64 0)
  br label %end.endif

end.endif:                                        ; preds = %end.if, %end
  %.29 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.30 = load i1, ptr %.29, align 1
  %.31 = getelementptr %bigint, ptr %.7, i32 0, i32 1
  store i1 %.30, ptr %.31, align 1
  %.33 = getelementptr %bigint, ptr %.7, i32 0, i32 2
  store ptr %.9, ptr %.33, align 8
  %.35 = load %bigint, ptr %.7, align 8
  ret %bigint %.35
}

define %bigint @bigint_split_high(ptr %.1, i64 %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = alloca %bigint, align 8
  %.8 = call ptr @malloc(i64 32)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  %.11 = alloca i64, align 8
  store i64 %.2, ptr %.11, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %.14 = load i64, ptr %.11, align 4
  %.15 = icmp slt i64 %.14, %.6
  br i1 %.15, label %body, label %end

body:                                             ; preds = %cond
  %.17 = call i64 @i64.array.get(ptr %.5, i64 %.14)
  call void @i64.array.append(ptr %.9, i64 %.17)
  %.19 = add i64 %.14, 1
  store i64 %.19, ptr %.11, align 4
  br label %cond

end:                                              ; preds = %cond
  %.22 = call i64 @i64.array.length(ptr %.9)
  %.23 = icmp eq i64 %.22, 0
  br i1 %.23, label %end.if, label %end.endif

end.if:                                           ; preds = %end
  call void @i64.array.append(ptr %.9, i64 0)
  br label %end.endif

end.endif:                                        ; preds = %end.if, %end
  %.27 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.28 = load i1, ptr %.27, align 1
  %.29 = getelementptr %bigint, ptr %.7, i32 0, i32 1
  store i1 %.28, ptr %.29, align 1
  %.31 = getelementptr %bigint, ptr %.7, i32 0, i32 2
  store ptr %.9, ptr %.31, align 8
  %.33 = load %bigint, ptr %.7, align 8
  ret %bigint %.33
}

define %bigint @bigint_shift_left(ptr %.1, i64 %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = alloca %bigint, align 8
  %.8 = call ptr @malloc(i64 32)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  %.11 = alloca i64, align 8
  store i64 0, ptr %.11, align 4
  br label %zero_cond

zero_cond:                                        ; preds = %zero_body, %entry
  %.14 = load i64, ptr %.11, align 4
  %.15 = icmp slt i64 %.14, %.2
  br i1 %.15, label %zero_body, label %zero_end

zero_body:                                        ; preds = %zero_cond
  call void @i64.array.append(ptr %.9, i64 0)
  %.18 = add i64 %.14, 1
  store i64 %.18, ptr %.11, align 4
  br label %zero_cond

zero_end:                                         ; preds = %zero_cond
  %.21 = alloca i64, align 8
  store i64 0, ptr %.21, align 4
  br label %copy_cond

copy_cond:                                        ; preds = %copy_body, %zero_end
  %.24 = load i64, ptr %.21, align 4
  %.25 = icmp slt i64 %.24, %.6
  br i1 %.25, label %copy_body, label %copy_end

copy_body:                                        ; preds = %copy_cond
  %.27 = call i64 @i64.array.get(ptr %.5, i64 %.24)
  call void @i64.array.append(ptr %.9, i64 %.27)
  %.29 = add i64 %.24, 1
  store i64 %.29, ptr %.21, align 4
  br label %copy_cond

copy_end:                                         ; preds = %copy_cond
  %.32 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.33 = load i1, ptr %.32, align 1
  %.34 = getelementptr %bigint, ptr %.7, i32 0, i32 1
  store i1 %.33, ptr %.34, align 1
  %.36 = getelementptr %bigint, ptr %.7, i32 0, i32 2
  store ptr %.9, ptr %.36, align 8
  %.38 = load %bigint, ptr %.7, align 8
  ret %bigint %.38
}

define %bigint @bigint_mul(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.7 = load ptr, ptr %.6, align 8
  %.8 = call i64 @i64.array.length(ptr %.5)
  %.9 = call i64 @i64.array.length(ptr %.7)
  %.10 = icmp slt i64 %.8, 32
  %.11 = icmp slt i64 %.9, 32
  %.12 = and i1 %.10, %.11
  br i1 %.12, label %naive, label %karatsuba

naive:                                            ; preds = %entry
  %.14 = call %bigint @bigint_mul_naive(ptr %.1, ptr %.2)
  ret %bigint %.14

karatsuba:                                        ; preds = %entry
  %.16 = icmp sgt i64 %.8, %.9
  %.17 = select i1 %.16, i64 %.8, i64 %.9
  %.18 = sdiv i64 %.17, 2
  %.19 = alloca %bigint, align 8
  %.20 = alloca %bigint, align 8
  %.21 = alloca %bigint, align 8
  %.22 = alloca %bigint, align 8
  %.23 = call %bigint @bigint_split_low(ptr %.1, i64 %.18)
  store %bigint %.23, ptr %.19, align 8
  %.25 = call %bigint @bigint_split_high(ptr %.1, i64 %.18)
  store %bigint %.25, ptr %.20, align 8
  %.27 = call %bigint @bigint_split_low(ptr %.2, i64 %.18)
  store %bigint %.27, ptr %.21, align 8
  %.29 = call %bigint @bigint_split_high(ptr %.2, i64 %.18)
  store %bigint %.29, ptr %.22, align 8
  %.31 = alloca %bigint, align 8
  %.32 = alloca %bigint, align 8
  %.33 = call %bigint @bigint_mul(ptr %.19, ptr %.21)
  store %bigint %.33, ptr %.31, align 8
  %.35 = call %bigint @bigint_mul(ptr %.20, ptr %.22)
  store %bigint %.35, ptr %.32, align 8
  %.37 = alloca %bigint, align 8
  %.38 = call %bigint @bigint_add(ptr %.19, ptr %.20)
  store %bigint %.38, ptr %.37, align 8
  %.40 = alloca %bigint, align 8
  %.41 = call %bigint @bigint_add(ptr %.21, ptr %.22)
  store %bigint %.41, ptr %.40, align 8
  %.43 = alloca %bigint, align 8
  %.44 = call %bigint @bigint_mul(ptr %.37, ptr %.40)
  store %bigint %.44, ptr %.43, align 8
  %.46 = alloca %bigint, align 8
  %.47 = call %bigint @bigint_sub(ptr %.43, ptr %.31)
  store %bigint %.47, ptr %.46, align 8
  %.49 = alloca %bigint, align 8
  %.50 = call %bigint @bigint_sub(ptr %.46, ptr %.32)
  store %bigint %.50, ptr %.49, align 8
  %.52 = mul i64 %.18, 2
  %.53 = alloca %bigint, align 8
  %.54 = call %bigint @bigint_shift_left(ptr %.32, i64 %.52)
  store %bigint %.54, ptr %.53, align 8
  %.56 = alloca %bigint, align 8
  %.57 = call %bigint @bigint_shift_left(ptr %.49, i64 %.18)
  store %bigint %.57, ptr %.56, align 8
  %.59 = alloca %bigint, align 8
  %.60 = call %bigint @bigint_add(ptr %.53, ptr %.56)
  store %bigint %.60, ptr %.59, align 8
  %.62 = call %bigint @bigint_add(ptr %.59, ptr %.31)
  call void @free_bigint(ptr %.19)
  call void @free_bigint(ptr %.20)
  call void @free_bigint(ptr %.21)
  call void @free_bigint(ptr %.22)
  call void @free_bigint(ptr %.31)
  call void @free_bigint(ptr %.32)
  call void @free_bigint(ptr %.37)
  call void @free_bigint(ptr %.40)
  call void @free_bigint(ptr %.43)
  call void @free_bigint(ptr %.46)
  call void @free_bigint(ptr %.49)
  call void @free_bigint(ptr %.53)
  call void @free_bigint(ptr %.56)
  call void @free_bigint(ptr %.59)
  ret %bigint %.62
}

define %bigint @bigint_div(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = icmp eq i64 %.6, 1
  %.8 = call i64 @i64.array.get(ptr %.5, i64 0)
  %.9 = icmp eq i64 %.8, 0
  %.10 = and i1 %.7, %.9
  br i1 %.10, label %div_zero, label %start_div

div_zero:                                         ; preds = %entry
  %.12 = alloca [17 x i8], align 1
  store [17 x i8] c"Division by zero\00", ptr %.12, align 1
  %.14 = getelementptr [17 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @exit(i32 1)
  unreachable

start_div:                                        ; preds = %entry
  %.19 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.20 = load i1, ptr %.19, align 1
  %.21 = getelementptr %bigint, ptr %.2, i32 0, i32 1
  %.22 = load i1, ptr %.21, align 1
  %.23 = xor i1 %.20, %.22
  %.24 = alloca %bigint, align 8
  %.25 = getelementptr %bigint, ptr %.24, i32 0, i32 1
  store i1 false, ptr %.25, align 1
  %.27 = getelementptr %bigint, ptr %.24, i32 0, i32 2
  store ptr %.5, ptr %.27, align 8
  %.29 = alloca %bigint, align 8
  %.30 = getelementptr %bigint, ptr %.29, i32 0, i32 1
  store i1 false, ptr %.30, align 1
  %.32 = getelementptr %bigint, ptr %.29, i32 0, i32 2
  %.33 = call ptr @malloc(i64 32)
  %.34 = bitcast ptr %.33 to ptr
  call void @i64.array.init(ptr %.34)
  call void @i64.array.append(ptr %.34, i64 0)
  store ptr %.34, ptr %.32, align 8
  %.38 = alloca %bigint, align 8
  %.39 = call ptr @malloc(i64 32)
  %.40 = bitcast ptr %.39 to ptr
  call void @i64.array.init(ptr %.40)
  %.42 = getelementptr %bigint, ptr %.38, i32 0, i32 2
  store ptr %.40, ptr %.42, align 8
  %.44 = getelementptr %bigint, ptr %.38, i32 0, i32 1
  store i1 false, ptr %.44, align 1
  %.46 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.47 = load ptr, ptr %.46, align 8
  %.48 = call i64 @i64.array.length(ptr %.47)
  %.49 = alloca i64, align 8
  store i64 0, ptr %.49, align 4
  br label %fill_q_cond

fill_q_cond:                                      ; preds = %fill_q_body, %start_div
  %.52 = load i64, ptr %.49, align 4
  %.53 = icmp slt i64 %.52, %.48
  br i1 %.53, label %fill_q_body, label %fill_q_end

fill_q_body:                                      ; preds = %fill_q_cond
  call void @i64.array.append(ptr %.40, i64 0)
  %.56 = add i64 %.52, 1
  store i64 %.56, ptr %.49, align 4
  br label %fill_q_cond

fill_q_end:                                       ; preds = %fill_q_cond
  %.59 = alloca i64, align 8
  %.60 = alloca i64, align 8
  %.61 = alloca i64, align 8
  %.62 = mul i64 %.48, 64
  %.63 = sub i64 %.62, 1
  store i64 %.63, ptr %.59, align 4
  br label %loop_div_cond

loop_div_cond:                                    ; preds = %next_iter, %fill_q_end
  %.66 = load i64, ptr %.59, align 4
  %.67 = icmp sge i64 %.66, 0
  br i1 %.67, label %loop_div_body, label %loop_div_end

loop_div_body:                                    ; preds = %loop_div_cond
  %.69 = sdiv i64 %.66, 64
  %.70 = srem i64 %.66, 64
  %.71 = call i64 @i64.array.get(ptr %.47, i64 %.69)
  %.72 = lshr i64 %.71, %.70
  %.73 = and i64 %.72, 1
  %.74 = load ptr, ptr %.32, align 8
  %.75 = call i64 @i64.array.length(ptr %.74)
  store i64 %.73, ptr %.60, align 4
  store i64 0, ptr %.61, align 4
  br label %shift_loop_cond

loop_div_end:                                     ; preds = %loop_div_cond
  br label %div_trim_cond

shift_loop_cond:                                  ; preds = %shift_loop_body, %loop_div_body
  %.79 = load i64, ptr %.61, align 4
  %.80 = icmp slt i64 %.79, %.75
  br i1 %.80, label %shift_loop_body, label %shift_loop_end

shift_loop_body:                                  ; preds = %shift_loop_cond
  %.82 = call i64 @i64.array.get(ptr %.74, i64 %.79)
  %.83 = load i64, ptr %.60, align 4
  %.84 = shl i64 %.82, 1
  %.85 = or i64 %.84, %.83
  %.86 = lshr i64 %.82, 63
  call void @i64.array.set(ptr %.74, i64 %.79, i64 %.85)
  store i64 %.86, ptr %.60, align 4
  %.89 = add i64 %.79, 1
  store i64 %.89, ptr %.61, align 4
  br label %shift_loop_cond

shift_loop_end:                                   ; preds = %shift_loop_cond
  %.92 = load i64, ptr %.60, align 4
  %.93 = icmp ne i64 %.92, 0
  br i1 %.93, label %shift_loop_end.if, label %shift_loop_end.endif

shift_loop_end.if:                                ; preds = %shift_loop_end
  call void @i64.array.append(ptr %.74, i64 %.92)
  br label %shift_loop_end.endif

shift_loop_end.endif:                             ; preds = %shift_loop_end.if, %shift_loop_end
  %.97 = call i32 @bigint_cmp(ptr %.29, ptr %.24)
  %.98 = icmp sge i32 %.97, 0
  br i1 %.98, label %sub_block, label %next_iter

sub_block:                                        ; preds = %shift_loop_end.endif
  %.100 = call %bigint @bigint_sub(ptr %.29, ptr %.24)
  %.101 = alloca %bigint, align 8
  store %bigint %.100, ptr %.101, align 8
  %.103 = getelementptr %bigint, ptr %.101, i32 0, i32 2
  %.104 = load ptr, ptr %.103, align 8
  %.105 = getelementptr %bigint, ptr %.101, i32 0, i32 1
  %.106 = load i1, ptr %.105, align 1
  call void @free_bigint(ptr %.29)
  store ptr %.104, ptr %.32, align 8
  store i1 %.106, ptr %.30, align 1
  %.110 = call i64 @i64.array.get(ptr %.40, i64 %.69)
  %.111 = shl i64 1, %.70
  %.112 = or i64 %.110, %.111
  call void @i64.array.set(ptr %.40, i64 %.69, i64 %.112)
  br label %next_iter

next_iter:                                        ; preds = %sub_block, %shift_loop_end.endif
  %.115 = sub i64 %.66, 1
  store i64 %.115, ptr %.59, align 4
  br label %loop_div_cond

div_trim_cond:                                    ; preds = %div_trim_body, %loop_div_end
  %.119 = call i64 @i64.array.length(ptr %.40)
  %.120 = icmp sgt i64 %.119, 1
  br i1 %.120, label %div_check_zero, label %div_trim_end

div_trim_body:                                    ; preds = %div_check_zero
  %.126 = getelementptr %i64.array, ptr %.40, i32 0, i32 1
  %.127 = sub i64 %.119, 1
  store i64 %.127, ptr %.126, align 4
  br label %div_trim_cond

div_trim_end:                                     ; preds = %div_check_zero, %div_trim_cond
  store i1 %.23, ptr %.44, align 1
  %.131 = call i64 @i64.array.length(ptr %.40)
  %.132 = icmp eq i64 %.131, 1
  %.133 = call i64 @i64.array.get(ptr %.40, i64 0)
  %.134 = icmp eq i64 %.133, 0
  %.135 = and i1 %.132, %.134
  br i1 %.135, label %div_trim_end.if, label %div_trim_end.endif

div_check_zero:                                   ; preds = %div_trim_cond
  %.122 = sub i64 %.119, 1
  %.123 = call i64 @i64.array.get(ptr %.40, i64 %.122)
  %.124 = icmp eq i64 %.123, 0
  br i1 %.124, label %div_trim_body, label %div_trim_end

div_trim_end.if:                                  ; preds = %div_trim_end
  store i1 false, ptr %.44, align 1
  br label %div_trim_end.endif

div_trim_end.endif:                               ; preds = %div_trim_end.if, %div_trim_end
  call void @free_bigint(ptr %.29)
  %.140 = load %bigint, ptr %.38, align 8
  ret %bigint %.140
}

define %bigint @bigint_mod(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = icmp eq i64 %.6, 1
  %.8 = call i64 @i64.array.get(ptr %.5, i64 0)
  %.9 = icmp eq i64 %.8, 0
  %.10 = and i1 %.7, %.9
  br i1 %.10, label %div_zero, label %start_div

div_zero:                                         ; preds = %entry
  %.12 = alloca [15 x i8], align 1
  store [15 x i8] c"Modulo by zero\00", ptr %.12, align 1
  %.14 = getelementptr [15 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @exit(i32 1)
  unreachable

start_div:                                        ; preds = %entry
  %.19 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.20 = load i1, ptr %.19, align 1
  %.21 = alloca %bigint, align 8
  %.22 = getelementptr %bigint, ptr %.21, i32 0, i32 1
  store i1 false, ptr %.22, align 1
  %.24 = getelementptr %bigint, ptr %.21, i32 0, i32 2
  store ptr %.5, ptr %.24, align 8
  %.26 = alloca %bigint, align 8
  %.27 = getelementptr %bigint, ptr %.26, i32 0, i32 1
  store i1 false, ptr %.27, align 1
  %.29 = getelementptr %bigint, ptr %.26, i32 0, i32 2
  %.30 = call ptr @malloc(i64 32)
  %.31 = bitcast ptr %.30 to ptr
  call void @i64.array.init(ptr %.31)
  call void @i64.array.append(ptr %.31, i64 0)
  store ptr %.31, ptr %.29, align 8
  %.35 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.36 = load ptr, ptr %.35, align 8
  %.37 = call i64 @i64.array.length(ptr %.36)
  %.38 = alloca i64, align 8
  %.39 = alloca i64, align 8
  %.40 = alloca i64, align 8
  %.41 = mul i64 %.37, 64
  %.42 = sub i64 %.41, 1
  store i64 %.42, ptr %.38, align 4
  br label %loop_mod_cond

loop_mod_cond:                                    ; preds = %next_iter, %start_div
  %.45 = load i64, ptr %.38, align 4
  %.46 = icmp sge i64 %.45, 0
  br i1 %.46, label %loop_mod_body, label %loop_mod_end

loop_mod_body:                                    ; preds = %loop_mod_cond
  %.48 = sdiv i64 %.45, 64
  %.49 = srem i64 %.45, 64
  %.50 = call i64 @i64.array.get(ptr %.36, i64 %.48)
  %.51 = lshr i64 %.50, %.49
  %.52 = and i64 %.51, 1
  %.53 = load ptr, ptr %.29, align 8
  %.54 = call i64 @i64.array.length(ptr %.53)
  store i64 %.52, ptr %.39, align 4
  store i64 0, ptr %.40, align 4
  br label %shift_loop_cond

loop_mod_end:                                     ; preds = %loop_mod_cond
  %.93 = load ptr, ptr %.29, align 8
  store i1 %.20, ptr %.27, align 1
  %.95 = call i64 @i64.array.length(ptr %.93)
  %.96 = icmp eq i64 %.95, 1
  %.97 = call i64 @i64.array.get(ptr %.93, i64 0)
  %.98 = icmp eq i64 %.97, 0
  %.99 = and i1 %.96, %.98
  br i1 %.99, label %loop_mod_end.if, label %loop_mod_end.endif

shift_loop_cond:                                  ; preds = %shift_loop_body, %loop_mod_body
  %.58 = load i64, ptr %.40, align 4
  %.59 = icmp slt i64 %.58, %.54
  br i1 %.59, label %shift_loop_body, label %shift_loop_end

shift_loop_body:                                  ; preds = %shift_loop_cond
  %.61 = call i64 @i64.array.get(ptr %.53, i64 %.58)
  %.62 = load i64, ptr %.39, align 4
  %.63 = shl i64 %.61, 1
  %.64 = or i64 %.63, %.62
  %.65 = lshr i64 %.61, 63
  call void @i64.array.set(ptr %.53, i64 %.58, i64 %.64)
  store i64 %.65, ptr %.39, align 4
  %.68 = add i64 %.58, 1
  store i64 %.68, ptr %.40, align 4
  br label %shift_loop_cond

shift_loop_end:                                   ; preds = %shift_loop_cond
  %.71 = load i64, ptr %.39, align 4
  %.72 = icmp ne i64 %.71, 0
  br i1 %.72, label %shift_loop_end.if, label %shift_loop_end.endif

shift_loop_end.if:                                ; preds = %shift_loop_end
  call void @i64.array.append(ptr %.53, i64 %.71)
  br label %shift_loop_end.endif

shift_loop_end.endif:                             ; preds = %shift_loop_end.if, %shift_loop_end
  %.76 = call i32 @bigint_cmp(ptr %.26, ptr %.21)
  %.77 = icmp sge i32 %.76, 0
  br i1 %.77, label %sub_block, label %next_iter

sub_block:                                        ; preds = %shift_loop_end.endif
  %.79 = call %bigint @bigint_sub(ptr %.26, ptr %.21)
  %.80 = alloca %bigint, align 8
  store %bigint %.79, ptr %.80, align 8
  %.82 = getelementptr %bigint, ptr %.80, i32 0, i32 2
  %.83 = load ptr, ptr %.82, align 8
  %.84 = getelementptr %bigint, ptr %.80, i32 0, i32 1
  %.85 = load i1, ptr %.84, align 1
  call void @free_bigint(ptr %.26)
  store ptr %.83, ptr %.29, align 8
  store i1 %.85, ptr %.27, align 1
  br label %next_iter

next_iter:                                        ; preds = %sub_block, %shift_loop_end.endif
  %.90 = sub i64 %.45, 1
  store i64 %.90, ptr %.38, align 4
  br label %loop_mod_cond

loop_mod_end.if:                                  ; preds = %loop_mod_end
  store i1 false, ptr %.27, align 1
  br label %loop_mod_end.endif

loop_mod_end.endif:                               ; preds = %loop_mod_end.if, %loop_mod_end
  %.103 = load %bigint, ptr %.26, align 8
  ret %bigint %.103
}

define %decimal @decimal_add(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %decimal, ptr %.1, i32 0, i32 1
  %.5 = load ptr, ptr %.4, align 8
  %.6 = getelementptr %decimal, ptr %.1, i32 0, i32 2
  %.7 = load i64, ptr %.6, align 4
  %.8 = getelementptr %decimal, ptr %.2, i32 0, i32 1
  %.9 = load ptr, ptr %.8, align 8
  %.10 = getelementptr %decimal, ptr %.2, i32 0, i32 2
  %.11 = load i64, ptr %.10, align 4
  %.12 = icmp slt i64 %.7, %.11
  %.13 = icmp sgt i64 %.7, %.11
  %.14 = alloca ptr, align 8
  %.15 = alloca ptr, align 8
  %.16 = alloca i64, align 8
  store ptr %.5, ptr %.14, align 8
  store ptr %.9, ptr %.15, align 8
  store i64 %.7, ptr %.16, align 4
  br i1 %.12, label %adjust_b, label %adjust_a

adjust_b:                                         ; preds = %entry
  %.21 = sub i64 %.11, %.7
  store i64 %.7, ptr %.16, align 4
  %.23 = alloca %bigint, align 8
  %.24 = call ptr @malloc(i64 32)
  %.25 = bitcast ptr %.24 to ptr
  call void @i64.array.init(ptr %.25)
  call void @i64.array.append(ptr %.25, i64 10)
  %.28 = getelementptr %bigint, ptr %.23, i32 0, i32 1
  store i1 false, ptr %.28, align 1
  %.30 = getelementptr %bigint, ptr %.23, i32 0, i32 2
  store ptr %.25, ptr %.30, align 8
  %.32 = alloca ptr, align 8
  store ptr %.9, ptr %.32, align 8
  %.34 = alloca i64, align 8
  store i64 0, ptr %.34, align 4
  br label %loop_cond_b

adjust_a:                                         ; preds = %entry
  br i1 %.13, label %need_adjust_a, label %no_adjust

do_add:                                           ; preds = %loop_end_a, %no_adjust, %loop_end_b
  %.85 = load ptr, ptr %.14, align 8
  %.86 = load ptr, ptr %.15, align 8
  %.87 = load i64, ptr %.16, align 4
  %.88 = call %bigint @bigint_add(ptr %.85, ptr %.86)
  %.89 = call ptr @malloc(i64 16)
  %.90 = bitcast ptr %.89 to ptr
  store %bigint %.88, ptr %.90, align 8
  %.92 = alloca %decimal, align 8
  %.93 = getelementptr %decimal, ptr %.92, i32 0, i32 1
  store ptr %.90, ptr %.93, align 8
  %.95 = getelementptr %decimal, ptr %.92, i32 0, i32 2
  store i64 %.87, ptr %.95, align 4
  %.97 = load %decimal, ptr %.92, align 8
  ret %decimal %.97

loop_cond_b:                                      ; preds = %loop_body_b, %adjust_b
  %.37 = load i64, ptr %.34, align 4
  %.38 = icmp slt i64 %.37, %.21
  br i1 %.38, label %loop_body_b, label %loop_end_b

loop_body_b:                                      ; preds = %loop_cond_b
  %.40 = load ptr, ptr %.32, align 8
  %.41 = call %bigint @bigint_mul(ptr %.40, ptr %.23)
  %.42 = call ptr @malloc(i64 16)
  %.43 = bitcast ptr %.42 to ptr
  store %bigint %.41, ptr %.43, align 8
  store ptr %.43, ptr %.32, align 8
  %.46 = add i64 %.37, 1
  store i64 %.46, ptr %.34, align 4
  br label %loop_cond_b

loop_end_b:                                       ; preds = %loop_cond_b
  %.49 = load ptr, ptr %.32, align 8
  store ptr %.49, ptr %.15, align 8
  br label %do_add

need_adjust_a:                                    ; preds = %adjust_a
  %.53 = sub i64 %.7, %.11
  store i64 %.11, ptr %.16, align 4
  %.55 = alloca %bigint, align 8
  %.56 = call ptr @malloc(i64 32)
  %.57 = bitcast ptr %.56 to ptr
  call void @i64.array.init(ptr %.57)
  call void @i64.array.append(ptr %.57, i64 10)
  %.60 = getelementptr %bigint, ptr %.55, i32 0, i32 1
  store i1 false, ptr %.60, align 1
  %.62 = getelementptr %bigint, ptr %.55, i32 0, i32 2
  store ptr %.57, ptr %.62, align 8
  %.64 = alloca ptr, align 8
  store ptr %.5, ptr %.64, align 8
  %.66 = alloca i64, align 8
  store i64 0, ptr %.66, align 4
  br label %loop_cond_a

no_adjust:                                        ; preds = %adjust_a
  br label %do_add

loop_cond_a:                                      ; preds = %loop_body_a, %need_adjust_a
  %.69 = load i64, ptr %.66, align 4
  %.70 = icmp slt i64 %.69, %.53
  br i1 %.70, label %loop_body_a, label %loop_end_a

loop_body_a:                                      ; preds = %loop_cond_a
  %.72 = load ptr, ptr %.64, align 8
  %.73 = call %bigint @bigint_mul(ptr %.72, ptr %.55)
  %.74 = call ptr @malloc(i64 16)
  %.75 = bitcast ptr %.74 to ptr
  store %bigint %.73, ptr %.75, align 8
  store ptr %.75, ptr %.64, align 8
  %.78 = add i64 %.69, 1
  store i64 %.78, ptr %.66, align 4
  br label %loop_cond_a

loop_end_a:                                       ; preds = %loop_cond_a
  %.81 = load ptr, ptr %.64, align 8
  store ptr %.81, ptr %.14, align 8
  br label %do_add
}

define %decimal @decimal_sub(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %decimal, ptr %.1, i32 0, i32 1
  %.5 = load ptr, ptr %.4, align 8
  %.6 = getelementptr %decimal, ptr %.1, i32 0, i32 2
  %.7 = load i64, ptr %.6, align 4
  %.8 = getelementptr %decimal, ptr %.2, i32 0, i32 1
  %.9 = load ptr, ptr %.8, align 8
  %.10 = getelementptr %decimal, ptr %.2, i32 0, i32 2
  %.11 = load i64, ptr %.10, align 4
  %.12 = icmp slt i64 %.7, %.11
  %.13 = icmp sgt i64 %.7, %.11
  %.14 = alloca ptr, align 8
  %.15 = alloca ptr, align 8
  %.16 = alloca i64, align 8
  store ptr %.5, ptr %.14, align 8
  store ptr %.9, ptr %.15, align 8
  store i64 %.7, ptr %.16, align 4
  br i1 %.12, label %adjust_b, label %adjust_a

adjust_b:                                         ; preds = %entry
  %.21 = sub i64 %.11, %.7
  store i64 %.7, ptr %.16, align 4
  %.23 = alloca %bigint, align 8
  %.24 = call ptr @malloc(i64 32)
  %.25 = bitcast ptr %.24 to ptr
  call void @i64.array.init(ptr %.25)
  call void @i64.array.append(ptr %.25, i64 10)
  %.28 = getelementptr %bigint, ptr %.23, i32 0, i32 1
  store i1 false, ptr %.28, align 1
  %.30 = getelementptr %bigint, ptr %.23, i32 0, i32 2
  store ptr %.25, ptr %.30, align 8
  %.32 = alloca ptr, align 8
  store ptr %.9, ptr %.32, align 8
  %.34 = alloca i64, align 8
  store i64 0, ptr %.34, align 4
  br label %loop_cond_b

adjust_a:                                         ; preds = %entry
  br i1 %.13, label %need_adjust_a, label %no_adjust

do_sub:                                           ; preds = %loop_end_a, %no_adjust, %loop_end_b
  %.83 = load ptr, ptr %.14, align 8
  %.84 = load ptr, ptr %.15, align 8
  %.85 = load i64, ptr %.16, align 4
  %.86 = call %bigint @bigint_sub(ptr %.83, ptr %.84)
  %.87 = call ptr @malloc(i64 16)
  %.88 = bitcast ptr %.87 to ptr
  store %bigint %.86, ptr %.88, align 8
  %.90 = alloca %decimal, align 8
  %.91 = getelementptr %decimal, ptr %.90, i32 0, i32 1
  store ptr %.88, ptr %.91, align 8
  %.93 = getelementptr %decimal, ptr %.90, i32 0, i32 2
  store i64 %.85, ptr %.93, align 4
  %.95 = load %decimal, ptr %.90, align 8
  ret %decimal %.95

loop_cond_b:                                      ; preds = %loop_body_b, %adjust_b
  %.37 = load i64, ptr %.34, align 4
  %.38 = icmp slt i64 %.37, %.21
  br i1 %.38, label %loop_body_b, label %loop_end_b

loop_body_b:                                      ; preds = %loop_cond_b
  %.40 = load ptr, ptr %.32, align 8
  %.41 = call %bigint @bigint_mul(ptr %.40, ptr %.23)
  %.42 = alloca %bigint, align 8
  store %bigint %.41, ptr %.42, align 8
  store ptr %.42, ptr %.32, align 8
  %.45 = add i64 %.37, 1
  store i64 %.45, ptr %.34, align 4
  br label %loop_cond_b

loop_end_b:                                       ; preds = %loop_cond_b
  %.48 = load ptr, ptr %.32, align 8
  store ptr %.48, ptr %.15, align 8
  br label %do_sub

need_adjust_a:                                    ; preds = %adjust_a
  %.52 = sub i64 %.7, %.11
  store i64 %.11, ptr %.16, align 4
  %.54 = alloca %bigint, align 8
  %.55 = call ptr @malloc(i64 32)
  %.56 = bitcast ptr %.55 to ptr
  call void @i64.array.init(ptr %.56)
  call void @i64.array.append(ptr %.56, i64 10)
  %.59 = getelementptr %bigint, ptr %.54, i32 0, i32 1
  store i1 false, ptr %.59, align 1
  %.61 = getelementptr %bigint, ptr %.54, i32 0, i32 2
  store ptr %.56, ptr %.61, align 8
  %.63 = alloca ptr, align 8
  store ptr %.5, ptr %.63, align 8
  %.65 = alloca i64, align 8
  store i64 0, ptr %.65, align 4
  br label %loop_cond_a

no_adjust:                                        ; preds = %adjust_a
  br label %do_sub

loop_cond_a:                                      ; preds = %loop_body_a, %need_adjust_a
  %.68 = load i64, ptr %.65, align 4
  %.69 = icmp slt i64 %.68, %.52
  br i1 %.69, label %loop_body_a, label %loop_end_a

loop_body_a:                                      ; preds = %loop_cond_a
  %.71 = load ptr, ptr %.63, align 8
  %.72 = call %bigint @bigint_mul(ptr %.71, ptr %.54)
  %.73 = alloca %bigint, align 8
  store %bigint %.72, ptr %.73, align 8
  store ptr %.73, ptr %.63, align 8
  %.76 = add i64 %.68, 1
  store i64 %.76, ptr %.65, align 4
  br label %loop_cond_a

loop_end_a:                                       ; preds = %loop_cond_a
  %.79 = load ptr, ptr %.63, align 8
  store ptr %.79, ptr %.14, align 8
  br label %do_sub
}

define %decimal @decimal_mul(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %decimal, ptr %.1, i32 0, i32 1
  %.5 = load ptr, ptr %.4, align 8
  %.6 = getelementptr %decimal, ptr %.1, i32 0, i32 2
  %.7 = load i64, ptr %.6, align 4
  %.8 = getelementptr %decimal, ptr %.2, i32 0, i32 1
  %.9 = load ptr, ptr %.8, align 8
  %.10 = getelementptr %decimal, ptr %.2, i32 0, i32 2
  %.11 = load i64, ptr %.10, align 4
  %.12 = call %bigint @bigint_mul(ptr %.5, ptr %.9)
  %.13 = add i64 %.7, %.11
  %.14 = alloca %decimal, align 8
  %.15 = call ptr @malloc(i64 16)
  %.16 = bitcast ptr %.15 to ptr
  store %bigint %.12, ptr %.16, align 8
  %.18 = getelementptr %decimal, ptr %.14, i32 0, i32 1
  store ptr %.16, ptr %.18, align 8
  %.20 = getelementptr %decimal, ptr %.14, i32 0, i32 2
  store i64 %.13, ptr %.20, align 4
  %.22 = load %decimal, ptr %.14, align 8
  ret %decimal %.22
}

define %decimal @decimal_neg(ptr %.1) {
entry:
  %.3 = getelementptr %decimal, ptr %.1, i32 0, i32 1
  %.4 = load ptr, ptr %.3, align 8
  %.5 = getelementptr %decimal, ptr %.1, i32 0, i32 2
  %.6 = load i64, ptr %.5, align 4
  %.7 = call %bigint @bigint_neg(ptr %.4)
  %.8 = alloca %decimal, align 8
  %.9 = call ptr @malloc(i64 24)
  %.10 = bitcast ptr %.9 to ptr
  store %bigint %.7, ptr %.10, align 8
  %.12 = getelementptr %decimal, ptr %.8, i32 0, i32 1
  store ptr %.10, ptr %.12, align 8
  %.14 = getelementptr %decimal, ptr %.8, i32 0, i32 2
  store i64 %.6, ptr %.14, align 4
  %.16 = load %decimal, ptr %.8, align 8
  ret %decimal %.16
}

define ptr @number_to_decimal(ptr %.1) {
entry:
  %.3 = getelementptr %number, ptr %.1, i32 0, i32 1
  %.4 = load i8, ptr %.3, align 1
  %.5 = getelementptr %number, ptr %.1, i32 0, i32 2
  %.6 = load ptr, ptr %.5, align 8
  %result = alloca ptr, align 8
  switch i8 %.4, label %case_int [
    i8 0, label %case_int
    i8 1, label %case_float
    i8 2, label %case_bigint
    i8 3, label %case_decimal
  ]

case_int:                                         ; preds = %entry, %entry
  %.8 = bitcast ptr %.6 to ptr
  %.9 = load i64, ptr %.8, align 4
  %.10 = call ptr @malloc(i64 16)
  %.11 = bitcast ptr %.10 to ptr
  %.12 = call ptr @malloc(i64 16)
  %.13 = bitcast ptr %.12 to ptr
  %.14 = call ptr @malloc(i64 32)
  %.15 = bitcast ptr %.14 to ptr
  call void @i64.array.init(ptr %.15)
  %.17 = icmp slt i64 %.9, 0
  %.18 = sub i64 0, %.9
  %.19 = select i1 %.17, i64 %.18, i64 %.9
  call void @i64.array.append(ptr %.15, i64 %.19)
  %.21 = getelementptr %bigint, ptr %.13, i32 0, i32 1
  store i1 %.17, ptr %.21, align 1
  %.23 = getelementptr %bigint, ptr %.13, i32 0, i32 2
  store ptr %.15, ptr %.23, align 8
  %.25 = getelementptr %decimal, ptr %.11, i32 0, i32 1
  store ptr %.13, ptr %.25, align 8
  %.27 = getelementptr %decimal, ptr %.11, i32 0, i32 2
  store i64 0, ptr %.27, align 4
  store ptr %.11, ptr %result, align 8
  br label %end

case_float:                                       ; preds = %entry
  %.31 = bitcast ptr %.6 to ptr
  %.32 = load double, ptr %.31, align 8
  %.33 = fmul double %.32, 1.000000e+06
  %.34 = fptosi double %.33 to i64
  %.35 = call ptr @malloc(i64 16)
  %.36 = bitcast ptr %.35 to ptr
  %.37 = call ptr @malloc(i64 16)
  %.38 = bitcast ptr %.37 to ptr
  %.39 = call ptr @malloc(i64 32)
  %.40 = bitcast ptr %.39 to ptr
  call void @i64.array.init(ptr %.40)
  %.42 = icmp slt i64 %.34, 0
  %.43 = sub i64 0, %.34
  %.44 = select i1 %.42, i64 %.43, i64 %.34
  call void @i64.array.append(ptr %.40, i64 %.44)
  %.46 = getelementptr %bigint, ptr %.38, i32 0, i32 1
  store i1 %.42, ptr %.46, align 1
  %.48 = getelementptr %bigint, ptr %.38, i32 0, i32 2
  store ptr %.40, ptr %.48, align 8
  %.50 = getelementptr %decimal, ptr %.36, i32 0, i32 1
  store ptr %.38, ptr %.50, align 8
  %.52 = getelementptr %decimal, ptr %.36, i32 0, i32 2
  store i64 -6, ptr %.52, align 4
  store ptr %.36, ptr %result, align 8
  br label %end

case_bigint:                                      ; preds = %entry
  %.56 = bitcast ptr %.6 to ptr
  %.57 = call ptr @malloc(i64 16)
  %.58 = bitcast ptr %.57 to ptr
  %.59 = getelementptr %decimal, ptr %.58, i32 0, i32 1
  store ptr %.56, ptr %.59, align 8
  %.61 = getelementptr %decimal, ptr %.58, i32 0, i32 2
  store i64 0, ptr %.61, align 4
  store ptr %.58, ptr %result, align 8
  br label %end

case_decimal:                                     ; preds = %entry
  %.65 = bitcast ptr %.6 to ptr
  store ptr %.65, ptr %result, align 8
  br label %end

end:                                              ; preds = %case_decimal, %case_bigint, %case_float, %case_int
  %.68 = load ptr, ptr %result, align 8
  ret ptr %.68
}

define ptr @input_line() {
entry:
  %.2 = call ptr @malloc(i64 32)
  %.3 = bitcast ptr %.2 to ptr
  %.4 = getelementptr inbounds %i64.array, ptr %.3, i64 0, i32 1
  %.5 = getelementptr inbounds %i64.array, ptr %.3, i64 0, i32 2
  %.6 = getelementptr inbounds %i64.array, ptr %.3, i64 0, i32 3
  store i64 0, ptr %.4, align 4
  store i64 256, ptr %.5, align 4
  %.9 = mul i64 256, 8
  %.10 = call ptr @malloc(i64 %.9)
  %.11 = bitcast ptr %.10 to ptr
  store ptr %.11, ptr %.6, align 8
  %.13 = alloca i8, align 1
  br label %loop

loop:                                             ; preds = %store, %entry
  %.15 = call i8 @getchar()
  store i8 %.15, ptr %.13, align 1
  %.17 = icmp eq i8 %.15, 10
  %.18 = icmp eq i8 %.15, -1
  %.19 = or i1 %.17, %.18
  br i1 %.19, label %done, label %store

store:                                            ; preds = %loop
  %.21 = load i64, ptr %.4, align 4
  %.22 = add i64 %.21, 1
  store i64 %.22, ptr %.4, align 4
  %.24 = load ptr, ptr %.6, align 8
  %.25 = load i8, ptr %.13, align 1
  %.26 = sext i8 %.25 to i64
  %.27 = getelementptr inbounds i64, ptr %.24, i64 %.22
  store i64 %.26, ptr %.27, align 4
  br label %loop

done:                                             ; preds = %loop
  ret ptr %.3
}

define i64 @str_to_int(ptr %.1) {
entry:
  %.3 = getelementptr inbounds %i64.array, ptr %.1, i64 0, i32 1
  %.4 = getelementptr inbounds %i64.array, ptr %.1, i64 0, i32 3
  %.5 = load i64, ptr %.3, align 4
  %.6 = load ptr, ptr %.4, align 8
  %.7 = alloca i64, align 8
  store i64 0, ptr %.7, align 4
  %.9 = alloca i64, align 8
  store i64 1, ptr %.9, align 4
  %.11 = alloca i64, align 8
  store i64 0, ptr %.11, align 4
  br label %check_neg

check_neg:                                        ; preds = %entry
  %.14 = getelementptr inbounds i64, ptr %.6, i64 1
  %.15 = load i64, ptr %.14, align 4
  %.16 = icmp eq i64 %.15, 45
  br i1 %.16, label %check_neg.if, label %check_neg.endif

loop:                                             ; preds = %check_neg.endif, %body
  %.22 = load i64, ptr %.9, align 4
  %.23 = icmp sle i64 %.22, %.5
  br i1 %.23, label %body, label %done

body:                                             ; preds = %loop
  %.25 = getelementptr inbounds i64, ptr %.6, i64 %.22
  %.26 = load i64, ptr %.25, align 4
  %.27 = sub i64 %.26, 48
  %.28 = load i64, ptr %.7, align 4
  %.29 = mul i64 %.28, 10
  %.30 = add i64 %.29, %.27
  store i64 %.30, ptr %.7, align 4
  %.32 = add i64 %.22, 1
  store i64 %.32, ptr %.9, align 4
  br label %loop

done:                                             ; preds = %loop
  %.35 = load i64, ptr %.7, align 4
  %.36 = load i64, ptr %.11, align 4
  %.37 = icmp ne i64 %.36, 0
  %.38 = sub i64 0, %.35
  %.39 = select i1 %.37, i64 %.38, i64 %.35
  ret i64 %.39

check_neg.if:                                     ; preds = %check_neg
  store i64 1, ptr %.11, align 4
  store i64 2, ptr %.9, align 4
  br label %check_neg.endif

check_neg.endif:                                  ; preds = %check_neg.if, %check_neg
  br label %loop
}

define i64 @main() {
entry:
  %.2 = call i32 @mi_version()
  call void @test()
  br label %exit

exit:                                             ; preds = %entry
  ret i64 0
}

define void @test() {
entry:
  %s = alloca ptr, align 8
  store ptr null, ptr %s, align 8
  %.2 = call ptr @malloc(i64 40)
  %.3 = bitcast ptr %.2 to ptr
  call void @i64.array.init(ptr %.3)
  call void @i64.array.append(ptr %.3, i64 104)
  call void @i64.array.append(ptr %.3, i64 101)
  call void @i64.array.append(ptr %.3, i64 108)
  call void @i64.array.append(ptr %.3, i64 108)
  call void @i64.array.append(ptr %.3, i64 111)
  %.11 = load ptr, ptr %s, align 8
  %.12 = icmp ne ptr %.11, null
  br i1 %.12, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif
  %.24 = load ptr, ptr %s, align 8
  %.25 = icmp eq ptr %.24, null
  br i1 %.25, label %rc_release_continue.1, label %rc_release.1

entry.if:                                         ; preds = %entry
  %.14 = icmp eq ptr %.11, null
  br i1 %.14, label %rc_release_continue, label %rc_release

entry.endif:                                      ; preds = %rc_release_continue, %entry
  store ptr %.3, ptr %s, align 8
  %.21 = load ptr, ptr %s, align 8
  call void @print(ptr %.21)
  br label %exit

rc_release:                                       ; preds = %entry.if
  %.16 = bitcast ptr %.11 to ptr
  call void @meteor_release(ptr %.16)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %entry.if
  br label %entry.endif

rc_release.1:                                     ; preds = %exit
  %.27 = bitcast ptr %.24 to ptr
  call void @meteor_release(ptr %.27)
  br label %rc_release_continue.1

rc_release_continue.1:                            ; preds = %rc_release.1, %exit
  ret void
}

!0 = !{}
