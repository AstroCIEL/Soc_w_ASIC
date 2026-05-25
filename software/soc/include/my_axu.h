#ifndef MY_AXU_H
#define MY_AXU_H

#include <stdint.h>
#include "soc.h"

/*
 * MMIO layout — match hardware/user_ip/my_axu/axu_top_wrapper.sv
 * SoC window bases — match hardware/soc/minimum_my_mxu_axu/ariane_soc_pkg.sv
 */
//  地址窗口：
#define MY_AXU_CFG_BASE    0x70020000UL
#define MY_AXU_OPA_BASE    0x70028000UL
#define MY_AXU_OPB_BASE    0x70030000UL
#define MY_AXU_OUT_BASE    0x70038000UL

// 窗口长度：
#define MY_AXU_CFG_SIZE    0x1000UL
#define MY_AXU_OPA_SIZE    0x8000UL
#define MY_AXU_OPB_SIZE    0x8000UL
#define MY_AXU_OUT_SIZE    0x8000UL

// 寄存器 offset：
#define MY_AXU_REG_CTRL_OFF         0x000u
#define MY_AXU_REG_STATUS_OFF       0x008u
#define MY_AXU_REG_OPA_BUF_CTRL_OFF 0x010u
#define MY_AXU_REG_OPB_BUF_CTRL_OFF 0x018u
#define MY_AXU_REG_OUT_BUF_CTRL_OFF 0x020u
#define MY_AXU_REG_CFG_WRITE_OFF    0x030u
#define MY_AXU_REG_IRQ_MASK_OFF     0x038u
#define MY_AXU_REG_IRQ_STAT_OFF     0x040u

//bit位定义：
#define MY_AXU_CTRL_START        (1u << 0)
#define MY_AXU_CTRL_CLR_DONE     (1u << 1)

#define MY_AXU_STATUS_BUSY       (1ull << 0)
#define MY_AXU_STATUS_DONE       (1ull << 1)
#define MY_AXU_STATUS_CALC_DONE  (1ull << 2)  // AXU 特有：仅指示一次计算完成（未必整体完成）

//三个buffer都是1R1W，因此要分别指定读端口和写端口的归属
#define MY_AXU_BUF_RD_AXU        (1ull << 0)
#define MY_AXU_BUF_WR_AXU        (1ull << 1)

// CFG_WRITE：
// bit [3:0] cfg_addr
// bit [15:8] cfg_data
// AXU 的 cfg_addr=4 bit，cfg_data=8 bit，与 MXU 完全一致
#define MY_AXU_CFG_ADDR_SHIFT   0u
#define MY_AXU_CFG_ADDR_MASK    (0xFu << MY_AXU_CFG_ADDR_SHIFT)

#define MY_AXU_CFG_DATA_SHIFT   8u
#define MY_AXU_CFG_DATA_MASK    (0xFFu << MY_AXU_CFG_DATA_SHIFT)

#define MY_AXU_CFG_WRITE(addr, data) \
    ((((uint32_t)(addr) & 0xFu) << MY_AXU_CFG_ADDR_SHIFT) | \
     (((uint32_t)(data) & 0xFFu) << MY_AXU_CFG_DATA_SHIFT))

//axu cfg address枚举
#define AXU_CFG_FUNC_SEL                 0
#define AXU_CFG_OP_A_BASE_ADDR           1
#define AXU_CFG_OP_B_BASE_ADDR           2
#define AXU_CFG_VEC_OUT_BASE_ADDR        3
#define AXU_CFG_REDUCE_OUT_BASE_ADDR     4
#define AXU_CFG_BATCH_SIZE               5
#define AXU_CFG_UNIT_SEL                 6
#define AXU_CFG_SFU_SEED_HIGH_BASE_ADDR  7
#define AXU_CFG_SFU_SEED_LOW_BASE_ADDR   8
#define AXU_CFG_SFU_SEED_LOAD            9

//AXU工作模式
//AXU 激活模块
#define AXU_UNIT_VPU   0
#define AXU_UNIT_SFU   1
#define AXU_UNIT_NLI   2
#define AXU_UNIT_SCH   3
//AXU VPU工作模式
#define AXU_VPU_ADD         0
#define AXU_VPU_SUB         1
#define AXU_VPU_MUL         2
#define AXU_VPU_MAX_EW      3
#define AXU_VPU_MIN_EW      4
#define AXU_VPU_REDUCE_MAX  5
#define AXU_VPU_REDUCE_SUM  6
//AXU SFU工作模式
#define AXU_SFU_CORDIC      0
#define AXU_SFU_RNG         1
#define AXU_SFU_ITP         2
//AXU NLI工作模式
#define AXU_NLI_LOAD_MULT   0
#define AXU_NLI_LOAD_YBND   1
#define AXU_NLI_COMPUTE     2
//AXU SCH工作模式
#define AXU_SCH_RUN         0

