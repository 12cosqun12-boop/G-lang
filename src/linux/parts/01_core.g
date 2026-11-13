# ===========================================================================
# G Language compiler, written in G.
#
#   g input.g output
#
# Linux x86-64 self-hosted compiler. A G-built stage1 recompiles this source
# into a byte-identical stage2 ELF64 compiler (fixed-point proof).
# ===========================================================================

var srclen;
var ntok;
var ti;
var out_len;
var lbl;
var fid;
var cur_fn;
var str_total;
var str_count;
var g_cnt;
var l_cnt;
var l_bytes;
var l_frame;
var param_count;
var loop_depth;
var v_kind;
var v_off;
var v_arr;
var v_noff;
var v_nlen;

var src[1048576];
var sdata[131072];
var obuf[2097152];

var tok_kind[262144];
var tok_val[262144];
var tok_aux[262144];

var str_start[65536];
var str_len[65536];

var g_nam[1024];
var g_len[1024];
var g_arr[1024];

var l_nam[256];
var l_len[256];
var l_off[256];
var l_arr[256];

var loop_top[64];
var loop_end[64];

fn main() {
    var inp;
    var outp;
    var h;
    var n;

    if (argc() < 3) {
        fail("usage: g input.g output\n");
    }
    inp = argv(1);
    outp = argv(2);

    h = open(inp);
    if (h == 0) {
        fail("g: cannot open input\n");
    }
    n = read(h, &src, 8388608);
    close(h);
    if (n < 0) { n = 0; }
    srclen = n;

    lex();
    collect_globals();

    out_len = 0;
    emit_header();
    emit_runtime_code();
    parse_program();
    emit_strings();
    emit_globals();

    assemble();
    build_elf();

    h = create(outp);
    if (h == 0) {
        fail("g: cannot create output\n");
    }
    write_all(h, &pebuf, pe_len);
    close(h);
    return 0;
}

fn fail(msg) {
    write(2, msg, strlen(msg));
    exit(1);
    return 0;
}

fn write_all(fd, p, n) {
    var w;
    while (n > 0) {
        w = write(fd, p, n);
        if (w <= 0) { return 0; }
        p = p + w;
        n = n - w;
    }
    return 0;
}

fn emit_ch(ch) {
    sb(&obuf + out_len, ch);
    out_len = out_len + 1;
    return 0;
}

fn emit_bytes(p, n) {
    var i;
    i = 0;
    while (i < n) {
        sb(&obuf + out_len + i, lb(p + i));
        i = i + 1;
    }
    out_len = out_len + n;
    return 0;
}

fn emit_z(s) { emit_bytes(s, strlen(s)); return 0; }

fn emit_int(n) {
    var buf[32];
    var i;
    var neg;
    var d;
    i = 31;
    neg = 0;
    if (n < 0) { neg = 1; n = 0 - n; }
    if (n == 0) { i = i - 1; sb(&buf + i, 48); }
    while (n > 0) {
        d = n % 10;
        i = i - 1;
        sb(&buf + i, 48 + d);
        n = n / 10;
    }
    if (neg == 1) { i = i - 1; sb(&buf + i, 45); }
    emit_bytes(&buf + i, 31 - i);
    return 0;
}

fn emit_name(off, len) { emit_bytes(&src + off, len); return 0; }

fn emit_label(prefix, id) {
    emit_z(".L");
    emit_z(prefix);
    emit_int(id);
    emit_ch(58);
    emit_ch(10);
    return 0;
}

fn emit_ref(prefix, id) {
    emit_z(".L");
    emit_z(prefix);
    emit_int(id);
    return 0;
}

fn next_label() { lbl = lbl + 1; return lbl; }

fn emit_header() {
    emit_z("default rel\nsection .text\n");
    emit_z("global g_start\n");
    return 0;
}
