# bubble sort over a global array
var a[10];

fn main() {
    var i;
    var j;
    var t;
    i = 0;
    while (i < 10) {
        a[i] = (10 - i) * 3 % 17;
        i = i + 1;
    }
    i = 0;
    while (i < 9) {
        j = 0;
        while (j < 9 - i) {
            if (a[j] > a[j + 1]) {
                t = a[j];
                a[j] = a[j + 1];
                a[j + 1] = t;
            }
            j = j + 1;
        }
        i = i + 1;
    }
    i = 0;
    while (i < 10) {
        printn(a[i]);
        putc(32);
        i = i + 1;
    }
    putc(10);
    return 0;
}
