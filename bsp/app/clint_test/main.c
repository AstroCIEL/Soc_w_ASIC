/*
 * Demo: exercise CLINT timer (MTIP) and software (MSIP/IPI) interrupts.
 *
 * 1. Bind + initialize CLINT.
 * 2. Install timer and IPI callbacks.
 * 3. Enable MTIE + MSIE in mie and the global MIE bit in mstatus.
 * 4. Schedule a short timeout via mtimecmp and wait for MTIP handler.
 * 5. Raise MSIP (IPI to self) and wait for software-IRQ handler.
 */

#include <stdio.h>
#include <stdint.h>

#include "soc.h"
#include "clint.h"
#include "encoding.h"

#define TIMER_CYCLES  1000ul

static volatile int timer_hit = 0;
static volatile int ipi_hit   = 0;

static void on_timer(void *arg)
{
    (void)arg;
    /* Disarm: pushing mtimecmp far into the future clears MTIP. */
    clint0.set_mtimecmp(&clint0, 0, (uint64_t)-1);
    timer_hit = 1;
    printf("on_timer fired, mtime=%lu\n", (unsigned long)clint0.get_mtime(&clint0));
}

static void on_ipi(void *arg)
{
    (void)arg;
    /* MSIP has already been cleared by the BSP entry stub. */
    ipi_hit = 1;
    printf("on_ipi fired\n");
}

int main(void)
{
    printf("=== CLINT timer + IPI demo ===\n");

   
    clint0.register_timer_cb(&clint0, on_timer, NULL);
    clint0.register_ipi_cb  (&clint0, on_ipi,   NULL);

    /* Enable both sources in mie. */
    asm volatile("csrs mie,     %0" :: "r"(MIP_MTIP | MIP_MSIP));
    asm volatile("csrs mstatus, %0" :: "r"(MSTATUS_MIE));

    /* --- Timer path --- */
    printf("arming mtimer (now=%lu, +%lu cycles)...\n",
           (unsigned long)clint0.get_mtime(&clint0),
           (unsigned long)TIMER_CYCLES);
    clint0.schedule_after(&clint0, 0, TIMER_CYCLES);
    while (!timer_hit) { asm volatile("nop"); }
    printf("timer IRQ serviced -- PASS\n");

    /* --- IPI path --- */
    printf("raising MSIP to hart 0...\n");
    clint0.send_ipi(&clint0, 0);
    while (!ipi_hit) { asm volatile("nop"); }
    printf("IPI serviced -- PASS\n");

    return 0;
}
