class And_test {
    public static void main(String[] a) {
        test b;
        b = new test();
        System.out.println(b.foo());
    }

}

class test {
    int y;
    int k;

    public int foo() {
        y = 3;
        System.out.println(3 * y);

        return 0;
    }
}