// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// FPGA (Xilinx) implementation of sram_4096_64.
// Uses Xilinx XPM memory primitives (xpm_memory_spram).
// Maps to BRAM/URAM automatically based on size.
//
// Port-compatible with ARM memory compiler sram_4096_64.
//
// Ports (active-low control signals for ARM compatibility):
//   q[63:0]    : Read data output
//   clk        : Clock
//   cen        : Chip enable, active LOW (0=enable, 1=disable)
//   gwen       : Global write enable, active LOW (0=write, 1=read)
//   a[11:0]    : Address (12-bit for 4096 words)
//   d[63:0]    : Write data input
//   stov       : Strobe override (unused, tie to 0)
//   ema[2:0]   : Extra margin adjust (unused)
//   emaw[1:0]  : Extra margin adjust W (unused)
//   emas       : Extra margin adjust S (unused)
//   ret1n      : Retention mode (unused, tie to 1)

module sram_4096_64 (
  output logic [63:0]  q,
  input  logic         clk,
  input  logic         cen,
  input  logic         gwen,
  input  logic [11:0]  a,
  input  logic [63:0]  d,
  input  logic         stov,
  input  logic [2:0]   ema,
  input  logic [1:0]   emaw,
  input  logic         emas,
  input  logic         ret1n
);

  // Unused signal warnings suppression
  logic unused_stov, unused_ema, unused_emaw, unused_emas, unused_ret1n;
  assign unused_stov  = stov;
  assign unused_ema   = |ema;
  assign unused_emaw  = |emaw;
  assign unused_emas  = emas;
  assign unused_ret1n = ret1n;

  // XPM Single Port RAM configuration
  // gwen = 0 (active low) -> write operation
  // gwen = 1 (active high after inversion) -> read operation

  logic [63:0] dout;
  assign q = dout;

  // Convert ARM control signals to XPM:
  // cen (active low) -> ena (active high)
  // gwen (active low, 0=write, 1=read) -> wea (active high, 1=write)
  logic ena_xpm;
  logic wea_xpm;

  assign ena_xpm = ~cen;      // cen active-low -> ena active-high
  assign wea_xpm = ~gwen;     // gwen=0 (write) -> wea=1 (write)

  xpm_memory_spram #(
    .ADDR_WIDTH_A       (12),              // 4096 words
    .AUTO_SLEEP_TIME    (0),
    .BYTE_WRITE_WIDTH_A (64),              // No byte enable, full word write
    .CASCADE_HEIGHT     (0),
    .ECC_BIT_RANGE      ("7:0"),
    .ECC_MODE           ("no_ecc"),
    .ECC_TYPE           ("none"),
    .IGNORE_INIT_SYNTH  (0),
    .MEMORY_INIT_FILE   ("none"),
    .MEMORY_INIT_PARAM  ("0"),
    .MEMORY_OPTIMIZATION("true"),
    .MEMORY_PRIMITIVE   ("block"),         // Force BRAM, NOT distributed RAM
    .MEMORY_SIZE        (4096 * 64),       // 262144 bits (32KB)
    .MESSAGE_CONTROL    (0),
    .RAM_DECOMP         ("auto"),
    .READ_DATA_WIDTH_A  (64),
    .READ_LATENCY_A     (1),                // 1-cycle read latency (matches ARM macro)
    .READ_RESET_VALUE_A ("0"),
    .RST_MODE_A         ("SYNC"),
    .SIM_ASSERT_CHK     (0),
    .USE_MEM_INIT       (0),
    .USE_MEM_INIT_MMI   (0),
    .WAKEUP_TIME        ("disable_sleep"),
    .WRITE_DATA_WIDTH_A (64),
    .WRITE_MODE_A       ("read_first"),
    .WRITE_PROTECT      (1)
  ) i_xpm_spram (
    .clka           (clk),
    .rsta           (1'b0),               // No reset on FPGA
    .ena            (ena_xpm),             // cen active-low -> ena active-high
    .wea            (wea_xpm),             // gwen active-low (0=write) -> wea active-high (1=write)
    .addra          (a),
    .dina           (d),
    .douta          (dout),
    .regcea         (1'b1),
    .injectsbiterra (1'b0),
    .injectdbiterra (1'b0),
    .sbiterra       (),
    .dbiterra       (),
    .sleep          (1'b0)
  );

endmodule
