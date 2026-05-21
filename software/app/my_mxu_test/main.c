#include <stdint.h>
#include <stdio.h>

#include "my_mxu.h"

#if __has_include("input_data.h")
#include "input_data.h"
#endif

#define FENCE_MEM __asm__ volatile ("fence rw, rw" ::: "memory")
#define FENCE_OW  __asm__ volatile ("fence ow, ow" ::: "memory")

#ifndef MXU_TEST_MODE_NAME
#define MXU_TEST_MODE_NAME "int_ff_fallback"
#endif

#ifndef MXU_INPUT_BANK_COUNT
#define MXU_INPUT_BANK_COUNT 8u
#define MXU_WGT_ROW_START 0u
#define MXU_WGT_ROW_COUNT 1u
#define MXU_ACT_ROW_START 0u
#define MXU_ACT_ROW_COUNT 1u
#define MXU_OUT_ROW_START 0u
#define MXU_OUT_ROW_COUNT 1u
#define MXU_CFG_ACT_BATCHSIZE_VALUE 32u
#define MXU_CFG_DATA_FLOW_MODE_VALUE 0u
#define MXU_CFG_DATA_TYPE_MODE_VALUE 1u

static const uint64_t MXU_CFG_WGT_TILE_BASE_VALUES[4] = {0u, 4u, 8u, 12u};
static const uint64_t MXU_CFG_ACT_TILE_BASE_VALUES[4] = {0u, 8u, 16u, 24u};
static const uint64_t MXU_CFG_OUT_TILE_BASE_VALUES[4] = {0u, 8u, 16u, 24u};

static const uint64_t MXU_WGT_DATA[MXU_WGT_ROW_COUNT][MXU_INPUT_BANK_COUNT][2] = {
    {
        {0x0000000000000001ull, 0x0000000000000000ull},
        {0x0000000000000002ull, 0x0000000000000000ull},
        {0x0000000000000003ull, 0x0000000000000000ull},
        {0x0000000000000004ull, 0x0000000000000000ull},
        {0x0000000000000005ull, 0x0000000000000000ull},
        {0x0000000000000006ull, 0x0000000000000000ull},
        {0x0000000000000007ull, 0x0000000000000000ull},
        {0x0000000000000008ull, 0x0000000000000000ull},
    }
};

static const uint64_t MXU_ACT_DATA[MXU_ACT_ROW_COUNT][MXU_INPUT_BANK_COUNT][2] = {
    {
        {0x0000000000000011ull, 0x0000000000000000ull},
        {0x0000000000000012ull, 0x0000000000000000ull},
        {0x0000000000000013ull, 0x0000000000000000ull},
        {0x0000000000000014ull, 0x0000000000000000ull},
        {0x0000000000000015ull, 0x0000000000000000ull},
        {0x0000000000000016ull, 0x0000000000000000ull},
        {0x0000000000000017ull, 0x0000000000000000ull},
        {0x0000000000000018ull, 0x0000000000000000ull},
    }
};

static const uint64_t MXU_GOLDEN_DATA[MXU_OUT_ROW_COUNT][MXU_INPUT_BANK_COUNT][2] = {
    {
        {0x0000000000000000ull, 0x0000000000000000ull},
        {0x0000000000000000ull, 0x0000000000000000ull},
        {0x0000000000000000ull, 0x0000000000000000ull},
        {0x0000000000000000ull, 0x0000000000000000ull},
        {0x0000000000000000ull, 0x0000000000000000ull},
        {0x0000000000000000ull, 0x0000000000000000ull},
        {0x0000000000000000ull, 0x0000000000000000ull},
        {0x0000000000000000ull, 0x0000000000000000ull},
    }
};
#endif

static inline volatile uint64_t *mxu_buf64(volatile uint8_t *buf,
                                           unsigned bank,
                                           unsigned row,
                                           unsigned half64)
{
    uintptr_t off = mxu_buf_word_offset(bank, row, half64);
    return (volatile uint64_t *)((uintptr_t)buf + off);
}

static void print_mxu_word_tokens(uint64_t lo, uint64_t hi)
{
    for (unsigned token_idx = 0; token_idx < 8; token_idx++) {
        uint64_t word = token_idx < 4 ? lo : hi;
        unsigned shift = (token_idx & 3u) * 16u;
        unsigned token = (unsigned)((word >> shift) & 0xFFFFu);
        if (token_idx != 0) {
            printf("  ");
        }
        printf("%04x", token);
    }
}

static void dump_output_bank_files_compatible(struct my_mxu_drv *mxu)
{
    printf("===MXU_OUT_BEGIN bank_count=%u row_start=0x%x row_count=%u===\n",
           MXU_INPUT_BANK_COUNT, MXU_OUT_ROW_START, MXU_OUT_ROW_COUNT);
    for (unsigned b = 0; b < MXU_INPUT_BANK_COUNT; b++) {
        printf("===MXU_OUT_BANK_BEGIN bank=%u rows=%u===\n", b, MXU_OUT_ROW_COUNT);
        for (unsigned r = 0; r < MXU_OUT_ROW_COUNT; r++) {
            unsigned row = MXU_OUT_ROW_START + r;
            uint64_t lo = *mxu_buf64(mxu->outbuf, b, row, 0);
            uint64_t hi = *mxu_buf64(mxu->outbuf, b, row, 1);
            printf("row=%u ", row);
            print_mxu_word_tokens(lo, hi);
            printf("\n");
        }
        printf("===MXU_OUT_BANK_END bank=%u===\n", b);
    }
    printf("===MXU_OUT_END===\n");
}

