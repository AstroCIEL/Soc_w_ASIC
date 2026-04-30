#ifndef SERIAL_H
#define SERIAL_H

#include <stdint.h>

/* ── 16550 UART at 0x1000_0000 (matches soc_pkg::UARTBase) ── */
#define UART_BASE       0x10000000UL

/* Register offsets (byte-addressed, 32-bit APB).
 * apb_uart connects PADDR = addr[5:3], so offsets are reg_index * 4. */
#define UART_RBR_THR    0x00   /* reg0: Receive Buffer(R) / Transmit Holding(W) / DLAB: DLL */
#define UART_IER        0x08   /* reg1: Interrupt Enable  / DLAB: DLM */
#define UART_FCR        0x10   /* reg2: FIFO Control (write-only) / IIR (read) */
#define UART_LCR        0x18   /* reg3: Line Control */
#define UART_MCR        0x20   /* reg4: Modem Control */
#define UART_LSR        0x28   /* reg5: Line Status (read-only) */

/* LCR bits */
#define LCR_8N1         0x03   /* 8 data, no parity, 1 stop */
#define LCR_DLAB        0x80   /* Divisor Latch Access Bit */

/* FCR bits */
#define FCR_FIFO_EN     0x01
#define FCR_RX_RST      0x02
#define FCR_TX_RST      0x04

/* LSR bits */
#define LSR_DR          0x01   /* Data Ready */
#define LSR_THRE        0x20   /* THR Empty */
#define LSR_TEMT        0x40   /* Transmitter Empty */

/* ── Helpers ── */
#define UART_REG(off)   (*(volatile uint32_t *)(UART_BASE + (off)))

/* ── API ── */
void uart_init(uint32_t clk_hz, uint32_t baud);
void uart_putc(char c);
void uart_puts(const char *s);
void uart_flush_safe(uint32_t clk_hz, uint32_t baud);



#define SYS_CLK_HZ  500000000UL   /* 500 MHz — matches tb.sv */
#define BAUD_RATE   6250000UL     /* 500 MHz / (16*5) = 6.25 Mbaud; divisor=5 exact */


#endif /* SERIAL_H */
