/* JSON parser and JSON generator */

.set UNDEFINED, 0x0
.set NULL, 0x1
.set BOOLEAN, 0x2
.set NUMBER, 0x3
.set STRING, 0x4
.set ARRAY, 0x5
.set OBJECT, 0x6

.set NO_NESTING, 0x0
.set ARRAY_VALUE, 0x1
.set OBJECT_PROPERTY, 0x2
.set OBJECT_VALUE, 0x3

.set MAX_SIZE, 32768

.section .rodata
    parse_number_table:
        .long parse_number_even_mode
        .long parse_number_odd_mode
        .long parse_number_even_mode
        .long parse_number_odd_mode
        .long parse_number_even_mode

.bss
    input:
        .space MAX_SIZE
    buffer:
        .space MAX_SIZE
    output:
        .space MAX_SIZE

.text
    .globl _start



_start:
    movl 8(%esp), %ebx

open:
    movl $5, %eax
    movl $0, %ecx /* read only mode */
    int $0x80
    testl %eax, %eax
    cmpl $0, %eax
    jl error
    pushl %eax

read:
    movl $3, %eax
    movl (%esp), %ebx
    movl $input, %ecx
    movl $MAX_SIZE, %edx
    int $0x80
    testl %eax, %eax
    jz error

close:
    movl $6, %eax
    popl %ebx
    int $0x80

parsing:
    pushl $NO_NESTING
    pushl $buffer
    pushl $input
    call parse_json
    addl $12, %esp

    testl %eax, %eax
    jz error

generating:
    pushl $NO_NESTING
    pushl $output
    pushl %eax
    call generate_json
    addl $12, %esp

printing:
    movl $4, %eax
    movl $1, %ebx
    movl $output, %ecx
    movl $MAX_SIZE, %edx
    int $0x80

exit:
    movl $1, %eax
    xor %ebx, %ebx
    int $0x80

error:
    movl $1, %eax
    movl $1, %ebx
    int $0x80



parse_json:
    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp

    movb $UNDEFINED, %al
    movb %al, -4(%ebp) /* mode_type */
    movb $0, %al
    movb %al, -8(%ebp) /* mode_content */
    movb %al, -12(%ebp) /* mode_number */
    movb %al, -16(%ebp) /* mode_escaping */

    xorl %eax, %eax
    movl 8(%ebp), %esi
    movl 12(%ebp), %edi
parse_json_character_load:
    lodsb

    movb -4(%ebp), %bl
    cmpb $NULL, %bl
    je parse_null
    cmpb $BOOLEAN, %bl
    je parse_boolean
    cmpb $NUMBER, %bl
    je parse_number
    cmpb $STRING, %bl
    je parse_string
    cmpb $ARRAY, %bl
    je parse_array
    cmpb $OBJECT, %bl
    je parse_object

    cmpb $' ', %al
    je parse_json_character_load
    cmpb $'\n', %al
    je parse_json_character_load
    cmpb $'\t', %al
    je parse_json_character_load
    cmpb $'"', %al
    je enter_string_mode
    movb 16(%ebp), %bl
    cmpb $OBJECT_PROPERTY, %bl
    je end_object_property

    cmpb $'n', %al
    je enter_null_mode
    cmpb $'t', %al
    je enter_boolean_mode
    cmpb $'f', %al
    je enter_boolean_mode
    cmpb $'0', %al
    setge %bl
    cmpb $'9', %al
    setle %cl
    andb %cl, %bl
    jnz enter_number_mode
    cmpb $'-', %al
    je enter_number_mode
    cmpb $'[', %al
    je enter_array_mode
    cmpb $'{', %al
    je enter_object_mode

    movb 16(%ebp), %bl
    cmpb $NO_NESTING, %bl
    je end_no_nesting
    cmpb $ARRAY_VALUE, %bl
    je end_array_value
    cmpb $OBJECT_VALUE, %bl
    je end_object_value

    jmp parse_json_error
parse_json_character_store:
    stosb
    movb $1, %al
    movb %al, -8(%ebp)
    jmp parse_json_character_load

parse_json_error:
    movl $0, %eax
    jmp parse_json_return
