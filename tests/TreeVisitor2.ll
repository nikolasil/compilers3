@.TreeVisitor_vtable = global [0 x i8*] []
@.TV_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*)* @TV.Start to i8*)
]
@.Tree_vtable = global [21 x i8*] [
	i8* bitcast (i1 (i8*,i32)* @Tree.Init to i8*),
	i8* bitcast (i1 (i8*,i8*)* @Tree.SetRight to i8*),
	i8* bitcast (i1 (i8*,i8*)* @Tree.SetLeft to i8*),
	i8* bitcast (i8* (i8*)* @Tree.GetRight to i8*),
	i8* bitcast (i8* (i8*)* @Tree.GetLeft to i8*),
	i8* bitcast (i32 (i8*)* @Tree.GetKey to i8*),
	i8* bitcast (i1 (i8*,i32)* @Tree.SetKey to i8*),
	i8* bitcast (i1 (i8*)* @Tree.GetHas_Right to i8*),
	i8* bitcast (i1 (i8*)* @Tree.GetHas_Left to i8*),
	i8* bitcast (i1 (i8*,i1)* @Tree.SetHas_Left to i8*),
	i8* bitcast (i1 (i8*,i1)* @Tree.SetHas_Right to i8*),
	i8* bitcast (i1 (i8*,i32,i32)* @Tree.Compare to i8*),
	i8* bitcast (i1 (i8*,i32)* @Tree.Insert to i8*),
	i8* bitcast (i1 (i8*,i32)* @Tree.Delete to i8*),
	i8* bitcast (i1 (i8*,i8*,i8*)* @Tree.Remove to i8*),
	i8* bitcast (i1 (i8*,i8*,i8*)* @Tree.RemoveRight to i8*),
	i8* bitcast (i1 (i8*,i8*,i8*)* @Tree.RemoveLeft to i8*),
	i8* bitcast (i32 (i8*,i32)* @Tree.Search to i8*),
	i8* bitcast (i1 (i8*)* @Tree.Print to i8*),
	i8* bitcast (i1 (i8*,i8*)* @Tree.RecPrint to i8*),
	i8* bitcast (i32 (i8*,i8*)* @Tree.accept to i8*)
]
@.Visitor_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*,i8*)* @Visitor.visit to i8*)
]
@.MyVisitor_vtable = global [1 x i8*] [
	i8* bitcast (i32 (i8*,i8*)* @MyVisitor.visit to i8*)
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

	%_0 = call i8* @calloc(i32 1, i32 8)
	%_1 = bitcast i8* %_0 to i8***
	%_2 = getelementptr [1 x i8*], [1 x i8*]* @.TV_vtable, i32 0, i32 0
	store i8** %_2, i8*** %_1

	%_3 = bitcast i8* %_0 to i8***
	%_4 = load i8**, i8*** %_3
	%_5 = getelementptr i8*, i8** %_4, i32 0
	%_6 = load i8*, i8** %_5
	%_7 = bitcast i8* %_6 to i32 (i8*)*
	%_8 = call i32 %_7(i8* %_0)

	call void (i32) @print_int(i32 %_8)
	ret i32 0
}

