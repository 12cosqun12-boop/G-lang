# ===========================================================================
# G Language compiler, written in G.
#
#   g input.g output.asm
#
# This file is stage 1 of the bootstrap: stage 0 (asm/g0.asm) compiles it into
# g1.exe, and g1.exe compiles this same file into g2.exe.  g1 and g2 emit
# byte-identical assembly, which is the fixed-point proof of self-hosting.
#
# Compiler layout:
#   01 core     globals, process entry, emit primitives
#   02 lex      source bytes -> tokens
#   03 table    token helpers and symbol tables
#   04 decl     globals, locals, functions, whole-program emission
#   05 expr     expression parser and code generation
#   06 stmt     statement parser
# ===========================================================================

# ---- token kinds ----------------------------------------------------------
#   0 eof   1 ident   2 number   3 string   4 punctuation

# ---- punctuation codes above 255 ------------------------------------------
#   256 ==   257 !=   258 <=   259 >=   260 &&   261 ||   262 <<   263 >>

# ---- program state --------------------------------------------------------
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

# ---- memory ---------------------------------------------------------------
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
        fail("usage: g input.g output.exe\n");
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
    build_pe();

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

fn emit_z(s) {
    emit_bytes(s, strlen(s));
    return 0;
}

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
    emit_z("extern GetStdHandle\nextern WriteFile\nextern ReadFile\n");
    emit_z("extern CreateFileA\nextern CloseHandle\nextern ExitProcess\n");
    emit_z("extern GetCommandLineA\n");
    emit_z("global g_start\n");
    return 0;
}
