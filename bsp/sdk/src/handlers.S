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

/* Exception codes */
#define EXCEPTION_ILLEGAL_INSN 2
#define EXCEPTION_BREAKPOINT 3
#define EXCEPTION_ECALL_M 11

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


/* exception handling */
__no_irq_handler:
	la a0, no_exception_handler_msg
	jal ra, puts
	j __no_irq_handler

m_software_irq_handler:
	j __no_irq_handler

m_timer_irq_handler:
	j __no_irq_handler

m_external_irq_handler:
	j __no_irq_handler

m_fast0_irq_handler:
	j __no_irq_handler

m_fast1_irq_handler:
	j __no_irq_handler

m_fast2_irq_handler:
	j __no_irq_handler

m_fast3_irq_handler:
	j __no_irq_handler

m_fast4_irq_handler:
	j __no_irq_handler

m_fast5_irq_handler:
	j __no_irq_handler

m_fast6_irq_handler:
	j __no_irq_handler

m_fast7_irq_handler:
	j __no_irq_handler

m_fast8_irq_handler:
	j __no_irq_handler

m_fast9_irq_handler:
	j __no_irq_handler

m_fast10_irq_handler:
	j __no_irq_handler

m_fast11_irq_handler:
	j __no_irq_handler

m_fast12_irq_handler:
	j __no_irq_handler

m_fast13_irq_handler:
	j __no_irq_handler

m_fast14_irq_handler:
	j __no_irq_handler

m_fast15_irq_handler:
	j __no_irq_handler

u_sw_irq_handler:
	/* While we are still using puts in handlers, save all caller saved
	   regs.  Eventually, some of these saves could be deferred.  */
	addi sp,sp,-128
	sd ra,  0(sp)
	sd a0,  8(sp)
	sd a1, 16(sp)
	sd a2, 24(sp)
	sd a3, 32(sp)
	sd a4, 40(sp)
	sd a5, 48(sp)
	sd a6, 56(sp)
	sd a7, 64(sp)
	sd t0, 72(sp)
	sd t1, 80(sp)
	sd t2, 88(sp)
	sd t3, 96(sp)
	sd t4,104(sp)
	sd t5,112(sp)
	sd t6,120(sp)
	csrr t0, mcause
	li t1, EXCEPTION_ILLEGAL_INSN
	beq t0, t1, handle_illegal_insn
	li t1, EXCEPTION_ECALL_M
	beq t0, t1, handle_ecall
	li t1, EXCEPTION_BREAKPOINT
	beq t0, t1, handle_ebreak
	j handle_unknown

handle_ecall:
	jal ra, handle_syscall
	j end_handler_incr_mepc

handle_ebreak:
	/* TODO support debug handling requirements.  */
	la a0, ebreak_msg
	jal ra, puts
	j end_handler_incr_mepc

handle_illegal_insn:
	la a0, illegal_insn_msg
	jal ra, puts
	j end_handler_incr_mepc

handle_unknown:
	la a0, unknown_msg
	jal ra, puts
	/* We don't know what interrupt/exception is being handled, so don't
	   increment mepc.  */
	j end_handler_ret

end_handler_incr_mepc:
	csrr t0, mepc
	lb t1, 0(t0)
	li a0, 0x3
	and t1, t1, a0
	/* Increment mepc by 2 or 4 depending on whether the instruction at mepc
	   is compressed or not.  */
	bne t1, a0, end_handler_incr_mepc2
	addi t0, t0, 2
end_handler_incr_mepc2:
	addi t0, t0, 2
	csrw mepc, t0
end_handler_ret:
	ld ra,  0(sp)
	ld a0,  8(sp)
	ld a1, 16(sp)
	ld a2, 24(sp)
	ld a3, 32(sp)
	ld a4, 40(sp)
	ld a5, 48(sp)
	ld a6, 56(sp)
	ld a7, 64(sp)
	ld t0, 72(sp)
	ld t1, 80(sp)
	ld t2, 88(sp)
	ld t3, 96(sp)
	ld t4,104(sp)
	ld t5,112(sp)
	ld t6,120(sp)
	addi sp,sp,128
	mret

.section .rodata
illegal_insn_msg:
	.string "BSP: illegal instruction exception handler entered\n"
ecall_msg:
	.string "BSP: ecall exception handler entered\n"
ebreak_msg:
	.string "BSP: ebreak exception handler entered\n"
unknown_msg:
	.string "BSP: unknown exception handler entered\n"
no_exception_handler_msg:
	.string "BSP: no exception handler installed\n"
