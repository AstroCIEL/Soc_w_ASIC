#ifndef _CONTEXT_H_
#define _CONTEXT_H_

#define REG_RA    1
#define REG_SP    2
#define REG_GP    3
#define REG_TP    4
#define REG_T0    5
#define REG_T1    6
#define REG_T2    7
#define REG_S0    8
#define REG_S1    9
#define REG_A0    10
#define REG_A1    11
#define REG_A2    12
#define REG_A3    13
#define REG_A4    14
#define REG_A5    15
#define REG_A6    16
#define REG_A7    17

#define CTX_GPR_OFF(i)  ((i) * 8)
#define CTX_MCAUSE_OFF  (32 * 8 +  0)
#define CTX_MSTATUS_OFF (32 * 8 +  8)
#define CTX_MEPC_OFF    (32 * 8 + 16)
#define CTX_SIZE        (32 * 8 + 32)

#ifndef __ASSEMBLER__

#include <stdint.h>

typedef struct trap_context {
    uint64_t gpr[32];
    uint64_t mcause;
    uint64_t mstatus;
    uint64_t mepc;
    uint64_t _pad;
} trap_context_t;

_Static_assert(sizeof(trap_context_t) == CTX_SIZE,
               "trap_context_t layout must match handlers.S offsets");

#endif

#endif
