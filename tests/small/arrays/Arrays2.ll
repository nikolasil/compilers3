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

define void @throw_nsz() {
    %_str = bitcast [15 x i8]* @_cNSZ to i8*
    call i32 (i8*, ...) @printf(i8* %_str)
    call void @exit(i32 1)
    ret void
}

define i32 @main() {
	%x = alloca i32*

	%_0 = load i32*, i32** %x
	%_1 = load i32, i32* %_0
	%_2 = icmp sge i32 0, 0
	%_3 = icmp slt i32 0, %_1
	%_4 = and i1 %_2, %_3
	br i1 %_4, label %oob_ok_0, label %oob_err_0

	oob_err_0:
	call void @throw_oob()
	br label %oob_ok_0

	oob_ok_0:
	%_5 = add i32 1, 0
	%_6 = getelementptr i32 , i32* %_0, i32 %_5
	store i32 1, i32* %_6


	%_7 = load i32*, i32** %x
	%_8 = load i32, i32* %_7
	%_9 = icmp sge i32 1, 0
	%_10 = icmp slt i32 1, %_8
	%_11 = and i1 %_9, %_10
	br i1 %_11, label %oob_ok_1, label %oob_err_1

	oob_err_1:
	call void @throw_oob()
	br label %oob_ok_1

	oob_ok_1:
	%_12 = add i32 1, 1
	%_13 = getelementptr i32 , i32* %_7, i32 %_12
	store i32 2, i32* %_13

	ret i32 0
}
