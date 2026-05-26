%include "io64.inc"
section .bss
    vs resb 13
    cpun resb 49
    buf resb 128
    cr resd 1
    col resd 1
    fn resq 1
    sn resq 1
section .data
    bc db 7,0
    cexit db "exit",10,0
    chelp db "help",10,0
    ccpun db "cpun",10,0
    ccls db "cls",10,0
    ccol db "col %d",13,10,0
    clang db "lang %d",13,10,0
    csum db "sum %lld %lld",13,10,0
    csub db "sub %lld %lld",13,10,0
    cmul db "mul %lld %lld",13,10,0
    cdiv db "div %lld %lld",13,10,0
    cdebug db "dbg %d",13,10,0
    
    msg_p db 0
    
    ;lang ru
    help_ru db "help - Помощь", 10, "cpun - Имя ЦПУ", 10, "exit - Закрыть программу", 10, "cls - Очистить экран", 10, "col %d - Сменить цвет консоли",10, "lang %d - Сменить язык", 10, "sum/sub/mul/div %d %d - крутые калькуляторы", 10, "dbg %d - очень странная штука для дебаггинга", 0
    ;lang en
    help_en db "help - Help", 10, "cpun - CPU Name", 10, "exit - Close Program", 10, "cls - Clear Screen", 10, "col %d - Change Console Color",10, "lang %d - Change language", 10, "sum/sub/mul/div %d %d - Cool Calculators", 10, "dbg %d - A Very Strange Thing for Debugging", 0
    ;lang pl
    help_pl db "help - Pomoc", 10, "cpun - Nazwa procesora", 10, "exit - Zamknij program", 10, "cls - Wyczyść ekran", 10, "col %d - Zmień kolor konsoli", 10, "sum/sub/mul/div %d %d - Fajne kalkulatory", 10, "dbg %d - Bardzo dziwna rzecz do debugowania", 0
    
    lang:
        dq help_en, help_ru, help_pl
    
    cur_lang dq 0
    LANG_C equ 3
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
extern strcmp
extern ExitProcess ;stupid ret is not working, sorry
%macro GAPLS 1 ;Get and print language string
    mov rax, %1
    imul rax, 24 ; x*8, x=3
    mov rbx, [cur_lang]
    shl rbx, 3 ;cur_lang*8
    add rax, rbx ;x*8+cur_lang*8
    mov rax, [lang+rax] ;pointer to lang+(x*8+cur_lang*8)
    PRINT_STRING [rax] ;get out!
%endmacro

%macro INVOKE1 2
    sub rsp, 32
    mov rcx, %2
    call %1
    add rsp, 32
%endmacro

%macro INVOKE2 3
    sub rsp, 32
    mov rcx, %2
    mov rdx, %3
    call %1
    add rsp, 32
%endmacro

%macro INVOKE3 4
    sub rsp, 32
    mov rcx, %2
    mov rdx, %3
    mov r8, %4
    call %1
    add rsp, 32
%endmacro

%macro INVOKE4 5
    sub rsp, 32
    mov rcx, %2
    mov rdx, %3
    mov r8, %4
    mov r9, %5
    call %1
    add rsp, 32
%endmacro

main:
    mov rbp, rsp; for correct debugging
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
    GET_STRING buf, 256
    INVOKE2 strcmp, buf, cexit
    cmp rax, 0
    je .rt
    jne .t
.t:
    INVOKE2 strcmp, buf, chelp
    cmp rax, 0
    je .help
    jne .scls
.scls:
    INVOKE2 strcmp, buf, ccls
    cmp rax, 0
    je .cls
    jne .lol
.cls:
    INVOKE1 system,ccls
    jmp .s
.lol:
    INVOKE2 strcmp, buf, ccpun
    cmp rax, 0
    je .cpun
    jne .col
.cpun:
    PRINT_STRING cpun
    NEWLINE
    jmp .s
.help:
    GAPLS 0
    NEWLINE
    jmp .s
.col:
    INVOKE3 sscanf, buf, ccol, col
    
    cmp rax, 1
    jne .clang
    
    INVOKE1 GetStdHandle, -11
    push rax
    INVOKE2 SetConsoleTextAttribute, rax, [col]
    pop rcx
    jmp .s
.clang:
    INVOKE3 sscanf, buf, clang, fn
    
    cmp rax, 1
    jne .Nsum
    
    cmp qword [fn], 0
    jl .s
    cmp qword [fn], LANG_C
    jge .s
    mov rax, [fn]
    mov qword [cur_lang], rax
    jmp .s
.Nsum:
    jmp .sum
.sum:
    INVOKE4 sscanf, buf, csum, fn, sn
    
    cmp rax, 2
    jne .sub
    
    push r12
    mov r12, qword [fn]
    add r12, qword [sn]
    PRINT_DEC 8, r12
    NEWLINE
    pop r12
    jmp .s
.sub:
    INVOKE4 sscanf, buf, csub, fn, sn
    
    cmp rax, 2
    jne .Nmul
    
    push r12
    mov r12, qword [fn]
    sub r12, qword [sn]
    PRINT_DEC 8, r12
    NEWLINE
    pop r12
    jmp .s
.Nmul:
    jmp .mul
.mul:
    INVOKE4 sscanf, buf, cmul, fn, sn
    
    cmp rax, 2
    jne .Ndiv
    
    push r12
    mov r12, qword [fn]
    imul r12, qword [sn]
    PRINT_DEC 8, r12
    NEWLINE
    pop r12
    jmp .s
.Ndiv:
    jmp .div
.div:
    INVOKE4 sscanf, buf, cdiv, fn, sn
    
    cmp rax, 2
    jne .debug
    
    push rbx
    push rdx
    mov rbx, qword [sn]
    test rbx, rbx
    je .errdiv
    mov rax, qword [fn]
    cqo
    idiv rbx
    PRINT_DEC 8, rax
    NEWLINE
    PRINT_DEC 8, rdx
    NEWLINE
    pop rdx
    pop rbx
    jmp .s
.errdiv:
    pop rdx
    pop rbx
    PRINT_STRING "DIV_ERR_BY_0"
    NEWLINE
    jmp .Ns
.debug:
    INVOKE3 sscanf, buf, cdebug, fn
    
    cmp rax, 1
    jne .Ns
    
    cmp qword [fn], 1
    je .rt
    cmp qword [fn], 2
    je .oops
    jmp .s
.Ns:
    jmp .s
.oops:
    ;dbg 2 is the stupid idea
    ;
    ;
    ;idk what i should add
    ;
    ;
    mov rax, [0] ;oh no nullptr is dereferenced
.rt:
    pop rbp
    xor rcx, rcx
    call ExitProcess