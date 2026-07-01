#include <stdint.h>
#include <stdio.h>

#include "dcim.h"
#include "input_data.h"

#ifndef DCIM_TEST_TOPO
#define DCIM_TEST_TOPO DCIM_TOPO_1CH
#endif

#ifndef DCIM_POST_START_CYCLES
#ifdef DCIM_WAIT_CYCLES
#define DCIM_POST_START_CYCLES DCIM_WAIT_CYCLES
#else
#define DCIM_POST_START_CYCLES 100ULL
#endif
#endif

#ifndef DCIM_POST_LOAD_CYCLES
#define DCIM_POST_LOAD_CYCLES 32ULL
#endif

#ifndef DCIM_VERIFY_RW
#define DCIM_VERIFY_RW 1
#endif

#if !defined(DCIM_GOLDEN_CFG_TOPO) || !defined(DCIM_GOLDEN_CFG_MODE) || \
    !defined(DCIM_GOLDEN_CFG_ACC) || !defined(DCIM_GOLDEN_CFG_ACT_LEN) || \
    !defined(DCIM_GOLDEN_CFG_OUT_LEN) || !defined(DCIM_GOLDEN_CFG_LOOP)
#error "input_data.h missing DCIM_GOLDEN_CFG_* macros"
#endif

#if (DCIM_GOLDEN_CFG_TOPO != DCIM_TEST_TOPO)
#error "Golden topo mismatch with dcim_test configure()"
#endif
#if (DCIM_GOLDEN_CFG_ACC != DCIM_GOLDEN_ACC)
#error "Golden acc mismatch with dcim_test configure()"
#endif
#if (DCIM_GOLDEN_CFG_ACT_LEN != DCIM_ACT_ROWS)
#error "Golden act_len mismatch with dcim_test configure()"
#endif
#if (DCIM_GOLDEN_CFG_OUT_LEN != DCIM_OUT_ROWS)
#error "Golden out_len mismatch with dcim_test configure()"
#endif
#if (DCIM_GOLDEN_CFG_LOOP != 0u)
#error "Golden loop mismatch with dcim_test configure()"
#endif

static int write_input_buffers(struct dcim_drv *d)
{
    for (uint32_t i = 0; i < DCIM_WEI_WORD_COUNT; ++i) {
        d->write_wei64(d, 0, i, DCIM_WEI_WORDS[i]);
    }
    for (uint32_t i = 0; i < DCIM_ACT_WORD_COUNT; ++i) {
        d->write_act64(d, 0, i, DCIM_ACT_WORDS[i]);
    }
    DCIM_FENCE_OW;
    return 0;
}

static int verify_input_buffers(struct dcim_drv *d)
{
    for (uint32_t i = 0; i < DCIM_WEI_WORD_COUNT; ++i) {
        uint64_t got = d->read_wei64(d, 0, i);
        uint64_t exp = DCIM_WEI_WORDS[i];
        if (got != exp) {
            printf("DCIM_IN_MISMATCH WEI idx=%u got=0x%08x%08x exp=0x%08x%08x\n",
                   i,
                   (unsigned int)(got >> 32),
                   (unsigned int)(got & 0xFFFFFFFFu),
                   (unsigned int)(exp >> 32),
                   (unsigned int)(exp & 0xFFFFFFFFu));
            return -1;
        }
    }
    for (uint32_t i = 0; i < DCIM_ACT_WORD_COUNT; ++i) {
        uint64_t got = d->read_act64(d, 0, i);
        uint64_t exp = DCIM_ACT_WORDS[i];
        if (got != exp) {
            printf("DCIM_IN_MISMATCH ACT idx=%u got=0x%08x%08x exp=0x%08x%08x\n",
                   i,
                   (unsigned int)(got >> 32),
                   (unsigned int)(got & 0xFFFFFFFFu),
                   (unsigned int)(exp >> 32),
                   (unsigned int)(exp & 0xFFFFFFFFu));
            return -1;
        }
    }
    return 0;
}

static int compare_output_buffers(struct dcim_drv *d)
{
    uint32_t mismatch = 0;
    for (uint32_t i = 0; i < DCIM_OUT_WORD_COUNT; ++i) {
        uint64_t got = d->read_out64(d, 0, i);
        uint64_t exp = DCIM_OUT_GOLDEN_WORDS[i];
        if (got != exp) {
            ++mismatch;
            printf("DCIM_MISMATCH idx=%u got=0x%08x%08x exp=0x%08x%08x\n",
                   i,
                   (unsigned int)(got >> 32),
                   (unsigned int)(got & 0xFFFFFFFFu),
                   (unsigned int)(exp >> 32),
                   (unsigned int)(exp & 0xFFFFFFFFu));
        }
    }
    return (mismatch == 0) ? 0 : -1;
}

int main(void)
{
    int rc;

    /* Runtime hard check: keep generator and configure params locked together. */
    if (DCIM_GOLDEN_CFG_TOPO != DCIM_TEST_TOPO ||
        DCIM_GOLDEN_CFG_ACC != DCIM_GOLDEN_ACC ||
        DCIM_GOLDEN_CFG_ACT_LEN != DCIM_ACT_ROWS ||
        DCIM_GOLDEN_CFG_OUT_LEN != DCIM_OUT_ROWS ||
        DCIM_GOLDEN_CFG_LOOP != 0u) {
        printf("DCIM_FAIL\n");
        return 1;
    }

    dcim_bind(&dcim0);
    dcim0.init(&dcim0,
               DCIM_CFG_REGS,
               (volatile uint8_t *)(uintptr_t)DCIM_ACT_BASE,
               (volatile uint8_t *)(uintptr_t)DCIM_OUT_BASE,
               (volatile uint8_t *)(uintptr_t)DCIM_WEI_BASE);

    dcim0.set_buffer_owner(&dcim0, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);
    rc = write_input_buffers(&dcim0);
    if (rc != 0) {
        printf("DCIM_FAIL\n");
        return 1;
    }
#if DCIM_VERIFY_RW
    rc = verify_input_buffers(&dcim0);
    if (rc != 0) {
        printf("DCIM_FAIL\n");
        return 1;
    }
#endif

    dcim0.configure(&dcim0,
                    DCIM_TEST_TOPO,
                    DCIM_GOLDEN_CFG_MODE,
                    DCIM_GOLDEN_ACC,
                    DCIM_ACT_ROWS,
                    DCIM_OUT_ROWS,
                    0u);

    dcim0.load_wei(&dcim0);
    /* Match standalone TB sequencing: give load_wei time to move WEI SRAM -> cache. */
    dcim0.wait_done(&dcim0, DCIM_POST_LOAD_CYCLES);
    dcim0.start(&dcim0);
    /* This stimulus does not wait for a done IRQ/status.
     * Use a fixed post-start delay before reading OUT buffer. */
    dcim0.wait_done(&dcim0, DCIM_POST_START_CYCLES);

    dcim0.set_buffer_owner(&dcim0, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);
    DCIM_FENCE_RW;

    rc = compare_output_buffers(&dcim0);
    if (rc != 0) {
        printf("DCIM_FAIL\n");
        return 1;
    }

    printf("DCIM_PASS\n");
    return 0;
}
