/*
 * Demo: exercise the iDMA desc64 frontend via interrupt.
 *
 * 1. Allocate src / dst buffers and a descriptor in .l2.
 * 2. Fill src with a deterministic pattern; zero dst.
 * 3. Build a descriptor with IRQ flag set.
 * 4. Register PLIC handler for IRQn_DMA, enable interrupts.
 * 5. Submit the descriptor via dma_desc64_0.submit().
 * 6. WFI until ISR signals completion.
 * 7. Verify dst against src.
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "soc.h"
#include "dma_desc64.h"
#include "plic.h"
#include "encoding.h"

#define XFER_LEN        1024u

static uint8_t src_buf[XFER_LEN] __attribute__((aligned(64), section(".l2")));
static uint8_t dst_buf[XFER_LEN] __attribute__((aligned(64), section(".l2")));

/* Descriptor must be 16-byte aligned */
static struct dma_desc64_descriptor desc __attribute__((aligned(16), section(".l2")));

static volatile int dma_irq_done = 0;

static void dma_isr(irqn_t irq, void *arg)
{
    (void)irq;
    (void)arg;
    dma_irq_done = 1;
}

static void fill_pattern(uint8_t *buf, unsigned len)
{
    for (unsigned i = 0; i < len; ++i)
        buf[i] = (uint8_t)(i * 7u + 0x13u);
}

static int verify(const uint8_t *a, const uint8_t *b, unsigned len)
{
    for (unsigned i = 0; i < len; ++i) {
        if (a[i] != b[i]) {
            printf("MISMATCH @ %u: got 0x%02x, exp 0x%02x\n",
                   i, b[i], a[i]);
            return -1;
        }
    }
    return 0;
}

int main(void)
{
    printf("=== iDMA desc64 memcpy demo (IRQ) ===\n");
    printf("src = %p  dst = %p  len = %u\n",
           (void *)src_buf, (void *)dst_buf, XFER_LEN);

    /* Setup PLIC for DMA interrupt */
    plic0.register_handler(&plic0, IRQn_DMA, dma_isr, NULL);
    plic0.set_priority    (&plic0, IRQn_DMA, 1);
    plic0.set_threshold   (&plic0, PLIC_CTX_M0, 0);
    plic0.enable          (&plic0, PLIC_CTX_M0, IRQn_DMA);

    /* Enable machine external interrupts */
    asm volatile("csrs mie,     %0" :: "r"(MIP_MEIP));
    asm volatile("csrs mstatus, %0" :: "r"(MSTATUS_MIE));

    /* Fill source, zero destination */
    fill_pattern(src_buf, XFER_LEN);
    memset(dst_buf, 0, XFER_LEN);

    /* Build descriptor: INCR burst, IRQ on completion */
    desc.flags_and_length = dma_desc64_pack(
        XFER_LEN,
        DMA_DESC64_FLAG_SRC_INCR | DMA_DESC64_FLAG_DST_INCR | DMA_DESC64_FLAG_IRQ
    );
    desc.next     = DMA_DESC64_END_OF_CHAIN;
    desc.src_addr = (uint64_t)(uintptr_t)src_buf;
    desc.dst_addr = (uint64_t)(uintptr_t)dst_buf;

    /* Submit descriptor */
    dma_desc64_0.submit(&dma_desc64_0, &desc);
    printf("submitted descriptor, waiting for IRQ...\n");

    /* Wait for interrupt */
    while (!dma_irq_done)
        asm volatile ("wfi");

    printf("IRQ received, busy=%d\n", dma_desc64_0.busy(&dma_desc64_0));

    if (verify(src_buf, dst_buf, XFER_LEN) != 0) {
        printf("FAIL\n");
        return 1;
    }
    printf("PASS\n");
    return 0;
}
