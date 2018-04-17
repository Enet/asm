.section .rodata
    scanf_number:
        .string "%d"
    printf_count:
        .string "How much numbers you want to compare?\n"
    printf_input:
        .string "Enter the number:\n"
    printf_output:
        .string "Min value is %d. Max value is %d.\n"
    printf_error:
        .string "Positive integer was expected!\n"

.data
    number:
        .long 0
    max:
        .long 0
    min:
        .long 0

.text
    .globl main

main:
    pushl $printf_count
    call printf

    pushl $number
    pushl $scanf_number
    call scanf
    addl $12, %esp
    movl number, %ecx
    cmpl $0, %ecx
    jl error
    movl %ecx, %edx
loop_body:
    pushl %ecx
    pushl %edx
    pushl $printf_input
    call printf

    pushl $number
    pushl $scanf_number
    call scanf
    addl $12, %esp
    popl %edx
    popl %ecx

    movl number, %eax
    cmpl %ecx, %edx
    je 1f
    jmp 2f
1:
    movl %eax, min
    movl %eax, max
    jmp 6f
2:
    cmpl max, %eax
    jg 3f
    jmp 4f
3:
    movl %eax, max
4:
    cmpl min, %eax
    jl 5f
    jmp 6f
5:
    movl %eax, min
6:
loop_inc:
    loop loop_body
    jmp end
error:
    pushl $printf_error
    call printf
    addl $4, %esp
    movl $1, %eax
    ret
end:
    pushl max
    pushl min
    pushl $printf_output
    call printf
    addl $12, %esp
    xor %eax, %eax
    ret
