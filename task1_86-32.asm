section .data
    prompt db "Enter x value: ", 0
    format_in db "%f", 0
    format_out db "exp(%f) = %f", 10, 0

section .text
global main
extern printf, scanf, malloc, free

main:
    ; СТАНДАРТНЫЙ ПРОЛОГ
    push ebp
    mov ebp, esp
    
    ; ВЫДЕЛЕНИЕ ПАМЯТИ ДИНАМИЧЕСКИ
    push 4                   ; sizeof(float)
    call malloc
    add esp, 4
    mov ebx, eax            ; Сохраняем указатель
    
    ; ВВОД ЗНАЧЕНИЯ X
    push prompt
    call printf
    add esp, 4
    
    push ebx                ; указатель на выделенную память
    push format_in
    call scanf
    add esp, 8
    
    ; ВЫЧИСЛЕНИЕ EXP(X) ЧЕРЕЗ FPU
    fld dword [ebx]         ; st0 = x
    
    ; Ряд Тейлора через FPU
    fld1                    ; st0 = 1.0, st1 = x
    fadd st0, st1           ; 1 + x
    
    fld st1                 ; st0 = x, st1 = результат, st2 = x
    fmul st0, st0           ; x²
    fild dword [two]        ; st0 = 2.0
    fdivp                   ; x²/2
    faddp                   ; + x²/2
    
    fld st1                 ; st0 = x
    fmul st0, st0           ; x²
    fmul st0, st2           ; x³
    fild dword [six]        ; st0 = 6.0
    fdivp                   ; x³/6
    faddp                   ; + x³/6
    
    fld st1                 ; st0 = x
    fmul st0, st0           ; x²
    fmul st0, st0           ; x⁴
    fild dword [twentyfour] ; st0 = 24.0
    fdivp                   ; x⁴/24
    faddp                   ; + x⁴/24
    
    ; ВЫВОД РЕЗУЛЬТАТА
    sub esp, 8
    fst qword [esp]         ; результат как double
    
    sub esp, 8
    fld dword [ebx]
    fstp qword [esp]        ; x_val как double
    
    push format_out
    call printf
    add esp, 20
    
    ; ОСВОБОЖДЕНИЕ ПАМЯТИ
    push ebx
    call free
    add esp, 4
    
    ; СТАНДАРТНЫЙ ЭПИЛОГ
    pop ebp
    xor eax, eax
    ret

; Константы в коде (не в .data!)
two: dd 2
six: dd 6  
twentyfour: dd 24
