        PUBLIC main
        EXTERN _halt
        
        SECTION .data : DATA (2)
var_x:  DC32 43

        SECTION .text : CODE (2)

        THUMB
main:
        ldr r1, =var_x  
        ldr r1, [r1] // Load initial argument.

        mov r2, r1
        lsl r2, r2, #4
        add r2, r2, r1
        add r2, r2, r1
        add r2, r2, r1
        lsl r1, r1, #3
        add r2, r2, r1 // r2 = r1 * 27

        mov r3, r2
        lsr r3, r3, #4  // r3 = r2 // 16
        mov r4, r2
        mov r0, #15
        and r4, r4, r0 // r4 = r2 % 16 = r2 & (16 - 1) = r2 & 15

        eor r5, r5, r5

        mov r0, r4
        bl  _FUNC_CHECK_PARITY
        cmp r0, #1
        bne _PARITY_Q
        mov r5, #1
_PARITY_Q:
        mov r0, r3
        bl  _FUNC_CHECK_PARITY
        cmp r0, #1
        bne _P_1
        mov r0, #2
        orr r5, r5, r0
_P_1:
        mov r0, #1
        tst r5, r0
        beq _P_1_0
        mov r7, r4
        b   _P_2
_P_1_0:
        eor r7, r7, r7
_P_2:
        mov r0, #2
        tst r5, r0
        beq _P_2_0
        mov r6, r3
        b   _halt
_P_2_0:
        eor r6, r6, r6

        ldr r0, =var_x
        str r3, [r0]

        b _halt

        // Check the parity of the value in r0
        // Input: r0: the argument to check
        // Output: r0=1 for even parity, r0=0 otherwise

_FUNC_CHECK_PARITY:
        push {r1}
        mov  r1, r0
        lsr  r1, r1, #16
        eor  r0, r0, r1 // r0 ^= r0 >> 16
        mov  r1, r0
        lsr  r1, r1, #8
        eor  r0, r0, r1 // r0 ^= r0 >> 8
        mov  r1, r0
        lsr  r1, r1, #4
        eor  r0, r0, r1 // r0 ^= r0 >> 4
        mov  r1, r0
        lsr  r1, r1, #2
        eor  r0, r0, r1 // r0 ^= r0 >> 2
        mov  r1, r0
        lsr  r1, r1, #1
        eor  r0, r0, r1 // r0 ^= r0 >> 8
        mvn  r0, r0
        mov  r1, #1
        and  r0, r0, r1  // r0 = (~r0) & 1
        pop  {r1}
        mov  pc, lr // return 1 if r0 originally had even parity otherwise 0

        END
