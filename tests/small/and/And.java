class And {
    public static void main(String[] a) {
        boolean b;
        boolean c;
        int x;

        b = false;
        c = true;

        if (b && c)
            x = 0;
        else
            x = 1;

        System.out.println(x);
    }
}

class test {
    int x;
    boolean k;
    boolean k2;
    int k3;

    public int func() {
        int y;
        y = 2;
        return y;
    }
}

class test2 extends test {
    int x;
    boolean k;
    boolean k2;
    int k3;

    public int func() {
        int y;
        y = 2;
        return y;
    }

    public int func2() {
        int y;
        y = 2;
        return y;
    }
}