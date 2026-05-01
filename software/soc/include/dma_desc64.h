#ifndef DMA_DESC64_H
#define DMA_DESC64_H
/*
 * Driver for the iDMA desc64 frontend (ariane_dma_desc64.sv) mapped at DMA_BASE.
 *
 * The desc64 frontend is descriptor-based: software prepares descriptors in
 * memory and writes their address to the DESC_ADDR register. The hardware
 * fetches descriptors via its own AXI master port, chains them, and fires
 * an IRQ on completion (per-descriptor, controlled by flag bit 0).
 *
 * Register map (only 2 registers):
 *   0x00  DESC_ADDR  (rw, 64-bit) - Write a descriptor address to enqueue.
 *   0x08  STATUS     (ro, 64-bit) - bit 0: busy, bit 1: input FIFO full
 *
 * Descriptor layout in memory (4 x 64-bit words, 32 bytes, 16-byte aligned):
 *   Word 0 [63:0]:  flags[63:32] | length[31:0]
 *   Word 1 [63:0]:  next descriptor address (0xFFFF_FFFF_FFFF_FFFF = end of chain)
 *   Word 2 [63:0]:  source address
 *   Word 3 [63:0]:  destination address
 *
 * Flags (upper 32 bits of word 0):
 *   bit  0         set to trigger an IRQ on completion
 *   bits 2:1       source burst type (00=FIXED, 01=INCR, 10=WRAP)
 *   bits 4:3       destination burst type
 *   bit  5         decouple_rw (decouple reads and writes in backend)
 *   bit  6         serialize (serialize requests)
 *   bit  7         deburst (split each burst into individual transfers)
 *   bits 11:8      AXI cache attributes for source
 *   bits 15:12     AXI cache attributes for destination
 *   bits 23:16     AXI ID used for the transfer
 *   bits 31:24     reserved
 */

#include <stdint.h>
#include <stddef.h>
#include "soc.h"

/* ---- Register offsets ----------------------------------------------- */
#define DMA_DESC64_DESC_ADDR_OFF    0x00u
#define DMA_DESC64_STATUS_OFF       0x08u

/* ---- Status register bits ------------------------------------------- */
#define DMA_DESC64_STATUS_BUSY      (1u << 0)
#define DMA_DESC64_STATUS_FIFO_FULL (1u << 1)

/* ---- Descriptor flags ----------------------------------------------- */
#define DMA_DESC64_FLAG_IRQ          (1u << 0)
#define DMA_DESC64_FLAG_SRC_INCR     (1u << 1)
#define DMA_DESC64_FLAG_DST_INCR     (1u << 3)
#define DMA_DESC64_FLAG_DECOUPLE_RW  (1u << 5)
#define DMA_DESC64_FLAG_SERIALIZE    (1u << 6)
#define DMA_DESC64_FLAG_DEBURST      (1u << 7)

/* End-of-chain marker for the next pointer */
#define DMA_DESC64_END_OF_CHAIN      0xFFFFFFFFFFFFFFFFULL

/* ---- Register access struct ----------------------------------------- */
struct dma_desc64_regs {
    /* 0x00 */ volatile uint64_t desc_addr;
    /* 0x08 */ volatile uint64_t status;
};

#define DMA_DESC64_0_REGS    ((struct dma_desc64_regs *)(DMA_BASE))

/* ---- Descriptor struct (must be 16-byte aligned in memory) ---------- */
struct dma_desc64_descriptor {
    uint64_t flags_and_length;   /* [31:0]=length, [63:32]=flags */
    uint64_t next;               /* next descriptor addr or END_OF_CHAIN */
    uint64_t src_addr;
    uint64_t dst_addr;
} __attribute__((aligned(16)));

/* ---- Helper to build flags_and_length field ------------------------- */
static inline uint64_t dma_desc64_pack(uint32_t length, uint32_t flags)
{
    return ((uint64_t)flags << 32) | (uint64_t)length;
}

/* ---- Driver object -------------------------------------------------- */
struct dma_desc64 {
    struct dma_desc64_regs *regs;

    void (*init)  (struct dma_desc64 *d, struct dma_desc64_regs *regs);

    /* Submit a single descriptor (blocking until FIFO has space). */
    void (*submit)(struct dma_desc64 *d, struct dma_desc64_descriptor *desc);

    /* Check if the DMA is busy. */
    int  (*busy)  (struct dma_desc64 *d);

    /* Blocking wait until DMA is idle. */
    void (*wait)  (struct dma_desc64 *d);
};

extern struct dma_desc64 dma_desc64_0;

void dma_desc64_bind(struct dma_desc64 *d);

#endif /* DMA_DESC64_H */
