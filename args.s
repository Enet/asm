.section .rodata
    printf_argc:
        .string "argc: %d\n"
    printf_argv:
        .string "argv[%d]: %s\n"

.text
    .globl main

main:
prolog:
    pushl %ebp
    movl %esp, %ebp

body:
    pushl 8(%ebp)
    pushl $printf_argc
    call printf
    addl $8, %esp

loop_init:
    movl 12(%ebp), %eax
    movl $-1, %ecx
    jmp loop_inc

loop_body:
    pushl %ecx
    pushl %eax

    pushl (%eax,%ecx,4)
    pushl %ecx
    pushl $printf_argv
    call printf
    addl $12, %esp

    popl %eax
    popl %ecx

loop_inc:
    incl %ecx
    cmpl 8(%ebp), %ecx
    jne loop_body

epilog:
    movl %ebp, %esp
    popl %ebp
end:
    xor %eax, %eax
    ret
