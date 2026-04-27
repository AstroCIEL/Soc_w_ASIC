    .section .text.entry
    .globl _start
_start:
    la   sp, __stack_top   

    call main             

.Lhang:
    wfi
    j    .Lhang

    

     .section .bss.stack, "aw", @nobits
    .align 12                  /* 2^12 = 4096-byte align */

    .globl __stack_bottom
__stack_bottom:
    .space 0x1000              /* 4 KB stack */

    .globl __stack_top
__stack_top:

