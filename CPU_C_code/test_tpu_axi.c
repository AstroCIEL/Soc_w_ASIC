//////////////////////////////////////////////////////////////////////////////////
// Author:          GitHub Copilot
// Description:     TPU Functional Test (C equivalent of tpu_tb.sv)
//////////////////////////////////////////////////////////////////////////////////

#include "tpu_utils.h"

static int error_count = 0;

// ============================================================================
// Test Functions
// ============================================================================

void test_sequential_ub_access() {
    // Write First 16 words
    for (uint64_t addr = UBUF_START_ADDR; addr < UBUF_START_ADDR + (16 * 8); addr += 8) {
        uint64_t wdata = addr + 0xA5A5000000000000ULL;
        REG64(addr) = wdata;
    }

    // Write Last 16 words
    for (uint64_t addr = UBUF_END_ADDR - (15 * 8); addr <= UBUF_END_ADDR; addr += 8) {
        uint64_t wdata = addr + 0x5A5A000000000000ULL;
        REG64(addr) = wdata;
    }

    // Verify First 16 words
    for (uint64_t addr = UBUF_START_ADDR; addr < UBUF_START_ADDR + (16 * 8); addr += 8) {
        uint64_t expected = addr + 0xA5A5000000000000ULL;
        uint64_t rdata = REG64(addr);
        if (rdata != expected) {
            error_count++;
        }
    }

    // Verify Last 16 words
    for (uint64_t addr = UBUF_END_ADDR - (15 * 8); addr <= UBUF_END_ADDR; addr += 8) {
        uint64_t expected = addr + 0x5A5A000000000000ULL;
        uint64_t rdata = REG64(addr);
        if (rdata != expected) {
            error_count++;
        }
    }
}


void test_icache_access() {
    // Write Pattern to ICACHE (First 32 words)
    for (uint64_t addr = ICACHE_START_ADDR; addr < ICACHE_START_ADDR + (32 * 8); addr += 8) {
        // Instructions are 54-bit, mask upper bits
        uint64_t wdata = (addr + 0xBEEF000000000000ULL) & 0x003FFFFFFFFFFFFFULL;
        REG64(addr) = wdata;
    }

    // Verify ICACHE
    for (uint64_t addr = ICACHE_START_ADDR; addr < ICACHE_START_ADDR + (32 * 8); addr += 8) {
        uint64_t expected = (addr + 0xBEEF000000000000ULL) & 0x003FFFFFFFFFFFFFULL;
        uint64_t rdata = REG64(addr);

        if (rdata != expected) {
            error_count++;
        }
    }
}


void test_status_reg_access() {
    uint64_t wdata, rdata;

    // Test Global Enable Register (Bit 0) - Write 1
    wdata = 1;
    REG64(STATUS_REG_EN_ADDR) = wdata;
    rdata = REG64(STATUS_REG_EN_ADDR);

    if ((rdata & 1) != 1) {
        error_count++;
    }

    // Test Global Enable Register (Bit 0) - Write 0
    wdata = 0;
    REG64(STATUS_REG_EN_ADDR) = wdata;
    rdata = REG64(STATUS_REG_EN_ADDR);

    if ((rdata & 1) != 0) {
        error_count++;
    }
}

// ============================================================================
// Main
// ============================================================================

int main() {
    error_count = 0;

    test_sequential_ub_access();

    test_icache_access();

    test_status_reg_access();

    // Report results via Error Flag Address
    volatile uint64_t* error_flag_ptr = (volatile uint64_t*)(uintptr_t)ERROR_FLAG_ADDR;

    if (error_count == 0) {
        // Pass Pattern
        *error_flag_ptr = 0xABABABABABABABABULL;
    }
    else {
        // Fail Pattern
        *error_flag_ptr = 0xBEEFBEEFBEEFBEEFULL;
    }

    return 0;
}