#include "hook.h"
#include "serial.h"
#include "plic.h"
#include "clint.h"
#include "soc_ctrl.h"
#include "dma_reg64_1d.h"
#include "dma_desc64.h"
#include "soc.h"
#include "csr.h"

#define MSTATUS_FS_VS_DIRTY_MASK 0x00006600u

__attribute__((weak))
void pre_main(void)
{
    uart_bind(&uart0);
    uart0.init(&uart0, UART0_REGS, SYS_CLK_HZ, BAUD_RATE);

    /* Interrupt controllers. */
    plic_bind(&plic0);
    plic0.init(&plic0, PLIC0_REGS);

    clint_bind(&clint0);
    clint0.init(&clint0, CLINT0_REGS);

    soc_ctrl_bind(&soc_ctrl0);
    soc_ctrl0.init(&soc_ctrl0, SOC_CTRL0_REGS);

    dma_desc64_bind(&dma_desc64_0);
    dma_desc64_0.init(&dma_desc64_0, DMA_DESC64_0_REGS);
    // dma_reg64_1d_bind(&dma_reg64_1d_0);
    // dma_reg64_1d_0.init(&dma_reg64_1d_0, DMA_REG64_1D_0_REGS);


    /* Keep FS/VS dirty so F/V state survives context switches. */
    CSR_SET_BITS(CSR_REG_MSTATUS, MSTATUS_FS_VS_DIRTY_MASK);
}

__attribute__((weak))
void post_main(void)
{
    uart0.flush(&uart0);
}
