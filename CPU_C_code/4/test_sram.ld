/* 适配 boot_addr_i=ROMBase：CPU 从 ROM 启动，bootrom 跳 0x8000_0000；
   程序整体链接在 RAM，TB 将 hex 载入 主存SRAM 后从 0x8000_0000 执行 */
MEMORY
{
  RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 8K
}

SECTIONS
{
  /DISCARD/ : {
    *(.note.gnu.build-id)
    *(.note*)
  }

  .text : {
    *(.text.entry)
    *(.text*)
    *(.rodata*)
  } > RAM

  .data : {
    *(.data*)
    *(.sdata*)
  } > RAM

  .bss (NOLOAD) : {
    __bss_start = .;
    *(.bss*)
    *(.sbss*)
    *(COMMON)
    __bss_end = .;
  } > RAM
}
