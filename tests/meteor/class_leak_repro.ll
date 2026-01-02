; ModuleID = '<string>'
source_filename = "<string>"
target triple = "unknown-unknown-unknown"

%i64.array = type { %meteor.header, i64, i64, ptr }
%meteor.header = type { i32, i32, i8, i8, i16, i32 }
%bigint = type { %meteor.header, i1, ptr }
%decimal = type { %meteor.header, ptr, i64 }
%number = type { %meteor.header, i8, ptr }
%dynamic = type { %meteor.header, i32, ptr }
%meteor.mutex = type { ptr }
%meteor.channel = type { %meteor.header, ptr, ptr, ptr, i64, i64, i64, i64 }
%StringWrapper = type { ptr }

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

declare ptr @calloc(i64, i64)

declare ptr @memset(ptr, i32, i64)

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
  %.23 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 1
  store i32 0, ptr %.23, align 4
  %.25 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 2
  store i8 0, ptr %.25, align 1
  %.27 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 3
  store i8 4, ptr %.27, align 1
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
  %.22 = call i32 @fflush(ptr null)
  call void @exit(i32 1)
  unreachable

is_index_less_than_zero:                          ; preds = %entry
  %.25 = icmp slt i64 %.11, 0
  br i1 %.25, label %negative_index, label %set

negative_index:                                   ; preds = %is_index_less_than_zero
  %.27 = add i64 %.14, %.11
  store i64 %.27, ptr %.7, align 4
  br label %set

set:                                              ; preds = %negative_index, %is_index_less_than_zero
  %.30 = load ptr, ptr %.5, align 8
  %.31 = getelementptr inbounds %i64.array, ptr %.30, i32 0, i32 3
  %.32 = load i64, ptr %.7, align 4
  %.33 = load ptr, ptr %.31, align 8
  %.34 = getelementptr inbounds i64, ptr %.33, i64 %.32
  %.35 = load i64, ptr %.9, align 4
  store i64 %.35, ptr %.34, align 4
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
  %.32 = call ptr @memset(ptr %.31, i32 0, i64 40)
  %.33 = bitcast ptr %.31 to ptr
  call void @i64.array.init(ptr %.33)
  %.35 = call ptr @malloc(i64 40)
  %.36 = call ptr @memset(ptr %.35, i32 0, i64 40)
  %.37 = bitcast ptr %.35 to ptr
  call void @i64.array.init(ptr %.37)
  %.39 = alloca i64, align 8
  store i64 0, ptr %.39, align 4
  br label %copy_cond

end:                                              ; preds = %print_dec_finish, %print_zero, %single_digit
  ret void

copy_cond:                                        ; preds = %copy_body, %multi_digit
  %.42 = load i64, ptr %.39, align 4
  %.43 = icmp slt i64 %.42, %.20
  br i1 %.43, label %copy_body, label %copy_end

copy_body:                                        ; preds = %copy_cond
  %.45 = getelementptr i64, ptr %.22, i64 %.42
  %.46 = load i64, ptr %.45, align 4
  call void @i64.array.append(ptr %.37, i64 %.46)
  %.48 = add i64 %.42, 1
  store i64 %.48, ptr %.39, align 4
  br label %copy_cond

copy_end:                                         ; preds = %copy_cond
  %.51 = alloca i64, align 8
  %.52 = alloca i64, align 8
  %.53 = alloca i64, align 8
  br label %div_loop

div_loop:                                         ; preds = %trim_end, %copy_end
  %.55 = getelementptr %i64.array, ptr %.37, i32 0, i32 1
  %.56 = load i64, ptr %.55, align 4
  store i64 %.56, ptr %.53, align 4
  %.58 = icmp eq i64 %.56, 0
  br i1 %.58, label %div_end, label %div_check_zero

div_check_zero:                                   ; preds = %div_loop
  %.60 = getelementptr %i64.array, ptr %.37, i32 0, i32 3
  %.61 = load ptr, ptr %.60, align 8
  %.62 = sub i64 %.56, 1
  %.63 = getelementptr i64, ptr %.61, i64 %.62
  %.64 = load i64, ptr %.63, align 4
  %.65 = icmp eq i64 %.64, 0
  %.66 = icmp eq i64 %.56, 1
  %.67 = and i1 %.65, %.66
  br i1 %.67, label %div_end, label %div_body

div_body:                                         ; preds = %div_check_zero
  store i64 0, ptr %.51, align 4
  %.70 = load i64, ptr %.53, align 4
  %.71 = sub i64 %.70, 1
  store i64 %.71, ptr %.52, align 4
  br label %div_inner_cond

div_end:                                          ; preds = %div_check_zero, %div_loop
  %.121 = getelementptr %i64.array, ptr %.33, i32 0, i32 1
  %.122 = load i64, ptr %.121, align 4
  %.123 = icmp sgt i64 %.122, 0
  br i1 %.123, label %print_digits, label %print_zero

div_inner_cond:                                   ; preds = %div_inner_body, %div_body
  %.74 = load i64, ptr %.52, align 4
  %.75 = icmp sge i64 %.74, 0
  br i1 %.75, label %div_inner_body, label %div_inner_end

div_inner_body:                                   ; preds = %div_inner_cond
  %.77 = getelementptr %i64.array, ptr %.37, i32 0, i32 3
  %.78 = load ptr, ptr %.77, align 8
  %.79 = getelementptr i64, ptr %.78, i64 %.74
  %.80 = load i64, ptr %.79, align 4
  %.81 = load i64, ptr %.51, align 4
  %.82 = mul i64 %.81, %.30
  %.83 = mul i64 %.81, 709551616
  %.84 = add i64 %.83, %.80
  %.85 = icmp ult i64 %.84, %.80
  %.86 = udiv i64 %.84, 1000000000
  %.87 = urem i64 %.84, 1000000000
  %.88 = select i1 %.85, i64 %.30, i64 0
  %.89 = select i1 %.85, i64 709551616, i64 0
  %.90 = add i64 %.87, %.89
  %.91 = urem i64 %.90, 1000000000
  %.92 = udiv i64 %.90, 1000000000
  %.93 = add i64 %.82, %.86
  %.94 = add i64 %.93, %.88
  %.95 = add i64 %.94, %.92
  store i64 %.95, ptr %.79, align 4
  store i64 %.91, ptr %.51, align 4
  %.98 = sub i64 %.74, 1
  store i64 %.98, ptr %.52, align 4
  br label %div_inner_cond

div_inner_end:                                    ; preds = %div_inner_cond
  %.101 = load i64, ptr %.51, align 4
  call void @i64.array.append(ptr %.33, i64 %.101)
  br label %trim_cond

trim_cond:                                        ; preds = %trim_do, %div_inner_end
  %.104 = getelementptr %i64.array, ptr %.37, i32 0, i32 1
  %.105 = load i64, ptr %.104, align 4
  %.106 = icmp sgt i64 %.105, 0
  br i1 %.106, label %trim_body, label %trim_end

trim_body:                                        ; preds = %trim_cond
  %.108 = getelementptr %i64.array, ptr %.37, i32 0, i32 3
  %.109 = load ptr, ptr %.108, align 8
  %.110 = sub i64 %.105, 1
  %.111 = getelementptr i64, ptr %.109, i64 %.110
  %.112 = load i64, ptr %.111, align 4
  %.113 = icmp eq i64 %.112, 0
  %.114 = icmp sgt i64 %.105, 1
  %.115 = and i1 %.113, %.114
  br i1 %.115, label %trim_do, label %trim_end

trim_end:                                         ; preds = %trim_body, %trim_cond
  br label %div_loop

trim_do:                                          ; preds = %trim_body
  %.117 = sub i64 %.105, 1
  store i64 %.117, ptr %.104, align 4
  br label %trim_cond

print_zero:                                       ; preds = %div_end
  %.125 = bitcast ptr @fmt_zero to ptr
  %.126 = call i32 (ptr, ...) @printf(ptr %.125)
  br label %end

print_digits:                                     ; preds = %div_end
  %.128 = alloca i64, align 8
  %.129 = sub i64 %.122, 1
  store i64 %.129, ptr %.128, align 4
  br label %print_dec_cond

print_dec_cond:                                   ; preds = %print_cont_blk, %print_digits
  %.132 = load i64, ptr %.128, align 4
  %.133 = icmp sge i64 %.132, 0
  br i1 %.133, label %print_dec_body, label %print_dec_finish

print_dec_body:                                   ; preds = %print_dec_cond
  %.135 = getelementptr %i64.array, ptr %.33, i32 0, i32 3
  %.136 = load ptr, ptr %.135, align 8
  %.137 = getelementptr i64, ptr %.136, i64 %.132
  %.138 = load i64, ptr %.137, align 4
  %.139 = icmp eq i64 %.132, %.129
  br i1 %.139, label %print_first_blk, label %print_pad_blk

print_dec_finish:                                 ; preds = %print_dec_cond
  %.150 = getelementptr %i64.array, ptr %.37, i32 0, i32 3
  %.151 = load ptr, ptr %.150, align 8
  %.152 = bitcast ptr %.151 to ptr
  call void @free(ptr %.152)
  %.154 = bitcast ptr %.37 to ptr
  call void @free(ptr %.154)
  %.156 = getelementptr %i64.array, ptr %.33, i32 0, i32 3
  %.157 = load ptr, ptr %.156, align 8
  %.158 = bitcast ptr %.157 to ptr
  call void @free(ptr %.158)
  %.160 = bitcast ptr %.33 to ptr
  call void @free(ptr %.160)
  %.162 = bitcast ptr @nl_str to ptr
  %.163 = call i32 (ptr, ...) @printf(ptr %.162)
  br label %end

print_first_blk:                                  ; preds = %print_dec_body
  %.141 = bitcast ptr @fmt_dec_first to ptr
  %.142 = call i32 (ptr, ...) @printf(ptr %.141, i64 %.138)
  br label %print_cont_blk

print_pad_blk:                                    ; preds = %print_dec_body
  %.144 = bitcast ptr @fmt_dec_pad to ptr
  %.145 = call i32 (ptr, ...) @printf(ptr %.144, i64 %.138)
  br label %print_cont_blk

print_cont_blk:                                   ; preds = %print_pad_blk, %print_first_blk
  %.147 = sub i64 %.132, 1
  store i64 %.147, ptr %.128, align 4
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
  %.13 = icmp eq i8 %.6, 7
  %.14 = icmp eq i8 %.6, 4
  %.15 = or i1 %.13, %.14
  br i1 %.15, label %free_array_data, label %check_bigint

free_array_data:                                  ; preds = %check_array
  %.31 = bitcast ptr %.1 to ptr
  %.32 = getelementptr i8, ptr %.31, i64 32
  %.33 = bitcast ptr %.32 to ptr
  %.34 = load ptr, ptr %.33, align 8
  %.35 = icmp eq ptr %.34, null
  br i1 %.35, label %exit, label %do_free

exit:                                             ; preds = %do_free, %free_digits, %free_bigint_data, %check_bigint, %class_destroy, %free_array_data, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr %meteor.header, ptr %.1, i32 0, i32 3
  %.6 = load i8, ptr %.5, align 1
  %.7 = icmp eq i8 %.6, 10
  br i1 %.7, label %class_destroy, label %check_array

class_destroy:                                    ; preds = %not_null
  %.9 = getelementptr %meteor.header, ptr %.1, i32 0, i32 5
  %.10 = load i32, ptr %.9, align 4
  call void @meteor_destroy_class_dispatch(ptr %.1, i32 %.10)
  br label %exit

check_bigint:                                     ; preds = %check_array
  %.17 = icmp eq i8 %.6, 5
  br i1 %.17, label %free_bigint_data, label %exit

free_bigint_data:                                 ; preds = %check_bigint
  %.19 = bitcast ptr %.1 to ptr
  %.20 = getelementptr %bigint, ptr %.19, i32 0, i32 2
  %.21 = load ptr, ptr %.20, align 8
  %.22 = icmp eq ptr %.21, null
  br i1 %.22, label %exit, label %free_digits

free_digits:                                      ; preds = %free_bigint_data
  %.24 = getelementptr %i64.array, ptr %.21, i32 0, i32 3
  %.25 = load ptr, ptr %.24, align 8
  %.26 = bitcast ptr %.25 to ptr
  call void @free(ptr %.26)
  %.28 = bitcast ptr %.21 to ptr
  call void @free(ptr %.28)
  br label %exit

do_free:                                          ; preds = %free_array_data
  call void @free(ptr %.34)
  br label %exit
}

