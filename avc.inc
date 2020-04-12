; asmsyntax=nasm

%macro _syscall_3 4
        ; syscall clobbers RCX & R11. RAX: return value
        ; preserve clobbered registers
        push    rcx
        push    r11
        ; use RAX: syscall num
        ; RDI, RSI, RDX: arguments
        ; preserve registers used as args
        push    rdx
        push    rsi
        push    rdi
        ; transfer arguments for syscall
        push    %1
        push    %2
        push    %3
        push    %4
        pop     rdx
        pop     rsi
        pop     rdi
        pop     rax
        syscall
        ; restore argument registers
        pop     rdi
        pop     rsi
        pop     rdx
        ; restore clobbered registers
        pop     r11
        pop     rcx
%endmacro

; %1: descriptor   %2: buffer addr   %3: buffer length 
; output: eax: written bytes
%macro _syscall_write 3
        _syscall_3 1,%1,%2,%3
%endmacro


%macro _syscall_read 3
        _syscall_3 0,%1,%2,%3
%endmacro


%macro _print_stdout 2
        _syscall_write 1,%1,%2
%endmacro


%macro _read_stdin 2
        _syscall_read 0,%1,%2
%endmacro


%macro 	PRINT 1
        pushf
        push    rax
        jmp     %%astr
%%str	  db      %1
%%strln	equ     $-%%str
%%astr:	_print_stdout %%str, %%strln
        pop rax	      
        popf
%endmacro

%macro FINISH 1
        ; no point in preserving anything: exitting
        mov     rdi, %1   ; Exit code
        mov     rax, 60   ; Syscall code
        syscall           ; Actual syscall
%endmacro
