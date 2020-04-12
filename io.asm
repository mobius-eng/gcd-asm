; asmsyntax=nasm
%include "avc.inc"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  str2uinti     Convert a string into an unsigned integer
;;
;;    Arguments:
;;      RDI     Beginning of the string
;;      RSI     Length of the string
;;    Return value:
;;      RAX     Converted number
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global str2uinti
str2uinti:
        push    rcx
        push    rdx
        push    rbx
        push    r8                    ; Use R8 to load new digits
        xor     rax, rax
        xor     r8, r8
        mov     rbx, 10               ; Base of the number
        mov     rcx, 0                ; Indexer
.loop:  mov     r8b, BYTE [rdi+rcx]   ; Load a digit (start from the end)
        sub     r8b, "0"              ; Convert char digit to a number
        mul     rbx                   ; 1 decimal shift to left in RAX
        add     rax, r8               ; Add the digit
        inc     rcx                   ; Next character
        cmp     rcx, rsi              ; Check if passed the end of the string
        jng     .loop                 ; Repeat if there are more characters
        pop     r8
        pop     rbx                   ; Restore the stack & registers
        pop     rdx
        pop     rcx
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  str2uint      Convert a string into an unsigned integer. Read string
;;                until non-digit symbol is encountered
;;
;;    Arguments:
;;      RDI     (in)  Beginning of the string
;;      RSI     (out) How many characters read
;;    Return value:
;;      RAX     Converted number
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global str2uint
str2uint:
        push    rdx
        push    rbx
        push    r8                    ; Use R8 to load new digits
        xor     rax, rax
        xor     r8, r8
        mov     rbx, 10               ; Base of the number
        mov     rsi, 0                ; Indexer
.loop:  mov     r8b, BYTE [rdi+rsi]   ; Load a digit (start from the end)
        sub     r8b, "0"              ; Convert char digit to a number
        cmp     r8b, 9
        ja      .done
        cmp     r8b, 0
        jl      .done
        mul     rbx                   ; 1 decimal shift to left in RAX
        add     rax, r8               ; Add the digit
        inc     rsi                   ; Next character
        jmp     .loop
.done:  pop     r8
        pop     rbx                   ; Restore the stack & registers
        pop     rdx
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  read_uint     Reads an unsigned interger from stdin
;;
;;    Arguments:
;;      Does not take any
;;    Result:
;;      RAX:    uint number read from stdin
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global read_uint
read_uint:
        push    rsi                   ; Preserve rsi & rdi
        push    rdi
        sub     rsp, 16               ; Alloc space for string on the stack
        lea     rdi, [rsp]
        call    read_nums             ; RDI: buffer, RSI: EOF encountered, RAX: num of chars
        call    str2uint              ; Convert the string into uint (RAX)
        add     rsp, 16
        pop     rdi
        pop     rsi
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  uint2str      Converts an unsigned integer into string in decimal
;;                form
;;
;;    Arguments:
;;      RDI:    number to convert
;;      RSI:    address of the string
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global uint2str
uint2str:
        cmp     rdi, 0
        jne     .nzero                ; If passed number not zero: do main job
        mov     [rsi], BYTE "0"       ; Treat zero input
        mov     [rsi+1], BYTE 0x0     ; Terminating with 0x0 (C-string)
        jmp     .done
.nzero: push    rbx
        push    rcx
        push    rdx
        push    rdi                   ; Save args as well: use these
        push    rsi                   ;   registers in call to revstr
        mov     rax, rdi              ; Copy number to RAX: prep for div
        mov     rbx, 10               ; Divisor
        mov     rcx, 0                ; Char displacement from RDI
.loop:  xor     rdx, rdx              ; Prep RDX for division = 0
        div     rbx                   ; Divide RAX by 10
        add     rdx, "0"              ; Convert remainder to char
        mov     [rsi+rcx], dl         ; Move char to memory loc of string
        inc     rcx                   ; Increase the displacement
        cmp     rax, 0                ; If result is 0: we are done
        jne     .loop                 ; Non-zero quotient
        mov     [rsi+rcx], BYTE 0x0   ; 0-terminate string (C-style)
                                      ; Last thing left: reverse the string
        mov     rdi, rsi              ; Beginning of the string
        mov     rsi, rcx              ; Length of the string to reverse (note: excludes 0x0)
        call    revstr                ; Reverse the string
        mov     rax, rcx
        pop     rsi                   ; Restore used registers
        pop     rdi
        pop     rdx
        pop     rcx
        pop     rbx
.done:  ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  revstr        Revers the order of characters in the string
;;
;;    Arguments:
;;      RDI:    String address
;;      RSI:    Number of characters to revers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global revstr
revstr:
        push    rax                   ; Save RAX: will use it to keep temp. chars
        push    rcx                   ; Use RCX & RDX to point to beginning and
        push    rdx                   ; the end of the string
        mov     rcx, rdi
        lea     rdx, [rdi+rsi-1]
.loop:  cmp     rcx, rdx              ; If pointers coincide or
        jge     .done                 ; RCX is passed RDX: we are done
        mov     al, BYTE [rcx]        ; Swap characters in RCX & RDX
        mov     ah, BYTE [rdx]
        mov     [rdx], al
        mov     [rcx], ah
        inc     rcx                   ; Move pointers
        dec     rdx
        jmp     .loop
.done:  pop     rdx                   ; Restore used registers
        pop     rcx
        pop     rax
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  print_uint    Prints an unsigned integer into stdout
;;
;;    Arguments:
;;      RDI:    integer to print
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .data
nline   db      0x0a, 0x0
        section .text
        global print_uint
