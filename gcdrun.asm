%include "avc.inc"

        section .text
        global _start
        extern gcd
        extern read_uint
        extern print_uint
_start:
        call    read_uint
        mov     rdi, rax
        call    read_uint
        mov     rsi, rax
        call    gcd
        mov     rdi, rax
        call    print_uint
        FINISH  0
