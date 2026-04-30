#ifndef ARA_PLIC_H
#define ARA_PLIC_H

#include <stdint.h>
#include "soc.h"

#define PLIC_NUM_TARGETS    2u
#define PLIC_NUM_SOURCES    32u

/* Target (context) ids used by the OO API. */
#define PLIC_CTX_M0  0u   /* hart 0, M-mode */
#define PLIC_CTX_S0  1u   /* hart 0, S-mode */

/* ------------------------------------------------------------------ */
/*  rv_plic register block -- SiFive-style sparse layout               */
/*                                                                      */
/*    0x000000  priority[i]            (i = 0..N_SOURCE)                */
/*    0x001000  pending bit array                                       */
/*    0x002000  enable bit array, target 0                              */
/*    0x002080  enable bit array, target 1                              */
/*    0x200000  threshold / claim-complete, target 0                    */
/*    0x201000  threshold / claim-complete, target 1                    */
/*                                                                      */
/*  Source id mapping (plic_top.sv inserts a one-slot offset):          */
/*     SW-visible id  = irq_sources[]_index + 1                         */
/*     id 0 is the SiFive "no interrupt" sentinel.                      */
/* ------------------------------------------------------------------ */
struct plic_target_regs {
    volatile uint32_t threshold;
    volatile uint32_t claim_complete;
    uint32_t          _rsv[(0x1000 - 8) / 4];
};

struct plic_regs {
    volatile uint32_t priority[1024];                               /* 0x000000 */
    volatile uint32_t pending [1024];                               /* 0x001000 */
    volatile uint32_t enable  [PLIC_NUM_TARGETS][32];               /* 0x002000 */
    uint32_t          _pad[(0x200000 - 0x002100) / 4];
    struct plic_target_regs target[PLIC_NUM_TARGETS];               /* 0x200000 */
};

#define PLIC0_REGS  ((struct plic_regs *)(PLIC_BASE))

struct plic_entry {
    void  (*fn)(irqn_t irq, void *arg);
    void   *arg;
};

struct plic;

struct plic {
    struct plic_regs *regs;
    struct plic_entry table[PLIC_NUM_SOURCES];

    /* OO-style ops; populated by plic_bind() at init time. */
    void     (*init)           (struct plic *p, struct plic_regs *regs);
    void     (*set_priority)   (struct plic *p, irqn_t irq, unsigned prio);
    void     (*enable)         (struct plic *p, unsigned ctx, irqn_t irq);
    void     (*disable)        (struct plic *p, unsigned ctx, irqn_t irq);
    void     (*set_threshold)  (struct plic *p, unsigned ctx, unsigned thr);
    void     (*register_handler)(struct plic *p, irqn_t irq,
                                 void (*fn)(irqn_t, void *), void *arg);
    uint32_t (*claim)          (struct plic *p, unsigned ctx);
    void     (*complete)       (struct plic *p, unsigned ctx, uint32_t irq);
    void     (*handle_m_ext)   (struct plic *p);
};

extern struct plic plic0;

/* Install the default ops into `p`. */
void plic_bind(struct plic *p);

/* Bridge called from handlers.S on M-mode external IRQ; dispatches on plic0. */
void plic_handle_m_ext_irq(void);

#endif
