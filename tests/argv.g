# command line: argc and argv
fn main() {
    var i;
    printn(argc());
    putc(10);
    i = 1;
    while (i < argc()) {
        print(argv(i));
        putc(32);
        i = i + 1;
    }
    putc(10);
    return 0;
}
