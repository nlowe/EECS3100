#include <st/iostm32f207zx.h>
        NAME    I2C
        PUBLIC  I2C_Init
        PUBLIC  I2C_DeInit
        PUBLIC  I2C_Write
        PUBLIC  I2C_Read
        
        SECTION .i2c_data : CONST (2)
APBAHBPrescTable:
        DC8     0, 0, 0, 0, 1, 2, 3, 4, 1, 2, 3, 4, 6, 7, 8, 9
HSE_VALUE:
        DC32    25000000 // 25 MHz
HSI_VALUE:
        DC32    16000000 // 16 MHz


        SECTION .i2c : CODE(2)
        THUMB
        
I2C_RW_Setup:
        push    {r0-r4, lr}
        
        // Enable ACK & Start
        ldr     r3, =I2C1_CR1
        ldr     r4, [r3]
        orr     r4, r4, #(1 << 10 | 1 << 8)
        str     r4, [r3]
        
        // Enable START
        //orr     r4, r4, #(1 << 8)
        //str     r4, [r3]

        // Wait for START to be generated
        ldr     r3, =I2C1_SR1
__wait_sb:
        ldr     r4, [r3]
        tst     r4, #1
        beq     __wait_sb
        
        // Send address
        ldr     r3, =I2C1_DR
        strb    r0, [r3]
        
        // Wait for address to be sent (ADDR || (!ADDR && TxE))
        ldr     r3, =I2C1_SR1
__wait_addr:
        ldr     r4, [r3]
        tst     r4, #(1 << 1)
        bne     __addr_sent
        tst     r4, #(1 << 7)
        beq     __wait_addr     // We might miss ADDR so also check TxE
        
__addr_sent:
        // If we're receiving one byte, disable ACK
        cmp     r2, #1
        bne     __clear_addr
        tst     r0, #1
        beq     __clear_addr
        ldr     r3, =I2C1_CR1
        ldr     r4, [r3]
        bic     r4, r4, #(1 << 10)
        str     r4, [r3]
        
__clear_addr:
        // Read SR2 to clear ADDR
        ldr     r3, =I2C1_SR2
        ldr     r4, [r3]

        // If we're receiving one byte, generate STOP
        cmp     r2, #1
        bne     __i2c_rw_done
        tst     r0, #1
        beq     __i2c_rw_done
        ldr     r3, =I2C1_CR1
        ldr     r4, [r3]
        orr     r4, r4, #(1 << 9)
        str     r4, [r3]

__i2c_rw_done:
        pop     {r0-r4, lr}
        mov     pc, lr
        
        /**
         * Write to I2C
         * Inputs: r0: I2C slave address
         *         r1: pointer to data buffer
         *         r2: number of bytes to write
         * Outputs: none
         */
I2C_Write:
        push    {r0-r8, lr}
        cmp     r2, #0
        beq     __i2c_write_done
        
        bic     r0, r0, #1  // Ensure LSB Reset
        
        eor     r4, r4, r4
        
        // Generate ACK & START and send address
        bl      I2C_RW_Setup

        ldr     r3, =I2C1_DR
__i2c_write_data:
        cmp     r2, #0
        beq     __i2c_write_done
        // Move a byte into I2C1_DR
        ldrb    r0, [r1], #1
        strb    r0, [r3]
        // If last byte, set STOP bit
        sub     r2, r2, #1
        cmp     r2, #0
        bne     __i2c_write_wait_tx
        ldr     r0, =I2C1_CR1
        ldr     r1, [r0]
        orr     r1, r1, #(1 << 9)
        str     r1, [r0]
__i2c_write_wait_tx:
        // wait for byte to be transmitted
        ldr     r4, =I2C1_SR1
        ldr     r5, [r4]
        tst     r5, #(1 << 7)
        bne     __i2c_write_data
        tst     r5, #1
        // The bus might close before we can check TxE
        // Check to see if START is no longer being generated
        bne     __i2c_write_data
        
