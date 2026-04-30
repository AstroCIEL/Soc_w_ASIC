// Utility helpers for the Ara SoC BSP:
//   * cycle-counter based timer (start/stop/get_timer, get_cycle_count)
//   * floating-point similarity checks

#ifndef __UTIL_H__
#define __UTIL_H__

#include <stdint.h>

/* ------------------------------------------------------------------ */
/* Cycle-counter timer                                                 */
/* ------------------------------------------------------------------ */
/* Defined in util.c; backs start/stop/get_timer(). */
extern unsigned long int timer;

/* Sample mcycle.  The leading fence drains in-flight Ara vector stores
 * so stop_timer() sees a consistent view of the pipeline. */
static inline int64_t get_cycle_count(void)
{
    int64_t c;
    asm volatile("fence; csrr %[c], cycle" : [c] "=r"(c));
    return c;
}

static inline void    start_timer(void) { timer  = -get_cycle_count(); }
static inline void    stop_timer (void) { timer +=  get_cycle_count(); }
static inline int64_t get_timer  (void) { return (int64_t)timer; }

/* ------------------------------------------------------------------ */
/* Floating-point helpers                                              */
/* ------------------------------------------------------------------ */
int similarity_check    (double a, double b, double threshold);
int similarity_check_32b(float  a, float  b, float  threshold);

#endif /* __UTIL_H__ */
