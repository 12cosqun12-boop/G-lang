# pointers, memory words, alloc
var buf[16];

fn main() {
    var p;
    var x;
    p = alloc(64);
    sq(p, 123456789);
    printn(lq(p)); putc(10);
    sw(p, 4660);
    printn(lw(p)); putc(10);
    sb(p, 66);
    printn(lb(p)); putc(10);
    sq(p + 8, 7);
    printn(lq(p + 8)); putc(10);
    memcpy(p + 16, p + 8, 8);
    printn(lq(p + 16)); putc(10);
    buf[3] = 99;
    p = &buf[3];
    printn(lq(p)); putc(10);
    x = 5;
    p = &x;
    sq(p, 6);
    printn(x); putc(10);
    return 0;
}
