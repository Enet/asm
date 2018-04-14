.section .rodata
    scanf_number:
        .string "%d"
    printf_size:
        .string "Enter the size of table (%d-%d):\n"
    printf_cell:
        .string "%5d"
    printf_newline:
        .string "\n"
    printf_error:
        .string "Invalid size!\n"
    min_size:
        .long 1
    max_size:
        .long 30
    exit_code_success:
        .long 0
    exit_code_error:
        .long 1

.data
    size:
        .long 0

.text
    .globl main

main:
    pushl max_size
    pushl min_size
    pushl $printf_size
    call printf
    addl $12, %esp

    pushl $size
    pushl $scanf_number
    call scanf
    addl $8, %esp

    movl size, %eax
    cmpw min_size, %ax
    jl error
    cmpw max_size, %ax
    jg error

    incl %eax
    movl %eax, size
    movl $1, %ecx

row:
    movl $1, %ebx

cell:
    call multiply

cell_done:
    incl %ebx
    cmpl size, %ebx
    jne cell

row_done:
    pushl %ecx
    pushl $printf_newline
    call printf
    addl $4, %esp
    popl %ecx

    incl %ecx
    cmpl size, %ecx
    jne row

    jmp end

multiply:
    movl %ebx, %eax
    mull %ecx

    pushl %ebx
    pushl %ecx
    pushl %eax
    pushl $printf_cell
    call printf
    addl $8, %esp
    popl %ecx
    popl %ebx

    ret

error:
    pushl $printf_error
    call printf
    addl $4, %esp
    movl exit_code_error, %eax
    ret

end:
    movl exit_code_success, %eax
    ret
