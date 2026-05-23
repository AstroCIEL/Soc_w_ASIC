// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// FPGA (Xilinx) implementation of rf2p_256_128.
// Uses Xilinx XPM memory primitives (xpm_memory_tdpram).
// Maps to BRAM automatically based on size.
//
// Port-compatible with ARM memory compiler rf2p_256_128.
//
// Ports (active-low control signals for ARM compatibility):
//   qa[127:0]   : Read data output (Port A)
//   clka        : Read clock (Port A)
//   cena        : Read enable, active LOW (0=enable read, 1=disable)
//   aa[7:0]     : Read address (Port A, 8-bit for 256 words)
//   clkb        : Write clock (Port B)
//   cenb        : Write enable, active LOW (0=enable write port, 1=disable)
//   wenb[127:0] : Per-bit write mask, active LOW (0=write this bit, 1=mask/preserve)
//   ab[7:0]     : Write address (Port B, 8-bit for 256 words)
//   db[127:0]   : Write data input (Port B)
//   stov        : Strobe override (unused, tie to 0)
//   emaa[2:0]   : Extra margin adjust A (unused)
//   emasa       : Extra margin adjust SA (unused)
//   emab[2:0]   : Extra margin adjust B (unused)
//   ret1n       : Retention mode (unused, tie to 1)

module rf2p_256_128 (
  output logic [127:0] qa,
  input  logic         clka,
  input  logic         cena,
  input  logic [7:0]   aa,
  input  logic         clkb,
  input  logic         cenb,
  input  logic [127:0] wenb,
  input  logic [7:0]   ab,
  input  logic [127:0] db,
  input  logic         stov,
  input  logic [2:0]   emaa,
  input  logic         emasa,
  input  logic [2:0]   emab,
  input  logic         ret1n
);

  // Unused signal warnings suppression
  logic unused_stov, unused_emaa, unused_emasa, unused_emab, unused_ret1n;
  assign unused_stov  = stov;
  assign unused_emaa  = |emaa;
  assign unused_emasa = emasa;
  assign unused_emab  = |emab;
  assign unused_ret1n = ret1n;

  // XPM True Dual Port RAM configuration
  // Port A: Read-only (wea=0)
  // Port B: Write-only with per-byte enable
  // wenb is per-bit active-low, need to convert to XPM's per-byte active-high web

  // wenb is 128-bit, each bit controls one bit position
  // XPM expects 16 byte-enables (128/8 = 16)
  logic [15:0] web_xpm;  // XPM byte write enable, active high

  // Convert per-bit active-low wenb to per-byte active-high web
  // If all 8 bits in a byte are 0 (not masked), enable that byte for write
  genvar i;
  generate
    for (i = 0; i < 16; i++) begin : gen_wenb_to_web
      // wenb[i*8 +: 8] = 8'b0 means all bits enabled for write -> web=1
      assign web_xpm[i] = (wenb[i*8 +: 8] == 8'h00);
    end
  endgenerate

  // Read port output
  logic [127:0] douta;
  assign qa = douta;

  xpm_memory_tdpram #(
    .ADDR_WIDTH_A       (8),               // 256 words
    .ADDR_WIDTH_B       (8),
    .AUTO_SLEEP_TIME    (0),
    .BYTE_WRITE_WIDTH_A (8),               // Byte-wise write
    .BYTE_WRITE_WIDTH_B (8),               // 16 bytes = 128 bits
    .CASCADE_HEIGHT     (0),
    .CLOCKING_MODE      ("independent_clock"),  // Separate clocks for A and B
    .ECC_BIT_RANGE      ("7:0"),
    .ECC_MODE           ("no_ecc"),
    .ECC_TYPE           ("none"),
    .IGNORE_INIT_SYNTH  (0),
    .MEMORY_INIT_FILE   ("none"),
    .MEMORY_INIT_PARAM  ("0"),
    .MEMORY_OPTIMIZATION("true"),
    .MEMORY_PRIMITIVE   ("block"),         // Force BRAM, NOT distributed RAM
    .MEMORY_SIZE        (256 * 128),       // 32768 bits (4KB)
    .MESSAGE_CONTROL    (0),
    .READ_DATA_WIDTH_A  (128),
    .READ_DATA_WIDTH_B  (128),
    .READ_LATENCY_A     (1),                // 1-cycle read latency (matches ARM macro)
    .READ_LATENCY_B     (1),
    .READ_RESET_VALUE_A ("0"),
    .READ_RESET_VALUE_B ("0"),
    .RST_MODE_A         ("SYNC"),
    .RST_MODE_B         ("SYNC"),
    .SIM_ASSERT_CHK     (0),
    .USE_MEM_INIT       (0),
    .USE_MEM_INIT_MMI   (0),
    .WAKEUP_TIME        ("disable_sleep"),
    .WRITE_DATA_WIDTH_A (128),
    .WRITE_DATA_WIDTH_B (128),
    .WRITE_MODE_A       ("read_first"),
    .WRITE_MODE_B       ("read_first"),
    .WRITE_PROTECT      (1)
  ) i_xpm_tdpram (
    // Port A: Read only (clka/cena)
    .clka           (clka),
    .rsta           (1'b0),               // No reset on FPGA
    .ena            (~cena),              // cena active-low -> ena active-high
    .regcea         (1'b1),
    .wea            (16'h0000),           // Disable writes on port A
    .addra          (aa),
    .dina           (128'h0),             // Don't care for read-only
    .douta          (douta),
    .injectdbiterra (1'b0),
    .injectsbiterra (1'b0),
    .dbiterra       (),
    .sbiterra       (),

    // Port B: Write only (clkb/cenb/wenb)
    .clkb           (clkb),
    .rstb           (1'b0),               // No reset on FPGA
    .enb            (~cenb),              // cenb active-low -> enb active-high
    .regceb         (1'b1),
    .web            (web_xpm),            // Byte-wise write enable (active high)
    .addrb          (ab),
    .dinb           (db),
    .doutb          (),                    // Not used for write-only port
    .injectdbiterrb (1'b0),
    .injectsbiterrb (1'b0),
    .dbiterrb       (),
    .sbiterrb       (),

    .sleep          (1'b0)
  );

endmodule
