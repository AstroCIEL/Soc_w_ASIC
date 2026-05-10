#ifndef VMMA_H
#define VMMA_H

#include <stdint.h>
#include "soc.h"

/* 64-bit AXI cfg slots — match hardware/user_ip/vmma/vmma_sim.sv */
#define VMMA_REG_CMD_OFF       0x00u
#define VMMA_REG_STATUS_OFF    0x08u
#define VMMA_REG_CTRL_OFF      0x10u
#define VMMA_REG_M_OFF         0x18u
#define VMMA_REG_N_OFF         0x20u
#define VMMA_REG_W_ADDR_OFF    0x28u
#define VMMA_REG_X_ADDR_OFF    0x30u
#define VMMA_REG_Y_ADDR_OFF    0x38u
#define VMMA_REG_W_STRIDE_OFF  0x40u
#define VMMA_REG_CYCLE_CNT_OFF 0x48u
#define VMMA_REG_IRQ_MASK_OFF  0x50u
#define VMMA_REG_IRQ_STAT_OFF  0x58u

#define VMMA_CMD_START     (1u << 0)
#define VMMA_CMD_CLR_DONE  (1u << 1)

#define VMMA_STATUS_BUSY   (1u << 0)
#define VMMA_STATUS_DONE   (1u << 1)
#define VMMA_STATUS_ERR_M  (0xfu << 4)

typedef enum {
    VMMA_DTYPE_INT8  = 0,
    VMMA_DTYPE_INT16 = 1,
    VMMA_DTYPE_FP16  = 2,
    VMMA_DTYPE_FP32  = 3
} vmma_dtype_t;

struct vmma_regs {
    volatile uint64_t cmd;
    volatile uint64_t status;
    volatile uint64_t ctrl;
    volatile uint64_t m_dim;
    volatile uint64_t n_dim;
    volatile uint64_t w_addr;
    volatile uint64_t x_addr;
    volatile uint64_t y_addr;
    volatile uint64_t w_stride;
    volatile uint64_t cycle_cnt;
    volatile uint64_t irq_mask;
    volatile uint64_t irq_status;
};

#define VMMA_REGS ((struct vmma_regs *)(VMMA_ACCEL_BASE))

struct vmma_drv {
    struct vmma_regs *regs;
    void (*init)(struct vmma_drv *d, struct vmma_regs *r);
    void (*config)(struct vmma_drv *d, vmma_dtype_t dt, uint32_t m, uint32_t n,
                   uint64_t w, uint64_t x, uint64_t y, uint64_t w_stride);
    void (*start)(struct vmma_drv *d);
    int (*busy)(struct vmma_drv *d);
    void (*wait)(struct vmma_drv *d);
    uint64_t (*cycles)(struct vmma_drv *d);
    void (*irq_enable)(struct vmma_drv *d, int en);
    void (*irq_clear)(struct vmma_drv *d);
};

extern struct vmma_drv vmma0;

void vmma_bind(struct vmma_drv *d);

/* Hardware DMA uses 64-bit AXI reads for each weight row: keep w_stride a multiple of 8.
 * On CVA6 WT D$, place DMA output buffers away from inputs or use explicit cache maintenance,
 * otherwise prefetch can leave a valid stale line after an external master writes DRAM. */

#endif
