#include <stdint.h>
#include <stdio.h>

#include "dma_desc64.h"
#include "encoding.h"
#include "global_buffer.h"
#include "my_mxu.h"
#include "plic.h"

#define FENCE_MEM __asm__ volatile ("fence rw, rw" ::: "memory")
#define FENCE_OW  __asm__ volatile ("fence ow, ow" ::: "memory")

/* minimum_my_mxu_axu: ariane_peripherals.sv connects DMA irq_o to irq_sources[7]. */
#define IRQn_IDMA_DESC64 8u

#define TEST_WORDS 16u
#define TEST_BYTES (TEST_WORDS * sizeof(uint64_t))
#define GBUF_RETURN_WORD_OFFSET 64u

static struct dma_desc64_descriptor g_dma_desc __attribute__((aligned(16), section(".l2")));
static volatile int g_dma_irq_done;

static volatile uint64_t *gbuf_word(unsigned word_idx)
{
    return (volatile uint64_t *)global_buffer_word_addr(word_idx);
}

static volatile uint64_t *mxu_wgt_word(unsigned word_idx)
{
    return (volatile uint64_t *)((uintptr_t)MY_MXU_WGTBUF_BASE + word_idx * sizeof(uint64_t));
}

static uint64_t pattern_word(unsigned idx)
{
    return 0x5A5A000000000000ull
         | ((uint64_t)idx << 32)
         | (uint64_t)(idx * 0x1021u + 0x33u);
}

static void dma_isr(irqn_t irq, void *arg)
{
    (void)irq;
    (void)arg;
    g_dma_irq_done = 1;
}

static void wait_for_dma_irq(void)
{
    uintptr_t done_addr = (uintptr_t)&g_dma_irq_done;
    asm volatile(
        "1:\n\t"
        "wfi\n\t"
        "lw   t0, 0(%0)\n\t"
        "beqz t0, 1b"
        :
        : "r"(done_addr)
        : "t0", "memory");
}

static void enable_dma_irq(void)
{
    plic0.set_threshold(&plic0, PLIC_CTX_M0, 0);
    plic0.register_handler(&plic0, IRQn_IDMA_DESC64, dma_isr, NULL);
    plic0.set_priority(&plic0, IRQn_IDMA_DESC64, 1);
    plic0.enable(&plic0, PLIC_CTX_M0, IRQn_IDMA_DESC64);

    asm volatile("csrs mie,     %0" :: "r"(MIP_MEIP));
    asm volatile("csrs mstatus, %0" :: "r"(MSTATUS_MIE));
}

static void fill_global_buffer_source(void)
{
    for (unsigned i = 0; i < TEST_WORDS; i++) {
        *gbuf_word(i) = pattern_word(i);
    }
    FENCE_OW;
}

static void poison_mxu_wgt_buffer(void)
{
    for (unsigned i = 0; i < TEST_WORDS; i++) {
        *mxu_wgt_word(i) = 0xDEADBEEF00000000ull | (uint64_t)i;
    }
    FENCE_OW;
}

static void poison_global_buffer_return_area(void)
{
    for (unsigned i = 0; i < TEST_WORDS; i++) {
        *gbuf_word(GBUF_RETURN_WORD_OFFSET + i) = 0xBAD0000000000000ull | (uint64_t)i;
    }
    FENCE_OW;
}

static int verify_mxu_wgt_buffer(void)
{
    FENCE_MEM;
    for (unsigned i = 0; i < TEST_WORDS; i++) {
        uint64_t got = *mxu_wgt_word(i);
        uint64_t exp = pattern_word(i);
        if (got != exp) {
            printf("WGT_MISMATCH word=%u got=0x%016lx exp=0x%016lx\n",
                   i, (unsigned long)got, (unsigned long)exp);
            return -1;
        }
    }
    return 0;
}

static int verify_global_buffer_return_area(void)
{
    FENCE_MEM;
    for (unsigned i = 0; i < TEST_WORDS; i++) {
        uint64_t got = *gbuf_word(GBUF_RETURN_WORD_OFFSET + i);
        uint64_t exp = pattern_word(i);
        if (got != exp) {
            printf("GBUF_RETURN_MISMATCH word=%u got=0x%016lx exp=0x%016lx\n",
                   i, (unsigned long)got, (unsigned long)exp);
            return -1;
        }
    }
    return 0;
}

static void idma_memcpy(uint64_t src_addr, uint64_t dst_addr, uint32_t nbytes)
{
    g_dma_irq_done = 0;

    g_dma_desc.flags_and_length = dma_desc64_pack(
        nbytes,
        DMA_DESC64_FLAG_SRC_INCR | DMA_DESC64_FLAG_DST_INCR | DMA_DESC64_FLAG_IRQ);
    g_dma_desc.next     = DMA_DESC64_END_OF_CHAIN;
    g_dma_desc.src_addr = src_addr;
    g_dma_desc.dst_addr = dst_addr;

    FENCE_OW;
    dma_desc64_0.submit(&dma_desc64_0, &g_dma_desc);
    wait_for_dma_irq();
    FENCE_MEM;
}

int main(void)
{
    printf("MXU_IDMA_GBUF_TEST_BEGIN\n");
    printf("gbuf=0x%lx wgt=0x%lx bytes=%u\n",
           (unsigned long)GLOBAL_BUFFER_BASE,
           (unsigned long)MY_MXU_WGTBUF_BASE,
           (unsigned)TEST_BYTES);

    my_mxu_bind(&my_mxu0);
    my_mxu0.init(&my_mxu0,
                 MY_MXU_REGS,
                 (volatile uint8_t *)MY_MXU_WGTBUF_BASE,
                 (volatile uint8_t *)MY_MXU_ACTBUF_BASE,
                 (volatile uint8_t *)MY_MXU_OUTBUF_BASE);
    my_mxu0.mxu_set_wgt_ports(&my_mxu0, 0, 0);
    FENCE_MEM;

    enable_dma_irq();

    fill_global_buffer_source();
    poison_mxu_wgt_buffer();
    poison_global_buffer_return_area();

    idma_memcpy((uint64_t)(uintptr_t)gbuf_word(0),
                (uint64_t)(uintptr_t)mxu_wgt_word(0),
                (uint32_t)TEST_BYTES);

    if (verify_mxu_wgt_buffer() != 0) {
        printf("MXU_IDMA_GBUF_FAIL\n");
        printf("MXU_IDMA_GBUF_TEST_END\n");
        return 1;
    }

    idma_memcpy((uint64_t)(uintptr_t)mxu_wgt_word(0),
                (uint64_t)(uintptr_t)gbuf_word(GBUF_RETURN_WORD_OFFSET),
                (uint32_t)TEST_BYTES);

    if (verify_global_buffer_return_area() != 0) {
        printf("MXU_IDMA_GBUF_FAIL\n");
        printf("MXU_IDMA_GBUF_TEST_END\n");
        return 2;
    }

    printf("MXU_IDMA_GBUF_PASS\n");
    printf("MXU_IDMA_GBUF_TEST_END\n");
    return 0;
}
