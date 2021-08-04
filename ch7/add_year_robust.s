.include "linux.s"
.include "record-def.s"

input_filename:
    .ascii "incorrect_filename.dat\0"

no_open_file_code:
    .ascii "0001: \0"

no_open_file_message:
    .ascii "Can't open input file\0"

output_filename:
    .ascii "testout.dat\0"

.section .bss

.lcomm RECORD_BUFFER, RECORD_SIZE

.section .text

.global _start

_start:
    .equ    ST_INPUT_DESCRIPTOR, -8
    .equ    ST_OUTPUT_DESCRIPTOR, -16

    movq    %rsp, %rbp

    # open test.dat

    movq    $SYS_OPEN, %rax
    movq    $input_filename, %rdi
    movq    $0, %rsi
    movq    $0666, %rdx
    syscall
    pushq   %rax                    # push input file descriptor onto stack

    # check to see if there was an error opening the file
    cmpq    $0, %rax
    jge     open_output_file

    pushq   $no_open_file_message
    pushq   $no_open_file_code
    callq   error_exit

open_output_file:
    # open testout.dat
    movq    $SYS_OPEN, %rax
    movq    $output_filename, %rdi
    movq    $0101, %rsi
    movq    $0666, %rdx
    syscall
    pushq   %rax

loop_begin:
    # invoke read_record function
    pushq   ST_INPUT_DESCRIPTOR(%rbp)
    pushq   $RECORD_BUFFER
    callq   read_record
    addq    $16, %rsp

    cmpq    $RECORD_SIZE, %rax
    jne     loop_end

    incq    RECORD_BUFFER + RECORD_AGE

    pushq   ST_OUTPUT_DESCRIPTOR(%rbp)
    pushq   $RECORD_BUFFER
    callq   write_record
    addq    $16, %rsp

    jmp     loop_begin

loop_end:
    movq    $SYS_EXIT, %rax
    movq    $0, %rdi
    syscall