define i32 @TV.Start(i8* %this) {

	%root = alloca i8*
	%ntb = alloca i1
	%nti = alloca i32
	%v = alloca i8*
	%_0 = call i8* @calloc(i32 1, i32 38)
	%_1 = bitcast i8* %_0 to i8***
	%_2 = getelementptr [21 x i8*], [21 x i8*]* @.Tree_vtable, i32 0, i32 0
	store i8** %_2, i8*** %_1
	store i8* %_0, i8** %root

	%_3 = load i8*, i8** %root
	%_4 = bitcast i8* %_3 to i8***
	%_5 = load i8**, i8*** %_4
	%_6 = getelementptr i8*, i8** %_5, i32 0
	%_7 = load i8*, i8** %_6
	%_8 = bitcast i8* %_7 to i1 (i8*,i32)*
	%_9 = call i1 %_8(i8* %_3, i32 16)

	store i1 %_9, i1* %ntb

	%_10 = load i8*, i8** %root
	%_11 = bitcast i8* %_10 to i8***
	%_12 = load i8**, i8*** %_11
	%_13 = getelementptr i8*, i8** %_12, i32 18
	%_14 = load i8*, i8** %_13
	%_15 = bitcast i8* %_14 to i1 (i8*)*
	%_16 = call i1 %_15(i8* %_10)

	store i1 %_16, i1* %ntb
	call void (i32) @print_int(i32 100000000)

	%_17 = load i8*, i8** %root
	%_18 = bitcast i8* %_17 to i8***
	%_19 = load i8**, i8*** %_18
	%_20 = getelementptr i8*, i8** %_19, i32 12
	%_21 = load i8*, i8** %_20
	%_22 = bitcast i8* %_21 to i1 (i8*,i32)*
	%_23 = call i1 %_22(i8* %_17, i32 8)

	store i1 %_23, i1* %ntb

	%_24 = load i8*, i8** %root
	%_25 = bitcast i8* %_24 to i8***
	%_26 = load i8**, i8*** %_25
	%_27 = getelementptr i8*, i8** %_26, i32 12
	%_28 = load i8*, i8** %_27
	%_29 = bitcast i8* %_28 to i1 (i8*,i32)*
	%_30 = call i1 %_29(i8* %_24, i32 24)

	store i1 %_30, i1* %ntb

	%_31 = load i8*, i8** %root
	%_32 = bitcast i8* %_31 to i8***
	%_33 = load i8**, i8*** %_32
	%_34 = getelementptr i8*, i8** %_33, i32 12
	%_35 = load i8*, i8** %_34
	%_36 = bitcast i8* %_35 to i1 (i8*,i32)*
	%_37 = call i1 %_36(i8* %_31, i32 4)

	store i1 %_37, i1* %ntb

	%_38 = load i8*, i8** %root
	%_39 = bitcast i8* %_38 to i8***
	%_40 = load i8**, i8*** %_39
	%_41 = getelementptr i8*, i8** %_40, i32 12
	%_42 = load i8*, i8** %_41
	%_43 = bitcast i8* %_42 to i1 (i8*,i32)*
	%_44 = call i1 %_43(i8* %_38, i32 12)

	store i1 %_44, i1* %ntb

	%_45 = load i8*, i8** %root
	%_46 = bitcast i8* %_45 to i8***
	%_47 = load i8**, i8*** %_46
	%_48 = getelementptr i8*, i8** %_47, i32 12
	%_49 = load i8*, i8** %_48
	%_50 = bitcast i8* %_49 to i1 (i8*,i32)*
	%_51 = call i1 %_50(i8* %_45, i32 20)

	store i1 %_51, i1* %ntb

	%_52 = load i8*, i8** %root
	%_53 = bitcast i8* %_52 to i8***
	%_54 = load i8**, i8*** %_53
	%_55 = getelementptr i8*, i8** %_54, i32 12
	%_56 = load i8*, i8** %_55
	%_57 = bitcast i8* %_56 to i1 (i8*,i32)*
	%_58 = call i1 %_57(i8* %_52, i32 28)

	store i1 %_58, i1* %ntb

	%_59 = load i8*, i8** %root
	%_60 = bitcast i8* %_59 to i8***
	%_61 = load i8**, i8*** %_60
	%_62 = getelementptr i8*, i8** %_61, i32 12
	%_63 = load i8*, i8** %_62
	%_64 = bitcast i8* %_63 to i1 (i8*,i32)*
	%_65 = call i1 %_64(i8* %_59, i32 14)

	store i1 %_65, i1* %ntb

	%_66 = load i8*, i8** %root
	%_67 = bitcast i8* %_66 to i8***
	%_68 = load i8**, i8*** %_67
	%_69 = getelementptr i8*, i8** %_68, i32 18
	%_70 = load i8*, i8** %_69
	%_71 = bitcast i8* %_70 to i1 (i8*)*
	%_72 = call i1 %_71(i8* %_66)

	store i1 %_72, i1* %ntb
	call void (i32) @print_int(i32 100000000)
	%_73 = call i8* @calloc(i32 1, i32 24)
	%_74 = bitcast i8* %_73 to i8***
	%_75 = getelementptr [1 x i8*], [1 x i8*]* @.MyVisitor_vtable, i32 0, i32 0
	store i8** %_75, i8*** %_74
	store i8* %_73, i8** %v
	call void (i32) @print_int(i32 50000000)

	%_76 = load i8*, i8** %root
	%_77 = bitcast i8* %_76 to i8***
	%_78 = load i8**, i8*** %_77
	%_79 = getelementptr i8*, i8** %_78, i32 20
	%_80 = load i8*, i8** %_79
	%_81 = bitcast i8* %_80 to i32 (i8*,i8*)*
	%_82 = load i8*, i8** %v
	%_83 = call i32 %_81(i8* %_76, i8* %_82)

	store i32 %_83, i32* %nti
	call void (i32) @print_int(i32 100000000)

	%_84 = load i8*, i8** %root
	%_85 = bitcast i8* %_84 to i8***
	%_86 = load i8**, i8*** %_85
	%_87 = getelementptr i8*, i8** %_86, i32 17
	%_88 = load i8*, i8** %_87
	%_89 = bitcast i8* %_88 to i32 (i8*,i32)*
	%_90 = call i32 %_89(i8* %_84, i32 24)

	call void (i32) @print_int(i32 %_90)

	%_91 = load i8*, i8** %root
	%_92 = bitcast i8* %_91 to i8***
	%_93 = load i8**, i8*** %_92
	%_94 = getelementptr i8*, i8** %_93, i32 17
	%_95 = load i8*, i8** %_94
	%_96 = bitcast i8* %_95 to i32 (i8*,i32)*
	%_97 = call i32 %_96(i8* %_91, i32 12)

	call void (i32) @print_int(i32 %_97)

	%_98 = load i8*, i8** %root
	%_99 = bitcast i8* %_98 to i8***
	%_100 = load i8**, i8*** %_99
	%_101 = getelementptr i8*, i8** %_100, i32 17
	%_102 = load i8*, i8** %_101
	%_103 = bitcast i8* %_102 to i32 (i8*,i32)*
	%_104 = call i32 %_103(i8* %_98, i32 16)

	call void (i32) @print_int(i32 %_104)

	%_105 = load i8*, i8** %root
	%_106 = bitcast i8* %_105 to i8***
	%_107 = load i8**, i8*** %_106
	%_108 = getelementptr i8*, i8** %_107, i32 17
	%_109 = load i8*, i8** %_108
	%_110 = bitcast i8* %_109 to i32 (i8*,i32)*
	%_111 = call i32 %_110(i8* %_105, i32 50)

	call void (i32) @print_int(i32 %_111)

	%_112 = load i8*, i8** %root
	%_113 = bitcast i8* %_112 to i8***
	%_114 = load i8**, i8*** %_113
	%_115 = getelementptr i8*, i8** %_114, i32 17
	%_116 = load i8*, i8** %_115
	%_117 = bitcast i8* %_116 to i32 (i8*,i32)*
	%_118 = call i32 %_117(i8* %_112, i32 12)

	call void (i32) @print_int(i32 %_118)

	%_119 = load i8*, i8** %root
	%_120 = bitcast i8* %_119 to i8***
	%_121 = load i8**, i8*** %_120
	%_122 = getelementptr i8*, i8** %_121, i32 13
	%_123 = load i8*, i8** %_122
	%_124 = bitcast i8* %_123 to i1 (i8*,i32)*
	%_125 = call i1 %_124(i8* %_119, i32 12)

	store i1 %_125, i1* %ntb

	%_126 = load i8*, i8** %root
	%_127 = bitcast i8* %_126 to i8***
	%_128 = load i8**, i8*** %_127
	%_129 = getelementptr i8*, i8** %_128, i32 18
	%_130 = load i8*, i8** %_129
	%_131 = bitcast i8* %_130 to i1 (i8*)*
	%_132 = call i1 %_131(i8* %_126)

	store i1 %_132, i1* %ntb

	%_133 = load i8*, i8** %root
	%_134 = bitcast i8* %_133 to i8***
	%_135 = load i8**, i8*** %_134
	%_136 = getelementptr i8*, i8** %_135, i32 17
	%_137 = load i8*, i8** %_136
	%_138 = bitcast i8* %_137 to i32 (i8*,i32)*
	%_139 = call i32 %_138(i8* %_133, i32 12)

	call void (i32) @print_int(i32 %_139)
	ret i32 0
}

define i1 @Tree.Init(i8* %this, i32 %.v_key) {
	%v_key = alloca i32
	store i32 %.v_key, i32* %v_key

	%_0 = load i32, i32* %v_key
	%_1 = getelementptr i8, i8* %this, i32 24
	%_2 = bitcast i8* %_1 to i32*
	store i32 %_0, i32* %_2
	%_3 = getelementptr i8, i8* %this, i32 28
	%_4 = bitcast i8* %_3 to i1*
	store i1 0, i1* %_4
	%_5 = getelementptr i8, i8* %this, i32 29
	%_6 = bitcast i8* %_5 to i1*
	store i1 0, i1* %_6
	ret i1 1
}

define i1 @Tree.SetRight(i8* %this, i8* %.rn) {
	%rn = alloca i8*
	store i8* %.rn, i8** %rn

	%_0 = load i8*, i8** %rn
	%_1 = getelementptr i8, i8* %this, i32 16
	%_2 = bitcast i8* %_1 to i8**
	store i8* %_0, i8** %_2
	ret i1 1
}

define i1 @Tree.SetLeft(i8* %this, i8* %.ln) {
	%ln = alloca i8*
	store i8* %.ln, i8** %ln

	%_0 = load i8*, i8** %ln
	%_1 = getelementptr i8, i8* %this, i32 8
	%_2 = bitcast i8* %_1 to i8**
	store i8* %_0, i8** %_2
	ret i1 1
}

define i8* @Tree.GetRight(i8* %this) {

	%_0 = getelementptr i8, i8* %this, i32 16
	%_1 = bitcast i8* %_0 to i8**
	%_2 = load i8*, i8** %_1
	ret i8* %_2
}

define i8* @Tree.GetLeft(i8* %this) {

	%_0 = getelementptr i8, i8* %this, i32 8
	%_1 = bitcast i8* %_0 to i8**
	%_2 = load i8*, i8** %_1
	ret i8* %_2
}

define i32 @Tree.GetKey(i8* %this) {

	%_0 = getelementptr i8, i8* %this, i32 24
	%_1 = bitcast i8* %_0 to i32*
	%_2 = load i32, i32* %_1
	ret i32 %_2
}

define i1 @Tree.SetKey(i8* %this, i32 %.v_key) {
	%v_key = alloca i32
	store i32 %.v_key, i32* %v_key

	%_0 = load i32, i32* %v_key
	%_1 = getelementptr i8, i8* %this, i32 24
	%_2 = bitcast i8* %_1 to i32*
	store i32 %_0, i32* %_2
	ret i1 1
}

