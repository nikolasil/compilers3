@.BubbleSort_vtable = global [0 x i8*] []
@.BBS_vtable = global [4 x i8*] [
	i8* bitcast (i32 (i8*,i32)* @BBS.Start to i8*),
	i8* bitcast (i32 (i8*)* @BBS.Sort to i8*),
	i8* bitcast (i32 (i8*)* @BBS.Print to i8*),
	i8* bitcast (i32 (i8*,i32)* @BBS.Init to i8*)
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

	%_0 = call i8* @calloc(i32 1, i32 20)
	%_1 = bitcast i8* %_0 to i8***
	%_2 = getelementptr [4 x i8*], [4 x i8*]* @.BBS_vtable, i32 0, i32 0
	store i8** %_2, i8*** %_1

	%_3 = bitcast i8* %_0 to i8***
	%_4 = load i8**, i8*** %_3
	%_5 = getelementptr i8*, i8** %_4, i32 0
	%_6 = load i8*, i8** %_5
	%_7 = bitcast i8* %_6 to i32 (i8*,i32)*
	%_8 = call i32 %_7(i8* %_0, i32 10)

	call void (i32) @print_int(i32 %_8)
	ret i32 0
}

define i32 @BBS.Start(i8* %this, i32 %.sz) {
	%sz = alloca i32
	store i32 %.sz, i32* %sz

	%aux01 = alloca i32

	%_0 = bitcast i8* %this to i8***
	%_1 = load i8**, i8*** %_0
	%_2 = getelementptr i8*, i8** %_1, i32 3
	%_3 = load i8*, i8** %_2
	%_4 = bitcast i8* %_3 to i32 (i8*,i32)*
	%_5 = load i32, i32* %sz
	%_6 = call i32 %_4(i8* %this, i32 %_5)

	store i32 %_6, i32* %aux01

	%_7 = bitcast i8* %this to i8***
	%_8 = load i8**, i8*** %_7
	%_9 = getelementptr i8*, i8** %_8, i32 2
	%_10 = load i8*, i8** %_9
	%_11 = bitcast i8* %_10 to i32 (i8*)*
	%_12 = call i32 %_11(i8* %this)

	store i32 %_12, i32* %aux01
	call void (i32) @print_int(i32 99999)

	%_13 = bitcast i8* %this to i8***
	%_14 = load i8**, i8*** %_13
	%_15 = getelementptr i8*, i8** %_14, i32 1
	%_16 = load i8*, i8** %_15
	%_17 = bitcast i8* %_16 to i32 (i8*)*
	%_18 = call i32 %_17(i8* %this)

	store i32 %_18, i32* %aux01

	%_19 = bitcast i8* %this to i8***
	%_20 = load i8**, i8*** %_19
	%_21 = getelementptr i8*, i8** %_20, i32 2
	%_22 = load i8*, i8** %_21
	%_23 = bitcast i8* %_22 to i32 (i8*)*
	%_24 = call i32 %_23(i8* %this)

	store i32 %_24, i32* %aux01
	ret i32 0
}

