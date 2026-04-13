// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Author: Matheus Cavalcante <matheusd@iis.ee.ethz.ch>
// Description:
// Top level testbench module.

import "DPI-C" function void read_elf (input string filename);
import "DPI-C" function byte get_section (output longint address, output longint len);
import "DPI-C" context function byte read_section(input longint address, inout byte buffer[]);

`define STRINGIFY(x) `"x`"

module ara_tb_verilator #(
    parameter int unsigned NrLanes = 2,
    parameter int unsigned VLEN    = 2048
)(
    input  logic        clk_i,
    input  logic        rst_ni,
    output logic [63:0] exit_o
);



  localparam RTC_CLOCK_PERIOD  = 30.517us;

  localparam AXI_DATA_WIDTH    = 64;
  localparam AXI_DATA_BYTES    = AXI_DATA_WIDTH / 8;

  /********************************
   *  Clock and Reset Generation  *
   ********************************/

  logic rtc;  
  // RTC clock
  initial begin
    forever begin
      rtc = 1'b0;
      #(RTC_CLOCK_PERIOD/2) rtc = 1'b1;
      #(RTC_CLOCK_PERIOD/2) rtc = 1'b0;
    end
  end

  /*********
   *  DUT  *
   *********/

  logic [31:0] exit;
  logic uart_rx, uart_tx;

  // ── JTAG signals ──────────────────────────────────────────────────────────
  logic        jtag_tck, jtag_tms, jtag_tdi, jtag_trst_n;
  logic        jtag_tdo, jtag_tdo_driven;
  logic        jtag_enable;
  logic        debug_enable;
  logic [31:0] jtag_exit;
  logic        init_done;

  assign init_done = rst_ni;

  // Read simulation plusargs
  initial begin
    if (!$value$plusargs("jtag_rbb_enable=%b", jtag_enable)) jtag_enable = 1'b0;
    if ($test$plusargs("debug_disable")) debug_enable = 1'b0; else debug_enable = 1'b1;
  end

  ariane_soc_top #(
    .NrLanes           ( NrLanes   ),
    .VLEN              ( VLEN      )
  ) dut (
    .clk_i            ( clk_i          ),
    .rtc_i            ( rtc            ),
    .rst_ni           ( rst_ni         ),
    .uart_rx_i        ( uart_rx        ),
    .uart_tx_o        ( uart_tx        ),
    .exit_o           ( exit           ),
    .jtag_tck_i       ( jtag_tck       ),
    .jtag_tms_i       ( jtag_tms       ),
    .jtag_tdi_i       ( jtag_tdi       ),
    .jtag_trst_ni     ( jtag_trst_n    ),
    .jtag_tdo_o       ( jtag_tdo       ),
    .jtag_tdo_driven_o( jtag_tdo_driven),
    .debug_enable_i   ( debug_enable   )
  );

  // SiFive's SimJTAG – converts remote bitbang to JTAG pins
  SimJTAG i_SimJTAG (
    .clock           ( clk_i          ),
    .reset           ( ~rst_ni        ),
    .enable          ( jtag_enable    ),
    .init_done       ( init_done      ),
    .jtag_TCK        ( jtag_tck       ),
    .jtag_TMS        ( jtag_tms       ),
    .jtag_TDI        ( jtag_tdi       ),
    .jtag_TRSTn      ( jtag_trst_n    ),
    .jtag_TDO_data   ( jtag_tdo       ),
    .jtag_TDO_driven ( jtag_tdo_driven),
    .exit            ( jtag_exit      )
  );

  // uart_bus #(.BAUD_RATE(6250000), .PARITY_EN(0)) i_uart_bus (.rx(uart_tx), .tx(uart_rx), .rx_en(1'b1));
  uartdpi #(
    .BAUD('d6250000),             // 500 MHz / (16*5) = 6.25 Mbaud; divisor=5 exact
    .FREQ('d500_000_000),  // Hz
    .NAME("uart0")
  ) i_uart0 (
      .clk_i  (clk_i  ),   
      .rst_ni (rst_ni ),    
      .tx_o   (uart_rx),  // DPI → SoC rx
      .rx_i   (uart_tx)   // SoC tx → DPI
  );


  /*********
   *  EOC  *
   *********/

  always @(posedge clk_i) begin
    if (exit[0]) begin
      if (|exit[31:1]) begin
        $error("Core Test: *** FAILED *** (tohost = %0d)", (exit >> 1));
      end else begin
        $display("Core Test: *** SUCCESS *** (tohost = %0d)", (exit >> 1));
      end
      $finish(exit[31:1]);
    end
  end



endmodule : ara_tb_verilator
