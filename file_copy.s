.section .rodata
    .set access_mode, 511
    .set read_only, 0

.bss
    buffer:
        .space 128
        .set buffer_length, . - buffer
    input_fd:
        .space 4
    output_fd:
        .space 4

.text
    .globl main

main:
prolog:
    pushl %ebp
    movl %esp, %ebp

arguments:
    movl 12(%ebp), %esi

input_open:
    movl $5, %eax
    movl 4(%esi), %ebx
    movl $read_only, %ecx
    int $0x80
    cmpl $0, %eax
    jl error
    movl %eax, input_fd

output_open:
    movl $8, %eax
    movl 8(%esi), %ebx
    movl $access_mode, %ecx
    int $0x80
    cmpl $0, %eax
    jl error
    movl %eax, output_fd

input_read:
    movl $3, %eax
    movl input_fd, %ebx
    movl $buffer, %ecx
    movl $buffer_length, %edx
    int $0x80
    cmpl $0, %eax
    jl error
    pushl %eax

output_write:
    movl $4, %eax
    movl output_fd, %ebx
    movl $buffer, %ecx
    movl (%esp), %edx
    int $0x80
    cmpl $0, %eax
    jl error

rw_loop:
    popl %eax
    cmpl $0, %eax
    jg input_read

io_close:
    movl $6, %eax
    movl input_fd, %ebx
    int $0x80
    movl $6, %eax
    movl output_fd, %ebx
    int $0x80

epilog:
    xor %eax, %eax

end:
    movl %ebp, %esp
    popl %ebp
    ret

error:
    jmp end
