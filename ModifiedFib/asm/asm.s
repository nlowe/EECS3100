        NAME    main
        
        PUBLIC  __iar_program_start
        
        SECTION .intvec : CODE (2)
        THUMB
        
__iar_program_start
        B       main

        
        SECTION .text : CODE (2)
        THUMB

main:   ldr     r7, =results
        ldr     r7, [r7]
        eor     r0, r0, r0
        
        
        eor     r0, r0, r0
        mov     r1, #1
        mov     r2, #1
        mov     r3, #2
        
        
        B       _halt
        
_halt:  B      _halt

        SECTION .data : DATA(2)
        DATA
results:    DC32 0

        END
