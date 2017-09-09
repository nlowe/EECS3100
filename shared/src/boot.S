// Startup code for STM32F207ZG
#ifdef __GNU_AS__
    .syntax divided

    .section ".vectors"
// Interrupt vector definitions - See table 20 on page 163 of the Reference Manual
    .word _topOfStack //   Reserved (Top of Stack)
    .word _startup    //   Reset Vector
    .word _halt       //   NMI
    .word _halt       //   Hard Fault
    .word _halt       //   Memory Management
    .word _halt       //   Bus Fault
    .word _halt       //   Usage Fault
    .word _halt       //   Reserved
    .word _halt       //   System Service via SWI
    .word _halt       //   Debug Monitor
    .word _halt       //   Reserved
    .word _halt       //   Pending System Service
    .word _halt       //   System Tick Timer

    .section ".startup","x"
    .thumb_func
    .global _startup
#else
    // TODO: startup code compatible with IAR

    PUBLIC _startup
#endif
_startup:
    eor r0, r0, r0
    eor r1, r1, r1
    eor r2, r2, r2
    eor r3, r3, r3
    eor r4, r4, r4
    eor r5, r5, r5
    eor r6, r6, r6
    eor r7, r7, r7

    // TODO: Copy / relocate data segment(s) to ram from rom

    bl  _main    // Go do the thing. Main should either return to us or branch directly to _halt
    b   _halt

#if __GNU_AS__
    .thumb_func
    .global _halt
#else
    PUBLIC _halt
#endif
_halt: b _halt
#if __GNU_AS__
    .end
#else
    END
#endif
