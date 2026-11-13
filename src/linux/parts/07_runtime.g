# ===========================================================================
# Linux x86-64 runtime emitted into every G program
# Direct Linux syscalls; no libc and no dynamic linker required.
# ===========================================================================
fn emit_runtime_code() {
    emit_z("g_start:\n");
    emit_z("    mov rax, [rsp]\n");
    emit_z("    mov [arg_count], rax\n");
    emit_z("    lea r10, [rsp + 8]\n");
    emit_z("    lea r11, [rel arg_ptrs]\n");
    emit_z("    xor r9d, r9d\n");
    emit_z(".args_loop:\n");
    emit_z("    cmp r9, rax\n");
    emit_z("    jae .args_done\n");
    emit_z("    cmp r9, 16\n");
    emit_z("    jae .args_done\n");
    emit_z("    mov rdx, [r10 + r9 * 8]\n");
    emit_z("    mov [r11 + r9 * 8], rdx\n");
    emit_z("    inc r9\n");
    emit_z("    jmp .args_loop\n");
    emit_z(".args_done:\n");
    emit_z("    call f_main\n");
    emit_z("    mov rcx, rax\n");
    emit_z("    call exit\n");
    emit_z("strlen:\n");
    emit_z("    mov rax, rcx\n");
    emit_z("    xor edx, edx\n");
    emit_z(".loop:\n");
    emit_z("    cmp byte [rax], 0\n");
    emit_z("    je .done\n");
    emit_z("    inc rax\n");
    emit_z("    inc rdx\n");
    emit_z("    jmp .loop\n");
    emit_z(".done:\n");
    emit_z("    mov rax, rdx\n");
    emit_z("    ret\n\n");
    emit_z("streq:\n    xor eax, eax\n.loop:\n    mov r8b, [rcx]\n    mov r9b, [rdx]\n    cmp r8b, r9b\n    jne .no\n    test r8b, r8b\n    jz .yes\n    inc rcx\n    inc rdx\n    jmp .loop\n.yes:\n    mov eax, 1\n.no:\n    ret\n\n");
    emit_z("memcpy:\n    mov rax, rcx\n    test r8, r8\n    jz .done\n.loop:\n    mov r9b, [rdx]\n    mov [rcx], r9b\n    inc rcx\n    inc rdx\n    dec r8\n    jnz .loop\n.done:\n    ret\n\n");
    emit_z("write:\n    mov rdi, rcx\n    mov rsi, rdx\n    mov rdx, r8\n    mov rax, 1\n    call linux_syscall\n    ret\n");
    emit_z("read:\n    mov rdi, rcx\n    mov rsi, rdx\n    mov rdx, r8\n    xor eax, eax\n    call linux_syscall\n    ret\n");
    emit_z("open:\n    mov rsi, rcx\n    mov rdi, -100\n    xor edx, edx\n    xor r10d, r10d\n    mov rax, 257\n    call linux_syscall\n    test rax, rax\n    jns .ok\n    xor eax, eax\n.ok:\n    ret\n");
    emit_z("create:\n    mov rsi, rcx\n    mov rdi, -100\n    mov rdx, 577\n    mov r10, 420\n    mov rax, 257\n    call linux_syscall\n    test rax, rax\n    jns .ok\n    xor eax, eax\n.ok:\n    ret\n");
    emit_z("close:\n    mov rdi, rcx\n    mov rax, 3\n    call linux_syscall\n    ret\n");
    emit_z("exit:\n    mov rdi, rcx\n    mov rax, 60\n    call linux_syscall\n    ret\n");
    emit_z("print:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 64\n    mov [rbp - 8], rcx\n    call strlen\n    mov rdx, [rbp - 8]\n    mov r8, rax\n    mov ecx, 1\n    call write\n    mov rsp, rbp\n    pop rbp\n    ret\n\n");
    emit_z("printn:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 96\n    mov rax, rcx\n    lea r11, [rbp - 1]\n    mov byte [r11], 0\n    xor r9d, r9d\n    test rax, rax\n    jns .positive\n    mov r9d, 1\n    neg rax\n.positive:\n    mov r10, 10\n.digits:\n    xor edx, edx\n    div r10\n    add dl, '0'\n    dec r11\n    mov [r11], dl\n    test rax, rax\n    jnz .digits\n    test r9d, r9d\n    jz .emit\n    dec r11\n    mov byte [r11], '-'\n.emit:\n    lea r8, [rbp - 1]\n    sub r8, r11\n    mov rdx, r11\n    mov ecx, 1\n    call write\n    mov rsp, rbp\n    pop rbp\n    ret\n\n");
    emit_z("putc:\n    push rbp\n    mov rbp, rsp\n    sub rsp, 48\n    mov [rbp - 8], cl\n    lea rdx, [rbp - 8]\n    mov r8, 1\n    mov ecx, 1\n    call write\n    mov rsp, rbp\n    pop rbp\n    ret\n\n");
    emit_z("alloc:\n    mov rax, [heap_ptr]\n    test rax, rax\n    jnz .have\n    lea rax, [heap_base]\n.have:\n    add rcx, 15\n    and rcx, -16\n    lea rdx, [rax + rcx]\n    mov [heap_ptr], rdx\n    ret\n\n");
    emit_z("lb:\n    movzx eax, byte [rcx]\n    ret\n\nlw:\n    movzx eax, word [rcx]\n    ret\n\nld:\n    mov eax, dword [rcx]\n    ret\n\nlq:\n    mov rax, qword [rcx]\n    ret\n\nsb:\n    mov [rcx], dl\n    ret\n\nsw:\n    mov [rcx], dx\n    ret\n\nsd:\n    mov [rcx], edx\n    ret\n\nsq:\n    mov [rcx], rdx\n    ret\n\n");
    emit_z("argc:\n    mov rax, [arg_count]\n    ret\n");
    emit_z("argv:\n    cmp rcx, 0\n    jl .none\n    cmp rcx, [arg_count]\n    jae .none\n    lea rax, [rel arg_ptrs]\n    mov rax, [rax + rcx * 8]\n    ret\n.none:\n    xor eax, eax\n    ret\n");
    emit_z("args_init:\n    ret\n");
    emit_z("section .data\nlinux_syscall: db 15,5,195\nsection .text\n\n");
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
