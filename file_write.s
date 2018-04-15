.section .rodata
    .set access_mode, 511
    path:
        .string "file.txt"
    buffer:
        .string "Hello world!\n0123456789\n"
        .set buffer_length, . - buffer - 1

.text
    .globl main

main:
create:
    movl $8, %eax
    movl $path, %ebx
    movl $access_mode, %ecx
    int $0x80
    cmpl $0, %eax
    jl error
    pushl %eax
write:
    movl $4, %eax
    movl (%esp), %ebx
    movl $buffer, %ecx
    movl $buffer_length, %edx
    int $0x80
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
