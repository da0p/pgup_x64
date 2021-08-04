# PURPOSE - Given a number, this program computes the
#           factorial. For example, the factorial of 
#           3 is 3 * 2 * 1, or 6. The factorial of 
#           4 is 4 * 3 * 2 * 1, or 24, and so on.

# This program shows how to call a function recursively.
.section .data

# This program has no global data
.section .text
.equ    SYS_EXIT, 60

.globl _start
.globl factorial                    # this is unndeeded unless we want to share
                                    # this function among other programs

_start:
    push   $4                      # The factorial takes one argument - the 
                                    # number we want a factorial of. So, it gets 
                                    # pushed
    call    factorial               # run the factorial function
    add    $8, %rsp                # Scrubs the parameter that was pushed on
                                    # the stack
    mov    %rax, %rdi              # factorial returns the answer in %rax, but 
                                    # we want it in %rbx to send it as our exit
                                    # status
    mov    $SYS_EXIT, %rax                # call the kernel's exit function
    syscall

.type factorial, @function
factorial:
    push   %rbp                    # standard function stuff - we have to
                                    # restore %rbp to its prior state before
                                    # returning so we have to push it
    mov    %rsp, %rbp              # This is because we don't want to modify
                                    # the stack pointer, so we use %rbp

    mov    16(%rbp), %rax           # This moves the first argument to %rax
                                    # 4(%rbp) holds the return address, and
                                    # 8(%rbp) holds the first parameter
    cmp    $1, %rax                # If the number is 1, that is our base
                                    # case, and we simply return (1 is already
                                    # in %rax as the return value)
    je      end_factorial
    dec    %rax                    # otherwise, decrease the value
    push   %rax                    # push it for our call to factorial
    call    factorial               # call factorial
    mov    16(%rbp), %rbx           # %rax has the return value, so we reload
                                    # our parameter into %rbx
    imul   %rbx, %rax              # multiply that by the result of the last 

                                    # call to factorial (in %rax) the answer
                                    # is stored in %rax, which is good since 
                                    # that's where return values go.
end_factorial:
    mov     %rbp, %rsp              # standard function return stuff - we
    pop     %rbp                    # have to restore %rbp and %rsp to where 
                                    # they werre before the function started
    ret      
   
