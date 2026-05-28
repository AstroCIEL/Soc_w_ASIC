#ifndef GLOBAL_BUFFER_H
#define GLOBAL_BUFFER_H

#include <stdint.h>
#include "soc.h"

/* minimum_my_mxu_axu: one 4096x64 global_buffer bank @ GlobalBufferBase. */
#define GLOBAL_BUFFER_BASE       0x70040000UL
#define GLOBAL_BUFFER_SIZE       0x8000UL
#define GLOBAL_BUFFER_NUM_BANKS  1u
#define GLOBAL_BUFFER_BANK_WORDS 4096u
#define GLOBAL_BUFFER_WORD_BYTES 8u

static inline uintptr_t global_buffer_word_addr(unsigned word_idx)
{
    return (uintptr_t)GLOBAL_BUFFER_BASE
         + ((uintptr_t)(word_idx % GLOBAL_BUFFER_BANK_WORDS) * GLOBAL_BUFFER_WORD_BYTES);
}

#endif /* GLOBAL_BUFFER_H */
