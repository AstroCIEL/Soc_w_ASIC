#ifndef SERIAL_H
#define SERIAL_H

#include <stdint.h>
#include "soc.h"

/* ------------------------------------------------------------------ */
/*  APB 16550-compatible UART register block                          */
/* ------------------------------------------------------------------ */
/*
 * Register semantics (DLAB selects between RBR/THR/IER and DLL/DLM):
 *   rbr_thr_dll : DLAB=0 → Receive Buffer (R) / Transmit Holding (W)
 *                 DLAB=1 → Divisor Latch Low
 *   ier_dlm     : DLAB=0 → Interrupt Enable
 *                 DLAB=1 → Divisor Latch High
 *   fcr_iir     : Write = FIFO Control; Read = Interrupt ID
 *   lcr         : Line Control (DLAB lives in bit 7)
 *   mcr         : Modem Control
 *   lsr         : Line Status (read-only)
 *   msr         : Modem Status
 *   scr         : Scratch
 */
struct uart_regs {
    volatile uint32_t rbr_thr_dll;  uint32_t _rsv0;   /* 0x00 */
    volatile uint32_t ier_dlm;      uint32_t _rsv1;   /* 0x08 */
    volatile uint32_t fcr_iir;      uint32_t _rsv2;   /* 0x10 */
    volatile uint32_t lcr;          uint32_t _rsv3;   /* 0x18 */
    volatile uint32_t mcr;          uint32_t _rsv4;   /* 0x20 */
    volatile uint32_t lsr;          uint32_t _rsv5;   /* 0x28 */
    volatile uint32_t msr;          uint32_t _rsv6;   /* 0x30 */
    volatile uint32_t scr;          uint32_t _rsv7;   /* 0x38 */
};

struct uart {
    struct uart_regs *regs;
    uint32_t          clk_hz;
    uint32_t          baud;

    /* OO-style ops; populated by uart_bind() at init time. */
    void (*init) (struct uart *u, struct uart_regs *regs,
                  uint32_t clk_hz, uint32_t baud);
    void (*putc) (struct uart *u, char c);
    void (*puts) (struct uart *u, const char *s);
    void (*flush)(struct uart *u);
};

#define UART0_REGS  ((struct uart_regs *)(UART_BASE))

extern struct uart uart0;

/* Install the default ops into `u` so that u->init/putc/puts/flush work.    */
void uart_bind(struct uart *u);

/* LCR bits */
#define LCR_8N1         0x03u    /* 8 data, no parity, 1 stop */
#define LCR_DLAB        0x80u    /* Divisor Latch Access Bit */

/* FCR bits */
#define FCR_FIFO_EN     0x01u
#define FCR_RX_RST      0x02u
#define FCR_TX_RST      0x04u

/* LSR bits */
#define LSR_DR          0x01u
#define LSR_THRE        0x20u
#define LSR_TEMT        0x40u

#endif /* SERIAL_H */
