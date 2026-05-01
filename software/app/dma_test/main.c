/*
 * Demo: exercise the iDMA reg64_1d wrapper via polling.
 *
 * 1. Allocate src / dst buffers in .l2.
 * 2. Fill src with a deterministic pattern; zero dst.
 * 3. Submit a 1-D memcpy via dma_reg64_1d_0.submit().
 * 4. Poll dma_reg64_1d_0.done_id() until the returned id is met.
 * 5. Verify dst against src byte-for-byte.
 */

#include <stdio.h>
#include <stdint.h>
#include <string.h>

#include "soc.h"
#include "dma_reg64_1d.h"

#define XFER_LEN        1024u

static uint8_t src_buf[XFER_LEN] __attribute__((aligned(64), section(".l2")));
static uint8_t dst_buf[XFER_LEN] __attribute__((aligned(64), section(".l2")));

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
    printf("=== iDMA reg64_1d memcpy demo (polling) ===\n");
    printf("src = %p  dst = %p  len = %u\n",
           (void *)src_buf, (void *)dst_buf, XFER_LEN);

    /* -------------------------------------------------- */
    /* Polling path                                       */
    /* -------------------------------------------------- */
    fill_pattern(src_buf, XFER_LEN);
    memset(dst_buf, 0, XFER_LEN);

    uint32_t id = dma_reg64_1d_0.submit(&dma_reg64_1d_0,
                                        (uint64_t)(uintptr_t)dst_buf,
                                        (uint64_t)(uintptr_t)src_buf,
                                        XFER_LEN);
    printf("submitted id=%u\n", id);

    dma_reg64_1d_0.wait(&dma_reg64_1d_0, id);
    printf("done_id=%u busy=%d\n",
           dma_reg64_1d_0.done_id(&dma_reg64_1d_0),
           dma_reg64_1d_0.busy(&dma_reg64_1d_0));

    if (verify(src_buf, dst_buf, XFER_LEN) != 0) {
        printf("FAIL\n");
        return 1;
    }
    printf("PASS\n");
    return 0;
}
