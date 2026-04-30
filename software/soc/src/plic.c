#include <stdint.h>
#include "soc.h"
#include "plic.h"
#include "serial.h"

/* Default console-visible stub for unregistered sources. */
static void plic_default_isr(irqn_t irq, void *arg)
{
    (void)irq; (void)arg;
    uart0.puts(&uart0, "BSP: spurious PLIC IRQ\n");
}

static void plic_op_init(struct plic *p, struct plic_regs *regs)
{
    p->regs = regs;

    for (unsigned i = 0; i < PLIC_NUM_SOURCES; i++)
        regs->priority[i] = 0;

    for (unsigned t = 0; t < PLIC_NUM_TARGETS; t++) {
        for (unsigned w = 0; w < 32; w++)
            regs->enable[t][w] = 0;
        regs->target[t].threshold = 0;
    }

    for (unsigned i = 0; i < PLIC_NUM_SOURCES; i++) {
        p->table[i].fn  = plic_default_isr;
        p->table[i].arg = 0;
    }
}

static void plic_op_set_priority(struct plic *p, irqn_t irq, unsigned prio)
{
    if ((unsigned)irq >= PLIC_NUM_SOURCES) return;
    p->regs->priority[(unsigned)irq] = prio & 0x7u;
}

static void plic_op_enable(struct plic *p, unsigned ctx, irqn_t irq)
{
    if (ctx >= PLIC_NUM_TARGETS || (unsigned)irq >= PLIC_NUM_SOURCES) return;
    p->regs->enable[ctx][(unsigned)irq / 32u] |= (1u << ((unsigned)irq & 31u));
}

static void plic_op_disable(struct plic *p, unsigned ctx, irqn_t irq)
{
    if (ctx >= PLIC_NUM_TARGETS || (unsigned)irq >= PLIC_NUM_SOURCES) return;
    p->regs->enable[ctx][(unsigned)irq / 32u] &= ~(1u << ((unsigned)irq & 31u));
}

static void plic_op_set_threshold(struct plic *p, unsigned ctx, unsigned thr)
{
    if (ctx >= PLIC_NUM_TARGETS) return;
    p->regs->target[ctx].threshold = thr & 0x7u;
}

static void plic_op_register_handler(struct plic *p, irqn_t irq,
                                     void (*fn)(irqn_t, void *), void *arg)
{
    if ((unsigned)irq >= PLIC_NUM_SOURCES) return;
    p->table[(unsigned)irq].fn  = fn ? fn : plic_default_isr;
    p->table[(unsigned)irq].arg = arg;
}

static uint32_t plic_op_claim(struct plic *p, unsigned ctx)
{
    return p->regs->target[ctx].claim_complete;
}

static void plic_op_complete(struct plic *p, unsigned ctx, uint32_t irq)
{
    p->regs->target[ctx].claim_complete = irq;
}

static void plic_op_handle_m_ext(struct plic *p)
{
    uint32_t id = p->claim(p, PLIC_CTX_M0);

    if (id == 0 || id >= PLIC_NUM_SOURCES)
        return;

    p->table[id].fn((irqn_t)id, p->table[id].arg);
    p->complete(p, PLIC_CTX_M0, id);
}

struct plic plic0;

void plic_bind(struct plic *p)
{
    p->init             = plic_op_init;
    p->set_priority     = plic_op_set_priority;
    p->enable           = plic_op_enable;
    p->disable          = plic_op_disable;
    p->set_threshold    = plic_op_set_threshold;
    p->register_handler = plic_op_register_handler;
    p->claim            = plic_op_claim;
    p->complete         = plic_op_complete;
    p->handle_m_ext     = plic_op_handle_m_ext;
}

void plic_handle_m_ext_irq(void)
{
    plic0.handle_m_ext(&plic0);
}