define i1 @Tree.GetHas_Right(i8* %this) {

	%_0 = getelementptr i8, i8* %this, i32 29
	%_1 = bitcast i8* %_0 to i1*
	%_2 = load i1, i1* %_1
	ret i1 %_2
}

define i1 @Tree.GetHas_Left(i8* %this) {

	%_0 = getelementptr i8, i8* %this, i32 28
	%_1 = bitcast i8* %_0 to i1*
	%_2 = load i1, i1* %_1
	ret i1 %_2
}

define i1 @Tree.SetHas_Left(i8* %this, i1 %.val) {
	%val = alloca i1
	store i1 %.val, i1* %val

	%_0 = load i1, i1* %val
	%_1 = getelementptr i8, i8* %this, i32 28
	%_2 = bitcast i8* %_1 to i1*
	store i1 %_0, i1* %_2
	ret i1 1
}

define i1 @Tree.SetHas_Right(i8* %this, i1 %.val) {
	%val = alloca i1
	store i1 %.val, i1* %val

	%_0 = load i1, i1* %val
	%_1 = getelementptr i8, i8* %this, i32 29
	%_2 = bitcast i8* %_1 to i1*
	store i1 %_0, i1* %_2
	ret i1 1
}

define i1 @Tree.Compare(i8* %this, i32 %.num1, i32 %.num2) {
	%num1 = alloca i32
	store i32 %.num1, i32* %num1
	%num2 = alloca i32
	store i32 %.num2, i32* %num2

	%ntb = alloca i1
	%nti = alloca i32
	store i1 0, i1* %ntb
	%_0 = load i32, i32* %num2
	%_1 = add i32 %_0, 1
	store i32 %_1, i32* %nti
	%_2 = load i32, i32* %num1
	%_3 = load i32, i32* %num2
	%_4 = icmp slt i32 %_2, %_3
	br i1 %_4, label %if_then_0, label %if_else_0
	if_else_0:
	%_5 = load i32, i32* %num1
	%_6 = load i32, i32* %nti
	%_7 = icmp slt i32 %_5, %_6
	%_8 = xor i1 1, %_7
	br i1 %_8, label %if_then_1, label %if_else_1
	if_else_1:
	store i1 1, i1* %ntb

	br label %if_end_0
	if_then_1:
	store i1 0, i1* %ntb

	br label %if_end_0
	if_end_0:

	br label %if_end_1
	if_then_0:
	store i1 0, i1* %ntb

	br label %if_end_1
	if_end_1:
	%_9 = load i1, i1* %ntb
	ret i1 %_9
}

define i1 @Tree.Insert(i8* %this, i32 %.v_key) {
	%v_key = alloca i32
	store i32 %.v_key, i32* %v_key

	%new_node = alloca i8*
	%ntb = alloca i1
	%current_node = alloca i8*
	%cont = alloca i1
	%key_aux = alloca i32
	%_0 = call i8* @calloc(i32 1, i32 38)
	%_1 = bitcast i8* %_0 to i8***
	%_2 = getelementptr [21 x i8*], [21 x i8*]* @.Tree_vtable, i32 0, i32 0
	store i8** %_2, i8*** %_1
	store i8* %_0, i8** %new_node

	%_3 = load i8*, i8** %new_node
	%_4 = bitcast i8* %_3 to i8***
	%_5 = load i8**, i8*** %_4
	%_6 = getelementptr i8*, i8** %_5, i32 0
	%_7 = load i8*, i8** %_6
	%_8 = bitcast i8* %_7 to i1 (i8*,i32)*
	%_9 = load i32, i32* %v_key
	%_10 = call i1 %_8(i8* %_3, i32 %_9)

	store i1 %_10, i1* %ntb
	store i8* %this, i8** %current_node
	store i1 1, i1* %cont
	br label %loop01
	loop01:
	%_11 = load i1, i1* %cont
	br i1 %_11, label %loop02, label %loop03
	loop02:

	%_12 = load i8*, i8** %current_node
	%_13 = bitcast i8* %_12 to i8***
	%_14 = load i8**, i8*** %_13
	%_15 = getelementptr i8*, i8** %_14, i32 5
	%_16 = load i8*, i8** %_15
	%_17 = bitcast i8* %_16 to i32 (i8*)*
	%_18 = call i32 %_17(i8* %_12)

	store i32 %_18, i32* %key_aux
	%_19 = load i32, i32* %v_key
	%_20 = load i32, i32* %key_aux
	%_21 = icmp slt i32 %_19, %_20
	br i1 %_21, label %if_then_2, label %if_else_2
	if_else_2:

	%_22 = load i8*, i8** %current_node
	%_23 = bitcast i8* %_22 to i8***
	%_24 = load i8**, i8*** %_23
	%_25 = getelementptr i8*, i8** %_24, i32 7
	%_26 = load i8*, i8** %_25
	%_27 = bitcast i8* %_26 to i1 (i8*)*
	%_28 = call i1 %_27(i8* %_22)

	br i1 %_28, label %if_then_3, label %if_else_3
	if_else_3:
	store i1 0, i1* %cont

	%_29 = load i8*, i8** %current_node
	%_30 = bitcast i8* %_29 to i8***
	%_31 = load i8**, i8*** %_30
	%_32 = getelementptr i8*, i8** %_31, i32 10
	%_33 = load i8*, i8** %_32
	%_34 = bitcast i8* %_33 to i1 (i8*,i1)*
	%_35 = call i1 %_34(i8* %_29, i1 1)

	store i1 %_35, i1* %ntb

	%_36 = load i8*, i8** %current_node
	%_37 = bitcast i8* %_36 to i8***
	%_38 = load i8**, i8*** %_37
	%_39 = getelementptr i8*, i8** %_38, i32 1
	%_40 = load i8*, i8** %_39
	%_41 = bitcast i8* %_40 to i1 (i8*,i8*)*
	%_42 = load i8*, i8** %new_node
	%_43 = call i1 %_41(i8* %_36, i8* %_42)

	store i1 %_43, i1* %ntb

	br label %if_end_2
	if_then_3:

	%_44 = load i8*, i8** %current_node
	%_45 = bitcast i8* %_44 to i8***
	%_46 = load i8**, i8*** %_45
	%_47 = getelementptr i8*, i8** %_46, i32 3
	%_48 = load i8*, i8** %_47
	%_49 = bitcast i8* %_48 to i8* (i8*)*
	%_50 = call i8* %_49(i8* %_44)

	store i8* %_50, i8** %current_node

	br label %if_end_2
	if_end_2:

	br label %if_end_3
	if_then_2:

	%_51 = load i8*, i8** %current_node
	%_52 = bitcast i8* %_51 to i8***
	%_53 = load i8**, i8*** %_52
	%_54 = getelementptr i8*, i8** %_53, i32 8
	%_55 = load i8*, i8** %_54
	%_56 = bitcast i8* %_55 to i1 (i8*)*
	%_57 = call i1 %_56(i8* %_51)

	br i1 %_57, label %if_then_4, label %if_else_4
	if_else_4:
	store i1 0, i1* %cont

	%_58 = load i8*, i8** %current_node
	%_59 = bitcast i8* %_58 to i8***
	%_60 = load i8**, i8*** %_59
	%_61 = getelementptr i8*, i8** %_60, i32 9
	%_62 = load i8*, i8** %_61
	%_63 = bitcast i8* %_62 to i1 (i8*,i1)*
	%_64 = call i1 %_63(i8* %_58, i1 1)

	store i1 %_64, i1* %ntb

	%_65 = load i8*, i8** %current_node
	%_66 = bitcast i8* %_65 to i8***
	%_67 = load i8**, i8*** %_66
	%_68 = getelementptr i8*, i8** %_67, i32 2
	%_69 = load i8*, i8** %_68
	%_70 = bitcast i8* %_69 to i1 (i8*,i8*)*
	%_71 = load i8*, i8** %new_node
	%_72 = call i1 %_70(i8* %_65, i8* %_71)

	store i1 %_72, i1* %ntb

	br label %if_end_4
	if_then_4:

	%_73 = load i8*, i8** %current_node
	%_74 = bitcast i8* %_73 to i8***
	%_75 = load i8**, i8*** %_74
	%_76 = getelementptr i8*, i8** %_75, i32 4
	%_77 = load i8*, i8** %_76
	%_78 = bitcast i8* %_77 to i8* (i8*)*
	%_79 = call i8* %_78(i8* %_73)

	store i8* %_79, i8** %current_node

	br label %if_end_4
	if_end_4:

	br label %if_end_3
	if_end_3:
	br label %loop01
	loop03:
	ret i1 1
}

