#include <stdint.h>
#include "soc.h"
#include "clint.h"
#include "serial.h"

static void clint_default_cb(void *arg)
{
    (void)arg;
    uart0.puts(&uart0, "BSP: unhandled CLINT IRQ\n");
}

static void clint_op_init(struct clint *c, struct clint_regs *regs)
{
    c->regs = regs;

    c->timer_cb  = clint_default_cb;
    c->timer_arg = 0;
    c->ipi_cb    = clint_default_cb;
    c->ipi_arg   = 0;

    for (unsigned h = 0; h < CLINT_NUM_HARTS; h++)
        regs->msip[h] = 0;
}

static uint64_t clint_op_get_mtime(struct clint *c)
{
    return c->regs->mtime;
}

static void clint_op_set_mtimecmp(struct clint *c, unsigned hart, uint64_t t)
{
    if (hart >= CLINT_NUM_HARTS) return;
    c->regs->mtimecmp[hart] = t;
}

static void clint_op_schedule_after(struct clint *c, unsigned hart, uint64_t cycles)
{
    if (hart >= CLINT_NUM_HARTS) return;
    c->regs->mtimecmp[hart] = c->regs->mtime + cycles;
}

static void clint_op_register_timer_cb(struct clint *c,
                                       void (*fn)(void *), void *arg)
{
    c->timer_cb  = fn ? fn : clint_default_cb;
    c->timer_arg = arg;
}

static void clint_op_send_ipi(struct clint *c, unsigned hart)
{
    if (hart >= CLINT_NUM_HARTS) return;
    c->regs->msip[hart] = 1;
}

static void clint_op_clear_ipi(struct clint *c, unsigned hart)
{
    if (hart >= CLINT_NUM_HARTS) return;
    c->regs->msip[hart] = 0;
}

static void clint_op_register_ipi_cb(struct clint *c,
                                     void (*fn)(void *), void *arg)
{
    c->ipi_cb  = fn ? fn : clint_default_cb;
    c->ipi_arg = arg;
}

struct clint clint0;

void clint_bind(struct clint *c)
{
    c->init              = clint_op_init;
    c->get_mtime         = clint_op_get_mtime;
    c->set_mtimecmp      = clint_op_set_mtimecmp;
    c->schedule_after    = clint_op_schedule_after;
    c->register_timer_cb = clint_op_register_timer_cb;
    c->send_ipi          = clint_op_send_ipi;
    c->clear_ipi         = clint_op_clear_ipi;
    c->register_ipi_cb   = clint_op_register_ipi_cb;
}

/* ----- handlers.S entry points ------------------------------------ */

void clint_handle_m_timer_irq(void)
{
    clint0.timer_cb(clint0.timer_arg);
}

void clint_handle_m_sw_irq(void)
{
    /* Ack first so the line drops before returning. */
    clint0.regs->msip[0] = 0;
    clint0.ipi_cb(clint0.ipi_arg);
}