__i2c_write_done:
        pop     {r0-r8, lr}
        mov     pc, lr
        
        /**
         * Read from I2C
         * Inputs: r0: I2C slave address
         *         r1: pointer to data bufer
         *         r2: number of bytes to read
         * Outputs: none. Buffer pointed at by r1 is
         *   populated from data on the i2c bus
         */
I2C_Read:
        push    {r0-r8, lr}
        cmp     r2, #0
        beq     __i2c_read_done
        
        orr     r0, r0, #1  // Ensure LSB Set
        
        // Generate ACK & START and send address
        bl      I2C_RW_Setup
        
        // Wait for byte to be received
        ldr     r3, =I2C1_DR
__i2c_read_wait_rx:
        ldr     r4, =I2C1_SR1
        ldr     r5, [r4]
        tst     r5, #(1 << 6)
        beq     __i2c_read_wait_rx
        
        // If this is the last byte, disable ACK and generate STOP
        sub     r2, r2, #1
        cmp     r2, #1
        bne     __i2c_read_data
        ldr     r4, =I2C1_CR1
        ldr     r5, [r4]
        bic     r5, r5, #(1 << 10)
        orr     r5, r5, #(1 << 9)
        str     r5, [r4]
        
        // Read the data
__i2c_read_data:
        ldrb    r4, [r3]
        strb    r4, [r1], #1
        
        cmp     r2, #0
        beq     __i2c_read_done
        b       __i2c_read_wait_rx
        
__i2c_read_done:
        pop     {r0-r8, lr}
        mov     pc, lr
        
// According to the manual, here's what we need to do:
// Setup:
// * Program peripheral input clock in I2Cx_CR2
//   to generate the correct timings
// * Configure the clock control registers (CCR)
// * Configure rise time register
// * Enable the device using I2Cx_CR1
//
// To write:
// * Set START in I2Cx_CR1
// * SB in I2Cx_SR1 is set when START is sent
//   (read I2Cx_SR1 until SB set)
// * Write to I2Cx_DR with slave address
// * ADDR set in I2Cx_SR1/2? is set when slave address is sent
//   (read I2Cx_SR1 & I2Cx_SR2 until ADDR set)
//   if LSB of addr: master receiver, else master transmitter
//
// * Master Rx
//   * Read bytes from I2Cx_DR
//   * Set ACK in I2Cx_CR1/2? ?
//   * On last byte, set ACK=0 and STOP in I2Cx_CR1/2?
// * Master Tx
//   * Write to I2Cx_DR with all bytes (one at a time)
//   * Wait for BTF in I2Cx_CR1/2 (or TxE?)
//   * Set STOP in I2Cx_CR1/2?
I2C_Init:
        push    {r0-r1, lr}
        
        // Enable GPIOB for I2C1
        ldr     r0, =RCC_AHB1ENR
        ldr     r1, [r0]
        orr     r1, r1, #(1 << 1)
        str     r1, [r0]
        
        // Disable GPIOB Reset for I2C1
        ldr     r0, =RCC_AHB1RSTR
        ldr     r1, [r0]
        bic     r1, r1, #(1 << 1)
        str     r1, [r0]
        
        // Reset I2C1 State
        bl      I2C_DeInit
        
        // Setup B6 and B7 for AF I2C (0x4) (GPIO_PinAFConfig)
        ldr     r0, =GPIOB_AFRL
        ldr     r1, [r0]
        // TODO: Is this correct?
        orr     r1, r1, #(0x44 << 24)
        str     r1, [r0]
        
        // Setup B6 and B7
        bl      __I2C_Init_GPIO_Init
        
        // Enable I2C1 Peripheral Clock
        ldr     r0, =RCC_APB1ENR
        ldr     r1, [r0]
        orr     r1, r1, #(1 << 21)
        str     r1, [r0]
        
        // Enable I2C1
        ldr     r0, =I2C1_CR1
        ldr     r1, [r0]
        orr     r1, r1, #1
        str     r1, [r0]
        
        // Do the init init
        bl      __I2C_Init_Init
        
        // Enable I2C1 Events & Errors Interrupt
        //bl      __I2C_Init_NVIC_Init
        
        // Enable interrupts from I2C1 module
        //bl      __I2C_Init_I2C_ITConfig
        
        pop     {r0-r1, lr}
        mov     pc, lr


