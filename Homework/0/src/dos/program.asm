; --------------------------------
; | Include libraries and macros |
; --------------------------------
include ..\..\..\..\shared\pcmac.inc

.model small    ; Small Memory MODEL
.586            ; Pentium Instruction Set
.stack 100h     ; Stack area - 256 bytes

.data
var_x    DW  42

.code
Hello   PROC
    _LdSeg ds, @data
    mov ax, var_x ; Load initial argument
  
    mov  bx, ax
    shl  bx, 4
    add  bx, ax
    add  bx, ax
    add  bx, ax
    shl  ax, 3
    add  ax, bx ; ax = ax * 27
  
    mov  bx, ax
    shr  bx, 4  ; bx = ax // 16
    mov  cx, ax
    and  cx, 15 ; cx = ax % 15 = ax & (16 - 1) = ax % 15 

    xor  dx, dx

    mov  ax, cx
    call _FUNC_CHECK_PARITY
    cmp  ax, 1
    jne  _PARITY_Q
    mov  dx, 1
_PARITY_Q:
    mov  ax, bx
    call _FUNC_CHECK_PARITY
    cmp  ax, 1
    jne  _P_1
    or   dx, 2
_P_1:
    test dx, 1
    jz  _P_1_0
    mov  di, cx
    jmp  _P_2
_P_1_0:
    xor  di, di
_P_2:
    test dx, 2
    jz  _P_2_0
    mov  si, bx
    jmp  _halt
_P_2_0:
    xor  si, si

_halt:
    _Exit 00h
Hello   ENDP

  ; Check the parity of the value in ax
  ; Input: ax: the argument to check
  ; Output: ax=1 for even parity, ax=0 otherwise
_FUNC_CHECK_PARITY PROC
    push bx
    mov  bx, ax
    shr  bx, 16
    xor  ax, bx ; ax ^= ax >> 16
    mov  bx, ax
    shr  bx, 8
    xor  ax, bx ; ax ^= ax >> 8
    mov  bx, ax
    shr  bx, 4
    xor  ax, bx ; ax ^= ax >> 4
    mov  bx, ax
    shr  bx, 2
    xor  ax, bx ; ax ^= ax >> 2
    mov  bx, ax
    shr  bx, 1
    xor  ax, bx ; ax ^= ax >> 1
    not  ax
    and  ax, 1
    pop  bx
    ret
_FUNC_CHECK_PARITY ENDP

  END Hello
