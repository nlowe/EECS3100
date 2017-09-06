    .equ X, 42

    .syntax unified
    .thumb_func
    .global _main
_main:
    mov r1, X  // Load initial argument
    
    mov r2, r1
    lsl r2, 4
    add r2, r1
    add r2, r1
    add r2, r1
    lsl r1, 3
    add r2, r1 // r2 = r1 * 27

    mov r3, r2
    lsr r3, 4  // r3 = r2 // 16
    mov r4, r2
    and r4, 15 // r4 = r3 % 16 = r3 & (15 - 1) = r3 & 15

    eor r5, r5

    // TODO: Parity of R
    bne _PARITY_Q
    mov r5, 1
_PARITY_Q:
    // TODO: Parity of Q
    bne _P_1
    orr r5, 1
_P_1:
    tst r5, 1
    bne _P_1_0
    mov r7, r4
    b   _P_2
_P_1_0:
    eor r7, r7
_P_2:
    tst r5, 2
    bne _P_2_0
    mov r6, r3
    b   _halt
_P_2_0:
    eor r6, r6

    b _halt