define i1 @Tree.Delete(i8* %this, i32 %.v_key) {
	%v_key = alloca i32
	store i32 %.v_key, i32* %v_key

	%current_node = alloca i8*
	%parent_node = alloca i8*
	%cont = alloca i1
	%found = alloca i1
	%ntb = alloca i1
	%is_root = alloca i1
	%key_aux = alloca i32
	store i8* %this, i8** %current_node
	store i8* %this, i8** %parent_node
	store i1 1, i1* %cont
	store i1 0, i1* %found
	store i1 1, i1* %is_root
	br label %loop11
	loop11:
	%_0 = load i1, i1* %cont
	br i1 %_0, label %loop12, label %loop13
	loop12:

	%_1 = load i8*, i8** %current_node
	%_2 = bitcast i8* %_1 to i8***
	%_3 = load i8**, i8*** %_2
	%_4 = getelementptr i8*, i8** %_3, i32 5
	%_5 = load i8*, i8** %_4
	%_6 = bitcast i8* %_5 to i32 (i8*)*
	%_7 = call i32 %_6(i8* %_1)

	store i32 %_7, i32* %key_aux
	%_8 = load i32, i32* %v_key
	%_9 = load i32, i32* %key_aux
	%_10 = icmp slt i32 %_8, %_9
	br i1 %_10, label %if_then_5, label %if_else_5
	if_else_5:
	%_11 = load i32, i32* %key_aux
	%_12 = load i32, i32* %v_key
	%_13 = icmp slt i32 %_11, %_12
	br i1 %_13, label %if_then_6, label %if_else_6
	if_else_6:
	%_14 = load i1, i1* %is_root
	br i1 %_14, label %if_then_7, label %if_else_7
	if_else_7:

	%_15 = bitcast i8* %this to i8***
	%_16 = load i8**, i8*** %_15
	%_17 = getelementptr i8*, i8** %_16, i32 14
	%_18 = load i8*, i8** %_17
	%_19 = bitcast i8* %_18 to i1 (i8*,i8*,i8*)*
	%_20 = load i8*, i8** %parent_node
	%_21 = load i8*, i8** %current_node
	%_22 = call i1 %_19(i8* %this, i8* %_20, i8* %_21)

	store i1 %_22, i1* %ntb

	br label %if_end_5
	if_then_7:

	%_23 = load i8*, i8** %current_node
	%_24 = bitcast i8* %_23 to i8***
	%_25 = load i8**, i8*** %_24
	%_26 = getelementptr i8*, i8** %_25, i32 7
	%_27 = load i8*, i8** %_26
	%_28 = bitcast i8* %_27 to i1 (i8*)*
	%_29 = call i1 %_28(i8* %_23)

	%_30 = xor i1 1, %_29
	br i1 %_30, label %exp_res_1, label %exp_res_0

	exp_res_0:
	br label %exp_res_3

	exp_res_1:

	%_31 = load i8*, i8** %current_node
	%_32 = bitcast i8* %_31 to i8***
	%_33 = load i8**, i8*** %_32
	%_34 = getelementptr i8*, i8** %_33, i32 8
	%_35 = load i8*, i8** %_34
	%_36 = bitcast i8* %_35 to i1 (i8*)*
	%_37 = call i1 %_36(i8* %_31)

	%_38 = xor i1 1, %_37
	br label %exp_res_2

	exp_res_2:
	br label %exp_res_3

	exp_res_3:
	%_39 = phi i1 [ 0, %exp_res_0 ], [ %_38, %exp_res_2 ]
	br i1 %_39, label %if_then_8, label %if_else_8
	if_else_8:

	%_40 = bitcast i8* %this to i8***
	%_41 = load i8**, i8*** %_40
	%_42 = getelementptr i8*, i8** %_41, i32 14
	%_43 = load i8*, i8** %_42
	%_44 = bitcast i8* %_43 to i1 (i8*,i8*,i8*)*
	%_45 = load i8*, i8** %parent_node
	%_46 = load i8*, i8** %current_node
	%_47 = call i1 %_44(i8* %this, i8* %_45, i8* %_46)

	store i1 %_47, i1* %ntb

	br label %if_end_6
	if_then_8:
	store i1 1, i1* %ntb

	br label %if_end_6
	if_end_6:

	br label %if_end_5
	if_end_5:
	store i1 1, i1* %found
	store i1 0, i1* %cont

	br label %if_end_7
	if_then_6:

	%_48 = load i8*, i8** %current_node
	%_49 = bitcast i8* %_48 to i8***
	%_50 = load i8**, i8*** %_49
	%_51 = getelementptr i8*, i8** %_50, i32 7
	%_52 = load i8*, i8** %_51
	%_53 = bitcast i8* %_52 to i1 (i8*)*
	%_54 = call i1 %_53(i8* %_48)

	br i1 %_54, label %if_then_9, label %if_else_9
	if_else_9:
	store i1 0, i1* %cont

	br label %if_end_8
	if_then_9:
	%_55 = load i8*, i8** %current_node
	store i8* %_55, i8** %parent_node

	%_56 = load i8*, i8** %current_node
	%_57 = bitcast i8* %_56 to i8***
	%_58 = load i8**, i8*** %_57
	%_59 = getelementptr i8*, i8** %_58, i32 3
	%_60 = load i8*, i8** %_59
	%_61 = bitcast i8* %_60 to i8* (i8*)*
	%_62 = call i8* %_61(i8* %_56)

	store i8* %_62, i8** %current_node

	br label %if_end_8
	if_end_8:

	br label %if_end_7
	if_end_7:

	br label %if_end_9
	if_then_5:

	%_63 = load i8*, i8** %current_node
	%_64 = bitcast i8* %_63 to i8***
	%_65 = load i8**, i8*** %_64
	%_66 = getelementptr i8*, i8** %_65, i32 8
	%_67 = load i8*, i8** %_66
	%_68 = bitcast i8* %_67 to i1 (i8*)*
	%_69 = call i1 %_68(i8* %_63)

	br i1 %_69, label %if_then_10, label %if_else_10
	if_else_10:
	store i1 0, i1* %cont

	br label %if_end_10
	if_then_10:
	%_70 = load i8*, i8** %current_node
	store i8* %_70, i8** %parent_node

	%_71 = load i8*, i8** %current_node
	%_72 = bitcast i8* %_71 to i8***
	%_73 = load i8**, i8*** %_72
	%_74 = getelementptr i8*, i8** %_73, i32 4
	%_75 = load i8*, i8** %_74
	%_76 = bitcast i8* %_75 to i8* (i8*)*
	%_77 = call i8* %_76(i8* %_71)

	store i8* %_77, i8** %current_node

	br label %if_end_10
	if_end_10:

	br label %if_end_9
	if_end_9:
	store i1 0, i1* %is_root
	br label %loop11
	loop13:
	%_78 = load i1, i1* %found
	ret i1 %_78
}

