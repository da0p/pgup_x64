# PURPOSE   - Given a number, this program computes the fibonaci number
#             for example, fib(0) = 0, fib(1) = 1, fib(2) = fib(1) + fib(0) = 1,
#             fib(3) = fib(2) + fib(1) = 1 + 1 = 2

.section .data

.section .text
.equ    SYS_CALL, 60

.globl _start
.globl fib

_start:
    
    push   $6

    call    fib
    add    $8, %rsp
    mov    %rax, %rdi

    mov    $SYS_CALL, %rax
    syscall


.type fib, @function
fib:
    push   %rbp

    mov    %rsp, %rbp

    mov    16(%rbp), %rax

    cmp    $0, %rax 

    je      end_fib

    cmp    $1, %rax 

    je      end_fib

    dec    %rax

    mov    %rax, %rcx

    dec    %rcx

    push   %rcx

    push   %rax

    call    fib

    pop    %rbx

    pop    %rbx

    push   %rax

    push   %rbx

    call    fib

    pop    %rbx

    pop    %rbx

    add   %rbx, %rax
    
end_fib:
    mov    %rbp, %rsp
    pop    %rbp
    ret

