#include <stdint.h>
#include "vmma.h"

static void vmma_op_init(struct vmma_drv *d, struct vmma_regs *r)
{
    d->regs = r;
    d->regs->irq_mask = 0;
    d->regs->irq_status = 1;
    d->regs->cmd = VMMA_CMD_CLR_DONE;
}

static void vmma_op_config(struct vmma_drv *d, vmma_dtype_t dt, uint32_t m, uint32_t n,
                            uint64_t w, uint64_t x, uint64_t y, uint64_t w_stride)
{
    d->regs->ctrl = (uint64_t)(dt & 3u);
    d->regs->m_dim = m;
    d->regs->n_dim = n;
    d->regs->w_addr = w;
    d->regs->x_addr = x;
    d->regs->y_addr = y;
    d->regs->w_stride = w_stride;
}

static void vmma_op_start(struct vmma_drv *d)
{
    d->regs->cmd = VMMA_CMD_START;
}

static int vmma_op_busy(struct vmma_drv *d)
{
    return (d->regs->status & VMMA_STATUS_BUSY) != 0;
}

static void vmma_op_wait(struct vmma_drv *d)
{
    while (d->regs->status & VMMA_STATUS_BUSY)
        __asm__ volatile ("nop");
}

static uint64_t vmma_op_cycles(struct vmma_drv *d)
{
    return d->regs->cycle_cnt;
}

static void vmma_op_irq_enable(struct vmma_drv *d, int en)
{
    d->regs->irq_mask = en ? 1u : 0u;
}

static void vmma_op_irq_clear(struct vmma_drv *d)
{
    d->regs->irq_status = 1u;
    d->regs->cmd = VMMA_CMD_CLR_DONE;
}

struct vmma_drv vmma0;

void vmma_bind(struct vmma_drv *d)
{
    d->init = vmma_op_init;
    d->config = vmma_op_config;
    d->start = vmma_op_start;
    d->busy = vmma_op_busy;
    d->wait = vmma_op_wait;
    d->cycles = vmma_op_cycles;
    d->irq_enable = vmma_op_irq_enable;
    d->irq_clear = vmma_op_irq_clear;
}