define i1 @Tree.Remove(i8* %this, i8* %.p_node, i8* %.c_node) {
	%p_node = alloca i8*
	store i8* %.p_node, i8** %p_node
	%c_node = alloca i8*
	store i8* %.c_node, i8** %c_node

	%ntb = alloca i1
	%auxkey1 = alloca i32
	%auxkey2 = alloca i32

	%_0 = load i8*, i8** %c_node
	%_1 = bitcast i8* %_0 to i8***
	%_2 = load i8**, i8*** %_1
	%_3 = getelementptr i8*, i8** %_2, i32 8
	%_4 = load i8*, i8** %_3
	%_5 = bitcast i8* %_4 to i1 (i8*)*
	%_6 = call i1 %_5(i8* %_0)

	br i1 %_6, label %if_then_11, label %if_else_11
	if_else_11:

	%_7 = load i8*, i8** %c_node
	%_8 = bitcast i8* %_7 to i8***
	%_9 = load i8**, i8*** %_8
	%_10 = getelementptr i8*, i8** %_9, i32 7
	%_11 = load i8*, i8** %_10
	%_12 = bitcast i8* %_11 to i1 (i8*)*
	%_13 = call i1 %_12(i8* %_7)

	br i1 %_13, label %if_then_12, label %if_else_12
	if_else_12:

	%_14 = load i8*, i8** %c_node
	%_15 = bitcast i8* %_14 to i8***
	%_16 = load i8**, i8*** %_15
	%_17 = getelementptr i8*, i8** %_16, i32 5
	%_18 = load i8*, i8** %_17
	%_19 = bitcast i8* %_18 to i32 (i8*)*
	%_20 = call i32 %_19(i8* %_14)

	store i32 %_20, i32* %auxkey1


	%_21 = load i8*, i8** %p_node
	%_22 = bitcast i8* %_21 to i8***
	%_23 = load i8**, i8*** %_22
	%_24 = getelementptr i8*, i8** %_23, i32 4
	%_25 = load i8*, i8** %_24
	%_26 = bitcast i8* %_25 to i8* (i8*)*
	%_27 = call i8* %_26(i8* %_21)


	%_28 = bitcast i8* %_27 to i8***
	%_29 = load i8**, i8*** %_28
	%_30 = getelementptr i8*, i8** %_29, i32 5
	%_31 = load i8*, i8** %_30
	%_32 = bitcast i8* %_31 to i32 (i8*)*
	%_33 = call i32 %_32(i8* %_27)

	store i32 %_33, i32* %auxkey2

	%_34 = bitcast i8* %this to i8***
	%_35 = load i8**, i8*** %_34
	%_36 = getelementptr i8*, i8** %_35, i32 11
	%_37 = load i8*, i8** %_36
	%_38 = bitcast i8* %_37 to i1 (i8*,i32,i32)*
	%_39 = load i32, i32* %auxkey1
	%_40 = load i32, i32* %auxkey2
	%_41 = call i1 %_38(i8* %this, i32 %_39, i32 %_40)

	br i1 %_41, label %if_then_13, label %if_else_13
	if_else_13:

	%_42 = load i8*, i8** %p_node
	%_43 = bitcast i8* %_42 to i8***
	%_44 = load i8**, i8*** %_43
	%_45 = getelementptr i8*, i8** %_44, i32 1
	%_46 = load i8*, i8** %_45
	%_47 = bitcast i8* %_46 to i1 (i8*,i8*)*
	%_48 = getelementptr i8, i8* %this, i32 30
	%_49 = bitcast i8* %_48 to i8**
	%_50 = load i8*, i8** %_49
	%_51 = call i1 %_47(i8* %_42, i8* %_50)

	store i1 %_51, i1* %ntb

	%_52 = load i8*, i8** %p_node
	%_53 = bitcast i8* %_52 to i8***
	%_54 = load i8**, i8*** %_53
	%_55 = getelementptr i8*, i8** %_54, i32 10
	%_56 = load i8*, i8** %_55
	%_57 = bitcast i8* %_56 to i1 (i8*,i1)*
	%_58 = call i1 %_57(i8* %_52, i1 0)

	store i1 %_58, i1* %ntb

	br label %if_end_11
	if_then_13:

	%_59 = load i8*, i8** %p_node
	%_60 = bitcast i8* %_59 to i8***
	%_61 = load i8**, i8*** %_60
	%_62 = getelementptr i8*, i8** %_61, i32 2
	%_63 = load i8*, i8** %_62
	%_64 = bitcast i8* %_63 to i1 (i8*,i8*)*
	%_65 = getelementptr i8, i8* %this, i32 30
	%_66 = bitcast i8* %_65 to i8**
	%_67 = load i8*, i8** %_66
	%_68 = call i1 %_64(i8* %_59, i8* %_67)

	store i1 %_68, i1* %ntb

	%_69 = load i8*, i8** %p_node
	%_70 = bitcast i8* %_69 to i8***
	%_71 = load i8**, i8*** %_70
	%_72 = getelementptr i8*, i8** %_71, i32 9
	%_73 = load i8*, i8** %_72
	%_74 = bitcast i8* %_73 to i1 (i8*,i1)*
	%_75 = call i1 %_74(i8* %_69, i1 0)

	store i1 %_75, i1* %ntb

	br label %if_end_11
	if_end_11:

	br label %if_end_12
	if_then_12:

	%_76 = bitcast i8* %this to i8***
	%_77 = load i8**, i8*** %_76
	%_78 = getelementptr i8*, i8** %_77, i32 15
	%_79 = load i8*, i8** %_78
	%_80 = bitcast i8* %_79 to i1 (i8*,i8*,i8*)*
	%_81 = load i8*, i8** %p_node
	%_82 = load i8*, i8** %c_node
	%_83 = call i1 %_80(i8* %this, i8* %_81, i8* %_82)

	store i1 %_83, i1* %ntb

	br label %if_end_12
	if_end_12:

	br label %if_end_13
	if_then_11:

	%_84 = bitcast i8* %this to i8***
	%_85 = load i8**, i8*** %_84
	%_86 = getelementptr i8*, i8** %_85, i32 16
	%_87 = load i8*, i8** %_86
	%_88 = bitcast i8* %_87 to i1 (i8*,i8*,i8*)*
	%_89 = load i8*, i8** %p_node
	%_90 = load i8*, i8** %c_node
	%_91 = call i1 %_88(i8* %this, i8* %_89, i8* %_90)

	store i1 %_91, i1* %ntb

	br label %if_end_13
	if_end_13:
	ret i1 1
}

