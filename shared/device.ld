/*
 * Linker Script for the STM32F207ZG
 */

MEMORY {
    ROM (rx)  : ORIGIN = 0x08000000, LENGTH = 1M
    RAM (rwx) : ORIGIN = 0x20000000, LENGTH = 128K
}

SECTIONS {
    . = 0x00000000;
    .text : {
        KEEP(*(.vectors))
        . = 0x400 + ALIGN(8);
        *(.startup)
        *(.text)
    } > ROM

    _topOfStack = ORIGIN(RAM) + LENGTH(RAM); /* stack pointer start */
}
