/* Minimal LLD-compatible linker script for the Ara SoC BSP. */

OUTPUT_ARCH("riscv")
ENTRY(_start)

MEMORY {
  ram : ORIGIN = 0x80000000, LENGTH = 0x00020000
}

/* Ara's TB requires sections aligned to a AxiWideBeWidth (16B) boundary. */
SECTIONS {
  .text : {
    KEEP(*(.text.start))
    PROVIDE(__vector_start = .);
    KEEP(*(.vectors))
    *(.text.init)
    *(.text)
    *(.text.*)
  } > ram

  .rodata  : ALIGN(16) { *(.rodata .rodata.* .gnu.linkonce.r.*) } > ram
  .rodata1 : ALIGN(16) { *(.rodata1) } > ram
  .sdata2  : ALIGN(16) { *(.sdata2 .sdata2.* .gnu.linkonce.s2.*) } > ram

  /* Keep all relro sections contiguous (lld requirement). */
  .init_array : ALIGN(16) {
    PROVIDE_HIDDEN(__init_array_start = .);
    KEEP(*(SORT_BY_INIT_PRIORITY(.init_array.*)))
    KEEP(*(.init_array))
    PROVIDE_HIDDEN(__init_array_end = .);
  } > ram

  .fini_array : ALIGN(16) {
    PROVIDE_HIDDEN(__fini_array_start = .);
    KEEP(*(SORT_BY_INIT_PRIORITY(.fini_array.*)))
    KEEP(*(.fini_array))
    PROVIDE_HIDDEN(__fini_array_end = .);
  } > ram

  .got : ALIGN(16) { *(.got.plt) *(.igot.plt) *(.got) *(.igot) } > ram

  .data : ALIGN(16) {
    *(.data)
    *(.data.*)
  } > ram

  .sdata : ALIGN(16) {
    __global_pointer$ = . + 0x800;
    *(.srodata.cst16) *(.srodata.cst8) *(.srodata.cst4) *(.srodata.cst2)
    *(.srodata .srodata.*)
    *(.sdata .sdata.* .gnu.linkonce.s.*)
  } > ram

  .bss : ALIGN(16) {
    __bss_start = .;
    *(.bss)
    *(.bss.*)
    *(.sbss .sbss.* .sbss2 .sbss2.* .gnu.linkonce.sb2.*)
    *(COMMON)
    . = ALIGN(16);
    __bss_end = .;
  } > ram

  . = ALIGN(16);
  __heap_start = .;
  __heap_end   = ORIGIN(ram) + LENGTH(ram) - 0x1000;
  __stack_end  = ORIGIN(ram) + LENGTH(ram);

  .comment 0 : { *(.comment) }
}
