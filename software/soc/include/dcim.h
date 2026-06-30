#ifndef DCIM_H
#define DCIM_H

#include <stdint.h>
#include "soc.h"

/*
 * MMIO layout — match hardware/user_ip/dcim_wrap/adapt/adapt_decode.sv
 * SoC window — match hardware/soc/minimum_dcim/ariane_soc_pkg.sv
 *
 * Single AXI slave; region select = axi_addr[19:17] (absolute address).
 * cfg_sel / act_sel / out_sel / wei_sel: 1 = CPU, 0 = accelerator (internal).
 *
 * Current RTL has no irq_o and no MMIO STATUS; completion uses software delay
 * (see dcim_wait_done) until an interrupt path is added.
 */

/* ------------------------------------------------------------------ */
/* Base / region map                                                  */
/* ------------------------------------------------------------------ */
#define DCIM_BASE           DCIM_BASE_ADDR
#define DCIM_LENGTH         0xA0000UL

#define DCIM_CTRL_BASE      (DCIM_BASE + 0x00000UL)
#define DCIM_CFG_BASE       (DCIM_BASE + 0x20000UL)
#define DCIM_ACT_BASE       (DCIM_BASE + 0x40000UL)
#define DCIM_OUT_BASE       (DCIM_BASE + 0x60000UL)
#define DCIM_WEI_BASE       (DCIM_BASE + 0x80000UL)

#define DCIM_CTRL_SIZE      0x20000UL
#define DCIM_CFG_SIZE       0x20000UL
#define DCIM_ACT_BANK_SIZE  0x800UL
#define DCIM_OUT_BANK_SIZE  0x2000UL
#define DCIM_WEI_BANK_SIZE  0x8000UL

#define DCIM_ACT_BANK_COUNT 4u
#define DCIM_OUT_BANK_COUNT 4u
#define DCIM_WEI_BANK_COUNT 4u

#define DCIM_ACT_BANK_STRIDE  DCIM_ACT_BANK_SIZE
#define DCIM_OUT_BANK_STRIDE  DCIM_OUT_BANK_SIZE
#define DCIM_WEI_BANK_STRIDE  DCIM_WEI_BANK_SIZE

/* ------------------------------------------------------------------ */
/* cfg slots: ext_addr[6:3] << 3 from DCIM_CFG_BASE (64-bit MMIO)     */
/* ------------------------------------------------------------------ */
#define DCIM_CFG_SLOT_ENA         0x00u
#define DCIM_CFG_SLOT_TOPO        0x08u
#define DCIM_CFG_SLOT_MODE        0x10u
#define DCIM_CFG_SLOT_ACC         0x18u
#define DCIM_CFG_SLOT_LOOP        0x20u
#define DCIM_CFG_SLOT_ACT_LEN     0x28u
#define DCIM_CFG_SLOT_OUT_LEN     0x30u
#define DCIM_CFG_SLOT_ACT_SEL     0x38u
#define DCIM_CFG_SLOT_OUT_SEL     0x40u
#define DCIM_CFG_SLOT_WEI_SEL     0x48u
#define DCIM_CFG_SLOT_EMA         0x50u
#define DCIM_CFG_SLOT_EMAW        0x58u
#define DCIM_CFG_SLOT_EMAS        0x60u
#define DCIM_CFG_SLOT_WABLM       0x68u
#define DCIM_CFG_SLOT_RAWLM       0x70u

/* ctrl commands: ext_addr[4:3] << 3 from DCIM_CTRL_BASE */
#define DCIM_CTRL_START_OFF       0x00u
#define DCIM_CTRL_CLR_OFF         0x08u
#define DCIM_CTRL_LOAD_OFF        0x10u
#define DCIM_CTRL_SWAP_OFF        0x18u

/* topo — match adapt_ctrl.sv TOPO1/TOPO2/TOPO3 */
#define DCIM_TOPO_4CH             0u
#define DCIM_TOPO_2CH             2u
#define DCIM_TOPO_1CH             3u

/* mode — match hardware/user_ip/dcim_wrap/dcim/inc/para.v */
#define DCIM_MODE_UINT4           0u
#define DCIM_MODE_UINT8           2u
#define DCIM_MODE_UINT16          3u
#define DCIM_MODE_INT4            4u
#define DCIM_MODE_INT8            6u
#define DCIM_MODE_INT16           7u

