        NAME    main
        PUBLIC  main
		EXTERN 	_halt
        SECTION .text : CODE (2)

        DATA
res:    DS32 25

        // Reg Map:
        // * r0: a
        // * r1: b
        // * r2: c
        // * r3: tmp
        //
        // * r4: res buff base
        // * r5: i

        THUMB
main:   ldr     r4, =res
        eor     r5, r5, r5

        eor     r0, r0, r0
        str     r0, [r4, r5]
        add     r5, r5, #4
        
        mov     r1, #1
        str     r1, [r4, r5]
        add     r5, r5, #4
        
        mov     r2, #1
        str     r2, [r4, r5]
        add     r5, r5, #4

loop:
        add     r3, r2, r1
        add     r3, r3, r0
        str     r3, [r4, r5]
        add     r5, r5, #4
        cmp     r5, #(25 *4)
        beq     _halt
        mov     r0, r1
        mov     r1, r2
        mov     r2, r3
        b       loop

        END