define void @meteor_destroy_class_dispatch(ptr %.1, i32 %.2) {
entry:
  switch i32 %.2, label %default [
    i32 1, label %case_StringWrapper
  ]

default:                                          ; preds = %entry
  ret void

case_StringWrapper:                               ; preds = %entry
  %.6 = bitcast ptr %.1 to ptr
  %.7 = getelementptr i8, ptr %.6, i32 16
  %.8 = bitcast ptr %.7 to ptr
  %.9 = getelementptr %StringWrapper, ptr %.8, i64 0, i32 0
  %.10 = load ptr, ptr %.9, align 8
  %.11 = icmp eq ptr %.10, null
  br i1 %.11, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %case_StringWrapper
  %.13 = bitcast ptr %.10 to ptr
  call void @meteor_release(ptr %.13)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %case_StringWrapper
  ret void
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

define ptr @bigint_add(ptr %.1, ptr %.2) {
entry:
  %.4 = call ptr @malloc(i64 32)
  %.5 = bitcast ptr %.4 to ptr
  %.6 = getelementptr %bigint, ptr %.5, i32 0, i32 0
  %.7 = getelementptr %meteor.header, ptr %.6, i32 0, i32 0
  store i32 1, ptr %.7, align 4
  %.9 = getelementptr %meteor.header, ptr %.6, i32 0, i32 1
  store i32 0, ptr %.9, align 4
  %.11 = getelementptr %meteor.header, ptr %.6, i32 0, i32 2
  store i8 0, ptr %.11, align 1
  %.13 = getelementptr %meteor.header, ptr %.6, i32 0, i32 3
  store i8 5, ptr %.13, align 1
  %.15 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.16 = load ptr, ptr %.15, align 8
  %.17 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.18 = load ptr, ptr %.17, align 8
  %.19 = call ptr @malloc(i64 32)
  %.20 = bitcast ptr %.19 to ptr
  call void @i64.array.init(ptr %.20)
  %idx = alloca i64, align 8
  store i64 0, ptr %idx, align 4
  %carry = alloca i64, align 8
  store i64 0, ptr %carry, align 4
  %val_a = alloca i64, align 8
  %val_b = alloca i64, align 8
  %.24 = call i64 @i64.array.length(ptr %.16)
  %.25 = call i64 @i64.array.length(ptr %.18)
  br label %cond

cond:                                             ; preds = %body.endif.endif, %entry
  %.27 = load i64, ptr %idx, align 4
  %.28 = load i64, ptr %carry, align 4
  %.29 = icmp slt i64 %.27, %.24
  %.30 = icmp slt i64 %.27, %.25
  %.31 = icmp ne i64 %.28, 0
  %.32 = or i1 %.29, %.30
  %.33 = or i1 %.32, %.31
  br i1 %.33, label %body, label %end

body:                                             ; preds = %cond
  store i64 0, ptr %val_a, align 4
  br i1 %.29, label %body.if, label %body.endif

end:                                              ; preds = %cond
  %.59 = getelementptr %bigint, ptr %.5, i32 0, i32 2
  store ptr %.20, ptr %.59, align 8
  %.61 = getelementptr %bigint, ptr %.5, i32 0, i32 1
  store i1 false, ptr %.61, align 1
  ret ptr %.5

body.if:                                          ; preds = %body
  %.37 = call i64 @i64.array.get(ptr %.16, i64 %.27)
  store i64 %.37, ptr %val_a, align 4
  br label %body.endif

body.endif:                                       ; preds = %body.if, %body
  store i64 0, ptr %val_b, align 4
  br i1 %.30, label %body.endif.if, label %body.endif.endif

body.endif.if:                                    ; preds = %body.endif
  %.42 = call i64 @i64.array.get(ptr %.18, i64 %.27)
  store i64 %.42, ptr %val_b, align 4
  br label %body.endif.endif

body.endif.endif:                                 ; preds = %body.endif.if, %body.endif
  %.45 = load i64, ptr %val_a, align 4
  %.46 = load i64, ptr %val_b, align 4
  %.47 = load i64, ptr %carry, align 4
  %.48 = add i64 %.45, %.46
  %.49 = icmp ult i64 %.48, %.45
  %.50 = add i64 %.48, %.47
  %.51 = icmp ult i64 %.50, %.48
  %.52 = or i1 %.49, %.51
  %.53 = zext i1 %.52 to i64
  store i64 %.53, ptr %carry, align 4
  call void @i64.array.append(ptr %.20, i64 %.50)
  %.56 = add i64 %.27, 1
  store i64 %.56, ptr %idx, align 4
  br label %cond
}

define ptr @bigint_neg(ptr %.1) {
entry:
  %.3 = call ptr @malloc(i64 32)
  %.4 = bitcast ptr %.3 to ptr
  %.5 = getelementptr %bigint, ptr %.4, i32 0, i32 0
  %.6 = getelementptr %meteor.header, ptr %.5, i32 0, i32 0
  store i32 1, ptr %.6, align 4
  %.8 = getelementptr %meteor.header, ptr %.5, i32 0, i32 1
  store i32 0, ptr %.8, align 4
  %.10 = getelementptr %meteor.header, ptr %.5, i32 0, i32 2
  store i8 0, ptr %.10, align 1
  %.12 = getelementptr %meteor.header, ptr %.5, i32 0, i32 3
  store i8 5, ptr %.12, align 1
  %.14 = call ptr @malloc(i64 32)
  %.15 = bitcast ptr %.14 to ptr
  call void @i64.array.init(ptr %.15)
  %.17 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.18 = load i1, ptr %.17, align 1
  %.19 = xor i1 %.18, true
  %.20 = getelementptr %bigint, ptr %.4, i32 0, i32 1
  store i1 %.19, ptr %.20, align 1
  %.22 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.23 = load ptr, ptr %.22, align 8
  %.24 = call i64 @i64.array.length(ptr %.23)
  %.25 = alloca i64, align 8
  store i64 0, ptr %.25, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %.28 = load i64, ptr %.25, align 4
  %.29 = icmp slt i64 %.28, %.24
  br i1 %.29, label %body, label %end

body:                                             ; preds = %cond
  %.31 = call i64 @i64.array.get(ptr %.23, i64 %.28)
  call void @i64.array.append(ptr %.15, i64 %.31)
  %.33 = add i64 %.28, 1
  store i64 %.33, ptr %.25, align 4
  br label %cond

end:                                              ; preds = %cond
  %.36 = getelementptr %bigint, ptr %.4, i32 0, i32 2
  store ptr %.15, ptr %.36, align 8
  ret ptr %.4
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

define ptr @bigint_sub(ptr %.1, ptr %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.5 = load i1, ptr %.4, align 1
  %.6 = getelementptr %bigint, ptr %.2, i32 0, i32 1
  %.7 = load i1, ptr %.6, align 1
  %.8 = icmp ne i1 %.5, %.7
  br i1 %.8, label %signs_diff, label %signs_same

signs_diff:                                       ; preds = %entry
  %.10 = call ptr @bigint_add(ptr %.1, ptr %.2)
  %.11 = getelementptr %bigint, ptr %.10, i32 0, i32 1
  store i1 %.5, ptr %.11, align 1
  ret ptr %.10

signs_same:                                       ; preds = %entry
  %.14 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.15 = load ptr, ptr %.14, align 8
  %.16 = getelementptr %bigint, ptr %.2, i32 0, i32 2
  %.17 = load ptr, ptr %.16, align 8
  %.18 = call i64 @i64.array.length(ptr %.15)
  %.19 = call i64 @i64.array.length(ptr %.17)
  %.20 = alloca ptr, align 8
  %.21 = alloca ptr, align 8
  %.22 = alloca i1, align 1
  store ptr %.1, ptr %.20, align 8
  store ptr %.2, ptr %.21, align 8
  store i1 false, ptr %.22, align 1
  %.26 = icmp ne i64 %.18, %.19
  br i1 %.26, label %len_check, label %digits_check

len_check:                                        ; preds = %signs_same
  %.28 = icmp sgt i64 %.19, %.18
  store i1 %.28, ptr %.22, align 1
  br label %set_x_y

digits_check:                                     ; preds = %signs_same
  %.31 = alloca i64, align 8
  %.32 = sub i64 %.18, 1
  store i64 %.32, ptr %.31, align 4
  br label %d_loop_cond

set_x_y:                                          ; preds = %d_diff, %d_loop_end, %len_check
  %.49 = load i1, ptr %.22, align 1
  %.50 = select i1 %.49, ptr %.2, ptr %.1
  %.51 = select i1 %.49, ptr %.1, ptr %.2
  store ptr %.50, ptr %.20, align 8
  store ptr %.51, ptr %.21, align 8
  %.54 = load ptr, ptr %.20, align 8
  %.55 = load ptr, ptr %.21, align 8
  %.56 = getelementptr %bigint, ptr %.54, i32 0, i32 2
  %.57 = load ptr, ptr %.56, align 8
  %.58 = getelementptr %bigint, ptr %.55, i32 0, i32 2
  %.59 = load ptr, ptr %.58, align 8
  %.60 = call i64 @i64.array.length(ptr %.57)
  %.61 = call i64 @i64.array.length(ptr %.59)
  %.62 = call ptr @malloc(i64 32)
  %.63 = bitcast ptr %.62 to ptr
  %.64 = getelementptr %bigint, ptr %.63, i32 0, i32 0
  %.65 = getelementptr %meteor.header, ptr %.64, i32 0, i32 0
  store i32 1, ptr %.65, align 4
  %.67 = getelementptr %meteor.header, ptr %.64, i32 0, i32 1
  store i32 0, ptr %.67, align 4
  %.69 = getelementptr %meteor.header, ptr %.64, i32 0, i32 2
  store i8 0, ptr %.69, align 1
  %.71 = getelementptr %meteor.header, ptr %.64, i32 0, i32 3
  store i8 5, ptr %.71, align 1
  %.73 = call ptr @malloc(i64 32)
  %.74 = bitcast ptr %.73 to ptr
  call void @i64.array.init(ptr %.74)
  %.76 = alloca i64, align 8
  store i64 0, ptr %.76, align 4
  %.78 = alloca i64, align 8
  store i64 0, ptr %.78, align 4
  %.80 = alloca i64, align 8
  br label %sub_loop_cond

d_loop_cond:                                      ; preds = %d_next, %digits_check
  %.35 = load i64, ptr %.31, align 4
  %.36 = icmp sge i64 %.35, 0
  br i1 %.36, label %d_loop_body, label %d_loop_end

d_loop_body:                                      ; preds = %d_loop_cond
  %.38 = call i64 @i64.array.get(ptr %.15, i64 %.35)
  %.39 = call i64 @i64.array.get(ptr %.17, i64 %.35)
  %.40 = icmp ne i64 %.38, %.39
  br i1 %.40, label %d_diff, label %d_next

d_loop_end:                                       ; preds = %d_loop_cond
  br label %set_x_y

d_diff:                                           ; preds = %d_loop_body
  %.42 = icmp ugt i64 %.39, %.38
  store i1 %.42, ptr %.22, align 1
  br label %set_x_y

d_next:                                           ; preds = %d_loop_body
  %.45 = sub i64 %.35, 1
  store i64 %.45, ptr %.31, align 4
  br label %d_loop_cond

sub_loop_cond:                                    ; preds = %sub_loop_body.endif, %set_x_y
  %.82 = load i64, ptr %.76, align 4
  %.83 = icmp slt i64 %.82, %.60
  br i1 %.83, label %sub_loop_body, label %sub_loop_end

sub_loop_body:                                    ; preds = %sub_loop_cond
  %.85 = call i64 @i64.array.get(ptr %.57, i64 %.82)
  store i64 0, ptr %.80, align 4
  %.87 = icmp slt i64 %.82, %.61
  br i1 %.87, label %sub_loop_body.if, label %sub_loop_body.endif

sub_loop_end:                                     ; preds = %sub_loop_cond
  br label %trim_cond

sub_loop_body.if:                                 ; preds = %sub_loop_body
  %.89 = call i64 @i64.array.get(ptr %.59, i64 %.82)
  store i64 %.89, ptr %.80, align 4
  br label %sub_loop_body.endif

sub_loop_body.endif:                              ; preds = %sub_loop_body.if, %sub_loop_body
  %.92 = load i64, ptr %.80, align 4
  %.93 = load i64, ptr %.78, align 4
  %.94 = sub i64 %.85, %.92
  %.95 = icmp ult i64 %.85, %.92
  %.96 = sub i64 %.94, %.93
  %.97 = icmp ult i64 %.94, %.93
  %.98 = or i1 %.95, %.97
  %.99 = zext i1 %.98 to i64
  store i64 %.99, ptr %.78, align 4
  call void @i64.array.append(ptr %.74, i64 %.96)
  %.102 = add i64 %.82, 1
  store i64 %.102, ptr %.76, align 4
  br label %sub_loop_cond

trim_cond:                                        ; preds = %trim_body, %sub_loop_end
  %.106 = call i64 @i64.array.length(ptr %.74)
  %.107 = icmp sgt i64 %.106, 1
  br i1 %.107, label %check_zero, label %trim_end

trim_body:                                        ; preds = %check_zero
  %.113 = getelementptr %i64.array, ptr %.74, i32 0, i32 1
  %.114 = sub i64 %.106, 1
  store i64 %.114, ptr %.113, align 4
  br label %trim_cond

trim_end:                                         ; preds = %check_zero, %trim_cond
  %.117 = getelementptr %bigint, ptr %.63, i32 0, i32 2
  store ptr %.74, ptr %.117, align 8
  %.119 = getelementptr %bigint, ptr %.63, i32 0, i32 1
  %.120 = xor i1 %.5, true
  %.121 = select i1 %.49, i1 %.120, i1 %.5
  store i1 %.121, ptr %.119, align 1
  %.123 = call i64 @i64.array.length(ptr %.74)
  %.124 = icmp eq i64 %.123, 1
  %.125 = call i64 @i64.array.get(ptr %.74, i64 0)
  %.126 = icmp eq i64 %.125, 0
  %.127 = and i1 %.124, %.126
  br i1 %.127, label %trim_end.if, label %trim_end.endif

check_zero:                                       ; preds = %trim_cond
  %.109 = sub i64 %.106, 1
  %.110 = call i64 @i64.array.get(ptr %.74, i64 %.109)
  %.111 = icmp eq i64 %.110, 0
  br i1 %.111, label %trim_body, label %trim_end

trim_end.if:                                      ; preds = %trim_end
  store i1 false, ptr %.119, align 1
  br label %trim_end.endif

trim_end.endif:                                   ; preds = %trim_end.if, %trim_end
  ret ptr %.63
}

define ptr @bigint_mul_naive(ptr %.1, ptr %.2) {
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
  %.15 = call ptr @malloc(i64 32)
  %.16 = bitcast ptr %.15 to ptr
  %.17 = getelementptr %bigint, ptr %.16, i32 0, i32 0
  %.18 = getelementptr %meteor.header, ptr %.17, i32 0, i32 0
  store i32 1, ptr %.18, align 4
  %.20 = getelementptr %meteor.header, ptr %.17, i32 0, i32 1
  store i32 0, ptr %.20, align 4
  %.22 = getelementptr %meteor.header, ptr %.17, i32 0, i32 2
  store i8 0, ptr %.22, align 1
  %.24 = getelementptr %meteor.header, ptr %.17, i32 0, i32 3
  store i8 5, ptr %.24, align 1
  %.26 = call ptr @malloc(i64 32)
  %.27 = bitcast ptr %.26 to ptr
  call void @i64.array.init(ptr %.27)
  %.29 = add i64 %.13, %.14
  %.30 = alloca i64, align 8
  store i64 0, ptr %.30, align 4
  br label %fill_cond

fill_cond:                                        ; preds = %fill_body, %entry
  %.33 = load i64, ptr %.30, align 4
  %.34 = icmp slt i64 %.33, %.29
  br i1 %.34, label %fill_body, label %fill_end

fill_body:                                        ; preds = %fill_cond
  call void @i64.array.append(ptr %.27, i64 0)
  %.37 = add i64 %.33, 1
  store i64 %.37, ptr %.30, align 4
  br label %fill_cond

fill_end:                                         ; preds = %fill_cond
  %.40 = alloca i64, align 8
  store i64 0, ptr %.40, align 4
  %.42 = alloca i128, align 8
  %.43 = alloca i64, align 8
  br label %outer_cond

outer_cond:                                       ; preds = %inner_end, %fill_end
  %.45 = load i64, ptr %.40, align 4
  %.46 = icmp slt i64 %.45, %.13
  br i1 %.46, label %outer_body, label %outer_end

outer_body:                                       ; preds = %outer_cond
  %.48 = call i64 @i64.array.get(ptr %.10, i64 %.45)
  %.49 = zext i64 %.48 to i128
  store i128 0, ptr %.42, align 4
  store i64 0, ptr %.43, align 4
  br label %inner_cond

outer_end:                                        ; preds = %outer_cond
  br label %trim_cond

inner_cond:                                       ; preds = %inner_body, %outer_body
  %.53 = load i64, ptr %.43, align 4
  %.54 = icmp slt i64 %.53, %.14
  br i1 %.54, label %inner_body, label %inner_end

inner_body:                                       ; preds = %inner_cond
  %.56 = call i64 @i64.array.get(ptr %.12, i64 %.53)
  %.57 = zext i64 %.56 to i128
  %.58 = add i64 %.45, %.53
  %.59 = call i64 @i64.array.get(ptr %.27, i64 %.58)
  %.60 = zext i64 %.59 to i128
  %.61 = mul i128 %.49, %.57
  %.62 = load i128, ptr %.42, align 4
  %.63 = add i128 %.61, %.60
  %.64 = add i128 %.63, %.62
  %.65 = trunc i128 %.64 to i64
  call void @i64.array.set(ptr %.27, i64 %.58, i64 %.65)
  %.67 = lshr i128 %.64, 64
  store i128 %.67, ptr %.42, align 4
  %.69 = add i64 %.53, 1
  store i64 %.69, ptr %.43, align 4
  br label %inner_cond

inner_end:                                        ; preds = %inner_cond
  %.72 = load i128, ptr %.42, align 4
  %.73 = trunc i128 %.72 to i64
  %.74 = add i64 %.45, %.14
  call void @i64.array.set(ptr %.27, i64 %.74, i64 %.73)
  %.76 = add i64 %.45, 1
  store i64 %.76, ptr %.40, align 4
  br label %outer_cond

trim_cond:                                        ; preds = %trim_body, %outer_end
  %.80 = call i64 @i64.array.length(ptr %.27)
  %.81 = icmp sgt i64 %.80, 1
  br i1 %.81, label %check_zero, label %trim_end

trim_body:                                        ; preds = %check_zero
  %.87 = getelementptr %i64.array, ptr %.27, i32 0, i32 1
  %.88 = sub i64 %.80, 1
  store i64 %.88, ptr %.87, align 4
  br label %trim_cond

trim_end:                                         ; preds = %check_zero, %trim_cond
  %.91 = getelementptr %bigint, ptr %.16, i32 0, i32 2
  store ptr %.27, ptr %.91, align 8
  %.93 = getelementptr %bigint, ptr %.16, i32 0, i32 1
  store i1 %.8, ptr %.93, align 1
  %.95 = call i64 @i64.array.length(ptr %.27)
  %.96 = icmp eq i64 %.95, 1
  %.97 = call i64 @i64.array.get(ptr %.27, i64 0)
  %.98 = icmp eq i64 %.97, 0
  %.99 = and i1 %.96, %.98
  br i1 %.99, label %trim_end.if, label %trim_end.endif

check_zero:                                       ; preds = %trim_cond
  %.83 = sub i64 %.80, 1
  %.84 = call i64 @i64.array.get(ptr %.27, i64 %.83)
  %.85 = icmp eq i64 %.84, 0
  br i1 %.85, label %trim_body, label %trim_end

trim_end.if:                                      ; preds = %trim_end
  store i1 false, ptr %.93, align 1
  br label %trim_end.endif

trim_end.endif:                                   ; preds = %trim_end.if, %trim_end
  ret ptr %.16
}

define ptr @bigint_split_low(ptr %.1, i64 %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = call ptr @malloc(i64 32)
  %.8 = bitcast ptr %.7 to ptr
  %.9 = getelementptr %bigint, ptr %.8, i32 0, i32 0
  %.10 = getelementptr %meteor.header, ptr %.9, i32 0, i32 0
  store i32 1, ptr %.10, align 4
  %.12 = getelementptr %meteor.header, ptr %.9, i32 0, i32 1
  store i32 0, ptr %.12, align 4
  %.14 = getelementptr %meteor.header, ptr %.9, i32 0, i32 2
  store i8 0, ptr %.14, align 1
  %.16 = getelementptr %meteor.header, ptr %.9, i32 0, i32 3
  store i8 5, ptr %.16, align 1
  %.18 = call ptr @malloc(i64 32)
  %.19 = bitcast ptr %.18 to ptr
  call void @i64.array.init(ptr %.19)
  %.21 = icmp slt i64 %.2, %.6
  %.22 = select i1 %.21, i64 %.2, i64 %.6
  %.23 = alloca i64, align 8
  store i64 0, ptr %.23, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %.26 = load i64, ptr %.23, align 4
  %.27 = icmp slt i64 %.26, %.22
  br i1 %.27, label %body, label %end

body:                                             ; preds = %cond
  %.29 = call i64 @i64.array.get(ptr %.5, i64 %.26)
  call void @i64.array.append(ptr %.19, i64 %.29)
  %.31 = add i64 %.26, 1
  store i64 %.31, ptr %.23, align 4
  br label %cond

end:                                              ; preds = %cond
  %.34 = call i64 @i64.array.length(ptr %.19)
  %.35 = icmp eq i64 %.34, 0
  br i1 %.35, label %end.if, label %end.endif

end.if:                                           ; preds = %end
  call void @i64.array.append(ptr %.19, i64 0)
  br label %end.endif

end.endif:                                        ; preds = %end.if, %end
  %.39 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.40 = load i1, ptr %.39, align 1
  %.41 = getelementptr %bigint, ptr %.8, i32 0, i32 1
  store i1 %.40, ptr %.41, align 1
  %.43 = getelementptr %bigint, ptr %.8, i32 0, i32 2
  store ptr %.19, ptr %.43, align 8
  ret ptr %.8
}

define ptr @bigint_split_high(ptr %.1, i64 %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = call ptr @malloc(i64 32)
  %.8 = bitcast ptr %.7 to ptr
  %.9 = getelementptr %bigint, ptr %.8, i32 0, i32 0
  %.10 = getelementptr %meteor.header, ptr %.9, i32 0, i32 0
  store i32 1, ptr %.10, align 4
  %.12 = getelementptr %meteor.header, ptr %.9, i32 0, i32 1
  store i32 0, ptr %.12, align 4
  %.14 = getelementptr %meteor.header, ptr %.9, i32 0, i32 2
  store i8 0, ptr %.14, align 1
  %.16 = getelementptr %meteor.header, ptr %.9, i32 0, i32 3
  store i8 5, ptr %.16, align 1
  %.18 = call ptr @malloc(i64 32)
  %.19 = bitcast ptr %.18 to ptr
  call void @i64.array.init(ptr %.19)
  %.21 = alloca i64, align 8
  store i64 %.2, ptr %.21, align 4
  br label %cond

cond:                                             ; preds = %body, %entry
  %.24 = load i64, ptr %.21, align 4
  %.25 = icmp slt i64 %.24, %.6
  br i1 %.25, label %body, label %end

body:                                             ; preds = %cond
  %.27 = call i64 @i64.array.get(ptr %.5, i64 %.24)
  call void @i64.array.append(ptr %.19, i64 %.27)
  %.29 = add i64 %.24, 1
  store i64 %.29, ptr %.21, align 4
  br label %cond

end:                                              ; preds = %cond
  %.32 = call i64 @i64.array.length(ptr %.19)
  %.33 = icmp eq i64 %.32, 0
  br i1 %.33, label %end.if, label %end.endif

end.if:                                           ; preds = %end
  call void @i64.array.append(ptr %.19, i64 0)
  br label %end.endif

end.endif:                                        ; preds = %end.if, %end
  %.37 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.38 = load i1, ptr %.37, align 1
  %.39 = getelementptr %bigint, ptr %.8, i32 0, i32 1
  store i1 %.38, ptr %.39, align 1
  %.41 = getelementptr %bigint, ptr %.8, i32 0, i32 2
  store ptr %.19, ptr %.41, align 8
  ret ptr %.8
}

define ptr @bigint_shift_left(ptr %.1, i64 %.2) {
entry:
  %.4 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.5 = load ptr, ptr %.4, align 8
  %.6 = call i64 @i64.array.length(ptr %.5)
  %.7 = call ptr @malloc(i64 32)
  %.8 = bitcast ptr %.7 to ptr
  %.9 = getelementptr %bigint, ptr %.8, i32 0, i32 0
  %.10 = getelementptr %meteor.header, ptr %.9, i32 0, i32 0
  store i32 1, ptr %.10, align 4
  %.12 = getelementptr %meteor.header, ptr %.9, i32 0, i32 1
  store i32 0, ptr %.12, align 4
  %.14 = getelementptr %meteor.header, ptr %.9, i32 0, i32 2
  store i8 0, ptr %.14, align 1
  %.16 = getelementptr %meteor.header, ptr %.9, i32 0, i32 3
  store i8 5, ptr %.16, align 1
  %.18 = call ptr @malloc(i64 32)
  %.19 = bitcast ptr %.18 to ptr
  call void @i64.array.init(ptr %.19)
  %.21 = alloca i64, align 8
  store i64 0, ptr %.21, align 4
  br label %zero_cond

zero_cond:                                        ; preds = %zero_body, %entry
  %.24 = load i64, ptr %.21, align 4
  %.25 = icmp slt i64 %.24, %.2
  br i1 %.25, label %zero_body, label %zero_end

zero_body:                                        ; preds = %zero_cond
  call void @i64.array.append(ptr %.19, i64 0)
  %.28 = add i64 %.24, 1
  store i64 %.28, ptr %.21, align 4
  br label %zero_cond

zero_end:                                         ; preds = %zero_cond
  %.31 = alloca i64, align 8
  store i64 0, ptr %.31, align 4
  br label %copy_cond

copy_cond:                                        ; preds = %copy_body, %zero_end
  %.34 = load i64, ptr %.31, align 4
  %.35 = icmp slt i64 %.34, %.6
  br i1 %.35, label %copy_body, label %copy_end

copy_body:                                        ; preds = %copy_cond
  %.37 = call i64 @i64.array.get(ptr %.5, i64 %.34)
  call void @i64.array.append(ptr %.19, i64 %.37)
  %.39 = add i64 %.34, 1
  store i64 %.39, ptr %.31, align 4
  br label %copy_cond

copy_end:                                         ; preds = %copy_cond
  %.42 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.43 = load i1, ptr %.42, align 1
  %.44 = getelementptr %bigint, ptr %.8, i32 0, i32 1
  store i1 %.43, ptr %.44, align 1
  %.46 = getelementptr %bigint, ptr %.8, i32 0, i32 2
  store ptr %.19, ptr %.46, align 8
  ret ptr %.8
}

define ptr @bigint_mul(ptr %.1, ptr %.2) {
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
  %.14 = call ptr @bigint_mul_naive(ptr %.1, ptr %.2)
  ret ptr %.14

karatsuba:                                        ; preds = %entry
  %.16 = icmp sgt i64 %.8, %.9
  %.17 = select i1 %.16, i64 %.8, i64 %.9
  %.18 = sdiv i64 %.17, 2
  %.19 = alloca ptr, align 8
  %.20 = alloca ptr, align 8
  %.21 = alloca ptr, align 8
  %.22 = alloca ptr, align 8
  %.23 = call ptr @bigint_split_low(ptr %.1, i64 %.18)
  store ptr %.23, ptr %.19, align 8
  %.25 = call ptr @bigint_split_high(ptr %.1, i64 %.18)
  store ptr %.25, ptr %.20, align 8
  %.27 = call ptr @bigint_split_low(ptr %.2, i64 %.18)
  store ptr %.27, ptr %.21, align 8
  %.29 = call ptr @bigint_split_high(ptr %.2, i64 %.18)
  store ptr %.29, ptr %.22, align 8
  %.31 = alloca ptr, align 8
  %.32 = alloca ptr, align 8
  %.33 = load ptr, ptr %.19, align 8
  %.34 = load ptr, ptr %.20, align 8
  %.35 = load ptr, ptr %.21, align 8
  %.36 = load ptr, ptr %.22, align 8
  %.37 = call ptr @bigint_mul(ptr %.33, ptr %.35)
  store ptr %.37, ptr %.31, align 8
  %.39 = call ptr @bigint_mul(ptr %.34, ptr %.36)
  store ptr %.39, ptr %.32, align 8
  %.41 = alloca ptr, align 8
  %.42 = call ptr @bigint_add(ptr %.33, ptr %.34)
  store ptr %.42, ptr %.41, align 8
  %.44 = alloca ptr, align 8
  %.45 = call ptr @bigint_add(ptr %.35, ptr %.36)
  store ptr %.45, ptr %.44, align 8
  %.47 = load ptr, ptr %.41, align 8
  %.48 = load ptr, ptr %.44, align 8
  %.49 = alloca ptr, align 8
  %.50 = call ptr @bigint_mul(ptr %.47, ptr %.48)
  store ptr %.50, ptr %.49, align 8
  %.52 = load ptr, ptr %.31, align 8
  %.53 = alloca ptr, align 8
  %.54 = load ptr, ptr %.49, align 8
  %.55 = call ptr @bigint_sub(ptr %.54, ptr %.52)
  store ptr %.55, ptr %.53, align 8
  %.57 = load ptr, ptr %.32, align 8
  %.58 = alloca ptr, align 8
  %.59 = load ptr, ptr %.53, align 8
  %.60 = call ptr @bigint_sub(ptr %.59, ptr %.57)
  store ptr %.60, ptr %.58, align 8
  %.62 = mul i64 %.18, 2
  %.63 = alloca ptr, align 8
  %.64 = call ptr @bigint_shift_left(ptr %.57, i64 %.62)
  store ptr %.64, ptr %.63, align 8
  %.66 = load ptr, ptr %.58, align 8
  %.67 = alloca ptr, align 8
  %.68 = call ptr @bigint_shift_left(ptr %.66, i64 %.18)
  store ptr %.68, ptr %.67, align 8
  %.70 = load ptr, ptr %.63, align 8
  %.71 = load ptr, ptr %.67, align 8
  %.72 = alloca ptr, align 8
  %.73 = call ptr @bigint_add(ptr %.70, ptr %.71)
  store ptr %.73, ptr %.72, align 8
  %.75 = load ptr, ptr %.72, align 8
  %.76 = call ptr @bigint_add(ptr %.75, ptr %.52)
  %.77 = load ptr, ptr %.31, align 8
  %.78 = bitcast ptr %.77 to ptr
  call void @meteor_release(ptr %.78)
  %.80 = load ptr, ptr %.32, align 8
  %.81 = bitcast ptr %.80 to ptr
  call void @meteor_release(ptr %.81)
  %.83 = load ptr, ptr %.41, align 8
  %.84 = bitcast ptr %.83 to ptr
  call void @meteor_release(ptr %.84)
  %.86 = load ptr, ptr %.44, align 8
  %.87 = bitcast ptr %.86 to ptr
  call void @meteor_release(ptr %.87)
  %.89 = load ptr, ptr %.49, align 8
  %.90 = bitcast ptr %.89 to ptr
  call void @meteor_release(ptr %.90)
  %.92 = load ptr, ptr %.53, align 8
  %.93 = bitcast ptr %.92 to ptr
  call void @meteor_release(ptr %.93)
  %.95 = load ptr, ptr %.58, align 8
  %.96 = bitcast ptr %.95 to ptr
  call void @meteor_release(ptr %.96)
  %.98 = load ptr, ptr %.72, align 8
  %.99 = bitcast ptr %.98 to ptr
  call void @meteor_release(ptr %.99)
  %.101 = load ptr, ptr %.19, align 8
  %.102 = bitcast ptr %.101 to ptr
  call void @meteor_release(ptr %.102)
  %.104 = load ptr, ptr %.20, align 8
  %.105 = bitcast ptr %.104 to ptr
  call void @meteor_release(ptr %.105)
  %.107 = load ptr, ptr %.21, align 8
  %.108 = bitcast ptr %.107 to ptr
  call void @meteor_release(ptr %.108)
  %.110 = load ptr, ptr %.22, align 8
  %.111 = bitcast ptr %.110 to ptr
  call void @meteor_release(ptr %.111)
  %.113 = load ptr, ptr %.63, align 8
  %.114 = bitcast ptr %.113 to ptr
  call void @meteor_release(ptr %.114)
  %.116 = load ptr, ptr %.67, align 8
  %.117 = bitcast ptr %.116 to ptr
  call void @meteor_release(ptr %.117)
  ret ptr %.76
}

define ptr @bigint_div(ptr %.1, ptr %.2) {
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
  %.17 = call i32 @fflush(ptr null)
  call void @exit(i32 1)
  unreachable

start_div:                                        ; preds = %entry
  %.20 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.21 = load i1, ptr %.20, align 1
  %.22 = getelementptr %bigint, ptr %.2, i32 0, i32 1
  %.23 = load i1, ptr %.22, align 1
  %.24 = xor i1 %.21, %.23
  %.25 = alloca %bigint, align 8
  %.26 = getelementptr %bigint, ptr %.25, i32 0, i32 1
  store i1 false, ptr %.26, align 1
  %.28 = getelementptr %bigint, ptr %.25, i32 0, i32 2
  store ptr %.5, ptr %.28, align 8
  %.30 = alloca %bigint, align 8
  %.31 = getelementptr %bigint, ptr %.30, i32 0, i32 1
  store i1 false, ptr %.31, align 1
  %.33 = getelementptr %bigint, ptr %.30, i32 0, i32 2
  %.34 = call ptr @malloc(i64 32)
  %.35 = bitcast ptr %.34 to ptr
  call void @i64.array.init(ptr %.35)
  call void @i64.array.append(ptr %.35, i64 0)
  store ptr %.35, ptr %.33, align 8
  %.39 = call ptr @malloc(i64 32)
  %.40 = bitcast ptr %.39 to ptr
  %.41 = getelementptr %bigint, ptr %.40, i32 0, i32 0
  %.42 = getelementptr %meteor.header, ptr %.41, i32 0, i32 0
  store i32 1, ptr %.42, align 4
  %.44 = getelementptr %meteor.header, ptr %.41, i32 0, i32 1
  store i32 0, ptr %.44, align 4
  %.46 = getelementptr %meteor.header, ptr %.41, i32 0, i32 2
  store i8 0, ptr %.46, align 1
  %.48 = getelementptr %meteor.header, ptr %.41, i32 0, i32 3
  store i8 5, ptr %.48, align 1
  %.50 = call ptr @malloc(i64 32)
  %.51 = bitcast ptr %.50 to ptr
  call void @i64.array.init(ptr %.51)
  %.53 = getelementptr %bigint, ptr %.40, i32 0, i32 2
  store ptr %.51, ptr %.53, align 8
  %.55 = getelementptr %bigint, ptr %.40, i32 0, i32 1
  store i1 false, ptr %.55, align 1
  %.57 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.58 = load ptr, ptr %.57, align 8
  %.59 = call i64 @i64.array.length(ptr %.58)
  %.60 = alloca i64, align 8
  store i64 0, ptr %.60, align 4
  br label %fill_q_cond

fill_q_cond:                                      ; preds = %fill_q_body, %start_div
  %.63 = load i64, ptr %.60, align 4
  %.64 = icmp slt i64 %.63, %.59
  br i1 %.64, label %fill_q_body, label %fill_q_end

fill_q_body:                                      ; preds = %fill_q_cond
  call void @i64.array.append(ptr %.51, i64 0)
  %.67 = add i64 %.63, 1
  store i64 %.67, ptr %.60, align 4
  br label %fill_q_cond

fill_q_end:                                       ; preds = %fill_q_cond
  %.70 = alloca i64, align 8
  %.71 = alloca i64, align 8
  %.72 = alloca i64, align 8
  %.73 = mul i64 %.59, 64
  %.74 = sub i64 %.73, 1
  store i64 %.74, ptr %.70, align 4
  br label %loop_div_cond

loop_div_cond:                                    ; preds = %next_iter, %fill_q_end
  %.77 = load i64, ptr %.70, align 4
  %.78 = icmp sge i64 %.77, 0
  br i1 %.78, label %loop_div_body, label %loop_div_end

loop_div_body:                                    ; preds = %loop_div_cond
  %.80 = sdiv i64 %.77, 64
  %.81 = srem i64 %.77, 64
  %.82 = call i64 @i64.array.get(ptr %.58, i64 %.80)
  %.83 = lshr i64 %.82, %.81
  %.84 = and i64 %.83, 1
  %.85 = load ptr, ptr %.33, align 8
  %.86 = call i64 @i64.array.length(ptr %.85)
  store i64 %.84, ptr %.71, align 4
  store i64 0, ptr %.72, align 4
  br label %shift_loop_cond

loop_div_end:                                     ; preds = %loop_div_cond
  br label %div_trim_cond

shift_loop_cond:                                  ; preds = %shift_loop_body, %loop_div_body
  %.90 = load i64, ptr %.72, align 4
  %.91 = icmp slt i64 %.90, %.86
  br i1 %.91, label %shift_loop_body, label %shift_loop_end

shift_loop_body:                                  ; preds = %shift_loop_cond
  %.93 = call i64 @i64.array.get(ptr %.85, i64 %.90)
  %.94 = load i64, ptr %.71, align 4
  %.95 = shl i64 %.93, 1
  %.96 = or i64 %.95, %.94
  %.97 = lshr i64 %.93, 63
  call void @i64.array.set(ptr %.85, i64 %.90, i64 %.96)
  store i64 %.97, ptr %.71, align 4
  %.100 = add i64 %.90, 1
  store i64 %.100, ptr %.72, align 4
  br label %shift_loop_cond

shift_loop_end:                                   ; preds = %shift_loop_cond
  %.103 = load i64, ptr %.71, align 4
  %.104 = icmp ne i64 %.103, 0
  br i1 %.104, label %shift_loop_end.if, label %shift_loop_end.endif

shift_loop_end.if:                                ; preds = %shift_loop_end
  call void @i64.array.append(ptr %.85, i64 %.103)
  br label %shift_loop_end.endif

shift_loop_end.endif:                             ; preds = %shift_loop_end.if, %shift_loop_end
  %.108 = call i32 @bigint_cmp(ptr %.30, ptr %.25)
  %.109 = icmp sge i32 %.108, 0
  br i1 %.109, label %sub_block, label %next_iter

sub_block:                                        ; preds = %shift_loop_end.endif
  %.111 = call ptr @bigint_sub(ptr %.30, ptr %.25)
  %.112 = getelementptr %bigint, ptr %.111, i32 0, i32 2
  %.113 = load ptr, ptr %.112, align 8
  %.114 = getelementptr %bigint, ptr %.111, i32 0, i32 1
  %.115 = load i1, ptr %.114, align 1
  call void @free_bigint(ptr %.30)
  store ptr %.113, ptr %.33, align 8
  store i1 %.115, ptr %.31, align 1
  %.119 = call i64 @i64.array.get(ptr %.51, i64 %.80)
  %.120 = shl i64 1, %.81
  %.121 = or i64 %.119, %.120
  call void @i64.array.set(ptr %.51, i64 %.80, i64 %.121)
  br label %next_iter

next_iter:                                        ; preds = %sub_block, %shift_loop_end.endif
  %.124 = sub i64 %.77, 1
  store i64 %.124, ptr %.70, align 4
  br label %loop_div_cond

div_trim_cond:                                    ; preds = %div_trim_body, %loop_div_end
  %.128 = call i64 @i64.array.length(ptr %.51)
  %.129 = icmp sgt i64 %.128, 1
  br i1 %.129, label %div_check_zero, label %div_trim_end

div_trim_body:                                    ; preds = %div_check_zero
  %.135 = getelementptr %i64.array, ptr %.51, i32 0, i32 1
  %.136 = sub i64 %.128, 1
  store i64 %.136, ptr %.135, align 4
  br label %div_trim_cond

div_trim_end:                                     ; preds = %div_check_zero, %div_trim_cond
  store i1 %.24, ptr %.55, align 1
  %.140 = call i64 @i64.array.length(ptr %.51)
  %.141 = icmp eq i64 %.140, 1
  %.142 = call i64 @i64.array.get(ptr %.51, i64 0)
  %.143 = icmp eq i64 %.142, 0
  %.144 = and i1 %.141, %.143
  br i1 %.144, label %div_trim_end.if, label %div_trim_end.endif

div_check_zero:                                   ; preds = %div_trim_cond
  %.131 = sub i64 %.128, 1
  %.132 = call i64 @i64.array.get(ptr %.51, i64 %.131)
  %.133 = icmp eq i64 %.132, 0
  br i1 %.133, label %div_trim_body, label %div_trim_end

div_trim_end.if:                                  ; preds = %div_trim_end
  store i1 false, ptr %.55, align 1
  br label %div_trim_end.endif

div_trim_end.endif:                               ; preds = %div_trim_end.if, %div_trim_end
  call void @free_bigint(ptr %.30)
  ret ptr %.40
}

define ptr @bigint_mod(ptr %.1, ptr %.2) {
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
  %.17 = call i32 @fflush(ptr null)
  call void @exit(i32 1)
  unreachable

start_div:                                        ; preds = %entry
  %.20 = getelementptr %bigint, ptr %.1, i32 0, i32 1
  %.21 = load i1, ptr %.20, align 1
  %.22 = alloca %bigint, align 8
  %.23 = getelementptr %bigint, ptr %.22, i32 0, i32 1
  store i1 false, ptr %.23, align 1
  %.25 = getelementptr %bigint, ptr %.22, i32 0, i32 2
  store ptr %.5, ptr %.25, align 8
  %.27 = call ptr @malloc(i64 32)
  %.28 = bitcast ptr %.27 to ptr
  %.29 = getelementptr %bigint, ptr %.28, i32 0, i32 0
  %.30 = getelementptr %meteor.header, ptr %.29, i32 0, i32 0
  store i32 1, ptr %.30, align 4
  %.32 = getelementptr %meteor.header, ptr %.29, i32 0, i32 1
  store i32 0, ptr %.32, align 4
  %.34 = getelementptr %meteor.header, ptr %.29, i32 0, i32 2
  store i8 0, ptr %.34, align 1
  %.36 = getelementptr %meteor.header, ptr %.29, i32 0, i32 3
  store i8 5, ptr %.36, align 1
  %.38 = getelementptr %bigint, ptr %.28, i32 0, i32 1
  store i1 false, ptr %.38, align 1
  %.40 = getelementptr %bigint, ptr %.28, i32 0, i32 2
  %.41 = call ptr @malloc(i64 32)
  %.42 = bitcast ptr %.41 to ptr
  call void @i64.array.init(ptr %.42)
  call void @i64.array.append(ptr %.42, i64 0)
  store ptr %.42, ptr %.40, align 8
  %.46 = getelementptr %bigint, ptr %.1, i32 0, i32 2
  %.47 = load ptr, ptr %.46, align 8
  %.48 = call i64 @i64.array.length(ptr %.47)
  %.49 = alloca i64, align 8
  %.50 = alloca i64, align 8
  %.51 = alloca i64, align 8
  %.52 = mul i64 %.48, 64
  %.53 = sub i64 %.52, 1
  store i64 %.53, ptr %.49, align 4
  br label %loop_mod_cond

loop_mod_cond:                                    ; preds = %next_iter, %start_div
  %.56 = load i64, ptr %.49, align 4
  %.57 = icmp sge i64 %.56, 0
  br i1 %.57, label %loop_mod_body, label %loop_mod_end

loop_mod_body:                                    ; preds = %loop_mod_cond
  %.59 = sdiv i64 %.56, 64
  %.60 = srem i64 %.56, 64
  %.61 = call i64 @i64.array.get(ptr %.47, i64 %.59)
  %.62 = lshr i64 %.61, %.60
  %.63 = and i64 %.62, 1
  %.64 = load ptr, ptr %.40, align 8
  %.65 = call i64 @i64.array.length(ptr %.64)
  store i64 %.63, ptr %.50, align 4
  store i64 0, ptr %.51, align 4
  br label %shift_loop_cond

loop_mod_end:                                     ; preds = %loop_mod_cond
  %.102 = load ptr, ptr %.40, align 8
  store i1 %.21, ptr %.38, align 1
  %.104 = call i64 @i64.array.length(ptr %.102)
  %.105 = icmp eq i64 %.104, 1
  %.106 = call i64 @i64.array.get(ptr %.102, i64 0)
  %.107 = icmp eq i64 %.106, 0
  %.108 = and i1 %.105, %.107
  br i1 %.108, label %loop_mod_end.if, label %loop_mod_end.endif

shift_loop_cond:                                  ; preds = %shift_loop_body, %loop_mod_body
  %.69 = load i64, ptr %.51, align 4
  %.70 = icmp slt i64 %.69, %.65
  br i1 %.70, label %shift_loop_body, label %shift_loop_end

shift_loop_body:                                  ; preds = %shift_loop_cond
  %.72 = call i64 @i64.array.get(ptr %.64, i64 %.69)
  %.73 = load i64, ptr %.50, align 4
  %.74 = shl i64 %.72, 1
  %.75 = or i64 %.74, %.73
  %.76 = lshr i64 %.72, 63
  call void @i64.array.set(ptr %.64, i64 %.69, i64 %.75)
  store i64 %.76, ptr %.50, align 4
  %.79 = add i64 %.69, 1
  store i64 %.79, ptr %.51, align 4
  br label %shift_loop_cond

shift_loop_end:                                   ; preds = %shift_loop_cond
  %.82 = load i64, ptr %.50, align 4
  %.83 = icmp ne i64 %.82, 0
  br i1 %.83, label %shift_loop_end.if, label %shift_loop_end.endif

shift_loop_end.if:                                ; preds = %shift_loop_end
  call void @i64.array.append(ptr %.64, i64 %.82)
  br label %shift_loop_end.endif

shift_loop_end.endif:                             ; preds = %shift_loop_end.if, %shift_loop_end
  %.87 = call i32 @bigint_cmp(ptr %.28, ptr %.22)
  %.88 = icmp sge i32 %.87, 0
  br i1 %.88, label %sub_block, label %next_iter

sub_block:                                        ; preds = %shift_loop_end.endif
  %.90 = call ptr @bigint_sub(ptr %.28, ptr %.22)
  %.91 = getelementptr %bigint, ptr %.90, i32 0, i32 2
  %.92 = load ptr, ptr %.91, align 8
  %.93 = getelementptr %bigint, ptr %.90, i32 0, i32 1
  %.94 = load i1, ptr %.93, align 1
  call void @free_bigint(ptr %.28)
  store ptr %.92, ptr %.40, align 8
  store i1 %.94, ptr %.38, align 1
  br label %next_iter

next_iter:                                        ; preds = %sub_block, %shift_loop_end.endif
  %.99 = sub i64 %.56, 1
  store i64 %.99, ptr %.49, align 4
  br label %loop_mod_cond

loop_mod_end.if:                                  ; preds = %loop_mod_end
  store i1 false, ptr %.38, align 1
  br label %loop_mod_end.endif

loop_mod_end.endif:                               ; preds = %loop_mod_end.if, %loop_mod_end
  ret ptr %.28
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
  %.91 = load ptr, ptr %.14, align 8
  %.92 = load ptr, ptr %.15, align 8
  %.93 = load i64, ptr %.16, align 4
  %.94 = call ptr @bigint_add(ptr %.91, ptr %.92)
  %.95 = alloca %decimal, align 8
  %.96 = getelementptr %decimal, ptr %.95, i32 0, i32 1
  store ptr %.94, ptr %.96, align 8
  %.98 = getelementptr %decimal, ptr %.95, i32 0, i32 2
  store i64 %.93, ptr %.98, align 4
  %.100 = load %decimal, ptr %.95, align 8
  ret %decimal %.100

loop_cond_b:                                      ; preds = %loop_body_b.endif, %adjust_b
  %.37 = load i64, ptr %.34, align 4
  %.38 = icmp slt i64 %.37, %.21
  br i1 %.38, label %loop_body_b, label %loop_end_b

loop_body_b:                                      ; preds = %loop_cond_b
  %.40 = load ptr, ptr %.32, align 8
  %.41 = call ptr @bigint_mul(ptr %.40, ptr %.23)
  %.42 = icmp eq ptr %.40, %.9
  %.43 = xor i1 %.42, true
  br i1 %.43, label %loop_body_b.if, label %loop_body_b.endif

loop_end_b:                                       ; preds = %loop_cond_b
  %.52 = load ptr, ptr %.32, align 8
  store ptr %.52, ptr %.15, align 8
  br label %do_add

loop_body_b.if:                                   ; preds = %loop_body_b
  %.45 = bitcast ptr %.40 to ptr
  call void @meteor_release(ptr %.45)
  br label %loop_body_b.endif

loop_body_b.endif:                                ; preds = %loop_body_b.if, %loop_body_b
  store ptr %.41, ptr %.32, align 8
  %.49 = add i64 %.37, 1
  store i64 %.49, ptr %.34, align 4
  br label %loop_cond_b

need_adjust_a:                                    ; preds = %adjust_a
  %.56 = sub i64 %.7, %.11
  store i64 %.11, ptr %.16, align 4
  %.58 = alloca %bigint, align 8
  %.59 = call ptr @malloc(i64 32)
  %.60 = bitcast ptr %.59 to ptr
  call void @i64.array.init(ptr %.60)
  call void @i64.array.append(ptr %.60, i64 10)
  %.63 = getelementptr %bigint, ptr %.58, i32 0, i32 1
  store i1 false, ptr %.63, align 1
  %.65 = getelementptr %bigint, ptr %.58, i32 0, i32 2
  store ptr %.60, ptr %.65, align 8
  %.67 = alloca ptr, align 8
  store ptr %.5, ptr %.67, align 8
  %.69 = alloca i64, align 8
  store i64 0, ptr %.69, align 4
  br label %loop_cond_a

no_adjust:                                        ; preds = %adjust_a
  br label %do_add

loop_cond_a:                                      ; preds = %loop_body_a.endif, %need_adjust_a
  %.72 = load i64, ptr %.69, align 4
  %.73 = icmp slt i64 %.72, %.56
  br i1 %.73, label %loop_body_a, label %loop_end_a

loop_body_a:                                      ; preds = %loop_cond_a
  %.75 = load ptr, ptr %.67, align 8
  %.76 = call ptr @bigint_mul(ptr %.75, ptr %.58)
  %.77 = icmp eq ptr %.75, %.5
  %.78 = xor i1 %.77, true
  br i1 %.78, label %loop_body_a.if, label %loop_body_a.endif

loop_end_a:                                       ; preds = %loop_cond_a
  %.87 = load ptr, ptr %.67, align 8
  store ptr %.87, ptr %.14, align 8
  br label %do_add

loop_body_a.if:                                   ; preds = %loop_body_a
  %.80 = bitcast ptr %.75 to ptr
  call void @meteor_release(ptr %.80)
  br label %loop_body_a.endif

loop_body_a.endif:                                ; preds = %loop_body_a.if, %loop_body_a
  store ptr %.76, ptr %.67, align 8
  %.84 = add i64 %.72, 1
  store i64 %.84, ptr %.69, align 4
  br label %loop_cond_a
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
  %.91 = load ptr, ptr %.14, align 8
  %.92 = load ptr, ptr %.15, align 8
  %.93 = load i64, ptr %.16, align 4
  %.94 = call ptr @bigint_sub(ptr %.91, ptr %.92)
  %.95 = alloca %decimal, align 8
  %.96 = getelementptr %decimal, ptr %.95, i32 0, i32 1
  store ptr %.94, ptr %.96, align 8
  %.98 = getelementptr %decimal, ptr %.95, i32 0, i32 2
  store i64 %.93, ptr %.98, align 4
  %.100 = load %decimal, ptr %.95, align 8
  ret %decimal %.100

loop_cond_b:                                      ; preds = %loop_body_b.endif, %adjust_b
  %.37 = load i64, ptr %.34, align 4
  %.38 = icmp slt i64 %.37, %.21
  br i1 %.38, label %loop_body_b, label %loop_end_b

loop_body_b:                                      ; preds = %loop_cond_b
  %.40 = load ptr, ptr %.32, align 8
  %.41 = call ptr @bigint_mul(ptr %.40, ptr %.23)
  %.42 = icmp eq ptr %.40, %.9
  %.43 = xor i1 %.42, true
  br i1 %.43, label %loop_body_b.if, label %loop_body_b.endif

loop_end_b:                                       ; preds = %loop_cond_b
  %.52 = load ptr, ptr %.32, align 8
  store ptr %.52, ptr %.15, align 8
  br label %do_sub

loop_body_b.if:                                   ; preds = %loop_body_b
  %.45 = bitcast ptr %.40 to ptr
  call void @meteor_release(ptr %.45)
  br label %loop_body_b.endif

loop_body_b.endif:                                ; preds = %loop_body_b.if, %loop_body_b
  store ptr %.41, ptr %.32, align 8
  %.49 = add i64 %.37, 1
  store i64 %.49, ptr %.34, align 4
  br label %loop_cond_b

need_adjust_a:                                    ; preds = %adjust_a
  %.56 = sub i64 %.7, %.11
  store i64 %.11, ptr %.16, align 4
  %.58 = alloca %bigint, align 8
  %.59 = call ptr @malloc(i64 32)
  %.60 = bitcast ptr %.59 to ptr
  call void @i64.array.init(ptr %.60)
  call void @i64.array.append(ptr %.60, i64 10)
  %.63 = getelementptr %bigint, ptr %.58, i32 0, i32 1
  store i1 false, ptr %.63, align 1
  %.65 = getelementptr %bigint, ptr %.58, i32 0, i32 2
  store ptr %.60, ptr %.65, align 8
  %.67 = alloca ptr, align 8
  store ptr %.5, ptr %.67, align 8
  %.69 = alloca i64, align 8
  store i64 0, ptr %.69, align 4
  br label %loop_cond_a

no_adjust:                                        ; preds = %adjust_a
  br label %do_sub

loop_cond_a:                                      ; preds = %loop_body_a.endif, %need_adjust_a
  %.72 = load i64, ptr %.69, align 4
  %.73 = icmp slt i64 %.72, %.56
  br i1 %.73, label %loop_body_a, label %loop_end_a

loop_body_a:                                      ; preds = %loop_cond_a
  %.75 = load ptr, ptr %.67, align 8
  %.76 = call ptr @bigint_mul(ptr %.75, ptr %.58)
  %.77 = icmp eq ptr %.75, %.5
  %.78 = xor i1 %.77, true
  br i1 %.78, label %loop_body_a.if, label %loop_body_a.endif

loop_end_a:                                       ; preds = %loop_cond_a
  %.87 = load ptr, ptr %.67, align 8
  store ptr %.87, ptr %.14, align 8
  br label %do_sub

loop_body_a.if:                                   ; preds = %loop_body_a
  %.80 = bitcast ptr %.75 to ptr
  call void @meteor_release(ptr %.80)
  br label %loop_body_a.endif

loop_body_a.endif:                                ; preds = %loop_body_a.if, %loop_body_a
  store ptr %.76, ptr %.67, align 8
  %.84 = add i64 %.72, 1
  store i64 %.84, ptr %.69, align 4
  br label %loop_cond_a
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
  %.12 = call ptr @bigint_mul(ptr %.5, ptr %.9)
  %.13 = add i64 %.7, %.11
  %.14 = alloca %decimal, align 8
  %.15 = getelementptr %decimal, ptr %.14, i32 0, i32 1
  store ptr %.12, ptr %.15, align 8
  %.17 = getelementptr %decimal, ptr %.14, i32 0, i32 2
  store i64 %.13, ptr %.17, align 4
  %.19 = load %decimal, ptr %.14, align 8
  ret %decimal %.19
}

define %decimal @decimal_neg(ptr %.1) {
entry:
  %.3 = getelementptr %decimal, ptr %.1, i32 0, i32 1
  %.4 = load ptr, ptr %.3, align 8
  %.5 = getelementptr %decimal, ptr %.1, i32 0, i32 2
  %.6 = load i64, ptr %.5, align 4
  %.7 = call ptr @bigint_neg(ptr %.4)
  %.8 = alloca %decimal, align 8
  %.9 = getelementptr %decimal, ptr %.8, i32 0, i32 1
  store ptr %.7, ptr %.9, align 8
  %.11 = getelementptr %decimal, ptr %.8, i32 0, i32 2
  store i64 %.6, ptr %.11, align 4
  %.13 = load %decimal, ptr %.8, align 8
  ret %decimal %.13
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
  %.10 = call ptr @malloc(i64 32)
  %.11 = bitcast ptr %.10 to ptr
  %.12 = call ptr @malloc(i64 32)
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
  %.35 = call ptr @malloc(i64 32)
  %.36 = bitcast ptr %.35 to ptr
  %.37 = call ptr @malloc(i64 32)
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
  %.57 = call ptr @malloc(i64 32)
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
  %.3 = call ptr @malloc(i64 40)
  %.4 = call ptr @memset(ptr %.3, i32 0, i64 40)
  %.5 = bitcast ptr %.3 to ptr
  call void @i64.array.init(ptr %.5)
  %.7 = call ptr @malloc(i64 40)
  %.8 = call ptr @memset(ptr %.7, i32 0, i64 40)
  %.9 = bitcast ptr %.7 to ptr
  call void @i64.array.init(ptr %.9)
  %.11 = call ptr @malloc(i64 40)
  %.12 = call ptr @memset(ptr %.11, i32 0, i64 40)
  %.13 = bitcast ptr %.11 to ptr
  call void @i64.array.init(ptr %.13)
  %.15 = call ptr @malloc(i64 40)
  %.16 = call ptr @memset(ptr %.15, i32 0, i64 40)
  %.17 = bitcast ptr %.15 to ptr
  call void @i64.array.init(ptr %.17)
  call void @i64.array.append(ptr %.17, i64 83)
  call void @i64.array.append(ptr %.17, i64 116)
  call void @i64.array.append(ptr %.17, i64 97)
  call void @i64.array.append(ptr %.17, i64 114)
  call void @i64.array.append(ptr %.17, i64 116)
  call void @i64.array.append(ptr %.17, i64 105)
  call void @i64.array.append(ptr %.17, i64 110)
  call void @i64.array.append(ptr %.17, i64 103)
  call void @i64.array.append(ptr %.17, i64 32)
  call void @i64.array.append(ptr %.17, i64 67)
  call void @i64.array.append(ptr %.17, i64 108)
  call void @i64.array.append(ptr %.17, i64 97)
  call void @i64.array.append(ptr %.17, i64 115)
  call void @i64.array.append(ptr %.17, i64 115)
  call void @i64.array.append(ptr %.17, i64 32)
  call void @i64.array.append(ptr %.17, i64 76)
  call void @i64.array.append(ptr %.17, i64 101)
  call void @i64.array.append(ptr %.17, i64 97)
  call void @i64.array.append(ptr %.17, i64 107)
  call void @i64.array.append(ptr %.17, i64 32)
  call void @i64.array.append(ptr %.17, i64 84)
  call void @i64.array.append(ptr %.17, i64 101)
  call void @i64.array.append(ptr %.17, i64 115)
  call void @i64.array.append(ptr %.17, i64 116)
  call void @i64.array.append(ptr %.17, i64 46)
  call void @i64.array.append(ptr %.17, i64 46)
  call void @i64.array.append(ptr %.17, i64 46)
  call void @print(ptr %.17)
  %.47 = icmp eq ptr %.17, null
  br i1 %.47, label %rc_release_continue, label %rc_release

exit:                                             ; preds = %rc_release_continue.1
  ret i64 0

rc_release:                                       ; preds = %entry
  %.49 = bitcast ptr %.17 to ptr
  call void @meteor_release(ptr %.49)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %entry
  call void @run_test()
  %.53 = call ptr @malloc(i64 40)
  %.54 = call ptr @memset(ptr %.53, i32 0, i64 40)
  %.55 = bitcast ptr %.53 to ptr
  call void @i64.array.init(ptr %.55)
  call void @i64.array.append(ptr %.55, i64 84)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 115)
  call void @i64.array.append(ptr %.55, i64 116)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 67)
  call void @i64.array.append(ptr %.55, i64 111)
  call void @i64.array.append(ptr %.55, i64 109)
  call void @i64.array.append(ptr %.55, i64 112)
  call void @i64.array.append(ptr %.55, i64 108)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 116)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 46)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 73)
  call void @i64.array.append(ptr %.55, i64 102)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 109)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 109)
  call void @i64.array.append(ptr %.55, i64 111)
  call void @i64.array.append(ptr %.55, i64 114)
  call void @i64.array.append(ptr %.55, i64 121)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 117)
  call void @i64.array.append(ptr %.55, i64 115)
  call void @i64.array.append(ptr %.55, i64 97)
  call void @i64.array.append(ptr %.55, i64 103)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 100)
  call void @i64.array.append(ptr %.55, i64 105)
  call void @i64.array.append(ptr %.55, i64 100)
  call void @i64.array.append(ptr %.55, i64 110)
  call void @i64.array.append(ptr %.55, i64 39)
  call void @i64.array.append(ptr %.55, i64 116)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 115)
  call void @i64.array.append(ptr %.55, i64 112)
  call void @i64.array.append(ptr %.55, i64 105)
  call void @i64.array.append(ptr %.55, i64 107)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 44)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 99)
  call void @i64.array.append(ptr %.55, i64 104)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 99)
  call void @i64.array.append(ptr %.55, i64 107)
  call void @i64.array.append(ptr %.55, i64 32)
  call void @i64.array.append(ptr %.55, i64 105)
  call void @i64.array.append(ptr %.55, i64 109)
  call void @i64.array.append(ptr %.55, i64 112)
  call void @i64.array.append(ptr %.55, i64 108)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 109)
  call void @i64.array.append(ptr %.55, i64 101)
  call void @i64.array.append(ptr %.55, i64 110)
  call void @i64.array.append(ptr %.55, i64 116)
  call void @i64.array.append(ptr %.55, i64 97)
  call void @i64.array.append(ptr %.55, i64 116)
  call void @i64.array.append(ptr %.55, i64 105)
  call void @i64.array.append(ptr %.55, i64 111)
  call void @i64.array.append(ptr %.55, i64 110)
  call void @i64.array.append(ptr %.55, i64 46)
  call void @print(ptr %.55)
  %.124 = icmp eq ptr %.55, null
  br i1 %.124, label %rc_release_continue.1, label %rc_release.1

