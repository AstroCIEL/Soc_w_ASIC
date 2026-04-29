#include "hook.h"
#include "serial.h"
#include "soc.h"
#include "csr.h"

#define MSTATUS_FS_VS_DIRTY_MASK 0x00006600u

__attribute__((weak))
void pre_main(void)
{
    uart_init(SYS_CLK_HZ, BAUD_RATE);
    CSR_SET_BITS(CSR_REG_MSTATUS, MSTATUS_FS_VS_DIRTY_MASK);
}

__attribute__((weak))
void post_main(void)
{
    uart_flush_safe(SYS_CLK_HZ, BAUD_RATE);
}
