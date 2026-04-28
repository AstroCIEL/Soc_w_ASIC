#ifndef ARA_SOC_H
#define ARA_SOC_H

/* ------------------------------------------------------------------ */
/* UART (16550-compatible, APB)                                       */
/* ------------------------------------------------------------------ */
#define UART_BASE       0x10000000UL

/* ------------------------------------------------------------------ */
/* Testbench control registers (ctrl_registers.sv)                    */
/*   EOC_ADDRESS_REG  : write (status<<1 | 1) to terminate simulation */
/* ------------------------------------------------------------------ */
#define EOC_ADDRESS_REG         0xD0000000UL
#define DRAM_START_ADDRESS_REG  0xD0000008UL
#define DRAM_END_ADDRESS_REG    0xD0000010UL
#define EVENT_TRIGGER_REG       0xD0000018UL
#define HW_CNT_EN_REG           0xD0000020UL

/* ------------------------------------------------------------------ */
/* Platform clock / baudrate defaults                                 */
/* ------------------------------------------------------------------ */
#define SYS_CLK_HZ      500000000UL   /* 500 MHz — matches tb.sv */
#define BAUD_RATE       6250000UL     /* 500 MHz / (16*5) exact  */

#endif /* ARA_SOC_H */
