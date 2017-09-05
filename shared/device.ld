/*
 * Linker Script for the Teensy 3.1
 * See http://disconnected.systems/blog/bare-metal-assembly-on-the-teensy-3.1/
 * TODO: Alter to match whatever device we will be using in lab
 */

MEMORY {
    FLASH (rx) : ORIGIN = 0x00000000, LENGTH = 256K
    RAM  (rwx) : ORIGIN = 0x1FFF8000, LENGTH = 64K
}

SECTIONS {
    . = 0x00000000;
    .text : {
        KEEP(*(.vectors))
        . = 0x400;
        KEEP(*(.flashconfig*))
        *(.startup)
        *(.text)
    } > FLASH

    _estack = ORIGIN(RAM) + LENGTH(RAM); /* stack pointer start */
}
