.section .rodata
    printf_input:
        .string "Enter the number (%d-%d):\n"
    printf_output:
        .string "%d! = %d\n"
    printf_error:
        .string "Number must be in range!\n"
    scanf_number:
        .string "%d"
    min_number:
        .long 0
    max_number:
        .long 10

.data
    n:
        .long 0

.text
    .globl main

main:
    pushl max_number
    pushl min_number
    pushl $printf_input
    call printf

    pushl $n
    pushl $scanf_number
    call scanf
    addl $20, %esp

    movl n, %eax
    cmpl min_number, %eax
    jl error
    cmpl max_number, %eax
    jg error

    movl %eax, %ecx
    decl %ecx

    cmpl $2, %ecx
    jl zero_one

factorial:
    mull %ecx
    loop factorial
    jmp output

error:
    pushl $printf_error
    call printf
    addl $4, %esp

    movl $1, %eax
    ret

zero_one:
    movl $1, %eax

output:
    pushl %eax
    pushl n
    pushl $printf_output
    call printf
    addl $12, %esp

    xor %eax, %eax
    ret
