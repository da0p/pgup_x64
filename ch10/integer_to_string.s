# PURPOSE: Convert an integer number to a decimal string for display
#
# INPUT:   A buffer large enough to hold the largest possible number
#          An integer to convert
#
# OUTPUT:  The buffer will be overwritten with the decimal string
#
# Variables: 
#          %rcx will hold the count of characters processed
#          %rax will hold the current value
#          %rdi will hold the base (10)
#
.equ ST_VALUE, 16
.equ ST_BUFFER, 24

.global integer2string
.type integer2string, @function

integer2string:
    pushq   %rbp
    movq   %rsp, %rbp

    movq    $0, %rcx                # current character count
    movq    ST_VALUE(%rbp), %rax    # move the value into position
    movq    $10, %rdi               # must be in a register or memory location

conversion_loop:
    movq    $0, %rdx                # division is actually performed on the
                                    # %rdx:%rax register, so first clear out
                                    # %rdx 
    divq    %rdi                    # divide %rdx:rax (which are implied) by 10.
                                    # store the quotient in %rax and the
                                    # remainder in %rdx (both of which are
                                    # implied). 
    addq    $'0', %rdx              # convert the remainder into string
    pushq   %rdx 
    incq    %rcx                    # increment digit counts
    cmpq    $0, %rax                # check if %rax is zero
    je      end_conversion_loop

    jmp     conversion_loop

end_conversion_loop:
    movq    ST_BUFFER(%rbp), %rdx   # get the pointer to the buffer in %rdx

copy_reversing_loop:
    popq    %rax
    movb    %al, (%rdx)
    decq    %rcx                    # decrease rcx so that we know when we
                                    # finish
    incq    %rdx                    # increase %rdx so that it will be pointing
                                    # to the next byte
    cmpq    $0, %rcx                # check whether we finished
    je      end_copy_reversing_loop # jump to the end if finished
    jmp     copy_reversing_loop     # otherwise, repeat the loop

end_copy_reversing_loop:
    movb    $0, (%rdx)              # NULL

    movq    %rbp, %rsp
    popq    %rbp
    ret
