//////////////////////////////////////////////////////////////////////////////////
// Author:          Zhantong Zhu
// Acknowledgement: GitHub Copilot
// Description:     DMA Engine Function Test
//////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>

// 测试数据模式
static const uint64_t test_patterns[] = {
    0xb6acad2abb260109,
    0x11752c63ab69c863,
    0x1234567890abcdef,
    0xfedcba0987654321,
    0x1122334455667788,
    0x99aabbccddeeff00,
    0x0011223344556677,
    0x8899aabbccddeeff,
    0xdeadbeefdeadbeef,
    0xfeedfacefeedface,
    0xaaaaaaaaaaaaaaaa,
    0x5555555555555555,
    0x0000000000000000,
    0xffffffffffffffff,
    0x0123456789abcdef,
    0xfedcba9876543210
};

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

// Base Addresses
#define DMA_ENGINE_BASE_ADDR    0x30000000
#define MAIN_MEM_BASE_ADDR      0x80001000
#define TPU_BASE_ADDR           0x40000000

// Transfer Size
#define TEST_SIZE               32 // 32 elements
#define ELEM_SIZE               8  // 64-bit (8 bytes)
#define PATTERN_COUNT         (sizeof(test_patterns) / sizeof(test_patterns[0]))
#define TRANSFER_BYTES          (TEST_SIZE * ELEM_SIZE)

// Helper macros for register access
#define REG32(base, offset)     (*((volatile uint32_t *)((base) + (offset))))

// static const int transfer_sizes[] = { 32, 64, 128, 256, 512, 1024, 2048 };
static const int transfer_sizes[] = { 32, 64, 128 };
#define NUM_TRANSFER_SIZES (sizeof(transfer_sizes) / sizeof(transfer_sizes[0]))
#define LOG_BASE_ADDR 0x8000D100  // Base address for logging cycles
#define ERROR_FLAG_BASE_ADDR 0x8000E000


void test_axi_write() {
    // Use CPU to write data from main memory to TPU memory (Reference check)
    uint64_t* mem_base = (uint64_t*)MAIN_MEM_BASE_ADDR;
    uint64_t* tpu_mem_base = (uint64_t*)TPU_BASE_ADDR;
    for (int i = 0; i < TEST_SIZE; i++) {
        uint64_t data = *(mem_base + i);
        *(tpu_mem_base + i) = data;
    }
}

void test_dma_transfer(int test_size) {
    int transfer_bytes = test_size * ELEM_SIZE;

    // 1. Configure Source Address (Main Memory)
    REG32(DMA_ENGINE_BASE_ADDR, DMA_SRC_ADDR_LO_OFFSET) = (uint32_t)(MAIN_MEM_BASE_ADDR & 0xFFFFFFFF);
    REG32(DMA_ENGINE_BASE_ADDR, DMA_SRC_ADDR_HI_OFFSET) = (uint32_t)((uint64_t)MAIN_MEM_BASE_ADDR >> 32);

    // 2. Configure Destination Address (TPU Memory)
    REG32(DMA_ENGINE_BASE_ADDR, DMA_DST_ADDR_LO_OFFSET) = (uint32_t)(TPU_BASE_ADDR & 0xFFFFFFFF);
    REG32(DMA_ENGINE_BASE_ADDR, DMA_DST_ADDR_HI_OFFSET) = (uint32_t)((uint64_t)TPU_BASE_ADDR >> 32);

    // 3. Configure Transfer Length (in bytes)
    REG32(DMA_ENGINE_BASE_ADDR, DMA_LENGTH_LO_OFFSET) = transfer_bytes;
    REG32(DMA_ENGINE_BASE_ADDR, DMA_LENGTH_HI_OFFSET) = 0;

    // 4. Configure DMA Options
    REG32(DMA_ENGINE_BASE_ADDR, DMA_CONFIG_OFFSET) = 0x3;

    // 5. Launch Transfer
    REG32(DMA_ENGINE_BASE_ADDR, DMA_LAUNCH_OFFSET) = 1;

    // 6. Poll for Completion
    while (REG32(DMA_ENGINE_BASE_ADDR, DMA_STATUS_OFFSET) & 0x1) {
        // Wait while busy
    }
}

// Helper to read RISC-V cycle counter
static inline uint64_t read_cycle() {
    uint64_t cycle;
    asm volatile ("rdcycle %0" : "=r"(cycle));
    return cycle;
}

int main() {
    for (int t = 0; t < NUM_TRANSFER_SIZES; t++) {
        int test_size = transfer_sizes[t];

        // Fill source memory
        uint64_t* mem_base = (uint64_t*)MAIN_MEM_BASE_ADDR;
        for (int i = 0; i < test_size; i++) {
            mem_base[i] = test_patterns[i % PATTERN_COUNT];
        }

        // Clear destination memory
        uint64_t* tpu_mem_base = (uint64_t*)TPU_BASE_ADDR;
        for (int i = 0; i < test_size; i++) {
            tpu_mem_base[i] = 0;
        }

        // Read start cycle
        uint64_t start_cycle = read_cycle();

        test_dma_transfer(test_size);

        // Read end cycle
        uint64_t end_cycle = read_cycle();

        // Store to log addresses using base + offset
        uint64_t* log_base = (uint64_t*)LOG_BASE_ADDR;
        uint64_t* log_start = log_base + t * 2;
        uint64_t* log_end = log_base + t * 2 + 1;
        *log_start = start_cycle;
        *log_end = end_cycle;

        // Optionally verify transfer
        int error = 0;
        for (int i = 0; i < test_size; i++) {
            if (tpu_mem_base[i] != mem_base[i]) {
                error = 1;
                break;
            }
        }

        // Set error flag if verification failed
        uint64_t* error_flag_base = (uint64_t*)ERROR_FLAG_BASE_ADDR;
        uint64_t* error_flag = error_flag_base + t;
        if (error) {
            *error_flag = 0xFFFFFFFFFFFFFFFF;
        }
        else {
            *error_flag = 0xABABABABABABABAB;
        }
    }
    return 0;
}