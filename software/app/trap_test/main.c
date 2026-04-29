#include <stdio.h>
#include <stdint.h>

static inline long do_ecall(long id) {
  register long a7 asm("a7") = id;
  register long a0 asm("a0");
  asm volatile("ecall"
               : "=r"(a0)
               : "r"(a7)
               : "memory");
  return a0;
}


static inline void do_illegal_32(void) {
  asm volatile(".word 0xffffffff" ::: "memory");
}


static inline void do_illegal_16(void) {
  asm volatile(".2byte 0x0000" ::: "memory");
}


int main(void) {
  printf("=== BSP trap test ===\n");

  /* --- Phase A: ECALL ---------------------------------------------------- */
  printf("[A] issuing ecall (SYS_getpid=172)...\n");
  long ret = do_ecall(172 /* SYS_getpid */);
  printf("[A] returned from ecall, a0 = %ld\n", ret);

  /* --- Phase B: Illegal 32-bit instruction ------------------------------ */
  printf("[B] executing illegal 32-bit insn (.word 0xffffffff)...\n");
  do_illegal_32();
  printf("[B] resumed after illegal 32-bit insn\n");

  /* --- Phase C: Illegal 16-bit compressed instruction ------------------- */
  printf("[C] executing illegal RVC insn  (.2byte 0x0000)...\n");
  do_illegal_16();
  printf("[C] resumed after illegal RVC insn\n");

  printf("=== ALL TRAP TESTS PASSED ===\n");
  return 0;
}
