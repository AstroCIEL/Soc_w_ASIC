#ifndef ARA_SOC_H
#define ARA_SOC_H

/* ------------------------------------------------------------------ */
/* UART (16550-compatible, APB)                                       */
/* ------------------------------------------------------------------ */
#define UART_BASE       0x10000000UL

/* ------------------------------------------------------------------ */
/* PLIC (SiFive / rv_plic compatible)                                 */
/*   - 2 targets (context 0 = hart0 M-mode, 1 = hart0 S-mode)         */
/*   - 30 sources; source 0 reserved by spec                          */
/* ------------------------------------------------------------------ */
#define PLIC_BASE           0x0C000000UL

/* ------------------------------------------------------------------ */
/* CLINT (SiFive-style)                                                */
/* ------------------------------------------------------------------ */
#define CLINT_BASE          0x02000000UL

/* ------------------------------------------------------------------ */
/* Default slave (simple mem + IRQ doorbell)                          */
/*   - write offset 0x00  → raise irq                                  */
/*   - write offset 0x10  → clear irq                                  */
/* ------------------------------------------------------------------ */
#define DEFAULT_SLAVE_BASE          0x50000000UL
#define DEFAULT_SLAVE_IRQ_SET_OFF   0x00UL
#define DEFAULT_SLAVE_IRQ_ACK_OFF   0x10UL

typedef enum irqn {
    IRQn_NONE           = 0,
    IRQn_UART           = 1,
    IRQn_DEFAULT_SLAVE  = 2,
    IRQn_MAX            = 31
} irqn_t;

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
