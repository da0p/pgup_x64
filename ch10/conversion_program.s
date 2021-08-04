.include "linux.s"

.section .data

tmp_buffer:
    .ascii "\0\0\0\0\0\0\0\0\0\0\0\0"

.section .text

.global _start

_start:
    movq    %rsp, %rbp

    pushq   $tmp_buffer         # storage for the result
    pushq   $824                # number to convert
    callq   integer2string
    addq    $16, %rsp    

    pushq   $tmp_buffer
    callq   count_chars
    addq    $8, %rsp

    movq    %rax, %rdx
    movq    $SYS_WRITE, %rax
    movq    $STDOUT, %rdi
    movq    $tmp_buffer, %rsi
    syscall

    pushq   $STDOUT
    callq   write_newline

    movq    $SYS_EXIT, %rax
    movq    $0, %rdi
    syscall


