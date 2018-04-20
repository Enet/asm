// unoptimized atoi function, that convert string (first argument) to integer

.section .rodata
    printf_output:
        .string "%d = %d * 2\n"
    number_0:
        .long '0'
    number_9:
        .long '9'
    plus:
        .long '+'
    minus:
        .long '-'
    space:
        .long ' '
    new_line:
        .long '\n'

.text
    .globl main

custom_atoi:
    pushl %ebp
    movl %esp, %ebp
    movl 8(%ebp), %eax
atoi_space_loop_body:
    movl (%eax), %ebx
    andl $0x000000ff, %ebx
    cmpl space, %ebx
    je atoi_space_loop_inc
    cmpl $0, %ebx
    je atoi_error
    jmp atoi_sign
atoi_space_loop_inc:
    incl %eax
    jmp atoi_space_loop_body
atoi_sign:
    movl $0, %esi
    cmpl plus, %ebx
    je atoi_plus
    cmpl minus, %ebx
    je atoi_minus
    jmp atoi_digit
atoi_minus:
    movl $1, %esi
atoi_plus:
    incl %eax
atoi_digit:
    pushl %esi
    movl $0, %ecx
atoi_digit_loop_body:
    movl (%eax), %ebx
    andl $0x000000ff, %ebx
    cmpl number_0, %ebx
    jl atoi_digit_loop_break
    cmpl number_9, %ebx
    jg atoi_digit_loop_break
    subl number_0, %ebx
    pushl %ebx
    incl %ecx
atoi_digit_loop_inc:
    incl %eax
    jmp atoi_digit_loop_body
atoi_digit_loop_break:
    cmpl $0, %ebx
    je atoi_sum_loop_init
    cmpl space, %ebx
    je atoi_sum_loop_init
    cmpl new_line, %ebx
    je atoi_sum_loop_init
    jmp atoi_error
atoi_sum_loop_init:
    movl $0, %esi
    movl $0, %edi
atoi_sum_loop_body:
    popl %eax
    pushl %ecx
    movl %edi, %ecx
atoi_multi_loop_inc:
    cmpl $0, %ecx
    je atoi_multi_loop_break
atoi_multi_loop_body:
    leal (%eax,%eax,4), %eax
    shl $1, %eax
    loop atoi_multi_loop_body
    jmp atoi_multi_loop_break
atoi_multi_loop_break:
    popl %ecx
    addl %eax, %esi
    incl %edi
    loop atoi_sum_loop_body
    movl %esi, %eax
    popl %esi
    xor %ebx, %ebx
    testl %esi, %esi
    jz atoi_return
    notl %eax
    incl %eax
    jmp atoi_return
atoi_sum_loop_inc:
    decl %ecx
atoi_error:
    movl $-1, %ebx
    jmp atoi_return
atoi_return:
    movl %ebp, %esp
    popl %ebp
    ret

main:
    movl 4(%esp), %eax
    cmpl $2, %eax
    jl error

    movl 8(%esp), %eax
    pushl 4(%eax)
    call custom_atoi
    addl $4, %esp

    testl %ebx, %ebx
    jnz error

    pushl %eax
    shl $1, %eax
    pushl %eax
    pushl $printf_output
    call printf
    addl $12, %esp

    xor %eax, %eax
    ret

error:
    movl $1, %eax
    ret