__I2C_Init_GPIO_Init:
        push    {r0-r1, lr}
        
        // GPIO_Init order: MODER, OSPEEDR, OTYPER, PUPDR
        ldr     r0, =GPIOB_MODER
        ldr     r1, [r0]
        bic     r1, r1, #(0xF << 12)
        orr     r1, r1, #(0xA << 12)
        str     r1, [r0]
        
        // B6 and B7 to fast speed (50Mhz)
        ldr     r0, =GPIOB_OSPEEDR
        ldr     r1, [r0]
        orr     r1, r1, #(0xA << 12)
        bic     r1, r1, #(0xA << 11)
        str     r1, [r0]
        
        // B6 and B7 to open-drain mode?
        ldr     r0, =GPIOB_OTYPER
        ldr     r1, [r0]
        orr     r1, r1, #(0x3 << 6)
        str     r1, [r0]

        pop     {r0-r1, lr}
        mov     pc, lr


__I2C_Init_Init:
        push    {r0-r5, lr}
        
        // Init_Init order: CR2, TRISE, CCR, CR1, OAR1
        
        // Get PCLK1
        bl      RCC_GetClocksFreq
        mov     r4, #0xf0000
        orr     r4, r4, #0x4200
        orr     r4, r4, #0x40
        udiv    r4, r3, r4      // freqrange
        
        // Set I2C1 frequency
        ldr     r0, =I2C1_CR2
        ldr     r1, [r0]
        bic     r1, r1, #0x7F
        orr     r1, r1, r4
        str     r1, [r0]
        
        // Disable I2C1 to configure CCR and TRISE
        ldr     r0, =I2C1_CR1
        ldr     r1, [r0]
        bic     r1, r1, #1
        str     r1, [r0]
        
        // Set I2C1 Clock Speed to 100MHz and TRISE to that + 1
        mov     r2, #0x10000
        orr     r2, r2, #0x8600
        orr     r2, r2, #0xa0
        lsr     r2, r2, #1
        udiv    r5, r3, r2
        cmp     r5, #0x04
        bge     __i2c_init_init_trise
        mov     r5, #0x04
__i2c_init_init_trise:
        ldr     r0, =I2C1_TRISE
        add     r1, r4, #1
        and     r1, r1, #0x3F
        str     r1, [r0]
        ldr     r0, =I2C1_CCR
        str     r5, [r0]
        
        // Enable I2C1
        ldr     r0, =I2C1_CR1
        ldr     r1, [r0]
        orr     r1, r1, #1
        str     r1, [r0]
        
        // Clear AK, SMBTYPE, and SMBUS
        // Setup mode and ack mode
        mov     r2, #0xFB00
        orr     r2, r2, #0xF5
        and     r1, r1, r2
        orr     r1, r1, #0x400
        str     r1, [r0]
        
        // Setup I2C1 OAR1 and ack mode
        ldr     r0, =I2C1_OAR1
        mov     r1, #0xAA
        orr     r1, r1, #0x4000
        str     r1, [r0]
        
        pop     {r0-r5, lr}
        mov     pc, lr


__I2C_Init_NVIC_Init:
        push    {r0-r1, lr}
        
        // TODO: Enable I2C1 Events Interrupt
        // TODO: Enable I2C1 Errors Interrupt
        
        pop     {r0-r1, lr}
        mov     pc, lr


__I2C_Init_I2C_ITConfig:
        push    {r0-r1, lr}
        // TODO: Enable interrupts from I2C1 Module
        
        pop     {r0-r1, lr}
        mov     pc, lr


        /**
         * Get SYSCLK, HCLK, and PCLK1 frequencies
         * Inputs: None
         * Outputs: r1: SYSCLK
         *          r2: HCLK
         *          r3: PLCK1
         *          r4: PLCK2
         */
