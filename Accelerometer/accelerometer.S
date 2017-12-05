#include <accelerometer_regs.h>
#include <i2c.h>
        
        NAME    accelerometer
        PUBLIC  Accel_Init
        public  Accel_Read
        EXTERN  _halt
        
        SECTION .data : DATA(2)
i2cbuff:
        DC8     0
        DS8     15
        
        SECTION .accel : CODE(2)
        THUMB
        
Accel_Init:
        push    {r0-r8, lr}
        
        // Test i2c
        ldr     r0, =ACCEL_ADDR
        ldr     r1, =i2cbuff
        ldr     r2, =ACCEL_WHOAMI
        strb    r2, [r1]
        mov     r2, #1
        bl      I2C_Write
        bl      I2C_Read
        
        ldrb    r2, [r1, #0]
        
        cmp     r2, #0x3a
        bne     _halt
        
        // Enable all axes and power on the device
        ldr     r2, =ACCEL_CR1
        strb    r2, [r1, #0]
        mov     r2, #0x47
        strb    r2, [r1, #1]
        mov     r2, #2
        bl      I2C_Write
        
        // Data-Ready generation on F10
        ldr     r2, =ACCEL_CR2
        strb    r2, [r1, #0]
        mov     r2, #0x04
        strb    r2, [r1, #0]
        mov     r2, #2
        bl      I2C_Write
        
        pop     {r0-r8, lr}
        mov     pc, lr
        
        /**
         * Reads x, y, and z axes data from acceleromter
         * Inputs: None
         * Outputs: r0: X acceleration
         *          r1: Y acceleration
         *          r2: Z acceleration
         */
Accel_Read:
        push    {lr}
        
        ldr     r0, =ACCEL_ADDR
        ldr     r1, =i2cbuff
        ldr     r2, =ACCEL_OUTX_L
        orr     r2, r2, #0x80       // Read multiple bytes
        strb    r2, [r1, #0]
        mov     r2, #1
        bl      I2C_Write
        
        mov     r2, #6
        bl      I2C_Read
        
        // Each axis returns a signed half-word
        ldrsh   r1, [r1, #2]
        ldrsh   r2, [r1, #4]
        ldrsh   r0, [r1, #0]
        
        pop     {lr}
        mov     pc, lr
        
        
        END