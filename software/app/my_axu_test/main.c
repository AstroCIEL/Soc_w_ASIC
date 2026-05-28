#include <stdint.h>
#include <stdio.h>

#include "my_axu.h"
#include "input_data.h"

#define FENCE_MEM __asm__ volatile ("fence rw, rw" ::: "memory")
#define FENCE_OW  __asm__ volatile ("fence ow, ow" ::: "memory")

#define AXU_WAIT_TIMEOUT  5000000u

/* Bitmask helpers selecting which banks participate in golden comparison.
 *   0xff -> all 8 banks (full 64-lane output)
 *   0x0f -> first 4 banks (first 32 lanes, used by SFU ITP / NLI compute)
 *   0x01 -> bank 0 only  (reduce / scheduler output) */
#define LANE_MASK_FULL64    0xffu
#define LANE_MASK_FIRST32   0x0fu
#define LANE_MASK_BANK0     0x01u

/* Compare scope of token0..N within a bank.  All lanes wide (0xff = 64 token
 * over 8 banks; 0x0f = 32 token over 4 banks; etc.).  In addition some cases
 * only populate the first few tokens of bank0 (reduce, scheduler).  When
 * `tokens_in_bank0_only` is non-zero, only the first N tokens of bank0 are
 * compared; this is detected automatically because non-target tokens in the
 * reference are zero, but to keep the comparator strict we compare the full
 * 64-bit half-words for every selected bank. */

/* CASE special-mode flags. */
#define CASE_NORMAL       0u
#define CASE_SEED_LOAD    1u  /* SFU seed_load: no axu_start, no compare */
#define CASE_LUT_LOAD     2u  /* NLI mul/ybnd lut load: start, no compare */

struct axu_case {
    const char *name;
    uint8_t  unit;
    uint8_t  func;
    uint8_t  opa_base;
    uint8_t  opb_base;
    uint8_t  vec_out_base;
    uint8_t  reduce_out_base;
    uint8_t  batch_size;
    uint8_t  out_row_start;
    uint8_t  out_row_count;
    uint8_t  bank_mask;        /* which banks participate in golden compare */
    uint8_t  special;          /* CASE_NORMAL / CASE_SEED_LOAD / CASE_LUT_LOAD */
};

/* Test program mirrors axu_top_tb.sv stimulus order so that data placement
 * in OP_A / OP_B / GOLDEN matches the testbench expectations. */