define i32 @BBS.Sort(i8* %this) {

	%nt = alloca i32
	%i = alloca i32
	%aux02 = alloca i32
	%aux04 = alloca i32
	%aux05 = alloca i32
	%aux06 = alloca i32
	%aux07 = alloca i32
	%j = alloca i32
	%t = alloca i32
	%_0 = getelementptr i8, i8* %this, i32 16
	%_1 = bitcast i8* %_0 to i32*
	%_2 = load i32, i32* %_1
	%_3 = sub i32 %_2, 1
	store i32 %_3, i32* %i
	%_4 = sub i32 0, 1
	store i32 %_4, i32* %aux02
	br label %loop01
	loop01:
	%_5 = load i32, i32* %aux02
	%_6 = load i32, i32* %i
	%_7 = icmp slt i32 %_5, %_6
	br i1 %_7, label %loop02, label %loop03
	loop02:
	store i32 1, i32* %j
	br label %loop11
	loop11:
	%_8 = load i32, i32* %i
	%_9 = add i32 %_8, 1
	%_10 = load i32, i32* %j
	%_11 = icmp slt i32 %_10, %_9
	br i1 %_11, label %loop12, label %loop13
	loop12:
	%_12 = load i32, i32* %j
	%_13 = sub i32 %_12, 1
	store i32 %_13, i32* %aux07

	%_14 = getelementptr i8, i8* %this , i32 8
	%_15 = bitcast i8* %_14 to i32**
	%_16 = load i32*, i32** %_15
	%_17 = load i32, i32* %aux07
	%_18 = load i32, i32* %_16
	%_19 = icmp ult i32 %_17, %_18
	br i1 %_19, label %oob_ok_0, label %oob_err_0

	oob_err_0:
	call void @throw_oob()
	br label %oob_ok_0

	oob_ok_0:
	%_20 = add i32 1, %_17
	%_21 = getelementptr i32 , i32* %_16, i32 %_20
	%_22 = load i32 , i32* %_21
	store i32 %_22, i32* %aux04

	%_23 = getelementptr i8, i8* %this , i32 8
	%_24 = bitcast i8* %_23 to i32**
	%_25 = load i32*, i32** %_24
	%_26 = load i32, i32* %j
	%_27 = load i32, i32* %_25
	%_28 = icmp ult i32 %_26, %_27
	br i1 %_28, label %oob_ok_1, label %oob_err_1

	oob_err_1:
	call void @throw_oob()
	br label %oob_ok_1

	oob_ok_1:
	%_29 = add i32 1, %_26
	%_30 = getelementptr i32 , i32* %_25, i32 %_29
	%_31 = load i32 , i32* %_30
	store i32 %_31, i32* %aux05
	%_32 = load i32, i32* %aux05
	%_33 = load i32, i32* %aux04
	%_34 = icmp slt i32 %_32, %_33
	br i1 %_34, label %if_then_0, label %if_else_0
	if_else_0:
	store i32 0, i32* %nt

	br label %if_end_0
	if_then_0:
	%_35 = load i32, i32* %j
	%_36 = sub i32 %_35, 1
	store i32 %_36, i32* %aux06

	%_37 = getelementptr i8, i8* %this , i32 8
	%_38 = bitcast i8* %_37 to i32**
	%_39 = load i32*, i32** %_38
	%_40 = load i32, i32* %aux06
	%_41 = load i32, i32* %_39
	%_42 = icmp ult i32 %_40, %_41
	br i1 %_42, label %oob_ok_2, label %oob_err_2

	oob_err_2:
	call void @throw_oob()
	br label %oob_ok_2

	oob_ok_2:
	%_43 = add i32 1, %_40
	%_44 = getelementptr i32 , i32* %_39, i32 %_43
	%_45 = load i32 , i32* %_44
	store i32 %_45, i32* %t

	%_46 = getelementptr i8, i8* %this , i32 8
	%_47 = bitcast i8* %_46 to i32**
	%_48 = load i32*, i32** %_47
	%_49 = load i32, i32* %aux06
	%_50 = load i32, i32* %_48
	%_51 = icmp ult i32 %_49, %_50
	br i1 %_51, label %oob_ok_3, label %oob_err_3

	oob_err_3:
	call void @throw_oob()
	br label %oob_ok_3

	oob_ok_3:
	%_52 = add i32 1, %_49
	%_53 = getelementptr i32 , i32* %_48, i32 %_52

	%_54 = getelementptr i8, i8* %this , i32 8
	%_55 = bitcast i8* %_54 to i32**
	%_56 = load i32*, i32** %_55
	%_57 = load i32, i32* %j
	%_58 = load i32, i32* %_56
	%_59 = icmp ult i32 %_57, %_58
	br i1 %_59, label %oob_ok_4, label %oob_err_4

	oob_err_4:
	call void @throw_oob()
	br label %oob_ok_4

	oob_ok_4:
	%_60 = add i32 1, %_57
	%_61 = getelementptr i32 , i32* %_56, i32 %_60
	%_62 = load i32 , i32* %_61
	store i32 %_62, i32* %_53


	%_63 = getelementptr i8, i8* %this , i32 8
	%_64 = bitcast i8* %_63 to i32**
	%_65 = load i32*, i32** %_64
	%_66 = load i32, i32* %j
	%_67 = load i32, i32* %_65
	%_68 = icmp ult i32 %_66, %_67
	br i1 %_68, label %oob_ok_5, label %oob_err_5

	oob_err_5:
	call void @throw_oob()
	br label %oob_ok_5

	oob_ok_5:
	%_69 = add i32 1, %_66
	%_70 = getelementptr i32 , i32* %_65, i32 %_69
	%_71 = load i32, i32* %t
	store i32 %_71, i32* %_70


	br label %if_end_0
	if_end_0:
	%_72 = load i32, i32* %j
	%_73 = add i32 %_72, 1
	store i32 %_73, i32* %j
	br label %loop11
	loop13:
	%_74 = load i32, i32* %i
	%_75 = sub i32 %_74, 1
	store i32 %_75, i32* %i
	br label %loop01
	loop03:
	ret i32 0
}

