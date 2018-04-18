.section .rodata
    printf_output:
        .string "%s\nLength of string: %d\n"
    data:
        .string "Hello world!"

.text
    .globl main

main:
    movl $0xffffffff, %ecx
    xor %eax, %eax
    movl $data, %edi
    repne scasb
    not %ecx
    decl %ecx

    pushl %ecx
    pushl $data
    pushl $printf_output
    call printf
    addl $12, %esp

    xor %eax, %eax
    ret
