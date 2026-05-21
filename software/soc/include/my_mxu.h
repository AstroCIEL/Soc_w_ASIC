#ifndef MY_MXU_H
#define MY_MXU_H

#include <stdint.h>
#include "soc.h"

/*
 * MMIO layout — match hardware/user_ip/my_mxu/mxu_top_wrapper.sv
 * SoC window bases — match hardware/soc/minimum_my_mxu/ariane_soc_pkg.sv
 */
//  地址窗口：
#define MY_MXU_CFG_BASE    0x70000000UL
#define MY_MXU_WGT_BASE    0x70008000UL
#define MY_MXU_ACT_BASE    0x70010000UL
#define MY_MXU_OUT_BASE    0x70018000UL

#define MY_MXU_WGTBUF_BASE MY_MXU_WGT_BASE
#define MY_MXU_ACTBUF_BASE MY_MXU_ACT_BASE
#define MY_MXU_OUTBUF_BASE MY_MXU_OUT_BASE
// 窗口长度：
#define MY_MXU_CFG_SIZE    0x1000UL
#define MY_MXU_WGT_SIZE    0x8000UL
#define MY_MXU_ACT_SIZE    0x8000UL
#define MY_MXU_OUT_SIZE    0x8000UL


// 寄存器 offset：
#define MY_MXU_REG_CTRL_OFF        0x000u    
#define MY_MXU_REG_STATUS_OFF      0x008u   
#define MY_MXU_REG_WGT_BUF_CTRL_OFF 0x010u   
#define MY_MXU_REG_ACT_BUF_CTRL_OFF 0x018u   
#define MY_MXU_REG_OUT_BUF_CTRL_OFF 0x020u    
#define MY_MXU_REG_CFG_WRITE_OFF   0x030u   
#define MY_MXU_REG_IRQ_MASK_OFF    0x038u  
#define MY_MXU_REG_IRQ_STAT_OFF    0x040u  

//bit位定义：
#define MY_MXU_CTRL_START        (1u << 0)
#define MY_MXU_CTRL_CLR_DONE     (1u << 1)

#define MY_MXU_STATUS_BUSY    (1ull << 0)
#define MY_MXU_STATUS_DONE    (1ull << 1)
//三个buffer都是1R1W，因此要分别指定读端口和写端口的归属 
#define MY_MXU_BUF_RD_MXU     (1ull << 0)
#define MY_MXU_BUF_WR_MXU     (1ull << 1)

// CFG_WRITE：
// bit [3:0] cfg_addr
// bit [15:8] cfg_data

#define MY_MXU_CFG_ADDR_SHIFT   0u
#define MY_MXU_CFG_ADDR_MASK    (0xFu << MY_MXU_CFG_ADDR_SHIFT) //表示1111作为掩码

#define MY_MXU_CFG_DATA_SHIFT   8u
#define MY_MXU_CFG_DATA_MASK    (0xFFu << MY_MXU_CFG_DATA_SHIFT) //表示11111111作为掩码

#define MY_MXU_CFG_WRITE(addr, data) \
    ((((uint32_t)(addr) & 0xFu) << MY_MXU_CFG_ADDR_SHIFT) | \
     (((uint32_t)(data) & 0xFFu) << MY_MXU_CFG_DATA_SHIFT))

//cfg address枚举
#define MXU_CFG_WGT_TILE0_BASE_ADDR 0
#define MXU_CFG_WGT_TILE1_BASE_ADDR 1
#define MXU_CFG_WGT_TILE2_BASE_ADDR 2
#define MXU_CFG_WGT_TILE3_BASE_ADDR 3
#define MXU_CFG_ACT_TILE0_BASE_ADDR 4
#define MXU_CFG_ACT_TILE1_BASE_ADDR 5
#define MXU_CFG_ACT_TILE2_BASE_ADDR 6
#define MXU_CFG_ACT_TILE3_BASE_ADDR 7
#define MXU_CFG_OUT_TILE0_BASE_ADDR 8
#define MXU_CFG_OUT_TILE1_BASE_ADDR 9
#define MXU_CFG_OUT_TILE2_BASE_ADDR 10
#define MXU_CFG_OUT_TILE3_BASE_ADDR 11
#define MXU_CFG_ACT_BATCHSIZE_M     12
#define MXU_CFG_SA_DATA_FLOW_MODE   13
#define MXU_CFG_SA_DATA_TYPE_MODE   14

//模式
#define MXU_FLOW_FF    0
#define MXU_FLOW_BP    1
#define MXU_TYPE_POSIT 0
#define MXU_TYPE_INT   1


// mxu和buffer相关参数
#define MXU_LANE_NUM          4u
#define MXU_BUF_BANK_COUNT    8u
#define MXU_BUF_ROW_COUNT     256u
#define MXU_BUF_ROW_BYTES     16u
#define MXU_BUF_WORD_BYTES    8u

#define mxu_buf_word_offset(bank, row, half64) \
    ((((uint32_t)(bank) & 0x7u) << 12) | \
     (((uint32_t)(row) & 0xFFu) << 4) | \
     (((uint32_t)(half64) & 0x1u) << 3))


/* irq_sources[2] in ariane_peripherals.sv -> PLIC id 3 */
#define MY_MXU_PLIC_IRQ_SRC   2u
#define IRQn_MY_MXU           (MY_MXU_PLIC_IRQ_SRC + 1u)

struct my_mxu_regs {
    volatile uint64_t ctrl;          // 0x000
    volatile uint64_t status;        // 0x008
    volatile uint64_t wgt_buf_ctrl;  // 0x010
    volatile uint64_t act_buf_ctrl;  // 0x018
    volatile uint64_t out_buf_ctrl;  // 0x020
    volatile uint64_t _reserved0;    // 0x028
    volatile uint64_t cfg_write;     // 0x030
    volatile uint64_t irq_mask;      // 0x038
    volatile uint64_t irq_status;    // 0x040
};

#define MY_MXU_REGS ((struct my_mxu_regs *)(uintptr_t)(MY_MXU_CFG_BASE))

struct my_mxu_drv {
    struct my_mxu_regs *regs;
    volatile uint8_t *wgtbuf;
    volatile uint8_t *actbuf;
    volatile uint8_t *outbuf;

//提供API声明
    void (*init) (struct my_mxu_drv *d,
                            struct my_mxu_regs *r,
                            volatile uint8_t *wgtbuf_mmio,
                            volatile uint8_t *actbuf_mmio,
                            volatile uint8_t *outbuf_mmio);

    void(*mxu_write_cfg)(struct my_mxu_drv *drv, uint32_t cfg_addr, uint32_t cfg_data);
    void(*mxu_config_common)(struct my_mxu_drv *drv, uint32_t flow_mode, uint32_t data_type_mode);
    void(*mxu_set_wgt_ports)(struct my_mxu_drv *drv, uint32_t rd_acc, uint32_t wr_acc);
    void(*mxu_set_act_ports)(struct my_mxu_drv *drv, uint32_t rd_acc, uint32_t wr_acc);
    void(*mxu_set_out_ports)(struct my_mxu_drv *drv, uint32_t rd_acc, uint32_t wr_acc);
    void(*mxu_start)(struct my_mxu_drv *drv);
    uint64_t(*mxu_read_status)(struct my_mxu_drv *drv);
    int(*mxu_wait_done)(struct my_mxu_drv *drv, uint64_t timeout);
    void(*mxu_clear_done)(struct my_mxu_drv *drv);
};

extern struct my_mxu_drv my_mxu0;

void my_mxu_bind(struct my_mxu_drv *d);

#endif
