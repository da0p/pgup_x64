# PURPOSE: Program to illustrate how functions work
#          This program will compute the value of 
#          2^3 + 5^2
#

# Everything in the main program is stored in registers,
# so the data section doesn't have anything.
.section .data

.section .text
.equ    SYS_EXIT, 60

.globl _start

_start:
    pushq   $3                  # pushq second argument
    pushq   $2                  # pushq first argument
    callq    power               # call the function
    addq    $16, %rsp            # movqe the stack pointer back
    pushq   %rax                # save the first answer before calling the 
                                # the next function
    pushq   $2                  # pushq the second argument
    pushq   $5                  # pushq first argument
    call    power               # call the function
    add    $16, %rsp            # movqe the stack pointer back

    popq    %rbx                # The second answer is already in %rax. We 
                                # saved the first answer onto the stack, so now
                                # we can just popq it
                                # out into %rbx
    add    %rax, %rbx          # add them together
    pushq   %rbx

    pushq   $0
    pushq   $2
    call    power 
    add    $16, %rsp
    popq    %rbx
    add    %rax, %rbx

                                # the result is in %rbx
    movq    $SYS_EXIT, %rax            # exit (%rbx is returned)
    movq    %rbx, %rdi
    syscall
# PURPOSE:  This function is used to compute
#           the value of a number raised to a power
#
# INPUT:    First argument - the base number
#           Second argument - the power to raise it to
#
# OUTPUT:   will give the result as a return value
#
# NOTES:    The power must be 1 or greater
#
# VARIABLES: 
#           %rbx - holds the base number
#           %rcx - holds the power
#           -4(%rbp) - holds the current result
#
#           %rax is used for temporary storage
#
.type power, @function
power:
    pushq   %rbp                # save old base pointer
    movq    %rsp, %rbp          # make stack pointer the base pointer
    subq    $8, %rsp            # get room for our local storage

    movq    16(%rbp), %rbx       # put first argument in %rax
    movq    24(%rbp), %rcx      # put second argument in %rcx
    movq    $1, -8(%rbp)
    cmpq    $0, %rcx
    je      end_power
    movq    %rbx, -8(%rbp)      # store current result
    
power_loop_start:
    cmpq    $1, %rcx            # if the power is 1, we are done
    je      end_power
    movq    -8(%rbp), %rax      # movqe the current result into %rax
    imul   %rbx, %rax          # multiply the current result by the base number
    movq    %rax, -8(%rbp)      # store the current result
    decq    %rcx                # decrease the power
    jmp     power_loop_start    # run for the next power

end_power:
    movq    -8(%rbp), %rax      # return value goes in %rax
    movq    %rbp, %rsp          # restore the stack pointer
    popq    %rbp                # retore the base pointer
    ret
