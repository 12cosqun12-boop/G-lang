# ===========================================================================
# runtime emitted into every program
# The compiler carries the whole runtime as text and turns it into machine code
# itself, so a G program needs nothing but the system kernel32 to run.
# ===========================================================================
fn emit_runtime_code() {
    emit_z("; entry point\n");
    emit_z("g_start:\n");
    emit_z("    sub rsp, 40\n");
    emit_z("    call f_main\n");
    emit_z("    mov ecx, eax\n");
    emit_z("    call ExitProcess\n");
    emit_z("strlen:\n    mov rax, rcx\n    xor edx, edx\n.loop:\n    cmp byte [rax], 0\n    je .done\n    inc rax\n    inc rdx\n    jmp .loop\n.done:\n    mov rax, rdx\n    ret\n");
    emit_z("streq:\n    xor eax, eax\n.loop:\n    mov r8b, [rcx]\n    mov r9b, [rdx]\n    cmp r8b, r9b\n    jne .no\n    test r8b, r8b\n    jz .yes\n    inc rcx\n    inc rdx\n    jmp .loop\n.yes:\n    mov eax, 1\n.no:\n    ret\n");
    emit_z("memcpy:\n    mov rax, rcx\n    test r8, r8\n    jz .done\n.loop:\n    mov r9b, [rdx]\n    mov [rcx], r9b\n    inc rcx\n    inc rdx\n    dec r8\n    jnz .loop\n.done:\n    ret\n");
    emit_z("write:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 64\n    mov [rbp - 8], rcx\n    mov [rbp - 16], rdx\n    mov [rbp - 24], r8\n    cmp rcx, 2\n    je .stderr\n    cmp rcx, 1\n    je .stdout\n    jmp .have_handle\n.stdout:\n    mov ecx, -11\n    jmp .get\n.stderr:\n    mov ecx, -12\n.get:\n    call GetStdHandle\n    mov [rbp - 8], rax\n.have_handle:\n    mov rcx, [rbp - 8]\n    mov rdx, [rbp - 16]\n    mov r8, [rbp - 24]\n    lea r9, [rbp - 32]\n    mov qword [rsp + 32], 0\n    call WriteFile\n    test eax, eax\n    jz .fail\n    mov rax, [rbp - 32]\n    jmp .done\n.fail:\n    xor eax, eax\n.done:\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("read:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 64\n    mov [rbp - 8], rcx\n    mov [rbp - 16], rdx\n    mov [rbp - 24], r8\n    cmp rcx, 0\n    jne .have_handle\n    mov ecx, -10\n    call GetStdHandle\n    mov [rbp - 8], rax\n.have_handle:\n    mov rcx, [rbp - 8]\n    mov rdx, [rbp - 16]\n    mov r8, [rbp - 24]\n    lea r9, [rbp - 32]\n    mov qword [rsp + 32], 0\n    call ReadFile\n    test eax, eax\n    jz .fail\n    mov rax, [rbp - 32]\n    jmp .done\n.fail:\n    xor eax, eax\n.done:\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("open:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 80\n    mov edx, 0x80000000\n    mov r8, 1\n    xor r9d, r9d\n    mov qword [rsp + 32], 3\n    mov qword [rsp + 40], 0x80\n    mov qword [rsp + 48], 0\n    call CreateFileA\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("create:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 80\n    mov edx, 0x40000000\n    xor r8d, r8d\n    xor r9d, r9d\n    mov qword [rsp + 32], 2\n    mov qword [rsp + 40], 0x80\n    mov qword [rsp + 48], 0\n    call CreateFileA\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("close:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 32\n    call CloseHandle\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("exit:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 32\n    call ExitProcess\n");
    emit_z("print:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 64\n    mov [rbp - 8], rcx\n    call strlen\n    mov rdx, [rbp - 8]\n    mov r8, rax\n    mov ecx, 1\n    call write\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("printn:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 96\n    mov rax, rcx\n    lea r11, [rbp - 1]\n    mov byte [r11], 0\n    xor r9d, r9d\n    test rax, rax\n    jns .positive\n    mov r9d, 1\n    neg rax\n.positive:\n    mov r10, 10\n.digits:\n    xor edx, edx\n    div r10\n    add dl, '0'\n    dec r11\n    mov [r11], dl\n    test rax, rax\n    jnz .digits\n    test r9d, r9d\n    jz .emit\n    dec r11\n    mov byte [r11], '-'\n.emit:\n    lea r8, [rbp - 1]\n    sub r8, r11\n    mov rdx, r11\n    mov ecx, 1\n    call write\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("putc:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 48\n    mov [rbp - 8], cl\n    lea rdx, [rbp - 8]\n    mov r8, 1\n    mov ecx, 1\n    call write\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("alloc:\n    mov rax, [heap_ptr]\n    test rax, rax\n    jnz .have\n    lea rax, [heap_base]\n.have:\n    add rcx, 15\n    and rcx, -16\n    lea rdx, [rax + rcx]\n    mov [heap_ptr], rdx\n    ret\n");
    emit_z("lb:\n    movzx eax, byte [rcx]\n    ret\nlw:\n    movzx eax, word [rcx]\n    ret\nld:\n    mov eax, dword [rcx]\n    ret\nlq:\n    mov rax, qword [rcx]\n    ret\nsb:\n    mov [rcx], dl\n    ret\nsw:\n    mov [rcx], dx\n    ret\nsd:\n    mov [rcx], edx\n    ret\nsq:\n    mov [rcx], rdx\n    ret\n");
    emit_z("argc:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 32\n    call args_init\n    mov rax, [arg_count]\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("argv:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 32\n    mov [rbp - 8], rcx\n    call args_init\n    mov rcx, [rbp - 8]\n    cmp rcx, 0\n    jl .none\n    cmp rcx, [arg_count]\n    jae .none\n    lea rax, [arg_ptrs]\n    mov rax, [rax + rcx * 8]\n    jmp .done\n.none:\n    xor eax, eax\n.done:\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    emit_z("args_init:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 48\n    cmp qword [arg_ready], 0\n    jne .done\n    mov qword [arg_ready], 1\n    call GetCommandLineA\n    lea r8, [arg_buf]\n    mov r10, rax\n    mov r11, r8\n.copy:\n    mov al, [r10]\n    mov [r11], al\n    inc r10\n    inc r11\n    test al, al\n    jnz .copy\n    lea r8, [arg_ptrs]\n    xor r9d, r9d\n    lea r10, [arg_buf]\n    xor r11d, r11d\n.next:\n    mov al, [r10]\n    test al, al\n    jz .end\n    cmp al, ' '\n    je .space\n    cmp al, 9\n    je .space\n    test r11d, r11d\n    jnz .advance\n    mov [r8 + r9 * 8], r10\n    inc r9\n    cmp r9, 16\n    jae .end\n    mov r11d, 1\n.advance:\n    inc r10\n    jmp .next\n.space:\n    test r11d, r11d\n    jz .space_advance\n    mov byte [r10], 0\n    xor r11d, r11d\n.space_advance:\n    inc r10\n    jmp .next\n.end:\n    mov [arg_count], r9\n.done:\n    mov rsp, rbp\n    pop rbp\n    ret\n");
    return 0;
}
fn emit_runtime_data() {
    emit_z("\nsection .bss\nalign 8\n");
    emit_z("heap_ptr:   resq 1\n");
    emit_z("heap_base:  resb 67108864\n\n");
    emit_z("arg_ready:  resq 1\n");
    emit_z("arg_count:  resq 1\n");
    emit_z("arg_ptrs:   resq 16\n");
    emit_z("arg_buf:    resb 32768\n");
    return 0;
}
