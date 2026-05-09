#ifndef ASIC_ACCEL_H
#define ASIC_ACCEL_H

#include <stdint.h>
#include "soc.h"

#define ASIC_ACCEL_CMD_OFF        0x00u
#define ASIC_ACCEL_STATUS_OFF     0x08u
#define ASIC_ACCEL_OP_A_OFF       0x10u
#define ASIC_ACCEL_OP_B_OFF       0x18u
#define ASIC_ACCEL_RESULT_OFF     0x20u
#define ASIC_ACCEL_CYCLE_CNT_OFF  0x28u
#define ASIC_ACCEL_IRQ_MASK_OFF   0x30u
#define ASIC_ACCEL_IRQ_STAT_OFF   0x38u

#define ASIC_ACCEL_CMD_START      (1u << 0)
#define ASIC_ACCEL_CMD_CLR_DONE   (1u << 1)

#define ASIC_ACCEL_STATUS_BUSY    (1u << 0)
#define ASIC_ACCEL_STATUS_DONE    (1u << 1)

struct asic_accel_regs {
    volatile uint64_t cmd;
    volatile uint64_t status;
    volatile uint64_t op_a;
    volatile uint64_t op_b;
    volatile uint64_t result;
    volatile uint64_t cycle_cnt;
    volatile uint64_t irq_mask;
    volatile uint64_t irq_status;
};

#define ASIC_ACCEL_REGS ((struct asic_accel_regs *)(ASIC_ACCEL_BASE))

struct asic_accel {
    struct asic_accel_regs *regs;
    void     (*init)(struct asic_accel *a, struct asic_accel_regs *regs);
    void     (*set_operands)(struct asic_accel *a, uint64_t op_a, uint64_t op_b);
    void     (*start)(struct asic_accel *a);
    int      (*busy)(struct asic_accel *a);
    void     (*wait)(struct asic_accel *a);
    uint64_t (*result)(struct asic_accel *a);
    uint64_t (*cycle_cnt)(struct asic_accel *a);
    void     (*irq_enable)(struct asic_accel *a, int en);
    void     (*irq_clear)(struct asic_accel *a);
};

extern struct asic_accel asic_accel0;

void asic_accel_bind(struct asic_accel *a);

#endif
