/*
* Copyright 2019 ETH Zürich and University of Bologna
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

#include <context.h>

/* Exception codes */
#define EXCEPTION_ILLEGAL_INSN 2
#define EXCEPTION_BREAKPOINT   3
#define EXCEPTION_ECALL_M      11

.section .text.handlers
.global __no_irq_handler
.global u_sw_irq_handler
.global m_software_irq_handler
.global m_timer_irq_handler
.global m_external_irq_handler
.global m_fast0_irq_handler
.global m_fast1_irq_handler
.global m_fast2_irq_handler
.global m_fast3_irq_handler
.global m_fast4_irq_handler
.global m_fast5_irq_handler
.global m_fast6_irq_handler
.global m_fast7_irq_handler
.global m_fast8_irq_handler
.global m_fast9_irq_handler
.global m_fast10_irq_handler
.global m_fast11_irq_handler
.global m_fast12_irq_handler
.global m_fast13_irq_handler
.global m_fast14_irq_handler
.global m_fast15_irq_handler

.weak u_sw_irq_handler
.weak m_software_irq_handler
.weak m_timer_irq_handler
.weak m_external_irq_handler
.weak m_fast0_irq_handler
.weak m_fast1_irq_handler
.weak m_fast2_irq_handler
.weak m_fast3_irq_handler
.weak m_fast4_irq_handler
.weak m_fast5_irq_handler
.weak m_fast6_irq_handler
.weak m_fast7_irq_handler
.weak m_fast8_irq_handler
.weak m_fast9_irq_handler
.weak m_fast10_irq_handler
.weak m_fast11_irq_handler
.weak m_fast12_irq_handler
.weak m_fast13_irq_handler
.weak m_fast14_irq_handler
.weak m_fast15_irq_handler

/* -------------------------------------------------------------------
 * Context save / restore macros.
 *
 *   SAVE_CTX   : allocate CTX_SIZE on the stack, spill x1..x31 (the
 *                saved x2 reflects the pre-trap sp), and snapshot
 *                mcause/mstatus/mepc.  After this, `sp` points at a
 *                trap_context_t suitable for handing to C.
 *   RESTORE_CTX: inverse of SAVE_CTX.  Reloads mstatus/mepc so that
 *                any handler-side modifications (e.g. ctx_advance_mepc)
 *                take effect, then pops the GPRs and deallocates the
 *                frame.
 *
 * Both macros clobber t0 during the CSR save/restore sequence; `t0`
 * is itself part of the saved context, so that is safe.
 * ----------------------------------------------------------------- */
.macro SAVE_CTX
	addi	sp, sp, -CTX_SIZE
	sd	x1,  CTX_GPR_OFF(1)(sp)
	addi	t0, sp, CTX_SIZE
	sd	t0,  CTX_GPR_OFF(2)(sp)          /* original sp */
	sd	x3,  CTX_GPR_OFF(3)(sp)
	sd	x4,  CTX_GPR_OFF(4)(sp)
	sd	x5,  CTX_GPR_OFF(5)(sp)
	sd	x6,  CTX_GPR_OFF(6)(sp)
	sd	x7,  CTX_GPR_OFF(7)(sp)
	sd	x8,  CTX_GPR_OFF(8)(sp)
	sd	x9,  CTX_GPR_OFF(9)(sp)
	sd	x10, CTX_GPR_OFF(10)(sp)
	sd	x11, CTX_GPR_OFF(11)(sp)
	sd	x12, CTX_GPR_OFF(12)(sp)
	sd	x13, CTX_GPR_OFF(13)(sp)
	sd	x14, CTX_GPR_OFF(14)(sp)
	sd	x15, CTX_GPR_OFF(15)(sp)
	sd	x16, CTX_GPR_OFF(16)(sp)
	sd	x17, CTX_GPR_OFF(17)(sp)
	sd	x18, CTX_GPR_OFF(18)(sp)
	sd	x19, CTX_GPR_OFF(19)(sp)
	sd	x20, CTX_GPR_OFF(20)(sp)
	sd	x21, CTX_GPR_OFF(21)(sp)
	sd	x22, CTX_GPR_OFF(22)(sp)
	sd	x23, CTX_GPR_OFF(23)(sp)
	sd	x24, CTX_GPR_OFF(24)(sp)
	sd	x25, CTX_GPR_OFF(25)(sp)
	sd	x26, CTX_GPR_OFF(26)(sp)
	sd	x27, CTX_GPR_OFF(27)(sp)
	sd	x28, CTX_GPR_OFF(28)(sp)
	sd	x29, CTX_GPR_OFF(29)(sp)
	sd	x30, CTX_GPR_OFF(30)(sp)
	sd	x31, CTX_GPR_OFF(31)(sp)

	csrr	t0, mcause
	sd	t0, CTX_MCAUSE_OFF(sp)
	csrr	t0, mstatus
	sd	t0, CTX_MSTATUS_OFF(sp)
	csrr	t0, mepc
	sd	t0, CTX_MEPC_OFF(sp)
.endm

