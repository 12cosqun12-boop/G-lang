# globals, local arrays, nested loops
var total;
var grid[9];

fn main() {
    var i;
    var j;
    var row[4];
    i = 0;
    while (i < 9) {
        grid[i] = i * 3;
        i = i + 1;
    }
    i = 0;
    total = 0;
    while (i < 3) {
        j = 0;
        while (j < 3) {
            total = total + grid[i * 3 + j];
            j = j + 1;
        }
        i = i + 1;
    }
    printn(total); putc(10);
    row[0] = 1;
    row[1] = 2;
    row[2] = 4;
    row[3] = 8;
    printn(row[0] + row[1] + row[2] + row[3]); putc(10);
    return 0;
}
