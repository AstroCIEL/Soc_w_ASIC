#include <stdint.h>
#include "serial.h"

void uart_init(uint32_t clk_hz, uint32_t baud) {
    uint16_t divisor = (uint16_t)((clk_hz + 8u * baud) / (16u * baud));

    UART_REG(UART_IER) = 0;                          /* disable interrupts */
    UART_REG(UART_LCR) = LCR_8N1 | LCR_DLAB;        /* DLAB=1 */
    UART_REG(UART_RBR_THR) = divisor & 0xFF;         /* DLL */
    UART_REG(UART_IER)     = divisor >> 8;            /* DLM */
    UART_REG(UART_LCR) = LCR_8N1;                    /* DLAB=0 */

    UART_REG(UART_FCR) = FCR_RX_RST | FCR_TX_RST;
}

void uart_putc(char c) {
    while ((UART_REG(UART_LSR) & LSR_THRE) == 0);
    UART_REG(UART_RBR_THR) = (uint8_t)c;
}

void uart_puts(const char *s) {
    while (*s) uart_putc(*s++);
}

static void uart_delay_cycles(volatile uint32_t cycles) {
    while (cycles--) {
        __asm__ volatile("nop");
    }
}

void uart_flush_safe(uint32_t clk_hz, uint32_t baud) {
    while ((UART_REG(UART_LSR) & LSR_THRE) == 0) {
    }

    uint32_t cycles_per_bit = (clk_hz + baud - 1) / baud;
    uint32_t wait_cycles = cycles_per_bit * 12;  
    uart_delay_cycles(wait_cycles);
}

void _putchar(char c) {
  uart_putc(c);
}