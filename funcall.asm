; asmsyntax=nasm
%include "avc.inc"
        section .data

msg1    db    "After calling", 0x0a, 0
nmsg1   equ   $-msg1
msg2    db    "RBP is restored", 0x0a, 0
nmsg2   equ   $-msg2
nl      db    0x0a

        section .bss
strnum  resb  64
        section .text
        global _start

_start:
        push    rbp
        mov     rbp, rsp
        mov     r10, rbp
        sub     rsp, 0x20
        mov     rcx, p2
        call    foo
p1:     PRINT   msg1, nmsg1
        cmp     r10, rbp       ; Check if RBP is properly restored
        jne     done
p2:     PRINT   msg2, nmsg2
        mov     rcx, 127
        mov     rdx, strnum
        call    uint2str
        PRINT   strnum, 64
        PRINT   nl, 1
done:   FINISH  0

foo:
        push    rbp         ; Save previous RBP
        mov     rbp, rsp    ; Set my own RBP
        sub     rsp, 8      ; My local variables
        mov     rsp, rbp    ; Restore stack
        pop     rbp         ; Restore RBP
        ret

; UINT2STR
; Convert an unsigned integer into a string of decimals
; RCX: number to convert
; RDX: address to string
uint2str:
        push    rbp
        mov     rbp, rsp
        cmp     rcx, 0
        jne     .nzero         ; If passed number not zero: do main job
        mov     [rdx], BYTE "0"    ; Treat zero input
        mov     [rdx+1], BYTE 0x0  ; C-string
        jmp     .done
.nzero: push    rax
        push    rbx
        push    rcx
        push    rdx
        push    r8
        push    r9
        mov     rax, rcx      ; Copy number to RAX: prep for div
        mov     rbx, 10       ; Divisor
        mov     r8, rdx       ; Use RDX for division; Keep string pointer in R8
        mov     r9, r8        ; R8 will change, keep string beginning in R9
.loop:  xor     rdx, rdx      ; Prep RDX for division = 0
        div     rbx           ; Divide RAX by 10
        add     rdx, "0"      ; Convert remainder to char
        mov     [r8], dl      ; Move char to memory loc of string
        inc     r8            ; Increase the pointer's address
        cmp     rax, 0        ; If result is 0: we are done
        jne     .loop         ; Non-zero quotient
        mov     [r8], BYTE 0x0     ; 0-terminate string (C-style)
                              ; Last thing left: reverse the string
        mov     rcx, r9       ; Beginning of the string
        dec     r8
        mov     rdx, r8       ; End of the string (but not 0x0)
        call    revstr
        pop     r9
        pop     r8
        pop     rdx
        pop     rcx
        pop     rbx
        pop     rax
.done:  mov     rsp, rbp
        pop     rbp
        ret
; END UINT2STR

; REVSTR
; Reverse string
; RCX: pointer to the beginning of the string
; RDX: pointer to the end of the string
revstr:
        push    rbp
        mov     rbp, rsp
        push    rax           ; Save RAX & RBX: will
        push    rbx           ; use them for copying
        push    rcx           ; Save pointers
        push    rdx           ; On the stack
.loop:  cmp     rcx, rdx      ; If pointers coincide or
        jge     .done         ; RCX is passed RDX: we are done
        mov     al, BYTE [rcx]  ; Swap characters in RCX & RDX
        mov     bl, BYTE [rdx]
        mov     [rdx], al
        mov     [rcx], bl
        inc     rcx           ; Move pointers
        dec     rdx
        jmp     .loop
.done:  pop     rdx           ; Restore used registers
        pop     rcx
        pop     rbx
        pop     rax
        mov     rsp, rbp      ; Resore the stack
        pop     rbp
        ret
; END REVSTR
