# strings and characters
fn main() {
    var s;
    s = "hello";
    printn(strlen(s)); putc(10);
    printn(streq(s, "hello")); putc(10);
    printn(streq(s, "hell")); putc(10);
    print("tab:\there\n");
    print("quote:\"q\"\n");
    print("ch:");
    putc('A');
    putc(' ');
    putc('A' + 1);
    putc(10);
    return 0;
}
