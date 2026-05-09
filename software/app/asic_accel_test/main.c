#include <stdio.h>
#include <stdint.h>

#include "asic_accel.h"
#include "plic.h"
#include "encoding.h"

static volatile int g_irq_seen = 0;

static void asic_irq_handler(irqn_t irq, void *arg)
{
    (void)arg;
    if (irq == IRQn_ASIC_ACCEL) {
        asic_accel0.irq_clear(&asic_accel0);
        g_irq_seen = 1;
    }
}

int main(void)
{
    const uint64_t a = 37;
    const uint64_t b = 11;
    const uint64_t expect = (a * b) + a + b;

    printf("=== ASIC accelerator test (minimum) ===\n");

    asic_accel_bind(&asic_accel0);
    asic_accel0.init(&asic_accel0, ASIC_ACCEL_REGS);
    asic_accel0.irq_enable(&asic_accel0, 1);

    plic0.register_handler(&plic0, IRQn_ASIC_ACCEL, asic_irq_handler, NULL);
    plic0.set_priority(&plic0, IRQn_ASIC_ACCEL, 1);
    plic0.set_threshold(&plic0, PLIC_CTX_M0, 0);
    plic0.enable(&plic0, PLIC_CTX_M0, IRQn_ASIC_ACCEL);
    asm volatile("csrs mie, %0" :: "r"(MIP_MEIP));
    asm volatile("csrs mstatus, %0" :: "r"(MSTATUS_MIE));

    asic_accel0.set_operands(&asic_accel0, a, b);
    asic_accel0.start(&asic_accel0);

    while (!g_irq_seen) {
        asm volatile("wfi");
    }

    const uint64_t got = asic_accel0.result(&asic_accel0);
    const uint64_t cycles = asic_accel0.cycle_cnt(&asic_accel0);
    printf("result=%lu expect=%lu cycles=%lu\n", got, expect, cycles);

    if (got != expect) {
        printf("FAIL\n");
        return 1;
    }

    printf("PASS\n");
    return 0;
}
