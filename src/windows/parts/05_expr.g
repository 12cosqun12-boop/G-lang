# ===========================================================================
# expressions
# ===========================================================================
fn punct_prec(op) {
    if (op == 261) { return 1; }
    if (op == 260) { return 2; }
    if (op == '|') { return 3; }
    if (op == '^') { return 4; }
    if (op == '&') { return 5; }
    if (op == 256 || op == 257) { return 6; }
    if (op == '<' || op == '>' || op == 258 || op == 259) { return 7; }
    if (op == 262 || op == 263) { return 8; }
    if (op == '+' || op == '-') { return 9; }
    if (op == '*' || op == '/' || op == '%') { return 10; }
    return 0 - 1;
}
fn emit_binop(op) {
    if (op == '+') { emit_z("add rax, rcx\n"); return 0; }
    if (op == '-') { emit_z("sub rax, rcx\n"); return 0; }
    if (op == '*') { emit_z("imul rax, rcx\n"); return 0; }
    if (op == '/') { emit_z("cqo\nidiv rcx\n"); return 0; }
    if (op == '%') { emit_z("cqo\nidiv rcx\nmov rax, rdx\n"); return 0; }
    if (op == '&') { emit_z("and rax, rcx\n"); return 0; }
    if (op == '|') { emit_z("or rax, rcx\n"); return 0; }
    if (op == '^') { emit_z("xor rax, rcx\n"); return 0; }
    if (op == 262) { emit_z("shl rax, cl\n"); return 0; }
    if (op == 263) { emit_z("sar rax, cl\n"); return 0; }
    if (op == 256) { emit_z("cmp rax, rcx\nsete al\nmovzx rax, al\n"); return 0; }
    if (op == 257) { emit_z("cmp rax, rcx\nsetne al\nmovzx rax, al\n"); return 0; }
    if (op == '<') { emit_z("cmp rax, rcx\nsetl al\nmovzx rax, al\n"); return 0; }
    if (op == 258) { emit_z("cmp rax, rcx\nsetle al\nmovzx rax, al\n"); return 0; }
    if (op == '>') { emit_z("cmp rax, rcx\nsetg al\nmovzx rax, al\n"); return 0; }
    if (op == 259) { emit_z("cmp rax, rcx\nsetge al\nmovzx rax, al\n"); return 0; }
    fail("g: syntax error\n"); return 0;
}
fn parse_expr(min) {
    var op; var p;
    parse_unary();
    while (1) {
        if (tok_kind[ti] != 4) { return 0; }
        op = tok_val[ti]; p = punct_prec(op);
        if (p < min) { return 0; }
        if (op == 260) { logic_and(); continue; }
        if (op == 261) { logic_or(); continue; }
        ti = ti + 1;
        emit_z("sub rsp, 16\nmov [rsp], rax\n");
        parse_expr(p + 1);
        emit_z("mov rcx, rax\nmov rax, [rsp]\nadd rsp, 16\n");
        emit_binop(op);
    }
    return 0;
}
fn logic_and() {
    var f; var e; ti=ti+1; f=next_label(); e=next_label();
    emit_z("test rax, rax\njz "); emit_ref("s",f); emit_ch(10);
    parse_expr(0); emit_z("test rax, rax\njz "); emit_ref("s",f); emit_ch(10);
    emit_z("mov rax, 1\n"); emit_z("jmp "); emit_ref("s",e); emit_ch(10);
    emit_label("s",f); emit_z("xor eax, eax\n"); emit_label("s",e); return 0;
}
fn logic_or() {
    var t; var e; ti=ti+1; t=next_label(); e=next_label();
    emit_z("test rax, rax\njnz "); emit_ref("s",t); emit_ch(10);
    parse_expr(0); emit_z("test rax, rax\njnz "); emit_ref("s",t); emit_ch(10);
    emit_z("xor eax, eax\n"); emit_z("jmp "); emit_ref("s",e); emit_ch(10);
    emit_label("s",t); emit_z("mov rax, 1\n"); emit_label("s",e); return 0;
}
fn parse_unary() {
    var op;
    if (tok_kind[ti] == 4) {
        op=tok_val[ti];
        if(op=='-'){ti=ti+1;parse_unary();emit_z("neg rax\n");return 0;}
        if(op=='!'){ti=ti+1;parse_unary();emit_z("test rax, rax\nsete al\nmovzx rax, al\n");return 0;}
        if(op=='~'){ti=ti+1;parse_unary();emit_z("not rax\n");return 0;}
        if(op=='&'){ti=ti+1;return parse_addr();}
    }
    return parse_primary();
}
fn parse_addr() {
    var idx;var nm;var nl;idx=expect_ident();nm=tok_val[idx];nl=tok_aux[idx];
    if(cur_punct('[')==1){ti=ti+1;parse_expr(0);emit_z("mov rcx, rax\n");if(lookup(nm,nl)==0){fail("g: syntax error\n");}if(v_kind==2){emit_z("lea rdx, [rbp-");emit_int(v_off);emit_z("]\n");}else if(v_kind==4){emit_z("lea rdx, [rel g_");emit_name(v_noff,v_nlen);emit_z("]\n");}else{fail("g: syntax error\n");}emit_z("lea rax, [rdx + rcx * 8]\n");expect_punct(']');return 0;}
    if(lookup(nm,nl)==0){fail("g: syntax error\n");}
    if(v_kind==1||v_kind==2){emit_z("lea rax, [rbp-");emit_int(v_off);emit_z("]\n");return 0;}
    if(v_kind==3||v_kind==4){emit_z("lea rax, [rel g_");emit_name(v_noff,v_nlen);emit_z("]\n");return 0;}
    fail("g: syntax error\n");return 0;
}
fn parse_index(nm,nl){ti=ti+1;parse_expr(0);expect_punct(']');emit_z("mov rcx, rax\n");if(lookup(nm,nl)==0){fail("g: syntax error\n");}if(v_kind==2){emit_z("lea rdx, [rbp-");emit_int(v_off);emit_z("]\n");}else if(v_kind==4){emit_z("lea rdx, [rel g_");emit_name(v_noff,v_nlen);emit_z("]\n");}else{fail("g: syntax error\n");}emit_z("mov rax, [rdx + rcx * 8]\n");return 0;}
fn parse_call(nm,nl){var nargs;ti=ti+1;emit_z("sub rsp, 32\n");nargs=0;while(1){if(cur_punct(')')==1){break;}parse_expr(0);emit_z("mov [rsp + ");emit_int(nargs*8);emit_z("], rax\n");nargs=nargs+1;if(nargs>4){fail("g: too many symbols or arguments\n");}if(cur_punct(',')==0){break;}ti=ti+1;}expect_punct(')');emit_z("mov rcx, [rsp]\nmov rdx, [rsp + 8]\nmov r8, [rsp + 16]\nmov r9, [rsp + 24]\n");if(is_builtin(nm,nl)==1){emit_z("call ");}else{emit_z("call f_");}emit_name(nm,nl);emit_ch(10);emit_z("add rsp, 32\n");return 0;}
fn parse_primary(){var idx;var k;var nm;var nl;idx=ti;k=tok_kind[idx];if(k==2){emit_z("mov rax, ");emit_int(tok_val[idx]);emit_ch(10);ti=ti+1;return 0;}if(k==3){emit_z("lea rax, [rel s");emit_int(tok_val[idx]);emit_z("]\n");ti=ti+1;return 0;}if(k==4&&tok_val[idx]=='('){ti=ti+1;parse_expr(0);expect_punct(')');return 0;}if(k==1){nm=tok_val[idx];nl=tok_aux[idx];ti=ti+1;if(cur_punct('(')==1){return parse_call(nm,nl);}if(cur_punct('[')==1){return parse_index(nm,nl);}if(lookup(nm,nl)==0){fail("g: syntax error\n");}if(v_kind==1){emit_z("mov rax, [rbp-");emit_int(v_off);emit_z("]\n");return 0;}if(v_kind==2){emit_z("lea rax, [rbp-");emit_int(v_off);emit_z("]\n");return 0;}if(v_kind==3){emit_z("mov rax, [rel g_");emit_name(v_noff,v_nlen);emit_z("]\n");return 0;}if(v_kind==4){emit_z("lea rax, [rel g_");emit_name(v_noff,v_nlen);emit_z("]\n");return 0;}fail("g: syntax error\n");}fail("g: syntax error\n");return 0;}