define i32 @BBS.Print(i8* %this) {

	%j = alloca i32
	store i32 0, i32* %j
	br label %loop21
	loop21:
	%_0 = load i32, i32* %j
	%_1 = getelementptr i8, i8* %this, i32 16
	%_2 = bitcast i8* %_1 to i32*
	%_3 = load i32, i32* %_2
	%_4 = icmp slt i32 %_0, %_3
	br i1 %_4, label %loop22, label %loop23
	loop22:

	%_5 = getelementptr i8, i8* %this , i32 8
	%_6 = bitcast i8* %_5 to i32**
	%_7 = load i32*, i32** %_6
	%_8 = load i32, i32* %j
	%_9 = load i32, i32* %_7
	%_10 = icmp ult i32 %_8, %_9
	br i1 %_10, label %oob_ok_6, label %oob_err_6

	oob_err_6:
	call void @throw_oob()
	br label %oob_ok_6

	oob_ok_6:
	%_11 = add i32 1, %_8
	%_12 = getelementptr i32 , i32* %_7, i32 %_11
	%_13 = load i32 , i32* %_12
	call void (i32) @print_int(i32 %_13)
	%_14 = load i32, i32* %j
	%_15 = add i32 %_14, 1
	store i32 %_15, i32* %j
	br label %loop21
	loop23:
	ret i32 0
}

