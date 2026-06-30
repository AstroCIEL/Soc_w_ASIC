#include <stdint.h>
#include <stdio.h>

#include "dcim.h"

#ifndef DCIM_TEST_TOPO
#define DCIM_TEST_TOPO DCIM_TOPO_1CH
#endif

#ifndef DCIM_POST_START_CYCLES
#ifdef DCIM_WAIT_CYCLES
#define DCIM_POST_START_CYCLES DCIM_WAIT_CYCLES
#else
#define DCIM_POST_START_CYCLES 200ULL
#endif
#endif

static int check_cfg_rw(struct dcim_drv *d)
{
    d->configure(d, DCIM_TEST_TOPO, DCIM_MODE_INT8, 0u, 4u, 4u, 0u);

    if (d->read_cfg64(d, DCIM_CFG_SLOT_ENA) != 1u) {
        printf("DCIM_FAIL: cfg_ena readback\n");
        return -1;
    }
    if (d->read_cfg64(d, DCIM_CFG_SLOT_TOPO) != DCIM_TEST_TOPO) {
        printf("DCIM_FAIL: cfg_topo readback\n");
        return -1;
    }
    if (d->read_cfg64(d, DCIM_CFG_SLOT_ACT_LEN) != 4u) {
        printf("DCIM_FAIL: cfg_act_length readback\n");
        return -1;
    }
    return 0;
}

static int check_buffer_rw(struct dcim_drv *d)
{
    const uint64_t act_pat = 0x0123456789abcdefULL;
    const uint64_t wei_pat = 0xfedcba9876543210ULL;
    const uint64_t out_pat = 0xaaaabbbbccccddddULL;

    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);

    d->write_act64(d, 0, 0, act_pat);
    d->write_wei64(d, 0, 0, wei_pat);
    d->write_out64(d, 0, 0, out_pat);
    DCIM_FENCE_OW;

    if (d->read_act64(d, 0, 0) != act_pat) {
        printf("DCIM_FAIL: act buffer readback\n");
        return -1;
    }
    if (d->read_wei64(d, 0, 0) != wei_pat) {
        printf("DCIM_FAIL: wei buffer readback\n");
        return -1;
    }
    if (d->read_out64(d, 0, 0) != out_pat) {
        printf("DCIM_FAIL: out buffer readback\n");
        return -1;
    }
    return 0;
}

static int check_ctrl_clear(struct dcim_drv *d)
{
    d->clear(d);
    d->write_cfg64(d, DCIM_CFG_SLOT_ENA, 1u);
    if (d->read_cfg64(d, DCIM_CFG_SLOT_ENA) != 1u) {
        printf("DCIM_FAIL: ctrl clear path\n");
        return -1;
    }
    return 0;
}

static int check_kick_flow(struct dcim_drv *d)
{
    /*
     * Doc flow (minimum compute kick, no golden yet):
     * CPU owns buffers -> write inputs -> fence -> cfg -> start
     * (start auto hands buffers to accelerator) -> fixed delay -> CPU owns out -> read
     */
    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);
    d->write_act64(d, 0, 0, 0x0000000100000002ULL);
    d->write_wei64(d, 0, 0, 0x0000000300000004ULL);
    DCIM_FENCE_OW;

    d->configure(d, DCIM_TEST_TOPO, DCIM_MODE_INT8, 0u, 1u, 1u, 0u);
    d->start(d);
    /* Current RTL has no done/irq completion; delay a fixed cycles after START. */
    d->wait_done(d, DCIM_POST_START_CYCLES);

    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);
    DCIM_FENCE_RW;
    (void)d->read_out64(d, 0, 0);
    return 0;
}

int main(void)
{
    int rc;

    printf("=== DCIM wrap smoke test (topo=%u) ===\n", (unsigned)DCIM_TEST_TOPO);

    dcim_bind(&dcim0);
    dcim0.init(&dcim0,
               DCIM_CFG_REGS,
               (volatile uint8_t *)(uintptr_t)DCIM_ACT_BASE,
               (volatile uint8_t *)(uintptr_t)DCIM_OUT_BASE,
               (volatile uint8_t *)(uintptr_t)DCIM_WEI_BASE);

    rc = check_cfg_rw(&dcim0);
    if (rc != 0)
        return rc;

    rc = check_buffer_rw(&dcim0);
    if (rc != 0)
        return rc;

    rc = check_ctrl_clear(&dcim0);
    if (rc != 0)
        return rc;

    rc = check_kick_flow(&dcim0);
    if (rc != 0)
        return rc;

    dcim0.clear(&dcim0);
    printf("DCIM_PASS\n");
    return 0;
}
