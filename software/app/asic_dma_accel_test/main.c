#include <stdio.h>
#include <stdint.h>

#include "asic_dma_accel.h"
static volatile uint64_t src_buf __attribute__((aligned(64), section(".l2")));
static volatile uint64_t dst_buf __attribute__((aligned(64), section(".l2")));

int main(void)
{
    src_buf = 0x1234567890ABCDEFULL;
    dst_buf = 0ULL;

    printf("=== ASIC DMA accelerator test ===\n");

    asic_dma_bind(&asic_dma0);
    asic_dma0.init(&asic_dma0, ASIC_DMA_REGS);
    asic_dma0.irq_enable(&asic_dma0, 0);

    asic_dma0.config(&asic_dma0,
                     (uint64_t)(uintptr_t)&src_buf,
                     (uint64_t)(uintptr_t)&dst_buf,
                     8);
    printf("cfg src=0x%016lx dst=0x%016lx len=%lu\n",
           asic_dma0.regs->src_addr, asic_dma0.regs->dst_addr, asic_dma0.regs->length);
    asic_dma0.start(&asic_dma0);
    printf("status after start=0x%lx\n", asic_dma0.regs->status);

    uint64_t timeout = 1000000;
    while (asic_dma0.busy(&asic_dma0) && timeout--) {
        __asm__ volatile ("nop");
    }
    if (timeout == 0) {
        printf("timeout status=0x%lx\n", asic_dma0.regs->status);
        printf("src=0x%016lx dst=0x%016lx\n", src_buf, dst_buf);
        printf("FAIL\n");
        return 2;
    }

    printf("src=0x%016lx dst=0x%016lx result=0x%016lx cycles=%lu\n",
           src_buf, dst_buf, asic_dma0.regs->result, asic_dma0.cycle_cnt(&asic_dma0));

    if (asic_dma0.regs->result != (src_buf + 1)) {
        printf("FAIL\n");
        return 1;
    }

    printf("PASS\n");
    return 0;
}
