
#include "encoding.h"

/* Make sure the vector table gets linked into the binary. */
.global vector_table

/* Entry point for bare-metal programs on the Ara SoC. */
.section .text.start
.global _start
.type _start, @function

_start:
	/* initialize global pointer */
.option push
.option norelax
1:	auipc gp, %pcrel_hi(__global_pointer$)
	addi  gp, gp, %pcrel_lo(1b)
.option pop

	/* Clear GPRs (keep gp and sp, which we set below) */
	li	x1,  0
	li	x4,  0
	li	x5,  0
	li	x6,  0
	li	x7,  0
	li	x8,  0
	li	x9,  0
	li	x10, 0
	li	x11, 0
	li	x12, 0
	li	x13, 0
	li	x14, 0
	li	x15, 0
	li	x16, 0
	li	x17, 0
	li	x18, 0
	li	x19, 0
	li	x20, 0
	li	x21, 0
	li	x22, 0
	li	x23, 0
	li	x24, 0
	li	x25, 0
	li	x26, 0
	li	x27, 0
	li	x28, 0
	li	x29, 0
	li	x30, 0
	li	x31, 0

	/* Initialize stack pointer at the end of RAM */
	la	sp, __stack_end

	/* Set up a PMP to permit all accesses (Machine mode default-deny fallback) */
	li	t0, (1 << (31 + (__riscv_xlen / 64) * (53 - 31))) - 1
	csrw	pmpaddr0, t0
	li	t0, PMP_NAPOT | PMP_R | PMP_W | PMP_X
	csrw	pmpcfg0, t0

	/* Delegate no traps, disable interrupts */
	csrwi	mie, 0
	csrwi	medeleg, 0
	csrwi	mideleg, 0
	csrwi	mstatus, 0

	/* Install interrupt vector table in vectored mode */
	la	t0, __vector_start
	ori	t0, t0, 1           /* mtvec.MODE = Vectored */
	csrw	mtvec, t0

	/* Enable FP extension */
	li	t0, (MSTATUS_FS & (MSTATUS_FS >> 1))
	csrs	mstatus, t0
	csrwi	fcsr, 0

	/* Enable Vector extension */
	li	t0, (MSTATUS_VS & (MSTATUS_VS >> 1))
	csrs	mstatus, t0

	/* Expose cycle/time/instret to lower modes */
	csrsi	mcounteren, 1
	csrsi	scounteren, 1

	/* Zero the BSS segment (memset(__bss_start, 0, __bss_end - __bss_start)) */
	la	a0, __bss_start
	la	a2, __bss_end
	sub	a2, a2, a0
	li	a1, 0
	call	memset

	/* new-style constructors and destructors */
	la	a0, __libc_fini_array
	call	atexit
	call	__libc_init_array

	/* Platform-level early init hook (e.g. UART bring-up). */
	call	pre_main

	/* Zero argc/argv/envp (the stack is not populated). */
	li	a0, 0
	li	a1, 0
	li	a2, 0

	call	main

	/* Platform-level shutdown hook (e.g. drain UART TX) — a0 holds
	 * main()'s return value, forwarded unchanged to exit().  */
	mv	s0, a0
	call	post_main
	mv	a0, s0
	tail	exit

.size _start, .-_start

.global _init
.type   _init, @function
.global _fini
.type   _fini, @function
_init:
_fini:
	/* We rely on init_array/fini_array; these are placeholders. */
	ret
.size _init, .-_init
.size _fini, .-_fini