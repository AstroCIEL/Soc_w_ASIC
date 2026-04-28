#include "hook.h"
#include "serial.h"
#include "soc.h"

__attribute__((weak))
void pre_main(void)
{
    uart_init(SYS_CLK_HZ, BAUD_RATE);
}

__attribute__((weak))
void post_main(void)
{
    uart_flush_safe(SYS_CLK_HZ, BAUD_RATE);
}
