// Copyright 2021 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Testbench for io_top — minimum_dco SoC wrapped with IO pads.
// cd sim
// make vcs FILELIST=filelist_minimum_my_mxu_axu_dco_io.f VCS_TOP=io_top_tb
// make vcs-run FILELIST=filelist_minimum_my_mxu_axu_dco_io.f VCS_TOP=io_top_tb app=../software/build/bin/hello_world

import "DPI-C" function void read_elf (input string filename);
import "DPI-C" function byte get_section (output longint address, output longint len);
import "DPI-C" context function byte read_section(input longint address, inout byte buffer[]);

// `ifdef WITH_IO_PAD
//   `define SOC_HIER dut.u_ariane_soc_top
// `else
//   `define SOC_HIER dut
// `endif

  `define SOC_HIER dut.u_ariane_soc_top

module io_top_tb;

  `ifndef VERILATOR
  timeunit      1ns;
  timeprecision 1ps;
  `endif

  localparam ClockPeriod      = 2ns;

  // Safe-boot DCO configuration (matches dco_wrapper defaults)
  localparam logic       DcoEn      = 1'b1;
  localparam logic [5:0] DcoCcSel    = 6'd16;
  localparam logic [5:0] DcoFcSel    = 6'd0;
  localparam logic       DcoClkSel   = 1'b1; // ext_clk bypass for deterministic sim
  localparam logic [1:0] DcoFreqSel  = 2'b00;

  logic        dco_ext_clk;
  logic        rst_n;
  wire         sys_clk;

  logic        dco_en;
  logic [5:0]  dco_cc_sel;
  logic [5:0]  dco_fc_sel;
  logic        dco_clk_sel;
  logic [1:0]  dco_freq_sel;
  logic        dco_clk_div;

  // External reference clock for DCO (also used as bypass system clock in sim)
  // initial begin
  //   dco_ext_clk = 1'b0;
  //   rst_n       = 1'b0;
  //   forever #(ClockPeriod/2) dco_ext_clk = ~dco_ext_clk;
  // end

  initial begin
    dco_ext_clk   = 1'b0;
    rst_n = 1'b0;
    repeat(16)
      #(ClockPeriod/2) dco_ext_clk = ~dco_ext_clk;
    rst_n = 1'b1;
    forever #(ClockPeriod/2) dco_ext_clk = ~dco_ext_clk;
  end

  initial begin
    dco_en       = DcoEn;
    dco_cc_sel   = DcoCcSel;
    dco_fc_sel   = DcoFcSel;
    dco_clk_sel  = DcoClkSel;
    dco_freq_sel = DcoFreqSel;
  end

  logic        exit;
  logic        uart_rx, uart_tx;

  logic        jtag_tck, jtag_tms, jtag_tdi, jtag_trst_n;
  logic        jtag_tdo, jtag_tdo_driven;
  logic        jtag_enable;
  logic        debug_enable;
  logic [31:0] jtag_exit;
  logic        init_done;

  assign init_done = rst_n;
  assign sys_clk   = `SOC_HIER.i_dco_wrapper.clk_o;

  initial begin
    if (!$value$plusargs("jtag_rbb_enable=%b", jtag_enable)) jtag_enable = 1'b0;
    if ($test$plusargs("debug_disable")) debug_enable = 1'b0; else debug_enable = 1'b1;
  end

  io_top dut (
    .IO_dco_ext_clk_i    ( dco_ext_clk    ),
    .IO_dco_en_i         ( dco_en         ),
    .IO_dco_cc_sel_i     ( dco_cc_sel     ),

    .IO_dco_fc_sel_i     ( dco_fc_sel     ),

    .IO_dco_clk_sel_i    ( dco_clk_sel    ),

    .IO_dco_freq_sel_i   ( dco_freq_sel   ),

    .IO_dco_clk_div_o    ( dco_clk_div    ),
    .IO_rst_ni           ( rst_n          ),
    .IO_uart_rx_i        ( uart_rx        ),
    .IO_uart_tx_o        ( uart_tx        ),
    .IO_exit_o           ( exit           ),
    .IO_jtag_tck_i       ( jtag_tck       ),
    .IO_jtag_tms_i       ( jtag_tms       ),
    .IO_jtag_tdi_i       ( jtag_tdi       ),
    .IO_jtag_trst_ni     ( jtag_trst_n    ),
    .IO_jtag_tdo_o       ( jtag_tdo       ),
    .IO_jtag_tdo_driven_o( jtag_tdo_driven),
    .IO_debug_enable_i   ( debug_enable   )
  );

  SimJTAG i_SimJTAG (
    .clock           ( sys_clk        ),
    .reset           ( ~rst_n         ),
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

  uartdpi #(
    .BAUD('d6250000),
    .FREQ('d500_000_000),
    .NAME("uart0")
  ) i_uart0 (
    .clk_i  ( sys_clk ),
    .rst_ni ( rst_n   ),
    .tx_o   ( uart_rx ),
    .rx_i   ( uart_tx )
  );

  `ifdef GATE_SIM
    localparam bit USE_REAL_SRAM = 1'b1;
  `elsif SYN_SRAM
    localparam bit USE_REAL_SRAM = 1'b1;
  `else
    localparam bit USE_REAL_SRAM = 1'b0;
  `endif



  if (USE_REAL_SRAM) begin : gen_real_sram_init

    // `ifdef GATE_SIM
    //   `define L2_MACRO dut.u_ariane_soc_top.i_sram.i_tc_sram_wrapper.i_tc_sram.gen_l2_4096x64_mem_i_macro
    // `else
    //   `define L2_MACRO dut.u_ariane_soc_top.i_sram.i_tc_sram_wrapper.i_tc_sram.gen_l2_4096x64_mem.i_macro
    // `endif
    `ifdef GATE_SIM
      // DC flattens gen block + instance name into one cell instance.
      // `define L2_MACRO `SOC_HIER.i_sram.i_tc_sram_wrapper.i_tc_sram.gen_l2_4096x64_mem_i_macro
      `define L2_LOADADDR(addr, data) `SOC_HIER.i_sram.i_tc_sram_wrapper.i_tc_sram.\gen_l2_4096x64_mem.i_macro .loadaddr(addr, data)
    `else
      // `define L2_MACRO `SOC_HIER.i_sram.i_tc_sram_wrapper.i_tc_sram.gen_l2_4096x64_mem.i_macro
      `define L2_LOADADDR(addr, data) `SOC_HIER.i_sram.i_tc_sram_wrapper.i_tc_sram.gen_l2_4096x64_mem.i_macro.loadaddr(addr, data)
    `endif

    initial begin : dram_init
      automatic logic [7:0][7:0] mem_row;
      longint address, load_address, last_load_address, len;
      byte buffer[];
      string binary;
      
      $display("zzc: USE_REAL_SRAM = 1");
      $display("zzc: GATE_SIM = 1");
      $display("zzc: using real sram");

      @(posedge rst_n);
      repeat (2) @(posedge sys_clk);

      void'($value$plusargs("PRELOAD=%s", binary));
      if (binary != "") begin
        read_elf(binary);
        $display("Loading ELF file %s into real SRAM via backdoor", binary);

        last_load_address = 'hFFFFFFFF;
        while (get_section(address, len)) begin
          automatic int num_words = (len + 7) / 8;
          buffer = new [num_words * 8];
          void'(read_section(address, buffer));
          for (int i = 0; i < num_words; i++) begin
            mem_row = '0;
            for (int j = 0; j < 8; j++) begin
              mem_row[j] = buffer[i * 8 + j];
            end
            load_address = (address[23:0] >> 3) + i;
            if (load_address != last_load_address) begin
              // `L2_MACRO.loadaddr(load_address[11:0], mem_row);
              `L2_LOADADDR(load_address[11:0], mem_row);
              last_load_address = load_address;
            end
          end
        end
        $display("SRAM backdoor load complete.");
      end else begin
        $error("Expecting a firmware to run, none was provided!");
        $finish;
      end
    end : dram_init

  end else begin : gen_sim_sram_init
    `define MAIN_MEM(P) dut.u_ariane_soc_top.i_sram.i_tc_sram_wrapper.i_tc_sram.init_val[(``P``)]
    initial begin : dram_init
      automatic logic [7:0][7:0] mem_row;
      longint address, load_address, last_load_address, len;
      byte buffer[];
      string binary;

      $display("zzc: USE_REAL_SRAM = 0");
      $display("zzc: using sim sram");

      // Preload DRAM while PoR is held; ext_clk bypass keeps tc_sram clocked.
      repeat (4) #ClockPeriod;

      void'($value$plusargs("PRELOAD=%s", binary));
      if (binary != "") begin
        read_elf(binary);
        $display("Loading ELF file %s", binary);

        last_load_address = 'hFFFFFFFF;
        while (get_section(address, len)) begin
          automatic int num_words = (len + 7) / 8;
          buffer = new [num_words * 8];
          void'(read_section(address, buffer));
          for (int i = 0; i < num_words; i++) begin
            mem_row = '0;
            for (int j = 0; j < 8; j++) begin
              mem_row[j] = buffer[i * 8 + j];
            end
            load_address = (address[23:0] >> 3) + i;
            if (load_address != last_load_address) begin
              `MAIN_MEM(load_address) = mem_row;
              last_load_address = load_address;
            end
          end
        end

        repeat (8) @(posedge sys_clk);
        // rst_n = 1'b1;
        $display("PoR released after DRAM preload (minimum_dco).");
      end else begin
        $error("Expecting a firmware to run, none was provided!");
        $finish;
      end
    end : dram_init
  end : gen_sim_sram_init

  always @(posedge sys_clk) begin
    if (exit) begin
      $display("Core Test: *** FINISHED ***");
      #5000
      $finish;
    end
  end

  initial begin
    $display("zzc: creating  waveform.fsdb");
    $fsdbDumpfile("waveform.fsdb");
    $fsdbDumpvars(0, dut, "+all");
  end

endmodule : io_top_tb
