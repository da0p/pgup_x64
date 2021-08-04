.include "linux.s"
.equ    ST_ERROR_CODE, 16
.equ    ST_ERROR_MSG, 24

.global     error_exit
.type       error_exit, @function

error_exit:
    pushq   %rbp
    movq    %rsp, %rbp

    # write out error code
    movq    ST_ERROR_CODE(%rbp), %rsi
    pushq   %rsi
    callq   count_chars
    popq    %rsi
    movq    %rax, %rdx
    movq    $STDERR, %rdi
    movq    $SYS_WRITE, %rax
    syscall

    # write out the error message
    movq    ST_ERROR_MSG(%rbp), %rsi
    pushq   %rsi
    callq   count_chars
    popq    %rsi
    movq    %rax, %rdx
    movq    $STDERR, %rdi
    movq    $SYS_WRITE, %rax
    syscall

    movq    $SYS_EXIT, %rax
    movq    $1, %rdi
    syscall
