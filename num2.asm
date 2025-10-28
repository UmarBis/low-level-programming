section .data
    format_scalar db "Scalar SSE cosine = %f", 10, 0
    format_vector db "Vector SSE cosine = %f", 10, 0
    vector1: dd 5.0, 2.0, 3.0, 4.0
    vector2: dd 2.0, 3.0, 4.0, 5.0

section .bss
    cosine_scalar resd 1
    cosine_vector resd 1

section .text
global main
extern printf

; 1. Скалярные инструкции SSE (используем только младшие 4 байта XMM)
scalar_sse:
    ; Скалярное произведение поэлементно
    movss xmm0, [vector1]      ; xmm0[0] = v1[0]
    mulss xmm0, [vector2]      ; xmm0[0] = v1[0]*v2[0]
    
    movss xmm1, [vector1+4]    ; xmm1[0] = v1[1]
    mulss xmm1, [vector2+4]    ; xmm1[0] = v1[1]*v2[1]
    addss xmm0, xmm1           ; суммируем
    
    movss xmm1, [vector1+8]    ; xmm1[0] = v1[2]
    mulss xmm1, [vector2+8]    ; xmm1[0] = v1[2]*v2[2]
    addss xmm0, xmm1           ; суммируем
    
    movss xmm1, [vector1+12]   ; xmm1[0] = v1[3]
    mulss xmm1, [vector2+12]   ; xmm1[0] = v1[3]*v2[3]
    addss xmm0, xmm1           ; xmm0[0] = скалярное произведение
    
    ; Длина первого вектора (скалярно)
    movss xmm1, [vector1]      ; v1[0]
    mulss xmm1, xmm1           ; v1[0]^2
    
    movss xmm2, [vector1+4]    ; v1[1]
    mulss xmm2, xmm2           ; v1[1]^2
    addss xmm1, xmm2           ; суммируем
    
    movss xmm2, [vector1+8]    ; v1[2]
    mulss xmm2, xmm2           ; v1[2]^2
    addss xmm1, xmm2           ; суммируем
    
    movss xmm2, [vector1+12]   ; v1[3]
    mulss xmm2, xmm2           ; v1[3]^2
    addss xmm1, xmm2           ; xmm1[0] = сумма квадратов
    sqrtss xmm1, xmm1          ; xmm1[0] = длина v1
    
    ; Длина второго вектора (скалярно)
    movss xmm2, [vector2]      ; v2[0]
    mulss xmm2, xmm2           ; v2[0]^2
    
    movss xmm3, [vector2+4]    ; v2[1]
    mulss xmm3, xmm3           ; v2[1]^2
    addss xmm2, xmm3           ; суммируем
    
    movss xmm3, [vector2+8]    ; v2[2]
    mulss xmm3, xmm3           ; v2[2]^2
    addss xmm2, xmm3           ; суммируем
    
    movss xmm3, [vector2+12]   ; v2[3]
    mulss xmm3, xmm3           ; v2[3]^2
    addss xmm2, xmm3           ; xmm2[0] = сумма квадратов
    sqrtss xmm2, xmm2          ; xmm2[0] = длина v2
    
    ; Косинус угла
    mulss xmm1, xmm2           ; произведение длин
    divss xmm0, xmm1           ; косинус = dot_product / (len1 * len2)
    
    movss [cosine_scalar], xmm0
    ret

; 2. Векторные регистры (используем полные XMM регистры)
vector_sse:
    movaps xmm0, [vector1]     ; xmm0 = [v1[0], v1[1], v1[2], v1[3]]
    movaps xmm1, [vector2]     ; xmm1 = [v2[0], v2[1], v2[2], v2[3]]
    
    ; Скалярное произведение через векторные операции
    mulps xmm0, xmm1           ; поэлементное умножение: [v1[0]*v2[0], v1[1]*v2[1], ...]
    
    ; Горизонтальное суммирование
    movaps xmm1, xmm0          ; копируем
    haddps xmm0, xmm1          ; горизонтальное сложение
    haddps xmm0, xmm0          ; xmm0[0] = сумма всех элементов
    
    ; Длины векторов через векторные операции
    movaps xmm1, [vector1]     ; 
    mulps xmm1, xmm1           ; квадраты элементов v1
    movaps xmm2, xmm1
    haddps xmm1, xmm2
    haddps xmm1, xmm1          ; xmm1[0] = сумма квадратов v1
    sqrtss xmm1, xmm1          ; длина v1
    
    movaps xmm2, [vector2]
    mulps xmm2, xmm2           ; квадраты элементов v2
    movaps xmm3, xmm2
    haddps xmm2, xmm3
    haddps xmm2, xmm2          ; xmm2[0] = сумма квадратов v2
    sqrtss xmm2, xmm2          ; длина v2
    
    ; Косинус угла
    mulss xmm1, xmm2           ; произведение длин
    divss xmm0, xmm1           ; косинус
    
    movss [cosine_vector], xmm0
    ret

main:
    ; Скалярный метод SSE
    call scalar_sse
    sub rsp, 40
    mov rcx, format_scalar
    movss xmm0, [cosine_scalar]
    cvtss2sd xmm0, xmm0
    movq rdx, xmm0
    call printf
    add rsp, 40
    
    ; Векторный метод SSE
    call vector_sse
    sub rsp, 40
    mov rcx, format_vector
    movss xmm0, [cosine_vector]
    cvtss2sd xmm0, xmm0
    movq rdx, xmm0
    call printf
    add rsp, 40
    
    xor eax, eax
    ret