parse_json_return_property:
parse_json_return_value:
    movb -8(%ebp), %al
    testb %al, %al
    jnz parse_json_return_json
    movl $1, %eax
    jmp parse_json_return
parse_json_return_json:
    movl 12(%ebp), %eax
parse_json_return:
    movl %ebp, %esp
    popl %ebp
    ret



end_no_nesting:
    cmpb $0, %al
    jne parse_json_error
    stosb
    jmp parse_json_return_json
end_array_value:
    cmpb $',', %al
    je parse_json_return_value
    cmpb $']', %al
    je parse_json_return_value
    jmp parse_json_error
end_object_property:
    cmpb $':', %al
    je parse_json_return_property
    cmpb $'}', %al
    je parse_json_return_property
    jmp parse_json_error
end_object_value:
    cmpb $',', %al
    je parse_json_return_value
    cmpb $'}', %al
    je parse_json_return_value
    jmp parse_json_error



enter_null_mode:
    movb $NULL, %al
    jmp enter_any_mode
enter_boolean_mode:
    movb $BOOLEAN, %al
    jmp enter_any_mode
enter_number_mode:
    movb $0, %al
    movb %al, -12(%ebp)
    decl %esi
    movb $NUMBER, %al
    jmp enter_any_mode
enter_string_mode:
    movb $0, %al
    movb %al, -16(%ebp)
    movb $STRING, %al
    jmp enter_any_mode
enter_array_mode:
    xorl %ecx, %ecx
    movb $ARRAY, %al
    jmp enter_any_mode
enter_object_mode:
    xorl %ecx, %ecx
    movb $OBJECT, %al
    jmp enter_any_mode
enter_any_mode:
    movb %al, -4(%ebp)
    jmp parse_json_character_store



parse_null:
    cmpb $'u', %al
    sete %cl
    movb (%esi), %al
    cmpb $'l', %al
    sete %dl
    andb %dl, %cl
    movb 1(%esi), %al
    cmpb $'l', %al
    sete %dl
    andb %dl, %cl
    jz parse_json_error
    addl $2, %esi
    movb $UNDEFINED, %bl
    movb %bl, -4(%ebp)
    jmp parse_json_character_load

parse_boolean:
    cmpb $'r', %al
    je parse_boolean_true
    cmpb $'a', %al
    je parse_boolean_false
    jmp parse_json_error
parse_boolean_true:
    movb (%esi), %al
    cmpb $'u', %al
    sete %dl
    movb 1(%esi), %al
    cmpb $'e', %al
    sete %cl
    andb %dl, %cl
    jz parse_json_error
    addl $2, %esi
    movb $1, %al
    movb $UNDEFINED, %bl
    movb %bl, -4(%ebp)
    jmp parse_json_character_store
parse_boolean_false:
    movb (%esi), %al
    cmpb $'l', %al
    sete %dl
    movb 1(%esi), %al
    cmpb $'s', %al
    sete %cl
    andb %dl, %cl
    movb 2(%esi), %al
    cmpb $'e', %al
    sete %cl
    andb %dl, %cl
    jz parse_json_error
    addl $3, %esi
    movb $0, %al
    movb $UNDEFINED, %bl
    movb %bl, -4(%ebp)
    jmp parse_json_character_store

parse_number:
    movb -12(%ebp), %bl
    testb %bl, %bl
    jz parse_number_sign
parse_number_digit:
    cmpb $'0', %al
    setge %cl
    cmpb $'9', %al
    setle %dl
    andb %dl, %cl
    jz parse_number_point
    jmp *parse_number_table(,%ebx,4)
parse_number_odd_mode:
    incb %bl
    movb %bl, -12(%ebp)
parse_number_even_mode:
    jmp parse_json_character_store
parse_number_point:
    cmpb $2, %bl
    sete %cl
    cmpb $'.', %al
    sete %dl
    andb %dl, %cl
    jz parse_number_exit
    incb %bl
    movb %bl, -12(%ebp)
    jmp parse_json_character_store
parse_number_sign:
    incb %bl
    movb %bl, -12(%ebp)
    cmpb $'-', %al
    je parse_json_character_store
    jmp parse_number_digit
