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
    // We must read 64-bit words because byte-level access might not be supported on this AXI bus
    volatile uint64_t* result_base_64 = (volatile uint64_t*)(uintptr_t)(TPU_BASE_ADDR + 0x11000);

    for (int i = 0; i < OUTPUT_ROWS; i++) {
        // Read the entire 512-bit row (8 * 64-bit words)
        // Each row corresponds to one i loop iteration
        for (int w = 0; w < 8; w++) {
            uint64_t word_val = result_base_64[i * 8 + w];

            // Process each byte in the 64-bit word
            for (int b = 0; b < 8; b++) {
                int8_t output_value = (int8_t)((word_val >> (b * 8)) & 0xFF);

                // Calculate the byte address offset of this specific byte
                int byte_offset_in_row = w * 8 + b;

                // Map this hardware byte offset back to the logical index j
                // HW Byte Offset: [0..15]=Ch3, [16..31]=Ch2, [32..47]=Ch1, [48..63]=Ch0
                int chunk_idx = 3 - (byte_offset_in_row / 16); // 3->0, 2->1, 1->2, 0->3
                int byte_in_chunk = byte_offset_in_row % 16;
                int logical_j = chunk_idx * 16 + byte_in_chunk;

                int8_t expected_value = golden_result[i * OUTPUT_ROW_SIZE + logical_j];

                // Write the expected value to s3 for debugging
                asm volatile ("mv s3, %0" :: "r"(expected_value));
                // Write the output value to s4 for debugging
                asm volatile ("mv s4, %0" :: "r"(output_value));

                // Check with tolerance +/- 1
                if (output_value != expected_value &&
                    output_value != (expected_value + 1) &&
                    output_value != (expected_value - 1)) {
                    errors++;
                    // Write error count to s2 immediately for debugging
                    asm volatile ("mv s2, %0" :: "r"(errors));
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