define i1 @Tree.RemoveRight(i8* %this, i8* %.p_node, i8* %.c_node) {
	%p_node = alloca i8*
	store i8* %.p_node, i8** %p_node
	%c_node = alloca i8*
	store i8* %.c_node, i8** %c_node

	%ntb = alloca i1
	br label %loop21
	loop21:

	%_0 = load i8*, i8** %c_node
	%_1 = bitcast i8* %_0 to i8***
	%_2 = load i8**, i8*** %_1
	%_3 = getelementptr i8*, i8** %_2, i32 7
	%_4 = load i8*, i8** %_3
	%_5 = bitcast i8* %_4 to i1 (i8*)*
	%_6 = call i1 %_5(i8* %_0)

	br i1 %_6, label %loop22, label %loop23
	loop22:

	%_7 = load i8*, i8** %c_node
	%_8 = bitcast i8* %_7 to i8***
	%_9 = load i8**, i8*** %_8
	%_10 = getelementptr i8*, i8** %_9, i32 6
	%_11 = load i8*, i8** %_10
	%_12 = bitcast i8* %_11 to i1 (i8*,i32)*


	%_13 = load i8*, i8** %c_node
	%_14 = bitcast i8* %_13 to i8***
	%_15 = load i8**, i8*** %_14
	%_16 = getelementptr i8*, i8** %_15, i32 3
	%_17 = load i8*, i8** %_16
	%_18 = bitcast i8* %_17 to i8* (i8*)*
	%_19 = call i8* %_18(i8* %_13)


	%_20 = bitcast i8* %_19 to i8***
	%_21 = load i8**, i8*** %_20
	%_22 = getelementptr i8*, i8** %_21, i32 5
	%_23 = load i8*, i8** %_22
	%_24 = bitcast i8* %_23 to i32 (i8*)*
	%_25 = call i32 %_24(i8* %_19)

	%_26 = call i1 %_12(i8* %_7, i32 %_25)

	store i1 %_26, i1* %ntb
	%_27 = load i8*, i8** %c_node
	store i8* %_27, i8** %p_node

	%_28 = load i8*, i8** %c_node
	%_29 = bitcast i8* %_28 to i8***
	%_30 = load i8**, i8*** %_29
	%_31 = getelementptr i8*, i8** %_30, i32 3
	%_32 = load i8*, i8** %_31
	%_33 = bitcast i8* %_32 to i8* (i8*)*
	%_34 = call i8* %_33(i8* %_28)

	store i8* %_34, i8** %c_node
	br label %loop21
	loop23:

	%_35 = load i8*, i8** %p_node
	%_36 = bitcast i8* %_35 to i8***
	%_37 = load i8**, i8*** %_36
	%_38 = getelementptr i8*, i8** %_37, i32 1
	%_39 = load i8*, i8** %_38
	%_40 = bitcast i8* %_39 to i1 (i8*,i8*)*
	%_41 = getelementptr i8, i8* %this, i32 30
	%_42 = bitcast i8* %_41 to i8**
	%_43 = load i8*, i8** %_42
	%_44 = call i1 %_40(i8* %_35, i8* %_43)

	store i1 %_44, i1* %ntb

	%_45 = load i8*, i8** %p_node
	%_46 = bitcast i8* %_45 to i8***
	%_47 = load i8**, i8*** %_46
	%_48 = getelementptr i8*, i8** %_47, i32 10
	%_49 = load i8*, i8** %_48
	%_50 = bitcast i8* %_49 to i1 (i8*,i1)*
	%_51 = call i1 %_50(i8* %_45, i1 0)

	store i1 %_51, i1* %ntb
	ret i1 1
}

define i1 @Tree.RemoveLeft(i8* %this, i8* %.p_node, i8* %.c_node) {
	%p_node = alloca i8*
	store i8* %.p_node, i8** %p_node
	%c_node = alloca i8*
	store i8* %.c_node, i8** %c_node

	%ntb = alloca i1
	br label %loop31
	loop31:

	%_0 = load i8*, i8** %c_node
	%_1 = bitcast i8* %_0 to i8***
	%_2 = load i8**, i8*** %_1
	%_3 = getelementptr i8*, i8** %_2, i32 8
	%_4 = load i8*, i8** %_3
	%_5 = bitcast i8* %_4 to i1 (i8*)*
	%_6 = call i1 %_5(i8* %_0)

	br i1 %_6, label %loop32, label %loop33
	loop32:

	%_7 = load i8*, i8** %c_node
	%_8 = bitcast i8* %_7 to i8***
	%_9 = load i8**, i8*** %_8
	%_10 = getelementptr i8*, i8** %_9, i32 6
	%_11 = load i8*, i8** %_10
	%_12 = bitcast i8* %_11 to i1 (i8*,i32)*


	%_13 = load i8*, i8** %c_node
	%_14 = bitcast i8* %_13 to i8***
	%_15 = load i8**, i8*** %_14
	%_16 = getelementptr i8*, i8** %_15, i32 4
	%_17 = load i8*, i8** %_16
	%_18 = bitcast i8* %_17 to i8* (i8*)*
	%_19 = call i8* %_18(i8* %_13)


	%_20 = bitcast i8* %_19 to i8***
	%_21 = load i8**, i8*** %_20
	%_22 = getelementptr i8*, i8** %_21, i32 5
	%_23 = load i8*, i8** %_22
	%_24 = bitcast i8* %_23 to i32 (i8*)*
	%_25 = call i32 %_24(i8* %_19)

	%_26 = call i1 %_12(i8* %_7, i32 %_25)

	store i1 %_26, i1* %ntb
	%_27 = load i8*, i8** %c_node
	store i8* %_27, i8** %p_node

	%_28 = load i8*, i8** %c_node
	%_29 = bitcast i8* %_28 to i8***
	%_30 = load i8**, i8*** %_29
	%_31 = getelementptr i8*, i8** %_30, i32 4
	%_32 = load i8*, i8** %_31
	%_33 = bitcast i8* %_32 to i8* (i8*)*
	%_34 = call i8* %_33(i8* %_28)

	store i8* %_34, i8** %c_node
	br label %loop31
	loop33:

	%_35 = load i8*, i8** %p_node
	%_36 = bitcast i8* %_35 to i8***
	%_37 = load i8**, i8*** %_36
	%_38 = getelementptr i8*, i8** %_37, i32 2
	%_39 = load i8*, i8** %_38
	%_40 = bitcast i8* %_39 to i1 (i8*,i8*)*
	%_41 = getelementptr i8, i8* %this, i32 30
	%_42 = bitcast i8* %_41 to i8**
	%_43 = load i8*, i8** %_42
	%_44 = call i1 %_40(i8* %_35, i8* %_43)

	store i1 %_44, i1* %ntb

	%_45 = load i8*, i8** %p_node
	%_46 = bitcast i8* %_45 to i8***
	%_47 = load i8**, i8*** %_46
	%_48 = getelementptr i8*, i8** %_47, i32 9
	%_49 = load i8*, i8** %_48
	%_50 = bitcast i8* %_49 to i1 (i8*,i1)*
	%_51 = call i1 %_50(i8* %_45, i1 0)

	store i1 %_51, i1* %ntb
	ret i1 1
}

