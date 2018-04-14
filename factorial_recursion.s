.section .rodata
    printf_input:
        .string "Enter the number (%d-%d):\n"
    printf_output:
        .string "%d! = %d\n"
    printf_error:
        .string "Number must be in range!\n"
    scanf_input:
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
    pushl $scanf_input
    call scanf

    addl $20, %esp
    movl n, %eax
    cmpl min_number, %eax
    jl error
    cmpl max_number, %eax
    jg error

    pushl n
    call factorial
    addl $4, %esp
    jmp output

factorial:
    pushl %ebp
    movl %esp, %ebp

    movl 8(%ebp), %ebx
    testl %ebx, %ebx
    jz factorial_zero

    movl %ebx, %eax
    decl %eax
    pushl %ebx
    pushl %eax
    call factorial
    addl $4, %esp
    popl %ebx
    mull %ebx
    jmp factorial_return

factorial_zero:
    movl $1, %eax

factorial_return:
    movl %ebp, %esp
    popl %ebp
    ret

error:
    pushl $printf_error
    call printf
    addl $4, %esp

    movl $1, %eax
    ret

output:
    pushl %eax
    pushl n
    pushl $printf_output
    call printf
    addl $12, %esp

    movl $0, %eax
    ret