rc_release.1:                                     ; preds = %rc_release_continue
  %.126 = bitcast ptr %.55 to ptr
  call void @meteor_release(ptr %.126)
  br label %rc_release_continue.1

rc_release_continue.1:                            ; preds = %rc_release.1, %rc_release_continue
  br label %exit
}

define void @StringWrapper.new(ptr %self, ptr %v) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %v.1 = alloca ptr, align 8
  store ptr %v, ptr %v.1, align 8
  %.6 = call ptr @malloc(i64 40)
  %.7 = call ptr @memset(ptr %.6, i32 0, i64 40)
  %.8 = bitcast ptr %.6 to ptr
  call void @i64.array.init(ptr %.8)
  call void @i64.array.append(ptr %.8, i64 73)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 119)
  call void @print(ptr %.8)
  %.17 = icmp eq ptr %.8, null
  br i1 %.17, label %rc_release_continue, label %rc_release

exit:                                             ; preds = %rc_release_continue.endif
  ret void

rc_release:                                       ; preds = %entry
  %.19 = bitcast ptr %.8 to ptr
  call void @meteor_release(ptr %.19)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %entry
  %.22 = load ptr, ptr %v.1, align 8
  %.23 = load ptr, ptr %self.1, align 8
  %.24 = getelementptr inbounds %StringWrapper, ptr %.23, i32 0, i32 0
  %.25 = load ptr, ptr %v.1, align 8
  %.26 = load ptr, ptr %.24, align 8
  %.27 = icmp ne ptr %.26, null
  br i1 %.27, label %rc_release_continue.if, label %rc_release_continue.endif

