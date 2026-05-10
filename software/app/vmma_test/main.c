#include <stdio.h>
#include <stdint.h>

#include "vmma.h"

#define FENCE_MEM __asm__ volatile ("fence rw, rw" ::: "memory")

/* Y = W * X; M=2, N=3, int16.
 * Row stride must be 8-byte aligned: 64b AXI DMA uses awsize=64b bursts.
 * Output buffer: see .vmma_dma_out / app.mk --section-start (WT D$ prefetch vs DMA writeback). */
static volatile int16_t W[2][4] __attribute__((aligned(64), section(".l2")));
static volatile int16_t X[3] __attribute__((aligned(64), section(".l2")));
static volatile int16_t Y[2] __attribute__((aligned(64), section(".vmma_dma_out")));

int main(void)
{
    printf("=== VMMA (VecMatMul + DMA) test ===\n");

    W[0][0] = 1;
    W[0][1] = 2;
    W[0][2] = 3;
    W[1][0] = 4;
    W[1][1] = 5;
    W[1][2] = 6;
    X[0] = 1;
    X[1] = 2;
    X[2] = 3;

    vmma_bind(&vmma0);
    vmma0.init(&vmma0, VMMA_REGS);
    vmma0.irq_enable(&vmma0, 0);

    uint32_t m = 2, n = 3;
    uint64_t stride = (uint64_t)sizeof(W[0]);

    vmma0.config(&vmma0, VMMA_DTYPE_INT16, m, n,
                 (uint64_t)(uintptr_t)W,
                 (uint64_t)(uintptr_t)X,
                 (uint64_t)(uintptr_t)Y,
                 stride);

    /* Drain WT D$ store buffer so VMMA DMA sees W/X in DRAM (matches dma drivers). */
    __asm__ volatile ("fence ow, ow" ::: "memory");

    vmma0.start(&vmma0);

    uint64_t timeout = 5000000ULL;
    while (vmma0.busy(&vmma0) && timeout--)
        __asm__ volatile ("nop");

    if (timeout == 0) {
        printf("TIMEOUT status=0x%lx\n", (unsigned long)vmma0.regs->status);
        printf("FAIL\n");
        return 2;
    }

    FENCE_MEM;

    uint64_t st = vmma0.regs->status;
    uint8_t stlo = (uint8_t)(st & 0xffu);
    if ((stlo >> 4) & 0xfu) {
        printf("VMMA error in STATUS bits[7:4]: 0x%x\n", (unsigned)stlo);
        printf("FAIL\n");
        return 3;
    }

    int16_t e0 = (int16_t)(1 * 1 + 2 * 2 + 3 * 3);
    int16_t e1 = (int16_t)(4 * 1 + 5 * 2 + 6 * 3);

    printf("Y[0]=%d (expect %d), Y[1]=%d (expect %d), cycles=%lu status=0x%x\n",
           (int)Y[0], (int)e0, (int)Y[1], (int)e1,
           (unsigned long)vmma0.cycles(&vmma0), (unsigned)stlo);

    if (Y[0] != e0 || Y[1] != e1) {
        printf("FAIL\n");
        return 1;
    }

    printf("PASS\n");
    return 0;
}
