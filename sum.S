#define EXIT_CODE_SUCCESS 0

.section .rodata
    printf_number_format:
        .string "Enter the number:\n"
    scanf_number_format:
        .string "%d"
    printf_sum_format:
        .string "Sum is equal %d\n"

.data
    number_a:
        .long 0
    number_b:
        .long 0

.text
    .globl main

main:
    movl $number_a, %ebx
    call enter

    movl $number_b, %ebx
    call enter

    movl number_a, %eax
    addl number_b, %eax

    pushl %eax
    pushl $printf_sum_format
    call printf
    addl $8, %esp

    movl $EXIT_CODE_SUCCESS, %eax
    ret

enter:
    pushl $printf_number_format
    call printf

    pushl %ebx
    pushl $scanf_number_format
    call scanf

    addl $12, %esp
    ret
