# PURPOSE: Count the characters until a null byte is reached.
# 
# INPUT:   The address of the character string
#
# OUTPUT:  Returns the count in %eax
# 
# PROCESS: 
#   Registers used:
#       %ecx - character count
#       %al  - current character
#       %edx - current character address

.section .text

.type count_chars, @function
.global count_chars

# This is where our one parameter is on the stack
.equ    ST_STRING_START_ADDRESS, 16
count_chars:
    pushq    %rbp
    movq     %rsp, %rbp

    movq     $0, %rcx            # counter starts at 0
    movq     ST_STRING_START_ADDRESS(%rbp), %rdx    # starting address of data

count_loop_begin:
    movb    (%rdx), %al         # grab the current character
    cmpb    $0, %al
    je      count_loop_end      # if the character is NULL, we are done
    incq     %rcx                # otherwise, increase the counter
    incq     %rdx                
    jmp     count_loop_begin    # go back to the beginning of loop

count_loop_end:
    movq     %rcx, %rax          # we're done. Move the count into %eax and
                                # return
    movq     %rbp, %rsp

    popq     %rbp
    ret
    
