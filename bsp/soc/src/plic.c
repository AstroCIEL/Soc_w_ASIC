#include <stdint.h>
#include "soc.h"
#include "plic.h"
#include "serial.h"

#define PLIC_MAX_SOURCE   31u

typedef struct {
    plic_isr_t fn;
    void      *arg;
} plic_entry_t;

static plic_entry_t plic_table[PLIC_MAX_SOURCE + 1];

static void plic_default_isr(IRQn_Type irq, void *arg)
{
    (void)arg; (void)irq;
    uart_puts(&uart0, "BSP: spurious PLIC IRQ\n");
}

void plic_init(plic_regs_t *p)
{
    for (unsigned i = 0; i <= PLIC_MAX_SOURCE; i++)
        p->priority[i] = 0;

    for (unsigned t = 0; t < PLIC_NUM_TARGETS; t++) {
        for (unsigned w = 0; w < 32; w++)
            p->enable[t][w] = 0;
        p->target[t].threshold = 0;
    }

    for (unsigned i = 0; i <= PLIC_MAX_SOURCE; i++) {
        plic_table[i].fn  = plic_default_isr;
        plic_table[i].arg = 0;
    }
}

void plic_set_priority(plic_regs_t *p, IRQn_Type irq, unsigned prio)
{
    if ((unsigned)irq > PLIC_MAX_SOURCE) return;
    p->priority[(unsigned)irq] = prio & 0x7u;
}

void plic_enable(plic_regs_t *p, unsigned ctx, IRQn_Type irq)
{
    if (ctx >= PLIC_NUM_TARGETS || (unsigned)irq > PLIC_MAX_SOURCE) return;
    p->enable[ctx][(unsigned)irq / 32u] |= (1u << ((unsigned)irq & 31u));
}

void plic_disable(plic_regs_t *p, unsigned ctx, IRQn_Type irq)
{
    if (ctx >= PLIC_NUM_TARGETS || (unsigned)irq > PLIC_MAX_SOURCE) return;
    p->enable[ctx][(unsigned)irq / 32u] &= ~(1u << ((unsigned)irq & 31u));
}

void plic_set_threshold(plic_regs_t *p, unsigned ctx, unsigned thr)
{
    if (ctx >= PLIC_NUM_TARGETS) return;
    p->target[ctx].threshold = thr & 0x7u;
}

void plic_register_handler(IRQn_Type irq, plic_isr_t fn, void *arg)
{
    if ((unsigned)irq > PLIC_MAX_SOURCE) return;
    plic_table[(unsigned)irq].fn  = fn ? fn : plic_default_isr;
    plic_table[(unsigned)irq].arg = arg;
}

void plic_handle_m_ext_irq(void)
{
    uint32_t id = plic_claim(PLIC0, PLIC_CTX_M0);

    if (id == 0 || id > PLIC_MAX_SOURCE)
        return;

    plic_entry_t *e = &plic_table[id];
    e->fn((IRQn_Type)id, e->arg);

    plic_complete(PLIC0, PLIC_CTX_M0, id);
}
