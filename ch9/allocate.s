# PURPOSE: Program to manage memory usage - allocates and deallocates memory as
#          requested
#
# NOTES:   The program using these routines will ask for a certain size of
#          memory. We actually use more than that size, but we put it at the
#          beginning, before the pointer we hand back. We add a size field and
#          an AVAILABLE/UNAVAILABLE marker. So, the memory looks like this.
##############################################################################
# Available Marker | Size of memory | Actual memory locations|
##############################################################################
#                                       ^-- Returned pointer points here
#                                                        
#          The pointer we return only points to the actual locations requested
#          to make it easier for the calling program. It also allows us to
#          change our structure without the calling program having to change at
#          all.

.section .data

##### GLOBAL VARIABLES ######
# This points to the beginning of the memory we are managing
heap_begin:
    .quad 0

# This points to one location past the memory we are managing
current_break:
    .quad 0

########### Structure information ########
# Size of space for memory region header
.equ    HEADER_SIZE, 16
# Location of the "available" flag in the header
.equ    HDR_AVAIL_OFFSET, 0
# Location of the size field in the header
.equ    HDR_SIZE_OFFSET, 8

########## Constants ####################
.equ    UNAVAILABLE, 0          # This is the number we will use to mark space
                                # that has been given out
.equ    AVAILABLE, 1            # This is the number we will use to mark space
                                # that has been returned, and is available for 
                                # giving
.equ    SYS_BRK, 12

.section .text
################## Functions ############
# allocate_init ##
# PURPOSE:  Call this function to initialize the functions (specifically, this
#           sets heap_begin and current_break). This has no parameters and no 
#           return value.
.global allocate_init
.type   allocate_init, @function

allocate_init:
    pushq   %rbp                # standard function stuff
    movq    %rsp, %rbp          

    movq    $SYS_BRK, %rax      # if the brk system call is called with 0 in 
                                # %ebx, it returns the last valid usable address
    movq    $0, %rbx
    syscall

    incq    %rax                # %rax now has the last valid address, and we 
                                # want the memory location after that
    movq    %rax, current_break # store the current break
    movq    %rax, heap_begin    # store the current break as our first address.
                                # This will cause the allocate function to get
                                # more memory from Linux the first time it is
                                # run
    movq    %rbp, %rsp          # exit the function
    popq    %rbp
    ret

## End of function
## Allocate ##
# PURPOSE:    This function is used to grab a section of memory. It checks to
#               see if there are any free blocks, and, if not, it asks Linux for 
#               a new one.
#
# PARAMETERS: This function has one parameter - the size of the memory block
#               we want to allocate
#
# RETURN VALUE: This function returns the address of the allocated memory in
#               %rax. If there is no memory available, it will return 0 in %rax
#
## Processing ##
# Variables used:
# 
#   %rcx - hold the size of the requested memory (first/only parameter)
#   %rax - current memory region being examined
#   %rbx - current break position
#   %rdx - size of current memory region.
#
# We scan through each memory region starting with heap_begin. We look at the 
# size of each one, and if it has been allocated. If it's big enough for the 
# requested size, and its available, it grabs that one. If it does not find a
# region large enough, it asks Linux for more memory. In that case, it moves
# current_break up
.global allocate
.type allocate, @function
.equ ST_MEM_SIZE, 16             # stack position of memory size to allocate

allocate:
    pushq   %rbp
    movq    %rsp, %rbp

    movq    ST_MEM_SIZE(%rbp), %rcx     # rcx will hold the size we are looking
                                        # for (which is the first and only 
                                        # parameter)
    movq    heap_begin, %rax            # %rax will hold the current search
                                        # location
    movq    current_break, %rbx         # %rbx will hold the current break

