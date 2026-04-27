    .section .text.entry
    .globl _start
_start:
    la   sp, _stack_top   

    call main             

1:  j 1b                 

    .section .bss
    .globl _stack_top
    // _stack_top is provided by test_sram.ld
