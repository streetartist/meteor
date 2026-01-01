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
%Header = type { ptr, ptr }
%Header.array = type { %meteor.header, i64, i64, ptr }
%HttpMethod = type { i8 }
%Request = type { ptr, ptr, ptr, ptr, ptr, ptr }
%HttpStatus = type { i8 }
%Response = type { ptr, ptr, ptr }
%Route = type { ptr, ptr, ptr }
%Middleware = type { ptr }
%Route.array = type { %meteor.header, i64, i64, ptr }
%Middleware.array = type { %meteor.header, i64, i64, ptr }
%Server = type { ptr, ptr, i64, ptr, ptr, ptr }

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
  %.3 = getelementptr %meteor.header, ptr %.1, i32 0, i32 3
  %.4 = load i8, ptr %.3, align 1
  br label %exit

exit:                                             ; preds = %entry
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
  %.3 = call ptr @malloc(i64 40)
  %.4 = bitcast ptr %.3 to ptr
  call void @i64.array.init(ptr %.4)
  %.6 = call ptr @malloc(i64 40)
  %.7 = bitcast ptr %.6 to ptr
  call void @i64.array.init(ptr %.7)
  %.9 = call ptr @malloc(i64 40)
  %.10 = bitcast ptr %.9 to ptr
  call void @i64.array.init(ptr %.10)
  %.12 = call ptr @malloc(i64 40)
  %.13 = bitcast ptr %.12 to ptr
  call void @i64.array.init(ptr %.13)
  %.15 = call ptr @malloc(i64 40)
  %.16 = bitcast ptr %.15 to ptr
  call void @i64.array.init(ptr %.16)
  %.18 = call ptr @malloc(i64 40)
  %.19 = bitcast ptr %.18 to ptr
  call void @i64.array.init(ptr %.19)
  %.21 = call ptr @malloc(i64 40)
  %.22 = bitcast ptr %.21 to ptr
  call void @i64.array.init(ptr %.22)
  %.24 = call ptr @malloc(i64 40)
  %.25 = bitcast ptr %.24 to ptr
  call void @Header.array.init(ptr %.25)
  %.27 = call ptr @malloc(i64 40)
  %.28 = bitcast ptr %.27 to ptr
  call void @Header.array.init(ptr %.28)
  %.30 = call ptr @malloc(i64 40)
  %.31 = bitcast ptr %.30 to ptr
  call void @i64.array.init(ptr %.31)
  %.33 = call ptr @malloc(i64 40)
  %.34 = bitcast ptr %.33 to ptr
  call void @i64.array.init(ptr %.34)
  %.36 = call ptr @malloc(i64 40)
  %.37 = bitcast ptr %.36 to ptr
  call void @i64.array.init(ptr %.37)
  %.39 = call ptr @malloc(i64 40)
  %.40 = bitcast ptr %.39 to ptr
  call void @i64.array.init(ptr %.40)
  %.42 = call ptr @malloc(i64 40)
  %.43 = bitcast ptr %.42 to ptr
  call void @i64.array.init(ptr %.43)
  %.45 = call ptr @malloc(i64 40)
  %.46 = bitcast ptr %.45 to ptr
  call void @Header.array.init(ptr %.46)
  %.48 = call ptr @malloc(i64 40)
  %.49 = bitcast ptr %.48 to ptr
  call void @i64.array.init(ptr %.49)
  %.51 = call ptr @malloc(i64 40)
  %.52 = bitcast ptr %.51 to ptr
  call void @i64.array.init(ptr %.52)
  %.54 = call ptr @malloc(i64 40)
  %.55 = bitcast ptr %.54 to ptr
  call void @i64.array.init(ptr %.55)
  %.57 = call ptr @malloc(i64 40)
  %.58 = bitcast ptr %.57 to ptr
  call void @i64.array.init(ptr %.58)
  %.60 = call ptr @malloc(i64 40)
  %.61 = bitcast ptr %.60 to ptr
  call void @i64.array.init(ptr %.61)
  %.63 = call ptr @malloc(i64 40)
  %.64 = bitcast ptr %.63 to ptr
  call void @i64.array.init(ptr %.64)
  %.66 = call ptr @malloc(i64 40)
  %.67 = bitcast ptr %.66 to ptr
  call void @i64.array.init(ptr %.67)
  %.69 = call ptr @malloc(i64 40)
  %.70 = bitcast ptr %.69 to ptr
  call void @i64.array.init(ptr %.70)
  %.72 = call ptr @malloc(i64 40)
  %.73 = bitcast ptr %.72 to ptr
  call void @i64.array.init(ptr %.73)
  %.75 = call ptr @malloc(i64 40)
  %.76 = bitcast ptr %.75 to ptr
  call void @i64.array.init(ptr %.76)
  %.78 = call ptr @malloc(i64 40)
  %.79 = bitcast ptr %.78 to ptr
  call void @i64.array.init(ptr %.79)
  %.81 = call ptr @malloc(i64 40)
  %.82 = bitcast ptr %.81 to ptr
  call void @i64.array.init(ptr %.82)
  %.84 = call ptr @malloc(i64 40)
  %.85 = bitcast ptr %.84 to ptr
  call void @i64.array.init(ptr %.85)
  %.87 = call ptr @malloc(i64 40)
  %.88 = bitcast ptr %.87 to ptr
  call void @Route.array.init(ptr %.88)
  %.90 = call ptr @malloc(i64 40)
  %.91 = bitcast ptr %.90 to ptr
  call void @Middleware.array.init(ptr %.91)
  %.93 = call ptr @malloc(i64 40)
  %.94 = bitcast ptr %.93 to ptr
  call void @i64.array.init(ptr %.94)
  %.96 = call ptr @malloc(i64 40)
  %.97 = bitcast ptr %.96 to ptr
  call void @i64.array.init(ptr %.97)
  %.99 = call ptr @malloc(i64 40)
  %.100 = bitcast ptr %.99 to ptr
  call void @i64.array.init(ptr %.100)
  %.102 = call ptr @malloc(i64 40)
  %.103 = bitcast ptr %.102 to ptr
  call void @i64.array.init(ptr %.103)
  %.105 = call ptr @malloc(i64 40)
  %.106 = bitcast ptr %.105 to ptr
  call void @i64.array.init(ptr %.106)
  %.108 = call ptr @malloc(i64 40)
  %.109 = bitcast ptr %.108 to ptr
  call void @i64.array.init(ptr %.109)
  %.111 = call ptr @malloc(i64 40)
  %.112 = bitcast ptr %.111 to ptr
  call void @i64.array.init(ptr %.112)
  %.114 = call ptr @malloc(i64 40)
  %.115 = bitcast ptr %.114 to ptr
  call void @i64.array.init(ptr %.115)
  call void @mymain()
  br label %exit

exit:                                             ; preds = %entry
  ret i64 0
}

declare void @__va_start(ptr)

declare void @__security_init_cookie()

declare void @__security_check_cookie(i64)

declare void @__report_gsfailure(i64)

declare i64 @__C_specific_handler(ptr, ptr, ptr, ptr)

declare i64 @_exception_code()

declare ptr @_exception_info()

declare i32 @_abnormal_termination()

declare void @_invalid_parameter_noinfo()

declare void @_invalid_parameter_noinfo_noreturn()

declare void @_invoke_watson(ptr, ptr, ptr, i64, i64)

declare ptr @__pctype_func()

declare ptr @__pwctype_func()

declare i32 @iswalnum(i64)

declare i32 @iswalpha(i64)

declare i32 @iswascii(i64)

declare i32 @iswblank(i64)

declare i32 @iswcntrl(i64)

declare i32 @iswdigit(i64)

declare i32 @iswgraph(i64)

declare i32 @iswlower(i64)

declare i32 @iswprint(i64)

declare i32 @iswpunct(i64)

declare i32 @iswspace(i64)

declare i32 @iswupper(i64)

declare i32 @iswxdigit(i64)

declare i32 @__iswcsymf(i64)

declare i32 @__iswcsym(i64)

declare i32 @_iswalnum_l(i64, ptr)

declare i32 @_iswalpha_l(i64, ptr)

declare i32 @_iswblank_l(i64, ptr)

declare i32 @_iswcntrl_l(i64, ptr)

declare i32 @_iswdigit_l(i64, ptr)

declare i32 @_iswgraph_l(i64, ptr)

declare i32 @_iswlower_l(i64, ptr)

declare i32 @_iswprint_l(i64, ptr)

declare i32 @_iswpunct_l(i64, ptr)

declare i32 @_iswspace_l(i64, ptr)

declare i32 @_iswupper_l(i64, ptr)

declare i32 @_iswxdigit_l(i64, ptr)

declare i32 @_iswcsymf_l(i64, ptr)

declare i32 @_iswcsym_l(i64, ptr)

declare i64 @towupper(i64)

declare i64 @towlower(i64)

declare i32 @iswctype(i64, i64)

declare i64 @_towupper_l(i64, ptr)

declare i64 @_towlower_l(i64, ptr)

declare i32 @_iswctype_l(i64, i64, ptr)

declare i32 @isleadbyte(i32)

declare i32 @_isleadbyte_l(i32, ptr)

declare i32 @is_wctype(i64, i64)

declare i32 @_isctype(i32, i32)

declare i32 @_isctype_l(i32, i32, ptr)

declare i32 @isalpha(i32)

declare i32 @_isalpha_l(i32, ptr)

declare i32 @isupper(i32)

declare i32 @_isupper_l(i32, ptr)

declare i32 @islower(i32)

declare i32 @_islower_l(i32, ptr)

declare i32 @isdigit(i32)

declare i32 @_isdigit_l(i32, ptr)

declare i32 @isxdigit(i32)

declare i32 @_isxdigit_l(i32, ptr)

declare i32 @isspace(i32)

declare i32 @_isspace_l(i32, ptr)

declare i32 @ispunct(i32)

declare i32 @_ispunct_l(i32, ptr)

declare i32 @isblank(i32)

declare i32 @_isblank_l(i32, ptr)

declare i32 @isalnum(i32)

declare i32 @_isalnum_l(i32, ptr)

declare i32 @isprint(i32)

declare i32 @_isprint_l(i32, ptr)

declare i32 @isgraph(i32)

declare i32 @_isgraph_l(i32, ptr)

declare i32 @iscntrl(i32)

declare i32 @_iscntrl_l(i32, ptr)

declare i32 @toupper(i32)

declare i32 @tolower(i32)

declare i32 @_tolower(i32)

declare i32 @_tolower_l(i32, ptr)

declare i32 @_toupper(i32)

declare i32 @_toupper_l(i32, ptr)

declare i32 @__isascii(i32)

declare i32 @__toascii(i32)

declare i32 @__iscsymf(i32)

declare i32 @__iscsym(i32)

declare i32 @__acrt_locale_get_ctype_array_value(ptr, i32, i32)

declare i32 @___mb_cur_max_func()

declare i32 @___mb_cur_max_l_func(ptr)

declare i32 @__ascii_tolower(i32)

declare i32 @__ascii_toupper(i32)

declare i32 @__ascii_iswalpha(i32)

declare i32 @__ascii_iswdigit(i32)

declare i32 @__ascii_towlower(i32)

declare i32 @__ascii_towupper(i32)

declare ptr @__acrt_get_locale_data_prefix(ptr)

declare i32 @_chvalidchk_l(i32, i32, ptr)

declare i32 @_ischartype_l(i32, i32, ptr)

declare i64 @HandleToULong(ptr)

declare i64 @HandleToLong(ptr)

declare ptr @ULongToHandle(i64)

declare ptr @LongToHandle(i64)

declare i64 @PtrToUlong(ptr)

declare i64 @PtrToUint(ptr)

declare i64 @PtrToUshort(ptr)

declare i64 @PtrToLong(ptr)

declare i32 @PtrToInt(ptr)

declare i64 @PtrToShort(ptr)

declare ptr @IntToPtr(i32)

declare ptr @UIntToPtr(i64)

declare ptr @LongToPtr(i64)

declare ptr @ULongToPtr(i64)

declare ptr @Ptr32ToPtr(ptr)

declare ptr @Handle32ToHandle(ptr)

declare ptr @PtrToPtr32(ptr)

declare i64 @_rotl8(i64, i64)

declare i64 @_rotl16(i64, i64)

declare i64 @_rotr8(i64, i64)

declare i64 @_rotr16(i64, i64)

declare i64 @_rotl(i64, i32)

declare i64 @_rotl64(i64, i32)

declare i64 @_rotr(i64, i32)

declare i64 @_rotr64(i64, i32)

declare ptr @_errno()

declare i32 @_set_errno(i32)

declare i32 @_get_errno(ptr)

declare ptr @__doserrno()

declare i32 @_set_doserrno(i64)

declare i32 @_get_doserrno(ptr)

declare ptr @memchr(ptr, i32, i64)

declare i32 @memcmp(ptr, ptr, i64)

declare ptr @memcpy(ptr, ptr, i64)

declare ptr @memmove(ptr, ptr, i64)

declare ptr @memset(ptr, i32, i64)

declare ptr @strchr(ptr, i32)

declare ptr @strrchr(ptr, i32)

declare ptr @strstr(ptr, ptr)

declare ptr @wcschr(ptr, i64)

declare ptr @wcsrchr(ptr, i64)

declare ptr @wcsstr(ptr, ptr)

declare i32 @memcpy_s(ptr, i64, ptr, i64)

declare i32 @memmove_s(ptr, i64, ptr, i64)

declare i32 @_memicmp(ptr, ptr, i64)

declare i32 @_memicmp_l(ptr, ptr, i64, ptr)

declare ptr @memccpy(ptr, ptr, i32, i64)

declare i32 @memicmp(ptr, ptr, i64)

declare i32 @wcscat_s(ptr, i64, ptr)

declare i32 @wcscpy_s(ptr, i64, ptr)

declare i32 @wcsncat_s(ptr, i64, ptr, i64)

declare i32 @wcsncpy_s(ptr, i64, ptr, i64)

declare ptr @wcstok_s(ptr, ptr, ptr)

declare ptr @_wcsdup(ptr)

declare ptr @wcscat(ptr, ptr)

declare i32 @wcscmp(ptr, ptr)

declare ptr @wcscpy(ptr, ptr)

declare i64 @wcscspn(ptr, ptr)

declare i64 @wcslen(ptr)

declare i64 @wcsnlen(ptr, i64)

declare i64 @wcsnlen_s(ptr, i64)

declare ptr @wcsncat(ptr, ptr, i64)

declare i32 @wcsncmp(ptr, ptr, i64)

declare ptr @wcsncpy(ptr, ptr, i64)

declare ptr @wcspbrk(ptr, ptr)

declare i64 @wcsspn(ptr, ptr)

declare ptr @wcstok(ptr, ptr, ptr)

declare ptr @_wcstok(ptr, ptr)

declare ptr @_wcserror(i32)

declare i32 @_wcserror_s(ptr, i64, i32)

declare ptr @__wcserror(ptr)

declare i32 @__wcserror_s(ptr, i64, ptr)

declare i32 @_wcsicmp(ptr, ptr)

declare i32 @_wcsicmp_l(ptr, ptr, ptr)

declare i32 @_wcsnicmp(ptr, ptr, i64)

declare i32 @_wcsnicmp_l(ptr, ptr, i64, ptr)

declare i32 @_wcsnset_s(ptr, i64, i64, i64)

declare ptr @_wcsnset(ptr, i64, i64)

declare ptr @_wcsrev(ptr)

declare i32 @_wcsset_s(ptr, i64, i64)

declare ptr @_wcsset(ptr, i64)

declare i32 @_wcslwr_s(ptr, i64)

declare ptr @_wcslwr(ptr)

declare i32 @_wcslwr_s_l(ptr, i64, ptr)

declare ptr @_wcslwr_l(ptr, ptr)

declare i32 @_wcsupr_s(ptr, i64)

declare ptr @_wcsupr(ptr)

declare i32 @_wcsupr_s_l(ptr, i64, ptr)

declare ptr @_wcsupr_l(ptr, ptr)

declare i64 @wcsxfrm(ptr, ptr, i64)

declare i64 @_wcsxfrm_l(ptr, ptr, i64, ptr)

declare i32 @wcscoll(ptr, ptr)

declare i32 @_wcscoll_l(ptr, ptr, ptr)

declare i32 @_wcsicoll(ptr, ptr)

declare i32 @_wcsicoll_l(ptr, ptr, ptr)

declare i32 @_wcsncoll(ptr, ptr, i64)

declare i32 @_wcsncoll_l(ptr, ptr, i64, ptr)

declare i32 @_wcsnicoll(ptr, ptr, i64)

declare i32 @_wcsnicoll_l(ptr, ptr, i64, ptr)

declare ptr @wcsdup(ptr)

declare i32 @wcsicmp(ptr, ptr)

declare i32 @wcsnicmp(ptr, ptr, i64)

declare ptr @wcsnset(ptr, i64, i64)

declare ptr @wcsrev(ptr)

declare ptr @wcsset(ptr, i64)

declare ptr @wcslwr(ptr)

declare ptr @wcsupr(ptr)

declare i32 @wcsicoll(ptr, ptr)

declare i32 @strcpy_s(ptr, i64, ptr)

declare i32 @strcat_s(ptr, i64, ptr)

declare i32 @strerror_s(ptr, i64, i32)

declare i32 @strncat_s(ptr, i64, ptr, i64)

declare i32 @strncpy_s(ptr, i64, ptr, i64)

declare ptr @strtok_s(ptr, ptr, ptr)

declare ptr @_memccpy(ptr, ptr, i32, i64)

declare ptr @strcat(ptr, ptr)

declare i32 @strcmp(ptr, ptr)

declare i32 @_strcmpi(ptr, ptr)

declare i32 @strcoll(ptr, ptr)

declare i32 @_strcoll_l(ptr, ptr, ptr)

declare ptr @strcpy(ptr, ptr)

declare i64 @strcspn(ptr, ptr)

declare ptr @_strdup(ptr)

declare ptr @_strerror(ptr)

declare i32 @_strerror_s(ptr, i64, ptr)

declare ptr @strerror(i32)

declare i32 @_stricmp(ptr, ptr)

declare i32 @_stricoll(ptr, ptr)

declare i32 @_stricoll_l(ptr, ptr, ptr)

declare i32 @_stricmp_l(ptr, ptr, ptr)

declare i64 @strlen(ptr)

declare i32 @_strlwr_s(ptr, i64)

declare ptr @_strlwr(ptr)

declare i32 @_strlwr_s_l(ptr, i64, ptr)

declare ptr @_strlwr_l(ptr, ptr)

declare ptr @strncat(ptr, ptr, i64)

declare i32 @strncmp(ptr, ptr, i64)

declare i32 @_strnicmp(ptr, ptr, i64)

declare i32 @_strnicmp_l(ptr, ptr, i64, ptr)

declare i32 @_strnicoll(ptr, ptr, i64)

declare i32 @_strnicoll_l(ptr, ptr, i64, ptr)

declare i32 @_strncoll(ptr, ptr, i64)

declare i32 @_strncoll_l(ptr, ptr, i64, ptr)

declare i64 @__strncnt(ptr, i64)

declare ptr @strncpy(ptr, ptr, i64)

declare i64 @strnlen(ptr, i64)

declare i64 @strnlen_s(ptr, i64)

declare i32 @_strnset_s(ptr, i64, i32, i64)

declare ptr @_strnset(ptr, i32, i64)

declare ptr @strpbrk(ptr, ptr)

declare ptr @_strrev(ptr)

declare i32 @_strset_s(ptr, i64, i32)

declare ptr @_strset(ptr, i32)

declare i64 @strspn(ptr, ptr)

declare ptr @strtok(ptr, ptr)

declare i32 @_strupr_s(ptr, i64)

declare ptr @_strupr(ptr)

declare i32 @_strupr_s_l(ptr, i64, ptr)

declare ptr @_strupr_l(ptr, ptr)

declare i64 @strxfrm(ptr, ptr, i64)

declare i64 @_strxfrm_l(ptr, ptr, i64, ptr)

declare ptr @strdup(ptr)

declare i32 @strcmpi(ptr, ptr)

declare i32 @stricmp(ptr, ptr)

declare ptr @strlwr(ptr)

declare i32 @strnicmp(ptr, ptr, i64)

declare ptr @strnset(ptr, i32, i64)

declare ptr @strrev(ptr)

declare ptr @strset(ptr, i32)

declare ptr @strupr(ptr)

declare i64 @_bittest(ptr, i64)

declare i64 @_bittestandcomplement(ptr, i64)

declare i64 @_bittestandset(ptr, i64)

declare i64 @_bittestandreset(ptr, i64)

declare i64 @_interlockedbittestandset(ptr, i64)

declare i64 @_interlockedbittestandreset(ptr, i64)

declare i64 @_bittest64(ptr, i64)

declare i64 @_bittestandcomplement64(ptr, i64)

declare i64 @_bittestandset64(ptr, i64)

declare i64 @_bittestandreset64(ptr, i64)

declare i64 @_interlockedbittestandset64(ptr, i64)

declare i64 @_interlockedbittestandreset64(ptr, i64)

declare i64 @_BitScanForward(ptr, i64)

declare i64 @_BitScanReverse(ptr, i64)

declare i64 @_BitScanForward64(ptr, i64)

declare i64 @_BitScanReverse64(ptr, i64)

declare i64 @_InterlockedIncrement16(ptr)

declare i64 @_InterlockedDecrement16(ptr)

declare i64 @_InterlockedCompareExchange16(ptr, i64, i64)

declare i64 @_InterlockedAnd(ptr, i64)

declare i64 @_InterlockedOr(ptr, i64)

declare i64 @_InterlockedXor(ptr, i64)

declare i64 @_InterlockedAnd64(ptr, i64)

declare i64 @_InterlockedOr64(ptr, i64)

declare i64 @_InterlockedXor64(ptr, i64)

declare i64 @_InterlockedIncrement(ptr)

declare i64 @_InterlockedDecrement(ptr)

declare i64 @_InterlockedExchange(ptr, i64)

declare i64 @_InterlockedExchangeAdd(ptr, i64)

declare i64 @_InlineInterlockedAdd(ptr, i64)

declare i64 @_InterlockedCompareExchange(ptr, i64, i64)

declare i64 @_InterlockedIncrement64(ptr)

declare i64 @_InterlockedDecrement64(ptr)

declare i64 @_InterlockedExchange64(ptr, i64)

declare i64 @_InterlockedExchangeAdd64(ptr, i64)

declare i64 @_InlineInterlockedAdd64(ptr, i64)

declare i64 @_InterlockedCompareExchange64(ptr, i64, i64)

declare i64 @_InterlockedCompareExchange128(ptr, i64, i64, ptr)

declare ptr @_InterlockedCompareExchangePointer(ptr, ptr, ptr)

declare ptr @_InterlockedExchangePointer(ptr, ptr)

declare i64 @_InterlockedExchange8(ptr, i64)

declare i64 @_InterlockedExchange16(ptr, i64)

declare i64 @_InterlockedExchangeAdd8(ptr, i64)

declare i64 @_InterlockedAnd8(ptr, i64)

declare i64 @_InterlockedOr8(ptr, i64)

declare i64 @_InterlockedXor8(ptr, i64)

declare i64 @_InterlockedAnd16(ptr, i64)

declare i64 @_InterlockedOr16(ptr, i64)

declare i64 @_InterlockedXor16(ptr, i64)

declare void @__cpuidex(i64, i32, i32)

declare void @_mm_clflush(ptr)

declare void @_ReadWriteBarrier()

declare void @__faststorefence()

declare void @_mm_lfence()

declare void @_mm_mfence()

declare void @_mm_sfence()

declare void @_mm_pause()

declare void @_mm_prefetch(ptr, i32)

declare void @_m_prefetchw(ptr)

declare i64 @_mm_getcsr()

declare void @_mm_setcsr(i64)

declare i64 @__getcallerseflags()

declare i64 @__segmentlimit(i64)

declare i64 @__readpmc(i64)

declare i64 @__rdtsc()

declare void @__movsb(ptr, ptr, i64)

declare void @__movsw(ptr, ptr, i64)

declare void @__movsd(ptr, ptr, i64)

declare void @__movsq(ptr, ptr, i64)

declare void @__stosb(ptr, i64, i64)

declare void @__stosw(ptr, i64, i64)

declare void @__stosd(ptr, i64, i64)

declare void @__stosq(ptr, i64, i64)

declare i64 @__mulh(i64, i64)

declare i64 @__umulh(i64, i64)

declare i64 @__popcnt64(i64)

declare i64 @__shiftleft128(i64, i64, i64)

declare i64 @__shiftright128(i64, i64, i64)

declare i64 @_mul128(i64, i64, ptr)

declare i64 @UnsignedMultiply128(i64, i64, ptr)

declare i64 @_umul128(i64, i64, ptr)

declare i64 @MultiplyExtract128(i64, i64, i64)

declare i64 @UnsignedMultiplyExtract128(i64, i64, i64)

declare i64 @__readgsbyte(i64)

declare i64 @__readgsword(i64)

declare i64 @__readgsdword(i64)

declare i64 @__readgsqword(i64)

declare void @__writegsbyte(i64, i64)

declare void @__writegsword(i64, i64)

declare void @__writegsdword(i64, i64)

declare void @__writegsqword(i64, i64)

declare void @__incgsbyte(i64)

declare void @__addgsbyte(i64, i64)

declare void @__incgsword(i64)

declare void @__addgsword(i64, i64)

declare void @__incgsdword(i64)

declare void @__addgsdword(i64, i64)

declare void @__incgsqword(i64)

declare void @__addgsqword(i64, i64)

declare void @__int2c()

declare i64 @ReadAcquire8(ptr)

declare i64 @ReadNoFence8(ptr)

declare void @WriteRelease8(ptr, i64)

declare void @WriteNoFence8(ptr, i64)

declare i64 @ReadAcquire16(ptr)

declare i64 @ReadNoFence16(ptr)

declare void @WriteRelease16(ptr, i64)

declare void @WriteNoFence16(ptr, i64)

declare i64 @ReadAcquire(ptr)

declare i64 @ReadNoFence(ptr)

declare void @WriteRelease(ptr, i64)

declare void @WriteNoFence(ptr, i64)

declare i64 @ReadAcquire64(ptr)

declare i64 @ReadNoFence64(ptr)

declare void @WriteRelease64(ptr, i64)

declare void @WriteNoFence64(ptr, i64)

declare void @BarrierAfterRead()

declare i64 @ReadRaw8(ptr)

declare void @WriteRaw8(ptr, i64)

declare i64 @ReadRaw16(ptr)

declare void @WriteRaw16(ptr, i64)

declare i64 @ReadRaw(ptr)

declare void @WriteRaw(ptr, i64)

declare i64 @ReadRaw64(ptr)

declare void @WriteRaw64(ptr, i64)

declare i64 @AddRaw(ptr, i64)

declare i64 @AddULongRaw(ptr, i64)

declare i64 @IncrementRaw(ptr)

declare i64 @IncrementULongRaw(ptr)

declare i64 @ReadUCharAcquire(ptr)

declare i64 @ReadUCharNoFence(ptr)

declare i64 @ReadBooleanAcquire(ptr)

declare i64 @ReadBooleanNoFence(ptr)

declare i64 @ReadBooleanRaw(ptr)

declare i64 @ReadUCharRaw(ptr)

declare void @WriteUCharRelease(ptr, i64)

declare void @WriteUCharNoFence(ptr, i64)

declare void @WriteBooleanRelease(ptr, i64)

declare void @WriteBooleanNoFence(ptr, i64)

declare void @WriteUCharRaw(ptr, i64)

declare i64 @ReadUShortAcquire(ptr)

declare i64 @ReadUShortNoFence(ptr)

declare i64 @ReadUShortRaw(ptr)

declare void @WriteUShortRelease(ptr, i64)

declare void @WriteUShortNoFence(ptr, i64)

declare void @WriteUShortRaw(ptr, i64)

declare i64 @ReadULongAcquire(ptr)

declare i64 @ReadULongNoFence(ptr)

declare i64 @ReadULongRaw(ptr)

declare void @WriteULongRelease(ptr, i64)

declare void @WriteULongNoFence(ptr, i64)

declare void @WriteULongRaw(ptr, i64)

declare i32 @ReadInt32Acquire(ptr)

declare i32 @ReadInt32NoFence(ptr)

declare i32 @ReadInt32Raw(ptr)

declare void @WriteInt32Release(ptr, i32)

declare void @WriteInt32NoFence(ptr, i32)

declare void @WriteInt32Raw(ptr, i32)

declare i64 @ReadUInt32Acquire(ptr)

declare i64 @ReadUInt32NoFence(ptr)

declare i64 @ReadUInt32Raw(ptr)

declare void @WriteUInt32Release(ptr, i64)

declare void @WriteUInt32NoFence(ptr, i64)

declare void @WriteUInt32Raw(ptr, i64)

declare i64 @ReadULong64Acquire(ptr)

declare i64 @ReadULong64NoFence(ptr)

declare i64 @ReadULong64Raw(ptr)

declare void @WriteULong64Release(ptr, i64)

declare void @WriteULong64NoFence(ptr, i64)

declare void @WriteULong64Raw(ptr, i64)

declare i64 @AddRaw64(ptr, i64)

declare i64 @AddULong64Raw(ptr, i64)

declare i64 @IncrementRaw64(ptr)

declare i64 @IncrementULong64Raw(ptr)

declare ptr @ReadPointerAcquire(ptr)

declare ptr @ReadPointerNoFence(ptr)

declare ptr @ReadPointerRaw(ptr)

declare void @WritePointerRelease(ptr, ptr)

declare void @WritePointerNoFence(ptr, ptr)

declare void @WritePointerRaw(ptr, ptr)

declare i64 @RtlCaptureStackBackTrace(i64, i64, ptr, ptr)

declare void @RtlCaptureContext(ptr)

declare void @RtlCaptureContext2(ptr)

declare void @RtlUnwind(ptr, ptr, ptr, ptr)

declare i64 @RtlAddFunctionTable(ptr, i64, i64)

declare i64 @RtlDeleteFunctionTable(ptr)

declare i64 @RtlInstallFunctionTableCallback(i64, i64, i64, ptr, ptr, ptr)

declare i64 @RtlAddGrowableFunctionTable(ptr, ptr, i64, i64, i64, i64)

declare void @RtlGrowFunctionTable(ptr, i64)

declare void @RtlDeleteGrowableFunctionTable(ptr)

declare ptr @RtlLookupFunctionEntry(i64, ptr, ptr)

declare void @RtlRestoreContext(ptr, ptr)

declare void @RtlUnwindEx(ptr, ptr, ptr, ptr, ptr, ptr)

declare ptr @RtlVirtualUnwind(i64, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare void @RtlRaiseException(ptr)

declare ptr @RtlPcToFileHeader(ptr, ptr)

declare i64 @RtlCompareMemory(ptr, ptr, i64)

declare void @RtlInitializeSListHead(ptr)

declare ptr @RtlFirstEntrySList(ptr)

declare ptr @RtlInterlockedPopEntrySList(ptr)

declare ptr @RtlInterlockedPushEntrySList(ptr, ptr)

declare ptr @RtlInterlockedPushListSListEx(ptr, ptr, ptr, i64)

declare ptr @RtlInterlockedFlushSList(ptr)

declare i64 @RtlQueryDepthSList(ptr)

declare i64 @RtlGetReturnAddressHijackTarget()

declare void @__fastfail(i64)

declare i64 @HEAP_MAKE_TAG_FLAGS(i64, i64)

declare ptr @RtlCopyDeviceMemory(ptr, ptr, i64)

declare ptr @RtlCopyVolatileMemory(ptr, ptr, i64)

declare ptr @RtlMoveVolatileMemory(ptr, ptr, i64)

declare ptr @RtlSetVolatileMemory(ptr, i32, i64)

declare ptr @RtlFillVolatileMemory(ptr, i64, i32)

declare ptr @RtlZeroVolatileMemory(ptr, i64)

declare ptr @RtlSecureZeroMemory2(ptr, i64)

declare ptr @RtlFillDeviceMemory(ptr, i64, i32)

declare ptr @RtlZeroDeviceMemory(ptr, i64)

declare i32 @RtlConstantTimeEqualMemory(ptr, ptr, i64)

declare ptr @RtlSecureZeroMemory(ptr, i64)

declare i64 @VerSetConditionMask(i64, i64, i64)

declare i64 @RtlGetProductInfo(i64, i64, i64, i64, ptr)

declare i64 @RtlCrc32(ptr, i64, i64)

declare i64 @RtlCrc64(ptr, i64, i64)

declare i64 @RtlOsDeploymentState(i64)

declare i64 @RtlGetNonVolatileToken(ptr, i64, ptr)

declare i64 @RtlFreeNonVolatileToken(ptr)

declare i64 @RtlFlushNonVolatileMemory(ptr, ptr, i64, i64)

declare i64 @RtlDrainNonVolatileFlush(ptr)

declare i64 @RtlWriteNonVolatileMemory(ptr, ptr, ptr, i64, i64)

declare i64 @RtlFillNonVolatileMemory(ptr, ptr, i64, i64, i64)

declare i64 @RtlFlushNonVolatileMemoryRanges(ptr, ptr, i64, i64)

declare i64 @RtlInitializeCorrelationVector(ptr, i32, ptr)

declare i64 @RtlIncrementCorrelationVector(ptr)

declare i64 @RtlExtendCorrelationVector(ptr)

declare i64 @RtlValidateCorrelationVector(ptr)

declare void @CUSTOM_SYSTEM_EVENT_TRIGGER_INIT(ptr, ptr)

declare i64 @RtlRaiseCustomSystemEventTrigger(ptr)

declare i64 @RtlIsZeroMemory(ptr, i64)

declare i64 @RtlNormalizeSecurityDescriptor(ptr, i64, ptr, ptr, i64)

declare i64 @RtlGetSystemGlobalData(i64, ptr, i64)

declare i64 @RtlSetSystemGlobalData(i64, ptr, i64)

declare void @RtlGetDeviceFamilyInfoEnum(ptr, ptr, ptr)

declare i64 @RtlConvertDeviceFamilyInfoToString(ptr, ptr, ptr, ptr)

declare i64 @RtlSwitchedVVI(ptr, i64, i64)

declare void @TpInitializeCallbackEnviron(ptr)

declare void @TpSetCallbackThreadpool(ptr, ptr)

declare void @TpSetCallbackCleanupGroup(ptr, ptr, ptr)

declare void @TpSetCallbackActivationContext(ptr, ptr)

declare void @TpSetCallbackNoActivationContext(ptr)

declare void @TpSetCallbackLongFunction(ptr)

declare void @TpSetCallbackRaceWithDll(ptr, ptr)

declare void @TpSetCallbackFinalizationCallback(ptr, ptr)

declare void @TpSetCallbackPriority(ptr, i64)

declare void @TpSetCallbackPersistent(ptr)

declare void @TpDestroyCallbackEnviron(ptr)

declare ptr @NtCurrentTeb()

declare i64 @NtReadCurrentTebByte(i64)

declare i64 @NtReadCurrentTebUshort(i64)

declare i64 @NtReadCurrentTebUlong(i64)

declare i64 @NtReadCurrentTebUlongPtr(i64)

declare ptr @NtReadCurrentTebPVOID(i64)

declare i64 @NtReadCurrentTebUlonglong(i64)

declare ptr @GetCurrentFiber()

declare ptr @GetFiberData()

declare i32 @IsApiSetImplemented(ptr)

declare i64 @GetApiSetModuleBaseName(ptr, i64, ptr, ptr)

declare i32 @SetEnvironmentStringsW(ptr)

declare ptr @GetStdHandle(i64)

declare i32 @SetStdHandle(i64, ptr)

declare i32 @SetStdHandleEx(i64, ptr, ptr)

declare ptr @GetCommandLineA()

declare ptr @GetCommandLineW()

declare ptr @GetEnvironmentStrings()

declare ptr @GetEnvironmentStringsW()

declare i32 @FreeEnvironmentStringsA(ptr)

declare i32 @FreeEnvironmentStringsW(ptr)

declare i64 @GetEnvironmentVariableA(ptr, ptr, i64)

declare i64 @GetEnvironmentVariableW(ptr, ptr, i64)

declare i32 @SetEnvironmentVariableA(ptr, ptr)

declare i32 @SetEnvironmentVariableW(ptr, ptr)

declare i64 @ExpandEnvironmentStringsA(ptr, ptr, i64)

declare i64 @ExpandEnvironmentStringsW(ptr, ptr, i64)

declare i32 @SetCurrentDirectoryA(ptr)

declare i32 @SetCurrentDirectoryW(ptr)

declare i64 @GetCurrentDirectoryA(i64, ptr)

declare i64 @GetCurrentDirectoryW(i64, ptr)

declare i64 @SearchPathW(ptr, ptr, ptr, i64, ptr, ptr)

declare i64 @SearchPathA(ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @NeedCurrentDirectoryForExePathA(ptr)

declare i32 @NeedCurrentDirectoryForExePathW(ptr)

declare i64 @CompareFileTime(ptr, ptr)

declare i32 @CreateDirectoryA(ptr, ptr)

declare i32 @CreateDirectoryW(ptr, ptr)

declare ptr @CreateFileA(ptr, i64, i64, ptr, i64, i64, ptr)

declare ptr @CreateFileW(ptr, i64, i64, ptr, i64, i64, ptr)

declare i32 @DefineDosDeviceW(i64, ptr, ptr)

declare i32 @DeleteFileA(ptr)

declare i32 @DeleteFileW(ptr)

declare i32 @DeleteVolumeMountPointW(ptr)

declare i32 @FileTimeToLocalFileTime(ptr, ptr)

declare i32 @FindClose(ptr)

declare i32 @FindCloseChangeNotification(ptr)

declare ptr @FindFirstChangeNotificationA(ptr, i32, i64)

declare ptr @FindFirstChangeNotificationW(ptr, i32, i64)

declare ptr @FindFirstFileA(ptr, ptr)

declare ptr @FindFirstFileW(ptr, ptr)

declare ptr @FindFirstFileExA(ptr, i64, ptr, i64, ptr, i64)

declare ptr @FindFirstFileExW(ptr, i64, ptr, i64, ptr, i64)

declare ptr @FindFirstVolumeW(ptr, i64)

declare i32 @FindNextChangeNotification(ptr)

declare i32 @FindNextFileA(ptr, ptr)

declare i32 @FindNextFileW(ptr, ptr)

declare i32 @FindNextVolumeW(ptr, ptr, i64)

declare i32 @FindVolumeClose(ptr)

declare i32 @FlushFileBuffers(ptr)

declare i32 @GetDiskFreeSpaceA(ptr, ptr, ptr, ptr, ptr)

declare i32 @GetDiskFreeSpaceW(ptr, ptr, ptr, ptr, ptr)

declare i32 @GetDiskFreeSpaceExA(ptr, ptr, ptr, ptr)

declare i32 @GetDiskFreeSpaceExW(ptr, ptr, ptr, ptr)

declare i64 @GetDiskSpaceInformationA(ptr, ptr)

declare i64 @GetDiskSpaceInformationW(ptr, ptr)

declare i64 @GetDriveTypeA(ptr)

declare i64 @GetDriveTypeW(ptr)

declare i64 @GetFileAttributesA(ptr)

declare i64 @GetFileAttributesW(ptr)

declare i32 @GetFileAttributesExA(ptr, i64, ptr)

declare i32 @GetFileAttributesExW(ptr, i64, ptr)

declare i32 @GetFileInformationByHandle(ptr, ptr)

declare i64 @GetFileSize(ptr, ptr)

declare i32 @GetFileSizeEx(ptr, ptr)

declare i64 @GetFileType(ptr)

declare i64 @GetFinalPathNameByHandleA(ptr, ptr, i64, i64)

declare i64 @GetFinalPathNameByHandleW(ptr, ptr, i64, i64)

declare i32 @GetFileTime(ptr, ptr, ptr, ptr)

declare i64 @GetFullPathNameW(ptr, i64, ptr, ptr)

declare i64 @GetFullPathNameA(ptr, i64, ptr, ptr)

declare i64 @GetLogicalDrives()

declare i64 @GetLogicalDriveStringsW(i64, ptr)

declare i64 @GetLongPathNameA(ptr, ptr, i64)

declare i64 @GetLongPathNameW(ptr, ptr, i64)

declare i32 @AreShortNamesEnabled(ptr, ptr)

declare i64 @GetShortPathNameW(ptr, ptr, i64)

declare i64 @GetTempFileNameW(ptr, ptr, i64, ptr)

declare i32 @GetVolumeInformationByHandleW(ptr, ptr, i64, ptr, ptr, ptr, ptr, i64)

declare i32 @GetVolumeInformationW(ptr, ptr, i64, ptr, ptr, ptr, ptr, i64)

declare i32 @GetVolumePathNameW(ptr, ptr, i64)

declare i32 @LocalFileTimeToFileTime(ptr, ptr)

declare i32 @LockFile(ptr, i64, i64, i64, i64)

declare i32 @LockFileEx(ptr, i64, i64, i64, i64, ptr)

declare i64 @QueryDosDeviceW(ptr, ptr, i64)

declare i32 @ReadFile(ptr, ptr, i64, ptr, ptr)

declare i32 @ReadFileEx(ptr, ptr, i64, ptr, ptr)

declare i32 @ReadFileScatter(ptr, i64, i64, ptr, ptr)

declare i32 @RemoveDirectoryA(ptr)

declare i32 @RemoveDirectoryW(ptr)

declare i32 @SetEndOfFile(ptr)

declare i32 @SetFileAttributesA(ptr, i64)

declare i32 @SetFileAttributesW(ptr, i64)

declare i32 @SetFileInformationByHandle(ptr, i64, ptr, i64)

declare i64 @SetFilePointer(ptr, i64, ptr, i64)

declare i32 @SetFilePointerEx(ptr, i64, ptr, i64)

declare i32 @SetFileTime(ptr, ptr, ptr, ptr)

declare i32 @SetFileValidData(ptr, i64)

declare i32 @UnlockFile(ptr, i64, i64, i64, i64)

declare i32 @UnlockFileEx(ptr, i64, i64, i64, ptr)

declare i32 @WriteFile(ptr, ptr, i64, ptr, ptr)

declare i32 @WriteFileEx(ptr, ptr, i64, ptr, ptr)

declare i32 @WriteFileGather(ptr, i64, i64, ptr, ptr)

declare i64 @GetTempPathW(i64, ptr)

declare i32 @GetVolumeNameForVolumeMountPointW(ptr, ptr, i64)

declare i32 @GetVolumePathNamesForVolumeNameW(ptr, ptr, i64, ptr)

declare ptr @CreateFile2(ptr, i64, i64, i64, ptr)

declare i32 @SetFileIoOverlappedRange(ptr, ptr, i64)

declare i64 @GetCompressedFileSizeA(ptr, ptr)

declare i64 @GetCompressedFileSizeW(ptr, ptr)

declare ptr @FindFirstStreamW(ptr, i64, ptr, i64)

declare i32 @FindNextStreamW(ptr, ptr)

declare i32 @AreFileApisANSI()

declare i64 @GetTempPathA(i64, ptr)

declare ptr @FindFirstFileNameW(ptr, i64, ptr, ptr)

declare i32 @FindNextFileNameW(ptr, ptr, ptr)

declare i32 @GetVolumeInformationA(ptr, ptr, i64, ptr, ptr, ptr, ptr, i64)

declare i64 @GetTempFileNameA(ptr, ptr, i64, ptr)

declare void @SetFileApisToOEM()

declare void @SetFileApisToANSI()

declare i64 @GetTempPath2W(i64, ptr)

declare i64 @GetTempPath2A(i64, ptr)

declare ptr @CreateFile3(ptr, i64, i64, i64, ptr)

declare ptr @CreateDirectory2A(ptr, i64, i64, i64, ptr)

declare ptr @CreateDirectory2W(ptr, i64, i64, i64, ptr)

declare i32 @RemoveDirectory2A(ptr, i64)

declare i32 @RemoveDirectory2W(ptr, i64)

declare i32 @DeleteFile2A(ptr, i64)

declare i32 @DeleteFile2W(ptr, i64)

declare i32 @CopyFileFromAppW(ptr, ptr, i32)

declare i32 @CreateDirectoryFromAppW(ptr, ptr)

declare ptr @CreateFileFromAppW(ptr, i64, i64, ptr, i64, i64, ptr)

declare ptr @CreateFile2FromAppW(ptr, i64, i64, i64, ptr)

declare i32 @DeleteFileFromAppW(ptr)

declare ptr @FindFirstFileExFromAppW(ptr, i64, ptr, i64, ptr, i64)

declare i32 @GetFileAttributesExFromAppW(ptr, i64, ptr)

declare i32 @MoveFileFromAppW(ptr, ptr)

declare i32 @RemoveDirectoryFromAppW(ptr)

declare i32 @ReplaceFileFromAppW(ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @SetFileAttributesFromAppW(ptr, i64)

declare i32 @IsDebuggerPresent()

declare void @DebugBreak()

declare void @OutputDebugStringA(ptr)

declare void @OutputDebugStringW(ptr)

declare i32 @ContinueDebugEvent(i64, i64, i64)

declare i32 @WaitForDebugEvent(ptr, i64)

declare i32 @DebugActiveProcess(i64)

declare i32 @DebugActiveProcessStop(i64)

declare i32 @CheckRemoteDebuggerPresent(ptr, ptr)

declare i32 @WaitForDebugEventEx(ptr, i64)

declare ptr @EncodePointer(ptr)

declare ptr @DecodePointer(ptr)

declare ptr @EncodeSystemPointer(ptr)

declare ptr @DecodeSystemPointer(ptr)

declare i64 @EncodeRemotePointer(ptr, ptr, ptr)

declare i64 @DecodeRemotePointer(ptr, ptr, ptr)

declare i32 @Beep(i64, i64)

declare i32 @DuplicateHandle(ptr, ptr, ptr, ptr, i64, i32, i64)

declare i32 @CompareObjectHandles(ptr, ptr)

declare i32 @GetHandleInformation(ptr, ptr)

declare i32 @SetHandleInformation(ptr, i64, i64)

declare void @RaiseException(i64, i64, i64, ptr)

declare i64 @UnhandledExceptionFilter(ptr)

declare ptr @SetUnhandledExceptionFilter(ptr)

declare i64 @GetLastError()

declare void @SetLastError(i64)

declare i64 @GetErrorMode()

declare i64 @SetErrorMode(i64)

declare ptr @AddVectoredExceptionHandler(i64, ptr)

declare i64 @RemoveVectoredExceptionHandler(ptr)

declare ptr @AddVectoredContinueHandler(i64, ptr)

declare i64 @RemoveVectoredContinueHandler(ptr)

declare void @RaiseFailFastException(ptr, ptr, i64)

declare void @FatalAppExitA(i64, ptr)

declare void @FatalAppExitW(i64, ptr)

declare i64 @GetThreadErrorMode()

declare i32 @SetThreadErrorMode(i64, ptr)

declare void @TerminateProcessOnMemoryExhaustion(i64)

declare i64 @FlsAlloc(ptr)

declare ptr @FlsGetValue(i64)

declare i32 @FlsSetValue(i64, ptr)

declare i32 @FlsFree(i64)

declare i32 @IsThreadAFiber()

declare ptr @FlsGetValue2(i64)

declare i32 @CreatePipe(ptr, ptr, ptr, i64)

declare i32 @ConnectNamedPipe(ptr, ptr)

declare i32 @DisconnectNamedPipe(ptr)

declare i32 @SetNamedPipeHandleState(ptr, ptr, ptr, ptr)

declare i32 @PeekNamedPipe(ptr, ptr, i64, ptr, ptr, ptr)

declare i32 @TransactNamedPipe(ptr, ptr, i64, ptr, i64, ptr, ptr)

declare ptr @CreateNamedPipeW(ptr, i64, i64, i64, i64, i64, i64, ptr)

declare i32 @WaitNamedPipeW(ptr, i64)

declare i32 @GetNamedPipeClientComputerNameW(ptr, ptr, i64)

declare i32 @ImpersonateNamedPipeClient(ptr)

declare i32 @GetNamedPipeInfo(ptr, ptr, ptr, ptr, ptr)

declare i32 @GetNamedPipeHandleStateW(ptr, ptr, ptr, ptr, ptr, ptr, i64)

declare i32 @CallNamedPipeW(ptr, ptr, i64, ptr, i64, ptr, i64)

declare i32 @QueryPerformanceCounter(ptr)

declare i32 @QueryPerformanceFrequency(ptr)

declare ptr @HeapCreate(i64, i64, i64)

declare i32 @HeapDestroy(ptr)

declare ptr @HeapAlloc(ptr, i64, i64)

declare ptr @HeapReAlloc(ptr, i64, ptr, i64)

declare i32 @HeapFree(ptr, i64, ptr)

declare i64 @HeapSize(ptr, i64, ptr)

declare ptr @GetProcessHeap()

declare i64 @HeapCompact(ptr, i64)

declare i32 @HeapSetInformation(ptr, i64, ptr, i64)

declare i32 @HeapValidate(ptr, i64, ptr)

declare i32 @HeapSummary(ptr, i64, ptr)

declare i64 @GetProcessHeaps(i64, ptr)

declare i32 @HeapLock(ptr)

declare i32 @HeapUnlock(ptr)

declare i32 @HeapWalk(ptr, ptr)

declare i32 @HeapQueryInformation(ptr, i64, ptr, i64, ptr)

declare ptr @CreateIoCompletionPort(ptr, ptr, i64, i64)

declare i32 @GetQueuedCompletionStatus(ptr, ptr, ptr, ptr, i64)

declare i32 @GetQueuedCompletionStatusEx(ptr, ptr, i64, ptr, i64, i32)

declare i32 @PostQueuedCompletionStatus(ptr, i64, i64, ptr)

declare i32 @DeviceIoControl(ptr, i64, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @GetOverlappedResult(ptr, ptr, ptr, i32)

declare i32 @CancelIoEx(ptr, ptr)

declare i32 @CancelIo(ptr)

declare i32 @GetOverlappedResultEx(ptr, ptr, ptr, i64, i32)

declare i32 @CancelSynchronousIo(ptr)

declare void @InitializeSRWLock(ptr)

declare void @ReleaseSRWLockExclusive(ptr)

declare void @ReleaseSRWLockShared(ptr)

declare void @AcquireSRWLockExclusive(ptr)

declare void @AcquireSRWLockShared(ptr)

declare i64 @TryAcquireSRWLockExclusive(ptr)

declare i64 @TryAcquireSRWLockShared(ptr)

declare i32 @InitializeCriticalSectionAndSpinCount(ptr, i64)

declare i32 @InitializeCriticalSectionEx(ptr, i64, i64)

declare i64 @SetCriticalSectionSpinCount(ptr, i64)

declare i32 @TryEnterCriticalSection(ptr)

declare void @DeleteCriticalSection(ptr)

declare void @InitOnceInitialize(ptr)

declare i32 @InitOnceExecuteOnce(ptr, ptr, ptr, ptr)

declare i32 @InitOnceBeginInitialize(ptr, i64, ptr, ptr)

declare i32 @InitOnceComplete(ptr, i64, ptr)

declare void @InitializeConditionVariable(ptr)

declare void @WakeConditionVariable(ptr)

declare void @WakeAllConditionVariable(ptr)

declare i32 @SleepConditionVariableCS(ptr, ptr, i64)

declare i32 @SleepConditionVariableSRW(ptr, ptr, i64, i64)

declare i32 @SetEvent(ptr)

declare i32 @ResetEvent(ptr)

declare i32 @ReleaseSemaphore(ptr, i64, ptr)

declare i32 @ReleaseMutex(ptr)

declare i64 @SleepEx(i64, i32)

declare i64 @WaitForSingleObjectEx(ptr, i64, i32)

declare i64 @WaitForMultipleObjectsEx(i64, ptr, i32, i64, i32)

declare ptr @CreateMutexA(ptr, i32, ptr)

declare ptr @CreateMutexW(ptr, i32, ptr)

declare ptr @OpenMutexW(i64, i32, ptr)

declare ptr @CreateEventA(ptr, i32, i32, ptr)

declare ptr @CreateEventW(ptr, i32, i32, ptr)

declare ptr @OpenEventA(i64, i32, ptr)

declare ptr @OpenEventW(i64, i32, ptr)

declare ptr @OpenSemaphoreW(i64, i32, ptr)

declare ptr @OpenWaitableTimerW(i64, i32, ptr)

declare i32 @SetWaitableTimerEx(ptr, ptr, i64, ptr, ptr, ptr, i64)

declare i32 @SetWaitableTimer(ptr, ptr, i64, ptr, ptr, i32)

declare i32 @CancelWaitableTimer(ptr)

declare ptr @CreateMutexExA(ptr, ptr, i64, i64)

declare ptr @CreateMutexExW(ptr, ptr, i64, i64)

declare ptr @CreateEventExA(ptr, ptr, i64, i64)

declare ptr @CreateEventExW(ptr, ptr, i64, i64)

declare ptr @CreateSemaphoreExW(ptr, i64, i64, ptr, i64, i64)

declare ptr @CreateWaitableTimerExW(ptr, ptr, i64, i64)

declare i32 @EnterSynchronizationBarrier(ptr, i64)

declare i32 @InitializeSynchronizationBarrier(ptr, i64, i64)

declare i32 @DeleteSynchronizationBarrier(ptr)

declare void @Sleep(i64)

declare i32 @WaitOnAddress(ptr, ptr, i64, i64)

declare void @WakeByAddressSingle(ptr)

declare void @WakeByAddressAll(ptr)

declare i64 @SignalObjectAndWait(ptr, ptr, i64, i32)

declare i64 @WaitForMultipleObjects(i64, ptr, i32, i64)

declare ptr @CreateSemaphoreW(ptr, i64, i64, ptr)

declare ptr @CreateWaitableTimerW(ptr, i32, ptr)

declare void @InitializeSListHead(ptr)

declare ptr @InterlockedPopEntrySList(ptr)

declare ptr @InterlockedPushEntrySList(ptr, ptr)

declare ptr @InterlockedPushListSListEx(ptr, ptr, ptr, i64)

declare ptr @InterlockedFlushSList(ptr)

declare i64 @QueryDepthSList(ptr)

declare i64 @QueueUserAPC(ptr, ptr, i64)

declare i32 @QueueUserAPC2(ptr, ptr, i64, i64)

declare i32 @GetProcessTimes(ptr, ptr, ptr, ptr, ptr)

declare ptr @GetCurrentProcess()

declare i64 @GetCurrentProcessId()

declare void @ExitProcess(i64)

declare i32 @TerminateProcess(ptr, i64)

declare i32 @GetExitCodeProcess(ptr, ptr)

declare i32 @SwitchToThread()

declare ptr @CreateRemoteThread(ptr, ptr, i64, ptr, ptr, i64, ptr)

declare ptr @GetCurrentThread()

declare i64 @GetCurrentThreadId()

declare ptr @OpenThread(i64, i32, i64)

declare i32 @SetThreadPriority(ptr, i32)

declare i32 @SetThreadPriorityBoost(ptr, i32)

declare i32 @GetThreadPriorityBoost(ptr, ptr)

declare i32 @GetThreadPriority(ptr)

declare void @ExitThread(i64)

declare i32 @TerminateThread(ptr, i64)

declare i32 @GetExitCodeThread(ptr, ptr)

declare i64 @SuspendThread(ptr)

declare i64 @ResumeThread(ptr)

declare i64 @TlsAlloc()

declare ptr @TlsGetValue(i64)

declare i32 @TlsSetValue(i64, ptr)

declare i32 @TlsFree(i64)

declare i32 @CreateProcessA(ptr, ptr, ptr, ptr, i32, i64, ptr, ptr, ptr, ptr)

declare i32 @CreateProcessW(ptr, ptr, ptr, ptr, i32, i64, ptr, ptr, ptr, ptr)

declare i32 @SetProcessShutdownParameters(i64, i64)

declare i64 @GetProcessVersion(i64)

declare void @GetStartupInfoW(ptr)

declare i32 @CreateProcessAsUserW(ptr, ptr, ptr, ptr, ptr, i32, i64, ptr, ptr, ptr, ptr)

declare ptr @GetCurrentProcessToken()

declare ptr @GetCurrentThreadToken()

declare ptr @GetCurrentThreadEffectiveToken()

declare i32 @SetThreadToken(ptr, ptr)

declare i32 @OpenProcessToken(ptr, i64, ptr)

declare i32 @OpenThreadToken(ptr, i64, i32, ptr)

declare i32 @SetPriorityClass(ptr, i64)

declare i64 @GetPriorityClass(ptr)

declare i32 @SetThreadStackGuarantee(ptr)

declare i32 @ProcessIdToSessionId(i64, ptr)

declare i64 @GetProcessId(ptr)

declare i64 @GetThreadId(ptr)

declare void @FlushProcessWriteBuffers()

declare i64 @GetProcessIdOfThread(ptr)

declare i32 @InitializeProcThreadAttributeList(ptr, i64, i64, ptr)

declare void @DeleteProcThreadAttributeList(ptr)

declare i32 @UpdateProcThreadAttribute(ptr, i64, i64, ptr, i64, ptr, ptr)

declare i32 @SetProcessDynamicEHContinuationTargets(ptr, i64, ptr)

declare i32 @SetProcessDynamicEnforcedCetCompatibleRanges(ptr, i64, ptr)

declare i32 @SetProcessAffinityUpdateMode(ptr, i64)

declare i32 @QueryProcessAffinityUpdateMode(ptr, ptr)

declare ptr @CreateRemoteThreadEx(ptr, ptr, i64, ptr, ptr, i64, ptr, ptr)

declare void @GetCurrentThreadStackLimits(ptr, ptr)

declare i32 @GetThreadContext(ptr, ptr)

declare i32 @GetProcessMitigationPolicy(ptr, i64, ptr, i64)

declare i32 @SetThreadContext(ptr, ptr)

declare i32 @SetProcessMitigationPolicy(i64, ptr, i64)

declare i32 @FlushInstructionCache(ptr, ptr, i64)

declare i32 @GetThreadTimes(ptr, ptr, ptr, ptr, ptr)

declare ptr @OpenProcess(i64, i32, i64)

declare i32 @IsProcessorFeaturePresent(i64)

declare i32 @GetProcessHandleCount(ptr, ptr)

declare i64 @GetCurrentProcessorNumber()

declare i32 @SetThreadIdealProcessorEx(ptr, ptr, ptr)

declare i32 @GetThreadIdealProcessorEx(ptr, ptr)

declare void @GetCurrentProcessorNumberEx(ptr)

declare i32 @GetProcessPriorityBoost(ptr, ptr)

declare i32 @SetProcessPriorityBoost(ptr, i32)

declare i32 @GetThreadIOPendingFlag(ptr, ptr)

declare i32 @GetSystemTimes(ptr, ptr, ptr)

declare i32 @GetThreadInformation(ptr, i64, ptr, i64)

declare i32 @SetThreadInformation(ptr, i64, ptr, i64)

declare i32 @IsProcessCritical(ptr, ptr)

declare i32 @SetProtectedPolicy(ptr, i64, ptr)

declare i32 @QueryProtectedPolicy(ptr, ptr)

declare i64 @SetThreadIdealProcessor(ptr, i64)

declare i32 @SetProcessInformation(ptr, i64, ptr, i64)

declare i32 @GetProcessInformation(ptr, i64, ptr, i64)

declare i32 @GetSystemCpuSetInformation(ptr, i64, ptr, ptr, i64)

declare i32 @GetProcessDefaultCpuSets(ptr, ptr, i64, ptr)

declare i32 @SetProcessDefaultCpuSets(ptr, ptr, i64)

declare i32 @GetThreadSelectedCpuSets(ptr, ptr, i64, ptr)

declare i32 @SetThreadSelectedCpuSets(ptr, ptr, i64)

declare i32 @CreateProcessAsUserA(ptr, ptr, ptr, ptr, ptr, i32, i64, ptr, ptr, ptr, ptr)

declare i32 @GetProcessShutdownParameters(ptr, ptr)

declare i32 @GetProcessDefaultCpuSetMasks(ptr, ptr, i64, ptr)

declare i32 @SetProcessDefaultCpuSetMasks(ptr, ptr, i64)

declare i32 @GetThreadSelectedCpuSetMasks(ptr, ptr, i64, ptr)

declare i32 @SetThreadSelectedCpuSetMasks(ptr, ptr, i64)

declare i64 @GetMachineTypeAttributes(i64, ptr)

declare i64 @SetThreadDescription(ptr, ptr)

declare i64 @GetThreadDescription(ptr, ptr)

declare ptr @TlsGetValue2(i64)

declare i32 @GlobalMemoryStatusEx(ptr)

declare void @GetSystemInfo(ptr)

declare void @GetSystemTime(ptr)

declare void @GetSystemTimeAsFileTime(ptr)

declare void @GetLocalTime(ptr)

declare i32 @IsUserCetAvailableInEnvironment(i64)

declare i32 @GetSystemLeapSecondInformation(ptr, ptr)

declare i64 @GetVersion()

declare i32 @SetLocalTime(ptr)

declare i64 @GetTickCount()

declare i64 @GetTickCount64()

declare i32 @GetSystemTimeAdjustment(ptr, ptr, ptr)

declare i32 @GetSystemTimeAdjustmentPrecise(ptr, ptr, ptr)

declare i64 @GetSystemDirectoryA(ptr, i64)

declare i64 @GetSystemDirectoryW(ptr, i64)

declare i64 @GetWindowsDirectoryA(ptr, i64)

declare i64 @GetWindowsDirectoryW(ptr, i64)

declare i64 @GetSystemWindowsDirectoryA(ptr, i64)

declare i64 @GetSystemWindowsDirectoryW(ptr, i64)

declare i32 @GetComputerNameExA(i64, ptr, ptr)

declare i32 @GetComputerNameExW(i64, ptr, ptr)

declare i32 @SetComputerNameExW(i64, ptr)

declare i32 @SetSystemTime(ptr)

declare i32 @GetVersionExA(ptr)

declare i32 @GetVersionExW(ptr)

declare i32 @GetLogicalProcessorInformation(ptr, ptr)

declare i32 @GetLogicalProcessorInformationEx(i64, ptr, ptr)

declare void @GetNativeSystemInfo(ptr)

declare void @GetSystemTimePreciseAsFileTime(ptr)

declare i32 @GetProductInfo(i64, i64, i64, i64, ptr)

declare i32 @GetOsSafeBootMode(ptr)

declare i64 @EnumSystemFirmwareTables(i64, ptr, i64)

declare i64 @GetSystemFirmwareTable(i64, i64, ptr, i64)

declare i32 @DnsHostnameToComputerNameExW(ptr, ptr, ptr)

declare i32 @GetPhysicallyInstalledSystemMemory(ptr)

declare i32 @SetComputerNameEx2W(i64, i64, ptr)

declare i32 @SetSystemTimeAdjustment(i64, i32)

declare i32 @SetSystemTimeAdjustmentPrecise(i64, i32)

declare i32 @InstallELAMCertificateInfo(ptr)

declare i32 @GetProcessorSystemCycleTime(i64, ptr, ptr)

declare i32 @GetOsManufacturingMode(ptr)

declare i64 @GetIntegratedDisplaySize(ptr)

declare i32 @SetComputerNameA(ptr)

declare i32 @SetComputerNameW(ptr)

declare i32 @SetComputerNameExA(i64, ptr)

declare i64 @GetDeveloperDriveEnablementState()

declare ptr @VirtualAlloc(ptr, i64, i64, i64)

declare i32 @VirtualProtect(ptr, i64, i64, ptr)

declare i32 @VirtualFree(ptr, i64, i64)

declare i64 @VirtualQuery(ptr, ptr, i64)

declare ptr @VirtualAllocEx(ptr, ptr, i64, i64, i64)

declare i32 @VirtualProtectEx(ptr, ptr, i64, i64, ptr)

declare i64 @VirtualQueryEx(ptr, ptr, ptr, i64)

declare i32 @ReadProcessMemory(ptr, ptr, ptr, i64, ptr)

declare i32 @WriteProcessMemory(ptr, ptr, ptr, i64, ptr)

declare ptr @CreateFileMappingW(ptr, ptr, i64, i64, i64, ptr)

declare ptr @OpenFileMappingW(i64, i32, ptr)

declare ptr @MapViewOfFile(ptr, i64, i64, i64, i64)

declare ptr @MapViewOfFileEx(ptr, i64, i64, i64, i64, ptr)

declare i32 @VirtualFreeEx(ptr, ptr, i64, i64)

declare i32 @FlushViewOfFile(ptr, i64)

declare i32 @UnmapViewOfFile(ptr)

declare i64 @GetLargePageMinimum()

declare i32 @GetProcessWorkingSetSize(ptr, ptr, ptr)

declare i32 @GetProcessWorkingSetSizeEx(ptr, ptr, ptr, ptr)

declare i32 @SetProcessWorkingSetSize(ptr, i64, i64)

declare i32 @SetProcessWorkingSetSizeEx(ptr, i64, i64, i64)

declare i32 @VirtualLock(ptr, i64)

declare i32 @VirtualUnlock(ptr, i64)

declare i64 @GetWriteWatch(i64, ptr, i64, ptr, ptr, ptr)

declare i64 @ResetWriteWatch(ptr, i64)

declare ptr @CreateMemoryResourceNotification(i64)

declare i32 @QueryMemoryResourceNotification(ptr, ptr)

declare i32 @GetSystemFileCacheSize(ptr, ptr, ptr)

declare i32 @SetSystemFileCacheSize(i64, i64, i64)

declare ptr @CreateFileMappingNumaW(ptr, ptr, i64, i64, i64, ptr, i64)

declare i32 @PrefetchVirtualMemory(ptr, i64, ptr, i64)

declare ptr @CreateFileMappingFromApp(ptr, ptr, i64, i64, ptr)

declare ptr @MapViewOfFileFromApp(ptr, i64, i64, i64)

declare i32 @UnmapViewOfFileEx(ptr, i64)

declare i32 @AllocateUserPhysicalPages(ptr, ptr, ptr)

declare i32 @FreeUserPhysicalPages(ptr, ptr, ptr)

declare i32 @MapUserPhysicalPages(ptr, i64, ptr)

declare i32 @AllocateUserPhysicalPagesNuma(ptr, ptr, ptr, i64)

declare ptr @VirtualAllocExNuma(ptr, ptr, i64, i64, i64, i64)

declare i32 @GetMemoryErrorHandlingCapabilities(ptr)

declare ptr @RegisterBadMemoryNotification(ptr)

declare i32 @UnregisterBadMemoryNotification(ptr)

declare i64 @OfferVirtualMemory(ptr, i64, i64)

declare i64 @ReclaimVirtualMemory(ptr, i64)

declare i64 @DiscardVirtualMemory(ptr, i64)

declare i32 @SetProcessValidCallTargets(ptr, ptr, i64, i64, ptr)

declare i32 @SetProcessValidCallTargetsForMappedView(ptr, ptr, i64, i64, ptr, ptr, i64)

declare ptr @VirtualAllocFromApp(ptr, i64, i64, i64)

declare i32 @VirtualProtectFromApp(ptr, i64, i64, ptr)

declare ptr @OpenFileMappingFromApp(i64, i32, ptr)

declare i32 @QueryVirtualMemoryInformation(ptr, ptr, i64, ptr, i64, ptr)

declare ptr @MapViewOfFileNuma2(ptr, ptr, i64, ptr, i64, i64, i64, i64)

declare ptr @MapViewOfFile2(ptr, ptr, i64, ptr, i64, i64, i64)

declare i32 @UnmapViewOfFile2(ptr, ptr, i64)

declare i32 @VirtualUnlockEx(ptr, ptr, i64)

declare ptr @VirtualAlloc2(ptr, ptr, i64, i64, i64, ptr, i64)

declare ptr @MapViewOfFile3(ptr, ptr, ptr, i64, i64, i64, i64, ptr, i64)

declare ptr @VirtualAlloc2FromApp(ptr, ptr, i64, i64, i64, ptr, i64)

declare ptr @MapViewOfFile3FromApp(ptr, ptr, ptr, i64, i64, i64, i64, ptr, i64)

declare ptr @CreateFileMapping2(ptr, ptr, i64, i64, i64, i64, ptr, ptr, i64)

declare i32 @AllocateUserPhysicalPages2(ptr, ptr, ptr, ptr, i64)

declare ptr @OpenDedicatedMemoryPartition(ptr, i64, i64, i32)

declare i32 @QueryPartitionInformation(ptr, i64, ptr, i64)

declare i32 @GetMemoryNumaClosestInitiatorNode(i64, ptr)

declare i32 @GetMemoryNumaPerformanceInformation(i64, i64, ptr)

declare i32 @IsEnclaveTypeSupported(i64)

declare ptr @CreateEnclave(ptr, ptr, i64, i64, i64, ptr, i64, ptr)

declare i32 @LoadEnclaveData(ptr, ptr, ptr, i64, i64, ptr, i64, ptr, ptr)

declare i32 @InitializeEnclave(ptr, ptr, ptr, i64, ptr)

declare i32 @LoadEnclaveImageA(ptr, ptr)

declare i32 @LoadEnclaveImageW(ptr, ptr)

declare i32 @CallEnclave(ptr, ptr, i32, ptr)

declare i32 @TerminateEnclave(ptr, i32)

declare i32 @DeleteEnclave(ptr)

declare i32 @QueueUserWorkItem(ptr, ptr, i64)

declare i32 @UnregisterWaitEx(ptr, ptr)

declare ptr @CreateTimerQueue()

declare i32 @CreateTimerQueueTimer(ptr, ptr, ptr, ptr, i64, i64, i64)

declare i32 @ChangeTimerQueueTimer(ptr, ptr, i64, i64)

declare i32 @DeleteTimerQueueTimer(ptr, ptr, ptr)

declare i32 @DeleteTimerQueue(ptr)

declare i32 @DeleteTimerQueueEx(ptr, ptr)

declare ptr @CreateThreadpool(ptr)

declare void @SetThreadpoolThreadMaximum(ptr, i64)

declare i32 @SetThreadpoolThreadMinimum(ptr, i64)

declare i32 @SetThreadpoolStackInformation(ptr, ptr)

declare i32 @QueryThreadpoolStackInformation(ptr, ptr)

declare void @CloseThreadpool(ptr)

declare ptr @CreateThreadpoolCleanupGroup()

declare void @CloseThreadpoolCleanupGroupMembers(ptr, i32, ptr)

declare void @CloseThreadpoolCleanupGroup(ptr)

declare void @SetEventWhenCallbackReturns(ptr, ptr)

declare void @ReleaseSemaphoreWhenCallbackReturns(ptr, ptr, i64)

declare void @ReleaseMutexWhenCallbackReturns(ptr, ptr)

declare void @LeaveCriticalSectionWhenCallbackReturns(ptr, ptr)

declare void @FreeLibraryWhenCallbackReturns(ptr, ptr)

declare i32 @CallbackMayRunLong(ptr)

declare void @DisassociateCurrentThreadFromCallback(ptr)

declare i32 @TrySubmitThreadpoolCallback(ptr, ptr, ptr)

declare ptr @CreateThreadpoolWork(ptr, ptr, ptr)

declare void @SubmitThreadpoolWork(ptr)

declare void @WaitForThreadpoolWorkCallbacks(ptr, i32)

declare void @CloseThreadpoolWork(ptr)

declare ptr @CreateThreadpoolTimer(ptr, ptr, ptr)

declare void @SetThreadpoolTimer(ptr, ptr, i64, i64)

declare i32 @IsThreadpoolTimerSet(ptr)

declare void @WaitForThreadpoolTimerCallbacks(ptr, i32)

declare void @CloseThreadpoolTimer(ptr)

declare ptr @CreateThreadpoolWait(ptr, ptr, ptr)

declare void @SetThreadpoolWait(ptr, ptr, ptr)

declare void @WaitForThreadpoolWaitCallbacks(ptr, i32)

declare void @CloseThreadpoolWait(ptr)

declare ptr @CreateThreadpoolIo(ptr, ptr, ptr, ptr)

declare void @StartThreadpoolIo(ptr)

declare void @CancelThreadpoolIo(ptr)

declare void @WaitForThreadpoolIoCallbacks(ptr, i32)

declare void @CloseThreadpoolIo(ptr)

declare i32 @SetThreadpoolTimerEx(ptr, ptr, i64, i64)

declare i32 @SetThreadpoolWaitEx(ptr, ptr, ptr, ptr)

declare i32 @IsProcessInJob(ptr, ptr, ptr)

declare ptr @CreateJobObjectW(ptr, ptr)

declare void @FreeMemoryJobObject(ptr)

declare ptr @OpenJobObjectW(i64, i32, ptr)

declare i32 @AssignProcessToJobObject(ptr, ptr)

declare i32 @TerminateJobObject(ptr, i64)

declare i32 @SetInformationJobObject(ptr, i64, ptr, i64)

declare i64 @SetIoRateControlInformationJobObject(ptr, ptr)

declare i32 @QueryInformationJobObject(ptr, i64, ptr, i64, ptr)

declare i64 @QueryIoRateControlInformationJobObject(ptr, ptr, ptr, ptr)

declare i64 @Wow64EnableWow64FsRedirection(i64)

declare i32 @Wow64DisableWow64FsRedirection(ptr)

declare i32 @Wow64RevertWow64FsRedirection(ptr)

declare i32 @IsWow64Process(ptr, ptr)

declare i64 @GetSystemWow64DirectoryA(ptr, i64)

declare i64 @GetSystemWow64DirectoryW(ptr, i64)

declare i64 @Wow64SetThreadDefaultGuestMachine(i64)

declare i32 @IsWow64Process2(ptr, ptr, ptr)

declare i64 @GetSystemWow64Directory2A(ptr, i64, i64)

declare i64 @GetSystemWow64Directory2W(ptr, i64, i64)

declare i64 @IsWow64GuestMachineSupported(i64, ptr)

declare i32 @Wow64GetThreadContext(ptr, ptr)

declare i32 @Wow64SetThreadContext(ptr, ptr)

declare i64 @Wow64SuspendThread(ptr)

declare i32 @DisableThreadLibraryCalls(ptr)

declare ptr @FindResourceExW(ptr, ptr, ptr, i64)

declare i32 @FindStringOrdinal(i64, ptr, i32, ptr, i32, i32)

declare i32 @FreeLibrary(ptr)

declare void @FreeLibraryAndExitThread(ptr, i64)

declare i32 @FreeResource(ptr)

declare i64 @GetModuleFileNameA(ptr, ptr, i64)

declare i64 @GetModuleFileNameW(ptr, ptr, i64)

declare ptr @GetModuleHandleA(ptr)

declare ptr @GetModuleHandleW(ptr)

declare i32 @GetModuleHandleExA(i64, ptr, ptr)

declare i32 @GetModuleHandleExW(i64, ptr, ptr)

declare ptr @GetProcAddress(ptr, ptr)

declare ptr @LoadLibraryExA(ptr, ptr, i64)

declare ptr @LoadLibraryExW(ptr, ptr, i64)

declare ptr @LoadResource(ptr, ptr)

declare i32 @LoadStringA(ptr, i64, ptr, i32)

declare i32 @LoadStringW(ptr, i64, ptr, i32)

declare ptr @LockResource(ptr)

declare i64 @SizeofResource(ptr, ptr)

declare ptr @AddDllDirectory(ptr)

declare i32 @RemoveDllDirectory(ptr)

declare i32 @SetDefaultDllDirectories(i64)

declare i32 @EnumResourceLanguagesExA(ptr, ptr, ptr, ptr, i64, i64, i64)

declare i32 @EnumResourceLanguagesExW(ptr, ptr, ptr, ptr, i64, i64, i64)

declare i32 @EnumResourceNamesExA(ptr, ptr, ptr, i64, i64, i64)

declare i32 @EnumResourceNamesExW(ptr, ptr, ptr, i64, i64, i64)

declare i32 @EnumResourceTypesExA(ptr, ptr, i64, i64, i64)

declare i32 @EnumResourceTypesExW(ptr, ptr, i64, i64, i64)

declare ptr @FindResourceW(ptr, ptr, ptr)

declare ptr @LoadLibraryA(ptr)

declare ptr @LoadLibraryW(ptr)

declare i32 @EnumResourceNamesW(ptr, ptr, ptr, i64)

declare i32 @EnumResourceNamesA(ptr, ptr, ptr, i64)

declare i32 @AccessCheck(ptr, ptr, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @AccessCheckAndAuditAlarmW(ptr, ptr, ptr, ptr, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @AccessCheckByType(ptr, ptr, ptr, i64, ptr, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @AccessCheckByTypeResultList(ptr, ptr, ptr, i64, ptr, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @AccessCheckByTypeAndAuditAlarmW(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i64, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @AccessCheckByTypeResultListAndAuditAlarmW(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i64, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @AccessCheckByTypeResultListAndAuditAlarmByHandleW(ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i64, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @AddAccessAllowedAce(ptr, i64, i64, ptr)

declare i32 @AddAccessAllowedAceEx(ptr, i64, i64, i64, ptr)

declare i32 @AddAccessAllowedObjectAce(ptr, i64, i64, i64, ptr, ptr, ptr)

declare i32 @AddAccessDeniedAce(ptr, i64, i64, ptr)

declare i32 @AddAccessDeniedAceEx(ptr, i64, i64, i64, ptr)

declare i32 @AddAccessDeniedObjectAce(ptr, i64, i64, i64, ptr, ptr, ptr)

declare i32 @AddAce(ptr, i64, i64, ptr, i64)

declare i32 @AddAuditAccessAce(ptr, i64, i64, ptr, i32, i32)

declare i32 @AddAuditAccessAceEx(ptr, i64, i64, i64, ptr, i32, i32)

declare i32 @AddAuditAccessObjectAce(ptr, i64, i64, i64, ptr, ptr, ptr, i32, i32)

declare i32 @AddMandatoryAce(ptr, i64, i64, i64, ptr)

declare i32 @AddResourceAttributeAce(ptr, i64, i64, i64, ptr, ptr, ptr)

declare i32 @AddScopedPolicyIDAce(ptr, i64, i64, i64, ptr)

declare i32 @AdjustTokenGroups(ptr, i32, ptr, i64, ptr, ptr)

declare i32 @AdjustTokenPrivileges(ptr, i32, ptr, i64, ptr, ptr)

declare i32 @AllocateAndInitializeSid(ptr, i64, i64, i64, i64, i64, i64, i64, i64, i64, ptr)

declare i32 @AllocateLocallyUniqueId(ptr)

declare i32 @AreAllAccessesGranted(i64, i64)

declare i32 @AreAnyAccessesGranted(i64, i64)

declare i32 @CheckTokenMembership(ptr, ptr, ptr)

declare i32 @CheckTokenCapability(ptr, ptr, ptr)

declare i32 @GetAppContainerAce(ptr, i64, ptr, ptr)

declare i32 @CheckTokenMembershipEx(ptr, ptr, i64, ptr)

declare i32 @ConvertToAutoInheritPrivateObjectSecurity(ptr, ptr, ptr, ptr, i64, ptr)

declare i32 @CopySid(i64, ptr, ptr)

declare i32 @CreatePrivateObjectSecurity(ptr, ptr, ptr, i32, ptr, ptr)

declare i32 @CreatePrivateObjectSecurityEx(ptr, ptr, ptr, ptr, i32, i64, ptr, ptr)

declare i32 @CreatePrivateObjectSecurityWithMultipleInheritance(ptr, ptr, ptr, ptr, i64, i32, i64, ptr, ptr)

declare i32 @CreateRestrictedToken(ptr, i64, i64, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @CreateWellKnownSid(i64, ptr, ptr, ptr)

declare i32 @EqualDomainSid(ptr, ptr, ptr)

declare i32 @DeleteAce(ptr, i64)

declare i32 @DestroyPrivateObjectSecurity(ptr)

declare i32 @DuplicateToken(ptr, i64, ptr)

declare i32 @DuplicateTokenEx(ptr, i64, ptr, i64, i64, ptr)

declare i32 @EqualPrefixSid(ptr, ptr)

declare i32 @EqualSid(ptr, ptr)

declare i32 @FindFirstFreeAce(ptr, ptr)

declare ptr @FreeSid(ptr)

declare i32 @GetAce(ptr, i64, ptr)

declare i32 @GetAclInformation(ptr, ptr, i64, i64)

declare i32 @GetFileSecurityW(ptr, i64, ptr, i64, ptr)

declare i32 @GetKernelObjectSecurity(ptr, i64, ptr, i64, ptr)

declare i64 @GetLengthSid(ptr)

declare i32 @GetPrivateObjectSecurity(ptr, i64, ptr, i64, ptr)

declare i32 @GetSecurityDescriptorControl(ptr, ptr, ptr)

declare i32 @GetSecurityDescriptorDacl(ptr, ptr, ptr, ptr)

declare i32 @GetSecurityDescriptorGroup(ptr, ptr, ptr)

declare i64 @GetSecurityDescriptorLength(ptr)

declare i32 @GetSecurityDescriptorOwner(ptr, ptr, ptr)

declare i64 @GetSecurityDescriptorRMControl(ptr, ptr)

declare i32 @GetSecurityDescriptorSacl(ptr, ptr, ptr, ptr)

declare ptr @GetSidIdentifierAuthority(ptr)

declare i64 @GetSidLengthRequired(i64)

declare ptr @GetSidSubAuthority(ptr, i64)

declare ptr @GetSidSubAuthorityCount(ptr)

declare i32 @GetTokenInformation(ptr, i64, ptr, i64, ptr)

declare i32 @GetWindowsAccountDomainSid(ptr, ptr, ptr)

declare i32 @ImpersonateAnonymousToken(ptr)

declare i32 @ImpersonateLoggedOnUser(ptr)

declare i32 @ImpersonateSelf(i64)

declare i32 @InitializeAcl(ptr, i64, i64)

declare i32 @InitializeSecurityDescriptor(ptr, i64)

declare i32 @InitializeSid(ptr, ptr, i64)

declare i32 @IsTokenRestricted(ptr)

declare i32 @IsValidAcl(ptr)

declare i32 @IsValidSecurityDescriptor(ptr)

declare i32 @IsValidSid(ptr)

declare i32 @IsWellKnownSid(ptr, i64)

declare i32 @MakeAbsoluteSD(ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @MakeSelfRelativeSD(ptr, ptr, ptr)

declare void @MapGenericMask(ptr, ptr)

declare i32 @ObjectCloseAuditAlarmW(ptr, ptr, i32)

declare i32 @ObjectDeleteAuditAlarmW(ptr, ptr, i32)

declare i32 @ObjectOpenAuditAlarmW(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, ptr, i32, i32, ptr)

declare i32 @ObjectPrivilegeAuditAlarmW(ptr, ptr, ptr, i64, ptr, i32)

declare i32 @PrivilegeCheck(ptr, ptr, ptr)

declare i32 @PrivilegedServiceAuditAlarmW(ptr, ptr, ptr, ptr, i32)

declare void @QuerySecurityAccessMask(i64, ptr)

declare i32 @RevertToSelf()

declare i32 @SetAclInformation(ptr, ptr, i64, i64)

declare i32 @SetFileSecurityW(ptr, i64, ptr)

declare i32 @SetKernelObjectSecurity(ptr, i64, ptr)

declare i32 @SetPrivateObjectSecurity(i64, ptr, ptr, ptr, ptr)

declare i32 @SetPrivateObjectSecurityEx(i64, ptr, ptr, i64, ptr, ptr)

declare void @SetSecurityAccessMask(i64, ptr)

declare i32 @SetSecurityDescriptorControl(ptr, i64, i64)

declare i32 @SetSecurityDescriptorDacl(ptr, i32, ptr, i32)

declare i32 @SetSecurityDescriptorGroup(ptr, ptr, i32)

declare i32 @SetSecurityDescriptorOwner(ptr, ptr, i32)

declare i64 @SetSecurityDescriptorRMControl(ptr, ptr)

declare i32 @SetSecurityDescriptorSacl(ptr, i32, ptr, i32)

declare i32 @SetTokenInformation(ptr, i64, ptr, i64)

declare i32 @SetCachedSigningLevel(ptr, i64, i64, ptr)

declare i32 @GetCachedSigningLevel(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @CveEventWrite(ptr, ptr)

declare i32 @DeriveCapabilitySidsFromName(ptr, ptr, ptr, ptr, ptr)

declare ptr @CreatePrivateNamespaceW(ptr, ptr, ptr)

declare ptr @OpenPrivateNamespaceW(ptr, ptr)

declare i64 @ClosePrivateNamespace(ptr, i64)

declare ptr @CreateBoundaryDescriptorW(ptr, i64)

declare i32 @AddSIDToBoundaryDescriptor(ptr, ptr)

declare void @DeleteBoundaryDescriptor(ptr)

declare i32 @GetNumaHighestNodeNumber(ptr)

declare i32 @GetNumaNodeProcessorMaskEx(i64, ptr)

declare i32 @GetNumaNodeProcessorMask2(i64, ptr, i64, ptr)

declare i32 @GetNumaProximityNodeEx(i64, ptr)

declare i32 @GetProcessGroupAffinity(ptr, ptr, ptr)

declare i32 @GetThreadGroupAffinity(ptr, ptr)

declare i32 @SetThreadGroupAffinity(ptr, ptr, ptr)

declare i32 @GetAppContainerNamedObjectPath(ptr, ptr, i64, ptr, ptr)

declare i32 @QueryThreadCycleTime(ptr, ptr)

declare i32 @QueryProcessCycleTime(ptr, ptr)

declare i32 @QueryIdleProcessorCycleTime(ptr, ptr)

declare i32 @QueryIdleProcessorCycleTimeEx(i64, ptr, ptr)

declare void @QueryInterruptTimePrecise(ptr)

declare void @QueryUnbiasedInterruptTimePrecise(ptr)

declare void @QueryInterruptTime(ptr)

declare i32 @QueryUnbiasedInterruptTime(ptr)

declare i64 @QueryAuxiliaryCounterFrequency(ptr)

declare i64 @ConvertAuxiliaryCounterToPerformanceCounter(i64, ptr, ptr)

declare i64 @ConvertPerformanceCounterToAuxiliaryCounter(i64, ptr, ptr)

declare i32 @WinMain(ptr, ptr, ptr, i32)

declare i32 @wWinMain(ptr, ptr, ptr, i32)

declare ptr @GlobalAlloc(i64, i64)

declare ptr @GlobalReAlloc(ptr, i64, i64)

declare i64 @GlobalSize(ptr)

declare i32 @GlobalUnlock(ptr)

declare ptr @GlobalLock(ptr)

declare i64 @GlobalFlags(ptr)

declare ptr @GlobalHandle(ptr)

declare ptr @GlobalFree(ptr)

declare i64 @GlobalCompact(i64)

declare void @GlobalFix(ptr)

declare void @GlobalUnfix(ptr)

declare ptr @GlobalWire(ptr)

declare i32 @GlobalUnWire(ptr)

declare void @GlobalMemoryStatus(ptr)

declare ptr @LocalAlloc(i64, i64)

declare ptr @LocalReAlloc(ptr, i64, i64)

declare ptr @LocalLock(ptr)

declare ptr @LocalHandle(ptr)

declare i32 @LocalUnlock(ptr)

declare i64 @LocalSize(ptr)

declare i64 @LocalFlags(ptr)

declare ptr @LocalFree(ptr)

declare i64 @LocalShrink(ptr, i64)

declare i64 @LocalCompact(i64)

declare i32 @GetBinaryTypeA(ptr, ptr)

declare i32 @GetBinaryTypeW(ptr, ptr)

declare i64 @GetShortPathNameA(ptr, ptr, i64)

declare i64 @GetLongPathNameTransactedA(ptr, ptr, i64, ptr)

declare i64 @GetLongPathNameTransactedW(ptr, ptr, i64, ptr)

declare i32 @GetProcessAffinityMask(ptr, ptr, ptr)

declare i32 @SetProcessAffinityMask(ptr, i64)

declare i32 @GetProcessIoCounters(ptr, ptr)

declare void @FatalExit(i32)

declare i32 @SetEnvironmentStringsA(ptr)

declare void @SwitchToFiber(ptr)

declare void @DeleteFiber(ptr)

declare i32 @ConvertFiberToThread()

declare ptr @CreateFiberEx(i64, i64, i64, ptr, ptr)

declare ptr @ConvertThreadToFiberEx(ptr, i64)

declare ptr @CreateFiber(i64, ptr, ptr)

declare ptr @ConvertThreadToFiber(ptr)

declare i32 @CreateUmsCompletionList(ptr)

declare i32 @DequeueUmsCompletionListItems(ptr, i64, ptr)

declare i32 @GetUmsCompletionListEvent(ptr, ptr)

declare i32 @ExecuteUmsThread(ptr)

declare i32 @UmsThreadYield(ptr)

declare i32 @DeleteUmsCompletionList(ptr)

declare ptr @GetCurrentUmsThread()

declare ptr @GetNextUmsListItem(ptr)

declare i32 @QueryUmsThreadInformation(ptr, i64, ptr, i64, ptr)

declare i32 @SetUmsThreadInformation(ptr, i64, ptr, i64)

declare i32 @DeleteUmsThreadContext(ptr)

declare i32 @CreateUmsThreadContext(ptr)

declare i32 @EnterUmsSchedulingMode(ptr)

declare i32 @GetUmsSystemThreadInformation(ptr, ptr)

declare i64 @SetThreadAffinityMask(ptr, i64)

declare i32 @SetProcessDEPPolicy(i64)

declare i32 @GetProcessDEPPolicy(ptr, ptr, ptr)

declare i32 @RequestWakeupLatency(i64)

declare i32 @IsSystemResumeAutomatic()

declare i32 @GetThreadSelectorEntry(ptr, i64, ptr)

declare i64 @SetThreadExecutionState(i64)

declare ptr @PowerCreateRequest(ptr)

declare i32 @PowerSetRequest(ptr, i64)

declare i32 @PowerClearRequest(ptr, i64)

declare i32 @SetFileCompletionNotificationModes(ptr, i64)

declare i32 @Wow64GetThreadSelectorEntry(ptr, i64, ptr)

declare i32 @DebugSetProcessKillOnExit(i32)

declare i32 @DebugBreakProcess(ptr)

declare i32 @PulseEvent(ptr)

declare i64 @GlobalDeleteAtom(i64)

declare i32 @InitAtomTable(i64)

declare i64 @DeleteAtom(i64)

declare i64 @SetHandleCount(i64)

declare i32 @RequestDeviceWakeup(ptr)

declare i32 @CancelDeviceWakeupRequest(ptr)

declare i32 @GetDevicePowerState(ptr, ptr)

declare i32 @SetMessageWaitingIndicator(ptr, i64)

declare i32 @SetFileShortNameA(ptr, ptr)

declare i32 @SetFileShortNameW(ptr, ptr)

declare i64 @LoadModule(ptr, ptr)

declare i64 @WinExec(ptr, i64)

declare i32 @ClearCommBreak(ptr)

declare i32 @ClearCommError(ptr, ptr, ptr)

declare i32 @SetupComm(ptr, i64, i64)

declare i32 @EscapeCommFunction(ptr, i64)

declare i32 @GetCommConfig(ptr, ptr, ptr)

declare i32 @GetCommMask(ptr, ptr)

declare i32 @GetCommProperties(ptr, ptr)

declare i32 @GetCommModemStatus(ptr, ptr)

declare i32 @GetCommState(ptr, ptr)

declare i32 @GetCommTimeouts(ptr, ptr)

declare i32 @PurgeComm(ptr, i64)

declare i32 @SetCommBreak(ptr)

declare i32 @SetCommConfig(ptr, ptr, i64)

declare i32 @SetCommMask(ptr, i64)

declare i32 @SetCommState(ptr, ptr)

declare i32 @SetCommTimeouts(ptr, ptr)

declare i32 @TransmitCommChar(ptr, i64)

declare i32 @WaitCommEvent(ptr, ptr, ptr)

declare ptr @OpenCommPort(i64, i64, i64)

declare i64 @GetCommPorts(ptr, i64, ptr)

declare i64 @SetTapePosition(ptr, i64, i64, i64, i64, i32)

declare i64 @GetTapePosition(ptr, i64, ptr, ptr, ptr)

declare i64 @PrepareTape(ptr, i64, i32)

declare i64 @EraseTape(ptr, i64, i32)

declare i64 @CreateTapePartition(ptr, i64, i64, i64)

declare i64 @WriteTapemark(ptr, i64, i64, i32)

declare i64 @GetTapeStatus(ptr)

declare i64 @GetTapeParameters(ptr, i64, ptr, ptr)

declare i64 @SetTapeParameters(ptr, i64, ptr)

declare i32 @MulDiv(i32, i32, i32)

declare i64 @GetSystemDEPPolicy()

declare i32 @GetSystemRegistryQuota(ptr, ptr)

declare i32 @FileTimeToDosDateTime(ptr, ptr, ptr)

declare i32 @DosDateTimeToFileTime(i64, i64, ptr)

declare i64 @FormatMessageA(i64, ptr, i64, i64, ptr, i64, ptr)

declare i64 @FormatMessageW(i64, ptr, i64, i64, ptr, i64, ptr)

declare ptr @CreateMailslotA(ptr, i64, i64, ptr)

declare ptr @CreateMailslotW(ptr, i64, i64, ptr)

declare i32 @GetMailslotInfo(ptr, ptr, ptr, ptr, ptr)

declare i32 @SetMailslotInfo(ptr, i64)

declare i32 @EncryptFileA(ptr)

declare i32 @EncryptFileW(ptr)

declare i32 @DecryptFileA(ptr, i64)

declare i32 @DecryptFileW(ptr, i64)

declare i32 @FileEncryptionStatusA(ptr, ptr)

declare i32 @FileEncryptionStatusW(ptr, ptr)

declare i64 @OpenEncryptedFileRawA(ptr, i64, ptr)

declare i64 @OpenEncryptedFileRawW(ptr, i64, ptr)

declare i64 @ReadEncryptedFileRaw(ptr, ptr, ptr)

declare i64 @WriteEncryptedFileRaw(ptr, ptr, ptr)

declare void @CloseEncryptedFileRaw(ptr)

declare i32 @lstrcmpA(ptr, ptr)

declare i32 @lstrcmpW(ptr, ptr)

declare i32 @lstrcmpiA(ptr, ptr)

declare i32 @lstrcmpiW(ptr, ptr)

declare ptr @lstrcpynA(ptr, ptr, i32)

declare ptr @lstrcpynW(ptr, ptr, i32)

declare ptr @lstrcpyA(ptr, ptr)

declare ptr @lstrcpyW(ptr, ptr)

declare ptr @lstrcatA(ptr, ptr)

declare ptr @lstrcatW(ptr, ptr)

declare i32 @lstrlenA(ptr)

declare i32 @lstrlenW(ptr)

declare i32 @OpenFile(ptr, ptr, i64)

declare i32 @_lopen(ptr, i32)

declare i32 @_lcreat(ptr, i32)

declare i64 @_lread(i32, ptr, i64)

declare i64 @_lwrite(i32, ptr, i64)

declare i64 @_hread(i32, ptr, i64)

declare i64 @_hwrite(i32, ptr, i64)

declare i32 @_lclose(i32)

declare i64 @_llseek(i32, i64, i32)

declare i32 @IsTextUnicode(ptr, i32, ptr)

declare i32 @BackupRead(ptr, ptr, i64, ptr, i32, i32, ptr)

declare i32 @BackupSeek(ptr, i64, i64, ptr, ptr, ptr)

declare i32 @BackupWrite(ptr, ptr, i64, ptr, i32, i32, ptr)

declare ptr @OpenMutexA(i64, i32, ptr)

declare ptr @CreateSemaphoreA(ptr, i64, i64, ptr)

declare ptr @OpenSemaphoreA(i64, i32, ptr)

declare ptr @CreateWaitableTimerA(ptr, i32, ptr)

declare ptr @OpenWaitableTimerA(i64, i32, ptr)

declare ptr @CreateSemaphoreExA(ptr, i64, i64, ptr, i64, i64)

declare ptr @CreateWaitableTimerExA(ptr, ptr, i64, i64)

declare ptr @CreateFileMappingA(ptr, ptr, i64, i64, i64, ptr)

declare ptr @CreateFileMappingNumaA(ptr, ptr, i64, i64, i64, ptr, i64)

declare ptr @OpenFileMappingA(i64, i32, ptr)

declare i64 @GetLogicalDriveStringsA(i64, ptr)

declare ptr @LoadPackagedLibrary(ptr, i64)

declare i32 @QueryFullProcessImageNameA(ptr, i64, ptr, ptr)

declare i32 @QueryFullProcessImageNameW(ptr, i64, ptr, ptr)

declare void @GetStartupInfoA(ptr)

declare i64 @GetFirmwareEnvironmentVariableA(ptr, ptr, ptr, i64)

declare i64 @GetFirmwareEnvironmentVariableW(ptr, ptr, ptr, i64)

declare i64 @GetFirmwareEnvironmentVariableExA(ptr, ptr, ptr, i64, ptr)

declare i64 @GetFirmwareEnvironmentVariableExW(ptr, ptr, ptr, i64, ptr)

declare i32 @SetFirmwareEnvironmentVariableA(ptr, ptr, ptr, i64)

declare i32 @SetFirmwareEnvironmentVariableW(ptr, ptr, ptr, i64)

declare i32 @SetFirmwareEnvironmentVariableExA(ptr, ptr, ptr, i64, i64)

declare i32 @SetFirmwareEnvironmentVariableExW(ptr, ptr, ptr, i64, i64)

declare i32 @GetFirmwareType(ptr)

declare i32 @IsNativeVhdBoot(ptr)

declare ptr @FindResourceA(ptr, ptr, ptr)

declare ptr @FindResourceExA(ptr, ptr, ptr, i64)

declare i32 @EnumResourceTypesA(ptr, ptr, i64)

declare i32 @EnumResourceTypesW(ptr, ptr, i64)

declare i32 @EnumResourceLanguagesA(ptr, ptr, ptr, ptr, i64)

declare i32 @EnumResourceLanguagesW(ptr, ptr, ptr, ptr, i64)

declare ptr @BeginUpdateResourceA(ptr, i32)

declare ptr @BeginUpdateResourceW(ptr, i32)

declare i32 @UpdateResourceA(ptr, ptr, ptr, i64, ptr, i64)

declare i32 @UpdateResourceW(ptr, ptr, ptr, i64, ptr, i64)

declare i32 @EndUpdateResourceA(ptr, i32)

declare i32 @EndUpdateResourceW(ptr, i32)

declare i64 @GlobalAddAtomA(ptr)

declare i64 @GlobalAddAtomW(ptr)

declare i64 @GlobalAddAtomExA(ptr, i64)

declare i64 @GlobalAddAtomExW(ptr, i64)

declare i64 @GlobalFindAtomA(ptr)

declare i64 @GlobalFindAtomW(ptr)

declare i64 @GlobalGetAtomNameA(i64, ptr, i32)

declare i64 @GlobalGetAtomNameW(i64, ptr, i32)

declare i64 @AddAtomA(ptr)

declare i64 @AddAtomW(ptr)

declare i64 @FindAtomA(ptr)

declare i64 @FindAtomW(ptr)

declare i64 @GetAtomNameA(i64, ptr, i32)

declare i64 @GetAtomNameW(i64, ptr, i32)

declare i64 @GetProfileIntA(ptr, ptr, i32)

declare i64 @GetProfileIntW(ptr, ptr, i32)

declare i64 @GetProfileStringA(ptr, ptr, ptr, ptr, i64)

declare i64 @GetProfileStringW(ptr, ptr, ptr, ptr, i64)

declare i32 @WriteProfileStringA(ptr, ptr, ptr)

declare i32 @WriteProfileStringW(ptr, ptr, ptr)

declare i64 @GetProfileSectionA(ptr, ptr, i64)

declare i64 @GetProfileSectionW(ptr, ptr, i64)

declare i32 @WriteProfileSectionA(ptr, ptr)

declare i32 @WriteProfileSectionW(ptr, ptr)

declare i64 @GetPrivateProfileIntA(ptr, ptr, i32, ptr)

declare i64 @GetPrivateProfileIntW(ptr, ptr, i32, ptr)

declare i64 @GetPrivateProfileStringA(ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @GetPrivateProfileStringW(ptr, ptr, ptr, ptr, i64, ptr)

declare i32 @WritePrivateProfileStringA(ptr, ptr, ptr, ptr)

declare i32 @WritePrivateProfileStringW(ptr, ptr, ptr, ptr)

declare i64 @GetPrivateProfileSectionA(ptr, ptr, i64, ptr)

declare i64 @GetPrivateProfileSectionW(ptr, ptr, i64, ptr)

declare i32 @WritePrivateProfileSectionA(ptr, ptr, ptr)

declare i32 @WritePrivateProfileSectionW(ptr, ptr, ptr)

declare i64 @GetPrivateProfileSectionNamesA(ptr, i64, ptr)

declare i64 @GetPrivateProfileSectionNamesW(ptr, i64, ptr)

declare i32 @GetPrivateProfileStructA(ptr, ptr, ptr, i64, ptr)

declare i32 @GetPrivateProfileStructW(ptr, ptr, ptr, i64, ptr)

declare i32 @WritePrivateProfileStructA(ptr, ptr, ptr, i64, ptr)

declare i32 @WritePrivateProfileStructW(ptr, ptr, ptr, i64, ptr)

declare i32 @SetDllDirectoryA(ptr)

declare i32 @SetDllDirectoryW(ptr)

declare i64 @GetDllDirectoryA(i64, ptr)

declare i64 @GetDllDirectoryW(i64, ptr)

declare i32 @SetSearchPathMode(i64)

declare i32 @CreateDirectoryExA(ptr, ptr, ptr)

declare i32 @CreateDirectoryExW(ptr, ptr, ptr)

declare i32 @CreateDirectoryTransactedA(ptr, ptr, ptr, ptr)

declare i32 @CreateDirectoryTransactedW(ptr, ptr, ptr, ptr)

declare i32 @RemoveDirectoryTransactedA(ptr, ptr)

declare i32 @RemoveDirectoryTransactedW(ptr, ptr)

declare i64 @GetFullPathNameTransactedA(ptr, i64, ptr, ptr, ptr)

declare i64 @GetFullPathNameTransactedW(ptr, i64, ptr, ptr, ptr)

declare i32 @DefineDosDeviceA(i64, ptr, ptr)

declare i64 @QueryDosDeviceA(ptr, ptr, i64)

declare ptr @CreateFileTransactedA(ptr, i64, i64, ptr, i64, i64, ptr, ptr, ptr, ptr)

declare ptr @CreateFileTransactedW(ptr, i64, i64, ptr, i64, i64, ptr, ptr, ptr, ptr)

declare ptr @ReOpenFile(ptr, i64, i64, i64)

declare i32 @SetFileAttributesTransactedA(ptr, i64, ptr)

declare i32 @SetFileAttributesTransactedW(ptr, i64, ptr)

declare i32 @GetFileAttributesTransactedA(ptr, i64, ptr, ptr)

declare i32 @GetFileAttributesTransactedW(ptr, i64, ptr, ptr)

declare i64 @GetCompressedFileSizeTransactedA(ptr, ptr, ptr)

declare i64 @GetCompressedFileSizeTransactedW(ptr, ptr, ptr)

declare i32 @DeleteFileTransactedA(ptr, ptr)

declare i32 @DeleteFileTransactedW(ptr, ptr)

declare i32 @CheckNameLegalDOS8Dot3A(ptr, ptr, i64, ptr, ptr)

declare i32 @CheckNameLegalDOS8Dot3W(ptr, ptr, i64, ptr, ptr)

declare ptr @FindFirstFileTransactedA(ptr, i64, ptr, i64, ptr, i64, ptr)

declare ptr @FindFirstFileTransactedW(ptr, i64, ptr, i64, ptr, i64, ptr)

declare i32 @CopyFileA(ptr, ptr, i32)

declare i32 @CopyFileW(ptr, ptr, i32)

declare i32 @CopyFileExA(ptr, ptr, ptr, ptr, ptr, i64)

declare i32 @CopyFileExW(ptr, ptr, ptr, ptr, ptr, i64)

declare i32 @CopyFileTransactedA(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i32 @CopyFileTransactedW(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @CopyFile2(ptr, ptr, ptr)

declare i32 @MoveFileA(ptr, ptr)

declare i32 @MoveFileW(ptr, ptr)

declare i32 @MoveFileExA(ptr, ptr, i64)

declare i32 @MoveFileExW(ptr, ptr, i64)

declare i32 @MoveFileWithProgressA(ptr, ptr, ptr, ptr, i64)

declare i32 @MoveFileWithProgressW(ptr, ptr, ptr, ptr, i64)

declare i32 @MoveFileTransactedA(ptr, ptr, ptr, ptr, i64, ptr)

declare i32 @MoveFileTransactedW(ptr, ptr, ptr, ptr, i64, ptr)

declare i32 @ReplaceFileA(ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @ReplaceFileW(ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @CreateHardLinkA(ptr, ptr, ptr)

declare i32 @CreateHardLinkW(ptr, ptr, ptr)

declare i32 @CreateHardLinkTransactedA(ptr, ptr, ptr, ptr)

declare i32 @CreateHardLinkTransactedW(ptr, ptr, ptr, ptr)

declare ptr @FindFirstStreamTransactedW(ptr, i64, ptr, i64, ptr)

declare ptr @FindFirstFileNameTransactedW(ptr, i64, ptr, ptr, ptr)

declare ptr @CreateNamedPipeA(ptr, i64, i64, i64, i64, i64, i64, ptr)

declare i32 @GetNamedPipeHandleStateA(ptr, ptr, ptr, ptr, ptr, ptr, i64)

declare i32 @CallNamedPipeA(ptr, ptr, i64, ptr, i64, ptr, i64)

declare i32 @WaitNamedPipeA(ptr, i64)

declare i32 @GetNamedPipeClientComputerNameA(ptr, ptr, i64)

declare i32 @GetNamedPipeClientProcessId(ptr, ptr)

declare i32 @GetNamedPipeClientSessionId(ptr, ptr)

declare i32 @GetNamedPipeServerProcessId(ptr, ptr)

declare i32 @GetNamedPipeServerSessionId(ptr, ptr)

declare i32 @SetVolumeLabelA(ptr, ptr)

declare i32 @SetVolumeLabelW(ptr, ptr)

declare i32 @SetFileBandwidthReservation(ptr, i64, i64, i32, ptr, ptr)

declare i32 @GetFileBandwidthReservation(ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @ClearEventLogA(ptr, ptr)

declare i32 @ClearEventLogW(ptr, ptr)

declare i32 @BackupEventLogA(ptr, ptr)

declare i32 @BackupEventLogW(ptr, ptr)

declare i32 @CloseEventLog(ptr)

declare i32 @DeregisterEventSource(ptr)

declare i32 @NotifyChangeEventLog(ptr, ptr)

declare i32 @GetNumberOfEventLogRecords(ptr, ptr)

declare i32 @GetOldestEventLogRecord(ptr, ptr)

declare ptr @OpenEventLogA(ptr, ptr)

declare ptr @OpenEventLogW(ptr, ptr)

declare ptr @RegisterEventSourceA(ptr, ptr)

declare ptr @RegisterEventSourceW(ptr, ptr)

declare ptr @OpenBackupEventLogA(ptr, ptr)

declare ptr @OpenBackupEventLogW(ptr, ptr)

declare i32 @ReadEventLogA(ptr, i64, i64, ptr, i64, ptr, ptr)

declare i32 @ReadEventLogW(ptr, i64, i64, ptr, i64, ptr, ptr)

declare i32 @ReportEventA(ptr, i64, i64, i64, ptr, i64, i64, ptr, ptr)

declare i32 @ReportEventW(ptr, i64, i64, i64, ptr, i64, i64, ptr, ptr)

declare i32 @GetEventLogInformation(ptr, i64, ptr, i64, ptr)

declare i32 @OperationStart(ptr)

declare i32 @OperationEnd(ptr)

declare i32 @AccessCheckAndAuditAlarmA(ptr, ptr, ptr, ptr, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @AccessCheckByTypeAndAuditAlarmA(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i64, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @AccessCheckByTypeResultListAndAuditAlarmA(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i64, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @AccessCheckByTypeResultListAndAuditAlarmByHandleA(ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, i64, ptr, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @ObjectOpenAuditAlarmA(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64, ptr, i32, i32, ptr)

declare i32 @ObjectPrivilegeAuditAlarmA(ptr, ptr, ptr, i64, ptr, i32)

declare i32 @ObjectCloseAuditAlarmA(ptr, ptr, i32)

declare i32 @ObjectDeleteAuditAlarmA(ptr, ptr, i32)

declare i32 @PrivilegedServiceAuditAlarmA(ptr, ptr, ptr, ptr, i32)

declare i32 @AddConditionalAce(ptr, i64, i64, i64, i64, ptr, ptr, ptr)

declare i32 @SetFileSecurityA(ptr, i64, ptr)

declare i32 @GetFileSecurityA(ptr, i64, ptr, i64, ptr)

declare i32 @ReadDirectoryChangesW(ptr, ptr, i64, i32, i64, ptr, ptr, ptr)

declare i32 @ReadDirectoryChangesExW(ptr, ptr, i64, i32, i64, ptr, ptr, ptr, i64)

declare ptr @MapViewOfFileExNuma(ptr, i64, i64, i64, i64, ptr, i64)

declare i32 @IsBadReadPtr(ptr, i64)

declare i32 @IsBadWritePtr(ptr, i64)

declare i32 @IsBadHugeReadPtr(ptr, i64)

declare i32 @IsBadHugeWritePtr(ptr, i64)

declare i32 @IsBadCodePtr(ptr)

declare i32 @IsBadStringPtrA(ptr, i64)

declare i32 @IsBadStringPtrW(ptr, i64)

declare i32 @LookupAccountSidA(ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupAccountSidW(ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupAccountNameA(ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupAccountNameW(ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupAccountNameLocalA(ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupAccountNameLocalW(ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupAccountSidLocalA(ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupAccountSidLocalW(ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupPrivilegeValueA(ptr, ptr, ptr)

declare i32 @LookupPrivilegeValueW(ptr, ptr, ptr)

declare i32 @LookupPrivilegeNameA(ptr, ptr, ptr, ptr)

declare i32 @LookupPrivilegeNameW(ptr, ptr, ptr, ptr)

declare i32 @LookupPrivilegeDisplayNameA(ptr, ptr, ptr, ptr, ptr)

declare i32 @LookupPrivilegeDisplayNameW(ptr, ptr, ptr, ptr, ptr)

declare i32 @BuildCommDCBA(ptr, ptr)

declare i32 @BuildCommDCBW(ptr, ptr)

declare i32 @BuildCommDCBAndTimeoutsA(ptr, ptr, ptr)

declare i32 @BuildCommDCBAndTimeoutsW(ptr, ptr, ptr)

declare i32 @CommConfigDialogA(ptr, ptr, ptr)

declare i32 @CommConfigDialogW(ptr, ptr, ptr)

declare i32 @GetDefaultCommConfigA(ptr, ptr, ptr)

declare i32 @GetDefaultCommConfigW(ptr, ptr, ptr)

declare i32 @SetDefaultCommConfigA(ptr, ptr, i64)

declare i32 @SetDefaultCommConfigW(ptr, ptr, i64)

declare i32 @GetComputerNameA(ptr, ptr)

declare i32 @GetComputerNameW(ptr, ptr)

declare i32 @DnsHostnameToComputerNameA(ptr, ptr, ptr)

declare i32 @DnsHostnameToComputerNameW(ptr, ptr, ptr)

declare i32 @GetUserNameA(ptr, ptr)

declare i32 @GetUserNameW(ptr, ptr)

declare i32 @LogonUserA(ptr, ptr, ptr, i64, i64, ptr)

declare i32 @LogonUserW(ptr, ptr, ptr, i64, i64, ptr)

declare i32 @LogonUserExA(ptr, ptr, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @LogonUserExW(ptr, ptr, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @CreateProcessWithLogonW(ptr, ptr, ptr, i64, ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @CreateProcessWithTokenW(ptr, i64, ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @IsTokenUntrusted(ptr)

declare i32 @RegisterWaitForSingleObject(ptr, ptr, ptr, ptr, i64, i64)

declare i32 @UnregisterWait(ptr)

declare i32 @BindIoCompletionCallback(ptr, ptr, i64)

declare ptr @SetTimerQueueTimer(ptr, ptr, ptr, i64, i64, i32)

declare i32 @CancelTimerQueueTimer(ptr, ptr)

declare void @InitializeThreadpoolEnvironment(ptr)

declare void @SetThreadpoolCallbackPool(ptr, ptr)

declare void @SetThreadpoolCallbackCleanupGroup(ptr, ptr, ptr)

declare void @SetThreadpoolCallbackRunsLong(ptr)

declare void @SetThreadpoolCallbackLibrary(ptr, ptr)

declare void @SetThreadpoolCallbackPriority(ptr, i64)

declare void @DestroyThreadpoolEnvironment(ptr)

declare void @SetThreadpoolCallbackPersistent(ptr)

declare ptr @CreatePrivateNamespaceA(ptr, ptr, ptr)

declare ptr @OpenPrivateNamespaceA(ptr, ptr)

declare ptr @CreateBoundaryDescriptorA(ptr, i64)

declare i32 @AddIntegrityLabelToBoundaryDescriptor(ptr, ptr)

declare i32 @GetCurrentHwProfileA(ptr)

declare i32 @GetCurrentHwProfileW(ptr)

declare i32 @VerifyVersionInfoA(ptr, i64, i64)

declare i32 @VerifyVersionInfoW(ptr, i64, i64)

declare i64 @HRESULT_FROM_WIN32(i64)

declare i64 @HRESULT_FROM_SETUPAPI(i64)

declare i32 @SystemTimeToTzSpecificLocalTime(ptr, ptr, ptr)

declare i32 @TzSpecificLocalTimeToSystemTime(ptr, ptr, ptr)

declare i32 @FileTimeToSystemTime(ptr, ptr)

declare i32 @SystemTimeToFileTime(ptr, ptr)

declare i64 @GetTimeZoneInformation(ptr)

declare i32 @SetTimeZoneInformation(ptr)

declare i32 @SetDynamicTimeZoneInformation(ptr)

declare i64 @GetDynamicTimeZoneInformation(ptr)

declare i32 @GetTimeZoneInformationForYear(i64, ptr, ptr)

declare i64 @EnumDynamicTimeZoneInformation(i64, ptr)

declare i64 @GetDynamicTimeZoneInformationEffectiveYears(ptr, ptr, ptr)

declare i32 @SystemTimeToTzSpecificLocalTimeEx(ptr, ptr, ptr)

declare i32 @TzSpecificLocalTimeToSystemTimeEx(ptr, ptr, ptr)

declare i32 @LocalFileTimeToLocalSystemTime(ptr, ptr, ptr)

declare i32 @LocalSystemTimeToLocalFileTime(ptr, ptr, ptr)

declare i32 @SetSystemPowerState(i32, i32)

declare i32 @GetSystemPowerStatus(ptr)

declare i32 @MapUserPhysicalPagesScatter(ptr, i64, ptr)

declare ptr @CreateJobObjectA(ptr, ptr)

declare ptr @OpenJobObjectA(i64, i32, ptr)

declare i32 @CreateJobSet(i64, ptr, i64)

declare ptr @FindFirstVolumeA(ptr, i64)

declare i32 @FindNextVolumeA(ptr, ptr, i64)

declare ptr @FindFirstVolumeMountPointA(ptr, ptr, i64)

declare ptr @FindFirstVolumeMountPointW(ptr, ptr, i64)

declare i32 @FindNextVolumeMountPointA(ptr, ptr, i64)

declare i32 @FindNextVolumeMountPointW(ptr, ptr, i64)

declare i32 @FindVolumeMountPointClose(ptr)

declare i32 @SetVolumeMountPointA(ptr, ptr)

declare i32 @SetVolumeMountPointW(ptr, ptr)

declare i32 @DeleteVolumeMountPointA(ptr)

declare i32 @GetVolumeNameForVolumeMountPointA(ptr, ptr, i64)

declare i32 @GetVolumePathNameA(ptr, ptr, i64)

declare i32 @GetVolumePathNamesForVolumeNameA(ptr, ptr, i64, ptr)

declare ptr @CreateActCtxA(ptr)

declare ptr @CreateActCtxW(ptr)

declare void @AddRefActCtx(ptr)

declare void @ReleaseActCtx(ptr)

declare i32 @ZombifyActCtx(ptr)

declare i32 @ActivateActCtx(ptr, ptr)

declare i32 @DeactivateActCtx(i64, i64)

declare i32 @GetCurrentActCtx(ptr)

declare i32 @FindActCtxSectionStringA(i64, ptr, i64, ptr, ptr)

declare i32 @FindActCtxSectionStringW(i64, ptr, i64, ptr, ptr)

declare i32 @FindActCtxSectionGuid(i64, ptr, i64, ptr, ptr)

declare i32 @QueryActCtxW(i64, ptr, ptr, i64, ptr, i64, ptr)

declare i64 @WTSGetActiveConsoleSessionId()

declare i64 @WTSGetServiceSessionId()

declare i64 @WTSIsServerContainer()

declare i64 @GetActiveProcessorGroupCount()

declare i64 @GetMaximumProcessorGroupCount()

declare i64 @GetActiveProcessorCount(i64)

declare i64 @GetMaximumProcessorCount(i64)

declare i32 @GetNumaProcessorNode(i64, ptr)

declare i32 @GetNumaNodeNumberFromHandle(ptr, ptr)

declare i32 @GetNumaProcessorNodeEx(ptr, ptr)

declare i32 @GetNumaNodeProcessorMask(i64, ptr)

declare i32 @GetNumaAvailableMemoryNode(i64, ptr)

declare i32 @GetNumaAvailableMemoryNodeEx(i64, ptr)

declare i32 @GetNumaProximityNode(i64, ptr)

declare i64 @RegisterApplicationRecoveryCallback(ptr, ptr, i64, i64)

declare i64 @UnregisterApplicationRecoveryCallback()

declare i64 @RegisterApplicationRestart(ptr, i64)

declare i64 @UnregisterApplicationRestart()

declare i64 @GetApplicationRecoveryCallback(ptr, ptr, ptr, ptr, ptr)

declare i64 @GetApplicationRestartSettings(ptr, ptr, ptr, ptr)

declare i64 @ApplicationRecoveryInProgress(ptr)

declare void @ApplicationRecoveryFinished(i32)

declare i32 @GetFileInformationByHandleEx(ptr, i64, ptr, i64)

declare i32 @GetFileInformationByName(ptr, i64, ptr, i64)

declare ptr @OpenFileById(ptr, ptr, i64, i64, ptr, i64)

declare i64 @CreateSymbolicLinkA(ptr, ptr, i64)

declare i64 @CreateSymbolicLinkW(ptr, ptr, i64)

declare i32 @QueryActCtxSettingsW(i64, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @CreateSymbolicLinkTransactedA(ptr, ptr, i64, ptr)

declare i64 @CreateSymbolicLinkTransactedW(ptr, ptr, i64, ptr)

declare i32 @ReplacePartitionUnit(ptr, ptr, i64)

declare i32 @AddSecureMemoryCacheCallback(ptr)

declare i32 @RemoveSecureMemoryCacheCallback(ptr)

declare i32 @CopyContext(ptr, i64, ptr)

declare i32 @InitializeContext(ptr, i64, ptr, ptr)

declare i32 @InitializeContext2(ptr, i64, ptr, ptr, i64)

declare i64 @GetEnabledXStateFeatures()

declare i32 @GetXStateFeaturesMask(ptr, ptr)

declare ptr @LocateXStateFeature(ptr, i64, ptr)

declare i32 @SetXStateFeaturesMask(ptr, i64)

declare i64 @GetThreadEnabledXStateFeatures()

declare i32 @EnableProcessOptionalXStateFeatures(i64)

declare i64 @EnableThreadProfiling(ptr, i64, i64, ptr)

declare i64 @DisableThreadProfiling(ptr)

declare i64 @QueryThreadProfiling(ptr, ptr)

declare i64 @ReadThreadProfilingData(ptr, i64, ptr)

declare i64 @RaiseCustomSystemEventTrigger(ptr)

declare i32 @AddFontResourceA(ptr)

declare i32 @AddFontResourceW(ptr)

declare i32 @AnimatePalette(ptr, i64, i64, ptr)

declare i32 @Arc(ptr, i32, i32, i32, i32, i32, i32, i32, i32)

declare i32 @BitBlt(ptr, i32, i32, i32, i32, ptr, i32, i32, i64)

declare i32 @CancelDC(ptr)

declare i32 @Chord(ptr, i32, i32, i32, i32, i32, i32, i32, i32)

declare i32 @ChoosePixelFormat(ptr, ptr)

declare ptr @CloseMetaFile(ptr)

declare i32 @CombineRgn(ptr, ptr, ptr, i32)

declare ptr @CopyMetaFileA(ptr, ptr)

declare ptr @CopyMetaFileW(ptr, ptr)

declare ptr @CreateBitmap(i32, i32, i64, i64, ptr)

declare ptr @CreateBitmapIndirect(ptr)

declare ptr @CreateBrushIndirect(ptr)

declare ptr @CreateCompatibleBitmap(ptr, i32, i32)

declare ptr @CreateDiscardableBitmap(ptr, i32, i32)

declare ptr @CreateCompatibleDC(ptr)

declare ptr @CreateDCA(ptr, ptr, ptr, ptr)

declare ptr @CreateDCW(ptr, ptr, ptr, ptr)

declare ptr @CreateDIBitmap(ptr, ptr, i64, ptr, ptr, i64)

declare ptr @CreateDIBPatternBrush(ptr, i64)

declare ptr @CreateDIBPatternBrushPt(ptr, i64)

declare ptr @CreateEllipticRgn(i32, i32, i32, i32)

declare ptr @CreateEllipticRgnIndirect(ptr)

declare ptr @CreateFontIndirectA(ptr)

declare ptr @CreateFontIndirectW(ptr)

declare ptr @CreateFontA(i32, i32, i32, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, ptr)

declare ptr @CreateFontW(i32, i32, i32, i32, i32, i64, i64, i64, i64, i64, i64, i64, i64, ptr)

declare ptr @CreateHatchBrush(i32, i64)

declare ptr @CreateICA(ptr, ptr, ptr, ptr)

declare ptr @CreateICW(ptr, ptr, ptr, ptr)

declare ptr @CreateMetaFileA(ptr)

declare ptr @CreateMetaFileW(ptr)

declare ptr @CreatePalette(ptr)

declare ptr @CreatePen(i32, i32, i64)

declare ptr @CreatePenIndirect(ptr)

declare ptr @CreatePolyPolygonRgn(ptr, ptr, i32, i32)

declare ptr @CreatePatternBrush(ptr)

declare ptr @CreateRectRgn(i32, i32, i32, i32)

declare ptr @CreateRectRgnIndirect(ptr)

declare ptr @CreateRoundRectRgn(i32, i32, i32, i32, i32, i32)

declare i32 @CreateScalableFontResourceA(i64, ptr, ptr, ptr)

declare i32 @CreateScalableFontResourceW(i64, ptr, ptr, ptr)

declare ptr @CreateSolidBrush(i64)

declare i32 @DeleteDC(ptr)

declare i32 @DeleteMetaFile(ptr)

declare i32 @DeleteObject(ptr)

declare i32 @DescribePixelFormat(ptr, i32, i64, ptr)

declare i32 @DeviceCapabilitiesA(ptr, ptr, i64, ptr, ptr)

declare i32 @DeviceCapabilitiesW(ptr, ptr, i64, ptr, ptr)

declare i32 @DrawEscape(ptr, i32, i32, ptr)

declare i32 @Ellipse(ptr, i32, i32, i32, i32)

declare i32 @EnumFontFamiliesExA(ptr, ptr, ptr, i64, i64)

declare i32 @EnumFontFamiliesExW(ptr, ptr, ptr, i64, i64)

declare i32 @EnumFontFamiliesA(ptr, ptr, ptr, i64)

declare i32 @EnumFontFamiliesW(ptr, ptr, ptr, i64)

declare i32 @EnumFontsA(ptr, ptr, ptr, i64)

declare i32 @EnumFontsW(ptr, ptr, ptr, i64)

declare i32 @EnumObjects(ptr, i32, ptr, i64)

declare i32 @EqualRgn(ptr, ptr)

declare i32 @Escape(ptr, i32, i32, ptr, ptr)

declare i32 @ExtEscape(ptr, i32, i32, ptr, i32, ptr)

declare i32 @ExcludeClipRect(ptr, i32, i32, i32, i32)

declare ptr @ExtCreateRegion(ptr, i64, ptr)

declare i32 @ExtFloodFill(ptr, i32, i32, i64, i64)

declare i32 @FillRgn(ptr, ptr, ptr)

declare i32 @FloodFill(ptr, i32, i32, i64)

declare i32 @FrameRgn(ptr, ptr, ptr, i32, i32)

declare i32 @GetROP2(ptr)

declare i32 @GetAspectRatioFilterEx(ptr, ptr)

declare i64 @GetBkColor(ptr)

declare i64 @GetDCBrushColor(ptr)

declare i64 @GetDCPenColor(ptr)

declare i32 @GetBkMode(ptr)

declare i64 @GetBitmapBits(ptr, i64, ptr)

declare i32 @GetBitmapDimensionEx(ptr, ptr)

declare i64 @GetBoundsRect(ptr, ptr, i64)

declare i32 @GetBrushOrgEx(ptr, ptr)

declare i32 @GetCharWidthA(ptr, i64, i64, ptr)

declare i32 @GetCharWidthW(ptr, i64, i64, ptr)

declare i32 @GetCharWidth32A(ptr, i64, i64, ptr)

declare i32 @GetCharWidth32W(ptr, i64, i64, ptr)

declare i32 @GetCharWidthFloatA(ptr, i64, i64, ptr)

declare i32 @GetCharWidthFloatW(ptr, i64, i64, ptr)

declare i32 @GetCharABCWidthsA(ptr, i64, i64, ptr)

declare i32 @GetCharABCWidthsW(ptr, i64, i64, ptr)

declare i32 @GetCharABCWidthsFloatA(ptr, i64, i64, ptr)

declare i32 @GetCharABCWidthsFloatW(ptr, i64, i64, ptr)

declare i32 @GetClipBox(ptr, ptr)

declare i32 @GetClipRgn(ptr, ptr)

declare i32 @GetMetaRgn(ptr, ptr)

declare ptr @GetCurrentObject(ptr, i64)

declare i32 @GetCurrentPositionEx(ptr, ptr)

declare i32 @GetDeviceCaps(ptr, i32)

declare i32 @GetDIBits(ptr, ptr, i64, i64, ptr, ptr, i64)

declare i64 @GetFontData(ptr, i64, i64, ptr, i64)

declare i64 @GetGlyphOutlineA(ptr, i64, i64, ptr, i64, ptr, ptr)

declare i64 @GetGlyphOutlineW(ptr, i64, i64, ptr, i64, ptr, ptr)

declare i32 @GetGraphicsMode(ptr)

declare i32 @GetMapMode(ptr)

declare i64 @GetMetaFileBitsEx(ptr, i64, ptr)

declare ptr @GetMetaFileA(ptr)

declare ptr @GetMetaFileW(ptr)

declare i64 @GetNearestColor(ptr, i64)

declare i64 @GetNearestPaletteIndex(ptr, i64)

declare i64 @GetObjectType(ptr)

declare i64 @GetOutlineTextMetricsA(ptr, i64, ptr)

declare i64 @GetOutlineTextMetricsW(ptr, i64, ptr)

declare i64 @GetPaletteEntries(ptr, i64, i64, ptr)

declare i64 @GetPixel(ptr, i32, i32)

declare i32 @GetPixelFormat(ptr)

declare i32 @GetPolyFillMode(ptr)

declare i32 @GetRasterizerCaps(ptr, i64)

declare i32 @GetRandomRgn(ptr, ptr, i32)

declare i64 @GetRegionData(ptr, i64, ptr)

declare i32 @GetRgnBox(ptr, ptr)

declare ptr @GetStockObject(i32)

declare i32 @GetStretchBltMode(ptr)

declare i64 @GetSystemPaletteEntries(ptr, i64, i64, ptr)

declare i64 @GetSystemPaletteUse(ptr)

declare i32 @GetTextCharacterExtra(ptr)

declare i64 @GetTextAlign(ptr)

declare i64 @GetTextColor(ptr)

declare i32 @GetTextExtentPointA(ptr, ptr, i32, ptr)

declare i32 @GetTextExtentPointW(ptr, ptr, i32, ptr)

declare i32 @GetTextExtentPoint32A(ptr, ptr, i32, ptr)

declare i32 @GetTextExtentPoint32W(ptr, ptr, i32, ptr)

declare i32 @GetTextExtentExPointA(ptr, ptr, i32, i32, ptr, ptr, ptr)

declare i32 @GetTextExtentExPointW(ptr, ptr, i32, i32, ptr, ptr, ptr)

declare i32 @GetTextCharset(ptr)

declare i32 @GetTextCharsetInfo(ptr, ptr, i64)

declare i32 @TranslateCharsetInfo(ptr, ptr, i64)

declare i64 @GetFontLanguageInfo(ptr)

declare i64 @GetCharacterPlacementA(ptr, ptr, i32, i32, ptr, i64)

declare i64 @GetCharacterPlacementW(ptr, ptr, i32, i32, ptr, i64)

declare i64 @GetFontUnicodeRanges(ptr, ptr)

declare i64 @GetGlyphIndicesA(ptr, ptr, i32, ptr, i64)

declare i64 @GetGlyphIndicesW(ptr, ptr, i32, ptr, i64)

declare i32 @GetTextExtentPointI(ptr, ptr, i32, ptr)

declare i32 @GetTextExtentExPointI(ptr, ptr, i32, i32, ptr, ptr, ptr)

declare i32 @GetCharWidthI(ptr, i64, i64, ptr, ptr)

declare i32 @GetCharABCWidthsI(ptr, i64, i64, ptr, ptr)

declare i32 @AddFontResourceExA(ptr, i64, ptr)

declare i32 @AddFontResourceExW(ptr, i64, ptr)

declare i32 @RemoveFontResourceExA(ptr, i64, ptr)

declare i32 @RemoveFontResourceExW(ptr, i64, ptr)

declare ptr @AddFontMemResourceEx(ptr, i64, ptr, ptr)

declare i32 @RemoveFontMemResourceEx(ptr)

declare ptr @CreateFontIndirectExA(ptr)

declare ptr @CreateFontIndirectExW(ptr)

declare i32 @GetViewportExtEx(ptr, ptr)

declare i32 @GetViewportOrgEx(ptr, ptr)

declare i32 @GetWindowExtEx(ptr, ptr)

declare i32 @GetWindowOrgEx(ptr, ptr)

declare i32 @IntersectClipRect(ptr, i32, i32, i32, i32)

declare i32 @InvertRgn(ptr, ptr)

declare i32 @LineDDA(i32, i32, i32, i32, ptr, i64)

declare i32 @LineTo(ptr, i32, i32)

declare i32 @MaskBlt(ptr, i32, i32, i32, i32, ptr, i32, i32, ptr, i32, i32, i64)

declare i32 @PlgBlt(ptr, ptr, ptr, i32, i32, i32, i32, ptr, i32, i32)

declare i32 @OffsetClipRgn(ptr, i32, i32)

declare i32 @OffsetRgn(ptr, i32, i32)

declare i32 @PatBlt(ptr, i32, i32, i32, i32, i64)

declare i32 @Pie(ptr, i32, i32, i32, i32, i32, i32, i32, i32)

declare i32 @PlayMetaFile(ptr, ptr)

declare i32 @PaintRgn(ptr, ptr)

declare i32 @PolyPolygon(ptr, ptr, ptr, i32)

declare i32 @PtInRegion(ptr, i32, i32)

declare i32 @PtVisible(ptr, i32, i32)

declare i32 @RectInRegion(ptr, ptr)

declare i32 @RectVisible(ptr, ptr)

declare i32 @Rectangle(ptr, i32, i32, i32, i32)

declare i32 @RestoreDC(ptr, i32)

declare ptr @ResetDCA(ptr, ptr)

declare ptr @ResetDCW(ptr, ptr)

declare i64 @RealizePalette(ptr)

declare i32 @RemoveFontResourceA(ptr)

declare i32 @RemoveFontResourceW(ptr)

declare i32 @RoundRect(ptr, i32, i32, i32, i32, i32, i32)

declare i32 @ResizePalette(ptr, i64)

declare i32 @SaveDC(ptr)

declare i32 @SelectClipRgn(ptr, ptr)

declare i32 @ExtSelectClipRgn(ptr, ptr, i32)

declare i32 @SetMetaRgn(ptr)

declare ptr @SelectObject(ptr, ptr)

declare ptr @SelectPalette(ptr, ptr, i32)

declare i64 @SetBkColor(ptr, i64)

declare i64 @SetDCBrushColor(ptr, i64)

declare i64 @SetDCPenColor(ptr, i64)

declare i32 @SetBkMode(ptr, i32)

declare i64 @SetBitmapBits(ptr, i64, ptr)

declare i64 @SetBoundsRect(ptr, ptr, i64)

declare i32 @SetDIBits(ptr, ptr, i64, i64, ptr, ptr, i64)

declare i32 @SetDIBitsToDevice(ptr, i32, i32, i64, i64, i32, i32, i64, i64, ptr, ptr, i64)

declare i64 @SetMapperFlags(ptr, i64)

declare i32 @SetGraphicsMode(ptr, i32)

declare i32 @SetMapMode(ptr, i32)

declare i64 @SetLayout(ptr, i64)

declare i64 @GetLayout(ptr)

declare ptr @SetMetaFileBitsEx(i64, ptr)

declare i64 @SetPaletteEntries(ptr, i64, i64, ptr)

declare i64 @SetPixel(ptr, i32, i32, i64)

declare i32 @SetPixelV(ptr, i32, i32, i64)

declare i32 @SetPixelFormat(ptr, i32, ptr)

declare i32 @SetPolyFillMode(ptr, i32)

declare i32 @StretchBlt(ptr, i32, i32, i32, i32, ptr, i32, i32, i32, i32, i64)

declare i32 @SetRectRgn(ptr, i32, i32, i32, i32)

declare i32 @StretchDIBits(ptr, i32, i32, i32, i32, i32, i32, i32, i32, ptr, ptr, i64, i64)

declare i32 @SetROP2(ptr, i32)

declare i32 @SetStretchBltMode(ptr, i32)

declare i64 @SetSystemPaletteUse(ptr, i64)

declare i32 @SetTextCharacterExtra(ptr, i32)

declare i64 @SetTextColor(ptr, i64)

declare i64 @SetTextAlign(ptr, i64)

declare i32 @SetTextJustification(ptr, i32, i32)

declare i32 @UpdateColors(ptr)

declare i32 @AlphaBlend(ptr, i32, i32, i32, i32, ptr, i32, i32, i32, i32, i64)

declare i32 @TransparentBlt(ptr, i32, i32, i32, i32, ptr, i32, i32, i32, i32, i64)

declare i32 @GradientFill(ptr, ptr, i64, ptr, i64, i64)

declare i32 @GdiAlphaBlend(ptr, i32, i32, i32, i32, ptr, i32, i32, i32, i32, i64)

declare i32 @GdiTransparentBlt(ptr, i32, i32, i32, i32, ptr, i32, i32, i32, i32, i64)

declare i32 @GdiGradientFill(ptr, ptr, i64, ptr, i64, i64)

declare i32 @PlayMetaFileRecord(ptr, ptr, ptr, i64)

declare i32 @EnumMetaFile(ptr, ptr, ptr, i64)

declare ptr @CloseEnhMetaFile(ptr)

declare ptr @CopyEnhMetaFileA(ptr, ptr)

declare ptr @CopyEnhMetaFileW(ptr, ptr)

declare ptr @CreateEnhMetaFileA(ptr, ptr, ptr, ptr)

declare ptr @CreateEnhMetaFileW(ptr, ptr, ptr, ptr)

declare i32 @DeleteEnhMetaFile(ptr)

declare i32 @EnumEnhMetaFile(ptr, ptr, ptr, ptr, ptr)

declare ptr @GetEnhMetaFileA(ptr)

declare ptr @GetEnhMetaFileW(ptr)

declare i64 @GetEnhMetaFileBits(ptr, i64, ptr)

declare i64 @GetEnhMetaFileDescriptionA(ptr, i64, ptr)

declare i64 @GetEnhMetaFileDescriptionW(ptr, i64, ptr)

declare i64 @GetEnhMetaFileHeader(ptr, i64, ptr)

declare i64 @GetEnhMetaFilePaletteEntries(ptr, i64, ptr)

declare i64 @GetEnhMetaFilePixelFormat(ptr, i64, ptr)

declare i64 @GetWinMetaFileBits(ptr, i64, ptr, i32, ptr)

declare i32 @PlayEnhMetaFile(ptr, ptr, ptr)

declare i32 @PlayEnhMetaFileRecord(ptr, ptr, ptr, i64)

declare ptr @SetEnhMetaFileBits(i64, ptr)

declare ptr @SetWinMetaFileBits(i64, ptr, ptr, ptr)

declare i32 @GdiComment(ptr, i64, ptr)

declare i32 @GetTextMetricsA(ptr, ptr)

declare i32 @GetTextMetricsW(ptr, ptr)

declare i32 @AngleArc(ptr, i32, i32, i64, float, float)

declare i32 @PolyPolyline(ptr, ptr, ptr, i64)

declare i32 @GetWorldTransform(ptr, ptr)

declare i32 @SetWorldTransform(ptr, ptr)

declare i32 @ModifyWorldTransform(ptr, ptr, i64)

declare i32 @CombineTransform(ptr, ptr, ptr)

declare ptr @CreateDIBSection(ptr, ptr, i64, ptr, ptr, i64)

declare i64 @GetDIBColorTable(ptr, i64, i64, ptr)

declare i64 @SetDIBColorTable(ptr, i64, i64, ptr)

declare i32 @SetColorAdjustment(ptr, ptr)

declare i32 @GetColorAdjustment(ptr, ptr)

declare ptr @CreateHalftonePalette(ptr)

declare i32 @StartDocA(ptr, ptr)

declare i32 @StartDocW(ptr, ptr)

declare i32 @EndDoc(ptr)

declare i32 @StartPage(ptr)

declare i32 @EndPage(ptr)

declare i32 @AbortDoc(ptr)

declare i32 @SetAbortProc(ptr, ptr)

declare i32 @AbortPath(ptr)

declare i32 @ArcTo(ptr, i32, i32, i32, i32, i32, i32, i32, i32)

declare i32 @BeginPath(ptr)

declare i32 @CloseFigure(ptr)

declare i32 @EndPath(ptr)

declare i32 @FillPath(ptr)

declare i32 @FlattenPath(ptr)

declare i32 @GetPath(ptr, ptr, ptr, i32)

declare ptr @PathToRegion(ptr)

declare i32 @PolyDraw(ptr, ptr, ptr, i32)

declare i32 @SelectClipPath(ptr, i32)

declare i32 @SetArcDirection(ptr, i32)

declare i32 @SetMiterLimit(ptr, float, ptr)

declare i32 @StrokeAndFillPath(ptr)

declare i32 @StrokePath(ptr)

declare i32 @WidenPath(ptr)

declare ptr @ExtCreatePen(i64, i64, ptr, i64, ptr)

declare i32 @GetMiterLimit(ptr, ptr)

declare i32 @GetArcDirection(ptr)

declare i32 @GetObjectA(ptr, i32, ptr)

declare i32 @GetObjectW(ptr, i32, ptr)

declare i32 @MoveToEx(ptr, i32, i32, ptr)

declare i32 @TextOutA(ptr, i32, i32, ptr, i32)

declare i32 @TextOutW(ptr, i32, i32, ptr, i32)

declare i32 @ExtTextOutA(ptr, i32, i32, i64, ptr, ptr, i64, ptr)

declare i32 @ExtTextOutW(ptr, i32, i32, i64, ptr, ptr, i64, ptr)

declare i32 @PolyTextOutA(ptr, ptr, i32)

declare i32 @PolyTextOutW(ptr, ptr, i32)

declare ptr @CreatePolygonRgn(ptr, i32, i32)

declare i32 @DPtoLP(ptr, ptr, i32)

declare i32 @LPtoDP(ptr, ptr, i32)

declare i32 @Polygon(ptr, ptr, i32)

declare i32 @Polyline(ptr, ptr, i32)

declare i32 @PolyBezier(ptr, ptr, i64)

declare i32 @PolyBezierTo(ptr, ptr, i64)

declare i32 @PolylineTo(ptr, ptr, i64)

declare i32 @SetViewportExtEx(ptr, i32, i32, ptr)

declare i32 @SetViewportOrgEx(ptr, i32, i32, ptr)

declare i32 @SetWindowExtEx(ptr, i32, i32, ptr)

declare i32 @SetWindowOrgEx(ptr, i32, i32, ptr)

declare i32 @OffsetViewportOrgEx(ptr, i32, i32, ptr)

declare i32 @OffsetWindowOrgEx(ptr, i32, i32, ptr)

declare i32 @ScaleViewportExtEx(ptr, i32, i32, i32, i32, ptr)

declare i32 @ScaleWindowExtEx(ptr, i32, i32, i32, i32, ptr)

declare i32 @SetBitmapDimensionEx(ptr, i32, i32, ptr)

declare i32 @SetBrushOrgEx(ptr, i32, i32, ptr)

declare i32 @GetTextFaceA(ptr, i32, ptr)

declare i32 @GetTextFaceW(ptr, i32, ptr)

declare i64 @GetKerningPairsA(ptr, i64, ptr)

declare i64 @GetKerningPairsW(ptr, i64, ptr)

declare i32 @GetDCOrgEx(ptr, ptr)

declare i32 @FixBrushOrgEx(ptr, i32, i32, ptr)

declare i32 @UnrealizeObject(ptr)

declare i32 @GdiFlush()

declare i64 @GdiSetBatchLimit(i64)

declare i64 @GdiGetBatchLimit()

declare i32 @SetICMMode(ptr, i32)

declare i32 @CheckColorsInGamut(ptr, ptr, ptr, i64)

declare ptr @GetColorSpace(ptr)

declare i32 @GetLogColorSpaceA(ptr, ptr, i64)

declare i32 @GetLogColorSpaceW(ptr, ptr, i64)

declare ptr @CreateColorSpaceA(ptr)

declare ptr @CreateColorSpaceW(ptr)

declare ptr @SetColorSpace(ptr, ptr)

declare i32 @DeleteColorSpace(ptr)

declare i32 @GetICMProfileA(ptr, ptr, ptr)

declare i32 @GetICMProfileW(ptr, ptr, ptr)

declare i32 @SetICMProfileA(ptr, ptr)

declare i32 @SetICMProfileW(ptr, ptr)

declare i32 @GetDeviceGammaRamp(ptr, ptr)

declare i32 @SetDeviceGammaRamp(ptr, ptr)

declare i32 @ColorMatchToTarget(ptr, ptr, i64)

declare i32 @EnumICMProfilesA(ptr, ptr, i64)

declare i32 @EnumICMProfilesW(ptr, ptr, i64)

declare i32 @UpdateICMRegKeyA(i64, ptr, ptr, i64)

declare i32 @UpdateICMRegKeyW(i64, ptr, ptr, i64)

declare i32 @ColorCorrectPalette(ptr, ptr, i64, i64)

declare i32 @wglCopyContext(ptr, ptr, i64)

declare ptr @wglCreateContext(ptr)

declare ptr @wglCreateLayerContext(ptr, i32)

declare i32 @wglDeleteContext(ptr)

declare ptr @wglGetCurrentContext()

declare ptr @wglGetCurrentDC()

declare ptr @wglGetProcAddress(ptr)

declare i32 @wglMakeCurrent(ptr, ptr)

declare i32 @wglShareLists(ptr, ptr)

declare i32 @wglUseFontBitmapsA(ptr, i64, i64, i64)

declare i32 @wglUseFontBitmapsW(ptr, i64, i64, i64)

declare i32 @SwapBuffers(ptr)

declare i32 @wglUseFontOutlinesA(ptr, i64, i64, i64, float, float, i32, ptr)

declare i32 @wglUseFontOutlinesW(ptr, i64, i64, i64, float, float, i32, ptr)

declare i32 @wglDescribeLayerPlane(ptr, i32, i32, i64, ptr)

declare i32 @wglSetLayerPaletteEntries(ptr, i32, i32, i32, ptr)

declare i32 @wglGetLayerPaletteEntries(ptr, i32, i32, i32, ptr)

declare i32 @wglRealizeLayerPalette(ptr, i32, i32)

declare i32 @wglSwapLayerBuffers(ptr, i64)

declare i64 @wglSwapMultipleBuffers(i64, ptr)

declare i32 @wvsprintfA(ptr, ptr, ptr)

declare i32 @wvsprintfW(ptr, ptr, ptr)

declare i32 @wsprintfA(ptr, ptr)

declare i32 @wsprintfW(ptr, ptr)

declare ptr @LoadKeyboardLayoutA(ptr, i64)

declare ptr @LoadKeyboardLayoutW(ptr, i64)

declare ptr @ActivateKeyboardLayout(ptr, i64)

declare i32 @ToUnicodeEx(i64, i64, ptr, ptr, i32, i64, ptr)

declare i32 @UnloadKeyboardLayout(ptr)

declare i32 @GetKeyboardLayoutNameA(ptr)

declare i32 @GetKeyboardLayoutNameW(ptr)

declare i32 @GetKeyboardLayoutList(i32, ptr)

declare ptr @GetKeyboardLayout(i64)

declare i32 @GetMouseMovePointsEx(i64, ptr, ptr, i32, i64)

declare ptr @CreateDesktopA(ptr, ptr, ptr, i64, i64, ptr)

declare ptr @CreateDesktopW(ptr, ptr, ptr, i64, i64, ptr)

declare ptr @CreateDesktopExA(ptr, ptr, ptr, i64, i64, ptr, i64, ptr)

declare ptr @CreateDesktopExW(ptr, ptr, ptr, i64, i64, ptr, i64, ptr)

declare ptr @OpenDesktopA(ptr, i64, i32, i64)

declare ptr @OpenDesktopW(ptr, i64, i32, i64)

declare ptr @OpenInputDesktop(i64, i32, i64)

declare i32 @EnumDesktopsA(ptr, ptr, i64)

declare i32 @EnumDesktopsW(ptr, ptr, i64)

declare i32 @EnumDesktopWindows(ptr, ptr, i64)

declare i32 @SwitchDesktop(ptr)

declare i32 @SetThreadDesktop(ptr)

declare i32 @CloseDesktop(ptr)

declare ptr @GetThreadDesktop(i64)

declare ptr @CreateWindowStationA(ptr, i64, i64, ptr)

declare ptr @CreateWindowStationW(ptr, i64, i64, ptr)

declare ptr @OpenWindowStationA(ptr, i32, i64)

declare ptr @OpenWindowStationW(ptr, i32, i64)

declare i32 @EnumWindowStationsA(ptr, i64)

declare i32 @EnumWindowStationsW(ptr, i64)

declare i32 @CloseWindowStation(ptr)

declare i32 @SetProcessWindowStation(ptr)

declare ptr @GetProcessWindowStation()

declare i32 @SetUserObjectSecurity(ptr, ptr, ptr)

declare i32 @GetUserObjectSecurity(ptr, ptr, ptr, i64, ptr)

declare i32 @GetUserObjectInformationA(ptr, i32, ptr, i64, ptr)

declare i32 @GetUserObjectInformationW(ptr, i32, ptr, i64, ptr)

declare i32 @SetUserObjectInformationA(ptr, i32, ptr, i64)

declare i32 @SetUserObjectInformationW(ptr, i32, ptr, i64)

declare i32 @IsHungAppWindow(ptr)

declare void @DisableProcessWindowsGhosting()

declare i64 @RegisterWindowMessageA(ptr)

declare i64 @RegisterWindowMessageW(ptr)

declare i32 @TrackMouseEvent(ptr)

declare i32 @DrawEdge(ptr, ptr, i64, i64)

declare i32 @DrawFrameControl(ptr, ptr, i64, i64)

declare i32 @DrawCaption(ptr, ptr, ptr, i64)

declare i32 @DrawAnimatedRects(ptr, i32, ptr, ptr)

declare i32 @GetMessageA(ptr, ptr, i64, i64)

declare i32 @GetMessageW(ptr, ptr, i64, i64)

declare i32 @TranslateMessage(ptr)

declare i64 @DispatchMessageA(ptr)

declare i64 @DispatchMessageW(ptr)

declare i32 @SetMessageQueue(i32)

declare i32 @PeekMessageA(ptr, ptr, i64, i64, i64)

declare i32 @PeekMessageW(ptr, ptr, i64, i64, i64)

declare i32 @RegisterHotKey(ptr, i32, i64, i64)

declare i32 @UnregisterHotKey(ptr, i32)

declare i32 @ExitWindowsEx(i64, i64)

declare i32 @SwapMouseButton(i32)

declare i64 @GetMessagePos()

declare i64 @GetMessageTime()

declare i64 @GetMessageExtraInfo()

declare i64 @GetUnpredictedMessagePos()

declare i32 @IsWow64Message()

declare i64 @SetMessageExtraInfo(i64)

declare i64 @SendMessageA(ptr, i64, i64, i64)

declare i64 @SendMessageW(ptr, i64, i64, i64)

declare i64 @SendMessageTimeoutA(ptr, i64, i64, i64, i64, i64, ptr)

declare i64 @SendMessageTimeoutW(ptr, i64, i64, i64, i64, i64, ptr)

declare i32 @SendNotifyMessageA(ptr, i64, i64, i64)

declare i32 @SendNotifyMessageW(ptr, i64, i64, i64)

declare i32 @SendMessageCallbackA(ptr, i64, i64, i64, ptr, i64)

declare i32 @SendMessageCallbackW(ptr, i64, i64, i64, ptr, i64)

declare i64 @BroadcastSystemMessageExA(i64, ptr, i64, i64, i64, ptr)

declare i64 @BroadcastSystemMessageExW(i64, ptr, i64, i64, i64, ptr)

declare i64 @BroadcastSystemMessageA(i64, ptr, i64, i64, i64)

declare i64 @BroadcastSystemMessageW(i64, ptr, i64, i64, i64)

declare ptr @RegisterDeviceNotificationA(ptr, ptr, i64)

declare ptr @RegisterDeviceNotificationW(ptr, ptr, i64)

declare i32 @UnregisterDeviceNotification(ptr)

declare ptr @RegisterPowerSettingNotification(ptr, ptr, i64)

declare i32 @UnregisterPowerSettingNotification(ptr)

declare ptr @RegisterSuspendResumeNotification(ptr, i64)

declare i32 @UnregisterSuspendResumeNotification(ptr)

declare i32 @PostMessageA(ptr, i64, i64, i64)

declare i32 @PostMessageW(ptr, i64, i64, i64)

declare i32 @PostThreadMessageA(i64, i64, i64, i64)

declare i32 @PostThreadMessageW(i64, i64, i64, i64)

declare i32 @AttachThreadInput(i64, i64, i32)

declare i32 @ReplyMessage(i64)

declare i32 @WaitMessage()

declare i64 @WaitForInputIdle(ptr, i64)

declare i64 @DefWindowProcA(ptr, i64, i64, i64)

declare i64 @DefWindowProcW(ptr, i64, i64, i64)

declare void @PostQuitMessage(i32)

declare i64 @CallWindowProcA(ptr, ptr, i64, i64, i64)

declare i64 @CallWindowProcW(ptr, ptr, i64, i64, i64)

declare i32 @InSendMessage()

declare i64 @InSendMessageEx(ptr)

declare i64 @GetDoubleClickTime()

declare i32 @SetDoubleClickTime(i64)

declare i64 @RegisterClassA(ptr)

declare i64 @RegisterClassW(ptr)

declare i32 @UnregisterClassA(ptr, ptr)

declare i32 @UnregisterClassW(ptr, ptr)

declare i32 @GetClassInfoA(ptr, ptr, ptr)

declare i32 @GetClassInfoW(ptr, ptr, ptr)

declare i64 @RegisterClassExA(ptr)

declare i64 @RegisterClassExW(ptr)

declare i32 @GetClassInfoExA(ptr, ptr, ptr)

declare i32 @GetClassInfoExW(ptr, ptr, ptr)

declare ptr @CreateWindowExA(i64, ptr, ptr, i64, i32, i32, i32, i32, ptr, ptr, ptr, ptr)

declare ptr @CreateWindowExW(i64, ptr, ptr, i64, i32, i32, i32, i32, ptr, ptr, ptr, ptr)

declare i32 @IsWindow(ptr)

declare i32 @IsMenu(ptr)

declare i32 @IsChild(ptr, ptr)

declare i32 @DestroyWindow(ptr)

declare i32 @ShowWindow(ptr, i32)

declare i32 @AnimateWindow(ptr, i64, i64)

declare i32 @UpdateLayeredWindow(ptr, ptr, ptr, ptr, ptr, ptr, i64, ptr, i64)

declare i32 @UpdateLayeredWindowIndirect(ptr, ptr)

declare i32 @GetLayeredWindowAttributes(ptr, ptr, ptr, ptr)

declare i32 @PrintWindow(ptr, ptr, i64)

declare i32 @SetLayeredWindowAttributes(ptr, i64, i64, i64)

declare i32 @ShowWindowAsync(ptr, i32)

declare i32 @FlashWindow(ptr, i32)

declare i32 @FlashWindowEx(ptr)

declare i32 @ShowOwnedPopups(ptr, i32)

declare i32 @OpenIcon(ptr)

declare i32 @CloseWindow(ptr)

declare i32 @MoveWindow(ptr, i32, i32, i32, i32, i32)

declare i32 @SetWindowPos(ptr, ptr, i32, i32, i32, i32, i64)

declare i32 @GetWindowPlacement(ptr, ptr)

declare i32 @SetWindowPlacement(ptr, ptr)

declare i32 @GetWindowDisplayAffinity(ptr, ptr)

declare i32 @SetWindowDisplayAffinity(ptr, i64)

declare ptr @BeginDeferWindowPos(i32)

declare ptr @DeferWindowPos(ptr, ptr, ptr, i32, i32, i32, i32, i64)

declare i32 @EndDeferWindowPos(ptr)

declare i32 @IsWindowVisible(ptr)

declare i32 @IsIconic(ptr)

declare i32 @AnyPopup()

declare i32 @BringWindowToTop(ptr)

declare i32 @IsZoomed(ptr)

declare ptr @CreateDialogParamA(ptr, ptr, ptr, ptr, i64)

declare ptr @CreateDialogParamW(ptr, ptr, ptr, ptr, i64)

declare ptr @CreateDialogIndirectParamA(ptr, ptr, ptr, ptr, i64)

declare ptr @CreateDialogIndirectParamW(ptr, ptr, ptr, ptr, i64)

declare i64 @DialogBoxParamA(ptr, ptr, ptr, ptr, i64)

declare i64 @DialogBoxParamW(ptr, ptr, ptr, ptr, i64)

declare i64 @DialogBoxIndirectParamA(ptr, ptr, ptr, ptr, i64)

declare i64 @DialogBoxIndirectParamW(ptr, ptr, ptr, ptr, i64)

declare i32 @EndDialog(ptr, i64)

declare ptr @GetDlgItem(ptr, i32)

declare i32 @SetDlgItemInt(ptr, i32, i64, i32)

declare i64 @GetDlgItemInt(ptr, i32, ptr, i32)

declare i32 @SetDlgItemTextA(ptr, i32, ptr)

declare i32 @SetDlgItemTextW(ptr, i32, ptr)

declare i64 @GetDlgItemTextA(ptr, i32, ptr, i32)

declare i64 @GetDlgItemTextW(ptr, i32, ptr, i32)

declare i32 @CheckDlgButton(ptr, i32, i64)

declare i32 @CheckRadioButton(ptr, i32, i32, i32)

declare i64 @IsDlgButtonChecked(ptr, i32)

declare i64 @SendDlgItemMessageA(ptr, i32, i64, i64, i64)

declare i64 @SendDlgItemMessageW(ptr, i32, i64, i64, i64)

declare ptr @GetNextDlgGroupItem(ptr, ptr, i32)

declare ptr @GetNextDlgTabItem(ptr, ptr, i32)

declare i32 @GetDlgCtrlID(ptr)

declare i64 @GetDialogBaseUnits()

declare i64 @DefDlgProcA(ptr, i64, i64, i64)

declare i64 @DefDlgProcW(ptr, i64, i64, i64)

declare i32 @SetDialogControlDpiChangeBehavior(ptr, i64, i64)

declare i64 @GetDialogControlDpiChangeBehavior(ptr)

declare i32 @SetDialogDpiChangeBehavior(ptr, i64, i64)

declare i64 @GetDialogDpiChangeBehavior(ptr)

declare i32 @CallMsgFilterA(ptr, i32)

declare i32 @CallMsgFilterW(ptr, i32)

declare i32 @OpenClipboard(ptr)

declare i32 @CloseClipboard()

declare i64 @GetClipboardSequenceNumber()

declare ptr @GetClipboardOwner()

declare ptr @SetClipboardViewer(ptr)

declare ptr @GetClipboardViewer()

declare i32 @ChangeClipboardChain(ptr, ptr)

declare ptr @SetClipboardData(i64, ptr)

declare ptr @GetClipboardData(i64)

declare i32 @GetClipboardMetadata(i64, ptr)

declare i64 @RegisterClipboardFormatA(ptr)

declare i64 @RegisterClipboardFormatW(ptr)

declare i32 @CountClipboardFormats()

declare i64 @EnumClipboardFormats(i64)

declare i32 @GetClipboardFormatNameA(i64, ptr, i32)

declare i32 @GetClipboardFormatNameW(i64, ptr, i32)

declare i32 @EmptyClipboard()

declare i32 @IsClipboardFormatAvailable(i64)

declare i32 @GetPriorityClipboardFormat(ptr, i32)

declare ptr @GetOpenClipboardWindow()

declare i32 @AddClipboardFormatListener(ptr)

declare i32 @RemoveClipboardFormatListener(ptr)

declare i32 @GetUpdatedClipboardFormats(ptr, i64, ptr)

declare i32 @CharToOemA(ptr, ptr)

declare i32 @CharToOemW(ptr, ptr)

declare i32 @OemToCharA(ptr, ptr)

declare i32 @OemToCharW(ptr, ptr)

declare i32 @CharToOemBuffA(ptr, ptr, i64)

declare i32 @CharToOemBuffW(ptr, ptr, i64)

declare i32 @OemToCharBuffA(ptr, ptr, i64)

declare i32 @OemToCharBuffW(ptr, ptr, i64)

declare ptr @CharUpperA(ptr)

declare ptr @CharUpperW(ptr)

declare i64 @CharUpperBuffA(ptr, i64)

declare i64 @CharUpperBuffW(ptr, i64)

declare ptr @CharLowerA(ptr)

declare ptr @CharLowerW(ptr)

declare i64 @CharLowerBuffA(ptr, i64)

declare i64 @CharLowerBuffW(ptr, i64)

declare ptr @CharNextA(ptr)

declare ptr @CharNextW(ptr)

declare ptr @CharPrevA(ptr, ptr)

declare ptr @CharPrevW(ptr, ptr)

declare ptr @CharNextExA(i64, ptr, i64)

declare ptr @CharPrevExA(i64, ptr, ptr, i64)

declare i32 @IsCharAlphaA(i64)

declare i32 @IsCharAlphaW(i64)

declare i32 @IsCharAlphaNumericA(i64)

declare i32 @IsCharAlphaNumericW(i64)

declare i32 @IsCharUpperA(i64)

declare i32 @IsCharUpperW(i64)

declare i32 @IsCharLowerA(i64)

declare i32 @IsCharLowerW(i64)

declare ptr @SetFocus(ptr)

declare ptr @GetActiveWindow()

declare ptr @GetFocus()

declare i64 @GetKBCodePage()

declare i64 @GetKeyState(i32)

declare i64 @GetAsyncKeyState(i32)

declare i32 @GetKeyboardState(ptr)

declare i32 @SetKeyboardState(ptr)

declare i32 @GetKeyNameTextA(i64, ptr, i32)

declare i32 @GetKeyNameTextW(i64, ptr, i32)

declare i32 @GetKeyboardType(i32)

declare i32 @ToAscii(i64, i64, ptr, ptr, i64)

declare i32 @ToAsciiEx(i64, i64, ptr, ptr, i64, ptr)

declare i32 @ToUnicode(i64, i64, ptr, ptr, i32, i64)

declare i64 @OemKeyScan(i64)

declare i64 @VkKeyScanA(i64)

declare i64 @VkKeyScanW(i64)

declare i64 @VkKeyScanExA(i64, ptr)

declare i64 @VkKeyScanExW(i64, ptr)

declare void @keybd_event(i64, i64, i64, i64)

declare void @mouse_event(i64, i64, i64, i64, i64)

declare i64 @SendInput(i64, ptr, i32)

declare i32 @GetTouchInputInfo(ptr, i64, ptr, i32)

declare i32 @CloseTouchInputHandle(ptr)

declare i32 @RegisterTouchWindow(ptr, i64)

declare i32 @UnregisterTouchWindow(ptr)

declare i32 @IsTouchWindow(ptr, ptr)

declare i32 @InitializeTouchInjection(i64, i64)

declare i32 @InjectTouchInput(i64, ptr)

declare i32 @GetPointerType(i64, ptr)

declare i32 @GetPointerCursorId(i64, ptr)

declare i32 @GetPointerInfo(i64, ptr)

declare i32 @GetPointerInfoHistory(i64, ptr, ptr)

declare i32 @GetPointerFrameInfo(i64, ptr, ptr)

declare i32 @GetPointerFrameInfoHistory(i64, ptr, ptr, ptr)

declare i32 @GetPointerTouchInfo(i64, ptr)

declare i32 @GetPointerTouchInfoHistory(i64, ptr, ptr)

declare i32 @GetPointerFrameTouchInfo(i64, ptr, ptr)

declare i32 @GetPointerFrameTouchInfoHistory(i64, ptr, ptr, ptr)

declare i32 @GetPointerPenInfo(i64, ptr)

declare i32 @GetPointerPenInfoHistory(i64, ptr, ptr)

declare i32 @GetPointerFramePenInfo(i64, ptr, ptr)

declare i32 @GetPointerFramePenInfoHistory(i64, ptr, ptr, ptr)

declare i32 @SkipPointerFrameMessages(i64)

declare i32 @RegisterPointerInputTarget(ptr, i64)

declare i32 @UnregisterPointerInputTarget(ptr, i64)

declare i32 @RegisterPointerInputTargetEx(ptr, i64, i32)

declare i32 @UnregisterPointerInputTargetEx(ptr, i64)

declare ptr @CreateSyntheticPointerDevice(i64, i64, i64)

declare i32 @InjectSyntheticPointerInput(ptr, ptr, i64)

declare void @DestroySyntheticPointerDevice(ptr)

declare i32 @EnableMouseInPointer(i32)

declare i32 @IsMouseInPointerEnabled()

declare i32 @EnableMouseInPointerForThread()

declare i32 @RegisterTouchHitTestingWindow(ptr, i64)

declare i32 @EvaluateProximityToRect(ptr, ptr, ptr)

declare i32 @EvaluateProximityToPolygon(i64, ptr, ptr, ptr)

declare i64 @PackTouchHitTestingProximityEvaluation(ptr, ptr)

declare i32 @GetWindowFeedbackSetting(ptr, i64, i64, ptr, ptr)

declare i32 @SetWindowFeedbackSetting(ptr, i64, i64, i64, ptr)

declare i32 @GetPointerInputTransform(i64, i64, ptr)

declare i32 @GetLastInputInfo(ptr)

declare i64 @MapVirtualKeyA(i64, i64)

declare i64 @MapVirtualKeyW(i64, i64)

declare i64 @MapVirtualKeyExA(i64, i64, ptr)

declare i64 @MapVirtualKeyExW(i64, i64, ptr)

declare i32 @GetInputState()

declare i64 @GetQueueStatus(i64)

declare ptr @GetCapture()

declare ptr @SetCapture(ptr)

declare i32 @ReleaseCapture()

declare i64 @MsgWaitForMultipleObjects(i64, ptr, i32, i64, i64)

declare i64 @MsgWaitForMultipleObjectsEx(i64, ptr, i64, i64, i64)

declare i64 @SetTimer(ptr, i64, i64, ptr)

declare i64 @SetCoalescableTimer(ptr, i64, i64, ptr, i64)

declare i32 @KillTimer(ptr, i64)

declare i32 @IsWindowUnicode(ptr)

declare i32 @EnableWindow(ptr, i32)

declare i32 @IsWindowEnabled(ptr)

declare ptr @LoadAcceleratorsA(ptr, ptr)

declare ptr @LoadAcceleratorsW(ptr, ptr)

declare ptr @CreateAcceleratorTableA(ptr, i32)

declare ptr @CreateAcceleratorTableW(ptr, i32)

declare i32 @DestroyAcceleratorTable(ptr)

declare i32 @CopyAcceleratorTableA(ptr, ptr, i32)

declare i32 @CopyAcceleratorTableW(ptr, ptr, i32)

declare i32 @TranslateAcceleratorA(ptr, ptr, ptr)

declare i32 @TranslateAcceleratorW(ptr, ptr, ptr)

declare i32 @GetSystemMetrics(i32)

declare i32 @GetSystemMetricsForDpi(i32, i64)

declare ptr @LoadMenuA(ptr, ptr)

declare ptr @LoadMenuW(ptr, ptr)

declare ptr @LoadMenuIndirectA(ptr)

declare ptr @LoadMenuIndirectW(ptr)

declare ptr @GetMenu(ptr)

declare i32 @SetMenu(ptr, ptr)

declare i32 @ChangeMenuA(ptr, i64, ptr, i64, i64)

declare i32 @ChangeMenuW(ptr, i64, ptr, i64, i64)

declare i32 @HiliteMenuItem(ptr, ptr, i64, i64)

declare i32 @GetMenuStringA(ptr, i64, ptr, i32, i64)

declare i32 @GetMenuStringW(ptr, i64, ptr, i32, i64)

declare i64 @GetMenuState(ptr, i64, i64)

declare i32 @DrawMenuBar(ptr)

declare ptr @GetSystemMenu(ptr, i32)

declare ptr @CreateMenu()

declare ptr @CreatePopupMenu()

declare i32 @DestroyMenu(ptr)

declare i64 @CheckMenuItem(ptr, i64, i64)

declare i32 @EnableMenuItem(ptr, i64, i64)

declare ptr @GetSubMenu(ptr, i32)

declare i64 @GetMenuItemID(ptr, i32)

declare i32 @GetMenuItemCount(ptr)

declare i32 @InsertMenuA(ptr, i64, i64, i64, ptr)

declare i32 @InsertMenuW(ptr, i64, i64, i64, ptr)

declare i32 @AppendMenuA(ptr, i64, i64, ptr)

declare i32 @AppendMenuW(ptr, i64, i64, ptr)

declare i32 @ModifyMenuA(ptr, i64, i64, i64, ptr)

declare i32 @ModifyMenuW(ptr, i64, i64, i64, ptr)

declare i32 @RemoveMenu(ptr, i64, i64)

declare i32 @DeleteMenu(ptr, i64, i64)

declare i32 @SetMenuItemBitmaps(ptr, i64, i64, ptr, ptr)

declare i64 @GetMenuCheckMarkDimensions()

declare i32 @TrackPopupMenu(ptr, i64, i32, i32, i32, ptr, ptr)

declare i32 @TrackPopupMenuEx(ptr, i64, i32, i32, ptr, ptr)

declare i32 @CalculatePopupWindowPosition(ptr, ptr, i64, ptr, ptr)

declare i32 @GetMenuInfo(ptr, ptr)

declare i32 @SetMenuInfo(ptr, ptr)

declare i32 @EndMenu()

declare i32 @InsertMenuItemA(ptr, i64, i32, ptr)

declare i32 @InsertMenuItemW(ptr, i64, i32, ptr)

declare i32 @GetMenuItemInfoA(ptr, i64, i32, ptr)

declare i32 @GetMenuItemInfoW(ptr, i64, i32, ptr)

declare i32 @SetMenuItemInfoA(ptr, i64, i32, ptr)

declare i32 @SetMenuItemInfoW(ptr, i64, i32, ptr)

declare i64 @GetMenuDefaultItem(ptr, i64, i64)

declare i32 @SetMenuDefaultItem(ptr, i64, i64)

declare i32 @GetMenuItemRect(ptr, ptr, i64, ptr)

declare i32 @MenuItemFromPoint(ptr, ptr, i64)

declare i64 @DragObject(ptr, ptr, i64, i64, ptr)

declare i32 @DragDetect(ptr, i64)

declare i32 @DrawIcon(ptr, i32, i32, ptr)

declare i32 @DrawTextA(ptr, ptr, i32, ptr, i64)

declare i32 @DrawTextW(ptr, ptr, i32, ptr, i64)

declare i32 @DrawTextExA(ptr, ptr, i32, ptr, i64, ptr)

declare i32 @DrawTextExW(ptr, ptr, i32, ptr, i64, ptr)

declare i32 @GrayStringA(ptr, ptr, ptr, i64, i32, i32, i32, i32, i32)

declare i32 @GrayStringW(ptr, ptr, ptr, i64, i32, i32, i32, i32, i32)

declare i32 @DrawStateA(ptr, ptr, ptr, i64, i64, i32, i32, i32, i32, i64)

declare i32 @DrawStateW(ptr, ptr, ptr, i64, i64, i32, i32, i32, i32, i64)

declare i64 @TabbedTextOutA(ptr, i32, i32, ptr, i32, i32, ptr, i32)

declare i64 @TabbedTextOutW(ptr, i32, i32, ptr, i32, i32, ptr, i32)

declare i64 @GetTabbedTextExtentA(ptr, ptr, i32, i32, ptr)

declare i64 @GetTabbedTextExtentW(ptr, ptr, i32, i32, ptr)

declare i32 @UpdateWindow(ptr)

declare ptr @SetActiveWindow(ptr)

declare ptr @GetForegroundWindow()

declare i32 @PaintDesktop(ptr)

declare void @SwitchToThisWindow(ptr, i32)

declare i32 @SetForegroundWindow(ptr)

declare i32 @AllowSetForegroundWindow(i64)

declare i32 @LockSetForegroundWindow(i64)

declare ptr @WindowFromDC(ptr)

declare ptr @GetDC(ptr)

declare ptr @GetDCEx(ptr, ptr, i64)

declare ptr @GetWindowDC(ptr)

declare i32 @ReleaseDC(ptr, ptr)

declare ptr @BeginPaint(ptr, ptr)

declare i32 @EndPaint(ptr, ptr)

declare i32 @GetUpdateRect(ptr, ptr, i32)

declare i32 @GetUpdateRgn(ptr, ptr, i32)

declare i32 @SetWindowRgn(ptr, ptr, i32)

declare i32 @GetWindowRgn(ptr, ptr)

declare i32 @GetWindowRgnBox(ptr, ptr)

declare i32 @ExcludeUpdateRgn(ptr, ptr)

declare i32 @InvalidateRect(ptr, ptr, i32)

declare i32 @ValidateRect(ptr, ptr)

declare i32 @InvalidateRgn(ptr, ptr, i32)

declare i32 @ValidateRgn(ptr, ptr)

declare i32 @RedrawWindow(ptr, ptr, ptr, i64)

declare i32 @LockWindowUpdate(ptr)

declare i32 @ScrollWindow(ptr, i32, i32, ptr, ptr)

declare i32 @ScrollDC(ptr, i32, i32, ptr, ptr, ptr, ptr)

declare i32 @ScrollWindowEx(ptr, i32, i32, ptr, ptr, ptr, ptr, i64)

declare i32 @SetScrollPos(ptr, i32, i32, i32)

declare i32 @GetScrollPos(ptr, i32)

declare i32 @SetScrollRange(ptr, i32, i32, i32, i32)

declare i32 @GetScrollRange(ptr, i32, ptr, ptr)

declare i32 @ShowScrollBar(ptr, i32, i32)

declare i32 @EnableScrollBar(ptr, i64, i64)

declare i32 @SetPropA(ptr, ptr, ptr)

declare i32 @SetPropW(ptr, ptr, ptr)

declare ptr @GetPropA(ptr, ptr)

declare ptr @GetPropW(ptr, ptr)

declare ptr @RemovePropA(ptr, ptr)

declare ptr @RemovePropW(ptr, ptr)

declare i32 @EnumPropsExA(ptr, ptr, i64)

declare i32 @EnumPropsExW(ptr, ptr, i64)

declare i32 @EnumPropsA(ptr, ptr)

declare i32 @EnumPropsW(ptr, ptr)

declare i32 @SetWindowTextA(ptr, ptr)

declare i32 @SetWindowTextW(ptr, ptr)

declare i32 @GetWindowTextA(ptr, ptr, i32)

declare i32 @GetWindowTextW(ptr, ptr, i32)

declare i32 @GetWindowTextLengthA(ptr)

declare i32 @GetWindowTextLengthW(ptr)

declare i32 @GetClientRect(ptr, ptr)

declare i32 @GetWindowRect(ptr, ptr)

declare i32 @AdjustWindowRect(ptr, i64, i32)

declare i32 @AdjustWindowRectEx(ptr, i64, i32, i64)

declare i32 @AdjustWindowRectExForDpi(ptr, i64, i32, i64, i64)

declare i32 @SetWindowContextHelpId(ptr, i64)

declare i64 @GetWindowContextHelpId(ptr)

declare i32 @SetMenuContextHelpId(ptr, i64)

declare i64 @GetMenuContextHelpId(ptr)

declare i32 @MessageBoxA(ptr, ptr, ptr, i64)

declare i32 @MessageBoxW(ptr, ptr, ptr, i64)

declare i32 @MessageBoxExA(ptr, ptr, ptr, i64, i64)

declare i32 @MessageBoxExW(ptr, ptr, ptr, i64, i64)

declare i32 @MessageBoxIndirectA(ptr)

declare i32 @MessageBoxIndirectW(ptr)

declare i32 @MessageBeep(i64)

declare i32 @ShowCursor(i32)

declare i32 @SetCursorPos(i32, i32)

declare i32 @SetPhysicalCursorPos(i32, i32)

declare ptr @SetCursor(ptr)

declare i32 @GetCursorPos(ptr)

declare i32 @GetPhysicalCursorPos(ptr)

declare i32 @GetClipCursor(ptr)

declare ptr @GetCursor()

declare i32 @CreateCaret(ptr, ptr, i32, i32)

declare i64 @GetCaretBlinkTime()

declare i32 @SetCaretBlinkTime(i64)

declare i32 @DestroyCaret()

declare i32 @HideCaret(ptr)

declare i32 @ShowCaret(ptr)

declare i32 @SetCaretPos(i32, i32)

declare i32 @GetCaretPos(ptr)

declare i32 @ClientToScreen(ptr, ptr)

declare i32 @ScreenToClient(ptr, ptr)

declare i32 @LogicalToPhysicalPoint(ptr, ptr)

declare i32 @PhysicalToLogicalPoint(ptr, ptr)

declare i32 @LogicalToPhysicalPointForPerMonitorDPI(ptr, ptr)

declare i32 @PhysicalToLogicalPointForPerMonitorDPI(ptr, ptr)

declare i32 @MapWindowPoints(ptr, ptr, ptr, i64)

declare ptr @WindowFromPoint(i64)

declare ptr @WindowFromPhysicalPoint(i64)

declare ptr @ChildWindowFromPoint(ptr, i64)

declare i32 @ClipCursor(ptr)

declare ptr @ChildWindowFromPointEx(ptr, i64, i64)

declare i64 @GetSysColor(i32)

declare ptr @GetSysColorBrush(i32)

declare i32 @SetSysColors(i32, ptr, ptr)

declare i32 @DrawFocusRect(ptr, ptr)

declare i32 @FillRect(ptr, ptr, ptr)

declare i32 @FrameRect(ptr, ptr, ptr)

declare i32 @InvertRect(ptr, ptr)

declare i32 @SetRect(ptr, i32, i32, i32, i32)

declare i32 @SetRectEmpty(ptr)

declare i32 @CopyRect(ptr, ptr)

declare i32 @InflateRect(ptr, i32, i32)

declare i32 @IntersectRect(ptr, ptr, ptr)

declare i32 @UnionRect(ptr, ptr, ptr)

declare i32 @SubtractRect(ptr, ptr, ptr)

declare i32 @OffsetRect(ptr, i32, i32)

declare i32 @IsRectEmpty(ptr)

declare i32 @EqualRect(ptr, ptr)

declare i32 @PtInRect(ptr, i64)

declare i64 @GetWindowWord(ptr, i32)

declare i64 @SetWindowWord(ptr, i32, i64)

declare i64 @GetWindowLongA(ptr, i32)

declare i64 @GetWindowLongW(ptr, i32)

declare i64 @SetWindowLongA(ptr, i32, i64)

declare i64 @SetWindowLongW(ptr, i32, i64)

declare i64 @GetWindowLongPtrA(ptr, i32)

declare i64 @GetWindowLongPtrW(ptr, i32)

declare i64 @SetWindowLongPtrA(ptr, i32, i64)

declare i64 @SetWindowLongPtrW(ptr, i32, i64)

declare i64 @GetClassWord(ptr, i32)

declare i64 @SetClassWord(ptr, i32, i64)

declare i64 @GetClassLongA(ptr, i32)

declare i64 @GetClassLongW(ptr, i32)

declare i64 @SetClassLongA(ptr, i32, i64)

declare i64 @SetClassLongW(ptr, i32, i64)

declare i64 @GetClassLongPtrA(ptr, i32)

declare i64 @GetClassLongPtrW(ptr, i32)

declare i64 @SetClassLongPtrA(ptr, i32, i64)

declare i64 @SetClassLongPtrW(ptr, i32, i64)

declare i32 @GetProcessDefaultLayout(ptr)

declare i32 @SetProcessDefaultLayout(i64)

declare ptr @GetDesktopWindow()

declare ptr @GetParent(ptr)

declare ptr @SetParent(ptr, ptr)

declare i32 @EnumChildWindows(ptr, ptr, i64)

declare ptr @FindWindowA(ptr, ptr)

declare ptr @FindWindowW(ptr, ptr)

declare ptr @FindWindowExA(ptr, ptr, ptr, ptr)

declare ptr @FindWindowExW(ptr, ptr, ptr, ptr)

declare ptr @GetShellWindow()

declare i32 @RegisterShellHookWindow(ptr)

declare i32 @DeregisterShellHookWindow(ptr)

declare i32 @EnumWindows(ptr, i64)

declare i32 @EnumThreadWindows(i64, ptr, i64)

declare i32 @GetClassNameA(ptr, ptr, i32)

declare i32 @GetClassNameW(ptr, ptr, i32)

declare ptr @GetTopWindow(ptr)

declare i64 @GetWindowThreadProcessId(ptr, ptr)

declare i32 @IsGUIThread(i32)

declare ptr @GetLastActivePopup(ptr)

declare ptr @GetWindow(ptr, i64)

declare ptr @SetWindowsHookA(i32, ptr)

declare ptr @SetWindowsHookW(i32, ptr)

declare i32 @UnhookWindowsHook(i32, ptr)

declare ptr @SetWindowsHookExA(i32, ptr, ptr, i64)

declare ptr @SetWindowsHookExW(i32, ptr, ptr, i64)

declare i32 @UnhookWindowsHookEx(ptr)

declare i64 @CallNextHookEx(ptr, i32, i64, i64)

declare i32 @CheckMenuRadioItem(ptr, i64, i64, i64, i64)

declare ptr @LoadBitmapA(ptr, ptr)

declare ptr @LoadBitmapW(ptr, ptr)

declare ptr @LoadCursorA(ptr, ptr)

declare ptr @LoadCursorW(ptr, ptr)

declare ptr @LoadCursorFromFileA(ptr)

declare ptr @LoadCursorFromFileW(ptr)

declare ptr @CreateCursor(ptr, i32, i32, i32, i32, ptr, ptr)

declare i32 @DestroyCursor(ptr)

declare i32 @SetSystemCursor(ptr, i64)

declare ptr @LoadIconA(ptr, ptr)

declare ptr @LoadIconW(ptr, ptr)

declare i64 @PrivateExtractIconsA(ptr, i32, i32, i32, ptr, ptr, i64, i64)

declare i64 @PrivateExtractIconsW(ptr, i32, i32, i32, ptr, ptr, i64, i64)

declare ptr @CreateIcon(ptr, i32, i32, i64, i64, ptr, ptr)

declare i32 @DestroyIcon(ptr)

declare i32 @LookupIconIdFromDirectory(ptr, i32)

declare i32 @LookupIconIdFromDirectoryEx(ptr, i32, i32, i32, i64)

declare ptr @CreateIconFromResource(ptr, i64, i32, i64)

declare ptr @CreateIconFromResourceEx(ptr, i64, i32, i64, i32, i32, i64)

declare i64 @SetThreadCursorCreationScaling(i64)

declare ptr @LoadImageA(ptr, ptr, i64, i32, i32, i64)

declare ptr @LoadImageW(ptr, ptr, i64, i32, i32, i64)

declare ptr @CopyImage(ptr, i64, i32, i32, i64)

declare i32 @DrawIconEx(ptr, i32, i32, ptr, i32, i32, i64, ptr, i64)

declare ptr @CreateIconIndirect(ptr)

declare ptr @CopyIcon(ptr)

declare i32 @GetIconInfo(ptr, ptr)

declare i32 @GetIconInfoExA(ptr, ptr)

declare i32 @GetIconInfoExW(ptr, ptr)

declare i32 @IsDialogMessageA(ptr, ptr)

declare i32 @IsDialogMessageW(ptr, ptr)

declare i32 @MapDialogRect(ptr, ptr)

declare i32 @DlgDirListA(ptr, ptr, i32, i32, i64)

declare i32 @DlgDirListW(ptr, ptr, i32, i32, i64)

declare i32 @DlgDirSelectExA(ptr, ptr, i32, i32)

declare i32 @DlgDirSelectExW(ptr, ptr, i32, i32)

declare i32 @DlgDirListComboBoxA(ptr, ptr, i32, i32, i64)

declare i32 @DlgDirListComboBoxW(ptr, ptr, i32, i32, i64)

declare i32 @DlgDirSelectComboBoxExA(ptr, ptr, i32, i32)

declare i32 @DlgDirSelectComboBoxExW(ptr, ptr, i32, i32)

declare i32 @SetScrollInfo(ptr, i32, ptr, i32)

declare i32 @GetScrollInfo(ptr, i32, ptr)

declare i64 @DefFrameProcA(ptr, ptr, i64, i64, i64)

declare i64 @DefFrameProcW(ptr, ptr, i64, i64, i64)

declare i64 @DefMDIChildProcA(ptr, i64, i64, i64)

declare i64 @DefMDIChildProcW(ptr, i64, i64, i64)

declare i32 @TranslateMDISysAccel(ptr, ptr)

declare i64 @ArrangeIconicWindows(ptr)

declare ptr @CreateMDIWindowA(ptr, ptr, i64, i32, i32, i32, i32, ptr, ptr, i64)

declare ptr @CreateMDIWindowW(ptr, ptr, i64, i32, i32, i32, i32, ptr, ptr, i64)

declare i64 @TileWindows(ptr, i64, ptr, i64, ptr)

declare i64 @CascadeWindows(ptr, i64, ptr, i64, ptr)

declare i32 @WinHelpA(ptr, ptr, i64, i64)

declare i32 @WinHelpW(ptr, ptr, i64, i64)

declare i64 @GetGuiResources(ptr, i64)

declare i64 @ChangeDisplaySettingsA(ptr, i64)

declare i64 @ChangeDisplaySettingsW(ptr, i64)

declare i64 @ChangeDisplaySettingsExA(ptr, ptr, ptr, i64, ptr)

declare i64 @ChangeDisplaySettingsExW(ptr, ptr, ptr, i64, ptr)

declare i32 @EnumDisplaySettingsA(ptr, i64, ptr)

declare i32 @EnumDisplaySettingsW(ptr, i64, ptr)

declare i32 @EnumDisplaySettingsExA(ptr, i64, ptr, i64)

declare i32 @EnumDisplaySettingsExW(ptr, i64, ptr, i64)

declare i32 @EnumDisplayDevicesA(ptr, i64, ptr, i64)

declare i32 @EnumDisplayDevicesW(ptr, i64, ptr, i64)

declare i64 @GetDisplayConfigBufferSizes(i64, ptr, ptr)

declare i64 @SetDisplayConfig(i64, ptr, i64, ptr, i64)

declare i64 @QueryDisplayConfig(i64, ptr, ptr, ptr, ptr, ptr)

declare i64 @DisplayConfigGetDeviceInfo(ptr)

declare i64 @DisplayConfigSetDeviceInfo(ptr)

declare i32 @SystemParametersInfoA(i64, i64, ptr, i64)

declare i32 @SystemParametersInfoW(i64, i64, ptr, i64)

declare i32 @SystemParametersInfoForDpi(i64, i64, ptr, i64, i64)

declare i32 @SoundSentry()

declare void @SetDebugErrorLevel(i64)

declare void @SetLastErrorEx(i64, i64)

declare i32 @InternalGetWindowText(ptr, ptr, i32)

declare i32 @CancelShutdown()

declare ptr @MonitorFromPoint(i64, i64)

declare ptr @MonitorFromRect(ptr, i64)

declare ptr @MonitorFromWindow(ptr, i64)

declare i32 @GetMonitorInfoA(ptr, ptr)

declare i32 @GetMonitorInfoW(ptr, ptr)

declare i32 @EnumDisplayMonitors(ptr, ptr, ptr, i64)

declare void @NotifyWinEvent(i64, ptr, i64, i64)

declare ptr @SetWinEventHook(i64, i64, ptr, ptr, i64, i64, i64)

declare i32 @IsWinEventHookInstalled(i64)

declare i32 @UnhookWinEvent(ptr)

declare i32 @GetGUIThreadInfo(i64, ptr)

declare i32 @BlockInput(i32)

declare i32 @SetProcessDPIAware()

declare i32 @IsProcessDPIAware()

declare ptr @SetThreadDpiAwarenessContext(ptr)

declare ptr @GetThreadDpiAwarenessContext()

declare ptr @GetWindowDpiAwarenessContext(ptr)

declare i64 @GetAwarenessFromDpiAwarenessContext(ptr)

declare i64 @GetDpiFromDpiAwarenessContext(ptr)

declare i32 @AreDpiAwarenessContextsEqual(ptr, ptr)

declare i32 @IsValidDpiAwarenessContext(ptr)

declare i64 @GetDpiForWindow(ptr)

declare i64 @GetDpiForSystem()

declare i64 @GetSystemDpiForProcess(ptr)

declare i32 @EnableNonClientDpiScaling(ptr)

declare i32 @InheritWindowMonitor(ptr, ptr)

declare i32 @SetProcessDpiAwarenessContext(ptr)

declare ptr @GetDpiAwarenessContextForProcess(ptr)

declare i64 @SetThreadDpiHostingBehavior(i64)

declare i64 @GetThreadDpiHostingBehavior()

declare i64 @GetWindowDpiHostingBehavior(ptr)

declare i64 @GetWindowModuleFileNameA(ptr, ptr, i64)

declare i64 @GetWindowModuleFileNameW(ptr, ptr, i64)

declare i32 @GetCursorInfo(ptr)

declare i32 @GetWindowInfo(ptr, ptr)

declare i32 @GetTitleBarInfo(ptr, ptr)

declare i32 @GetMenuBarInfo(ptr, i64, i64, ptr)

declare i32 @GetScrollBarInfo(ptr, i64, ptr)

declare i32 @GetComboBoxInfo(ptr, ptr)

declare ptr @GetAncestor(ptr, i64)

declare ptr @RealChildWindowFromPoint(ptr, i64)

declare i64 @RealGetWindowClassA(ptr, ptr, i64)

declare i64 @RealGetWindowClassW(ptr, ptr, i64)

declare i32 @GetAltTabInfoA(ptr, i32, ptr, ptr, i64)

declare i32 @GetAltTabInfoW(ptr, i32, ptr, ptr, i64)

declare i64 @GetListBoxInfo(ptr)

declare i32 @LockWorkStation()

declare i32 @UserHandleGrantAccess(ptr, ptr, i32)

declare i64 @GetRawInputData(ptr, i64, ptr, ptr, i64)

declare i64 @GetRawInputDeviceInfoA(ptr, i64, ptr, ptr)

declare i64 @GetRawInputDeviceInfoW(ptr, i64, ptr, ptr)

declare i64 @GetRawInputBuffer(ptr, ptr, i64)

declare i32 @RegisterRawInputDevices(ptr, i64, i64)

declare i64 @GetRegisteredRawInputDevices(ptr, ptr, i64)

declare i64 @GetRawInputDeviceList(ptr, ptr, i64)

declare i64 @DefRawInputProc(ptr, i32, i64)

declare i32 @GetPointerDevices(ptr, ptr)

declare i32 @GetPointerDevice(ptr, ptr)

declare i32 @GetPointerDeviceProperties(ptr, ptr, ptr)

declare i32 @RegisterPointerDeviceNotifications(ptr, i32)

declare i32 @GetPointerDeviceRects(ptr, ptr, ptr)

declare i32 @GetPointerDeviceCursors(ptr, ptr, ptr)

declare i32 @GetRawPointerDeviceData(i64, i64, i64, ptr, ptr)

declare i32 @ChangeWindowMessageFilter(i64, i64)

declare i32 @ChangeWindowMessageFilterEx(ptr, i64, i64, ptr)

declare i32 @GetGestureInfo(ptr, ptr)

declare i32 @GetGestureExtraArgs(ptr, i64, ptr)

declare i32 @CloseGestureInfoHandle(ptr)

declare i32 @SetGestureConfig(ptr, i64, i64, ptr, i64)

declare i32 @GetGestureConfig(ptr, i64, i64, ptr, ptr, i64)

declare i32 @ShutdownBlockReasonCreate(ptr, ptr)

declare i32 @ShutdownBlockReasonQuery(ptr, ptr, ptr)

declare i32 @ShutdownBlockReasonDestroy(ptr)

declare i32 @GetCurrentInputMessageSource(ptr)

declare i32 @GetCIMSSM(ptr)

declare i32 @GetAutoRotationState(ptr)

declare i32 @GetDisplayAutoRotationPreferences(ptr)

declare i32 @GetDisplayAutoRotationPreferencesByProcessId(i64, ptr, ptr)

declare i32 @SetDisplayAutoRotationPreferences(i64)

declare i32 @IsImmersiveProcess(ptr)

declare i32 @SetProcessRestrictionExemption(i32)

declare i32 @ConvertToInterceptWindow(ptr)

declare i32 @IsInterceptWindow(ptr, ptr)

declare i32 @ApplyWindowAction(ptr, ptr)

declare i32 @SetAdditionalForegroundBoostProcesses(ptr, i64, ptr)

declare i32 @RegisterForTooltipDismissNotification(ptr, i64)

declare i32 @IsWindowArranged(ptr)

declare i64 @GetCurrentMonitorTopologyId()

declare i32 @RegisterCloakedNotification(ptr, i32)

declare i32 @EnterMoveSizeLoop(ptr, i64, i64)

declare i32 @GetDateFormatA(i64, i64, ptr, ptr, ptr, i32)

declare i32 @GetDateFormatW(i64, i64, ptr, ptr, ptr, i32)

declare i32 @GetTimeFormatA(i64, i64, ptr, ptr, ptr, i32)

declare i32 @GetTimeFormatW(i64, i64, ptr, ptr, ptr, i32)

declare i32 @GetTimeFormatEx(ptr, i64, ptr, ptr, ptr, i32)

declare i32 @GetDateFormatEx(ptr, i64, ptr, ptr, ptr, i32, ptr)

declare i32 @GetDurationFormatEx(ptr, i64, ptr, i64, ptr, ptr, i32)

declare i32 @CompareStringEx(ptr, i64, ptr, i32, ptr, i32, ptr, ptr, i64)

declare i32 @CompareStringOrdinal(ptr, i32, ptr, i32, i32)

declare i32 @CompareStringW(i64, i64, ptr, i32, ptr, i32)

declare i32 @FoldStringW(i64, ptr, i32, ptr, i32)

declare i32 @GetStringTypeExW(i64, i64, ptr, i32, ptr)

declare i32 @GetStringTypeW(i64, ptr, i32, ptr)

declare i32 @MultiByteToWideChar(i64, i64, ptr, i32, ptr, i32)

declare i32 @WideCharToMultiByte(i64, i64, ptr, i32, ptr, i32, ptr, ptr)

declare i32 @IsValidCodePage(i64)

declare i64 @GetACP()

declare i64 @GetOEMCP()

declare i32 @GetCPInfo(i64, ptr)

declare i32 @GetCPInfoExA(i64, i64, ptr)

declare i32 @GetCPInfoExW(i64, i64, ptr)

declare i32 @CompareStringA(i64, i64, ptr, i32, ptr, i32)

declare i32 @FindNLSString(i64, i64, ptr, i32, ptr, i32, ptr)

declare i32 @LCMapStringW(i64, i64, ptr, i32, ptr, i32)

declare i32 @LCMapStringA(i64, i64, ptr, i32, ptr, i32)

declare i32 @GetLocaleInfoW(i64, i64, ptr, i32)

declare i32 @GetLocaleInfoA(i64, i64, ptr, i32)

declare i32 @SetLocaleInfoA(i64, i64, ptr)

declare i32 @SetLocaleInfoW(i64, i64, ptr)

declare i32 @GetCalendarInfoA(i64, i64, i64, ptr, i32, ptr)

declare i32 @GetCalendarInfoW(i64, i64, i64, ptr, i32, ptr)

declare i32 @SetCalendarInfoA(i64, i64, i64, ptr)

declare i32 @SetCalendarInfoW(i64, i64, i64, ptr)

declare i32 @LoadStringByReference(i64, ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @IsDBCSLeadByte(i64)

declare i32 @IsDBCSLeadByteEx(i64, i64)

declare i64 @LocaleNameToLCID(ptr, i64)

declare i32 @LCIDToLocaleName(i64, ptr, i32, i64)

declare i32 @GetDurationFormat(i64, i64, ptr, i64, ptr, ptr, i32)

declare i32 @GetNumberFormatA(i64, i64, ptr, ptr, ptr, i32)

declare i32 @GetNumberFormatW(i64, i64, ptr, ptr, ptr, i32)

declare i32 @GetCurrencyFormatA(i64, i64, ptr, ptr, ptr, i32)

declare i32 @GetCurrencyFormatW(i64, i64, ptr, ptr, ptr, i32)

declare i32 @EnumCalendarInfoA(ptr, i64, i64, i64)

declare i32 @EnumCalendarInfoW(ptr, i64, i64, i64)

declare i32 @EnumCalendarInfoExA(ptr, i64, i64, i64)

declare i32 @EnumCalendarInfoExW(ptr, i64, i64, i64)

declare i32 @EnumTimeFormatsA(ptr, i64, i64)

declare i32 @EnumTimeFormatsW(ptr, i64, i64)

declare i32 @EnumDateFormatsA(ptr, i64, i64)

declare i32 @EnumDateFormatsW(ptr, i64, i64)

declare i32 @EnumDateFormatsExA(ptr, i64, i64)

declare i32 @EnumDateFormatsExW(ptr, i64, i64)

declare i32 @IsValidLanguageGroup(i64, i64)

declare i32 @GetNLSVersion(i64, i64, ptr)

declare i32 @IsValidLocale(i64, i64)

declare i32 @GetGeoInfoA(i64, i64, ptr, i32, i64)

declare i32 @GetGeoInfoW(i64, i64, ptr, i32, i64)

declare i32 @GetGeoInfoEx(ptr, i64, ptr, i32)

declare i32 @EnumSystemGeoID(i64, i64, ptr)

declare i32 @EnumSystemGeoNames(i64, ptr, i64)

declare i64 @GetUserGeoID(i64)

declare i32 @GetUserDefaultGeoName(ptr, i32)

declare i32 @SetUserGeoID(i64)

declare i32 @SetUserGeoName(ptr)

declare i64 @ConvertDefaultLocale(i64)

declare i64 @GetSystemDefaultUILanguage()

declare i64 @GetThreadLocale()

declare i32 @SetThreadLocale(i64)

declare i64 @GetUserDefaultUILanguage()

declare i64 @GetUserDefaultLangID()

declare i64 @GetSystemDefaultLangID()

declare i64 @GetSystemDefaultLCID()

declare i64 @GetUserDefaultLCID()

declare i64 @SetThreadUILanguage(i64)

declare i64 @GetThreadUILanguage()

declare i32 @GetProcessPreferredUILanguages(i64, ptr, ptr, ptr)

declare i32 @SetProcessPreferredUILanguages(i64, ptr, ptr)

declare i32 @GetUserPreferredUILanguages(i64, ptr, ptr, ptr)

declare i32 @GetSystemPreferredUILanguages(i64, ptr, ptr, ptr)

declare i32 @GetThreadPreferredUILanguages(i64, ptr, ptr, ptr)

declare i32 @SetThreadPreferredUILanguages(i64, ptr, ptr)

declare i32 @GetFileMUIInfo(i64, ptr, ptr, ptr)

declare i32 @GetFileMUIPath(i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @GetUILanguageInfo(i64, ptr, ptr, ptr, ptr)

declare i32 @SetThreadPreferredUILanguages2(i64, ptr, ptr, ptr)

declare void @RestoreThreadPreferredUILanguages(ptr)

declare i32 @NotifyUILanguageChange(i64, ptr, ptr, i64, ptr)

declare i32 @GetStringTypeExA(i64, i64, ptr, i32, ptr)

declare i32 @GetStringTypeA(i64, i64, ptr, i32, ptr)

declare i32 @FoldStringA(i64, ptr, i32, ptr, i32)

declare i32 @EnumSystemLocalesA(ptr, i64)

declare i32 @EnumSystemLocalesW(ptr, i64)

declare i32 @EnumSystemLanguageGroupsA(ptr, i64, i64)

declare i32 @EnumSystemLanguageGroupsW(ptr, i64, i64)

declare i32 @EnumLanguageGroupLocalesA(ptr, i64, i64, i64)

declare i32 @EnumLanguageGroupLocalesW(ptr, i64, i64, i64)

declare i32 @EnumUILanguagesA(ptr, i64, i64)

declare i32 @EnumUILanguagesW(ptr, i64, i64)

declare i32 @EnumSystemCodePagesA(ptr, i64)

declare i32 @EnumSystemCodePagesW(ptr, i64)

declare i32 @IdnToAscii(i64, ptr, i32, ptr, i32)

declare i32 @IdnToUnicode(i64, ptr, i32, ptr, i32)

declare i32 @IdnToNameprepUnicode(i64, ptr, i32, ptr, i32)

declare i32 @NormalizeString(i64, ptr, i32, ptr, i32)

declare i32 @IsNormalizedString(i64, ptr, i32)

declare i32 @VerifyScripts(i64, ptr, i32, ptr, i32)

declare i32 @GetStringScripts(i64, ptr, i32, ptr, i32)

declare i32 @GetLocaleInfoEx(ptr, i64, ptr, i32)

declare i32 @GetCalendarInfoEx(ptr, i64, ptr, i64, ptr, i32, ptr)

declare i32 @GetNumberFormatEx(ptr, i64, ptr, ptr, ptr, i32)

declare i32 @GetCurrencyFormatEx(ptr, i64, ptr, ptr, ptr, i32)

declare i32 @GetUserDefaultLocaleName(ptr, i32)

declare i32 @GetSystemDefaultLocaleName(ptr, i32)

declare i32 @IsNLSDefinedString(i64, i64, ptr, ptr, i32)

declare i32 @GetNLSVersionEx(i64, ptr, ptr)

declare i64 @IsValidNLSVersion(i64, ptr, ptr)

declare i32 @FindNLSStringEx(ptr, i64, ptr, i32, ptr, i32, ptr, ptr, ptr, i64)

declare i32 @LCMapStringEx(ptr, i64, ptr, i32, ptr, i32, ptr, ptr, i64)

declare i32 @IsValidLocaleName(ptr)

declare i32 @EnumCalendarInfoExEx(ptr, ptr, i64, ptr, i64, i64)

declare i32 @EnumDateFormatsExEx(ptr, ptr, i64, i64)

declare i32 @EnumTimeFormatsEx(ptr, ptr, i64, i64)

declare i32 @EnumSystemLocalesEx(ptr, i64, i64, ptr)

declare i32 @ResolveLocaleName(ptr, ptr, i32)

declare i32 @AllocConsole()

declare i64 @AllocConsoleWithOptions(ptr, ptr)

declare i32 @FreeConsole()

declare i32 @AttachConsole(i64)

declare i64 @GetConsoleCP()

declare i64 @GetConsoleOutputCP()

declare i32 @GetConsoleMode(ptr, ptr)

declare i32 @SetConsoleMode(ptr, i64)

declare i32 @GetNumberOfConsoleInputEvents(ptr, ptr)

declare i32 @ReadConsoleInputA(ptr, ptr, i64, ptr)

declare i32 @ReadConsoleInputW(ptr, ptr, i64, ptr)

declare i32 @PeekConsoleInputA(ptr, ptr, i64, ptr)

declare i32 @PeekConsoleInputW(ptr, ptr, i64, ptr)

declare i32 @ReadConsoleA(ptr, ptr, i64, ptr, ptr)

declare i32 @ReadConsoleW(ptr, ptr, i64, ptr, ptr)

declare i32 @WriteConsoleA(ptr, ptr, i64, ptr, ptr)

declare i32 @WriteConsoleW(ptr, ptr, i64, ptr, ptr)

declare i32 @SetConsoleCtrlHandler(ptr, i32)

declare i64 @CreatePseudoConsole(i64, ptr, ptr, i64, ptr)

declare i64 @ResizePseudoConsole(ptr, i64)

declare void @ClosePseudoConsole(ptr)

declare i64 @ReleasePseudoConsole(ptr)

declare i32 @FillConsoleOutputCharacterA(ptr, i64, i64, i64, ptr)

declare i32 @FillConsoleOutputCharacterW(ptr, i64, i64, i64, ptr)

declare i32 @FillConsoleOutputAttribute(ptr, i64, i64, i64, ptr)

declare i32 @GenerateConsoleCtrlEvent(i64, i64)

declare ptr @CreateConsoleScreenBuffer(i64, i64, ptr, i64, ptr)

declare i32 @SetConsoleActiveScreenBuffer(ptr)

declare i32 @FlushConsoleInputBuffer(ptr)

declare i32 @SetConsoleCP(i64)

declare i32 @SetConsoleOutputCP(i64)

declare i32 @GetConsoleCursorInfo(ptr, ptr)

declare i32 @SetConsoleCursorInfo(ptr, ptr)

declare i32 @GetConsoleScreenBufferInfo(ptr, ptr)

declare i32 @GetConsoleScreenBufferInfoEx(ptr, ptr)

declare i32 @SetConsoleScreenBufferInfoEx(ptr, ptr)

declare i32 @SetConsoleScreenBufferSize(ptr, i64)

declare i32 @SetConsoleCursorPosition(ptr, i64)

declare i64 @GetLargestConsoleWindowSize(ptr)

declare i32 @SetConsoleTextAttribute(ptr, i64)

declare i32 @SetConsoleWindowInfo(ptr, i32, ptr)

declare i32 @WriteConsoleOutputCharacterA(ptr, ptr, i64, i64, ptr)

declare i32 @WriteConsoleOutputCharacterW(ptr, ptr, i64, i64, ptr)

declare i32 @WriteConsoleOutputAttribute(ptr, ptr, i64, i64, ptr)

declare i32 @ReadConsoleOutputCharacterA(ptr, ptr, i64, i64, ptr)

declare i32 @ReadConsoleOutputCharacterW(ptr, ptr, i64, i64, ptr)

declare i32 @ReadConsoleOutputAttribute(ptr, ptr, i64, i64, ptr)

declare i32 @WriteConsoleInputA(ptr, ptr, i64, ptr)

declare i32 @WriteConsoleInputW(ptr, ptr, i64, ptr)

declare i32 @ScrollConsoleScreenBufferA(ptr, ptr, ptr, i64, ptr)

declare i32 @ScrollConsoleScreenBufferW(ptr, ptr, ptr, i64, ptr)

declare i32 @WriteConsoleOutputA(ptr, ptr, i64, i64, ptr)

declare i32 @WriteConsoleOutputW(ptr, ptr, i64, i64, ptr)

declare i32 @ReadConsoleOutputA(ptr, ptr, i64, i64, ptr)

declare i32 @ReadConsoleOutputW(ptr, ptr, i64, i64, ptr)

declare i64 @GetConsoleTitleA(ptr, i64)

declare i64 @GetConsoleTitleW(ptr, i64)

declare i64 @GetConsoleOriginalTitleA(ptr, i64)

declare i64 @GetConsoleOriginalTitleW(ptr, i64)

declare i32 @SetConsoleTitleA(ptr)

declare i32 @SetConsoleTitleW(ptr)

declare i32 @GetNumberOfConsoleMouseButtons(ptr)

declare i64 @GetConsoleFontSize(ptr, i64)

declare i32 @GetCurrentConsoleFont(ptr, i32, ptr)

declare i32 @GetCurrentConsoleFontEx(ptr, i32, ptr)

declare i32 @SetCurrentConsoleFontEx(ptr, i32, ptr)

declare i32 @GetConsoleSelectionInfo(ptr)

declare i32 @GetConsoleHistoryInfo(ptr)

declare i32 @SetConsoleHistoryInfo(ptr)

declare i32 @GetConsoleDisplayMode(ptr)

declare i32 @SetConsoleDisplayMode(ptr, i64, ptr)

declare ptr @GetConsoleWindow()

declare i32 @AddConsoleAliasA(ptr, ptr, ptr)

declare i32 @AddConsoleAliasW(ptr, ptr, ptr)

declare i64 @GetConsoleAliasA(ptr, ptr, i64, ptr)

declare i64 @GetConsoleAliasW(ptr, ptr, i64, ptr)

declare i64 @GetConsoleAliasesLengthA(ptr)

declare i64 @GetConsoleAliasesLengthW(ptr)

declare i64 @GetConsoleAliasExesLengthA()

declare i64 @GetConsoleAliasExesLengthW()

declare i64 @GetConsoleAliasesA(ptr, i64, ptr)

declare i64 @GetConsoleAliasesW(ptr, i64, ptr)

declare i64 @GetConsoleAliasExesA(ptr, i64)

declare i64 @GetConsoleAliasExesW(ptr, i64)

declare void @ExpungeConsoleCommandHistoryA(ptr)

declare void @ExpungeConsoleCommandHistoryW(ptr)

declare i32 @SetConsoleNumberOfCommandsA(i64, ptr)

declare i32 @SetConsoleNumberOfCommandsW(i64, ptr)

declare i64 @GetConsoleCommandHistoryLengthA(ptr)

declare i64 @GetConsoleCommandHistoryLengthW(ptr)

declare i64 @GetConsoleCommandHistoryA(ptr, i64, ptr)

declare i64 @GetConsoleCommandHistoryW(ptr, i64, ptr)

declare i64 @GetConsoleProcessList(ptr, i64)

declare i64 @VerFindFileA(i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @VerFindFileW(i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @VerInstallFileA(i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @VerInstallFileW(i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @GetFileVersionInfoSizeA(ptr, ptr)

declare i64 @GetFileVersionInfoSizeW(ptr, ptr)

declare i32 @GetFileVersionInfoA(ptr, i64, i64, ptr)

declare i32 @GetFileVersionInfoW(ptr, i64, i64, ptr)

declare i64 @GetFileVersionInfoSizeExA(i64, ptr, ptr)

declare i64 @GetFileVersionInfoSizeExW(i64, ptr, ptr)

declare i32 @GetFileVersionInfoExA(i64, ptr, i64, i64, ptr)

declare i32 @GetFileVersionInfoExW(i64, ptr, i64, i64, ptr)

declare i64 @VerLanguageNameA(i64, ptr, i64)

declare i64 @VerLanguageNameW(i64, ptr, i64)

declare i32 @VerQueryValueA(ptr, ptr, ptr, ptr)

declare i32 @VerQueryValueW(ptr, ptr, ptr, ptr)

declare i64 @RegCloseKey(ptr)

declare i64 @RegOverridePredefKey(ptr, ptr)

declare i64 @RegOpenUserClassesRoot(ptr, i64, i64, ptr)

declare i64 @RegOpenCurrentUser(i64, ptr)

declare i64 @RegDisablePredefinedCache()

declare i64 @RegDisablePredefinedCacheEx()

declare i64 @RegConnectRegistryA(ptr, ptr, ptr)

declare i64 @RegConnectRegistryW(ptr, ptr, ptr)

declare i64 @RegConnectRegistryExA(ptr, ptr, i64, ptr)

declare i64 @RegConnectRegistryExW(ptr, ptr, i64, ptr)

declare i64 @RegCreateKeyA(ptr, ptr, ptr)

declare i64 @RegCreateKeyW(ptr, ptr, ptr)

declare i64 @RegCreateKeyExA(ptr, ptr, i64, ptr, i64, i64, ptr, ptr, ptr)

declare i64 @RegCreateKeyExW(ptr, ptr, i64, ptr, i64, i64, ptr, ptr, ptr)

declare i64 @RegCreateKeyTransactedA(ptr, ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegCreateKeyTransactedW(ptr, ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegDeleteKeyA(ptr, ptr)

declare i64 @RegDeleteKeyW(ptr, ptr)

declare i64 @RegDeleteKeyExA(ptr, ptr, i64, i64)

declare i64 @RegDeleteKeyExW(ptr, ptr, i64, i64)

declare i64 @RegDeleteKeyTransactedA(ptr, ptr, i64, i64, ptr, ptr)

declare i64 @RegDeleteKeyTransactedW(ptr, ptr, i64, i64, ptr, ptr)

declare i64 @RegDisableReflectionKey(ptr)

declare i64 @RegEnableReflectionKey(ptr)

declare i64 @RegQueryReflectionKey(ptr, ptr)

declare i64 @RegDeleteValueA(ptr, ptr)

declare i64 @RegDeleteValueW(ptr, ptr)

declare i64 @RegEnumKeyA(ptr, i64, ptr, i64)

declare i64 @RegEnumKeyW(ptr, i64, ptr, i64)

declare i64 @RegEnumKeyExA(ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegEnumKeyExW(ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegEnumValueA(ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegEnumValueW(ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegFlushKey(ptr)

declare i64 @RegGetKeySecurity(ptr, i64, ptr, ptr)

declare i64 @RegLoadKeyA(ptr, ptr, ptr)

declare i64 @RegLoadKeyW(ptr, ptr, ptr)

declare i64 @RegNotifyChangeKeyValue(ptr, i32, i64, ptr, i32)

declare i64 @RegOpenKeyA(ptr, ptr, ptr)

declare i64 @RegOpenKeyW(ptr, ptr, ptr)

declare i64 @RegOpenKeyExA(ptr, ptr, i64, i64, ptr)

declare i64 @RegOpenKeyExW(ptr, ptr, i64, i64, ptr)

declare i64 @RegOpenKeyTransactedA(ptr, ptr, i64, i64, ptr, ptr, ptr)

declare i64 @RegOpenKeyTransactedW(ptr, ptr, i64, i64, ptr, ptr, ptr)

declare i64 @RegQueryInfoKeyA(ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegQueryInfoKeyW(ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegQueryValueA(ptr, ptr, ptr, ptr)

declare i64 @RegQueryValueW(ptr, ptr, ptr, ptr)

declare i64 @RegQueryMultipleValuesA(ptr, ptr, i64, ptr, ptr)

declare i64 @RegQueryMultipleValuesW(ptr, ptr, i64, ptr, ptr)

declare i64 @RegQueryValueExA(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegQueryValueExW(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RegReplaceKeyA(ptr, ptr, ptr, ptr)

declare i64 @RegReplaceKeyW(ptr, ptr, ptr, ptr)

declare i64 @RegRestoreKeyA(ptr, ptr, i64)

declare i64 @RegRestoreKeyW(ptr, ptr, i64)

declare i64 @RegRenameKey(ptr, ptr, ptr)

declare i64 @RegSaveKeyA(ptr, ptr, ptr)

declare i64 @RegSaveKeyW(ptr, ptr, ptr)

declare i64 @RegSetKeySecurity(ptr, i64, ptr)

declare i64 @RegSetValueA(ptr, ptr, i64, ptr, i64)

declare i64 @RegSetValueW(ptr, ptr, i64, ptr, i64)

declare i64 @RegSetValueExA(ptr, ptr, i64, i64, ptr, i64)

declare i64 @RegSetValueExW(ptr, ptr, i64, i64, ptr, i64)

declare i64 @RegUnLoadKeyA(ptr, ptr)

declare i64 @RegUnLoadKeyW(ptr, ptr)

declare i64 @RegDeleteKeyValueA(ptr, ptr, ptr)

declare i64 @RegDeleteKeyValueW(ptr, ptr, ptr)

declare i64 @RegSetKeyValueA(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @RegSetKeyValueW(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @RegDeleteTreeA(ptr, ptr)

declare i64 @RegDeleteTreeW(ptr, ptr)

declare i64 @RegCopyTreeA(ptr, ptr, ptr)

declare i64 @RegGetValueA(ptr, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @RegGetValueW(ptr, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @RegCopyTreeW(ptr, ptr, ptr)

declare i64 @RegLoadMUIStringA(ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i64 @RegLoadMUIStringW(ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i64 @RegLoadAppKeyA(ptr, ptr, i64, i64, i64)

declare i64 @RegLoadAppKeyW(ptr, ptr, i64, i64, i64)

declare i32 @InitiateSystemShutdownA(ptr, ptr, i64, i32, i32)

declare i32 @InitiateSystemShutdownW(ptr, ptr, i64, i32, i32)

declare i32 @AbortSystemShutdownA(ptr)

declare i32 @AbortSystemShutdownW(ptr)

declare i32 @InitiateSystemShutdownExA(ptr, ptr, i64, i32, i32, i64)

declare i32 @InitiateSystemShutdownExW(ptr, ptr, i64, i32, i32, i64)

declare i64 @InitiateShutdownA(ptr, ptr, i64, i64, i64)

declare i64 @InitiateShutdownW(ptr, ptr, i64, i64, i64)

declare i64 @CheckForHiberboot(ptr, i64)

declare i64 @RegSaveKeyExA(ptr, ptr, ptr, i64)

declare i64 @RegSaveKeyExW(ptr, ptr, ptr, i64)

declare i64 @WNetAddConnectionA(ptr, ptr, ptr)

declare i64 @WNetAddConnectionW(ptr, ptr, ptr)

declare i64 @WNetAddConnection2A(ptr, ptr, ptr, i64)

declare i64 @WNetAddConnection2W(ptr, ptr, ptr, i64)

declare i64 @WNetAddConnection3A(ptr, ptr, ptr, ptr, i64)

declare i64 @WNetAddConnection3W(ptr, ptr, ptr, ptr, i64)

declare i64 @WNetAddConnection4A(ptr, ptr, ptr, i64, i64, ptr, i64)

declare i64 @WNetAddConnection4W(ptr, ptr, ptr, i64, i64, ptr, i64)

declare i64 @WNetCancelConnectionA(ptr, i32)

declare i64 @WNetCancelConnectionW(ptr, i32)

declare i64 @WNetCancelConnection2A(ptr, i64, i32)

declare i64 @WNetCancelConnection2W(ptr, i64, i32)

declare i64 @WNetGetConnectionA(ptr, ptr, ptr)

declare i64 @WNetGetConnectionW(ptr, ptr, ptr)

declare i64 @WNetRestoreSingleConnectionW(ptr, ptr, i32)

declare i64 @WNetUseConnectionA(ptr, ptr, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @WNetUseConnectionW(ptr, ptr, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @WNetUseConnection4A(ptr, ptr, ptr, i64, i64, ptr, i64, ptr, ptr, ptr)

declare i64 @WNetUseConnection4W(ptr, ptr, ptr, i64, i64, ptr, i64, ptr, ptr, ptr)

declare i64 @WNetConnectionDialog(ptr, i64)

declare i64 @WNetDisconnectDialog(ptr, i64)

declare i64 @WNetConnectionDialog1A(ptr)

declare i64 @WNetConnectionDialog1W(ptr)

declare i64 @WNetDisconnectDialog1A(ptr)

declare i64 @WNetDisconnectDialog1W(ptr)

declare i64 @WNetOpenEnumA(i64, i64, i64, ptr, ptr)

declare i64 @WNetOpenEnumW(i64, i64, i64, ptr, ptr)

declare i64 @WNetEnumResourceA(ptr, ptr, ptr, ptr)

declare i64 @WNetEnumResourceW(ptr, ptr, ptr, ptr)

declare i64 @WNetCloseEnum(ptr)

declare i64 @WNetGetResourceParentA(ptr, ptr, ptr)

declare i64 @WNetGetResourceParentW(ptr, ptr, ptr)

declare i64 @WNetGetResourceInformationA(ptr, ptr, ptr, ptr)

declare i64 @WNetGetResourceInformationW(ptr, ptr, ptr, ptr)

declare i64 @WNetGetUniversalNameA(ptr, i64, ptr, ptr)

declare i64 @WNetGetUniversalNameW(ptr, i64, ptr, ptr)

declare i64 @WNetGetUserA(ptr, ptr, ptr)

declare i64 @WNetGetUserW(ptr, ptr, ptr)

declare i64 @WNetGetProviderNameA(i64, ptr, ptr)

declare i64 @WNetGetProviderNameW(i64, ptr, ptr)

declare i64 @WNetGetNetworkInformationA(ptr, ptr)

declare i64 @WNetGetNetworkInformationW(ptr, ptr)

declare i64 @WNetGetLastErrorA(ptr, ptr, i64, ptr, i64)

declare i64 @WNetGetLastErrorW(ptr, ptr, i64, ptr, i64)

declare i64 @MultinetGetConnectionPerformanceA(ptr, ptr)

declare i64 @MultinetGetConnectionPerformanceW(ptr, ptr)

declare i32 @DdeSetQualityOfService(ptr, ptr, ptr)

declare i32 @ImpersonateDdeClientWindow(ptr, ptr)

declare i64 @PackDDElParam(i64, i64, i64)

declare i32 @UnpackDDElParam(i64, i64, ptr, ptr)

declare i32 @FreeDDElParam(i64, i64)

declare i64 @ReuseDDElParam(i64, i64, i64, i64, i64)

declare i64 @DdeInitializeA(ptr, ptr, i64, i64)

declare i64 @DdeInitializeW(ptr, ptr, i64, i64)

declare i32 @DdeUninitialize(i64)

declare ptr @DdeConnectList(i64, ptr, ptr, ptr, ptr)

declare ptr @DdeQueryNextServer(ptr, ptr)

declare i32 @DdeDisconnectList(ptr)

declare ptr @DdeConnect(i64, ptr, ptr, ptr)

declare i32 @DdeDisconnect(ptr)

declare ptr @DdeReconnect(ptr)

declare i64 @DdeQueryConvInfo(ptr, i64, ptr)

declare i32 @DdeSetUserHandle(ptr, i64, i64)

declare i32 @DdeAbandonTransaction(i64, ptr, i64)

declare i32 @DdePostAdvise(i64, ptr, ptr)

declare i32 @DdeEnableCallback(i64, ptr, i64)

declare i32 @DdeImpersonateClient(ptr)

declare ptr @DdeNameService(i64, ptr, ptr, i64)

declare ptr @DdeClientTransaction(ptr, i64, ptr, ptr, i64, i64, i64, ptr)

declare ptr @DdeCreateDataHandle(i64, ptr, i64, i64, ptr, i64, i64)

declare ptr @DdeAddData(ptr, ptr, i64, i64)

declare i64 @DdeGetData(ptr, ptr, i64, i64)

declare ptr @DdeAccessData(ptr, ptr)

declare i32 @DdeUnaccessData(ptr)

declare i32 @DdeFreeDataHandle(ptr)

declare i64 @DdeGetLastError(i64)

declare ptr @DdeCreateStringHandleA(i64, ptr, i32)

declare ptr @DdeCreateStringHandleW(i64, ptr, i32)

declare i64 @DdeQueryStringA(i64, ptr, ptr, i64, i32)

declare i64 @DdeQueryStringW(i64, ptr, ptr, i64, i32)

declare i32 @DdeFreeStringHandle(i64, ptr)

declare i32 @DdeKeepStringHandle(i64, ptr)

declare i32 @DdeCmpStringHandles(ptr, ptr)

declare i32 @LZStart()

declare void @LZDone()

declare i64 @CopyLZFile(i32, i32)

declare i64 @LZCopy(i32, i32)

declare i32 @LZInit(i32)

declare i32 @GetExpandedNameA(ptr, ptr)

declare i32 @GetExpandedNameW(ptr, ptr)

declare i32 @LZOpenFileA(ptr, ptr, i64)

declare i32 @LZOpenFileW(ptr, ptr, i64)

declare i64 @LZSeek(i32, i64, i32)

declare i32 @LZRead(i32, ptr, i32)

declare void @LZClose(i32)

declare i64 @mciSendCommandA(i64, i64, i64, i64)

declare i64 @mciSendCommandW(i64, i64, i64, i64)

declare i64 @mciSendStringA(ptr, ptr, i64, ptr)

declare i64 @mciSendStringW(ptr, ptr, i64, ptr)

declare i64 @mciGetDeviceIDA(ptr)

declare i64 @mciGetDeviceIDW(ptr)

declare i64 @mciGetDeviceIDFromElementIDA(i64, ptr)

declare i64 @mciGetDeviceIDFromElementIDW(i64, ptr)

declare i32 @mciGetErrorStringA(i64, ptr, i64)

declare i32 @mciGetErrorStringW(i64, ptr, i64)

declare i32 @mciSetYieldProc(i64, ptr, i64)

declare ptr @mciGetCreatorTask(i64)

declare ptr @mciGetYieldProc(i64, ptr)

declare i64 @mciGetDriverData(i64)

declare i64 @mciLoadCommandResource(ptr, ptr, i64)

declare i32 @mciSetDriverData(i64, i64)

declare i64 @mciDriverYield(i64)

declare i32 @mciDriverNotify(ptr, i64, i64)

declare i32 @mciFreeCommandResource(i64)

declare i64 @CloseDriver(ptr, i64, i64)

declare ptr @OpenDriver(ptr, ptr, i64)

declare i64 @SendDriverMessage(ptr, i64, i64, i64)

declare ptr @DrvGetModuleHandle(ptr)

declare ptr @GetDriverModuleHandle(ptr)

declare i64 @DefDriverProc(i64, ptr, i64, i64, i64)

declare i32 @DriverCallback(i64, i64, ptr, i64, i64, i64, i64)

declare i64 @sndOpenSound(ptr, ptr, i32, ptr)

declare i64 @mmDrvInstall(ptr, ptr, ptr, i64)

declare i64 @mmioStringToFOURCCA(ptr, i64)

declare i64 @mmioStringToFOURCCW(ptr, i64)

declare ptr @mmioInstallIOProcA(i64, ptr, i64)

declare ptr @mmioInstallIOProcW(i64, ptr, i64)

declare ptr @mmioOpenA(ptr, ptr, i64)

declare ptr @mmioOpenW(ptr, ptr, i64)

declare i64 @mmioRenameA(ptr, ptr, ptr, i64)

declare i64 @mmioRenameW(ptr, ptr, ptr, i64)

declare i64 @mmioClose(ptr, i64)

declare i64 @mmioRead(ptr, ptr, i64)

declare i64 @mmioWrite(ptr, ptr, i64)

declare i64 @mmioSeek(ptr, i64, i32)

declare i64 @mmioGetInfo(ptr, ptr, i64)

declare i64 @mmioSetInfo(ptr, ptr, i64)

declare i64 @mmioSetBuffer(ptr, ptr, i64, i64)

declare i64 @mmioFlush(ptr, i64)

declare i64 @mmioAdvance(ptr, ptr, i64)

declare i64 @mmioSendMessage(ptr, i64, i64, i64)

declare i64 @mmioDescend(ptr, ptr, ptr, i64)

declare i64 @mmioAscend(ptr, ptr, i64)

declare i64 @mmioCreateChunk(ptr, ptr, i64)

declare i64 @timeSetEvent(i64, i64, ptr, i64, i64)

declare i64 @timeKillEvent(i64)

declare i32 @sndPlaySoundA(ptr, i64)

declare i32 @sndPlaySoundW(ptr, i64)

declare i32 @PlaySoundA(ptr, ptr, i64)

declare i32 @PlaySoundW(ptr, ptr, i64)

declare i64 @waveOutGetNumDevs()

declare i64 @waveOutGetDevCapsA(i64, ptr, i64)

declare i64 @waveOutGetDevCapsW(i64, ptr, i64)

declare i64 @waveOutGetVolume(ptr, ptr)

declare i64 @waveOutSetVolume(ptr, i64)

declare i64 @waveOutGetErrorTextA(i64, ptr, i64)

declare i64 @waveOutGetErrorTextW(i64, ptr, i64)

declare i64 @waveOutOpen(ptr, i64, ptr, i64, i64, i64)

declare i64 @waveOutClose(ptr)

declare i64 @waveOutPrepareHeader(ptr, ptr, i64)

declare i64 @waveOutUnprepareHeader(ptr, ptr, i64)

declare i64 @waveOutWrite(ptr, ptr, i64)

declare i64 @waveOutPause(ptr)

declare i64 @waveOutRestart(ptr)

declare i64 @waveOutReset(ptr)

declare i64 @waveOutBreakLoop(ptr)

declare i64 @waveOutGetPosition(ptr, ptr, i64)

declare i64 @waveOutGetPitch(ptr, ptr)

declare i64 @waveOutSetPitch(ptr, i64)

declare i64 @waveOutGetPlaybackRate(ptr, ptr)

declare i64 @waveOutSetPlaybackRate(ptr, i64)

declare i64 @waveOutGetID(ptr, ptr)

declare i64 @waveOutMessage(ptr, i64, i64, i64)

declare i64 @waveInGetNumDevs()

declare i64 @waveInGetDevCapsA(i64, ptr, i64)

declare i64 @waveInGetDevCapsW(i64, ptr, i64)

declare i64 @waveInGetErrorTextA(i64, ptr, i64)

declare i64 @waveInGetErrorTextW(i64, ptr, i64)

declare i64 @waveInOpen(ptr, i64, ptr, i64, i64, i64)

declare i64 @waveInClose(ptr)

declare i64 @waveInPrepareHeader(ptr, ptr, i64)

declare i64 @waveInUnprepareHeader(ptr, ptr, i64)

declare i64 @waveInAddBuffer(ptr, ptr, i64)

declare i64 @waveInStart(ptr)

declare i64 @waveInStop(ptr)

declare i64 @waveInReset(ptr)

declare i64 @waveInGetPosition(ptr, ptr, i64)

declare i64 @waveInGetID(ptr, ptr)

declare i64 @waveInMessage(ptr, i64, i64, i64)

declare i64 @midiOutGetNumDevs()

declare i64 @midiStreamOpen(ptr, ptr, i64, i64, i64, i64)

declare i64 @midiStreamClose(ptr)

declare i64 @midiStreamProperty(ptr, ptr, i64)

declare i64 @midiStreamPosition(ptr, ptr, i64)

declare i64 @midiStreamOut(ptr, ptr, i64)

declare i64 @midiStreamPause(ptr)

declare i64 @midiStreamRestart(ptr)

declare i64 @midiStreamStop(ptr)

declare i64 @midiConnect(ptr, ptr, ptr)

declare i64 @midiDisconnect(ptr, ptr, ptr)

declare i64 @midiOutGetDevCapsA(i64, ptr, i64)

declare i64 @midiOutGetDevCapsW(i64, ptr, i64)

declare i64 @midiOutGetVolume(ptr, ptr)

declare i64 @midiOutSetVolume(ptr, i64)

declare i64 @midiOutGetErrorTextA(i64, ptr, i64)

declare i64 @midiOutGetErrorTextW(i64, ptr, i64)

declare i64 @midiOutOpen(ptr, i64, i64, i64, i64)

declare i64 @midiOutClose(ptr)

declare i64 @midiOutPrepareHeader(ptr, ptr, i64)

declare i64 @midiOutUnprepareHeader(ptr, ptr, i64)

declare i64 @midiOutShortMsg(ptr, i64)

declare i64 @midiOutLongMsg(ptr, ptr, i64)

declare i64 @midiOutReset(ptr)

declare i64 @midiOutCachePatches(ptr, i64, ptr, i64)

declare i64 @midiOutCacheDrumPatches(ptr, i64, ptr, i64)

declare i64 @midiOutGetID(ptr, ptr)

declare i64 @midiOutMessage(ptr, i64, i64, i64)

declare i64 @midiInGetNumDevs()

declare i64 @midiInGetDevCapsA(i64, ptr, i64)

declare i64 @midiInGetDevCapsW(i64, ptr, i64)

declare i64 @midiInGetErrorTextA(i64, ptr, i64)

declare i64 @midiInGetErrorTextW(i64, ptr, i64)

declare i64 @midiInOpen(ptr, i64, i64, i64, i64)

declare i64 @midiInClose(ptr)

declare i64 @midiInPrepareHeader(ptr, ptr, i64)

declare i64 @midiInUnprepareHeader(ptr, ptr, i64)

declare i64 @midiInAddBuffer(ptr, ptr, i64)

declare i64 @midiInStart(ptr)

declare i64 @midiInStop(ptr)

declare i64 @midiInReset(ptr)

declare i64 @midiInGetID(ptr, ptr)

declare i64 @midiInMessage(ptr, i64, i64, i64)

declare i64 @auxGetNumDevs()

declare i64 @auxGetDevCapsA(i64, ptr, i64)

declare i64 @auxGetDevCapsW(i64, ptr, i64)

declare i64 @auxSetVolume(i64, i64)

declare i64 @auxGetVolume(i64, ptr)

declare i64 @auxOutMessage(i64, i64, i64, i64)

declare i64 @mixerGetNumDevs()

declare i64 @mixerGetDevCapsA(i64, ptr, i64)

declare i64 @mixerGetDevCapsW(i64, ptr, i64)

declare i64 @mixerOpen(ptr, i64, i64, i64, i64)

declare i64 @mixerClose(ptr)

declare i64 @mixerMessage(ptr, i64, i64, i64)

declare i64 @mixerGetLineInfoA(ptr, ptr, i64)

declare i64 @mixerGetLineInfoW(ptr, ptr, i64)

declare i64 @mixerGetID(ptr, ptr, i64)

declare i64 @mixerGetLineControlsA(ptr, ptr, i64)

declare i64 @mixerGetLineControlsW(ptr, ptr, i64)

declare i64 @mixerGetControlDetailsA(ptr, ptr, i64)

declare i64 @mixerGetControlDetailsW(ptr, ptr, i64)

declare i64 @mixerSetControlDetails(ptr, ptr, i64)

declare i64 @timeGetSystemTime(ptr, i64)

declare i64 @timeGetTime()

declare i64 @timeGetDevCaps(ptr, i64)

declare i64 @timeBeginPeriod(i64)

declare i64 @timeEndPeriod(i64)

declare i64 @joyGetPosEx(i64, ptr)

declare i64 @joyGetNumDevs()

declare i64 @joyGetDevCapsA(i64, ptr, i64)

declare i64 @joyGetDevCapsW(i64, ptr, i64)

declare i64 @joyGetPos(i64, ptr)

declare i64 @joyGetThreshold(i64, ptr)

declare i64 @joyReleaseCapture(i64)

declare i64 @joySetCapture(ptr, i64, i64, i32)

declare i64 @joySetThreshold(i64, i64)

declare i64 @joyConfigChanged(i64)

declare i64 @Netbios(ptr)

declare i64 @RpcBindingCopy(ptr, ptr)

declare i64 @RpcBindingFree(ptr)

declare i64 @RpcBindingSetOption(ptr, i64, i64)

declare i64 @RpcBindingInqOption(ptr, i64, ptr)

declare i64 @RpcBindingFromStringBindingA(ptr, ptr)

declare i64 @RpcBindingFromStringBindingW(ptr, ptr)

declare i64 @RpcSsGetContextBinding(ptr, ptr)

declare i64 @RpcBindingInqMaxCalls(ptr, ptr)

declare i64 @RpcBindingInqObject(ptr, ptr)

declare i64 @RpcBindingReset(ptr)

declare i64 @RpcBindingSetObject(ptr, ptr)

declare i64 @RpcMgmtInqDefaultProtectLevel(i64, ptr)

declare i64 @RpcBindingToStringBindingA(ptr, ptr)

declare i64 @RpcBindingToStringBindingW(ptr, ptr)

declare i64 @RpcBindingVectorFree(ptr)

declare i64 @RpcStringBindingComposeA(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcStringBindingComposeW(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcStringBindingParseA(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcStringBindingParseW(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcStringFreeA(ptr)

declare i64 @RpcStringFreeW(ptr)

declare i64 @RpcIfInqId(ptr, ptr)

declare i64 @RpcNetworkIsProtseqValidA(ptr)

declare i64 @RpcNetworkIsProtseqValidW(ptr)

declare i64 @RpcMgmtInqComTimeout(ptr, ptr)

declare i64 @RpcMgmtSetComTimeout(ptr, i64)

declare i64 @RpcMgmtSetCancelTimeout(i64)

declare i64 @RpcNetworkInqProtseqsA(ptr)

declare i64 @RpcNetworkInqProtseqsW(ptr)

declare i64 @RpcObjectInqType(ptr, ptr)

declare i64 @RpcObjectSetInqFn(ptr)

declare i64 @RpcObjectSetType(ptr, ptr)

declare i64 @RpcProtseqVectorFreeA(ptr)

declare i64 @RpcProtseqVectorFreeW(ptr)

declare i64 @RpcServerInqBindings(ptr)

declare i64 @RpcServerInqBindingsEx(ptr, ptr)

declare i64 @RpcServerInqIf(ptr, ptr, ptr)

declare i64 @RpcServerListen(i64, i64, i64)

declare i64 @RpcServerRegisterIf(ptr, ptr, ptr)

declare i64 @RpcServerRegisterIfEx(ptr, ptr, ptr, i64, i64, ptr)

declare i64 @RpcServerRegisterIf2(ptr, ptr, ptr, i64, i64, i64, ptr)

declare i64 @RpcServerRegisterIf3(ptr, ptr, ptr, i64, i64, i64, ptr, ptr)

declare i64 @RpcServerUnregisterIf(ptr, ptr, i64)

declare i64 @RpcServerUnregisterIfEx(ptr, ptr, i32)

declare i64 @RpcServerUseAllProtseqs(i64, ptr)

declare i64 @RpcServerUseAllProtseqsEx(i64, ptr, ptr)

declare i64 @RpcServerUseAllProtseqsIf(i64, ptr, ptr)

declare i64 @RpcServerUseAllProtseqsIfEx(i64, ptr, ptr, ptr)

declare i64 @RpcServerUseProtseqA(ptr, i64, ptr)

declare i64 @RpcServerUseProtseqExA(ptr, i64, ptr, ptr)

declare i64 @RpcServerUseProtseqW(ptr, i64, ptr)

declare i64 @RpcServerUseProtseqExW(ptr, i64, ptr, ptr)

declare i64 @RpcServerUseProtseqEpA(ptr, i64, ptr, ptr)

declare i64 @RpcServerUseProtseqEpExA(ptr, i64, ptr, ptr, ptr)

declare i64 @RpcServerUseProtseqEpW(ptr, i64, ptr, ptr)

declare i64 @RpcServerUseProtseqEpExW(ptr, i64, ptr, ptr, ptr)

declare i64 @RpcServerUseProtseqIfA(ptr, i64, ptr, ptr)

declare i64 @RpcServerUseProtseqIfExA(ptr, i64, ptr, ptr, ptr)

declare i64 @RpcServerUseProtseqIfW(ptr, i64, ptr, ptr)

declare i64 @RpcServerUseProtseqIfExW(ptr, i64, ptr, ptr, ptr)

declare void @RpcServerYield()

declare i64 @RpcMgmtStatsVectorFree(ptr)

declare i64 @RpcMgmtInqStats(ptr, ptr)

declare i64 @RpcMgmtIsServerListening(ptr)

declare i64 @RpcMgmtStopServerListening(ptr)

declare i64 @RpcMgmtWaitServerListen()

declare i64 @RpcMgmtSetServerStackSize(i64)

declare void @RpcSsDontSerializeContext()

declare i64 @RpcMgmtEnableIdleCleanup()

declare i64 @RpcMgmtInqIfIds(ptr, ptr)

declare i64 @RpcIfIdVectorFree(ptr)

declare i64 @RpcMgmtInqServerPrincNameA(ptr, i64, ptr)

declare i64 @RpcMgmtInqServerPrincNameW(ptr, i64, ptr)

declare i64 @RpcServerInqDefaultPrincNameA(i64, ptr)

declare i64 @RpcServerInqDefaultPrincNameW(i64, ptr)

declare i64 @RpcEpResolveBinding(ptr, ptr)

declare i64 @RpcNsBindingInqEntryNameA(ptr, i64, ptr)

declare i64 @RpcNsBindingInqEntryNameW(ptr, i64, ptr)

declare i64 @RpcBindingCreateA(ptr, ptr, ptr, ptr)

declare i64 @RpcBindingCreateW(ptr, ptr, ptr, ptr)

declare i64 @RpcBindingGetTrainingContextHandle(ptr, ptr)

declare i64 @RpcServerInqBindingHandle(ptr)

declare i64 @RpcImpersonateClient(ptr)

declare i64 @RpcImpersonateClient2(ptr)

declare i64 @RpcRevertToSelfEx(ptr)

declare i64 @RpcRevertToSelf()

declare i64 @RpcImpersonateClientContainer(ptr)

declare i64 @RpcRevertContainerImpersonation()

declare i64 @RpcBindingInqAuthClientA(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcBindingInqAuthClientW(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcBindingInqAuthClientExA(ptr, ptr, ptr, ptr, ptr, ptr, i64)

declare i64 @RpcBindingInqAuthClientExW(ptr, ptr, ptr, ptr, ptr, ptr, i64)

declare i64 @RpcBindingInqAuthInfoA(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcBindingInqAuthInfoW(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcBindingSetAuthInfoA(ptr, ptr, i64, i64, ptr, i64)

declare i64 @RpcBindingSetAuthInfoExA(ptr, ptr, i64, i64, ptr, i64, ptr)

declare i64 @RpcBindingSetAuthInfoW(ptr, ptr, i64, i64, ptr, i64)

declare i64 @RpcBindingSetAuthInfoExW(ptr, ptr, i64, i64, ptr, i64, ptr)

declare i64 @RpcBindingInqAuthInfoExA(ptr, ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @RpcBindingInqAuthInfoExW(ptr, ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @RpcServerCompleteSecurityCallback(ptr, i64)

declare i64 @RpcServerRegisterAuthInfoA(ptr, i64, ptr, ptr)

declare i64 @RpcServerRegisterAuthInfoW(ptr, i64, ptr, ptr)

declare i64 @RpcBindingServerFromClient(ptr, ptr)

declare void @RpcRaiseException(i64)

declare i64 @RpcTestCancel()

declare i64 @RpcServerTestCancel(ptr)

declare i64 @RpcCancelThread(ptr)

declare i64 @RpcCancelThreadEx(ptr, i64)

declare i64 @UuidCreate(ptr)

declare i64 @UuidCreateSequential(ptr)

declare i64 @UuidToStringA(ptr, ptr)

declare i64 @UuidFromStringA(ptr, ptr)

declare i64 @UuidToStringW(ptr, ptr)

declare i64 @UuidFromStringW(ptr, ptr)

declare i32 @UuidCompare(ptr, ptr, ptr)

declare i64 @UuidCreateNil(ptr)

declare i32 @UuidEqual(ptr, ptr, ptr)

declare i64 @UuidHash(ptr, ptr)

declare i32 @UuidIsNil(ptr, ptr)

declare i64 @RpcEpRegisterNoReplaceA(ptr, ptr, ptr, ptr)

declare i64 @RpcEpRegisterNoReplaceW(ptr, ptr, ptr, ptr)

declare i64 @RpcEpRegisterA(ptr, ptr, ptr, ptr)

declare i64 @RpcEpRegisterW(ptr, ptr, ptr, ptr)

declare i64 @RpcEpUnregister(ptr, ptr, ptr)

declare i64 @DceErrorInqTextA(i64, ptr)

declare i64 @DceErrorInqTextW(i64, ptr)

declare i64 @RpcMgmtEpEltInqBegin(ptr, i64, ptr, i64, ptr, ptr)

declare i64 @RpcMgmtEpEltInqDone(ptr)

declare i64 @RpcMgmtEpEltInqNextA(ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcMgmtEpEltInqNextW(ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcMgmtEpUnregister(ptr, ptr, ptr, ptr)

declare i64 @RpcMgmtSetAuthorizationFn(ptr)

declare i32 @RpcExceptionFilter(i64)

declare i64 @RpcServerInterfaceGroupCreateW(ptr, i64, ptr, i64, i64, i64, ptr, ptr)

declare i64 @RpcServerInterfaceGroupCreateA(ptr, i64, ptr, i64, i64, i64, ptr, ptr)

declare i64 @RpcServerInterfaceGroupClose(ptr)

declare i64 @RpcServerInterfaceGroupActivate(ptr)

declare i64 @RpcServerInterfaceGroupDeactivate(ptr, i64)

declare i64 @RpcServerInterfaceGroupInqBindings(ptr, ptr)

declare i64 @I_RpcNegotiateTransferSyntax(ptr)

declare i64 @I_RpcGetBuffer(ptr)

declare i64 @I_RpcGetBufferWithObject(ptr, ptr)

declare i64 @I_RpcSendReceive(ptr)

declare i64 @I_RpcFreeBuffer(ptr)

declare i64 @I_RpcSend(ptr)

declare i64 @I_RpcReceive(ptr, i64)

declare i64 @I_RpcFreePipeBuffer(ptr)

declare i64 @I_RpcReallocPipeBuffer(ptr, i64)

declare void @I_RpcRequestMutex(ptr)

declare void @I_RpcClearMutex(ptr)

declare void @I_RpcDeleteMutex(ptr)

declare ptr @I_RpcAllocate(i64)

declare void @I_RpcFree(ptr)

declare i64 @I_RpcFreeSystemHandleCollection(ptr, i64)

declare i64 @I_RpcSetSystemHandle(ptr, i64, i64, ptr, ptr)

declare i64 @I_RpcGetSystemHandle(ptr, i64, i64, i64, ptr)

declare void @I_RpcFreeSystemHandle(i64, ptr)

declare void @I_RpcPauseExecution(i64)

declare i64 @I_RpcGetExtendedError()

declare i64 @I_RpcSystemHandleTypeSpecificWork(ptr, i64, i64, i64)

declare i64 @I_RpcMonitorAssociation(ptr, ptr, ptr)

declare i64 @I_RpcStopMonitorAssociation(ptr)

declare ptr @I_RpcGetCurrentCallHandle()

declare i64 @I_RpcGetAssociationContext(ptr, ptr)

declare ptr @I_RpcGetServerContextList(ptr)

declare void @I_RpcSetServerContextList(ptr, ptr)

declare i64 @I_RpcNsInterfaceExported(i64, ptr, ptr)

declare i64 @I_RpcNsInterfaceUnexported(i64, ptr, ptr)

declare i64 @I_RpcBindingToStaticStringBindingW(ptr, ptr)

declare i64 @I_RpcBindingInqSecurityContext(ptr, ptr)

declare i64 @I_RpcBindingInqSecurityContextKeyInfo(ptr, ptr)

declare i64 @I_RpcBindingInqWireIdForSnego(ptr, ptr)

declare i64 @I_RpcBindingInqMarshalledTargetInfo(ptr, ptr, ptr)

declare i64 @I_RpcBindingInqLocalClientPID(ptr, ptr)

declare i64 @I_RpcBindingHandleToAsyncHandle(ptr, ptr)

declare i64 @I_RpcNsBindingSetEntryNameW(ptr, i64, ptr)

declare i64 @I_RpcNsBindingSetEntryNameA(ptr, i64, ptr)

declare i64 @I_RpcServerUseProtseqEp2A(ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @I_RpcServerUseProtseqEp2W(ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @I_RpcServerUseProtseq2W(ptr, ptr, i64, ptr, ptr)

declare i64 @I_RpcServerUseProtseq2A(ptr, ptr, i64, ptr, ptr)

declare i64 @I_RpcServerStartService(ptr, ptr, ptr)

declare i64 @I_RpcBindingInqDynamicEndpointW(ptr, ptr)

declare i64 @I_RpcBindingInqDynamicEndpointA(ptr, ptr)

declare i64 @I_RpcServerCheckClientRestriction(ptr)

declare i64 @I_RpcBindingInqTransportType(ptr, ptr)

declare i64 @I_RpcIfInqTransferSyntaxes(ptr, ptr, i64, ptr)

declare i64 @I_UuidCreate(ptr)

declare void @I_RpcUninitializeNdrOle()

declare i64 @I_RpcBindingCopy(ptr, ptr)

declare i64 @I_RpcBindingIsClientLocal(ptr, ptr)

declare i64 @I_RpcBindingInqConnId(ptr, ptr, ptr)

declare i64 @I_RpcBindingCreateNP(ptr, ptr, ptr, ptr)

declare void @I_RpcSsDontSerializeContext()

declare i64 @I_RpcLaunchDatagramReceiveThread(ptr)

declare i64 @I_RpcServerRegisterForwardFunction(ptr)

declare ptr @I_RpcServerInqAddressChangeFn()

declare i64 @I_RpcServerSetAddressChangeFn(ptr)

declare i64 @I_RpcServerInqLocalConnAddress(ptr, ptr, ptr, ptr)

declare i64 @I_RpcServerInqRemoteConnAddress(ptr, ptr, ptr, ptr)

declare void @I_RpcSessionStrictContextHandle()

declare i64 @I_RpcTurnOnEEInfoPropagation()

declare i64 @I_RpcConnectionInqSockBuffSize(ptr, ptr)

declare i64 @I_RpcConnectionSetSockBuffSize(i64, i64)

declare i64 @I_RpcServerStartListening(ptr)

declare i64 @I_RpcServerStopListening()

declare i64 @I_RpcBindingSetAsync(ptr, ptr, i64)

declare i64 @I_RpcSetThreadParams(i32, ptr, ptr)

declare i64 @I_RpcWindowProc(ptr, i64, i64, i64)

declare i64 @I_RpcServerUnregisterEndpointA(ptr, ptr)

declare i64 @I_RpcServerUnregisterEndpointW(ptr, ptr)

declare i64 @I_RpcServerInqTransportType(ptr)

declare i64 @I_RpcMapWin32Status(i64)

declare i64 @I_RpcProxyNewConnection(i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @I_RpcReplyToClientWithStatus(ptr, i64)

declare void @I_RpcRecordCalloutFailure(i64, ptr, ptr)

declare i64 @I_RpcMgmtEnableDedicatedThreadPool()

declare i64 @I_RpcGetDefaultSD(ptr)

declare i64 @I_RpcOpenClientProcess(ptr, i64, ptr)

declare i64 @I_RpcBindingIsServerLocal(ptr, ptr)

declare i64 @I_RpcBindingSetPrivateOption(ptr, i64, i64)

declare i64 @I_RpcServerSubscribeForDisconnectNotification(ptr, ptr)

declare i64 @I_RpcServerGetAssociationID(ptr, ptr)

declare i64 @I_RpcServerDisableExceptionFilter()

declare i64 @I_RpcServerSubscribeForDisconnectNotification2(ptr, ptr, ptr)

declare i64 @I_RpcServerUnsubscribeForDisconnectNotification(ptr, i64)

declare i64 @RpcNsBindingExportA(i64, ptr, ptr, ptr, ptr)

declare i64 @RpcNsBindingUnexportA(i64, ptr, ptr, ptr)

declare i64 @RpcNsBindingExportW(i64, ptr, ptr, ptr, ptr)

declare i64 @RpcNsBindingUnexportW(i64, ptr, ptr, ptr)

declare i64 @RpcNsBindingExportPnPA(i64, ptr, ptr, ptr)

declare i64 @RpcNsBindingUnexportPnPA(i64, ptr, ptr, ptr)

declare i64 @RpcNsBindingExportPnPW(i64, ptr, ptr, ptr)

declare i64 @RpcNsBindingUnexportPnPW(i64, ptr, ptr, ptr)

declare i64 @RpcNsBindingLookupBeginA(i64, ptr, ptr, ptr, i64, ptr)

declare i64 @RpcNsBindingLookupBeginW(i64, ptr, ptr, ptr, i64, ptr)

declare i64 @RpcNsBindingLookupNext(ptr, ptr)

declare i64 @RpcNsBindingLookupDone(ptr)

declare i64 @RpcNsGroupDeleteA(i64, ptr)

declare i64 @RpcNsGroupMbrAddA(i64, ptr, i64, ptr)

declare i64 @RpcNsGroupMbrRemoveA(i64, ptr, i64, ptr)

declare i64 @RpcNsGroupMbrInqBeginA(i64, ptr, i64, ptr)

declare i64 @RpcNsGroupMbrInqNextA(ptr, ptr)

declare i64 @RpcNsGroupDeleteW(i64, ptr)

declare i64 @RpcNsGroupMbrAddW(i64, ptr, i64, ptr)

declare i64 @RpcNsGroupMbrRemoveW(i64, ptr, i64, ptr)

declare i64 @RpcNsGroupMbrInqBeginW(i64, ptr, i64, ptr)

declare i64 @RpcNsGroupMbrInqNextW(ptr, ptr)

declare i64 @RpcNsGroupMbrInqDone(ptr)

declare i64 @RpcNsProfileDeleteA(i64, ptr)

declare i64 @RpcNsProfileEltAddA(i64, ptr, ptr, i64, ptr, i64, ptr)

declare i64 @RpcNsProfileEltRemoveA(i64, ptr, ptr, i64, ptr)

declare i64 @RpcNsProfileEltInqBeginA(i64, ptr, i64, ptr, i64, i64, ptr, ptr)

declare i64 @RpcNsProfileEltInqNextA(ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcNsProfileDeleteW(i64, ptr)

declare i64 @RpcNsProfileEltAddW(i64, ptr, ptr, i64, ptr, i64, ptr)

declare i64 @RpcNsProfileEltRemoveW(i64, ptr, ptr, i64, ptr)

declare i64 @RpcNsProfileEltInqBeginW(i64, ptr, i64, ptr, i64, i64, ptr, ptr)

declare i64 @RpcNsProfileEltInqNextW(ptr, ptr, ptr, ptr, ptr)

declare i64 @RpcNsProfileEltInqDone(ptr)

declare i64 @RpcNsEntryObjectInqBeginA(i64, ptr, ptr)

declare i64 @RpcNsEntryObjectInqBeginW(i64, ptr, ptr)

declare i64 @RpcNsEntryObjectInqNext(ptr, ptr)

declare i64 @RpcNsEntryObjectInqDone(ptr)

declare i64 @RpcNsEntryExpandNameA(i64, ptr, ptr)

declare i64 @RpcNsMgmtBindingUnexportA(i64, ptr, ptr, i64, ptr)

declare i64 @RpcNsMgmtEntryCreateA(i64, ptr)

declare i64 @RpcNsMgmtEntryDeleteA(i64, ptr)

declare i64 @RpcNsMgmtEntryInqIfIdsA(i64, ptr, ptr)

declare i64 @RpcNsMgmtHandleSetExpAge(ptr, i64)

declare i64 @RpcNsMgmtInqExpAge(ptr)

declare i64 @RpcNsMgmtSetExpAge(i64)

declare i64 @RpcNsEntryExpandNameW(i64, ptr, ptr)

declare i64 @RpcNsMgmtBindingUnexportW(i64, ptr, ptr, i64, ptr)

declare i64 @RpcNsMgmtEntryCreateW(i64, ptr)

declare i64 @RpcNsMgmtEntryDeleteW(i64, ptr)

declare i64 @RpcNsMgmtEntryInqIfIdsW(i64, ptr, ptr)

declare i64 @RpcNsBindingImportBeginA(i64, ptr, ptr, ptr, ptr)

declare i64 @RpcNsBindingImportBeginW(i64, ptr, ptr, ptr, ptr)

declare i64 @RpcNsBindingImportNext(ptr, ptr)

declare i64 @RpcNsBindingImportDone(ptr)

declare i64 @RpcNsBindingSelect(ptr, ptr)

declare i64 @RpcAsyncRegisterInfo(ptr)

declare i64 @RpcAsyncInitializeHandle(ptr, i64)

declare i64 @RpcAsyncGetCallStatus(ptr)

declare i64 @RpcAsyncCompleteCall(ptr, ptr)

declare i64 @RpcAsyncAbortCall(ptr, i64)

declare i64 @RpcAsyncCancelCall(ptr, i32)

declare i64 @RpcErrorStartEnumeration(ptr)

declare i64 @RpcErrorGetNextRecord(ptr, i32, ptr)

declare i64 @RpcErrorEndEnumeration(ptr)

declare i64 @RpcErrorResetEnumeration(ptr)

declare i64 @RpcErrorGetNumberOfRecords(ptr, ptr)

declare i64 @RpcErrorSaveErrorInfo(ptr, ptr, ptr)

declare i64 @RpcErrorLoadErrorInfo(ptr, i64, ptr)

declare i64 @RpcErrorAddRecord(ptr)

declare void @RpcErrorClearInformation()

declare i64 @RpcAsyncCleanupThread(i64)

declare i64 @RpcGetAuthorizationContextForClient(ptr, i32, ptr, ptr, i64, i64, ptr, ptr)

declare i64 @RpcFreeAuthorizationContext(ptr)

declare i64 @RpcSsContextLockExclusive(ptr, ptr)

declare i64 @RpcSsContextLockShared(ptr, ptr)

declare i64 @RpcServerInqCallAttributesW(ptr, ptr)

declare i64 @RpcServerInqCallAttributesA(ptr, ptr)

declare i64 @RpcServerSubscribeForNotification(ptr, i64, i64, ptr)

declare i64 @RpcServerUnsubscribeForNotification(ptr, i64, ptr)

declare i64 @RpcBindingBind(ptr, ptr, ptr)

declare i64 @RpcBindingUnbind(ptr)

declare i64 @I_RpcAsyncSetHandle(ptr, ptr)

declare i64 @I_RpcAsyncAbortCall(ptr, i64)

declare i32 @I_RpcExceptionFilter(i64)

declare i64 @I_RpcBindingInqClientTokenAttributes(ptr, ptr, ptr, ptr)

declare ptr @CommandLineToArgvW(ptr, ptr)

declare i64 @DragQueryFileA(ptr, i64, ptr, i64)

declare i64 @DragQueryFileW(ptr, i64, ptr, i64)

declare i32 @DragQueryPoint(ptr, ptr)

declare void @DragFinish(ptr)

declare void @DragAcceptFiles(ptr, i32)

declare ptr @ShellExecuteA(ptr, ptr, ptr, ptr, ptr, i32)

declare ptr @ShellExecuteW(ptr, ptr, ptr, ptr, ptr, i32)

declare ptr @FindExecutableA(ptr, ptr, ptr)

declare ptr @FindExecutableW(ptr, ptr, ptr)

declare i32 @ShellAboutA(ptr, ptr, ptr, ptr)

declare i32 @ShellAboutW(ptr, ptr, ptr, ptr)

declare ptr @DuplicateIcon(ptr, ptr)

declare ptr @ExtractAssociatedIconA(ptr, ptr, ptr)

declare ptr @ExtractAssociatedIconW(ptr, ptr, ptr)

declare ptr @ExtractAssociatedIconExA(ptr, ptr, ptr, ptr)

declare ptr @ExtractAssociatedIconExW(ptr, ptr, ptr, ptr)

declare ptr @ExtractIconA(ptr, ptr, i64)

declare ptr @ExtractIconW(ptr, ptr, i64)

declare i64 @SHAppBarMessage(i64, ptr)

declare i64 @DoEnvironmentSubstA(ptr, i64)

declare i64 @DoEnvironmentSubstW(ptr, i64)

declare i64 @ExtractIconExA(ptr, i32, ptr, ptr, i64)

declare i64 @ExtractIconExW(ptr, i32, ptr, ptr, i64)

declare i32 @SHFileOperationA(ptr)

declare i32 @SHFileOperationW(ptr)

declare void @SHFreeNameMappings(ptr)

declare i32 @ShellExecuteExA(ptr)

declare i32 @ShellExecuteExW(ptr)

declare i32 @SHCreateProcessAsUserW(ptr)

declare i64 @SHEvaluateSystemCommandTemplate(ptr, ptr, ptr, ptr)

declare i64 @AssocCreateForClasses(ptr, i64, ptr, ptr)

declare i64 @SHQueryRecycleBinA(ptr, ptr)

declare i64 @SHQueryRecycleBinW(ptr, ptr)

declare i64 @SHEmptyRecycleBinA(ptr, ptr, i64)

declare i64 @SHEmptyRecycleBinW(ptr, ptr, i64)

declare i64 @SHQueryUserNotificationState(ptr)

declare i64 @SHGetPropertyStoreForWindow(ptr, ptr, ptr)

declare i32 @Shell_NotifyIconA(i64, ptr)

declare i32 @Shell_NotifyIconW(i64, ptr)

declare i64 @Shell_NotifyIconGetRect(ptr, ptr)

declare i64 @SHGetFileInfoA(ptr, i64, ptr, i64, i64)

declare i64 @SHGetFileInfoW(ptr, i64, ptr, i64, i64)

declare i64 @SHGetStockIconInfo(i64, i64, ptr)

declare i32 @SHGetDiskFreeSpaceExA(ptr, ptr, ptr, ptr)

declare i32 @SHGetDiskFreeSpaceExW(ptr, ptr, ptr, ptr)

declare i32 @SHGetNewLinkInfoA(ptr, ptr, ptr, ptr, i64)

declare i32 @SHGetNewLinkInfoW(ptr, ptr, ptr, ptr, i64)

declare i32 @SHInvokePrinterCommandA(ptr, i64, ptr, ptr, i32)

declare i32 @SHInvokePrinterCommandW(ptr, i64, ptr, ptr, i32)

declare i64 @SHLoadNonloadedIconOverlayIdentifiers()

declare i64 @SHIsFileAvailableOffline(ptr, ptr)

declare i64 @SHSetLocalizedName(ptr, ptr, i32)

declare i64 @SHRemoveLocalizedName(ptr)

declare i64 @SHGetLocalizedName(ptr, ptr, i64, ptr)

declare i32 @ShellMessageBoxA(ptr, ptr, ptr, ptr, i64)

declare i32 @ShellMessageBoxW(ptr, ptr, ptr, ptr, i64)

declare i32 @IsLFNDriveA(ptr)

declare i32 @IsLFNDriveW(ptr)

declare i64 @SHEnumerateUnreadMailAccountsA(ptr, i64, ptr, i32)

declare i64 @SHEnumerateUnreadMailAccountsW(ptr, i64, ptr, i32)

declare i64 @SHGetUnreadMailCountA(ptr, ptr, ptr, ptr, ptr, i32)

declare i64 @SHGetUnreadMailCountW(ptr, ptr, ptr, ptr, ptr, i32)

declare i64 @SHSetUnreadMailCountA(ptr, i64, ptr)

declare i64 @SHSetUnreadMailCountW(ptr, i64, ptr)

declare i32 @SHTestTokenMembership(ptr, i64)

declare i64 @SHGetImageList(i32, ptr, ptr)

declare i32 @InitNetworkAddressControl()

declare i64 @SHGetDriveMedia(ptr, ptr)

declare i32 @CryptAcquireContextA(ptr, ptr, ptr, i64, i64)

declare i32 @CryptAcquireContextW(ptr, ptr, ptr, i64, i64)

declare i32 @CryptReleaseContext(i64, i64)

declare i32 @CryptGenKey(i64, i64, i64, ptr)

declare i32 @CryptDeriveKey(i64, i64, i64, i64, ptr)

declare i32 @CryptDestroyKey(i64)

declare i32 @CryptSetKeyParam(i64, i64, ptr, i64)

declare i32 @CryptGetKeyParam(i64, i64, ptr, ptr, i64)

declare i32 @CryptSetHashParam(i64, i64, ptr, i64)

declare i32 @CryptGetHashParam(i64, i64, ptr, ptr, i64)

declare i32 @CryptSetProvParam(i64, i64, ptr, i64)

declare i32 @CryptGetProvParam(i64, i64, ptr, ptr, i64)

declare i32 @CryptGenRandom(i64, i64, ptr)

declare i32 @CryptGetUserKey(i64, i64, ptr)

declare i32 @CryptExportKey(i64, i64, i64, i64, ptr, ptr)

declare i32 @CryptImportKey(i64, ptr, i64, i64, i64, ptr)

declare i32 @CryptEncrypt(i64, i64, i32, i64, ptr, ptr, i64)

declare i32 @CryptDecrypt(i64, i64, i32, i64, ptr, ptr)

declare i32 @CryptCreateHash(i64, i64, i64, i64, ptr)

declare i32 @CryptHashData(i64, ptr, i64, i64)

declare i32 @CryptHashSessionKey(i64, i64, i64)

declare i32 @CryptDestroyHash(i64)

declare i32 @CryptSignHashA(i64, i64, ptr, i64, ptr, ptr)

declare i32 @CryptSignHashW(i64, i64, ptr, i64, ptr, ptr)

declare i32 @CryptVerifySignatureA(i64, ptr, i64, i64, ptr, i64)

declare i32 @CryptVerifySignatureW(i64, ptr, i64, i64, ptr, i64)

declare i32 @CryptSetProviderA(ptr, i64)

declare i32 @CryptSetProviderW(ptr, i64)

declare i32 @CryptSetProviderExA(ptr, i64, ptr, i64)

declare i32 @CryptSetProviderExW(ptr, i64, ptr, i64)

declare i32 @CryptGetDefaultProviderA(i64, ptr, i64, ptr, ptr)

declare i32 @CryptGetDefaultProviderW(i64, ptr, i64, ptr, ptr)

declare i32 @CryptEnumProviderTypesA(i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptEnumProviderTypesW(i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptEnumProvidersA(i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptEnumProvidersW(i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptContextAddRef(i64, ptr, i64)

declare i32 @CryptDuplicateKey(i64, ptr, i64, ptr)

declare i32 @CryptDuplicateHash(i64, ptr, i64, ptr)

declare i32 @GetEncSChannel(ptr, ptr)

declare i64 @BCryptOpenAlgorithmProvider(ptr, ptr, ptr, i64)

declare i64 @BCryptEnumAlgorithms(i64, ptr, ptr, i64)

declare i64 @BCryptEnumProviders(ptr, ptr, ptr, i64)

declare i64 @BCryptGetProperty(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @BCryptSetProperty(ptr, ptr, ptr, i64, i64)

declare i64 @BCryptCloseAlgorithmProvider(ptr, i64)

declare void @BCryptFreeBuffer(ptr)

declare i64 @BCryptGenerateSymmetricKey(ptr, ptr, ptr, i64, ptr, i64, i64)

declare i64 @BCryptGenerateKeyPair(ptr, ptr, i64, i64)

declare i64 @BCryptEncrypt(ptr, ptr, i64, ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @BCryptDecrypt(ptr, ptr, i64, ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @BCryptExportKey(ptr, ptr, ptr, ptr, i64, ptr, i64)

declare i64 @BCryptImportKey(ptr, ptr, ptr, ptr, ptr, i64, ptr, i64, i64)

declare i64 @BCryptImportKeyPair(ptr, ptr, ptr, ptr, ptr, i64, i64)

declare i64 @BCryptDuplicateKey(ptr, ptr, ptr, i64, i64)

declare i64 @BCryptFinalizeKeyPair(ptr, i64)

declare i64 @BCryptDestroyKey(ptr)

declare i64 @BCryptDestroySecret(ptr)

declare i64 @BCryptSignHash(ptr, ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @BCryptVerifySignature(ptr, ptr, ptr, i64, ptr, i64, i64)

declare i64 @BCryptSecretAgreement(ptr, ptr, ptr, i64)

declare i64 @BCryptDeriveKey(ptr, ptr, ptr, ptr, i64, ptr, i64)

declare i64 @BCryptKeyDerivation(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @BCryptCreateHash(ptr, ptr, ptr, i64, ptr, i64, i64)

declare i64 @BCryptHashData(ptr, ptr, i64, i64)

declare i64 @BCryptFinishHash(ptr, ptr, i64, i64)

declare i64 @BCryptCreateMultiHash(ptr, ptr, i64, ptr, i64, ptr, i64, i64)

declare i64 @BCryptProcessMultiOperations(ptr, i64, ptr, i64, i64)

declare i64 @BCryptDuplicateHash(ptr, ptr, ptr, i64, i64)

declare i64 @BCryptDestroyHash(ptr)

declare i64 @BCryptHash(ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @BCryptGenRandom(ptr, ptr, i64, i64)

declare i64 @BCryptDeriveKeyCapi(ptr, ptr, ptr, i64, i64)

declare i64 @BCryptDeriveKeyPBKDF2(ptr, ptr, i64, ptr, i64, i64, ptr, i64, i64)

declare i64 @BCryptEncapsulate(ptr, ptr, i64, ptr, ptr, i64, ptr, i64)

declare i64 @BCryptDecapsulate(ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @BCryptQueryProviderRegistration(ptr, i64, i64, ptr, ptr)

declare i64 @BCryptEnumRegisteredProviders(ptr, ptr)

declare i64 @BCryptCreateContext(i64, ptr, ptr)

declare i64 @BCryptDeleteContext(i64, ptr)

declare i64 @BCryptEnumContexts(i64, ptr, ptr)

declare i64 @BCryptConfigureContext(i64, ptr, ptr)

declare i64 @BCryptQueryContextConfiguration(i64, ptr, ptr, ptr)

declare i64 @BCryptAddContextFunction(i64, ptr, i64, ptr, i64)

declare i64 @BCryptRemoveContextFunction(i64, ptr, i64, ptr)

declare i64 @BCryptEnumContextFunctions(i64, ptr, i64, ptr, ptr)

declare i64 @BCryptConfigureContextFunction(i64, ptr, i64, ptr, ptr)

declare i64 @BCryptQueryContextFunctionConfiguration(i64, ptr, i64, ptr, ptr, ptr)

declare i64 @BCryptEnumContextFunctionProviders(i64, ptr, i64, ptr, ptr, ptr)

declare i64 @BCryptSetContextFunctionProperty(i64, ptr, i64, ptr, ptr, i64, ptr)

declare i64 @BCryptQueryContextFunctionProperty(i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @BCryptRegisterConfigChangeNotify(ptr)

declare i64 @BCryptUnregisterConfigChangeNotify(ptr)

declare i64 @BCryptResolveProviders(ptr, i64, ptr, ptr, i64, i64, ptr, ptr)

declare i64 @BCryptGetFipsAlgorithmMode(ptr)

declare i64 @CngGetFipsAlgorithmMode()

declare i64 @NCryptOpenStorageProvider(ptr, ptr, i64)

declare i64 @NCryptEnumAlgorithms(i64, i64, ptr, ptr, i64)

declare i64 @NCryptIsAlgSupported(i64, ptr, i64)

declare i64 @NCryptEnumKeys(i64, ptr, ptr, ptr, i64)

declare i64 @NCryptEnumStorageProviders(ptr, ptr, i64)

declare i64 @NCryptFreeBuffer(ptr)

declare i64 @NCryptOpenKey(i64, ptr, ptr, i64, i64)

declare i64 @NCryptCreatePersistedKey(i64, ptr, ptr, ptr, i64, i64)

declare i64 @NCryptGetProperty(i64, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptSetProperty(i64, ptr, ptr, i64, i64)

declare i64 @NCryptFinalizeKey(i64, i64)

declare i64 @NCryptEncrypt(i64, ptr, i64, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptDecrypt(i64, ptr, i64, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptEncapsulate(i64, ptr, i64, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptDecapsulate(i64, ptr, i64, ptr, i64, ptr, i64)

declare i64 @NCryptImportKey(i64, i64, ptr, ptr, ptr, ptr, i64, i64)

declare i64 @NCryptExportKey(i64, i64, ptr, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptSignHash(i64, ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @NCryptVerifySignature(i64, ptr, ptr, i64, ptr, i64, i64)

declare i64 @NCryptDeleteKey(i64, i64)

declare i64 @NCryptFreeObject(i64)

declare i32 @NCryptIsKeyHandle(i64)

declare i64 @NCryptTranslateHandle(ptr, ptr, i64, i64, i64, i64)

declare i64 @NCryptNotifyChangeKey(i64, ptr, i64)

declare i64 @NCryptSecretAgreement(i64, i64, ptr, i64)

declare i64 @NCryptDeriveKey(i64, ptr, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptKeyDerivation(i64, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptCreateClaim(i64, i64, i64, ptr, ptr, i64, ptr, i64)

declare i64 @NCryptVerifyClaim(i64, i64, i64, ptr, ptr, i64, ptr, i64)

declare i32 @CryptFormatObject(i64, i64, i64, ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @CryptEncodeObjectEx(i64, ptr, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptEncodeObject(i64, ptr, ptr, ptr, ptr)

declare i32 @CryptDecodeObjectEx(i64, ptr, ptr, i64, i64, ptr, ptr, ptr)

declare i32 @CryptDecodeObject(i64, ptr, ptr, i64, i64, ptr, ptr)

declare i32 @CryptInstallOIDFunctionAddress(ptr, i64, ptr, i64, i64, i64)

declare ptr @CryptInitOIDFunctionSet(ptr, i64)

declare i32 @CryptGetOIDFunctionAddress(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @CryptGetDefaultOIDDllList(ptr, i64, ptr, ptr)

declare i32 @CryptGetDefaultOIDFunctionAddress(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @CryptFreeOIDFunctionAddress(ptr, i64)

declare i32 @CryptRegisterOIDFunction(i64, ptr, ptr, ptr, ptr)

declare i32 @CryptUnregisterOIDFunction(i64, ptr, ptr)

declare i32 @CryptRegisterDefaultOIDFunction(i64, ptr, i64, ptr)

declare i32 @CryptUnregisterDefaultOIDFunction(i64, ptr, ptr)

declare i32 @CryptSetOIDFunctionValue(i64, ptr, ptr, ptr, i64, ptr, i64)

declare i32 @CryptGetOIDFunctionValue(i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @CryptEnumOIDFunction(i64, ptr, ptr, i64, ptr, ptr)

declare ptr @CryptFindOIDInfo(i64, ptr, i64)

declare i32 @CryptRegisterOIDInfo(ptr, i64)

declare i32 @CryptUnregisterOIDInfo(ptr)

declare i32 @CryptEnumOIDInfo(i64, i64, ptr, ptr)

declare ptr @CryptFindLocalizedName(ptr)

declare ptr @CryptMsgOpenToEncode(i64, i64, i64, ptr, ptr, ptr)

declare i64 @CryptMsgCalculateEncodedLength(i64, i64, i64, ptr, ptr, i64)

declare ptr @CryptMsgOpenToDecode(i64, i64, i64, i64, ptr, ptr)

declare ptr @CryptMsgDuplicate(ptr)

declare i32 @CryptMsgClose(ptr)

declare i32 @CryptMsgUpdate(ptr, ptr, i64, i32)

declare i32 @CryptMsgGetParam(ptr, i64, i64, ptr, ptr)

declare i32 @CryptMsgControl(ptr, i64, i64, ptr)

declare i32 @CryptMsgVerifyCountersignatureEncoded(i64, i64, ptr, i64, ptr, i64, ptr)

declare i32 @CryptMsgVerifyCountersignatureEncodedEx(i64, i64, ptr, i64, ptr, i64, i64, ptr, i64, ptr)

declare i32 @CryptMsgCountersign(ptr, i64, i64, ptr)

declare i32 @CryptMsgCountersignEncoded(i64, ptr, i64, i64, ptr, ptr, ptr)

declare ptr @CertOpenStore(ptr, i64, i64, i64, ptr)

declare ptr @CertDuplicateStore(ptr)

declare i32 @CertSaveStore(ptr, i64, i64, i64, ptr, i64)

declare i32 @CertCloseStore(ptr, i64)

declare ptr @CertGetSubjectCertificateFromStore(ptr, i64, ptr)

declare ptr @CertEnumCertificatesInStore(ptr, ptr)

declare ptr @CertFindCertificateInStore(ptr, i64, i64, i64, ptr, ptr)

declare ptr @CertGetIssuerCertificateFromStore(ptr, ptr, ptr, ptr)

declare i32 @CertVerifySubjectCertificateContext(ptr, ptr, ptr)

declare ptr @CertDuplicateCertificateContext(ptr)

declare ptr @CertCreateCertificateContext(i64, ptr, i64)

declare i32 @CertFreeCertificateContext(ptr)

declare i32 @CertSetCertificateContextProperty(ptr, i64, i64, ptr)

declare i32 @CertGetCertificateContextProperty(ptr, i64, ptr, ptr)

declare i64 @CertEnumCertificateContextProperties(ptr, i64)

declare i32 @CertCreateCTLEntryFromCertificateContextProperties(ptr, i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CertSetCertificateContextPropertiesFromCTLEntry(ptr, ptr, i64)

declare ptr @CertGetCRLFromStore(ptr, ptr, ptr, ptr)

declare ptr @CertEnumCRLsInStore(ptr, ptr)

declare ptr @CertFindCRLInStore(ptr, i64, i64, i64, ptr, ptr)

declare ptr @CertDuplicateCRLContext(ptr)

declare ptr @CertCreateCRLContext(i64, ptr, i64)

declare i32 @CertFreeCRLContext(ptr)

declare i32 @CertSetCRLContextProperty(ptr, i64, i64, ptr)

declare i32 @CertGetCRLContextProperty(ptr, i64, ptr, ptr)

declare i64 @CertEnumCRLContextProperties(ptr, i64)

declare i32 @CertFindCertificateInCRL(ptr, ptr, i64, ptr, ptr)

declare i32 @CertIsValidCRLForCertificate(ptr, ptr, i64, ptr)

declare i32 @CertAddEncodedCertificateToStore(ptr, i64, ptr, i64, i64, ptr)

declare i32 @CertAddCertificateContextToStore(ptr, ptr, i64, ptr)

declare i32 @CertAddSerializedElementToStore(ptr, ptr, i64, i64, i64, i64, ptr, ptr)

declare i32 @CertDeleteCertificateFromStore(ptr)

declare i32 @CertAddEncodedCRLToStore(ptr, i64, ptr, i64, i64, ptr)

declare i32 @CertAddCRLContextToStore(ptr, ptr, i64, ptr)

declare i32 @CertDeleteCRLFromStore(ptr)

declare i32 @CertSerializeCertificateStoreElement(ptr, i64, ptr, ptr)

declare i32 @CertSerializeCRLStoreElement(ptr, i64, ptr, ptr)

declare ptr @CertDuplicateCTLContext(ptr)

declare ptr @CertCreateCTLContext(i64, ptr, i64)

declare i32 @CertFreeCTLContext(ptr)

declare i32 @CertSetCTLContextProperty(ptr, i64, i64, ptr)

declare i32 @CertGetCTLContextProperty(ptr, i64, ptr, ptr)

declare i64 @CertEnumCTLContextProperties(ptr, i64)

declare ptr @CertEnumCTLsInStore(ptr, ptr)

declare ptr @CertFindSubjectInCTL(i64, i64, ptr, ptr, i64)

declare ptr @CertFindCTLInStore(ptr, i64, i64, i64, ptr, ptr)

declare i32 @CertAddEncodedCTLToStore(ptr, i64, ptr, i64, i64, ptr)

declare i32 @CertAddCTLContextToStore(ptr, ptr, i64, ptr)

declare i32 @CertSerializeCTLStoreElement(ptr, i64, ptr, ptr)

declare i32 @CertDeleteCTLFromStore(ptr)

declare i32 @CertAddCertificateLinkToStore(ptr, ptr, i64, ptr)

declare i32 @CertAddCRLLinkToStore(ptr, ptr, i64, ptr)

declare i32 @CertAddCTLLinkToStore(ptr, ptr, i64, ptr)

declare i32 @CertAddStoreToCollection(ptr, ptr, i64, i64)

declare void @CertRemoveStoreFromCollection(ptr, ptr)

declare i32 @CertControlStore(ptr, i64, i64, ptr)

declare i32 @CertSetStoreProperty(ptr, i64, i64, ptr)

declare i32 @CertGetStoreProperty(ptr, i64, ptr, ptr)

declare ptr @CertCreateContext(i64, i64, ptr, i64, i64, ptr)

declare i32 @CertRegisterSystemStore(ptr, i64, ptr, ptr)

declare i32 @CertRegisterPhysicalStore(ptr, i64, ptr, ptr, ptr)

declare i32 @CertUnregisterSystemStore(ptr, i64)

declare i32 @CertUnregisterPhysicalStore(ptr, i64, ptr)

declare i32 @CertEnumSystemStoreLocation(i64, ptr, ptr)

declare i32 @CertEnumSystemStore(i64, ptr, ptr, ptr)

declare i32 @CertEnumPhysicalStore(ptr, i64, ptr, ptr)

declare i32 @CertGetEnhancedKeyUsage(ptr, i64, ptr, ptr)

declare i32 @CertSetEnhancedKeyUsage(ptr, ptr)

declare i32 @CertAddEnhancedKeyUsageIdentifier(ptr, ptr)

declare i32 @CertRemoveEnhancedKeyUsageIdentifier(ptr, ptr)

declare i32 @CertGetValidUsages(i64, ptr, ptr, ptr, ptr)

declare i32 @CryptMsgGetAndVerifySigner(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @CryptMsgSignCTL(i64, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @CryptMsgEncodeAndSignCTL(i64, ptr, ptr, i64, ptr, ptr)

declare i32 @CertFindSubjectInSortedCTL(ptr, ptr, i64, ptr, ptr)

declare i32 @CertEnumSubjectInSortedCTL(ptr, ptr, ptr, ptr)

declare i32 @CertVerifyCTLUsage(i64, i64, ptr, ptr, i64, ptr, ptr)

declare i32 @CertVerifyRevocation(i64, i64, i64, i64, i64, ptr, ptr)

declare i32 @CertCompareIntegerBlob(ptr, ptr)

declare i32 @CertCompareCertificate(i64, ptr, ptr)

declare i32 @CertCompareCertificateName(i64, ptr, ptr)

declare i32 @CertIsRDNAttrsInCertificateName(i64, i64, ptr, ptr)

declare i32 @CertComparePublicKeyInfo(i64, ptr, ptr)

declare i64 @CertGetPublicKeyLength(i64, ptr)

declare i32 @CryptVerifyCertificateSignature(i64, i64, ptr, i64, ptr)

declare i32 @CryptVerifyCertificateSignatureEx(i64, i64, i64, ptr, i64, ptr, i64, ptr)

declare i32 @CertIsStrongHashToSign(ptr, ptr, ptr)

declare i32 @CryptHashToBeSigned(i64, i64, ptr, i64, ptr, ptr)

declare i32 @CryptHashCertificate(i64, i64, i64, ptr, i64, ptr, ptr)

declare i32 @CryptHashCertificate2(ptr, i64, ptr, ptr, i64, ptr, ptr)

declare i32 @CryptSignCertificate(i64, i64, i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptSignAndEncodeCertificate(i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @CertVerifyTimeValidity(ptr, ptr)

declare i64 @CertVerifyCRLTimeValidity(ptr, ptr)

declare i32 @CertVerifyValidityNesting(ptr, ptr)

declare i32 @CertVerifyCRLRevocation(i64, ptr, i64, i64)

declare ptr @CertAlgIdToOID(i64)

declare i64 @CertOIDToAlgId(ptr)

declare ptr @CertFindExtension(ptr, i64, i64)

declare ptr @CertFindAttribute(ptr, i64, i64)

declare ptr @CertFindRDNAttr(ptr, ptr)

declare i32 @CertGetIntendedKeyUsage(i64, ptr, ptr, i64)

declare i32 @CryptInstallDefaultContext(i64, i64, ptr, i64, ptr, ptr)

declare i32 @CryptUninstallDefaultContext(ptr, i64, ptr)

declare i32 @CryptExportPublicKeyInfo(i64, i64, i64, ptr, ptr)

declare i32 @CryptExportPublicKeyInfoEx(i64, i64, i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptExportPublicKeyInfoFromBCryptKeyHandle(ptr, i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptImportPublicKeyInfo(i64, i64, ptr, ptr)

declare i32 @CryptImportPublicKeyInfoEx(i64, i64, ptr, i64, i64, ptr, ptr)

declare i32 @CryptImportPublicKeyInfoEx2(i64, ptr, i64, ptr, ptr)

declare i32 @CryptAcquireCertificatePrivateKey(ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptFindCertificateKeyProvInfo(ptr, i64, ptr)

declare i32 @CryptImportPKCS8(i64, i64, ptr, ptr)

declare i32 @CryptExportPKCS8(i64, i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptExportPKCS8Ex(ptr, i64, ptr, ptr, ptr)

declare i32 @CryptHashPublicKeyInfo(i64, i64, i64, i64, ptr, ptr, ptr)

declare i64 @CertRDNValueToStrA(i64, ptr, ptr, i64)

declare i64 @CertRDNValueToStrW(i64, ptr, ptr, i64)

declare i64 @CertNameToStrA(i64, ptr, i64, ptr, i64)

declare i64 @CertNameToStrW(i64, ptr, i64, ptr, i64)

declare i32 @CertStrToNameA(i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @CertStrToNameW(i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @CertGetNameStringA(ptr, i64, i64, ptr, ptr, i64)

declare i64 @CertGetNameStringW(ptr, i64, i64, ptr, ptr, i64)

declare i32 @CryptSignMessage(ptr, i32, i64, i64, i64, ptr, ptr)

declare i32 @CryptVerifyMessageSignature(ptr, i64, ptr, i64, ptr, ptr, ptr)

declare i64 @CryptGetMessageSignerCount(i64, ptr, i64)

declare ptr @CryptGetMessageCertificates(i64, i64, i64, ptr, i64)

declare i32 @CryptVerifyDetachedMessageSignature(ptr, i64, ptr, i64, i64, i64, i64, ptr)

declare i32 @CryptEncryptMessage(ptr, i64, i64, ptr, i64, ptr, ptr)

declare i32 @CryptDecryptMessage(ptr, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptSignAndEncryptMessage(ptr, ptr, i64, i64, ptr, i64, ptr, ptr)

declare i32 @CryptDecryptAndVerifyMessageSignature(ptr, ptr, i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptDecodeMessage(i64, ptr, ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @CryptHashMessage(ptr, i32, i64, i64, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptVerifyMessageHash(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptVerifyDetachedMessageHash(ptr, ptr, i64, i64, i64, i64, ptr, ptr)

declare i32 @CryptSignMessageWithKey(ptr, ptr, i64, ptr, ptr)

declare i32 @CryptVerifyMessageSignatureWithKey(ptr, ptr, ptr, i64, ptr, ptr)

declare ptr @CertOpenSystemStoreA(i64, ptr)

declare ptr @CertOpenSystemStoreW(i64, ptr)

declare i32 @CertAddEncodedCertificateToSystemStoreA(ptr, ptr, i64)

declare i32 @CertAddEncodedCertificateToSystemStoreW(ptr, ptr, i64)

declare i64 @FindCertsByIssuer(ptr, ptr, ptr, ptr, i64, ptr, i64)

declare i32 @CryptQueryObject(i64, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare ptr @CryptMemAlloc(i64)

declare ptr @CryptMemRealloc(ptr, i64)

declare void @CryptMemFree(ptr)

declare i32 @CryptCreateAsyncHandle(i64, ptr)

declare i32 @CryptSetAsyncParam(ptr, ptr, ptr, ptr)

declare i32 @CryptGetAsyncParam(ptr, ptr, ptr, ptr)

declare i32 @CryptCloseAsyncHandle(ptr)

declare i32 @CryptRetrieveObjectByUrlA(ptr, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @CryptRetrieveObjectByUrlW(ptr, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @CryptInstallCancelRetrieval(ptr, ptr, i64, ptr)

declare i32 @CryptUninstallCancelRetrieval(i64, ptr)

declare i32 @CryptCancelAsyncRetrieval(ptr)

declare i32 @CryptGetObjectUrl(ptr, ptr, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @CryptGetTimeValidObject(ptr, ptr, ptr, ptr, i64, i64, ptr, ptr, ptr)

declare i32 @CryptFlushTimeValidObject(ptr, ptr, ptr, i64, ptr)

declare ptr @CertCreateSelfSignCertificate(i64, ptr, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @CryptGetKeyIdentifierProperty(ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptSetKeyIdentifierProperty(ptr, i64, i64, ptr, ptr, ptr)

declare i32 @CryptEnumKeyIdentifierProperties(ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptCreateKeyIdentifierFromCSP(i64, ptr, ptr, i64, i64, ptr, ptr, ptr)

declare i32 @CertCreateCertificateChainEngine(ptr, ptr)

declare void @CertFreeCertificateChainEngine(ptr)

declare i32 @CertResyncCertificateChainEngine(ptr)

declare i32 @CertGetCertificateChain(ptr, ptr, ptr, ptr, ptr, i64, ptr, ptr)

declare void @CertFreeCertificateChain(ptr)

declare ptr @CertDuplicateCertificateChain(ptr)

declare ptr @CertFindChainInStore(ptr, i64, i64, i64, ptr, ptr)

declare i32 @CertVerifyCertificateChainPolicy(ptr, ptr, ptr, ptr)

declare i32 @CryptStringToBinaryA(ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptStringToBinaryW(ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i32 @CryptBinaryToStringA(ptr, i64, i64, ptr, ptr)

declare i32 @CryptBinaryToStringW(ptr, i64, i64, ptr, ptr)

declare ptr @PFXImportCertStore(ptr, ptr, i64)

declare i32 @PFXIsPFXBlob(ptr)

declare i32 @PFXVerifyPassword(ptr, ptr, i64)

declare i32 @PFXExportCertStoreEx(ptr, ptr, ptr, ptr, i64)

declare i32 @PFXExportCertStore(ptr, ptr, ptr, i64)

declare ptr @CertOpenServerOcspResponse(ptr, i64, ptr)

declare void @CertAddRefServerOcspResponse(ptr)

declare void @CertCloseServerOcspResponse(ptr, i64)

declare ptr @CertGetServerOcspResponseContext(ptr, i64, ptr)

declare void @CertAddRefServerOcspResponseContext(ptr)

declare void @CertFreeServerOcspResponseContext(ptr)

declare i32 @CertRetrieveLogoOrBiometricInfo(ptr, ptr, i64, i64, i64, ptr, ptr, ptr, ptr)

declare i32 @CertSelectCertificateChains(ptr, i64, ptr, i64, ptr, ptr, ptr, ptr)

declare void @CertFreeCertificateChainList(ptr)

declare i32 @CryptRetrieveTimeStamp(ptr, i64, i64, ptr, ptr, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptVerifyTimeStampSignature(ptr, i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @CertIsWeakHash(i64, ptr, i64, ptr, ptr, ptr)

declare i32 @CryptProtectData(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i32 @CryptUnprotectData(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i32 @CryptProtectDataNoUI(ptr, ptr, ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i32 @CryptUnprotectDataNoUI(ptr, ptr, ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i32 @CryptUpdateProtectedState(ptr, ptr, i64, ptr, ptr)

declare i32 @CryptProtectMemory(ptr, i64, i64)

declare i32 @CryptUnprotectMemory(ptr, i64, i64)

declare i64 @QueryUsersOnEncryptedFile(ptr, ptr)

declare i64 @QueryRecoveryAgentsOnEncryptedFile(ptr, ptr)

declare i64 @RemoveUsersFromEncryptedFile(ptr, ptr)

declare i64 @AddUsersToEncryptedFile(ptr, ptr)

declare i64 @SetUserFileEncryptionKey(ptr)

declare i64 @SetUserFileEncryptionKeyEx(ptr, i64, i64, ptr)

declare void @FreeEncryptionCertificateHashList(ptr)

declare i32 @EncryptionDisable(ptr, i32)

declare i64 @DuplicateEncryptionInfoFile(ptr, ptr, i64, i64, ptr)

declare i64 @GetEncryptedFileMetadata(ptr, ptr, ptr)

declare i64 @SetEncryptedFileMetadata(ptr, ptr, ptr, ptr, i64, ptr)

declare void @FreeEncryptedFileMetadata(ptr)

declare i64 @I_RpcNsGetBuffer(ptr)

declare i64 @I_RpcNsSendReceive(ptr, ptr)

declare void @I_RpcNsRaiseException(ptr, i64)

declare i64 @I_RpcReBindBuffer(ptr)

declare i64 @I_NsServerBindSearch()

declare i64 @I_NsClientBindSearch()

declare void @I_NsClientBindDone()

declare ptr @MIDL_user_allocate(i64)

declare void @MIDL_user_free(ptr)

declare ptr @I_RpcDefaultAllocate(ptr, i64, ptr)

declare void @I_RpcDefaultFree(ptr, ptr, ptr)

declare ptr @NDRCContextBinding(ptr)

declare void @NDRCContextMarshall(ptr, ptr)

declare void @NDRCContextUnmarshall(ptr, ptr, ptr, i64)

declare void @NDRCContextUnmarshall2(ptr, ptr, ptr, i64)

declare void @NDRSContextMarshall(ptr, ptr, ptr)

declare ptr @NDRSContextUnmarshall(ptr, i64)

declare void @NDRSContextMarshallEx(ptr, ptr, ptr, ptr)

declare void @NDRSContextMarshall2(ptr, ptr, ptr, ptr, ptr, i64)

declare ptr @NDRSContextUnmarshallEx(ptr, ptr, i64)

declare ptr @NDRSContextUnmarshall2(ptr, ptr, i64, ptr, i64)

declare void @RpcSsDestroyClientContext(ptr)

declare void @RpcCsGetTags(ptr, i32, ptr, ptr, ptr, ptr)

declare i64 @NdrClientGetSupportedSyntaxes(ptr, ptr, ptr)

declare i64 @NdrServerGetSupportedSyntaxes(ptr, ptr, ptr, ptr)

declare void @NdrSimpleTypeMarshall(ptr, ptr, i64)

declare ptr @NdrPointerMarshall(ptr, ptr, ptr)

declare ptr @NdrCsArrayMarshall(ptr, ptr, ptr)

declare ptr @NdrCsTagMarshall(ptr, ptr, ptr)

declare ptr @NdrSimpleStructMarshall(ptr, ptr, ptr)

declare ptr @NdrConformantStructMarshall(ptr, ptr, ptr)

declare ptr @NdrConformantVaryingStructMarshall(ptr, ptr, ptr)

declare ptr @NdrComplexStructMarshall(ptr, ptr, ptr)

declare ptr @NdrFixedArrayMarshall(ptr, ptr, ptr)

declare ptr @NdrConformantArrayMarshall(ptr, ptr, ptr)

declare ptr @NdrConformantVaryingArrayMarshall(ptr, ptr, ptr)

declare ptr @NdrVaryingArrayMarshall(ptr, ptr, ptr)

declare ptr @NdrComplexArrayMarshall(ptr, ptr, ptr)

declare ptr @NdrNonConformantStringMarshall(ptr, ptr, ptr)

declare ptr @NdrConformantStringMarshall(ptr, ptr, ptr)

declare ptr @NdrEncapsulatedUnionMarshall(ptr, ptr, ptr)

declare ptr @NdrNonEncapsulatedUnionMarshall(ptr, ptr, ptr)

declare ptr @NdrByteCountPointerMarshall(ptr, ptr, ptr)

declare ptr @NdrXmitOrRepAsMarshall(ptr, ptr, ptr)

declare ptr @NdrUserMarshalMarshall(ptr, ptr, ptr)

declare ptr @NdrInterfacePointerMarshall(ptr, ptr, ptr)

declare void @NdrClientContextMarshall(ptr, ptr, i32)

declare void @NdrServerContextMarshall(ptr, ptr, ptr)

declare void @NdrServerContextNewMarshall(ptr, ptr, ptr, ptr)

declare void @NdrSimpleTypeUnmarshall(ptr, ptr, i64)

declare ptr @NdrCsArrayUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrCsTagUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrRangeUnmarshall(ptr, ptr, ptr, i64)

declare void @NdrCorrelationInitialize(ptr, ptr, i64, i64)

declare void @NdrCorrelationPass(ptr)

declare void @NdrCorrelationFree(ptr)

declare ptr @NdrPointerUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrSimpleStructUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrConformantStructUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrConformantVaryingStructUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrComplexStructUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrFixedArrayUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrConformantArrayUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrConformantVaryingArrayUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrVaryingArrayUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrComplexArrayUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrNonConformantStringUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrConformantStringUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrEncapsulatedUnionUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrNonEncapsulatedUnionUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrByteCountPointerUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrXmitOrRepAsUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrUserMarshalUnmarshall(ptr, ptr, ptr, i64)

declare ptr @NdrInterfacePointerUnmarshall(ptr, ptr, ptr, i64)

declare void @NdrClientContextUnmarshall(ptr, ptr, ptr)

declare ptr @NdrServerContextUnmarshall(ptr)

declare ptr @NdrContextHandleInitialize(ptr, ptr)

declare ptr @NdrServerContextNewUnmarshall(ptr, ptr)

declare void @NdrPointerBufferSize(ptr, ptr, ptr)

declare void @NdrCsArrayBufferSize(ptr, ptr, ptr)

declare void @NdrCsTagBufferSize(ptr, ptr, ptr)

declare void @NdrSimpleStructBufferSize(ptr, ptr, ptr)

declare void @NdrConformantStructBufferSize(ptr, ptr, ptr)

declare void @NdrConformantVaryingStructBufferSize(ptr, ptr, ptr)

declare void @NdrComplexStructBufferSize(ptr, ptr, ptr)

declare void @NdrFixedArrayBufferSize(ptr, ptr, ptr)

declare void @NdrConformantArrayBufferSize(ptr, ptr, ptr)

declare void @NdrConformantVaryingArrayBufferSize(ptr, ptr, ptr)

declare void @NdrVaryingArrayBufferSize(ptr, ptr, ptr)

declare void @NdrComplexArrayBufferSize(ptr, ptr, ptr)

declare void @NdrConformantStringBufferSize(ptr, ptr, ptr)

declare void @NdrNonConformantStringBufferSize(ptr, ptr, ptr)

declare void @NdrEncapsulatedUnionBufferSize(ptr, ptr, ptr)

declare void @NdrNonEncapsulatedUnionBufferSize(ptr, ptr, ptr)

declare void @NdrByteCountPointerBufferSize(ptr, ptr, ptr)

declare void @NdrXmitOrRepAsBufferSize(ptr, ptr, ptr)

declare void @NdrUserMarshalBufferSize(ptr, ptr, ptr)

declare void @NdrInterfacePointerBufferSize(ptr, ptr, ptr)

declare void @NdrContextHandleSize(ptr, ptr, ptr)

declare i64 @NdrPointerMemorySize(ptr, ptr)

declare i64 @NdrContextHandleMemorySize(ptr, ptr)

declare i64 @NdrCsArrayMemorySize(ptr, ptr)

declare i64 @NdrCsTagMemorySize(ptr, ptr)

declare i64 @NdrSimpleStructMemorySize(ptr, ptr)

declare i64 @NdrConformantStructMemorySize(ptr, ptr)

declare i64 @NdrConformantVaryingStructMemorySize(ptr, ptr)

declare i64 @NdrComplexStructMemorySize(ptr, ptr)

declare i64 @NdrFixedArrayMemorySize(ptr, ptr)

declare i64 @NdrConformantArrayMemorySize(ptr, ptr)

declare i64 @NdrConformantVaryingArrayMemorySize(ptr, ptr)

declare i64 @NdrVaryingArrayMemorySize(ptr, ptr)

declare i64 @NdrComplexArrayMemorySize(ptr, ptr)

declare i64 @NdrConformantStringMemorySize(ptr, ptr)

declare i64 @NdrNonConformantStringMemorySize(ptr, ptr)

declare i64 @NdrEncapsulatedUnionMemorySize(ptr, ptr)

declare i64 @NdrNonEncapsulatedUnionMemorySize(ptr, ptr)

declare i64 @NdrXmitOrRepAsMemorySize(ptr, ptr)

declare i64 @NdrUserMarshalMemorySize(ptr, ptr)

declare i64 @NdrInterfacePointerMemorySize(ptr, ptr)

declare void @NdrPointerFree(ptr, ptr, ptr)

declare void @NdrCsArrayFree(ptr, ptr, ptr)

declare void @NdrSimpleStructFree(ptr, ptr, ptr)

declare void @NdrConformantStructFree(ptr, ptr, ptr)

declare void @NdrConformantVaryingStructFree(ptr, ptr, ptr)

declare void @NdrComplexStructFree(ptr, ptr, ptr)

declare void @NdrFixedArrayFree(ptr, ptr, ptr)

declare void @NdrConformantArrayFree(ptr, ptr, ptr)

declare void @NdrConformantVaryingArrayFree(ptr, ptr, ptr)

declare void @NdrVaryingArrayFree(ptr, ptr, ptr)

declare void @NdrComplexArrayFree(ptr, ptr, ptr)

declare void @NdrEncapsulatedUnionFree(ptr, ptr, ptr)

declare void @NdrNonEncapsulatedUnionFree(ptr, ptr, ptr)

declare void @NdrByteCountPointerFree(ptr, ptr, ptr)

declare void @NdrXmitOrRepAsFree(ptr, ptr, ptr)

declare void @NdrUserMarshalFree(ptr, ptr, ptr)

declare void @NdrInterfacePointerFree(ptr, ptr, ptr)

declare void @NdrConvert2(ptr, ptr, i64)

declare void @NdrConvert(ptr, ptr)

declare ptr @NdrUserMarshalSimpleTypeConvert(ptr, ptr, i64)

declare void @NdrClientInitializeNew(ptr, ptr, ptr, i64)

declare ptr @NdrServerInitializeNew(ptr, ptr, ptr)

declare void @NdrServerInitializePartial(ptr, ptr, ptr, i64)

declare void @NdrClientInitialize(ptr, ptr, ptr, i64)

declare ptr @NdrServerInitialize(ptr, ptr, ptr)

declare ptr @NdrServerInitializeUnmarshall(ptr, ptr, ptr)

declare void @NdrServerInitializeMarshall(ptr, ptr)

declare ptr @NdrGetBuffer(ptr, i64, ptr)

declare ptr @NdrNsGetBuffer(ptr, i64, ptr)

declare ptr @NdrSendReceive(ptr, ptr)

declare ptr @NdrNsSendReceive(ptr, ptr, ptr)

declare void @NdrFreeBuffer(ptr)

declare i64 @NdrGetDcomProtocolVersion(ptr, ptr)

declare i64 @NdrClientCall2(ptr, ptr)

declare i64 @NdrClientCall(ptr, ptr)

declare i64 @NdrAsyncClientCall(ptr, ptr)

declare i64 @NdrDcomAsyncClientCall(ptr, ptr)

declare void @NdrAsyncServerCall(ptr)

declare i64 @NdrAsyncStubCall(ptr, ptr, ptr, ptr)

declare i64 @NdrDcomAsyncStubCall(ptr, ptr, ptr, ptr)

declare i64 @NdrStubCall2(ptr, ptr, ptr, ptr)

declare void @NdrServerCall2(ptr)

declare i64 @NdrStubCall(ptr, ptr, ptr, ptr)

declare void @NdrServerCall(ptr)

declare i32 @NdrServerUnmarshall(ptr, ptr, ptr, ptr, ptr, ptr)

declare void @NdrServerMarshall(ptr, ptr, ptr, ptr)

declare i64 @NdrMapCommAndFaultStatus(ptr, ptr, ptr, i64)

declare ptr @RpcSsAllocate(i64)

declare void @RpcSsDisableAllocate()

declare void @RpcSsEnableAllocate()

declare void @RpcSsFree(ptr)

declare ptr @RpcSsGetThreadHandle()

declare void @RpcSsSetClientAllocFree(ptr, ptr)

declare void @RpcSsSetThreadHandle(ptr)

declare void @RpcSsSwapClientAllocFree(ptr, ptr, ptr, ptr)

declare ptr @RpcSmAllocate(i64, ptr)

declare i64 @RpcSmClientFree(ptr)

declare i64 @RpcSmDestroyClientContext(ptr)

declare i64 @RpcSmDisableAllocate()

declare i64 @RpcSmEnableAllocate()

declare i64 @RpcSmFree(ptr)

declare ptr @RpcSmGetThreadHandle(ptr)

declare i64 @RpcSmSetClientAllocFree(ptr, ptr)

declare i64 @RpcSmSetThreadHandle(ptr)

declare i64 @RpcSmSwapClientAllocFree(ptr, ptr, ptr, ptr)

declare void @NdrRpcSsEnableAllocate(ptr)

declare void @NdrRpcSsDisableAllocate(ptr)

declare void @NdrRpcSmSetClientToOsf(ptr)

declare ptr @NdrRpcSmClientAllocate(i64)

declare void @NdrRpcSmClientFree(ptr)

declare ptr @NdrRpcSsDefaultAllocate(i64)

declare void @NdrRpcSsDefaultFree(ptr)

declare ptr @NdrFullPointerXlatInit(i64, i64)

declare void @NdrFullPointerXlatFree(ptr)

declare ptr @NdrAllocate(ptr, i64)

declare void @NdrClearOutParameters(ptr, ptr, ptr)

declare ptr @NdrOleAllocate(i64)

declare void @NdrOleFree(ptr)

declare i64 @NdrGetUserMarshalInfo(ptr, i64, ptr)

declare i64 @NdrCreateServerInterfaceFromStub(ptr, ptr)

declare i64 @NdrClientCall3(ptr, i64, ptr)

declare i64 @Ndr64AsyncClientCall(ptr, i64, ptr)

declare i64 @Ndr64DcomAsyncClientCall(ptr, i64, ptr)

declare void @Ndr64AsyncServerCall(ptr)

declare void @Ndr64AsyncServerCall64(ptr)

declare void @Ndr64AsyncServerCallAll(ptr)

declare i64 @Ndr64AsyncStubCall(ptr, ptr, ptr, ptr)

declare i64 @Ndr64DcomAsyncStubCall(ptr, ptr, ptr, ptr)

declare i64 @NdrStubCall3(ptr, ptr, ptr, ptr)

declare void @NdrServerCallAll(ptr)

declare void @NdrServerCallNdr64(ptr)

declare void @NdrServerCall3(ptr)

declare void @NdrPartialIgnoreClientMarshall(ptr, ptr)

declare void @NdrPartialIgnoreServerUnmarshall(ptr, ptr)

declare void @NdrPartialIgnoreClientBufferSize(ptr, ptr)

declare void @NdrPartialIgnoreServerInitialize(ptr, ptr, ptr)

declare void @RpcUserFree(ptr, ptr)

declare ptr @GetStorageHwCryptoCapability(ptr, i64)

declare ptr @GetStorageHwCryptoCapabilityMut(ptr, i64)

declare ptr @DeviceDsmParameterBlock(ptr)

declare ptr @DeviceDsmDataSetRanges(ptr)

declare i64 @DeviceDsmNumberOfDataSetRanges(ptr)

declare i64 @DeviceDsmGetInputLength(ptr, i64, i64)

declare i64 @DeviceDsmGetNumberOfDataSetRanges(ptr, i64, i64)

declare void @DeviceDsmInitializeInput(ptr, ptr, i64, i64, ptr, i64)

declare i64 @DeviceDsmAddDataSetRange(ptr, i64, i64, i64)

declare i64 @DeviceDsmValidateInput(ptr, ptr, i64)

declare ptr @DeviceDsmOutputBlock(ptr)

declare i64 @DeviceDsmGetOutputLength(ptr, i64)

declare i64 @DeviceDsmValidateOutputLength(ptr, i64)

declare i64 @DeviceDsmGetOutputBlockLength(ptr, i64)

declare void @DeviceDsmInitializeOutput(ptr, ptr, i64, i64)

declare i64 @DeviceDsmValidateOutput(ptr, ptr, i64)

declare i64 @SCardEstablishContext(i64, ptr, ptr, ptr)

declare i64 @SCardReleaseContext(i64)

declare i64 @SCardIsValidContext(i64)

declare i64 @SCardListReaderGroupsA(i64, ptr, ptr)

declare i64 @SCardListReaderGroupsW(i64, ptr, ptr)

declare i64 @SCardListReadersA(i64, ptr, ptr, ptr)

declare i64 @SCardListReadersW(i64, ptr, ptr, ptr)

declare i64 @SCardListCardsA(i64, ptr, ptr, i64, ptr, ptr)

declare i64 @SCardListCardsW(i64, ptr, ptr, i64, ptr, ptr)

declare i64 @SCardListInterfacesA(i64, ptr, ptr, ptr)

declare i64 @SCardListInterfacesW(i64, ptr, ptr, ptr)

declare i64 @SCardGetProviderIdA(i64, ptr, ptr)

declare i64 @SCardGetProviderIdW(i64, ptr, ptr)

declare i64 @SCardGetCardTypeProviderNameA(i64, ptr, i64, ptr, ptr)

declare i64 @SCardGetCardTypeProviderNameW(i64, ptr, i64, ptr, ptr)

declare i64 @SCardIntroduceReaderGroupA(i64, ptr)

declare i64 @SCardIntroduceReaderGroupW(i64, ptr)

declare i64 @SCardForgetReaderGroupA(i64, ptr)

declare i64 @SCardForgetReaderGroupW(i64, ptr)

declare i64 @SCardIntroduceReaderA(i64, ptr, ptr)

declare i64 @SCardIntroduceReaderW(i64, ptr, ptr)

declare i64 @SCardForgetReaderA(i64, ptr)

declare i64 @SCardForgetReaderW(i64, ptr)

declare i64 @SCardAddReaderToGroupA(i64, ptr, ptr)

declare i64 @SCardAddReaderToGroupW(i64, ptr, ptr)

declare i64 @SCardRemoveReaderFromGroupA(i64, ptr, ptr)

declare i64 @SCardRemoveReaderFromGroupW(i64, ptr, ptr)

declare i64 @SCardIntroduceCardTypeA(i64, ptr, ptr, ptr, i64, ptr, ptr, i64)

declare i64 @SCardIntroduceCardTypeW(i64, ptr, ptr, ptr, i64, ptr, ptr, i64)

declare i64 @SCardSetCardTypeProviderNameA(i64, ptr, i64, ptr)

declare i64 @SCardSetCardTypeProviderNameW(i64, ptr, i64, ptr)

declare i64 @SCardForgetCardTypeA(i64, ptr)

declare i64 @SCardForgetCardTypeW(i64, ptr)

declare i64 @SCardFreeMemory(i64, ptr)

declare ptr @SCardAccessStartedEvent()

declare void @SCardReleaseStartedEvent()

declare i64 @SCardLocateCardsA(i64, ptr, ptr, i64)

declare i64 @SCardLocateCardsW(i64, ptr, ptr, i64)

declare i64 @SCardLocateCardsByATRA(i64, ptr, i64, ptr, i64)

declare i64 @SCardLocateCardsByATRW(i64, ptr, i64, ptr, i64)

declare i64 @SCardGetStatusChangeA(i64, i64, ptr, i64)

declare i64 @SCardGetStatusChangeW(i64, i64, ptr, i64)

declare i64 @SCardCancel(i64)

declare i64 @SCardConnectA(i64, ptr, i64, i64, ptr, ptr)

declare i64 @SCardConnectW(i64, ptr, i64, i64, ptr, ptr)

declare i64 @SCardReconnect(i64, i64, i64, i64, ptr)

declare i64 @SCardDisconnect(i64, i64)

declare i64 @SCardBeginTransaction(i64)

declare i64 @SCardEndTransaction(i64, i64)

declare i64 @SCardCancelTransaction(i64)

declare i64 @SCardState(i64, ptr, ptr, ptr, ptr)

declare i64 @SCardStatusA(i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @SCardStatusW(i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @SCardTransmit(i64, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @SCardGetTransmitCount(i64, ptr)

declare i64 @SCardControl(i64, i64, ptr, i64, ptr, i64, ptr)

declare i64 @SCardGetAttrib(i64, i64, ptr, ptr)

declare i64 @SCardSetAttrib(i64, i64, ptr, i64)

declare i64 @SCardUIDlgSelectCardA(ptr)

declare i64 @SCardUIDlgSelectCardW(ptr)

declare i64 @GetOpenCardNameA(ptr)

declare i64 @GetOpenCardNameW(ptr)

declare i64 @SCardDlgExtendedError()

declare i64 @SCardReadCacheA(i64, ptr, i64, ptr, ptr, ptr)

declare i64 @SCardReadCacheW(i64, ptr, i64, ptr, ptr, ptr)

declare i64 @SCardWriteCacheA(i64, ptr, i64, ptr, ptr, i64)

declare i64 @SCardWriteCacheW(i64, ptr, i64, ptr, ptr, i64)

declare i64 @SCardGetReaderIconA(i64, ptr, ptr, ptr)

declare i64 @SCardGetReaderIconW(i64, ptr, ptr, ptr)

declare i64 @SCardGetDeviceTypeIdA(i64, ptr, ptr)

declare i64 @SCardGetDeviceTypeIdW(i64, ptr, ptr)

declare i64 @SCardGetReaderDeviceInstanceIdA(i64, ptr, ptr, ptr)

declare i64 @SCardGetReaderDeviceInstanceIdW(i64, ptr, ptr, ptr)

declare i64 @SCardListReadersWithDeviceInstanceIdA(i64, ptr, ptr, ptr)

declare i64 @SCardListReadersWithDeviceInstanceIdW(i64, ptr, ptr, ptr)

declare i64 @SCardAudit(i64, i64)

declare ptr @CreatePropertySheetPageA(ptr)

declare ptr @CreatePropertySheetPageW(ptr)

declare i32 @DestroyPropertySheetPage(ptr)

declare i64 @PropertySheetA(ptr)

declare i64 @PropertySheetW(ptr)

declare i32 @EnumPrintersA(i64, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumPrintersW(i64, ptr, i64, ptr, i64, ptr, ptr)

declare ptr @GetSpoolFileHandle(ptr)

declare ptr @CommitSpoolData(ptr, ptr, i64)

declare i32 @CloseSpoolFileHandle(ptr, ptr)

declare i32 @OpenPrinterA(ptr, ptr, ptr)

declare i32 @OpenPrinterW(ptr, ptr, ptr)

declare i32 @ResetPrinterA(ptr, ptr)

declare i32 @ResetPrinterW(ptr, ptr)

declare i32 @SetJobA(ptr, i64, i64, ptr, i64)

declare i32 @SetJobW(ptr, i64, i64, ptr, i64)

declare i32 @GetJobA(ptr, i64, i64, ptr, i64, ptr)

declare i32 @GetJobW(ptr, i64, i64, ptr, i64, ptr)

declare i32 @EnumJobsA(ptr, i64, i64, i64, ptr, i64, ptr, ptr)

declare i32 @EnumJobsW(ptr, i64, i64, i64, ptr, i64, ptr, ptr)

declare ptr @AddPrinterA(ptr, i64, ptr)

declare ptr @AddPrinterW(ptr, i64, ptr)

declare i32 @DeletePrinter(ptr)

declare i32 @SetPrinterA(ptr, i64, ptr, i64)

declare i32 @SetPrinterW(ptr, i64, ptr, i64)

declare i32 @GetPrinterA(ptr, i64, ptr, i64, ptr)

declare i32 @GetPrinterW(ptr, i64, ptr, i64, ptr)

declare i32 @AddPrinterDriverA(ptr, i64, ptr)

declare i32 @AddPrinterDriverW(ptr, i64, ptr)

declare i32 @AddPrinterDriverExA(ptr, i64, ptr, i64)

declare i32 @AddPrinterDriverExW(ptr, i64, ptr, i64)

declare i32 @EnumPrinterDriversA(ptr, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumPrinterDriversW(ptr, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @GetPrinterDriverA(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @GetPrinterDriverW(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @GetPrinterDriverDirectoryA(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @GetPrinterDriverDirectoryW(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @DeletePrinterDriverA(ptr, ptr, ptr)

declare i32 @DeletePrinterDriverW(ptr, ptr, ptr)

declare i32 @DeletePrinterDriverExA(ptr, ptr, ptr, i64, i64)

declare i32 @DeletePrinterDriverExW(ptr, ptr, ptr, i64, i64)

declare i32 @AddPrintProcessorA(ptr, ptr, ptr, ptr)

declare i32 @AddPrintProcessorW(ptr, ptr, ptr, ptr)

declare i32 @EnumPrintProcessorsA(ptr, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumPrintProcessorsW(ptr, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @GetPrintProcessorDirectoryA(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @GetPrintProcessorDirectoryW(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @EnumPrintProcessorDatatypesA(ptr, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumPrintProcessorDatatypesW(ptr, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @DeletePrintProcessorA(ptr, ptr, ptr)

declare i32 @DeletePrintProcessorW(ptr, ptr, ptr)

declare i64 @StartDocPrinterA(ptr, i64, ptr)

declare i64 @StartDocPrinterW(ptr, i64, ptr)

declare i32 @StartPagePrinter(ptr)

declare i32 @WritePrinter(ptr, ptr, i64, ptr)

declare i32 @FlushPrinter(ptr, ptr, i64, ptr, i64)

declare i32 @EndPagePrinter(ptr)

declare i32 @AbortPrinter(ptr)

declare i32 @ReadPrinter(ptr, ptr, i64, ptr)

declare i32 @EndDocPrinter(ptr)

declare i32 @AddJobA(ptr, i64, ptr, i64, ptr)

declare i32 @AddJobW(ptr, i64, ptr, i64, ptr)

declare i32 @ScheduleJob(ptr, i64)

declare i32 @PrinterProperties(ptr, ptr)

declare i64 @DocumentPropertiesA(ptr, ptr, ptr, ptr, ptr, i64)

declare i64 @DocumentPropertiesW(ptr, ptr, ptr, ptr, ptr, i64)

declare i64 @AdvancedDocumentPropertiesA(ptr, ptr, ptr, ptr, ptr)

declare i64 @AdvancedDocumentPropertiesW(ptr, ptr, ptr, ptr, ptr)

declare i64 @ExtDeviceMode(ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64)

declare i64 @GetPrinterDataA(ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @GetPrinterDataW(ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @GetPrinterDataExA(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @GetPrinterDataExW(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @EnumPrinterDataA(ptr, i64, ptr, i64, ptr, ptr, ptr, i64, ptr)

declare i64 @EnumPrinterDataW(ptr, i64, ptr, i64, ptr, ptr, ptr, i64, ptr)

declare i64 @EnumPrinterDataExA(ptr, ptr, ptr, i64, ptr, ptr)

declare i64 @EnumPrinterDataExW(ptr, ptr, ptr, i64, ptr, ptr)

declare i64 @EnumPrinterKeyA(ptr, ptr, ptr, i64, ptr)

declare i64 @EnumPrinterKeyW(ptr, ptr, ptr, i64, ptr)

declare i64 @SetPrinterDataA(ptr, ptr, i64, ptr, i64)

declare i64 @SetPrinterDataW(ptr, ptr, i64, ptr, i64)

declare i64 @SetPrinterDataExA(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @SetPrinterDataExW(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @DeletePrinterDataA(ptr, ptr)

declare i64 @DeletePrinterDataW(ptr, ptr)

declare i64 @DeletePrinterDataExA(ptr, ptr, ptr)

declare i64 @DeletePrinterDataExW(ptr, ptr, ptr)

declare i64 @DeletePrinterKeyA(ptr, ptr)

declare i64 @DeletePrinterKeyW(ptr, ptr)

declare i64 @WaitForPrinterChange(ptr, i64)

declare ptr @FindFirstPrinterChangeNotification(ptr, i64, i64, ptr)

declare i32 @FindNextPrinterChangeNotification(ptr, ptr, ptr, ptr)

declare i32 @FreePrinterNotifyInfo(ptr)

declare i32 @FindClosePrinterChangeNotification(ptr)

declare i64 @PrinterMessageBoxA(ptr, i64, ptr, ptr, ptr, i64)

declare i64 @PrinterMessageBoxW(ptr, i64, ptr, ptr, ptr, i64)

declare i32 @ClosePrinter(ptr)

declare i32 @AddFormA(ptr, i64, ptr)

declare i32 @AddFormW(ptr, i64, ptr)

declare i32 @DeleteFormA(ptr, ptr)

declare i32 @DeleteFormW(ptr, ptr)

declare i32 @GetFormA(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @GetFormW(ptr, ptr, i64, ptr, i64, ptr)

declare i32 @SetFormA(ptr, ptr, i64, ptr)

declare i32 @SetFormW(ptr, ptr, i64, ptr)

declare i32 @EnumFormsA(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumFormsW(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumMonitorsA(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumMonitorsW(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @AddMonitorA(ptr, i64, ptr)

declare i32 @AddMonitorW(ptr, i64, ptr)

declare i32 @DeleteMonitorA(ptr, ptr, ptr)

declare i32 @DeleteMonitorW(ptr, ptr, ptr)

declare i32 @EnumPortsA(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumPortsW(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @AddPortA(ptr, ptr, ptr)

declare i32 @AddPortW(ptr, ptr, ptr)

declare i32 @ConfigurePortA(ptr, ptr, ptr)

declare i32 @ConfigurePortW(ptr, ptr, ptr)

declare i32 @DeletePortA(ptr, ptr, ptr)

declare i32 @DeletePortW(ptr, ptr, ptr)

declare i32 @XcvDataW(ptr, ptr, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @GetDefaultPrinterA(ptr, ptr)

declare i32 @GetDefaultPrinterW(ptr, ptr)

declare i32 @SetDefaultPrinterA(ptr)

declare i32 @SetDefaultPrinterW(ptr)

declare i32 @SetPortA(ptr, ptr, i64, ptr)

declare i32 @SetPortW(ptr, ptr, i64, ptr)

declare i32 @AddPrinterConnectionA(ptr)

declare i32 @AddPrinterConnectionW(ptr)

declare i32 @DeletePrinterConnectionA(ptr)

declare i32 @DeletePrinterConnectionW(ptr)

declare ptr @ConnectToPrinterDlg(ptr, i64)

declare i32 @AddPrintProvidorA(ptr, i64, ptr)

declare i32 @AddPrintProvidorW(ptr, i64, ptr)

declare i32 @DeletePrintProvidorA(ptr, ptr, ptr)

declare i32 @DeletePrintProvidorW(ptr, ptr, ptr)

declare i32 @IsValidDevmodeA(ptr, i64)

declare i32 @IsValidDevmodeW(ptr, i64)

declare i32 @OpenPrinter2A(ptr, ptr, ptr, ptr)

declare i32 @OpenPrinter2W(ptr, ptr, ptr, ptr)

declare i32 @AddPrinterConnection2A(ptr, ptr, i64, ptr)

declare i32 @AddPrinterConnection2W(ptr, ptr, i64, ptr)

declare i64 @InstallPrinterDriverFromPackageA(ptr, ptr, ptr, ptr, i64)

declare i64 @InstallPrinterDriverFromPackageW(ptr, ptr, ptr, ptr, i64)

declare i64 @UploadPrinterDriverPackageA(ptr, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @UploadPrinterDriverPackageW(ptr, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @GetCorePrinterDriversA(ptr, ptr, ptr, i64, ptr)

declare i64 @GetCorePrinterDriversW(ptr, ptr, ptr, i64, ptr)

declare i64 @CorePrinterDriverInstalledA(ptr, ptr, i64, i64, i64, ptr)

declare i64 @CorePrinterDriverInstalledW(ptr, ptr, i64, i64, i64, ptr)

declare i64 @GetPrinterDriverPackagePathA(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @GetPrinterDriverPackagePathW(ptr, ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @DeletePrinterDriverPackageA(ptr, ptr, ptr)

declare i64 @DeletePrinterDriverPackageW(ptr, ptr, ptr)

declare i64 @ReportJobProcessingProgress(ptr, i64, i64, i64)

declare i32 @GetPrinterDriver2A(ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i32 @GetPrinterDriver2W(ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i32 @GetPrintExecutionData(ptr)

declare i64 @GetJobNamedPropertyValue(ptr, i64, ptr, ptr)

declare void @FreePrintPropertyValue(ptr)

declare void @FreePrintNamedPropertyArray(i64, ptr)

declare i64 @SetJobNamedProperty(ptr, i64, ptr)

declare i64 @DeleteJobNamedProperty(ptr, i64, ptr)

declare i64 @EnumJobNamedProperties(ptr, i64, ptr, ptr)

declare i64 @GetPrintOutputInfo(ptr, ptr, ptr, ptr)

declare ptr @_calloc_base(i64, i64)

declare ptr @calloc(i64, i64)

declare i32 @_callnewh(i64)

declare ptr @_expand(ptr, i64)

declare void @_free_base(ptr)

declare ptr @_malloc_base(i64)

declare i64 @_msize_base(ptr)

declare i64 @_msize(ptr)

declare ptr @_realloc_base(ptr, i64)

declare ptr @_recalloc_base(ptr, i64, i64)

declare ptr @_recalloc(ptr, i64, i64)

declare void @_aligned_free(ptr)

declare ptr @_aligned_malloc(i64, i64)

declare ptr @_aligned_offset_malloc(i64, i64, i64)

declare i64 @_aligned_msize(ptr, i64, i64)

declare ptr @_aligned_offset_realloc(ptr, i64, i64, i64)

declare ptr @_aligned_offset_recalloc(ptr, i64, i64, i64, i64)

declare ptr @_aligned_realloc(ptr, i64, i64)

declare ptr @_aligned_recalloc(ptr, i64, i64, i64)

declare i64 @__threadid()

declare i64 @__threadhandle()

declare ptr @bsearch_s(ptr, ptr, i64, i64, ptr, ptr)

declare void @qsort_s(ptr, i64, i64, ptr, ptr)

declare ptr @bsearch(ptr, ptr, i64, i64, ptr)

declare void @qsort(ptr, i64, i64, ptr)

declare ptr @_lfind_s(ptr, ptr, ptr, i64, ptr, ptr)

declare ptr @_lfind(ptr, ptr, ptr, i64, ptr)

declare ptr @_lsearch_s(ptr, ptr, ptr, i64, ptr, ptr)

declare ptr @_lsearch(ptr, ptr, ptr, i64, ptr)

declare ptr @lfind(ptr, ptr, ptr, i64, ptr)

declare ptr @lsearch(ptr, ptr, ptr, i64, ptr)

declare i32 @_itow_s(i32, ptr, i64, i32)

declare ptr @_itow(i32, ptr, i32)

declare i32 @_ltow_s(i64, ptr, i64, i32)

declare ptr @_ltow(i64, ptr, i32)

declare i32 @_ultow_s(i64, ptr, i64, i32)

declare ptr @_ultow(i64, ptr, i32)

declare double @wcstod(ptr, ptr)

declare double @_wcstod_l(ptr, ptr, ptr)

declare i64 @wcstol(ptr, ptr, i32)

declare i64 @_wcstol_l(ptr, ptr, i32, ptr)

declare i64 @wcstoll(ptr, ptr, i32)

declare i64 @_wcstoll_l(ptr, ptr, i32, ptr)

declare i64 @wcstoul(ptr, ptr, i32)

declare i64 @_wcstoul_l(ptr, ptr, i32, ptr)

declare i64 @wcstoull(ptr, ptr, i32)

declare i64 @_wcstoull_l(ptr, ptr, i32, ptr)

declare i64 @wcstold(ptr, ptr)

declare i64 @_wcstold_l(ptr, ptr, ptr)

declare float @wcstof(ptr, ptr)

declare float @_wcstof_l(ptr, ptr, ptr)

declare double @_wtof(ptr)

declare double @_wtof_l(ptr, ptr)

declare i32 @_wtoi(ptr)

declare i32 @_wtoi_l(ptr, ptr)

declare i64 @_wtol(ptr)

declare i64 @_wtol_l(ptr, ptr)

declare i64 @_wtoll(ptr)

declare i64 @_wtoll_l(ptr, ptr)

declare i32 @_i64tow_s(i64, ptr, i64, i32)

declare ptr @_i64tow(i64, ptr, i32)

declare i32 @_ui64tow_s(i64, ptr, i64, i32)

declare ptr @_ui64tow(i64, ptr, i32)

declare i64 @_wtoi64(ptr)

declare i64 @_wtoi64_l(ptr, ptr)

declare i64 @_wcstoi64(ptr, ptr, i32)

declare i64 @_wcstoi64_l(ptr, ptr, i32, ptr)

declare i64 @_wcstoui64(ptr, ptr, i32)

declare i64 @_wcstoui64_l(ptr, ptr, i32, ptr)

declare ptr @_wfullpath(ptr, ptr, i64)

declare i32 @_wmakepath_s(ptr, i64, ptr, ptr, ptr, ptr)

declare void @_wmakepath(ptr, ptr, ptr, ptr, ptr)

declare void @_wperror(ptr)

declare void @_wsplitpath(ptr, ptr, ptr, ptr, ptr)

declare i32 @_wsplitpath_s(ptr, ptr, i64, ptr, i64, ptr, i64, ptr, i64)

declare i32 @_wdupenv_s(ptr, ptr, ptr)

declare ptr @_wgetenv(ptr)

declare i32 @_wgetenv_s(ptr, ptr, i64, ptr)

declare i32 @_wputenv(ptr)

declare i32 @_wputenv_s(ptr, ptr)

declare i32 @_wsearchenv_s(ptr, ptr, ptr, i64)

declare void @_wsearchenv(ptr, ptr, ptr)

declare i32 @_wsystem(ptr)

declare void @_swab(ptr, ptr, i32)

declare void @_exit(i32)

declare void @_Exit(i32)

declare void @quick_exit(i32)

declare i64 @_set_abort_behavior(i64, i64)

declare i32 @atexit(ptr)

declare ptr @_onexit(ptr)

declare i32 @at_quick_exit(ptr)

declare ptr @_set_purecall_handler(ptr)

declare ptr @_get_purecall_handler()

declare ptr @_set_invalid_parameter_handler(ptr)

declare ptr @_get_invalid_parameter_handler()

declare ptr @_set_thread_local_invalid_parameter_handler(ptr)

declare ptr @_get_thread_local_invalid_parameter_handler()

declare i32 @_set_error_mode(i32)

declare ptr @__sys_errlist()

declare ptr @__sys_nerr()

declare void @perror(ptr)

declare ptr @__p__pgmptr()

declare ptr @__p__wpgmptr()

declare ptr @__p__fmode()

declare i32 @_get_pgmptr(ptr)

declare i32 @_get_wpgmptr(ptr)

declare i32 @_set_fmode(i32)

declare i32 @_get_fmode(ptr)

declare i32 @abs(i32)

declare i64 @labs(i64)

declare i64 @llabs(i64)

declare i64 @_abs64(i64)

declare i64 @_byteswap_ushort(i64)

declare i64 @_byteswap_ulong(i64)

declare i64 @_byteswap_uint64(i64)

declare i64 @div(i32, i32)

declare i64 @ldiv(i64, i64)

declare i64 @lldiv(i64, i64)

declare i64 @_lrotl(i64, i32)

declare i64 @_lrotr(i64, i32)

declare void @srand(i64)

declare i32 @rand()

declare double @atof(ptr)

declare i32 @atoi(ptr)

declare i64 @atol(ptr)

declare i64 @atoll(ptr)

declare i64 @_atoi64(ptr)

declare double @_atof_l(ptr, ptr)

declare i32 @_atoi_l(ptr, ptr)

declare i64 @_atol_l(ptr, ptr)

declare i64 @_atoll_l(ptr, ptr)

declare i64 @_atoi64_l(ptr, ptr)

declare i32 @_atoflt(ptr, ptr)

declare i32 @_atodbl(ptr, ptr)

declare i32 @_atoldbl(ptr, ptr)

declare i32 @_atoflt_l(ptr, ptr, ptr)

declare i32 @_atodbl_l(ptr, ptr, ptr)

declare i32 @_atoldbl_l(ptr, ptr, ptr)

declare float @strtof(ptr, ptr)

declare float @_strtof_l(ptr, ptr, ptr)

declare double @strtod(ptr, ptr)

declare double @_strtod_l(ptr, ptr, ptr)

declare i64 @strtold(ptr, ptr)

declare i64 @_strtold_l(ptr, ptr, ptr)

declare i64 @strtol(ptr, ptr, i32)

declare i64 @_strtol_l(ptr, ptr, i32, ptr)

declare i64 @strtoll(ptr, ptr, i32)

declare i64 @_strtoll_l(ptr, ptr, i32, ptr)

declare i64 @strtoul(ptr, ptr, i32)

declare i64 @_strtoul_l(ptr, ptr, i32, ptr)

declare i64 @strtoull(ptr, ptr, i32)

declare i64 @_strtoull_l(ptr, ptr, i32, ptr)

declare i64 @_strtoi64(ptr, ptr, i32)

declare i64 @_strtoi64_l(ptr, ptr, i32, ptr)

declare i64 @_strtoui64(ptr, ptr, i32)

declare i64 @_strtoui64_l(ptr, ptr, i32, ptr)

declare i32 @_itoa_s(i32, ptr, i64, i32)

declare ptr @_itoa(i32, ptr, i32)

declare i32 @_ltoa_s(i64, ptr, i64, i32)

declare ptr @_ltoa(i64, ptr, i32)

declare i32 @_ultoa_s(i64, ptr, i64, i32)

declare ptr @_ultoa(i64, ptr, i32)

declare i32 @_i64toa_s(i64, ptr, i64, i32)

declare ptr @_i64toa(i64, ptr, i32)

declare i32 @_ui64toa_s(i64, ptr, i64, i32)

declare ptr @_ui64toa(i64, ptr, i32)

declare i32 @_ecvt_s(ptr, i64, double, i32, ptr, ptr)

declare ptr @_ecvt(double, i32, ptr, ptr)

declare i32 @_fcvt_s(ptr, i64, double, i32, ptr, ptr)

declare ptr @_fcvt(double, i32, ptr, ptr)

declare i32 @_gcvt_s(ptr, i64, double, i32)

declare ptr @_gcvt(double, i32, ptr)

declare i32 @mblen(ptr, i64)

declare i32 @_mblen_l(ptr, i64, ptr)

declare i64 @_mbstrlen(ptr)

declare i64 @_mbstrlen_l(ptr, ptr)

declare i64 @_mbstrnlen(ptr, i64)

declare i64 @_mbstrnlen_l(ptr, i64, ptr)

declare i32 @mbtowc(ptr, ptr, i64)

declare i32 @_mbtowc_l(ptr, ptr, i64, ptr)

declare i32 @mbstowcs_s(ptr, ptr, i64, ptr, i64)

declare i64 @mbstowcs(ptr, ptr, i64)

declare i32 @_mbstowcs_s_l(ptr, ptr, i64, ptr, i64, ptr)

declare i64 @_mbstowcs_l(ptr, ptr, i64, ptr)

declare i32 @wctomb(ptr, i64)

declare i32 @_wctomb_l(ptr, i64, ptr)

declare i32 @wctomb_s(ptr, ptr, i64, i64)

declare i32 @_wctomb_s_l(ptr, ptr, i64, i64, ptr)

declare i32 @wcstombs_s(ptr, ptr, i64, ptr, i64)

declare i64 @wcstombs(ptr, ptr, i64)

declare i32 @_wcstombs_s_l(ptr, ptr, i64, ptr, i64, ptr)

declare i64 @_wcstombs_l(ptr, ptr, i64, ptr)

declare ptr @_fullpath(ptr, ptr, i64)

declare i32 @_makepath_s(ptr, i64, ptr, ptr, ptr, ptr)

declare void @_makepath(ptr, ptr, ptr, ptr, ptr)

declare void @_splitpath(ptr, ptr, ptr, ptr, ptr)

declare i32 @_splitpath_s(ptr, ptr, i64, ptr, i64, ptr, i64, ptr, i64)

declare i32 @getenv_s(ptr, ptr, i64, ptr)

declare ptr @__p___argc()

declare ptr @__p___argv()

declare ptr @__p___wargv()

declare ptr @__p__environ()

declare ptr @__p__wenviron()

declare ptr @getenv(ptr)

declare i32 @_dupenv_s(ptr, ptr, ptr)

declare i32 @system(ptr)

declare i32 @_putenv(ptr)

declare i32 @_putenv_s(ptr, ptr)

declare i32 @_searchenv_s(ptr, ptr, ptr, i64)

declare void @_searchenv(ptr, ptr, ptr)

declare void @_seterrormode(i32)

declare void @_beep(i64, i64)

declare void @_sleep(i64)

declare ptr @ecvt(double, i32, ptr, ptr)

declare ptr @fcvt(double, i32, ptr, ptr)

declare ptr @gcvt(double, i32, ptr)

declare ptr @itoa(i32, ptr, i32)

declare ptr @ltoa(i64, ptr, i32)

declare void @swab(ptr, ptr, i32)

declare ptr @ultoa(i64, ptr, i32)

declare i32 @putenv(ptr)

declare ptr @onexit(ptr)

declare i64 @IUnknown_QueryInterface_Proxy(ptr, ptr, ptr)

declare void @IUnknown_QueryInterface_Stub(ptr, ptr, ptr, ptr)

declare i64 @IUnknown_AddRef_Proxy(ptr)

declare void @IUnknown_AddRef_Stub(ptr, ptr, ptr, ptr)

declare i64 @IUnknown_Release_Proxy(ptr)

declare void @IUnknown_Release_Stub(ptr, ptr, ptr, ptr)

declare i64 @IClassFactory_RemoteCreateInstance_Proxy(ptr, ptr, ptr)

declare void @IClassFactory_RemoteCreateInstance_Stub(ptr, ptr, ptr, ptr)

declare i64 @IClassFactory_RemoteLockServer_Proxy(ptr, i32)

declare void @IClassFactory_RemoteLockServer_Stub(ptr, ptr, ptr, ptr)

declare i64 @IClassFactory_CreateInstance_Proxy(ptr, ptr, ptr, ptr)

declare i64 @IClassFactory_CreateInstance_Stub(ptr, ptr, ptr)

declare i64 @IClassFactory_LockServer_Proxy(ptr, i32)

declare i64 @IClassFactory_LockServer_Stub(ptr, i32)

declare i64 @IEnumUnknown_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumUnknown_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumString_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumString_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @ISequentialStream_RemoteRead_Proxy(ptr, ptr, i64, ptr)

declare void @ISequentialStream_RemoteRead_Stub(ptr, ptr, ptr, ptr)

declare i64 @ISequentialStream_RemoteWrite_Proxy(ptr, ptr, i64, ptr)

declare void @ISequentialStream_RemoteWrite_Stub(ptr, ptr, ptr, ptr)

declare i64 @IStream_RemoteSeek_Proxy(ptr, i64, i64, ptr)

declare void @IStream_RemoteSeek_Stub(ptr, ptr, ptr, ptr)

declare i64 @IStream_RemoteCopyTo_Proxy(ptr, ptr, i64, ptr, ptr)

declare void @IStream_RemoteCopyTo_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumUnknown_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumUnknown_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @IEnumString_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumString_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @ISequentialStream_Read_Proxy(ptr, ptr, i64, ptr)

declare i64 @ISequentialStream_Read_Stub(ptr, ptr, i64, ptr)

declare i64 @ISequentialStream_Write_Proxy(ptr, ptr, i64, ptr)

declare i64 @ISequentialStream_Write_Stub(ptr, ptr, i64, ptr)

declare i64 @IStream_Seek_Proxy(ptr, i64, i64, ptr)

declare i64 @IStream_Seek_Stub(ptr, i64, i64, ptr)

declare i64 @IStream_CopyTo_Proxy(ptr, ptr, i64, ptr, ptr)

declare i64 @IStream_CopyTo_Stub(ptr, ptr, i64, ptr, ptr)

declare i64 @CoGetMalloc(i64, ptr)

declare i64 @CreateStreamOnHGlobal(ptr, i32, ptr)

declare i64 @GetHGlobalFromStream(ptr, ptr)

declare void @CoUninitialize()

declare i64 @CoGetCurrentProcess()

declare i64 @CoInitializeEx(ptr, i64)

declare i64 @CoGetCallerTID(ptr)

declare i64 @CoGetCurrentLogicalThreadId(ptr)

declare i64 @CoGetContextToken(ptr)

declare i64 @CoGetDefaultContext(i64, ptr, ptr)

declare i64 @CoGetApartmentType(ptr, ptr)

declare i64 @CoDecodeProxy(i64, i64, ptr)

declare i64 @CoIncrementMTAUsage(ptr)

declare i64 @CoDecrementMTAUsage(ptr)

declare i64 @CoAllowUnmarshalerCLSID(ptr)

declare i64 @CoGetObjectContext(ptr, ptr)

declare i64 @CoGetClassObject(ptr, i64, ptr, ptr, ptr)

declare i64 @CoRegisterClassObject(ptr, ptr, i64, i64, ptr)

declare i64 @CoRevokeClassObject(i64)

declare i64 @CoResumeClassObjects()

declare i64 @CoSuspendClassObjects()

declare i64 @CoAddRefServerProcess()

declare i64 @CoReleaseServerProcess()

declare i64 @CoGetPSClsid(ptr, ptr)

declare i64 @CoRegisterPSClsid(ptr, ptr)

declare i64 @CoRegisterSurrogate(ptr)

declare i64 @CoGetMarshalSizeMax(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @CoMarshalInterface(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @CoUnmarshalInterface(ptr, ptr, ptr)

declare i64 @CoMarshalHresult(ptr, i64)

declare i64 @CoUnmarshalHresult(ptr, ptr)

declare i64 @CoReleaseMarshalData(ptr)

declare i64 @CoDisconnectObject(ptr, i64)

declare i64 @CoLockObjectExternal(ptr, i32, i32)

declare i64 @CoGetStandardMarshal(ptr, ptr, i64, ptr, i64, ptr)

declare i64 @CoGetStdMarshalEx(ptr, i64, ptr)

declare i32 @CoIsHandlerConnected(ptr)

declare i64 @CoMarshalInterThreadInterfaceInStream(ptr, ptr, ptr)

declare i64 @CoGetInterfaceAndReleaseStream(ptr, ptr, ptr)

declare i64 @CoCreateFreeThreadedMarshaler(ptr, ptr)

declare void @CoFreeUnusedLibraries()

declare void @CoFreeUnusedLibrariesEx(i64, i64)

declare i64 @CoDisconnectContext(i64)

declare i64 @CoInitializeSecurity(ptr, i64, ptr, ptr, i64, i64, ptr, i64, ptr)

declare i64 @CoGetCallContext(ptr, ptr)

declare i64 @CoQueryProxyBlanket(ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @CoSetProxyBlanket(ptr, i64, i64, ptr, i64, i64, ptr, i64)

declare i64 @CoCopyProxy(ptr, ptr)

declare i64 @CoQueryClientBlanket(ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @CoImpersonateClient()

declare i64 @CoRevertToSelf()

declare i64 @CoQueryAuthenticationServices(ptr, ptr)

declare i64 @CoSwitchCallContext(ptr, ptr)

declare i64 @CoCreateInstance(ptr, ptr, i64, ptr, ptr)

declare i64 @CoCreateInstanceEx(ptr, ptr, i64, ptr, i64, ptr)

declare i64 @CoCreateInstanceFromApp(ptr, ptr, i64, ptr, i64, ptr)

declare i64 @CoRegisterActivationFilter(ptr)

declare i64 @CoGetCancelObject(i64, ptr, ptr)

declare i64 @CoSetCancelObject(ptr)

declare i64 @CoCancelCall(i64, i64)

declare i64 @CoTestCancel()

declare i64 @CoEnableCallCancellation(ptr)

declare i64 @CoDisableCallCancellation(ptr)

declare i64 @StringFromCLSID(ptr, ptr)

declare i64 @CLSIDFromString(ptr, ptr)

declare i64 @StringFromIID(ptr, ptr)

declare i64 @IIDFromString(ptr, ptr)

declare i64 @ProgIDFromCLSID(ptr, ptr)

declare i64 @CLSIDFromProgID(ptr, ptr)

declare i32 @StringFromGUID2(ptr, ptr, i32)

declare i64 @CoCreateGuid(ptr)

declare i64 @PropVariantCopy(ptr, ptr)

declare i64 @PropVariantClear(ptr)

declare i64 @FreePropVariantArray(i64, ptr)

declare i64 @CoWaitForMultipleHandles(i64, i64, i64, ptr, ptr)

declare i64 @CoWaitForMultipleObjects(i64, i64, i64, ptr, ptr)

declare i64 @CoGetTreatAsClass(ptr, ptr)

declare i64 @CoInvalidateRemoteMachineBindings(ptr)

declare i64 @RoGetAgileReference(i64, ptr, ptr, ptr)

declare i64 @DllGetClassObject(ptr, ptr, ptr)

declare i64 @DllCanUnloadNow()

declare ptr @CoTaskMemAlloc(i64)

declare ptr @CoTaskMemRealloc(ptr, i64)

declare void @CoTaskMemFree(ptr)

declare i64 @CoFileTimeNow(ptr)

declare i64 @CLSIDFromProgIDEx(ptr, ptr)

declare i64 @CoRegisterDeviceCatalog(ptr, ptr)

declare i64 @CoRevokeDeviceCatalog(ptr)

declare i64 @IBindCtx_RemoteSetBindOptions_Proxy(ptr, ptr)

declare void @IBindCtx_RemoteSetBindOptions_Stub(ptr, ptr, ptr, ptr)

declare i64 @IBindCtx_RemoteGetBindOptions_Proxy(ptr, ptr)

declare void @IBindCtx_RemoteGetBindOptions_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumMoniker_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumMoniker_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @IRunnableObject_RemoteIsRunning_Proxy(ptr)

declare void @IRunnableObject_RemoteIsRunning_Stub(ptr, ptr, ptr, ptr)

declare i64 @IMoniker_RemoteBindToObject_Proxy(ptr, ptr, ptr, ptr, ptr)

declare void @IMoniker_RemoteBindToObject_Stub(ptr, ptr, ptr, ptr)

declare i64 @IMoniker_RemoteBindToStorage_Proxy(ptr, ptr, ptr, ptr, ptr)

declare void @IMoniker_RemoteBindToStorage_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumSTATSTG_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumSTATSTG_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @IStorage_RemoteOpenStream_Proxy(ptr, ptr, i64, ptr, i64, i64, ptr)

declare void @IStorage_RemoteOpenStream_Stub(ptr, ptr, ptr, ptr)

declare i64 @IStorage_RemoteCopyTo_Proxy(ptr, i64, ptr, ptr, ptr)

declare void @IStorage_RemoteCopyTo_Stub(ptr, ptr, ptr, ptr)

declare i64 @IStorage_RemoteEnumElements_Proxy(ptr, i64, i64, ptr, i64, ptr)

declare void @IStorage_RemoteEnumElements_Stub(ptr, ptr, ptr, ptr)

declare i64 @ILockBytes_RemoteReadAt_Proxy(ptr, i64, ptr, i64, ptr)

declare void @ILockBytes_RemoteReadAt_Stub(ptr, ptr, ptr, ptr)

declare i64 @ILockBytes_RemoteWriteAt_Proxy(ptr, i64, ptr, i64, ptr)

declare void @ILockBytes_RemoteWriteAt_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumFORMATETC_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumFORMATETC_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumSTATDATA_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumSTATDATA_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @IAdviseSink_RemoteOnDataChange_Proxy(ptr, ptr, ptr)

declare void @IAdviseSink_RemoteOnDataChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @IAdviseSink_RemoteOnViewChange_Proxy(ptr, i64, i64)

declare void @IAdviseSink_RemoteOnViewChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @IAdviseSink_RemoteOnRename_Proxy(ptr, ptr)

declare void @IAdviseSink_RemoteOnRename_Stub(ptr, ptr, ptr, ptr)

declare i64 @IAdviseSink_RemoteOnSave_Proxy(ptr)

declare void @IAdviseSink_RemoteOnSave_Stub(ptr, ptr, ptr, ptr)

declare i64 @IAdviseSink_RemoteOnClose_Proxy(ptr)

declare void @IAdviseSink_RemoteOnClose_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Begin_RemoteOnDataChange_Proxy(ptr, ptr, ptr)

declare void @AsyncIAdviseSink_Begin_RemoteOnDataChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Finish_RemoteOnDataChange_Proxy(ptr)

declare void @AsyncIAdviseSink_Finish_RemoteOnDataChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Begin_RemoteOnViewChange_Proxy(ptr, i64, i64)

declare void @AsyncIAdviseSink_Begin_RemoteOnViewChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Finish_RemoteOnViewChange_Proxy(ptr)

declare void @AsyncIAdviseSink_Finish_RemoteOnViewChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Begin_RemoteOnRename_Proxy(ptr, ptr)

declare void @AsyncIAdviseSink_Begin_RemoteOnRename_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Finish_RemoteOnRename_Proxy(ptr)

declare void @AsyncIAdviseSink_Finish_RemoteOnRename_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Begin_RemoteOnSave_Proxy(ptr)

declare void @AsyncIAdviseSink_Begin_RemoteOnSave_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Finish_RemoteOnSave_Proxy(ptr)

declare void @AsyncIAdviseSink_Finish_RemoteOnSave_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Begin_RemoteOnClose_Proxy(ptr)

declare void @AsyncIAdviseSink_Begin_RemoteOnClose_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Finish_RemoteOnClose_Proxy(ptr)

declare void @AsyncIAdviseSink_Finish_RemoteOnClose_Stub(ptr, ptr, ptr, ptr)

declare i64 @IAdviseSink2_RemoteOnLinkSrcChange_Proxy(ptr, ptr)

declare void @IAdviseSink2_RemoteOnLinkSrcChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink2_Begin_RemoteOnLinkSrcChange_Proxy(ptr, ptr)

declare void @AsyncIAdviseSink2_Begin_RemoteOnLinkSrcChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink2_Finish_RemoteOnLinkSrcChange_Proxy(ptr)

declare void @AsyncIAdviseSink2_Finish_RemoteOnLinkSrcChange_Stub(ptr, ptr, ptr, ptr)

declare i64 @IDataObject_RemoteGetData_Proxy(ptr, ptr, ptr)

declare void @IDataObject_RemoteGetData_Stub(ptr, ptr, ptr, ptr)

declare i64 @IDataObject_RemoteGetDataHere_Proxy(ptr, ptr, ptr)

declare void @IDataObject_RemoteGetDataHere_Stub(ptr, ptr, ptr, ptr)

declare i64 @IDataObject_RemoteSetData_Proxy(ptr, ptr, ptr, i32)

declare void @IDataObject_RemoteSetData_Stub(ptr, ptr, ptr, ptr)

declare i64 @IFillLockBytes_RemoteFillAppend_Proxy(ptr, ptr, i64, ptr)

declare void @IFillLockBytes_RemoteFillAppend_Stub(ptr, ptr, ptr, ptr)

declare i64 @IFillLockBytes_RemoteFillAt_Proxy(ptr, i64, ptr, i64, ptr)

declare void @IFillLockBytes_RemoteFillAt_Stub(ptr, ptr, ptr, ptr)

declare i64 @ASYNC_STGMEDIUM_UserSize(ptr, i64, ptr)

declare ptr @ASYNC_STGMEDIUM_UserMarshal(ptr, ptr, ptr)

declare ptr @ASYNC_STGMEDIUM_UserUnmarshal(ptr, ptr, ptr)

declare void @ASYNC_STGMEDIUM_UserFree(ptr, ptr)

declare i64 @CLIPFORMAT_UserSize(ptr, i64, ptr)

declare ptr @CLIPFORMAT_UserMarshal(ptr, ptr, ptr)

declare ptr @CLIPFORMAT_UserUnmarshal(ptr, ptr, ptr)

declare void @CLIPFORMAT_UserFree(ptr, ptr)

declare i64 @FLAG_STGMEDIUM_UserSize(ptr, i64, ptr)

declare ptr @FLAG_STGMEDIUM_UserMarshal(ptr, ptr, ptr)

declare ptr @FLAG_STGMEDIUM_UserUnmarshal(ptr, ptr, ptr)

declare void @FLAG_STGMEDIUM_UserFree(ptr, ptr)

declare i64 @HBITMAP_UserSize(ptr, i64, ptr)

declare ptr @HBITMAP_UserMarshal(ptr, ptr, ptr)

declare ptr @HBITMAP_UserUnmarshal(ptr, ptr, ptr)

declare void @HBITMAP_UserFree(ptr, ptr)

declare i64 @HDC_UserSize(ptr, i64, ptr)

declare ptr @HDC_UserMarshal(ptr, ptr, ptr)

declare ptr @HDC_UserUnmarshal(ptr, ptr, ptr)

declare void @HDC_UserFree(ptr, ptr)

declare i64 @HICON_UserSize(ptr, i64, ptr)

declare ptr @HICON_UserMarshal(ptr, ptr, ptr)

declare ptr @HICON_UserUnmarshal(ptr, ptr, ptr)

declare void @HICON_UserFree(ptr, ptr)

declare i64 @SNB_UserSize(ptr, i64, ptr)

declare ptr @SNB_UserMarshal(ptr, ptr, ptr)

declare ptr @SNB_UserUnmarshal(ptr, ptr, ptr)

declare void @SNB_UserFree(ptr, ptr)

declare i64 @STGMEDIUM_UserSize(ptr, i64, ptr)

declare ptr @STGMEDIUM_UserMarshal(ptr, ptr, ptr)

declare ptr @STGMEDIUM_UserUnmarshal(ptr, ptr, ptr)

declare void @STGMEDIUM_UserFree(ptr, ptr)

declare i64 @ASYNC_STGMEDIUM_UserSize64(ptr, i64, ptr)

declare ptr @ASYNC_STGMEDIUM_UserMarshal64(ptr, ptr, ptr)

declare ptr @ASYNC_STGMEDIUM_UserUnmarshal64(ptr, ptr, ptr)

declare void @ASYNC_STGMEDIUM_UserFree64(ptr, ptr)

declare i64 @CLIPFORMAT_UserSize64(ptr, i64, ptr)

declare ptr @CLIPFORMAT_UserMarshal64(ptr, ptr, ptr)

declare ptr @CLIPFORMAT_UserUnmarshal64(ptr, ptr, ptr)

declare void @CLIPFORMAT_UserFree64(ptr, ptr)

declare i64 @FLAG_STGMEDIUM_UserSize64(ptr, i64, ptr)

declare ptr @FLAG_STGMEDIUM_UserMarshal64(ptr, ptr, ptr)

declare ptr @FLAG_STGMEDIUM_UserUnmarshal64(ptr, ptr, ptr)

declare void @FLAG_STGMEDIUM_UserFree64(ptr, ptr)

declare i64 @HBITMAP_UserSize64(ptr, i64, ptr)

declare ptr @HBITMAP_UserMarshal64(ptr, ptr, ptr)

declare ptr @HBITMAP_UserUnmarshal64(ptr, ptr, ptr)

declare void @HBITMAP_UserFree64(ptr, ptr)

declare i64 @HDC_UserSize64(ptr, i64, ptr)

declare ptr @HDC_UserMarshal64(ptr, ptr, ptr)

declare ptr @HDC_UserUnmarshal64(ptr, ptr, ptr)

declare void @HDC_UserFree64(ptr, ptr)

declare i64 @HICON_UserSize64(ptr, i64, ptr)

declare ptr @HICON_UserMarshal64(ptr, ptr, ptr)

declare ptr @HICON_UserUnmarshal64(ptr, ptr, ptr)

declare void @HICON_UserFree64(ptr, ptr)

declare i64 @SNB_UserSize64(ptr, i64, ptr)

declare ptr @SNB_UserMarshal64(ptr, ptr, ptr)

declare ptr @SNB_UserUnmarshal64(ptr, ptr, ptr)

declare void @SNB_UserFree64(ptr, ptr)

declare i64 @STGMEDIUM_UserSize64(ptr, i64, ptr)

declare ptr @STGMEDIUM_UserMarshal64(ptr, ptr, ptr)

declare ptr @STGMEDIUM_UserUnmarshal64(ptr, ptr, ptr)

declare void @STGMEDIUM_UserFree64(ptr, ptr)

declare i64 @IBindCtx_SetBindOptions_Proxy(ptr, ptr)

declare i64 @IBindCtx_SetBindOptions_Stub(ptr, ptr)

declare i64 @IBindCtx_GetBindOptions_Proxy(ptr, ptr)

declare i64 @IBindCtx_GetBindOptions_Stub(ptr, ptr)

declare i64 @IEnumMoniker_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumMoniker_Next_Stub(ptr, i64, ptr, ptr)

declare i32 @IRunnableObject_IsRunning_Proxy(ptr)

declare i64 @IRunnableObject_IsRunning_Stub(ptr)

declare i64 @IMoniker_BindToObject_Proxy(ptr, ptr, ptr, ptr, ptr)

declare i64 @IMoniker_BindToObject_Stub(ptr, ptr, ptr, ptr, ptr)

declare i64 @IMoniker_BindToStorage_Proxy(ptr, ptr, ptr, ptr, ptr)

declare i64 @IMoniker_BindToStorage_Stub(ptr, ptr, ptr, ptr, ptr)

declare i64 @IEnumSTATSTG_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumSTATSTG_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @IStorage_OpenStream_Proxy(ptr, ptr, ptr, i64, i64, ptr)

declare i64 @IStorage_OpenStream_Stub(ptr, ptr, i64, ptr, i64, i64, ptr)

declare i64 @IStorage_CopyTo_Proxy(ptr, i64, ptr, ptr, ptr)

declare i64 @IStorage_CopyTo_Stub(ptr, i64, ptr, ptr, ptr)

declare i64 @IStorage_EnumElements_Proxy(ptr, i64, ptr, i64, ptr)

declare i64 @IStorage_EnumElements_Stub(ptr, i64, i64, ptr, i64, ptr)

declare i64 @ILockBytes_ReadAt_Proxy(ptr, i64, ptr, i64, ptr)

declare i64 @ILockBytes_ReadAt_Stub(ptr, i64, ptr, i64, ptr)

declare i64 @ILockBytes_WriteAt_Proxy(ptr, i64, ptr, i64, ptr)

declare i64 @ILockBytes_WriteAt_Stub(ptr, i64, ptr, i64, ptr)

declare i64 @IEnumFORMATETC_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumFORMATETC_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @IEnumSTATDATA_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumSTATDATA_Next_Stub(ptr, i64, ptr, ptr)

declare void @IAdviseSink_OnDataChange_Proxy(ptr, ptr, ptr)

declare i64 @IAdviseSink_OnDataChange_Stub(ptr, ptr, ptr)

declare void @IAdviseSink_OnViewChange_Proxy(ptr, i64, i64)

declare i64 @IAdviseSink_OnViewChange_Stub(ptr, i64, i64)

declare void @IAdviseSink_OnRename_Proxy(ptr, ptr)

declare i64 @IAdviseSink_OnRename_Stub(ptr, ptr)

declare void @IAdviseSink_OnSave_Proxy(ptr)

declare i64 @IAdviseSink_OnSave_Stub(ptr)

declare void @IAdviseSink_OnClose_Proxy(ptr)

declare i64 @IAdviseSink_OnClose_Stub(ptr)

declare void @AsyncIAdviseSink_Begin_OnDataChange_Proxy(ptr, ptr, ptr)

declare i64 @AsyncIAdviseSink_Begin_OnDataChange_Stub(ptr, ptr, ptr)

declare void @AsyncIAdviseSink_Finish_OnDataChange_Proxy(ptr)

declare i64 @AsyncIAdviseSink_Finish_OnDataChange_Stub(ptr)

declare void @AsyncIAdviseSink_Begin_OnViewChange_Proxy(ptr, i64, i64)

declare i64 @AsyncIAdviseSink_Begin_OnViewChange_Stub(ptr, i64, i64)

declare void @AsyncIAdviseSink_Finish_OnViewChange_Proxy(ptr)

declare i64 @AsyncIAdviseSink_Finish_OnViewChange_Stub(ptr)

declare void @AsyncIAdviseSink_Begin_OnRename_Proxy(ptr, ptr)

declare i64 @AsyncIAdviseSink_Begin_OnRename_Stub(ptr, ptr)

declare void @AsyncIAdviseSink_Finish_OnRename_Proxy(ptr)

declare i64 @AsyncIAdviseSink_Finish_OnRename_Stub(ptr)

declare void @AsyncIAdviseSink_Begin_OnSave_Proxy(ptr)

declare i64 @AsyncIAdviseSink_Begin_OnSave_Stub(ptr)

declare void @AsyncIAdviseSink_Finish_OnSave_Proxy(ptr)

declare i64 @AsyncIAdviseSink_Finish_OnSave_Stub(ptr)

declare void @AsyncIAdviseSink_Begin_OnClose_Proxy(ptr)

declare i64 @AsyncIAdviseSink_Begin_OnClose_Stub(ptr)

declare void @AsyncIAdviseSink_Finish_OnClose_Proxy(ptr)

declare i64 @AsyncIAdviseSink_Finish_OnClose_Stub(ptr)

declare void @IAdviseSink2_OnLinkSrcChange_Proxy(ptr, ptr)

declare i64 @IAdviseSink2_OnLinkSrcChange_Stub(ptr, ptr)

declare void @AsyncIAdviseSink2_Begin_OnLinkSrcChange_Proxy(ptr, ptr)

declare i64 @AsyncIAdviseSink2_Begin_OnLinkSrcChange_Stub(ptr, ptr)

declare void @AsyncIAdviseSink2_Finish_OnLinkSrcChange_Proxy(ptr)

declare i64 @AsyncIAdviseSink2_Finish_OnLinkSrcChange_Stub(ptr)

declare i64 @IDataObject_GetData_Proxy(ptr, ptr, ptr)

declare i64 @IDataObject_GetData_Stub(ptr, ptr, ptr)

declare i64 @IDataObject_GetDataHere_Proxy(ptr, ptr, ptr)

declare i64 @IDataObject_GetDataHere_Stub(ptr, ptr, ptr)

declare i64 @IDataObject_SetData_Proxy(ptr, ptr, ptr, i32)

declare i64 @IDataObject_SetData_Stub(ptr, ptr, ptr, i32)

declare i64 @IFillLockBytes_FillAppend_Proxy(ptr, ptr, i64, ptr)

declare i64 @IFillLockBytes_FillAppend_Stub(ptr, ptr, i64, ptr)

declare i64 @IFillLockBytes_FillAt_Proxy(ptr, i64, ptr, i64, ptr)

declare i64 @IFillLockBytes_FillAt_Stub(ptr, i64, ptr, i64, ptr)

declare i64 @IDispatch_RemoteInvoke_Proxy(ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr, i64, ptr, ptr)

declare void @IDispatch_RemoteInvoke_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumVARIANT_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumVARIANT_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeComp_RemoteBind_Proxy(ptr, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare void @ITypeComp_RemoteBind_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeComp_RemoteBindType_Proxy(ptr, ptr, i64, ptr)

declare void @ITypeComp_RemoteBindType_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteGetTypeAttr_Proxy(ptr, ptr, ptr)

declare void @ITypeInfo_RemoteGetTypeAttr_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteGetFuncDesc_Proxy(ptr, i64, ptr, ptr)

declare void @ITypeInfo_RemoteGetFuncDesc_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteGetVarDesc_Proxy(ptr, i64, ptr, ptr)

declare void @ITypeInfo_RemoteGetVarDesc_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteGetNames_Proxy(ptr, i64, ptr, i64, ptr)

declare void @ITypeInfo_RemoteGetNames_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_LocalGetIDsOfNames_Proxy(ptr)

declare void @ITypeInfo_LocalGetIDsOfNames_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_LocalInvoke_Proxy(ptr)

declare void @ITypeInfo_LocalInvoke_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteGetDocumentation_Proxy(ptr, i64, i64, ptr, ptr, ptr, ptr)

declare void @ITypeInfo_RemoteGetDocumentation_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteGetDllEntry_Proxy(ptr, i64, i64, i64, ptr, ptr, ptr)

declare void @ITypeInfo_RemoteGetDllEntry_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_LocalAddressOfMember_Proxy(ptr)

declare void @ITypeInfo_LocalAddressOfMember_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteCreateInstance_Proxy(ptr, ptr, ptr)

declare void @ITypeInfo_RemoteCreateInstance_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_RemoteGetContainingTypeLib_Proxy(ptr, ptr, ptr)

declare void @ITypeInfo_RemoteGetContainingTypeLib_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_LocalReleaseTypeAttr_Proxy(ptr)

declare void @ITypeInfo_LocalReleaseTypeAttr_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_LocalReleaseFuncDesc_Proxy(ptr)

declare void @ITypeInfo_LocalReleaseFuncDesc_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_LocalReleaseVarDesc_Proxy(ptr)

declare void @ITypeInfo_LocalReleaseVarDesc_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo2_RemoteGetDocumentation2_Proxy(ptr, i64, i64, i64, ptr, ptr, ptr)

declare void @ITypeInfo2_RemoteGetDocumentation2_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_RemoteGetTypeInfoCount_Proxy(ptr, ptr)

declare void @ITypeLib_RemoteGetTypeInfoCount_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_RemoteGetLibAttr_Proxy(ptr, ptr, ptr)

declare void @ITypeLib_RemoteGetLibAttr_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_RemoteGetDocumentation_Proxy(ptr, i32, i64, ptr, ptr, ptr, ptr)

declare void @ITypeLib_RemoteGetDocumentation_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_RemoteIsName_Proxy(ptr, ptr, i64, ptr, ptr)

declare void @ITypeLib_RemoteIsName_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_RemoteFindName_Proxy(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare void @ITypeLib_RemoteFindName_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_LocalReleaseTLibAttr_Proxy(ptr)

declare void @ITypeLib_LocalReleaseTLibAttr_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib2_RemoteGetLibStatistics_Proxy(ptr, ptr, ptr)

declare void @ITypeLib2_RemoteGetLibStatistics_Stub(ptr, ptr, ptr, ptr)

declare i64 @ITypeLib2_RemoteGetDocumentation2_Proxy(ptr, i32, i64, i64, ptr, ptr, ptr)

declare void @ITypeLib2_RemoteGetDocumentation2_Stub(ptr, ptr, ptr, ptr)

declare i64 @IPropertyBag_RemoteRead_Proxy(ptr, ptr, ptr, ptr, i64, ptr)

declare void @IPropertyBag_RemoteRead_Stub(ptr, ptr, ptr, ptr)

declare i64 @BSTR_UserSize(ptr, i64, ptr)

declare ptr @BSTR_UserMarshal(ptr, ptr, ptr)

declare ptr @BSTR_UserUnmarshal(ptr, ptr, ptr)

declare void @BSTR_UserFree(ptr, ptr)

declare i64 @CLEANLOCALSTORAGE_UserSize(ptr, i64, ptr)

declare ptr @CLEANLOCALSTORAGE_UserMarshal(ptr, ptr, ptr)

declare ptr @CLEANLOCALSTORAGE_UserUnmarshal(ptr, ptr, ptr)

declare void @CLEANLOCALSTORAGE_UserFree(ptr, ptr)

declare i64 @VARIANT_UserSize(ptr, i64, ptr)

declare ptr @VARIANT_UserMarshal(ptr, ptr, ptr)

declare ptr @VARIANT_UserUnmarshal(ptr, ptr, ptr)

declare void @VARIANT_UserFree(ptr, ptr)

declare i64 @BSTR_UserSize64(ptr, i64, ptr)

declare ptr @BSTR_UserMarshal64(ptr, ptr, ptr)

declare ptr @BSTR_UserUnmarshal64(ptr, ptr, ptr)

declare void @BSTR_UserFree64(ptr, ptr)

declare i64 @CLEANLOCALSTORAGE_UserSize64(ptr, i64, ptr)

declare ptr @CLEANLOCALSTORAGE_UserMarshal64(ptr, ptr, ptr)

declare ptr @CLEANLOCALSTORAGE_UserUnmarshal64(ptr, ptr, ptr)

declare void @CLEANLOCALSTORAGE_UserFree64(ptr, ptr)

declare i64 @VARIANT_UserSize64(ptr, i64, ptr)

declare ptr @VARIANT_UserMarshal64(ptr, ptr, ptr)

declare ptr @VARIANT_UserUnmarshal64(ptr, ptr, ptr)

declare void @VARIANT_UserFree64(ptr, ptr)

declare i64 @IDispatch_Invoke_Proxy(ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i64 @IDispatch_Invoke_Stub(ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr, i64, ptr, ptr)

declare i64 @IEnumVARIANT_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumVARIANT_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @ITypeComp_Bind_Proxy(ptr, ptr, i64, i64, ptr, ptr, ptr)

declare i64 @ITypeComp_Bind_Stub(ptr, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @ITypeComp_BindType_Proxy(ptr, ptr, i64, ptr, ptr)

declare i64 @ITypeComp_BindType_Stub(ptr, ptr, i64, ptr)

declare i64 @ITypeInfo_GetTypeAttr_Proxy(ptr, ptr)

declare i64 @ITypeInfo_GetTypeAttr_Stub(ptr, ptr, ptr)

declare i64 @ITypeInfo_GetFuncDesc_Proxy(ptr, i64, ptr)

declare i64 @ITypeInfo_GetFuncDesc_Stub(ptr, i64, ptr, ptr)

declare i64 @ITypeInfo_GetVarDesc_Proxy(ptr, i64, ptr)

declare i64 @ITypeInfo_GetVarDesc_Stub(ptr, i64, ptr, ptr)

declare i64 @ITypeInfo_GetNames_Proxy(ptr, i64, ptr, i64, ptr)

declare i64 @ITypeInfo_GetNames_Stub(ptr, i64, ptr, i64, ptr)

declare i64 @ITypeInfo_GetIDsOfNames_Proxy(ptr, ptr, i64, ptr)

declare i64 @ITypeInfo_GetIDsOfNames_Stub(ptr)

declare i64 @ITypeInfo_Invoke_Proxy(ptr, ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_Invoke_Stub(ptr)

declare i64 @ITypeInfo_GetDocumentation_Proxy(ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_GetDocumentation_Stub(ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_GetDllEntry_Proxy(ptr, i64, i64, ptr, ptr, ptr)

declare i64 @ITypeInfo_GetDllEntry_Stub(ptr, i64, i64, i64, ptr, ptr, ptr)

declare i64 @ITypeInfo_AddressOfMember_Proxy(ptr, i64, i64, ptr)

declare i64 @ITypeInfo_AddressOfMember_Stub(ptr)

declare i64 @ITypeInfo_CreateInstance_Proxy(ptr, ptr, ptr, ptr)

declare i64 @ITypeInfo_CreateInstance_Stub(ptr, ptr, ptr)

declare i64 @ITypeInfo_GetContainingTypeLib_Proxy(ptr, ptr, ptr)

declare i64 @ITypeInfo_GetContainingTypeLib_Stub(ptr, ptr, ptr)

declare void @ITypeInfo_ReleaseTypeAttr_Proxy(ptr, ptr)

declare i64 @ITypeInfo_ReleaseTypeAttr_Stub(ptr)

declare void @ITypeInfo_ReleaseFuncDesc_Proxy(ptr, ptr)

declare i64 @ITypeInfo_ReleaseFuncDesc_Stub(ptr)

declare void @ITypeInfo_ReleaseVarDesc_Proxy(ptr, ptr)

declare i64 @ITypeInfo_ReleaseVarDesc_Stub(ptr)

declare i64 @ITypeInfo2_GetDocumentation2_Proxy(ptr, i64, i64, ptr, ptr, ptr)

declare i64 @ITypeInfo2_GetDocumentation2_Stub(ptr, i64, i64, i64, ptr, ptr, ptr)

declare i64 @ITypeLib_GetTypeInfoCount_Proxy(ptr)

declare i64 @ITypeLib_GetTypeInfoCount_Stub(ptr, ptr)

declare i64 @ITypeLib_GetLibAttr_Proxy(ptr, ptr)

declare i64 @ITypeLib_GetLibAttr_Stub(ptr, ptr, ptr)

declare i64 @ITypeLib_GetDocumentation_Proxy(ptr, i32, ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_GetDocumentation_Stub(ptr, i32, i64, ptr, ptr, ptr, ptr)

declare i64 @ITypeLib_IsName_Proxy(ptr, ptr, i64, ptr)

declare i64 @ITypeLib_IsName_Stub(ptr, ptr, i64, ptr, ptr)

declare i64 @ITypeLib_FindName_Proxy(ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @ITypeLib_FindName_Stub(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare void @ITypeLib_ReleaseTLibAttr_Proxy(ptr, ptr)

declare i64 @ITypeLib_ReleaseTLibAttr_Stub(ptr)

declare i64 @ITypeLib2_GetLibStatistics_Proxy(ptr, ptr, ptr)

declare i64 @ITypeLib2_GetLibStatistics_Stub(ptr, ptr, ptr)

declare i64 @ITypeLib2_GetDocumentation2_Proxy(ptr, i32, i64, ptr, ptr, ptr)

declare i64 @ITypeLib2_GetDocumentation2_Stub(ptr, i32, i64, i64, ptr, ptr, ptr)

declare i64 @IPropertyBag_Read_Proxy(ptr, ptr, ptr, ptr)

declare i64 @IPropertyBag_Read_Stub(ptr, ptr, ptr, ptr, i64, ptr)

declare i64 @IEnumSTATPROPSTG_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumSTATPROPSTG_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumSTATPROPSETSTG_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumSTATPROPSETSTG_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @LPSAFEARRAY_UserSize(ptr, i64, ptr)

declare ptr @LPSAFEARRAY_UserMarshal(ptr, ptr, ptr)

declare ptr @LPSAFEARRAY_UserUnmarshal(ptr, ptr, ptr)

declare void @LPSAFEARRAY_UserFree(ptr, ptr)

declare i64 @LPSAFEARRAY_UserSize64(ptr, i64, ptr)

declare ptr @LPSAFEARRAY_UserMarshal64(ptr, ptr, ptr)

declare ptr @LPSAFEARRAY_UserUnmarshal64(ptr, ptr, ptr)

declare void @LPSAFEARRAY_UserFree64(ptr, ptr)

declare i64 @IEnumSTATPROPSTG_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumSTATPROPSTG_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @IEnumSTATPROPSETSTG_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumSTATPROPSETSTG_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @StgCreateDocfile(ptr, i64, i64, ptr)

declare i64 @StgCreateDocfileOnILockBytes(ptr, i64, i64, ptr)

declare i64 @StgOpenStorage(ptr, ptr, i64, ptr, i64, ptr)

declare i64 @StgOpenStorageOnILockBytes(ptr, ptr, i64, ptr, i64, ptr)

declare i64 @StgIsStorageFile(ptr)

declare i64 @StgIsStorageILockBytes(ptr)

declare i64 @StgSetTimes(ptr, ptr, ptr, ptr)

declare i64 @StgCreateStorageEx(ptr, i64, i64, i64, ptr, ptr, ptr, ptr)

declare i64 @StgOpenStorageEx(ptr, i64, i64, i64, ptr, ptr, ptr, ptr)

declare i64 @StgCreatePropStg(ptr, ptr, ptr, i64, i64, ptr)

declare i64 @StgOpenPropStg(ptr, ptr, i64, i64, ptr)

declare i64 @StgCreatePropSetStg(ptr, i64, ptr)

declare i64 @FmtIdToPropStgName(ptr, ptr)

declare i64 @PropStgNameToFmtId(ptr, ptr)

declare i64 @ReadClassStg(ptr, ptr)

declare i64 @WriteClassStg(ptr, ptr)

declare i64 @ReadClassStm(ptr, ptr)

declare i64 @WriteClassStm(ptr, ptr)

declare i64 @GetHGlobalFromILockBytes(ptr, ptr)

declare i64 @CreateILockBytesOnHGlobal(ptr, i32, ptr)

declare i64 @GetConvertStg(ptr)

declare i64 @CoBuildVersion()

declare i64 @CoInitialize(ptr)

declare i64 @CoRegisterMallocSpy(ptr)

declare i64 @CoRevokeMallocSpy()

declare i64 @CoCreateStandardMalloc(i64, ptr)

declare i64 @CoRegisterInitializeSpy(ptr, ptr)

declare i64 @CoRevokeInitializeSpy(i64)

declare i64 @CoGetSystemSecurityPermissions(i64, ptr)

declare ptr @CoLoadLibrary(ptr, i32)

declare void @CoFreeLibrary(ptr)

declare void @CoFreeAllLibraries()

declare i64 @CoGetInstanceFromFile(ptr, ptr, ptr, i64, i64, ptr, i64, ptr)

declare i64 @CoGetInstanceFromIStorage(ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i64 @CoAllowSetForegroundWindow(ptr, ptr)

declare i64 @DcomChannelSetHResult(ptr, ptr, i64)

declare i32 @CoIsOle1Class(ptr)

declare i32 @CoFileTimeToDosDateTime(ptr, ptr, ptr)

declare i32 @CoDosDateTimeToFileTime(i64, i64, ptr)

declare i64 @CoRegisterMessageFilter(ptr, ptr)

declare i64 @CoRegisterChannelHook(ptr, ptr)

declare i64 @CoTreatAsClass(ptr, ptr)

declare i64 @CreateDataAdviseHolder(ptr)

declare i64 @CreateDataCache(ptr, ptr, ptr, ptr)

declare i64 @StgOpenAsyncDocfileOnIFillLockBytes(ptr, i64, i64, ptr)

declare i64 @StgGetIFillLockBytesOnILockBytes(ptr, ptr)

declare i64 @StgGetIFillLockBytesOnFile(ptr, ptr)

declare i64 @StgOpenLayoutDocfile(ptr, i64, i64, ptr)

declare i64 @CoInstall(ptr, i64, ptr, ptr, ptr)

declare i64 @BindMoniker(ptr, i64, ptr, ptr)

declare i64 @CoGetObject(ptr, ptr, ptr, ptr)

declare i64 @MkParseDisplayName(ptr, ptr, ptr, ptr)

declare i64 @MonikerRelativePathTo(ptr, ptr, ptr, i32)

declare i64 @MonikerCommonPrefixWith(ptr, ptr, ptr)

declare i64 @CreateBindCtx(i64, ptr)

declare i64 @CreateGenericComposite(ptr, ptr, ptr)

declare i64 @GetClassFile(ptr, ptr)

declare i64 @CreateClassMoniker(ptr, ptr)

declare i64 @CreateFileMoniker(ptr, ptr)

declare i64 @CreateItemMoniker(ptr, ptr, ptr)

declare i64 @CreateAntiMoniker(ptr)

declare i64 @CreatePointerMoniker(ptr, ptr)

declare i64 @CreateObjrefMoniker(ptr, ptr)

declare i64 @GetRunningObjectTable(i64, ptr)

declare i64 @IOleCache2_RemoteUpdateCache_Proxy(ptr, ptr, i64, i64)

declare void @IOleCache2_RemoteUpdateCache_Stub(ptr, ptr, ptr, ptr)

declare i64 @IOleInPlaceActiveObject_RemoteTranslateAccelerator_Proxy(ptr)

declare void @IOleInPlaceActiveObject_RemoteTranslateAccelerator_Stub(ptr, ptr, ptr, ptr)

declare i64 @IOleInPlaceActiveObject_RemoteResizeBorder_Proxy(ptr, ptr, ptr, ptr, i32)

declare void @IOleInPlaceActiveObject_RemoteResizeBorder_Stub(ptr, ptr, ptr, ptr)

declare i64 @IViewObject_RemoteDraw_Proxy(ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare void @IViewObject_RemoteDraw_Stub(ptr, ptr, ptr, ptr)

declare i64 @IViewObject_RemoteGetColorSet_Proxy(ptr, i64, i64, i64, ptr, i64, ptr)

declare void @IViewObject_RemoteGetColorSet_Stub(ptr, ptr, ptr, ptr)

declare i64 @IViewObject_RemoteFreeze_Proxy(ptr, i64, i64, i64, ptr)

declare void @IViewObject_RemoteFreeze_Stub(ptr, ptr, ptr, ptr)

declare i64 @IViewObject_RemoteGetAdvise_Proxy(ptr, ptr, ptr, ptr)

declare void @IViewObject_RemoteGetAdvise_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumOLEVERB_RemoteNext_Proxy(ptr, i64, ptr, ptr)

declare void @IEnumOLEVERB_RemoteNext_Stub(ptr, ptr, ptr, ptr)

declare i64 @HACCEL_UserSize(ptr, i64, ptr)

declare ptr @HACCEL_UserMarshal(ptr, ptr, ptr)

declare ptr @HACCEL_UserUnmarshal(ptr, ptr, ptr)

declare void @HACCEL_UserFree(ptr, ptr)

declare i64 @HGLOBAL_UserSize(ptr, i64, ptr)

declare ptr @HGLOBAL_UserMarshal(ptr, ptr, ptr)

declare ptr @HGLOBAL_UserUnmarshal(ptr, ptr, ptr)

declare void @HGLOBAL_UserFree(ptr, ptr)

declare i64 @HMENU_UserSize(ptr, i64, ptr)

declare ptr @HMENU_UserMarshal(ptr, ptr, ptr)

declare ptr @HMENU_UserUnmarshal(ptr, ptr, ptr)

declare void @HMENU_UserFree(ptr, ptr)

declare i64 @HWND_UserSize(ptr, i64, ptr)

declare ptr @HWND_UserMarshal(ptr, ptr, ptr)

declare ptr @HWND_UserUnmarshal(ptr, ptr, ptr)

declare void @HWND_UserFree(ptr, ptr)

declare i64 @HACCEL_UserSize64(ptr, i64, ptr)

declare ptr @HACCEL_UserMarshal64(ptr, ptr, ptr)

declare ptr @HACCEL_UserUnmarshal64(ptr, ptr, ptr)

declare void @HACCEL_UserFree64(ptr, ptr)

declare i64 @HGLOBAL_UserSize64(ptr, i64, ptr)

declare ptr @HGLOBAL_UserMarshal64(ptr, ptr, ptr)

declare ptr @HGLOBAL_UserUnmarshal64(ptr, ptr, ptr)

declare void @HGLOBAL_UserFree64(ptr, ptr)

declare i64 @HMENU_UserSize64(ptr, i64, ptr)

declare ptr @HMENU_UserMarshal64(ptr, ptr, ptr)

declare ptr @HMENU_UserUnmarshal64(ptr, ptr, ptr)

declare void @HMENU_UserFree64(ptr, ptr)

declare i64 @HWND_UserSize64(ptr, i64, ptr)

declare ptr @HWND_UserMarshal64(ptr, ptr, ptr)

declare ptr @HWND_UserUnmarshal64(ptr, ptr, ptr)

declare void @HWND_UserFree64(ptr, ptr)

declare i64 @IOleCache2_UpdateCache_Proxy(ptr, ptr, i64, ptr)

declare i64 @IOleCache2_UpdateCache_Stub(ptr, ptr, i64, i64)

declare i64 @IOleInPlaceActiveObject_TranslateAccelerator_Proxy(ptr, ptr)

declare i64 @IOleInPlaceActiveObject_TranslateAccelerator_Stub(ptr)

declare i64 @IOleInPlaceActiveObject_ResizeBorder_Proxy(ptr, ptr, ptr, i32)

declare i64 @IOleInPlaceActiveObject_ResizeBorder_Stub(ptr, ptr, ptr, ptr, i32)

declare i64 @IViewObject_Draw_Proxy(ptr, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64)

declare i64 @IViewObject_Draw_Stub(ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @IViewObject_GetColorSet_Proxy(ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i64 @IViewObject_GetColorSet_Stub(ptr, i64, i64, i64, ptr, i64, ptr)

declare i64 @IViewObject_Freeze_Proxy(ptr, i64, i64, ptr, ptr)

declare i64 @IViewObject_Freeze_Stub(ptr, i64, i64, i64, ptr)

declare i64 @IViewObject_GetAdvise_Proxy(ptr, ptr, ptr, ptr)

declare i64 @IViewObject_GetAdvise_Stub(ptr, ptr, ptr, ptr)

declare i64 @IEnumOLEVERB_Next_Proxy(ptr, i64, ptr, ptr)

declare i64 @IEnumOLEVERB_Next_Stub(ptr, i64, ptr, ptr)

declare i64 @IServiceProvider_RemoteQueryService_Proxy(ptr, ptr, ptr, ptr)

declare void @IServiceProvider_RemoteQueryService_Stub(ptr, ptr, ptr, ptr)

declare i64 @IServiceProvider_QueryService_Proxy(ptr, ptr, ptr, ptr)

declare i64 @IServiceProvider_QueryService_Stub(ptr, ptr, ptr, ptr)

declare i64 @CreateURLMoniker(ptr, ptr, ptr)

declare i64 @CreateURLMonikerEx(ptr, ptr, ptr, i64)

declare i64 @GetClassURL(ptr, ptr)

declare i64 @CreateAsyncBindCtx(i64, ptr, ptr, ptr)

declare i64 @CreateURLMonikerEx2(ptr, ptr, ptr, i64)

declare i64 @CreateAsyncBindCtxEx(ptr, i64, ptr, ptr, ptr, i64)

declare i64 @MkParseDisplayNameEx(ptr, ptr, ptr, ptr)

declare i64 @RegisterBindStatusCallback(ptr, ptr, ptr, i64)

declare i64 @RevokeBindStatusCallback(ptr, ptr)

declare i64 @GetClassFileOrMime(ptr, ptr, ptr, i64, ptr, i64, ptr)

declare i64 @IsValidURL(ptr, ptr, i64)

declare i64 @CoGetClassObjectFromURL(ptr, ptr, i64, i64, ptr, ptr, i64, ptr, ptr, ptr)

declare i64 @IEInstallScope(ptr)

declare i64 @FaultInIEFeature(ptr, ptr, ptr, i64)

declare i64 @GetComponentIDFromCLSSPEC(ptr, ptr)

declare i64 @IsAsyncMoniker(ptr)

declare i64 @CreateURLBinding(ptr, ptr, ptr)

declare i64 @RegisterMediaTypes(i64, ptr, ptr)

declare i64 @FindMediaType(ptr, ptr)

declare i64 @CreateFormatEnumerator(i64, ptr, ptr)

declare i64 @RegisterFormatEnumerator(ptr, ptr, i64)

declare i64 @RevokeFormatEnumerator(ptr, ptr)

declare i64 @RegisterMediaTypeClass(ptr, i64, ptr, ptr, i64)

declare i64 @FindMediaTypeClass(ptr, ptr, ptr, i64)

declare i64 @UrlMkSetSessionOption(i64, ptr, i64, i64)

declare i64 @UrlMkGetSessionOption(i64, ptr, i64, ptr, i64)

declare i64 @FindMimeFromData(ptr, ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @ObtainUserAgentString(i64, ptr, ptr)

declare i64 @CompareSecurityIds(ptr, i64, ptr, i64, i64)

declare i64 @CompatFlagsFromClsid(ptr, ptr, ptr)

declare i64 @SetAccessForIEAppContainer(ptr, i64, i64)

declare i64 @IBinding_RemoteGetBindResult_Proxy(ptr, ptr, ptr, ptr, i64)

declare void @IBinding_RemoteGetBindResult_Stub(ptr, ptr, ptr, ptr)

declare i64 @IBindStatusCallback_RemoteGetBindInfo_Proxy(ptr, ptr, ptr, ptr)

declare void @IBindStatusCallback_RemoteGetBindInfo_Stub(ptr, ptr, ptr, ptr)

declare i64 @IBindStatusCallback_RemoteOnDataAvailable_Proxy(ptr, i64, i64, ptr, ptr)

declare void @IBindStatusCallback_RemoteOnDataAvailable_Stub(ptr, ptr, ptr, ptr)

declare i64 @IBindStatusCallbackEx_RemoteGetBindInfoEx_Proxy(ptr, ptr, ptr, ptr, ptr, ptr)

declare void @IBindStatusCallbackEx_RemoteGetBindInfoEx_Stub(ptr, ptr, ptr, ptr)

declare i64 @CreateUri(ptr, i64, i64, ptr)

declare i64 @CreateUriWithFragment(ptr, ptr, i64, i64, ptr)

declare i64 @CreateUriFromMultiByteString(ptr, i64, i64, i64, i64, ptr)

declare i64 @CreateIUriBuilder(ptr, i64, i64, ptr)

declare i64 @IWinInetInfo_RemoteQueryOption_Proxy(ptr, i64, ptr, ptr)

declare void @IWinInetInfo_RemoteQueryOption_Stub(ptr, ptr, ptr, ptr)

declare i64 @IWinInetHttpInfo_RemoteQueryInfo_Proxy(ptr, i64, ptr, ptr, ptr, ptr)

declare void @IWinInetHttpInfo_RemoteQueryInfo_Stub(ptr, ptr, ptr, ptr)

declare i64 @IBindHost_RemoteMonikerBindToStorage_Proxy(ptr, ptr, ptr, ptr, ptr, ptr)

declare void @IBindHost_RemoteMonikerBindToStorage_Stub(ptr, ptr, ptr, ptr)

declare i64 @IBindHost_RemoteMonikerBindToObject_Proxy(ptr, ptr, ptr, ptr, ptr, ptr)

declare void @IBindHost_RemoteMonikerBindToObject_Stub(ptr, ptr, ptr, ptr)

declare i64 @HlinkSimpleNavigateToString(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64)

declare i64 @HlinkSimpleNavigateToMoniker(ptr, ptr, ptr, ptr, ptr, ptr, i64, i64)

declare i64 @URLOpenStreamA(ptr, ptr, i64, ptr)

declare i64 @URLOpenStreamW(ptr, ptr, i64, ptr)

declare i64 @URLOpenPullStreamA(ptr, ptr, i64, ptr)

declare i64 @URLOpenPullStreamW(ptr, ptr, i64, ptr)

declare i64 @URLDownloadToFileA(ptr, ptr, ptr, i64, ptr)

declare i64 @URLDownloadToFileW(ptr, ptr, ptr, i64, ptr)

declare i64 @URLDownloadToCacheFileA(ptr, ptr, ptr, i64, i64, ptr)

declare i64 @URLDownloadToCacheFileW(ptr, ptr, ptr, i64, i64, ptr)

declare i64 @URLOpenBlockingStreamA(ptr, ptr, ptr, i64, ptr)

declare i64 @URLOpenBlockingStreamW(ptr, ptr, ptr, i64, ptr)

declare i64 @HlinkGoBack(ptr)

declare i64 @HlinkGoForward(ptr)

declare i64 @HlinkNavigateString(ptr, ptr)

declare i64 @HlinkNavigateMoniker(ptr, ptr)

declare i64 @CoInternetParseUrl(ptr, i64, i64, ptr, i64, ptr, i64)

declare i64 @CoInternetParseIUri(ptr, i64, i64, ptr, i64, ptr, i64)

declare i64 @CoInternetCombineUrl(ptr, ptr, i64, ptr, i64, ptr, i64)

declare i64 @CoInternetCombineUrlEx(ptr, ptr, i64, ptr, i64)

declare i64 @CoInternetCombineIUri(ptr, ptr, i64, ptr, i64)

declare i64 @CoInternetCompareUrl(ptr, ptr, i64)

declare i64 @CoInternetGetProtocolFlags(ptr, ptr, i64)

declare i64 @CoInternetQueryInfo(ptr, i64, i64, ptr, i64, ptr, i64)

declare i64 @CoInternetGetSession(i64, ptr, i64)

declare i64 @CoInternetGetSecurityUrl(ptr, ptr, i64, i64)

declare i64 @AsyncInstallDistributionUnit(ptr, ptr, ptr, i64, i64, ptr, ptr, ptr, i64)

declare i64 @CoInternetGetSecurityUrlEx(ptr, ptr, i64, i64)

declare i64 @CoInternetSetFeatureEnabled(i64, i64, i32)

declare i64 @CoInternetIsFeatureEnabled(i64, i64)

declare i64 @CoInternetIsFeatureEnabledForUrl(i64, i64, ptr, ptr)

declare i64 @CoInternetIsFeatureEnabledForIUri(i64, i64, ptr, ptr)

declare i64 @CoInternetIsFeatureZoneElevationEnabled(ptr, ptr, ptr, i64)

declare i64 @CopyStgMedium(ptr, ptr)

declare i64 @CopyBindInfo(ptr, ptr)

declare void @ReleaseBindInfo(ptr)

declare ptr @IEGetUserPrivateNamespaceName()

declare i64 @CoInternetCreateSecurityManager(ptr, ptr, i64)

declare i64 @CoInternetCreateZoneManager(ptr, ptr, i64)

declare i64 @GetSoftwareUpdateInfo(ptr, ptr)

declare i64 @SetSoftwareUpdateAdvertisementState(ptr, i64, i64, i64)

declare i32 @IsLoggingEnabledA(ptr)

declare i32 @IsLoggingEnabledW(ptr)

declare i32 @WriteHitLogging(ptr)

declare i64 @IBinding_GetBindResult_Proxy(ptr, ptr, ptr, ptr, ptr)

declare i64 @IBinding_GetBindResult_Stub(ptr, ptr, ptr, ptr, i64)

declare i64 @IBindStatusCallback_GetBindInfo_Proxy(ptr, ptr, ptr)

declare i64 @IBindStatusCallback_GetBindInfo_Stub(ptr, ptr, ptr, ptr)

declare i64 @IBindStatusCallback_OnDataAvailable_Proxy(ptr, i64, i64, ptr, ptr)

declare i64 @IBindStatusCallback_OnDataAvailable_Stub(ptr, i64, i64, ptr, ptr)

declare i64 @IBindStatusCallbackEx_GetBindInfoEx_Proxy(ptr, ptr, ptr, ptr, ptr)

declare i64 @IBindStatusCallbackEx_GetBindInfoEx_Stub(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @IWinInetInfo_QueryOption_Proxy(ptr, i64, ptr, ptr)

declare i64 @IWinInetInfo_QueryOption_Stub(ptr, i64, ptr, ptr)

declare i64 @IWinInetHttpInfo_QueryInfo_Proxy(ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @IWinInetHttpInfo_QueryInfo_Stub(ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @IBindHost_MonikerBindToStorage_Proxy(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @IBindHost_MonikerBindToStorage_Stub(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @IBindHost_MonikerBindToObject_Proxy(ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @IBindHost_MonikerBindToObject_Stub(ptr, ptr, ptr, ptr, ptr, ptr)

declare ptr @StgConvertVariantToProperty(ptr, i64, ptr, ptr, i64, i64, ptr)

declare i64 @CreateStdProgressIndicator(ptr, ptr, ptr, ptr)

declare ptr @SysAllocString(ptr)

declare i32 @SysReAllocString(ptr, ptr)

declare ptr @SysAllocStringLen(ptr, i64)

declare i32 @SysReAllocStringLen(ptr, ptr, i64)

declare i64 @SysAddRefString(ptr)

declare void @SysReleaseString(ptr)

declare void @SysFreeString(ptr)

declare i64 @SysStringLen(ptr)

declare i64 @SysStringByteLen(ptr)

declare ptr @SysAllocStringByteLen(ptr, i64)

declare i32 @DosDateTimeToVariantTime(i64, i64, ptr)

declare i32 @VariantTimeToDosDateTime(double, ptr, ptr)

declare i32 @SystemTimeToVariantTime(ptr, ptr)

declare i32 @VariantTimeToSystemTime(double, ptr)

declare i64 @SafeArrayAllocDescriptor(i64, ptr)

declare i64 @SafeArrayAllocDescriptorEx(i64, i64, ptr)

declare i64 @SafeArrayAllocData(ptr)

declare ptr @SafeArrayCreate(i64, i64, ptr)

declare ptr @SafeArrayCreateEx(i64, i64, ptr, ptr)

declare i64 @SafeArrayCopyData(ptr, ptr)

declare void @SafeArrayReleaseDescriptor(ptr)

declare i64 @SafeArrayDestroyDescriptor(ptr)

declare void @SafeArrayReleaseData(ptr)

declare i64 @SafeArrayDestroyData(ptr)

declare i64 @SafeArrayAddRef(ptr, ptr)

declare i64 @SafeArrayDestroy(ptr)

declare i64 @SafeArrayRedim(ptr, ptr)

declare i64 @SafeArrayGetDim(ptr)

declare i64 @SafeArrayGetElemsize(ptr)

declare i64 @SafeArrayGetUBound(ptr, i64, ptr)

declare i64 @SafeArrayGetLBound(ptr, i64, ptr)

declare i64 @SafeArrayLock(ptr)

declare i64 @SafeArrayUnlock(ptr)

declare i64 @SafeArrayAccessData(ptr, ptr)

declare i64 @SafeArrayUnaccessData(ptr)

declare i64 @SafeArrayGetElement(ptr, ptr, ptr)

declare i64 @SafeArrayPutElement(ptr, ptr, ptr)

declare i64 @SafeArrayCopy(ptr, ptr)

declare i64 @SafeArrayPtrOfIndex(ptr, ptr, ptr)

declare i64 @SafeArraySetRecordInfo(ptr, ptr)

declare i64 @SafeArrayGetRecordInfo(ptr, ptr)

declare i64 @SafeArraySetIID(ptr, ptr)

declare i64 @SafeArrayGetIID(ptr, ptr)

declare i64 @SafeArrayGetVartype(ptr, ptr)

declare ptr @SafeArrayCreateVector(i64, i64, i64)

declare ptr @SafeArrayCreateVectorEx(i64, i64, i64, ptr)

declare void @VariantInit(ptr)

declare i64 @VariantClear(ptr)

declare i64 @VariantCopy(ptr, ptr)

declare i64 @VariantCopyInd(ptr, ptr)

declare i64 @VariantChangeType(ptr, ptr, i64, i64)

declare i64 @VariantChangeTypeEx(ptr, ptr, i64, i64, i64)

declare i64 @VectorFromBstr(ptr, ptr)

declare i64 @BstrFromVector(ptr, ptr)

declare i64 @VarUI1FromI2(i64, ptr)

declare i64 @VarUI1FromI4(i64, ptr)

declare i64 @VarUI1FromI8(i64, ptr)

declare i64 @VarUI1FromR4(float, ptr)

declare i64 @VarUI1FromR8(double, ptr)

declare i64 @VarUI1FromCy(i64, ptr)

declare i64 @VarUI1FromDate(double, ptr)

declare i64 @VarUI1FromStr(ptr, i64, i64, ptr)

declare i64 @VarUI1FromDisp(ptr, i64, ptr)

declare i64 @VarUI1FromBool(i64, ptr)

declare i64 @VarUI1FromI1(i64, ptr)

declare i64 @VarUI1FromUI2(i64, ptr)

declare i64 @VarUI1FromUI4(i64, ptr)

declare i64 @VarUI1FromUI8(i64, ptr)

declare i64 @VarUI1FromDec(ptr, ptr)

declare i64 @VarI2FromUI1(i64, ptr)

declare i64 @VarI2FromI4(i64, ptr)

declare i64 @VarI2FromI8(i64, ptr)

declare i64 @VarI2FromR4(float, ptr)

declare i64 @VarI2FromR8(double, ptr)

declare i64 @VarI2FromCy(i64, ptr)

declare i64 @VarI2FromDate(double, ptr)

declare i64 @VarI2FromStr(ptr, i64, i64, ptr)

declare i64 @VarI2FromDisp(ptr, i64, ptr)

declare i64 @VarI2FromBool(i64, ptr)

declare i64 @VarI2FromI1(i64, ptr)

declare i64 @VarI2FromUI2(i64, ptr)

declare i64 @VarI2FromUI4(i64, ptr)

declare i64 @VarI2FromUI8(i64, ptr)

declare i64 @VarI2FromDec(ptr, ptr)

declare i64 @VarI4FromUI1(i64, ptr)

declare i64 @VarI4FromI2(i64, ptr)

declare i64 @VarI4FromI8(i64, ptr)

declare i64 @VarI4FromR4(float, ptr)

declare i64 @VarI4FromR8(double, ptr)

declare i64 @VarI4FromCy(i64, ptr)

declare i64 @VarI4FromDate(double, ptr)

declare i64 @VarI4FromStr(ptr, i64, i64, ptr)

declare i64 @VarI4FromDisp(ptr, i64, ptr)

declare i64 @VarI4FromBool(i64, ptr)

declare i64 @VarI4FromI1(i64, ptr)

declare i64 @VarI4FromUI2(i64, ptr)

declare i64 @VarI4FromUI4(i64, ptr)

declare i64 @VarI4FromUI8(i64, ptr)

declare i64 @VarI4FromDec(ptr, ptr)

declare i64 @VarI8FromUI1(i64, ptr)

declare i64 @VarI8FromI2(i64, ptr)

declare i64 @VarI8FromR4(float, ptr)

declare i64 @VarI8FromR8(double, ptr)

declare i64 @VarI8FromCy(i64, ptr)

declare i64 @VarI8FromDate(double, ptr)

declare i64 @VarI8FromStr(ptr, i64, i64, ptr)

declare i64 @VarI8FromDisp(ptr, i64, ptr)

declare i64 @VarI8FromBool(i64, ptr)

declare i64 @VarI8FromI1(i64, ptr)

declare i64 @VarI8FromUI2(i64, ptr)

declare i64 @VarI8FromUI4(i64, ptr)

declare i64 @VarI8FromUI8(i64, ptr)

declare i64 @VarI8FromDec(ptr, ptr)

declare i64 @VarR4FromUI1(i64, ptr)

declare i64 @VarR4FromI2(i64, ptr)

declare i64 @VarR4FromI4(i64, ptr)

declare i64 @VarR4FromI8(i64, ptr)

declare i64 @VarR4FromR8(double, ptr)

declare i64 @VarR4FromCy(i64, ptr)

declare i64 @VarR4FromDate(double, ptr)

declare i64 @VarR4FromStr(ptr, i64, i64, ptr)

declare i64 @VarR4FromDisp(ptr, i64, ptr)

declare i64 @VarR4FromBool(i64, ptr)

declare i64 @VarR4FromI1(i64, ptr)

declare i64 @VarR4FromUI2(i64, ptr)

declare i64 @VarR4FromUI4(i64, ptr)

declare i64 @VarR4FromUI8(i64, ptr)

declare i64 @VarR4FromDec(ptr, ptr)

declare i64 @VarR8FromUI1(i64, ptr)

declare i64 @VarR8FromI2(i64, ptr)

declare i64 @VarR8FromI4(i64, ptr)

declare i64 @VarR8FromI8(i64, ptr)

declare i64 @VarR8FromR4(float, ptr)

declare i64 @VarR8FromCy(i64, ptr)

declare i64 @VarR8FromDate(double, ptr)

declare i64 @VarR8FromStr(ptr, i64, i64, ptr)

declare i64 @VarR8FromDisp(ptr, i64, ptr)

declare i64 @VarR8FromBool(i64, ptr)

declare i64 @VarR8FromI1(i64, ptr)

declare i64 @VarR8FromUI2(i64, ptr)

declare i64 @VarR8FromUI4(i64, ptr)

declare i64 @VarR8FromUI8(i64, ptr)

declare i64 @VarR8FromDec(ptr, ptr)

declare i64 @VarDateFromUI1(i64, ptr)

declare i64 @VarDateFromI2(i64, ptr)

declare i64 @VarDateFromI4(i64, ptr)

declare i64 @VarDateFromI8(i64, ptr)

declare i64 @VarDateFromR4(float, ptr)

declare i64 @VarDateFromR8(double, ptr)

declare i64 @VarDateFromCy(i64, ptr)

declare i64 @VarDateFromStr(ptr, i64, i64, ptr)

declare i64 @VarDateFromDisp(ptr, i64, ptr)

declare i64 @VarDateFromBool(i64, ptr)

declare i64 @VarDateFromI1(i64, ptr)

declare i64 @VarDateFromUI2(i64, ptr)

declare i64 @VarDateFromUI4(i64, ptr)

declare i64 @VarDateFromUI8(i64, ptr)

declare i64 @VarDateFromDec(ptr, ptr)

declare i64 @VarCyFromUI1(i64, ptr)

declare i64 @VarCyFromI2(i64, ptr)

declare i64 @VarCyFromI4(i64, ptr)

declare i64 @VarCyFromI8(i64, ptr)

declare i64 @VarCyFromR4(float, ptr)

declare i64 @VarCyFromR8(double, ptr)

declare i64 @VarCyFromDate(double, ptr)

declare i64 @VarCyFromStr(ptr, i64, i64, ptr)

declare i64 @VarCyFromDisp(ptr, i64, ptr)

declare i64 @VarCyFromBool(i64, ptr)

declare i64 @VarCyFromI1(i64, ptr)

declare i64 @VarCyFromUI2(i64, ptr)

declare i64 @VarCyFromUI4(i64, ptr)

declare i64 @VarCyFromUI8(i64, ptr)

declare i64 @VarCyFromDec(ptr, ptr)

declare i64 @VarBstrFromUI1(i64, i64, i64, ptr)

declare i64 @VarBstrFromI2(i64, i64, i64, ptr)

declare i64 @VarBstrFromI4(i64, i64, i64, ptr)

declare i64 @VarBstrFromI8(i64, i64, i64, ptr)

declare i64 @VarBstrFromR4(float, i64, i64, ptr)

declare i64 @VarBstrFromR8(double, i64, i64, ptr)

declare i64 @VarBstrFromCy(i64, i64, i64, ptr)

declare i64 @VarBstrFromDate(double, i64, i64, ptr)

declare i64 @VarBstrFromDisp(ptr, i64, i64, ptr)

declare i64 @VarBstrFromBool(i64, i64, i64, ptr)

declare i64 @VarBstrFromI1(i64, i64, i64, ptr)

declare i64 @VarBstrFromUI2(i64, i64, i64, ptr)

declare i64 @VarBstrFromUI4(i64, i64, i64, ptr)

declare i64 @VarBstrFromUI8(i64, i64, i64, ptr)

declare i64 @VarBstrFromDec(ptr, i64, i64, ptr)

declare i64 @VarBoolFromUI1(i64, ptr)

declare i64 @VarBoolFromI2(i64, ptr)

declare i64 @VarBoolFromI4(i64, ptr)

declare i64 @VarBoolFromI8(i64, ptr)

declare i64 @VarBoolFromR4(float, ptr)

declare i64 @VarBoolFromR8(double, ptr)

declare i64 @VarBoolFromDate(double, ptr)

declare i64 @VarBoolFromCy(i64, ptr)

declare i64 @VarBoolFromStr(ptr, i64, i64, ptr)

declare i64 @VarBoolFromDisp(ptr, i64, ptr)

declare i64 @VarBoolFromI1(i64, ptr)

declare i64 @VarBoolFromUI2(i64, ptr)

declare i64 @VarBoolFromUI4(i64, ptr)

declare i64 @VarBoolFromUI8(i64, ptr)

declare i64 @VarBoolFromDec(ptr, ptr)

declare i64 @VarI1FromUI1(i64, ptr)

declare i64 @VarI1FromI2(i64, ptr)

declare i64 @VarI1FromI4(i64, ptr)

declare i64 @VarI1FromI8(i64, ptr)

declare i64 @VarI1FromR4(float, ptr)

declare i64 @VarI1FromR8(double, ptr)

declare i64 @VarI1FromDate(double, ptr)

declare i64 @VarI1FromCy(i64, ptr)

declare i64 @VarI1FromStr(ptr, i64, i64, ptr)

declare i64 @VarI1FromDisp(ptr, i64, ptr)

declare i64 @VarI1FromBool(i64, ptr)

declare i64 @VarI1FromUI2(i64, ptr)

declare i64 @VarI1FromUI4(i64, ptr)

declare i64 @VarI1FromUI8(i64, ptr)

declare i64 @VarI1FromDec(ptr, ptr)

declare i64 @VarUI2FromUI1(i64, ptr)

declare i64 @VarUI2FromI2(i64, ptr)

declare i64 @VarUI2FromI4(i64, ptr)

declare i64 @VarUI2FromI8(i64, ptr)

declare i64 @VarUI2FromR4(float, ptr)

declare i64 @VarUI2FromR8(double, ptr)

declare i64 @VarUI2FromDate(double, ptr)

declare i64 @VarUI2FromCy(i64, ptr)

declare i64 @VarUI2FromStr(ptr, i64, i64, ptr)

declare i64 @VarUI2FromDisp(ptr, i64, ptr)

declare i64 @VarUI2FromBool(i64, ptr)

declare i64 @VarUI2FromI1(i64, ptr)

declare i64 @VarUI2FromUI4(i64, ptr)

declare i64 @VarUI2FromUI8(i64, ptr)

declare i64 @VarUI2FromDec(ptr, ptr)

declare i64 @VarUI4FromUI1(i64, ptr)

declare i64 @VarUI4FromI2(i64, ptr)

declare i64 @VarUI4FromI4(i64, ptr)

declare i64 @VarUI4FromI8(i64, ptr)

declare i64 @VarUI4FromR4(float, ptr)

declare i64 @VarUI4FromR8(double, ptr)

declare i64 @VarUI4FromDate(double, ptr)

declare i64 @VarUI4FromCy(i64, ptr)

declare i64 @VarUI4FromStr(ptr, i64, i64, ptr)

declare i64 @VarUI4FromDisp(ptr, i64, ptr)

declare i64 @VarUI4FromBool(i64, ptr)

declare i64 @VarUI4FromI1(i64, ptr)

declare i64 @VarUI4FromUI2(i64, ptr)

declare i64 @VarUI4FromUI8(i64, ptr)

declare i64 @VarUI4FromDec(ptr, ptr)

declare i64 @VarUI8FromUI1(i64, ptr)

declare i64 @VarUI8FromI2(i64, ptr)

declare i64 @VarUI8FromI4(i64, ptr)

declare i64 @VarUI8FromI8(i64, ptr)

declare i64 @VarUI8FromR4(float, ptr)

declare i64 @VarUI8FromR8(double, ptr)

declare i64 @VarUI8FromCy(i64, ptr)

declare i64 @VarUI8FromDate(double, ptr)

declare i64 @VarUI8FromStr(ptr, i64, i64, ptr)

declare i64 @VarUI8FromDisp(ptr, i64, ptr)

declare i64 @VarUI8FromBool(i64, ptr)

declare i64 @VarUI8FromI1(i64, ptr)

declare i64 @VarUI8FromUI2(i64, ptr)

declare i64 @VarUI8FromUI4(i64, ptr)

declare i64 @VarUI8FromDec(ptr, ptr)

declare i64 @VarDecFromUI1(i64, ptr)

declare i64 @VarDecFromI2(i64, ptr)

declare i64 @VarDecFromI4(i64, ptr)

declare i64 @VarDecFromI8(i64, ptr)

declare i64 @VarDecFromR4(float, ptr)

declare i64 @VarDecFromR8(double, ptr)

declare i64 @VarDecFromDate(double, ptr)

declare i64 @VarDecFromCy(i64, ptr)

declare i64 @VarDecFromStr(ptr, i64, i64, ptr)

declare i64 @VarDecFromDisp(ptr, i64, ptr)

declare i64 @VarDecFromBool(i64, ptr)

declare i64 @VarDecFromI1(i64, ptr)

declare i64 @VarDecFromUI2(i64, ptr)

declare i64 @VarDecFromUI4(i64, ptr)

declare i64 @VarDecFromUI8(i64, ptr)

declare i64 @VarParseNumFromStr(ptr, i64, i64, ptr, ptr)

declare i64 @VarNumFromParseNum(ptr, ptr, i64, ptr)

declare i64 @VarAdd(ptr, ptr, ptr)

declare i64 @VarAnd(ptr, ptr, ptr)

declare i64 @VarCat(ptr, ptr, ptr)

declare i64 @VarDiv(ptr, ptr, ptr)

declare i64 @VarEqv(ptr, ptr, ptr)

declare i64 @VarIdiv(ptr, ptr, ptr)

declare i64 @VarImp(ptr, ptr, ptr)

declare i64 @VarMod(ptr, ptr, ptr)

declare i64 @VarMul(ptr, ptr, ptr)

declare i64 @VarOr(ptr, ptr, ptr)

declare i64 @VarPow(ptr, ptr, ptr)

declare i64 @VarSub(ptr, ptr, ptr)

declare i64 @VarXor(ptr, ptr, ptr)

declare i64 @VarAbs(ptr, ptr)

declare i64 @VarFix(ptr, ptr)

declare i64 @VarInt(ptr, ptr)

declare i64 @VarNeg(ptr, ptr)

declare i64 @VarNot(ptr, ptr)

declare i64 @VarRound(ptr, i32, ptr)

declare i64 @VarCmp(ptr, ptr, i64, i64)

declare i64 @VarDecAdd(ptr, ptr, ptr)

declare i64 @VarDecDiv(ptr, ptr, ptr)

declare i64 @VarDecMul(ptr, ptr, ptr)

declare i64 @VarDecSub(ptr, ptr, ptr)

declare i64 @VarDecAbs(ptr, ptr)

declare i64 @VarDecFix(ptr, ptr)

declare i64 @VarDecInt(ptr, ptr)

declare i64 @VarDecNeg(ptr, ptr)

declare i64 @VarDecRound(ptr, i32, ptr)

declare i64 @VarDecCmp(ptr, ptr)

declare i64 @VarDecCmpR8(ptr, double)

declare i64 @VarCyAdd(i64, i64, ptr)

declare i64 @VarCyMul(i64, i64, ptr)

declare i64 @VarCyMulI4(i64, i64, ptr)

declare i64 @VarCyMulI8(i64, i64, ptr)

declare i64 @VarCySub(i64, i64, ptr)

declare i64 @VarCyAbs(i64, ptr)

declare i64 @VarCyFix(i64, ptr)

declare i64 @VarCyInt(i64, ptr)

declare i64 @VarCyNeg(i64, ptr)

declare i64 @VarCyRound(i64, i32, ptr)

declare i64 @VarCyCmp(i64, i64)

declare i64 @VarCyCmpR8(i64, double)

declare i64 @VarBstrCat(ptr, ptr, ptr)

declare i64 @VarBstrCmp(ptr, ptr, i64, i64)

declare i64 @VarR8Pow(double, double, ptr)

declare i64 @VarR4CmpR8(float, double)

declare i64 @VarR8Round(double, i32, ptr)

declare i64 @VarDateFromUdate(ptr, i64, ptr)

declare i64 @VarDateFromUdateEx(ptr, i64, i64, ptr)

declare i64 @VarUdateFromDate(double, i64, ptr)

declare i64 @GetAltMonthNames(i64, ptr)

declare i64 @VarFormat(ptr, ptr, i32, i32, i64, ptr)

declare i64 @VarFormatDateTime(ptr, i32, i64, ptr)

declare i64 @VarFormatNumber(ptr, i32, i32, i32, i32, i64, ptr)

declare i64 @VarFormatPercent(ptr, i32, i32, i32, i32, i64, ptr)

declare i64 @VarFormatCurrency(ptr, i32, i32, i32, i32, i64, ptr)

declare i64 @VarWeekdayName(i32, i32, i32, i64, ptr)

declare i64 @VarMonthName(i32, i32, i64, ptr)

declare i64 @VarFormatFromTokens(ptr, ptr, ptr, i64, ptr, i64)

declare i64 @VarTokenizeFormatString(ptr, ptr, i32, i32, i32, i64, ptr)

declare i64 @LHashValOfNameSysA(i64, i64, ptr)

declare i64 @LHashValOfNameSys(i64, i64, ptr)

declare i64 @LoadTypeLib(ptr, ptr)

declare i64 @LoadTypeLibEx(ptr, i64, ptr)

declare i64 @LoadRegTypeLib(ptr, i64, i64, i64, ptr)

declare i64 @QueryPathOfRegTypeLib(ptr, i64, i64, i64, ptr)

declare i64 @RegisterTypeLib(ptr, ptr, ptr)

declare i64 @UnRegisterTypeLib(ptr, i64, i64, i64, i64)

declare i64 @RegisterTypeLibForUser(ptr, ptr, ptr)

declare i64 @UnRegisterTypeLibForUser(ptr, i64, i64, i64, i64)

declare i64 @CreateTypeLib(i64, ptr, ptr)

declare i64 @CreateTypeLib2(i64, ptr, ptr)

declare i64 @DispGetParam(ptr, i64, i64, ptr, ptr)

declare i64 @DispGetIDsOfNames(ptr, ptr, i64, ptr)

declare i64 @DispInvoke(ptr, ptr, i64, i64, ptr, ptr, ptr, ptr)

declare i64 @CreateDispTypeInfo(ptr, i64, ptr)

declare i64 @CreateStdDispatch(ptr, ptr, ptr, ptr)

declare i64 @DispCallFunc(ptr, i64, i64, i64, i64, ptr, ptr, ptr)

declare i64 @RegisterActiveObject(ptr, ptr, i64, ptr)

declare i64 @RevokeActiveObject(i64, ptr)

declare i64 @GetActiveObject(ptr, ptr, ptr)

declare i64 @SetErrorInfo(i64, ptr)

declare i64 @GetErrorInfo(i64, ptr)

declare i64 @CreateErrorInfo(ptr)

declare i64 @GetRecordInfoFromTypeInfo(ptr, ptr)

declare i64 @GetRecordInfoFromGuids(ptr, i64, i64, i64, ptr, ptr)

declare i64 @OaBuildVersion()

declare void @ClearCustData(ptr)

declare void @OaEnablePerUserTLibRegistration()

declare i64 @OleBuildVersion()

declare i64 @WriteFmtUserTypeStg(ptr, i64, ptr)

declare i64 @ReadFmtUserTypeStg(ptr, ptr, ptr)

declare i64 @OleInitialize(ptr)

declare void @OleUninitialize()

declare i64 @OleQueryLinkFromData(ptr)

declare i64 @OleQueryCreateFromData(ptr)

declare i64 @OleCreate(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @OleCreateEx(ptr, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @OleCreateFromData(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @OleCreateFromDataEx(ptr, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @OleCreateLinkFromData(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @OleCreateLinkFromDataEx(ptr, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @OleCreateStaticFromData(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @OleCreateLink(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @OleCreateLinkEx(ptr, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @OleCreateLinkToFile(ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @OleCreateLinkToFileEx(ptr, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @OleCreateFromFile(ptr, ptr, ptr, i64, ptr, ptr, ptr, ptr)

declare i64 @OleCreateFromFileEx(ptr, ptr, ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @OleLoad(ptr, ptr, ptr, ptr)

declare i64 @OleSave(ptr, ptr, i32)

declare i64 @OleLoadFromStream(ptr, ptr, ptr)

declare i64 @OleSaveToStream(ptr, ptr)

declare i64 @OleSetContainedObject(ptr, i32)

declare i64 @OleNoteObjectVisible(ptr, i32)

declare i64 @RegisterDragDrop(ptr, ptr)

declare i64 @RevokeDragDrop(ptr)

declare i64 @DoDragDrop(ptr, ptr, i64, ptr)

declare i64 @OleSetClipboard(ptr)

declare i64 @OleGetClipboard(ptr)

declare i64 @OleGetClipboardWithEnterpriseInfo(ptr, ptr, ptr, ptr, ptr)

declare i64 @OleFlushClipboard()

declare i64 @OleIsCurrentClipboard(ptr)

declare ptr @OleCreateMenuDescriptor(ptr, ptr)

declare i64 @OleSetMenuDescriptor(ptr, ptr, ptr, ptr, ptr)

declare i64 @OleDestroyMenuDescriptor(ptr)

declare i64 @OleTranslateAccelerator(ptr, ptr, ptr)

declare ptr @OleDuplicateData(ptr, i64, i64)

declare i64 @OleDraw(ptr, i64, ptr, ptr)

declare i64 @OleRun(ptr)

declare i32 @OleIsRunning(ptr)

declare i64 @OleLockRunning(ptr, i32, i32)

declare void @ReleaseStgMedium(ptr)

declare i64 @CreateOleAdviseHolder(ptr)

declare i64 @OleCreateDefaultHandler(ptr, ptr, ptr, ptr)

declare i64 @OleCreateEmbeddingHelper(ptr, ptr, i64, ptr, ptr, ptr)

declare i32 @IsAccelerator(ptr, i32, ptr, ptr)

declare ptr @OleGetIconOfFile(ptr, i32)

declare ptr @OleGetIconOfClass(ptr, ptr, i32)

declare ptr @OleMetafilePictFromIconAndLabel(ptr, ptr, ptr, i64)

declare i64 @OleRegGetUserType(ptr, i64, ptr)

declare i64 @OleRegGetMiscStatus(ptr, i64, ptr)

declare i64 @OleRegEnumFormatEtc(ptr, i64, ptr)

declare i64 @OleRegEnumVerbs(ptr, ptr)

declare i64 @OleConvertOLESTREAMToIStorage(ptr, ptr, ptr)

declare i64 @OleConvertOLESTREAMToIStorage2(ptr, ptr, ptr, i64, ptr, ptr)

declare i64 @OleConvertIStorageToOLESTREAM(ptr, ptr)

declare i64 @OleDoAutoConvert(ptr, ptr)

declare i64 @OleGetAutoConvert(ptr, ptr)

declare i64 @OleSetAutoConvert(ptr, ptr)

declare i64 @SetConvertStg(ptr, i32)

declare i64 @OleConvertIStorageToOLESTREAMEx(ptr, i64, i64, i64, i64, ptr, ptr)

declare i64 @OleConvertOLESTREAMToIStorageEx(ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i64 @OleConvertOLESTREAMToIStorageEx2(ptr, ptr, ptr, ptr, ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @GetOpenFileNameA(ptr)

declare i32 @GetOpenFileNameW(ptr)

declare i32 @GetSaveFileNameA(ptr)

declare i32 @GetSaveFileNameW(ptr)

declare i64 @GetFileTitleA(ptr, ptr, i64)

declare i64 @GetFileTitleW(ptr, ptr, i64)

declare i32 @ChooseColorA(ptr)

declare i32 @ChooseColorW(ptr)

declare ptr @FindTextA(ptr)

declare ptr @FindTextW(ptr)

declare ptr @ReplaceTextA(ptr)

declare ptr @ReplaceTextW(ptr)

declare i32 @ChooseFontA(ptr)

declare i32 @ChooseFontW(ptr)

declare i32 @PrintDlgA(ptr)

declare i32 @PrintDlgW(ptr)

declare i64 @PrintDlgExA(ptr)

declare i64 @PrintDlgExW(ptr)

declare i64 @CommDlgExtendedError()

declare i32 @PageSetupDlgA(ptr)

declare i32 @PageSetupDlgW(ptr)

declare ptr @uaw_CharUpperW(ptr)

declare i32 @uaw_lstrcmpW(ptr, ptr)

declare i32 @uaw_lstrcmpiW(ptr, ptr)

declare i32 @uaw_lstrlenW(ptr)

declare ptr @uaw_wcschr(ptr, i64)

declare ptr @uaw_wcscpy(ptr, ptr)

declare i32 @uaw_wcsicmp(ptr, ptr)

declare i64 @uaw_wcslen(ptr)

declare ptr @uaw_wcsrchr(ptr, i64)

declare ptr @ua_CharUpperW(ptr)

declare i32 @ua_lstrcmpW(ptr, ptr)

declare i32 @ua_lstrcmpiW(ptr, ptr)

declare i32 @ua_lstrlenW(ptr)

declare ptr @ua_wcschr(ptr, i64)

declare ptr @ua_wcsrchr(ptr, i64)

declare ptr @ua_wcscpy(ptr, ptr)

declare ptr @ua_wcscpy_s(ptr, i64, ptr)

declare i64 @ua_wcslen(ptr)

declare i32 @ua_wcsicmp(ptr, ptr)

declare i32 @ChangeServiceConfigA(ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @ChangeServiceConfigW(ptr, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @ChangeServiceConfig2A(ptr, i64, ptr)

declare i32 @ChangeServiceConfig2W(ptr, i64, ptr)

declare i32 @CloseServiceHandle(ptr)

declare i32 @ControlService(ptr, i64, ptr)

declare ptr @CreateServiceA(ptr, ptr, ptr, i64, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare ptr @CreateServiceW(ptr, ptr, ptr, i64, i64, i64, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @DeleteService(ptr)

declare i32 @EnumDependentServicesA(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumDependentServicesW(ptr, i64, ptr, i64, ptr, ptr)

declare i32 @EnumServicesStatusA(ptr, i64, i64, ptr, i64, ptr, ptr, ptr)

declare i32 @EnumServicesStatusW(ptr, i64, i64, ptr, i64, ptr, ptr, ptr)

declare i32 @EnumServicesStatusExA(ptr, i64, i64, i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @EnumServicesStatusExW(ptr, i64, i64, i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @GetServiceKeyNameA(ptr, ptr, ptr, ptr)

declare i32 @GetServiceKeyNameW(ptr, ptr, ptr, ptr)

declare i32 @GetServiceDisplayNameA(ptr, ptr, ptr, ptr)

declare i32 @GetServiceDisplayNameW(ptr, ptr, ptr, ptr)

declare ptr @LockServiceDatabase(ptr)

declare i32 @NotifyBootConfigStatus(i32)

declare ptr @OpenSCManagerA(ptr, ptr, i64)

declare ptr @OpenSCManagerW(ptr, ptr, i64)

declare ptr @OpenServiceA(ptr, ptr, i64)

declare ptr @OpenServiceW(ptr, ptr, i64)

declare i32 @QueryServiceConfigA(ptr, ptr, i64, ptr)

declare i32 @QueryServiceConfigW(ptr, ptr, i64, ptr)

declare i32 @QueryServiceConfig2A(ptr, i64, ptr, i64, ptr)

declare i32 @QueryServiceConfig2W(ptr, i64, ptr, i64, ptr)

declare i32 @QueryServiceLockStatusA(ptr, ptr, i64, ptr)

declare i32 @QueryServiceLockStatusW(ptr, ptr, i64, ptr)

declare i32 @QueryServiceObjectSecurity(ptr, i64, ptr, i64, ptr)

declare i32 @QueryServiceStatus(ptr, ptr)

declare i32 @QueryServiceStatusEx(ptr, i64, ptr, i64, ptr)

declare ptr @RegisterServiceCtrlHandlerA(ptr, ptr)

declare ptr @RegisterServiceCtrlHandlerW(ptr, ptr)

declare ptr @RegisterServiceCtrlHandlerExA(ptr, ptr, ptr)

declare ptr @RegisterServiceCtrlHandlerExW(ptr, ptr, ptr)

declare i32 @SetServiceObjectSecurity(ptr, i64, ptr)

declare i32 @SetServiceStatus(ptr, ptr)

declare i32 @StartServiceCtrlDispatcherA(ptr)

declare i32 @StartServiceCtrlDispatcherW(ptr)

declare i32 @StartServiceA(ptr, i64, ptr)

declare i32 @StartServiceW(ptr, i64, ptr)

declare i32 @UnlockServiceDatabase(ptr)

declare i64 @NotifyServiceStatusChangeA(ptr, i64, ptr)

declare i64 @NotifyServiceStatusChangeW(ptr, i64, ptr)

declare i32 @ControlServiceExA(ptr, i64, i64, ptr)

declare i32 @ControlServiceExW(ptr, i64, i64, ptr)

declare i32 @QueryServiceDynamicInformation(ptr, i64, ptr)

declare i64 @SubscribeServiceChangeNotifications(ptr, i64, ptr, ptr, ptr)

declare void @UnsubscribeServiceChangeNotifications(ptr)

declare i64 @WaitServiceState(ptr, i64, i64, ptr)

declare i64 @GetServiceRegistryStateKey(ptr, i64, i64, ptr)

declare i64 @GetServiceDirectory(ptr, i64, ptr, i64, ptr)

declare i64 @GetSharedServiceRegistryStateKey(ptr, i64, i64, ptr)

declare i64 @GetSharedServiceDirectory(ptr, i64, ptr, i64, ptr)

declare ptr @ImmInstallIMEA(ptr, ptr)

declare ptr @ImmInstallIMEW(ptr, ptr)

declare ptr @ImmGetDefaultIMEWnd(ptr)

declare i64 @ImmGetDescriptionA(ptr, ptr, i64)

declare i64 @ImmGetDescriptionW(ptr, ptr, i64)

declare i64 @ImmGetIMEFileNameA(ptr, ptr, i64)

declare i64 @ImmGetIMEFileNameW(ptr, ptr, i64)

declare i64 @ImmGetProperty(ptr, i64)

declare i32 @ImmIsIME(ptr)

declare i32 @ImmSimulateHotKey(ptr, i64)

declare ptr @ImmCreateContext()

declare i32 @ImmDestroyContext(ptr)

declare ptr @ImmGetContext(ptr)

declare i32 @ImmReleaseContext(ptr, ptr)

declare ptr @ImmAssociateContext(ptr, ptr)

declare i32 @ImmAssociateContextEx(ptr, ptr, i64)

declare i64 @ImmGetCompositionStringA(ptr, i64, ptr, i64)

declare i64 @ImmGetCompositionStringW(ptr, i64, ptr, i64)

declare i32 @ImmSetCompositionStringA(ptr, i64, ptr, i64, ptr, i64)

declare i32 @ImmSetCompositionStringW(ptr, i64, ptr, i64, ptr, i64)

declare i64 @ImmGetCandidateListCountA(ptr, ptr)

declare i64 @ImmGetCandidateListCountW(ptr, ptr)

declare i64 @ImmGetCandidateListA(ptr, i64, ptr, i64)

declare i64 @ImmGetCandidateListW(ptr, i64, ptr, i64)

declare i64 @ImmGetGuideLineA(ptr, i64, ptr, i64)

declare i64 @ImmGetGuideLineW(ptr, i64, ptr, i64)

declare i32 @ImmGetConversionStatus(ptr, ptr, ptr)

declare i32 @ImmSetConversionStatus(ptr, i64, i64)

declare i32 @ImmGetOpenStatus(ptr)

declare i32 @ImmSetOpenStatus(ptr, i32)

declare i32 @ImmGetCompositionFontA(ptr, ptr)

declare i32 @ImmGetCompositionFontW(ptr, ptr)

declare i32 @ImmSetCompositionFontA(ptr, ptr)

declare i32 @ImmSetCompositionFontW(ptr, ptr)

declare i32 @ImmConfigureIMEA(ptr, ptr, i64, ptr)

declare i32 @ImmConfigureIMEW(ptr, ptr, i64, ptr)

declare i64 @ImmEscapeA(ptr, ptr, i64, ptr)

declare i64 @ImmEscapeW(ptr, ptr, i64, ptr)

declare i64 @ImmGetConversionListA(ptr, ptr, ptr, ptr, i64, i64)

declare i64 @ImmGetConversionListW(ptr, ptr, ptr, ptr, i64, i64)

declare i32 @ImmNotifyIME(ptr, i64, i64, i64)

declare i32 @ImmGetStatusWindowPos(ptr, ptr)

declare i32 @ImmSetStatusWindowPos(ptr, ptr)

declare i32 @ImmGetCompositionWindow(ptr, ptr)

declare i32 @ImmSetCompositionWindow(ptr, ptr)

declare i32 @ImmGetCandidateWindow(ptr, i64, ptr)

declare i32 @ImmSetCandidateWindow(ptr, ptr)

declare i32 @ImmIsUIMessageA(ptr, i64, i64, i64)

declare i32 @ImmIsUIMessageW(ptr, i64, i64, i64)

declare i64 @ImmGetVirtualKey(ptr)

declare i32 @ImmRegisterWordA(ptr, ptr, i64, ptr)

declare i32 @ImmRegisterWordW(ptr, ptr, i64, ptr)

declare i32 @ImmUnregisterWordA(ptr, ptr, i64, ptr)

declare i32 @ImmUnregisterWordW(ptr, ptr, i64, ptr)

declare i64 @ImmGetRegisterWordStyleA(ptr, i64, ptr)

declare i64 @ImmGetRegisterWordStyleW(ptr, i64, ptr)

declare i64 @ImmEnumRegisterWordA(ptr, ptr, ptr, i64, ptr, ptr)

declare i64 @ImmEnumRegisterWordW(ptr, ptr, ptr, i64, ptr, ptr)

declare i32 @ImmDisableIME(i64)

declare i32 @ImmEnumInputContext(i64, ptr, i64)

declare i64 @ImmGetImeMenuItemsA(ptr, i64, i64, ptr, ptr, i64)

declare i64 @ImmGetImeMenuItemsW(ptr, i64, i64, ptr, ptr, i64)

declare i32 @ImmDisableTextFrameService(i64)

declare i32 @ImmDisableLegacyIME()

declare i32 @__WSAFDIsSet(i64, ptr)

declare i64 @accept(i64, ptr, ptr)

declare i32 @bind(i64, ptr, i32)

declare i32 @closesocket(i64)

declare i32 @connect(i64, ptr, i32)

declare i32 @ioctlsocket(i64, i64, ptr)

declare i32 @getpeername(i64, ptr, ptr)

declare i32 @getsockname(i64, ptr, ptr)

declare i32 @getsockopt(i64, i32, i32, ptr, ptr)

declare i64 @htonl(i64)

declare i64 @htons(i64)

declare i64 @inet_addr(ptr)

declare ptr @inet_ntoa(i64)

declare i64 @htonll(i64)

declare i64 @ntohll(i64)

declare i64 @htonf(float)

declare float @ntohf(i64)

declare i64 @htond(double)

declare double @ntohd(i64)

declare i32 @listen(i64, i32)

declare i64 @ntohl(i64)

declare i64 @ntohs(i64)

declare i32 @recv(i64, ptr, i32, i32)

declare i32 @recvfrom(i64, ptr, i32, i32, ptr, ptr)

declare i32 @select(i32, ptr, ptr, ptr, ptr)

declare i32 @send(i64, ptr, i32, i32)

declare i32 @sendto(i64, ptr, i32, i32, ptr, i32)

declare i32 @setsockopt(i64, i32, i32, ptr, i32)

declare i32 @shutdown(i64, i32)

declare i64 @socket(i32, i32, i32)

declare ptr @gethostbyaddr(ptr, i32, i32)

declare ptr @gethostbyname(ptr)

declare i32 @gethostname(ptr, i32)

declare i32 @GetHostNameW(ptr, i32)

declare ptr @getservbyport(i32, ptr)

declare ptr @getservbyname(ptr, ptr)

declare ptr @getprotobynumber(i32)

declare ptr @getprotobyname(ptr)

declare i32 @WSAStartup(i64, ptr)

declare i32 @WSACleanup()

declare void @WSASetLastError(i32)

declare i32 @WSAGetLastError()

declare i32 @WSAIsBlocking()

declare i32 @WSAUnhookBlockingHook()

declare ptr @WSASetBlockingHook(ptr)

declare i32 @WSACancelBlockingCall()

declare ptr @WSAAsyncGetServByName(ptr, i64, ptr, ptr, ptr, i32)

declare ptr @WSAAsyncGetServByPort(ptr, i64, i32, ptr, ptr, i32)

declare ptr @WSAAsyncGetProtoByName(ptr, i64, ptr, ptr, i32)

declare ptr @WSAAsyncGetProtoByNumber(ptr, i64, i32, ptr, i32)

declare ptr @WSAAsyncGetHostByName(ptr, i64, ptr, ptr, i32)

declare ptr @WSAAsyncGetHostByAddr(ptr, i64, ptr, i32, i32, ptr, i32)

declare i32 @WSACancelAsyncRequest(ptr)

declare i32 @WSAAsyncSelect(i64, ptr, i64, i64)

declare i64 @WSAAccept(i64, ptr, ptr, ptr, i64)

declare i32 @WSACloseEvent(ptr)

declare i32 @WSAConnect(i64, ptr, i32, ptr, ptr, ptr, ptr)

declare i32 @WSAConnectByNameW(i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @WSAConnectByNameA(i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @WSAConnectByList(i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare ptr @WSACreateEvent()

declare i32 @WSADuplicateSocketA(i64, i64, ptr)

declare i32 @WSADuplicateSocketW(i64, i64, ptr)

declare i32 @WSAEnumNetworkEvents(i64, ptr, ptr)

declare i32 @WSAEnumProtocolsA(ptr, ptr, ptr)

declare i32 @WSAEnumProtocolsW(ptr, ptr, ptr)

declare i32 @WSAEventSelect(i64, ptr, i64)

declare i32 @WSAGetOverlappedResult(i64, ptr, ptr, i32, ptr)

declare i32 @WSAGetQOSByName(i64, ptr, ptr)

declare i32 @WSAHtonl(i64, i64, ptr)

declare i32 @WSAHtons(i64, i64, ptr)

declare i32 @WSAIoctl(i64, i64, ptr, i64, ptr, i64, ptr, ptr, ptr)

declare i64 @WSAJoinLeaf(i64, ptr, i32, ptr, ptr, ptr, ptr, i64)

declare i32 @WSANtohl(i64, i64, ptr)

declare i32 @WSANtohs(i64, i64, ptr)

declare i32 @WSARecv(i64, ptr, i64, ptr, ptr, ptr, ptr)

declare i32 @WSARecvDisconnect(i64, ptr)

declare i32 @WSARecvFrom(i64, ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @WSAResetEvent(ptr)

declare i32 @WSASend(i64, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @WSASendMsg(i64, ptr, i64, ptr, ptr, ptr)

declare i32 @WSASendDisconnect(i64, ptr)

declare i32 @WSASendTo(i64, ptr, i64, ptr, i64, ptr, i32, ptr, ptr)

declare i32 @WSASetEvent(ptr)

declare i64 @WSASocketA(i32, i32, i32, ptr, i64, i64)

declare i64 @WSASocketW(i32, i32, i32, ptr, i64, i64)

declare i64 @WSAWaitForMultipleEvents(i64, ptr, i32, i64, i32)

declare i32 @WSAAddressToStringA(ptr, i64, ptr, ptr, ptr)

declare i32 @WSAAddressToStringW(ptr, i64, ptr, ptr, ptr)

declare i32 @WSAStringToAddressA(ptr, i32, ptr, ptr, ptr)

declare i32 @WSAStringToAddressW(ptr, i32, ptr, ptr, ptr)

declare i32 @WSALookupServiceBeginA(ptr, i64, ptr)

declare i32 @WSALookupServiceBeginW(ptr, i64, ptr)

declare i32 @WSALookupServiceNextA(ptr, i64, ptr, ptr)

declare i32 @WSALookupServiceNextW(ptr, i64, ptr, ptr)

declare i32 @WSANSPIoctl(ptr, i64, ptr, i64, ptr, i64, ptr, ptr)

declare i32 @WSALookupServiceEnd(ptr)

declare i32 @WSAInstallServiceClassA(ptr)

declare i32 @WSAInstallServiceClassW(ptr)

declare i32 @WSARemoveServiceClass(ptr)

declare i32 @WSAGetServiceClassInfoA(ptr, ptr, ptr, ptr)

declare i32 @WSAGetServiceClassInfoW(ptr, ptr, ptr, ptr)

declare i32 @WSAEnumNameSpaceProvidersA(ptr, ptr)

declare i32 @WSAEnumNameSpaceProvidersW(ptr, ptr)

declare i32 @WSAEnumNameSpaceProvidersExA(ptr, ptr)

declare i32 @WSAEnumNameSpaceProvidersExW(ptr, ptr)

declare i32 @WSAGetServiceClassNameByClassIdA(ptr, ptr, ptr)

declare i32 @WSAGetServiceClassNameByClassIdW(ptr, ptr, ptr)

declare i32 @WSASetServiceA(ptr, i64, i64)

declare i32 @WSASetServiceW(ptr, i64, i64)

declare i32 @WSAProviderConfigChange(ptr, ptr, ptr)

declare i32 @WSAPoll(ptr, i64, i32)

declare i64 @ProcessSocketNotifications(ptr, i64, ptr, i64, i64, ptr, ptr)

declare i64 @SocketNotificationRetrieveEvents(ptr)

declare i64 @IN6_ADDR_EQUAL(ptr, ptr)

declare i64 @IN6_IS_ADDR_UNSPECIFIED(ptr)

declare i64 @IN6_IS_ADDR_LOOPBACK(ptr)

declare i64 @IN6_IS_ADDR_MULTICAST(ptr)

declare i64 @IN6_IS_ADDR_EUI64(ptr)

declare i64 @IN6_IS_ADDR_SUBNET_ROUTER_ANYCAST(ptr)

declare i64 @IN6_IS_ADDR_SUBNET_RESERVED_ANYCAST(ptr)

declare i64 @IN6_IS_ADDR_ANYCAST(ptr)

declare i64 @IN6_IS_ADDR_LINKLOCAL(ptr)

declare i64 @IN6_IS_ADDR_SITELOCAL(ptr)

declare i64 @IN6_IS_ADDR_GLOBAL(ptr)

declare i64 @IN6_IS_ADDR_V4MAPPED(ptr)

declare i64 @IN6_IS_ADDR_V4COMPAT(ptr)

declare i64 @IN6_IS_ADDR_V4TRANSLATED(ptr)

declare i64 @IN6_IS_ADDR_MC_NODELOCAL(ptr)

declare i64 @IN6_IS_ADDR_MC_LINKLOCAL(ptr)

declare i64 @IN6_IS_ADDR_MC_SITELOCAL(ptr)

declare i64 @IN6_IS_ADDR_MC_ORGLOCAL(ptr)

declare i64 @IN6_IS_ADDR_MC_GLOBAL(ptr)

declare void @IN6_SET_ADDR_UNSPECIFIED(ptr)

declare void @IN6_SET_ADDR_LOOPBACK(ptr)

declare void @IN6ADDR_SETANY(ptr)

declare void @IN6ADDR_SETLOOPBACK(ptr)

declare i64 @IN6ADDR_ISANY(ptr)

declare i64 @IN6ADDR_ISLOOPBACK(ptr)

declare i64 @IN6ADDR_ISEQUAL(ptr, ptr)

declare i64 @IN6ADDR_ISUNSPECIFIED(ptr)

declare i32 @getaddrinfo(ptr, ptr, ptr, ptr)

declare i32 @GetAddrInfoW(ptr, ptr, ptr, ptr)

declare i32 @GetAddrInfoExA(ptr, ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @GetAddrInfoExW(ptr, ptr, i64, ptr, ptr, ptr, ptr, ptr, ptr, ptr)

declare i32 @GetAddrInfoExCancel(ptr)

declare i32 @GetAddrInfoExOverlappedResult(ptr)

declare i32 @SetAddrInfoExA(ptr, ptr, ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare i32 @SetAddrInfoExW(ptr, ptr, ptr, i64, ptr, i64, i64, ptr, ptr, ptr, ptr, ptr)

declare void @freeaddrinfo(ptr)

declare void @FreeAddrInfoW(ptr)

declare void @FreeAddrInfoEx(ptr)

declare void @FreeAddrInfoExW(ptr)

declare i32 @getnameinfo(ptr, i32, ptr, i64, ptr, i64, i32)

declare i32 @GetNameInfoW(ptr, i32, ptr, i64, ptr, i64, i32)

declare i32 @inet_pton(i32, ptr, ptr)

declare i32 @InetPtonW(i32, ptr, ptr)

declare ptr @inet_ntop(i32, ptr, ptr, i64)

declare ptr @InetNtopW(i32, ptr, ptr, i64)

declare ptr @gai_strerrorA(i32)

declare ptr @gai_strerrorW(i32)

declare i32 @setipv4sourcefilter(i64, i64, i64, i64, i64, ptr)

declare i32 @getipv4sourcefilter(i64, i64, i64, ptr, ptr, ptr)

declare i32 @setsourcefilter(i64, i64, ptr, i32, i64, i64, ptr)

declare i32 @getsourcefilter(i64, i64, ptr, i32, ptr, ptr, ptr)

declare i32 @idealsendbacklogquery(i64, ptr)

declare i32 @idealsendbacklognotify(i64, ptr, ptr)

declare i32 @WSAGetIPUserMtu(i64, ptr)

declare i32 @WSASetIPUserMtu(i64, i64)

declare i32 @WSAGetFailConnectOnIcmpError(i64, ptr)

declare i32 @WSASetFailConnectOnIcmpError(i64, i64)

declare i32 @WSAGetIcmpErrorInfo(i64, ptr)

declare i32 @WSAGetUdpSendMessageSize(i64, ptr)

declare i32 @WSASetUdpSendMessageSize(i64, i64)

declare i32 @WSAGetUdpRecvMaxCoalescedSize(i64, ptr)

declare i32 @WSASetUdpRecvMaxCoalescedSize(i64, i64)

declare i32 @WSAGetRecvIPEcn(i64, ptr)

declare i32 @WSASetRecvIPEcn(i64, i64)

declare i32 @WSAGetReceivedProcessorOption(i64, ptr)

declare i32 @WSASetReceivedProcessorOption(i64, i64)

declare ptr @meteor_http_server_create()

declare i32 @meteor_http_server_set_host(ptr, ptr)

declare i32 @meteor_http_server_set_port(ptr, i32)

declare i32 @meteor_http_server_set_static_dir(ptr, ptr)

declare i32 @meteor_http_server_route(ptr, i32, ptr, ptr, ptr)

declare i32 @meteor_http_server_listen(ptr)

declare i32 @meteor_http_server_bind(ptr)

declare ptr @meteor_http_server_accept(ptr)

declare ptr @meteor_http_connection_read_request(ptr)

declare i32 @meteor_http_connection_send_response(ptr, ptr)

declare void @meteor_http_connection_close(ptr)

declare i32 @meteor_http_server_start(ptr)

declare i32 @meteor_http_server_stop(ptr)

declare void @meteor_http_server_destroy(ptr)

declare ptr @meteor_http_client_create()

declare i32 @meteor_http_client_set_timeout(ptr, i32)

declare i32 @meteor_http_client_set_header(ptr, ptr, ptr)

declare ptr @meteor_http_client_request(ptr, i32, ptr, ptr, i64)

declare void @meteor_http_response_free(ptr)

declare void @meteor_http_request_free(ptr)

declare void @meteor_http_client_destroy(ptr)

declare ptr @meteor_http_get(ptr)

declare ptr @meteor_http_post(ptr, ptr, i64)

declare void @meteor_http_response_init(ptr)

declare i32 @meteor_http_response_set_status(ptr, i32)

declare i32 @meteor_http_response_set_header(ptr, ptr, ptr)

declare i32 @meteor_http_response_set_body(ptr, ptr, i64)

declare i32 @meteor_http_response_set_json(ptr, ptr)

declare i32 @meteor_http_response_set_html(ptr, ptr)

declare i32 @meteor_http_response_set_text(ptr, ptr)

declare ptr @meteor_url_encode(ptr)

declare ptr @meteor_url_decode(ptr)

declare ptr @meteor_http_status_message(i32)

declare i32 @meteor_parse_query_string(ptr, ptr, i32)

declare i32 @meteor_request_get_method(ptr)

declare ptr @meteor_request_get_path(ptr)

declare ptr @meteor_request_get_query(ptr)

declare ptr @meteor_request_get_body(ptr)

declare ptr @meteor_request_get_header(ptr, ptr)

declare ptr @meteor_request_get_param(ptr, ptr)

declare i32 @meteor_request_get_header_count(ptr)

declare ptr @meteor_request_get_header_name_at(ptr, i32)

declare ptr @meteor_request_get_header_value_at(ptr, i32)

declare ptr @meteor_http_response_create()

define void @Header.new(ptr %self, ptr %name, ptr %value) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %name.1 = alloca ptr, align 8
  store ptr %name, ptr %name.1, align 8
  %value.1 = alloca ptr, align 8
  store ptr %value, ptr %value.1, align 8
  %.8 = load ptr, ptr %name.1, align 8
  %.9 = icmp eq ptr %.8, null
  br i1 %.9, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif
  ret void

entry.if:                                         ; preds = %entry
  %.11 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.11, align 1
  %.13 = getelementptr [32 x i8], ptr %.11, i64 0, i64 0
  %.14 = bitcast ptr %.13 to ptr
  %.15 = call i64 @puts(ptr %.14)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.18 = load ptr, ptr %self.1, align 8
  %.19 = getelementptr inbounds %Header, ptr %.18, i32 0, i32 0
  %.20 = load ptr, ptr %name.1, align 8
  %.21 = icmp eq ptr %.20, null
  br i1 %.21, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.23 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.23, align 1
  %.25 = getelementptr [32 x i8], ptr %.23, i64 0, i64 0
  %.26 = bitcast ptr %.25 to ptr
  %.27 = call i64 @puts(ptr %.26)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.30 = bitcast ptr %.20 to ptr
  call void @meteor_retain(ptr %.30)
  store ptr %.20, ptr %.19, align 8
  %.33 = load ptr, ptr %value.1, align 8
  %.34 = icmp eq ptr %.33, null
  br i1 %.34, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.36 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.36, align 1
  %.38 = getelementptr [32 x i8], ptr %.36, i64 0, i64 0
  %.39 = bitcast ptr %.38 to ptr
  %.40 = call i64 @puts(ptr %.39)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  %.43 = load ptr, ptr %self.1, align 8
  %.44 = getelementptr inbounds %Header, ptr %.43, i32 0, i32 1
  %.45 = load ptr, ptr %value.1, align 8
  %.46 = icmp eq ptr %.45, null
  br i1 %.46, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.48 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.48, align 1
  %.50 = getelementptr [32 x i8], ptr %.48, i64 0, i64 0
  %.51 = bitcast ptr %.50 to ptr
  %.52 = call i64 @puts(ptr %.51)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  %.55 = bitcast ptr %.45 to ptr
  call void @meteor_retain(ptr %.55)
  store ptr %.45, ptr %.44, align 8
  br label %exit
}

define internal void @__destroy_Header__(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

exit:                                             ; preds = %continue_value, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr inbounds %Header, ptr %.1, i32 0, i32 0
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %continue_name, label %release_name

release_name:                                     ; preds = %not_null
  %.9 = bitcast ptr %.6 to ptr
  call void @meteor_release(ptr %.9)
  br label %continue_name

continue_name:                                    ; preds = %release_name, %not_null
  %.12 = getelementptr inbounds %Header, ptr %.1, i32 0, i32 1
  %.13 = load ptr, ptr %.12, align 8
  %.14 = icmp eq ptr %.13, null
  br i1 %.14, label %continue_value, label %release_value

release_value:                                    ; preds = %continue_name
  %.16 = bitcast ptr %.13 to ptr
  call void @meteor_release(ptr %.16)
  br label %continue_value

continue_value:                                   ; preds = %release_value, %continue_name
  br label %exit
}

define void @Header.array.init(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Header.array, ptr %.5, i32 0, i32 1
  store i64 0, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %Header.array, ptr %.8, i32 0, i32 2
  store i64 16, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %Header.array, ptr %.11, i32 0, i32 3
  %.13 = load i64, ptr %.9, align 4
  %.14 = add i64 %.13, 1
  %.15 = mul i64 %.14, 8
  %.16 = call ptr @malloc(i64 %.15)
  %.17 = bitcast ptr %.16 to ptr
  store ptr %.17, ptr %.12, align 8
  %.19 = load ptr, ptr %.3, align 8
  %.20 = getelementptr inbounds %Header.array, ptr %.19, i32 0, i32 0
  %.21 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 0
  store i32 1, ptr %.21, align 4
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define void @Header.array.double_capacity_if_full(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Header.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %Header.array, ptr %.8, i32 0, i32 2
  %.10 = load i64, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %Header.array, ptr %.11, i32 0, i32 3
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

define void @Header.array.append(ptr %self, ptr %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca ptr, align 8
  store ptr %.2, ptr %.6, align 8
  %.8 = load ptr, ptr %.4, align 8
  call void @Header.array.double_capacity_if_full(ptr %.8)
  %.10 = load ptr, ptr %.4, align 8
  %.11 = getelementptr inbounds %Header.array, ptr %.10, i32 0, i32 1
  %.12 = load i64, ptr %.11, align 4
  %.13 = load ptr, ptr %.4, align 8
  %.14 = getelementptr inbounds %Header.array, ptr %.13, i32 0, i32 3
  %.15 = load ptr, ptr %.14, align 8
  %.16 = getelementptr inbounds ptr, ptr %.15, i64 %.12
  %.17 = load ptr, ptr %.6, align 8
  store ptr %.17, ptr %.16, align 8
  %.19 = add i64 %.12, 1
  store i64 %.19, ptr %.11, align 4
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define ptr @Header.array.get(ptr %self, i64 %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca i64, align 8
  store i64 %.2, ptr %.6, align 4
  %.8 = load i64, ptr %.6, align 4
  %.9 = load ptr, ptr %.4, align 8
  %.10 = getelementptr inbounds %Header.array, ptr %.9, i32 0, i32 1
  %.11 = load i64, ptr %.10, align 4
  %.12 = icmp sge i64 %.8, %.11
  br i1 %.12, label %index_out_of_bounds, label %is_index_less_than_zero

exit:                                             ; preds = %get
  %.27 = load ptr, ptr %.25, align 8
  ret ptr %.27

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
  %.22 = getelementptr inbounds %Header.array, ptr %.21, i32 0, i32 3
  %.23 = load i64, ptr %.6, align 4
  %.24 = load ptr, ptr %.22, align 8
  %.25 = getelementptr inbounds ptr, ptr %.24, i64 %.23
  br label %exit
}

define void @Header.array.set(ptr %self, i64 %.2, ptr %.3) {
entry:
  %.5 = alloca ptr, align 8
  store ptr %self, ptr %.5, align 8
  %.7 = alloca i64, align 8
  store i64 %.2, ptr %.7, align 4
  %.9 = alloca ptr, align 8
  store ptr %.3, ptr %.9, align 8
  %.11 = load i64, ptr %.7, align 4
  %.12 = load ptr, ptr %.5, align 8
  %.13 = getelementptr inbounds %Header.array, ptr %.12, i32 0, i32 1
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
  %.30 = getelementptr inbounds %Header.array, ptr %.29, i32 0, i32 3
  %.31 = load i64, ptr %.7, align 4
  %.32 = load ptr, ptr %.30, align 8
  %.33 = getelementptr inbounds ptr, ptr %.32, i64 %.31
  %.34 = load ptr, ptr %.9, align 8
  store ptr %.34, ptr %.33, align 8
  br label %exit
}

define i64 @Header.array.length(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Header.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  ret i64 %.7
}

define void @Request.new(ptr %self) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %.4 = alloca %HttpMethod, align 8
  %.5 = getelementptr inbounds %HttpMethod, ptr %.4, i32 0, i32 0
  store i8 0, ptr %.5, align 1
  %.7 = load ptr, ptr %self.1, align 8
  %.8 = getelementptr inbounds %Request, ptr %.7, i32 0, i32 0
  %.9 = alloca %HttpMethod, align 8
  %.10 = getelementptr inbounds %HttpMethod, ptr %.9, i32 0, i32 0
  store i8 0, ptr %.10, align 1
  store ptr %.9, ptr %.8, align 8
  %.13 = call ptr @malloc(i64 40)
  %.14 = bitcast ptr %.13 to ptr
  call void @i64.array.init(ptr %.14)
  call void @i64.array.append(ptr %.14, i64 47)
  %.17 = load ptr, ptr %self.1, align 8
  %.18 = getelementptr inbounds %Request, ptr %.17, i32 0, i32 1
  %.19 = call ptr @malloc(i64 40)
  %.20 = bitcast ptr %.19 to ptr
  call void @i64.array.init(ptr %.20)
  call void @i64.array.append(ptr %.20, i64 47)
  %.23 = bitcast ptr %.20 to ptr
  call void @meteor_retain(ptr %.23)
  store ptr %.20, ptr %.18, align 8
  %.26 = call ptr @malloc(i64 40)
  %.27 = bitcast ptr %.26 to ptr
  call void @i64.array.init(ptr %.27)
  %.29 = load ptr, ptr %self.1, align 8
  %.30 = getelementptr inbounds %Request, ptr %.29, i32 0, i32 2
  %.31 = call ptr @malloc(i64 40)
  %.32 = bitcast ptr %.31 to ptr
  call void @i64.array.init(ptr %.32)
  %.34 = bitcast ptr %.32 to ptr
  call void @meteor_retain(ptr %.34)
  store ptr %.32, ptr %.30, align 8
  %.37 = call ptr @malloc(i64 40)
  %.38 = bitcast ptr %.37 to ptr
  call void @i64.array.init(ptr %.38)
  %.40 = load ptr, ptr %self.1, align 8
  %.41 = getelementptr inbounds %Request, ptr %.40, i32 0, i32 3
  %.42 = call ptr @malloc(i64 40)
  %.43 = bitcast ptr %.42 to ptr
  call void @i64.array.init(ptr %.43)
  %.45 = bitcast ptr %.43 to ptr
  call void @meteor_retain(ptr %.45)
  store ptr %.43, ptr %.41, align 8
  %.48 = call ptr @malloc(i64 40)
  %.49 = bitcast ptr %.48 to ptr
  call void @i64.array.init(ptr %.49)
  %.51 = load ptr, ptr %self.1, align 8
  %.52 = getelementptr inbounds %Request, ptr %.51, i32 0, i32 4
  %.53 = call ptr @malloc(i64 40)
  %.54 = bitcast ptr %.53 to ptr
  call void @Header.array.init(ptr %.54)
  %.56 = bitcast ptr %.54 to ptr
  call void @meteor_retain(ptr %.56)
  store ptr %.54, ptr %.52, align 8
  %.59 = call ptr @malloc(i64 40)
  %.60 = bitcast ptr %.59 to ptr
  call void @i64.array.init(ptr %.60)
  %.62 = load ptr, ptr %self.1, align 8
  %.63 = getelementptr inbounds %Request, ptr %.62, i32 0, i32 5
  %.64 = call ptr @malloc(i64 40)
  %.65 = bitcast ptr %.64 to ptr
  call void @Header.array.init(ptr %.65)
  %.67 = bitcast ptr %.65 to ptr
  call void @meteor_retain(ptr %.67)
  store ptr %.65, ptr %.63, align 8
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define ptr @Request.get_header(ptr %self, ptr %name) {
entry:
  %h = alloca ptr, align 8
  %i = alloca i64, align 8
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %name.1 = alloca ptr, align 8
  store ptr %name, ptr %name.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  store i64 0, ptr %i, align 4
  br label %while.cond

exit:                                             ; preds = %rc_release_continue.3, %rc_release_continue
  %.152 = load ptr, ptr %ret_var, align 8
  %.153 = icmp eq ptr %.152, null
  br i1 %.153, label %exit.if, label %exit.endif

while.cond:                                       ; preds = %rc_release_continue.1, %entry
  %.9 = load i64, ptr %i, align 4
  %.10 = load ptr, ptr %self.1, align 8
  %.11 = icmp eq ptr %.10, null
  br i1 %.11, label %while.cond.if, label %while.cond.endif

while.body:                                       ; preds = %while.cond.endif
  %.24 = load i64, ptr %i, align 4
  %.25 = load ptr, ptr %self.1, align 8
  %.26 = icmp eq ptr %.25, null
  br i1 %.26, label %while.body.if, label %while.body.endif

while.end:                                        ; preds = %while.cond.endif
  %.131 = call ptr @malloc(i64 40)
  %.132 = bitcast ptr %.131 to ptr
  call void @i64.array.init(ptr %.132)
  %.134 = load ptr, ptr %ret_var, align 8
  %.135 = bitcast ptr %.132 to ptr
  call void @meteor_retain(ptr %.135)
  %.137 = icmp eq ptr %.134, null
  br i1 %.137, label %rc_release_continue.2, label %rc_release.2

while.cond.if:                                    ; preds = %while.cond
  %.13 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.13, align 1
  %.15 = getelementptr [32 x i8], ptr %.13, i64 0, i64 0
  %.16 = bitcast ptr %.15 to ptr
  %.17 = call i64 @puts(ptr %.16)
  call void @abort()
  unreachable

while.cond.endif:                                 ; preds = %while.cond
  %.20 = load %Request, ptr %.10, align 8
  %.21 = extractvalue %Request %.20, 4
  %.22 = call i64 @Header.array.length(ptr %.21)
  %cmptmp = icmp slt i64 %.9, %.22
  br i1 %cmptmp, label %while.body, label %while.end

while.body.if:                                    ; preds = %while.body
  %.28 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.28, align 1
  %.30 = getelementptr [32 x i8], ptr %.28, i64 0, i64 0
  %.31 = bitcast ptr %.30 to ptr
  %.32 = call i64 @puts(ptr %.31)
  call void @abort()
  unreachable

while.body.endif:                                 ; preds = %while.body
  %.35 = load %Request, ptr %.25, align 8
  %.36 = extractvalue %Request %.35, 4
  %.37 = call ptr @Header.array.get(ptr %.36, i64 %.24)
  store ptr %.37, ptr %h, align 8
  br label %if.start

if.start:                                         ; preds = %while.body.endif
  %.40 = load ptr, ptr %h, align 8
  %.41 = icmp eq ptr %.40, null
  br i1 %.41, label %if.start.if, label %if.start.endif

if.end:                                           ; preds = %str_eq.end
  %.107 = load i64, ptr %i, align 4
  %addtmp = add i64 %.107, 1
  store i64 %addtmp, ptr %i, align 4
  %.109 = load ptr, ptr %h, align 8
  %.110 = icmp eq ptr %.109, null
  br i1 %.110, label %rc_release_continue.1, label %rc_release.1

if.true.0:                                        ; preds = %str_eq.end
  %.83 = load ptr, ptr %h, align 8
  %.84 = icmp eq ptr %.83, null
  br i1 %.84, label %if.true.0.if, label %if.true.0.endif

if.start.if:                                      ; preds = %if.start
  %.43 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.43, align 1
  %.45 = getelementptr [32 x i8], ptr %.43, i64 0, i64 0
  %.46 = bitcast ptr %.45 to ptr
  %.47 = call i64 @puts(ptr %.46)
  call void @abort()
  unreachable

if.start.endif:                                   ; preds = %if.start
  %.50 = load %Header, ptr %.40, align 8
  %.51 = extractvalue %Header %.50, 0
  %.52 = load ptr, ptr %name.1, align 8
  %.53 = icmp eq ptr %.52, null
  br i1 %.53, label %if.start.endif.if, label %if.start.endif.endif

if.start.endif.if:                                ; preds = %if.start.endif
  %.55 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.55, align 1
  %.57 = getelementptr [32 x i8], ptr %.55, i64 0, i64 0
  %.58 = bitcast ptr %.57 to ptr
  %.59 = call i64 @puts(ptr %.58)
  call void @abort()
  unreachable

if.start.endif.endif:                             ; preds = %if.start.endif
  %left_len = call i64 @i64.array.length(ptr %.51)
  %right_len = call i64 @i64.array.length(ptr %.52)
  %str_eq_result = alloca i1, align 1
  br label %str_eq.len_check

str_eq.len_check:                                 ; preds = %if.start.endif.endif
  %.63 = icmp eq i64 %left_len, %right_len
  br i1 %.63, label %str_eq.compare, label %str_eq.len_mismatch

str_eq.len_mismatch:                              ; preds = %str_eq.len_check
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.compare:                                   ; preds = %str_eq.len_check
  %i_cmp = alloca i64, align 8
  store i64 0, ptr %i_cmp, align 4
  br label %str_eq.loop_cond

str_eq.loop_cond:                                 ; preds = %str_eq.loop_body, %str_eq.compare
  %.69 = load i64, ptr %i_cmp, align 4
  %.70 = icmp slt i64 %.69, %left_len
  br i1 %.70, label %str_eq.loop_body, label %str_eq.strings_equal

str_eq.loop_body:                                 ; preds = %str_eq.loop_cond
  %.72 = load i64, ptr %i_cmp, align 4
  %l_char = call i64 @i64.array.get(ptr %.51, i64 %.72)
  %r_char = call i64 @i64.array.get(ptr %.52, i64 %.72)
  %.73 = icmp eq i64 %l_char, %r_char
  %.74 = add i64 %.72, 1
  store i64 %.74, ptr %i_cmp, align 4
  br i1 %.73, label %str_eq.loop_cond, label %str_eq.char_mismatch

str_eq.char_mismatch:                             ; preds = %str_eq.loop_body
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.strings_equal:                             ; preds = %str_eq.loop_cond
  store i1 true, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.end:                                       ; preds = %str_eq.strings_equal, %str_eq.char_mismatch, %str_eq.len_mismatch
  %.81 = load i1, ptr %str_eq_result, align 1
  br i1 %.81, label %if.true.0, label %if.end

if.true.0.if:                                     ; preds = %if.true.0
  %.86 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.86, align 1
  %.88 = getelementptr [32 x i8], ptr %.86, i64 0, i64 0
  %.89 = bitcast ptr %.88 to ptr
  %.90 = call i64 @puts(ptr %.89)
  call void @abort()
  unreachable

if.true.0.endif:                                  ; preds = %if.true.0
  %.93 = load %Header, ptr %.83, align 8
  %.94 = extractvalue %Header %.93, 1
  %.95 = load ptr, ptr %ret_var, align 8
  %.96 = bitcast ptr %.94 to ptr
  call void @meteor_retain(ptr %.96)
  %.98 = icmp eq ptr %.95, null
  br i1 %.98, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %if.true.0.endif
  %.100 = bitcast ptr %.95 to ptr
  call void @meteor_release(ptr %.100)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %if.true.0.endif
  store ptr %.94, ptr %ret_var, align 8
  %.104 = bitcast ptr %.94 to ptr
  call void @meteor_retain(ptr %.104)
  br label %exit

rc_release.1:                                     ; preds = %if.end
  %.112 = bitcast ptr %.109 to ptr
  %.113 = getelementptr i8, ptr %.112, i64 -16
  %.114 = bitcast ptr %.113 to ptr
  %.115 = getelementptr %meteor.header, ptr %.114, i64 0, i32 0
  %.116 = load i32, ptr %.115, align 4
  %.117 = icmp eq i32 %.116, 1
  br i1 %.117, label %rc_destroy, label %rc_release_only

rc_release_continue.1:                            ; preds = %rc_release_only, %rc_destroy, %if.end
  br label %while.cond

rc_destroy:                                       ; preds = %rc_release.1
  call void @__destroy_Header__(ptr %.109)
  %.120 = bitcast ptr %.109 to ptr
  %.121 = getelementptr i8, ptr %.120, i64 -16
  %.122 = bitcast ptr %.121 to ptr
  call void @meteor_release(ptr %.122)
  br label %rc_release_continue.1

rc_release_only:                                  ; preds = %rc_release.1
  %.125 = bitcast ptr %.109 to ptr
  %.126 = getelementptr i8, ptr %.125, i64 -16
  %.127 = bitcast ptr %.126 to ptr
  call void @meteor_release(ptr %.127)
  br label %rc_release_continue.1

rc_release.2:                                     ; preds = %while.end
  %.139 = bitcast ptr %.134 to ptr
  call void @meteor_release(ptr %.139)
  br label %rc_release_continue.2

rc_release_continue.2:                            ; preds = %rc_release.2, %while.end
  store ptr %.132, ptr %ret_var, align 8
  %.143 = bitcast ptr %.132 to ptr
  call void @meteor_retain(ptr %.143)
  %.145 = load ptr, ptr %ret_var, align 8
  %.146 = icmp eq ptr %.145, null
  br i1 %.146, label %rc_release_continue.3, label %rc_release.3

rc_release.3:                                     ; preds = %rc_release_continue.2
  %.148 = bitcast ptr %.145 to ptr
  call void @meteor_release(ptr %.148)
  br label %rc_release_continue.3

rc_release_continue.3:                            ; preds = %rc_release.3, %rc_release_continue.2
  br label %exit

exit.if:                                          ; preds = %exit
  %.155 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.155, align 1
  %.157 = getelementptr [32 x i8], ptr %.155, i64 0, i64 0
  %.158 = bitcast ptr %.157 to ptr
  %.159 = call i64 @puts(ptr %.158)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.152
}

define ptr @Request.get_param(ptr %self, ptr %name) {
entry:
  %p = alloca ptr, align 8
  %i = alloca i64, align 8
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %name.1 = alloca ptr, align 8
  store ptr %name, ptr %name.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  store i64 0, ptr %i, align 4
  br label %while.cond

exit:                                             ; preds = %rc_release_continue.3, %rc_release_continue
  %.152 = load ptr, ptr %ret_var, align 8
  %.153 = icmp eq ptr %.152, null
  br i1 %.153, label %exit.if, label %exit.endif

while.cond:                                       ; preds = %rc_release_continue.1, %entry
  %.9 = load i64, ptr %i, align 4
  %.10 = load ptr, ptr %self.1, align 8
  %.11 = icmp eq ptr %.10, null
  br i1 %.11, label %while.cond.if, label %while.cond.endif

while.body:                                       ; preds = %while.cond.endif
  %.24 = load i64, ptr %i, align 4
  %.25 = load ptr, ptr %self.1, align 8
  %.26 = icmp eq ptr %.25, null
  br i1 %.26, label %while.body.if, label %while.body.endif

while.end:                                        ; preds = %while.cond.endif
  %.131 = call ptr @malloc(i64 40)
  %.132 = bitcast ptr %.131 to ptr
  call void @i64.array.init(ptr %.132)
  %.134 = load ptr, ptr %ret_var, align 8
  %.135 = bitcast ptr %.132 to ptr
  call void @meteor_retain(ptr %.135)
  %.137 = icmp eq ptr %.134, null
  br i1 %.137, label %rc_release_continue.2, label %rc_release.2

while.cond.if:                                    ; preds = %while.cond
  %.13 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.13, align 1
  %.15 = getelementptr [32 x i8], ptr %.13, i64 0, i64 0
  %.16 = bitcast ptr %.15 to ptr
  %.17 = call i64 @puts(ptr %.16)
  call void @abort()
  unreachable

while.cond.endif:                                 ; preds = %while.cond
  %.20 = load %Request, ptr %.10, align 8
  %.21 = extractvalue %Request %.20, 5
  %.22 = call i64 @Header.array.length(ptr %.21)
  %cmptmp = icmp slt i64 %.9, %.22
  br i1 %cmptmp, label %while.body, label %while.end

while.body.if:                                    ; preds = %while.body
  %.28 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.28, align 1
  %.30 = getelementptr [32 x i8], ptr %.28, i64 0, i64 0
  %.31 = bitcast ptr %.30 to ptr
  %.32 = call i64 @puts(ptr %.31)
  call void @abort()
  unreachable

while.body.endif:                                 ; preds = %while.body
  %.35 = load %Request, ptr %.25, align 8
  %.36 = extractvalue %Request %.35, 5
  %.37 = call ptr @Header.array.get(ptr %.36, i64 %.24)
  store ptr %.37, ptr %p, align 8
  br label %if.start

if.start:                                         ; preds = %while.body.endif
  %.40 = load ptr, ptr %p, align 8
  %.41 = icmp eq ptr %.40, null
  br i1 %.41, label %if.start.if, label %if.start.endif

if.end:                                           ; preds = %str_eq.end
  %.107 = load i64, ptr %i, align 4
  %addtmp = add i64 %.107, 1
  store i64 %addtmp, ptr %i, align 4
  %.109 = load ptr, ptr %p, align 8
  %.110 = icmp eq ptr %.109, null
  br i1 %.110, label %rc_release_continue.1, label %rc_release.1

if.true.0:                                        ; preds = %str_eq.end
  %.83 = load ptr, ptr %p, align 8
  %.84 = icmp eq ptr %.83, null
  br i1 %.84, label %if.true.0.if, label %if.true.0.endif

if.start.if:                                      ; preds = %if.start
  %.43 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.43, align 1
  %.45 = getelementptr [32 x i8], ptr %.43, i64 0, i64 0
  %.46 = bitcast ptr %.45 to ptr
  %.47 = call i64 @puts(ptr %.46)
  call void @abort()
  unreachable

if.start.endif:                                   ; preds = %if.start
  %.50 = load %Header, ptr %.40, align 8
  %.51 = extractvalue %Header %.50, 0
  %.52 = load ptr, ptr %name.1, align 8
  %.53 = icmp eq ptr %.52, null
  br i1 %.53, label %if.start.endif.if, label %if.start.endif.endif

if.start.endif.if:                                ; preds = %if.start.endif
  %.55 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.55, align 1
  %.57 = getelementptr [32 x i8], ptr %.55, i64 0, i64 0
  %.58 = bitcast ptr %.57 to ptr
  %.59 = call i64 @puts(ptr %.58)
  call void @abort()
  unreachable

if.start.endif.endif:                             ; preds = %if.start.endif
  %left_len = call i64 @i64.array.length(ptr %.51)
  %right_len = call i64 @i64.array.length(ptr %.52)
  %str_eq_result = alloca i1, align 1
  br label %str_eq.len_check

str_eq.len_check:                                 ; preds = %if.start.endif.endif
  %.63 = icmp eq i64 %left_len, %right_len
  br i1 %.63, label %str_eq.compare, label %str_eq.len_mismatch

str_eq.len_mismatch:                              ; preds = %str_eq.len_check
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.compare:                                   ; preds = %str_eq.len_check
  %i_cmp = alloca i64, align 8
  store i64 0, ptr %i_cmp, align 4
  br label %str_eq.loop_cond

str_eq.loop_cond:                                 ; preds = %str_eq.loop_body, %str_eq.compare
  %.69 = load i64, ptr %i_cmp, align 4
  %.70 = icmp slt i64 %.69, %left_len
  br i1 %.70, label %str_eq.loop_body, label %str_eq.strings_equal

str_eq.loop_body:                                 ; preds = %str_eq.loop_cond
  %.72 = load i64, ptr %i_cmp, align 4
  %l_char = call i64 @i64.array.get(ptr %.51, i64 %.72)
  %r_char = call i64 @i64.array.get(ptr %.52, i64 %.72)
  %.73 = icmp eq i64 %l_char, %r_char
  %.74 = add i64 %.72, 1
  store i64 %.74, ptr %i_cmp, align 4
  br i1 %.73, label %str_eq.loop_cond, label %str_eq.char_mismatch

str_eq.char_mismatch:                             ; preds = %str_eq.loop_body
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.strings_equal:                             ; preds = %str_eq.loop_cond
  store i1 true, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.end:                                       ; preds = %str_eq.strings_equal, %str_eq.char_mismatch, %str_eq.len_mismatch
  %.81 = load i1, ptr %str_eq_result, align 1
  br i1 %.81, label %if.true.0, label %if.end

if.true.0.if:                                     ; preds = %if.true.0
  %.86 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.86, align 1
  %.88 = getelementptr [32 x i8], ptr %.86, i64 0, i64 0
  %.89 = bitcast ptr %.88 to ptr
  %.90 = call i64 @puts(ptr %.89)
  call void @abort()
  unreachable

if.true.0.endif:                                  ; preds = %if.true.0
  %.93 = load %Header, ptr %.83, align 8
  %.94 = extractvalue %Header %.93, 1
  %.95 = load ptr, ptr %ret_var, align 8
  %.96 = bitcast ptr %.94 to ptr
  call void @meteor_retain(ptr %.96)
  %.98 = icmp eq ptr %.95, null
  br i1 %.98, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %if.true.0.endif
  %.100 = bitcast ptr %.95 to ptr
  call void @meteor_release(ptr %.100)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %if.true.0.endif
  store ptr %.94, ptr %ret_var, align 8
  %.104 = bitcast ptr %.94 to ptr
  call void @meteor_retain(ptr %.104)
  br label %exit

rc_release.1:                                     ; preds = %if.end
  %.112 = bitcast ptr %.109 to ptr
  %.113 = getelementptr i8, ptr %.112, i64 -16
  %.114 = bitcast ptr %.113 to ptr
  %.115 = getelementptr %meteor.header, ptr %.114, i64 0, i32 0
  %.116 = load i32, ptr %.115, align 4
  %.117 = icmp eq i32 %.116, 1
  br i1 %.117, label %rc_destroy, label %rc_release_only

rc_release_continue.1:                            ; preds = %rc_release_only, %rc_destroy, %if.end
  br label %while.cond

rc_destroy:                                       ; preds = %rc_release.1
  call void @__destroy_Header__(ptr %.109)
  %.120 = bitcast ptr %.109 to ptr
  %.121 = getelementptr i8, ptr %.120, i64 -16
  %.122 = bitcast ptr %.121 to ptr
  call void @meteor_release(ptr %.122)
  br label %rc_release_continue.1

rc_release_only:                                  ; preds = %rc_release.1
  %.125 = bitcast ptr %.109 to ptr
  %.126 = getelementptr i8, ptr %.125, i64 -16
  %.127 = bitcast ptr %.126 to ptr
  call void @meteor_release(ptr %.127)
  br label %rc_release_continue.1

rc_release.2:                                     ; preds = %while.end
  %.139 = bitcast ptr %.134 to ptr
  call void @meteor_release(ptr %.139)
  br label %rc_release_continue.2

rc_release_continue.2:                            ; preds = %rc_release.2, %while.end
  store ptr %.132, ptr %ret_var, align 8
  %.143 = bitcast ptr %.132 to ptr
  call void @meteor_retain(ptr %.143)
  %.145 = load ptr, ptr %ret_var, align 8
  %.146 = icmp eq ptr %.145, null
  br i1 %.146, label %rc_release_continue.3, label %rc_release.3

rc_release.3:                                     ; preds = %rc_release_continue.2
  %.148 = bitcast ptr %.145 to ptr
  call void @meteor_release(ptr %.148)
  br label %rc_release_continue.3

rc_release_continue.3:                            ; preds = %rc_release.3, %rc_release_continue.2
  br label %exit

exit.if:                                          ; preds = %exit
  %.155 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.155, align 1
  %.157 = getelementptr [32 x i8], ptr %.155, i64 0, i64 0
  %.158 = bitcast ptr %.157 to ptr
  %.159 = call i64 @puts(ptr %.158)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.152
}

define ptr @Request.content_type(ptr %self) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.5 = load ptr, ptr %self.1, align 8
  %.6 = call ptr @malloc(i64 40)
  %.7 = bitcast ptr %.6 to ptr
  call void @i64.array.init(ptr %.7)
  call void @i64.array.append(ptr %.7, i64 67)
  call void @i64.array.append(ptr %.7, i64 111)
  call void @i64.array.append(ptr %.7, i64 110)
  call void @i64.array.append(ptr %.7, i64 116)
  call void @i64.array.append(ptr %.7, i64 101)
  call void @i64.array.append(ptr %.7, i64 110)
  call void @i64.array.append(ptr %.7, i64 116)
  call void @i64.array.append(ptr %.7, i64 45)
  call void @i64.array.append(ptr %.7, i64 84)
  call void @i64.array.append(ptr %.7, i64 121)
  call void @i64.array.append(ptr %.7, i64 112)
  call void @i64.array.append(ptr %.7, i64 101)
  %.21 = call ptr @Request.get_header(ptr %.5, ptr %.7)
  %.22 = load ptr, ptr %ret_var, align 8
  %.23 = bitcast ptr %.21 to ptr
  call void @meteor_retain(ptr %.23)
  %.25 = icmp eq ptr %.22, null
  br i1 %.25, label %rc_release_continue, label %rc_release

exit:                                             ; preds = %rc_release_continue.1
  %.40 = load ptr, ptr %ret_var, align 8
  %.41 = icmp eq ptr %.40, null
  br i1 %.41, label %exit.if, label %exit.endif

rc_release:                                       ; preds = %entry
  %.27 = bitcast ptr %.22 to ptr
  call void @meteor_release(ptr %.27)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %entry
  store ptr %.21, ptr %ret_var, align 8
  %.31 = bitcast ptr %.21 to ptr
  call void @meteor_retain(ptr %.31)
  %.33 = load ptr, ptr %ret_var, align 8
  %.34 = icmp eq ptr %.33, null
  br i1 %.34, label %rc_release_continue.1, label %rc_release.1

rc_release.1:                                     ; preds = %rc_release_continue
  %.36 = bitcast ptr %.33 to ptr
  call void @meteor_release(ptr %.36)
  br label %rc_release_continue.1

rc_release_continue.1:                            ; preds = %rc_release.1, %rc_release_continue
  br label %exit

exit.if:                                          ; preds = %exit
  %.43 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.43, align 1
  %.45 = getelementptr [32 x i8], ptr %.43, i64 0, i64 0
  %.46 = bitcast ptr %.45 to ptr
  %.47 = call i64 @puts(ptr %.46)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.40
}

define i1 @Request.is_json(ptr %self) {
entry:
  %ct = alloca ptr, align 8
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %ret_var = alloca i1, align 1
  %.4 = load ptr, ptr %self.1, align 8
  %.5 = call ptr @Request.content_type(ptr %.4)
  store ptr %.5, ptr %ct, align 8
  %.7 = load ptr, ptr %ct, align 8
  %.8 = icmp eq ptr %.7, null
  br i1 %.8, label %entry.if, label %entry.endif

exit:                                             ; preds = %rc_release_continue
  %.64 = load i1, ptr %ret_var, align 1
  ret i1 %.64

entry.if:                                         ; preds = %entry
  %.10 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.10, align 1
  %.12 = getelementptr [32 x i8], ptr %.10, i64 0, i64 0
  %.13 = bitcast ptr %.12 to ptr
  %.14 = call i64 @puts(ptr %.13)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.17 = call ptr @malloc(i64 40)
  %.18 = bitcast ptr %.17 to ptr
  call void @i64.array.init(ptr %.18)
  call void @i64.array.append(ptr %.18, i64 97)
  call void @i64.array.append(ptr %.18, i64 112)
  call void @i64.array.append(ptr %.18, i64 112)
  call void @i64.array.append(ptr %.18, i64 108)
  call void @i64.array.append(ptr %.18, i64 105)
  call void @i64.array.append(ptr %.18, i64 99)
  call void @i64.array.append(ptr %.18, i64 97)
  call void @i64.array.append(ptr %.18, i64 116)
  call void @i64.array.append(ptr %.18, i64 105)
  call void @i64.array.append(ptr %.18, i64 111)
  call void @i64.array.append(ptr %.18, i64 110)
  call void @i64.array.append(ptr %.18, i64 47)
  call void @i64.array.append(ptr %.18, i64 106)
  call void @i64.array.append(ptr %.18, i64 115)
  call void @i64.array.append(ptr %.18, i64 111)
  call void @i64.array.append(ptr %.18, i64 110)
  %left_len = call i64 @i64.array.length(ptr %.7)
  %right_len = call i64 @i64.array.length(ptr %.18)
  %str_eq_result = alloca i1, align 1
  br label %str_eq.len_check

str_eq.len_check:                                 ; preds = %entry.endif
  %.37 = icmp eq i64 %left_len, %right_len
  br i1 %.37, label %str_eq.compare, label %str_eq.len_mismatch

str_eq.len_mismatch:                              ; preds = %str_eq.len_check
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.compare:                                   ; preds = %str_eq.len_check
  %i_cmp = alloca i64, align 8
  store i64 0, ptr %i_cmp, align 4
  br label %str_eq.loop_cond

str_eq.loop_cond:                                 ; preds = %str_eq.loop_body, %str_eq.compare
  %.43 = load i64, ptr %i_cmp, align 4
  %.44 = icmp slt i64 %.43, %left_len
  br i1 %.44, label %str_eq.loop_body, label %str_eq.strings_equal

str_eq.loop_body:                                 ; preds = %str_eq.loop_cond
  %.46 = load i64, ptr %i_cmp, align 4
  %l_char = call i64 @i64.array.get(ptr %.7, i64 %.46)
  %r_char = call i64 @i64.array.get(ptr %.18, i64 %.46)
  %.47 = icmp eq i64 %l_char, %r_char
  %.48 = add i64 %.46, 1
  store i64 %.48, ptr %i_cmp, align 4
  br i1 %.47, label %str_eq.loop_cond, label %str_eq.char_mismatch

str_eq.char_mismatch:                             ; preds = %str_eq.loop_body
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.strings_equal:                             ; preds = %str_eq.loop_cond
  store i1 true, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.end:                                       ; preds = %str_eq.strings_equal, %str_eq.char_mismatch, %str_eq.len_mismatch
  %.55 = load i1, ptr %str_eq_result, align 1
  store i1 %.55, ptr %ret_var, align 1
  %.57 = load ptr, ptr %ct, align 8
  %.58 = icmp eq ptr %.57, null
  br i1 %.58, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %str_eq.end
  %.60 = bitcast ptr %.57 to ptr
  call void @meteor_release(ptr %.60)
  br label %rc_release_continue

rc_release_continue:                              ; preds = %rc_release, %str_eq.end
  br label %exit
}

define internal void @__destroy_Request__(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

exit:                                             ; preds = %continue_params, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr inbounds %Request, ptr %.1, i32 0, i32 1
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %continue_path, label %release_path

release_path:                                     ; preds = %not_null
  %.9 = bitcast ptr %.6 to ptr
  call void @meteor_release(ptr %.9)
  br label %continue_path

continue_path:                                    ; preds = %release_path, %not_null
  %.12 = getelementptr inbounds %Request, ptr %.1, i32 0, i32 2
  %.13 = load ptr, ptr %.12, align 8
  %.14 = icmp eq ptr %.13, null
  br i1 %.14, label %continue_query, label %release_query

release_query:                                    ; preds = %continue_path
  %.16 = bitcast ptr %.13 to ptr
  call void @meteor_release(ptr %.16)
  br label %continue_query

continue_query:                                   ; preds = %release_query, %continue_path
  %.19 = getelementptr inbounds %Request, ptr %.1, i32 0, i32 3
  %.20 = load ptr, ptr %.19, align 8
  %.21 = icmp eq ptr %.20, null
  br i1 %.21, label %continue_body, label %release_body

release_body:                                     ; preds = %continue_query
  %.23 = bitcast ptr %.20 to ptr
  call void @meteor_release(ptr %.23)
  br label %continue_body

continue_body:                                    ; preds = %release_body, %continue_query
  %.26 = getelementptr inbounds %Request, ptr %.1, i32 0, i32 4
  %.27 = load ptr, ptr %.26, align 8
  %.28 = icmp eq ptr %.27, null
  br i1 %.28, label %continue_headers, label %release_headers

release_headers:                                  ; preds = %continue_body
  %.30 = bitcast ptr %.27 to ptr
  call void @meteor_release(ptr %.30)
  br label %continue_headers

continue_headers:                                 ; preds = %release_headers, %continue_body
  %.33 = getelementptr inbounds %Request, ptr %.1, i32 0, i32 5
  %.34 = load ptr, ptr %.33, align 8
  %.35 = icmp eq ptr %.34, null
  br i1 %.35, label %continue_params, label %release_params

release_params:                                   ; preds = %continue_headers
  %.37 = bitcast ptr %.34 to ptr
  call void @meteor_release(ptr %.37)
  br label %continue_params

continue_params:                                  ; preds = %release_params, %continue_headers
  br label %exit
}

define void @Response.new(ptr %self) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %.4 = alloca %HttpStatus, align 8
  %.5 = getelementptr inbounds %HttpStatus, ptr %.4, i32 0, i32 0
  store i8 0, ptr %.5, align 1
  %.7 = load ptr, ptr %self.1, align 8
  %.8 = getelementptr inbounds %Response, ptr %.7, i32 0, i32 0
  %.9 = alloca %HttpStatus, align 8
  %.10 = getelementptr inbounds %HttpStatus, ptr %.9, i32 0, i32 0
  store i8 0, ptr %.10, align 1
  store ptr %.9, ptr %.8, align 8
  %.13 = call ptr @malloc(i64 40)
  %.14 = bitcast ptr %.13 to ptr
  call void @i64.array.init(ptr %.14)
  %.16 = load ptr, ptr %self.1, align 8
  %.17 = getelementptr inbounds %Response, ptr %.16, i32 0, i32 1
  %.18 = call ptr @malloc(i64 40)
  %.19 = bitcast ptr %.18 to ptr
  call void @Header.array.init(ptr %.19)
  %.21 = bitcast ptr %.19 to ptr
  call void @meteor_retain(ptr %.21)
  store ptr %.19, ptr %.17, align 8
  %.24 = call ptr @malloc(i64 40)
  %.25 = bitcast ptr %.24 to ptr
  call void @i64.array.init(ptr %.25)
  %.27 = load ptr, ptr %self.1, align 8
  %.28 = getelementptr inbounds %Response, ptr %.27, i32 0, i32 2
  %.29 = call ptr @malloc(i64 40)
  %.30 = bitcast ptr %.29 to ptr
  call void @i64.array.init(ptr %.30)
  %.32 = bitcast ptr %.30 to ptr
  call void @meteor_retain(ptr %.32)
  store ptr %.30, ptr %.28, align 8
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define ptr @Response.set_status(ptr %self, ptr %status) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %status.1 = alloca ptr, align 8
  store ptr %status, ptr %status.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %status.1, align 8
  %.8 = icmp eq ptr %.7, null
  br i1 %.8, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif
  %.42 = load ptr, ptr %ret_var, align 8
  %.43 = icmp eq ptr %.42, null
  br i1 %.43, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.10 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.10, align 1
  %.12 = getelementptr [32 x i8], ptr %.10, i64 0, i64 0
  %.13 = bitcast ptr %.12 to ptr
  %.14 = call i64 @puts(ptr %.13)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.17 = load ptr, ptr %self.1, align 8
  %.18 = getelementptr inbounds %Response, ptr %.17, i32 0, i32 0
  %.19 = load ptr, ptr %status.1, align 8
  %.20 = icmp eq ptr %.19, null
  br i1 %.20, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.22 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.22, align 1
  %.24 = getelementptr [32 x i8], ptr %.22, i64 0, i64 0
  %.25 = bitcast ptr %.24 to ptr
  %.26 = call i64 @puts(ptr %.25)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  store ptr %.19, ptr %.18, align 8
  %.30 = load ptr, ptr %self.1, align 8
  %.31 = icmp eq ptr %.30, null
  br i1 %.31, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.33 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.33, align 1
  %.35 = getelementptr [32 x i8], ptr %.33, i64 0, i64 0
  %.36 = bitcast ptr %.35 to ptr
  %.37 = call i64 @puts(ptr %.36)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  store ptr %.30, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.45 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.45, align 1
  %.47 = getelementptr [32 x i8], ptr %.45, i64 0, i64 0
  %.48 = bitcast ptr %.47 to ptr
  %.49 = call i64 @puts(ptr %.48)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.42
}

define ptr @Response.set_header(ptr %self, ptr %name, ptr %value) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %name.1 = alloca ptr, align 8
  store ptr %name, ptr %name.1, align 8
  %value.1 = alloca ptr, align 8
  store ptr %value, ptr %value.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.9 = load ptr, ptr %self.1, align 8
  %.10 = icmp eq ptr %.9, null
  br i1 %.10, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif
  %.67 = load ptr, ptr %ret_var, align 8
  %.68 = icmp eq ptr %.67, null
  br i1 %.68, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.12 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.12, align 1
  %.14 = getelementptr [32 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.19 = load %Response, ptr %.9, align 8
  %.20 = extractvalue %Response %.19, 1
  %.21 = call ptr @malloc(i64 32)
  %.22 = bitcast ptr %.21 to ptr
  %.23 = getelementptr %meteor.header, ptr %.22, i64 0, i32 0
  store i32 1, ptr %.23, align 4
  %.25 = getelementptr %meteor.header, ptr %.22, i64 0, i32 1
  store i32 0, ptr %.25, align 4
  %.27 = getelementptr %meteor.header, ptr %.22, i64 0, i32 2
  store i8 0, ptr %.27, align 1
  %.29 = getelementptr %meteor.header, ptr %.22, i64 0, i32 3
  store i8 10, ptr %.29, align 1
  %.31 = getelementptr i8, ptr %.21, i64 16
  %.32 = bitcast ptr %.31 to ptr
  %.33 = load ptr, ptr %name.1, align 8
  %.34 = icmp eq ptr %.33, null
  br i1 %.34, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.36 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.36, align 1
  %.38 = getelementptr [32 x i8], ptr %.36, i64 0, i64 0
  %.39 = bitcast ptr %.38 to ptr
  %.40 = call i64 @puts(ptr %.39)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.43 = load ptr, ptr %value.1, align 8
  %.44 = icmp eq ptr %.43, null
  br i1 %.44, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.46 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.46, align 1
  %.48 = getelementptr [32 x i8], ptr %.46, i64 0, i64 0
  %.49 = bitcast ptr %.48 to ptr
  %.50 = call i64 @puts(ptr %.49)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  call void @Header.new(ptr %.32, ptr %.33, ptr %.43)
  call void @Header.array.append(ptr %.20, ptr %.32)
  %.55 = load ptr, ptr %self.1, align 8
  %.56 = icmp eq ptr %.55, null
  br i1 %.56, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.58 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.58, align 1
  %.60 = getelementptr [32 x i8], ptr %.58, i64 0, i64 0
  %.61 = bitcast ptr %.60 to ptr
  %.62 = call i64 @puts(ptr %.61)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  store ptr %.55, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.70 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.70, align 1
  %.72 = getelementptr [32 x i8], ptr %.70, i64 0, i64 0
  %.73 = bitcast ptr %.72 to ptr
  %.74 = call i64 @puts(ptr %.73)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.67
}

define ptr @Response.set_body(ptr %self, ptr %body) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %body.1 = alloca ptr, align 8
  store ptr %body, ptr %body.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %body.1, align 8
  %.8 = icmp eq ptr %.7, null
  br i1 %.8, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif
  %.44 = load ptr, ptr %ret_var, align 8
  %.45 = icmp eq ptr %.44, null
  br i1 %.45, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.10 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.10, align 1
  %.12 = getelementptr [32 x i8], ptr %.10, i64 0, i64 0
  %.13 = bitcast ptr %.12 to ptr
  %.14 = call i64 @puts(ptr %.13)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.17 = load ptr, ptr %self.1, align 8
  %.18 = getelementptr inbounds %Response, ptr %.17, i32 0, i32 2
  %.19 = load ptr, ptr %body.1, align 8
  %.20 = icmp eq ptr %.19, null
  br i1 %.20, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.22 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.22, align 1
  %.24 = getelementptr [32 x i8], ptr %.22, i64 0, i64 0
  %.25 = bitcast ptr %.24 to ptr
  %.26 = call i64 @puts(ptr %.25)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.29 = bitcast ptr %.19 to ptr
  call void @meteor_retain(ptr %.29)
  store ptr %.19, ptr %.18, align 8
  %.32 = load ptr, ptr %self.1, align 8
  %.33 = icmp eq ptr %.32, null
  br i1 %.33, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.35 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.35, align 1
  %.37 = getelementptr [32 x i8], ptr %.35, i64 0, i64 0
  %.38 = bitcast ptr %.37 to ptr
  %.39 = call i64 @puts(ptr %.38)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  store ptr %.32, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.47 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.47, align 1
  %.49 = getelementptr [32 x i8], ptr %.47, i64 0, i64 0
  %.50 = bitcast ptr %.49 to ptr
  %.51 = call i64 @puts(ptr %.50)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.44
}

define ptr @Response.content_type(ptr %self, ptr %ct) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %ct.1 = alloca ptr, align 8
  store ptr %ct, ptr %ct.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %self.1, align 8
  %.8 = call ptr @malloc(i64 40)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  call void @i64.array.append(ptr %.9, i64 67)
  call void @i64.array.append(ptr %.9, i64 111)
  call void @i64.array.append(ptr %.9, i64 110)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 110)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 45)
  call void @i64.array.append(ptr %.9, i64 84)
  call void @i64.array.append(ptr %.9, i64 121)
  call void @i64.array.append(ptr %.9, i64 112)
  call void @i64.array.append(ptr %.9, i64 101)
  %.23 = load ptr, ptr %ct.1, align 8
  %.24 = icmp eq ptr %.23, null
  br i1 %.24, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif
  %.36 = load ptr, ptr %ret_var, align 8
  %.37 = icmp eq ptr %.36, null
  br i1 %.37, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.26 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.26, align 1
  %.28 = getelementptr [32 x i8], ptr %.26, i64 0, i64 0
  %.29 = bitcast ptr %.28 to ptr
  %.30 = call i64 @puts(ptr %.29)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.33 = call ptr @Response.set_header(ptr %.7, ptr %.9, ptr %.23)
  store ptr %.33, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.39 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.39, align 1
  %.41 = getelementptr [32 x i8], ptr %.39, i64 0, i64 0
  %.42 = bitcast ptr %.41 to ptr
  %.43 = call i64 @puts(ptr %.42)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.36
}

define ptr @Response.html(ptr %self, ptr %content) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %content.1 = alloca ptr, align 8
  store ptr %content, ptr %content.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %self.1, align 8
  %.8 = call ptr @malloc(i64 40)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 120)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 47)
  call void @i64.array.append(ptr %.9, i64 104)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 109)
  call void @i64.array.append(ptr %.9, i64 108)
  call void @i64.array.append(ptr %.9, i64 59)
  call void @i64.array.append(ptr %.9, i64 32)
  call void @i64.array.append(ptr %.9, i64 99)
  call void @i64.array.append(ptr %.9, i64 104)
  call void @i64.array.append(ptr %.9, i64 97)
  call void @i64.array.append(ptr %.9, i64 114)
  call void @i64.array.append(ptr %.9, i64 115)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 61)
  call void @i64.array.append(ptr %.9, i64 117)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 102)
  call void @i64.array.append(ptr %.9, i64 45)
  call void @i64.array.append(ptr %.9, i64 56)
  %.35 = call ptr @Response.content_type(ptr %.7, ptr %.9)
  %.36 = load ptr, ptr %content.1, align 8
  %.37 = icmp eq ptr %.36, null
  br i1 %.37, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif
  %.73 = load ptr, ptr %ret_var, align 8
  %.74 = icmp eq ptr %.73, null
  br i1 %.74, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.39 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.39, align 1
  %.41 = getelementptr [32 x i8], ptr %.39, i64 0, i64 0
  %.42 = bitcast ptr %.41 to ptr
  %.43 = call i64 @puts(ptr %.42)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.46 = load ptr, ptr %self.1, align 8
  %.47 = getelementptr inbounds %Response, ptr %.46, i32 0, i32 2
  %.48 = load ptr, ptr %content.1, align 8
  %.49 = icmp eq ptr %.48, null
  br i1 %.49, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.51 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.51, align 1
  %.53 = getelementptr [32 x i8], ptr %.51, i64 0, i64 0
  %.54 = bitcast ptr %.53 to ptr
  %.55 = call i64 @puts(ptr %.54)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.58 = bitcast ptr %.48 to ptr
  call void @meteor_retain(ptr %.58)
  store ptr %.48, ptr %.47, align 8
  %.61 = load ptr, ptr %self.1, align 8
  %.62 = icmp eq ptr %.61, null
  br i1 %.62, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.64 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.64, align 1
  %.66 = getelementptr [32 x i8], ptr %.64, i64 0, i64 0
  %.67 = bitcast ptr %.66 to ptr
  %.68 = call i64 @puts(ptr %.67)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  store ptr %.61, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.76 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.76, align 1
  %.78 = getelementptr [32 x i8], ptr %.76, i64 0, i64 0
  %.79 = bitcast ptr %.78 to ptr
  %.80 = call i64 @puts(ptr %.79)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.73
}

define ptr @Response.text(ptr %self, ptr %content) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %content.1 = alloca ptr, align 8
  store ptr %content, ptr %content.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %self.1, align 8
  %.8 = call ptr @malloc(i64 40)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 120)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 47)
  call void @i64.array.append(ptr %.9, i64 112)
  call void @i64.array.append(ptr %.9, i64 108)
  call void @i64.array.append(ptr %.9, i64 97)
  call void @i64.array.append(ptr %.9, i64 105)
  call void @i64.array.append(ptr %.9, i64 110)
  call void @i64.array.append(ptr %.9, i64 59)
  call void @i64.array.append(ptr %.9, i64 32)
  call void @i64.array.append(ptr %.9, i64 99)
  call void @i64.array.append(ptr %.9, i64 104)
  call void @i64.array.append(ptr %.9, i64 97)
  call void @i64.array.append(ptr %.9, i64 114)
  call void @i64.array.append(ptr %.9, i64 115)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 61)
  call void @i64.array.append(ptr %.9, i64 117)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 102)
  call void @i64.array.append(ptr %.9, i64 45)
  call void @i64.array.append(ptr %.9, i64 56)
  %.36 = call ptr @Response.content_type(ptr %.7, ptr %.9)
  %.37 = load ptr, ptr %content.1, align 8
  %.38 = icmp eq ptr %.37, null
  br i1 %.38, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif
  %.74 = load ptr, ptr %ret_var, align 8
  %.75 = icmp eq ptr %.74, null
  br i1 %.75, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.40 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.40, align 1
  %.42 = getelementptr [32 x i8], ptr %.40, i64 0, i64 0
  %.43 = bitcast ptr %.42 to ptr
  %.44 = call i64 @puts(ptr %.43)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.47 = load ptr, ptr %self.1, align 8
  %.48 = getelementptr inbounds %Response, ptr %.47, i32 0, i32 2
  %.49 = load ptr, ptr %content.1, align 8
  %.50 = icmp eq ptr %.49, null
  br i1 %.50, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.52 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.52, align 1
  %.54 = getelementptr [32 x i8], ptr %.52, i64 0, i64 0
  %.55 = bitcast ptr %.54 to ptr
  %.56 = call i64 @puts(ptr %.55)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.59 = bitcast ptr %.49 to ptr
  call void @meteor_retain(ptr %.59)
  store ptr %.49, ptr %.48, align 8
  %.62 = load ptr, ptr %self.1, align 8
  %.63 = icmp eq ptr %.62, null
  br i1 %.63, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.65 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.65, align 1
  %.67 = getelementptr [32 x i8], ptr %.65, i64 0, i64 0
  %.68 = bitcast ptr %.67 to ptr
  %.69 = call i64 @puts(ptr %.68)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  store ptr %.62, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.77 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.77, align 1
  %.79 = getelementptr [32 x i8], ptr %.77, i64 0, i64 0
  %.80 = bitcast ptr %.79 to ptr
  %.81 = call i64 @puts(ptr %.80)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.74
}

define ptr @Response.json(ptr %self, ptr %content) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %content.1 = alloca ptr, align 8
  store ptr %content, ptr %content.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %self.1, align 8
  %.8 = call ptr @malloc(i64 40)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  call void @i64.array.append(ptr %.9, i64 97)
  call void @i64.array.append(ptr %.9, i64 112)
  call void @i64.array.append(ptr %.9, i64 112)
  call void @i64.array.append(ptr %.9, i64 108)
  call void @i64.array.append(ptr %.9, i64 105)
  call void @i64.array.append(ptr %.9, i64 99)
  call void @i64.array.append(ptr %.9, i64 97)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 105)
  call void @i64.array.append(ptr %.9, i64 111)
  call void @i64.array.append(ptr %.9, i64 110)
  call void @i64.array.append(ptr %.9, i64 47)
  call void @i64.array.append(ptr %.9, i64 106)
  call void @i64.array.append(ptr %.9, i64 115)
  call void @i64.array.append(ptr %.9, i64 111)
  call void @i64.array.append(ptr %.9, i64 110)
  %.27 = call ptr @Response.content_type(ptr %.7, ptr %.9)
  %.28 = load ptr, ptr %content.1, align 8
  %.29 = icmp eq ptr %.28, null
  br i1 %.29, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif
  %.65 = load ptr, ptr %ret_var, align 8
  %.66 = icmp eq ptr %.65, null
  br i1 %.66, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.31 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.31, align 1
  %.33 = getelementptr [32 x i8], ptr %.31, i64 0, i64 0
  %.34 = bitcast ptr %.33 to ptr
  %.35 = call i64 @puts(ptr %.34)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.38 = load ptr, ptr %self.1, align 8
  %.39 = getelementptr inbounds %Response, ptr %.38, i32 0, i32 2
  %.40 = load ptr, ptr %content.1, align 8
  %.41 = icmp eq ptr %.40, null
  br i1 %.41, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.43 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.43, align 1
  %.45 = getelementptr [32 x i8], ptr %.43, i64 0, i64 0
  %.46 = bitcast ptr %.45 to ptr
  %.47 = call i64 @puts(ptr %.46)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.50 = bitcast ptr %.40 to ptr
  call void @meteor_retain(ptr %.50)
  store ptr %.40, ptr %.39, align 8
  %.53 = load ptr, ptr %self.1, align 8
  %.54 = icmp eq ptr %.53, null
  br i1 %.54, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.56 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.56, align 1
  %.58 = getelementptr [32 x i8], ptr %.56, i64 0, i64 0
  %.59 = bitcast ptr %.58 to ptr
  %.60 = call i64 @puts(ptr %.59)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  store ptr %.53, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.68 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.68, align 1
  %.70 = getelementptr [32 x i8], ptr %.68, i64 0, i64 0
  %.71 = bitcast ptr %.70 to ptr
  %.72 = call i64 @puts(ptr %.71)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.65
}

define ptr @Response.redirect(ptr %self, ptr %url) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %url.1 = alloca ptr, align 8
  store ptr %url, ptr %url.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = alloca %HttpStatus, align 8
  %.8 = getelementptr inbounds %HttpStatus, ptr %.7, i32 0, i32 0
  store i8 4, ptr %.8, align 1
  %.10 = load ptr, ptr %self.1, align 8
  %.11 = getelementptr inbounds %Response, ptr %.10, i32 0, i32 0
  %.12 = alloca %HttpStatus, align 8
  %.13 = getelementptr inbounds %HttpStatus, ptr %.12, i32 0, i32 0
  store i8 4, ptr %.13, align 1
  store ptr %.12, ptr %.11, align 8
  %.16 = load ptr, ptr %self.1, align 8
  %.17 = call ptr @malloc(i64 40)
  %.18 = bitcast ptr %.17 to ptr
  call void @i64.array.init(ptr %.18)
  call void @i64.array.append(ptr %.18, i64 76)
  call void @i64.array.append(ptr %.18, i64 111)
  call void @i64.array.append(ptr %.18, i64 99)
  call void @i64.array.append(ptr %.18, i64 97)
  call void @i64.array.append(ptr %.18, i64 116)
  call void @i64.array.append(ptr %.18, i64 105)
  call void @i64.array.append(ptr %.18, i64 111)
  call void @i64.array.append(ptr %.18, i64 110)
  %.28 = load ptr, ptr %url.1, align 8
  %.29 = icmp eq ptr %.28, null
  br i1 %.29, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif
  %.51 = load ptr, ptr %ret_var, align 8
  %.52 = icmp eq ptr %.51, null
  br i1 %.52, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.31 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.31, align 1
  %.33 = getelementptr [32 x i8], ptr %.31, i64 0, i64 0
  %.34 = bitcast ptr %.33 to ptr
  %.35 = call i64 @puts(ptr %.34)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.38 = call ptr @Response.set_header(ptr %.16, ptr %.18, ptr %.28)
  %.39 = load ptr, ptr %self.1, align 8
  %.40 = icmp eq ptr %.39, null
  br i1 %.40, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.42 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.42, align 1
  %.44 = getelementptr [32 x i8], ptr %.42, i64 0, i64 0
  %.45 = bitcast ptr %.44 to ptr
  %.46 = call i64 @puts(ptr %.45)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  store ptr %.39, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.54 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.54, align 1
  %.56 = getelementptr [32 x i8], ptr %.54, i64 0, i64 0
  %.57 = bitcast ptr %.56 to ptr
  %.58 = call i64 @puts(ptr %.57)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.51
}

define ptr @Response.not_found(ptr %self) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.5 = alloca %HttpStatus, align 8
  %.6 = getelementptr inbounds %HttpStatus, ptr %.5, i32 0, i32 0
  store i8 9, ptr %.6, align 1
  %.8 = load ptr, ptr %self.1, align 8
  %.9 = getelementptr inbounds %Response, ptr %.8, i32 0, i32 0
  %.10 = alloca %HttpStatus, align 8
  %.11 = getelementptr inbounds %HttpStatus, ptr %.10, i32 0, i32 0
  store i8 9, ptr %.11, align 1
  store ptr %.10, ptr %.9, align 8
  %.14 = load ptr, ptr %self.1, align 8
  %.15 = call ptr @malloc(i64 40)
  %.16 = bitcast ptr %.15 to ptr
  call void @i64.array.init(ptr %.16)
  call void @i64.array.append(ptr %.16, i64 60)
  call void @i64.array.append(ptr %.16, i64 104)
  call void @i64.array.append(ptr %.16, i64 49)
  call void @i64.array.append(ptr %.16, i64 62)
  call void @i64.array.append(ptr %.16, i64 52)
  call void @i64.array.append(ptr %.16, i64 48)
  call void @i64.array.append(ptr %.16, i64 52)
  call void @i64.array.append(ptr %.16, i64 32)
  call void @i64.array.append(ptr %.16, i64 78)
  call void @i64.array.append(ptr %.16, i64 111)
  call void @i64.array.append(ptr %.16, i64 116)
  call void @i64.array.append(ptr %.16, i64 32)
  call void @i64.array.append(ptr %.16, i64 70)
  call void @i64.array.append(ptr %.16, i64 111)
  call void @i64.array.append(ptr %.16, i64 117)
  call void @i64.array.append(ptr %.16, i64 110)
  call void @i64.array.append(ptr %.16, i64 100)
  call void @i64.array.append(ptr %.16, i64 60)
  call void @i64.array.append(ptr %.16, i64 47)
  call void @i64.array.append(ptr %.16, i64 104)
  call void @i64.array.append(ptr %.16, i64 49)
  call void @i64.array.append(ptr %.16, i64 62)
  %.40 = call ptr @Response.html(ptr %.14, ptr %.16)
  %.41 = load ptr, ptr %self.1, align 8
  %.42 = icmp eq ptr %.41, null
  br i1 %.42, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif
  %.53 = load ptr, ptr %ret_var, align 8
  %.54 = icmp eq ptr %.53, null
  br i1 %.54, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.44 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.44, align 1
  %.46 = getelementptr [32 x i8], ptr %.44, i64 0, i64 0
  %.47 = bitcast ptr %.46 to ptr
  %.48 = call i64 @puts(ptr %.47)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  store ptr %.41, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.56 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.56, align 1
  %.58 = getelementptr [32 x i8], ptr %.56, i64 0, i64 0
  %.59 = bitcast ptr %.58 to ptr
  %.60 = call i64 @puts(ptr %.59)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.53
}

define ptr @Response.internal_error(ptr %self, ptr %message) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %message.1 = alloca ptr, align 8
  store ptr %message, ptr %message.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = alloca %HttpStatus, align 8
  %.8 = getelementptr inbounds %HttpStatus, ptr %.7, i32 0, i32 0
  store i8 11, ptr %.8, align 1
  %.10 = load ptr, ptr %self.1, align 8
  %.11 = getelementptr inbounds %Response, ptr %.10, i32 0, i32 0
  %.12 = alloca %HttpStatus, align 8
  %.13 = getelementptr inbounds %HttpStatus, ptr %.12, i32 0, i32 0
  store i8 11, ptr %.13, align 1
  store ptr %.12, ptr %.11, align 8
  %.16 = load ptr, ptr %self.1, align 8
  %.17 = call ptr @malloc(i64 40)
  %.18 = bitcast ptr %.17 to ptr
  call void @i64.array.init(ptr %.18)
  call void @i64.array.append(ptr %.18, i64 60)
  call void @i64.array.append(ptr %.18, i64 104)
  call void @i64.array.append(ptr %.18, i64 49)
  call void @i64.array.append(ptr %.18, i64 62)
  call void @i64.array.append(ptr %.18, i64 53)
  call void @i64.array.append(ptr %.18, i64 48)
  call void @i64.array.append(ptr %.18, i64 48)
  call void @i64.array.append(ptr %.18, i64 32)
  call void @i64.array.append(ptr %.18, i64 73)
  call void @i64.array.append(ptr %.18, i64 110)
  call void @i64.array.append(ptr %.18, i64 116)
  call void @i64.array.append(ptr %.18, i64 101)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 110)
  call void @i64.array.append(ptr %.18, i64 97)
  call void @i64.array.append(ptr %.18, i64 108)
  call void @i64.array.append(ptr %.18, i64 32)
  call void @i64.array.append(ptr %.18, i64 83)
  call void @i64.array.append(ptr %.18, i64 101)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 118)
  call void @i64.array.append(ptr %.18, i64 101)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 32)
  call void @i64.array.append(ptr %.18, i64 69)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 111)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 60)
  call void @i64.array.append(ptr %.18, i64 47)
  call void @i64.array.append(ptr %.18, i64 104)
  call void @i64.array.append(ptr %.18, i64 49)
  call void @i64.array.append(ptr %.18, i64 62)
  call void @i64.array.append(ptr %.18, i64 60)
  call void @i64.array.append(ptr %.18, i64 112)
  call void @i64.array.append(ptr %.18, i64 62)
  %.57 = load ptr, ptr %message.1, align 8
  %.58 = icmp eq ptr %.57, null
  br i1 %.58, label %entry.if, label %entry.endif

exit:                                             ; preds = %str_concat.right.end.1.endif
  %.133 = load ptr, ptr %ret_var, align 8
  %.134 = icmp eq ptr %.133, null
  br i1 %.134, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.60 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.60, align 1
  %.62 = getelementptr [32 x i8], ptr %.60, i64 0, i64 0
  %.63 = bitcast ptr %.62 to ptr
  %.64 = call i64 @puts(ptr %.63)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.67 = call ptr @malloc(i64 40)
  %.68 = bitcast ptr %.67 to ptr
  call void @i64.array.init(ptr %.68)
  %left_len = call i64 @i64.array.length(ptr %.18)
  %right_len = call i64 @i64.array.length(ptr %.57)
  %i_left = alloca i64, align 8
  store i64 0, ptr %i_left, align 4
  br label %str_concat.left.cond

str_concat.left.cond:                             ; preds = %str_concat.left.body, %entry.endif
  %.72 = load i64, ptr %i_left, align 4
  %.73 = icmp slt i64 %.72, %left_len
  br i1 %.73, label %str_concat.left.body, label %str_concat.left.end

str_concat.left.body:                             ; preds = %str_concat.left.cond
  %.75 = load i64, ptr %i_left, align 4
  %left_char = call i64 @i64.array.get(ptr %.18, i64 %.75)
  call void @i64.array.append(ptr %.68, i64 %left_char)
  %.77 = add i64 %.75, 1
  store i64 %.77, ptr %i_left, align 4
  br label %str_concat.left.cond

str_concat.left.end:                              ; preds = %str_concat.left.cond
  %i_right = alloca i64, align 8
  store i64 0, ptr %i_right, align 4
  br label %str_concat.right.cond

str_concat.right.cond:                            ; preds = %str_concat.right.body, %str_concat.left.end
  %.82 = load i64, ptr %i_right, align 4
  %.83 = icmp slt i64 %.82, %right_len
  br i1 %.83, label %str_concat.right.body, label %str_concat.right.end

str_concat.right.body:                            ; preds = %str_concat.right.cond
  %.85 = load i64, ptr %i_right, align 4
  %right_char = call i64 @i64.array.get(ptr %.57, i64 %.85)
  call void @i64.array.append(ptr %.68, i64 %right_char)
  %.87 = add i64 %.85, 1
  store i64 %.87, ptr %i_right, align 4
  br label %str_concat.right.cond

str_concat.right.end:                             ; preds = %str_concat.right.cond
  %.90 = call ptr @malloc(i64 40)
  %.91 = bitcast ptr %.90 to ptr
  call void @i64.array.init(ptr %.91)
  call void @i64.array.append(ptr %.91, i64 60)
  call void @i64.array.append(ptr %.91, i64 47)
  call void @i64.array.append(ptr %.91, i64 112)
  call void @i64.array.append(ptr %.91, i64 62)
  %.97 = call ptr @malloc(i64 40)
  %.98 = bitcast ptr %.97 to ptr
  call void @i64.array.init(ptr %.98)
  %left_len.1 = call i64 @i64.array.length(ptr %.68)
  %right_len.1 = call i64 @i64.array.length(ptr %.91)
  %i_left.1 = alloca i64, align 8
  store i64 0, ptr %i_left.1, align 4
  br label %str_concat.left.cond.1

str_concat.left.cond.1:                           ; preds = %str_concat.left.body.1, %str_concat.right.end
  %.102 = load i64, ptr %i_left.1, align 4
  %.103 = icmp slt i64 %.102, %left_len.1
  br i1 %.103, label %str_concat.left.body.1, label %str_concat.left.end.1

str_concat.left.body.1:                           ; preds = %str_concat.left.cond.1
  %.105 = load i64, ptr %i_left.1, align 4
  %left_char.1 = call i64 @i64.array.get(ptr %.68, i64 %.105)
  call void @i64.array.append(ptr %.98, i64 %left_char.1)
  %.107 = add i64 %.105, 1
  store i64 %.107, ptr %i_left.1, align 4
  br label %str_concat.left.cond.1

str_concat.left.end.1:                            ; preds = %str_concat.left.cond.1
  %i_right.1 = alloca i64, align 8
  store i64 0, ptr %i_right.1, align 4
  br label %str_concat.right.cond.1

str_concat.right.cond.1:                          ; preds = %str_concat.right.body.1, %str_concat.left.end.1
  %.112 = load i64, ptr %i_right.1, align 4
  %.113 = icmp slt i64 %.112, %right_len.1
  br i1 %.113, label %str_concat.right.body.1, label %str_concat.right.end.1

str_concat.right.body.1:                          ; preds = %str_concat.right.cond.1
  %.115 = load i64, ptr %i_right.1, align 4
  %right_char.1 = call i64 @i64.array.get(ptr %.91, i64 %.115)
  call void @i64.array.append(ptr %.98, i64 %right_char.1)
  %.117 = add i64 %.115, 1
  store i64 %.117, ptr %i_right.1, align 4
  br label %str_concat.right.cond.1

str_concat.right.end.1:                           ; preds = %str_concat.right.cond.1
  %.120 = call ptr @Response.html(ptr %.16, ptr %.98)
  %.121 = load ptr, ptr %self.1, align 8
  %.122 = icmp eq ptr %.121, null
  br i1 %.122, label %str_concat.right.end.1.if, label %str_concat.right.end.1.endif

str_concat.right.end.1.if:                        ; preds = %str_concat.right.end.1
  %.124 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.124, align 1
  %.126 = getelementptr [32 x i8], ptr %.124, i64 0, i64 0
  %.127 = bitcast ptr %.126 to ptr
  %.128 = call i64 @puts(ptr %.127)
  call void @abort()
  unreachable

str_concat.right.end.1.endif:                     ; preds = %str_concat.right.end.1
  store ptr %.121, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.136 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.136, align 1
  %.138 = getelementptr [32 x i8], ptr %.136, i64 0, i64 0
  %.139 = bitcast ptr %.138 to ptr
  %.140 = call i64 @puts(ptr %.139)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.133
}

define internal void @__destroy_Response__(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

exit:                                             ; preds = %continue_body, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr inbounds %Response, ptr %.1, i32 0, i32 1
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %continue_headers, label %release_headers

release_headers:                                  ; preds = %not_null
  %.9 = bitcast ptr %.6 to ptr
  call void @meteor_release(ptr %.9)
  br label %continue_headers

continue_headers:                                 ; preds = %release_headers, %not_null
  %.12 = getelementptr inbounds %Response, ptr %.1, i32 0, i32 2
  %.13 = load ptr, ptr %.12, align 8
  %.14 = icmp eq ptr %.13, null
  br i1 %.14, label %continue_body, label %release_body

release_body:                                     ; preds = %continue_headers
  %.16 = bitcast ptr %.13 to ptr
  call void @meteor_release(ptr %.16)
  br label %continue_body

continue_body:                                    ; preds = %release_body, %continue_headers
  br label %exit
}

define void @Route.new(ptr %self, ptr %method, ptr %pattern, ptr %handler) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %method.1 = alloca ptr, align 8
  store ptr %method, ptr %method.1, align 8
  %pattern.1 = alloca ptr, align 8
  store ptr %pattern, ptr %pattern.1, align 8
  %handler.1 = alloca ptr, align 8
  store ptr %handler, ptr %handler.1, align 8
  %.10 = load ptr, ptr %method.1, align 8
  %.11 = icmp eq ptr %.10, null
  br i1 %.11, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif.endif.endif
  ret void

entry.if:                                         ; preds = %entry
  %.13 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.13, align 1
  %.15 = getelementptr [32 x i8], ptr %.13, i64 0, i64 0
  %.16 = bitcast ptr %.15 to ptr
  %.17 = call i64 @puts(ptr %.16)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.20 = load ptr, ptr %self.1, align 8
  %.21 = getelementptr inbounds %Route, ptr %.20, i32 0, i32 0
  %.22 = load ptr, ptr %method.1, align 8
  %.23 = icmp eq ptr %.22, null
  br i1 %.23, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.25 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.25, align 1
  %.27 = getelementptr [32 x i8], ptr %.25, i64 0, i64 0
  %.28 = bitcast ptr %.27 to ptr
  %.29 = call i64 @puts(ptr %.28)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  store ptr %.22, ptr %.21, align 8
  %.33 = load ptr, ptr %pattern.1, align 8
  %.34 = icmp eq ptr %.33, null
  br i1 %.34, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.36 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.36, align 1
  %.38 = getelementptr [32 x i8], ptr %.36, i64 0, i64 0
  %.39 = bitcast ptr %.38 to ptr
  %.40 = call i64 @puts(ptr %.39)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  %.43 = load ptr, ptr %self.1, align 8
  %.44 = getelementptr inbounds %Route, ptr %.43, i32 0, i32 1
  %.45 = load ptr, ptr %pattern.1, align 8
  %.46 = icmp eq ptr %.45, null
  br i1 %.46, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.48 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.48, align 1
  %.50 = getelementptr [32 x i8], ptr %.48, i64 0, i64 0
  %.51 = bitcast ptr %.50 to ptr
  %.52 = call i64 @puts(ptr %.51)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  %.55 = bitcast ptr %.45 to ptr
  call void @meteor_retain(ptr %.55)
  store ptr %.45, ptr %.44, align 8
  %.58 = load ptr, ptr %handler.1, align 8
  %.59 = icmp eq ptr %.58, null
  br i1 %.59, label %entry.endif.endif.endif.endif.if, label %entry.endif.endif.endif.endif.endif

entry.endif.endif.endif.endif.if:                 ; preds = %entry.endif.endif.endif.endif
  %.61 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.61, align 1
  %.63 = getelementptr [32 x i8], ptr %.61, i64 0, i64 0
  %.64 = bitcast ptr %.63 to ptr
  %.65 = call i64 @puts(ptr %.64)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif.endif:              ; preds = %entry.endif.endif.endif.endif
  %.68 = load ptr, ptr %self.1, align 8
  %.69 = getelementptr inbounds %Route, ptr %.68, i32 0, i32 2
  %.70 = load ptr, ptr %handler.1, align 8
  %.71 = icmp eq ptr %.70, null
  br i1 %.71, label %entry.endif.endif.endif.endif.endif.if, label %entry.endif.endif.endif.endif.endif.endif

entry.endif.endif.endif.endif.endif.if:           ; preds = %entry.endif.endif.endif.endif.endif
  %.73 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.73, align 1
  %.75 = getelementptr [32 x i8], ptr %.73, i64 0, i64 0
  %.76 = bitcast ptr %.75 to ptr
  %.77 = call i64 @puts(ptr %.76)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif.endif.endif:        ; preds = %entry.endif.endif.endif.endif.endif
  store ptr %.70, ptr %.69, align 8
  br label %exit
}

define internal void @__destroy_Route__(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

exit:                                             ; preds = %continue_pattern, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr inbounds %Route, ptr %.1, i32 0, i32 1
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %continue_pattern, label %release_pattern

release_pattern:                                  ; preds = %not_null
  %.9 = bitcast ptr %.6 to ptr
  call void @meteor_release(ptr %.9)
  br label %continue_pattern

continue_pattern:                                 ; preds = %release_pattern, %not_null
  br label %exit
}

define void @Middleware.new(ptr %self, ptr %handler) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %handler.1 = alloca ptr, align 8
  store ptr %handler, ptr %handler.1, align 8
  %.6 = load ptr, ptr %handler.1, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif
  ret void

entry.if:                                         ; preds = %entry
  %.9 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.9, align 1
  %.11 = getelementptr [32 x i8], ptr %.9, i64 0, i64 0
  %.12 = bitcast ptr %.11 to ptr
  %.13 = call i64 @puts(ptr %.12)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.16 = load ptr, ptr %self.1, align 8
  %.17 = getelementptr inbounds %Middleware, ptr %.16, i32 0, i32 0
  %.18 = load ptr, ptr %handler.1, align 8
  %.19 = icmp eq ptr %.18, null
  br i1 %.19, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.21 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.21, align 1
  %.23 = getelementptr [32 x i8], ptr %.21, i64 0, i64 0
  %.24 = bitcast ptr %.23 to ptr
  %.25 = call i64 @puts(ptr %.24)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  store ptr %.18, ptr %.17, align 8
  br label %exit
}

define internal void @__destroy_Middleware__(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

exit:                                             ; preds = %not_null, %entry
  ret void

not_null:                                         ; preds = %entry
  br label %exit
}

define void @Route.array.init(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Route.array, ptr %.5, i32 0, i32 1
  store i64 0, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %Route.array, ptr %.8, i32 0, i32 2
  store i64 16, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %Route.array, ptr %.11, i32 0, i32 3
  %.13 = load i64, ptr %.9, align 4
  %.14 = add i64 %.13, 1
  %.15 = mul i64 %.14, 8
  %.16 = call ptr @malloc(i64 %.15)
  %.17 = bitcast ptr %.16 to ptr
  store ptr %.17, ptr %.12, align 8
  %.19 = load ptr, ptr %.3, align 8
  %.20 = getelementptr inbounds %Route.array, ptr %.19, i32 0, i32 0
  %.21 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 0
  store i32 1, ptr %.21, align 4
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define void @Route.array.double_capacity_if_full(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Route.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %Route.array, ptr %.8, i32 0, i32 2
  %.10 = load i64, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %Route.array, ptr %.11, i32 0, i32 3
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

define void @Route.array.append(ptr %self, ptr %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca ptr, align 8
  store ptr %.2, ptr %.6, align 8
  %.8 = load ptr, ptr %.4, align 8
  call void @Route.array.double_capacity_if_full(ptr %.8)
  %.10 = load ptr, ptr %.4, align 8
  %.11 = getelementptr inbounds %Route.array, ptr %.10, i32 0, i32 1
  %.12 = load i64, ptr %.11, align 4
  %.13 = load ptr, ptr %.4, align 8
  %.14 = getelementptr inbounds %Route.array, ptr %.13, i32 0, i32 3
  %.15 = load ptr, ptr %.14, align 8
  %.16 = getelementptr inbounds ptr, ptr %.15, i64 %.12
  %.17 = load ptr, ptr %.6, align 8
  store ptr %.17, ptr %.16, align 8
  %.19 = add i64 %.12, 1
  store i64 %.19, ptr %.11, align 4
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define ptr @Route.array.get(ptr %self, i64 %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca i64, align 8
  store i64 %.2, ptr %.6, align 4
  %.8 = load i64, ptr %.6, align 4
  %.9 = load ptr, ptr %.4, align 8
  %.10 = getelementptr inbounds %Route.array, ptr %.9, i32 0, i32 1
  %.11 = load i64, ptr %.10, align 4
  %.12 = icmp sge i64 %.8, %.11
  br i1 %.12, label %index_out_of_bounds, label %is_index_less_than_zero

exit:                                             ; preds = %get
  %.27 = load ptr, ptr %.25, align 8
  ret ptr %.27

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
  %.22 = getelementptr inbounds %Route.array, ptr %.21, i32 0, i32 3
  %.23 = load i64, ptr %.6, align 4
  %.24 = load ptr, ptr %.22, align 8
  %.25 = getelementptr inbounds ptr, ptr %.24, i64 %.23
  br label %exit
}

define void @Route.array.set(ptr %self, i64 %.2, ptr %.3) {
entry:
  %.5 = alloca ptr, align 8
  store ptr %self, ptr %.5, align 8
  %.7 = alloca i64, align 8
  store i64 %.2, ptr %.7, align 4
  %.9 = alloca ptr, align 8
  store ptr %.3, ptr %.9, align 8
  %.11 = load i64, ptr %.7, align 4
  %.12 = load ptr, ptr %.5, align 8
  %.13 = getelementptr inbounds %Route.array, ptr %.12, i32 0, i32 1
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
  %.30 = getelementptr inbounds %Route.array, ptr %.29, i32 0, i32 3
  %.31 = load i64, ptr %.7, align 4
  %.32 = load ptr, ptr %.30, align 8
  %.33 = getelementptr inbounds ptr, ptr %.32, i64 %.31
  %.34 = load ptr, ptr %.9, align 8
  store ptr %.34, ptr %.33, align 8
  br label %exit
}

define i64 @Route.array.length(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Route.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  ret i64 %.7
}

define void @Middleware.array.init(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Middleware.array, ptr %.5, i32 0, i32 1
  store i64 0, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %Middleware.array, ptr %.8, i32 0, i32 2
  store i64 16, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %Middleware.array, ptr %.11, i32 0, i32 3
  %.13 = load i64, ptr %.9, align 4
  %.14 = add i64 %.13, 1
  %.15 = mul i64 %.14, 8
  %.16 = call ptr @malloc(i64 %.15)
  %.17 = bitcast ptr %.16 to ptr
  store ptr %.17, ptr %.12, align 8
  %.19 = load ptr, ptr %.3, align 8
  %.20 = getelementptr inbounds %Middleware.array, ptr %.19, i32 0, i32 0
  %.21 = getelementptr inbounds %meteor.header, ptr %.20, i32 0, i32 0
  store i32 1, ptr %.21, align 4
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define void @Middleware.array.double_capacity_if_full(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Middleware.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  %.8 = load ptr, ptr %.3, align 8
  %.9 = getelementptr inbounds %Middleware.array, ptr %.8, i32 0, i32 2
  %.10 = load i64, ptr %.9, align 4
  %.11 = load ptr, ptr %.3, align 8
  %.12 = getelementptr inbounds %Middleware.array, ptr %.11, i32 0, i32 3
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

define void @Middleware.array.append(ptr %self, ptr %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca ptr, align 8
  store ptr %.2, ptr %.6, align 8
  %.8 = load ptr, ptr %.4, align 8
  call void @Middleware.array.double_capacity_if_full(ptr %.8)
  %.10 = load ptr, ptr %.4, align 8
  %.11 = getelementptr inbounds %Middleware.array, ptr %.10, i32 0, i32 1
  %.12 = load i64, ptr %.11, align 4
  %.13 = load ptr, ptr %.4, align 8
  %.14 = getelementptr inbounds %Middleware.array, ptr %.13, i32 0, i32 3
  %.15 = load ptr, ptr %.14, align 8
  %.16 = getelementptr inbounds ptr, ptr %.15, i64 %.12
  %.17 = load ptr, ptr %.6, align 8
  store ptr %.17, ptr %.16, align 8
  %.19 = add i64 %.12, 1
  store i64 %.19, ptr %.11, align 4
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define ptr @Middleware.array.get(ptr %self, i64 %.2) {
entry:
  %.4 = alloca ptr, align 8
  store ptr %self, ptr %.4, align 8
  %.6 = alloca i64, align 8
  store i64 %.2, ptr %.6, align 4
  %.8 = load i64, ptr %.6, align 4
  %.9 = load ptr, ptr %.4, align 8
  %.10 = getelementptr inbounds %Middleware.array, ptr %.9, i32 0, i32 1
  %.11 = load i64, ptr %.10, align 4
  %.12 = icmp sge i64 %.8, %.11
  br i1 %.12, label %index_out_of_bounds, label %is_index_less_than_zero

exit:                                             ; preds = %get
  %.27 = load ptr, ptr %.25, align 8
  ret ptr %.27

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
  %.22 = getelementptr inbounds %Middleware.array, ptr %.21, i32 0, i32 3
  %.23 = load i64, ptr %.6, align 4
  %.24 = load ptr, ptr %.22, align 8
  %.25 = getelementptr inbounds ptr, ptr %.24, i64 %.23
  br label %exit
}

define void @Middleware.array.set(ptr %self, i64 %.2, ptr %.3) {
entry:
  %.5 = alloca ptr, align 8
  store ptr %self, ptr %.5, align 8
  %.7 = alloca i64, align 8
  store i64 %.2, ptr %.7, align 4
  %.9 = alloca ptr, align 8
  store ptr %.3, ptr %.9, align 8
  %.11 = load i64, ptr %.7, align 4
  %.12 = load ptr, ptr %.5, align 8
  %.13 = getelementptr inbounds %Middleware.array, ptr %.12, i32 0, i32 1
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
  %.30 = getelementptr inbounds %Middleware.array, ptr %.29, i32 0, i32 3
  %.31 = load i64, ptr %.7, align 4
  %.32 = load ptr, ptr %.30, align 8
  %.33 = getelementptr inbounds ptr, ptr %.32, i64 %.31
  %.34 = load ptr, ptr %.9, align 8
  store ptr %.34, ptr %.33, align 8
  br label %exit
}

define i64 @Middleware.array.length(ptr %self) {
entry:
  %.3 = alloca ptr, align 8
  store ptr %self, ptr %.3, align 8
  %.5 = load ptr, ptr %.3, align 8
  %.6 = getelementptr inbounds %Middleware.array, ptr %.5, i32 0, i32 1
  %.7 = load i64, ptr %.6, align 4
  ret i64 %.7
}

define void @Server.new(ptr %self) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %.4 = call ptr @meteor_http_server_create()
  %.5 = load ptr, ptr %self.1, align 8
  %.6 = getelementptr inbounds %Server, ptr %.5, i32 0, i32 0
  %.7 = call ptr @meteor_http_server_create()
  store ptr %.7, ptr %.6, align 8
  %.9 = call ptr @malloc(i64 40)
  %.10 = bitcast ptr %.9 to ptr
  call void @i64.array.init(ptr %.10)
  call void @i64.array.append(ptr %.10, i64 49)
  call void @i64.array.append(ptr %.10, i64 50)
  call void @i64.array.append(ptr %.10, i64 55)
  call void @i64.array.append(ptr %.10, i64 46)
  call void @i64.array.append(ptr %.10, i64 48)
  call void @i64.array.append(ptr %.10, i64 46)
  call void @i64.array.append(ptr %.10, i64 48)
  call void @i64.array.append(ptr %.10, i64 46)
  call void @i64.array.append(ptr %.10, i64 49)
  %.21 = load ptr, ptr %self.1, align 8
  %.22 = getelementptr inbounds %Server, ptr %.21, i32 0, i32 1
  %.23 = call ptr @malloc(i64 40)
  %.24 = bitcast ptr %.23 to ptr
  call void @i64.array.init(ptr %.24)
  call void @i64.array.append(ptr %.24, i64 49)
  call void @i64.array.append(ptr %.24, i64 50)
  call void @i64.array.append(ptr %.24, i64 55)
  call void @i64.array.append(ptr %.24, i64 46)
  call void @i64.array.append(ptr %.24, i64 48)
  call void @i64.array.append(ptr %.24, i64 46)
  call void @i64.array.append(ptr %.24, i64 48)
  call void @i64.array.append(ptr %.24, i64 46)
  call void @i64.array.append(ptr %.24, i64 49)
  %.35 = bitcast ptr %.24 to ptr
  call void @meteor_retain(ptr %.35)
  store ptr %.24, ptr %.22, align 8
  %.38 = load ptr, ptr %self.1, align 8
  %.39 = getelementptr inbounds %Server, ptr %.38, i32 0, i32 2
  store i64 8080, ptr %.39, align 4
  %.41 = call ptr @malloc(i64 40)
  %.42 = bitcast ptr %.41 to ptr
  call void @i64.array.init(ptr %.42)
  %.44 = load ptr, ptr %self.1, align 8
  %.45 = getelementptr inbounds %Server, ptr %.44, i32 0, i32 3
  %.46 = call ptr @malloc(i64 40)
  %.47 = bitcast ptr %.46 to ptr
  call void @Route.array.init(ptr %.47)
  %.49 = bitcast ptr %.47 to ptr
  call void @meteor_retain(ptr %.49)
  store ptr %.47, ptr %.45, align 8
  %.52 = call ptr @malloc(i64 40)
  %.53 = bitcast ptr %.52 to ptr
  call void @i64.array.init(ptr %.53)
  %.55 = load ptr, ptr %self.1, align 8
  %.56 = getelementptr inbounds %Server, ptr %.55, i32 0, i32 4
  %.57 = call ptr @malloc(i64 40)
  %.58 = bitcast ptr %.57 to ptr
  call void @Middleware.array.init(ptr %.58)
  %.60 = bitcast ptr %.58 to ptr
  call void @meteor_retain(ptr %.60)
  store ptr %.58, ptr %.56, align 8
  %.63 = call ptr @malloc(i64 40)
  %.64 = bitcast ptr %.63 to ptr
  call void @i64.array.init(ptr %.64)
  %.66 = load ptr, ptr %self.1, align 8
  %.67 = getelementptr inbounds %Server, ptr %.66, i32 0, i32 5
  %.68 = call ptr @malloc(i64 40)
  %.69 = bitcast ptr %.68 to ptr
  call void @i64.array.init(ptr %.69)
  %.71 = bitcast ptr %.69 to ptr
  call void @meteor_retain(ptr %.71)
  store ptr %.69, ptr %.67, align 8
  br label %exit

exit:                                             ; preds = %entry
  ret void
}

define ptr @Server.bind(ptr %self, ptr %host, i64 %port) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %host.1 = alloca ptr, align 8
  store ptr %host, ptr %host.1, align 8
  %port.1 = alloca i64, align 8
  store i64 %port, ptr %port.1, align 4
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.9 = load ptr, ptr %host.1, align 8
  %.10 = icmp eq ptr %.9, null
  br i1 %.10, label %entry.if, label %entry.endif

exit:                                             ; preds = %str_conv_end.endif.endif
  %.112 = load ptr, ptr %ret_var, align 8
  %.113 = icmp eq ptr %.112, null
  br i1 %.113, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.12 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.12, align 1
  %.14 = getelementptr [32 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.19 = load ptr, ptr %self.1, align 8
  %.20 = getelementptr inbounds %Server, ptr %.19, i32 0, i32 1
  %.21 = load ptr, ptr %host.1, align 8
  %.22 = icmp eq ptr %.21, null
  br i1 %.22, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.24 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.24, align 1
  %.26 = getelementptr [32 x i8], ptr %.24, i64 0, i64 0
  %.27 = bitcast ptr %.26 to ptr
  %.28 = call i64 @puts(ptr %.27)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.31 = bitcast ptr %.21 to ptr
  call void @meteor_retain(ptr %.31)
  store ptr %.21, ptr %.20, align 8
  %.34 = load i64, ptr %port.1, align 4
  %.35 = load ptr, ptr %self.1, align 8
  %.36 = getelementptr inbounds %Server, ptr %.35, i32 0, i32 2
  %.37 = load i64, ptr %port.1, align 4
  store i64 %.37, ptr %.36, align 4
  %.39 = load ptr, ptr %self.1, align 8
  %.40 = icmp eq ptr %.39, null
  br i1 %.40, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.42 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.42, align 1
  %.44 = getelementptr [32 x i8], ptr %.42, i64 0, i64 0
  %.45 = bitcast ptr %.44 to ptr
  %.46 = call i64 @puts(ptr %.45)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  %.49 = load %Server, ptr %.39, align 8
  %.50 = extractvalue %Server %.49, 0
  %.51 = load ptr, ptr %host.1, align 8
  %.52 = icmp eq ptr %.51, null
  br i1 %.52, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.54 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.54, align 1
  %.56 = getelementptr [32 x i8], ptr %.54, i64 0, i64 0
  %.57 = bitcast ptr %.56 to ptr
  %.58 = call i64 @puts(ptr %.57)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  %.61 = getelementptr %i64.array, ptr %.51, i32 0, i32 1
  %.62 = load i64, ptr %.61, align 4
  %.63 = getelementptr %i64.array, ptr %.51, i32 0, i32 3
  %.64 = load ptr, ptr %.63, align 8
  %.65 = add i64 %.62, 1
  %.66 = call ptr @malloc(i64 %.65)
  %.67 = alloca i64, align 8
  store i64 0, ptr %.67, align 4
  br label %str_conv_cond

str_conv_cond:                                    ; preds = %str_conv_body, %entry.endif.endif.endif.endif
  %.70 = load i64, ptr %.67, align 4
  %.71 = icmp slt i64 %.70, %.62
  br i1 %.71, label %str_conv_body, label %str_conv_end

str_conv_body:                                    ; preds = %str_conv_cond
  %.73 = load i64, ptr %.67, align 4
  %.74 = getelementptr i64, ptr %.64, i64 %.73
  %.75 = load i64, ptr %.74, align 4
  %.76 = trunc i64 %.75 to i8
  %.77 = getelementptr i8, ptr %.66, i64 %.73
  store i8 %.76, ptr %.77, align 1
  %.79 = add i64 %.73, 1
  store i64 %.79, ptr %.67, align 4
  br label %str_conv_cond

str_conv_end:                                     ; preds = %str_conv_cond
  %.82 = getelementptr i8, ptr %.66, i64 %.62
  store i8 0, ptr %.82, align 1
  %.84 = call i32 @meteor_http_server_set_host(ptr %.50, ptr %.66)
  %.85 = load ptr, ptr %self.1, align 8
  %.86 = icmp eq ptr %.85, null
  br i1 %.86, label %str_conv_end.if, label %str_conv_end.endif

str_conv_end.if:                                  ; preds = %str_conv_end
  %.88 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.88, align 1
  %.90 = getelementptr [32 x i8], ptr %.88, i64 0, i64 0
  %.91 = bitcast ptr %.90 to ptr
  %.92 = call i64 @puts(ptr %.91)
  call void @abort()
  unreachable

str_conv_end.endif:                               ; preds = %str_conv_end
  %.95 = load %Server, ptr %.85, align 8
  %.96 = extractvalue %Server %.95, 0
  %.97 = load i64, ptr %port.1, align 4
  %.98 = trunc i64 %.97 to i32
  %.99 = call i32 @meteor_http_server_set_port(ptr %.96, i32 %.98)
  %.100 = load ptr, ptr %self.1, align 8
  %.101 = icmp eq ptr %.100, null
  br i1 %.101, label %str_conv_end.endif.if, label %str_conv_end.endif.endif

str_conv_end.endif.if:                            ; preds = %str_conv_end.endif
  %.103 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.103, align 1
  %.105 = getelementptr [32 x i8], ptr %.103, i64 0, i64 0
  %.106 = bitcast ptr %.105 to ptr
  %.107 = call i64 @puts(ptr %.106)
  call void @abort()
  unreachable

str_conv_end.endif.endif:                         ; preds = %str_conv_end.endif
  store ptr %.100, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.115 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.115, align 1
  %.117 = getelementptr [32 x i8], ptr %.115, i64 0, i64 0
  %.118 = bitcast ptr %.117 to ptr
  %.119 = call i64 @puts(ptr %.118)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.112
}

define ptr @Server.get(ptr %self, ptr %pattern, ptr %handler) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %pattern.1 = alloca ptr, align 8
  store ptr %pattern, ptr %pattern.1, align 8
  %handler.1 = alloca ptr, align 8
  store ptr %handler, ptr %handler.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.9 = load ptr, ptr %self.1, align 8
  %.10 = icmp eq ptr %.9, null
  br i1 %.10, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif
  %.70 = load ptr, ptr %ret_var, align 8
  %.71 = icmp eq ptr %.70, null
  br i1 %.71, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.12 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.12, align 1
  %.14 = getelementptr [32 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.19 = load %Server, ptr %.9, align 8
  %.20 = extractvalue %Server %.19, 3
  %.21 = call ptr @malloc(i64 40)
  %.22 = bitcast ptr %.21 to ptr
  %.23 = getelementptr %meteor.header, ptr %.22, i64 0, i32 0
  store i32 1, ptr %.23, align 4
  %.25 = getelementptr %meteor.header, ptr %.22, i64 0, i32 1
  store i32 0, ptr %.25, align 4
  %.27 = getelementptr %meteor.header, ptr %.22, i64 0, i32 2
  store i8 0, ptr %.27, align 1
  %.29 = getelementptr %meteor.header, ptr %.22, i64 0, i32 3
  store i8 10, ptr %.29, align 1
  %.31 = getelementptr i8, ptr %.21, i64 16
  %.32 = bitcast ptr %.31 to ptr
  %.33 = alloca %HttpMethod, align 8
  %.34 = getelementptr inbounds %HttpMethod, ptr %.33, i32 0, i32 0
  store i8 0, ptr %.34, align 1
  %.36 = load ptr, ptr %pattern.1, align 8
  %.37 = icmp eq ptr %.36, null
  br i1 %.37, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.39 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.39, align 1
  %.41 = getelementptr [32 x i8], ptr %.39, i64 0, i64 0
  %.42 = bitcast ptr %.41 to ptr
  %.43 = call i64 @puts(ptr %.42)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.46 = load ptr, ptr %handler.1, align 8
  %.47 = icmp eq ptr %.46, null
  br i1 %.47, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.49 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.49, align 1
  %.51 = getelementptr [32 x i8], ptr %.49, i64 0, i64 0
  %.52 = bitcast ptr %.51 to ptr
  %.53 = call i64 @puts(ptr %.52)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  call void @Route.new(ptr %.32, ptr %.33, ptr %.36, ptr %.46)
  call void @Route.array.append(ptr %.20, ptr %.32)
  %.58 = load ptr, ptr %self.1, align 8
  %.59 = icmp eq ptr %.58, null
  br i1 %.59, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.61 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.61, align 1
  %.63 = getelementptr [32 x i8], ptr %.61, i64 0, i64 0
  %.64 = bitcast ptr %.63 to ptr
  %.65 = call i64 @puts(ptr %.64)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  store ptr %.58, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.73 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.73, align 1
  %.75 = getelementptr [32 x i8], ptr %.73, i64 0, i64 0
  %.76 = bitcast ptr %.75 to ptr
  %.77 = call i64 @puts(ptr %.76)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.70
}

define ptr @Server.post(ptr %self, ptr %pattern, ptr %handler) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %pattern.1 = alloca ptr, align 8
  store ptr %pattern, ptr %pattern.1, align 8
  %handler.1 = alloca ptr, align 8
  store ptr %handler, ptr %handler.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.9 = load ptr, ptr %self.1, align 8
  %.10 = icmp eq ptr %.9, null
  br i1 %.10, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif
  %.70 = load ptr, ptr %ret_var, align 8
  %.71 = icmp eq ptr %.70, null
  br i1 %.71, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.12 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.12, align 1
  %.14 = getelementptr [32 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.19 = load %Server, ptr %.9, align 8
  %.20 = extractvalue %Server %.19, 3
  %.21 = call ptr @malloc(i64 40)
  %.22 = bitcast ptr %.21 to ptr
  %.23 = getelementptr %meteor.header, ptr %.22, i64 0, i32 0
  store i32 1, ptr %.23, align 4
  %.25 = getelementptr %meteor.header, ptr %.22, i64 0, i32 1
  store i32 0, ptr %.25, align 4
  %.27 = getelementptr %meteor.header, ptr %.22, i64 0, i32 2
  store i8 0, ptr %.27, align 1
  %.29 = getelementptr %meteor.header, ptr %.22, i64 0, i32 3
  store i8 10, ptr %.29, align 1
  %.31 = getelementptr i8, ptr %.21, i64 16
  %.32 = bitcast ptr %.31 to ptr
  %.33 = alloca %HttpMethod, align 8
  %.34 = getelementptr inbounds %HttpMethod, ptr %.33, i32 0, i32 0
  store i8 1, ptr %.34, align 1
  %.36 = load ptr, ptr %pattern.1, align 8
  %.37 = icmp eq ptr %.36, null
  br i1 %.37, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.39 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.39, align 1
  %.41 = getelementptr [32 x i8], ptr %.39, i64 0, i64 0
  %.42 = bitcast ptr %.41 to ptr
  %.43 = call i64 @puts(ptr %.42)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.46 = load ptr, ptr %handler.1, align 8
  %.47 = icmp eq ptr %.46, null
  br i1 %.47, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.49 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.49, align 1
  %.51 = getelementptr [32 x i8], ptr %.49, i64 0, i64 0
  %.52 = bitcast ptr %.51 to ptr
  %.53 = call i64 @puts(ptr %.52)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  call void @Route.new(ptr %.32, ptr %.33, ptr %.36, ptr %.46)
  call void @Route.array.append(ptr %.20, ptr %.32)
  %.58 = load ptr, ptr %self.1, align 8
  %.59 = icmp eq ptr %.58, null
  br i1 %.59, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.61 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.61, align 1
  %.63 = getelementptr [32 x i8], ptr %.61, i64 0, i64 0
  %.64 = bitcast ptr %.63 to ptr
  %.65 = call i64 @puts(ptr %.64)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  store ptr %.58, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.73 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.73, align 1
  %.75 = getelementptr [32 x i8], ptr %.73, i64 0, i64 0
  %.76 = bitcast ptr %.75 to ptr
  %.77 = call i64 @puts(ptr %.76)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.70
}

define ptr @Server.put(ptr %self, ptr %pattern, ptr %handler) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %pattern.1 = alloca ptr, align 8
  store ptr %pattern, ptr %pattern.1, align 8
  %handler.1 = alloca ptr, align 8
  store ptr %handler, ptr %handler.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.9 = load ptr, ptr %self.1, align 8
  %.10 = icmp eq ptr %.9, null
  br i1 %.10, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif
  %.70 = load ptr, ptr %ret_var, align 8
  %.71 = icmp eq ptr %.70, null
  br i1 %.71, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.12 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.12, align 1
  %.14 = getelementptr [32 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.19 = load %Server, ptr %.9, align 8
  %.20 = extractvalue %Server %.19, 3
  %.21 = call ptr @malloc(i64 40)
  %.22 = bitcast ptr %.21 to ptr
  %.23 = getelementptr %meteor.header, ptr %.22, i64 0, i32 0
  store i32 1, ptr %.23, align 4
  %.25 = getelementptr %meteor.header, ptr %.22, i64 0, i32 1
  store i32 0, ptr %.25, align 4
  %.27 = getelementptr %meteor.header, ptr %.22, i64 0, i32 2
  store i8 0, ptr %.27, align 1
  %.29 = getelementptr %meteor.header, ptr %.22, i64 0, i32 3
  store i8 10, ptr %.29, align 1
  %.31 = getelementptr i8, ptr %.21, i64 16
  %.32 = bitcast ptr %.31 to ptr
  %.33 = alloca %HttpMethod, align 8
  %.34 = getelementptr inbounds %HttpMethod, ptr %.33, i32 0, i32 0
  store i8 2, ptr %.34, align 1
  %.36 = load ptr, ptr %pattern.1, align 8
  %.37 = icmp eq ptr %.36, null
  br i1 %.37, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.39 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.39, align 1
  %.41 = getelementptr [32 x i8], ptr %.39, i64 0, i64 0
  %.42 = bitcast ptr %.41 to ptr
  %.43 = call i64 @puts(ptr %.42)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.46 = load ptr, ptr %handler.1, align 8
  %.47 = icmp eq ptr %.46, null
  br i1 %.47, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.49 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.49, align 1
  %.51 = getelementptr [32 x i8], ptr %.49, i64 0, i64 0
  %.52 = bitcast ptr %.51 to ptr
  %.53 = call i64 @puts(ptr %.52)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  call void @Route.new(ptr %.32, ptr %.33, ptr %.36, ptr %.46)
  call void @Route.array.append(ptr %.20, ptr %.32)
  %.58 = load ptr, ptr %self.1, align 8
  %.59 = icmp eq ptr %.58, null
  br i1 %.59, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.61 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.61, align 1
  %.63 = getelementptr [32 x i8], ptr %.61, i64 0, i64 0
  %.64 = bitcast ptr %.63 to ptr
  %.65 = call i64 @puts(ptr %.64)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  store ptr %.58, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.73 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.73, align 1
  %.75 = getelementptr [32 x i8], ptr %.73, i64 0, i64 0
  %.76 = bitcast ptr %.75 to ptr
  %.77 = call i64 @puts(ptr %.76)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.70
}

define ptr @Server.delete(ptr %self, ptr %pattern, ptr %handler) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %pattern.1 = alloca ptr, align 8
  store ptr %pattern, ptr %pattern.1, align 8
  %handler.1 = alloca ptr, align 8
  store ptr %handler, ptr %handler.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.9 = load ptr, ptr %self.1, align 8
  %.10 = icmp eq ptr %.9, null
  br i1 %.10, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif
  %.70 = load ptr, ptr %ret_var, align 8
  %.71 = icmp eq ptr %.70, null
  br i1 %.71, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.12 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.12, align 1
  %.14 = getelementptr [32 x i8], ptr %.12, i64 0, i64 0
  %.15 = bitcast ptr %.14 to ptr
  %.16 = call i64 @puts(ptr %.15)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.19 = load %Server, ptr %.9, align 8
  %.20 = extractvalue %Server %.19, 3
  %.21 = call ptr @malloc(i64 40)
  %.22 = bitcast ptr %.21 to ptr
  %.23 = getelementptr %meteor.header, ptr %.22, i64 0, i32 0
  store i32 1, ptr %.23, align 4
  %.25 = getelementptr %meteor.header, ptr %.22, i64 0, i32 1
  store i32 0, ptr %.25, align 4
  %.27 = getelementptr %meteor.header, ptr %.22, i64 0, i32 2
  store i8 0, ptr %.27, align 1
  %.29 = getelementptr %meteor.header, ptr %.22, i64 0, i32 3
  store i8 10, ptr %.29, align 1
  %.31 = getelementptr i8, ptr %.21, i64 16
  %.32 = bitcast ptr %.31 to ptr
  %.33 = alloca %HttpMethod, align 8
  %.34 = getelementptr inbounds %HttpMethod, ptr %.33, i32 0, i32 0
  store i8 3, ptr %.34, align 1
  %.36 = load ptr, ptr %pattern.1, align 8
  %.37 = icmp eq ptr %.36, null
  br i1 %.37, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.39 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.39, align 1
  %.41 = getelementptr [32 x i8], ptr %.39, i64 0, i64 0
  %.42 = bitcast ptr %.41 to ptr
  %.43 = call i64 @puts(ptr %.42)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.46 = load ptr, ptr %handler.1, align 8
  %.47 = icmp eq ptr %.46, null
  br i1 %.47, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.49 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.49, align 1
  %.51 = getelementptr [32 x i8], ptr %.49, i64 0, i64 0
  %.52 = bitcast ptr %.51 to ptr
  %.53 = call i64 @puts(ptr %.52)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  call void @Route.new(ptr %.32, ptr %.33, ptr %.36, ptr %.46)
  call void @Route.array.append(ptr %.20, ptr %.32)
  %.58 = load ptr, ptr %self.1, align 8
  %.59 = icmp eq ptr %.58, null
  br i1 %.59, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.61 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.61, align 1
  %.63 = getelementptr [32 x i8], ptr %.61, i64 0, i64 0
  %.64 = bitcast ptr %.63 to ptr
  %.65 = call i64 @puts(ptr %.64)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  store ptr %.58, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.73 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.73, align 1
  %.75 = getelementptr [32 x i8], ptr %.73, i64 0, i64 0
  %.76 = bitcast ptr %.75 to ptr
  %.77 = call i64 @puts(ptr %.76)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.70
}

define ptr @Server.route(ptr %self, ptr %method, ptr %pattern, ptr %handler) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %method.1 = alloca ptr, align 8
  store ptr %method, ptr %method.1, align 8
  %pattern.1 = alloca ptr, align 8
  store ptr %pattern, ptr %pattern.1, align 8
  %handler.1 = alloca ptr, align 8
  store ptr %handler, ptr %handler.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.11 = load ptr, ptr %self.1, align 8
  %.12 = icmp eq ptr %.11, null
  br i1 %.12, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif.endif.endif
  %.79 = load ptr, ptr %ret_var, align 8
  %.80 = icmp eq ptr %.79, null
  br i1 %.80, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.14 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.14, align 1
  %.16 = getelementptr [32 x i8], ptr %.14, i64 0, i64 0
  %.17 = bitcast ptr %.16 to ptr
  %.18 = call i64 @puts(ptr %.17)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.21 = load %Server, ptr %.11, align 8
  %.22 = extractvalue %Server %.21, 3
  %.23 = call ptr @malloc(i64 40)
  %.24 = bitcast ptr %.23 to ptr
  %.25 = getelementptr %meteor.header, ptr %.24, i64 0, i32 0
  store i32 1, ptr %.25, align 4
  %.27 = getelementptr %meteor.header, ptr %.24, i64 0, i32 1
  store i32 0, ptr %.27, align 4
  %.29 = getelementptr %meteor.header, ptr %.24, i64 0, i32 2
  store i8 0, ptr %.29, align 1
  %.31 = getelementptr %meteor.header, ptr %.24, i64 0, i32 3
  store i8 10, ptr %.31, align 1
  %.33 = getelementptr i8, ptr %.23, i64 16
  %.34 = bitcast ptr %.33 to ptr
  %.35 = load ptr, ptr %method.1, align 8
  %.36 = icmp eq ptr %.35, null
  br i1 %.36, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.38 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.38, align 1
  %.40 = getelementptr [32 x i8], ptr %.38, i64 0, i64 0
  %.41 = bitcast ptr %.40 to ptr
  %.42 = call i64 @puts(ptr %.41)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.45 = load ptr, ptr %pattern.1, align 8
  %.46 = icmp eq ptr %.45, null
  br i1 %.46, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.48 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.48, align 1
  %.50 = getelementptr [32 x i8], ptr %.48, i64 0, i64 0
  %.51 = bitcast ptr %.50 to ptr
  %.52 = call i64 @puts(ptr %.51)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  %.55 = load ptr, ptr %handler.1, align 8
  %.56 = icmp eq ptr %.55, null
  br i1 %.56, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.58 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.58, align 1
  %.60 = getelementptr [32 x i8], ptr %.58, i64 0, i64 0
  %.61 = bitcast ptr %.60 to ptr
  %.62 = call i64 @puts(ptr %.61)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  call void @Route.new(ptr %.34, ptr %.35, ptr %.45, ptr %.55)
  call void @Route.array.append(ptr %.22, ptr %.34)
  %.67 = load ptr, ptr %self.1, align 8
  %.68 = icmp eq ptr %.67, null
  br i1 %.68, label %entry.endif.endif.endif.endif.if, label %entry.endif.endif.endif.endif.endif

entry.endif.endif.endif.endif.if:                 ; preds = %entry.endif.endif.endif.endif
  %.70 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.70, align 1
  %.72 = getelementptr [32 x i8], ptr %.70, i64 0, i64 0
  %.73 = bitcast ptr %.72 to ptr
  %.74 = call i64 @puts(ptr %.73)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif.endif:              ; preds = %entry.endif.endif.endif.endif
  store ptr %.67, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.82 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.82, align 1
  %.84 = getelementptr [32 x i8], ptr %.82, i64 0, i64 0
  %.85 = bitcast ptr %.84 to ptr
  %.86 = call i64 @puts(ptr %.85)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.79
}

define ptr @Server.use(ptr %self, ptr %middleware) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %middleware.1 = alloca ptr, align 8
  store ptr %middleware, ptr %middleware.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %self.1, align 8
  %.8 = icmp eq ptr %.7, null
  br i1 %.8, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif.endif.endif
  %.42 = load ptr, ptr %ret_var, align 8
  %.43 = icmp eq ptr %.42, null
  br i1 %.43, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.10 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.10, align 1
  %.12 = getelementptr [32 x i8], ptr %.10, i64 0, i64 0
  %.13 = bitcast ptr %.12 to ptr
  %.14 = call i64 @puts(ptr %.13)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.17 = load %Server, ptr %.7, align 8
  %.18 = extractvalue %Server %.17, 4
  %.19 = load ptr, ptr %middleware.1, align 8
  %.20 = icmp eq ptr %.19, null
  br i1 %.20, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.22 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.22, align 1
  %.24 = getelementptr [32 x i8], ptr %.22, i64 0, i64 0
  %.25 = bitcast ptr %.24 to ptr
  %.26 = call i64 @puts(ptr %.25)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  call void @Middleware.array.append(ptr %.18, ptr %.19)
  %.30 = load ptr, ptr %self.1, align 8
  %.31 = icmp eq ptr %.30, null
  br i1 %.31, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.33 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.33, align 1
  %.35 = getelementptr [32 x i8], ptr %.33, i64 0, i64 0
  %.36 = bitcast ptr %.35 to ptr
  %.37 = call i64 @puts(ptr %.36)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  store ptr %.30, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.45 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.45, align 1
  %.47 = getelementptr [32 x i8], ptr %.45, i64 0, i64 0
  %.48 = bitcast ptr %.47 to ptr
  %.49 = call i64 @puts(ptr %.48)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.42
}

define ptr @Server.static(ptr %self, ptr %dir) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %dir.1 = alloca ptr, align 8
  store ptr %dir, ptr %dir.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %dir.1, align 8
  %.8 = icmp eq ptr %.7, null
  br i1 %.8, label %entry.if, label %entry.endif

exit:                                             ; preds = %str_conv_end.endif
  %.90 = load ptr, ptr %ret_var, align 8
  %.91 = icmp eq ptr %.90, null
  br i1 %.91, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.10 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.10, align 1
  %.12 = getelementptr [32 x i8], ptr %.10, i64 0, i64 0
  %.13 = bitcast ptr %.12 to ptr
  %.14 = call i64 @puts(ptr %.13)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.17 = load ptr, ptr %self.1, align 8
  %.18 = getelementptr inbounds %Server, ptr %.17, i32 0, i32 5
  %.19 = load ptr, ptr %dir.1, align 8
  %.20 = icmp eq ptr %.19, null
  br i1 %.20, label %entry.endif.if, label %entry.endif.endif

entry.endif.if:                                   ; preds = %entry.endif
  %.22 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.22, align 1
  %.24 = getelementptr [32 x i8], ptr %.22, i64 0, i64 0
  %.25 = bitcast ptr %.24 to ptr
  %.26 = call i64 @puts(ptr %.25)
  call void @abort()
  unreachable

entry.endif.endif:                                ; preds = %entry.endif
  %.29 = bitcast ptr %.19 to ptr
  call void @meteor_retain(ptr %.29)
  store ptr %.19, ptr %.18, align 8
  %.32 = load ptr, ptr %self.1, align 8
  %.33 = icmp eq ptr %.32, null
  br i1 %.33, label %entry.endif.endif.if, label %entry.endif.endif.endif

entry.endif.endif.if:                             ; preds = %entry.endif.endif
  %.35 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.35, align 1
  %.37 = getelementptr [32 x i8], ptr %.35, i64 0, i64 0
  %.38 = bitcast ptr %.37 to ptr
  %.39 = call i64 @puts(ptr %.38)
  call void @abort()
  unreachable

entry.endif.endif.endif:                          ; preds = %entry.endif.endif
  %.42 = load %Server, ptr %.32, align 8
  %.43 = extractvalue %Server %.42, 0
  %.44 = load ptr, ptr %dir.1, align 8
  %.45 = icmp eq ptr %.44, null
  br i1 %.45, label %entry.endif.endif.endif.if, label %entry.endif.endif.endif.endif

entry.endif.endif.endif.if:                       ; preds = %entry.endif.endif.endif
  %.47 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.47, align 1
  %.49 = getelementptr [32 x i8], ptr %.47, i64 0, i64 0
  %.50 = bitcast ptr %.49 to ptr
  %.51 = call i64 @puts(ptr %.50)
  call void @abort()
  unreachable

entry.endif.endif.endif.endif:                    ; preds = %entry.endif.endif.endif
  %.54 = getelementptr %i64.array, ptr %.44, i32 0, i32 1
  %.55 = load i64, ptr %.54, align 4
  %.56 = getelementptr %i64.array, ptr %.44, i32 0, i32 3
  %.57 = load ptr, ptr %.56, align 8
  %.58 = add i64 %.55, 1
  %.59 = call ptr @malloc(i64 %.58)
  %.60 = alloca i64, align 8
  store i64 0, ptr %.60, align 4
  br label %str_conv_cond

str_conv_cond:                                    ; preds = %str_conv_body, %entry.endif.endif.endif.endif
  %.63 = load i64, ptr %.60, align 4
  %.64 = icmp slt i64 %.63, %.55
  br i1 %.64, label %str_conv_body, label %str_conv_end

str_conv_body:                                    ; preds = %str_conv_cond
  %.66 = load i64, ptr %.60, align 4
  %.67 = getelementptr i64, ptr %.57, i64 %.66
  %.68 = load i64, ptr %.67, align 4
  %.69 = trunc i64 %.68 to i8
  %.70 = getelementptr i8, ptr %.59, i64 %.66
  store i8 %.69, ptr %.70, align 1
  %.72 = add i64 %.66, 1
  store i64 %.72, ptr %.60, align 4
  br label %str_conv_cond

str_conv_end:                                     ; preds = %str_conv_cond
  %.75 = getelementptr i8, ptr %.59, i64 %.55
  store i8 0, ptr %.75, align 1
  %.77 = call i32 @meteor_http_server_set_static_dir(ptr %.43, ptr %.59)
  %.78 = load ptr, ptr %self.1, align 8
  %.79 = icmp eq ptr %.78, null
  br i1 %.79, label %str_conv_end.if, label %str_conv_end.endif

str_conv_end.if:                                  ; preds = %str_conv_end
  %.81 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.81, align 1
  %.83 = getelementptr [32 x i8], ptr %.81, i64 0, i64 0
  %.84 = bitcast ptr %.83 to ptr
  %.85 = call i64 @puts(ptr %.84)
  call void @abort()
  unreachable

str_conv_end.endif:                               ; preds = %str_conv_end
  store ptr %.78, ptr %ret_var, align 8
  br label %exit

exit.if:                                          ; preds = %exit
  %.93 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.93, align 1
  %.95 = getelementptr [32 x i8], ptr %.93, i64 0, i64 0
  %.96 = bitcast ptr %.95 to ptr
  %.97 = call i64 @puts(ptr %.96)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.90
}

define i64 @Server.listen(ptr %self) {
entry:
  %h = alloca ptr, align 8
  %status_code = alloca i64, align 8
  %res_ptr = alloca ptr, align 8
  %route = alloca ptr, align 8
  %handled = alloca i1, align 1
  %res = alloca ptr, align 8
  %val = alloca ptr, align 8
  %name = alloca ptr, align 8
  %i = alloca i64, align 8
  %count = alloca i32, align 4
  %m_int = alloca i32, align 4
  %req = alloca ptr, align 8
  %req_ptr = alloca ptr, align 8
  %conn = alloca ptr, align 8
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %ret_var = alloca i64, align 8
  %.4 = load ptr, ptr %self.1, align 8
  %.5 = icmp eq ptr %.4, null
  br i1 %.5, label %entry.if, label %entry.endif

exit:                                             ; preds = %while.end
  %.1012 = load i64, ptr %ret_var, align 4
  ret i64 %.1012

entry.if:                                         ; preds = %entry
  %.7 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.7, align 1
  %.9 = getelementptr [32 x i8], ptr %.7, i64 0, i64 0
  %.10 = bitcast ptr %.9 to ptr
  %.11 = call i64 @puts(ptr %.10)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.14 = load %Server, ptr %.4, align 8
  %.15 = extractvalue %Server %.14, 0
  %.16 = call i32 @meteor_http_server_bind(ptr %.15)
  br label %while.cond

while.cond:                                       ; preds = %if.end.1.endif, %if.true.0, %entry.endif
  br i1 true, label %while.body, label %while.end

while.body:                                       ; preds = %while.cond
  %.19 = load ptr, ptr %self.1, align 8
  %.20 = icmp eq ptr %.19, null
  br i1 %.20, label %while.body.if, label %while.body.endif

while.end:                                        ; preds = %while.cond
  store i64 0, ptr %ret_var, align 4
  br label %exit

while.body.if:                                    ; preds = %while.body
  %.22 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.22, align 1
  %.24 = getelementptr [32 x i8], ptr %.22, i64 0, i64 0
  %.25 = bitcast ptr %.24 to ptr
  %.26 = call i64 @puts(ptr %.25)
  call void @abort()
  unreachable

while.body.endif:                                 ; preds = %while.body
  %.29 = load %Server, ptr %.19, align 8
  %.30 = extractvalue %Server %.29, 0
  %.31 = call ptr @meteor_http_server_accept(ptr %.30)
  store ptr %.31, ptr %conn, align 8
  br label %if.start

if.start:                                         ; preds = %while.body.endif
  %.34 = load ptr, ptr %conn, align 8
  %.35 = icmp eq ptr %.34, null
  br i1 %.35, label %if.start.if, label %if.start.endif

if.end:                                           ; preds = %if.start.endif
  %.47 = load ptr, ptr %conn, align 8
  %.48 = icmp eq ptr %.47, null
  br i1 %.48, label %if.end.if, label %if.end.endif

if.true.0:                                        ; preds = %if.start.endif
  br label %while.cond

if.start.if:                                      ; preds = %if.start
  %.37 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.37, align 1
  %.39 = getelementptr [32 x i8], ptr %.37, i64 0, i64 0
  %.40 = bitcast ptr %.39 to ptr
  %.41 = call i64 @puts(ptr %.40)
  call void @abort()
  unreachable

if.start.endif:                                   ; preds = %if.start
  %.44 = icmp eq ptr %.34, null
  br i1 %.44, label %if.true.0, label %if.end

if.end.if:                                        ; preds = %if.end
  %.50 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.50, align 1
  %.52 = getelementptr [32 x i8], ptr %.50, i64 0, i64 0
  %.53 = bitcast ptr %.52 to ptr
  %.54 = call i64 @puts(ptr %.53)
  call void @abort()
  unreachable

if.end.endif:                                     ; preds = %if.end
  %.57 = call ptr @meteor_http_connection_read_request(ptr %.47)
  store ptr %.57, ptr %req_ptr, align 8
  br label %if.start.1

if.start.1:                                       ; preds = %if.end.endif
  %.60 = load ptr, ptr %req_ptr, align 8
  %.61 = icmp eq ptr %.60, null
  br i1 %.61, label %if.start.1.if, label %if.start.1.endif

if.end.1:                                         ; preds = %rc_release_continue.3, %if.start.1.endif
  %.998 = load ptr, ptr %conn, align 8
  %.999 = icmp eq ptr %.998, null
  br i1 %.999, label %if.end.1.if, label %if.end.1.endif

if.true.0.1:                                      ; preds = %if.start.1.endif
  %.72 = call ptr @malloc(i64 64)
  %.73 = bitcast ptr %.72 to ptr
  %.74 = getelementptr %meteor.header, ptr %.73, i64 0, i32 0
  store i32 1, ptr %.74, align 4
  %.76 = getelementptr %meteor.header, ptr %.73, i64 0, i32 1
  store i32 0, ptr %.76, align 4
  %.78 = getelementptr %meteor.header, ptr %.73, i64 0, i32 2
  store i8 0, ptr %.78, align 1
  %.80 = getelementptr %meteor.header, ptr %.73, i64 0, i32 3
  store i8 10, ptr %.80, align 1
  %.82 = getelementptr i8, ptr %.72, i64 16
  %.83 = bitcast ptr %.82 to ptr
  call void @Request.new(ptr %.83)
  store ptr %.83, ptr %req, align 8
  %.86 = load ptr, ptr %req_ptr, align 8
  %.87 = icmp eq ptr %.86, null
  br i1 %.87, label %if.true.0.1.if, label %if.true.0.1.endif

if.start.1.if:                                    ; preds = %if.start.1
  %.63 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.63, align 1
  %.65 = getelementptr [32 x i8], ptr %.63, i64 0, i64 0
  %.66 = bitcast ptr %.65 to ptr
  %.67 = call i64 @puts(ptr %.66)
  call void @abort()
  unreachable

if.start.1.endif:                                 ; preds = %if.start.1
  %.70 = icmp ne ptr %.60, null
  br i1 %.70, label %if.true.0.1, label %if.end.1

if.true.0.1.if:                                   ; preds = %if.true.0.1
  %.89 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.89, align 1
  %.91 = getelementptr [32 x i8], ptr %.89, i64 0, i64 0
  %.92 = bitcast ptr %.91 to ptr
  %.93 = call i64 @puts(ptr %.92)
  call void @abort()
  unreachable

if.true.0.1.endif:                                ; preds = %if.true.0.1
  %.96 = call i32 @meteor_request_get_method(ptr %.86)
  store i32 %.96, ptr %m_int, align 4
  br label %if.start.2

if.start.2:                                       ; preds = %if.true.0.1.endif
  %.99 = load i32, ptr %m_int, align 4
  %.100 = sext i32 %.99 to i64
  %cmptmp = icmp eq i64 %.100, 0
  br i1 %cmptmp, label %if.true.0.2, label %if.false.0

if.end.2:                                         ; preds = %frozen.continue.3, %frozen.continue.2, %if.false.2, %frozen.continue.1, %frozen.continue
  %.191 = load ptr, ptr %req_ptr, align 8
  %.192 = icmp eq ptr %.191, null
  br i1 %.192, label %if.end.2.if, label %if.end.2.endif

if.true.0.2:                                      ; preds = %if.start.2
  %.102 = alloca %HttpMethod, align 8
  %.103 = getelementptr inbounds %HttpMethod, ptr %.102, i32 0, i32 0
  store i8 0, ptr %.103, align 1
  %.105 = load ptr, ptr %req, align 8
  %.106 = getelementptr inbounds %Request, ptr %.105, i32 0, i32 0
  %.107 = alloca %HttpMethod, align 8
  %.108 = getelementptr inbounds %HttpMethod, ptr %.107, i32 0, i32 0
  store i8 0, ptr %.108, align 1
  %.110 = bitcast ptr %.105 to ptr
  %.111 = getelementptr i8, ptr %.110, i64 -16
  %.112 = bitcast ptr %.111 to ptr
  %.113 = getelementptr %meteor.header, ptr %.112, i64 0, i32 2
  %.114 = load i8, ptr %.113, align 1
  %.115 = and i8 %.114, 1
  %.116 = icmp ne i8 %.115, 0
  br i1 %.116, label %frozen.abort, label %frozen.continue

if.false.0:                                       ; preds = %if.start.2
  %.122 = load i32, ptr %m_int, align 4
  %.123 = sext i32 %.122 to i64
  %cmptmp.1 = icmp eq i64 %.123, 1
  br i1 %cmptmp.1, label %if.true.1, label %if.false.1

frozen.abort:                                     ; preds = %if.true.0.2
  call void @abort()
  unreachable

frozen.continue:                                  ; preds = %if.true.0.2
  store ptr %.107, ptr %.106, align 8
  br label %if.end.2

if.true.1:                                        ; preds = %if.false.0
  %.125 = alloca %HttpMethod, align 8
  %.126 = getelementptr inbounds %HttpMethod, ptr %.125, i32 0, i32 0
  store i8 1, ptr %.126, align 1
  %.128 = load ptr, ptr %req, align 8
  %.129 = getelementptr inbounds %Request, ptr %.128, i32 0, i32 0
  %.130 = alloca %HttpMethod, align 8
  %.131 = getelementptr inbounds %HttpMethod, ptr %.130, i32 0, i32 0
  store i8 1, ptr %.131, align 1
  %.133 = bitcast ptr %.128 to ptr
  %.134 = getelementptr i8, ptr %.133, i64 -16
  %.135 = bitcast ptr %.134 to ptr
  %.136 = getelementptr %meteor.header, ptr %.135, i64 0, i32 2
  %.137 = load i8, ptr %.136, align 1
  %.138 = and i8 %.137, 1
  %.139 = icmp ne i8 %.138, 0
  br i1 %.139, label %frozen.abort.1, label %frozen.continue.1

if.false.1:                                       ; preds = %if.false.0
  %.145 = load i32, ptr %m_int, align 4
  %.146 = sext i32 %.145 to i64
  %cmptmp.2 = icmp eq i64 %.146, 2
  br i1 %cmptmp.2, label %if.true.2, label %if.false.2

frozen.abort.1:                                   ; preds = %if.true.1
  call void @abort()
  unreachable

frozen.continue.1:                                ; preds = %if.true.1
  store ptr %.130, ptr %.129, align 8
  br label %if.end.2

if.true.2:                                        ; preds = %if.false.1
  %.148 = alloca %HttpMethod, align 8
  %.149 = getelementptr inbounds %HttpMethod, ptr %.148, i32 0, i32 0
  store i8 2, ptr %.149, align 1
  %.151 = load ptr, ptr %req, align 8
  %.152 = getelementptr inbounds %Request, ptr %.151, i32 0, i32 0
  %.153 = alloca %HttpMethod, align 8
  %.154 = getelementptr inbounds %HttpMethod, ptr %.153, i32 0, i32 0
  store i8 2, ptr %.154, align 1
  %.156 = bitcast ptr %.151 to ptr
  %.157 = getelementptr i8, ptr %.156, i64 -16
  %.158 = bitcast ptr %.157 to ptr
  %.159 = getelementptr %meteor.header, ptr %.158, i64 0, i32 2
  %.160 = load i8, ptr %.159, align 1
  %.161 = and i8 %.160, 1
  %.162 = icmp ne i8 %.161, 0
  br i1 %.162, label %frozen.abort.2, label %frozen.continue.2

if.false.2:                                       ; preds = %if.false.1
  %.168 = load i32, ptr %m_int, align 4
  %.169 = sext i32 %.168 to i64
  %cmptmp.3 = icmp eq i64 %.169, 3
  br i1 %cmptmp.3, label %if.true.3, label %if.end.2

frozen.abort.2:                                   ; preds = %if.true.2
  call void @abort()
  unreachable

frozen.continue.2:                                ; preds = %if.true.2
  store ptr %.153, ptr %.152, align 8
  br label %if.end.2

if.true.3:                                        ; preds = %if.false.2
  %.171 = alloca %HttpMethod, align 8
  %.172 = getelementptr inbounds %HttpMethod, ptr %.171, i32 0, i32 0
  store i8 3, ptr %.172, align 1
  %.174 = load ptr, ptr %req, align 8
  %.175 = getelementptr inbounds %Request, ptr %.174, i32 0, i32 0
  %.176 = alloca %HttpMethod, align 8
  %.177 = getelementptr inbounds %HttpMethod, ptr %.176, i32 0, i32 0
  store i8 3, ptr %.177, align 1
  %.179 = bitcast ptr %.174 to ptr
  %.180 = getelementptr i8, ptr %.179, i64 -16
  %.181 = bitcast ptr %.180 to ptr
  %.182 = getelementptr %meteor.header, ptr %.181, i64 0, i32 2
  %.183 = load i8, ptr %.182, align 1
  %.184 = and i8 %.183, 1
  %.185 = icmp ne i8 %.184, 0
  br i1 %.185, label %frozen.abort.3, label %frozen.continue.3

frozen.abort.3:                                   ; preds = %if.true.3
  call void @abort()
  unreachable

frozen.continue.3:                                ; preds = %if.true.3
  store ptr %.176, ptr %.175, align 8
  br label %if.end.2

if.end.2.if:                                      ; preds = %if.end.2
  %.194 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.194, align 1
  %.196 = getelementptr [32 x i8], ptr %.194, i64 0, i64 0
  %.197 = bitcast ptr %.196 to ptr
  %.198 = call i64 @puts(ptr %.197)
  call void @abort()
  unreachable

if.end.2.endif:                                   ; preds = %if.end.2
  %.201 = call ptr @meteor_request_get_path(ptr %.191)
  %.202 = load ptr, ptr %req, align 8
  %.203 = getelementptr inbounds %Request, ptr %.202, i32 0, i32 1
  %.204 = load ptr, ptr %req_ptr, align 8
  %.205 = icmp eq ptr %.204, null
  br i1 %.205, label %if.end.2.endif.if, label %if.end.2.endif.endif

if.end.2.endif.if:                                ; preds = %if.end.2.endif
  %.207 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.207, align 1
  %.209 = getelementptr [32 x i8], ptr %.207, i64 0, i64 0
  %.210 = bitcast ptr %.209 to ptr
  %.211 = call i64 @puts(ptr %.210)
  call void @abort()
  unreachable

if.end.2.endif.endif:                             ; preds = %if.end.2.endif
  %.214 = call ptr @meteor_request_get_path(ptr %.204)
  %.215 = call i64 @strlen(ptr %.214)
  %.216 = call ptr @malloc(i64 40)
  %.217 = bitcast ptr %.216 to ptr
  call void @i64.array.init(ptr %.217)
  %.219 = alloca i64, align 8
  store i64 0, ptr %.219, align 4
  br label %cstr_conv_cond

cstr_conv_cond:                                   ; preds = %cstr_conv_body, %if.end.2.endif.endif
  %.222 = load i64, ptr %.219, align 4
  %.223 = icmp slt i64 %.222, %.215
  br i1 %.223, label %cstr_conv_body, label %cstr_conv_end

cstr_conv_body:                                   ; preds = %cstr_conv_cond
  %.225 = load i64, ptr %.219, align 4
  %.226 = getelementptr i8, ptr %.214, i64 %.225
  %.227 = load i8, ptr %.226, align 1
  %.228 = zext i8 %.227 to i64
  call void @i64.array.append(ptr %.217, i64 %.228)
  %.230 = add i64 %.225, 1
  store i64 %.230, ptr %.219, align 4
  br label %cstr_conv_cond

cstr_conv_end:                                    ; preds = %cstr_conv_cond
  %.233 = bitcast ptr %.202 to ptr
  %.234 = getelementptr i8, ptr %.233, i64 -16
  %.235 = bitcast ptr %.234 to ptr
  %.236 = getelementptr %meteor.header, ptr %.235, i64 0, i32 2
  %.237 = load i8, ptr %.236, align 1
  %.238 = and i8 %.237, 1
  %.239 = icmp ne i8 %.238, 0
  br i1 %.239, label %frozen.abort.4, label %frozen.continue.4

frozen.abort.4:                                   ; preds = %cstr_conv_end
  call void @abort()
  unreachable

frozen.continue.4:                                ; preds = %cstr_conv_end
  %.243 = bitcast ptr %.217 to ptr
  call void @meteor_retain(ptr %.243)
  store ptr %.217, ptr %.203, align 8
  %.246 = load ptr, ptr %req_ptr, align 8
  %.247 = icmp eq ptr %.246, null
  br i1 %.247, label %frozen.continue.4.if, label %frozen.continue.4.endif

frozen.continue.4.if:                             ; preds = %frozen.continue.4
  %.249 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.249, align 1
  %.251 = getelementptr [32 x i8], ptr %.249, i64 0, i64 0
  %.252 = bitcast ptr %.251 to ptr
  %.253 = call i64 @puts(ptr %.252)
  call void @abort()
  unreachable

frozen.continue.4.endif:                          ; preds = %frozen.continue.4
  %.256 = call ptr @meteor_request_get_query(ptr %.246)
  %.257 = load ptr, ptr %req, align 8
  %.258 = getelementptr inbounds %Request, ptr %.257, i32 0, i32 2
  %.259 = load ptr, ptr %req_ptr, align 8
  %.260 = icmp eq ptr %.259, null
  br i1 %.260, label %frozen.continue.4.endif.if, label %frozen.continue.4.endif.endif

frozen.continue.4.endif.if:                       ; preds = %frozen.continue.4.endif
  %.262 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.262, align 1
  %.264 = getelementptr [32 x i8], ptr %.262, i64 0, i64 0
  %.265 = bitcast ptr %.264 to ptr
  %.266 = call i64 @puts(ptr %.265)
  call void @abort()
  unreachable

frozen.continue.4.endif.endif:                    ; preds = %frozen.continue.4.endif
  %.269 = call ptr @meteor_request_get_query(ptr %.259)
  %.270 = call i64 @strlen(ptr %.269)
  %.271 = call ptr @malloc(i64 40)
  %.272 = bitcast ptr %.271 to ptr
  call void @i64.array.init(ptr %.272)
  %.274 = alloca i64, align 8
  store i64 0, ptr %.274, align 4
  br label %cstr_conv_cond.1

cstr_conv_cond.1:                                 ; preds = %cstr_conv_body.1, %frozen.continue.4.endif.endif
  %.277 = load i64, ptr %.274, align 4
  %.278 = icmp slt i64 %.277, %.270
  br i1 %.278, label %cstr_conv_body.1, label %cstr_conv_end.1

cstr_conv_body.1:                                 ; preds = %cstr_conv_cond.1
  %.280 = load i64, ptr %.274, align 4
  %.281 = getelementptr i8, ptr %.269, i64 %.280
  %.282 = load i8, ptr %.281, align 1
  %.283 = zext i8 %.282 to i64
  call void @i64.array.append(ptr %.272, i64 %.283)
  %.285 = add i64 %.280, 1
  store i64 %.285, ptr %.274, align 4
  br label %cstr_conv_cond.1

cstr_conv_end.1:                                  ; preds = %cstr_conv_cond.1
  %.288 = bitcast ptr %.257 to ptr
  %.289 = getelementptr i8, ptr %.288, i64 -16
  %.290 = bitcast ptr %.289 to ptr
  %.291 = getelementptr %meteor.header, ptr %.290, i64 0, i32 2
  %.292 = load i8, ptr %.291, align 1
  %.293 = and i8 %.292, 1
  %.294 = icmp ne i8 %.293, 0
  br i1 %.294, label %frozen.abort.5, label %frozen.continue.5

frozen.abort.5:                                   ; preds = %cstr_conv_end.1
  call void @abort()
  unreachable

frozen.continue.5:                                ; preds = %cstr_conv_end.1
  %.298 = bitcast ptr %.272 to ptr
  call void @meteor_retain(ptr %.298)
  store ptr %.272, ptr %.258, align 8
  %.301 = load ptr, ptr %req_ptr, align 8
  %.302 = icmp eq ptr %.301, null
  br i1 %.302, label %frozen.continue.5.if, label %frozen.continue.5.endif

frozen.continue.5.if:                             ; preds = %frozen.continue.5
  %.304 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.304, align 1
  %.306 = getelementptr [32 x i8], ptr %.304, i64 0, i64 0
  %.307 = bitcast ptr %.306 to ptr
  %.308 = call i64 @puts(ptr %.307)
  call void @abort()
  unreachable

frozen.continue.5.endif:                          ; preds = %frozen.continue.5
  %.311 = call ptr @meteor_request_get_body(ptr %.301)
  %.312 = load ptr, ptr %req, align 8
  %.313 = getelementptr inbounds %Request, ptr %.312, i32 0, i32 3
  %.314 = load ptr, ptr %req_ptr, align 8
  %.315 = icmp eq ptr %.314, null
  br i1 %.315, label %frozen.continue.5.endif.if, label %frozen.continue.5.endif.endif

frozen.continue.5.endif.if:                       ; preds = %frozen.continue.5.endif
  %.317 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.317, align 1
  %.319 = getelementptr [32 x i8], ptr %.317, i64 0, i64 0
  %.320 = bitcast ptr %.319 to ptr
  %.321 = call i64 @puts(ptr %.320)
  call void @abort()
  unreachable

frozen.continue.5.endif.endif:                    ; preds = %frozen.continue.5.endif
  %.324 = call ptr @meteor_request_get_body(ptr %.314)
  %.325 = call i64 @strlen(ptr %.324)
  %.326 = call ptr @malloc(i64 40)
  %.327 = bitcast ptr %.326 to ptr
  call void @i64.array.init(ptr %.327)
  %.329 = alloca i64, align 8
  store i64 0, ptr %.329, align 4
  br label %cstr_conv_cond.2

cstr_conv_cond.2:                                 ; preds = %cstr_conv_body.2, %frozen.continue.5.endif.endif
  %.332 = load i64, ptr %.329, align 4
  %.333 = icmp slt i64 %.332, %.325
  br i1 %.333, label %cstr_conv_body.2, label %cstr_conv_end.2

cstr_conv_body.2:                                 ; preds = %cstr_conv_cond.2
  %.335 = load i64, ptr %.329, align 4
  %.336 = getelementptr i8, ptr %.324, i64 %.335
  %.337 = load i8, ptr %.336, align 1
  %.338 = zext i8 %.337 to i64
  call void @i64.array.append(ptr %.327, i64 %.338)
  %.340 = add i64 %.335, 1
  store i64 %.340, ptr %.329, align 4
  br label %cstr_conv_cond.2

cstr_conv_end.2:                                  ; preds = %cstr_conv_cond.2
  %.343 = bitcast ptr %.312 to ptr
  %.344 = getelementptr i8, ptr %.343, i64 -16
  %.345 = bitcast ptr %.344 to ptr
  %.346 = getelementptr %meteor.header, ptr %.345, i64 0, i32 2
  %.347 = load i8, ptr %.346, align 1
  %.348 = and i8 %.347, 1
  %.349 = icmp ne i8 %.348, 0
  br i1 %.349, label %frozen.abort.6, label %frozen.continue.6

frozen.abort.6:                                   ; preds = %cstr_conv_end.2
  call void @abort()
  unreachable

frozen.continue.6:                                ; preds = %cstr_conv_end.2
  %.353 = bitcast ptr %.327 to ptr
  call void @meteor_retain(ptr %.353)
  store ptr %.327, ptr %.313, align 8
  %.356 = load ptr, ptr %req_ptr, align 8
  %.357 = icmp eq ptr %.356, null
  br i1 %.357, label %frozen.continue.6.if, label %frozen.continue.6.endif

frozen.continue.6.if:                             ; preds = %frozen.continue.6
  %.359 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.359, align 1
  %.361 = getelementptr [32 x i8], ptr %.359, i64 0, i64 0
  %.362 = bitcast ptr %.361 to ptr
  %.363 = call i64 @puts(ptr %.362)
  call void @abort()
  unreachable

frozen.continue.6.endif:                          ; preds = %frozen.continue.6
  %.366 = call i32 @meteor_request_get_header_count(ptr %.356)
  store i32 %.366, ptr %count, align 4
  store i64 0, ptr %i, align 4
  br label %while.cond.1

while.cond.1:                                     ; preds = %cstr_conv_end.4, %frozen.continue.6.endif
  %.370 = load i64, ptr %i, align 4
  %.371 = load i32, ptr %count, align 4
  %.372 = sext i32 %.371 to i64
  %cmptmp.4 = icmp slt i64 %.370, %.372
  br i1 %cmptmp.4, label %while.body.1, label %while.end.1

while.body.1:                                     ; preds = %while.cond.1
  %.374 = load ptr, ptr %req_ptr, align 8
  %.375 = icmp eq ptr %.374, null
  br i1 %.375, label %while.body.1.if, label %while.body.1.endif

while.end.1:                                      ; preds = %while.cond.1
  %.485 = call ptr @malloc(i64 40)
  %.486 = bitcast ptr %.485 to ptr
  %.487 = getelementptr %meteor.header, ptr %.486, i64 0, i32 0
  store i32 1, ptr %.487, align 4
  %.489 = getelementptr %meteor.header, ptr %.486, i64 0, i32 1
  store i32 0, ptr %.489, align 4
  %.491 = getelementptr %meteor.header, ptr %.486, i64 0, i32 2
  store i8 0, ptr %.491, align 1
  %.493 = getelementptr %meteor.header, ptr %.486, i64 0, i32 3
  store i8 10, ptr %.493, align 1
  %.495 = getelementptr i8, ptr %.485, i64 16
  %.496 = bitcast ptr %.495 to ptr
  call void @Response.new(ptr %.496)
  store ptr %.496, ptr %res, align 8
  store i1 false, ptr %handled, align 1
  store i64 0, ptr %i, align 4
  br label %while.cond.2

while.body.1.if:                                  ; preds = %while.body.1
  %.377 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.377, align 1
  %.379 = getelementptr [32 x i8], ptr %.377, i64 0, i64 0
  %.380 = bitcast ptr %.379 to ptr
  %.381 = call i64 @puts(ptr %.380)
  call void @abort()
  unreachable

while.body.1.endif:                               ; preds = %while.body.1
  %.384 = load i64, ptr %i, align 4
  %.385 = trunc i64 %.384 to i32
  %.386 = call ptr @meteor_request_get_header_name_at(ptr %.374, i32 %.385)
  store ptr %.386, ptr %name, align 8
  %.388 = load ptr, ptr %req_ptr, align 8
  %.389 = icmp eq ptr %.388, null
  br i1 %.389, label %while.body.1.endif.if, label %while.body.1.endif.endif

while.body.1.endif.if:                            ; preds = %while.body.1.endif
  %.391 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.391, align 1
  %.393 = getelementptr [32 x i8], ptr %.391, i64 0, i64 0
  %.394 = bitcast ptr %.393 to ptr
  %.395 = call i64 @puts(ptr %.394)
  call void @abort()
  unreachable

while.body.1.endif.endif:                         ; preds = %while.body.1.endif
  %.398 = load i64, ptr %i, align 4
  %.399 = trunc i64 %.398 to i32
  %.400 = call ptr @meteor_request_get_header_value_at(ptr %.388, i32 %.399)
  store ptr %.400, ptr %val, align 8
  %.402 = load ptr, ptr %req, align 8
  %.403 = icmp eq ptr %.402, null
  br i1 %.403, label %while.body.1.endif.endif.if, label %while.body.1.endif.endif.endif

while.body.1.endif.endif.if:                      ; preds = %while.body.1.endif.endif
  %.405 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.405, align 1
  %.407 = getelementptr [32 x i8], ptr %.405, i64 0, i64 0
  %.408 = bitcast ptr %.407 to ptr
  %.409 = call i64 @puts(ptr %.408)
  call void @abort()
  unreachable

while.body.1.endif.endif.endif:                   ; preds = %while.body.1.endif.endif
  %.412 = load %Request, ptr %.402, align 8
  %.413 = extractvalue %Request %.412, 4
  %.414 = call ptr @malloc(i64 32)
  %.415 = bitcast ptr %.414 to ptr
  %.416 = getelementptr %meteor.header, ptr %.415, i64 0, i32 0
  store i32 1, ptr %.416, align 4
  %.418 = getelementptr %meteor.header, ptr %.415, i64 0, i32 1
  store i32 0, ptr %.418, align 4
  %.420 = getelementptr %meteor.header, ptr %.415, i64 0, i32 2
  store i8 0, ptr %.420, align 1
  %.422 = getelementptr %meteor.header, ptr %.415, i64 0, i32 3
  store i8 10, ptr %.422, align 1
  %.424 = getelementptr i8, ptr %.414, i64 16
  %.425 = bitcast ptr %.424 to ptr
  %.426 = load ptr, ptr %name, align 8
  %.427 = icmp eq ptr %.426, null
  br i1 %.427, label %while.body.1.endif.endif.endif.if, label %while.body.1.endif.endif.endif.endif

while.body.1.endif.endif.endif.if:                ; preds = %while.body.1.endif.endif.endif
  %.429 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.429, align 1
  %.431 = getelementptr [32 x i8], ptr %.429, i64 0, i64 0
  %.432 = bitcast ptr %.431 to ptr
  %.433 = call i64 @puts(ptr %.432)
  call void @abort()
  unreachable

while.body.1.endif.endif.endif.endif:             ; preds = %while.body.1.endif.endif.endif
  %.436 = call i64 @strlen(ptr %.426)
  %.437 = call ptr @malloc(i64 40)
  %.438 = bitcast ptr %.437 to ptr
  call void @i64.array.init(ptr %.438)
  %.440 = alloca i64, align 8
  store i64 0, ptr %.440, align 4
  br label %cstr_conv_cond.3

cstr_conv_cond.3:                                 ; preds = %cstr_conv_body.3, %while.body.1.endif.endif.endif.endif
  %.443 = load i64, ptr %.440, align 4
  %.444 = icmp slt i64 %.443, %.436
  br i1 %.444, label %cstr_conv_body.3, label %cstr_conv_end.3

cstr_conv_body.3:                                 ; preds = %cstr_conv_cond.3
  %.446 = load i64, ptr %.440, align 4
  %.447 = getelementptr i8, ptr %.426, i64 %.446
  %.448 = load i8, ptr %.447, align 1
  %.449 = zext i8 %.448 to i64
  call void @i64.array.append(ptr %.438, i64 %.449)
  %.451 = add i64 %.446, 1
  store i64 %.451, ptr %.440, align 4
  br label %cstr_conv_cond.3

cstr_conv_end.3:                                  ; preds = %cstr_conv_cond.3
  %.454 = load ptr, ptr %val, align 8
  %.455 = icmp eq ptr %.454, null
  br i1 %.455, label %cstr_conv_end.3.if, label %cstr_conv_end.3.endif

cstr_conv_end.3.if:                               ; preds = %cstr_conv_end.3
  %.457 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.457, align 1
  %.459 = getelementptr [32 x i8], ptr %.457, i64 0, i64 0
  %.460 = bitcast ptr %.459 to ptr
  %.461 = call i64 @puts(ptr %.460)
  call void @abort()
  unreachable

cstr_conv_end.3.endif:                            ; preds = %cstr_conv_end.3
  %.464 = call i64 @strlen(ptr %.454)
  %.465 = call ptr @malloc(i64 40)
  %.466 = bitcast ptr %.465 to ptr
  call void @i64.array.init(ptr %.466)
  %.468 = alloca i64, align 8
  store i64 0, ptr %.468, align 4
  br label %cstr_conv_cond.4

cstr_conv_cond.4:                                 ; preds = %cstr_conv_body.4, %cstr_conv_end.3.endif
  %.471 = load i64, ptr %.468, align 4
  %.472 = icmp slt i64 %.471, %.464
  br i1 %.472, label %cstr_conv_body.4, label %cstr_conv_end.4

cstr_conv_body.4:                                 ; preds = %cstr_conv_cond.4
  %.474 = load i64, ptr %.468, align 4
  %.475 = getelementptr i8, ptr %.454, i64 %.474
  %.476 = load i8, ptr %.475, align 1
  %.477 = zext i8 %.476 to i64
  call void @i64.array.append(ptr %.466, i64 %.477)
  %.479 = add i64 %.474, 1
  store i64 %.479, ptr %.468, align 4
  br label %cstr_conv_cond.4

cstr_conv_end.4:                                  ; preds = %cstr_conv_cond.4
  call void @Header.new(ptr %.425, ptr %.438, ptr %.466)
  call void @Header.array.append(ptr %.413, ptr %.425)
  br label %while.cond.1

while.cond.2:                                     ; preds = %rc_release_continue, %while.end.1
  %.502 = load i64, ptr %i, align 4
  %.503 = load ptr, ptr %self.1, align 8
  %.504 = icmp eq ptr %.503, null
  br i1 %.504, label %while.cond.2.if, label %while.cond.2.endif

while.body.2:                                     ; preds = %while.cond.2.endif
  %.517 = load i64, ptr %i, align 4
  %.518 = load ptr, ptr %self.1, align 8
  %.519 = icmp eq ptr %.518, null
  br i1 %.519, label %while.body.2.if, label %while.body.2.endif

while.end.2:                                      ; preds = %if.true.0.3.endif.endif, %while.cond.2.endif
  br label %if.start.4

while.cond.2.if:                                  ; preds = %while.cond.2
  %.506 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.506, align 1
  %.508 = getelementptr [32 x i8], ptr %.506, i64 0, i64 0
  %.509 = bitcast ptr %.508 to ptr
  %.510 = call i64 @puts(ptr %.509)
  call void @abort()
  unreachable

while.cond.2.endif:                               ; preds = %while.cond.2
  %.513 = load %Server, ptr %.503, align 8
  %.514 = extractvalue %Server %.513, 3
  %.515 = call i64 @Route.array.length(ptr %.514)
  %cmptmp.5 = icmp slt i64 %.502, %.515
  br i1 %cmptmp.5, label %while.body.2, label %while.end.2

while.body.2.if:                                  ; preds = %while.body.2
  %.521 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.521, align 1
  %.523 = getelementptr [32 x i8], ptr %.521, i64 0, i64 0
  %.524 = bitcast ptr %.523 to ptr
  %.525 = call i64 @puts(ptr %.524)
  call void @abort()
  unreachable

while.body.2.endif:                               ; preds = %while.body.2
  %.528 = load %Server, ptr %.518, align 8
  %.529 = extractvalue %Server %.528, 3
  %.530 = call ptr @Route.array.get(ptr %.529, i64 %.517)
  store ptr %.530, ptr %route, align 8
  br label %if.start.3

if.start.3:                                       ; preds = %while.body.2.endif
  %.533 = load ptr, ptr %route, align 8
  %.534 = icmp eq ptr %.533, null
  br i1 %.534, label %if.start.3.if, label %if.start.3.endif

if.end.3:                                         ; preds = %str_eq.end
  %.604 = load i64, ptr %i, align 4
  %addtmp = add i64 %.604, 1
  store i64 %addtmp, ptr %i, align 4
  %.606 = load ptr, ptr %route, align 8
  %.607 = icmp eq ptr %.606, null
  br i1 %.607, label %rc_release_continue, label %rc_release

if.true.0.3:                                      ; preds = %str_eq.end
  %.578 = load ptr, ptr %route, align 8
  %.579 = getelementptr %Route, ptr %.578, i32 0, i32 2
  %.580 = load ptr, ptr %.579, align 8
  %.581 = load ptr, ptr %req, align 8
  %.582 = icmp eq ptr %.581, null
  br i1 %.582, label %if.true.0.3.if, label %if.true.0.3.endif

if.start.3.if:                                    ; preds = %if.start.3
  %.536 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.536, align 1
  %.538 = getelementptr [32 x i8], ptr %.536, i64 0, i64 0
  %.539 = bitcast ptr %.538 to ptr
  %.540 = call i64 @puts(ptr %.539)
  call void @abort()
  unreachable

if.start.3.endif:                                 ; preds = %if.start.3
  %.543 = load %Route, ptr %.533, align 8
  %.544 = extractvalue %Route %.543, 1
  %.545 = load ptr, ptr %req, align 8
  %.546 = icmp eq ptr %.545, null
  br i1 %.546, label %if.start.3.endif.if, label %if.start.3.endif.endif

if.start.3.endif.if:                              ; preds = %if.start.3.endif
  %.548 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.548, align 1
  %.550 = getelementptr [32 x i8], ptr %.548, i64 0, i64 0
  %.551 = bitcast ptr %.550 to ptr
  %.552 = call i64 @puts(ptr %.551)
  call void @abort()
  unreachable

if.start.3.endif.endif:                           ; preds = %if.start.3.endif
  %.555 = load %Request, ptr %.545, align 8
  %.556 = extractvalue %Request %.555, 1
  %left_len = call i64 @i64.array.length(ptr %.544)
  %right_len = call i64 @i64.array.length(ptr %.556)
  %str_eq_result = alloca i1, align 1
  br label %str_eq.len_check

str_eq.len_check:                                 ; preds = %if.start.3.endif.endif
  %.558 = icmp eq i64 %left_len, %right_len
  br i1 %.558, label %str_eq.compare, label %str_eq.len_mismatch

str_eq.len_mismatch:                              ; preds = %str_eq.len_check
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.compare:                                   ; preds = %str_eq.len_check
  %i_cmp = alloca i64, align 8
  store i64 0, ptr %i_cmp, align 4
  br label %str_eq.loop_cond

str_eq.loop_cond:                                 ; preds = %str_eq.loop_body, %str_eq.compare
  %.564 = load i64, ptr %i_cmp, align 4
  %.565 = icmp slt i64 %.564, %left_len
  br i1 %.565, label %str_eq.loop_body, label %str_eq.strings_equal

str_eq.loop_body:                                 ; preds = %str_eq.loop_cond
  %.567 = load i64, ptr %i_cmp, align 4
  %l_char = call i64 @i64.array.get(ptr %.544, i64 %.567)
  %r_char = call i64 @i64.array.get(ptr %.556, i64 %.567)
  %.568 = icmp eq i64 %l_char, %r_char
  %.569 = add i64 %.567, 1
  store i64 %.569, ptr %i_cmp, align 4
  br i1 %.568, label %str_eq.loop_cond, label %str_eq.char_mismatch

str_eq.char_mismatch:                             ; preds = %str_eq.loop_body
  store i1 false, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.strings_equal:                             ; preds = %str_eq.loop_cond
  store i1 true, ptr %str_eq_result, align 1
  br label %str_eq.end

str_eq.end:                                       ; preds = %str_eq.strings_equal, %str_eq.char_mismatch, %str_eq.len_mismatch
  %.576 = load i1, ptr %str_eq_result, align 1
  br i1 %.576, label %if.true.0.3, label %if.end.3

if.true.0.3.if:                                   ; preds = %if.true.0.3
  %.584 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.584, align 1
  %.586 = getelementptr [32 x i8], ptr %.584, i64 0, i64 0
  %.587 = bitcast ptr %.586 to ptr
  %.588 = call i64 @puts(ptr %.587)
  call void @abort()
  unreachable

if.true.0.3.endif:                                ; preds = %if.true.0.3
  %.591 = load ptr, ptr %res, align 8
  %.592 = icmp eq ptr %.591, null
  br i1 %.592, label %if.true.0.3.endif.if, label %if.true.0.3.endif.endif

if.true.0.3.endif.if:                             ; preds = %if.true.0.3.endif
  %.594 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.594, align 1
  %.596 = getelementptr [32 x i8], ptr %.594, i64 0, i64 0
  %.597 = bitcast ptr %.596 to ptr
  %.598 = call i64 @puts(ptr %.597)
  call void @abort()
  unreachable

if.true.0.3.endif.endif:                          ; preds = %if.true.0.3.endif
  %.601 = call ptr %.580(ptr %.581, ptr %.591)
  store i1 true, ptr %handled, align 1
  br label %while.end.2

rc_release:                                       ; preds = %if.end.3
  %.609 = bitcast ptr %.606 to ptr
  %.610 = getelementptr i8, ptr %.609, i64 -16
  %.611 = bitcast ptr %.610 to ptr
  %.612 = getelementptr %meteor.header, ptr %.611, i64 0, i32 0
  %.613 = load i32, ptr %.612, align 4
  %.614 = icmp eq i32 %.613, 1
  br i1 %.614, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %if.end.3
  br label %while.cond.2

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Route__(ptr %.606)
  %.617 = bitcast ptr %.606 to ptr
  %.618 = getelementptr i8, ptr %.617, i64 -16
  %.619 = bitcast ptr %.618 to ptr
  call void @meteor_release(ptr %.619)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.622 = bitcast ptr %.606 to ptr
  %.623 = getelementptr i8, ptr %.622, i64 -16
  %.624 = bitcast ptr %.623 to ptr
  call void @meteor_release(ptr %.624)
  br label %rc_release_continue

if.start.4:                                       ; preds = %while.end.2
  %.629 = load i1, ptr %handled, align 1
  %.630 = xor i1 %.629, true
  br i1 %.630, label %if.true.0.4, label %if.end.4

if.end.4:                                         ; preds = %if.true.0.4, %if.start.4
  %.635 = call ptr @meteor_http_response_create()
  store ptr %.635, ptr %res_ptr, align 8
  store i64 200, ptr %status_code, align 4
  br label %if.start.5

if.true.0.4:                                      ; preds = %if.start.4
  %.632 = load ptr, ptr %res, align 8
  %.633 = call ptr @Response.not_found(ptr %.632)
  br label %if.end.4

if.start.5:                                       ; preds = %if.end.4
  %.639 = load ptr, ptr %res, align 8
  %.640 = icmp eq ptr %.639, null
  br i1 %.640, label %if.start.5.if, label %if.start.5.endif

if.end.5:                                         ; preds = %if.false.1.1.endif, %if.true.2.1, %if.true.1.1, %if.true.0.5
  %.705 = load ptr, ptr %res_ptr, align 8
  %.706 = icmp eq ptr %.705, null
  br i1 %.706, label %if.end.5.if, label %if.end.5.endif

if.true.0.5:                                      ; preds = %if.start.5.endif
  store i64 200, ptr %status_code, align 4
  br label %if.end.5

if.false.0.1:                                     ; preds = %if.start.5.endif
  %.661 = load ptr, ptr %res, align 8
  %.662 = icmp eq ptr %.661, null
  br i1 %.662, label %if.false.0.1.if, label %if.false.0.1.endif

if.start.5.if:                                    ; preds = %if.start.5
  %.642 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.642, align 1
  %.644 = getelementptr [32 x i8], ptr %.642, i64 0, i64 0
  %.645 = bitcast ptr %.644 to ptr
  %.646 = call i64 @puts(ptr %.645)
  call void @abort()
  unreachable

if.start.5.endif:                                 ; preds = %if.start.5
  %.649 = load %Response, ptr %.639, align 8
  %.650 = extractvalue %Response %.649, 0
  %.651 = alloca %HttpStatus, align 8
  %.652 = getelementptr inbounds %HttpStatus, ptr %.651, i32 0, i32 0
  store i8 0, ptr %.652, align 1
  %.654 = load %HttpStatus, ptr %.650, align 1
  %.655 = load %HttpStatus, ptr %.651, align 1
  %.656 = extractvalue %HttpStatus %.654, 0
  %.657 = extractvalue %HttpStatus %.655, 0
  %cmptmp.6 = icmp eq i8 %.656, %.657
  br i1 %cmptmp.6, label %if.true.0.5, label %if.false.0.1

if.true.1.1:                                      ; preds = %if.false.0.1.endif
  store i64 404, ptr %status_code, align 4
  br label %if.end.5

if.false.1.1:                                     ; preds = %if.false.0.1.endif
  %.683 = load ptr, ptr %res, align 8
  %.684 = icmp eq ptr %.683, null
  br i1 %.684, label %if.false.1.1.if, label %if.false.1.1.endif

if.false.0.1.if:                                  ; preds = %if.false.0.1
  %.664 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.664, align 1
  %.666 = getelementptr [32 x i8], ptr %.664, i64 0, i64 0
  %.667 = bitcast ptr %.666 to ptr
  %.668 = call i64 @puts(ptr %.667)
  call void @abort()
  unreachable

if.false.0.1.endif:                               ; preds = %if.false.0.1
  %.671 = load %Response, ptr %.661, align 8
  %.672 = extractvalue %Response %.671, 0
  %.673 = alloca %HttpStatus, align 8
  %.674 = getelementptr inbounds %HttpStatus, ptr %.673, i32 0, i32 0
  store i8 9, ptr %.674, align 1
  %.676 = load %HttpStatus, ptr %.672, align 1
  %.677 = load %HttpStatus, ptr %.673, align 1
  %.678 = extractvalue %HttpStatus %.676, 0
  %.679 = extractvalue %HttpStatus %.677, 0
  %cmptmp.7 = icmp eq i8 %.678, %.679
  br i1 %cmptmp.7, label %if.true.1.1, label %if.false.1.1

if.true.2.1:                                      ; preds = %if.false.1.1.endif
  store i64 500, ptr %status_code, align 4
  br label %if.end.5

if.false.1.1.if:                                  ; preds = %if.false.1.1
  %.686 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.686, align 1
  %.688 = getelementptr [32 x i8], ptr %.686, i64 0, i64 0
  %.689 = bitcast ptr %.688 to ptr
  %.690 = call i64 @puts(ptr %.689)
  call void @abort()
  unreachable

if.false.1.1.endif:                               ; preds = %if.false.1.1
  %.693 = load %Response, ptr %.683, align 8
  %.694 = extractvalue %Response %.693, 0
  %.695 = alloca %HttpStatus, align 8
  %.696 = getelementptr inbounds %HttpStatus, ptr %.695, i32 0, i32 0
  store i8 11, ptr %.696, align 1
  %.698 = load %HttpStatus, ptr %.694, align 1
  %.699 = load %HttpStatus, ptr %.695, align 1
  %.700 = extractvalue %HttpStatus %.698, 0
  %.701 = extractvalue %HttpStatus %.699, 0
  %cmptmp.8 = icmp eq i8 %.700, %.701
  br i1 %cmptmp.8, label %if.true.2.1, label %if.end.5

if.end.5.if:                                      ; preds = %if.end.5
  %.708 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.708, align 1
  %.710 = getelementptr [32 x i8], ptr %.708, i64 0, i64 0
  %.711 = bitcast ptr %.710 to ptr
  %.712 = call i64 @puts(ptr %.711)
  call void @abort()
  unreachable

if.end.5.endif:                                   ; preds = %if.end.5
  %.715 = load i64, ptr %status_code, align 4
  %.716 = trunc i64 %.715 to i32
  %.717 = call i32 @meteor_http_response_set_status(ptr %.705, i32 %.716)
  store i64 0, ptr %i, align 4
  br label %while.cond.3

while.cond.3:                                     ; preds = %rc_release_continue.1, %if.end.5.endif
  %.720 = load i64, ptr %i, align 4
  %.721 = load ptr, ptr %res, align 8
  %.722 = icmp eq ptr %.721, null
  br i1 %.722, label %while.cond.3.if, label %while.cond.3.endif

while.body.3:                                     ; preds = %while.cond.3.endif
  %.735 = load i64, ptr %i, align 4
  %.736 = load ptr, ptr %res, align 8
  %.737 = icmp eq ptr %.736, null
  br i1 %.737, label %while.body.3.if, label %while.body.3.endif

while.end.3:                                      ; preds = %while.cond.3.endif
  %.853 = load ptr, ptr %res_ptr, align 8
  %.854 = icmp eq ptr %.853, null
  br i1 %.854, label %while.end.3.if, label %while.end.3.endif

while.cond.3.if:                                  ; preds = %while.cond.3
  %.724 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.724, align 1
  %.726 = getelementptr [32 x i8], ptr %.724, i64 0, i64 0
  %.727 = bitcast ptr %.726 to ptr
  %.728 = call i64 @puts(ptr %.727)
  call void @abort()
  unreachable

while.cond.3.endif:                               ; preds = %while.cond.3
  %.731 = load %Response, ptr %.721, align 8
  %.732 = extractvalue %Response %.731, 1
  %.733 = call i64 @Header.array.length(ptr %.732)
  %cmptmp.9 = icmp slt i64 %.720, %.733
  br i1 %cmptmp.9, label %while.body.3, label %while.end.3

while.body.3.if:                                  ; preds = %while.body.3
  %.739 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.739, align 1
  %.741 = getelementptr [32 x i8], ptr %.739, i64 0, i64 0
  %.742 = bitcast ptr %.741 to ptr
  %.743 = call i64 @puts(ptr %.742)
  call void @abort()
  unreachable

while.body.3.endif:                               ; preds = %while.body.3
  %.746 = load %Response, ptr %.736, align 8
  %.747 = extractvalue %Response %.746, 1
  %.748 = call ptr @Header.array.get(ptr %.747, i64 %.735)
  store ptr %.748, ptr %h, align 8
  %.750 = load ptr, ptr %res_ptr, align 8
  %.751 = icmp eq ptr %.750, null
  br i1 %.751, label %while.body.3.endif.if, label %while.body.3.endif.endif

while.body.3.endif.if:                            ; preds = %while.body.3.endif
  %.753 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.753, align 1
  %.755 = getelementptr [32 x i8], ptr %.753, i64 0, i64 0
  %.756 = bitcast ptr %.755 to ptr
  %.757 = call i64 @puts(ptr %.756)
  call void @abort()
  unreachable

while.body.3.endif.endif:                         ; preds = %while.body.3.endif
  %.760 = load ptr, ptr %h, align 8
  %.761 = icmp eq ptr %.760, null
  br i1 %.761, label %while.body.3.endif.endif.if, label %while.body.3.endif.endif.endif

while.body.3.endif.endif.if:                      ; preds = %while.body.3.endif.endif
  %.763 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.763, align 1
  %.765 = getelementptr [32 x i8], ptr %.763, i64 0, i64 0
  %.766 = bitcast ptr %.765 to ptr
  %.767 = call i64 @puts(ptr %.766)
  call void @abort()
  unreachable

while.body.3.endif.endif.endif:                   ; preds = %while.body.3.endif.endif
  %.770 = load %Header, ptr %.760, align 8
  %.771 = extractvalue %Header %.770, 0
  %.772 = getelementptr %i64.array, ptr %.771, i32 0, i32 1
  %.773 = load i64, ptr %.772, align 4
  %.774 = getelementptr %i64.array, ptr %.771, i32 0, i32 3
  %.775 = load ptr, ptr %.774, align 8
  %.776 = add i64 %.773, 1
  %.777 = call ptr @malloc(i64 %.776)
  %.778 = alloca i64, align 8
  store i64 0, ptr %.778, align 4
  br label %str_conv_cond

str_conv_cond:                                    ; preds = %str_conv_body, %while.body.3.endif.endif.endif
  %.781 = load i64, ptr %.778, align 4
  %.782 = icmp slt i64 %.781, %.773
  br i1 %.782, label %str_conv_body, label %str_conv_end

str_conv_body:                                    ; preds = %str_conv_cond
  %.784 = load i64, ptr %.778, align 4
  %.785 = getelementptr i64, ptr %.775, i64 %.784
  %.786 = load i64, ptr %.785, align 4
  %.787 = trunc i64 %.786 to i8
  %.788 = getelementptr i8, ptr %.777, i64 %.784
  store i8 %.787, ptr %.788, align 1
  %.790 = add i64 %.784, 1
  store i64 %.790, ptr %.778, align 4
  br label %str_conv_cond

str_conv_end:                                     ; preds = %str_conv_cond
  %.793 = getelementptr i8, ptr %.777, i64 %.773
  store i8 0, ptr %.793, align 1
  %.795 = load ptr, ptr %h, align 8
  %.796 = icmp eq ptr %.795, null
  br i1 %.796, label %str_conv_end.if, label %str_conv_end.endif

str_conv_end.if:                                  ; preds = %str_conv_end
  %.798 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.798, align 1
  %.800 = getelementptr [32 x i8], ptr %.798, i64 0, i64 0
  %.801 = bitcast ptr %.800 to ptr
  %.802 = call i64 @puts(ptr %.801)
  call void @abort()
  unreachable

str_conv_end.endif:                               ; preds = %str_conv_end
  %.805 = load %Header, ptr %.795, align 8
  %.806 = extractvalue %Header %.805, 1
  %.807 = getelementptr %i64.array, ptr %.806, i32 0, i32 1
  %.808 = load i64, ptr %.807, align 4
  %.809 = getelementptr %i64.array, ptr %.806, i32 0, i32 3
  %.810 = load ptr, ptr %.809, align 8
  %.811 = add i64 %.808, 1
  %.812 = call ptr @malloc(i64 %.811)
  %.813 = alloca i64, align 8
  store i64 0, ptr %.813, align 4
  br label %str_conv_cond.1

str_conv_cond.1:                                  ; preds = %str_conv_body.1, %str_conv_end.endif
  %.816 = load i64, ptr %.813, align 4
  %.817 = icmp slt i64 %.816, %.808
  br i1 %.817, label %str_conv_body.1, label %str_conv_end.1

str_conv_body.1:                                  ; preds = %str_conv_cond.1
  %.819 = load i64, ptr %.813, align 4
  %.820 = getelementptr i64, ptr %.810, i64 %.819
  %.821 = load i64, ptr %.820, align 4
  %.822 = trunc i64 %.821 to i8
  %.823 = getelementptr i8, ptr %.812, i64 %.819
  store i8 %.822, ptr %.823, align 1
  %.825 = add i64 %.819, 1
  store i64 %.825, ptr %.813, align 4
  br label %str_conv_cond.1

str_conv_end.1:                                   ; preds = %str_conv_cond.1
  %.828 = getelementptr i8, ptr %.812, i64 %.808
  store i8 0, ptr %.828, align 1
  %.830 = call i32 @meteor_http_response_set_header(ptr %.750, ptr %.777, ptr %.812)
  %.831 = load ptr, ptr %h, align 8
  %.832 = icmp eq ptr %.831, null
  br i1 %.832, label %rc_release_continue.1, label %rc_release.1

rc_release.1:                                     ; preds = %str_conv_end.1
  %.834 = bitcast ptr %.831 to ptr
  %.835 = getelementptr i8, ptr %.834, i64 -16
  %.836 = bitcast ptr %.835 to ptr
  %.837 = getelementptr %meteor.header, ptr %.836, i64 0, i32 0
  %.838 = load i32, ptr %.837, align 4
  %.839 = icmp eq i32 %.838, 1
  br i1 %.839, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %str_conv_end.1
  br label %while.cond.3

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Header__(ptr %.831)
  %.842 = bitcast ptr %.831 to ptr
  %.843 = getelementptr i8, ptr %.842, i64 -16
  %.844 = bitcast ptr %.843 to ptr
  call void @meteor_release(ptr %.844)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.847 = bitcast ptr %.831 to ptr
  %.848 = getelementptr i8, ptr %.847, i64 -16
  %.849 = bitcast ptr %.848 to ptr
  call void @meteor_release(ptr %.849)
  br label %rc_release_continue.1

while.end.3.if:                                   ; preds = %while.end.3
  %.856 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.856, align 1
  %.858 = getelementptr [32 x i8], ptr %.856, i64 0, i64 0
  %.859 = bitcast ptr %.858 to ptr
  %.860 = call i64 @puts(ptr %.859)
  call void @abort()
  unreachable

while.end.3.endif:                                ; preds = %while.end.3
  %.863 = load ptr, ptr %res, align 8
  %.864 = icmp eq ptr %.863, null
  br i1 %.864, label %while.end.3.endif.if, label %while.end.3.endif.endif

while.end.3.endif.if:                             ; preds = %while.end.3.endif
  %.866 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.866, align 1
  %.868 = getelementptr [32 x i8], ptr %.866, i64 0, i64 0
  %.869 = bitcast ptr %.868 to ptr
  %.870 = call i64 @puts(ptr %.869)
  call void @abort()
  unreachable

while.end.3.endif.endif:                          ; preds = %while.end.3.endif
  %.873 = load %Response, ptr %.863, align 8
  %.874 = extractvalue %Response %.873, 2
  %.875 = getelementptr %i64.array, ptr %.874, i32 0, i32 1
  %.876 = load i64, ptr %.875, align 4
  %.877 = getelementptr %i64.array, ptr %.874, i32 0, i32 3
  %.878 = load ptr, ptr %.877, align 8
  %.879 = add i64 %.876, 1
  %.880 = call ptr @malloc(i64 %.879)
  %.881 = alloca i64, align 8
  store i64 0, ptr %.881, align 4
  br label %str_conv_cond.2

str_conv_cond.2:                                  ; preds = %str_conv_body.2, %while.end.3.endif.endif
  %.884 = load i64, ptr %.881, align 4
  %.885 = icmp slt i64 %.884, %.876
  br i1 %.885, label %str_conv_body.2, label %str_conv_end.2

str_conv_body.2:                                  ; preds = %str_conv_cond.2
  %.887 = load i64, ptr %.881, align 4
  %.888 = getelementptr i64, ptr %.878, i64 %.887
  %.889 = load i64, ptr %.888, align 4
  %.890 = trunc i64 %.889 to i8
  %.891 = getelementptr i8, ptr %.880, i64 %.887
  store i8 %.890, ptr %.891, align 1
  %.893 = add i64 %.887, 1
  store i64 %.893, ptr %.881, align 4
  br label %str_conv_cond.2

str_conv_end.2:                                   ; preds = %str_conv_cond.2
  %.896 = getelementptr i8, ptr %.880, i64 %.876
  store i8 0, ptr %.896, align 1
  %.898 = load ptr, ptr %res, align 8
  %.899 = icmp eq ptr %.898, null
  br i1 %.899, label %str_conv_end.2.if, label %str_conv_end.2.endif

str_conv_end.2.if:                                ; preds = %str_conv_end.2
  %.901 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.901, align 1
  %.903 = getelementptr [32 x i8], ptr %.901, i64 0, i64 0
  %.904 = bitcast ptr %.903 to ptr
  %.905 = call i64 @puts(ptr %.904)
  call void @abort()
  unreachable

str_conv_end.2.endif:                             ; preds = %str_conv_end.2
  %.908 = load %Response, ptr %.898, align 8
  %.909 = extractvalue %Response %.908, 2
  %.910 = call i64 @i64.array.length(ptr %.909)
  %.911 = call i32 @meteor_http_response_set_body(ptr %.853, ptr %.880, i64 %.910)
  %.912 = load ptr, ptr %conn, align 8
  %.913 = icmp eq ptr %.912, null
  br i1 %.913, label %str_conv_end.2.endif.if, label %str_conv_end.2.endif.endif

str_conv_end.2.endif.if:                          ; preds = %str_conv_end.2.endif
  %.915 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.915, align 1
  %.917 = getelementptr [32 x i8], ptr %.915, i64 0, i64 0
  %.918 = bitcast ptr %.917 to ptr
  %.919 = call i64 @puts(ptr %.918)
  call void @abort()
  unreachable

str_conv_end.2.endif.endif:                       ; preds = %str_conv_end.2.endif
  %.922 = load ptr, ptr %res_ptr, align 8
  %.923 = icmp eq ptr %.922, null
  br i1 %.923, label %str_conv_end.2.endif.endif.if, label %str_conv_end.2.endif.endif.endif

str_conv_end.2.endif.endif.if:                    ; preds = %str_conv_end.2.endif.endif
  %.925 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.925, align 1
  %.927 = getelementptr [32 x i8], ptr %.925, i64 0, i64 0
  %.928 = bitcast ptr %.927 to ptr
  %.929 = call i64 @puts(ptr %.928)
  call void @abort()
  unreachable

str_conv_end.2.endif.endif.endif:                 ; preds = %str_conv_end.2.endif.endif
  %.932 = call i32 @meteor_http_connection_send_response(ptr %.912, ptr %.922)
  %.933 = load ptr, ptr %res_ptr, align 8
  %.934 = icmp eq ptr %.933, null
  br i1 %.934, label %str_conv_end.2.endif.endif.endif.if, label %str_conv_end.2.endif.endif.endif.endif

str_conv_end.2.endif.endif.endif.if:              ; preds = %str_conv_end.2.endif.endif.endif
  %.936 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.936, align 1
  %.938 = getelementptr [32 x i8], ptr %.936, i64 0, i64 0
  %.939 = bitcast ptr %.938 to ptr
  %.940 = call i64 @puts(ptr %.939)
  call void @abort()
  unreachable

str_conv_end.2.endif.endif.endif.endif:           ; preds = %str_conv_end.2.endif.endif.endif
  call void @meteor_http_response_free(ptr %.933)
  %.944 = load ptr, ptr %req_ptr, align 8
  %.945 = icmp eq ptr %.944, null
  br i1 %.945, label %str_conv_end.2.endif.endif.endif.endif.if, label %str_conv_end.2.endif.endif.endif.endif.endif

str_conv_end.2.endif.endif.endif.endif.if:        ; preds = %str_conv_end.2.endif.endif.endif.endif
  %.947 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.947, align 1
  %.949 = getelementptr [32 x i8], ptr %.947, i64 0, i64 0
  %.950 = bitcast ptr %.949 to ptr
  %.951 = call i64 @puts(ptr %.950)
  call void @abort()
  unreachable

str_conv_end.2.endif.endif.endif.endif.endif:     ; preds = %str_conv_end.2.endif.endif.endif.endif
  call void @meteor_http_request_free(ptr %.944)
  %.955 = load ptr, ptr %req, align 8
  %.956 = icmp eq ptr %.955, null
  br i1 %.956, label %rc_release_continue.2, label %rc_release.2

rc_release.2:                                     ; preds = %str_conv_end.2.endif.endif.endif.endif.endif
  %.958 = bitcast ptr %.955 to ptr
  %.959 = getelementptr i8, ptr %.958, i64 -16
  %.960 = bitcast ptr %.959 to ptr
  %.961 = getelementptr %meteor.header, ptr %.960, i64 0, i32 0
  %.962 = load i32, ptr %.961, align 4
  %.963 = icmp eq i32 %.962, 1
  br i1 %.963, label %rc_destroy.2, label %rc_release_only.2

rc_release_continue.2:                            ; preds = %rc_release_only.2, %rc_destroy.2, %str_conv_end.2.endif.endif.endif.endif.endif
  %.976 = load ptr, ptr %res, align 8
  %.977 = icmp eq ptr %.976, null
  br i1 %.977, label %rc_release_continue.3, label %rc_release.3

rc_destroy.2:                                     ; preds = %rc_release.2
  call void @__destroy_Request__(ptr %.955)
  %.966 = bitcast ptr %.955 to ptr
  %.967 = getelementptr i8, ptr %.966, i64 -16
  %.968 = bitcast ptr %.967 to ptr
  call void @meteor_release(ptr %.968)
  br label %rc_release_continue.2

rc_release_only.2:                                ; preds = %rc_release.2
  %.971 = bitcast ptr %.955 to ptr
  %.972 = getelementptr i8, ptr %.971, i64 -16
  %.973 = bitcast ptr %.972 to ptr
  call void @meteor_release(ptr %.973)
  br label %rc_release_continue.2

rc_release.3:                                     ; preds = %rc_release_continue.2
  %.979 = bitcast ptr %.976 to ptr
  %.980 = getelementptr i8, ptr %.979, i64 -16
  %.981 = bitcast ptr %.980 to ptr
  %.982 = getelementptr %meteor.header, ptr %.981, i64 0, i32 0
  %.983 = load i32, ptr %.982, align 4
  %.984 = icmp eq i32 %.983, 1
  br i1 %.984, label %rc_destroy.3, label %rc_release_only.3

rc_release_continue.3:                            ; preds = %rc_release_only.3, %rc_destroy.3, %rc_release_continue.2
  br label %if.end.1

rc_destroy.3:                                     ; preds = %rc_release.3
  call void @__destroy_Response__(ptr %.976)
  %.987 = bitcast ptr %.976 to ptr
  %.988 = getelementptr i8, ptr %.987, i64 -16
  %.989 = bitcast ptr %.988 to ptr
  call void @meteor_release(ptr %.989)
  br label %rc_release_continue.3

rc_release_only.3:                                ; preds = %rc_release.3
  %.992 = bitcast ptr %.976 to ptr
  %.993 = getelementptr i8, ptr %.992, i64 -16
  %.994 = bitcast ptr %.993 to ptr
  call void @meteor_release(ptr %.994)
  br label %rc_release_continue.3

if.end.1.if:                                      ; preds = %if.end.1
  %.1001 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.1001, align 1
  %.1003 = getelementptr [32 x i8], ptr %.1001, i64 0, i64 0
  %.1004 = bitcast ptr %.1003 to ptr
  %.1005 = call i64 @puts(ptr %.1004)
  call void @abort()
  unreachable

if.end.1.endif:                                   ; preds = %if.end.1
  call void @meteor_http_connection_close(ptr %.998)
  br label %while.cond
}

define void @Server.stop(ptr %self) {
entry:
  %self.1 = alloca ptr, align 8
  store ptr %self, ptr %self.1, align 8
  %.4 = load ptr, ptr %self.1, align 8
  %.5 = icmp eq ptr %.4, null
  br i1 %.5, label %entry.if, label %entry.endif

exit:                                             ; preds = %entry.endif
  ret void

entry.if:                                         ; preds = %entry
  %.7 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.7, align 1
  %.9 = getelementptr [32 x i8], ptr %.7, i64 0, i64 0
  %.10 = bitcast ptr %.9 to ptr
  %.11 = call i64 @puts(ptr %.10)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.14 = load %Server, ptr %.4, align 8
  %.15 = extractvalue %Server %.14, 0
  %.16 = call i32 @meteor_http_server_stop(ptr %.15)
  %.17 = call ptr @malloc(i64 40)
  %.18 = bitcast ptr %.17 to ptr
  call void @i64.array.init(ptr %.18)
  call void @i64.array.append(ptr %.18, i64 240)
  call void @i64.array.append(ptr %.18, i64 159)
  call void @i64.array.append(ptr %.18, i64 155)
  call void @i64.array.append(ptr %.18, i64 145)
  call void @i64.array.append(ptr %.18, i64 32)
  call void @i64.array.append(ptr %.18, i64 83)
  call void @i64.array.append(ptr %.18, i64 101)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 118)
  call void @i64.array.append(ptr %.18, i64 101)
  call void @i64.array.append(ptr %.18, i64 114)
  call void @i64.array.append(ptr %.18, i64 32)
  call void @i64.array.append(ptr %.18, i64 115)
  call void @i64.array.append(ptr %.18, i64 116)
  call void @i64.array.append(ptr %.18, i64 111)
  call void @i64.array.append(ptr %.18, i64 112)
  call void @i64.array.append(ptr %.18, i64 112)
  call void @i64.array.append(ptr %.18, i64 101)
  call void @i64.array.append(ptr %.18, i64 100)
  call void @print(ptr %.18)
  br label %exit
}

define internal void @__destroy_Server__(ptr %.1) {
entry:
  %.3 = icmp eq ptr %.1, null
  br i1 %.3, label %exit, label %not_null

exit:                                             ; preds = %continue_static_dir, %entry
  ret void

not_null:                                         ; preds = %entry
  %.5 = getelementptr inbounds %Server, ptr %.1, i32 0, i32 1
  %.6 = load ptr, ptr %.5, align 8
  %.7 = icmp eq ptr %.6, null
  br i1 %.7, label %continue_host, label %release_host

release_host:                                     ; preds = %not_null
  %.9 = bitcast ptr %.6 to ptr
  call void @meteor_release(ptr %.9)
  br label %continue_host

continue_host:                                    ; preds = %release_host, %not_null
  %.12 = getelementptr inbounds %Server, ptr %.1, i32 0, i32 3
  %.13 = load ptr, ptr %.12, align 8
  %.14 = icmp eq ptr %.13, null
  br i1 %.14, label %continue_routes, label %release_routes

release_routes:                                   ; preds = %continue_host
  %.16 = bitcast ptr %.13 to ptr
  call void @meteor_release(ptr %.16)
  br label %continue_routes

continue_routes:                                  ; preds = %release_routes, %continue_host
  %.19 = getelementptr inbounds %Server, ptr %.1, i32 0, i32 4
  %.20 = load ptr, ptr %.19, align 8
  %.21 = icmp eq ptr %.20, null
  br i1 %.21, label %continue_middlewares, label %release_middlewares

release_middlewares:                              ; preds = %continue_routes
  %.23 = bitcast ptr %.20 to ptr
  call void @meteor_release(ptr %.23)
  br label %continue_middlewares

continue_middlewares:                             ; preds = %release_middlewares, %continue_routes
  %.26 = getelementptr inbounds %Server, ptr %.1, i32 0, i32 5
  %.27 = load ptr, ptr %.26, align 8
  %.28 = icmp eq ptr %.27, null
  br i1 %.28, label %continue_static_dir, label %release_static_dir

release_static_dir:                               ; preds = %continue_middlewares
  %.30 = bitcast ptr %.27 to ptr
  call void @meteor_release(ptr %.30)
  br label %continue_static_dir

continue_static_dir:                              ; preds = %release_static_dir, %continue_middlewares
  br label %exit
}

define ptr @create_server() {
entry:
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.3 = call ptr @malloc(i64 64)
  %.4 = bitcast ptr %.3 to ptr
  %.5 = getelementptr %meteor.header, ptr %.4, i64 0, i32 0
  store i32 1, ptr %.5, align 4
  %.7 = getelementptr %meteor.header, ptr %.4, i64 0, i32 1
  store i32 0, ptr %.7, align 4
  %.9 = getelementptr %meteor.header, ptr %.4, i64 0, i32 2
  store i8 0, ptr %.9, align 1
  %.11 = getelementptr %meteor.header, ptr %.4, i64 0, i32 3
  store i8 10, ptr %.11, align 1
  %.13 = getelementptr i8, ptr %.3, i64 16
  %.14 = bitcast ptr %.13 to ptr
  call void @Server.new(ptr %.14)
  %.16 = load ptr, ptr %ret_var, align 8
  %.17 = bitcast ptr %.14 to ptr
  %.18 = getelementptr i8, ptr %.17, i64 -16
  %.19 = bitcast ptr %.18 to ptr
  call void @meteor_retain(ptr %.19)
  %.21 = icmp eq ptr %.16, null
  br i1 %.21, label %rc_release_continue, label %rc_release

exit:                                             ; preds = %rc_release_continue.1
  %.68 = load ptr, ptr %ret_var, align 8
  %.69 = icmp eq ptr %.68, null
  br i1 %.69, label %exit.if, label %exit.endif

rc_release:                                       ; preds = %entry
  %.23 = bitcast ptr %.16 to ptr
  %.24 = getelementptr i8, ptr %.23, i64 -16
  %.25 = bitcast ptr %.24 to ptr
  %.26 = getelementptr %meteor.header, ptr %.25, i64 0, i32 0
  %.27 = load i32, ptr %.26, align 4
  %.28 = icmp eq i32 %.27, 1
  br i1 %.28, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %entry
  store ptr %.14, ptr %ret_var, align 8
  %.42 = bitcast ptr %.14 to ptr
  %.43 = getelementptr i8, ptr %.42, i64 -16
  %.44 = bitcast ptr %.43 to ptr
  call void @meteor_retain(ptr %.44)
  %.46 = load ptr, ptr %ret_var, align 8
  %.47 = icmp eq ptr %.46, null
  br i1 %.47, label %rc_release_continue.1, label %rc_release.1

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Server__(ptr %.16)
  %.31 = bitcast ptr %.16 to ptr
  %.32 = getelementptr i8, ptr %.31, i64 -16
  %.33 = bitcast ptr %.32 to ptr
  call void @meteor_release(ptr %.33)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.36 = bitcast ptr %.16 to ptr
  %.37 = getelementptr i8, ptr %.36, i64 -16
  %.38 = bitcast ptr %.37 to ptr
  call void @meteor_release(ptr %.38)
  br label %rc_release_continue

rc_release.1:                                     ; preds = %rc_release_continue
  %.49 = bitcast ptr %.46 to ptr
  %.50 = getelementptr i8, ptr %.49, i64 -16
  %.51 = bitcast ptr %.50 to ptr
  %.52 = getelementptr %meteor.header, ptr %.51, i64 0, i32 0
  %.53 = load i32, ptr %.52, align 4
  %.54 = icmp eq i32 %.53, 1
  br i1 %.54, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %rc_release_continue
  br label %exit

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Server__(ptr %.46)
  %.57 = bitcast ptr %.46 to ptr
  %.58 = getelementptr i8, ptr %.57, i64 -16
  %.59 = bitcast ptr %.58 to ptr
  call void @meteor_release(ptr %.59)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.62 = bitcast ptr %.46 to ptr
  %.63 = getelementptr i8, ptr %.62, i64 -16
  %.64 = bitcast ptr %.63 to ptr
  call void @meteor_release(ptr %.64)
  br label %rc_release_continue.1

exit.if:                                          ; preds = %exit
  %.71 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.71, align 1
  %.73 = getelementptr [32 x i8], ptr %.71, i64 0, i64 0
  %.74 = bitcast ptr %.73 to ptr
  %.75 = call i64 @puts(ptr %.74)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.68
}

define ptr @create_request() {
entry:
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.3 = call ptr @malloc(i64 64)
  %.4 = bitcast ptr %.3 to ptr
  %.5 = getelementptr %meteor.header, ptr %.4, i64 0, i32 0
  store i32 1, ptr %.5, align 4
  %.7 = getelementptr %meteor.header, ptr %.4, i64 0, i32 1
  store i32 0, ptr %.7, align 4
  %.9 = getelementptr %meteor.header, ptr %.4, i64 0, i32 2
  store i8 0, ptr %.9, align 1
  %.11 = getelementptr %meteor.header, ptr %.4, i64 0, i32 3
  store i8 10, ptr %.11, align 1
  %.13 = getelementptr i8, ptr %.3, i64 16
  %.14 = bitcast ptr %.13 to ptr
  call void @Request.new(ptr %.14)
  %.16 = load ptr, ptr %ret_var, align 8
  %.17 = bitcast ptr %.14 to ptr
  %.18 = getelementptr i8, ptr %.17, i64 -16
  %.19 = bitcast ptr %.18 to ptr
  call void @meteor_retain(ptr %.19)
  %.21 = icmp eq ptr %.16, null
  br i1 %.21, label %rc_release_continue, label %rc_release

exit:                                             ; preds = %rc_release_continue.1
  %.68 = load ptr, ptr %ret_var, align 8
  %.69 = icmp eq ptr %.68, null
  br i1 %.69, label %exit.if, label %exit.endif

rc_release:                                       ; preds = %entry
  %.23 = bitcast ptr %.16 to ptr
  %.24 = getelementptr i8, ptr %.23, i64 -16
  %.25 = bitcast ptr %.24 to ptr
  %.26 = getelementptr %meteor.header, ptr %.25, i64 0, i32 0
  %.27 = load i32, ptr %.26, align 4
  %.28 = icmp eq i32 %.27, 1
  br i1 %.28, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %entry
  store ptr %.14, ptr %ret_var, align 8
  %.42 = bitcast ptr %.14 to ptr
  %.43 = getelementptr i8, ptr %.42, i64 -16
  %.44 = bitcast ptr %.43 to ptr
  call void @meteor_retain(ptr %.44)
  %.46 = load ptr, ptr %ret_var, align 8
  %.47 = icmp eq ptr %.46, null
  br i1 %.47, label %rc_release_continue.1, label %rc_release.1

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Request__(ptr %.16)
  %.31 = bitcast ptr %.16 to ptr
  %.32 = getelementptr i8, ptr %.31, i64 -16
  %.33 = bitcast ptr %.32 to ptr
  call void @meteor_release(ptr %.33)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.36 = bitcast ptr %.16 to ptr
  %.37 = getelementptr i8, ptr %.36, i64 -16
  %.38 = bitcast ptr %.37 to ptr
  call void @meteor_release(ptr %.38)
  br label %rc_release_continue

rc_release.1:                                     ; preds = %rc_release_continue
  %.49 = bitcast ptr %.46 to ptr
  %.50 = getelementptr i8, ptr %.49, i64 -16
  %.51 = bitcast ptr %.50 to ptr
  %.52 = getelementptr %meteor.header, ptr %.51, i64 0, i32 0
  %.53 = load i32, ptr %.52, align 4
  %.54 = icmp eq i32 %.53, 1
  br i1 %.54, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %rc_release_continue
  br label %exit

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Request__(ptr %.46)
  %.57 = bitcast ptr %.46 to ptr
  %.58 = getelementptr i8, ptr %.57, i64 -16
  %.59 = bitcast ptr %.58 to ptr
  call void @meteor_release(ptr %.59)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.62 = bitcast ptr %.46 to ptr
  %.63 = getelementptr i8, ptr %.62, i64 -16
  %.64 = bitcast ptr %.63 to ptr
  call void @meteor_release(ptr %.64)
  br label %rc_release_continue.1

exit.if:                                          ; preds = %exit
  %.71 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.71, align 1
  %.73 = getelementptr [32 x i8], ptr %.71, i64 0, i64 0
  %.74 = bitcast ptr %.73 to ptr
  %.75 = call i64 @puts(ptr %.74)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.68
}

define ptr @create_response() {
entry:
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.3 = call ptr @malloc(i64 40)
  %.4 = bitcast ptr %.3 to ptr
  %.5 = getelementptr %meteor.header, ptr %.4, i64 0, i32 0
  store i32 1, ptr %.5, align 4
  %.7 = getelementptr %meteor.header, ptr %.4, i64 0, i32 1
  store i32 0, ptr %.7, align 4
  %.9 = getelementptr %meteor.header, ptr %.4, i64 0, i32 2
  store i8 0, ptr %.9, align 1
  %.11 = getelementptr %meteor.header, ptr %.4, i64 0, i32 3
  store i8 10, ptr %.11, align 1
  %.13 = getelementptr i8, ptr %.3, i64 16
  %.14 = bitcast ptr %.13 to ptr
  call void @Response.new(ptr %.14)
  %.16 = load ptr, ptr %ret_var, align 8
  %.17 = bitcast ptr %.14 to ptr
  %.18 = getelementptr i8, ptr %.17, i64 -16
  %.19 = bitcast ptr %.18 to ptr
  call void @meteor_retain(ptr %.19)
  %.21 = icmp eq ptr %.16, null
  br i1 %.21, label %rc_release_continue, label %rc_release

exit:                                             ; preds = %rc_release_continue.1
  %.68 = load ptr, ptr %ret_var, align 8
  %.69 = icmp eq ptr %.68, null
  br i1 %.69, label %exit.if, label %exit.endif

rc_release:                                       ; preds = %entry
  %.23 = bitcast ptr %.16 to ptr
  %.24 = getelementptr i8, ptr %.23, i64 -16
  %.25 = bitcast ptr %.24 to ptr
  %.26 = getelementptr %meteor.header, ptr %.25, i64 0, i32 0
  %.27 = load i32, ptr %.26, align 4
  %.28 = icmp eq i32 %.27, 1
  br i1 %.28, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %entry
  store ptr %.14, ptr %ret_var, align 8
  %.42 = bitcast ptr %.14 to ptr
  %.43 = getelementptr i8, ptr %.42, i64 -16
  %.44 = bitcast ptr %.43 to ptr
  call void @meteor_retain(ptr %.44)
  %.46 = load ptr, ptr %ret_var, align 8
  %.47 = icmp eq ptr %.46, null
  br i1 %.47, label %rc_release_continue.1, label %rc_release.1

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Response__(ptr %.16)
  %.31 = bitcast ptr %.16 to ptr
  %.32 = getelementptr i8, ptr %.31, i64 -16
  %.33 = bitcast ptr %.32 to ptr
  call void @meteor_release(ptr %.33)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.36 = bitcast ptr %.16 to ptr
  %.37 = getelementptr i8, ptr %.36, i64 -16
  %.38 = bitcast ptr %.37 to ptr
  call void @meteor_release(ptr %.38)
  br label %rc_release_continue

rc_release.1:                                     ; preds = %rc_release_continue
  %.49 = bitcast ptr %.46 to ptr
  %.50 = getelementptr i8, ptr %.49, i64 -16
  %.51 = bitcast ptr %.50 to ptr
  %.52 = getelementptr %meteor.header, ptr %.51, i64 0, i32 0
  %.53 = load i32, ptr %.52, align 4
  %.54 = icmp eq i32 %.53, 1
  br i1 %.54, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %rc_release_continue
  br label %exit

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Response__(ptr %.46)
  %.57 = bitcast ptr %.46 to ptr
  %.58 = getelementptr i8, ptr %.57, i64 -16
  %.59 = bitcast ptr %.58 to ptr
  call void @meteor_release(ptr %.59)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.62 = bitcast ptr %.46 to ptr
  %.63 = getelementptr i8, ptr %.62, i64 -16
  %.64 = bitcast ptr %.63 to ptr
  call void @meteor_release(ptr %.64)
  br label %rc_release_continue.1

exit.if:                                          ; preds = %exit
  %.71 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.71, align 1
  %.73 = getelementptr [32 x i8], ptr %.71, i64 0, i64 0
  %.74 = bitcast ptr %.73 to ptr
  %.75 = call i64 @puts(ptr %.74)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.68
}

define ptr @home_handler(ptr %req, ptr %res) {
entry:
  %html = alloca ptr, align 8
  %req.1 = alloca ptr, align 8
  store ptr %req, ptr %req.1, align 8
  %res.1 = alloca ptr, align 8
  store ptr %res, ptr %res.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = call ptr @malloc(i64 40)
  %.8 = bitcast ptr %.7 to ptr
  call void @i64.array.init(ptr %.8)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 33)
  call void @i64.array.append(ptr %.8, i64 68)
  call void @i64.array.append(ptr %.8, i64 79)
  call void @i64.array.append(ptr %.8, i64 67)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 89)
  call void @i64.array.append(ptr %.8, i64 80)
  call void @i64.array.append(ptr %.8, i64 69)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 77)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 72)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 80)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 68)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 123)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 65)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 44)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 119)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 56)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 53)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 50)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 125)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 123)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 35)
  call void @i64.array.append(ptr %.8, i64 54)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 53)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 125)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 46)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 107)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 123)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 50)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 125)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 46)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 107)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 123)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 53)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 35)
  call void @i64.array.append(ptr %.8, i64 52)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 54)
  call void @i64.array.append(ptr %.8, i64 57)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 125)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 123)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 107)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 35)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 52)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 52)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 52)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 50)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 54)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 51)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 59)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 125)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 240)
  call void @i64.array.append(ptr %.8, i64 159)
  call void @i64.array.append(ptr %.8, i64 154)
  call void @i64.array.append(ptr %.8, i64 128)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 87)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 77)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 72)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 80)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 83)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 118)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 33)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 118)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 77)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 39)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 72)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 80)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 46)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 118)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 61)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 107)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 51)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 51)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 61)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 71)
  call void @i64.array.append(ptr %.8, i64 69)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 83)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 120)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 61)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 71)
  call void @i64.array.append(ptr %.8, i64 69)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 74)
  call void @i64.array.append(ptr %.8, i64 83)
  call void @i64.array.append(ptr %.8, i64 79)
  call void @i64.array.append(ptr %.8, i64 78)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 65)
  call void @i64.array.append(ptr %.8, i64 80)
  call void @i64.array.append(ptr %.8, i64 73)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 102)
  call void @i64.array.append(ptr %.8, i64 61)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 71)
  call void @i64.array.append(ptr %.8, i64 69)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 67)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 40)
  call void @i64.array.append(ptr %.8, i64 74)
  call void @i64.array.append(ptr %.8, i64 83)
  call void @i64.array.append(ptr %.8, i64 79)
  call void @i64.array.append(ptr %.8, i64 78)
  call void @i64.array.append(ptr %.8, i64 41)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 118)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 80)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 119)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 77)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 76)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 99)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 98)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 100)
  call void @i64.array.append(ptr %.8, i64 121)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 60)
  call void @i64.array.append(ptr %.8, i64 47)
  call void @i64.array.append(ptr %.8, i64 104)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 108)
  call void @i64.array.append(ptr %.8, i64 62)
  call void @i64.array.append(ptr %.8, i64 10)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 32)
  store ptr %.8, ptr %html, align 8
  %.1044 = load ptr, ptr %res.1, align 8
  %.1045 = load ptr, ptr %html, align 8
  %.1046 = icmp eq ptr %.1045, null
  br i1 %.1046, label %entry.if, label %entry.endif

exit:                                             ; preds = %rc_release_continue.2
  %.1114 = load ptr, ptr %ret_var, align 8
  %.1115 = icmp eq ptr %.1114, null
  br i1 %.1115, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.1048 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.1048, align 1
  %.1050 = getelementptr [32 x i8], ptr %.1048, i64 0, i64 0
  %.1051 = bitcast ptr %.1050 to ptr
  %.1052 = call i64 @puts(ptr %.1051)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.1055 = call ptr @Response.html(ptr %.1044, ptr %.1045)
  %.1056 = load ptr, ptr %ret_var, align 8
  %.1057 = bitcast ptr %.1055 to ptr
  %.1058 = getelementptr i8, ptr %.1057, i64 -16
  %.1059 = bitcast ptr %.1058 to ptr
  call void @meteor_retain(ptr %.1059)
  %.1061 = icmp eq ptr %.1056, null
  br i1 %.1061, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %entry.endif
  %.1063 = bitcast ptr %.1056 to ptr
  %.1064 = getelementptr i8, ptr %.1063, i64 -16
  %.1065 = bitcast ptr %.1064 to ptr
  %.1066 = getelementptr %meteor.header, ptr %.1065, i64 0, i32 0
  %.1067 = load i32, ptr %.1066, align 4
  %.1068 = icmp eq i32 %.1067, 1
  br i1 %.1068, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %entry.endif
  store ptr %.1055, ptr %ret_var, align 8
  %.1082 = bitcast ptr %.1055 to ptr
  %.1083 = getelementptr i8, ptr %.1082, i64 -16
  %.1084 = bitcast ptr %.1083 to ptr
  call void @meteor_retain(ptr %.1084)
  %.1086 = load ptr, ptr %ret_var, align 8
  %.1087 = icmp eq ptr %.1086, null
  br i1 %.1087, label %rc_release_continue.1, label %rc_release.1

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Response__(ptr %.1056)
  %.1071 = bitcast ptr %.1056 to ptr
  %.1072 = getelementptr i8, ptr %.1071, i64 -16
  %.1073 = bitcast ptr %.1072 to ptr
  call void @meteor_release(ptr %.1073)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.1076 = bitcast ptr %.1056 to ptr
  %.1077 = getelementptr i8, ptr %.1076, i64 -16
  %.1078 = bitcast ptr %.1077 to ptr
  call void @meteor_release(ptr %.1078)
  br label %rc_release_continue

rc_release.1:                                     ; preds = %rc_release_continue
  %.1089 = bitcast ptr %.1086 to ptr
  %.1090 = getelementptr i8, ptr %.1089, i64 -16
  %.1091 = bitcast ptr %.1090 to ptr
  %.1092 = getelementptr %meteor.header, ptr %.1091, i64 0, i32 0
  %.1093 = load i32, ptr %.1092, align 4
  %.1094 = icmp eq i32 %.1093, 1
  br i1 %.1094, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %rc_release_continue
  %.1107 = load ptr, ptr %html, align 8
  %.1108 = icmp eq ptr %.1107, null
  br i1 %.1108, label %rc_release_continue.2, label %rc_release.2

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Response__(ptr %.1086)
  %.1097 = bitcast ptr %.1086 to ptr
  %.1098 = getelementptr i8, ptr %.1097, i64 -16
  %.1099 = bitcast ptr %.1098 to ptr
  call void @meteor_release(ptr %.1099)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.1102 = bitcast ptr %.1086 to ptr
  %.1103 = getelementptr i8, ptr %.1102, i64 -16
  %.1104 = bitcast ptr %.1103 to ptr
  call void @meteor_release(ptr %.1104)
  br label %rc_release_continue.1

rc_release.2:                                     ; preds = %rc_release_continue.1
  %.1110 = bitcast ptr %.1107 to ptr
  call void @meteor_release(ptr %.1110)
  br label %rc_release_continue.2

rc_release_continue.2:                            ; preds = %rc_release.2, %rc_release_continue.1
  br label %exit

exit.if:                                          ; preds = %exit
  %.1117 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.1117, align 1
  %.1119 = getelementptr [32 x i8], ptr %.1117, i64 0, i64 0
  %.1120 = bitcast ptr %.1119 to ptr
  %.1121 = call i64 @puts(ptr %.1120)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.1114
}

define ptr @hello_handler(ptr %req, ptr %res) {
entry:
  %req.1 = alloca ptr, align 8
  store ptr %req, ptr %req.1, align 8
  %res.1 = alloca ptr, align 8
  store ptr %res, ptr %res.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = load ptr, ptr %res.1, align 8
  %.8 = call ptr @malloc(i64 40)
  %.9 = bitcast ptr %.8 to ptr
  call void @i64.array.init(ptr %.9)
  call void @i64.array.append(ptr %.9, i64 72)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 108)
  call void @i64.array.append(ptr %.9, i64 108)
  call void @i64.array.append(ptr %.9, i64 111)
  call void @i64.array.append(ptr %.9, i64 32)
  call void @i64.array.append(ptr %.9, i64 102)
  call void @i64.array.append(ptr %.9, i64 114)
  call void @i64.array.append(ptr %.9, i64 111)
  call void @i64.array.append(ptr %.9, i64 109)
  call void @i64.array.append(ptr %.9, i64 32)
  call void @i64.array.append(ptr %.9, i64 77)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 116)
  call void @i64.array.append(ptr %.9, i64 101)
  call void @i64.array.append(ptr %.9, i64 111)
  call void @i64.array.append(ptr %.9, i64 114)
  call void @i64.array.append(ptr %.9, i64 33)
  call void @i64.array.append(ptr %.9, i64 32)
  call void @i64.array.append(ptr %.9, i64 240)
  call void @i64.array.append(ptr %.9, i64 159)
  call void @i64.array.append(ptr %.9, i64 140)
  call void @i64.array.append(ptr %.9, i64 159)
  %.34 = call ptr @Response.text(ptr %.7, ptr %.9)
  %.35 = load ptr, ptr %ret_var, align 8
  %.36 = bitcast ptr %.34 to ptr
  %.37 = getelementptr i8, ptr %.36, i64 -16
  %.38 = bitcast ptr %.37 to ptr
  call void @meteor_retain(ptr %.38)
  %.40 = icmp eq ptr %.35, null
  br i1 %.40, label %rc_release_continue, label %rc_release

exit:                                             ; preds = %rc_release_continue.1
  %.87 = load ptr, ptr %ret_var, align 8
  %.88 = icmp eq ptr %.87, null
  br i1 %.88, label %exit.if, label %exit.endif

rc_release:                                       ; preds = %entry
  %.42 = bitcast ptr %.35 to ptr
  %.43 = getelementptr i8, ptr %.42, i64 -16
  %.44 = bitcast ptr %.43 to ptr
  %.45 = getelementptr %meteor.header, ptr %.44, i64 0, i32 0
  %.46 = load i32, ptr %.45, align 4
  %.47 = icmp eq i32 %.46, 1
  br i1 %.47, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %entry
  store ptr %.34, ptr %ret_var, align 8
  %.61 = bitcast ptr %.34 to ptr
  %.62 = getelementptr i8, ptr %.61, i64 -16
  %.63 = bitcast ptr %.62 to ptr
  call void @meteor_retain(ptr %.63)
  %.65 = load ptr, ptr %ret_var, align 8
  %.66 = icmp eq ptr %.65, null
  br i1 %.66, label %rc_release_continue.1, label %rc_release.1

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Response__(ptr %.35)
  %.50 = bitcast ptr %.35 to ptr
  %.51 = getelementptr i8, ptr %.50, i64 -16
  %.52 = bitcast ptr %.51 to ptr
  call void @meteor_release(ptr %.52)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.55 = bitcast ptr %.35 to ptr
  %.56 = getelementptr i8, ptr %.55, i64 -16
  %.57 = bitcast ptr %.56 to ptr
  call void @meteor_release(ptr %.57)
  br label %rc_release_continue

rc_release.1:                                     ; preds = %rc_release_continue
  %.68 = bitcast ptr %.65 to ptr
  %.69 = getelementptr i8, ptr %.68, i64 -16
  %.70 = bitcast ptr %.69 to ptr
  %.71 = getelementptr %meteor.header, ptr %.70, i64 0, i32 0
  %.72 = load i32, ptr %.71, align 4
  %.73 = icmp eq i32 %.72, 1
  br i1 %.73, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %rc_release_continue
  br label %exit

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Response__(ptr %.65)
  %.76 = bitcast ptr %.65 to ptr
  %.77 = getelementptr i8, ptr %.76, i64 -16
  %.78 = bitcast ptr %.77 to ptr
  call void @meteor_release(ptr %.78)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.81 = bitcast ptr %.65 to ptr
  %.82 = getelementptr i8, ptr %.81, i64 -16
  %.83 = bitcast ptr %.82 to ptr
  call void @meteor_release(ptr %.83)
  br label %rc_release_continue.1

exit.if:                                          ; preds = %exit
  %.90 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.90, align 1
  %.92 = getelementptr [32 x i8], ptr %.90, i64 0, i64 0
  %.93 = bitcast ptr %.92 to ptr
  %.94 = call i64 @puts(ptr %.93)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.87
}

define ptr @api_info_handler(ptr %req, ptr %res) {
entry:
  %json_data = alloca ptr, align 8
  %req.1 = alloca ptr, align 8
  store ptr %req, ptr %req.1, align 8
  %res.1 = alloca ptr, align 8
  store ptr %res, ptr %res.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = call ptr @malloc(i64 40)
  %.8 = bitcast ptr %.7 to ptr
  call void @i64.array.init(ptr %.8)
  call void @i64.array.append(ptr %.8, i64 123)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 77)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 72)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 80)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 83)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 118)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 44)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 118)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 111)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 46)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 46)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 44)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 125)
  store ptr %.8, ptr %json_data, align 8
  %.82 = load ptr, ptr %res.1, align 8
  %.83 = load ptr, ptr %json_data, align 8
  %.84 = icmp eq ptr %.83, null
  br i1 %.84, label %entry.if, label %entry.endif

exit:                                             ; preds = %rc_release_continue.2
  %.152 = load ptr, ptr %ret_var, align 8
  %.153 = icmp eq ptr %.152, null
  br i1 %.153, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.86 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.86, align 1
  %.88 = getelementptr [32 x i8], ptr %.86, i64 0, i64 0
  %.89 = bitcast ptr %.88 to ptr
  %.90 = call i64 @puts(ptr %.89)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.93 = call ptr @Response.json(ptr %.82, ptr %.83)
  %.94 = load ptr, ptr %ret_var, align 8
  %.95 = bitcast ptr %.93 to ptr
  %.96 = getelementptr i8, ptr %.95, i64 -16
  %.97 = bitcast ptr %.96 to ptr
  call void @meteor_retain(ptr %.97)
  %.99 = icmp eq ptr %.94, null
  br i1 %.99, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %entry.endif
  %.101 = bitcast ptr %.94 to ptr
  %.102 = getelementptr i8, ptr %.101, i64 -16
  %.103 = bitcast ptr %.102 to ptr
  %.104 = getelementptr %meteor.header, ptr %.103, i64 0, i32 0
  %.105 = load i32, ptr %.104, align 4
  %.106 = icmp eq i32 %.105, 1
  br i1 %.106, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %entry.endif
  store ptr %.93, ptr %ret_var, align 8
  %.120 = bitcast ptr %.93 to ptr
  %.121 = getelementptr i8, ptr %.120, i64 -16
  %.122 = bitcast ptr %.121 to ptr
  call void @meteor_retain(ptr %.122)
  %.124 = load ptr, ptr %ret_var, align 8
  %.125 = icmp eq ptr %.124, null
  br i1 %.125, label %rc_release_continue.1, label %rc_release.1

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Response__(ptr %.94)
  %.109 = bitcast ptr %.94 to ptr
  %.110 = getelementptr i8, ptr %.109, i64 -16
  %.111 = bitcast ptr %.110 to ptr
  call void @meteor_release(ptr %.111)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.114 = bitcast ptr %.94 to ptr
  %.115 = getelementptr i8, ptr %.114, i64 -16
  %.116 = bitcast ptr %.115 to ptr
  call void @meteor_release(ptr %.116)
  br label %rc_release_continue

rc_release.1:                                     ; preds = %rc_release_continue
  %.127 = bitcast ptr %.124 to ptr
  %.128 = getelementptr i8, ptr %.127, i64 -16
  %.129 = bitcast ptr %.128 to ptr
  %.130 = getelementptr %meteor.header, ptr %.129, i64 0, i32 0
  %.131 = load i32, ptr %.130, align 4
  %.132 = icmp eq i32 %.131, 1
  br i1 %.132, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %rc_release_continue
  %.145 = load ptr, ptr %json_data, align 8
  %.146 = icmp eq ptr %.145, null
  br i1 %.146, label %rc_release_continue.2, label %rc_release.2

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Response__(ptr %.124)
  %.135 = bitcast ptr %.124 to ptr
  %.136 = getelementptr i8, ptr %.135, i64 -16
  %.137 = bitcast ptr %.136 to ptr
  call void @meteor_release(ptr %.137)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.140 = bitcast ptr %.124 to ptr
  %.141 = getelementptr i8, ptr %.140, i64 -16
  %.142 = bitcast ptr %.141 to ptr
  call void @meteor_release(ptr %.142)
  br label %rc_release_continue.1

rc_release.2:                                     ; preds = %rc_release_continue.1
  %.148 = bitcast ptr %.145 to ptr
  call void @meteor_release(ptr %.148)
  br label %rc_release_continue.2

rc_release_continue.2:                            ; preds = %rc_release.2, %rc_release_continue.1
  br label %exit

exit.if:                                          ; preds = %exit
  %.155 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.155, align 1
  %.157 = getelementptr [32 x i8], ptr %.155, i64 0, i64 0
  %.158 = bitcast ptr %.157 to ptr
  %.159 = call i64 @puts(ptr %.158)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.152
}

define ptr @api_time_handler(ptr %req, ptr %res) {
entry:
  %json_data = alloca ptr, align 8
  %req.1 = alloca ptr, align 8
  store ptr %req, ptr %req.1, align 8
  %res.1 = alloca ptr, align 8
  store ptr %res, ptr %res.1, align 8
  %ret_var = alloca ptr, align 8
  store ptr null, ptr %ret_var, align 8
  %.7 = call ptr @malloc(i64 40)
  %.8 = bitcast ptr %.7 to ptr
  call void @i64.array.init(ptr %.8)
  call void @i64.array.append(ptr %.8, i64 123)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 112)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 50)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 50)
  call void @i64.array.append(ptr %.8, i64 54)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 45)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 84)
  call void @i64.array.append(ptr %.8, i64 49)
  call void @i64.array.append(ptr %.8, i64 50)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 48)
  call void @i64.array.append(ptr %.8, i64 90)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 44)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 97)
  call void @i64.array.append(ptr %.8, i64 103)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 58)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 67)
  call void @i64.array.append(ptr %.8, i64 117)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 110)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 115)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 118)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 114)
  call void @i64.array.append(ptr %.8, i64 32)
  call void @i64.array.append(ptr %.8, i64 116)
  call void @i64.array.append(ptr %.8, i64 105)
  call void @i64.array.append(ptr %.8, i64 109)
  call void @i64.array.append(ptr %.8, i64 101)
  call void @i64.array.append(ptr %.8, i64 34)
  call void @i64.array.append(ptr %.8, i64 125)
  store ptr %.8, ptr %json_data, align 8
  %.82 = load ptr, ptr %res.1, align 8
  %.83 = load ptr, ptr %json_data, align 8
  %.84 = icmp eq ptr %.83, null
  br i1 %.84, label %entry.if, label %entry.endif

exit:                                             ; preds = %rc_release_continue.2
  %.152 = load ptr, ptr %ret_var, align 8
  %.153 = icmp eq ptr %.152, null
  br i1 %.153, label %exit.if, label %exit.endif

entry.if:                                         ; preds = %entry
  %.86 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.86, align 1
  %.88 = getelementptr [32 x i8], ptr %.86, i64 0, i64 0
  %.89 = bitcast ptr %.88 to ptr
  %.90 = call i64 @puts(ptr %.89)
  call void @abort()
  unreachable

entry.endif:                                      ; preds = %entry
  %.93 = call ptr @Response.json(ptr %.82, ptr %.83)
  %.94 = load ptr, ptr %ret_var, align 8
  %.95 = bitcast ptr %.93 to ptr
  %.96 = getelementptr i8, ptr %.95, i64 -16
  %.97 = bitcast ptr %.96 to ptr
  call void @meteor_retain(ptr %.97)
  %.99 = icmp eq ptr %.94, null
  br i1 %.99, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %entry.endif
  %.101 = bitcast ptr %.94 to ptr
  %.102 = getelementptr i8, ptr %.101, i64 -16
  %.103 = bitcast ptr %.102 to ptr
  %.104 = getelementptr %meteor.header, ptr %.103, i64 0, i32 0
  %.105 = load i32, ptr %.104, align 4
  %.106 = icmp eq i32 %.105, 1
  br i1 %.106, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %entry.endif
  store ptr %.93, ptr %ret_var, align 8
  %.120 = bitcast ptr %.93 to ptr
  %.121 = getelementptr i8, ptr %.120, i64 -16
  %.122 = bitcast ptr %.121 to ptr
  call void @meteor_retain(ptr %.122)
  %.124 = load ptr, ptr %ret_var, align 8
  %.125 = icmp eq ptr %.124, null
  br i1 %.125, label %rc_release_continue.1, label %rc_release.1

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Response__(ptr %.94)
  %.109 = bitcast ptr %.94 to ptr
  %.110 = getelementptr i8, ptr %.109, i64 -16
  %.111 = bitcast ptr %.110 to ptr
  call void @meteor_release(ptr %.111)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.114 = bitcast ptr %.94 to ptr
  %.115 = getelementptr i8, ptr %.114, i64 -16
  %.116 = bitcast ptr %.115 to ptr
  call void @meteor_release(ptr %.116)
  br label %rc_release_continue

rc_release.1:                                     ; preds = %rc_release_continue
  %.127 = bitcast ptr %.124 to ptr
  %.128 = getelementptr i8, ptr %.127, i64 -16
  %.129 = bitcast ptr %.128 to ptr
  %.130 = getelementptr %meteor.header, ptr %.129, i64 0, i32 0
  %.131 = load i32, ptr %.130, align 4
  %.132 = icmp eq i32 %.131, 1
  br i1 %.132, label %rc_destroy.1, label %rc_release_only.1

rc_release_continue.1:                            ; preds = %rc_release_only.1, %rc_destroy.1, %rc_release_continue
  %.145 = load ptr, ptr %json_data, align 8
  %.146 = icmp eq ptr %.145, null
  br i1 %.146, label %rc_release_continue.2, label %rc_release.2

rc_destroy.1:                                     ; preds = %rc_release.1
  call void @__destroy_Response__(ptr %.124)
  %.135 = bitcast ptr %.124 to ptr
  %.136 = getelementptr i8, ptr %.135, i64 -16
  %.137 = bitcast ptr %.136 to ptr
  call void @meteor_release(ptr %.137)
  br label %rc_release_continue.1

rc_release_only.1:                                ; preds = %rc_release.1
  %.140 = bitcast ptr %.124 to ptr
  %.141 = getelementptr i8, ptr %.140, i64 -16
  %.142 = bitcast ptr %.141 to ptr
  call void @meteor_release(ptr %.142)
  br label %rc_release_continue.1

rc_release.2:                                     ; preds = %rc_release_continue.1
  %.148 = bitcast ptr %.145 to ptr
  call void @meteor_release(ptr %.148)
  br label %rc_release_continue.2

rc_release_continue.2:                            ; preds = %rc_release.2, %rc_release_continue.1
  br label %exit

exit.if:                                          ; preds = %exit
  %.155 = alloca [32 x i8], align 1
  store [32 x i8] c"Error: Use-After-Move detected!\00", ptr %.155, align 1
  %.157 = getelementptr [32 x i8], ptr %.155, i64 0, i64 0
  %.158 = bitcast ptr %.157 to ptr
  %.159 = call i64 @puts(ptr %.158)
  call void @abort()
  unreachable

exit.endif:                                       ; preds = %exit
  ret ptr %.152
}

define void @mymain() {
entry:
  %server = alloca ptr, align 8
  %.2 = call ptr @malloc(i64 40)
  %.3 = bitcast ptr %.2 to ptr
  call void @i64.array.init(ptr %.3)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @i64.array.append(ptr %.3, i64 61)
  call void @print(ptr %.3)
  %.46 = call ptr @malloc(i64 40)
  %.47 = bitcast ptr %.46 to ptr
  call void @i64.array.init(ptr %.47)
  call void @i64.array.append(ptr %.47, i64 32)
  call void @i64.array.append(ptr %.47, i64 32)
  call void @i64.array.append(ptr %.47, i64 32)
  call void @i64.array.append(ptr %.47, i64 77)
  call void @i64.array.append(ptr %.47, i64 101)
  call void @i64.array.append(ptr %.47, i64 116)
  call void @i64.array.append(ptr %.47, i64 101)
  call void @i64.array.append(ptr %.47, i64 111)
  call void @i64.array.append(ptr %.47, i64 114)
  call void @i64.array.append(ptr %.47, i64 32)
  call void @i64.array.append(ptr %.47, i64 72)
  call void @i64.array.append(ptr %.47, i64 84)
  call void @i64.array.append(ptr %.47, i64 84)
  call void @i64.array.append(ptr %.47, i64 80)
  call void @i64.array.append(ptr %.47, i64 32)
  call void @i64.array.append(ptr %.47, i64 83)
  call void @i64.array.append(ptr %.47, i64 101)
  call void @i64.array.append(ptr %.47, i64 114)
  call void @i64.array.append(ptr %.47, i64 118)
  call void @i64.array.append(ptr %.47, i64 101)
  call void @i64.array.append(ptr %.47, i64 114)
  call void @i64.array.append(ptr %.47, i64 32)
  call void @i64.array.append(ptr %.47, i64 68)
  call void @i64.array.append(ptr %.47, i64 101)
  call void @i64.array.append(ptr %.47, i64 109)
  call void @i64.array.append(ptr %.47, i64 111)
  call void @print(ptr %.47)
  %.76 = call ptr @malloc(i64 40)
  %.77 = bitcast ptr %.76 to ptr
  call void @i64.array.init(ptr %.77)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @i64.array.append(ptr %.77, i64 61)
  call void @print(ptr %.77)
  %.120 = call ptr @create_server()
  store ptr %.120, ptr %server, align 8
  %.122 = load ptr, ptr %server, align 8
  %.123 = call ptr @malloc(i64 40)
  %.124 = bitcast ptr %.123 to ptr
  call void @i64.array.init(ptr %.124)
  call void @i64.array.append(ptr %.124, i64 49)
  call void @i64.array.append(ptr %.124, i64 50)
  call void @i64.array.append(ptr %.124, i64 55)
  call void @i64.array.append(ptr %.124, i64 46)
  call void @i64.array.append(ptr %.124, i64 48)
  call void @i64.array.append(ptr %.124, i64 46)
  call void @i64.array.append(ptr %.124, i64 48)
  call void @i64.array.append(ptr %.124, i64 46)
  call void @i64.array.append(ptr %.124, i64 49)
  %.135 = call ptr @Server.bind(ptr %.122, ptr %.124, i64 8080)
  %.136 = load ptr, ptr %server, align 8
  %.137 = call ptr @malloc(i64 40)
  %.138 = bitcast ptr %.137 to ptr
  call void @i64.array.init(ptr %.138)
  call void @i64.array.append(ptr %.138, i64 47)
  %.141 = call ptr @Server.get(ptr %.136, ptr %.138, ptr @home_handler)
  %.142 = load ptr, ptr %server, align 8
  %.143 = call ptr @malloc(i64 40)
  %.144 = bitcast ptr %.143 to ptr
  call void @i64.array.init(ptr %.144)
  call void @i64.array.append(ptr %.144, i64 47)
  call void @i64.array.append(ptr %.144, i64 104)
  call void @i64.array.append(ptr %.144, i64 101)
  call void @i64.array.append(ptr %.144, i64 108)
  call void @i64.array.append(ptr %.144, i64 108)
  call void @i64.array.append(ptr %.144, i64 111)
  %.152 = call ptr @Server.get(ptr %.142, ptr %.144, ptr @hello_handler)
  %.153 = load ptr, ptr %server, align 8
  %.154 = call ptr @malloc(i64 40)
  %.155 = bitcast ptr %.154 to ptr
  call void @i64.array.init(ptr %.155)
  call void @i64.array.append(ptr %.155, i64 47)
  call void @i64.array.append(ptr %.155, i64 97)
  call void @i64.array.append(ptr %.155, i64 112)
  call void @i64.array.append(ptr %.155, i64 105)
  call void @i64.array.append(ptr %.155, i64 47)
  call void @i64.array.append(ptr %.155, i64 105)
  call void @i64.array.append(ptr %.155, i64 110)
  call void @i64.array.append(ptr %.155, i64 102)
  call void @i64.array.append(ptr %.155, i64 111)
  %.166 = call ptr @Server.get(ptr %.153, ptr %.155, ptr @api_info_handler)
  %.167 = load ptr, ptr %server, align 8
  %.168 = call ptr @malloc(i64 40)
  %.169 = bitcast ptr %.168 to ptr
  call void @i64.array.init(ptr %.169)
  call void @i64.array.append(ptr %.169, i64 47)
  call void @i64.array.append(ptr %.169, i64 97)
  call void @i64.array.append(ptr %.169, i64 112)
  call void @i64.array.append(ptr %.169, i64 105)
  call void @i64.array.append(ptr %.169, i64 47)
  call void @i64.array.append(ptr %.169, i64 116)
  call void @i64.array.append(ptr %.169, i64 105)
  call void @i64.array.append(ptr %.169, i64 109)
  call void @i64.array.append(ptr %.169, i64 101)
  %.180 = call ptr @Server.get(ptr %.167, ptr %.169, ptr @api_time_handler)
  %.181 = call ptr @malloc(i64 40)
  %.182 = bitcast ptr %.181 to ptr
  call void @i64.array.init(ptr %.182)
  call void @print(ptr %.182)
  %.185 = call ptr @malloc(i64 40)
  %.186 = bitcast ptr %.185 to ptr
  call void @i64.array.init(ptr %.186)
  call void @i64.array.append(ptr %.186, i64 82)
  call void @i64.array.append(ptr %.186, i64 111)
  call void @i64.array.append(ptr %.186, i64 117)
  call void @i64.array.append(ptr %.186, i64 116)
  call void @i64.array.append(ptr %.186, i64 101)
  call void @i64.array.append(ptr %.186, i64 115)
  call void @i64.array.append(ptr %.186, i64 32)
  call void @i64.array.append(ptr %.186, i64 114)
  call void @i64.array.append(ptr %.186, i64 101)
  call void @i64.array.append(ptr %.186, i64 103)
  call void @i64.array.append(ptr %.186, i64 105)
  call void @i64.array.append(ptr %.186, i64 115)
  call void @i64.array.append(ptr %.186, i64 116)
  call void @i64.array.append(ptr %.186, i64 101)
  call void @i64.array.append(ptr %.186, i64 114)
  call void @i64.array.append(ptr %.186, i64 101)
  call void @i64.array.append(ptr %.186, i64 100)
  call void @i64.array.append(ptr %.186, i64 58)
  call void @print(ptr %.186)
  %.207 = call ptr @malloc(i64 40)
  %.208 = bitcast ptr %.207 to ptr
  call void @i64.array.init(ptr %.208)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 71)
  call void @i64.array.append(ptr %.208, i64 69)
  call void @i64.array.append(ptr %.208, i64 84)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 47)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 45)
  call void @i64.array.append(ptr %.208, i64 62)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 72)
  call void @i64.array.append(ptr %.208, i64 111)
  call void @i64.array.append(ptr %.208, i64 109)
  call void @i64.array.append(ptr %.208, i64 101)
  call void @i64.array.append(ptr %.208, i64 32)
  call void @i64.array.append(ptr %.208, i64 112)
  call void @i64.array.append(ptr %.208, i64 97)
  call void @i64.array.append(ptr %.208, i64 103)
  call void @i64.array.append(ptr %.208, i64 101)
  call void @print(ptr %.208)
  %.239 = call ptr @malloc(i64 40)
  %.240 = bitcast ptr %.239 to ptr
  call void @i64.array.init(ptr %.240)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 71)
  call void @i64.array.append(ptr %.240, i64 69)
  call void @i64.array.append(ptr %.240, i64 84)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 47)
  call void @i64.array.append(ptr %.240, i64 104)
  call void @i64.array.append(ptr %.240, i64 101)
  call void @i64.array.append(ptr %.240, i64 108)
  call void @i64.array.append(ptr %.240, i64 108)
  call void @i64.array.append(ptr %.240, i64 111)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 45)
  call void @i64.array.append(ptr %.240, i64 62)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 84)
  call void @i64.array.append(ptr %.240, i64 101)
  call void @i64.array.append(ptr %.240, i64 120)
  call void @i64.array.append(ptr %.240, i64 116)
  call void @i64.array.append(ptr %.240, i64 32)
  call void @i64.array.append(ptr %.240, i64 103)
  call void @i64.array.append(ptr %.240, i64 114)
  call void @i64.array.append(ptr %.240, i64 101)
  call void @i64.array.append(ptr %.240, i64 101)
  call void @i64.array.append(ptr %.240, i64 116)
  call void @i64.array.append(ptr %.240, i64 105)
  call void @i64.array.append(ptr %.240, i64 110)
  call void @i64.array.append(ptr %.240, i64 103)
  call void @print(ptr %.240)
  %.275 = call ptr @malloc(i64 40)
  %.276 = bitcast ptr %.275 to ptr
  call void @i64.array.init(ptr %.276)
  call void @i64.array.append(ptr %.276, i64 32)
  call void @i64.array.append(ptr %.276, i64 32)
  call void @i64.array.append(ptr %.276, i64 71)
  call void @i64.array.append(ptr %.276, i64 69)
  call void @i64.array.append(ptr %.276, i64 84)
  call void @i64.array.append(ptr %.276, i64 32)
  call void @i64.array.append(ptr %.276, i64 47)
  call void @i64.array.append(ptr %.276, i64 97)
  call void @i64.array.append(ptr %.276, i64 112)
  call void @i64.array.append(ptr %.276, i64 105)
  call void @i64.array.append(ptr %.276, i64 47)
  call void @i64.array.append(ptr %.276, i64 105)
  call void @i64.array.append(ptr %.276, i64 110)
  call void @i64.array.append(ptr %.276, i64 102)
  call void @i64.array.append(ptr %.276, i64 111)
  call void @i64.array.append(ptr %.276, i64 32)
  call void @i64.array.append(ptr %.276, i64 45)
  call void @i64.array.append(ptr %.276, i64 62)
  call void @i64.array.append(ptr %.276, i64 32)
  call void @i64.array.append(ptr %.276, i64 83)
  call void @i64.array.append(ptr %.276, i64 101)
  call void @i64.array.append(ptr %.276, i64 114)
  call void @i64.array.append(ptr %.276, i64 118)
  call void @i64.array.append(ptr %.276, i64 101)
  call void @i64.array.append(ptr %.276, i64 114)
  call void @i64.array.append(ptr %.276, i64 32)
  call void @i64.array.append(ptr %.276, i64 105)
  call void @i64.array.append(ptr %.276, i64 110)
  call void @i64.array.append(ptr %.276, i64 102)
  call void @i64.array.append(ptr %.276, i64 111)
  call void @i64.array.append(ptr %.276, i64 32)
  call void @i64.array.append(ptr %.276, i64 74)
  call void @i64.array.append(ptr %.276, i64 83)
  call void @i64.array.append(ptr %.276, i64 79)
  call void @i64.array.append(ptr %.276, i64 78)
  call void @print(ptr %.276)
  %.314 = call ptr @malloc(i64 40)
  %.315 = bitcast ptr %.314 to ptr
  call void @i64.array.init(ptr %.315)
  call void @i64.array.append(ptr %.315, i64 32)
  call void @i64.array.append(ptr %.315, i64 32)
  call void @i64.array.append(ptr %.315, i64 71)
  call void @i64.array.append(ptr %.315, i64 69)
  call void @i64.array.append(ptr %.315, i64 84)
  call void @i64.array.append(ptr %.315, i64 32)
  call void @i64.array.append(ptr %.315, i64 47)
  call void @i64.array.append(ptr %.315, i64 97)
  call void @i64.array.append(ptr %.315, i64 112)
  call void @i64.array.append(ptr %.315, i64 105)
  call void @i64.array.append(ptr %.315, i64 47)
  call void @i64.array.append(ptr %.315, i64 116)
  call void @i64.array.append(ptr %.315, i64 105)
  call void @i64.array.append(ptr %.315, i64 109)
  call void @i64.array.append(ptr %.315, i64 101)
  call void @i64.array.append(ptr %.315, i64 32)
  call void @i64.array.append(ptr %.315, i64 45)
  call void @i64.array.append(ptr %.315, i64 62)
  call void @i64.array.append(ptr %.315, i64 32)
  call void @i64.array.append(ptr %.315, i64 84)
  call void @i64.array.append(ptr %.315, i64 105)
  call void @i64.array.append(ptr %.315, i64 109)
  call void @i64.array.append(ptr %.315, i64 101)
  call void @i64.array.append(ptr %.315, i64 32)
  call void @i64.array.append(ptr %.315, i64 74)
  call void @i64.array.append(ptr %.315, i64 83)
  call void @i64.array.append(ptr %.315, i64 79)
  call void @i64.array.append(ptr %.315, i64 78)
  call void @print(ptr %.315)
  %.346 = call ptr @malloc(i64 40)
  %.347 = bitcast ptr %.346 to ptr
  call void @i64.array.init(ptr %.347)
  call void @print(ptr %.347)
  %.350 = load ptr, ptr %server, align 8
  %.351 = call i64 @Server.listen(ptr %.350)
  br label %exit

exit:                                             ; preds = %entry
  %.353 = load ptr, ptr %server, align 8
  %.354 = icmp eq ptr %.353, null
  br i1 %.354, label %rc_release_continue, label %rc_release

rc_release:                                       ; preds = %exit
  %.356 = bitcast ptr %.353 to ptr
  %.357 = getelementptr i8, ptr %.356, i64 -16
  %.358 = bitcast ptr %.357 to ptr
  %.359 = getelementptr %meteor.header, ptr %.358, i64 0, i32 0
  %.360 = load i32, ptr %.359, align 4
  %.361 = icmp eq i32 %.360, 1
  br i1 %.361, label %rc_destroy, label %rc_release_only

rc_release_continue:                              ; preds = %rc_release_only, %rc_destroy, %exit
  ret void

rc_destroy:                                       ; preds = %rc_release
  call void @__destroy_Server__(ptr %.353)
  %.364 = bitcast ptr %.353 to ptr
  %.365 = getelementptr i8, ptr %.364, i64 -16
  %.366 = bitcast ptr %.365 to ptr
  call void @meteor_release(ptr %.366)
  br label %rc_release_continue

rc_release_only:                                  ; preds = %rc_release
  %.369 = bitcast ptr %.353 to ptr
  %.370 = getelementptr i8, ptr %.369, i64 -16
  %.371 = bitcast ptr %.370 to ptr
  call void @meteor_release(ptr %.371)
  br label %rc_release_continue
}

!0 = !{}
