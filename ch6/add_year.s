.include "linux.s"
.include "record-def.s"

.section .data
input_file_name:
    .ascii  "test.dat\0"

output_file_name:
    .ascii  "testout.dat\0"

.section .bss
.lcomm  RECORD_BUFFER, RECORD_SIZE

# stack offsets of local variables
.equ    ST_INPUT_DESCRIPTOR, -8
.equ    ST_OUTPUT_DESCRIPTOR, -16

.section .text
.global _start
_start:
    movq    %rsp, %rbp      # copy stack pointer and make room for local vars
    subq    $16, %rsp

    movq    $SYS_OPEN, %rax # open file for reading
    movq    $input_file_name, %rdi
    movq    $0, %rsi 
    movq    $0666, %rdx
    syscall
    movq    %rax, ST_INPUT_DESCRIPTOR(%rbp)

    movq    $SYS_OPEN, %rax  # open file for writing
    movq    $output_file_name, %rdi
    movq    $0101, %rsi
    movq    $0666, %rdx
    syscall
    movq    %rax, ST_OUTPUT_DESCRIPTOR(%rbp)

loop_begin:
    pushq   ST_INPUT_DESCRIPTOR(%rbp)
    pushq   $RECORD_BUFFER
    callq    read_record
    addq    $16, %rsp

    # returns the number of bytes read. If itn't the same number we requested
    #, then it's either an end-of-file, or an error, so we're quitting
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

