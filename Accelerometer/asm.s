#include <st/iostm32f207zx.h>
#include <lcd.h>
LED1    EQU 6
LED2    EQU 7
LED3    EQU 8
LED4    EQU 9


ACCEL_ADDR   EQU 0x1c
// Taken from datasheet on page 28
ACCEL_WHOAMI EQU 0x0f

ACCEL_CR1    EQU 0x20
ACCEL_CR2    EQU 0x21
ACCEL_CR3    EQU 0x22

ACCEL_OUTX_L EQU 0x28
ACCEL_OUTX_H EQU 0x29
ACCEL_OUTY_L EQU 0x2A
ACCEL_OUTY_H EQU 0x2B
ACCEL_OUTZ_L EQU 0x2C
ACCEL_OUTZ_H EQU 0x2D

        NAME    main
        PUBLIC  main
		EXTERN 	_halt
        EXTERN  FONT_13
        EXTERN  I2C_Init
        
        SECTION .data : DATA (2)
nib_itoa:
        DC8     '0'
        DC8     '1'
        DC8     '2'
        DC8     '3'
        DC8     '4'
        DC8     '5'
        DC8     '6'
        DC8     '7'
        DC8     '8'
        DC8     '9'
        DC8     'A'
        DC8     'B'
        DC8     'C'
        DC8     'D'
        DC8     'E'
        DC8     'F'

strbuff:
        DC8     '0'
        DS8     15

        SECTION .text : CODE (2)

        THUMB
        // Enable ports B, F and G
main:   ldr     r0, =RCC_AHB1ENR
        ldr     r1, [r0]
        orr     r1, r1, #(1<<6 | 1<<5)
        str     r1, [r0]
        
        // Set G6 to discrete input
        ldr     r0, =GPIOG_MODER
        ldr     r1, [r0]
        bic     r1, r1, #(0x3 << 12)
        str     r1, [r0]

        // Enable TIM2
        ldr     r0, =RCC_APB1ENR
        ldr     r1, [r0]
        orr     r1, r1, #1
        str     r1, [r0]
        
        // Set TIM2 Prescalar to 1-ms intervals
        // 16 MHz / 16000 = 1ms
        ldr     r0, =TIM2_PSC
        ldr     r1, [r0]
        mov     r1, #16000
        str     r1, [r0]
        
        bl      I2C_Init
        bl      LCD_Init
        ldr     r0, =BLACK
        bl      LCD_Clear
        
        // Tell the accelerometer to power up
        ldr     r0, =ACCEL_ADDR
        orr     r0, r0, #1     // write
        ldr     r1, =ACCEL_CR1 // offset reg
        mov     r2, #(3 << 6)  // value
        bl      FUNC_i2c_WRITE
        
        // Tell the accelerometer to use a +/- 6g scale
        ldr     r0, =ACCEL_ADDR
        orr     r0, r0, #1     // write
        ldr     r1, =ACCEL_CR2 // offset reg
        mov     r2, #(1 << 7)  // value
        bl      FUNC_i2c_WRITE
        
party:
        // Test i2c
        ldr     r0, =ACCEL_ADDR
        ldr     r1, =ACCEL_WHOAMI
        bl      FUNC_i2c_READ
        
        
        b party
        
FUNC_WRITE_ACCEL:
        push    {lr}
        
        pop     {lr}
        mov     pc, lr
        
        /*
         * Write a byte to the device on the i2c bus
         * Inputs: r0: bus address
         *         r1: device reg
         *         r2: byte to write
         *
         * Outputs: None
         */
FUNC_i2c_WRITE:
        push    {r3, r4, lr}
        push    {r2}
        // Set START bit
        ldr     r3, =I2C1_CR1
        ldr     r4, [r3]
        orr     r4, r4, #(1 << 8)
        // busy?
        str     r4, [r3]
        
        // SR1?
        ldr     r3, =I2C1_SR1
__func_i2c_write_wait_start:
        ldr     r4, [r3]
        tst     r4, #1
        beq     __func_i2c_write_wait_start
        
        // Write slave address
        ldr     r3, =I2C1_DR
        strb    r0, [r3]
        
        // SR1?
        ldr     r3, =I2C1_SR1
