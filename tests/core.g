# core language exercise
var g_count;
var g_arr[8];

fn add(a, b) {
    return a + b;
}

fn fib(n) {
    if (n < 2) { return n; }
    return fib(n - 1) + fib(n - 2);
}

fn main() {
    var i;
    var sum;
    i = 0;
    while (i < 8) {
        g_arr[i] = i * i;
        i = i + 1;
    }
    i = 0;
    sum = 0;
    while (i < 8) {
        if (i == 5) { break; }
        sum = sum + g_arr[i];
        i = i + 1;
    }
    printn(sum);
    putc(10);
    printn(add(20, 22));
    putc(10);
    printn(fib(10));
    putc(10);
    i = 0;
    while (i < 5) {
        i = i + 1;
        if (i == 2) { continue; }
        printn(i);
        putc(32);
    }
    putc(10);
    g_count = 0;
    while (g_count < 3) {
        g_count = g_count + 1;
    }
    printn(g_count);
    putc(10);
    var p;
    p = alloc(64);
    sb(p, 65);
    sq(p + 8, 12345);
    printn(lb(p));
    putc(32);
    printn(lq(p + 8));
    putc(10);
    print("done\n");
    return 0;
}