rc_release_continue.if:                           ; preds = %rc_release_continue
  %.29 = icmp eq ptr %.26, null
  br i1 %.29, label %rc_release_continue.1, label %rc_release.1

rc_release_continue.endif:                        ; preds = %rc_release_continue.1, %rc_release_continue
  %.35 = bitcast ptr %.25 to ptr
  call void @meteor_retain(ptr %.35)
  store ptr %.25, ptr %.24, align 8
  br label %exit

rc_release.1:                                     ; preds = %rc_release_continue.if
  %.31 = bitcast ptr %.26 to ptr
  call void @meteor_release(ptr %.31)
  br label %rc_release_continue.1

rc_release_continue.1:                            ; preds = %rc_release.1, %rc_release_continue.if
  br label %rc_release_continue.endif
}

define internal void @__destroy_StringWrapper__(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

exit:                                             ; preds = %continue_value, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr inbounds %StringWrapper, ptr %.1, i32 0, i32 0
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %continue_value, label %release_value

release_value:                                    ; preds = %not_null
  %.9 = bitcast ptr %.6 to ptr
  call void @meteor_release(ptr %.9)
  br label %continue_value

continue_value:                                   ; preds = %release_value, %not_null
  br label %exit
}

define ptr @int_to_str(i64 %n) {
entry:
  %n.1 = alloca i64, align 8
  store i64 %n, ptr %n.1, align 4
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  br label %if.start

exit:                                             ; preds = %rc_release_continue.11.endif, %if.true.0.10.endif, %if.true.0.9.endif, %if.true.0.8.endif, %if.true.0.7.endif, %if.true.0.6.endif, %if.true.0.5.endif, %if.true.0.4.endif, %if.true.0.3.endif, %if.true.0.2.endif, %if.true.0.1.endif
  %.248 = load ptr, ptr %ret_var, align 8
  ret ptr %.248

if.start:                                         ; preds = %entry
  %.6 = load i64, ptr %n.1, align 4
  %cmptmp = icmp slt i64 %.6, 10
  br i1 %cmptmp, label %if.true.0, label %if.end

if.end:                                           ; preds = %if.end.10, %if.start
  %.199 = load i64, ptr %n.1, align 4
  %divtmp = sdiv i64 %.199, 10
  %.200 = call ptr @int_to_str(i64 %divtmp)
  %.201 = load i64, ptr %n.1, align 4
  %modtmp = srem i64 %.201, 10
  %.202 = call ptr @int_to_str(i64 %modtmp)
  %.203 = call ptr @malloc(i64 40)
  %.204 = call ptr @memset(ptr %.203, i32 0, i64 40)
  %.205 = bitcast ptr %.203 to ptr
  call void @i64.array.init(ptr %.205)
  %left_len = call i64 @i64.array.length(ptr %.200)
  %right_len = call i64 @i64.array.length(ptr %.202)
  %i_left = alloca i64, align 8
  store i64 0, ptr %i_left, align 4
  br label %str_concat.left.cond

if.true.0:                                        ; preds = %if.start
  br label %if.start.1

if.start.1:                                       ; preds = %if.true.0
  %.9 = load i64, ptr %n.1, align 4
  %cmptmp.1 = icmp eq i64 %.9, 0
  br i1 %cmptmp.1, label %if.true.0.1, label %if.end.1

if.end.1:                                         ; preds = %if.start.1
  br label %if.start.2

if.true.0.1:                                      ; preds = %if.start.1
  %.11 = call ptr @malloc(i64 40)
  %.12 = call ptr @memset(ptr %.11, i32 0, i64 40)
  %.13 = bitcast ptr %.11 to ptr
  call void @i64.array.init(ptr %.13)
  call void @i64.array.append(ptr %.13, i64 48)
  %.16 = load ptr, ptr %ret_var, align 8
  %.17 = icmp ne ptr %.16, null
  br i1 %.17, label %if.true.0.1.if, label %if.true.0.1.endif

if.true.0.1.if:                                   ; preds = %if.true.0.1
  %.19 = icmp eq ptr %.16, null
  br i1 %.19, label %rc_release_continue, label %rc_release

if.true.0.1.endif:                                ; preds = %rc_release_continue, %if.true.0.1
  store ptr %.13, ptr %ret_var, align 8
  br label %exit

rc_release:                                       ; preds = %if.true.0.1.if
  %.21 = bitcast ptr %.16 to ptr
  call void @meteor_release(ptr %.21)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %if.true.0.1.if
  br label %if.true.0.1.endif

if.start.2:                                       ; preds = %if.end.1
  %.28 = load i64, ptr %n.1, align 4
  %cmptmp.2 = icmp eq i64 %.28, 1
  br i1 %cmptmp.2, label %if.true.0.2, label %if.end.2

if.end.2:                                         ; preds = %if.start.2
  br label %if.start.3

if.true.0.2:                                      ; preds = %if.start.2
  %.30 = call ptr @malloc(i64 40)
  %.31 = call ptr @memset(ptr %.30, i32 0, i64 40)
  %.32 = bitcast ptr %.30 to ptr
  call void @i64.array.init(ptr %.32)
  call void @i64.array.append(ptr %.32, i64 49)
  %.35 = load ptr, ptr %ret_var, align 8
  %.36 = icmp ne ptr %.35, null
  br i1 %.36, label %if.true.0.2.if, label %if.true.0.2.endif

if.true.0.2.if:                                   ; preds = %if.true.0.2
  %.38 = icmp eq ptr %.35, null
  br i1 %.38, label %rc_release_continue.1, label %rc_release.1

if.true.0.2.endif:                                ; preds = %rc_release_continue.1, %if.true.0.2
  store ptr %.32, ptr %ret_var, align 8
  br label %exit

rc_release.1:                                     ; preds = %if.true.0.2.if
  %.40 = bitcast ptr %.35 to ptr
  call void @meteor_release(ptr %.40)
  br label %rc_release_continue.1

rc_release_continue.1:                            ; preds = %rc_release.1, %if.true.0.2.if
  br label %if.true.0.2.endif

if.start.3:                                       ; preds = %if.end.2
  %.47 = load i64, ptr %n.1, align 4
  %cmptmp.3 = icmp eq i64 %.47, 2
  br i1 %cmptmp.3, label %if.true.0.3, label %if.end.3

if.end.3:                                         ; preds = %if.start.3
  br label %if.start.4

if.true.0.3:                                      ; preds = %if.start.3
  %.49 = call ptr @malloc(i64 40)
  %.50 = call ptr @memset(ptr %.49, i32 0, i64 40)
  %.51 = bitcast ptr %.49 to ptr
  call void @i64.array.init(ptr %.51)
  call void @i64.array.append(ptr %.51, i64 50)
  %.54 = load ptr, ptr %ret_var, align 8
  %.55 = icmp ne ptr %.54, null
  br i1 %.55, label %if.true.0.3.if, label %if.true.0.3.endif

if.true.0.3.if:                                   ; preds = %if.true.0.3
  %.57 = icmp eq ptr %.54, null
  br i1 %.57, label %rc_release_continue.2, label %rc_release.2

if.true.0.3.endif:                                ; preds = %rc_release_continue.2, %if.true.0.3
  store ptr %.51, ptr %ret_var, align 8
  br label %exit

rc_release.2:                                     ; preds = %if.true.0.3.if
  %.59 = bitcast ptr %.54 to ptr
  call void @meteor_release(ptr %.59)
  br label %rc_release_continue.2

rc_release_continue.2:                            ; preds = %rc_release.2, %if.true.0.3.if
  br label %if.true.0.3.endif

if.start.4:                                       ; preds = %if.end.3
  %.66 = load i64, ptr %n.1, align 4
  %cmptmp.4 = icmp eq i64 %.66, 3
  br i1 %cmptmp.4, label %if.true.0.4, label %if.end.4

if.end.4:                                         ; preds = %if.start.4
  br label %if.start.5

if.true.0.4:                                      ; preds = %if.start.4
  %.68 = call ptr @malloc(i64 40)
  %.69 = call ptr @memset(ptr %.68, i32 0, i64 40)
  %.70 = bitcast ptr %.68 to ptr
  call void @i64.array.init(ptr %.70)
  call void @i64.array.append(ptr %.70, i64 51)
  %.73 = load ptr, ptr %ret_var, align 8
  %.74 = icmp ne ptr %.73, null
  br i1 %.74, label %if.true.0.4.if, label %if.true.0.4.endif

if.true.0.4.if:                                   ; preds = %if.true.0.4
  %.76 = icmp eq ptr %.73, null
  br i1 %.76, label %rc_release_continue.3, label %rc_release.3

if.true.0.4.endif:                                ; preds = %rc_release_continue.3, %if.true.0.4
  store ptr %.70, ptr %ret_var, align 8
  br label %exit

rc_release.3:                                     ; preds = %if.true.0.4.if
  %.78 = bitcast ptr %.73 to ptr
  call void @meteor_release(ptr %.78)
  br label %rc_release_continue.3

rc_release_continue.3:                            ; preds = %rc_release.3, %if.true.0.4.if
  br label %if.true.0.4.endif

if.start.5:                                       ; preds = %if.end.4
  %.85 = load i64, ptr %n.1, align 4
  %cmptmp.5 = icmp eq i64 %.85, 4
  br i1 %cmptmp.5, label %if.true.0.5, label %if.end.5

if.end.5:                                         ; preds = %if.start.5
  br label %if.start.6

if.true.0.5:                                      ; preds = %if.start.5
  %.87 = call ptr @malloc(i64 40)
  %.88 = call ptr @memset(ptr %.87, i32 0, i64 40)
  %.89 = bitcast ptr %.87 to ptr
  call void @i64.array.init(ptr %.89)
  call void @i64.array.append(ptr %.89, i64 52)
  %.92 = load ptr, ptr %ret_var, align 8
  %.93 = icmp ne ptr %.92, null
  br i1 %.93, label %if.true.0.5.if, label %if.true.0.5.endif

if.true.0.5.if:                                   ; preds = %if.true.0.5
  %.95 = icmp eq ptr %.92, null
  br i1 %.95, label %rc_release_continue.4, label %rc_release.4

if.true.0.5.endif:                                ; preds = %rc_release_continue.4, %if.true.0.5
  store ptr %.89, ptr %ret_var, align 8
  br label %exit

rc_release.4:                                     ; preds = %if.true.0.5.if
  %.97 = bitcast ptr %.92 to ptr
  call void @meteor_release(ptr %.97)
  br label %rc_release_continue.4

rc_release_continue.4:                            ; preds = %rc_release.4, %if.true.0.5.if
  br label %if.true.0.5.endif

if.start.6:                                       ; preds = %if.end.5
  %.104 = load i64, ptr %n.1, align 4
  %cmptmp.6 = icmp eq i64 %.104, 5
  br i1 %cmptmp.6, label %if.true.0.6, label %if.end.6

if.end.6:                                         ; preds = %if.start.6
  br label %if.start.7

if.true.0.6:                                      ; preds = %if.start.6
  %.106 = call ptr @malloc(i64 40)
  %.107 = call ptr @memset(ptr %.106, i32 0, i64 40)
  %.108 = bitcast ptr %.106 to ptr
  call void @i64.array.init(ptr %.108)
  call void @i64.array.append(ptr %.108, i64 53)
  %.111 = load ptr, ptr %ret_var, align 8
  %.112 = icmp ne ptr %.111, null
  br i1 %.112, label %if.true.0.6.if, label %if.true.0.6.endif

if.true.0.6.if:                                   ; preds = %if.true.0.6
  %.114 = icmp eq ptr %.111, null
  br i1 %.114, label %rc_release_continue.5, label %rc_release.5

if.true.0.6.endif:                                ; preds = %rc_release_continue.5, %if.true.0.6
  store ptr %.108, ptr %ret_var, align 8
  br label %exit

rc_release.5:                                     ; preds = %if.true.0.6.if
  %.116 = bitcast ptr %.111 to ptr
  call void @meteor_release(ptr %.116)
  br label %rc_release_continue.5

rc_release_continue.5:                            ; preds = %rc_release.5, %if.true.0.6.if
  br label %if.true.0.6.endif

if.start.7:                                       ; preds = %if.end.6
  %.123 = load i64, ptr %n.1, align 4
  %cmptmp.7 = icmp eq i64 %.123, 6
  br i1 %cmptmp.7, label %if.true.0.7, label %if.end.7

if.end.7:                                         ; preds = %if.start.7
  br label %if.start.8

if.true.0.7:                                      ; preds = %if.start.7
  %.125 = call ptr @malloc(i64 40)
  %.126 = call ptr @memset(ptr %.125, i32 0, i64 40)
  %.127 = bitcast ptr %.125 to ptr
  call void @i64.array.init(ptr %.127)
  call void @i64.array.append(ptr %.127, i64 54)
  %.130 = load ptr, ptr %ret_var, align 8
  %.131 = icmp ne ptr %.130, null
  br i1 %.131, label %if.true.0.7.if, label %if.true.0.7.endif

if.true.0.7.if:                                   ; preds = %if.true.0.7
  %.133 = icmp eq ptr %.130, null
  br i1 %.133, label %rc_release_continue.6, label %rc_release.6

if.true.0.7.endif:                                ; preds = %rc_release_continue.6, %if.true.0.7
  store ptr %.127, ptr %ret_var, align 8
  br label %exit

rc_release.6:                                     ; preds = %if.true.0.7.if
  %.135 = bitcast ptr %.130 to ptr
  call void @meteor_release(ptr %.135)
  br label %rc_release_continue.6

rc_release_continue.6:                            ; preds = %rc_release.6, %if.true.0.7.if
  br label %if.true.0.7.endif

if.start.8:                                       ; preds = %if.end.7
  %.142 = load i64, ptr %n.1, align 4
  %cmptmp.8 = icmp eq i64 %.142, 7
  br i1 %cmptmp.8, label %if.true.0.8, label %if.end.8

if.end.8:                                         ; preds = %if.start.8
  br label %if.start.9

if.true.0.8:                                      ; preds = %if.start.8
  %.144 = call ptr @malloc(i64 40)
  %.145 = call ptr @memset(ptr %.144, i32 0, i64 40)
  %.146 = bitcast ptr %.144 to ptr
  call void @i64.array.init(ptr %.146)
  call void @i64.array.append(ptr %.146, i64 55)
  %.149 = load ptr, ptr %ret_var, align 8
  %.150 = icmp ne ptr %.149, null
  br i1 %.150, label %if.true.0.8.if, label %if.true.0.8.endif

if.true.0.8.if:                                   ; preds = %if.true.0.8
  %.152 = icmp eq ptr %.149, null
  br i1 %.152, label %rc_release_continue.7, label %rc_release.7

if.true.0.8.endif:                                ; preds = %rc_release_continue.7, %if.true.0.8
  store ptr %.146, ptr %ret_var, align 8
  br label %exit

rc_release.7:                                     ; preds = %if.true.0.8.if
  %.154 = bitcast ptr %.149 to ptr
  call void @meteor_release(ptr %.154)
  br label %rc_release_continue.7

rc_release_continue.7:                            ; preds = %rc_release.7, %if.true.0.8.if
  br label %if.true.0.8.endif

if.start.9:                                       ; preds = %if.end.8
  %.161 = load i64, ptr %n.1, align 4
  %cmptmp.9 = icmp eq i64 %.161, 8
  br i1 %cmptmp.9, label %if.true.0.9, label %if.end.9

if.end.9:                                         ; preds = %if.start.9
  br label %if.start.10

if.true.0.9:                                      ; preds = %if.start.9
  %.163 = call ptr @malloc(i64 40)
  %.164 = call ptr @memset(ptr %.163, i32 0, i64 40)
  %.165 = bitcast ptr %.163 to ptr
  call void @i64.array.init(ptr %.165)
  call void @i64.array.append(ptr %.165, i64 56)
  %.168 = load ptr, ptr %ret_var, align 8
  %.169 = icmp ne ptr %.168, null
  br i1 %.169, label %if.true.0.9.if, label %if.true.0.9.endif

if.true.0.9.if:                                   ; preds = %if.true.0.9
  %.171 = icmp eq ptr %.168, null
  br i1 %.171, label %rc_release_continue.8, label %rc_release.8

if.true.0.9.endif:                                ; preds = %rc_release_continue.8, %if.true.0.9
  store ptr %.165, ptr %ret_var, align 8
  br label %exit

rc_release.8:                                     ; preds = %if.true.0.9.if
  %.173 = bitcast ptr %.168 to ptr
  call void @meteor_release(ptr %.173)
  br label %rc_release_continue.8

rc_release_continue.8:                            ; preds = %rc_release.8, %if.true.0.9.if
  br label %if.true.0.9.endif

if.start.10:                                      ; preds = %if.end.9
  %.180 = load i64, ptr %n.1, align 4
  %cmptmp.10 = icmp eq i64 %.180, 9
  br i1 %cmptmp.10, label %if.true.0.10, label %if.end.10

if.end.10:                                        ; preds = %if.start.10
  br label %if.end

if.true.0.10:                                     ; preds = %if.start.10
  %.182 = call ptr @malloc(i64 40)
  %.183 = call ptr @memset(ptr %.182, i32 0, i64 40)
  %.184 = bitcast ptr %.182 to ptr
  call void @i64.array.init(ptr %.184)
  call void @i64.array.append(ptr %.184, i64 57)
  %.187 = load ptr, ptr %ret_var, align 8
  %.188 = icmp ne ptr %.187, null
  br i1 %.188, label %if.true.0.10.if, label %if.true.0.10.endif

if.true.0.10.if:                                  ; preds = %if.true.0.10
  %.190 = icmp eq ptr %.187, null
  br i1 %.190, label %rc_release_continue.9, label %rc_release.9

if.true.0.10.endif:                               ; preds = %rc_release_continue.9, %if.true.0.10
  store ptr %.184, ptr %ret_var, align 8
  br label %exit

rc_release.9:                                     ; preds = %if.true.0.10.if
  %.192 = bitcast ptr %.187 to ptr
  call void @meteor_release(ptr %.192)
  br label %rc_release_continue.9

rc_release_continue.9:                            ; preds = %rc_release.9, %if.true.0.10.if
  br label %if.true.0.10.endif

str_concat.left.cond:                             ; preds = %str_concat.left.body, %if.end
  %.209 = load i64, ptr %i_left, align 4
  %.210 = icmp slt i64 %.209, %left_len
  br i1 %.210, label %str_concat.left.body, label %str_concat.left.end

str_concat.left.body:                             ; preds = %str_concat.left.cond
  %.212 = load i64, ptr %i_left, align 4
  %left_char = call i64 @i64.array.get(ptr %.200, i64 %.212)
  call void @i64.array.append(ptr %.205, i64 %left_char)
  %.214 = add i64 %.212, 1
  store i64 %.214, ptr %i_left, align 4
  br label %str_concat.left.cond

str_concat.left.end:                              ; preds = %str_concat.left.cond
  %i_right = alloca i64, align 8
  store i64 0, ptr %i_right, align 4
  br label %str_concat.right.cond

str_concat.right.cond:                            ; preds = %str_concat.right.body, %str_concat.left.end
  %.219 = load i64, ptr %i_right, align 4
  %.220 = icmp slt i64 %.219, %right_len
  br i1 %.220, label %str_concat.right.body, label %str_concat.right.end

str_concat.right.body:                            ; preds = %str_concat.right.cond
  %.222 = load i64, ptr %i_right, align 4
  %right_char = call i64 @i64.array.get(ptr %.202, i64 %.222)
  call void @i64.array.append(ptr %.205, i64 %right_char)
  %.224 = add i64 %.222, 1
  store i64 %.224, ptr %i_right, align 4
  br label %str_concat.right.cond

str_concat.right.end:                             ; preds = %str_concat.right.cond
  %.227 = icmp eq ptr %.200, null
  br i1 %.227, label %rc_release_continue.10, label %rc_release.10

rc_release.10:                                    ; preds = %str_concat.right.end
  %.229 = bitcast ptr %.200 to ptr
  call void @meteor_release(ptr %.229)
  br label %rc_release_continue.10

rc_release_continue.10:                           ; preds = %rc_release.10, %str_concat.right.end
  %.232 = icmp eq ptr %.202, null
  br i1 %.232, label %rc_release_continue.11, label %rc_release.11

rc_release.11:                                    ; preds = %rc_release_continue.10
  %.234 = bitcast ptr %.202 to ptr
  call void @meteor_release(ptr %.234)
  br label %rc_release_continue.11

rc_release_continue.11:                           ; preds = %rc_release.11, %rc_release_continue.10
  %.237 = load ptr, ptr %ret_var, align 8
  %.238 = icmp ne ptr %.237, null
  br i1 %.238, label %rc_release_continue.11.if, label %rc_release_continue.11.endif

rc_release_continue.11.if:                        ; preds = %rc_release_continue.11
  %.240 = icmp eq ptr %.237, null
  br i1 %.240, label %rc_release_continue.12, label %rc_release.12

rc_release_continue.11.endif:                     ; preds = %rc_release_continue.12, %rc_release_continue.11
  store ptr %.205, ptr %ret_var, align 8
  br label %exit

rc_release.12:                                    ; preds = %rc_release_continue.11.if
  %.242 = bitcast ptr %.237 to ptr
  call void @meteor_release(ptr %.242)
  br label %rc_release_continue.12

rc_release_continue.12:                           ; preds = %rc_release.12, %rc_release_continue.11.if
  br label %rc_release_continue.11.endif
}

