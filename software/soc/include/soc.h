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
    IRQn_DMA            = 3,
    IRQn_ASIC_ACCEL     = 8,
    IRQn_MAX            = 31
} irqn_t;

/* ------------------------------------------------------------------ */
/* iDMA (ariane_dma_desc64 wrapper)                                   */
/*   - AXI cfg slave  @ DMABase (ariane_soc_pkg)                      */
/*   - IRQ source = IRQn_DMA (desc64 frontend irq_o -> irq_sources[2])*/
/* ------------------------------------------------------------------ */
#define DMA_BASE            0x60000000UL

/* ------------------------------------------------------------------ */
/* Custom ASIC accelerator (minimum_asic_dma variant)                  */
/* ------------------------------------------------------------------ */
#define ASIC_ACCEL_BASE     0x70000000UL

/* ------------------------------------------------------------------ */
/* VMMA — VecMatMul + DMA (minimum_vmma_dma variant), same MMIO window */
/* ------------------------------------------------------------------ */
#define VMMA_ACCEL_BASE     0x70000000UL
#define IRQn_VVMA_ACCEL     8

/* ------------------------------------------------------------------ */
/* SoC control registers (ctrl_registers.sv, 64b-strided AXI)          */
/* ------------------------------------------------------------------ */
#define SOC_CTRL_BASE           0xD0000000UL

/* ------------------------------------------------------------------ */
/* Platform clock / baudrate defaults                                 */
/* ------------------------------------------------------------------ */
#ifdef TARGET_FPGA
    /* FPGA */
    #define SYS_CLK_HZ      40000000UL    /* 40 MHz */
    #define BAUD_RATE       115200UL      /* 标准串口终端波特率 */
#else
    /* RTL sim */
    #define SYS_CLK_HZ      500000000UL   /* 500 MHz — matches tb.sv */
    #define BAUD_RATE       6250000UL     /* 500 MHz / (16*5) exact  */
#endif

#endif /* ARA_SOC_H */