// AXU 通道数量
#define AXU_VPU_LANE_NUM    64u  // VPU 有64个通道
#define AXU_OTHER_LANE_NUM  32u  // 其他模块有32个通道

// AXU 三块 buffer 物理布局（每块都是 8 bank * 256 row * 128 bit = 32 KB）
// 与 MXU 完全相同，但用 AXU 前缀保持独立
#define AXU_BUF_BANK_COUNT    8u
#define AXU_BUF_ROW_COUNT     256u
#define AXU_BUF_ROW_BYTES     16u
#define AXU_BUF_WORD_BYTES    8u

#define axu_buf_word_offset(bank, row, half64) \
    ((((uint32_t)(bank) & 0x7u) << 12) | \
     (((uint32_t)(row) & 0xFFu) << 4) | \
     (((uint32_t)(half64) & 0x1u) << 3))


/* irq_sources[1] in ariane_peripherals.sv -> PLIC id 2 */
#define MY_AXU_PLIC_IRQ_SRC   1u
#define IRQn_MY_AXU           (MY_AXU_PLIC_IRQ_SRC + 1u)

struct my_axu_regs {
    volatile uint64_t ctrl;          // 0x000
    volatile uint64_t status;        // 0x008
    volatile uint64_t opa_buf_ctrl;  // 0x010
    volatile uint64_t opb_buf_ctrl;  // 0x018
    volatile uint64_t out_buf_ctrl;  // 0x020
    volatile uint64_t _reserved0;    // 0x028
    volatile uint64_t cfg_write;     // 0x030
    volatile uint64_t irq_mask;      // 0x038
    volatile uint64_t irq_status;    // 0x040
};

#define MY_AXU_REGS ((struct my_axu_regs *)(uintptr_t)(MY_AXU_CFG_BASE))


struct my_axu_drv {
    struct my_axu_regs *regs;
    volatile uint8_t *opabuf;
    volatile uint8_t *opbbuf;
    volatile uint8_t *outbuf;

    /* 初始化 / 通用 cfg 写 */
    void (*init)(struct my_axu_drv *d,
                 struct my_axu_regs *r,
                 volatile uint8_t *opabuf_mmio,
                 volatile uint8_t *opbbuf_mmio,
                 volatile uint8_t *outbuf_mmio);
    void (*axu_write_cfg)(struct my_axu_drv *d, uint32_t cfg_addr, uint32_t cfg_data);

    /* CFG 字段 setter（每个对应一个 axu_ctrl.sv 的 CFG_ 寄存器） */
    void (*axu_set_unit)            (struct my_axu_drv *d, uint32_t unit_sel);
    void (*axu_set_func)            (struct my_axu_drv *d, uint32_t func_sel);
    void (*axu_set_batch_size)      (struct my_axu_drv *d, uint32_t batch);
    void (*axu_set_op_a_base)       (struct my_axu_drv *d, uint32_t row);
    void (*axu_set_op_b_base)       (struct my_axu_drv *d, uint32_t row);
    void (*axu_set_vec_out_base)    (struct my_axu_drv *d, uint32_t row);
    void (*axu_set_reduce_out_base) (struct my_axu_drv *d, uint32_t row);
    void (*axu_set_seed_high_base)  (struct my_axu_drv *d, uint32_t row);
    void (*axu_set_seed_low_base)   (struct my_axu_drv *d, uint32_t row);

    /* SFU 专用：在 op_a/op_b buffer 中预放好 seed 数据后，触发 seed_load 状态机
     * 硬件：axu_ctrl.sv 在 IDLE 收到 cfg_set_i && cfg_addr==CFG_SFU_SEED_LOAD &&
     * cfg_data[0]==1 时跳到 ST_SEED_HIGH_REQ，加载完返回 IDLE。
     * 这不走普通 START 路径。
     */
    void (*axu_load_seed)(struct my_axu_drv *d);

    /* buffer 端口归属 */
    void (*axu_set_opa_ports)(struct my_axu_drv *d, uint32_t rd_to_acc, uint32_t wr_to_acc);
    void (*axu_set_opb_ports)(struct my_axu_drv *d, uint32_t rd_to_acc, uint32_t wr_to_acc);
    void (*axu_set_out_ports)(struct my_axu_drv *d, uint32_t rd_to_acc, uint32_t wr_to_acc);

    /* 启动 / 状态 */
    void     (*axu_start)         (struct my_axu_drv *d);
    uint64_t (*axu_read_status)   (struct my_axu_drv *d);
    int      (*axu_wait_done)     (struct my_axu_drv *d, uint64_t timeout);
    void     (*axu_clear_done)    (struct my_axu_drv *d);
};

extern struct my_axu_drv my_axu0;

void my_axu_bind(struct my_axu_drv *d);

#endif
