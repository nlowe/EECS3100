#include <st/iostm32f207zx.h>
#include <lcd.h>
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
        
        // Set F3 to analog
        ldr     r0, =GPIOF_MODER
        ldr     r1, [r0]
        orr     r1, r1, #(0x3 << 6)
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
        
        // Enable ADC3 Clock
        ldr     r0, =RCC_APB2ENR
        ldr     r1, [r0]
        orr     r1, r1, #(1 << 10)
        str     r1, [r0]
        
        // Enable ADC in continuous mode and start conversion
        ldr     r0, =ADC3_CR2
        ldr     r1, [r0]
        orr     r1, r1, #0x3
        str     r1, [r0]
        
        // Set Sequence First Conversion to IN9
        ldr     r0, =ADC3_SQR3
        ldr     r1, [r0]
        orr     r1, r1, #0x9
        str     r1, [r0]
        
        bl      LCD_Init
        ldr     r0, =BLACK
        bl      LCD_Clear
        
party:
        bl      FUNC_READ_POT
        push    {r1}
        mov     r6, r1
        
        // Convert pot value to text
        ldr     r5, =strbuff
        mov     r3, #'0'
        orr     r3, r3, #('x' << 8)
        str     r3, [r5, #0]
        
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #16
        mov     r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        lsl     r2, r2, #8
        orr     r3, r3, r2
        lsr     r6, r6, #4
        bl      FUNC_NIB_ITOA
        orr     r3, r3, r2
        str     r3, [r5, #2]
        
        mov     r0, #5
        mov     r1, #30
        ldr     r2, =WHITE
        ldr     r3, =BLACK
        ldr     r4, =FONT_13
        bl      LCD_WriteString
        
        mov     r3, #'S'
        lsl     r3, r3, #8
        orr     r3, r3, #'T'
        lsl     r3, r3, #8
        orr     r3, r3, #'N'
        lsl     r3, r3, #8
        orr     r3, r3, #'C'
        str     r3, [r5, #0]
        
        eor     r0, r0, r0
        strb    r0, [r5, #4]
        
        mov     r0, #50
        mov     r1, #30
        ldr     r2, =BLACK
        ldr     r3, =GREEN
        ldr     r4, =FONT_13
        bl      LCD_WriteString
        
        // Now find voltage
        pop     {r1}
        mov     r2, #3300
        mul     r6, r1, r2
        mov     r1, #0xFF
        orr     r1, r1, #0xF00
        udiv    r6, r6, r1
        // Voltage in mV is now r6
        
        ldr     r0, =nib_itoa
        ldr     r5, =strbuff
        bl      FUNC_DIVMOD_10
        push    {r2}
        bl      FUNC_DIVMOD_10
        push    {r2}
        bl      FUNC_DIVMOD_10
        push    {r2}
        bl      FUNC_DIVMOD_10
        ldrb    r1, [r0, r2]
        mov     r2, #'.'
        lsl     r2, r2, #8
        orr     r1, r1, r2
        pop     {r2}
        ldrb    r2, [r0, r2]
        lsl     r2, r2, #16
        orr     r1, r1, r2
        pop     {r2}
        ldrb    r2, [r0, r2]
        lsl     r2, r2, #24
        orr     r1, r1, r2
        str     r1, [r5]
        
        pop     {r2}
        ldrb    r1, [r0, r2]
        str     r1, [r5, #4]
        
        mov     r0, #5
        mov     r1, #50
        ldr     r2, =WHITE
        ldr     r3, =BLACK
        ldr     r4, =FONT_13
        bl      LCD_WriteString
        
        mov     r3, #'V'
        str     r3, [r5, #0]
        
        mov     r0, #50
        mov     r1, #50
        ldr     r2, =BLACK
        ldr     r3, =GREEN
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
         * Reads analog value from the POT
         *
         * Inputs: None
         * Outputs: r1: pot value from 0x000-0xFFF
         */
FUNC_READ_POT:
        push    {r0}
        ldr     r0, =ADC3_CR2
        ldr     r1, [r0]
        orr     r1, r1, #(1 << 30)
        str     r1, [r0]
        
        ldr     r0, =ADC3_DR
        ldr     r1, [r0]
        pop     {r0}
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