// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Synthesis wrapper for tc_sram.
// Routes each (NumWords, DataWidth) shape to the corresponding SRAM macro.
// Unknown shapes trigger an elaboration-time $fatal.
//
// Known shapes (from sram.txt):
//    16384 ×  64  — L2 main memory (128 kB, AXI_DATA_WIDTH=64b / NrLanes=2)
//       64 × 256  — D$ data bank
//       64 × 128  — I$ data
//       64 ×  64  — Ara VRF bank
//       64 ×  47  — I$ tag
//       64 ×  46  — D$ tag

module tc_sram #(
  parameter int unsigned NumWords     = 32'd1024,
  parameter int unsigned DataWidth    = 32'd128,
  parameter int unsigned ByteWidth    = 32'd8,
  parameter int unsigned NumPorts     = 32'd2,
  parameter int unsigned Latency      = 32'd1,
  parameter              SimInit      = "none",
  parameter bit          PrintSimCfg  = 1'b0,
  parameter              ImplKey      = "none",
  // DEPENDENT PARAMETERS, DO NOT OVERWRITE!
  parameter int unsigned AddrWidth = (NumWords > 32'd1) ? $clog2(NumWords) : 32'd1,
  parameter int unsigned BeWidth   = (DataWidth + ByteWidth - 32'd1) / ByteWidth,
  parameter type         addr_t    = logic [AddrWidth-1:0],
  parameter type         data_t    = logic [DataWidth-1:0],
  parameter type         be_t      = logic [BeWidth-1:0]
) (
  input  logic                 clk_i,
  input  logic                 rst_ni,
  input  logic  [NumPorts-1:0] req_i,
  input  logic  [NumPorts-1:0] we_i,
  input  addr_t [NumPorts-1:0] addr_i,
  input  data_t [NumPorts-1:0] wdata_i,
  input  be_t   [NumPorts-1:0] be_i,
  output data_t [NumPorts-1:0] rdata_o
);

  // All known macros are single-port, latency-1
  if (NumPorts != 1) begin : gen_err_ports
    $fatal(1, "tc_sram_syn: NumPorts=%0d not supported (only 1-port macros available)", NumPorts);
  end
  if (Latency != 1) begin : gen_err_latency
    $fatal(1, "tc_sram_syn: Latency=%0d not supported (only latency-1 macros available)", Latency);
  end

  // ── Shape dispatch ───────────────────────────────────────────────────────
  if (NumWords == 16384 && DataWidth == 64) begin : gen_l2_mem
    // L2 main memory — 16384 × 64b  (128 kB, AXI_DATA_WIDTH=64b / NrLanes=2)
    // TODO: instantiate real macro here
    // sram_16384x64 i_macro (
    //   .CLK   (clk_i        ),
    //   .CEN   (~req_i[0]    ),
    //   .WEN   (~we_i[0]     ),
    //   .A     (addr_i[0]    ),
    //   .D     (wdata_i[0]   ),
    //   .Q     (rdata_o[0]   ),
    //   .BEN   (~be_i[0]     )
    // );
    assign rdata_o[0] = '0;

  end else if (NumWords == 64 && DataWidth == 256) begin : gen_dcache_data
    // D$ data bank — 64 × 256b
    // TODO: instantiate real macro here
    assign rdata_o[0] = '0;

  end else if (NumWords == 64 && DataWidth == 128) begin : gen_icache_data
    // I$ data — 64 × 128b
    // TODO: instantiate real macro here
    assign rdata_o[0] = '0;

  end else if (NumWords == 64 && DataWidth == 64) begin : gen_vrf
    // Ara VRF bank — 64 × 64b
    // TODO: instantiate real macro here
    assign rdata_o[0] = '0;

  end else if (NumWords == 64 && DataWidth == 47) begin : gen_icache_tag
    // I$ tag — 64 × 47b
    // TODO: instantiate real macro here
    assign rdata_o[0] = '0;

  end else if (NumWords == 64 && DataWidth == 46) begin : gen_dcache_tag
    // D$ tag — 64 × 46b
    // TODO: instantiate real macro here
    assign rdata_o[0] = '0;

  end else begin : gen_err_shape
    $fatal(1, "tc_sram_syn: unsupported shape NumWords=%0d DataWidth=%0d — add a new macro branch",
           NumWords, DataWidth);
  end

endmodule
