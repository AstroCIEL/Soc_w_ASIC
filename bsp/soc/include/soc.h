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
/* Default slave (simple mem + IRQ doorbell)                          */
/*   - write offset 0x00  → raise irq                                  */
/*   - write offset 0x10  → clear irq                                  */
/* ------------------------------------------------------------------ */
#define DEFAULT_SLAVE_BASE          0x50000000UL
#define DEFAULT_SLAVE_IRQ_SET_OFF   0x00UL
#define DEFAULT_SLAVE_IRQ_ACK_OFF   0x10UL

/* ------------------------------------------------------------------ */
/* IRQ number enumeration (rv_plic source IDs as seen by software).    */
/*                                                                      */
/* plic_top.sv inserts a one-slot offset between the hardware           */
/* `irq_sources[]` vector and the register-visible source id:           */
/*     prio_i[0] = 0         (reserved "no interrupt" sentinel)         */
/*     prio_i[i] = prio_q[i-1]   for i >= 1                             */
/*     ip_i     = {ip, 1'b0}                                            */
/*     ie_i[t]  = {ie_q[t][N_SOURCE-1:0], 1'b0}                         */
/*                                                                      */
/* Therefore the register/claim id used by software is                  */
/* `irq_sources_index + 1` (SiFive-style "id 0 == none").               */
/*                                                                      */
/*   irq_sources[0] (UART)           → id 1                              */
/*   irq_sources[1] (default_slave)  → id 2                              */
/* ------------------------------------------------------------------ */
typedef enum {
    IRQn_NONE           = 0,   /* "no interrupt" sentinel                */
    IRQn_UART           = 1,   /* irq_sources[0] ← UART                  */
    IRQn_DEFAULT_SLAVE  = 2,   /* irq_sources[1] ← default_slave.irq_o   */
    IRQn_MAX            = 31   /* rv_plic always allocates 32 sources    */
} IRQn_Type;

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