define void @run_test() {
entry:
  %w = alloca ptr, align 8
  store ptr null, ptr %w, align 8
  %i = alloca i64, align 8
  store i64 0, ptr %i, align 4
  br label %while.cond

exit:                                             ; preds = %while.end
  %.344 = load ptr, ptr %w, align 8
  %.345 = icmp eq ptr %.344, null
  br i1 %.345, label %rc_release_continue.14, label %rc_release.14

while.cond:                                       ; preds = %rc_release_continue.13, %entry
  %.4 = load i64, ptr %i, align 4
  %cmptmp = icmp slt i64 %.4, 100000
  br i1 %cmptmp, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %.6 = call ptr @malloc(i64 40)
  %.7 = call ptr @memset(ptr %.6, i32 0, i64 40)
  %.8 = bitcast ptr %.6 to ptr
  call void @i64.array.init(ptr %.8)
  call void @i64.array.append(ptr %.8, i64 76)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 32)
  %.21 = load i64, ptr %i, align 4
  %.22 = call ptr @int_to_str(i64 %.21)
  %.23 = call ptr @malloc(i64 40)
  %.24 = call ptr @memset(ptr %.23, i32 0, i64 40)
  %.25 = bitcast ptr %.23 to ptr
  call void @i64.array.init(ptr %.25)
  %left_len = call i64 @i64.array.length(ptr %.8)
  %right_len = call i64 @i64.array.length(ptr %.22)
  %i_left = alloca i64, align 8
  store i64 0, ptr %i_left, align 4
  br label %str_concat.left.cond

