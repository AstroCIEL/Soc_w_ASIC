//////////////////////////////////////////////////////////////////////////////////
// Author:          GitHub Copilot
// Description:     Test MLP First Layer Inference
//////////////////////////////////////////////////////////////////////////////////

#include "stdint.h"

#include "tpu_utils.h"
#include "mlp_const.h"

int main() {
    // 1. Transfer Weight Data
    // Destination: TPU_BASE + 0x00000 (Weight Memory Base)
    dma_transfer((uint64_t)weight_data, TPU_BASE_ADDR + 0x00000, sizeof(weight_data));

    // 2. Transfer Input Data
    // Destination: TPU_BASE + 0x10000 (Input Memory Base: 0x2000 words * 8)
    dma_transfer((uint64_t)input_data, TPU_BASE_ADDR + 0x10000, sizeof(input_data));

    // 3. Transfer Misc Data
    // Destination: TPU_BASE + 0x14000 (Misc Memory Base: 0x2800 words * 8)
    dma_transfer((uint64_t)misc_data, TPU_BASE_ADDR + 0x14000, sizeof(misc_data));

    // 4. Transfer Instruction Data
    // Destination: TPU_BASE + 0x15000 (Instruction Memory Base: 0x2A00 words * 8)
    // Size: 1024 * 8 bytes = 8192 bytes
    dma_transfer((uint64_t)ins_data, TPU_BASE_ADDR + 0x15000, sizeof(ins_data));

    // 4. Launch TPU
    // Write 1 to ADDR_REG_ENABLE (TPU_BASE + 0x17000)
    REG64(STATUS_REG_EN_ADDR) = 0x1;

    // 5. Poll for Finish
    // ADDR_REG_FINISH is STATUS_REG_EN_ADDR + 8
    // Wait until bit 0 is 1
    while ((REG64(STATUS_REG_EN_ADDR + 8) & 0x1) == 0) {
        // Busy wait
    }

    int errors = 0;
    // 6. Verify Output Against Golden Results
    for (int i = 0; i < OUTPUT_ROWS; i++) {
        for (int j = 0; j < OUTPUT_ROW_SIZE; j += 8) {
            // Read 8 bytes at once from TPU (64-bit aligned)
            uint64_t addr = TPU_BASE_ADDR + 0x11000 + (i * OUTPUT_ROW_SIZE) + j;
            uint64_t word = REG64(addr);

            // Verify each of the 8 bytes
            for (int k = 0; k < 8; k++) {
                int8_t output_value = (int8_t)((word >> (k * 8)) & 0xFF);
                int8_t expected_value = golden_result[i * OUTPUT_ROW_SIZE + j + k];
                if (output_value != expected_value) {
                    errors++;
                }
            }
        }
    }

    // 7. Write to a specific RISC-V CPU register s2 to indicate test result
    if (errors == 0) {
        // Write 0xABAB to s2 for success
        asm volatile ("li s2, 0xABAB");
    }
    else {
        // Write 0xDEAD to s2 for failure
        asm volatile ("li s2, 0xDEAD");
    }

    return 0;
}
