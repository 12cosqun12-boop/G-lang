# ===========================================================================
# lexer: source bytes -> tokens
# ===========================================================================
fn is_alpha(c) {
    if (c >= 65 && c <= 90) { return 1; }
    if (c >= 97 && c <= 122) { return 1; }
    if (c == 95) { return 1; }
    return 0;
}

fn is_digit(c) {
    if (c >= 48 && c <= 57) { return 1; }
    return 0;
}

fn lex_escape(c) {
    if (c == 'n') { return 10; }
    if (c == 't') { return 9; }
    if (c == 'r') { return 13; }
    if (c == '0') { return 0; }
    return c;
}

fn lex() {
    var pos; var len; var ch; var nxt; var start; var val; var idx; var d;
    pos = 0; len = srclen; ntok = 0; str_total = 0; str_count = 0;
    while (pos < len) {
        ch = lb(&src + pos);
        if (ch == 32) { pos = pos + 1; continue; }
        if (ch == 9)  { pos = pos + 1; continue; }
        if (ch == 13) { pos = pos + 1; continue; }
        if (ch == 10) { pos = pos + 1; continue; }
        if (ch == '#') {
            while (pos < len) {
                ch = lb(&src + pos); pos = pos + 1;
                if (ch == 10) { break; }
            }
            continue;
        }
        if (ch == '"') {
            pos = pos + 1; idx = str_count; str_start[idx] = str_total; val = 0;
            while (1) {
                if (pos >= len) { fail("g: unterminated string\n"); }
                ch = lb(&src + pos); pos = pos + 1;
                if (ch == '"') { break; }
                if (ch == 92) { ch = lb(&src + pos); pos = pos + 1; ch = lex_escape(ch); }
                sb(&sdata + str_total, ch); str_total = str_total + 1; val = val + 1;
            }
            sb(&sdata + str_total, 0); str_total = str_total + 1;
            str_len[idx] = val; str_count = str_count + 1; add_tok(3, idx, 0); continue;
        }
        if (ch == 39) {
            pos = pos + 1;
            if (pos >= len) { fail("g: bad character literal\n"); }
            ch = lb(&src + pos); pos = pos + 1;
            if (ch == 92) { ch = lb(&src + pos); pos = pos + 1; ch = lex_escape(ch); }
            if (pos >= len || lb(&src + pos) != 39) { fail("g: bad character literal\n"); }
            pos = pos + 1; add_tok(2, ch, 0); continue;
        }
        if (is_digit(ch) == 1) {
            val = 0;
            if (ch == 48 && pos + 1 < len) {
                nxt = lb(&src + pos + 1);
                if (nxt == 'x' || nxt == 'X') {
                    pos = pos + 2;
                    while (pos < len) {
                        ch = lb(&src + pos); d = 0 - 1;
                        if (ch >= 48 && ch <= 57) { d = ch - 48; }
                        if (ch >= 97 && ch <= 102) { d = ch - 87; }
                        if (ch >= 65 && ch <= 70) { d = ch - 55; }
                        if (d < 0) { break; }
                        val = val * 16 + d; pos = pos + 1;
                    }
                    add_tok(2, val, 0); continue;
                }
            }
            while (pos < len) {
                ch = lb(&src + pos);
                if (is_digit(ch) == 0) { break; }
                val = val * 10 + (ch - 48); pos = pos + 1;
            }
            add_tok(2, val, 0); continue;
        }
        if (is_alpha(ch) == 1) {
            start = pos;
            while (pos < len) {
                ch = lb(&src + pos);
                if (is_alpha(ch) == 0 && is_digit(ch) == 0) { break; }
                pos = pos + 1;
            }
            add_tok(1, start, pos - start); continue;
        }
        val = ch; nxt = 0;
        if (pos + 1 < len) { nxt = lb(&src + pos + 1); }
        d = 0;
        if (ch == '=' && nxt == '=') { val = 256; d = 1; }
        if (ch == '!' && nxt == '=') { val = 257; d = 1; }
        if (ch == '<' && nxt == '=') { val = 258; d = 1; }
        if (ch == '<' && nxt == '<') { val = 262; d = 1; }
        if (ch == '>' && nxt == '=') { val = 259; d = 1; }
        if (ch == '>' && nxt == '>') { val = 263; d = 1; }
        if (ch == '&' && nxt == '&') { val = 260; d = 1; }
        if (ch == '|' && nxt == '|') { val = 261; d = 1; }
        pos = pos + 1 + d; add_tok(4, val, 0);
    }
    add_tok(0, 0, 0); return 0;
}