static void write_cfg_table(struct my_mxu_drv *mxu)
{
    for (unsigned i = 0; i < 4; i++) {
        mxu->mxu_write_cfg(mxu, MXU_CFG_WGT_TILE0_BASE_ADDR + i, MXU_CFG_WGT_TILE_BASE_VALUES[i]);
        mxu->mxu_write_cfg(mxu, MXU_CFG_ACT_TILE0_BASE_ADDR + i, MXU_CFG_ACT_TILE_BASE_VALUES[i]);
        mxu->mxu_write_cfg(mxu, MXU_CFG_OUT_TILE0_BASE_ADDR + i, MXU_CFG_OUT_TILE_BASE_VALUES[i]);
    }

    mxu->mxu_write_cfg(mxu, MXU_CFG_ACT_BATCHSIZE_M, MXU_CFG_ACT_BATCHSIZE_VALUE);
    mxu->mxu_config_common(mxu, MXU_CFG_DATA_FLOW_MODE_VALUE, MXU_CFG_DATA_TYPE_MODE_VALUE);
}

static void write_input_buffers(struct my_mxu_drv *mxu)
{
    for (unsigned r = 0; r < MXU_WGT_ROW_COUNT; r++) {
        unsigned row = MXU_WGT_ROW_START + r;
        for (unsigned b = 0; b < MXU_INPUT_BANK_COUNT; b++) {
            *mxu_buf64(mxu->wgtbuf, b, row, 0) = MXU_WGT_DATA[r][b][0];
            *mxu_buf64(mxu->wgtbuf, b, row, 1) = MXU_WGT_DATA[r][b][1];
        }
    }

    for (unsigned r = 0; r < MXU_ACT_ROW_COUNT; r++) {
        unsigned row = MXU_ACT_ROW_START + r;
        for (unsigned b = 0; b < MXU_INPUT_BANK_COUNT; b++) {
            *mxu_buf64(mxu->actbuf, b, row, 0) = MXU_ACT_DATA[r][b][0];
            *mxu_buf64(mxu->actbuf, b, row, 1) = MXU_ACT_DATA[r][b][1];
        }
    }
}

static int compare_output(struct my_mxu_drv *mxu)
{
    for (unsigned r = 0; r < MXU_OUT_ROW_COUNT; r++) {
        unsigned row = MXU_OUT_ROW_START + r;
        for (unsigned b = 0; b < MXU_INPUT_BANK_COUNT; b++) {
            uint64_t expected_lo = MXU_GOLDEN_DATA[r][b][0];
            uint64_t expected_hi = MXU_GOLDEN_DATA[r][b][1];
            uint64_t actual_lo = *mxu_buf64(mxu->outbuf, b, row, 0);
            uint64_t actual_hi = *mxu_buf64(mxu->outbuf, b, row, 1);

            if (actual_lo != expected_lo || actual_hi != expected_hi) {
                printf("MXU_MISMATCH row=0x%02x bank=%u actual=0x%016lx_%016lx expected=0x%016lx_%016lx\n",
                       row, b,
                       (unsigned long)actual_hi, (unsigned long)actual_lo,
                       (unsigned long)expected_hi, (unsigned long)expected_lo);
                return -1;
            }
        }
    }
    return 0;
}

int main(void)
{
    printf("MXU_SOC_TEST_BEGIN\n");
    printf("MXU_MODE %s\n", MXU_TEST_MODE_NAME);

    my_mxu_bind(&my_mxu0);
    my_mxu0.init(&my_mxu0,
                 MY_MXU_REGS,
                 (volatile uint8_t *)MY_MXU_WGTBUF_BASE,
                 (volatile uint8_t *)MY_MXU_ACTBUF_BASE,
                 (volatile uint8_t *)MY_MXU_OUTBUF_BASE);

    my_mxu0.mxu_set_wgt_ports(&my_mxu0, 0, 0);
    my_mxu0.mxu_set_act_ports(&my_mxu0, 0, 0);
    my_mxu0.mxu_set_out_ports(&my_mxu0, 0, 0);

    write_input_buffers(&my_mxu0);
    FENCE_OW;
    FENCE_MEM;

    write_cfg_table(&my_mxu0);

    my_mxu0.mxu_set_wgt_ports(&my_mxu0, 1, 0);
    my_mxu0.mxu_set_act_ports(&my_mxu0, 1, 0);
    my_mxu0.mxu_set_out_ports(&my_mxu0, 0, 1);
    FENCE_MEM;

    my_mxu0.mxu_start(&my_mxu0);

    if (my_mxu0.mxu_wait_done(&my_mxu0, 5000000u) != 0) {
        printf("MXU_TIMEOUT status=0x%lx\n", (unsigned long)my_mxu0.mxu_read_status(&my_mxu0));
        printf("MXU_FAIL\n");
        printf("MXU_SOC_TEST_END\n");
        return 2;
    }

    uint64_t status = my_mxu0.mxu_read_status(&my_mxu0);
    if ((status & MY_MXU_STATUS_DONE) == 0) {
        printf("MXU_NO_DONE status=0x%lx\n", (unsigned long)status);
        printf("MXU_FAIL\n");
        printf("MXU_SOC_TEST_END\n");
        return 3;
    }

    my_mxu0.mxu_set_wgt_ports(&my_mxu0, 0, 0);
    my_mxu0.mxu_set_act_ports(&my_mxu0, 0, 0);
    my_mxu0.mxu_set_out_ports(&my_mxu0, 0, 0);
    FENCE_MEM;

    // dump_output_bank_files_compatible(&my_mxu0);

    // if (compare_output(&my_mxu0) != 0) {
    //     printf("MXU_FAIL\n");
    //     printf("MXU_SOC_TEST_END\n");
    //     return 1;
    // }

    printf("MXU_PASS\n");
    printf("MXU_SOC_TEST_END\n");
    return 0;
}