while.end:                                        ; preds = %while.cond
  br label %exit

str_concat.left.cond:                             ; preds = %str_concat.left.body, %while.body
  %.29 = load i64, ptr %i_left, align 4
  %.30 = icmp slt i64 %.29, %left_len
  br i1 %.30, label %str_concat.left.body, label %str_concat.left.end

str_concat.left.body:                             ; preds = %str_concat.left.cond
  %.32 = load i64, ptr %i_left, align 4
  %left_char = call i64 @i64.array.get(ptr %.8, i64 %.32)
  call void @i64.array.append(ptr %.25, i64 %left_char)
  %.34 = add i64 %.32, 1
  store i64 %.34, ptr %i_left, align 4
  br label %str_concat.left.cond

str_concat.left.end:                              ; preds = %str_concat.left.cond
  %i_right = alloca i64, align 8
  store i64 0, ptr %i_right, align 4
  br label %str_concat.right.cond

str_concat.right.cond:                            ; preds = %str_concat.right.body, %str_concat.left.end
  %.39 = load i64, ptr %i_right, align 4
  %.40 = icmp slt i64 %.39, %right_len
  br i1 %.40, label %str_concat.right.body, label %str_concat.right.end

str_concat.right.body:                            ; preds = %str_concat.right.cond
  %.42 = load i64, ptr %i_right, align 4
  %right_char = call i64 @i64.array.get(ptr %.22, i64 %.42)
  call void @i64.array.append(ptr %.25, i64 %right_char)
  %.44 = add i64 %.42, 1
  store i64 %.44, ptr %i_right, align 4
  br label %str_concat.right.cond

