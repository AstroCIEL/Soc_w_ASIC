/* verilog_memcomp Version: c1.0.0-EAC */
/* common_memcomp Version: c1.0.0-EAC */
/* lang compiler Version: 4.16.0-EAC Jul 27 2020 14:36:03 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF Arm, Inc.
//      
//       Copyright (c) 1993 - 2025 Arm, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with Arm, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for High Density Single Port Register File SHVT MVT Compiler
//
//       Instance Name:              sram128x46
//       Words:                      128
//       Bits:                       46
//       Mux:                        2
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
//       Extra Margin Adjustment:    On
//       Test Muxes                  Off
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Fri Jan 31 19:58:27 2025
//       Version: 	r3p1
//
//      Modeling Assumptions: This model supports full gate level simulation
//          including proper x-handling and timing check behavior.  Unit
//          delay timing is included in the model. Back-annotation of SDF
//          (v3.0 or v2.1) is supported.  SDF can be created utilyzing the delay
//          calculation views provided with this generator and supported
//          delay calculators.  All buses are modeled [MSB:LSB].  All 
//          ports are padded with Verilog primitives.
//
//      Modeling Limitations: None.
//
//      Known Bugs: None.
//
//      Known Work Arounds: N/A
//
`timescale 1 ns/1 ps
`define ARM_MEM_PROP 1.000
`define ARM_MEM_RETAIN 1.000
`define ARM_MEM_PERIOD 3.000
`define ARM_MEM_WIDTH 1.000
`define ARM_MEM_SETUP 1.000
`define ARM_MEM_HOLD 0.500
`define ARM_MEM_COLLISION 3.000
`define ARM_OFFSET_TIME 0
  `define RF_SP_HDE_SHVT_MVT_ARM_REF_EMA_VALUE 7
  `define RF_SP_HDE_SHVT_MVT_ARM_REF_EMAW_VALUE 3
  `define RF_SP_HDE_SHVT_MVT_ARM_REF_EMAS_VALUE 1
// If ARM_UD_MODEL is defined at Simulator Command Line, it Selects the Fast Functional Model
`ifdef ARM_UD_MODEL

// Following parameter Values can be overridden at Simulator Command Line.

// ARM_UD_DP Defines the delay through Data Paths, for Memory Models it represents BIST MUX output delays.
`ifdef ARM_UD_DP
`else
`define ARM_UD_DP #0.001
`endif
// ARM_UD_CP Defines the delay through Clock Path Cells, for Memory Models it is not used.
`ifdef ARM_UD_CP
`else
`define ARM_UD_CP
`endif
// ARM_UD_SEQ Defines the delay through the Memory, for Memory Models it is used for CLK->Q delays.
`ifdef ARM_UD_SEQ
`else
`define ARM_UD_SEQ #0.01
`endif

`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sram128x46 (VDDCE, VDDPE, VSSE, q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, 
    wabl, wablm, rawl, rawlm);
`else
module sram128x46 (q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, wabl, wablm, rawl, 
    rawlm);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 46;
  parameter WORDS = 128;
  parameter MUX = 2;
  parameter MEM_WIDTH = 92; // redun block size 2, 44 on left, 48 on right
  parameter MEM_HEIGHT = 64;
  parameter WP_SIZE = 46 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;
  parameter ARM_LOCAL_OFFSET_TIME = `ARM_OFFSET_TIME;

`ifdef ARM_DISABLE_EMA_CHECK
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 1;
`else
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 0;
`endif

  parameter ARM_REF_EMA_VALUE = `RF_SP_HDE_SHVT_MVT_ARM_REF_EMA_VALUE;
  parameter ARM_REF_EMAW_VALUE = `RF_SP_HDE_SHVT_MVT_ARM_REF_EMAW_VALUE;
  parameter ARM_REF_EMAS_VALUE = `RF_SP_HDE_SHVT_MVT_ARM_REF_EMAS_VALUE;

  output [45:0] q;
  input  clk;
  input  cen;
  input  wen;
  input [6:0] a;
  input [45:0] d;
  input [2:0] ema;
  input [1:0] emaw;
  input  emas;
  input  ret1n;
  input  wabl;
  input [1:0] wablm;
  input  rawl;
  input [1:0] rawlm;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif
`ifdef POWER_PINS
  reg bad_VDDCE;
  reg bad_VDDPE;
  reg bad_VSSE;
  reg bad_power;
`endif
 wire corrupt_power;
`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

  reg pre_charge_st;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [91:0] mem [0:63];
  reg [91:0] row, row_t;
  reg LAST_clk;
  reg [91:0] row_mask;
  reg [91:0] new_data;
  reg [91:0] data_out;
  reg [45:0] readLatch0;
  reg [45:0] shifted_readLatch0;
  reg [45:0] q_int;
  reg [45:0] writeEnable;
  reg clk0_int;

  wire [45:0] q_;
  wire [45:0] q_out;
 wire  clk_;
  wire  cen_;
  reg  cen_int;
  reg  cen_p2;
  wire  wen_;
  reg  wen_int;
  wire [6:0] a_;
  reg [6:0] a_int;
  wire [45:0] d_;
  reg [45:0] d_int;
  wire [2:0] ema_;
  reg [2:0] ema_int;
  wire [1:0] emaw_;
  reg [1:0] emaw_int;
  wire  emas_;
  reg  emas_int;
  wire  ret1n_;
  reg  ret1n_int;
  wire  wabl_;
  reg  wabl_int;
  wire [1:0] wablm_;
  reg [1:0] wablm_int;
  wire  rawl_;
  reg  rawl_int;
  wire [1:0] rawlm_;
  reg [1:0] rawlm_int;

  assign q[0] = q_[0]; 
  assign q[1] = q_[1]; 
  assign q[2] = q_[2]; 
  assign q[3] = q_[3]; 
  assign q[4] = q_[4]; 
  assign q[5] = q_[5]; 
  assign q[6] = q_[6]; 
  assign q[7] = q_[7]; 
  assign q[8] = q_[8]; 
  assign q[9] = q_[9]; 
  assign q[10] = q_[10]; 
  assign q[11] = q_[11]; 
  assign q[12] = q_[12]; 
  assign q[13] = q_[13]; 
  assign q[14] = q_[14]; 
  assign q[15] = q_[15]; 
  assign q[16] = q_[16]; 
  assign q[17] = q_[17]; 
  assign q[18] = q_[18]; 
  assign q[19] = q_[19]; 
  assign q[20] = q_[20]; 
  assign q[21] = q_[21]; 
  assign q[22] = q_[22]; 
  assign q[23] = q_[23]; 
  assign q[24] = q_[24]; 
  assign q[25] = q_[25]; 
  assign q[26] = q_[26]; 
  assign q[27] = q_[27]; 
  assign q[28] = q_[28]; 
  assign q[29] = q_[29]; 
  assign q[30] = q_[30]; 
  assign q[31] = q_[31]; 
  assign q[32] = q_[32]; 
  assign q[33] = q_[33]; 
  assign q[34] = q_[34]; 
  assign q[35] = q_[35]; 
  assign q[36] = q_[36]; 
  assign q[37] = q_[37]; 
  assign q[38] = q_[38]; 
  assign q[39] = q_[39]; 
  assign q[40] = q_[40]; 
  assign q[41] = q_[41]; 
  assign q[42] = q_[42]; 
  assign q[43] = q_[43]; 
  assign q[44] = q_[44]; 
  assign q[45] = q_[45]; 
  assign clk_ = clk;
  assign cen_ = cen;
  assign wen_ = wen;
  assign a_[0] = a[0];
  assign a_[1] = a[1];
  assign a_[2] = a[2];
  assign a_[3] = a[3];
  assign a_[4] = a[4];
  assign a_[5] = a[5];
  assign a_[6] = a[6];
  assign d_[0] = d[0];
  assign d_[1] = d[1];
  assign d_[2] = d[2];
  assign d_[3] = d[3];
  assign d_[4] = d[4];
  assign d_[5] = d[5];
  assign d_[6] = d[6];
  assign d_[7] = d[7];
  assign d_[8] = d[8];
  assign d_[9] = d[9];
  assign d_[10] = d[10];
  assign d_[11] = d[11];
  assign d_[12] = d[12];
  assign d_[13] = d[13];
  assign d_[14] = d[14];
  assign d_[15] = d[15];
  assign d_[16] = d[16];
  assign d_[17] = d[17];
  assign d_[18] = d[18];
  assign d_[19] = d[19];
  assign d_[20] = d[20];
  assign d_[21] = d[21];
  assign d_[22] = d[22];
  assign d_[23] = d[23];
  assign d_[24] = d[24];
  assign d_[25] = d[25];
  assign d_[26] = d[26];
  assign d_[27] = d[27];
  assign d_[28] = d[28];
  assign d_[29] = d[29];
  assign d_[30] = d[30];
  assign d_[31] = d[31];
  assign d_[32] = d[32];
  assign d_[33] = d[33];
  assign d_[34] = d[34];
  assign d_[35] = d[35];
  assign d_[36] = d[36];
  assign d_[37] = d[37];
  assign d_[38] = d[38];
  assign d_[39] = d[39];
  assign d_[40] = d[40];
  assign d_[41] = d[41];
  assign d_[42] = d[42];
  assign d_[43] = d[43];
  assign d_[44] = d[44];
  assign d_[45] = d[45];
  assign ema_[0] = ema[0];
  assign ema_[1] = ema[1];
  assign ema_[2] = ema[2];
  assign emaw_[0] = emaw[0];
  assign emaw_[1] = emaw[1];
  assign emas_ = emas;
  assign ret1n_ = ret1n;
  assign wabl_ = wabl;
  assign wablm_[0] = wablm[0];
  assign wablm_[1] = wablm[1];
  assign rawl_ = rawl;
  assign rawlm_[0] = rawlm[0];
  assign rawlm_[1] = rawlm[1];

   `ifdef ARM_FAULT_MODELING
     sram128x46_error_injection u1(.CLK(clk_), .Q_out(q_out), .A(a_int), .CEN(cen_int), .WEN(wen_int), .Q_in(q_int));
   `else
     assign q_out = q_int;
   `endif
  assign `ARM_UD_SEQ q_ = (ret1n_ | pre_charge_st) & ~corrupt_power ? ((q_out)) : {46{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial begin
  #ARM_LOCAL_OFFSET_TIME;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
// If INITIALIZE_OUTPUT is defined at Simulator Command Line, it Initializes the Output with Random value.

`ifdef INITIALIZE_OUTPUT
  initial
  begin
  #ARM_LOCAL_OFFSET_TIME;
	q_int = $random;
  end
`endif

  always @ (posedge clk_  ) begin
      if(ema_ !== ARM_REF_EMA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) && ~corrupt_power && ret1n_ === 1'b1 &&  (((cen_int === 1'b0 &&  clk_ === 1'b1) )   )) 
      $display("Warning: Set Value for ema is %d and is not equal to %d in %m at %0t. Please refer README for correct value of ema", ema_, ARM_REF_EMA_VALUE, $time);
  end
  always @ (posedge clk_ ) begin
      if(emaw_ !== ARM_REF_EMAW_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) && ~corrupt_power && ret1n_ === 1'b1 &&  (((cen_int === 1'b0 &&  clk_ === 1'b1) )   )) 
      $display("Warning: Set Value for emaw is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emaw", emaw_, ARM_REF_EMAW_VALUE, $time);
  end
  always @ (posedge clk_  ) begin
      if(emas_ !== ARM_REF_EMAS_VALUE  && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) && ~corrupt_power && ret1n_ === 1'b1 &&  (((cen_int === 1'b0 &&  clk_ === 1'b1) )   )) 
      $display("Warning: Set Value for emas is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emas", emas_, ARM_REF_EMAS_VALUE, $time);
  end

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval===1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        row_mask =  ( {1'b0, writeEnable[45], 1'b0, writeEnable[44], 1'b0, writeEnable[43],
          1'b0, writeEnable[42], 1'b0, writeEnable[41], 1'b0, writeEnable[40], 1'b0, writeEnable[39],
          1'b0, writeEnable[38], 1'b0, writeEnable[37], 1'b0, writeEnable[36], 1'b0, writeEnable[35],
          1'b0, writeEnable[34], 1'b0, writeEnable[33], 1'b0, writeEnable[32], 1'b0, writeEnable[31],
          1'b0, writeEnable[30], 1'b0, writeEnable[29], 1'b0, writeEnable[28], 1'b0, writeEnable[27],
          1'b0, writeEnable[26], 1'b0, writeEnable[25], 1'b0, writeEnable[24], 1'b0, writeEnable[23],
          1'b0, writeEnable[22], 1'b0, writeEnable[21], 1'b0, writeEnable[20], 1'b0, writeEnable[19],
          1'b0, writeEnable[18], 1'b0, writeEnable[17], 1'b0, writeEnable[16], 1'b0, writeEnable[15],
          1'b0, writeEnable[14], 1'b0, writeEnable[13], 1'b0, writeEnable[12], 1'b0, writeEnable[11],
          1'b0, writeEnable[10], 1'b0, writeEnable[9], 1'b0, writeEnable[8], 1'b0, writeEnable[7],
          1'b0, writeEnable[6], 1'b0, writeEnable[5], 1'b0, writeEnable[4], 1'b0, writeEnable[3],
          1'b0, writeEnable[2], 1'b0, writeEnable[1], 1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[45], 1'b0, wordtemp[44], 1'b0, wordtemp[43],
          1'b0, wordtemp[42], 1'b0, wordtemp[41], 1'b0, wordtemp[40], 1'b0, wordtemp[39],
          1'b0, wordtemp[38], 1'b0, wordtemp[37], 1'b0, wordtemp[36], 1'b0, wordtemp[35],
          1'b0, wordtemp[34], 1'b0, wordtemp[33], 1'b0, wordtemp[32], 1'b0, wordtemp[31],
          1'b0, wordtemp[30], 1'b0, wordtemp[29], 1'b0, wordtemp[28], 1'b0, wordtemp[27],
          1'b0, wordtemp[26], 1'b0, wordtemp[25], 1'b0, wordtemp[24], 1'b0, wordtemp[23],
          1'b0, wordtemp[22], 1'b0, wordtemp[21], 1'b0, wordtemp[20], 1'b0, wordtemp[19],
          1'b0, wordtemp[18], 1'b0, wordtemp[17], 1'b0, wordtemp[16], 1'b0, wordtemp[15],
          1'b0, wordtemp[14], 1'b0, wordtemp[13], 1'b0, wordtemp[12], 1'b0, wordtemp[11],
          1'b0, wordtemp[10], 1'b0, wordtemp[9], 1'b0, wordtemp[8], 1'b0, wordtemp[7],
          1'b0, wordtemp[6], 1'b0, wordtemp[5], 1'b0, wordtemp[4], 1'b0, wordtemp[3],
          1'b0, wordtemp[2], 1'b0, wordtemp[1], 1'b0, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[90], data_out[88], data_out[86], data_out[84], data_out[82],
          data_out[80], data_out[78], data_out[76], data_out[74], data_out[72], data_out[70],
          data_out[68], data_out[66], data_out[64], data_out[62], data_out[60], data_out[58],
          data_out[56], data_out[54], data_out[52], data_out[50], data_out[48], data_out[46],
          data_out[44], data_out[42], data_out[40], data_out[38], data_out[36], data_out[34],
          data_out[32], data_out[30], data_out[28], data_out[26], data_out[24], data_out[22],
          data_out[20], data_out[18], data_out[16], data_out[14], data_out[12], data_out[10],
          data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43],
          shifted_readLatch0[42], shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39],
          shifted_readLatch0[38], shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35],
          shifted_readLatch0[34], shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31],
          shifted_readLatch0[30], shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27],
          shifted_readLatch0[26], shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23],
          shifted_readLatch0[22], shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19],
          shifted_readLatch0[18], shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15],
          shifted_readLatch0[14], shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", q_int);
  end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [6:0] load_addr;
	input [45:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        row_mask =  ( {1'b0, writeEnable[45], 1'b0, writeEnable[44], 1'b0, writeEnable[43],
          1'b0, writeEnable[42], 1'b0, writeEnable[41], 1'b0, writeEnable[40], 1'b0, writeEnable[39],
          1'b0, writeEnable[38], 1'b0, writeEnable[37], 1'b0, writeEnable[36], 1'b0, writeEnable[35],
          1'b0, writeEnable[34], 1'b0, writeEnable[33], 1'b0, writeEnable[32], 1'b0, writeEnable[31],
          1'b0, writeEnable[30], 1'b0, writeEnable[29], 1'b0, writeEnable[28], 1'b0, writeEnable[27],
          1'b0, writeEnable[26], 1'b0, writeEnable[25], 1'b0, writeEnable[24], 1'b0, writeEnable[23],
          1'b0, writeEnable[22], 1'b0, writeEnable[21], 1'b0, writeEnable[20], 1'b0, writeEnable[19],
          1'b0, writeEnable[18], 1'b0, writeEnable[17], 1'b0, writeEnable[16], 1'b0, writeEnable[15],
          1'b0, writeEnable[14], 1'b0, writeEnable[13], 1'b0, writeEnable[12], 1'b0, writeEnable[11],
          1'b0, writeEnable[10], 1'b0, writeEnable[9], 1'b0, writeEnable[8], 1'b0, writeEnable[7],
          1'b0, writeEnable[6], 1'b0, writeEnable[5], 1'b0, writeEnable[4], 1'b0, writeEnable[3],
          1'b0, writeEnable[2], 1'b0, writeEnable[1], 1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[45], 1'b0, wordtemp[44], 1'b0, wordtemp[43],
          1'b0, wordtemp[42], 1'b0, wordtemp[41], 1'b0, wordtemp[40], 1'b0, wordtemp[39],
          1'b0, wordtemp[38], 1'b0, wordtemp[37], 1'b0, wordtemp[36], 1'b0, wordtemp[35],
          1'b0, wordtemp[34], 1'b0, wordtemp[33], 1'b0, wordtemp[32], 1'b0, wordtemp[31],
          1'b0, wordtemp[30], 1'b0, wordtemp[29], 1'b0, wordtemp[28], 1'b0, wordtemp[27],
          1'b0, wordtemp[26], 1'b0, wordtemp[25], 1'b0, wordtemp[24], 1'b0, wordtemp[23],
          1'b0, wordtemp[22], 1'b0, wordtemp[21], 1'b0, wordtemp[20], 1'b0, wordtemp[19],
          1'b0, wordtemp[18], 1'b0, wordtemp[17], 1'b0, wordtemp[16], 1'b0, wordtemp[15],
          1'b0, wordtemp[14], 1'b0, wordtemp[13], 1'b0, wordtemp[12], 1'b0, wordtemp[11],
          1'b0, wordtemp[10], 1'b0, wordtemp[9], 1'b0, wordtemp[8], 1'b0, wordtemp[7],
          1'b0, wordtemp[6], 1'b0, wordtemp[5], 1'b0, wordtemp[4], 1'b0, wordtemp[3],
          1'b0, wordtemp[2], 1'b0, wordtemp[1], 1'b0, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [45:0] dump_data;
	input [6:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[90], data_out[88], data_out[86], data_out[84], data_out[82],
          data_out[80], data_out[78], data_out[76], data_out[74], data_out[72], data_out[70],
          data_out[68], data_out[66], data_out[64], data_out[62], data_out[60], data_out[58],
          data_out[56], data_out[54], data_out[52], data_out[50], data_out[48], data_out[46],
          data_out[44], data_out[42], data_out[40], data_out[38], data_out[36], data_out[34],
          data_out[32], data_out[30], data_out[28], data_out[26], data_out[24], data_out[22],
          data_out[20], data_out[18], data_out[16], data_out[14], data_out[12], data_out[10],
          data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43],
          shifted_readLatch0[42], shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39],
          shifted_readLatch0[38], shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35],
          shifted_readLatch0[34], shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31],
          shifted_readLatch0[30], shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27],
          shifted_readLatch0[26], shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23],
          shifted_readLatch0[22], shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19],
          shifted_readLatch0[18], shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15],
          shifted_readLatch0[14], shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
   	dump_data = q_int;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWrite;
  begin
    if (rawl_ === 1'bx)
      d_int = {46{1'bx}};
    if (^rawlm_ === 1'bx)
      d_int = {46{1'bx}};
    if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_int === 1'b0 && cen_int === 1'b0) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{cen_int, ema_int, emaw_int, emas_int, ret1n_int, wabl_int, wablm_int, rawl_int, rawlm_int} === 1'bx) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if ((a_int >= WORDS) && (cen_int === 1'b0)) begin
      q_int = wen_int !== 1'b1 ? q_int : {46{1'bx}};
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
     if (wen_int !== 1)
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (cen_int === 1'b0) begin
      mux_address = (a_int & 1'b1);
      row_address = (a_int >> 1);
      if (row_address > 63)
        row = {92{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {46{wen_int}};
      if (wen_int !== 1'b1) begin
        row_mask =  ( {1'b0, writeEnable[45], 1'b0, writeEnable[44], 1'b0, writeEnable[43],
          1'b0, writeEnable[42], 1'b0, writeEnable[41], 1'b0, writeEnable[40], 1'b0, writeEnable[39],
          1'b0, writeEnable[38], 1'b0, writeEnable[37], 1'b0, writeEnable[36], 1'b0, writeEnable[35],
          1'b0, writeEnable[34], 1'b0, writeEnable[33], 1'b0, writeEnable[32], 1'b0, writeEnable[31],
          1'b0, writeEnable[30], 1'b0, writeEnable[29], 1'b0, writeEnable[28], 1'b0, writeEnable[27],
          1'b0, writeEnable[26], 1'b0, writeEnable[25], 1'b0, writeEnable[24], 1'b0, writeEnable[23],
          1'b0, writeEnable[22], 1'b0, writeEnable[21], 1'b0, writeEnable[20], 1'b0, writeEnable[19],
          1'b0, writeEnable[18], 1'b0, writeEnable[17], 1'b0, writeEnable[16], 1'b0, writeEnable[15],
          1'b0, writeEnable[14], 1'b0, writeEnable[13], 1'b0, writeEnable[12], 1'b0, writeEnable[11],
          1'b0, writeEnable[10], 1'b0, writeEnable[9], 1'b0, writeEnable[8], 1'b0, writeEnable[7],
          1'b0, writeEnable[6], 1'b0, writeEnable[5], 1'b0, writeEnable[4], 1'b0, writeEnable[3],
          1'b0, writeEnable[2], 1'b0, writeEnable[1], 1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, d_int[45], 1'b0, d_int[44], 1'b0, d_int[43], 1'b0, d_int[42],
          1'b0, d_int[41], 1'b0, d_int[40], 1'b0, d_int[39], 1'b0, d_int[38], 1'b0, d_int[37],
          1'b0, d_int[36], 1'b0, d_int[35], 1'b0, d_int[34], 1'b0, d_int[33], 1'b0, d_int[32],
          1'b0, d_int[31], 1'b0, d_int[30], 1'b0, d_int[29], 1'b0, d_int[28], 1'b0, d_int[27],
          1'b0, d_int[26], 1'b0, d_int[25], 1'b0, d_int[24], 1'b0, d_int[23], 1'b0, d_int[22],
          1'b0, d_int[21], 1'b0, d_int[20], 1'b0, d_int[19], 1'b0, d_int[18], 1'b0, d_int[17],
          1'b0, d_int[16], 1'b0, d_int[15], 1'b0, d_int[14], 1'b0, d_int[13], 1'b0, d_int[12],
          1'b0, d_int[11], 1'b0, d_int[10], 1'b0, d_int[9], 1'b0, d_int[8], 1'b0, d_int[7],
          1'b0, d_int[6], 1'b0, d_int[5], 1'b0, d_int[4], 1'b0, d_int[3], 1'b0, d_int[2],
          1'b0, d_int[1], 1'b0, d_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[90], data_out[88], data_out[86], data_out[84], data_out[82],
          data_out[80], data_out[78], data_out[76], data_out[74], data_out[72], data_out[70],
          data_out[68], data_out[66], data_out[64], data_out[62], data_out[60], data_out[58],
          data_out[56], data_out[54], data_out[52], data_out[50], data_out[48], data_out[46],
          data_out[44], data_out[42], data_out[40], data_out[38], data_out[36], data_out[34],
          data_out[32], data_out[30], data_out[28], data_out[26], data_out[24], data_out[22],
          data_out[20], data_out[18], data_out[16], data_out[14], data_out[12], data_out[10],
          data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43],
          shifted_readLatch0[42], shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39],
          shifted_readLatch0[38], shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35],
          shifted_readLatch0[34], shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31],
          shifted_readLatch0[30], shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27],
          shifted_readLatch0[26], shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23],
          shifted_readLatch0[22], shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19],
          shifted_readLatch0[18], shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15],
          shifted_readLatch0[14], shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
      end
    if (rawl_ === 1'bx)
        q_int = {46{1'bx}};
    if (^rawlm_ === 1'bx)
        q_int = {46{1'bx}};
      if( isBitX(wen_int) ) begin
        q_int = {46{1'bx}};
      end
    end
  end
  endtask
  always @ (cen_ or clk_) begin
  	if(clk_ == 1'b0) begin
  		cen_p2 = cen_;
  	end
  end

`ifndef ARM_MONORAIL
`ifdef POWER_PINS
  always @ (posedge VDDCE or negedge VDDCE) begin
      if (VDDCE != 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDCE should be powered down after VDDPE, Illegal power down sequencing in %m at %0t", $time);
       end
        $display("In PowerDown Mode in %m at %0t", $time);
        failedWrite(0);
      end
      if (VDDCE == 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDPE should be powered up after VDDCE in %m at %0t", $time);
        $display("Illegal power up sequencing in %m at %0t", $time);
       end
        failedWrite(0);
      end
  end
`endif
`endif
`ifdef POWER_PINS
  always @ (ret1n_ or VDDPE or VDDCE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st == 1'b1 && (cen_ === 1'bx || clk_ === 1'bx)) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
      q_int = {46{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {46{1'bx}};
      ema_int = {3{1'bx}};
      emaw_int = {2{1'bx}};
      emas_int = 1'bx;
      ret1n_int = 1'bx;
      wabl_int = 1'bx;
      wablm_int = {2{1'bx}};
      rawl_int = 1'bx;
      rawlm_int = {2{1'bx}};
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st == 1'b1) begin
      pre_charge_st = 0;
    end else begin
      pre_charge_st = 0;
`else     
    end else begin
`endif
        q_int = {46{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {46{1'bx}};
      ema_int = {3{1'bx}};
      emaw_int = {2{1'bx}};
      emas_int = 1'bx;
      ret1n_int = 1'bx;
      wabl_int = 1'bx;
      wablm_int = {2{1'bx}};
      rawl_int = 1'bx;
      rawlm_int = {2{1'bx}};
    end
    ret1n_int = ret1n_;
  end


  always @ clk_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((clk_ === 1'bx || clk_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (clk_ === 1'b1 && LAST_clk === 1'b0) begin
      cen_int = cen_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      if (cen_int != 1'b1) begin
        wen_int = wen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      cen_int = cen_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      if (cen_int != 1'b1) begin
        wen_int = wen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
    readWrite;
    end else if (clk_ === 1'b0 && LAST_clk === 1'b1) begin
    end
  end
    LAST_clk = clk_;
  end
reg clk_s;

always @ (clk_)
    clk_s <= clk_;

// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
	always @ (VDDCE or VDDPE or VSSE or clk_s) begin
		if (VDDCE !== 1'b1) begin
			$display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
        q_int = {46{1'bx}};
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (VDDPE !== 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        q_int = {46{1'bx}};
		if (ret1n_ !== 1'b0)
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE !== 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        q_int = {46{1'bx}};
			failedWrite(0);
			bad_VSSE = 1'b1;
		end else begin
			bad_VSSE = 1'b0;
		end
		bad_power = bad_VDDCE | bad_VDDPE | bad_VSSE ;
	end
`endif

endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sram128x46 (VDDCE, VDDPE, VSSE, q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, 
    wabl, wablm, rawl, rawlm);
`else
module sram128x46 (q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, wabl, wablm, rawl, 
    rawlm);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 46;
  parameter WORDS = 128;
  parameter MUX = 2;
  parameter MEM_WIDTH = 92; // redun block size 2, 44 on left, 48 on right
  parameter MEM_HEIGHT = 64;
  parameter WP_SIZE = 46 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;
  parameter ARM_LOCAL_OFFSET_TIME = `ARM_OFFSET_TIME;

`ifdef ARM_DISABLE_EMA_CHECK
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 1;
`else
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 0;
`endif

  parameter ARM_REF_EMA_VALUE = `RF_SP_HDE_SHVT_MVT_ARM_REF_EMA_VALUE;
  parameter ARM_REF_EMAW_VALUE = `RF_SP_HDE_SHVT_MVT_ARM_REF_EMAW_VALUE;
  parameter ARM_REF_EMAS_VALUE = `RF_SP_HDE_SHVT_MVT_ARM_REF_EMAS_VALUE;

  output [45:0] q;
  input  clk;
  input  cen;
  input  wen;
  input [6:0] a;
  input [45:0] d;
  input [2:0] ema;
  input [1:0] emaw;
  input  emas;
  input  ret1n;
  input  wabl;
  input [1:0] wablm;
  input  rawl;
  input [1:0] rawlm;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif
`ifdef POWER_PINS
  reg bad_VDDCE;
  reg bad_VDDPE;
  reg bad_VSSE;
  reg bad_power;
`endif
 wire corrupt_power;
`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

  reg pre_charge_st;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [91:0] mem [0:63];
  reg [91:0] row, row_t;
  reg LAST_clk;
  reg [91:0] row_mask;
  reg [91:0] new_data;
  reg [91:0] data_out;
  reg [45:0] readLatch0;
  reg [45:0] shifted_readLatch0;
  reg [45:0] q_int;
  reg [45:0] writeEnable;

  reg NOT_cen, NOT_wen, NOT_a6, NOT_a5, NOT_a4, NOT_a3, NOT_a2, NOT_a1, NOT_a0, NOT_d45;
  reg NOT_d44, NOT_d43, NOT_d42, NOT_d41, NOT_d40, NOT_d39, NOT_d38, NOT_d37, NOT_d36;
  reg NOT_d35, NOT_d34, NOT_d33, NOT_d32, NOT_d31, NOT_d30, NOT_d29, NOT_d28, NOT_d27;
  reg NOT_d26, NOT_d25, NOT_d24, NOT_d23, NOT_d22, NOT_d21, NOT_d20, NOT_d19, NOT_d18;
  reg NOT_d17, NOT_d16, NOT_d15, NOT_d14, NOT_d13, NOT_d12, NOT_d11, NOT_d10, NOT_d9;
  reg NOT_d8, NOT_d7, NOT_d6, NOT_d5, NOT_d4, NOT_d3, NOT_d2, NOT_d1, NOT_d0, NOT_ema2;
  reg NOT_ema1, NOT_ema0, NOT_emaw1, NOT_emaw0, NOT_emas, NOT_ret1n, NOT_wabl, NOT_wablm1;
  reg NOT_wablm0, NOT_rawl, NOT_rawlm1, NOT_rawlm0;
  reg NOT_clk_PER, NOT_clk_MINH, NOT_clk_MINL;
  reg clk0_int;

  wire [45:0] q_;
  wire [45:0] q_out;
 wire  clk_;
  wire  cen_;
  reg  cen_int;
  reg  cen_p2;
  wire  wen_;
  reg  wen_int;
  wire [6:0] a_;
  reg [6:0] a_int;
  wire [45:0] d_;
  reg [45:0] d_int;
  wire [2:0] ema_;
  reg [2:0] ema_int;
  wire [1:0] emaw_;
  reg [1:0] emaw_int;
  wire  emas_;
  reg  emas_int;
  wire  ret1n_;
  reg  ret1n_int;
  wire  wabl_;
  reg  wabl_int;
  wire [1:0] wablm_;
  reg [1:0] wablm_int;
  wire  rawl_;
  reg  rawl_int;
  wire [1:0] rawlm_;
  reg [1:0] rawlm_int;

  buf B0(q[0], q_[0]);
  buf B1(q[1], q_[1]);
  buf B2(q[2], q_[2]);
  buf B3(q[3], q_[3]);
  buf B4(q[4], q_[4]);
  buf B5(q[5], q_[5]);
  buf B6(q[6], q_[6]);
  buf B7(q[7], q_[7]);
  buf B8(q[8], q_[8]);
  buf B9(q[9], q_[9]);
  buf B10(q[10], q_[10]);
  buf B11(q[11], q_[11]);
  buf B12(q[12], q_[12]);
  buf B13(q[13], q_[13]);
  buf B14(q[14], q_[14]);
  buf B15(q[15], q_[15]);
  buf B16(q[16], q_[16]);
  buf B17(q[17], q_[17]);
  buf B18(q[18], q_[18]);
  buf B19(q[19], q_[19]);
  buf B20(q[20], q_[20]);
  buf B21(q[21], q_[21]);
  buf B22(q[22], q_[22]);
  buf B23(q[23], q_[23]);
  buf B24(q[24], q_[24]);
  buf B25(q[25], q_[25]);
  buf B26(q[26], q_[26]);
  buf B27(q[27], q_[27]);
  buf B28(q[28], q_[28]);
  buf B29(q[29], q_[29]);
  buf B30(q[30], q_[30]);
  buf B31(q[31], q_[31]);
  buf B32(q[32], q_[32]);
  buf B33(q[33], q_[33]);
  buf B34(q[34], q_[34]);
  buf B35(q[35], q_[35]);
  buf B36(q[36], q_[36]);
  buf B37(q[37], q_[37]);
  buf B38(q[38], q_[38]);
  buf B39(q[39], q_[39]);
  buf B40(q[40], q_[40]);
  buf B41(q[41], q_[41]);
  buf B42(q[42], q_[42]);
  buf B43(q[43], q_[43]);
  buf B44(q[44], q_[44]);
  buf B45(q[45], q_[45]);
  buf B46(clk_, clk);
  buf B47(cen_, cen);
  buf B48(wen_, wen);
  buf B49(a_[0], a[0]);
  buf B50(a_[1], a[1]);
  buf B51(a_[2], a[2]);
  buf B52(a_[3], a[3]);
  buf B53(a_[4], a[4]);
  buf B54(a_[5], a[5]);
  buf B55(a_[6], a[6]);
  buf B56(d_[0], d[0]);
  buf B57(d_[1], d[1]);
  buf B58(d_[2], d[2]);
  buf B59(d_[3], d[3]);
  buf B60(d_[4], d[4]);
  buf B61(d_[5], d[5]);
  buf B62(d_[6], d[6]);
  buf B63(d_[7], d[7]);
  buf B64(d_[8], d[8]);
  buf B65(d_[9], d[9]);
  buf B66(d_[10], d[10]);
  buf B67(d_[11], d[11]);
  buf B68(d_[12], d[12]);
  buf B69(d_[13], d[13]);
  buf B70(d_[14], d[14]);
  buf B71(d_[15], d[15]);
  buf B72(d_[16], d[16]);
  buf B73(d_[17], d[17]);
  buf B74(d_[18], d[18]);
  buf B75(d_[19], d[19]);
  buf B76(d_[20], d[20]);
  buf B77(d_[21], d[21]);
  buf B78(d_[22], d[22]);
  buf B79(d_[23], d[23]);
  buf B80(d_[24], d[24]);
  buf B81(d_[25], d[25]);
  buf B82(d_[26], d[26]);
  buf B83(d_[27], d[27]);
  buf B84(d_[28], d[28]);
  buf B85(d_[29], d[29]);
  buf B86(d_[30], d[30]);
  buf B87(d_[31], d[31]);
  buf B88(d_[32], d[32]);
  buf B89(d_[33], d[33]);
  buf B90(d_[34], d[34]);
  buf B91(d_[35], d[35]);
  buf B92(d_[36], d[36]);
  buf B93(d_[37], d[37]);
  buf B94(d_[38], d[38]);
  buf B95(d_[39], d[39]);
  buf B96(d_[40], d[40]);
  buf B97(d_[41], d[41]);
  buf B98(d_[42], d[42]);
  buf B99(d_[43], d[43]);
  buf B100(d_[44], d[44]);
  buf B101(d_[45], d[45]);
  buf B102(ema_[0], ema[0]);
  buf B103(ema_[1], ema[1]);
  buf B104(ema_[2], ema[2]);
  buf B105(emaw_[0], emaw[0]);
  buf B106(emaw_[1], emaw[1]);
  buf B107(emas_, emas);
  buf B108(ret1n_, ret1n);
  buf B109(wabl_, wabl);
  buf B110(wablm_[0], wablm[0]);
  buf B111(wablm_[1], wablm[1]);
  buf B112(rawl_, rawl);
  buf B113(rawlm_[0], rawlm[0]);
  buf B114(rawlm_[1], rawlm[1]);

   `ifdef ARM_FAULT_MODELING
     sram128x46_error_injection u1(.CLK(clk_), .Q_out(q_out), .A(a_int), .CEN(cen_int), .WEN(wen_int), .Q_in(q_int));
   `else
     assign q_out = q_int;
   `endif
  assign q_ = (ret1n_ | pre_charge_st) & ~corrupt_power ? ((q_out)) : {46{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial begin
  #ARM_LOCAL_OFFSET_TIME;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
// If INITIALIZE_OUTPUT is defined at Simulator Command Line, it Initializes the Output with Random value.

`ifdef INITIALIZE_OUTPUT
  initial
  begin
  #ARM_LOCAL_OFFSET_TIME;
	q_int = $random;
  end
`endif

  always @ (posedge clk_  ) begin
      if(ema_ !== ARM_REF_EMA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) && ~corrupt_power && ret1n_ === 1'b1 &&  (((cen_int === 1'b0 &&  clk_ === 1'b1) )   )) 
      $display("Warning: Set Value for ema is %d and is not equal to %d in %m at %0t. Please refer README for correct value of ema", ema_, ARM_REF_EMA_VALUE, $time);
  end
  always @ (posedge clk_ ) begin
      if(emaw_ !== ARM_REF_EMAW_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) && ~corrupt_power && ret1n_ === 1'b1 &&  (((cen_int === 1'b0 &&  clk_ === 1'b1) )   )) 
      $display("Warning: Set Value for emaw is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emaw", emaw_, ARM_REF_EMAW_VALUE, $time);
  end
  always @ (posedge clk_  ) begin
      if(emas_ !== ARM_REF_EMAS_VALUE  && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) && ~corrupt_power && ret1n_ === 1'b1 &&  (((cen_int === 1'b0 &&  clk_ === 1'b1) )   )) 
      $display("Warning: Set Value for emas is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emas", emas_, ARM_REF_EMAS_VALUE, $time);
  end

  task failedWrite;
  input port_f;
  integer i;
  begin
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'bx}};
  end
  endtask

  function isBitX;
    input bitval;
    begin
      isBitX = ( bitval===1'bx || bitval===1'bz ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        row_mask =  ( {1'b0, writeEnable[45], 1'b0, writeEnable[44], 1'b0, writeEnable[43],
          1'b0, writeEnable[42], 1'b0, writeEnable[41], 1'b0, writeEnable[40], 1'b0, writeEnable[39],
          1'b0, writeEnable[38], 1'b0, writeEnable[37], 1'b0, writeEnable[36], 1'b0, writeEnable[35],
          1'b0, writeEnable[34], 1'b0, writeEnable[33], 1'b0, writeEnable[32], 1'b0, writeEnable[31],
          1'b0, writeEnable[30], 1'b0, writeEnable[29], 1'b0, writeEnable[28], 1'b0, writeEnable[27],
          1'b0, writeEnable[26], 1'b0, writeEnable[25], 1'b0, writeEnable[24], 1'b0, writeEnable[23],
          1'b0, writeEnable[22], 1'b0, writeEnable[21], 1'b0, writeEnable[20], 1'b0, writeEnable[19],
          1'b0, writeEnable[18], 1'b0, writeEnable[17], 1'b0, writeEnable[16], 1'b0, writeEnable[15],
          1'b0, writeEnable[14], 1'b0, writeEnable[13], 1'b0, writeEnable[12], 1'b0, writeEnable[11],
          1'b0, writeEnable[10], 1'b0, writeEnable[9], 1'b0, writeEnable[8], 1'b0, writeEnable[7],
          1'b0, writeEnable[6], 1'b0, writeEnable[5], 1'b0, writeEnable[4], 1'b0, writeEnable[3],
          1'b0, writeEnable[2], 1'b0, writeEnable[1], 1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[45], 1'b0, wordtemp[44], 1'b0, wordtemp[43],
          1'b0, wordtemp[42], 1'b0, wordtemp[41], 1'b0, wordtemp[40], 1'b0, wordtemp[39],
          1'b0, wordtemp[38], 1'b0, wordtemp[37], 1'b0, wordtemp[36], 1'b0, wordtemp[35],
          1'b0, wordtemp[34], 1'b0, wordtemp[33], 1'b0, wordtemp[32], 1'b0, wordtemp[31],
          1'b0, wordtemp[30], 1'b0, wordtemp[29], 1'b0, wordtemp[28], 1'b0, wordtemp[27],
          1'b0, wordtemp[26], 1'b0, wordtemp[25], 1'b0, wordtemp[24], 1'b0, wordtemp[23],
          1'b0, wordtemp[22], 1'b0, wordtemp[21], 1'b0, wordtemp[20], 1'b0, wordtemp[19],
          1'b0, wordtemp[18], 1'b0, wordtemp[17], 1'b0, wordtemp[16], 1'b0, wordtemp[15],
          1'b0, wordtemp[14], 1'b0, wordtemp[13], 1'b0, wordtemp[12], 1'b0, wordtemp[11],
          1'b0, wordtemp[10], 1'b0, wordtemp[9], 1'b0, wordtemp[8], 1'b0, wordtemp[7],
          1'b0, wordtemp[6], 1'b0, wordtemp[5], 1'b0, wordtemp[4], 1'b0, wordtemp[3],
          1'b0, wordtemp[2], 1'b0, wordtemp[1], 1'b0, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  end
  endtask

task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[90], data_out[88], data_out[86], data_out[84], data_out[82],
          data_out[80], data_out[78], data_out[76], data_out[74], data_out[72], data_out[70],
          data_out[68], data_out[66], data_out[64], data_out[62], data_out[60], data_out[58],
          data_out[56], data_out[54], data_out[52], data_out[50], data_out[48], data_out[46],
          data_out[44], data_out[42], data_out[40], data_out[38], data_out[36], data_out[34],
          data_out[32], data_out[30], data_out[28], data_out[26], data_out[24], data_out[22],
          data_out[20], data_out[18], data_out[16], data_out[14], data_out[12], data_out[10],
          data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43],
          shifted_readLatch0[42], shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39],
          shifted_readLatch0[38], shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35],
          shifted_readLatch0[34], shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31],
          shifted_readLatch0[30], shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27],
          shifted_readLatch0[26], shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23],
          shifted_readLatch0[22], shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19],
          shifted_readLatch0[18], shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15],
          shifted_readLatch0[14], shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", q_int);
  end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [6:0] load_addr;
	input [45:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        row_mask =  ( {1'b0, writeEnable[45], 1'b0, writeEnable[44], 1'b0, writeEnable[43],
          1'b0, writeEnable[42], 1'b0, writeEnable[41], 1'b0, writeEnable[40], 1'b0, writeEnable[39],
          1'b0, writeEnable[38], 1'b0, writeEnable[37], 1'b0, writeEnable[36], 1'b0, writeEnable[35],
          1'b0, writeEnable[34], 1'b0, writeEnable[33], 1'b0, writeEnable[32], 1'b0, writeEnable[31],
          1'b0, writeEnable[30], 1'b0, writeEnable[29], 1'b0, writeEnable[28], 1'b0, writeEnable[27],
          1'b0, writeEnable[26], 1'b0, writeEnable[25], 1'b0, writeEnable[24], 1'b0, writeEnable[23],
          1'b0, writeEnable[22], 1'b0, writeEnable[21], 1'b0, writeEnable[20], 1'b0, writeEnable[19],
          1'b0, writeEnable[18], 1'b0, writeEnable[17], 1'b0, writeEnable[16], 1'b0, writeEnable[15],
          1'b0, writeEnable[14], 1'b0, writeEnable[13], 1'b0, writeEnable[12], 1'b0, writeEnable[11],
          1'b0, writeEnable[10], 1'b0, writeEnable[9], 1'b0, writeEnable[8], 1'b0, writeEnable[7],
          1'b0, writeEnable[6], 1'b0, writeEnable[5], 1'b0, writeEnable[4], 1'b0, writeEnable[3],
          1'b0, writeEnable[2], 1'b0, writeEnable[1], 1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[45], 1'b0, wordtemp[44], 1'b0, wordtemp[43],
          1'b0, wordtemp[42], 1'b0, wordtemp[41], 1'b0, wordtemp[40], 1'b0, wordtemp[39],
          1'b0, wordtemp[38], 1'b0, wordtemp[37], 1'b0, wordtemp[36], 1'b0, wordtemp[35],
          1'b0, wordtemp[34], 1'b0, wordtemp[33], 1'b0, wordtemp[32], 1'b0, wordtemp[31],
          1'b0, wordtemp[30], 1'b0, wordtemp[29], 1'b0, wordtemp[28], 1'b0, wordtemp[27],
          1'b0, wordtemp[26], 1'b0, wordtemp[25], 1'b0, wordtemp[24], 1'b0, wordtemp[23],
          1'b0, wordtemp[22], 1'b0, wordtemp[21], 1'b0, wordtemp[20], 1'b0, wordtemp[19],
          1'b0, wordtemp[18], 1'b0, wordtemp[17], 1'b0, wordtemp[16], 1'b0, wordtemp[15],
          1'b0, wordtemp[14], 1'b0, wordtemp[13], 1'b0, wordtemp[12], 1'b0, wordtemp[11],
          1'b0, wordtemp[10], 1'b0, wordtemp[9], 1'b0, wordtemp[8], 1'b0, wordtemp[7],
          1'b0, wordtemp[6], 1'b0, wordtemp[5], 1'b0, wordtemp[4], 1'b0, wordtemp[3],
          1'b0, wordtemp[2], 1'b0, wordtemp[1], 1'b0, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [45:0] dump_data;
	input [6:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [6:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cen_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 1'b1);
      row_address = (Atemp >> 1);
      row = mem[row_address];
        writeEnable = {46{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[90], data_out[88], data_out[86], data_out[84], data_out[82],
          data_out[80], data_out[78], data_out[76], data_out[74], data_out[72], data_out[70],
          data_out[68], data_out[66], data_out[64], data_out[62], data_out[60], data_out[58],
          data_out[56], data_out[54], data_out[52], data_out[50], data_out[48], data_out[46],
          data_out[44], data_out[42], data_out[40], data_out[38], data_out[36], data_out[34],
          data_out[32], data_out[30], data_out[28], data_out[26], data_out[24], data_out[22],
          data_out[20], data_out[18], data_out[16], data_out[14], data_out[12], data_out[10],
          data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43],
          shifted_readLatch0[42], shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39],
          shifted_readLatch0[38], shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35],
          shifted_readLatch0[34], shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31],
          shifted_readLatch0[30], shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27],
          shifted_readLatch0[26], shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23],
          shifted_readLatch0[22], shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19],
          shifted_readLatch0[18], shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15],
          shifted_readLatch0[14], shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
   	dump_data = q_int;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWrite;
  begin
    if (rawl_ === 1'bx)
      d_int = {46{1'bx}};
    if (^rawlm_ === 1'bx)
      d_int = {46{1'bx}};
    if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_int === 1'b0 && cen_int === 1'b0) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{cen_int, ema_int, emaw_int, emas_int, ret1n_int, wabl_int, wablm_int, rawl_int, rawlm_int} === 1'bx) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if ((a_int >= WORDS) && (cen_int === 1'b0)) begin
      q_int = wen_int !== 1'b1 ? q_int : {46{1'bx}};
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
     if (wen_int !== 1)
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (cen_int === 1'b0) begin
      mux_address = (a_int & 1'b1);
      row_address = (a_int >> 1);
      if (row_address > 63)
        row = {92{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {46{wen_int}};
      if (wen_int !== 1'b1) begin
        row_mask =  ( {1'b0, writeEnable[45], 1'b0, writeEnable[44], 1'b0, writeEnable[43],
          1'b0, writeEnable[42], 1'b0, writeEnable[41], 1'b0, writeEnable[40], 1'b0, writeEnable[39],
          1'b0, writeEnable[38], 1'b0, writeEnable[37], 1'b0, writeEnable[36], 1'b0, writeEnable[35],
          1'b0, writeEnable[34], 1'b0, writeEnable[33], 1'b0, writeEnable[32], 1'b0, writeEnable[31],
          1'b0, writeEnable[30], 1'b0, writeEnable[29], 1'b0, writeEnable[28], 1'b0, writeEnable[27],
          1'b0, writeEnable[26], 1'b0, writeEnable[25], 1'b0, writeEnable[24], 1'b0, writeEnable[23],
          1'b0, writeEnable[22], 1'b0, writeEnable[21], 1'b0, writeEnable[20], 1'b0, writeEnable[19],
          1'b0, writeEnable[18], 1'b0, writeEnable[17], 1'b0, writeEnable[16], 1'b0, writeEnable[15],
          1'b0, writeEnable[14], 1'b0, writeEnable[13], 1'b0, writeEnable[12], 1'b0, writeEnable[11],
          1'b0, writeEnable[10], 1'b0, writeEnable[9], 1'b0, writeEnable[8], 1'b0, writeEnable[7],
          1'b0, writeEnable[6], 1'b0, writeEnable[5], 1'b0, writeEnable[4], 1'b0, writeEnable[3],
          1'b0, writeEnable[2], 1'b0, writeEnable[1], 1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, d_int[45], 1'b0, d_int[44], 1'b0, d_int[43], 1'b0, d_int[42],
          1'b0, d_int[41], 1'b0, d_int[40], 1'b0, d_int[39], 1'b0, d_int[38], 1'b0, d_int[37],
          1'b0, d_int[36], 1'b0, d_int[35], 1'b0, d_int[34], 1'b0, d_int[33], 1'b0, d_int[32],
          1'b0, d_int[31], 1'b0, d_int[30], 1'b0, d_int[29], 1'b0, d_int[28], 1'b0, d_int[27],
          1'b0, d_int[26], 1'b0, d_int[25], 1'b0, d_int[24], 1'b0, d_int[23], 1'b0, d_int[22],
          1'b0, d_int[21], 1'b0, d_int[20], 1'b0, d_int[19], 1'b0, d_int[18], 1'b0, d_int[17],
          1'b0, d_int[16], 1'b0, d_int[15], 1'b0, d_int[14], 1'b0, d_int[13], 1'b0, d_int[12],
          1'b0, d_int[11], 1'b0, d_int[10], 1'b0, d_int[9], 1'b0, d_int[8], 1'b0, d_int[7],
          1'b0, d_int[6], 1'b0, d_int[5], 1'b0, d_int[4], 1'b0, d_int[3], 1'b0, d_int[2],
          1'b0, d_int[1], 1'b0, d_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[90], data_out[88], data_out[86], data_out[84], data_out[82],
          data_out[80], data_out[78], data_out[76], data_out[74], data_out[72], data_out[70],
          data_out[68], data_out[66], data_out[64], data_out[62], data_out[60], data_out[58],
          data_out[56], data_out[54], data_out[52], data_out[50], data_out[48], data_out[46],
          data_out[44], data_out[42], data_out[40], data_out[38], data_out[36], data_out[34],
          data_out[32], data_out[30], data_out[28], data_out[26], data_out[24], data_out[22],
          data_out[20], data_out[18], data_out[16], data_out[14], data_out[12], data_out[10],
          data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43],
          shifted_readLatch0[42], shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39],
          shifted_readLatch0[38], shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35],
          shifted_readLatch0[34], shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31],
          shifted_readLatch0[30], shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27],
          shifted_readLatch0[26], shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23],
          shifted_readLatch0[22], shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19],
          shifted_readLatch0[18], shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15],
          shifted_readLatch0[14], shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11],
          shifted_readLatch0[10], shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7],
          shifted_readLatch0[6], shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3],
          shifted_readLatch0[2], shifted_readLatch0[1], shifted_readLatch0[0]};
      end
    if (rawl_ === 1'bx)
        q_int = {46{1'bx}};
    if (^rawlm_ === 1'bx)
        q_int = {46{1'bx}};
      if( isBitX(wen_int) ) begin
        q_int = {46{1'bx}};
      end
    end
  end
  endtask
  always @ (cen_ or clk_) begin
  	if(clk_ == 1'b0) begin
  		cen_p2 = cen_;
  	end
  end

`ifndef ARM_MONORAIL
`ifdef POWER_PINS
  always @ (posedge VDDCE or negedge VDDCE) begin
      if (VDDCE != 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDCE should be powered down after VDDPE, Illegal power down sequencing in %m at %0t", $time);
       end
        $display("In PowerDown Mode in %m at %0t", $time);
        failedWrite(0);
      end
      if (VDDCE == 1'b1) begin
       if (VDDPE == 1'b1) begin
        $display("VDDPE should be powered up after VDDCE in %m at %0t", $time);
        $display("Illegal power up sequencing in %m at %0t", $time);
       end
        failedWrite(0);
      end
  end
`endif
`endif
`ifdef POWER_PINS
  always @ (ret1n_ or VDDPE or VDDCE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st == 1'b1 && (cen_ === 1'bx || clk_ === 1'bx)) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
      q_int = {46{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {46{1'bx}};
      ema_int = {3{1'bx}};
      emaw_int = {2{1'bx}};
      emas_int = 1'bx;
      ret1n_int = 1'bx;
      wabl_int = 1'bx;
      wablm_int = {2{1'bx}};
      rawl_int = 1'bx;
      rawlm_int = {2{1'bx}};
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st == 1'b1) begin
      pre_charge_st = 0;
    end else begin
      pre_charge_st = 0;
`else     
    end else begin
`endif
        q_int = {46{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {46{1'bx}};
      ema_int = {3{1'bx}};
      emaw_int = {2{1'bx}};
      emas_int = 1'bx;
      ret1n_int = 1'bx;
      wabl_int = 1'bx;
      wablm_int = {2{1'bx}};
      rawl_int = 1'bx;
      rawlm_int = {2{1'bx}};
    end
    ret1n_int = ret1n_;
  end


  always @ clk_ begin
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
`endif
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
      // no cycle in retention mode
  end else begin
    if ((clk_ === 1'bx || clk_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(0);
        q_int = {46{1'bx}};
    end else if (clk_ === 1'b1 && LAST_clk === 1'b0) begin
      cen_int = cen_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      if (cen_int != 1'b1) begin
        wen_int = wen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      cen_int = cen_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      if (cen_int != 1'b1) begin
        wen_int = wen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
    readWrite;
    end else if (clk_ === 1'b0 && LAST_clk === 1'b1) begin
    end
  end
    LAST_clk = clk_;
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (cen_int === 1'bx || clk0_int === 1'bx || ema_int[0] === 1'bx || 
      ema_int[1] === 1'bx || ema_int[2] === 1'bx || emas_int === 1'bx || emaw_int[0] === 1'bx || 
      emaw_int[1] === 1'bx || rawl_int === 1'bx || rawlm_int[0] === 1'bx || rawlm_int[1] === 1'bx || 
      ret1n_int === 1'bx || wabl_int === 1'bx || wablm_int[0] === 1'bx || wablm_int[1] === 1'bx) begin
        q_int = {46{1'bx}};
      failedWrite(0);
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
        failedWrite(0);
        q_int = {46{1'bx}};
    end else begin
      #0;#0;
      readWrite;
   end
    globalNotifier0 = 1'b0;
  end
reg clk_s;

always @ (clk_)
    clk_s <= clk_;

// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
	always @ (VDDCE or VDDPE or VSSE or clk_s) begin
		if (VDDCE !== 1'b1) begin
			$display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
        q_int = {46{1'bx}};
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (VDDPE !== 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        q_int = {46{1'bx}};
		if (ret1n_ !== 1'b0)
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE !== 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        q_int = {46{1'bx}};
			failedWrite(0);
			bad_VSSE = 1'b1;
		end else begin
			bad_VSSE = 1'b0;
		end
		bad_power = bad_VDDCE | bad_VDDPE | bad_VSSE ;
	end
`endif

  always @ NOT_cen begin
    cen_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_wen begin
    wen_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a6 begin
    a_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a5 begin
    a_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a4 begin
    a_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a3 begin
    a_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a2 begin
    a_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a1 begin
    a_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a0 begin
    a_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d45 begin
    d_int[45] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d44 begin
    d_int[44] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d43 begin
    d_int[43] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d42 begin
    d_int[42] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d41 begin
    d_int[41] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d40 begin
    d_int[40] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d39 begin
    d_int[39] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d38 begin
    d_int[38] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d37 begin
    d_int[37] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d36 begin
    d_int[36] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d35 begin
    d_int[35] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d34 begin
    d_int[34] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d33 begin
    d_int[33] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d32 begin
    d_int[32] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d31 begin
    d_int[31] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d30 begin
    d_int[30] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d29 begin
    d_int[29] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d28 begin
    d_int[28] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d27 begin
    d_int[27] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d26 begin
    d_int[26] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d25 begin
    d_int[25] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d24 begin
    d_int[24] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d23 begin
    d_int[23] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d22 begin
    d_int[22] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d21 begin
    d_int[21] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d20 begin
    d_int[20] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d19 begin
    d_int[19] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d18 begin
    d_int[18] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d17 begin
    d_int[17] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d16 begin
    d_int[16] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d15 begin
    d_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d14 begin
    d_int[14] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d13 begin
    d_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d12 begin
    d_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d11 begin
    d_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d10 begin
    d_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d9 begin
    d_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d8 begin
    d_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d7 begin
    d_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d6 begin
    d_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d5 begin
    d_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d4 begin
    d_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d3 begin
    d_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d2 begin
    d_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d1 begin
    d_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d0 begin
    d_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_ema2 begin
    ema_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_ema1 begin
    ema_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_ema0 begin
    ema_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emaw1 begin
    emaw_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emaw0 begin
    emaw_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emas begin
    emas_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_ret1n begin
    ret1n_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_wabl begin
    wabl_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_wablm1 begin
    wablm_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_wablm0 begin
    wablm_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_rawl begin
    rawl_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_rawlm1 begin
    rawlm_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_rawlm0 begin
    rawlm_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end

  always @ NOT_clk_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_clk_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_clk_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end



  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire ret1neq1, rawleq1awableq1aret1neq1aceneq0, rawleq0awableq1aret1neq1aceneq0;
  wire rawleq1awableq0aret1neq1aceneq0, rawleq0awableq0aret1neq1aceneq0, ret1neq1aceneq0aweneq0;
  wire ret1neq1aceneq0;

  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;


  assign rawleq1awableq1aret1neq1aceneq0 = rawl&&wabl&&ret1n&&!cen;
  assign rawleq0awableq1aret1neq1aceneq0 = !rawl&&wabl&&ret1n&&!cen;
  assign rawleq1awableq0aret1neq1aceneq0 = rawl&&!wabl&&ret1n&&!cen;
  assign rawleq0awableq0aret1neq1aceneq0 = !rawl&&!wabl&&ret1n&&!cen;
  assign ret1neq1aceneq0aweneq0 = ret1n&&!cen&&!wen;

  assign ret1neq1 = ret1n;
  assign ret1neq1aceneq0 = ret1n&&!cen;

  specify

    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge clk, `ARM_MEM_PERIOD, NOT_clk_PER);
   `else
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& ret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
   `endif


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge clk, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(negedge clk, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
   `else
       $width(posedge clk &&& ret1neq1, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(negedge clk &&& ret1neq1, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
   `endif

    $setuphold(posedge clk &&& ret1neq1, posedge cen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cen);
    $setuphold(posedge clk &&& ret1neq1, negedge cen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cen);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge wen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wen);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge wen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wen);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[45], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d45);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[44], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d44);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[43], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d43);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[42], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d42);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[41], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d41);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[40], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d40);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[39], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d39);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[38], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d38);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[37], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d37);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[36], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d36);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[35], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d35);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[34], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d34);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[33], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d33);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[32], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d32);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[31], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d31);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[30], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d30);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[29], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d29);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[28], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d28);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[27], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d27);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[26], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d26);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[25], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d25);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[24], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d24);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[23], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d23);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[22], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d22);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[21], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d21);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[20], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d20);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[19], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d19);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[18], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d18);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[17], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d17);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[16], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d16);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d15);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d14);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d13);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d12);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d11);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d10);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d9);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d8);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d7);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d6);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d5);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d4);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d3);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d2);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d1);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d0);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[45], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d45);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[44], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d44);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[43], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d43);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[42], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d42);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[41], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d41);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[40], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d40);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[39], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d39);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[38], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d38);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[37], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d37);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[36], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d36);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[35], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d35);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[34], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d34);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[33], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d33);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[32], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d32);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[31], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d31);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[30], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d30);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[29], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d29);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[28], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d28);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[27], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d27);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[26], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d26);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[25], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d25);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[24], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d24);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[23], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d23);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[22], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d22);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[21], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d21);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[20], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d20);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[19], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d19);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[18], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d18);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[17], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d17);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[16], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d16);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d15);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d14);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d13);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d12);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d11);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d10);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d9);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d8);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d7);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d6);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d5);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d4);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d3);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d2);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d1);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge ema[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema2);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge ema[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge ema[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge ema[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema2);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge ema[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge ema[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge emaw[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge emaw[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge emaw[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge emaw[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge emas, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emas);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge emas, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emas);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge wabl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wabl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge wabl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wabl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge wablm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge wablm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge wablm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge wablm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawlm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawlm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawlm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawlm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm0);
    $setuphold(negedge ret1n, negedge cen, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge ret1n, negedge cen, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cen, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cen, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
  endspecify


endmodule
`endcelldefine
`endif
`timescale 1ns/1ps
`ifdef ARM_FAULT_MODELING
module sram128x46_error_injection (Q_out, Q_in, CLK, A, CEN, WEN);
   output [45:0] Q_out;
   input [45:0] Q_in;
   input CLK;
   input [6:0] A;
   input CEN;
   input WEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [45:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [17:0] fault_table [63:0];
   reg [17:0] fault_entry;
initial
begin
   `ifdef sram128x46_pre_pend_path
      `define pre_pend_path `sram128x46_pre_pend_path
   `else
      `ifdef DUT
         `define pre_pend_path TB.DUT_inst.CHIP.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST
      `else
          `define pre_pend_path TB.CHIP.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST
      `endif
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.u1.add_fault(7'd2,6'd0,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [6:0] address;
      input [5:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 63)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[10:5] = bitPlace;
            fault_entry[17:11] = address;
            fault_table[i] = fault_entry;
            done = 1'b1;
         end
         i = i+1;
      end
   end
   endtask
//This task removes all fault entries injected by user
task remove_all_faults;
   integer i;
begin
   for (i = 0; i < 64; i=i+1)
   begin
      fault_entry = fault_table[i];
      fault_entry[0] = 1'b0;
      fault_table[i] = fault_entry;
   end
end
endtask
task bit_error;
// This task is used to inject error in memory and should be called
// only from current module.
//
// This task injects error depending upon fault type to particular bit
// of the output
   inout [45:0] q_int;
   input [1:0] fault_type;
   input [5:0] bitLoc;
begin
   if (fault_type === 2'd0)
      q_int[bitLoc] = 1'b0;
   else if (fault_type === 2'd1)
      q_int[bitLoc] = 1'b1;
   else
      q_int[bitLoc] = ~q_int[bitLoc];
end
endtask
task error_injection_on_output;
// This function goes through error injection table for every
// read cycle and corrupts Q output if fault for the particular
// address is present in fault table
//
// If fault is redundant column is detected, this task corrupts
// Q output in read cycle
//
// If fault is repaired using repair bus, this task does not
// courrpt Q output in read cycle
//
   output [45:0] Q_output;
   reg list_complete;
   integer i;
   reg [5:0] row_address;
   reg [0:0] column_address;
   reg [5:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
   reg [4:0] msb_bit_calc;
begin
   entry_found = 1'b0;
   list_complete = 1'b0;
   i = 0;
   Q_output = Q_in;
   while(!list_complete)
   begin
      fault_entry = fault_table[i];
      {row_address, column_address, bitPlace, fault_type, red_fault, valid} = fault_entry;
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault === NO_RED_FAULT)
         begin
            if (row_address == A[6:1] && column_address == A[0:0])
            begin
               if (bitPlace < 22)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 22 )
                  bit_error(Q_output,fault_type, bitPlace);
            end
         end
      end
      else
         list_complete = 1'b1;
      end
   end
   endtask
   always @ (Q_in or CLK or A or CEN or WEN)
   begin
   if (CEN === 1'b0 && &WEN === 1'b1)
      error_injection_on_output(Q_out);
   else
      Q_out = Q_in;
   end
endmodule
`endif
