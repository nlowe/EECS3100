        NAME    main
        PUBLIC  main
		EXTERN 	_halt

        SECTION .data:DATA(2)
        DC8  "Lorem ipsum dolor sit amet volutpat."
foo:    DC32 42

        SECTION .text : CODE (2)

        THUMB
main:   ldr     r0, =foo
        ldr     r1, [r0]
        add     r1, r1, #42
        str     r1, [r0]
        
        b       _halt
        
        END