str_concat.right.end:                             ; preds = %str_concat.right.cond
  %.47 = icmp eq ptr %.8, null
  br i1 %.47, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %str_concat.right.end
  %.49 = bitcast ptr %.8 to ptr
  call void @meteor_release(ptr %.49)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %str_concat.right.end
  %.52 = icmp eq ptr %.22, null
  br i1 %.52, label %rc_release_continue.1, label %rc_release.1

rc_release.1:                                     ; preds = %rc_release_continue
  %.54 = bitcast ptr %.22 to ptr
  call void @meteor_release(ptr %.54)
  br label %rc_release_continue.1

rc_release_continue.1:                            ; preds = %rc_release.1, %rc_release_continue
  call void @print(ptr %.25)
  %.58 = icmp eq ptr %.25, null
  br i1 %.58, label %rc_release_continue.2, label %rc_release.2

rc_release.2:                                     ; preds = %rc_release_continue.1
  %.60 = bitcast ptr %.25 to ptr
  call void @meteor_release(ptr %.60)
  br label %rc_release_continue.2

rc_release_continue.2:                            ; preds = %rc_release.2, %rc_release_continue.1
  %.63 = getelementptr %StringWrapper, ptr null, i64 1
  %.64 = ptrtoint ptr %.63 to i64
  %.65 = add i64 16, %.64
  %.66 = call ptr @malloc(i64 %.65)
  %.67 = call ptr @memset(ptr %.66, i32 0, i64 %.65)
  %.68 = bitcast ptr %.66 to ptr
  %.69 = getelementptr %meteor.header, ptr %.68, i64 0, i32 0
  store i32 1, ptr %.69, align 4
  %.71 = getelementptr %meteor.header, ptr %.68, i64 0, i32 1
  store i32 0, ptr %.71, align 4
  %.73 = getelementptr %meteor.header, ptr %.68, i64 0, i32 2
  store i8 0, ptr %.73, align 1
  %.75 = getelementptr %meteor.header, ptr %.68, i64 0, i32 3
  store i8 10, ptr %.75, align 1
  %.77 = getelementptr %meteor.header, ptr %.68, i64 0, i32 5
  store i32 1, ptr %.77, align 4
  %.79 = getelementptr i8, ptr %.66, i64 16
  %.80 = bitcast ptr %.79 to ptr
  %.81 = getelementptr inbounds %StringWrapper, ptr %.80, i32 0, i32 0
  store ptr null, ptr %.81, align 8
  %.83 = call ptr @malloc(i64 40)
  %.84 = call ptr @memset(ptr %.83, i32 0, i64 40)
  %.85 = bitcast ptr %.83 to ptr
  call void @i64.array.init(ptr %.85)
  call void @i64.array.append(ptr %.85, i64 73)
  call void @i64.array.append(ptr %.85, i64 110)
  call void @i64.array.append(ptr %.85, i64 105)
  call void @i64.array.append(ptr %.85, i64 116)
  call void @i64.array.append(ptr %.85, i64 105)
  call void @i64.array.append(ptr %.85, i64 97)
  call void @i64.array.append(ptr %.85, i64 108)
  call void @i64.array.append(ptr %.85, i64 32)
  call void @i64.array.append(ptr %.85, i64 99)
  call void @i64.array.append(ptr %.85, i64 104)
  call void @i64.array.append(ptr %.85, i64 101)
  call void @i64.array.append(ptr %.85, i64 99)
  call void @i64.array.append(ptr %.85, i64 107)
  call void @StringWrapper.new(ptr %.80, ptr %.85)
  %.101 = icmp eq ptr %.85, null
  br i1 %.101, label %rc_release_continue.3, label %rc_release.3

rc_release.3:                                     ; preds = %rc_release_continue.2
  %.103 = bitcast ptr %.85 to ptr
  call void @meteor_release(ptr %.103)
  br label %rc_release_continue.3

rc_release_continue.3:                            ; preds = %rc_release.3, %rc_release_continue.2
  %.107 = load ptr, ptr %w, align 8
  %.108 = icmp ne ptr %.107, null
  br i1 %.108, label %rc_release_continue.3.if, label %rc_release_continue.3.endif

rc_release_continue.3.if:                         ; preds = %rc_release_continue.3
  %.110 = icmp eq ptr %.107, null
  br i1 %.110, label %rc_release_continue.4, label %rc_release.4

rc_release_continue.3.endif:                      ; preds = %rc_release_continue.4, %rc_release_continue.3
  store ptr %.80, ptr %w, align 8
  %.119 = call ptr @malloc(i64 40)
  %.120 = call ptr @memset(ptr %.119, i32 0, i64 40)
  %.121 = bitcast ptr %.119 to ptr
  call void @i64.array.init(ptr %.121)
  call void @i64.array.append(ptr %.121, i64 65)
  call void @i64.array.append(ptr %.121, i64 108)
  call void @i64.array.append(ptr %.121, i64 108)
  call void @i64.array.append(ptr %.121, i64 111)
  call void @i64.array.append(ptr %.121, i64 99)
  call void @i64.array.append(ptr %.121, i64 97)
  call void @i64.array.append(ptr %.121, i64 116)
  call void @i64.array.append(ptr %.121, i64 101)
  call void @i64.array.append(ptr %.121, i64 100)
  call void @print(ptr %.121)
  %.133 = icmp eq ptr %.121, null
  br i1 %.133, label %rc_release_continue.5, label %rc_release.5

rc_release.4:                                     ; preds = %rc_release_continue.3.if
  %.112 = bitcast ptr %.107 to ptr
  %.113 = getelementptr i8, ptr %.112, i64 -16
  %.114 = bitcast ptr %.113 to ptr
  call void @meteor_release(ptr %.114)
  br label %rc_release_continue.4

rc_release_continue.4:                            ; preds = %rc_release.4, %rc_release_continue.3.if
  br label %rc_release_continue.3.endif

