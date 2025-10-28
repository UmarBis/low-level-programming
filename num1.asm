section .data
    format db "exp(1.0) = %f", 10, 0
    x_val dd 1.0
    one dd 1.0
    half dd 0.5
    one_6 dd 0.16666667
    one_24 dd 0.04166667

section .bss
    result resd 1

section .text
global main
extern printf

main:
    ; ВЫЧИСЛЕНИЕ EXP(1.0) ЧЕРЕЗ SSE
    movss xmm0, [x_val]     ; xmm0 = 1.0
    
    ; Ряд Тейлора: exp(x) ≈ 1 + x + x²/2! + x³/3! + x⁴/4!
    movss xmm1, [one]       ; xmm1 = 1.0
    
    ; 1 + x
    movss xmm2, xmm0
    addss xmm1, xmm2        ; xmm1 = 1 + x = 2.0
    
    ; + x²/2!
    movss xmm2, xmm0
    mulss xmm2, xmm2        ; x²
    mulss xmm2, [half]      ; x²/2
    addss xmm1, xmm2        ; xmm1 = 2.5
    
    ; + x³/3! 
    movss xmm2, xmm0
    mulss xmm2, xmm0        ; x²
    mulss xmm2, xmm0        ; x³
    mulss xmm2, [one_6]     ; x³/6
    addss xmm1, xmm2        ; xmm1 = 2.666667
    
    ; + x⁴/4!
    movss xmm2, xmm0
    mulss xmm2, xmm0        ; x²
    mulss xmm2, xmm2        ; x⁴
    mulss xmm2, [one_24]    ; x⁴/24
    addss xmm1, xmm2        ; xmm1 = 2.708334
    
    ; Сохраняем результат
    movss [result], xmm1
    
    ; ВЫВОД РЕЗУЛЬТАТА 
    sub rsp, 40
    movss xmm0, [result]
    cvtss2sd xmm0, xmm0
    movq rdx, xmm0          ; передаем double через RDX
    mov rcx, format         ; форматная строка
    call printf
    add rsp, 40
    
    xor eax, eax
    ret
