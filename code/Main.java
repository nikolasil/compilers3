import syntaxtree.*;
import visitor.*;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.*;
import java.util.*;

public class Main {
    public static void main(String[] args) throws Exception {
        if (args.length < 1) {
            System.err.println("Usage: java Main <inputFiles>");

        }

        FileInputStream fis = null;
        for (int i = 0; i < args.length; i++) {
            try {
                System.out.println("\n - - - - - Checking file: " + args[i] + " - - - - - \n");
                fis = new FileInputStream(args[i]);
                MiniJavaParser parser = new MiniJavaParser(fis);

                Goal root = parser.Goal();

                System.err.println("Program parsed successfully.");
                SymbolTable st = new SymbolTable();
                Map<String, VTable> offsets = new LinkedHashMap<String, VTable>();

                FileWriter myWriter = new FileWriter(args[i].substring(0, args[i].length() - 5) + "2.ll");

                MyVisitor declarationST = new MyVisitor(st, offsets, myWriter);
                MyVisitor llvm = new MyVisitor(st, offsets, myWriter);

                root.accept(declarationST, null);
                System.out.println("\nllvm code creation Started");
                root.accept(llvm, null);
                myWriter.close();
            } catch (TypeCheckError ex) {
                System.out.println(ex.getMessage());
            } catch (ParseException ex) {
                System.out.println(ex.getMessage());
            } catch (FileNotFoundException ex) {
                System.err.println(ex.getMessage());
            } finally {
                try {
                    if (fis != null)
                        fis.close();
                } catch (IOException ex) {
                    System.err.println(ex.getMessage());
                }
            }
        }
    }
}

class TypeCheckError extends Exception {
    public TypeCheckError(String message) {
        super(message);
    }
}

class VTable {
    String name;
    Map<String, Integer> methods;
    Map<String, String> belongsTo;

    Map<String, Integer> variables;

    VTable(String n) {
        name = n;
        variables = new LinkedHashMap<String, Integer>();
        methods = new LinkedHashMap<String, Integer>();
        belongsTo = new LinkedHashMap<String, String>();
    }

    void addMethod(String mName, Integer offset, String belongs) {
        this.methods.put(mName, offset);
        this.belongsTo.put(mName, belongs);
    }

    void addVariable(String vName, Integer offset) {
        this.variables.put(vName, offset);
    }

    void print() {
        System.out.println(name);
        System.out.println("\t -- [Variables] --");
        if (this.variables.size() == 0)
            System.out.println("\tnone");
        else {
            for (String name : this.variables.keySet()) {
                System.out.println("\t" + this.variables.get(name) + " " + name);
            }
        }
        System.out.println("\n\t -- [Methods] --");
        if (this.methods.size() == 0)
            System.out.println("\tnone");
        else {
            for (String name : this.methods.keySet()) {
                System.out.println("\t" + this.methods.get(name) + " " + name);
            }
        }
    }
}

class SymbolTable {
    Map<String, ST_Class> classes;
    int state; // 0 = fill table , 1 = type check
    String location;

    SymbolTable() {
        classes = new LinkedHashMap<String, ST_Class>();
        state = 0;
    }

    void setState(int s) {
        this.state = s;
    }

    int getState() {
        return this.state;
    }

    void createOffsets(Map<String, VTable> offsets) {
        System.out.println("-- [START PRINTING OFFSETS] --");
        Map<String, ST_Class> visited = new LinkedHashMap<String, ST_Class>();
        String main = this.classes.keySet().iterator().next();
        // System.out.println(main);
        for (String name : this.classes.keySet()) {
            if (name.equals(main)) {
                VTable mainV = new VTable(main);
                mainV.addMethod("main", 0, name);
                offsets.put(name, mainV);
                continue;
            }
            if (visited.containsKey(name))
                continue;

            int offset_var = 0;
            int offset_func = 0;
            ST_Class C = this.classes.get(name);

            VTable prevTable = null;

            while (true) {
                String Cname = C.getName();
                if (visited.containsKey(Cname))
                    continue;
                System.out.println("-----------Class " + Cname + "-----------");

                VTable table = new VTable(Cname);

                offsets.put(Cname, table);

                Map<String, String> atr = C.getAtributes();
                System.out.println("---Variables---");
                for (String at : atr.keySet()) {
                    if (at.equals("this"))
                        continue;

                    System.out.println(Cname + "." + at + " : " + offset_var);
                    table.addVariable(at, offset_var);

                    if (atr.get(at).equals("int"))
                        offset_var += 4;
                    else if (atr.get(at).equals("boolean"))
                        offset_var++;
                    else
                        offset_var += 8;
                }
                if (C.getParent() != null) {
                    for (String parentVar : prevTable.variables.keySet()) {
                        if (!table.variables.containsKey(parentVar)) {
                            table.addVariable(parentVar, prevTable.variables.get(parentVar));
                        }
                    }
                }
                Map<String, ST_Method> meth = C.getMethods();
                System.out.println("---Methods---");
                for (String me : meth.keySet()) {
                    if (this.lookupSameMethodInParents(this, Cname, me) == 2) {
                        table.addMethod(me, prevTable.methods.get(me), Cname);
                        continue;
                    }
                    System.out.println(Cname + "." + me + " : " + offset_func);
                    table.addMethod(me, offset_func, Cname);
                    offset_func += 8;
                }
                if (C.getParent() != null) {
                    for (String parentMeth : prevTable.methods.keySet()) {
                        if (!table.methods.containsKey(parentMeth)) {
                            table.addMethod(parentMeth, prevTable.methods.get(parentMeth),
                                    prevTable.belongsTo.get(parentMeth));
                        }
                    }
                }
                visited.put(Cname, C);
                C = C.getChild();
                prevTable = table;
                if (C == null) {
                    prevTable = null;
                    break;
                }
            }
            System.out.println();
        }
        System.out.println("-- [END PRINTING OFFSETS] --");

    }

    int enter(String className, String classExtend) {
        if (this.getClass(className) == null) {
            if (classExtend == null) {
                this.classes.put(className, new ST_Class(className, null));
                return 0;
            }
            if (this.getClass(classExtend) == null) {
                // System.out.println(
                // "Error in class: " + className + " -- extend class: " + classExtend + " not
                // declared --");
                return 1;
            }
            this.classes.put(className, new ST_Class(className, this.getClass(classExtend)));
            return 2;
        }
        // System.out.println("Error in class: " + className + " -- double declaration
        // --");
        return 3;
    }

    int insertAtribute(String className, String atrName, String atrType) throws Exception {
        if (this.getClass(className) != null) {
            this.getClass(className).addAtribute(atrName, atrType);
            return 0;
        }
        System.out.println("Error in class: " + className + " -- not declared --");
        return 1;
    }

    int insertMethod(String className, String methName, String methType) throws Exception {
        if (this.getClass(className) != null) {
            this.getClass(className).addMethod(methName, methType);
            return 0;
        }
        System.out.println("Error in class: " + className + " -- not declared --");
        return 1;
    }