print_uint:
        push    rbp
        push    rsi
        mov     rbp, rsp
        sub     rsp, 16               ; Memory for the string on the stack
        lea     rsi, [rsp]            ; Load the pointer to the string
        call    uint2str              ; Convert number to string
        _print_stdout rsi, rax
        _print_stdout nline, 2
        pop     rsi
        ; PRINT   0x0a                  ; New line
        mov     rsp, rbp
        pop     rsi
        pop     rbp
        ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  getc & ungetc Extracts & "puts back" 1 character from/into stdin
;;    Arguments:
;;      getc:   None
;;      ungetc:
;;        RDI:  Character (in DIL) to put back
;;    Result:
;;      getc:
;;        RAX:  Read character in AL
;;      ungetc: None
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .data
getcbuf db      0x0                   ; Buffer to keep read symbol in
getcbufflag db  0x0                   ; Flag indicating wherer to use the buffer
        section .text
        global getc
getc:
        push    rbx                   ; RBX: address of read char on stack
        sub     rsp, 8                ; Prepare the space for reading a char
        cmp     BYTE [getcbufflag], 0 ; Check whether the flag is on
        jne     .getbuf
        lea     rbx, [rsp]
        _read_stdin rbx, 1            ; Flag is not on: read from STDIN
        mov     al, [rsp]             ; Transfer the result into RAX (AL)
        jmp     .done
.getbuf:
        mov     al, BYTE [getcbuf]    ; Flag is on: get char from buffer
        mov     BYTE [getcbufflag], 0 ; Drop the flag
.done:  add     rsp, 8                ; Clear up the stack
        pop     rbx
        ret

        section .text
        global ungetc
ungetc:
        mov     BYTE [getcbuf], dil   ; Place BYTE char into the buffer
        mov     BYTE [getcbufflag], 1 ; Set the flag
        ret



%define EOF     -1
%define EOT     0x04
%define EOL     0x0a
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  read_line     Reads one line from standard input
;;
;;    Arguments:
;;      RDI:    Pointer to the buffer to read to
;;      RSI:    (out) Indicator if end of input was encountered
;;    Result:
;;      RAX:    Number of read characters
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global read_line
read_line:
        push    rcx
        mov     rcx, 0                ; Counter of read chars
        xor     rsi, rsi              ; RSI: 0 - no end of input; 1 - end of input
.loop:  call    getc                  ; Read a char
        cmp     al, EOT               ; Check if EOF/EOT or 0x0 are encountered
        je      .eof                  ;   It seems that Linux just give 0x0 if
        cmp     al, EOF               ;   ther is nothing to be read left.
        je      .eof
        cmp     al, 0x0
        je      .eof
        cmp     al, EOL               ; EOL: end of the line encountered. Stop reading
        je      .done
        mov     BYTE [rdi+rcx], al
        inc     rcx
        jmp     .loop
.eof:   mov     rsi, 1                ; EOF/EOT/0x0 encountered. Set RSI
.done:  mov     BYTE [rdi+rcx], 0x0 ; C-string
        mov     rax, rcx              ; Transfer num of read chars to RAX (result)
        pop     rcx
        ret



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;  read_nums     Reads numerals until non numeral is found
;;
;;    Arguments:
;;      RDI:    Pointer to the buffer to read into
;;      RSI:    (out) Indicator if end of input was encountered
;;    Result:
;;      RAX:    Number of read characters
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        section .text
        global read_nums
read_nums:
        ; RDI, RSI: inputs; don't touch them
        ; RAX used for getc/ungetc
        ; RCX counter for read chars
        push    rcx
        push    rbx
        xor     rsi, rsi              ; RSI: 0 - no end of input; 1 - end of input
        xor     rcx, rcx              ; 0 chars read: info for return
        ; Block 1: skip whitespace from stdin
.wspc:  call    getc                  ; Skip whitespace before a number
        cmp     al, " "
        je      .wspc
        cmp     al, 0x09              ; Tab
        je      .wspc
        cmp     al, 0x0a              ; newline TODO: should I use EOL? is EOL 0x0a?
        je      .wspc
        cmp     al, 0x0               ; Reached the end of input.
        je      .eof                  ; No number read here. How to indicate that?
        ; Block 1a: Get here if in AL not a whitespace. Put it back
        mov     rcx, rdi              ; Temporary save RDI in RCX
        mov     rdi, rax
        call    ungetc
        mov     rdi, rcx              ; Restore RDI
        ; Block 2: read numerals. If found non-numeral push it back
        mov     rcx, 0                ; Counter of read chars
.loop:  call    getc                  ; Read a char
        cmp     al, EOT               ; Check if EOF/EOT or 0x0 are encountered
        je      .eof                  ;   It seems that Linux just give 0x0 if
        cmp     al, EOF               ;   ther is nothing to be read left.
        je      .eof
        cmp     al, 0x0
        je      .eof
        cmp     al, "0"               ; Not a digit found: exit
        jb      .nonum
        cmp     al, "9"
        ja      .nonum
        mov     BYTE [rdi+rcx], al
        inc     rcx
        jmp     .loop
        ; Read non-numeral but not 0x0: put it back then done
.nonum: mov     rbx, rdi
        mov     rdi, rax
        call    ungetc
        mov     rdi, rbx
        jmp     .done
.eof:   mov     rsi, 1                ; EOF/EOT/0x0 encountered. Set RSI
.done:  mov     BYTE [rdi+rcx], 0x0   ; C-string
        mov     rax, rcx              ; Transfer num of read chars to RAX (result)
        pop     rbx
        pop     rcx
        ret