RCC_GetClocksFreq:
        push    {r0, r5-r7, lr}
        ldr     r0, =RCC_CFGR
        ldr     r1, [r0]
        and     r2, r1, #0xF0   // HCLK Prescalar Offset
        lsl     r2, r2, #4
        and     r3, r1, #0x1C00 // PCLK1 Prescalar Offset
        lsl     r3, r3, #10
        and     r4, r1, #0xE000 // PCLK2 Prescalar Offset
        lsl     r4, r4, #13     
        and     r1, r1, #0xC    // SYSCLK Source
        ldr     r0, =APBAHBPrescTable
        ldr     r2, [r0, r2]    // HCLK Prescalar
        ldr     r3, [r0, r3]    // PCLK1 Prescalar
        ldr     r4, [r0, r4]    // PCLK2 Prescalar
        
        // Calculate SYSCLK from source
        cmp     r1, #0x00
        bne     rcc_getclocksfreq_sysclk_4
        b       rcc_getclocksfreq_sysclk_default
rcc_getclocksfreq_sysclk_4:
        cmp     r1, #0x04
        bne     rcc_getclocksfreq_sysclk_8
        // SYSCLK is HSE
        ldr     r0, =HSE_VALUE
        ldr     r1, [r0]
        
        b       rcc_getclocksfreq_hclk
rcc_getclocksfreq_sysclk_8:
        cmp     r1, #0x08
        bne     rcc_getclocksfreq_sysclk_default
        // SYSCLK is PLL
        
        // PLL_VCO = (HSE or HSI / PLLM) * PLLN
        // SYSCLK = PLL_VCO / PLLP
        ldr     r0, =RCC_PLLCFGR
        ldr     r1, [r0]
        and     r0, r1, #0x3F    // PLLM
        mov     r7, #0x700
        orr     r7, r7, #0xFC
        and     r5, r1, r7       // PLLN
        lsl     r5, r5, #6
        and     r6, r1, #0x30000 // PLLP
        and     r1, r1, #(1 << 22)
        lsl     r1, r1, #22  // PLLSRC
        
        cmp     r1, #0
        beq     rcc_getclocksfreq_pllm_hse
        // PLLSRC is HSE
        ldr     r1, =HSE_VALUE
        ldr     r1, [r1]
        
        b       rcc_getclocksfreq_pllp
rcc_getclocksfreq_pllm_hse:
        // PLLSRC is HSI
        ldr     r1, =HSI_VALUE
        ldr     r1, [r1]
        
rcc_getclocksfreq_pllp:
        udiv    r1, r1, r0
        mul     r1, r1, r5  // pllvco
        udiv    r1, r1, r6  // SYSCLK = pllvco / pllp

        b       rcc_getclocksfreq_hclk
rcc_getclocksfreq_sysclk_default:
        // SYSCLK is HSI
        ldr     r0, =HSI_VALUE
        ldr     r1, [r0]
        
rcc_getclocksfreq_hclk:
        lsl     r2, r1, r2  // HCLK  = SYSCLK >> HCLK_PRESC
        lsl     r3, r2, r3  // PLCK1 = HCLK   >> PLCK1_PRESC
        lsl     r4, r2, r4  // PLCK2 = HCLK   >> PLCK2_PRESC
        
        pop     {r0, r5-r7, lr}
        mov     pc, lr


I2C_DeInit:
        push    {r0-r1, lr}
        
        // Enable I2C1 Reset State
        ldr     r0, =RCC_APB1RSTR
        ldr     r1, [r0]
        orr     r1, r1, #(1 << 21)
        str     r1, [r0]
        
        // Release I2C1 from Reset State
        ldr     r1, [r0]
        bic     r1, r1, #(1 << 21)
        str     r1, [r0]
        
        pop     {r0-r1, lr}
        mov     pc, lr

        END