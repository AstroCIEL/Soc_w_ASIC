#ifndef ARA_PLIC_H
#define ARA_PLIC_H

#include <stdint.h>
#include "soc.h"

#define PLIC_NUM_TARGETS    2u

typedef struct {
    volatile uint32_t threshold;
    volatile uint32_t claim_complete;
    uint32_t _rsv[(0x1000 - 8) / 4];
} plic_target_t;

typedef struct {
    volatile uint32_t priority[1024];                 /* 0x000000 */
    volatile uint32_t pending[1024];                  /* 0x001000 */
    volatile uint32_t enable[PLIC_NUM_TARGETS][32];   /* 0x002000 */
    uint32_t _pad[(0x200000 - 0x002100) / 4];
    plic_target_t     target[PLIC_NUM_TARGETS];       /* 0x200000 */
} plic_regs_t;

#define PLIC0        ((plic_regs_t *)(PLIC_BASE))
#define PLIC_CTX_M0  0u
#define PLIC_CTX_S0  1u

typedef void (*plic_isr_t)(IRQn_Type irq, void *arg);

void plic_init             (plic_regs_t *p);
void plic_set_priority     (plic_regs_t *p, IRQn_Type irq, unsigned prio);
void plic_enable           (plic_regs_t *p, unsigned ctx, IRQn_Type irq);
void plic_disable          (plic_regs_t *p, unsigned ctx, IRQn_Type irq);
void plic_set_threshold    (plic_regs_t *p, unsigned ctx, unsigned thr);
void plic_register_handler (IRQn_Type irq, plic_isr_t fn, void *arg);
void plic_handle_m_ext_irq (void);

static inline uint32_t plic_claim(plic_regs_t *p, unsigned ctx)
{
    return p->target[ctx].claim_complete;
}

static inline void plic_complete(plic_regs_t *p, unsigned ctx, uint32_t irq)
{
    p->target[ctx].claim_complete = irq;
}

#endif
