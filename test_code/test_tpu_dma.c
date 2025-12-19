//////////////////////////////////////////////////////////////////////////////////
// Author:          GitHub Copilot
// Description:     TPU DMA Read/Write Test
//////////////////////////////////////////////////////////////////////////////////

#include "tpu_utils.h"

#define TEST_SIZE               128

int ubuf_error_count = 0;
int icache_error_count = 0;

void test_dma_write_ubuf() {
    // Pattern to write
    uint64_t pattern[TEST_SIZE];
    for (int i = 0; i < TEST_SIZE; i++) {
        pattern[i] = 0x1122334455667788ULL + i;
    }

    // Write pattern to Main Memory
    uint64_t* mem_base = (uint64_t*)MAIN_MEM_BASE_ADDR;
    for (int i = 0; i < TEST_SIZE; i++) {
        mem_base[i] = pattern[i];
    }

    // DMA Transfer: Main Memory -> TPU UBUF
    dma_transfer(MAIN_MEM_BASE_ADDR, UBUF_START_ADDR, TEST_SIZE * 8);

    // Verify TPU UBUF content using CPU read
    volatile uint64_t* ubuf_base = (volatile uint64_t*)(uintptr_t)UBUF_START_ADDR;
    for (int i = 0; i < TEST_SIZE; i++) {
        uint64_t val = ubuf_base[i];
        if (val != pattern[i]) {
            ubuf_error_count++;
        }
    }
}

void test_dma_read_ubuf() {
    // Pattern to write to TPU
    uint64_t pattern[TEST_SIZE];
    for (int i = 0; i < TEST_SIZE; i++) {
        pattern[i] = 0xAABBCCDDEEFF0011ULL + i;
    }

    // Write pattern to TPU UBUF using CPU
    volatile uint64_t* ubuf_base = (volatile uint64_t*)(uintptr_t)UBUF_START_ADDR;
    for (int i = 0; i < TEST_SIZE; i++) {
        ubuf_base[i] = pattern[i];
    }

    // Clear Main Memory destination area (offset by 2048 bytes to avoid overlap with source)
    uint64_t dst_mem_addr = MAIN_MEM_BASE_ADDR + 2048;
    uint64_t* mem_dst = (uint64_t*)dst_mem_addr;
    for (int i = 0; i < TEST_SIZE; i++) {
        mem_dst[i] = 0;
    }

    // DMA Transfer: TPU UBUF -> Main Memory
    dma_transfer(UBUF_START_ADDR, dst_mem_addr, TEST_SIZE * 8);

    // Verify Main Memory content
    for (int i = 0; i < TEST_SIZE; i++) {
        if (mem_dst[i] != pattern[i]) {
            ubuf_error_count++;
        }
    }
}

void test_dma_write_icache() {
    // Pattern to write
    uint64_t pattern[TEST_SIZE];
    for (int i = 0; i < TEST_SIZE; i++) {
        // Instructions are 54-bit, mask upper bits
        pattern[i] = (0xDEADBEEF00000000ULL + i) & 0x003FFFFFFFFFFFFFULL;
    }

    // Write pattern to Main Memory
    uint64_t* mem_base = (uint64_t*)MAIN_MEM_BASE_ADDR;
    for (int i = 0; i < TEST_SIZE; i++) {
        mem_base[i] = pattern[i];
    }

    // DMA Transfer: Main Memory -> TPU ICACHE
    dma_transfer(MAIN_MEM_BASE_ADDR, ICACHE_START_ADDR, TEST_SIZE * 8);

    // Verify TPU ICACHE content using CPU read
    volatile uint64_t* icache_base = (volatile uint64_t*)(uintptr_t)ICACHE_START_ADDR;
    for (int i = 0; i < TEST_SIZE; i++) {
        uint64_t val = icache_base[i];
        // Mask upper bits as ICACHE is 54-bit
        if ((val & 0x003FFFFFFFFFFFFFULL) != pattern[i]) {
            icache_error_count++;
        }
    }
}

void test_dma_read_icache() {
    // Pattern to write to TPU
    uint64_t pattern[TEST_SIZE];
    for (int i = 0; i < TEST_SIZE; i++) {
        pattern[i] = (0xCAFEBABE00000000ULL + i) & 0x003FFFFFFFFFFFFFULL;
    }

    // Write pattern to TPU ICACHE using CPU
    volatile uint64_t* icache_base = (volatile uint64_t*)(uintptr_t)ICACHE_START_ADDR;
    for (int i = 0; i < TEST_SIZE; i++) {
        icache_base[i] = pattern[i];
    }

    // Clear Main Memory destination area (offset by 4096 bytes)
    uint64_t dst_mem_addr = MAIN_MEM_BASE_ADDR + 4096;
    uint64_t* mem_dst = (uint64_t*)dst_mem_addr;
    for (int i = 0; i < TEST_SIZE; i++) {
        mem_dst[i] = 0;
    }

    // DMA Transfer: TPU ICACHE -> Main Memory
    dma_transfer(ICACHE_START_ADDR, dst_mem_addr, TEST_SIZE * 8);

    // Verify Main Memory content
    for (int i = 0; i < TEST_SIZE; i++) {
        // Mask upper bits as ICACHE is 54-bit and DMA might transfer garbage in upper bits
        if ((mem_dst[i] & 0x003FFFFFFFFFFFFFULL) != pattern[i]) {
            icache_error_count++;
        }
    }
}

int main() {
    ubuf_error_count = 0;
    icache_error_count = 0;

    test_dma_write_ubuf();
    test_dma_read_ubuf();
    test_dma_write_icache();
    test_dma_read_icache();

    volatile uint64_t* error_flag_ptr = (volatile uint64_t*)(uintptr_t)ERROR_FLAG_ADDR;
    if (ubuf_error_count == 0 && icache_error_count == 0) {
        *error_flag_ptr = 0xABABABABABABABABULL;
    }
    else {
        // High 32 bits: ICACHE error count
        // Low 32 bits: UBUF error count
        *error_flag_ptr = ((uint64_t)icache_error_count << 32) | (uint32_t)ubuf_error_count;
    }

    return 0;
}
