/* Driver for the iDMA reg64_1d frontend (see dma_reg64_1d.h). */

#include <stdint.h>
#include "dma_reg64_1d.h"

static void dma_reg64_1d_op_init(struct dma_reg64_1d *d, struct dma_reg64_1d_regs *regs)
{
    d->regs = regs;
    d->regs->conf = DMA_REG64_1D_CONF_DEFAULT;
}

static uint32_t dma_reg64_1d_op_submit(struct dma_reg64_1d *d, uint64_t dst, uint64_t src,
                                       uint64_t len)
{
    struct dma_reg64_1d_regs *r = d->regs;

    /* 1. Program the descriptor fields. */
    r->src_addr_low  = (uint32_t)(src);
    r->src_addr_high = (uint32_t)(src >> 32);
    r->dst_addr_low  = (uint32_t)(dst);
    r->dst_addr_high = (uint32_t)(dst >> 32);
    r->length_low    = (uint32_t)(len);
    r->length_high   = (uint32_t)(len >> 32);

    /* 2. Drain the programming writes, then launch by READING next_id[0].
     *    The reggen-backed frontend uses the read-enable as the submission
     *    trigger; the value read is the 32-bit transfer id assigned to
     *    this launch. */
    __asm__ volatile ("fence ow, ir" ::: "memory");
    return r->next_id[0];
}

static int dma_reg64_1d_op_busy(struct dma_reg64_1d *d)
{
    return (d->regs->status[0] & DMA_REG64_1D_STATUS_BUSY_MASK) != 0;
}

static uint32_t dma_reg64_1d_op_done_id(struct dma_reg64_1d *d)
{
    return d->regs->done_id[0];
}

static void dma_reg64_1d_op_wait(struct dma_reg64_1d *d, uint32_t id)
{
    /* Counter is monotonic; use signed delta to tolerate 32-bit wrap. */
    while ((int32_t)(d->regs->done_id[0] - id) < 0)
        __asm__ volatile ("nop");
}

struct dma_reg64_1d dma_reg64_1d_0;

void dma_reg64_1d_bind(struct dma_reg64_1d *d)
{
    d->init    = dma_reg64_1d_op_init;
    d->submit  = dma_reg64_1d_op_submit;
    d->busy    = dma_reg64_1d_op_busy;
    d->wait    = dma_reg64_1d_op_wait;
    d->done_id = dma_reg64_1d_op_done_id;
}
