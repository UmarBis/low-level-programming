section .data
    prompt db "Enter x value: ", 0
    format_in db "%f", 0
    format_out db "exp(%f) = %f", 10, 0
    one dd 1.0

section .bss
    x_val resd 1

section .text
global main
extern printf, scanf

main:
    push rbp
    mov rbp, rsp
    
    ; ВВОД ЗНАЧЕНИЯ X
    sub rsp, 32
    mov rcx, prompt
    call printf
    add rsp, 32
    
    sub rsp, 32
    mov rcx, format_in
    mov rdx, x_val
    call scanf
    add rsp, 32
    
    ; ВЫЧИСЛЕНИЕ EXP(X) ЧЕРЕЗ SSE
    movss xmm0, [x_val]     ; xmm0 = введенное значение x
    
    ; Константы в регистрах XMM
    movss xmm1, [one]       ; xmm1 = 1.0 (единица)
    
    ; Ряд Тейлора: exp(x) ≈ 1 + x + x²/2! + x³/3! + x⁴/4!
    
    ; 1 + x
    movss xmm2, xmm0        ; копируем x
    addss xmm1, xmm2        ; xmm1 = 1 + x
    
    ; + x²/2!
    movss xmm2, xmm0
    mulss xmm2, xmm2        ; x²
    movss xmm3, [one] 
    movss xmm4, [one]
    addss xmm3, xmm4        ; xmm3 = 2.0
    divss xmm2, xmm3        ; x²/2
    addss xmm1, xmm2        ; xmm1 = 1 + x + x²/2
    
    ; + x³/3! 
    movss xmm2, xmm0
    mulss xmm2, xmm0        ; x²
    mulss xmm2, xmm0        ; x³
    movss xmm3, [one] 
    movss xmm4, [one]
    movss xmm5, [one]
    addss xmm3, xmm4
    addss xmm3, xmm5        ; xmm3 = 3.0
    movss xmm4, [one]
    movss xmm5, [one]
    addss xmm4, xmm5        ; xmm4 = 2.0
    mulss xmm3, xmm4        ; xmm3 = 6.0 (3!)
    divss xmm2, xmm3        ; x³/6
    addss xmm1, xmm2        ; xmm1 = 1 + x + x²/2 + x³/6
    
    ; + x⁴/4!
    movss xmm2, xmm0
    mulss xmm2, xmm0        ; x²
    mulss xmm2, xmm2        ; x⁴
    movss xmm3, [one] 
    movss xmm4, [one]
    movss xmm5, [one]
    movss xmm6, [one]
    addss xmm3, xmm4
    addss xmm3, xmm5
    addss xmm3, xmm6        ; xmm3 = 4.0
    movss xmm4, [one]
    movss xmm5, [one]
    movss xmm6, [one]
    addss xmm4, xmm5
    addss xmm4, xmm6        ; xmm4 = 3.0
    mulss xmm3, xmm4        ; xmm3 = 12.0
    movss xmm4, [one]
    movss xmm5, [one]
    addss xmm4, xmm5        ; xmm4 = 2.0
    mulss xmm3, xmm4        ; xmm3 = 24.0 (4!)
    divss xmm2, xmm3        ; x⁴/24
    addss xmm1, xmm2        ; xmm1 = окончательный результат
    
    ; ВЫВОД РЕЗУЛЬТАТА через printf
    sub rsp, 32
    movss xmm2, xmm1        ; сохраняем результат
    cvtss2sd xmm1, xmm2     ; результат для вывода (double)
    cvtss2sd xmm0, [x_val]  ; введенное значение (double)
    movq r8, xmm1           ; третий аргумент - результат
    movq rdx, xmm0          ; второй аргумент - введенное значение
    mov rcx, format_out     ; первый аргумент - форматная строка
    call printf
    add rsp, 32
    
    pop rbp
    xor eax, eax
    ret
