#include <stdint.h>
#include <stdio.h>

#include "dcim.h"
#include "input_data.h"

#ifndef DCIM_TEST_TOPO
#define DCIM_TEST_TOPO DCIM_TOPO_4CH
#endif

#ifndef DCIM_POST_START_CYCLES
#define DCIM_POST_START_CYCLES 100ULL
#endif

#ifndef DCIM_POST_LOAD_CYCLES
#define DCIM_POST_LOAD_CYCLES 32ULL
#endif

#ifndef DCIM_VERIFY_RW
#define DCIM_VERIFY_RW 1
#endif

static int write_input_buffers(struct dcim_drv *d)
{
    for (uint32_t bank = 0; bank < DCIM_MACRO_COUNT; ++bank) {
        for (uint32_t i = 0; i < DCIM_WEI_WORD_COUNT; ++i) {
            d->write_wei64(d, bank, i, DCIM_WEI_WORDS[bank][i]);
        }
        for (uint32_t i = 0; i < DCIM_ACT_WORD_COUNT; ++i) {
            d->write_act64(d, bank, i, DCIM_ACT_WORDS[bank][i]);
        }
    }
    DCIM_FENCE_OW;
    return 0;
}

static int verify_input_buffers(struct dcim_drv *d)
{
    for (uint32_t bank = 0; bank < DCIM_MACRO_COUNT; ++bank) {
        for (uint32_t i = 0; i < DCIM_WEI_WORD_COUNT; ++i) {
            uint64_t got = d->read_wei64(d, bank, i);
            uint64_t exp = DCIM_WEI_WORDS[bank][i];
            if (got != exp) {
                printf("DCIM_IN_MISMATCH WEI bank=%u idx=%u got=0x%08x%08x exp=0x%08x%08x\n",
                       bank,
                       i,
                       (unsigned int)(got >> 32),
                       (unsigned int)(got & 0xFFFFFFFFu),
                       (unsigned int)(exp >> 32),
                       (unsigned int)(exp & 0xFFFFFFFFu));
                return -1;
            }
        }
        for (uint32_t i = 0; i < DCIM_ACT_WORD_COUNT; ++i) {
            uint64_t got = d->read_act64(d, bank, i);
            uint64_t exp = DCIM_ACT_WORDS[bank][i];
            if (got != exp) {
                printf("DCIM_IN_MISMATCH ACT bank=%u idx=%u got=0x%08x%08x exp=0x%08x%08x\n",
                       bank,
                       i,
                       (unsigned int)(got >> 32),
                       (unsigned int)(got & 0xFFFFFFFFu),
                       (unsigned int)(exp >> 32),
                       (unsigned int)(exp & 0xFFFFFFFFu));
                return -1;
            }
        }
    }
    return 0;
}

static int compare_output_buffers(struct dcim_drv *d)
{
    uint32_t mismatch = 0;
    for (uint32_t bank = 0; bank < DCIM_MACRO_COUNT; ++bank) {
        for (uint32_t i = 0; i < DCIM_OUT_WORD_COUNT; ++i) {
            uint64_t got = d->read_out64(d, bank, i);
            uint64_t exp = DCIM_OUT_GOLDEN_WORDS[bank][i];
            if (got != exp) {
                ++mismatch;
                printf("DCIM_MISMATCH bank=%u idx=%u got=0x%08x%08x exp=0x%08x%08x\n",
                       bank,
                       i,
                       (unsigned int)(got >> 32),
                       (unsigned int)(got & 0xFFFFFFFFu),
                       (unsigned int)(exp >> 32),
                       (unsigned int)(exp & 0xFFFFFFFFu));
            }
        }
    }
    return (mismatch == 0) ? 0 : -1;
}

int main(void)
{
    int rc;

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
    dcim0.wait_done(&dcim0, DCIM_POST_LOAD_CYCLES);
    dcim0.start(&dcim0);
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
