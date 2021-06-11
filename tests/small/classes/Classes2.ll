@.Classes_vtable = global [0 x i8*] []
@.Base_vtable = global [2 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @Base.set to i8*),
	i8* bitcast (i32 (i8*)* @Base.get to i8*)
]
@.Derived_vtable = global [2 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @Derived.set to i8*),
	i8* bitcast (i32 (i8*)* @Base.get to i8*)
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

define void @throw_nsz() {
    %_str = bitcast [15 x i8]* @_cNSZ to i8*
    call i32 (i8*, ...) @printf(i8* %_str)
    call void @exit(i32 1)
    ret void
}

define i32 @main() {
	%b = alloca i8
	%d = alloca i8
	store i8 return , i8* %b
	store i8 return , i8* %d
	%_0 = load i8, i8* %d
	store i8 %_0, i8* %b
	ret i32 0
}
	%data = alloca i32
	%c = alloca i1
define i32 @Base.set(i8* %this, i32 %.x) {
	%c = alloca i1
	%_0 = load i1, i1* %c
	%_1 = load i1, i1* %c
	%_2 = getelementptr i8, i8* %this, i32 8
	%_3 = bitcast i8* %_2 to i32*
	store i32 1, i32* %_3
	%_4 = getelementptr i8, i8* %this, i32 8
	%_5 = bitcast i8* %_4 to i32*
	store i32 2, i32* %_5
}
define i32 @Base.get(i8* %this) {
}
define i32 @Derived.set(i8* %this, i32 %.x) {
	%_0 = getelementptr i8, i8* %this, i32 8
	%_1 = bitcast i8* %_0 to i32*
	store i32 int, i32* %_1
}