parse_number_exit:
    cmpb $1, %bl
    jz parse_json_error
    cmpb $3, %bl
    jz parse_json_error
    decl %esi
    movb $0, %al
    movb $UNDEFINED, %bl
    movb %bl, -4(%ebp)
    jmp parse_json_character_store

parse_string:
    cmpb $'\n', %al
    je parse_json_error
    movb -16(%ebp), %bl
    testb %bl, %bl
    jnz parse_string_escaped
    cmpb $'\\', %al
    je parse_string_slash
    cmpb $'"', %al
    je parse_string_quote
    jmp parse_json_character_store
parse_string_escaped:
    xorb %bl, %bl
    movb %bl, -16(%ebp)
    cmpb $'b', %al
    je parse_string_escaped_backspace
    cmpb $'f', %al
    je parse_string_escaped_form_feed
    cmpb $'n', %al
    je parse_string_escaped_new_line
    cmpb $'r', %al
    je parse_string_escaped_return
    cmpb $'t', %al
    je parse_string_escaped_tab
    jmp parse_json_character_store
parse_string_escaped_backspace:
    movb $'\b', %al
    jmp parse_json_character_store
parse_string_escaped_form_feed:
    movb $'\f', %al
    jmp parse_json_character_store
parse_string_escaped_new_line:
    movb $'\n', %al
    jmp parse_json_character_store
parse_string_escaped_return:
    movb $'\r', %al
    jmp parse_json_character_store
parse_string_escaped_tab:
    movb $'\t', %al
    jmp parse_json_character_store
parse_string_slash:
    movb $1, %bl
    movb %bl, -16(%ebp)
    jmp parse_json_character_load
parse_string_quote:
    movb $0, %al
    movb $UNDEFINED, %bl
    movb %bl, -4(%ebp)
    jmp parse_json_character_store

parse_array:
    decl %esi

    pushl %ecx
    pushl $ARRAY_VALUE
    pushl %edi
    pushl %esi
    call parse_json
    movl %eax, %edx
    addl $12, %esp
    testb %al, %al
    popl %ecx
    jz parse_json_error

    incl %ecx
    decl %esi
    lodsb
    cmpb $',', %al
    jne parse_array_end
    cmpb $1, %dl
    je parse_json_error /* comma after empty item */
    incl %esi
    jmp parse_array
parse_array_end:
    cmpl $1, %ecx
    setg %cl
    cmpb $1, %dl
    sete %dl
    andb %cl, %dl
    jnz parse_json_error /* empty (and not first) item before end of array */
    cmpb $']', %al
    jne parse_json_error
    movb $0, %al
    movb $UNDEFINED, %bl
    movb %bl, -4(%ebp)
    jmp parse_json_character_store

parse_object:
    decl %esi
    pushl %ecx

    pushl $OBJECT_PROPERTY
    pushl %edi
    pushl %esi
    call parse_json
    addl $12, %esp
    testb %al, %al
    jz parse_json_error
    cmpb $1, %al
    je parse_object_empty_property

    pushl $OBJECT_VALUE
    pushl %edi
    pushl %esi
    call parse_json
    addl $12, %esp
    testb %al, %al
    jz parse_json_error
    cmpb $1, %al
    je parse_json_error

    popl %ecx
    incl %ecx
    decl %esi
    lodsb
    cmpb $',', %al
    jne parse_object_end
    incl %esi
    jmp parse_object
parse_object_empty_property:
    movb -1(%esi), %al
    testl %ecx, %ecx
    jnz parse_json_error
parse_object_end:
    cmpb $'}', %al
    jne parse_json_error
    movb $0, %al
    movb $UNDEFINED, %bl
    movb %bl, -4(%ebp)
    jmp parse_json_character_store



generate_json:
    pushl %ebp
    movl %esp, %ebp

    xorl %eax, %eax
    movl 8(%ebp), %esi
    movl 12(%ebp), %edi

generate_json_character_load:
    lodsb
    cmpb $NULL, %al
    je generate_null
    cmpb $BOOLEAN, %al
    je generate_boolean
    cmpb $NUMBER, %al
    je generate_number
    cmpb $STRING, %al
    je generate_string
    cmpb $ARRAY, %al
    je generate_array
    cmpb $OBJECT, %al
    je generate_object
    cmpb $0, %al
    je generate_end
    jmp generate_json_error
