// Startup code for the Teensy 3.1
// See http://disconnected.systems/blog/bare-metal-assembly-on-the-teensy-3.1/
// TODO: Alter to match whatever device we will be using in lab
    .syntax unified

    .section ".vectors"
    // Interrupt vector definitions - page 63
    .long _estack  //  0 ARM: Initial Stack Pointer
    .long _startup //  1 ARM: Initial Program Counter
    .long _halt    //  2 ARM: Non-maskable Interrupt (NMI)
    .long _halt    //  3 ARM: Hard Fault
    .long _halt    //  4 ARM: MemManage Fault
    .long _halt    //  5 ARM: Bus Fault
    .long _halt    //  6 ARM: Usage Fault

    .section ".startup","x",%progbits
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

_halt: b _halt
    .end