define i32 @BBS.Init(i8* %this, i32 %.sz) {
	%sz = alloca i32
	store i32 %.sz, i32* %sz

	%_0 = load i32, i32* %sz
	%_1 = getelementptr i8, i8* %this, i32 16
	%_2 = bitcast i8* %_1 to i32*
	store i32 %_0, i32* %_2
	%_3 = load i32, i32* %sz
	%_4 = icmp slt i32 %_3, 0
	br i1 %_4, label %nsz_err_0, label %nsz_ok_0

	nsz_err_0:
	call void @throw_nsz()
	br label %nsz_ok_0

	nsz_ok_0:
	%_5 = add i32 %_3, 1
	%_6 = call i8* @calloc(i32 %_5, i32 4)
	%_7 = bitcast i8* %_6 to i32*
	store i32 %_3, i32* %_7
	%_8 = getelementptr i8, i8* %this, i32 8
	%_9 = bitcast i8* %_8 to i32**
	store i32* %_7, i32** %_9

	%_10 = getelementptr i8, i8* %this , i32 8
	%_11 = bitcast i8* %_10 to i32**
	%_12 = load i32*, i32** %_11
	%_13 = load i32, i32* %_12
	%_14 = icmp ult i32 0, %_13
	br i1 %_14, label %oob_ok_7, label %oob_err_7

	oob_err_7:
	call void @throw_oob()
	br label %oob_ok_7

	oob_ok_7:
	%_15 = add i32 1, 0
	%_16 = getelementptr i32 , i32* %_12, i32 %_15
	store i32 20, i32* %_16


	%_17 = getelementptr i8, i8* %this , i32 8
	%_18 = bitcast i8* %_17 to i32**
	%_19 = load i32*, i32** %_18
	%_20 = load i32, i32* %_19
	%_21 = icmp ult i32 1, %_20
	br i1 %_21, label %oob_ok_8, label %oob_err_8

	oob_err_8:
	call void @throw_oob()
	br label %oob_ok_8

	oob_ok_8:
	%_22 = add i32 1, 1
	%_23 = getelementptr i32 , i32* %_19, i32 %_22
	store i32 7, i32* %_23


	%_24 = getelementptr i8, i8* %this , i32 8
	%_25 = bitcast i8* %_24 to i32**
	%_26 = load i32*, i32** %_25
	%_27 = load i32, i32* %_26
	%_28 = icmp ult i32 2, %_27
	br i1 %_28, label %oob_ok_9, label %oob_err_9

	oob_err_9:
	call void @throw_oob()
	br label %oob_ok_9

	oob_ok_9:
	%_29 = add i32 1, 2
	%_30 = getelementptr i32 , i32* %_26, i32 %_29
	store i32 12, i32* %_30


	%_31 = getelementptr i8, i8* %this , i32 8
	%_32 = bitcast i8* %_31 to i32**
	%_33 = load i32*, i32** %_32
	%_34 = load i32, i32* %_33
	%_35 = icmp ult i32 3, %_34
	br i1 %_35, label %oob_ok_10, label %oob_err_10

	oob_err_10:
	call void @throw_oob()
	br label %oob_ok_10

	oob_ok_10:
	%_36 = add i32 1, 3
	%_37 = getelementptr i32 , i32* %_33, i32 %_36
	store i32 18, i32* %_37


	%_38 = getelementptr i8, i8* %this , i32 8
	%_39 = bitcast i8* %_38 to i32**
	%_40 = load i32*, i32** %_39
	%_41 = load i32, i32* %_40
	%_42 = icmp ult i32 4, %_41
	br i1 %_42, label %oob_ok_11, label %oob_err_11

	oob_err_11:
	call void @throw_oob()
	br label %oob_ok_11

	oob_ok_11:
	%_43 = add i32 1, 4
	%_44 = getelementptr i32 , i32* %_40, i32 %_43
	store i32 2, i32* %_44


	%_45 = getelementptr i8, i8* %this , i32 8
	%_46 = bitcast i8* %_45 to i32**
	%_47 = load i32*, i32** %_46
	%_48 = load i32, i32* %_47
	%_49 = icmp ult i32 5, %_48
	br i1 %_49, label %oob_ok_12, label %oob_err_12

	oob_err_12:
	call void @throw_oob()
	br label %oob_ok_12

	oob_ok_12:
	%_50 = add i32 1, 5
	%_51 = getelementptr i32 , i32* %_47, i32 %_50
	store i32 11, i32* %_51


	%_52 = getelementptr i8, i8* %this , i32 8
	%_53 = bitcast i8* %_52 to i32**
	%_54 = load i32*, i32** %_53
	%_55 = load i32, i32* %_54
	%_56 = icmp ult i32 6, %_55
	br i1 %_56, label %oob_ok_13, label %oob_err_13

	oob_err_13:
	call void @throw_oob()
	br label %oob_ok_13

	oob_ok_13:
	%_57 = add i32 1, 6
	%_58 = getelementptr i32 , i32* %_54, i32 %_57
	store i32 6, i32* %_58


	%_59 = getelementptr i8, i8* %this , i32 8
	%_60 = bitcast i8* %_59 to i32**
	%_61 = load i32*, i32** %_60
	%_62 = load i32, i32* %_61
	%_63 = icmp ult i32 7, %_62
	br i1 %_63, label %oob_ok_14, label %oob_err_14

	oob_err_14:
	call void @throw_oob()
	br label %oob_ok_14

	oob_ok_14:
	%_64 = add i32 1, 7
	%_65 = getelementptr i32 , i32* %_61, i32 %_64
	store i32 9, i32* %_65


	%_66 = getelementptr i8, i8* %this , i32 8
	%_67 = bitcast i8* %_66 to i32**
	%_68 = load i32*, i32** %_67
	%_69 = load i32, i32* %_68
	%_70 = icmp ult i32 8, %_69
	br i1 %_70, label %oob_ok_15, label %oob_err_15

	oob_err_15:
	call void @throw_oob()
	br label %oob_ok_15

	oob_ok_15:
	%_71 = add i32 1, 8
	%_72 = getelementptr i32 , i32* %_68, i32 %_71
	store i32 19, i32* %_72


	%_73 = getelementptr i8, i8* %this , i32 8
	%_74 = bitcast i8* %_73 to i32**
	%_75 = load i32*, i32** %_74
	%_76 = load i32, i32* %_75
	%_77 = icmp ult i32 9, %_76
	br i1 %_77, label %oob_ok_16, label %oob_err_16

	oob_err_16:
	call void @throw_oob()
	br label %oob_ok_16

	oob_ok_16:
	%_78 = add i32 1, 9
	%_79 = getelementptr i32 , i32* %_75, i32 %_78
	store i32 5, i32* %_79

	ret i32 0
}
