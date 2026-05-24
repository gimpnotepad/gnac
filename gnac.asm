%include "io64.inc"
section .bss
    vs resb 13
    cpun resb 49
    wbuf resw 128
    buf resb 128
    cr resd 1
    col resd 1
    fn resq 1
    sn resq 1
section .data
    bc db 7,0
    cexit db "exit",13,10,0
    chelp db "help",13,10,0
    ccpun db "cpun",13,10,0
    ccls db "cls",13,10,0
    ccol db "col %d",13,10,0
    csum db "sum %d %d",13,10,0
    csub db "sub %d %d",13,10,0
section .text
global main
extern Sleep
extern GetStdHandle
extern ReadConsoleW
extern WideCharToMultiByte
extern SetConsoleOutputCP
extern sscanf
extern system
extern SetConsoleTextAttribute
extern ExitProcess ;stupid ret is not working, sorry
main:
    sub rsp, 64
    mov rcx, 65001
    call SetConsoleOutputCP ;UTF-8
    push rbp
    mov rbp,rsp ;classic
    PRINT_CHAR bc ;bep
    mov rax, 0 ;why you don't use xor rax, rax? because why you can't use mov rax, 0?
    cpuid
    mov [vs], ebx
    mov [vs+4], edx
    mov [vs+8], ecx
    mov byte [vs+12],0
    PRINT_STRING vs
    NEWLINE
    mov rax, 2147483650
    cpuid
    mov [cpun], eax
    mov [cpun+4], ebx
    mov [cpun+8], ecx
    mov [cpun+12], edx
    mov rax, 2147483651
    cpuid
    mov [cpun+16], eax
    mov [cpun+20], ebx
    mov [cpun+24], ecx
    mov [cpun+28], edx
    mov rax, 2147483652
    cpuid
    mov [cpun+32], eax
    mov [cpun+36], ebx
    mov [cpun+40], ecx
    mov [cpun+44], edx
    mov byte [cpun+48],0 ;da end
    PRINT_STRING cpun
    sub rsp, 32
    mov rcx, 1500
    call Sleep ;zzzzzzzzzzzzzzzzzzz
    add rsp, 32
    PRINT_CHAR bc
    NEWLINE
    PRINT_STRING "SSE3:"
    mov rax, 1
    cpuid
    test ecx, 1 ;SSE3 register
    jnz .h
    PRINT_STRING "-"
    NEWLINE
    jmp .s
.h:
    PRINT_STRING "+"
    NEWLINE
.s:
    PRINT_STRING ">"
    push rdi
    push rcx
    push rax
    mov rdi, buf
    mov al, 0
    mov rcx,64
    cld
    rep stosb
    mov rdi, wbuf
    mov al, 0
    mov rcx, 128
    cld
    rep stosb
    pop rcx
    pop rdi
    pop rax
    mov rcx, -10
    call GetStdHandle
    mov r12, rax
    mov rcx, r12
    mov rdx, wbuf
    mov r8, 64
    mov r9, cr
    mov qword [rsp+32],0
    call ReadConsoleW ;input
    mov rcx, 65001
    mov rdx, 0
    mov r8, wbuf
    mov r9, -1
    mov qword [rsp+32], buf
    mov qword [rsp+40], 64
    mov qword [rsp+48], 0
    mov qword [rsp+56], 0
    call WideCharToMultiByte ;По русски, пожалуйста
    
    mov rsi, buf
    mov rdi, cexit ;exit
    mov rcx, 6
    cld
    repe cmpsb
    je .rt
    jne .t
.t:
    mov rsi, buf
    mov rdi, chelp ;help
    mov rcx, 6
    cld
    repe cmpsb
    je .help
    jne .scls
.scls:
    mov rsi, buf
    mov rdi, ccls
    mov rcx, 5
    cld
    repe cmpsb
    je .cls
    jne .lol
.cls:
    sub rsp, 32
    mov rcx, ccls
    call system
    add rsp, 32
    jmp .s
.lol:
    mov rsi, buf
    mov rdi, ccpun
    mov rcx, 6
    cld
    repe cmpsb
    je .cpun
    jne .col
.cpun:
    PRINT_STRING cpun
    NEWLINE
    jmp .s
.help:
    PRINT_STRING "help - Помощь"
    NEWLINE
    PRINT_STRING "cpun - Имя ЦПУ"
    NEWLINE
    PRINT_STRING "exit - Закрыть программу"
    NEWLINE
    PRINT_STRING "sum %d %d - Сумма"
    NEWLINE
    PRINT_STRING "sub %d %d - Вычитание"
    NEWLINE
    PRINT_STRING "col %d - Сменить цвет консоли"
    NEWLINE
    PRINT_STRING "cls - Очистить экран"
    NEWLINE
    jmp .s
.col:
    sub rsp, 32
    mov rcx, buf
    mov rdx, ccol
    mov r8, col
    call sscanf
    add rsp, 32
    
    cmp rax, 1
    jne .Nsum
    
    sub rsp, 32
    mov rcx, -11
    call GetStdHandle
    add rsp, 32
    push rax
    sub rsp, 32
    mov rcx, rax
    mov rdx, [col]
    call SetConsoleTextAttribute
    add rsp, 32
    jmp .s
.Nsum:
    add rsp, 32
    jmp .sum
.sum:
    sub rsp, 32
    mov rcx, buf
    mov rdx, csum
    mov r8, fn
    mov r9, sn
    call sscanf
    add rsp, 32
    
    cmp rax, 2
    jne .Nsub
    
    mov r12, qword [fn]
    add r12, qword [sn]
    PRINT_DEC 8, r12
    NEWLINE
    add rsp, 32
    jmp .s
.Nsub:
    add rsp, 32
    jmp .sub
.sub:
    sub rsp, 32
    mov rcx, buf
    mov rdx, csub
    mov r8, fn
    mov r9, sn
    call sscanf
    add rsp, 32
    
    cmp rax, 2
    jne .Ns
    
    mov r12, qword [fn]
    sub r12, qword [sn]
    PRINT_DEC 8, r12
    NEWLINE
    add rsp, 32
    jmp .s
.Ns:
    add rsp, 32
    jmp .s
.rt:
    add rsp, 64
    pop rbp
    xor rcx, rcx
    call ExitProcess