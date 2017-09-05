// Startup code for STM32F207ZG
    .syntax unified

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
_startup:
    eor r0, r0
    eor r1, r1
    eor r2, r2
    eor r3, r3
    eor r4, r4
    eor r5, r5
    eor r6, r6
    eor r7, r7
    eor r8, r8
    eor r9, r9
    eor r10, r10
    eor r12, r12 
    b   _main

    .thumb_func
    .global _halt
_halt: b _halt
    .end
