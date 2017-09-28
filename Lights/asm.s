#include <st/iostm32f207zx.h>
LED1    EQU 6
LED2    EQU 7
LED3    EQU 8
LED4    EQU 9

        NAME    main
        PUBLIC  main
		EXTERN 	_halt

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
        
        // Set F6 and F9 to discrete output
        ldr     r0, =GPIOF_MODER
        ldr     r1, [r0]
        orr     r1, r1, #(0x55 << 12)
        bic     r1, r1, #(0x55 << 13)
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

party:
        bl      FUNC_LED_ALL_OFF
        eor     r7, r7, r7
wait_for_btn:
        bl      FUNC_USER_BTN_PRESSED
        bne     wait_for_btn
        
        ldr     r2, =LED1
        bl      FUNC_LED_ON
        mov     r2, #600
        bl      FUNC_WAIT_TIM2
        
        ldr     r2, =LED3
        bl      FUNC_LED_ON
        mov     r2, #600
        bl      FUNC_WAIT_TIM2
        
        ldr     r2, =LED2
        bl      FUNC_LED_ON
        mov     r2, #600
        bl      FUNC_WAIT_TIM2
        
        ldr     r2, =LED4
        bl      FUNC_LED_ON
        mov     r2, #600
        bl      FUNC_WAIT_TIM2
        
        // If the button has not been released..
        mov     r7, #1
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        mov     r2, #500
        bl      FUNC_WAIT_TIM2
        
flash:
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        
        ldr     r2, =LED1
        bl      FUNC_LED_OFF
        ldr     r2, =LED4
        bl      FUNC_LED_OFF
        ldr     r2, =LED2
        bl      FUNC_LED_ON
        ldr     r2, =LED3
        bl      FUNC_LED_ON
        
        mov     r2, #250
        bl      FUNC_WAIT_TIM2
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        
        ldr     r2, =LED1
        bl      FUNC_LED_ON
        ldr     r2, =LED4
        bl      FUNC_LED_ON
        ldr     r2, =LED2
        bl      FUNC_LED_OFF
        ldr     r2, =LED3
        bl      FUNC_LED_OFF
        
        mov     r2, #700
        bl      FUNC_WAIT_TIM2
        
        b       flash
        
        b       _halt
        
        /*
         * Turns on the specified LED on the board
         * Inputs: r2: the pin of the LED
         * Outputs: None
         */
FUNC_LED_ON:
        push    {r0, r1, r3}
        ldr     r0, =GPIOF_ODR
        ldr     r1, [r0]
        mov     r3, #1
        lsl     r3, r3, r2
        orr     r1, r1, r3
        str     r1, [r0]
        pop     {r0, r1, r3}
        mov     pc, lr

        /*
         * Turns off the specified LED on the board
         * Inputs: r2: the pin of the LED
         * Outputs: None
         */
FUNC_LED_OFF:
        push    {r0, r1, r3}
        ldr     r0, =GPIOF_ODR
        ldr     r1, [r0]
        mov     r3, #1
        lsl     r3, r3, r2
        bic     r1, r1, r3
        str     r1, [r0]
        pop     {r0, r1, r3}
        mov     pc, lr

        /*
         * Turns off all LEDs
         * Inputs: none
         * Outputs: none
         */
FUNC_LED_ALL_OFF:
        push    {r0, r1}
        ldr     r0, =GPIOF_ODR
        ldr     r1, [r0]
        bic     r1, r1, #(1 << LED1 | 1 << LED2 | 1 << LED3 | 1 << LED4)
        str     r1, [r0]
        pop     {r0, r1}
        mov     pc, lr
        
        /*
         * Waits until TIM2 has counted the specified number of iterations
         * The timer is reset and started before blocking
         * If r7=1 and the user button is released, the function returns early
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

        // If the flag in r7 is set, also break out of the sleep if
        // the button was released
        cmp     r7, #1
        bne     __func_wait_tim2_sleep_real
        push    {lr}
        bl      FUNC_USER_BTN_PRESSED
        pop     {lr}
        beq     __func_wait_tim2_sleep_real
        b       party

__func_wait_tim2_sleep_real:
        ldr     r1, [r0]
        cmp     r1, r2
        blt     __func_wait_tim2__sleep
        pop     {r0, r1}
        mov     pc, lr
        
        /*
         * Checks to see if the USER Button is pressed
         * Inputs: None
         * Outputs: Compare Flags
         */
FUNC_USER_BTN_PRESSED:
        push    {r0}
        ldr     r0, =GPIOG_IDR
        ldr     r1, [r0]
        tst     r1, #(1<<6)
        pop     {r0}
        mov     pc, lr
        
        END