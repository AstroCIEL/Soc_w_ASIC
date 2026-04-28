#include <stdint.h>
#include "soc.h"
#include "soc_ctrl.h"

void soc_exit(int status)
{
    /* ctrl_registers.sv captures a write with bit 0 == 1 as end-of-
     * computation, taking bits [31:1] as the exit code. */
    *(volatile uint64_t *)EOC_ADDRESS_REG =
        ((uint64_t)(uint32_t)status << 1) | 1ULL;
    for (;;) {
        __asm__ volatile ("wfi");
    }
}
