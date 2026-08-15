// Post-PnR functional testbench for flattened io_top.
// Hierarchy inside the chip is flattened; DCO / dcim / SRAM keep escaped instance names.
//
//   make -C sim vcs FILELIST=filelist_minimum_dcim_postpnr.f VCS_TOP=io_top_postpnr_tb
//   make -C sim vcs-run FILELIST=filelist_minimum_dcim_postpnr.f VCS_TOP=io_top_postpnr_tb \
//        app=../software/build/bin/dcim_test

import "DPI-C" function void read_elf (input string filename);
import "DPI-C" function byte get_section (output longint address, output longint len);
import "DPI-C" context function byte read_section(input longint address, inout byte buffer[]);

// Trailing space after escaped names is required so ".CLK" is not swallowed.
`define DCO_INST dut.\u_ariane_soc_top/i_dco_wrapper/i_dco 
`define L2_MACRO dut.\u_ariane_soc_top/i_sram/i_tc_sram_wrapper/i_tc_sram/gen_l2_4096x64_mem_i_macro 

module io_top_postpnr_tb;

  `ifndef VERILATOR
  timeunit      1ns;
  timeprecision 1ps;
  `endif

  localparam ClockPeriod      = 2ns;

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
  wire         dco_clk_div;

  initial begin
    dco_ext_clk = 1'b0;
    rst_n       = 1'b0;
    repeat (16)
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

  // Flattened DCO still contains a combinational ring. Force CLK_SEL so CLK
  // follows EXT_CLK (same intent as the RTL TB DcoClkSel=1 bypass).
  initial begin
    force `DCO_INST .CLK_SEL = 1'b1;
    force `DCO_INST .EN      = 1'b1;
  end

  wire         exit;
  wire         uart_rx, uart_tx;

  logic        jtag_tck, jtag_tms, jtag_tdi, jtag_trst_n;
  wire         jtag_tdo, jtag_tdo_driven;
  logic        jtag_enable;
  logic        debug_enable;
  logic [31:0] jtag_exit;
  logic        init_done;

  assign init_done = rst_n;
  assign sys_clk   = `DCO_INST .CLK;

  supply1 VDD_CORE, VDD_DCO, VDD_DCIM0, VDD_DCIM1, VDD_DCIM2, VDD_DCIM3;
  supply1 VDDPST_CORE_LEFT, VDDPST_CORE_RIGHT_UPPER, VDDPST_CORE_RIGHT_LOWER;
  supply1 VDDPST_DCO, VDDPST_DCIM0, VDDPST_DCIM1, VDDPST_DCIM2, VDDPST_DCIM3;
  supply0 VSS;
  supply0 VSSPST_CORE_LEFT, VSSPST_CORE_RIGHT_UPPER, VSSPST_CORE_RIGHT_LOWER;
  supply0 VSSPST_DCO, VSSPST_DCIM0, VSSPST_DCIM1, VSSPST_DCIM2, VSSPST_DCIM3;

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
    .IO_debug_enable_i   ( debug_enable   ),
    .VSS                 ( VSS            ),
    .VDD_CORE            ( VDD_CORE       ),
    .VDDPST_CORE_LEFT    ( VDDPST_CORE_LEFT ),
    .VDDPST_CORE_RIGHT_UPPER ( VDDPST_CORE_RIGHT_UPPER ),
    .VDDPST_CORE_RIGHT_LOWER ( VDDPST_CORE_RIGHT_LOWER ),
    .VSSPST_CORE_LEFT    ( VSSPST_CORE_LEFT ),
    .VSSPST_CORE_RIGHT_UPPER ( VSSPST_CORE_RIGHT_UPPER ),
    .VSSPST_CORE_RIGHT_LOWER ( VSSPST_CORE_RIGHT_LOWER ),
    .VDD_DCO             ( VDD_DCO        ),
    .VDDPST_DCO          ( VDDPST_DCO     ),
    .VSSPST_DCO          ( VSSPST_DCO     ),
    .VDD_DCIM0           ( VDD_DCIM0      ),
    .VDDPST_DCIM0        ( VDDPST_DCIM0   ),
    .VSSPST_DCIM0        ( VSSPST_DCIM0   ),
    .VDD_DCIM1           ( VDD_DCIM1      ),
    .VDDPST_DCIM1        ( VDDPST_DCIM1   ),
    .VSSPST_DCIM1        ( VSSPST_DCIM1   ),
    .VDD_DCIM2           ( VDD_DCIM2      ),
    .VDDPST_DCIM2        ( VDDPST_DCIM2   ),
    .VSSPST_DCIM2        ( VSSPST_DCIM2   ),
    .VDD_DCIM3           ( VDD_DCIM3      ),
    .VDDPST_DCIM3        ( VDDPST_DCIM3   ),
    .VSSPST_DCIM3        ( VSSPST_DCIM3   )
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

  initial begin : dram_init
    automatic logic [7:0][7:0] mem_row;
    longint address, load_address, last_load_address, len;
    byte buffer[];
    string binary;

    @(posedge rst_n);
    repeat (20) @(posedge sys_clk);

    void'($value$plusargs("PRELOAD=%s", binary));
    if (binary != "") begin
      read_elf(binary);
      $display("Loading ELF file %s into post-PnR SRAM via backdoor", binary);

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
            `L2_MACRO .loadaddr(load_address[11:0], mem_row);
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

  always @(posedge sys_clk) begin
    if (exit) begin
      $display("Core Test: *** FINISHED ***");
      #5000
      $finish;
    end
  end

endmodule : io_top_postpnr_tb
