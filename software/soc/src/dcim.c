#include "dcim.h"

#if DCIM_CPU_IO_TRACE
#include <stdio.h>
#endif

#ifndef DCIM_CPU_IO_TRACE
#define DCIM_CPU_IO_TRACE 0
#endif

#if DCIM_CPU_IO_TRACE
static inline void dcim_trace_mmio(const char *op, uintptr_t addr, uint64_t data)
{
    printf("DCIM_IO %s addr=0x%08lx data=0x%016llx\n",
           op,
           (unsigned long)addr,
           (unsigned long long)data);
}
#endif

static inline volatile uint64_t *dcim_cfg_slot(struct dcim_drv *d, uint32_t off)
{
    (void)d;
    return (volatile uint64_t *)((uintptr_t)DCIM_CFG_BASE + off);
}

static void dcim_op_init(struct dcim_drv *d,
                         struct dcim_cfg_regs *cfg,
                         volatile uint8_t *actbuf_mmio,
                         volatile uint8_t *outbuf_mmio,
                         volatile uint8_t *weibuf_mmio)
{
    d->cfg    = cfg;
    d->actbuf = actbuf_mmio;
    d->outbuf = outbuf_mmio;
    d->weibuf = weibuf_mmio;

    d->clear(d);
    d->write_cfg64(d, DCIM_CFG_SLOT_ENA, 1u);
    d->set_buffer_owner(d, DCIM_BUF_CPU, DCIM_BUF_CPU, DCIM_BUF_CPU);
}

static void dcim_op_write_cfg64(struct dcim_drv *d, uint32_t slot_off, uint64_t val)
{
    volatile uint64_t *slot = dcim_cfg_slot(d, slot_off);
    *slot = val;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("W_CFG", (uintptr_t)slot, val);
#endif
}

static uint64_t dcim_op_read_cfg64(struct dcim_drv *d, uint32_t slot_off)
{
    volatile uint64_t *slot = dcim_cfg_slot(d, slot_off);
    uint64_t val = *slot;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("R_CFG", (uintptr_t)slot, val);
#endif
    return val;
}

static void dcim_op_configure(struct dcim_drv *d, uint32_t topo, uint32_t mode,
                              uint32_t acc, uint32_t act_len, uint32_t out_len,
                              uint32_t loop)
{
    d->write_cfg64(d, DCIM_CFG_SLOT_TOPO, topo);
    d->write_cfg64(d, DCIM_CFG_SLOT_MODE, mode);
    d->write_cfg64(d, DCIM_CFG_SLOT_ACC, acc);
    d->write_cfg64(d, DCIM_CFG_SLOT_ACT_LEN, act_len);
    d->write_cfg64(d, DCIM_CFG_SLOT_OUT_LEN, out_len);
    d->write_cfg64(d, DCIM_CFG_SLOT_LOOP, loop ? 1u : 0u);
}

static void dcim_op_set_buffer_owner(struct dcim_drv *d, uint32_t act_cpu,
                                     uint32_t out_cpu, uint32_t wei_cpu)
{
    d->write_cfg64(d, DCIM_CFG_SLOT_ACT_SEL, act_cpu ? 1u : 0u);
    d->write_cfg64(d, DCIM_CFG_SLOT_OUT_SEL, out_cpu ? 1u : 0u);
    d->write_cfg64(d, DCIM_CFG_SLOT_WEI_SEL, wei_cpu ? 1u : 0u);
}

static void dcim_op_write_act64(struct dcim_drv *d, unsigned bank,
                                uint32_t word_off, uint64_t val)
{
    volatile uint64_t *word =
        (volatile uint64_t *)dcim_act_word_offset(bank, word_off);
    (void)d;
    *word = val;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("W_ACT", (uintptr_t)word, val);
#endif
}

