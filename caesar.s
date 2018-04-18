.section .rodata
    printf_shift:
        .string "Enter the shift (0-26):\n"
    printf_input:
        .string "Enter the message:\n"
    printf_output:
        .string "Encoded data:\n%s"
    printf_error:
        .string "Wrong shift!\n"
    scanf_number:
        .string "%d"
    upper_min_charcode:
        .long 65
    upper_max_charcode:
        .long 90
    lower_min_charcode:
        .long 97
    lower_max_charcode:
        .long 122
    newline:
        .asciz "\n"

.bss
    data:
        .space 128
        .set data_length, . - data

.data
    shift:
        .long 0

.text
    .globl main

main:
input_shift:
    pushl $printf_shift
    call printf

    pushl $shift
    pushl $scanf_number
    call scanf
    addl $12, %esp

    movl shift, %eax
    cmpl $0, %eax
    jl error
    cmpl $26, %eax
    jg error

input_data:
    /* handle new line character */
    pushl stdin
    call fgetc

    pushl $printf_input
    call printf

    pushl stdin
    pushl $data_length
    pushl $data
    call fgets
    addl $20, %esp

    /* reset %eax before reading from stream */
    xor %eax, %eax
    /* use the same stream for reading and writing */
    movl $data, %esi
    movl $data, %edi

load_char:
    lodsb
check_char:
    /* charcode < upper_min_charcode */
    cmpl upper_min_charcode, %eax
    jl store_char
    /* charcode > lower_max_charcode */
    cmpl lower_max_charcode, %eax
    jg store_char
    /* charcode > upper_max_charcode && charcode < lower_min_charcode */
    cmpl upper_max_charcode, %eax
    setg %cl
    cmpl lower_min_charcode, %eax
    setl %bl
    andb %cl, %bl
    jnz store_char
shift_char:
    movl %eax, %ebx
    addl shift, %eax
    cmpl upper_max_charcode, %ebx
    jg 1f
0:
    cmpl upper_max_charcode, %eax
    jg normalize_char
    jmp store_char
1:
    cmpl lower_max_charcode, %eax
    jg normalize_char
    jmp store_char
normalize_char:
    subl $26, %eax
store_char:
    stosb
    cmpl newline, %eax
    jne load_char

output_data:
    pushl $data
    pushl $printf_output
    call printf
    addl $8, %esp

end:
    xor %eax, %eax
    ret

error:
    pushl $printf_error
    call printf
    addl $4, %esp
    movl $1, %eax
    ret
