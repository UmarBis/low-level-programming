section .data
    prompt db "Enter x value: ", 0
    format_in db "%f", 0
    format_out db "exp(%f) = %f", 10, 0
    one dd 1.0
    two dd 2.0
    six dd 6.0
    twentyfour dd 24.0

section .bss
    x_val resd 1
    temp resd 1

section .text
global main
extern printf, scanf

main:
    push ebp
    mov ebp, esp
    
    ; ВВОД ЗНАЧЕНИЯ X
    push prompt
    call printf
    add esp, 4
    
    push x_val
    push format_in
    call scanf
    add esp, 8
    
    ; ВЫЧИСЛЕНИЕ EXP(X) ЧЕРЕЗ FPU
    fld dword [x_val]       ; st0 = x
    
    ; Ряд Тейлора: exp(x) ≈ 1 + x + x²/2! + x³/3! + x⁴/4!
    fld1                    ; st0 = 1.0, st1 = x
    
    ; 1 + x
    fadd st0, st1           ; st0 = 1 + x
    
    ; + x²/2!
    fld st1                 ; st0 = x, st1 = 1+x, st2 = x
    fmul st0, st0           ; st0 = x²
    fdiv dword [two]        ; st0 = x²/2
    faddp                   ; st0 = 1 + x + x²/2
    
    ; + x³/3!
    fld st1                 ; st0 = x, st1 = результат, st2 = x
    fmul st0, st0           ; st0 = x²
    fmul st0, st2           ; st0 = x³
    fdiv dword [six]        ; st0 = x³/6
    faddp                   ; st0 = 1 + x + x²/2 + x³/6
    
    ; + x⁴/4!
    fld st1                 ; st0 = x, st1 = результат, st2 = x
    fmul st0, st0           ; st0 = x²
    fmul st0, st0           ; st0 = x⁴
    fdiv dword [twentyfour] ; st0 = x⁴/24
    faddp                   ; st0 = окончательный результат
    
    ; Сохраняем результат
    fstp dword [temp]
    
    ; ВЫВОД РЕЗУЛЬТАТА
    sub esp, 8
    fld dword [temp]        ; загружаем результат
    fstp qword [esp]        ; конвертируем в double и кладем на стек
    
    sub esp, 8
    fld dword [x_val]       ; загружаем x
    fstp qword [esp]        ; конвертируем в double и кладем на стек
    
    push format_out
    call printf
    add esp, 20
    
    ; Завершение программы
    pop ebp
    xor eax, eax
    ret