    int insertArgumentToMethod(String className, String methName, String argName, String argType) throws Exception {
        if (this.getClass(className) != null) {
            if (this.getClass(className).getMethod(methName) != null) {
                this.getClass(className).getMethod(methName).addArgument(argName, argType);
                return 0;
            }
        }
        return 1;
    }

    int insertBodyVariableToMethod(String className, String methName, String varName, String varType) throws Exception {
        if (this.getClass(className) != null) {
            if (this.getClass(className).getMethod(methName) != null) {
                this.getClass(className).getMethod(methName).addBodyVariable(varName, varType);
                return 0;
            }
        }
        return 1;
    }

    String lookup(String className, String methName, String varName) {
        String r = "";
        ST_Class C = this.getClass(className);
        if (C != null) {
            ST_Method M = C.getMethod(methName);
            if (M != null) {
                r = M.getBodyVariable(varName);
                if (!r.equals("")) {
                    location = "bodyVariable";
                    return r;
                }
                r = M.getArgument(varName);
                if (!r.equals("")) {
                    location = "argument";
                    return r;
                }

                ST_Class temp = C;
                while (temp != null) {
                    r = temp.getAtribute(varName);
                    if (!r.equals("")) {
                        location = "outside";
                        return r;
                    }

                    temp = temp.getParent();
                }
            }
        }
        location = "dontexists";
        return "";
    }

    ST_Method getMethod(String className, String methName) {
        ST_Class C = this.getClass(className);
        if (C != null) {
            ST_Method M = C.getMethod(methName);
            if (M != null)
                return M;
        }
        return null;
    }

    ST_Method lookupMethod(String className, String methName) {
        ST_Class temp = this.getClass(className);
        while (temp != null) {
            ST_Method M = temp.getMethod(methName);
            if (M != null)
                return M;
            temp = temp.getParent();
        }
        return null;
    }

    int lookupSameMethodInParents(SymbolTable ST, String className, String methName) {
        // System.out.println("lookupSameMethodInParents " + className + " " +
        // methName);

        ST_Method Meth = this.getClass(className).getMethod(methName);
        ST_Class temp = this.getClass(className).getParent();
        while (temp != null) {
            // System.out.println(temp.getName());
            ST_Method M = this.getMethod(temp.getName(), methName);
            if (M != null) {
                if (!M.getType().equals(Meth.getType())) {
                    // System.out.println("ERROR type overidden method in class " + temp.getName());
                    return 0;
                }
                LinkedList<String> Margs = new LinkedList<String>();
                Map<String, String> args = M.getArguments();
                for (String name : args.keySet()) {
                    Margs.add(args.get(name));
                    // System.out.println("arg " + args.get(name));
                }
                if (Meth.compareArgs(ST, Margs)) {
                    // System.out.println("Found overidden method in class " + temp.getName());
                    return 2;
                }
                // System.out.println("ERROR overidden method in class " + temp.getName());
                return 0;
            }
            temp = temp.getParent();
        }

        // System.out.println("Did not found overidden method");
        return 1;
    }

    ST_Class getClass(String className) {
        if (this.classes.containsKey(className))
            return this.classes.get(className);
        return null;
    }

    void print() {
        System.out.println("-- [START PRINTING SYMBOLTABLE] --");
        for (String name : this.classes.keySet()) {
            this.classes.get(name).print();
            System.out.println();
        }
        System.out.println("-- [END PRINTING SYMBOLTABLE] --");
    }

}

class ST_Class {
    String name;
    ST_Class parent;
    ST_Class child;

    Map<String, String> atributes;
    Map<String, ST_Method> methods;

    ST_Class(String n, ST_Class p) {
        this.name = n;
        this.parent = p;
        this.child = null;
        if (parent != null)
            parent.setChild(this);
        atributes = new LinkedHashMap<String, String>();
        methods = new LinkedHashMap<String, ST_Method>();
        this.atributes.put("this", this.name);
    }

    void setChild(ST_Class c) {
        this.child = c;
    }

    String getName() {
        return this.name;
    }

    ST_Class getChild() {
        return this.child;
    }

    ST_Class getParent() {
        return this.parent;
    }

    String getAtribute(String name) {
        if (this.atributes.containsKey(name))
            return this.atributes.get(name);
        return "";
    }

    Map<String, String> getAtributes() {
        return this.atributes;
    }

    ST_Method getMethod(String name) {
        if (this.methods.containsKey(name))
            return this.methods.get(name);
        return null;
    }

    Map<String, ST_Method> getMethods() {
        return this.methods;
    }

    int addAtribute(String atrName, String atrType) throws Exception {
        if (this.getAtribute(atrName) == "") {
            this.atributes.put(atrName, atrType);
            return 0;
        }
        throw new TypeCheckError(
                "[ERROR] in class atribute: " + this.name + "." + atrName + " -- double declaration --");
    }

    int addMethod(String methName, String methType) throws Exception {
        if (this.getMethod(methName) == null) {
            this.methods.put(methName, new ST_Method(methName, methType));
            return 0;
        }
        throw new TypeCheckError(
                "[ERROR] in class method: " + this.name + "." + methName + " -- double declaration --");
    }

    void print() {
        if (parent != null)
            System.out.print("class " + name + " parent: " + parent.getName());
        else
            System.out.print("class " + name + " parent: none");
        if (child != null)
            System.out.println(" child: " + child.getName());
        else
            System.out.println(" child: none");

        System.out.println("\t -- [Attributes] --");
        if (this.atributes.size() == 0)
            System.out.println("\tnone");
        else {
            for (String name : this.atributes.keySet()) {
                System.out.println("\t" + this.atributes.get(name) + " " + name);
            }
        }
        System.out.println("\n\t -- [Methods] --");
        if (this.methods.size() == 0)
            System.out.println("\tnone");
        else {
            for (String name : this.methods.keySet()) {
                System.out.print("\t");
                this.methods.get(name).print();
            }
        }
    }
}

class ST_Method {
    String name;
    String type;

    Map<String, String> arguments;
    Map<String, String> bodyVariables;

    ST_Method(String n, String t) {
        this.name = n;
        this.type = t;
        this.arguments = new LinkedHashMap<String, String>();
        this.bodyVariables = new LinkedHashMap<String, String>();
    }

    boolean compareArgs(SymbolTable ST, LinkedList<String> args) {
        if (args.size() != this.arguments.size())
            return false;
        // System.out.println("same size");
        int count = 0;
        for (String name1 : this.arguments.keySet()) {
            int i = 0;
            for (int num = 0; num < args.size(); num++) {
                if (i == count) {
                    // System.out.println(
                    // "name1=" + name1 + " value1=" + this.arguments.get(name1) + " name2=" +
                    // args.get(num));
                    String t = args.get(num);
                    ST_Class temp = ST.getClass(t);
                    if (temp != null) {
                        boolean flag = false;
                        while (temp != null) {
                            // System.out.println(temp.getName());
                            if (!this.arguments.get(name1).equals(t)) {
                                temp = temp.getParent();
                                if (temp == null)
                                    break;
                                t = temp.getName();
                            } else {
                                flag = true;
                                // System.out.println("true " + t);
                                break;
                            }
                        }
                        if (!flag)
                            return false;
                        break;

                    } else {
                        if (!this.arguments.get(name1).equals(t)) {
                            return false;
                        } else {
                            break;
                        }
                    }
                }
                i++;
            }
            count++;
        }
        return true;
    }

