section .data
    ; Только строковые константы разрешены
    prompt db "Enter x value: ", 0
    format_in db "%f", 0
    format_out db "exp(%f) = %f", 10, 0

section .text
global main
extern printf, scanf, malloc, free

main:
    ; СТАНДАРТНЫЙ ПРОЛОГ ФУНКЦИИ
    push rbp
    mov rbp, rsp
    sub rsp, 32             ; Выделяем кадр стека (shadow space)
    
    ; ВЫДЕЛЕНИЕ ПАМЯТИ ДИНАМИЧЕСКИ вместо .bss
    mov rcx, 4              ; sizeof(float) = 4 байта
    call malloc
    mov rbx, rax            ; Сохраняем указатель в RBX
    
    ; ВВОД ЗНАЧЕНИЯ X
    mov rcx, prompt
    call printf
    
    mov rcx, format_in
    mov rdx, rbx            ; Указатель на выделенную память
    call scanf
    
    ; ВЫЧИСЛЕНИЕ EXP(X) ЧЕРЕЗ SSE - все в регистрах
    movss xmm0, [rbx]       ; xmm0 = введенное значение x
    
    ; Константы вычисляем в регистрах (никаких глобальных переменных)
    mov eax, 1
    cvtsi2ss xmm1, eax      ; xmm1 = 1.0 (единица)
    
    ; Ряд Тейлора: exp(x) ≈ 1 + x + x²/2! + x³/3! + x⁴/4!
    
    ; 1 + x
    movss xmm2, xmm0        ; копируем x
    addss xmm1, xmm2        ; xmm1 = 1 + x
    
    ; + x²/2!
    movss xmm2, xmm0
    mulss xmm2, xmm2        ; x²
    
    mov eax, 2
    cvtsi2ss xmm3, eax      ; xmm3 = 2.0
    divss xmm2, xmm3        ; x²/2
    addss xmm1, xmm2        ; xmm1 = 1 + x + x²/2
    
    ; + x³/3! 
    movss xmm2, xmm0
    mulss xmm2, xmm0        ; x²
    mulss xmm2, xmm0        ; x³
    
    mov eax, 6
    cvtsi2ss xmm3, eax      ; xmm3 = 6.0 (3!)
    divss xmm2, xmm3        ; x³/6
    addss xmm1, xmm2        ; xmm1 = 1 + x + x²/2 + x³/6
    
    ; + x⁴/4!
    movss xmm2, xmm0
    mulss xmm2, xmm0        ; x²
    mulss xmm2, xmm2        ; x⁴
    
    mov eax, 24
    cvtsi2ss xmm3, eax      ; xmm3 = 24.0 (4!)
    divss xmm2, xmm3        ; x⁴/24
    addss xmm1, xmm2        ; xmm1 = окончательный результат
    
    ; ВЫВОД РЕЗУЛЬТАТА через printf
    movss xmm2, xmm1        ; сохраняем результат
    cvtss2sd xmm1, xmm2     ; результат для вывода (double)
    cvtss2sd xmm0, [rbx]    ; введенное значение (double)
    movq rdx, xmm0          ; второй аргумент - введенное значение
    movq r8, xmm1           ; третий аргумент - результат
    mov rcx, format_out     ; первый аргумент - форматная строка
    call printf
    
    ; ОСВОБОЖДЕНИЕ ПАМЯТИ
    mov rcx, rbx
    call free
    
    ; СТАНДАРТНЫЙ ЭПИЛОГ ФУНКЦИИ
    add rsp, 32
    pop rbp
    xor eax, eax
    ret
