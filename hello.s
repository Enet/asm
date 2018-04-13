.section .rodata
    .set write_system_call, 4
    .set std_out, 1
    .set interruption_code, 0x80
    .set exit_code_success, 0

    hello_world:
        .string "Hello world!\n"
        .set hello_world_length, . - hello_world - 1

.text
    .globl main

main:
    movl $write_system_call, %eax
    movl $std_out, %ebx
    movl $hello_world, %ecx
    movl $hello_world_length, %edx
    int $interruption_code

    movl $exit_code_success, %eax
    ret
