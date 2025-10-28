section .data
    a dd 2.0
    b dd 1.5
    two dd 2.0
    format db "x = %f", 10, 0

section .bss
    x resd 1

section .text
global main
extern printf

main:
    ; Вычисляем x = a * arctg(2^(2b))
    fld dword [b]        ; st0 = 0.5
    fmul dword [two]     ; st0 = 1.0
    fld1                 ; st0 = 1.0, st1 = 1.0
    fscale               ; st0 = 2.0
    fstp st1             ; st0 = 2.0
    fld1                 ; st0 = 1.0, st1 = 2.0
    fpatan               ; st0 = arctg(2.0) ≈ 1.107149
    fmul dword [a]       ; st0 = 2.214298
    fstp dword [x]       ; сохраняем в x
    
    ; Вывод через xmm0
    sub rsp, 32
    mov rcx, format
    movss xmm0, [x]
    cvtss2sd xmm0, xmm0
    movq rdx, xmm0
    call printf
    add rsp, 32
    
    xor eax, eax
    ret
