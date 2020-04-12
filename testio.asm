%include "avc.inc"
        section .data
pmsg    db      "Consumed number: ", 0x0
lpmsg   equ     $-pmsg
nline   db      0x0a
        section .bss
buf     resb    128
        section .text
        extern  read_line
        extern  read_nums
        global  _start
_start:
        lea     rdi, [buf]
        call    read_nums
        cmp     rax,0                 ; Check if any numerals were read
        je      .nonum
        _print_stdout pmsg, lpmsg
        _print_stdout buf, rax
        _print_stdout nline, 1
        ; Read the rest of the input
.read:  lea     rdi, [buf]
        call    read_line
        cmp     rax, 0
        jne      .inp
        cmp     rsi, 0
        je      .read
        jmp     .noinput
.inp:   _print_stdout buf, rax
        _print_stdout nline, 1
        jmp     .done
.nonum: PRINT   "No number in input"
        _print_stdout nline, 1
        jmp     .done
.noinput:
        PRINT   "No additional input"
        _print_stdout nline, 1
.done:  PRINT   "Done"
        _print_stdout nline, 1
        FINISH  0

