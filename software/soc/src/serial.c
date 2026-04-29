#include <stdint.h>
#include "serial.h"

/* Default console UART instance. */
struct uart uart0;

static inline void uart_set_divisor(struct uart_regs *r, uint16_t divisor) {
    r->lcr         = LCR_8N1 | LCR_DLAB;   /* unlock DLL/DLM */
    r->rbr_thr_dll = divisor & 0xFFu;
    r->ier_dlm     = (uint32_t)(divisor >> 8);
    r->lcr         = LCR_8N1;              /* relock, 8N1 */
}

static void uart_delay_cycles(volatile uint32_t cycles) {
    while (cycles--) {
        __asm__ volatile("nop");
    }
}

static void uart_op_init(struct uart *u, struct uart_regs *regs,
                         uint32_t clk_hz, uint32_t baud) {
    u->regs   = regs;
    u->clk_hz = clk_hz;
    u->baud   = baud;

    uint16_t divisor = (uint16_t)((clk_hz + 8u * baud) / (16u * baud));

    regs->ier_dlm = 0;                     /* disable interrupts */
    uart_set_divisor(regs, divisor);
    regs->fcr_iir = FCR_RX_RST | FCR_TX_RST;
}

static void uart_op_putc(struct uart *u, char c) {
    struct uart_regs *r = u->regs;
    while ((r->lsr & LSR_THRE) == 0) { /* spin */ }
    r->rbr_thr_dll = (uint8_t)c;
}

static void uart_op_puts(struct uart *u, const char *s) {
    while (*s) u->putc(u, *s++);
}

static void uart_op_flush(struct uart *u) {
    struct uart_regs *r = u->regs;
    while ((r->lsr & LSR_THRE) == 0) { /* spin */ }

    uint32_t cycles_per_bit = (u->clk_hz + u->baud - 1) / u->baud;
    uart_delay_cycles(cycles_per_bit * 12);
}

void uart_bind(struct uart *u) {
    u->init  = uart_op_init;
    u->putc  = uart_op_putc;
    u->puts  = uart_op_puts;
    u->flush = uart_op_flush;
}

/* ------------------------------------------------------------------ */
/*  Paland printf backend                                             */
/* ------------------------------------------------------------------ */
void _putchar(char c) {
    uart0.putc(&uart0, c);
}
