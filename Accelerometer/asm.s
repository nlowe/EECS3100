#include <st/iostm32f207zx.h>
#include <lcd.h>
#include <i2c.h>
#include <accelerometer.h>
LED1    EQU 6
LED2    EQU 7
LED3    EQU 8
LED4    EQU 9

        NAME    main
        PUBLIC  main
		EXTERN 	_halt
        EXTERN  FONT_13
        
        SECTION .data : DATA (2)
nib_itoa:
        DC8     '0', '1', '2', '3', '4', '5', '6', '7'
        DC8     '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'

strbuff:
        DC8     '_', ' ', 'A', 'C', 'C', 'E', 'L', '='
        DC8     ' ', '0', 'x', ' ', ' ', ' ', ' '

        SECTION .text : CODE (2)

        THUMB
        // Enable ports F and G
main:   ldr     r0, =RCC_AHB1ENR
        ldr     r1, [r0]
        orr     r1, r1, #(1<<6 | 1<<5)
        str     r1, [r0]
        
        // Set G6 to discrete input
        ldr     r0, =GPIOG_MODER
        ldr     r1, [r0]
        bic     r1, r1, #(0x3 << 12)
        str     r1, [r0]
        
        // F10 used for ACCEL DRDY signal
        // Set F10 to discrete input
        ldr     r0, =GPIOF_MODER
        ldr     r1, [r0]
        bic     r1, r1, #(0x3 << 20)
        str     r1, [r0]
        
        // Set F10 to 50MHz speed
        ldr     r0, =GPIOF_OSPEEDR
        ldr     r1, [r0]
        orr     r1, r1, #(0x2 << 20)
        bic     r1, r1, #(0x1 << 20)
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
        
        bl      Accel_Init
        
party:
        // Wait for accelerometer data to be ready
        ldr     r0, =GPIOF_IDR
        ldr     r1, [r0]
        tst     r1, #(1 << 10)
        //beq     party
        
        bl      Accel_Read
        mov     r7, r1      // Save Y
        mov     r8, r2      // Save Z
        
        ldr     r5, =strbuff
        mov     r4, #'X'
        strb    r4, [r5, #0]
        
        mov     r6, r0
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #24
        mov     r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #16
        orr     r3, r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #8
        orr     r3, r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        orr     r3, r3, r2
        str     r3, [r5, #11]
        
        mov     r0, #5
        mov     r1, #15
        ldr     r2, =WHITE
        ldr     r3, =BLACK
        ldr     r4, =FONT_13
        bl      LCD_WriteString
        
        ldr     r5, =strbuff
        mov     r4, #'Y'
        strb    r4, [r5, #0]
        
        mov     r6, r7
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #24
        mov     r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #16
        orr     r3, r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #8
        orr     r3, r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        orr     r3, r3, r2
        str     r3, [r5, #11]
        
        mov     r0, #5
        mov     r1, #30
        ldr     r2, =WHITE
        ldr     r3, =BLACK
        ldr     r4, =FONT_13
        bl      LCD_WriteString
        
        ldr     r5, =strbuff
        mov     r4, #'Z'
        strb    r4, [r5, #0]
        
        mov     r6, r8
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #24
        mov     r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #16
        orr     r3, r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #8
        orr     r3, r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        orr     r3, r3, r2
        str     r3, [r5, #11]
        
        mov     r0, #5
        mov     r1, #45
        ldr     r2, =WHITE
        ldr     r3, =BLACK
        ldr     r4, =FONT_13
        bl      LCD_WriteString
        
        mov     r2, #100
        bl      FUNC_WAIT_TIM2
        
        b party
        


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
         * Converts the low nibble in r6 to ascii
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