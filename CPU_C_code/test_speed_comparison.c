//////////////////////////////////////////////////////////////////////////////////
// Author:          GitHub Copilot
// Description:     TPU Transfer Speed Comparison (CPU vs DMA)
//////////////////////////////////////////////////////////////////////////////////

#include "tpu_utils.h"

// Define transfer sizes to test (in 64-bit words)
#define NUM_SIZES 4
const uint32_t transfer_sizes[NUM_SIZES] = { 16, 64, 256, 1024 };

// Log structure in memory (starting at LOG_BASE_ADDR):
// For each size:
// [0]: Size (words)
// [1]: CPU Write Cycles (Main -> UBUF)
// [2]: CPU Read Cycles (UBUF -> Main)
// [3]: DMA Write Cycles (Main -> UBUF)
// [4]: DMA Read Cycles (UBUF -> Main)

int main() {
    volatile uint64_t* log_ptr = (volatile uint64_t*)(uintptr_t)LOG_BASE_ADDR;
    volatile uint64_t* main_mem = (volatile uint64_t*)(uintptr_t)MAIN_MEM_BASE_ADDR;
    volatile uint64_t* ubuf = (volatile uint64_t*)(uintptr_t)UBUF_START_ADDR;
    volatile uint64_t* error_flag = (volatile uint64_t*)(uintptr_t)ERROR_FLAG_ADDR;

    // Initialize Main Memory with some pattern
    for (int i = 0; i < 1024; i++) {
        main_mem[i] = i;
    }

    // Clear UBUF
    for (int i = 0; i < 1024; i++) {
        ubuf[i] = 0;
    }

    for (int i = 0; i < NUM_SIZES; i++) {
        uint32_t size = transfer_sizes[i];
        uint32_t bytes = size * 8;

        // Log Size
        *log_ptr++ = size;
        *error_flag = 0x1000 + i;

        // 1. CPU Write (Main -> UBUF)
        uint64_t start = read_cycle();
        for (int j = 0; j < size; j++) {
            ubuf[j] = main_mem[j];
        }
        uint64_t end = read_cycle();
        *log_ptr++ = end - start;
        *error_flag = 0x2000 + i;

        // 2. CPU Read (UBUF -> Main)
        // We read back to the same location for simplicity in this speed test
        start = read_cycle();
        for (int j = 0; j < size; j++) {
            main_mem[j] = ubuf[j];
        }
        end = read_cycle();
        *log_ptr++ = end - start;
        *error_flag = 0x3000 + i;

        // 3. DMA Write (Main -> UBUF)
        start = read_cycle();
        dma_transfer(MAIN_MEM_BASE_ADDR, UBUF_START_ADDR, bytes);
        end = read_cycle();
        *log_ptr++ = end - start;
        *error_flag = 0x4000 + i;

        // 4. DMA Read (UBUF -> Main)
        // We use a destination offset to avoid immediate cache hits if that's a concern,
        // but for raw throughput measurement, overwriting is often fine.
        // Let's overwrite the same buffer.
        start = read_cycle();
        dma_transfer(UBUF_START_ADDR, MAIN_MEM_BASE_ADDR, bytes);
        end = read_cycle();
        *log_ptr++ = end - start;
        *error_flag = 0x5000 + i;
    }

    // Signal completion
    *error_flag = 0xABABABABABABABABULL;

    return 0;
}
