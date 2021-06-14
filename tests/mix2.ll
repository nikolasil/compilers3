@.And_test_vtable = global [0 x i8*] []
@.test_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*)* @test.foo to i8*)
]

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
	%b = alloca i8*
	%_0 = call i8* @calloc(i32 1, i32 16)
	%_1 = bitcast i8* %_0 to i8***
	%_2 = getelementptr [1 x i8*], [1 x i8*]* @.test_vtable, i32 0, i32 0
	store i8** %_2, i8*** %_1
	store i8* %_0, i8** %b

	%_3 = load i8*, i8** %b
	%_4 = bitcast i8* %_3 to i8***
	%_5 = load i8**, i8*** %_4
	%_6 = getelementptr i8*, i8** %_5, i32 0
	%_7 = load i8*, i8** %_6
	%_8 = bitcast i8* %_7 to i32 (i8*)*
	%_9 = call i32 %_8(i8* %_3)

	call void (i32) @print_int(i32 %_9)
	ret i32 0
}

define i32 @test.foo(i8* %this) {

	%_0 = getelementptr i8, i8* %this, i32 8
	%_1 = bitcast i8* %_0 to i32*
	store i32 3, i32* %_1
	%_2 = getelementptr i8, i8* %this, i32 8
	%_3 = bitcast i8* %_2 to i32*
	%_4 = load i32, i32* %_3
	%_5 = mul i32 3, %_4
	call void (i32) @print_int(i32 %_5)
	ret i32 0
}