#define DCIM_BUF_CPU              1u
#define DCIM_BUF_ACCEL            0u

#define DCIM_ACT_DEPTH            64u
#define DCIM_OUT_DEPTH            64u
#define DCIM_BUF_WORD_BYTES       8u

#define DCIM_FENCE_OW  __asm__ volatile ("fence ow, ow" ::: "memory")
#define DCIM_FENCE_RW  __asm__ volatile ("fence rw, rw" ::: "memory")

#define dcim_act_bank_base(bank) \
    ((uintptr_t)(DCIM_ACT_BASE + ((uint32_t)(bank) * DCIM_ACT_BANK_STRIDE)))

#define dcim_out_bank_base(bank) \
    ((uintptr_t)(DCIM_OUT_BASE + ((uint32_t)(bank) * DCIM_OUT_BANK_STRIDE)))

#define dcim_wei_bank_base(bank) \
    ((uintptr_t)(DCIM_WEI_BASE + ((uint32_t)(bank) * DCIM_WEI_BANK_STRIDE)))

#define dcim_act_word_offset(bank, word) \
    (dcim_act_bank_base(bank) + ((uintptr_t)(word) * DCIM_BUF_WORD_BYTES))

#define dcim_out_word_offset(bank, word) \
    (dcim_out_bank_base(bank) + ((uintptr_t)(word) * DCIM_BUF_WORD_BYTES))

#define dcim_wei_word_offset(bank, word) \
    (dcim_wei_bank_base(bank) + ((uintptr_t)(word) * DCIM_BUF_WORD_BYTES))

struct dcim_cfg_regs {
    volatile uint64_t ena;
    volatile uint64_t topo;
    volatile uint64_t mode;
    volatile uint64_t acc;
    volatile uint64_t loop;
    volatile uint64_t act_length;
    volatile uint64_t out_length;
    volatile uint64_t act_sel;
    volatile uint64_t out_sel;
    volatile uint64_t wei_sel;
    volatile uint64_t ema;
    volatile uint64_t emaw;
    volatile uint64_t emas;
    volatile uint64_t wablm;
    volatile uint64_t rawlm;
};

#define DCIM_CFG_REGS ((struct dcim_cfg_regs *)(uintptr_t)(DCIM_CFG_BASE))

struct dcim_drv {
    struct dcim_cfg_regs *cfg;
    volatile uint8_t *actbuf;
    volatile uint8_t *outbuf;
    volatile uint8_t *weibuf;

    void (*init)(struct dcim_drv *d,
                 struct dcim_cfg_regs *cfg,
                 volatile uint8_t *actbuf_mmio,
                 volatile uint8_t *outbuf_mmio,
                 volatile uint8_t *weibuf_mmio);
    void (*write_cfg64)(struct dcim_drv *d, uint32_t slot_off, uint64_t val);
    uint64_t (*read_cfg64)(struct dcim_drv *d, uint32_t slot_off);
    void (*configure)(struct dcim_drv *d, uint32_t topo, uint32_t mode,
                      uint32_t acc, uint32_t act_len, uint32_t out_len,
                      uint32_t loop);
    void (*set_buffer_owner)(struct dcim_drv *d, uint32_t act_cpu,
                             uint32_t out_cpu, uint32_t wei_cpu);
    void (*write_act64)(struct dcim_drv *d, unsigned bank, uint32_t word_off,
                        uint64_t val);
    uint64_t (*read_act64)(struct dcim_drv *d, unsigned bank, uint32_t word_off);
    void (*write_wei64)(struct dcim_drv *d, unsigned bank, uint32_t word_off,
                        uint64_t val);
    uint64_t (*read_wei64)(struct dcim_drv *d, unsigned bank, uint32_t word_off);
    void (*write_out64)(struct dcim_drv *d, unsigned bank, uint32_t word_off,
                        uint64_t val);
    uint64_t (*read_out64)(struct dcim_drv *d, unsigned bank, uint32_t word_off);
    void (*load_wei)(struct dcim_drv *d);
    void (*swap_wei)(struct dcim_drv *d);
    void (*start)(struct dcim_drv *d);
    void (*clear)(struct dcim_drv *d);
    int (*wait_done)(struct dcim_drv *d, uint64_t timeout_cycles);
};

extern struct dcim_drv dcim0;

void dcim_bind(struct dcim_drv *d);

#endif /* DCIM_H */