static uint64_t dcim_op_read_act64(struct dcim_drv *d, unsigned bank,
                                   uint32_t word_off)
{
    volatile uint64_t *word =
        (volatile uint64_t *)dcim_act_word_offset(bank, word_off);
    (void)d;
    uint64_t val = *word;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("R_ACT", (uintptr_t)word, val);
#endif
    return val;
}

static void dcim_op_write_wei64(struct dcim_drv *d, unsigned bank,
                                uint32_t word_off, uint64_t val)
{
    volatile uint64_t *word =
        (volatile uint64_t *)dcim_wei_word_offset(bank, word_off);
    (void)d;
    *word = val;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("W_WEI", (uintptr_t)word, val);
#endif
}

static uint64_t dcim_op_read_wei64(struct dcim_drv *d, unsigned bank,
                                   uint32_t word_off)
{
    volatile uint64_t *word =
        (volatile uint64_t *)dcim_wei_word_offset(bank, word_off);
    (void)d;
    uint64_t val = *word;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("R_WEI", (uintptr_t)word, val);
#endif
    return val;
}

static void dcim_op_write_out64(struct dcim_drv *d, unsigned bank,
                                 uint32_t word_off, uint64_t val)
{
    volatile uint64_t *word =
        (volatile uint64_t *)dcim_out_word_offset(bank, word_off);
    (void)d;
    *word = val;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("W_OUT", (uintptr_t)word, val);
#endif
}

static uint64_t dcim_op_read_out64(struct dcim_drv *d, unsigned bank,
                                   uint32_t word_off)
{
    volatile uint64_t *word =
        (volatile uint64_t *)dcim_out_word_offset(bank, word_off);
    (void)d;
    uint64_t val = *word;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("R_OUT", (uintptr_t)word, val);
#endif
    return val;
}

static void dcim_op_ctrl_pulse(struct dcim_drv *d, uint32_t ctrl_off)
{
    volatile uint64_t *cmd =
        (volatile uint64_t *)((uintptr_t)DCIM_CTRL_BASE + ctrl_off);
    (void)d;
    *cmd = 1u;
#if DCIM_CPU_IO_TRACE
    dcim_trace_mmio("W_CTRL", (uintptr_t)cmd, 1u);
#endif
}

static void dcim_op_load_wei(struct dcim_drv *d)
{
    dcim_op_ctrl_pulse(d, DCIM_CTRL_LOAD_OFF);
}

static void dcim_op_swap_wei(struct dcim_drv *d)
{
    dcim_op_ctrl_pulse(d, DCIM_CTRL_SWAP_OFF);
}

static void dcim_op_start(struct dcim_drv *d)
{
    dcim_op_ctrl_pulse(d, DCIM_CTRL_START_OFF);
}

static void dcim_op_clear(struct dcim_drv *d)
{
    dcim_op_ctrl_pulse(d, DCIM_CTRL_CLR_OFF);
}

static int dcim_op_wait_done(struct dcim_drv *d, uint64_t timeout_cycles)
{
    (void)d;
    while (timeout_cycles--) {
        __asm__ volatile("nop");
    }
    return 0;
}

struct dcim_drv dcim0;

void dcim_bind(struct dcim_drv *d)
{
    d->init             = dcim_op_init;
    d->write_cfg64      = dcim_op_write_cfg64;
    d->read_cfg64       = dcim_op_read_cfg64;
    d->configure        = dcim_op_configure;
    d->set_buffer_owner = dcim_op_set_buffer_owner;
    d->write_act64      = dcim_op_write_act64;
    d->read_act64       = dcim_op_read_act64;
    d->write_wei64      = dcim_op_write_wei64;
    d->read_wei64       = dcim_op_read_wei64;
    d->write_out64      = dcim_op_write_out64;
    d->read_out64       = dcim_op_read_out64;
    d->load_wei         = dcim_op_load_wei;
    d->swap_wei         = dcim_op_swap_wei;
    d->start            = dcim_op_start;
    d->clear            = dcim_op_clear;
    d->wait_done        = dcim_op_wait_done;
}
