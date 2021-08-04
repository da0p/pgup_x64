#PURPOSE: This program finds the maximum number of a 
#         set of data items.
#VARIABLES: The registers have the following uses:
# %edi - Holds the index of the data item being examined
# %ebx - Largest data item found
# %eax - Current data item
#
# The following memory locations are used:
# 
# data_items - contains the item data. A 0 is used to 
#              terminate the data
#

.section .data
data_items:
    .quad   3, 67, 34, 222, 45, 75, 54, 34, 44, 33, 22, 11, 66, 0

.equ    SYS_EXIT, 60

.section .text

.globl _start
# rdi - index
# rbx - maximum
# rax - current item

_start:
    mov    $0, %rdi                            # move 0 into the index register
    mov    data_items(, %rdi, 8), %rax         # load the first byte of data
    mov    %rax, %rbx                          # since this is the first item,
                                                # %eax is the biggest

start_loop:                                     # start loop
    cmp    $0, %rax                            # check to see if we've hit the
                                                # end
    je     loop_exit
    inc    %rdi                                # load next value
    mov    data_items(, %rdi, 8), %rax         
    cmp    %rbx, %rax                          # compare values
    jle    start_loop                          # jump to loop beginning if the
                                                # new one isn't bigger
    mov    %rax, %rbx                          # move the value as the largest
    jmp    start_loop                          # jump to loop beginning

loop_exit:
    mov    $SYS_EXIT, %rax                  
    mov    %rbx, %rdi                                                
    syscall                                                