rc_release.5:                                     ; preds = %rc_release_continue.3.endif
  %.135 = bitcast ptr %.121 to ptr
  call void @meteor_release(ptr %.135)
  br label %rc_release_continue.5

rc_release_continue.5:                            ; preds = %rc_release.5, %rc_release_continue.3.endif
  %.138 = call ptr @malloc(i64 40)
  %.139 = call ptr @memset(ptr %.138, i32 0, i64 40)
  %.140 = bitcast ptr %.138 to ptr
  call void @i64.array.init(ptr %.140)
  call void @i64.array.append(ptr %.140, i64 85)
  call void @i64.array.append(ptr %.140, i64 112)
  call void @i64.array.append(ptr %.140, i64 100)
  call void @i64.array.append(ptr %.140, i64 97)
  call void @i64.array.append(ptr %.140, i64 116)
  call void @i64.array.append(ptr %.140, i64 101)
  call void @i64.array.append(ptr %.140, i64 100)
  call void @i64.array.append(ptr %.140, i64 32)
  call void @i64.array.append(ptr %.140, i64 118)
  call void @i64.array.append(ptr %.140, i64 97)
  call void @i64.array.append(ptr %.140, i64 108)
  call void @i64.array.append(ptr %.140, i64 117)
  call void @i64.array.append(ptr %.140, i64 101)
  call void @i64.array.append(ptr %.140, i64 32)
  %.156 = call ptr @malloc(i64 40)
  %.157 = call ptr @memset(ptr %.156, i32 0, i64 40)
  %.158 = bitcast ptr %.156 to ptr
  call void @i64.array.init(ptr %.158)
  call void @i64.array.append(ptr %.158, i64 99)
  call void @i64.array.append(ptr %.158, i64 111)
  call void @i64.array.append(ptr %.158, i64 110)
  call void @i64.array.append(ptr %.158, i64 99)
  call void @i64.array.append(ptr %.158, i64 97)
  call void @i64.array.append(ptr %.158, i64 116)
  call void @i64.array.append(ptr %.158, i64 101)
  call void @i64.array.append(ptr %.158, i64 110)
  call void @i64.array.append(ptr %.158, i64 97)
  call void @i64.array.append(ptr %.158, i64 116)
  call void @i64.array.append(ptr %.158, i64 101)
  call void @i64.array.append(ptr %.158, i64 100)
  %.172 = call ptr @malloc(i64 40)
  %.173 = call ptr @memset(ptr %.172, i32 0, i64 40)
  %.174 = bitcast ptr %.172 to ptr
  call void @i64.array.init(ptr %.174)
  %left_len.1 = call i64 @i64.array.length(ptr %.140)
  %right_len.1 = call i64 @i64.array.length(ptr %.158)
  %i_left.1 = alloca i64, align 8
  store i64 0, ptr %i_left.1, align 4
  br label %str_concat.left.cond.1

str_concat.left.cond.1:                           ; preds = %str_concat.left.body.1, %rc_release_continue.5
  %.178 = load i64, ptr %i_left.1, align 4
  %.179 = icmp slt i64 %.178, %left_len.1
  br i1 %.179, label %str_concat.left.body.1, label %str_concat.left.end.1

str_concat.left.body.1:                           ; preds = %str_concat.left.cond.1
  %.181 = load i64, ptr %i_left.1, align 4
  %left_char.1 = call i64 @i64.array.get(ptr %.140, i64 %.181)
  call void @i64.array.append(ptr %.174, i64 %left_char.1)
  %.183 = add i64 %.181, 1
  store i64 %.183, ptr %i_left.1, align 4
  br label %str_concat.left.cond.1

str_concat.left.end.1:                            ; preds = %str_concat.left.cond.1
  %i_right.1 = alloca i64, align 8
  store i64 0, ptr %i_right.1, align 4
  br label %str_concat.right.cond.1

str_concat.right.cond.1:                          ; preds = %str_concat.right.body.1, %str_concat.left.end.1
  %.188 = load i64, ptr %i_right.1, align 4
  %.189 = icmp slt i64 %.188, %right_len.1
  br i1 %.189, label %str_concat.right.body.1, label %str_concat.right.end.1

str_concat.right.body.1:                          ; preds = %str_concat.right.cond.1
  %.191 = load i64, ptr %i_right.1, align 4
  %right_char.1 = call i64 @i64.array.get(ptr %.158, i64 %.191)
  call void @i64.array.append(ptr %.174, i64 %right_char.1)
  %.193 = add i64 %.191, 1
  store i64 %.193, ptr %i_right.1, align 4
  br label %str_concat.right.cond.1

str_concat.right.end.1:                           ; preds = %str_concat.right.cond.1
  %.196 = icmp eq ptr %.140, null
  br i1 %.196, label %rc_release_continue.6, label %rc_release.6

rc_release.6:                                     ; preds = %str_concat.right.end.1
  %.198 = bitcast ptr %.140 to ptr
  call void @meteor_release(ptr %.198)
  br label %rc_release_continue.6

rc_release_continue.6:                            ; preds = %rc_release.6, %str_concat.right.end.1
  %.201 = icmp eq ptr %.158, null
  br i1 %.201, label %rc_release_continue.7, label %rc_release.7

rc_release.7:                                     ; preds = %rc_release_continue.6
  %.203 = bitcast ptr %.158 to ptr
  call void @meteor_release(ptr %.203)
  br label %rc_release_continue.7

rc_release_continue.7:                            ; preds = %rc_release.7, %rc_release_continue.6
  %.206 = load ptr, ptr %w, align 8
  %.207 = getelementptr inbounds %StringWrapper, ptr %.206, i32 0, i32 0
  %.208 = call ptr @malloc(i64 40)
  %.209 = call ptr @memset(ptr %.208, i32 0, i64 40)
  %.210 = bitcast ptr %.208 to ptr
  call void @i64.array.init(ptr %.210)
  call void @i64.array.append(ptr %.210, i64 85)
  call void @i64.array.append(ptr %.210, i64 112)
  call void @i64.array.append(ptr %.210, i64 100)
  call void @i64.array.append(ptr %.210, i64 97)
  call void @i64.array.append(ptr %.210, i64 116)
  call void @i64.array.append(ptr %.210, i64 101)
  call void @i64.array.append(ptr %.210, i64 100)
  call void @i64.array.append(ptr %.210, i64 32)
  call void @i64.array.append(ptr %.210, i64 118)
  call void @i64.array.append(ptr %.210, i64 97)
  call void @i64.array.append(ptr %.210, i64 108)
  call void @i64.array.append(ptr %.210, i64 117)
  call void @i64.array.append(ptr %.210, i64 101)
  call void @i64.array.append(ptr %.210, i64 32)
  %.226 = call ptr @malloc(i64 40)
  %.227 = call ptr @memset(ptr %.226, i32 0, i64 40)
  %.228 = bitcast ptr %.226 to ptr
  call void @i64.array.init(ptr %.228)
  call void @i64.array.append(ptr %.228, i64 99)
  call void @i64.array.append(ptr %.228, i64 111)
  call void @i64.array.append(ptr %.228, i64 110)
  call void @i64.array.append(ptr %.228, i64 99)
  call void @i64.array.append(ptr %.228, i64 97)
  call void @i64.array.append(ptr %.228, i64 116)
  call void @i64.array.append(ptr %.228, i64 101)
  call void @i64.array.append(ptr %.228, i64 110)
  call void @i64.array.append(ptr %.228, i64 97)
  call void @i64.array.append(ptr %.228, i64 116)
  call void @i64.array.append(ptr %.228, i64 101)
  call void @i64.array.append(ptr %.228, i64 100)
  %.242 = call ptr @malloc(i64 40)
  %.243 = call ptr @memset(ptr %.242, i32 0, i64 40)
  %.244 = bitcast ptr %.242 to ptr
  call void @i64.array.init(ptr %.244)
  %left_len.2 = call i64 @i64.array.length(ptr %.210)
  %right_len.2 = call i64 @i64.array.length(ptr %.228)
  %i_left.2 = alloca i64, align 8
  store i64 0, ptr %i_left.2, align 4
  br label %str_concat.left.cond.2

str_concat.left.cond.2:                           ; preds = %str_concat.left.body.2, %rc_release_continue.7
  %.248 = load i64, ptr %i_left.2, align 4
  %.249 = icmp slt i64 %.248, %left_len.2
  br i1 %.249, label %str_concat.left.body.2, label %str_concat.left.end.2

str_concat.left.body.2:                           ; preds = %str_concat.left.cond.2
  %.251 = load i64, ptr %i_left.2, align 4
  %left_char.2 = call i64 @i64.array.get(ptr %.210, i64 %.251)
  call void @i64.array.append(ptr %.244, i64 %left_char.2)
  %.253 = add i64 %.251, 1
  store i64 %.253, ptr %i_left.2, align 4
  br label %str_concat.left.cond.2

str_concat.left.end.2:                            ; preds = %str_concat.left.cond.2
  %i_right.2 = alloca i64, align 8
  store i64 0, ptr %i_right.2, align 4
  br label %str_concat.right.cond.2

str_concat.right.cond.2:                          ; preds = %str_concat.right.body.2, %str_concat.left.end.2
  %.258 = load i64, ptr %i_right.2, align 4
  %.259 = icmp slt i64 %.258, %right_len.2
  br i1 %.259, label %str_concat.right.body.2, label %str_concat.right.end.2

str_concat.right.body.2:                          ; preds = %str_concat.right.cond.2
  %.261 = load i64, ptr %i_right.2, align 4
  %right_char.2 = call i64 @i64.array.get(ptr %.228, i64 %.261)
  call void @i64.array.append(ptr %.244, i64 %right_char.2)
  %.263 = add i64 %.261, 1
  store i64 %.263, ptr %i_right.2, align 4
  br label %str_concat.right.cond.2

str_concat.right.end.2:                           ; preds = %str_concat.right.cond.2
  %.266 = icmp eq ptr %.210, null
  br i1 %.266, label %rc_release_continue.8, label %rc_release.8

rc_release.8:                                     ; preds = %str_concat.right.end.2
  %.268 = bitcast ptr %.210 to ptr
  call void @meteor_release(ptr %.268)
  br label %rc_release_continue.8

rc_release_continue.8:                            ; preds = %rc_release.8, %str_concat.right.end.2
  %.271 = icmp eq ptr %.228, null
  br i1 %.271, label %rc_release_continue.9, label %rc_release.9

rc_release.9:                                     ; preds = %rc_release_continue.8
  %.273 = bitcast ptr %.228 to ptr
  call void @meteor_release(ptr %.273)
  br label %rc_release_continue.9

rc_release_continue.9:                            ; preds = %rc_release.9, %rc_release_continue.8
  %.276 = bitcast ptr %.206 to ptr
  %.277 = getelementptr i8, ptr %.276, i64 -16
  %.278 = bitcast ptr %.277 to ptr
  %.279 = getelementptr %meteor.header, ptr %.278, i64 0, i32 2
  %.280 = load i8, ptr %.279, align 1
  %.281 = and i8 %.280, 1
  %.282 = icmp ne i8 %.281, 0
  br i1 %.282, label %frozen.abort, label %frozen.continue

frozen.abort:                                     ; preds = %rc_release_continue.9
  call void @abort()
  unreachable

frozen.continue:                                  ; preds = %rc_release_continue.9
  %.286 = load ptr, ptr %.207, align 8
  %.287 = icmp ne ptr %.286, null
  br i1 %.287, label %frozen.continue.if, label %frozen.continue.endif

frozen.continue.if:                               ; preds = %frozen.continue
  %.289 = icmp eq ptr %.286, null
  br i1 %.289, label %rc_release_continue.10, label %rc_release.10

frozen.continue.endif:                            ; preds = %rc_release_continue.10, %frozen.continue
  %.295 = bitcast ptr %.244 to ptr
  call void @meteor_retain(ptr %.295)
  store ptr %.244, ptr %.207, align 8
  %.298 = icmp eq ptr %.244, null
  br i1 %.298, label %rc_release_continue.11, label %rc_release.11

rc_release.10:                                    ; preds = %frozen.continue.if
  %.291 = bitcast ptr %.286 to ptr
  call void @meteor_release(ptr %.291)
  br label %rc_release_continue.10

rc_release_continue.10:                           ; preds = %rc_release.10, %frozen.continue.if
  br label %frozen.continue.endif

rc_release.11:                                    ; preds = %frozen.continue.endif
  %.300 = bitcast ptr %.244 to ptr
  call void @meteor_release(ptr %.300)
  br label %rc_release_continue.11

rc_release_continue.11:                           ; preds = %rc_release.11, %frozen.continue.endif
  %.303 = call ptr @malloc(i64 40)
  %.304 = call ptr @memset(ptr %.303, i32 0, i64 40)
  %.305 = bitcast ptr %.303 to ptr
  call void @i64.array.init(ptr %.305)
  call void @i64.array.append(ptr %.305, i64 65)
  call void @i64.array.append(ptr %.305, i64 115)
  call void @i64.array.append(ptr %.305, i64 115)
  call void @i64.array.append(ptr %.305, i64 105)
  call void @i64.array.append(ptr %.305, i64 103)
  call void @i64.array.append(ptr %.305, i64 110)
  call void @i64.array.append(ptr %.305, i64 101)
  call void @i64.array.append(ptr %.305, i64 100)
  call void @print(ptr %.305)
  %.316 = icmp eq ptr %.305, null
  br i1 %.316, label %rc_release_continue.12, label %rc_release.12

rc_release.12:                                    ; preds = %rc_release_continue.11
  %.318 = bitcast ptr %.305 to ptr
  call void @meteor_release(ptr %.318)
  br label %rc_release_continue.12

rc_release_continue.12:                           ; preds = %rc_release.12, %rc_release_continue.11
  %.321 = load i64, ptr %i, align 4
  %addtmp = add i64 %.321, 1
  store i64 %addtmp, ptr %i, align 4
  %.323 = call ptr @malloc(i64 40)
  %.324 = call ptr @memset(ptr %.323, i32 0, i64 40)
  %.325 = bitcast ptr %.323 to ptr
  call void @i64.array.init(ptr %.325)
  call void @i64.array.append(ptr %.325, i64 83)
  call void @i64.array.append(ptr %.325, i64 99)
  call void @i64.array.append(ptr %.325, i64 111)
  call void @i64.array.append(ptr %.325, i64 112)
  call void @i64.array.append(ptr %.325, i64 101)
  call void @i64.array.append(ptr %.325, i64 32)
  call void @i64.array.append(ptr %.325, i64 101)
  call void @i64.array.append(ptr %.325, i64 110)
  call void @i64.array.append(ptr %.325, i64 100)
  call void @print(ptr %.325)
  %.337 = icmp eq ptr %.325, null
  br i1 %.337, label %rc_release_continue.13, label %rc_release.13

rc_release.13:                                    ; preds = %rc_release_continue.12
  %.339 = bitcast ptr %.325 to ptr
  call void @meteor_release(ptr %.339)
  br label %rc_release_continue.13

rc_release_continue.13:                           ; preds = %rc_release.13, %rc_release_continue.12
  br label %while.cond

rc_release.14:                                    ; preds = %exit
  %.347 = bitcast ptr %.344 to ptr
  %.348 = getelementptr i8, ptr %.347, i64 -16
  %.349 = bitcast ptr %.348 to ptr
  call void @meteor_release(ptr %.349)
  br label %rc_release_continue.14

rc_release_continue.14:                           ; preds = %rc_release.14, %exit
  ret void
}

!0 = !{}