generate_json_error:
    movl $0, %eax
    jmp generate_json_return
generate_json_return_string:
    movl 16(%ebp), %eax
    cmpb $NO_NESTING, %al
    je generate_json_character_load
    movl 12(%ebp), %eax
generate_json_return:
    movl %ebp, %esp
    popl %ebp
    ret



generate_null:
    movl $0x6c6c756e, %eax /* null */
    stosl
    jmp generate_json_return_string

generate_boolean:
    lodsb
    testb %al, %al
    je generate_boolean_false
generate_boolean_true:
    movl $0x65757274, %eax /* true */
    stosl
    jmp generate_json_return_string
generate_boolean_false:
    movl $0x736c6166, %eax /* fals */
    stosl
    movb $'e', %al
    stosb
    jmp generate_json_return_string

generate_number:
    lodsb
    testb %al, %al
    je generate_json_return_string
    stosb
    jmp generate_number

generate_string:
    movb $'"', %al
    stosb
generate_string_character_load:
    lodsb
    testb %al, %al
    je generate_string_end
    cmpb $'\b', %al
    je generate_string_backspace
    cmpb $'\f', %al
    je generate_string_form_feed
    cmpb $'\n', %al
    je generate_string_new_line
    cmpb $'\r', %al
    je generate_string_return
    cmpb $'\t', %al
    je generate_string_tab
    cmpb $'"', %al
    je generate_string_quote
    cmpb $'\\', %al
    je generate_string_slash
generate_string_character_store:
    stosb
    jmp generate_string_character_load
generate_string_backspace:
    movb $'b', %bl
    jmp generate_string_special_character
generate_string_form_feed:
    movb $'f', %bl
    jmp generate_string_special_character
generate_string_new_line:
    movb $'n', %bl
    jmp generate_string_special_character
generate_string_return:
    movb $'r', %bl
    jmp generate_string_special_character
generate_string_tab:
    movb $'t', %bl
    jmp generate_string_special_character
generate_string_quote:
    movb $'"', %bl
    jmp generate_string_special_character
generate_string_slash:
    movb $'\\', %bl
    jmp generate_string_special_character
generate_string_special_character:
    movb $'\\', %al
    stosb
    movb %bl, %al
    jmp generate_string_character_store
generate_string_end:
    movb $'"', %al
    stosb
    jmp generate_json_return_string

generate_array:
    movb $'[', %al
    stosb
    xorl %ecx, %ecx
generate_array_item:
    lodsb
    testb %al, %al
    je generate_array_end
    decl %esi
    pushl %ecx
    pushl $ARRAY_VALUE
    pushl %edi
    pushl %esi
    call generate_json
    addl $12, %esp
    popl %ecx
    incl %ecx
    movb $',', %al
    stosb
    jmp generate_array_item
generate_array_end:
    xorl %eax, %eax
    testl %ecx, %ecx
    setnz %al
    subl %eax, %edi
    movb $']', %al
    stosb
    jmp generate_json_return_string

generate_object:
    movb $'{', %al
    stosb
    xorl %ecx, %ecx
generate_object_item:
    lodsb
    testb %al, %al
    je generate_object_end

    pushl %ecx
    decl %esi
    pushl $OBJECT_PROPERTY
    pushl %edi
    pushl %esi
    call generate_json
    addl $12, %esp
    movb $':', %al
    stosb

    pushl $OBJECT_VALUE
    pushl %edi
    pushl %esi
    call generate_json
    addl $12, %esp
    popl %ecx
    incl %ecx
    movb $',', %al
    stosb
    jmp generate_object_item
generate_object_end:
    xorl %eax, %eax
    testl %ecx, %ecx
    setnz %al
    subl %eax, %edi
    movb $'}', %al
    stosb
    jmp generate_json_return_string

generate_end:
    movw $0x000a, %ax /* new line and end of string */
    stosw
    movl 12(%ebp), %eax
    jmp generate_json_return