alloc_loop_begin:                       # here we iterate through each memory
                                        # region
    cmpq    %rbx, %rax                  # need more memory if these are equal
    je      move_break
    
    movq    HDR_SIZE_OFFSET(%rax), %rdx # grab the size of this memory
    cmpq    $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)    # If the space is
                                                    # unavailable, go to the
    je      next_location                           # next one

    cmpq    %rdx, %rcx                  # if the space is available, compare 
                                        # the size to the needed size. If its
                                        # big enough, go to allocate_here
    jle     allocate_here

next_location:
    addq    $HEADER_SIZE, %rax          # The total size of the memory region is
                                        # the sum of the size requested
                                        # (currently stored in %rdx), plus 
                                        # another 16 bytes for the header (8 for
                                        # the AVAILABLE/UNAVAILABLE flag, and 8
                                        # for the size of the region). So adding
                                        # %rdx and $16 to %rax will get the
                                        # address of the next memory region
    jmp     alloc_loop_begin            # go look at the next location

allocate_here:                          # if we've made it here, that means that
                                        # the region header of the region to 
                                        # allocate is in %rax
    movq    $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax) # mark space as unavailable
    addq    $HEADER_SIZE, %rax          # move %rax past the header to the 
                                        # usable memory (since that's what we
                                        # return)
    movq    %rbp, %rsp                  # return from the function
    popq    %rbp
    ret

move_break:                     # if we've made it here, that means that we 
                                # have exhausted all addressable memory, and we
                                # need to ask for more.
    addq    $HEADER_SIZE, %rbx  # %rbx holds the current endpoint of the data,
                                # and %rcx holds its size. We need to increase
                                # %rbx to where we want memory to end, so we 
                                # add space for the headers structure
    addq    %rcx, %rbx          # add space to the break for the data requested
                                # now it's tiem to ask Linux for more memory
    pushq   %rax                # save needed registers
    pushq   %rcx    
    pushq   %rbx
    movq    %rbx, %rdi

    movq    $SYS_BRK, %rax      # reset the break (%rbx has the requested break
                                # point)
    syscall                     # under normal conditions, this should return
                                # the new break in %rax, which will be either 0
                                # if it fails, or it will be equal to or larger 
                                # than we asked for. We don't care in this 
                                # program where it actually sets the break, so
                                # as long as %rax isn't 0, we don't care what
                                # it is
    cmpq    $0, %rax            # check for error conditions
    je      error

    popq    %rbx                # restore saved register
    popq    %rcx
    popq    %rax

    movq    $UNAVAILABLE, HDR_AVAIL_OFFSET(%rax)    # set this memory as
                                # unavailable, since we're about to give it away
    movq    %rcx, HDR_SIZE_OFFSET(%rax)

    addq    $HEADER_SIZE, %rax  # move %rax to the actual start of usable memory
                                # %rax now holds the return value
    movq    %rbx, current_break # save the new break
    
    movq    %rbp, %rsp          # return the function
    popq    %rbp
    ret

error:
    movq    $0, %rax
    movq    %rbp, %rsp
    popq    %rbp
    ret

## deallocate ##
# PURPOSE:  The purpose of this function is to give back a region of memory to
#           the pool after we're done using it.
#
# PARAMETERS: The only parameter is the address of the memory we want to return
#             to the memory pool.
#
# RETURN VALUE: There is no return value
#
# Processing: If you remember, we actually hand the program the start of the 
#             memory that they can use, which is 8 storage locations after the
#             actual start of the memory region. All we have to do is go back
#             8 memory locations and mark that memory as available, so that
#             the allocate function knows it can use it.
.global deallocate
.type deallocate, @function
.equ ST_MEMORY_SEG, 16           # stack position of the memory region to free

deallocate:                     
    pushq   %rbp
    movq    %rsp, %rbp
    
    movq    ST_MEMORY_SEG(%rsp), %rax

    subq    $HEADER_SIZE, %rax

    movq    $AVAILABLE, HDR_AVAIL_OFFSET(%rax)

    movq    %rbp, %rsp
    popq    %rbp
    ret


 



