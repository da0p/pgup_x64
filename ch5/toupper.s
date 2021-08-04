# PURPOSE:  This program converts an input file
#           to an output file with all letters
#           converted to uppercase
# PROCESSING: 1) Open the input file
#             2) Open the output file
#             3) While we're not at the end of the input file
#                a) read part of file into our memory buffer
#                b) go through each byte of memory, if the byte is a lower-case
#                   letter, convert it to uppercase
#                c) write the memory buffer to output file

.section    .data

# System call numbers
.equ        SYS_OPEN, 2
.equ        SYS_WRITE, 1
.equ        SYS_READ, 0
.equ        SYS_CLOSE, 3
.equ        SYS_EXIT, 60

# Options for open (look at /usr/incude/asm/fcntl.h for variaous values. You
# can combine them by adding them or ORing them). 
.equ        O_RDONLY, 0
.equ        O_CREAT_WRONLY_TRUNC, 03101

# System call interrupt
.equ        END_OF_FILE, 0                  # This is the return value
                                            # of read which means we've
                                            # hit the end of the file
.section    .bss
# Buffer - this is where the data is loaded into/from the data file and written
#          into/from the output file. This should never exceed 16,000 for
#          various reasons.
.equ        BUFFER_SIZE, 500
.lcomm      BUFFER_DATA, BUFFER_SIZE

.section    .text
# Stack positions
.equ        ST_SIZE_RESERVE, 16
.equ        ST_FD_IN, -8
.equ        ST_FD_OUT, -16
.equ        ST_ARGC, 0                  # Number of arguments
.equ        ST_ARGV_0, 8                # Name of program
.equ        ST_ARGV_1, 16                # Input file name
.equ        ST_ARGV_2, 24               # Output file name

.globl      _start
_start:
    mov    %rsp, %rbp                  # save the stack pointer
    sub    $ST_SIZE_RESERVE, %rsp      # allocate space for our file
                                        # descriptors on the stack
open_files:

open_fd_in:                             # open input file
    mov    $SYS_OPEN, %rax             # open syscall
    mov    ST_ARGV_1(%rbp), %rdi       # input filename into %rbx
    mov    $O_RDONLY, %rsi             # this doesn't really matter for reading
    mov    $0666, %rdx
    syscall

store_fd_in:
    mov    %rax, ST_FD_IN(%rbp)        # save the given file descriptor

open_fd_out:
    mov    $SYS_OPEN, %rax             # open the file
    mov    ST_ARGV_2(%rbp), %rdi       # output filename into %rbx
    mov    $O_CREAT_WRONLY_TRUNC, %rsi # flags for writing to the file
    mov    $0666, %rdx                 # mode for new file (if it's created)
    syscall

store_fd_out:
    mov    %rax, ST_FD_OUT(%rbp)       # store the file descriptor here

read_loop_begin:                        # _start
    mov    $SYS_READ, %rax             # read in a block from the input file
    mov    ST_FD_IN(%rbp), %rdi        # get the input file descriptor
    mov    $BUFFER_DATA, %rsi          # the location to read into
    mov    $BUFFER_SIZE, %rdx          # the size of the buffer
    syscall

    cmp    $END_OF_FILE, %rax          # check for end of file marker
    jle     end_loop                    # if found or on error, go to the end

continute_read_loop:
    push   $BUFFER_DATA                # location of buffer
    push   %rax                        # size of the buffer
    call    convert_to_upper 
    pop    %rax                        # get the size back
    add    $8, %rsp                    # restore %rsp
    mov    %rax, %rdx                  # write the block out to the output file
                                        # size of the buffer
    mov    $SYS_WRITE, %rax            
    mov    ST_FD_OUT(%rbp), %rdi       # file to use
    mov    $BUFFER_DATA, %rsi          # location of the buffer
    syscall

# continue the loop
    jmp     read_loop_begin

end_loop:
    mov    $SYS_CLOSE, %rax
    mov    ST_FD_OUT(%rbp), %rdi
    syscall

    mov    $SYS_CLOSE, %rax
    mov    ST_FD_IN(%rbp), %rdi 
    syscall

    mov    $SYS_EXIT, %rax
    mov    $0, %rdi 
    syscall

# PURPOSE: This function actually does the conversion to upper case for a block
#
# INPUT:   The first parameter is the location of the block of memory to convert
#          The second parameter is the length of that buffer
#
# OUTPUT:  This function overwrites the current buffer with the upper-classified
#          version.
# VARIABLES: 
#          %rax - beginning of buffer
#          %rbx - length of buffer
#          %rdi - curent buffer offset
#          %cl - current byte being examined (first part of %rcx)
#

# Constants #
.equ    LOWERCASE_A, 'a'                # The lower boundary of our search
.equ    LOWERCASE_Z, 'z'                # The upper boundary of our search
.equ    UPPER_CONVERSION, 'A' - 'a'     # Conversion between upper and lower
                                        # case
# Stack stuff #
.equ    ST_BUFFER_LEN, 16                # Length of buffer
.equ    ST_BUFFER, 24                   # actual buffer

convert_to_upper:
    push   %rbp
    mov    %rsp, %rbp

    mov    ST_BUFFER(%rbp), %rax 
    mov    ST_BUFFER_LEN(%rbp), %rbx
    mov    $0, %rdi

    cmp    $0, %rbx                    # if a buffer with zero length was given
                                        # to us, just leave
    je      end_convert_loop

convert_loop:
    movb    (%rax, %rdi, 1), %cl        # get the current byte
    cmpb    $LOWERCASE_A, %cl           # go to the next byte unless it is 
                                        # between 'a' and 'z'
    jl      next_byte
    cmpb    $LOWERCASE_Z, %cl           
    jg      next_byte
    
    addb    $UPPER_CONVERSION, %cl      # otherwise convert the byte to
                                        # uppercase and store it back
    movb    %cl, (%rax, %rdi, 1)

next_byte:
    inc    %rdi                        # next byte
    cmp    %rdi, %rbx                  # continue unless we've reached the end
    jne     convert_loop

end_convert_loop:
    mov    %rbp, %rsp
    pop    %rbp
    ret
    
