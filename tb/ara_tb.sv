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

module ara_tb;

  /*****************
   *  Definitions  *
   *****************/

  `ifndef VERILATOR
  timeunit      1ns;
  timeprecision 1ps;
  `endif

  `ifdef NR_LANES
  localparam NrLanes = `NR_LANES;
  `else
  localparam NrLanes = 0;
  `endif

  `ifdef VLEN
  localparam VLEN = `VLEN;
  `else
  localparam VLEN = 0;
  `endif

  localparam ClockPeriod       = 2ns;
  localparam RTC_CLOCK_PERIOD  = 30.517us;

  localparam NUM_WORDS         = 2**18;
  localparam AXI_DATA_WIDTH    = 64;
  localparam AXI_DATA_BYTES    = AXI_DATA_WIDTH / 8;

  /********************************
   *  Clock and Reset Generation  *
   ********************************/

  logic clk;
  logic rst_n;
  logic rtc;

  // Controlling the reset
  initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    repeat(8)
      #(ClockPeriod/2) clk = ~clk;
    rst_n = 1'b1;
    forever #(ClockPeriod/2) clk = ~clk;
  end

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

  ariane_testharness #(
    .NrLanes           ( NrLanes   ),
    .VLEN              ( VLEN      ),
    .NUM_WORDS         ( NUM_WORDS )
  ) dut (
    .clk_i    (clk     ),
    .rtc_i    (rtc     ),
    .rst_ni   (rst_n   ),
    .uart_rx_i(uart_rx ),
    .uart_tx_o(uart_tx ),
    .exit_o   (exit    )
  );

  // uart_bus #(.BAUD_RATE(6250000), .PARITY_EN(0)) i_uart_bus (.rx(uart_tx), .tx(uart_rx), .rx_en(1'b1));
  uartdpi #(
    .BAUD('d6250000),             // 500 MHz / (16*5) = 6.25 Mbaud; divisor=5 exact
    .FREQ('d500_000_000),  // Hz
    .NAME("uart0")
  ) i_uart0 (
      .clk_i  (clk  ),   
      .rst_ni (rst_n),    
      .tx_o   (uart_rx),  // DPI → SoC rx
      .rx_i   (uart_tx)   // SoC tx → DPI
  );



  /*************************
   *  DRAM Initialization  *
   *************************/

  `define MAIN_MEM(P) dut.i_sram.i_tc_sram_wrapper.i_tc_sram.init_val[(``P``)]

  initial begin : dram_init
    automatic logic [7:0][7:0] mem_row;
    longint address, load_address, last_load_address, len;
    byte buffer[];
    string binary;

    // Wait for clock
    repeat (2) #ClockPeriod;

    // Initialize memories
    void'($value$plusargs("PRELOAD=%s", binary));
    if (binary != "") begin
      read_elf(binary);
      $display("Loading ELF file %s", binary);
      wait(clk);

      last_load_address = 'hFFFFFFFF;
      while (get_section(address, len)) begin
        automatic int num_words = (len+7)/8;
        $display("Loading section %x of length %x", address, len);
        buffer = new [num_words*8];
        void'(read_section(address, buffer));
        for (int i = 0; i < num_words; i++) begin
          mem_row = '0;
          for (int j = 0; j < 8; j++) begin
            mem_row[j] = buffer[i*8 + j];
          end
          load_address = (address[23:0] >> 3) + i;
          if (load_address != last_load_address) begin
            `MAIN_MEM(load_address) = mem_row;
            last_load_address = load_address;
          end
        end
      end
    end else begin
      $error("Expecting a firmware to run, none was provided!");
      $finish;
    end
  end : dram_init

  /*********
   *  EOC  *
   *********/

  always @(posedge clk) begin
    if (exit[0]) begin
      if (exit >> 1) begin
        $error("Core Test: *** FAILED *** (tohost = %0d)", (exit >> 1));
      end else begin
        $display("Core Test: *** SUCCESS *** (tohost = %0d)", (exit >> 1));
      end
      #5000
      $finish(exit >> 1);
    end
  end

  initial begin
    $fsdbDumpfile("waveform.fsdb");
    $fsdbDumpvars(0, dut, "+all");
  end

endmodule : ara_tb
