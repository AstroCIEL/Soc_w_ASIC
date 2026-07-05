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

static int check_macro_rw(struct dcim_drv *d)
{
    const uint64_t act0 = 0x0123456789abcdefULL;
    const uint64_t act1 = 0x1111222233334444ULL;
    const uint64_t act2 = 0x2222333344445555ULL;
    const uint64_t act3 = 0x3333444455556666ULL;
    const uint64_t wei0 = 0xfedcba9876543210ULL;
    const uint64_t wei1 = 0x9999aaaabbbbccccULL;
    const uint64_t wei2 = 0x88889999aaaabbbbULL;
    const uint64_t wei3 = 0x777788889999aabbULL;
    const uint64_t out0 = 0x0123456789abcdefULL;
    const uint64_t out1 = 0x1111222233334444ULL;
    const uint64_t out2 = 0x2222333344445555ULL;
    const uint64_t out3 = 0x3333444455556666ULL;

    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);

    d->write_act64(d, 0, 0, act0);
    d->write_act64(d, 1, 1, act1);
    d->write_act64(d, 2, 2, act2);
    d->write_act64(d, 3, 3, act3);
    d->write_wei64(d, 0, 0, wei0);
    d->write_wei64(d, 1, 1, wei1);
    d->write_wei64(d, 2, 2, wei2);
    d->write_wei64(d, 3, 3, wei3);
    d->write_out64(d, 0, 0, out0);
    d->write_out64(d, 1, 1, out1);
    d->write_out64(d, 2, 2, out2);
    d->write_out64(d, 3, 3, out3);
//    DCIM_FENCE_OW;

    if (d->read_act64(d, 0, 0) != act0) return -1;
    if (d->read_act64(d, 1, 1) != act1) return -1;
    if (d->read_act64(d, 2, 2) != act2) return -1;
    if (d->read_act64(d, 3, 3) != act3) return -1;
    if (d->read_wei64(d, 0, 0) != wei0) return -1;
    if (d->read_wei64(d, 1, 1) != wei1) return -1;
    if (d->read_wei64(d, 2, 2) != wei2) return -1;
    if (d->read_wei64(d, 3, 3) != wei3) return -1;
    if (d->read_out64(d, 0, 0) != out0) return -1;
    if (d->read_out64(d, 1, 1) != out1) return -1;
    if (d->read_out64(d, 2, 2) != out2) return -1;
    if (d->read_out64(d, 3, 3) != out3) return -1;
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

    rc = check_macro_rw(d);
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

