# logic and operators
fn main() {
    printn(1 && 2); putc(10);
    printn(0 && 2); putc(10);
    printn(0 || 3); putc(10);
    printn(0 || 0); putc(10);
    printn(6 & 3); putc(10);
    printn(6 | 3); putc(10);
    printn(6 ^ 3); putc(10);
    printn(~0); putc(10);
    printn(1 << 4); putc(10);
    printn(256 >> 3); putc(10);
    printn(!0); putc(10);
    printn(!5); putc(10);
    printn(-7 / 2); putc(10);
    printn(-7 % 2); putc(10);
    printn(3 < 4); putc(10);
    printn(3 >= 4); putc(10);
    printn(3 != 4); putc(10);
    printn(2 + 3 * 4); putc(10);
    printn((2 + 3) * 4); putc(10);
    return 0;
}
