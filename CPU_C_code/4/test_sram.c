//////////////////////////////////////////////////////////////////////////////////
// Description:     Simple SRAM Read/Write test for CVA6 SoC
//////////////////////////////////////////////////////////////////////////////////

#include <stdint.h>
#include <stddef.h>

// ------------------------------
// 地址映射（来自 cva6-eda/soc_pkg.sv）
// ------------------------------

// soc_pkg::SRAMBase = 0x8000_0000
#define MAIN_MEM_ADDR    0x80000000UL

// 测试数据区：放在sram_1024_64_lx的地址空间
#define TEST_DATA_BASE    0xC0000000UL
#define TEST_WORD_NUM     256UL   // 256 * 8B = 2KB

// 日志与标志位
#define LOG_BASE_ADDR     (MAIN_MEM_ADDR + 0x0C00UL)  // 测试数据区之后
#define ERROR_FLAG_ADDR   (MAIN_MEM_ADDR + 0x1000UL)

int main(void)
{
    // 测试数据写/读到 TEST_DATA_BASE
    volatile uint64_t* const sram =
        (volatile uint64_t* const)(uintptr_t)TEST_DATA_BASE;
    volatile uint64_t* const log_ptr = 
        (volatile uint64_t* const)(uintptr_t)LOG_BASE_ADDR;
    volatile uint64_t* const error_flag =
        (volatile uint64_t* const)(uintptr_t)ERROR_FLAG_ADDR;

    // 先清掉 error_flag
    *error_flag = 0ULL;

    // 1) 写入测试数据
    for (uint64_t i = 0; i < TEST_WORD_NUM; ++i) {
        // 构造一个容易识别的图案：高 32bit = index，低 32bit = 固定常数
        uint64_t pattern = (i << 32) | 0xA5A5A5A5UL;
        sram[i] = pattern;
    } 

    // 2) 读回校验
    uint64_t error_count = 0;
    for (uint64_t i = 0; i < TEST_WORD_NUM; ++i) {
        uint64_t expected = (i << 32) | 0xA5A5A5A5UL;
        uint64_t readback = sram[i];

        if (readback != expected) {
            // 只记录前几个错误
            if (error_count < 4) {
                log_ptr[error_count * 3 + 0] = i;         // 出错 index
                log_ptr[error_count * 3 + 1] = expected;  // 期望值
                log_ptr[error_count * 3 + 2] = readback;  // 读回值
            }
            error_count++;
        }
    }

    if (error_count == 0) {
        // PASS：约定一个固定值
        *error_flag = 0x1234567812345678ULL;
    } else {
        // FAIL：记录错误个数 + 特殊标记
        log_ptr[32] = error_count; // 额外记一下一共多少错
        *error_flag = 0xDEADBEEFDEADBEEFULL;
    }


    return 0;
}