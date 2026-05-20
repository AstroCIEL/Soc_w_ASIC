// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// L2 main memory wrapper — single-port SRAM with byte-enable.
// Provides a clean boundary between SoC integration and the
// technology-dependent tc_sram implementation.

module l2_mem_wrapper #(
  parameter int unsigned NumWords  = 0,
  parameter int unsigned DataWidth = 0,
  parameter              SimInit   = "random",
  // Dependent parameters
  localparam int unsigned AddrWidth = (NumWords > 1) ? $clog2(NumWords) : 1,
  localparam int unsigned BeWidth   = (DataWidth + 7) / 8
) (
  input  logic                  clk_i,
  input  logic                  rst_ni,
  input  logic                  req_i,
  input  logic                  we_i,
  input  logic [AddrWidth-1:0]  addr_i,
  input  logic [DataWidth-1:0]  wdata_i,
  input  logic [BeWidth-1:0]    be_i,
  output logic [DataWidth-1:0]  rdata_o
);

  tc_sram_wrapper #(
    .NumWords (NumWords ),
    .NumPorts (1        ),
    .DataWidth(DataWidth),
    .SimInit  (SimInit  )
  ) i_tc_sram_wrapper (
    .clk_i  (clk_i  ),
    .rst_ni (rst_ni ),
    .req_i  (req_i  ),
    .we_i   (we_i   ),
    .addr_i (addr_i ),
    .wdata_i(wdata_i),
    .be_i   (be_i   ),
    .rdata_o(rdata_o)
  );

endmodule
