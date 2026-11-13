# ===========================================================================
# token helpers and symbol tables
# ===========================================================================
fn add_tok(kind, val, aux) {
    if (ntok >= 262144) { fail("g: too many tokens\n"); }
    tok_kind[ntok] = kind; tok_val[ntok] = val; tok_aux[ntok] = aux; ntok = ntok + 1; return 0;
}
fn peq(p, s, n) { var i; i=0; while(i<n){ if(lb(p+i)!=lb(s+i)){return 0;} i=i+1;} return 1; }
fn nm_eq(a,b,n){var i;i=0;while(i<n){if(lb(&src+a+i)!=lb(&src+b+i)){return 0;}i=i+1;}return 1;}
fn tok_is(idx,p,len){if(tok_kind[idx]!=1){return 0;}if(tok_aux[idx]!=len){return 0;}return peq(&src+tok_val[idx],p,len);}
fn cur_is(p,len){return tok_is(ti,p,len);}
fn cur_punct(v){if(tok_kind[ti]!=4){return 0;}if(tok_val[ti]!=v){return 0;}return 1;}
fn expect_punct(v){if(cur_punct(v)==0){fail("g: syntax error\n");}ti=ti+1;return 0;}
fn expect_ident(){var idx;if(tok_kind[ti]!=1){fail("g: syntax error\n");}idx=ti;ti=ti+1;return idx;}
fn skip_to_semi(){while(1){if(tok_kind[ti]==0){return 0;}if(tok_kind[ti]==4&&tok_val[ti]==';'){ti=ti+1;return 0;}ti=ti+1;}return 0;}
fn add_global(off,len,count){if(g_cnt>=1024){fail("g: too many symbols or arguments\n");}g_nam[g_cnt]=off;g_len[g_cnt]=len;g_arr[g_cnt]=count;g_cnt=g_cnt+1;return 0;}
fn add_local(off,len,count){var i;var size;i=0;while(i<l_cnt){if(l_len[i]==len&&nm_eq(off,l_nam[i],len)==1){return 0;}i=i+1;}if(l_cnt>=256){fail("g: too many symbols or arguments\n");}l_nam[l_cnt]=off;l_len[l_cnt]=len;l_arr[l_cnt]=count;size=8;if(count!=0){size=count*8;}l_bytes=l_bytes+size;l_off[l_cnt]=l_bytes;l_cnt=l_cnt+1;return 0;}
fn find_local(off,len){var i;i=0;while(i<l_cnt){if(l_len[i]==len&&nm_eq(off,l_nam[i],len)==1){if(l_arr[i]==0){v_kind=1;}else{v_kind=2;}v_arr=l_arr[i];v_off=l_off[i];return 1;}i=i+1;}return 0;}
fn find_global(off,len){var i;i=0;while(i<g_cnt){if(g_len[i]==len&&nm_eq(off,g_nam[i],len)==1){if(g_arr[i]==0){v_kind=3;}else{v_kind=4;}v_arr=g_arr[i];v_noff=g_nam[i];v_nlen=g_len[i];return 1;}i=i+1;}return 0;}
fn lookup(off,len){if(find_local(off,len)==1){return 1;}return find_global(off,len);}
