.section .data

helloworld:
.ascii  "hello world\n\0"

.section .text
.global _start
_start:

    movq   $helloworld, %rdi
    callq   printf

    movq   $0, %rdi
    callq   exit
