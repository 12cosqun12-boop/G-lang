# file round trip: create, write, close, open, read
fn main() {
    var f;
    var buf;
    var n;
    f = create("build/tmp_file.txt");
    if (f == 0) {
        print("create failed\n");
        return 1;
    }
    write(f, "roundtrip", 9);
    close(f);
    f = open("build/tmp_file.txt");
    if (f == 0) {
        print("open failed\n");
        return 1;
    }
    buf = alloc(64);
    n = read(f, buf, 63);
    close(f);
    sb(buf + n, 0);
    printn(n);
    putc(32);
    print(buf);
    putc(10);
    printn(streq(buf, "roundtrip"));
    putc(10);
    return 0;
}
