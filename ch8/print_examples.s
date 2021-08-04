# PURPOSE: This program is to demonstrate how to call printf
#
.section .data

# This string is called the format string. It's the first parameter, and printf
# uses it to find out how many parameters it was given, and what what kind they
# are
first_string:
    .ascii  "Hello! %s is a %s who loves the number %d, %s, %s, %s\n\0"

second_string:
    .ascii "LOL, just want to see if I am right\n\0"

third_string:
    .ascii "Another one\n\0"

fourth_string:
    .ascii "Should be passed in stack\n\0"

name: 
    .ascii  "Jonathan\0"

person_string: 
    .ascii  "person\0"

# This could also have been an .equ, but we decided to give it a real memory
# location just for kicks
number_loved:
    .quad   3

.section .text
.global _start

_start:
# note that the parameters are passed in the reverse order that they are passed 
# in the function's prototype.
    subq    $8, %rsp
    pushq   $fourth_string
    movq    $fourth_string, %r10
    movq    $third_string, %r9
    movq    $second_string, %r8
    movq    number_loved, %rcx            # this is the %d
    movq    $person_string, %rdx           # this is the second %s
    movq    $name, %rsi                         # this is the first
    movq    $first_string, %rdi
    callq   printf
    addq    $8, %rsp

    movq    $0, %rdi
    callq   exit
