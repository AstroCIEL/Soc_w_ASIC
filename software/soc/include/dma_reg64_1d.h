#ifndef DMA_REG64_1D_H
#define DMA_REG64_1D_H

#include <stdint.h>
#include <stddef.h>
#include "soc.h"

#define DMA_REG64_1D_NUM_STREAMS     16u

/* ---- CONF register bitfield ----------------------------------------- */
union dma_reg64_1d_conf {
    struct {
        uint32_t decouple_aw    : 1;  /* [0]    Decouple AW from R (AW after 1st R) */
        uint32_t decouple_rw    : 1;  /* [1]    Fully decouple R and W channels     */
        uint32_t src_reduce_len : 1;  /* [2]    Reduce max source burst length      */
        uint32_t dst_reduce_len : 1;  /* [3]    Reduce max destination burst length */
        uint32_t src_max_llen   : 3;  /* [6:4]  Log2 max source burst length        */
        uint32_t dst_max_llen   : 3;  /* [9:7]  Log2 max destination burst length   */
        uint32_t enable_nd      : 1;  /* [10]   Enable N-D extension (keep 0 for 1D)*/
        uint32_t src_protocol   : 3;  /* [13:11] Source protocol (0=AXI)            */
        uint32_t dst_protocol   : 3;  /* [16:14] Destination protocol (0=AXI)       */
        uint32_t _reserved      : 15; /* [31:17] Reserved                           */
    };
    volatile uint32_t raw;
};

static const union dma_reg64_1d_conf DMA_REG64_1D_CONF_DEFAULT = { .raw = 0u };

/* ---- Register map (struct-of-MMIO) --------------------------------- */
struct dma_reg64_1d_regs {
    /* 0x00 */ volatile union dma_reg64_1d_conf conf;
    /* 0x04 */ volatile uint32_t status  [DMA_REG64_1D_NUM_STREAMS];  /* 0x04..0x40 */
    /* 0x44 */ volatile uint32_t next_id [DMA_REG64_1D_NUM_STREAMS];  /* 0x44..0x80 */
    /* 0x84 */ volatile uint32_t done_id [DMA_REG64_1D_NUM_STREAMS];  /* 0x84..0xC0 */
    /* 0xC4 */ uint32_t          _pad    [(0xD0 - 0xC4) / 4];
    /* 0xD0 */ volatile uint32_t dst_addr_low;
    /* 0xD4 */ volatile uint32_t dst_addr_high;
    /* 0xD8 */ volatile uint32_t src_addr_low;
    /* 0xDC */ volatile uint32_t src_addr_high;
    /* 0xE0 */ volatile uint32_t length_low;
    /* 0xE4 */ volatile uint32_t length_high;
};

/* STATUS[i] fields - backend busy_vec[8:0] + midend_busy[9] */
#define DMA_REG64_1D_STATUS_BUSY_MASK    0x3FFu



#define DMA_REG64_1D_0_REGS    ((struct dma_reg64_1d_regs *)(DMA_BASE))

struct dma_reg64_1d {
    struct dma_reg64_1d_regs *regs;

    void     (*init)   (struct dma_reg64_1d *d, struct dma_reg64_1d_regs *regs);

    /* Submit a 1D memcpy of `len` bytes from `src` to `dst`.  Returns the
     * hardware-issued transfer id assigned to this launch. */
    uint32_t (*submit) (struct dma_reg64_1d *d, uint64_t dst, uint64_t src,
                        uint64_t len);

    /* Returns non-zero while any backend/midend lane is working. */
    int      (*busy)   (struct dma_reg64_1d *d);

    /* Blocking wait for a specific transfer id previously returned by
     * submit(). */
    void     (*wait)   (struct dma_reg64_1d *d, uint32_t id);

    /* Last completed transfer id (monotonic). */
    uint32_t (*done_id)(struct dma_reg64_1d *d);
};

extern struct dma_reg64_1d dma_reg64_1d_0;

void dma_reg64_1d_bind(struct dma_reg64_1d *d);

#endif /* DMA_REG64_1D_H */
