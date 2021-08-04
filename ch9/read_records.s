.include "linux.s"
.include "record-def.s"

.section    .data
record_buffer_ptr:
    .quad 0

filename:
    .ascii  "test.data\0"

.section    .bss

.section    .text
.global     _start

_start:

.equ        ST_INPUT_DESCRIPTOR, -8
.equ        ST_OUTPUT_DESCRIPTOR, -16
   
   movq      %rsp, %rbp              # copy the stack pointer to rbp
   subq      $16, %rbp                # allocate space to hold file descriptors

   callq     allocate_init
   
   pushq     $RECORD_SIZE
   callq     allocate
   movq      %rax, record_buffer_ptr

   # open the test.dat
   movq      $SYS_OPEN, %rax
   movq      $filename, %rdi
   movq      $0, %rsi
   movq      $0666, %rdx
   syscall

   movq     %rax, ST_INPUT_DESCRIPTOR(%rbp)

   # Enven though it's a constant, we are saving the output file descriptor
   # in a local variable so that if we later decide that it isn't always
   # going to be STDOUT, we can change it easily.
   movq     $STDOUT, ST_OUTPUT_DESCRIPTOR(%rbp)

record_read_loop:
   pushq    ST_INPUT_DESCRIPTOR(%rbp)
   pushq    record_buffer_ptr
   call     read_record
   addq     $16, %rsp

   cmpq     $RECORD_SIZE, %rax      # returns the number of byte read.
                                    # if it isn't the same number we
                                    # requested, then it's either an
                                    # end-of-file, or an error, so we're quitting
   cmpq     $RECORD_SIZE, %rax
   jne      finished_reading

   movq     record_buffer_ptr, %rax  # otherwise, print out firstname
   addq     $RECORD_FIRSTNAME, %rax
   pushq    %rax 
   call     count_chars
   addq     $8, %rsp

   movq     %rax, %rdx 
   movq     ST_OUTPUT_DESCRIPTOR(%rbp), %rdi
   movq     $SYS_WRITE, %rax
   movq     record_buffer_ptr, %rsi
   addq     $RECORD_FIRSTNAME, %rsi
   syscall

   pushq    ST_OUTPUT_DESCRIPTOR(%rbp)
   call     write_newline
   addq     $8, %rsp

   jmp      record_read_loop

finished_reading:
    pushq   record_buffer_ptr
    callq   deallocate

    movq    $SYS_EXIT, %rax
    movq    $0, %rdi
    syscall
