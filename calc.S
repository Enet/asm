#define EXIT_CODE_SUCCESS 0
#define EXIT_CODE_ERROR 1

.section .rodata
    printf_first_number:
        .string "Enter the first number: "
    printf_operator:
        .string "Choose operator from the list (+-*/^): "
    printf_second_number:
        .string "Enter the second number: "
    printf_result:
        .string "Result is %d\n"
    printf_remainder:
        .string "Remainder is %d\n"
    printf_error:
        .string "%s\n"
    scanf_number:
        .string "%d"
    scanf_string:
        .string "%s"
    error_illegal_operator:
        .string "Illegal operator!"
    error_zero_division:
        .string "Division by zero!"
    error_negative_power:
        .string "Power must be positive!"
    operator_add:
        .string "+"
    operator_subtract:
        .string "-"
    operator_multiply:
        .string "*"
    operator_divide:
        .string "/"
    operator_power:
        .string "^"

.data
    first_number:
        .long 0
    second_number:
        .long 0
    operator:
        .string ""

.text
    .globl main

main:
    pushl $printf_first_number
    call printf
    pushl $first_number
    pushl $scanf_number
    call scanf
    addl $12, %esp

    pushl $printf_second_number
    call printf
    pushl $second_number
    pushl $scanf_number
    call scanf
    addl $12, %esp

    pushl $printf_operator
    call printf
    pushl $operator
    pushl $scanf_string
    call scanf
    addl $12, %esp

    movl operator, %eax
    cmpw operator_add, %ax
    je case_add
    cmpw operator_subtract, %ax
    je case_subtract
    cmpw operator_multiply, %ax
    je case_multiply
    cmpw operator_divide, %ax
    je case_divide
    cmpw operator_power, %ax
    je case_power

    pushl $error_illegal_operator
    je error

case_add:
    movl first_number, %eax
    addl second_number, %eax
    jmp result

case_subtract:
    movl first_number, %eax
    subl second_number, %eax
    jmp result

case_multiply:
    movl first_number, %eax
    imull second_number
    jmp result

case_divide:
    cmpl $0, second_number
    pushl $error_zero_division
    je error
    addl $4, %esp

    movl first_number, %eax
    cmpl $0, %eax
    jl divide_switch_sign
    jmp divide

divide_switch_sign:
    not %eax
    incl %eax
    not %ebx
    incl %ebx

divide:
    xor %edx, %edx
    idivl second_number

    pushl %edx
    pushl $printf_remainder
    call printf
    addl $8, %esp

    jmp result

case_power:
    movl second_number, %ecx
    testl %ecx, %ecx
    jz power_one

    cmpl $0, %ecx
    jl power_exception

    movl first_number, %eax
    movl first_number, %ebx

power_loop:
    mull %ebx
    loop power_loop
    jmp result

power_one:
    movl $1, %eax
    jmp result

power_exception:
    pushl $error_negative_power

error:
    pushl $printf_error
    call printf
    addl $8, %esp
    movl $EXIT_CODE_ERROR, %eax
    ret

result:
    pushl %eax
    pushl $printf_result
    call printf
    addl $8, %esp
    movl $EXIT_CODE_SUCCESS, %eax
    ret
