section .data
    msg1 db 'Введите первое число: ', 0xA, 0
    msg2 db 'Введите второе число: ', 0xA, 0
    msg3 db 'Введите математическую операцию (+, -, *, /): ', 0xA, 0
    msg_result db 'Результат: ', 0
    buffer_number_size equ 20
    buffer_char_size equ 2
section .bss
    buffer_number resb buffer_number_size 
    number1 resb buffer_number_size 
    number2 resb buffer_number_size 
    bss_char resb 1
    buffer_char resb buffer_char_size
 
section .text
    global _start
 
_start:
    .loop:
    mov rax, msg1
    call print_string
 
    mov rax, buffer_number
    call input_number
    mov [number1], rax
 
    mov rax, msg2
    call print_string
 
    mov rax, buffer_number
    call input_number
    mov [number2], rax
 
    mov rax, msg3
    call print_string
 
    call input_char
    mov [buffer_char], rax
 
    mov rax, msg_result
    call print_string
 
    mov rax, [number1]
    mov rbx, [number2]
    mov rcx, [buffer_char]
    call calc
 
    ; Вывод результата
    call print_integer
    call print_line
    jmp .loop
 
    ; Завершаем программу
    mov rax, 1              ; Системный вызов sys_exit
    xor rbx, rbx            ; Код возврата 0
    int 0x80
 
; Input:
;   rax = number1
;   rbx = number2
;   rcx = operator
; Output:
;   rax = result
calc:
    cmp rcx, '-'
    je .substruct
 
    cmp rcx, '+'
    je .sum
 
    cmp rcx, '*'
    je .multiply
 
    cmp rcx, '/'
    je .divide
 
    .sum:
    add rax, rbx
    jmp .end_calc
 
    .substruct:
    sub rax, rbx
    jmp .end_calc
 
    .multiply:
    imul rax, rbx
    jmp .end_calc
 
    .divide:
    idiv rbx
 
    .end_calc:
    ret
 
 
; | input:
; rax = buffer
; rbx = buffer size
input_string:
    push rax
    push rbx
    push rcx
    push rdx
 
    mov rcx, rax
    mov rdx, rbx
    mov rax, 3 ; read
    mov rbx, 0 ; stdin
    int 0x80
 
    ; upd
    mov [rcx+rax-1], byte 0
 
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
 
 
; Output: rax = number
input_number:
    push rbx
    mov rax, buffer_number
    mov rbx, buffer_number_size
    call input_string
    call atoi
    pop rbx
    ret
 
 
; Output: rax = char
input_char:
    push rbx
    mov rax, buffer_char
    mov rbx, buffer_char_size
    call input_string
    mov rax, [rax]
    pop rbx
    ret
 
 
; | input
; rax = string
print_string:
    push rax
    push rbx
    push rcx
    push rdx
 
    mov rcx, rax
    call length_string
 
    mov rdx, rax
    mov rax, 4
    mov rbx, 1
    int 0x80
 
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
 
; Input: rax = number
print_integer:
    push rax
    push rbx
    push rcx
    push rdx
    xor rcx, rcx
    cmp rax, 0
    jl .is_minus
    jmp .next_iter
    .is_minus:
        neg rax
        push rax
        mov rax, '-'
        call print_char
        pop rax
    .next_iter:
        mov rbx, 10
        xor rdx, rdx
        idiv rbx
        add rdx, '0'
        push rdx
        inc rcx
        cmp rax, 0
        je .print_iter
        jmp .next_iter
    .print_iter:
        cmp rcx, 0
        je .close
        pop rax
        call print_char
        dec rcx
        jmp .print_iter
    .close:
        pop rdx
        pop rcx
        pop rbx
        pop rax
        ret
 
; Input: rax = char
print_char:
    push rdx
    push rcx
    push rbx
    push rax
 
    mov [bss_char], al
 
    mov rax, 4
    mov rbx, 1
    mov rcx, bss_char
    mov rdx, 1
    int 0x80
 
    pop rax
    pop rbx
    pop rcx
    pop rdx
    ret
 
 
; Input: rax = string
; Output: rax = number
atoi:
    push rbx
    push rcx
    push rdx
    push rdi
 
    xor rdi, rdi
    xor rbx, rbx
    xor rcx, rcx
    cmp [rax], byte '-'
    jne .next_iter
    inc rdi
    inc rbx
    .next_iter:
        cmp [rax+rbx], byte 0
        je .next_step
        mov cl, [rax+rbx]
        sub cl, '0'
        push rcx
        inc rbx
        jmp .next_iter
    .next_step:
        mov rcx, 1
        xor rax, rax
    .to_number:
        cmp rbx, rdi ; rdi = 1 or 0, (1 - число отрицательное, 0 - положительное)
        je .close
        pop rdx
        imul rdx, rcx
        imul rcx, 10
        add rax, rdx
        dec rbx
        jmp .to_number
    .close:
        cmp rdi, 1
        jne .is_not_negative
        neg rax
        .is_not_negative:
        pop rdi
        pop rdx
        pop rcx
        pop rbx
        ret
 
 
; | input
; rax = string
; | output
; rax = length
length_string:
    push rbx
    xor rbx, rbx
    .next_iter:
        cmp [rax+rbx], byte 0
        je .close
        inc rbx
        jmp .next_iter
    .close:
        mov rax, rbx
        pop rbx
        ret
 
 
print_line:
    push rax
    mov rax, 0xA
    call print_char
    pop rax
    ret
