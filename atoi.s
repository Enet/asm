/* atoi function, that converts string to integer */

.section .rodata
    printf_output:
        .string "%d = %d * 2\n"

.text
    .globl main

custom_atoi:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %eax
/* ignore spaces at the beginning */
atoi_space_loop_body:
    movb (%eax), %bl
    cmpb $' ', %bl
    je atoi_space_loop_inc
    cmpb $0, %bl
    je atoi_error
    jmp atoi_sign
atoi_space_loop_inc:
    incl %eax
    jmp atoi_space_loop_body
/* determine sign and store to %dl (0 means +, 1 means -) */
atoi_sign:
    movb $0, %dl
    cmpb $'+', %bl
    je atoi_plus
    cmpb $'-', %bl
    je atoi_minus
    jmp atoi_digit
atoi_minus:
    incb %dl
atoi_plus:
    incl %eax
/* push all the digits to the stack (%ecx is the number of digits) */
atoi_digit:
    xorl %ecx, %ecx
atoi_digit_loop_body:
    movb (%eax), %bl
    cmpb $'0', %bl
    jl atoi_digit_loop_break
    cmpb $'9', %bl
    jg atoi_digit_loop_break
    subb $'0', %bl
    pushl %ebx
    incl %ecx
atoi_digit_loop_inc:
    incl %eax
    jmp atoi_digit_loop_body
atoi_digit_loop_break:
    cmpb $0, %bl
    je atoi_sum_loop_init
    cmpb $' ', %bl
    je atoi_sum_loop_init
    cmpb $'\n', %bl
    je atoi_sum_loop_init
    jmp atoi_error
/* pop from the stack and sum the digits */
atoi_sum_loop_init:
    xorl %eax, %eax
    xorl %edi, %edi
atoi_sum_loop_body:
    popl %esi
    pushl %edi
atoi_multi_loop_inc:
    cmpl $0, %edi
    je atoi_sum_loop_inc
atoi_multi_loop_body:
    leal (%esi,%esi,4), %esi
    shl $1, %esi
    decl %edi
    jmp atoi_multi_loop_inc
atoi_sum_loop_inc:
    popl %edi
    incl %edi
    addl %esi, %eax
    loop atoi_sum_loop_body
/* apply the sign from %dl and return the value */
    xorl %ebx, %ebx
    testb %dl, %dl
    jz atoi_return
    notl %eax
    incl %eax
    jmp atoi_return
/* %eax contains result, %ebx contains error code */
atoi_error:
    movl $-1, %ebx
atoi_return:
    movl %ebp, %esp
    popl %ebp
    ret

main:
no_arguments:
    movl 4(%esp), %eax
    cmpl $2, %eax
    jl error
custom_atoi_call:
    movl 8(%esp), %eax
    pushl 4(%eax)
    call custom_atoi
    addl $4, %esp
custom_atoi_error:
    testl %ebx, %ebx
    jnz error
custom_atoi_output:
    pushl %eax
    shl $1, %eax
    pushl %eax
    pushl $printf_output
    call printf
    addl $12, %esp
end:
    xorl %eax, %eax
    ret
error:
    movl $1, %eax
    ret
