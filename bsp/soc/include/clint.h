#ifndef ARA_CLINT_H
#define ARA_CLINT_H

#include <stdint.h>
#include "soc.h"

/* Number of harts served by this CLINT. */
#ifndef CLINT_NUM_HARTS
#define CLINT_NUM_HARTS  1u
#endif

/*
 * SiFive-compatible CLINT register block.  Offsets are sparse by spec:
 *   0x0000  msip[hart]      uint32_t, 4B per hart
 *   0x4000  mtimecmp[hart]  uint64_t, 8B per hart
 *   0xBFF8  mtime           uint64_t, shared
 */
struct clint_regs {
    volatile uint32_t msip[CLINT_NUM_HARTS];
    uint8_t           _pad0[0x4000u - CLINT_NUM_HARTS * sizeof(uint32_t)];
    volatile uint64_t mtimecmp[CLINT_NUM_HARTS];
    uint8_t           _pad1[0xBFF8u - 0x4000u - CLINT_NUM_HARTS * sizeof(uint64_t)];
    volatile uint64_t mtime;
};

#define CLINT0_REGS   ((struct clint_regs *)(CLINT_BASE))

struct clint;

struct clint {
    struct clint_regs *regs;

    /* OO-style ops. */
    void     (*init)             (struct clint *c, struct clint_regs *regs);

    /* Timer */
    uint64_t (*get_mtime)        (struct clint *c);
    void     (*set_mtimecmp)     (struct clint *c, unsigned hart, uint64_t t);
    void     (*schedule_after)   (struct clint *c, unsigned hart, uint64_t cycles);
    void     (*register_timer_cb)(struct clint *c,
                                  void (*fn)(void *arg), void *arg);

    /* Software IPI */
    void     (*send_ipi)         (struct clint *c, unsigned hart);
    void     (*clear_ipi)        (struct clint *c, unsigned hart);
    void     (*register_ipi_cb)  (struct clint *c,
                                  void (*fn)(void *arg), void *arg);

    /* Handler entries (populated by register_*_cb). */
    void (*timer_cb)(void *);
    void  *timer_arg;
    void (*ipi_cb)  (void *);
    void  *ipi_arg;
};

extern struct clint clint0;

void clint_bind(struct clint *c);

/* Called from handlers.S. */
void clint_handle_m_timer_irq(void);
void clint_handle_m_sw_irq(void);

#endif