#if defined(AXU_TEST_CASE_vpu_add)
static const struct axu_case CASES[] = {
    { "vpu_add",         AXU_UNIT_VPU,   AXU_VPU_ADD,            AXU_MAP_OPA_0,   AXU_MAP_OPB_0,   AXU_MAP_GOLDEN_0,   0,  10,   AXU_MAP_GOLDEN_0, 10, LANE_MASK_FULL64,  CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_vpu_sub)
static const struct axu_case CASES[] = {
    { "vpu_sub",         AXU_UNIT_VPU,   AXU_VPU_SUB,            AXU_MAP_OPA_10,  AXU_MAP_OPB_10,  AXU_MAP_GOLDEN_10,  0,  10,  AXU_MAP_GOLDEN_10, 10, LANE_MASK_FULL64,  CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_vpu_mul)
static const struct axu_case CASES[] = {
    { "vpu_mul",         AXU_UNIT_VPU,   AXU_VPU_MUL,            AXU_MAP_OPA_20,  AXU_MAP_OPB_20,  AXU_MAP_GOLDEN_20,  0,  10,  AXU_MAP_GOLDEN_20, 10, LANE_MASK_FULL64,  CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_vpu_max)
static const struct axu_case CASES[] = {
    { "vpu_max",         AXU_UNIT_VPU,   AXU_VPU_MAX_EW,         AXU_MAP_OPA_30,  AXU_MAP_OPB_30,  AXU_MAP_GOLDEN_30,  0,  10,  AXU_MAP_GOLDEN_30, 10, LANE_MASK_FULL64,  CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_vpu_min)
static const struct axu_case CASES[] = {
    { "vpu_min",         AXU_UNIT_VPU,   AXU_VPU_MIN_EW,         AXU_MAP_OPA_40,  AXU_MAP_OPB_40,  AXU_MAP_GOLDEN_40,  0,  10,  AXU_MAP_GOLDEN_40, 10, LANE_MASK_FULL64,  CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_vpu_reduce_max)
static const struct axu_case CASES[] = {
    { "vpu_reduce_max",  AXU_UNIT_VPU,   AXU_VPU_REDUCE_MAX,     AXU_MAP_OPA_50,  AXU_MAP_OPB_50,  0,  AXU_MAP_GOLDEN_50,  10,  AXU_MAP_GOLDEN_50, 10, LANE_MASK_BANK0,   CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_vpu_reduce_sum)
static const struct axu_case CASES[] = {
    { "vpu_reduce_sum",  AXU_UNIT_VPU,   AXU_VPU_REDUCE_SUM,     AXU_MAP_OPA_60,  AXU_MAP_OPB_60,  0,  AXU_MAP_GOLDEN_60,  10,  AXU_MAP_GOLDEN_60, 10, LANE_MASK_BANK0,   CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_sfu_int2posit)
static const struct axu_case CASES[] = {
    { "sfu_int2posit",   AXU_UNIT_SFU,   AXU_SFU_ITP,            AXU_MAP_OPA_80,  AXU_MAP_OPB_80,  AXU_MAP_GOLDEN_80,  0,  10,  AXU_MAP_GOLDEN_80, 10, LANE_MASK_FIRST32, CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_sfu_rng)
static const struct axu_case CASES[] = {
    { "sfu_rng_seed",    AXU_UNIT_SFU,   0,                      0,   0,   0,   0,   0,   0,  0, 0,                 CASE_SEED_LOAD },
    { "sfu_rng",         AXU_UNIT_SFU,   AXU_SFU_RNG,            0,   0,  AXU_MAP_GOLDEN_90,   0,  10,  AXU_MAP_GOLDEN_90, 10, LANE_MASK_FULL64,  CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_nli_mish)
static const struct axu_case CASES[] = {
    { "nli_mish_mul",    AXU_UNIT_NLI,   AXU_NLI_LOAD_MULT,      AXU_MAP_OPA_90,   0,   0,   0,   0,   0,  0, 0,                 CASE_LUT_LOAD  },
    { "nli_mish_ybnd",   AXU_UNIT_NLI,   AXU_NLI_LOAD_YBND,      AXU_MAP_OPA_91,   0,   0,   0,   0,   0,  0, 0,                 CASE_LUT_LOAD  },
    { "nli_mish",        AXU_UNIT_NLI,   AXU_NLI_COMPUTE,        AXU_MAP_OPA_96,  AXU_MAP_OPB_50, AXU_MAP_GOLDEN_100,   0,  32, AXU_MAP_GOLDEN_100, 32, LANE_MASK_FIRST32, CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_nli_tanh)
static const struct axu_case CASES[] = {
    { "nli_tanh_mul",    AXU_UNIT_NLI,   AXU_NLI_LOAD_MULT,      AXU_MAP_OPA_128,   0,   0,   0,   0,   0,  0, 0,                 CASE_LUT_LOAD  },
    { "nli_tanh_ybnd",   AXU_UNIT_NLI,   AXU_NLI_LOAD_YBND,      AXU_MAP_OPA_129,   0,   0,   0,   0,   0,  0, 0,                 CASE_LUT_LOAD  },
    { "nli_tanh",        AXU_UNIT_NLI,   AXU_NLI_COMPUTE,        AXU_MAP_OPA_134,  AXU_MAP_OPB_51, AXU_MAP_GOLDEN_132,   0,  32, AXU_MAP_GOLDEN_132, 32, LANE_MASK_FIRST32, CASE_NORMAL    },
};
#elif defined(AXU_TEST_CASE_scheduler)
static const struct axu_case CASES[] = {
    { "scheduler",       AXU_UNIT_SCH,   AXU_SCH_RUN,            AXU_MAP_OPA_166,   0, AXU_MAP_GOLDEN_164,   0,   0, AXU_MAP_GOLDEN_164, 29, LANE_MASK_BANK0,   CASE_NORMAL    },
};
#else
/* Full test suite removed - use individual test cases only */
#error "Must specify AXU_TEST_CASE_xxx macro"
#endif

#define NUM_CASES  (sizeof(CASES) / sizeof(CASES[0]))

/* SFU rng seed source rows inside op_a buffer (matches axu_top_tb.sv). */
#ifdef AXU_TEST_CASE_sfu_rng
#define SFU_SEED_HIGH_ROW  AXU_MAP_OPA_48
#define SFU_SEED_LOW_ROW   AXU_MAP_OPA_49
#else
#define SFU_SEED_HIGH_ROW  48u
#define SFU_SEED_LOW_ROW   49u
#endif

static inline volatile uint64_t *axu_buf64(volatile uint8_t *buf,
                                           unsigned bank,
                                           unsigned row,
                                           unsigned half64)
{
    uintptr_t off = axu_buf_word_offset(bank, row, half64);
    return (volatile uint64_t *)((uintptr_t)buf + off);
}

static void write_all_input_buffers(struct my_axu_drv *axu)
{
    // Write OP_A (compact array)
    for (unsigned row = 0; row < AXU_TOTAL_ROW_COUNT_OPA; row++) {
        for (unsigned b = 0; b < AXU_INPUT_BANK_COUNT; b++) {
            *axu_buf64(axu->opabuf, b, row, 0) = AXU_OP_A_DATA[row][b][0];
            *axu_buf64(axu->opabuf, b, row, 1) = AXU_OP_A_DATA[row][b][1];
        }
    }
    
    // Write OP_B (compact array)
    for (unsigned row = 0; row < AXU_TOTAL_ROW_COUNT_OPB; row++) {
        for (unsigned b = 0; b < AXU_INPUT_BANK_COUNT; b++) {
            *axu_buf64(axu->opbbuf, b, row, 0) = AXU_OP_B_DATA[row][b][0];
            *axu_buf64(axu->opbbuf, b, row, 1) = AXU_OP_B_DATA[row][b][1];
        }
    }
}

static int compare_output_range(struct my_axu_drv *axu,
                                const struct axu_case *c)
{
    for (unsigned r = 0; r < c->out_row_count; r++) {
        unsigned row = (unsigned)c->out_row_start + r;
        
        // Bounds check for compact golden array
        if (row >= AXU_TOTAL_ROW_COUNT_GOLDEN) {
            printf("ERROR: golden_row %u out of bounds (max %u)\n",
                   row, AXU_TOTAL_ROW_COUNT_GOLDEN);
            return -1;
        }
        
        for (unsigned b = 0; b < AXU_INPUT_BANK_COUNT; b++) {
            if (((c->bank_mask >> b) & 0x1u) == 0u) {
                continue;
            }
            uint64_t expected_lo = AXU_GOLDEN_DATA[row][b][0];
            uint64_t expected_hi = AXU_GOLDEN_DATA[row][b][1];
            uint64_t actual_lo = *axu_buf64(axu->outbuf, b, row, 0);
            uint64_t actual_hi = *axu_buf64(axu->outbuf, b, row, 1);

            if (actual_lo != expected_lo || actual_hi != expected_hi) {
                printf("AXU_MISMATCH case=%s row=0x%02x bank=%u actual=0x%016lx_%016lx expected=0x%016lx_%016lx\n",
                       c->name, row, b,
                       (unsigned long)actual_hi, (unsigned long)actual_lo,
                       (unsigned long)expected_hi, (unsigned long)expected_lo);
                return -1;
            }
        }
    }
    return 0;
}

/* Run one sub-test: program cfg registers, hand buffer ports to the AXU,
 * pulse start (or seed_load), wait for done, hand ports back to CPU.
 * Returns 0 on success, non-zero on hardware error (timeout / no done). */
static int run_case(struct my_axu_drv *axu, const struct axu_case *c)
{
    /* CPU still owns all buffers from previous case / initial load. */
    axu->axu_clear_done(axu);

    if (c->special == CASE_SEED_LOAD) {
        /* Program seed source rows and trigger seed_load.  Buffer ports
         * must be handed to AXU because the seed loader reads op_a. */
        axu->axu_set_seed_high_base(axu, SFU_SEED_HIGH_ROW);
        axu->axu_set_seed_low_base (axu, SFU_SEED_LOW_ROW);

        axu->axu_set_opa_ports(axu, 1, 0);
        axu->axu_set_opb_ports(axu, 1, 0);
        axu->axu_set_out_ports(axu, 0, 0);
        FENCE_MEM;

        axu->axu_load_seed(axu);

        if (axu->axu_wait_done(axu, AXU_WAIT_TIMEOUT) != 0) {
            printf("AXU_TIMEOUT case=%s status=0x%lx\n",
                   c->name,
                   (unsigned long)axu->axu_read_status(axu));
            return -1;
        }

        axu->axu_set_opa_ports(axu, 0, 0);
        axu->axu_set_opb_ports(axu, 0, 0);
        axu->axu_set_out_ports(axu, 0, 0);
        FENCE_MEM;
        return 0;
    }

    /* Common cfg programming */
    axu->axu_set_unit           (axu, c->unit);
    axu->axu_set_func           (axu, c->func);
    axu->axu_set_op_a_base      (axu, c->opa_base);
    axu->axu_set_op_b_base      (axu, c->opb_base);
    axu->axu_set_vec_out_base   (axu, c->vec_out_base);
    axu->axu_set_reduce_out_base(axu, c->reduce_out_base);
    axu->axu_set_batch_size     (axu, c->batch_size);

    /* Buffer port ownership: AXU reads op_a/op_b, AXU writes out (except
     * LUT-load cases that only read op_a). */
    axu->axu_set_opa_ports(axu, 1, 0);
    axu->axu_set_opb_ports(axu, 1, 0);
    if (c->special == CASE_LUT_LOAD) {
        axu->axu_set_out_ports(axu, 0, 0);
    } else {
        axu->axu_set_out_ports(axu, 0, 1);
    }
    FENCE_MEM;

    axu->axu_start(axu);

    if (axu->axu_wait_done(axu, AXU_WAIT_TIMEOUT) != 0) {
        printf("AXU_TIMEOUT case=%s status=0x%lx\n",
               c->name,
               (unsigned long)axu->axu_read_status(axu));
        return -1;
    }

    uint64_t status = axu->axu_read_status(axu);
    if ((status & MY_AXU_STATUS_DONE) == 0) {
        printf("AXU_NO_DONE case=%s status=0x%lx\n",
               c->name, (unsigned long)status);
        return -1;
    }

    /* Return all buffer ports to CPU before next case / compare. */
    axu->axu_set_opa_ports(axu, 0, 0);
    axu->axu_set_opb_ports(axu, 0, 0);
    axu->axu_set_out_ports(axu, 0, 0);
    FENCE_MEM;
    return 0;
}

int main(void)
{
    printf("AXU_SOC_TEST_BEGIN\n");
    printf("AXU_MODE %s\n", AXU_TEST_MODE_NAME);

    my_axu_bind(&my_axu0);
    my_axu0.init(&my_axu0,
                 MY_AXU_REGS,
                 (volatile uint8_t *)MY_AXU_OPA_BASE,
                 (volatile uint8_t *)MY_AXU_OPB_BASE,
                 (volatile uint8_t *)MY_AXU_OUT_BASE);

    /* Start with all buffer ports on the CPU side so we can pre-load. */
    my_axu0.axu_set_opa_ports(&my_axu0, 0, 0);
    my_axu0.axu_set_opb_ports(&my_axu0, 0, 0);
    my_axu0.axu_set_out_ports(&my_axu0, 0, 0);

    write_all_input_buffers(&my_axu0);
    FENCE_OW;
    FENCE_MEM;

    unsigned pass = 0;
    unsigned fail = 0;

    for (unsigned i = 0; i < NUM_CASES; i++) {
        const struct axu_case *c = &CASES[i];

        int rc = run_case(&my_axu0, c);
        if (rc != 0) {
            printf("AXU_CASE name=%s result=FAIL (hw error)\n", c->name);
            fail++;
            continue;
        }

        if (c->special == CASE_SEED_LOAD || c->special == CASE_LUT_LOAD) {
            printf("AXU_CASE name=%s result=PASS (no compare)\n", c->name);
            pass++;
            continue;
        }

        if (compare_output_range(&my_axu0, c) != 0) {
            printf("AXU_CASE name=%s result=FAIL\n", c->name);
            fail++;
        } else {
            printf("AXU_CASE name=%s result=PASS\n", c->name);
            pass++;
        }
    }

    printf("AXU_SUMMARY total=%u pass=%u fail=%u\n",
           (unsigned)NUM_CASES, pass, fail);

    if (fail == 0) {
        printf("AXU_PASS\n");
    } else {
        printf("AXU_FAIL\n");
    }
    printf("AXU_SOC_TEST_END\n");
    return fail == 0 ? 0 : 1;
}
