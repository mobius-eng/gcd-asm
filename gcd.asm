%include "avc.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  gcd           Calculates greates common divisor
;;
;;    Arguments:
;;      RDI:    First number
;;      RSI:    Second number
;;
;;    Result:
;;      RAX:    GCD
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global gcd
gcd:
        push    rdx                   ; Preserve RDX & RBX
        push    rbx
        mov     rax, rdi              ; Prepare for Euclid algorithm:
        mov     rbx, rsi              ; m = q * n + r; m <- n; n <- r
                                      ; m ~ RAX, n ~ RBX, RDX ~ r, RAX ~ q
.loop:  xor     rdx, rdx              ; Clear RDX, otherwise it will be considered
                                      ; part of the divident
        cmp     rbx, 0                ; If prev remainder is 0 => current m is GCD
        jz      .done
        div     rbx                   ; Get (q,r) in RAX, RDX from m/n
        mov     rax, rbx              ; m <- n (drop the quotient)
        mov     rbx, rdx              ; n <- r
        jmp     .loop
.done:  pop     rbx                   ; Restore registers
        pop     rdx
        ret