__func_i2c_write_wait_addr:
        ldr     r4, [r3]
        tst     r4, #(1 << 7)
        beq     __func_i2c_write_wait_addr
        // read SR2 to clear ADDR
        ldr     r3, =I2C1_SR2
        ldr     r4, [r3]
        
        // Write device reg
        ldr     r3, =I2C1_DR
        strb    r1, [r3]
        
        ldr     r3, =I2C1_SR1
__func_i2c_write_wait_reg:
        ldr     r4, [r3]
        tst     r4, #(1 << 7)
        beq     __func_i2c_write_wait_reg
        
        // Write payload
        pop     {r2}
        strb    r2, [r3]
        
        // generate STOP bit
        ldr     r3, =I2C1_CR1
        ldr     r4, [r3]
        orr     r4, r4, #(1 << 9)
        str     r4, [r3]
        
__func_i2c_write_wait_eot:
        ldr     r4, [r3]
        tst     r4, #(1 << 7)
        beq     __func_i2c_write_wait_eot
        
        pop     {r3, r4, lr}
        mov     pc, lr

        /*
         * Read a byte from the device on the i2c bus
         * Inputs: r0: bus address
         *         r1: device reg
         *
         * Outputs: r2: byte read from the bus
         */
FUNC_i2c_READ:
        push    {r3, lr}
        // Set START bit
        ldr     r3, =I2C1_CR1
        ldr     r4, [r3]
        orr     r4, r4, #(1 << 8)
        // busy?
        str     r4, [r3]
        
        // SR1?
        ldr     r3, =I2C1_SR1
        ldr     r4, [r3]
        
        // Write slave address
        ldr     r3, =I2C1_DR
        strb    r0, [r3]
        
        // SR1?
        ldr     r3, =I2C1_SR1
        ldr     r4, [r3]
        // SR2?
        ldr     r3, =I2C1_SR2
        ldr     r4, [r3]
        // clear ADDR?
        
        // Write device reg
        ldr     r3, =I2C1_DR
        strb    r1, [r3]
        
        // Write NACK to close communication
        ldr     r3, =I2C1_CR1
        pop     {r3, lr}
        mov     pc, lr

        /*
         * Computes r6 % 10
         * inputs: r6: dividend
         * outputs: r6: r6 // r2
         *          r2: r6 % r2
         */
FUNC_DIVMOD_10:
        push    {r1}
        push    {r6}
        eor     r2, r2, r2
__func_divmod_start:
        add     r2, r2, #1
        subs    r6, r6, #10
        bmi     __func_divmod_end
        b       __func_divmod_start
__func_divmod_end:
        add     r6, r6, #10
        mov     r2, r6
        pop     {r6}
        mov     r1, #10
        udiv    r6, r6, r1
        pop     {r1}
        mov     pc, lr

        /*
         * Converts the low nibble in r0 to ascii
         * Inputs: r6 bits 0-3: the nibble to convert
         * Outputs: r2: the ascii char value
         */
FUNC_NIB_ITOA:
        push    {r1, r6}
        and     r6, r6, #0xF
        ldr     r1, =nib_itoa
        ldr     r2, [r1, r6]
        and     r2, r2, #0xFF
        pop     {r1, r6}
        mov     pc, lr

        /*
         * Waits until TIM2 has counted the specified number of iterations
         * The timer is reset and started before blocking
         *
         * Inputs: r2: the number of iterations to wait
         * Outputs: None
         */
FUNC_WAIT_TIM2:
        // Reset TIM2
        push    {r0, r1}
        ldr     r0, =TIM2_EGR
        ldr     r1, [r0]
        orr     r1, r1, #1
        str     r1, [r0]
        ldr     r0, =TIM2_CR1
        ldr     r1, [r0]
        orr     r1, r1, #1
        str     r1, [r0]
        
        ldr     r0, =TIM2_CNT
__func_wait_tim2__sleep:
        ldr     r1, [r0]
        cmp     r1, r2
        blt     __func_wait_tim2__sleep
        pop     {r0, r1}
        mov     pc, lr
        
        END