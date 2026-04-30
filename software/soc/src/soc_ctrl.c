#include <stdint.h>
#include "soc.h"
#include "soc_ctrl.h"

static void soc_ctrl_op_init(struct soc_ctrl *c, struct soc_ctrl_regs *regs)
{
    c->regs = regs;
    /* Leave ro fields untouched; clear the rw control bits. */
    regs->event_trigger = 0;
    regs->hw_cnt_en     = 0;
}

__attribute__((noreturn))
static void soc_ctrl_op_exit(struct soc_ctrl *c, int status)
{
    /* ctrl_registers.sv latches a write with bit0 == 1 as end-of-
     * computation and captures bits [31:1] as the exit code. */
    c->regs->exit = ((uint64_t)(uint32_t)status << 1) | 1ull;
    for (;;) __asm__ volatile ("wfi");
}

static uint64_t soc_ctrl_op_dram_base(struct soc_ctrl *c)
{
    return c->regs->dram_base_addr;
}

static uint64_t soc_ctrl_op_dram_end(struct soc_ctrl *c)
{
    return c->regs->dram_end_addr;
}

static void soc_ctrl_op_set_event(struct soc_ctrl *c, uint64_t v)
{
    c->regs->event_trigger = v;
}

static uint64_t soc_ctrl_op_get_event(struct soc_ctrl *c)
{
    return c->regs->event_trigger;
}

static void soc_ctrl_op_hw_cnt_enable(struct soc_ctrl *c)
{
    c->regs->hw_cnt_en = 1;
}

static void soc_ctrl_op_hw_cnt_disable(struct soc_ctrl *c)
{
    c->regs->hw_cnt_en = 0;
}

static uint64_t soc_ctrl_op_hw_cnt_get(struct soc_ctrl *c)
{
    return c->regs->hw_cnt_en;
}

struct soc_ctrl soc_ctrl0;

void soc_ctrl_bind(struct soc_ctrl *c)
{
    c->init           = soc_ctrl_op_init;
    c->exit           = soc_ctrl_op_exit;
    c->dram_base      = soc_ctrl_op_dram_base;
    c->dram_end       = soc_ctrl_op_dram_end;
    c->set_event      = soc_ctrl_op_set_event;
    c->get_event      = soc_ctrl_op_get_event;
    c->hw_cnt_enable  = soc_ctrl_op_hw_cnt_enable;
    c->hw_cnt_disable = soc_ctrl_op_hw_cnt_disable;
    c->hw_cnt_get     = soc_ctrl_op_hw_cnt_get;
}

/* Back-compat shim kept for syscalls.c::_exit() and crt0 tail calls. */
__attribute__((noreturn))
void soc_exit(int status)
{
    soc_ctrl0.exit(&soc_ctrl0, status);
}
