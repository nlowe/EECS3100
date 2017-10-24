#include <st/iostm32f207zx.h>
STAT1     EQU 6
STAT2     EQU 7
STAT3     EQU 8
STAT4     EQU 9
STAT_PORT EQU GPIOF_ODR

USER_PORT EQU GPIOG_IDR

LE        EQU 0  // B_0
LE_PORT   EQU GPIOB_ODR

// Switches in E0-E7
SW_MASK   EQU 0xff
SW_PORT   EQU GPIOE_IDR

// Bar LEDs in E8-E15
BAR_MASK  EQU 0xff << 8
BAR_PORT  EQU GPIOE_ODR

        NAME    main
        PUBLIC  main
		EXTERN 	_halt

        SECTION .text : CODE (2)

        THUMB
        // Enable ports B, E, F, and G
main:   ldr     r0, =RCC_AHB1ENR
        ldr     r1, [r0]
        orr     r1, r1, #(1 << 1 | 1 << 4 | 1<<5 | 1<<6)
        str     r1, [r0]
        
        // Set G6 to discrete input (USER)
        ldr     r0, =GPIOG_MODER
        ldr     r1, [r0]
        bic     r1, r1, #(0x3 << 12)
        str     r1, [r0]
        
        // Set B0 to discrete input (USER)
        ldr     r0, =GPIOB_MODER
        ldr     r1, [r0]
        bic     r1, r1, #0x3
        str     r1, [r0]
        
        // Set F6 and F9 to discrete output (STAT1-STAT4)
        ldr     r0, =GPIOF_MODER
        ldr     r1, [r0]
        orr     r1, r1, #(0x55 << 12)
        bic     r1, r1, #(0x55 << 13)
        str     r1, [r0]
        
        // Set E0-E7 to discrete input, E8-E15 to discrete output
        ldr     r0, =GPIOE_MODER
        mov     r1, #(0x55 << 16)
        orr     r1, r1, #(0x55 << 24)
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
        bl      FUNC_STAT_ALL_OFF
        eor     r7, r7, r7
wait_for_btn:
        bl      FUNC_USER_BTN_PRESSED
        bne     wait_for_btn
        
        // When the button is pressed, latch in switches
        bl      FUNC_LATCH_SW
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        
        mov     r7, #1
        mov     r2, #2000
        bl      FUNC_WAIT_TIM2
        bne     party
        
        // If after 2 seconds the button is still held
        // Read from the latch
        bl      FUNC_READ_SW
        
        ldr     r2, =SW_MASK
        cmp     r1, r2
        beq     sw_all_on
        mvn     r1, r1
        cmp     r1, r2
        beq     sw_all_off
        // mixed, the off-by-one is implemented in-hardware
        lsl     r1, r1, #8
        bl      FUNC_WRITE_BAR
        b       party
        
        // Until USER pressed:
        // * STAT1 on, BAR{0,2,4,6} on, BAR{1,3,5,7} off
        // * wait 500ms
        // * STAT1 off, BAR{0,2,4,6} off, BAR{1,3,5,7} on
        // * wait 500ms
sw_all_on:
        ldr     r2, =STAT1
        bl      FUNC_STAT_ON
        mov     r1, #(0x55 << 8)
        bl      FUNC_WRITE_BAR
        mov     r2, #500
        bl      FUNC_WAIT_TIM2
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        ldr     r2, =STAT1
        bl      FUNC_STAT_OFF
        mov     r1, #(0x55 << 7)
        bl      FUNC_WRITE_BAR
        mov     r2, #500
        bl      FUNC_WAIT_TIM2
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        b       sw_all_on

        // Until USER pressed
        // * STAT1 on
        // * wait 500ms
        // * STAT1 off
        // * wait 500ms
sw_all_off
        ldr     r2, =STAT1
        bl      FUNC_STAT_ON
        mov     r2, #500
        bl      FUNC_WAIT_TIM2
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        ldr     r2, =STAT1
        bl      FUNC_STAT_OFF
        mov     r2, #500
        bl      FUNC_WAIT_TIM2
        bl      FUNC_USER_BTN_PRESSED
        bne     party
        b       sw_all_off

        /*
         * Enables the latch for 5ms
         * inputs: none
         * outputs: none
         */
FUNC_LATCH_SW:
        push    {r0, r1, r2, r3, lr}
        ldr     r0, =LE_PORT
        ldr     r1, [r0]
        ldr     r2, =LE
        mov     r3, #1
        lsl     r3, r3, r2
        orr     r1, r1, r3
        str     r1, [r0]
        mov     r2, #5
        bl      FUNC_WAIT_TIM2
        bic     r1, r1, r3
        str     r1, [r0]
        pop     {r0, r1, r2, r3, lr}
        mov     pc, lr

        /*
         * Reads switch states from the latch
         * Inputs: none
         * Outputs: r1: bitmask of switch states from latch
         */
FUNC_READ_SW:
        push    {r0, r2, r3}
        ldr     r0, =SW_PORT
        ldr     r1, [r0]
        ldr     r2, =SW_MASK
        and     r1, r1, r2
        pop     {r0, r2, r3}
        mov     pc, lr

        /*
         * Writes latch states to bar LEDs
         * Inputs: r1: bar bitmask
         * Outputs: none
         */
FUNC_WRITE_BAR:
        push    {r0}
        ldr     r0, =BAR_PORT
        str     r1, [r0]
        pop     {r0}
        mov     pc, lr

        /*
         * Turns on the specified LED on the board
         * Inputs: r2: the pin of the LED
         * Outputs: None
         */
FUNC_STAT_ON:
        push    {r0, r1, r3}
        ldr     r0, =STAT_PORT
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
FUNC_STAT_OFF:
        push    {r0, r1, r3}
        ldr     r0, =STAT_PORT
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
FUNC_STAT_ALL_OFF:
        push    {r0, r1}
        ldr     r0, =STAT_PORT
        ldr     r1, [r0]
        bic     r1, r1, #(1 << STAT1 | 1 << STAT2 | 1 << STAT3 | 1 << STAT4)
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
        pop     {r0, r1}
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
        push    {r0, r1}
        ldr     r0, =USER_PORT
        ldr     r1, [r0]
        tst     r1, #(1<<6)
        pop     {r0, r1}
        mov     pc, lr
        
        END