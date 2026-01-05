#ifndef TPU_UTILS_H
#define TPU_UTILS_H

#include <stdint.h>

// ============================================================================
// Address Map Definitions
// ============================================================================

#define TPU_BASE_ADDR           0x40000000

// UBUF Address Range (0x0000 - 0x29FF words)
#define UBUF_START_OFFSET       (0x0000 * 8)
#define UBUF_END_OFFSET         (0x29FF * 8)
#define UBUF_START_ADDR         (TPU_BASE_ADDR + UBUF_START_OFFSET)
#define UBUF_END_ADDR           (TPU_BASE_ADDR + UBUF_END_OFFSET)

// ICACHE Address Range (0x2A00 - 0x2DFF words)
#define ICACHE_START_OFFSET     (0x2A00 * 8)
#define ICACHE_END_OFFSET       (0x2DFF * 8)
#define ICACHE_START_ADDR       (TPU_BASE_ADDR + ICACHE_START_OFFSET)
#define ICACHE_END_ADDR         (TPU_BASE_ADDR + ICACHE_END_OFFSET)

// STATUS REG Address Range (0x2E00 words)
#define STATUS_START_OFFSET     (0x2E00 * 8)
#define STATUS_REG_EN_ADDR      (TPU_BASE_ADDR + STATUS_START_OFFSET)

#define DMA_ENGINE_BASE_ADDR    0x30000000
#define MAIN_MEM_BASE_ADDR      0x80001000
#define ERROR_FLAG_ADDR         0x8000D100
#define LOG_BASE_ADDR           0x8000D200

// DMA Register Offsets
#define DMA_SRC_ADDR_LO_OFFSET  0x00
#define DMA_SRC_ADDR_HI_OFFSET  0x08
#define DMA_DST_ADDR_LO_OFFSET  0x10
#define DMA_DST_ADDR_HI_OFFSET  0x18
#define DMA_LENGTH_LO_OFFSET    0x20
#define DMA_LENGTH_HI_OFFSET    0x28
#define DMA_CONFIG_OFFSET       0x30
#define DMA_LAUNCH_OFFSET       0x38
#define DMA_STATUS_OFFSET       0x40

// ============================================================================
// Helper Macros
// ============================================================================

#define REG32(base, offset)     (*((volatile uint32_t *)((uintptr_t)(base) + (offset))))
#define REG64(addr)             (*((volatile uint64_t *)(uintptr_t)(addr)))

// ============================================================================
// Function Prototypes
// ============================================================================

void dma_transfer(uint64_t src, uint64_t dst, uint32_t length_bytes);

static inline uint64_t read_cycle() {
    uint64_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

#endif // TPU_UTILS_H
