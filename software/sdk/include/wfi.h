#ifndef _WFI_H
#define _WFI_H

#include "encoding.h"

#define WFI_WAIT(cond) do {                                     \
    while (!(cond)) {                                           \
        asm volatile("csrc mstatus, %0" :: "r"(MSTATUS_MIE));  \
        if (!(cond)) {                                          \
            asm volatile("wfi");                                \
        }                                                       \
        asm volatile("csrs mstatus, %0" :: "r"(MSTATUS_MIE));  \
    }                                                           \
} while (0)

#endif /* _WFI_H */