define i32 @Tree.Search(i8* %this, i32 %.v_key) {
	%v_key = alloca i32
	store i32 %.v_key, i32* %v_key

	%current_node = alloca i8*
	%ifound = alloca i32
	%cont = alloca i1
	%key_aux = alloca i32
	store i8* %this, i8** %current_node
	store i1 1, i1* %cont
	store i32 0, i32* %ifound
	br label %loop41
	loop41:
	%_0 = load i1, i1* %cont
	br i1 %_0, label %loop42, label %loop43
	loop42:

	%_1 = load i8*, i8** %current_node
	%_2 = bitcast i8* %_1 to i8***
	%_3 = load i8**, i8*** %_2
	%_4 = getelementptr i8*, i8** %_3, i32 5
	%_5 = load i8*, i8** %_4
	%_6 = bitcast i8* %_5 to i32 (i8*)*
	%_7 = call i32 %_6(i8* %_1)

	store i32 %_7, i32* %key_aux
	%_8 = load i32, i32* %v_key
	%_9 = load i32, i32* %key_aux
	%_10 = icmp slt i32 %_8, %_9
	br i1 %_10, label %if_then_14, label %if_else_14
	if_else_14:
	%_11 = load i32, i32* %key_aux
	%_12 = load i32, i32* %v_key
	%_13 = icmp slt i32 %_11, %_12
	br i1 %_13, label %if_then_15, label %if_else_15
	if_else_15:
	store i32 1, i32* %ifound
	store i1 0, i1* %cont

	br label %if_end_14
	if_then_15:

	%_14 = load i8*, i8** %current_node
	%_15 = bitcast i8* %_14 to i8***
	%_16 = load i8**, i8*** %_15
	%_17 = getelementptr i8*, i8** %_16, i32 7
	%_18 = load i8*, i8** %_17
	%_19 = bitcast i8* %_18 to i1 (i8*)*
	%_20 = call i1 %_19(i8* %_14)

	br i1 %_20, label %if_then_16, label %if_else_16
	if_else_16:
	store i1 0, i1* %cont

	br label %if_end_15
	if_then_16:

	%_21 = load i8*, i8** %current_node
	%_22 = bitcast i8* %_21 to i8***
	%_23 = load i8**, i8*** %_22
	%_24 = getelementptr i8*, i8** %_23, i32 3
	%_25 = load i8*, i8** %_24
	%_26 = bitcast i8* %_25 to i8* (i8*)*
	%_27 = call i8* %_26(i8* %_21)

	store i8* %_27, i8** %current_node

	br label %if_end_15
	if_end_15:

	br label %if_end_14
	if_end_14:

	br label %if_end_16
	if_then_14:

	%_28 = load i8*, i8** %current_node
	%_29 = bitcast i8* %_28 to i8***
	%_30 = load i8**, i8*** %_29
	%_31 = getelementptr i8*, i8** %_30, i32 8
	%_32 = load i8*, i8** %_31
	%_33 = bitcast i8* %_32 to i1 (i8*)*
	%_34 = call i1 %_33(i8* %_28)

	br i1 %_34, label %if_then_17, label %if_else_17
	if_else_17:
	store i1 0, i1* %cont

	br label %if_end_17
	if_then_17:

	%_35 = load i8*, i8** %current_node
	%_36 = bitcast i8* %_35 to i8***
	%_37 = load i8**, i8*** %_36
	%_38 = getelementptr i8*, i8** %_37, i32 4
	%_39 = load i8*, i8** %_38
	%_40 = bitcast i8* %_39 to i8* (i8*)*
	%_41 = call i8* %_40(i8* %_35)

	store i8* %_41, i8** %current_node

	br label %if_end_17
	if_end_17:

	br label %if_end_16
	if_end_16:
	br label %loop41
	loop43:
	%_42 = load i32, i32* %ifound
	ret i32 %_42
}

define i1 @Tree.Print(i8* %this) {

	%ntb = alloca i1
	%current_node = alloca i8*
	store i8* %this, i8** %current_node

	%_0 = bitcast i8* %this to i8***
	%_1 = load i8**, i8*** %_0
	%_2 = getelementptr i8*, i8** %_1, i32 19
	%_3 = load i8*, i8** %_2
	%_4 = bitcast i8* %_3 to i1 (i8*,i8*)*
	%_5 = load i8*, i8** %current_node
	%_6 = call i1 %_4(i8* %this, i8* %_5)

	store i1 %_6, i1* %ntb
	ret i1 1
}

define i1 @Tree.RecPrint(i8* %this, i8* %.node) {
	%node = alloca i8*
	store i8* %.node, i8** %node

	%ntb = alloca i1

	%_0 = load i8*, i8** %node
	%_1 = bitcast i8* %_0 to i8***
	%_2 = load i8**, i8*** %_1
	%_3 = getelementptr i8*, i8** %_2, i32 8
	%_4 = load i8*, i8** %_3
	%_5 = bitcast i8* %_4 to i1 (i8*)*
	%_6 = call i1 %_5(i8* %_0)

	br i1 %_6, label %if_then_18, label %if_else_18
	if_else_18:
	store i1 1, i1* %ntb

	br label %if_end_18
	if_then_18:

	%_7 = bitcast i8* %this to i8***
	%_8 = load i8**, i8*** %_7
	%_9 = getelementptr i8*, i8** %_8, i32 19
	%_10 = load i8*, i8** %_9
	%_11 = bitcast i8* %_10 to i1 (i8*,i8*)*

	%_12 = load i8*, i8** %node
	%_13 = bitcast i8* %_12 to i8***
	%_14 = load i8**, i8*** %_13
	%_15 = getelementptr i8*, i8** %_14, i32 4
	%_16 = load i8*, i8** %_15
	%_17 = bitcast i8* %_16 to i8* (i8*)*
	%_18 = call i8* %_17(i8* %_12)

	%_19 = call i1 %_11(i8* %this, i8* %_18)

	store i1 %_19, i1* %ntb

	br label %if_end_18
	if_end_18:

	%_20 = load i8*, i8** %node
	%_21 = bitcast i8* %_20 to i8***
	%_22 = load i8**, i8*** %_21
	%_23 = getelementptr i8*, i8** %_22, i32 5
	%_24 = load i8*, i8** %_23
	%_25 = bitcast i8* %_24 to i32 (i8*)*
	%_26 = call i32 %_25(i8* %_20)

	call void (i32) @print_int(i32 %_26)

	%_27 = load i8*, i8** %node
	%_28 = bitcast i8* %_27 to i8***
	%_29 = load i8**, i8*** %_28
	%_30 = getelementptr i8*, i8** %_29, i32 7
	%_31 = load i8*, i8** %_30
	%_32 = bitcast i8* %_31 to i1 (i8*)*
	%_33 = call i1 %_32(i8* %_27)

	br i1 %_33, label %if_then_19, label %if_else_19
	if_else_19:
	store i1 1, i1* %ntb

	br label %if_end_19
	if_then_19:

	%_34 = bitcast i8* %this to i8***
	%_35 = load i8**, i8*** %_34
	%_36 = getelementptr i8*, i8** %_35, i32 19
	%_37 = load i8*, i8** %_36
	%_38 = bitcast i8* %_37 to i1 (i8*,i8*)*

	%_39 = load i8*, i8** %node
	%_40 = bitcast i8* %_39 to i8***
	%_41 = load i8**, i8*** %_40
	%_42 = getelementptr i8*, i8** %_41, i32 3
	%_43 = load i8*, i8** %_42
	%_44 = bitcast i8* %_43 to i8* (i8*)*
	%_45 = call i8* %_44(i8* %_39)

	%_46 = call i1 %_38(i8* %this, i8* %_45)

	store i1 %_46, i1* %ntb

	br label %if_end_19
	if_end_19:
	ret i1 1
}

define i32 @Tree.accept(i8* %this, i8* %.v) {
	%v = alloca i8*
	store i8* %.v, i8** %v

	%nti = alloca i32
	call void (i32) @print_int(i32 333)

	%_0 = load i8*, i8** %v
	%_1 = bitcast i8* %_0 to i8***
	%_2 = load i8**, i8*** %_1
	%_3 = getelementptr i8*, i8** %_2, i32 0
	%_4 = load i8*, i8** %_3
	%_5 = bitcast i8* %_4 to i32 (i8*,i8*)*
	%_6 = call i32 %_5(i8* %_0, i8* %this)

	store i32 %_6, i32* %nti
	ret i32 0
}

