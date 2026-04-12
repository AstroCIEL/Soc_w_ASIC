// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Matheus Cavalcante <matheusd@iis.ee.ethz.ch>
// Date: 21/10/2020
// Description: Top level testbench module for Verilator.

module ara_tb_verilator #(
    parameter int unsigned NrLanes = 0,
    parameter int unsigned VLEN    = 0
  )(
    input  logic        clk_i,
    input  logic        rst_ni,
    output logic [31:0] exit_o
  );

  /*****************
   *  Definitions  *
   *****************/

  localparam NUM_WORDS = 2**18;

  // RTC clock generation
  logic rtc_i;
  initial begin
    forever begin
      rtc_i = 1'b0;
      #(15258ns) rtc_i = 1'b1; // ~30.517us / 2
      #(15258ns) rtc_i = 1'b0;
    end
  end

  /*********
   *  DUT  *
   *********/

  ariane_testharness #(
    .NrLanes           ( NrLanes   ),
    .VLEN              ( VLEN      ),
    .NUM_WORDS         ( NUM_WORDS ),
    .StallRandomOutput ( 1'b0      ),
    .StallRandomInput  ( 1'b0      )
  ) dut (
    .clk_i  (clk_i ),
    .rtc_i  (rtc_i ),
    .rst_ni (rst_ni),
    .exit_o (exit_o)
  );

  /*********
   *  EOC  *
   *********/

  always @(posedge clk_i) begin
    if (exit_o[0]) begin
      if (exit_o >> 1) begin
        $error("Core Test: *** FAILED *** (tohost = %0d)", (exit_o >> 1));
      end else begin
        $display("Core Test: *** SUCCESS *** (tohost = %0d)", (exit_o >> 1));
      end
      #50000;
      $finish(exit_o >> 1);
    end
  end

endmodule : ara_tb_verilator