.macro RESTORE_CTX
	ld	t0, CTX_MSTATUS_OFF(sp)
	csrw	mstatus, t0
	ld	t0, CTX_MEPC_OFF(sp)
	csrw	mepc, t0

	ld	x1,  CTX_GPR_OFF(1)(sp)
	/* x2 (sp) restored implicitly by the final addi below */
	ld	x3,  CTX_GPR_OFF(3)(sp)
	ld	x4,  CTX_GPR_OFF(4)(sp)
	ld	x5,  CTX_GPR_OFF(5)(sp)
	ld	x6,  CTX_GPR_OFF(6)(sp)
	ld	x7,  CTX_GPR_OFF(7)(sp)
	ld	x8,  CTX_GPR_OFF(8)(sp)
	ld	x9,  CTX_GPR_OFF(9)(sp)
	ld	x10, CTX_GPR_OFF(10)(sp)
	ld	x11, CTX_GPR_OFF(11)(sp)
	ld	x12, CTX_GPR_OFF(12)(sp)
	ld	x13, CTX_GPR_OFF(13)(sp)
	ld	x14, CTX_GPR_OFF(14)(sp)
	ld	x15, CTX_GPR_OFF(15)(sp)
	ld	x16, CTX_GPR_OFF(16)(sp)
	ld	x17, CTX_GPR_OFF(17)(sp)
	ld	x18, CTX_GPR_OFF(18)(sp)
	ld	x19, CTX_GPR_OFF(19)(sp)
	ld	x20, CTX_GPR_OFF(20)(sp)
	ld	x21, CTX_GPR_OFF(21)(sp)
	ld	x22, CTX_GPR_OFF(22)(sp)
	ld	x23, CTX_GPR_OFF(23)(sp)
	ld	x24, CTX_GPR_OFF(24)(sp)
	ld	x25, CTX_GPR_OFF(25)(sp)
	ld	x26, CTX_GPR_OFF(26)(sp)
	ld	x27, CTX_GPR_OFF(27)(sp)
	ld	x28, CTX_GPR_OFF(28)(sp)
	ld	x29, CTX_GPR_OFF(29)(sp)
	ld	x30, CTX_GPR_OFF(30)(sp)
	ld	x31, CTX_GPR_OFF(31)(sp)
	addi	sp, sp, CTX_SIZE
.endm


/* ----------------------------------------------------------------- */
/* Default "no handler" fall-through                                   */
/* ----------------------------------------------------------------- */
__no_irq_handler:
	la a0, no_exception_handler_msg
	jal ra, puts
	j __no_irq_handler

m_software_irq_handler:
	SAVE_CTX
	call	clint_handle_m_sw_irq
	RESTORE_CTX
	mret

m_timer_irq_handler:
	SAVE_CTX
	call	clint_handle_m_timer_irq
	RESTORE_CTX
	mret



m_fast0_irq_handler:     j __no_irq_handler
m_fast1_irq_handler:     j __no_irq_handler
m_fast2_irq_handler:     j __no_irq_handler
m_fast3_irq_handler:     j __no_irq_handler
m_fast4_irq_handler:     j __no_irq_handler
m_fast5_irq_handler:     j __no_irq_handler
m_fast6_irq_handler:     j __no_irq_handler
m_fast7_irq_handler:     j __no_irq_handler
m_fast8_irq_handler:     j __no_irq_handler
m_fast9_irq_handler:     j __no_irq_handler
m_fast10_irq_handler:    j __no_irq_handler
m_fast11_irq_handler:    j __no_irq_handler
m_fast12_irq_handler:    j __no_irq_handler
m_fast13_irq_handler:    j __no_irq_handler
m_fast14_irq_handler:    j __no_irq_handler
m_fast15_irq_handler:    j __no_irq_handler


/* -------------------------------------------------------------------
 * Synchronous trap handler (exceptions): ECALL, EBREAK, illegal insn …
 * ----------------------------------------------------------------- */
u_sw_irq_handler:
	SAVE_CTX

	mv	a0, sp
	ld	t0, CTX_MCAUSE_OFF(sp)
	li	t1, EXCEPTION_ILLEGAL_INSN
	beq	t0, t1, handle_illegal_insn
	li	t1, EXCEPTION_ECALL_M
	beq	t0, t1, handle_ecall
	li	t1, EXCEPTION_BREAKPOINT
	beq	t0, t1, handle_ebreak
	j	handle_unknown

handle_ecall:
	call	handle_syscall
	mv	a0, sp
	call	ctx_advance_mepc
	j	end_handler_ret

handle_ebreak:
	la	a0, ebreak_msg
	call	puts
	mv	a0, sp
	call	ctx_advance_mepc
	j	end_handler_ret

handle_illegal_insn:
	la	a0, illegal_insn_msg
	call	puts
	mv	a0, sp
	call	ctx_advance_mepc
	j	end_handler_ret

handle_unknown:
	la	a0, unknown_msg
	call	puts
	j	end_handler_ret

end_handler_ret:
	RESTORE_CTX
	mret


/* -------------------------------------------------------------------
 * Asynchronous: Machine External Interrupt (cause = 0x8000_000B).
 *
 * In vectored mtvec mode hardware jumped directly here with MIE
 * already cleared; `mret` will restore MIE from MPIE.  We do NOT
 * advance mepc — execution resumes at the interrupted instruction.
 * ----------------------------------------------------------------- */
m_external_irq_handler:
	SAVE_CTX
	call	plic_handle_m_ext_irq
	RESTORE_CTX
	mret


.section .rodata
illegal_insn_msg:
	.string "BSP: illegal instruction exception handler entered\n"
ebreak_msg:
	.string "BSP: ebreak exception handler entered\n"
unknown_msg:
	.string "BSP: unknown exception handler entered\n"
no_exception_handler_msg:
	.string "BSP: no exception handler installed\n"