    String getName() {
        return this.name;
    }

    String getType() {
        return this.type;
    }

    String getArgument(String argName) {
        if (this.arguments.containsKey(argName))
            return this.arguments.get(argName);
        return "";
    }

    Map<String, String> getArguments() {
        return this.arguments;
    }

    String getBodyVariable(String varName) {
        if (this.bodyVariables.containsKey(varName))
            return this.bodyVariables.get(varName);
        return "";
    }

    int addArgument(String argName, String argType) throws Exception {
        if (this.getArgument(argName) == "") {
            this.arguments.put(argName, argType);
            return 0;
        }
        throw new TypeCheckError(
                "[ERROR] in method's arguments: " + this.name + "." + argName + " -- double declaration --");
    }

    int addBodyVariable(String varName, String varType) throws Exception {
        if (this.getBodyVariable(varName) == "") {
            if (this.getArgument(varName) == "") {
                this.bodyVariables.put(varName, varType);
                return 0;
            }
        }
        throw new TypeCheckError(
                "[ERROR] in method's bodyVariables : " + this.name + "." + varName + " -- double declaration --");

    }

    void print() {
        System.out.print(type + " " + name + "(");

        for (String name : this.arguments.keySet()) {
            System.out.print(this.arguments.get(name) + " " + name + ",");
        }
        System.out.println(")");
        System.out.print("\t\t\tbodyVariables: \n\t\t\t  ");
        for (String name : this.bodyVariables.keySet()) {
            System.out.print(this.bodyVariables.get(name) + " " + name + ",");
        }
        System.out.println("\n");
    }
}

class MyVisitor extends GJDepthFirst<String, String> {
    SymbolTable ST;
    Map<String, VTable> offsets;
    FileWriter myWriter;
    Integer register;
    Integer exp_res_;
    Integer if_else_;
    Integer if_then_;
    Integer if_end_;
    Integer oob_ok_;
    Integer oob_err_;

    MyVisitor(SymbolTable S, Map<String, VTable> o, FileWriter writer) {
        ST = S;
        offsets = o;
        myWriter = writer;
        register = 0;
        exp_res_ = 0;
        if_else_ = 0;
        if_then_ = 0;
        if_end_ = 0;
        oob_ok_ = 0;
        oob_err_ = 0;
    }

    String getBits(String k) {
        if (k.equals("boolean"))
            return "i1";
        else if (k.equals("true"))
            return "i1";
        else if (k.equals("false"))
            return "i1";
        else if (k.equals("int") || k.equals("times") || k.equals("plus") || k.equals("minus"))
            return "i32";
        else if (isInteger(k))
            return "i32";
        else if (k.equals("int[]"))
            return "i32*";
        else
            return "i8";
    }

