#include <stdint.h>
#include "asic_accel.h"

static void asic_accel_op_init(struct asic_accel *a, struct asic_accel_regs *regs)
{
    a->regs = regs;
    a->regs->irq_mask = 0;
    a->regs->irq_status = 1;
    a->regs->cmd = ASIC_ACCEL_CMD_CLR_DONE;
}

static void asic_accel_op_set_operands(struct asic_accel *a, uint64_t op_a, uint64_t op_b)
{
    a->regs->op_a = op_a;
    a->regs->op_b = op_b;
}

static void asic_accel_op_start(struct asic_accel *a)
{
    a->regs->cmd = ASIC_ACCEL_CMD_START;
}

static int asic_accel_op_busy(struct asic_accel *a)
{
    return (a->regs->status & ASIC_ACCEL_STATUS_BUSY) != 0;
}

static void asic_accel_op_wait(struct asic_accel *a)
{
    while (a->regs->status & ASIC_ACCEL_STATUS_BUSY)
        __asm__ volatile ("nop");
}

static uint64_t asic_accel_op_result(struct asic_accel *a)
{
    return a->regs->result;
}

static uint64_t asic_accel_op_cycle_cnt(struct asic_accel *a)
{
    return a->regs->cycle_cnt;
}

static void asic_accel_op_irq_enable(struct asic_accel *a, int en)
{
    a->regs->irq_mask = en ? 1u : 0u;
}

static void asic_accel_op_irq_clear(struct asic_accel *a)
{
    a->regs->irq_status = 1u;
    a->regs->cmd = ASIC_ACCEL_CMD_CLR_DONE;
}

struct asic_accel asic_accel0;

void asic_accel_bind(struct asic_accel *a)
{
    a->init         = asic_accel_op_init;
    a->set_operands = asic_accel_op_set_operands;
    a->start        = asic_accel_op_start;
    a->busy         = asic_accel_op_busy;
    a->wait         = asic_accel_op_wait;
    a->result       = asic_accel_op_result;
    a->cycle_cnt    = asic_accel_op_cycle_cnt;
    a->irq_enable   = asic_accel_op_irq_enable;
    a->irq_clear    = asic_accel_op_irq_clear;
}
