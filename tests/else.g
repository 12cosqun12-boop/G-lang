# if / else if / else chains
fn classify(n) {
    if (n < 0) {
        return 0 - 1;
    } else if (n == 0) {
        return 0;
    } else if (n < 10) {
        return 1;
    } else {
        return 2;
    }
}

fn main() {
    printn(classify(0 - 5));
    putc(10);
    printn(classify(0));
    putc(10);
    printn(classify(7));
    putc(10);
    printn(classify(42));
    putc(10);
    return 0;
}