    boolean isInteger(String s) {
        try {
            Integer.parseInt(s);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    public String visit(Goal n, String argu) throws Exception {
        // System.out.println("state is " + ST.getState());
        n.f0.accept(this, argu);
        n.f1.accept(this, argu);
        n.f2.accept(this, argu);

        if (ST.getState() == 1) {
            System.out.println("llvm code created Successfully\n");
        } else {
            ST.setState(1);
            ST.print();
            ST.createOffsets(offsets);
            for (String name : offsets.keySet()) {
                offsets.get(name).print();
                System.out.println();
            }
        }
        return null;

    }

    /**
     * f0 -> "class" f1 -> Identifier() f2 -> "{" f3 -> "public" f4 -> "static" f5
     * -> "void" f6 -> "main" f7 -> "(" f8 -> "String" f9 -> "[" f10 -> "]" f11 ->
     * Identifier() f12 -> ")" f13 -> "{" f14 -> ( VarDeclaration() )* f15 -> (
     * Statement() )* f16 -> "}" f17 -> "}"
     */
    @Override
    public String visit(MainClass n, String argu) throws Exception {
        if (ST.getState() == 0) {
            n.f0.accept(this, null); // "class"
            String classname = n.f1.accept(this, null);
            n.f2.accept(this, classname); // "{"
            n.f3.accept(this, classname); // "public"
            n.f4.accept(this, classname); // "static"
            n.f5.accept(this, classname); // "void"
            n.f6.accept(this, classname); // "main"

            n.f7.accept(this, classname); // "("
            n.f8.accept(this, classname); // "String"
            n.f9.accept(this, classname); // "["
            n.f10.accept(this, classname); // "]"

            if (ST.enter(classname, null) != 0)
                throw new TypeCheckError("[ERROR] Class: " + classname + " double declaration");

            String argumentName = n.f11.accept(this, classname); // argument name

            ST.insertMethod(classname, "main", "void"); // insert the main method
            ST.insertArgumentToMethod(classname, "main", argumentName, "String[]");
            // insert the argument to the main method

            n.f12.accept(this, classname); // ")"
            n.f13.accept(this, classname); // "{"
            n.f14.accept(this, classname + "->main");
            // visit VarDeclaration with className->method in order to know where this
            // variable will the be
            n.f15.accept(this, classname + "->main"); // Statements
            n.f16.accept(this, classname + "->main"); // "}"
            n.f17.accept(this, classname + "->main"); // "}"
        } else {
            n.f0.accept(this, null); // "class"
            String classname = n.f1.accept(this, null);
            // myWriter.write("@." + classname + "_vtable = global [0 x i8*] []\n");
            String first = offsets.keySet().iterator().next();
            for (String name : offsets.keySet()) {
                if (name == first)
                    myWriter.write("@." + name + "_vtable = global [0 x i8*] []\n");
                else {
                    myWriter.write("@." + name + "_vtable = global [" + offsets.get(name).methods.size() + " x i8*] [");
                    if (offsets.get(name).methods.size() > 0) {
                        int count = 0;
                        for (String methName : offsets.get(name).methods.keySet()) {
                            if (count > 0)
                                myWriter.write(",\n\t");
                            else
                                myWriter.write("\n\t");

                            ST_Method meth = ST.lookupMethod(name, methName);
                            myWriter.write("i8* bitcast (");
                            myWriter.write(getBits(meth.getType()));
                            myWriter.write(" (i8*");
                            for (String arg : meth.getArguments().keySet())
                                myWriter.write("," + getBits(meth.getArguments().get(arg)));
                            myWriter.write(")* @" + offsets.get(name).belongsTo.get(meth.getName()) + "."
                                    + meth.getName() + " to i8*)");
                            count++;
                        }

                        myWriter.write("\n]\n");
                    } else
                        myWriter.write("]\n");
                }
            }
            myWriter.write("\ndeclare i8* @calloc(i32, i32)\n");
            myWriter.write("declare i32 @printf(i8*, ...)\n");
            myWriter.write("declare void @exit(i32)\n");
            myWriter.write("\n@_cint = constant [4 x i8] c\"%d\\0a\\00\"\n");
            myWriter.write("@_cOOB = constant [15 x i8] c\"Out of bounds\\0a\\00\"\n");
            myWriter.write("@_cNSZ = constant [15 x i8] c\"Negative size\\0a\\00\"\n");
            myWriter.write("define void @print_int(i32 %i) {\n");
            myWriter.write("    %_str = bitcast [4 x i8]* @_cint to i8*\n");
            myWriter.write("    call i32 (i8*, ...) @printf(i8* %_str, i32 %i)\n");
            myWriter.write("    ret void\n");
            myWriter.write("}\n");
            myWriter.write("\ndefine void @throw_oob() {\n");
            myWriter.write("    %_str = bitcast [15 x i8]* @_cOOB to i8*\n");
            myWriter.write("    call i32 (i8*, ...) @printf(i8* %_str)\n");
            myWriter.write("    call void @exit(i32 1)\n");
            myWriter.write("    ret void\n");
            myWriter.write("}\n");
            myWriter.write("\ndefine void @throw_nsz() {\n");
            myWriter.write("    %_str = bitcast [15 x i8]* @_cNSZ to i8*\n");
            myWriter.write("    call i32 (i8*, ...) @printf(i8* %_str)\n");
            myWriter.write("    call void @exit(i32 1)\n");
            myWriter.write("    ret void\n");
            myWriter.write("}\n");
            myWriter.write("\ndefine void @throw_nsz() {\n");
            myWriter.write("    %_str = bitcast [15 x i8]* @_cNSZ to i8*\n");
            myWriter.write("    call i32 (i8*, ...) @printf(i8* %_str)\n");
            myWriter.write("    call void @exit(i32 1)\n");
            myWriter.write("    ret void\n");
            myWriter.write("}\n");
            myWriter.write("\n");

            n.f2.accept(this, classname); // "{"
            n.f3.accept(this, classname); // "public"
            n.f4.accept(this, classname); // "static"
            n.f5.accept(this, classname); // "void"
            n.f6.accept(this, classname); // "main"

            n.f7.accept(this, classname); // "("
            n.f8.accept(this, classname); // "String"
            n.f9.accept(this, classname); // "["
            n.f10.accept(this, classname); // "]"

            String argumentName = n.f11.accept(this, classname); // argument name

            n.f12.accept(this, classname); // ")"
            n.f13.accept(this, classname); // "{"
            myWriter.write("define i32 @main() {\n");

            n.f14.accept(this, classname + "->main");
            // visit VarDeclaration with className->method in order to know where this
            // variable will the be
            n.f15.accept(this, classname + "->main"); // Statements
            n.f16.accept(this, classname + "->main"); // "}"
            n.f17.accept(this, classname + "->main"); // "}

            myWriter.write("\tret i32 0\n}\n");
        }
        return null;
    }

    /**
     * f0 -> "class" f1 -> Identifier() f2 -> "{" f3 -> ( VarDeclaration() )* f4 ->
     * ( MethodDeclaration() )* f5 -> "}"
     */
    @Override
    public String visit(ClassDeclaration n, String argu) throws Exception {
        if (ST.getState() == 0) {
            n.f0.accept(this, null); // "class"
            String classname = n.f1.accept(this, null);
            if (ST.enter(classname, null) != 0)
                throw new TypeCheckError("[ERROR] Class: " + classname + " double declaration");

            n.f2.accept(this, classname); // "{"
            n.f3.accept(this, classname); // variables
            n.f4.accept(this, classname); // methods
            n.f5.accept(this, classname); // "}"
        } else {
            n.f0.accept(this, null); // "class"
            String classname = n.f1.accept(this, null);
            n.f2.accept(this, classname); // "{"
            n.f3.accept(this, classname); // variables
            n.f4.accept(this, classname); // methods
            n.f5.accept(this, classname); // "}"
        }
        return null;
    }

    /**
     * f0 -> "class" f1 -> Identifier() f2 -> "extends" f3 -> Identifier() f4 -> "{"
     * f5 -> ( VarDeclaration() )* f6 -> ( MethodDeclaration() )* f7 -> "}"
     */
    @Override
    public String visit(ClassExtendsDeclaration n, String argu) throws Exception {
        if (ST.getState() == 0) {
            // System.out.println("ClassExtendsDeclaration");
            n.f0.accept(this, null); // "class"
            String classname = n.f1.accept(this, null);
            n.f2.accept(this, classname); // "extends"
            String parent = n.f3.accept(this, classname);

            if (ST.enter(classname, parent) != 2)
                throw new TypeCheckError("[ERROR] Class: " + classname + " double declaration");

            n.f4.accept(this, classname); // "{"
            n.f5.accept(this, classname); // variables
            n.f6.accept(this, classname); // methods
            n.f7.accept(this, classname); // "}"

            // ST.print();
        } else {
            n.f0.accept(this, null); // "class"
            String classname = n.f1.accept(this, null);
            n.f2.accept(this, classname); // "extends"
            String parent = n.f3.accept(this, classname);
            n.f4.accept(this, classname); // "{"
            n.f5.accept(this, classname); // variables
            n.f6.accept(this, classname); // methods
            n.f7.accept(this, classname); // "}"
        }
        return null;
    }

    /**
     * f0 -> Type() f1 -> Identifier() f2 -> ";"
     */
    @Override
    public String visit(VarDeclaration n, String argu) throws Exception {
        if (ST.getState() == 0) {
            String type = n.f0.accept(this, argu); // argument name
            String name = n.f1.accept(this, argu); // argument name

            String[] scope = argu.split("->");

            if (scope.length == 1) {
                // the variables will be in a class
                // System.out.println("In class with name [" + argu + "] there is a variable: "
                // + type + " " + name);
                ST.insertAtribute(argu, name, type);

            } else if (scope.length == 2) {
                // the variables will be in a methods class
                String classname = "";
                String methname = "";
                int count = 1;
                for (int i = 0; i < scope.length; i++) {
                    if (count == 1)
                        classname = scope[i];
                    else
                        methname = scope[i];

                    if (scope[i].length() != 0)
                        count = 2;
                }
                // System.out.println("In class with name [" + classname + "] in method [" +
                // methname
                // + "] there is a variable: " + type + " " + name);
                ST.insertBodyVariableToMethod(classname, methname, name, type);

            }

            n.f2.accept(this, argu); // ";"
        } else {
            String[] scope = argu.split("->");
            if (scope.length == 2) {
                String type = n.f0.accept(this, argu); // argument name
                String name = n.f1.accept(this, argu); // argument name
                myWriter.write("\t" + "%" + name + " = alloca " + getBits(type) + "\n");
            }
        }
        return null;
    }

    /**
     * f0 -> "public" f1 -> Type() f2 -> Identifier() f3 -> "(" f4 -> (
     * FormalParameterList() )? f5 -> ")" f6 -> "{" f7 -> ( VarDeclaration() )* f8
     * -> ( Statement() )* f9 -> "return" f10 -> Expression() f11 -> ";" f12 -> "}"
     */
    @Override
    public String visit(MethodDeclaration n, String argu) throws Exception {
        if (ST.getState() == 0) {
            n.f0.accept(this, argu); // "public"
            String myType = n.f1.accept(this, argu); // method type
            String myName = n.f2.accept(this, argu); // method name
            ST.insertMethod(argu, myName, myType);

            n.f3.accept(this, argu); // "("

            // the argument list
            String argumentList = n.f4.present() ? n.f4.accept(this, argu) : "";

            n.f5.accept(this, argu); // ")"
            n.f6.accept(this, argu); // "{"

            String[] arguments = argumentList.split(",");
            for (String arg : arguments) {
                String[] a = arg.split("\\s");
                String aType = "";
                String aName = "";
                int count = 1;
                for (int i = 0; i < a.length; i++) {
                    if (count == 1)
                        aType = a[i];
                    else
                        aName = a[i];

                    if (a[i].length() != 0)
                        count = 2;
                }
                // System.out.println("why??");
                if (!aName.equals("") && !aType.equals(""))
                    ST.insertArgumentToMethod(argu, myName, aName, aType);
            }
            // System.out.println("why 2 ??");

            n.f7.accept(this, argu + "->" + myName); // variables
            n.f8.accept(this, argu + "->" + myName); // statements
            n.f9.accept(this, argu + "->" + myName); // "return"
            n.f10.accept(this, argu + "->" + myName); // expresion
            n.f11.accept(this, argu + "->" + myName); // ";"
            n.f12.accept(this, argu + "->" + myName); // "}"
        } else {
            register = 0;
            exp_res_ = 0;
            if_else_ = 0;
            if_then_ = 0;
            if_end_ = 0;
            oob_ok_ = 0;
            oob_err_ = 0;
            n.f0.accept(this, argu); // "public"
            String myType = n.f1.accept(this, argu); // method type
            String myName = n.f2.accept(this, argu); // method name
            myWriter.write("\ndefine " + getBits(myType) + " @" + argu + "." + myName + "(i8* %this");
            n.f3.accept(this, argu); // "("

            String argumentList = n.f4.present() ? n.f4.accept(this, argu) : "";
            String[] arguments = argumentList.split(",");
            for (String arg : arguments) {
                String[] a = arg.split("\\s");
                String aType = "";
                String aName = "";
                int count = 1;
                for (int i = 0; i < a.length; i++) {
                    if (count == 1)
                        aType = a[i];
                    else
                        aName = a[i];

                    if (a[i].length() != 0)
                        count = 2;
                }

                if (!aName.equals("") && !aType.equals(""))
                    myWriter.write(", " + getBits(aType) + " %." + aName);
            }
            myWriter.write(") {");
            for (String arg : arguments) {
                String[] a = arg.split("\\s");
                String aType = "";
                String aName = "";
                int count = 1;
                for (int i = 0; i < a.length; i++) {
                    if (count == 1)
                        aType = a[i];
                    else
                        aName = a[i];

                    if (a[i].length() != 0)
                        count = 2;
                }

                if (!aName.equals("") && !aType.equals("")) {
                    myWriter.write("\n\t%" + aName + " alloca " + getBits(aType));
                    myWriter.write(
                            "\n\tstore " + getBits(aType) + " %." + aName + ", " + getBits(aType) + "* %" + aName);
                }
            }
            myWriter.write("\n\n");
            n.f5.accept(this, argu); // ")"
            n.f6.accept(this, argu); // "{"
            n.f7.accept(this, argu + "->" + myName); // variables
            n.f8.accept(this, argu + "->" + myName); // statements
            n.f9.accept(this, argu + "->" + myName); // "return"
            String r = n.f10.accept(this, argu + "->" + myName); // expresion
            String rType = ST.lookup(argu, myName, r);

            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                myWriter.write("\tret " + getBits(myType) + " %" + r + "\n");
            } else if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(argu).variables.get(r) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(rType) + "*\n");
                myWriter.write("\t%_" + register++ + " = load " + getBits(rType) + ", " + getBits(rType) + "* %_"
                        + (register - 2) + "\n");
                myWriter.write("\tret " + getBits(myType) + " %_" + (register - 1) + "\n");
            } else if (r.equals("times") || r.equals("plus") || r.equals("minus") || r.equals("&&")) {
                myWriter.write("\tret " + getBits(myType) + " %_" + (register - 1) + "\n");
            } else {
                myWriter.write("\tret " + getBits(myType) + " " + r + "\n");
            }
            n.f11.accept(this, argu + "->" + myName); // ";"
            n.f12.accept(this, argu + "->" + myName); // "}"
            myWriter.write("}\n");
        }
        return null;
    }

    /**
     * f0 -> FormalParameter() f1 -> FormalParameterTail()
     */
    @Override
    public String visit(FormalParameterList n, String argu) throws Exception {
        String ret = n.f0.accept(this, null);

        if (n.f1 != null)
            ret += n.f1.accept(this, null);

        return ret;
    }

    /**
     * f0 -> FormalParameter() f1 -> FormalParameterTail()
     */
    public String visit(FormalParameterTerm n, String argu) throws Exception {
        return n.f1.accept(this, argu);
    }

    /**
     * f0 -> "," f1 -> FormalParameter()
     */
    @Override
    public String visit(FormalParameterTail n, String argu) throws Exception {
        String ret = "";
        for (Node node : n.f0.nodes)
            ret += ", " + node.accept(this, null);

        return ret;
    }

    /**
     * f0 -> Type() f1 -> Identifier()
     */
    @Override
    public String visit(FormalParameter n, String argu) throws Exception {
        if (ST.getState() == 1) {
            String type = n.f0.accept(this, null);
            String name = n.f1.accept(this, null); // method name

            // System.out.println("type:" + type + " exists");
            return type + " " + name;
        } else {
            String type = n.f0.accept(this, null);
            String name = n.f1.accept(this, null); // method name
            return type + " " + name;
        }
    }

    /**
     * f0 -> "System.out.println" f1 -> "(" f2 -> Expression() f3 -> ")" f4 -> ";"
     */
    public String visit(PrintStatement n, String argu) throws Exception {
        if (ST.getState() == 1) {

            return null;
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            n.f4.accept(this, argu);
            return null;

        }

    }

    /**
     * f0 -> PrimaryExpression() f1 -> "." f2 -> "length"
     */
    public String visit(ArrayLength n, String argu) throws Exception {
        if (ST.getState() == 1) {
            return "int";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return null;

        }
    }

    /**
     * f0 -> ArrayType() | BooleanType() | IntegerType() | Identifier()
     */
    public String visit(Type n, String argu) throws Exception {
        return n.f0.accept(this, argu);
    }

    /**
     * f0 -> IntegerLiteral() | TrueLiteral() | FalseLiteral() | Identifier() |
     * ThisExpression() | ArrayAllocationExpression() | AllocationExpression() |
     * NotExpression() | BracketExpression()
     */
    public String visit(PrimaryExpression n, String argu) throws Exception {
        return n.f0.accept(this, argu);
    }

    /**
     * f0 -> "(" f1 -> Expression() f2 -> ")"
     */
    public String visit(BracketExpression n, String argu) throws Exception {
        if (ST.getState() == 1) {
            n.f0.accept(this, argu);
            String a = n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return a;
        } else {
            return null;
        }
    }

    /**
     * f0 -> <INTEGER_LITERAL>
     */
    public String visit(IntegerLiteral n, String argu) throws Exception {
        return n.f0.toString();
    }

    /**
     * f0 -> "true"
     */
    public String visit(TrueLiteral n, String argu) throws Exception {
        n.f0.accept(this, argu);
        return "true";
    }

    /**
     * f0 -> "false"
     */
    public String visit(FalseLiteral n, String argu) throws Exception {
        n.f0.accept(this, argu);
        return "false";
    }

    /**
     * f0 -> <IDENTIFIER>
     */
    public String visit(Identifier n, String argu) throws Exception {
        String a = n.f0.toString();
        return a;
    }

    /**
     * f0 -> Identifier() f1 -> "=" f2 -> Expression() f3 -> ";"
     */
    public String visit(AssignmentStatement n, String argu) throws Exception {
        // System.out.println("AssignmentStatement");
        if (ST.getState() == 1) {

            String identifier = n.f0.accept(this, argu);
            String[] scope = argu.split("->");

            String idType = ST.lookup(scope[0], scope[1], identifier);
            boolean leftPart = true;
            if (!(ST.location.equals("bodyVariable") || ST.location.equals("argument"))) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType) + "*\n");
            } else {
                leftPart = false;
            }
            n.f1.accept(this, argu);
            String expr = n.f2.accept(this, argu);
            String exprType = ST.lookup(scope[0], scope[1], expr);
            boolean rightPart = true;
            if (ST.location.equals("dontexists")) {
                rightPart = false;
            } else {
                myWriter.write("\t%_" + register++ + " = load " + getBits(exprType) + ", " + getBits(exprType) + "* %"
                        + expr + "\n");
            }
            if (leftPart) {
                if (rightPart)
                    myWriter.write("\tstore " + getBits(exprType) + " %_" + (register - 1) + ", " + getBits(idType)
                            + "* %_" + (register - 2) + "\n");
                else {
                    if (expr.equals("true"))
                        myWriter.write("\tstore " + getBits(expr) + " " + 1 + ", " + getBits(idType) + "* %_"
                                + (register - 1) + "\n");
                    else if (expr.equals("false"))
                        myWriter.write("\tstore " + getBits(expr) + " " + 0 + ", " + getBits(idType) + "* %_"
                                + (register - 1) + "\n");
                    else if (expr.equals("times") || expr.equals("plus") || expr.equals("minus"))
                        myWriter.write("\tstore " + getBits(expr) + " %_" + (register - 1) + ", " + getBits(idType)
                                + "* %_" + (register - 3) + "\n");
                }
            } else {
                if (rightPart)
                    myWriter.write("\tstore " + getBits(exprType) + " %_" + (register - 1) + ", " + getBits(idType)
                            + "* %" + identifier + "\n");
                else {
                    if (expr.equals("true"))
                        myWriter.write("\tstore " + getBits(expr) + " " + 1 + ", " + getBits(idType) + "* %"
                                + identifier + "\n");
                    else if (expr.equals("false"))
                        myWriter.write("\tstore " + getBits(expr) + " " + 0 + ", " + getBits(idType) + "* %"
                                + identifier + "\n");
                    else if (expr.equals("times") || expr.equals("plus") || expr.equals("minus"))
                        myWriter.write("\tstore " + getBits(expr) + " %_" + (register - 1) + ", " + getBits(idType)
                                + "* %" + identifier + "\n");
                }
            }

            n.f3.accept(this, argu);
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
        }
        return null;
    }

    /**
     * f0 -> Identifier() f1 -> "[" f2 -> Expression() f3 -> "]" f4 -> "=" f5 ->
     * Expression() f6 -> ";"
     */
    public String visit(ArrayAssignmentStatement n, String argu) throws Exception {
        // System.out.println("ArrayAssignmentStatement");
        if (ST.getState() == 1) {
            String[] scope = argu.split("->");

            String identifier = n.f0.accept(this, argu);
            String idType = ST.lookup(scope[0], scope[1], identifier);
            Integer leftPart = 0;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                leftPart = 0;
                myWriter.write("\n\t%_" + register++ + " = load i32*, i32** %" + identifier + "\n");
                myWriter.write("\t%_" + register++ + " = load i32, i32* %_" + (register - 2) + "\n");
            } else {
                leftPart = 1;
            }
            n.f1.accept(this, argu);
            String insideBrac = n.f2.accept(this, argu);
            String insideBracType = ST.lookup(scope[0], scope[1], insideBrac);
            Integer insideBracPart = 0;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                insideBracPart = 0;
            } else if (ST.location.equals("outside")) {
                insideBracPart = 1;
            } else if (insideBrac.equals("times") || insideBrac.equals("plus") || insideBrac.equals("minus")) {
                insideBracPart = 2;
            } else {
                insideBracPart = 3;
                myWriter.write("\t%_" + register++ + " = icmp sge i32 " + insideBrac + ", 0" + "\n");
                myWriter.write("\t%_" + register++ + " = icmp slt i32 " + insideBrac + ", %_" + (register - 3) + "\n");
                myWriter.write("\t%_" + register++ + " = and i1 %_" + (register - 3) + ", %_" + (register - 2) + "\n");
                myWriter.write("\tbr i1 %_" + (register - 1) + ", label %oob_ok_" + oob_ok_++ + ", label %oob_err_"
                        + oob_err_++ + "\n");
                myWriter.write("\n\toob_err_" + (oob_err_ - 1) + ":\n");
                myWriter.write("\tcall void @throw_oob()\n");
                myWriter.write("\tbr label %oob_ok_" + (oob_ok_ - 1) + "\n");
                myWriter.write("\n\toob_ok_" + (oob_ok_ - 1) + ":\n");
                myWriter.write("\t%_" + register++ + " = add i32 1, " + insideBrac + "\n");
                myWriter.write("\t%_" + register++ + " = getelementptr i32 , i32* %_" + (register - 7) + ", i32 %_"
                        + (register - 2) + "\n");
            }

            n.f3.accept(this, argu);
            n.f4.accept(this, argu);

            String expr = n.f5.accept(this, argu);
            String exprType = ST.lookup(scope[0], scope[1], expr);
            Integer rightPart = 0;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                rightPart = 0;
            } else if (ST.location.equals("outside")) {
                rightPart = 1;
            } else if (insideBrac.equals("times") || insideBrac.equals("plus") || insideBrac.equals("minus")) {
                rightPart = 2;
            } else {
                rightPart = 3;
                myWriter.write("\tstore i32 " + expr + ", i32* %_" + (register - 1) + "\n\n");
            }
            n.f6.accept(this, argu);
            return null;
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            n.f4.accept(this, argu);
            n.f5.accept(this, argu);
            n.f6.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "[" f2 -> PrimaryExpression() f3 -> "]"
     */
    public String visit(ArrayLookup n, String argu) throws Exception {
        // System.out.println("ArrayLookup");
        if (ST.getState() == 1) {

            return "int";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> "if" f1 -> "(" f2 -> Expression() f3 -> ")" f4 -> Statement() f5 ->
     * "else" f6 -> Statement()
     */
    public String visit(IfStatement n, String argu) throws Exception {
        // System.out.println("IF");
        if (ST.getState() == 1) {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            myWriter.write("\tbr i1 %_" + (register - 1) + ", label %if_then_" + if_then_++ + ", label %if_else_"
                    + if_else_++ + "\n");
            myWriter.write("\tif_else_" + (if_else_ - 1) + ":\n");

            n.f6.accept(this, argu);
            myWriter.write("\n\tbr label %if_end_" + if_end_++ + "\n");
            n.f5.accept(this, argu);
            myWriter.write("\tif_then_" + (if_then_ - 1) + ":\n");
            n.f4.accept(this, argu);
            myWriter.write("\n\tbr label %if_end_" + (if_end_ - 1) + "\n");
            myWriter.write("\tif_end_" + (if_end_ - 1) + ":\n");

            return null;
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            n.f4.accept(this, argu);
            n.f5.accept(this, argu);
            n.f6.accept(this, argu);
            return null;

        }
    }

    /**
     * f0 -> "while" f1 -> "(" f2 -> Expression() f3 -> ")" f4 -> Statement()
     */
    public String visit(WhileStatement n, String argu) throws Exception {
        // System.out.println("WHILE");
        if (ST.getState() == 1) {

            return null;
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            n.f4.accept(this, argu);
            return null;

        }
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "<" f2 -> PrimaryExpression()
     */
    public String visit(CompareExpression n, String argu) throws Exception {
        // System.out.println("compare");
        if (ST.getState() == 1) {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return "return boolean";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "." f2 -> Identifier() f3 -> "(" f4 -> (
     * ExpressionList() )? f5 -> ")"
     */
    public String visit(MessageSend n, String argu) throws Exception {
        if (ST.getState() == 1) {

            return null;
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            n.f4.accept(this, argu);
            n.f5.accept(this, argu);

            return null;
        }
    }

    /**
     * f0 -> Expression() f1 -> ExpressionTail()
     */
    public String visit(ExpressionList n, String argu) throws Exception {
        return n.f0.accept(this, argu) + n.f1.accept(this, argu);
    }

    /**
     * f0 -> ( ExpressionTerm() )*
     */
    public String visit(ExpressionTail n, String argu) throws Exception {
        NodeListOptional args = n.f0;
        String list = "";
        // System.out.println("size =" + args.size());
        for (int i = 0; i < args.size(); i++) {
            ExpressionTerm variable = (ExpressionTerm) args.elementAt(i);
            String a = variable.f1.accept(this, argu);
            // System.out.println("var= " + a);
            list += "," + a;
        }

        return list;
    }

    /**
     * f0 -> "," f1 -> Expression()
     */
    public String visit(ExpressionTerm n, String argu) throws Exception {
        // n.f0.accept(this, argu);
        return n.f1.accept(this, argu);
    }

    /**
     * f0 -> "this"
     */
    public String visit(ThisExpression n, String argu) throws Exception {
        String t = n.f0.accept(this, argu);
        return "this";
    }

    /**
     * f0 -> "!" f1 -> PrimaryExpression()
     */
    public String visit(NotExpression n, String argu) throws Exception {
        // System.out.println("Not");
        if (ST.getState() == 1) {

            return "return boolean";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "+" f2 -> PrimaryExpression()
     */
    public String visit(PlusExpression n, String argu) throws Exception {
        if (ST.getState() == 1) {
            String[] scope = argu.split("->");
            String identifier1 = n.f0.accept(this, argu);
            String idType1 = ST.lookup(scope[0], scope[1], identifier1);
            boolean isLiteral1 = false;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType1) + ", " + getBits(idType1) + "* %"
                        + identifier1 + "\n");
            } else if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier1) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType1) + "*\n");
            } else {
                System.out.println("is literal");
                isLiteral1 = true;
            }
            n.f1.accept(this, argu);
            String identifier2 = n.f2.accept(this, argu);
            String idType2 = ST.lookup(scope[0], scope[1], identifier2);
            boolean wasOutside2 = false;
            boolean isLiteral2 = false;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType2) + ", " + getBits(idType2) + "* %"
                        + identifier2 + "\n");
            } else if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier2) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType2) + "*\n");
                wasOutside2 = true;
            } else {
                isLiteral2 = true;
            }

            if (isLiteral1 && !isLiteral2)
                myWriter.write("\t%_" + register++ + " = add i32 " + identifier1 + ", %_" + (register - 2) + "\n");
            else if (!isLiteral1 && isLiteral2)
                myWriter.write("\t%_" + register++ + " = add i32 %_" + (register - 2) + ", " + identifier2 + "\n");
            else if (isLiteral1 && isLiteral2)
                myWriter.write("\t%_" + register++ + " = add i32 " + identifier1 + ", " + identifier2 + "\n");
            else {
                if (wasOutside2)
                    myWriter.write(
                            "\t%_" + register++ + " = add i32 %_" + (register - 4) + ", %_" + (register - 2) + "\n");
                else
                    myWriter.write(
                            "\t%_" + register++ + " = add i32 %_" + (register - 3) + ", %_" + (register - 2) + "\n");

            }
            return "plus";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "-" f2 -> PrimaryExpression()
     */
    public String visit(MinusExpression n, String argu) throws Exception {
        if (ST.getState() == 1) {

            String[] scope = argu.split("->");
            String identifier1 = n.f0.accept(this, argu);
            String idType1 = ST.lookup(scope[0], scope[1], identifier1);
            boolean isLiteral1 = false;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType1) + ", " + getBits(idType1) + "* %"
                        + identifier1 + "\n");
            } else if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier1) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType1) + "*\n");
            } else {
                System.out.println("is literal");
                isLiteral1 = true;
            }
            n.f1.accept(this, argu);
            String identifier2 = n.f2.accept(this, argu);
            String idType2 = ST.lookup(scope[0], scope[1], identifier2);
            boolean wasOutside2 = false;
            boolean isLiteral2 = false;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType2) + ", " + getBits(idType2) + "* %"
                        + identifier2 + "\n");
            } else if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier2) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType2) + "*\n");
                wasOutside2 = true;
            } else {
                isLiteral2 = true;
            }

            if (isLiteral1 && !isLiteral2)
                myWriter.write("\t%_" + register++ + " = sub i32 " + identifier1 + ", %_" + (register - 2) + "\n");
            else if (!isLiteral1 && isLiteral2)
                myWriter.write("\t%_" + register++ + " = sub i32 %_" + (register - 2) + ", " + identifier2 + "\n");
            else if (isLiteral1 && isLiteral2)
                myWriter.write("\t%_" + register++ + " = sub i32 " + identifier1 + ", " + identifier2 + "\n");
            else {
                if (wasOutside2)
                    myWriter.write(
                            "\t%_" + register++ + " = sub i32 %_" + (register - 4) + ", %_" + (register - 2) + "\n");
                else
                    myWriter.write(
                            "\t%_" + register++ + " = sub i32 %_" + (register - 3) + ", %_" + (register - 2) + "\n");

            }
            return "minus";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "*" f2 -> PrimaryExpression()
     */
    public String visit(TimesExpression n, String argu) throws Exception {
        if (ST.getState() == 1) {
            String[] scope = argu.split("->");
            String identifier1 = n.f0.accept(this, argu);
            String idType1 = ST.lookup(scope[0], scope[1], identifier1);
            boolean isLiteral1 = false;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType1) + ", " + getBits(idType1) + "* %"
                        + identifier1 + "\n");
            } else if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier1) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType1) + "*\n");
            } else {
                System.out.println("is literal");
                isLiteral1 = true;
            }
            n.f1.accept(this, argu);
            String identifier2 = n.f2.accept(this, argu);
            String idType2 = ST.lookup(scope[0], scope[1], identifier2);
            boolean wasOutside2 = false;
            boolean isLiteral2 = false;
            if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType2) + ", " + getBits(idType2) + "* %"
                        + identifier2 + "\n");
            } else if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier2) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType2) + "*\n");
                wasOutside2 = true;
            } else {
                isLiteral2 = true;
            }

            if (isLiteral1 && !isLiteral2)
                myWriter.write("\t%_" + register++ + " = mul i32 " + identifier1 + ", %_" + (register - 2) + "\n");
            else if (!isLiteral1 && isLiteral2)
                myWriter.write("\t%_" + register++ + " = mul i32 %_" + (register - 2) + ", " + identifier2 + "\n");
            else if (isLiteral1 && isLiteral2)
                myWriter.write("\t%_" + register++ + " = mul i32 " + identifier1 + ", " + identifier2 + "\n");
            else {
                if (wasOutside2)
                    myWriter.write(
                            "\t%_" + register++ + " = mul i32 %_" + (register - 4) + ", %_" + (register - 2) + "\n");
                else
                    myWriter.write(
                            "\t%_" + register++ + " = mul i32 %_" + (register - 3) + ", %_" + (register - 2) + "\n");

            }
            return "times";
        } else

        {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> PrimaryExpression() f1 -> "&&" f2 -> PrimaryExpression()
     */
    public String visit(AndExpression n, String argu) throws Exception {
        if (ST.getState() == 1) {
            String[] scope = argu.split("->");
            String identifier1 = n.f0.accept(this, argu);
            String idType1 = ST.lookup(scope[0], scope[1], identifier1);
            Integer part1 = 0;

            if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier1) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType1) + "*\n");
            } else if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                part1 = 1;
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType1) + ", " + getBits(idType1) + "* %"
                        + identifier1 + "\n");
            } else if (ST.location.equals("dontexists")) {
                part1 = 2;
                myWriter.write("\tdontexists\n");
            }
            myWriter.write("\tbr i1 %_" + (register - 1) + ", label %exp_res_" + (exp_res_ + 1) + ", label %exp_res_"
                    + exp_res_++ + "\n\n");

            myWriter.write("\texp_res_" + (exp_res_ - 1) + ":\n");
            myWriter.write("\tbr label %exp_res__" + (exp_res_ + 2) + "\n\n");

            myWriter.write("\texp_res_" + exp_res_++ + ":\n");

            n.f1.accept(this, argu);
            String identifier2 = n.f2.accept(this, argu);
            String idType2 = ST.lookup(scope[0], scope[1], identifier2);
            Integer part2 = 0;

            if (ST.location.equals("outside")) {
                myWriter.write("\t%_" + register++ + " = getelementptr i8, i8* %this, i32 "
                        + (offsets.get(scope[0]).variables.get(identifier2) + 8) + "\n");
                myWriter.write(
                        "\t%_" + register++ + " = bitcast i8* %_" + (register - 2) + " to " + getBits(idType2) + "*\n");
            } else if (ST.location.equals("bodyVariable") || ST.location.equals("argument")) {
                part1 = 1;
                myWriter.write("\t%_" + register++ + " = load " + getBits(idType2) + ", " + getBits(idType2) + "* %"
                        + identifier2 + "\n");
            } else if (ST.location.equals("dontexists")) {
                part1 = 2;
                myWriter.write("\tdontexists\n");
            }
            myWriter.write("\tbr label %exp_res_" + exp_res_ + "\n\n");

            myWriter.write("\texp_res_" + exp_res_++ + ":\n");
            myWriter.write("\tbr label %exp_res_" + exp_res_ + "\n\n");
            myWriter.write("\texp_res_" + exp_res_ + ":\n");
            myWriter.write("\t%_" + register++ + " = phi i1 [ 0, %exp_res_" + (exp_res_ - 3) + " ], [ %_"
                    + (register - 2) + ", %exp_res_" + (exp_res_ - 1) + " ]" + "\n");

            return "&&";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> "new" f1 -> "int" f2 -> "[" f3 -> Expression() f4 -> "]"
     */
    public String visit(ArrayAllocationExpression n, String argu) throws Exception {
        if (ST.getState() == 1) {

            return "return int[]";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            n.f4.accept(this, argu);
            return null;
        }
    }

    /**
     * f0 -> "new" f1 -> Identifier() f2 -> "(" f3 -> ")"
     */
    public String visit(AllocationExpression n, String argu) throws Exception {
        if (ST.getState() == 1) {

            return "return ";
        } else {
            n.f0.accept(this, argu);
            n.f1.accept(this, argu);
            n.f2.accept(this, argu);
            n.f3.accept(this, argu);
            return null;
        }
    }

    @Override
    public String visit(ArrayType n, String argu) {
        return "int[]";
    }

    public String visit(BooleanType n, String argu) {
        return "boolean";
    }

    public String visit(IntegerType n, String argu) {
        return "int";
    }
}
