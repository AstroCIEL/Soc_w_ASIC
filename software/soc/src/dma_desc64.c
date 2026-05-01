/* Driver for the iDMA desc64 frontend (see dma_desc64.h). */

#include <stdint.h>
#include "dma_desc64.h"

static void dma_desc64_op_init(struct dma_desc64 *d, struct dma_desc64_regs *regs)
{
    d->regs = regs;
}

static void dma_desc64_op_submit(struct dma_desc64 *d,
                                  struct dma_desc64_descriptor *desc)
{
    /* Wait until the input FIFO has space. */
    while (d->regs->status & DMA_DESC64_STATUS_FIFO_FULL)
        __asm__ volatile ("nop");

    /* Ensure descriptor is visible in memory before writing its address. */
    __asm__ volatile ("fence ow, ow" ::: "memory");

    /* Write descriptor address to enqueue. */
    d->regs->desc_addr = (uint64_t)(uintptr_t)desc;
}

static int dma_desc64_op_busy(struct dma_desc64 *d)
{
    return (d->regs->status & DMA_DESC64_STATUS_BUSY) != 0;
}

static void dma_desc64_op_wait(struct dma_desc64 *d)
{
    while (d->regs->status & DMA_DESC64_STATUS_BUSY)
        __asm__ volatile ("nop");
}

struct dma_desc64 dma_desc64_0;

void dma_desc64_bind(struct dma_desc64 *d)
{
    d->init   = dma_desc64_op_init;
    d->submit = dma_desc64_op_submit;
    d->busy   = dma_desc64_op_busy;
    d->wait   = dma_desc64_op_wait;
}
