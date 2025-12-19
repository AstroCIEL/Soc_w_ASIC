#include "tpu_utils.h"

void dma_transfer(uint64_t src, uint64_t dst, uint32_t length_bytes) {
    // 1. Configure Source Address
    REG32(DMA_ENGINE_BASE_ADDR, DMA_SRC_ADDR_LO_OFFSET) = (uint32_t)(src & 0xFFFFFFFF);
    REG32(DMA_ENGINE_BASE_ADDR, DMA_SRC_ADDR_HI_OFFSET) = (uint32_t)(src >> 32);

    // 2. Configure Destination Address
    REG32(DMA_ENGINE_BASE_ADDR, DMA_DST_ADDR_LO_OFFSET) = (uint32_t)(dst & 0xFFFFFFFF);
    REG32(DMA_ENGINE_BASE_ADDR, DMA_DST_ADDR_HI_OFFSET) = (uint32_t)(dst >> 32);

    // 3. Configure Transfer Length
    REG32(DMA_ENGINE_BASE_ADDR, DMA_LENGTH_LO_OFFSET) = length_bytes;
    REG32(DMA_ENGINE_BASE_ADDR, DMA_LENGTH_HI_OFFSET) = 0;

    // 4. Configure DMA Options (Assuming 0x3 is standard config)
    REG32(DMA_ENGINE_BASE_ADDR, DMA_CONFIG_OFFSET) = 0x3;

    // 5. Launch Transfer
    REG32(DMA_ENGINE_BASE_ADDR, DMA_LAUNCH_OFFSET) = 1;

    // 6. Poll for Completion
    while (REG32(DMA_ENGINE_BASE_ADDR, DMA_STATUS_OFFSET) & 0x1) {
        // Wait while busy
    }
}
