@.Arrays_vtable = global [0 x i8*] []

declare i8* @calloc(i32, i32)
declare i32 @printf(i8*, ...)
declare void @exit(i32)

@_cint = constant [4 x i8] c"%d\0a\00"
@_cOOB = constant [15 x i8] c"Out of bounds\0a\00"
@_cNSZ = constant [15 x i8] c"Negative size\0a\00"
define void @print_int(i32 %i) {
    %_str = bitcast [4 x i8]* @_cint to i8*
    call i32 (i8*, ...) @printf(i8* %_str, i32 %i)
    ret void
}

define void @throw_oob() {
    %_str = bitcast [15 x i8]* @_cOOB to i8*
    call i32 (i8*, ...) @printf(i8* %_str)
    call void @exit(i32 1)
    ret void
}

define void @throw_nsz() {
    %_str = bitcast [15 x i8]* @_cNSZ to i8*
    call i32 (i8*, ...) @printf(i8* %_str)
    call void @exit(i32 1)
    ret void
}

define i32 @main() {
	%x = alloca i32*
	%_0 = add i32 1, 2
	%_1 = icmp sge i32 %_0, 1
	br i1 %_1, label %nsz_ok_0, label %nsz_err_0

	nsz_err_0:
	call void @throw_nsz()
	br label %nsz_ok_0

	nsz_ok_0:
	%_2 = call i8* @calloc(i32 %_0, i32 4)
	%_3 = bitcast i8* %_2 to i32*
	store i32 2, i32* %_3
	store i32* %_3, i32** %x

	%_4 = load i32*, i32** %x
	%_5 = load i32, i32* %_4
	%_6 = icmp sge i32 0, 0
	%_7 = icmp slt i32 0, %_5
	%_8 = and i1 %_6, %_7
	br i1 %_8, label %oob_ok_0, label %oob_err_0

	oob_err_0:
	call void @throw_oob()
	br label %oob_ok_0

	oob_ok_0:
	%_9 = add i32 1, 0
	%_10 = getelementptr i32 , i32* %_4, i32 %_9
	store i32 1, i32* %_10


	%_11 = load i32*, i32** %x
	%_12 = load i32, i32* %_11
	%_13 = icmp sge i32 1, 0
	%_14 = icmp slt i32 1, %_12
	%_15 = and i1 %_13, %_14
	br i1 %_15, label %oob_ok_1, label %oob_err_1

	oob_err_1:
	call void @throw_oob()
	br label %oob_ok_1

	oob_ok_1:
	%_16 = add i32 1, 1
	%_17 = getelementptr i32 , i32* %_11, i32 %_16
	store i32 2, i32* %_17


	%_18 = load i32*, i32** %x
	%_19 = load i32, i32* %_18
	%_20 = icmp sge i32 0, 0
	%_21 = icmp slt i32 0, %_19
	%_22 = and i1 %_20, %_21
	br i1 %_22, label %oob_ok_2, label %oob_err_2

	oob_err_2:
	call void @throw_oob()
	br label %oob_ok_2

	oob_ok_2:
	%_23 = add i32 1, 0
	%_24 = getelementptr i32 , i32* %_18, i32 %_23
	%_25 = load i32 , i32* %_24

	%_26 = load i32*, i32** %x
	%_27 = load i32, i32* %_26
	%_28 = icmp sge i32 1, 0
	%_29 = icmp slt i32 1, %_27
	%_30 = and i1 %_28, %_29
	br i1 %_30, label %oob_ok_3, label %oob_err_3

	oob_err_3:
	call void @throw_oob()
	br label %oob_ok_3

	oob_ok_3:
	%_31 = add i32 1, 1
	%_32 = getelementptr i32 , i32* %_26, i32 %_31
	%_33 = load i32 , i32* %_32
	%_34 = add i32 %_25, %_33
	call void (i32) @print_int(i32 %_34)
	ret i32 0
}
