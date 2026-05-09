#ifndef ASIC_DMA_ACCEL_H
#define ASIC_DMA_ACCEL_H

#include <stdint.h>
#include "soc.h"

#define ASIC_DMA_CMD_OFF       0x00u
#define ASIC_DMA_STATUS_OFF    0x08u
#define ASIC_DMA_SRC_OFF       0x10u
#define ASIC_DMA_DST_OFF       0x18u
#define ASIC_DMA_LEN_OFF       0x20u
#define ASIC_DMA_CYCLES_OFF    0x28u
#define ASIC_DMA_IRQ_MASK_OFF  0x30u
#define ASIC_DMA_IRQ_STAT_OFF  0x38u
#define ASIC_DMA_RESULT_OFF    0x40u

#define ASIC_DMA_CMD_START     (1u << 0)
#define ASIC_DMA_CMD_CLR_DONE  (1u << 1)

#define ASIC_DMA_STATUS_BUSY   (1u << 0)
#define ASIC_DMA_STATUS_DONE   (1u << 1)

struct asic_dma_regs {
    volatile uint64_t cmd;
    volatile uint64_t status;
    volatile uint64_t src_addr;
    volatile uint64_t dst_addr;
    volatile uint64_t length;
    volatile uint64_t cycle_cnt;
    volatile uint64_t irq_mask;
    volatile uint64_t irq_status;
    volatile uint64_t result;
};

#define ASIC_DMA_REGS ((struct asic_dma_regs *)(ASIC_ACCEL_BASE))

struct asic_dma_accel {
    struct asic_dma_regs *regs;
    void     (*init)(struct asic_dma_accel *a, struct asic_dma_regs *regs);
    void     (*config)(struct asic_dma_accel *a, uint64_t src, uint64_t dst, uint64_t len);
    void     (*start)(struct asic_dma_accel *a);
    int      (*busy)(struct asic_dma_accel *a);
    void     (*wait)(struct asic_dma_accel *a);
    uint64_t (*cycle_cnt)(struct asic_dma_accel *a);
    void     (*irq_enable)(struct asic_dma_accel *a, int en);
    void     (*irq_clear)(struct asic_dma_accel *a);
};

extern struct asic_dma_accel asic_dma0;

void asic_dma_bind(struct asic_dma_accel *a);

#endif
