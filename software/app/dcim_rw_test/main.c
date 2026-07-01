#include <stdint.h>
#include <stdio.h>

#include "dcim.h"

static int check_cfg_rw(struct dcim_drv *d)
{
    d->write_cfg64(d, DCIM_CFG_SLOT_ENA, 1u);
    d->write_cfg64(d, DCIM_CFG_SLOT_TOPO, DCIM_TOPO_1CH);
    d->write_cfg64(d, DCIM_CFG_SLOT_MODE, DCIM_MODE_INT8);
    d->write_cfg64(d, DCIM_CFG_SLOT_ACC, 0u);
    d->write_cfg64(d, DCIM_CFG_SLOT_ACT_LEN, 4u);
    d->write_cfg64(d, DCIM_CFG_SLOT_OUT_LEN, 4u);
    d->write_cfg64(d, DCIM_CFG_SLOT_LOOP, 0u);

    if (d->read_cfg64(d, DCIM_CFG_SLOT_ENA) != 1u) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_TOPO) != DCIM_TOPO_1CH) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_MODE) != DCIM_MODE_INT8) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_ACT_LEN) != 4u) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_OUT_LEN) != 4u) return -1;
    return 0;
}

static int check_act_wei_rw(struct dcim_drv *d)
{
    const uint64_t act0 = 0x0123456789abcdefULL;
    const uint64_t act1 = 0x1111222233334444ULL;
    const uint64_t wei0 = 0xfedcba9876543210ULL;
    const uint64_t wei1 = 0x9999aaaabbbbccccULL;

    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);

    d->write_act64(d, 0, 0, act0);
    d->write_act64(d, 1, 1, act1);
    d->write_wei64(d, 0, 0, wei0);
    d->write_wei64(d, 1, 1, wei1);
//    DCIM_FENCE_OW;

    if (d->read_act64(d, 0, 0) != act0) return -1;
    if (d->read_act64(d, 1, 1) != act1) return -1;
    if (d->read_wei64(d, 0, 0) != wei0) return -1;
    if (d->read_wei64(d, 1, 1) != wei1) return -1;
    return 0;
}

static int check_ctrl_rw(struct dcim_drv *d)
{
    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);
    d->load_wei(d);
    d->swap_wei(d);
    d->start(d);

    /* START pulse should hand ownership to internal side. */
    if (d->read_cfg64(d, DCIM_CFG_SLOT_ACT_SEL) != 0u) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_OUT_SEL) != 0u) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_WEI_SEL) != 0u) return -1;

    d->clear(d);
    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);
    if (d->read_cfg64(d, DCIM_CFG_SLOT_ACT_SEL) != 1u) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_OUT_SEL) != 1u) return -1;
    if (d->read_cfg64(d, DCIM_CFG_SLOT_WEI_SEL) != 1u) return -1;
    return 0;
}

int main(void)
{
    struct dcim_drv *d = &dcim0;
    int rc;

    printf("=== DCIM cfg/act/wei/ctrl rw test ===\n");

    dcim_bind(d);
    d->init(d,
            DCIM_CFG_REGS,
            (volatile uint8_t *)(uintptr_t)DCIM_ACT_BASE,
            (volatile uint8_t *)(uintptr_t)DCIM_OUT_BASE,
            (volatile uint8_t *)(uintptr_t)DCIM_WEI_BASE);

    rc = check_cfg_rw(d);
    if (rc != 0) {
        printf("DCIM_RW_FAIL: cfg\n");
        return rc;
    }

    rc = check_act_wei_rw(d);
    if (rc != 0) {
        printf("DCIM_RW_FAIL: act_wei\n");
        return rc;
    }

    rc = check_ctrl_rw(d);
    if (rc != 0) {
        printf("DCIM_RW_FAIL: ctrl\n");
        return rc;
    }

    printf("DCIM_RW_PASS\n");
    return 0;
}

