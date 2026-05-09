#include <stdint.h>
#include "asic_dma_accel.h"

static void asic_dma_op_init(struct asic_dma_accel *a, struct asic_dma_regs *regs)
{
    a->regs = regs;
    a->regs->irq_mask = 0;
    a->regs->irq_status = 1;
    a->regs->cmd = ASIC_DMA_CMD_CLR_DONE;
}

static void asic_dma_op_config(struct asic_dma_accel *a, uint64_t src, uint64_t dst, uint64_t len)
{
    a->regs->src_addr = src;
    a->regs->dst_addr = dst;
    a->regs->length = len;
}

static void asic_dma_op_start(struct asic_dma_accel *a)
{
    a->regs->cmd = ASIC_DMA_CMD_START;
}

static int asic_dma_op_busy(struct asic_dma_accel *a)
{
    return (a->regs->status & ASIC_DMA_STATUS_BUSY) != 0;
}

static void asic_dma_op_wait(struct asic_dma_accel *a)
{
    while (a->regs->status & ASIC_DMA_STATUS_BUSY)
        __asm__ volatile ("nop");
}

static uint64_t asic_dma_op_cycle_cnt(struct asic_dma_accel *a)
{
    return a->regs->cycle_cnt;
}

static void asic_dma_op_irq_enable(struct asic_dma_accel *a, int en)
{
    a->regs->irq_mask = en ? 1u : 0u;
}

static void asic_dma_op_irq_clear(struct asic_dma_accel *a)
{
    a->regs->irq_status = 1u;
    a->regs->cmd = ASIC_DMA_CMD_CLR_DONE;
}

struct asic_dma_accel asic_dma0;

void asic_dma_bind(struct asic_dma_accel *a)
{
    a->init      = asic_dma_op_init;
    a->config    = asic_dma_op_config;
    a->start     = asic_dma_op_start;
    a->busy      = asic_dma_op_busy;
    a->wait      = asic_dma_op_wait;
    a->cycle_cnt = asic_dma_op_cycle_cnt;
    a->irq_enable = asic_dma_op_irq_enable;
    a->irq_clear  = asic_dma_op_irq_clear;
}
