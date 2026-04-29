/*
 * Demo: trigger and service an interrupt from the "default_slave" IP.
 *
 * Flow
 * ----
 *   1. Initialize the PLIC and install an ISR for IRQn_DEFAULT_SLAVE.
 *   2. Enable MEI in mie and the global MIE bit in mstatus.
 *   3. Write the "raise IRQ" doorbell at DEFAULT_SLAVE_BASE + 0x00.
 *   4. The CPU takes a MEI, which vectors to m_external_irq_handler
 *      (handlers.S) and lands in plic_handle_m_ext_irq() → our ISR.
 *      The ISR writes the "ack IRQ" doorbell at offset 0x10.
 *   5. main() spins on a volatile `irq_hit` flag and reports success.
 */

#include <stdio.h>
#include <stdint.h>

#include "soc.h"
#include "plic.h"
#include "encoding.h"

static volatile int irq_hit = 0;

static void default_slave_isr(IRQn_Type irq, void *arg) {
    (void)arg;
    *(volatile uint32_t *)(DEFAULT_SLAVE_BASE + DEFAULT_SLAVE_IRQ_ACK_OFF) = 1;
    irq_hit = (int)irq;

    printf("exit default_slave_isr\n");
}

int main(void)
{
    printf("=== default_slave IRQ demo ===\n");

    /* Route the PLIC. */
    plic_init(PLIC0);
    plic_register_handler(IRQn_DEFAULT_SLAVE, default_slave_isr, NULL);
    plic_set_priority (PLIC0, IRQn_DEFAULT_SLAVE, 1);
    plic_set_threshold(PLIC0, PLIC_CTX_M0, 0);
    plic_enable       (PLIC0, PLIC_CTX_M0, IRQn_DEFAULT_SLAVE);

    /* Enable M-mode external interrupts in the hart. */
    asm volatile("csrs mie,     %0" :: "r"(MIP_MEIP));
    asm volatile("csrs mstatus, %0" :: "r"(MSTATUS_MIE));

    printf("arming default_slave doorbell...\n");
    *(volatile uint32_t *)(DEFAULT_SLAVE_BASE + DEFAULT_SLAVE_IRQ_SET_OFF) = 1;

    /* Wait for the ISR. */
    while (!irq_hit) { asm volatile("nop"); }

    printf("IRQ %d serviced -- PASS\n", irq_hit);
    return 0;
}
