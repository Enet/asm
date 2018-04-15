.section .rodata
    .set std_out, 1
    .set read_only, 0
    .set buffer_length, 5
    path:
        .string "file.txt"

.data
    buffer:
        .string ""

.text
    .globl main

main:
open:
    movl $5, %eax
    movl $path, %ebx
    movl $read_only, %ecx
    int $0x80
    cmpl $0, %eax
    jl error
    pushl %eax
    movl $0, %eax
    movl $buffer, %ebp

read:
    addl %eax, %ebp
    movl $3, %eax
    movl (%esp), %ebx
    movl %ebp, %ecx
    movl $buffer_length, %edx
    pushl %ecx
    int $0x80
    popl %ecx
    testl %eax, %eax

printf:
    movl $4, %eax
    movl $std_out, %ebx
    movl $buffer_length, %edx
    int $0x80

    jnz read

close:
    movl $6, %eax
    movl (%esp), %ebx
    int $0x80

exit:
    addl $4, %esp
    xor %eax, %eax
    ret

error:
    movl $1, %eax
    ret
