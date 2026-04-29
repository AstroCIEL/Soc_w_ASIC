#ifndef SOC_CTRL_H
#define SOC_CTRL_H

#include <stdint.h>
#include "soc.h"

/*
 * ctrl_registers.sv memory map, viewed as a 64-bit-strided AXI aperture
 * starting at SOC_CTRL_BASE:
 *
 *   off 0x00  exit            rw  (bit0 = EOC, [31:1] = status)
 *   off 0x08  dram_base_addr  ro
 *   off 0x10  dram_end_addr   ro
 *   off 0x18  event_trigger   rw
 *   off 0x20  hw_cnt_en       rw
 */
struct soc_ctrl_regs {
    uint64_t exit;
    uint64_t dram_base_addr;
    uint64_t dram_end_addr;
    uint64_t event_trigger;
    uint64_t hw_cnt_en;
};

struct soc_ctrl {
    struct soc_ctrl_regs *regs;

    void     (*init)          (struct soc_ctrl *c, struct soc_ctrl_regs *regs);

    /* End-of-computation: latches status and halts the hart. */
    void     (*exit)          (struct soc_ctrl *c, int status) __attribute__((noreturn));

    /* Read-only DRAM window reported by the SoC. */
    uint64_t (*dram_base)     (struct soc_ctrl *c);
    uint64_t (*dram_end)      (struct soc_ctrl *c);

    /* Free-form event trigger rw scratch (TB/monitor observable). */
    void     (*set_event)     (struct soc_ctrl *c, uint64_t v);
    uint64_t (*get_event)     (struct soc_ctrl *c);

    /* Hardware performance-counter enable. */
    void     (*hw_cnt_enable) (struct soc_ctrl *c);
    void     (*hw_cnt_disable)(struct soc_ctrl *c);
    uint64_t (*hw_cnt_get)    (struct soc_ctrl *c);
};

#define SOC_CTRL0_REGS  ((struct soc_ctrl_regs *)(SOC_CTRL_BASE))

extern struct soc_ctrl soc_ctrl0;

void soc_ctrl_bind(struct soc_ctrl *c);

/* Back-compat tail call used by syscalls.c::_exit(). */
void soc_exit(int status) __attribute__((noreturn));

#endif /* SOC_CTRL_H */