define i32 @Visitor.visit(i8* %this, i8* %.n) {
	%n = alloca i8*
	store i8* %.n, i8** %n

	%nti = alloca i32

	%_0 = load i8*, i8** %n
	%_1 = bitcast i8* %_0 to i8***
	%_2 = load i8**, i8*** %_1
	%_3 = getelementptr i8*, i8** %_2, i32 7
	%_4 = load i8*, i8** %_3
	%_5 = bitcast i8* %_4 to i1 (i8*)*
	%_6 = call i1 %_5(i8* %_0)

	br i1 %_6, label %if_then_20, label %if_else_20
	if_else_20:
	store i32 0, i32* %nti

	br label %if_end_20
	if_then_20:

	%_7 = load i8*, i8** %n
	%_8 = bitcast i8* %_7 to i8***
	%_9 = load i8**, i8*** %_8
	%_10 = getelementptr i8*, i8** %_9, i32 3
	%_11 = load i8*, i8** %_10
	%_12 = bitcast i8* %_11 to i8* (i8*)*
	%_13 = call i8* %_12(i8* %_7)

	%_14 = getelementptr i8, i8* %this, i32 16
	%_15 = bitcast i8* %_14 to i8**
	store i8* %_13, i8** %_15

	%_16 = getelementptr i8, i8* %this, i32 16
	%_17 = bitcast i8* %_16 to i8**
	%_18 = load i8*, i8** %_17
	%_19 = bitcast i8* %_18 to i8***
	%_20 = load i8**, i8*** %_19
	%_21 = getelementptr i8*, i8** %_20, i32 20
	%_22 = load i8*, i8** %_21
	%_23 = bitcast i8* %_22 to i32 (i8*,i8*)*
	%_24 = call i32 %_23(i8* %_18, i8* %this)

	store i32 %_24, i32* %nti

	br label %if_end_20
	if_end_20:

	%_25 = load i8*, i8** %n
	%_26 = bitcast i8* %_25 to i8***
	%_27 = load i8**, i8*** %_26
	%_28 = getelementptr i8*, i8** %_27, i32 8
	%_29 = load i8*, i8** %_28
	%_30 = bitcast i8* %_29 to i1 (i8*)*
	%_31 = call i1 %_30(i8* %_25)

	br i1 %_31, label %if_then_21, label %if_else_21
	if_else_21:
	store i32 0, i32* %nti

	br label %if_end_21
	if_then_21:

	%_32 = load i8*, i8** %n
	%_33 = bitcast i8* %_32 to i8***
	%_34 = load i8**, i8*** %_33
	%_35 = getelementptr i8*, i8** %_34, i32 4
	%_36 = load i8*, i8** %_35
	%_37 = bitcast i8* %_36 to i8* (i8*)*
	%_38 = call i8* %_37(i8* %_32)

	%_39 = getelementptr i8, i8* %this, i32 8
	%_40 = bitcast i8* %_39 to i8**
	store i8* %_38, i8** %_40

	%_41 = getelementptr i8, i8* %this, i32 8
	%_42 = bitcast i8* %_41 to i8**
	%_43 = load i8*, i8** %_42
	%_44 = bitcast i8* %_43 to i8***
	%_45 = load i8**, i8*** %_44
	%_46 = getelementptr i8*, i8** %_45, i32 20
	%_47 = load i8*, i8** %_46
	%_48 = bitcast i8* %_47 to i32 (i8*,i8*)*
	%_49 = call i32 %_48(i8* %_43, i8* %this)

	store i32 %_49, i32* %nti

	br label %if_end_21
	if_end_21:
	ret i32 0
}

define i32 @MyVisitor.visit(i8* %this, i8* %.n) {
	%n = alloca i8*
	store i8* %.n, i8** %n

	%nti = alloca i32

	%_0 = load i8*, i8** %n
	%_1 = bitcast i8* %_0 to i8***
	%_2 = load i8**, i8*** %_1
	%_3 = getelementptr i8*, i8** %_2, i32 7
	%_4 = load i8*, i8** %_3
	%_5 = bitcast i8* %_4 to i1 (i8*)*
	%_6 = call i1 %_5(i8* %_0)

	br i1 %_6, label %if_then_22, label %if_else_22
	if_else_22:
	store i32 0, i32* %nti

	br label %if_end_22
	if_then_22:

	%_7 = load i8*, i8** %n
	%_8 = bitcast i8* %_7 to i8***
	%_9 = load i8**, i8*** %_8
	%_10 = getelementptr i8*, i8** %_9, i32 3
	%_11 = load i8*, i8** %_10
	%_12 = bitcast i8* %_11 to i8* (i8*)*
	%_13 = call i8* %_12(i8* %_7)

	%_14 = getelementptr i8, i8* %this, i32 16
	%_15 = bitcast i8* %_14 to i8**
	store i8* %_13, i8** %_15

	%_16 = getelementptr i8, i8* %this, i32 16
	%_17 = bitcast i8* %_16 to i8**
	%_18 = load i8*, i8** %_17
	%_19 = bitcast i8* %_18 to i8***
	%_20 = load i8**, i8*** %_19
	%_21 = getelementptr i8*, i8** %_20, i32 20
	%_22 = load i8*, i8** %_21
	%_23 = bitcast i8* %_22 to i32 (i8*,i8*)*
	%_24 = call i32 %_23(i8* %_18, i8* %this)

	store i32 %_24, i32* %nti

	br label %if_end_22
	if_end_22:

	%_25 = load i8*, i8** %n
	%_26 = bitcast i8* %_25 to i8***
	%_27 = load i8**, i8*** %_26
	%_28 = getelementptr i8*, i8** %_27, i32 5
	%_29 = load i8*, i8** %_28
	%_30 = bitcast i8* %_29 to i32 (i8*)*
	%_31 = call i32 %_30(i8* %_25)

	call void (i32) @print_int(i32 %_31)

	%_32 = load i8*, i8** %n
	%_33 = bitcast i8* %_32 to i8***
	%_34 = load i8**, i8*** %_33
	%_35 = getelementptr i8*, i8** %_34, i32 8
	%_36 = load i8*, i8** %_35
	%_37 = bitcast i8* %_36 to i1 (i8*)*
	%_38 = call i1 %_37(i8* %_32)

	br i1 %_38, label %if_then_23, label %if_else_23
	if_else_23:
	store i32 0, i32* %nti

	br label %if_end_23
	if_then_23:

	%_39 = load i8*, i8** %n
	%_40 = bitcast i8* %_39 to i8***
	%_41 = load i8**, i8*** %_40
	%_42 = getelementptr i8*, i8** %_41, i32 4
	%_43 = load i8*, i8** %_42
	%_44 = bitcast i8* %_43 to i8* (i8*)*
	%_45 = call i8* %_44(i8* %_39)

	%_46 = getelementptr i8, i8* %this, i32 8
	%_47 = bitcast i8* %_46 to i8**
	store i8* %_45, i8** %_47

	%_48 = getelementptr i8, i8* %this, i32 8
	%_49 = bitcast i8* %_48 to i8**
	%_50 = load i8*, i8** %_49
	%_51 = bitcast i8* %_50 to i8***
	%_52 = load i8**, i8*** %_51
	%_53 = getelementptr i8*, i8** %_52, i32 20
	%_54 = load i8*, i8** %_53
	%_55 = bitcast i8* %_54 to i32 (i8*,i8*)*
	%_56 = call i32 %_55(i8* %_50, i8* %this)

	store i32 %_56, i32* %nti

	br label %if_end_23
	if_end_23:
	ret i32 0
}
