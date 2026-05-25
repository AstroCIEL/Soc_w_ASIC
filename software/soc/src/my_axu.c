#include "my_axu.h"

/* ---- init ---- */
static void my_axu_op_init(struct my_axu_drv *d,
                           struct my_axu_regs *r,
                           volatile uint8_t *opabuf_mmio,
                           volatile uint8_t *opbbuf_mmio,
                           volatile uint8_t *outbuf_mmio)
{
    d->regs   = r;
    d->opabuf = opabuf_mmio;
    d->opbbuf = opbbuf_mmio;
    d->outbuf = outbuf_mmio;
    d->regs->irq_mask   = 0;
    d->regs->irq_status = 1;                       /* W1C clear sticky */
    d->regs->ctrl       = MY_AXU_CTRL_CLR_DONE;    /* clear done_sticky */
}

/* ---- 通用 cfg 写 ---- */
static void my_axu_op_write_cfg(struct my_axu_drv *d,
                                uint32_t cfg_addr,
                                uint32_t cfg_data)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(cfg_addr, cfg_data);
}

/* ---- 9 个 cfg setter ---- */
static void my_axu_op_set_unit(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_UNIT_SEL, v);
}

static void my_axu_op_set_func(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_FUNC_SEL, v);
}

static void my_axu_op_set_batch_size(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_BATCH_SIZE, v);
}

static void my_axu_op_set_op_a_base(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_OP_A_BASE_ADDR, v);
}

static void my_axu_op_set_op_b_base(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_OP_B_BASE_ADDR, v);
}

static void my_axu_op_set_vec_out_base(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_VEC_OUT_BASE_ADDR, v);
}

static void my_axu_op_set_reduce_out_base(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_REDUCE_OUT_BASE_ADDR, v);
}

static void my_axu_op_set_seed_high_base(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_SFU_SEED_HIGH_BASE_ADDR, v);
}

static void my_axu_op_set_seed_low_base(struct my_axu_drv *d, uint32_t v)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_SFU_SEED_LOW_BASE_ADDR, v);
}

/* ---- SFU seed 触发 ----
 * 不走 START 路径：写 CFG_SFU_SEED_LOAD 的 cfg_data[0]=1，状态机从 IDLE
 * 跳到 ST_SEED_HIGH_REQ，加载完返回 IDLE。
 */
static void my_axu_op_load_seed(struct my_axu_drv *d)
{
    d->regs->cfg_write = MY_AXU_CFG_WRITE(AXU_CFG_SFU_SEED_LOAD, 0x1u);
}

/* ---- 三组 buffer 端口归属 ---- */
static void my_axu_op_set_opa_ports(struct my_axu_drv *d,
                                    uint32_t rd_to_acc,
                                    uint32_t wr_to_acc)
{
    uint64_t v = 0;
    if (rd_to_acc) v |= MY_AXU_BUF_RD_AXU;
    if (wr_to_acc) v |= MY_AXU_BUF_WR_AXU;
    d->regs->opa_buf_ctrl = v;
}

static void my_axu_op_set_opb_ports(struct my_axu_drv *d,
                                    uint32_t rd_to_acc,
                                    uint32_t wr_to_acc)
{
    uint64_t v = 0;
    if (rd_to_acc) v |= MY_AXU_BUF_RD_AXU;
    if (wr_to_acc) v |= MY_AXU_BUF_WR_AXU;
    d->regs->opb_buf_ctrl = v;
}

static void my_axu_op_set_out_ports(struct my_axu_drv *d,
                                    uint32_t rd_to_acc,
                                    uint32_t wr_to_acc)
{
    uint64_t v = 0;
    if (rd_to_acc) v |= MY_AXU_BUF_RD_AXU;
    if (wr_to_acc) v |= MY_AXU_BUF_WR_AXU;
    d->regs->out_buf_ctrl = v;
}

/* ---- start / read_status / wait_done / clear_done ---- */
static void my_axu_op_start(struct my_axu_drv *d)
{
    d->regs->ctrl = MY_AXU_CTRL_START;
}

static uint64_t my_axu_op_read_status(struct my_axu_drv *d)
{
    return d->regs->status;
}

static int my_axu_op_busy(struct my_axu_drv *d)
{
    return (d->regs->status & MY_AXU_STATUS_BUSY) != 0;
}

static int my_axu_op_wait_done(struct my_axu_drv *d, uint64_t timeout)
{
    while (timeout--) {
        if (!my_axu_op_busy(d))
            return 0;
        __asm__ volatile ("nop");
    }
    return -1;
}

static void my_axu_op_clear_done(struct my_axu_drv *d)
{
    d->regs->irq_status = 1u;
    d->regs->ctrl       = MY_AXU_CTRL_CLR_DONE;
}


struct my_axu_drv my_axu0;

void my_axu_bind(struct my_axu_drv *d)
{
    d->init                    = my_axu_op_init;
    d->axu_write_cfg           = my_axu_op_write_cfg;
    d->axu_set_unit            = my_axu_op_set_unit;
    d->axu_set_func            = my_axu_op_set_func;
    d->axu_set_batch_size      = my_axu_op_set_batch_size;
    d->axu_set_op_a_base       = my_axu_op_set_op_a_base;
    d->axu_set_op_b_base       = my_axu_op_set_op_b_base;
    d->axu_set_vec_out_base    = my_axu_op_set_vec_out_base;
    d->axu_set_reduce_out_base = my_axu_op_set_reduce_out_base;
    d->axu_set_seed_high_base  = my_axu_op_set_seed_high_base;
    d->axu_set_seed_low_base   = my_axu_op_set_seed_low_base;
    d->axu_load_seed           = my_axu_op_load_seed;
    d->axu_set_opa_ports       = my_axu_op_set_opa_ports;
    d->axu_set_opb_ports       = my_axu_op_set_opb_ports;
    d->axu_set_out_ports       = my_axu_op_set_out_ports;
    d->axu_start               = my_axu_op_start;
    d->axu_read_status         = my_axu_op_read_status;
    d->axu_wait_done           = my_axu_op_wait_done;
    d->axu_clear_done          = my_axu_op_clear_done;
}
