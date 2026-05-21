#include "my_mxu.h"

static void my_mxu_op_init(struct my_mxu_drv *d,
                              struct my_mxu_regs *r,
                              volatile uint8_t *wgtbuf_mmio,
                              volatile uint8_t *actbuf_mmio,
                              volatile uint8_t *outbuf_mmio)
{
    d->regs             = r;
    d->wgtbuf           = wgtbuf_mmio;
    d->actbuf           = actbuf_mmio;
    d->outbuf           = outbuf_mmio;
    d->regs->irq_mask   = 0;
    d->regs->irq_status = 1;
    d->regs->ctrl       = MY_MXU_CTRL_CLR_DONE;
}


static void my_mxu_op_write_cfg(struct my_mxu_drv *d,
                                uint32_t cfg_addr,
                                uint32_t cfg_data)
{
    d->regs->cfg_write = MY_MXU_CFG_WRITE(cfg_addr, cfg_data);
}

static void my_mxu_op_config_common(struct my_mxu_drv *d,
                                    uint32_t flow_mode,
                                    uint32_t data_type_mode)
{
    d->regs->cfg_write = MY_MXU_CFG_WRITE(MXU_CFG_SA_DATA_FLOW_MODE, flow_mode);
    d->regs->cfg_write = MY_MXU_CFG_WRITE(MXU_CFG_SA_DATA_TYPE_MODE, data_type_mode);
}

static void my_mxu_op_set_wgtbuf_ports(struct my_mxu_drv *d,
                                       uint32_t rd_to_acc,
                                       uint32_t wr_to_acc)
{
    uint64_t v = 0;
    if (rd_to_acc) v |= MY_MXU_BUF_RD_MXU;
    if (wr_to_acc) v |= MY_MXU_BUF_WR_MXU;
    d->regs->wgt_buf_ctrl = v;
}

static void my_mxu_op_set_actbuf_ports(struct my_mxu_drv *d,
                                       uint32_t rd_to_acc,
                                       uint32_t wr_to_acc)
{
    uint64_t v = 0;
    if (rd_to_acc) v |= MY_MXU_BUF_RD_MXU;
    if (wr_to_acc) v |= MY_MXU_BUF_WR_MXU;
    d->regs->act_buf_ctrl = v;
}

static void my_mxu_op_set_outbuf_ports(struct my_mxu_drv *d,
                                       uint32_t rd_to_acc,
                                       uint32_t wr_to_acc)
{
    uint64_t v = 0;
    if (rd_to_acc) v |= MY_MXU_BUF_RD_MXU;
    if (wr_to_acc) v |= MY_MXU_BUF_WR_MXU;
    d->regs->out_buf_ctrl = v;
}


static void my_mxu_op_start(struct my_mxu_drv *d)
{
    d->regs->ctrl = MY_MXU_CTRL_START;
}

static uint64_t my_mxu_op_read_status(struct my_mxu_drv *d)
{
    return d->regs->status;
}

static int my_mxu_op_busy(struct my_mxu_drv *d)
{
    return (d->regs->status & MY_MXU_STATUS_BUSY) != 0;
}

static int my_mxu_op_wait_done(struct my_mxu_drv *d, uint64_t timeout)
{
    while (timeout--) {
        if (!my_mxu_op_busy(d))
            return 0;
        __asm__ volatile ("nop");
    }
    return -1;
}

static void my_mxu_op_clear_done(struct my_mxu_drv *d)
{
    d->regs->irq_status = 1u;
    d->regs->ctrl       = MY_MXU_CTRL_CLR_DONE;
}


struct my_mxu_drv my_mxu0;

void my_mxu_bind(struct my_mxu_drv *d)
{
    d->init              = my_mxu_op_init;
    d->mxu_write_cfg     = my_mxu_op_write_cfg;
    d->mxu_config_common = my_mxu_op_config_common;
    d->mxu_set_wgt_ports = my_mxu_op_set_wgtbuf_ports;
    d->mxu_set_act_ports = my_mxu_op_set_actbuf_ports;
    d->mxu_set_out_ports = my_mxu_op_set_outbuf_ports;
    d->mxu_start         = my_mxu_op_start;
    d->mxu_read_status   = my_mxu_op_read_status;
    d->mxu_wait_done     = my_mxu_op_wait_done;
    d->mxu_clear_done    = my_mxu_op_clear_done;
}
