/* verilog_memcomp Version: p3.26.32-EAC */
/* common_memcomp Version: p3.26.32-EAC */
/* lang compiler Version: 4.14.4-EAC Mar 31 2020 06:59:59 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF Arm, INC.
//      
//       Copyright (c) 1993 - 2026 Arm, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with Arm, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for Synchronous Single-Port Ram
//
//       Instance Name:              sramsp_4096_64
//       Words:                      4096
//       Bits:                       64
//       Mux:                        16
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
//       Extra Margin Adjustment:    On
//       Redundany:                  Off
//       Test Muxes                  Off
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Thu May 28 21:08:13 2026
//       Version: 	r1p0
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

  `define SRAM_SP_HDE_SVT_MVT_ARM_REF_EMA_VALUE   4
  `define SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAW_VALUE  1
  `define SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAS_VALUE  0 //修改为svt推荐值


module datapath_latch_sramsp_4096_64 (CLK,Q_update,D_update,SE,SI,D,DFTRAMBYP,mem_path,XQ,Q);
	input CLK,Q_update,D_update,SE,SI,D,DFTRAMBYP,mem_path,XQ;
	output Q;

	reg    D_int;
	reg    Q;

   //  Model PHI2 portion
   always @(CLK or SE or SI or D) begin
      if (CLK === 1'b0) begin
         if (SE===1'b1)
           D_int=SI;
         else if (SE===1'bx)
           D_int=1'bx;
         else
           D_int=D;
      end
   end

   // model output side of RAM latch
   always @(posedge Q_update or posedge D_update or mem_path or posedge XQ) begin
      if (XQ===1'b0) begin
         if (DFTRAMBYP===1'b1)
           Q=D_int;
         else
           Q=mem_path;
      end
      else
        Q=1'bx;
   end
endmodule // datapath_latch_sramsp_4096_64

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
module sramsp_4096_64 (VDDCE, VDDPE, VSSE, q, clk, cen, gwen, a, d, stov, ema, emaw, 
    emas, ret1n, rawl, rawlm, wabl, wablm);
`else
module sramsp_4096_64 (q, clk, cen, gwen, a, d, stov, ema, emaw, emas, ret1n, rawl, 
    rawlm, wabl, wablm);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 64;
  parameter WORDS = 4096;
  parameter MUX = 16;
  parameter MEM_WIDTH = 1024; // redun block size 16, 512 on left, 512 on right
  parameter MEM_HEIGHT = 256;
  parameter WP_SIZE = 64 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;
  parameter UPMP_WIDTH = 0;
  parameter ARM_DUMMY_CYCLE_WIDTH = `ARM_MEM_WIDTH;
  parameter ARM_LOCAL_OFFSET_TIME = `ARM_OFFSET_TIME;

`ifdef ARM_DISABLE_EMA_CHECK
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 1;
`else
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 0;
`endif

  parameter ARM_REF_EMA_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMA_VALUE;
  parameter ARM_REF_EMAW_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAW_VALUE;
  parameter ARM_REF_EMAS_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAS_VALUE;
  parameter ROWS = 256;

  output [63:0] q;
  input  clk;
  input  cen;
  input  gwen;
  input [11:0] a;
  input [63:0] d;
  input  stov;
  input [2:0] ema;
  input [1:0] emaw;
  input  emas;
  input  ret1n;
  input  rawl;
  input [1:0] rawlm;
  input  wabl;
  input [1:0] wablm;
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
  reg pre_charge_st;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [1023:0] row, row_t;
  reg LAST_clk;
  reg [1023:0] mem [0:255];
  reg [1023:0] row_mask;
  reg [1023:0] new_data;
  reg [1023:0] data_out;
  reg [63:0] readLatch0;
  reg [63:0] shifted_readLatch0;
  wire [63:0] q_int;
  reg [63:0] q_int_delayed;
  reg Xq, q_update;
  reg Xd_sh, d_sh_update;
  wire [63:0] d_int_bmux;
  reg [63:0] mem_path;
  reg [63:0] mem_path_d;
  reg [63:0] writeEnable;
  reg clk0_int;

  wire [63:0] q_;
  wire [63:0] q_out;

 wire  clk_;
  wire  cen_;
  reg  cen_int;
  reg  cen_p2;
  wire  gwen_;
  reg  gwen_int;
  wire [11:0] a_;
  reg [11:0] a_int;
  wire [63:0] d_;
  reg [63:0] d_int;
  reg [63:0] Xd_int;
  wire  stov_;
  reg  stov_int;
  wire [2:0] ema_;
  reg [2:0] ema_int;
  wire [1:0] emaw_;
  reg [1:0] emaw_int;
  wire  emas_;
  reg  emas_int;
  wire  ret1n_;
  reg  ret1n_int;
  wire  rawl_;
  reg  rawl_int;
  wire [1:0] rawlm_;
  reg [1:0] rawlm_int;
  wire  wabl_;
  reg  wabl_int;
  wire [1:0] wablm_;
  reg [1:0] wablm_int;

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
  assign q[46] = q_[46]; 
  assign q[47] = q_[47]; 
  assign q[48] = q_[48]; 
  assign q[49] = q_[49]; 
  assign q[50] = q_[50]; 
  assign q[51] = q_[51]; 
  assign q[52] = q_[52]; 
  assign q[53] = q_[53]; 
  assign q[54] = q_[54]; 
  assign q[55] = q_[55]; 
  assign q[56] = q_[56]; 
  assign q[57] = q_[57]; 
  assign q[58] = q_[58]; 
  assign q[59] = q_[59]; 
  assign q[60] = q_[60]; 
  assign q[61] = q_[61]; 
  assign q[62] = q_[62]; 
  assign q[63] = q_[63]; 
  assign clk_ = clk;
  assign cen_ = cen;
  assign gwen_ = gwen;
  assign a_[0] = a[0];
  assign a_[1] = a[1];
  assign a_[2] = a[2];
  assign a_[3] = a[3];
  assign a_[4] = a[4];
  assign a_[5] = a[5];
  assign a_[6] = a[6];
  assign a_[7] = a[7];
  assign a_[8] = a[8];
  assign a_[9] = a[9];
  assign a_[10] = a[10];
  assign a_[11] = a[11];
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
  assign d_[46] = d[46];
  assign d_[47] = d[47];
  assign d_[48] = d[48];
  assign d_[49] = d[49];
  assign d_[50] = d[50];
  assign d_[51] = d[51];
  assign d_[52] = d[52];
  assign d_[53] = d[53];
  assign d_[54] = d[54];
  assign d_[55] = d[55];
  assign d_[56] = d[56];
  assign d_[57] = d[57];
  assign d_[58] = d[58];
  assign d_[59] = d[59];
  assign d_[60] = d[60];
  assign d_[61] = d[61];
  assign d_[62] = d[62];
  assign d_[63] = d[63];
  assign stov_ = stov;
  assign ema_[0] = ema[0];
  assign ema_[1] = ema[1];
  assign ema_[2] = ema[2];
  assign emaw_[0] = emaw[0];
  assign emaw_[1] = emaw[1];
  assign emas_ = emas;
  assign ret1n_ = ret1n;
  assign rawl_ = rawl;
  assign rawlm_[0] = rawlm[0];
  assign rawlm_[1] = rawlm[1];
  assign wabl_ = wabl;
  assign wablm_[0] = wablm[0];
  assign wablm_[1] = wablm[1];

`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

   `ifdef ARM_FAULT_MODELING
     sramsp_4096_64_error_injection u1(.CLK(clk_), .Q_out(q_out), .A(a_int), .CEN(cen_int), .GWEN(gwen_int), .WEN(gwen_int), .Q_in(q_int));
  `else
   assign q_out = q_int;
  `endif
  assign `ARM_UD_SEQ q_ = (ret1n_ | pre_charge_st) & ~corrupt_power ? ((stov_ ? (q_int_delayed) : (q_out))) : {64{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
  begin
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
	uDQ0.Q = $random;
	uDQ1.Q = $random;
	uDQ2.Q = $random;
	uDQ3.Q = $random;
	uDQ4.Q = $random;
	uDQ5.Q = $random;
	uDQ6.Q = $random;
	uDQ7.Q = $random;
	uDQ8.Q = $random;
	uDQ9.Q = $random;
	uDQ10.Q = $random;
	uDQ11.Q = $random;
	uDQ12.Q = $random;
	uDQ13.Q = $random;
	uDQ14.Q = $random;
	uDQ15.Q = $random;
	uDQ16.Q = $random;
	uDQ17.Q = $random;
	uDQ18.Q = $random;
	uDQ19.Q = $random;
	uDQ20.Q = $random;
	uDQ21.Q = $random;
	uDQ22.Q = $random;
	uDQ23.Q = $random;
	uDQ24.Q = $random;
	uDQ25.Q = $random;
	uDQ26.Q = $random;
	uDQ27.Q = $random;
	uDQ28.Q = $random;
	uDQ29.Q = $random;
	uDQ30.Q = $random;
	uDQ31.Q = $random;
	uDQ32.Q = $random;
	uDQ33.Q = $random;
	uDQ34.Q = $random;
	uDQ35.Q = $random;
	uDQ36.Q = $random;
	uDQ37.Q = $random;
	uDQ38.Q = $random;
	uDQ39.Q = $random;
	uDQ40.Q = $random;
	uDQ41.Q = $random;
	uDQ42.Q = $random;
	uDQ43.Q = $random;
	uDQ44.Q = $random;
	uDQ45.Q = $random;
	uDQ46.Q = $random;
	uDQ47.Q = $random;
	uDQ48.Q = $random;
	uDQ49.Q = $random;
	uDQ50.Q = $random;
	uDQ51.Q = $random;
	uDQ52.Q = $random;
	uDQ53.Q = $random;
	uDQ54.Q = $random;
	uDQ55.Q = $random;
	uDQ56.Q = $random;
	uDQ57.Q = $random;
	uDQ58.Q = $random;
	uDQ59.Q = $random;
	uDQ60.Q = $random;
	uDQ61.Q = $random;
	uDQ62.Q = $random;
	uDQ63.Q = $random;

  end
`endif

  always @ (posedge clk_) begin
      if(ema_ !== ARM_REF_EMA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for ema is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of ema", ema_, ARM_REF_EMA_VALUE, $time);
  end
  always @ (posedge clk_) begin
      if(emaw_ !== ARM_REF_EMAW_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for emaw is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of emaw", emaw_, ARM_REF_EMAW_VALUE, $time);
  end
  always @ (posedge clk_) begin
      if(emas_ !== ARM_REF_EMAS_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for emas is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of emas", emas_, ARM_REF_EMAS_VALUE, $time);
  end
	always @ (stov_) begin
		if(clk_ == 1'b1) begin
			Xq = 1'b1; q_update = 1'b1;
			#0; q_update = 1'b0;
			Xq = 1'b0;
		end
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
	reg [11:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[63], 15'b000000000000000, wordtemp[62],
          15'b000000000000000, wordtemp[61], 15'b000000000000000, wordtemp[60], 15'b000000000000000, wordtemp[59],
          15'b000000000000000, wordtemp[58], 15'b000000000000000, wordtemp[57], 15'b000000000000000, wordtemp[56],
          15'b000000000000000, wordtemp[55], 15'b000000000000000, wordtemp[54], 15'b000000000000000, wordtemp[53],
          15'b000000000000000, wordtemp[52], 15'b000000000000000, wordtemp[51], 15'b000000000000000, wordtemp[50],
          15'b000000000000000, wordtemp[49], 15'b000000000000000, wordtemp[48], 15'b000000000000000, wordtemp[47],
          15'b000000000000000, wordtemp[46], 15'b000000000000000, wordtemp[45], 15'b000000000000000, wordtemp[44],
          15'b000000000000000, wordtemp[43], 15'b000000000000000, wordtemp[42], 15'b000000000000000, wordtemp[41],
          15'b000000000000000, wordtemp[40], 15'b000000000000000, wordtemp[39], 15'b000000000000000, wordtemp[38],
          15'b000000000000000, wordtemp[37], 15'b000000000000000, wordtemp[36], 15'b000000000000000, wordtemp[35],
          15'b000000000000000, wordtemp[34], 15'b000000000000000, wordtemp[33], 15'b000000000000000, wordtemp[32],
          15'b000000000000000, wordtemp[31], 15'b000000000000000, wordtemp[30], 15'b000000000000000, wordtemp[29],
          15'b000000000000000, wordtemp[28], 15'b000000000000000, wordtemp[27], 15'b000000000000000, wordtemp[26],
          15'b000000000000000, wordtemp[25], 15'b000000000000000, wordtemp[24], 15'b000000000000000, wordtemp[23],
          15'b000000000000000, wordtemp[22], 15'b000000000000000, wordtemp[21], 15'b000000000000000, wordtemp[20],
          15'b000000000000000, wordtemp[19], 15'b000000000000000, wordtemp[18], 15'b000000000000000, wordtemp[17],
          15'b000000000000000, wordtemp[16], 15'b000000000000000, wordtemp[15], 15'b000000000000000, wordtemp[14],
          15'b000000000000000, wordtemp[13], 15'b000000000000000, wordtemp[12], 15'b000000000000000, wordtemp[11],
          15'b000000000000000, wordtemp[10], 15'b000000000000000, wordtemp[9], 15'b000000000000000, wordtemp[8],
          15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6], 15'b000000000000000, wordtemp[5],
          15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3], 15'b000000000000000, wordtemp[2],
          15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
`ifdef ARM_BACKDOOR_NOCEN
`else
    end
`endif
  end
  endtask

  task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	 for (i=0;i<WORDS;i=i+1) begin
	 Atemp = i;
	 mux_address = (Atemp & 4'b1111);
      row_address = (Atemp >> 4);
      row = mem[row_address];
        writeEnable = {64{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_d = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", mem_path_d);
     end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [11:0] load_addr;
	input [63:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[63], 15'b000000000000000, wordtemp[62],
          15'b000000000000000, wordtemp[61], 15'b000000000000000, wordtemp[60], 15'b000000000000000, wordtemp[59],
          15'b000000000000000, wordtemp[58], 15'b000000000000000, wordtemp[57], 15'b000000000000000, wordtemp[56],
          15'b000000000000000, wordtemp[55], 15'b000000000000000, wordtemp[54], 15'b000000000000000, wordtemp[53],
          15'b000000000000000, wordtemp[52], 15'b000000000000000, wordtemp[51], 15'b000000000000000, wordtemp[50],
          15'b000000000000000, wordtemp[49], 15'b000000000000000, wordtemp[48], 15'b000000000000000, wordtemp[47],
          15'b000000000000000, wordtemp[46], 15'b000000000000000, wordtemp[45], 15'b000000000000000, wordtemp[44],
          15'b000000000000000, wordtemp[43], 15'b000000000000000, wordtemp[42], 15'b000000000000000, wordtemp[41],
          15'b000000000000000, wordtemp[40], 15'b000000000000000, wordtemp[39], 15'b000000000000000, wordtemp[38],
          15'b000000000000000, wordtemp[37], 15'b000000000000000, wordtemp[36], 15'b000000000000000, wordtemp[35],
          15'b000000000000000, wordtemp[34], 15'b000000000000000, wordtemp[33], 15'b000000000000000, wordtemp[32],
          15'b000000000000000, wordtemp[31], 15'b000000000000000, wordtemp[30], 15'b000000000000000, wordtemp[29],
          15'b000000000000000, wordtemp[28], 15'b000000000000000, wordtemp[27], 15'b000000000000000, wordtemp[26],
          15'b000000000000000, wordtemp[25], 15'b000000000000000, wordtemp[24], 15'b000000000000000, wordtemp[23],
          15'b000000000000000, wordtemp[22], 15'b000000000000000, wordtemp[21], 15'b000000000000000, wordtemp[20],
          15'b000000000000000, wordtemp[19], 15'b000000000000000, wordtemp[18], 15'b000000000000000, wordtemp[17],
          15'b000000000000000, wordtemp[16], 15'b000000000000000, wordtemp[15], 15'b000000000000000, wordtemp[14],
          15'b000000000000000, wordtemp[13], 15'b000000000000000, wordtemp[12], 15'b000000000000000, wordtemp[11],
          15'b000000000000000, wordtemp[10], 15'b000000000000000, wordtemp[9], 15'b000000000000000, wordtemp[8],
          15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6], 15'b000000000000000, wordtemp[5],
          15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3], 15'b000000000000000, wordtemp[2],
          15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask

  task dumpaddr;
	output [63:0] dump_data;
	input [11:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_d = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
   	dump_data = mem_path_d;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWrite;
  begin
    if (wabl_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (^wablm_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (rawl_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (^rawlm_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if (ret1n_int === 1'b0 && cen_int === 1'b0) begin
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(ema_int), (emaw_int), (emas_int)} === 1'bx) begin
  if(isBitX(emas_int)) begin 
        Xq = 1'b1; q_update = 1'b1;
  end
  if(isBitX(emaw_int) && cen_int === 1'b0) begin 
    if (gwen_int === 1'b0)
      failedWrite(0);
  end
  if(isBitX(ema_int)) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
  end
    end else if (^{cen_int, (stov_int && !cen_int), rawl_int, rawlm_int, wabl_int, wablm_int} === 1'bx) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if ((a_int >= WORDS) && (cen_int === 1'b0)) begin
        Xq = gwen_int !== 1'b1 ? 1'b0 : 1'b1; q_update = gwen_int !== 1'b1 ? 1'b0 : 1'b1;
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
      if (gwen_int !== 1'b1)
        failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if (cen_int === 1'b0) begin
      mux_address = (a_int & 4'b1111);
      row_address = (a_int >> 4);
      if (row_address > 255)
        row = {1024{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {64{gwen_int}};
      if (gwen_int !== 1'b1) begin
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, d_int[63], 15'b000000000000000, d_int[62],
          15'b000000000000000, d_int[61], 15'b000000000000000, d_int[60], 15'b000000000000000, d_int[59],
          15'b000000000000000, d_int[58], 15'b000000000000000, d_int[57], 15'b000000000000000, d_int[56],
          15'b000000000000000, d_int[55], 15'b000000000000000, d_int[54], 15'b000000000000000, d_int[53],
          15'b000000000000000, d_int[52], 15'b000000000000000, d_int[51], 15'b000000000000000, d_int[50],
          15'b000000000000000, d_int[49], 15'b000000000000000, d_int[48], 15'b000000000000000, d_int[47],
          15'b000000000000000, d_int[46], 15'b000000000000000, d_int[45], 15'b000000000000000, d_int[44],
          15'b000000000000000, d_int[43], 15'b000000000000000, d_int[42], 15'b000000000000000, d_int[41],
          15'b000000000000000, d_int[40], 15'b000000000000000, d_int[39], 15'b000000000000000, d_int[38],
          15'b000000000000000, d_int[37], 15'b000000000000000, d_int[36], 15'b000000000000000, d_int[35],
          15'b000000000000000, d_int[34], 15'b000000000000000, d_int[33], 15'b000000000000000, d_int[32],
          15'b000000000000000, d_int[31], 15'b000000000000000, d_int[30], 15'b000000000000000, d_int[29],
          15'b000000000000000, d_int[28], 15'b000000000000000, d_int[27], 15'b000000000000000, d_int[26],
          15'b000000000000000, d_int[25], 15'b000000000000000, d_int[24], 15'b000000000000000, d_int[23],
          15'b000000000000000, d_int[22], 15'b000000000000000, d_int[21], 15'b000000000000000, d_int[20],
          15'b000000000000000, d_int[19], 15'b000000000000000, d_int[18], 15'b000000000000000, d_int[17],
          15'b000000000000000, d_int[16], 15'b000000000000000, d_int[15], 15'b000000000000000, d_int[14],
          15'b000000000000000, d_int[13], 15'b000000000000000, d_int[12], 15'b000000000000000, d_int[11],
          15'b000000000000000, d_int[10], 15'b000000000000000, d_int[9], 15'b000000000000000, d_int[8],
          15'b000000000000000, d_int[7], 15'b000000000000000, d_int[6], 15'b000000000000000, d_int[5],
          15'b000000000000000, d_int[4], 15'b000000000000000, d_int[3], 15'b000000000000000, d_int[2],
          15'b000000000000000, d_int[1], 15'b000000000000000, d_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xq = 1'b0; q_update = 1'b1;
      end
    if (wabl_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (^wablm_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (rawl_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (^rawlm_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
      if( isBitX(gwen_int) )  begin
        Xq = 1'b1; q_update = 1'b1;
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
  always @ (VDDCE) begin
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
  always @ (ret1n_ or  VDDPE or VDDCE or VSSE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st == 1'b1 && (cen_ === 1'bx || clk_ === 1'bx)) begin
      failedWrite(0);
        Q_latch_corrupt;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        Q_latch_corrupt;
    end else if (ret1n_ === 1'b0 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        Q_latch_corrupt;
    end else if (ret1n_ === 1'b1 && ret1n_int !== 1'bx && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        Q_latch_corrupt;
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && VDDPE !== 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(0);
    end else if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
        Q_latch_corrupt;
      q_int_delayed = {64{1'bx}};
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 0;
    end else begin
      pre_charge_st = 0;
`else     
    end else begin
`endif
if ($realtime != 0)  Q_latch_corrupt;
      q_int_delayed = {64{1'bx}};
      cen_int = 1'bx;
      gwen_int = 1'bx;
      a_int = {12{1'bx}};
      d_int = {64{1'bx}};
      stov_int = 1'bx;
      ema_int = {3{1'bx}};
      emaw_int = {2{1'bx}};
      emas_int = 1'bx;
      ret1n_int = 1'bx;
      rawl_int = 1'bx;
      rawlm_int = {2{1'bx}};
      wabl_int = 1'bx;
      wablm_int = {2{1'bx}};
    end
    ret1n_int = ret1n_;
  end
   reg   ret1n_s;
`ifdef POWER_PINS
   reg   VDDCE_s;
   reg   VDDPE_s;
`endif
`ifdef POWER_PINS
	always @ (ret1n_ or VDDCE or VDDPE) begin 
`else
	always @ (ret1n_) begin 
`endif
 	ret1n_s <= ret1n_;
`ifdef POWER_PINS
 	VDDCE_s <= VDDCE;
 	VDDPE_s <= VDDPE;
`endif
	end
`ifdef POWER_PINS
	always @ (ret1n_s or VDDCE_s or VDDPE_s) begin 
`else
	always @ (ret1n_s) begin 
`endif
        Xq = 1'b0;
        Xd_int = {64{1'b0}};
        q_update = 1'b0;
	end
// Q_latch corruption
// -----------------------------
  task Q_latch_corrupt;
    begin
	uDQ0.Q = 1'bx;
	uDQ1.Q = 1'bx;
	uDQ2.Q = 1'bx;
	uDQ3.Q = 1'bx;
	uDQ4.Q = 1'bx;
	uDQ5.Q = 1'bx;
	uDQ6.Q = 1'bx;
	uDQ7.Q = 1'bx;
	uDQ8.Q = 1'bx;
	uDQ9.Q = 1'bx;
	uDQ10.Q = 1'bx;
	uDQ11.Q = 1'bx;
	uDQ12.Q = 1'bx;
	uDQ13.Q = 1'bx;
	uDQ14.Q = 1'bx;
	uDQ15.Q = 1'bx;
	uDQ16.Q = 1'bx;
	uDQ17.Q = 1'bx;
	uDQ18.Q = 1'bx;
	uDQ19.Q = 1'bx;
	uDQ20.Q = 1'bx;
	uDQ21.Q = 1'bx;
	uDQ22.Q = 1'bx;
	uDQ23.Q = 1'bx;
	uDQ24.Q = 1'bx;
	uDQ25.Q = 1'bx;
	uDQ26.Q = 1'bx;
	uDQ27.Q = 1'bx;
	uDQ28.Q = 1'bx;
	uDQ29.Q = 1'bx;
	uDQ30.Q = 1'bx;
	uDQ31.Q = 1'bx;
	uDQ32.Q = 1'bx;
	uDQ33.Q = 1'bx;
	uDQ34.Q = 1'bx;
	uDQ35.Q = 1'bx;
	uDQ36.Q = 1'bx;
	uDQ37.Q = 1'bx;
	uDQ38.Q = 1'bx;
	uDQ39.Q = 1'bx;
	uDQ40.Q = 1'bx;
	uDQ41.Q = 1'bx;
	uDQ42.Q = 1'bx;
	uDQ43.Q = 1'bx;
	uDQ44.Q = 1'bx;
	uDQ45.Q = 1'bx;
	uDQ46.Q = 1'bx;
	uDQ47.Q = 1'bx;
	uDQ48.Q = 1'bx;
	uDQ49.Q = 1'bx;
	uDQ50.Q = 1'bx;
	uDQ51.Q = 1'bx;
	uDQ52.Q = 1'bx;
	uDQ53.Q = 1'bx;
	uDQ54.Q = 1'bx;
	uDQ55.Q = 1'bx;
	uDQ56.Q = 1'bx;
	uDQ57.Q = 1'bx;
	uDQ58.Q = 1'bx;
	uDQ59.Q = 1'bx;
	uDQ60.Q = 1'bx;
	uDQ61.Q = 1'bx;
	uDQ62.Q = 1'bx;
	uDQ63.Q = 1'bx;

    end
  endtask



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
`ifdef POWER_PINS
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
`else     
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
`endif
      // no cycle in retention mode or during external power down
`ifdef POWER_PINS
    end else if ((VDDCE === 1'bx || VDDCE === 1'bz)) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
  end else if (ret1n_ == 1'b1 && VDDPE !== 1'b1) begin
  end else if (VSSE !== 1'b0) begin
`endif
  end else begin
    if ((clk_ === 1'bx || clk_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if ((clk_ === 1'b1 || clk_ === 1'b0) && LAST_clk === 1'bx) begin
       d_sh_update = 1'b0;  Xd_sh = 1'b0;
       Xd_int = {64{1'b0}};
       Xq = 1'b0; q_update = 1'b0; 
    end else if (clk_ === 1'b1 && LAST_clk === 1'b0) begin
      cen_int = cen_;
      stov_int = stov_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      if (cen_int != 1'b1) begin
        gwen_int = gwen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      cen_int = cen_;
      stov_int = stov_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      if (cen_int != 1'b1) begin
        gwen_int = gwen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      if (cen_int === 1'b0 && gwen_int === 1'b1) 
         q_int_delayed = {64{1'bx}};
    readWrite;
    end else if (clk_ === 1'b0 && LAST_clk === 1'b1) begin
      q_int_delayed = q_int;
      q_update = 1'b0;
      d_sh_update = 1'b0;
      Xq = 1'b0;
       Xd_int = {64{1'b0}};
    end
  end
    LAST_clk = clk_;
  end

  assign d_int_bmux = d_;

  datapath_latch_sramsp_4096_64 uDQ0 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(1'b0), .D(d_int_bmux[0]), .DFTRAMBYP(1'b0), .mem_path(mem_path[0]), .XQ(Xq|Xd_int[0]|1'b0), .Q(q_int[0]));
  datapath_latch_sramsp_4096_64 uDQ1 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[0]), .D(d_int_bmux[1]), .DFTRAMBYP(1'b0), .mem_path(mem_path[1]), .XQ(Xq|Xd_int[1]), .Q(q_int[1]));
  datapath_latch_sramsp_4096_64 uDQ2 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[1]), .D(d_int_bmux[2]), .DFTRAMBYP(1'b0), .mem_path(mem_path[2]), .XQ(Xq|Xd_int[2]), .Q(q_int[2]));
  datapath_latch_sramsp_4096_64 uDQ3 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[2]), .D(d_int_bmux[3]), .DFTRAMBYP(1'b0), .mem_path(mem_path[3]), .XQ(Xq|Xd_int[3]), .Q(q_int[3]));
  datapath_latch_sramsp_4096_64 uDQ4 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[3]), .D(d_int_bmux[4]), .DFTRAMBYP(1'b0), .mem_path(mem_path[4]), .XQ(Xq|Xd_int[4]), .Q(q_int[4]));
  datapath_latch_sramsp_4096_64 uDQ5 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[4]), .D(d_int_bmux[5]), .DFTRAMBYP(1'b0), .mem_path(mem_path[5]), .XQ(Xq|Xd_int[5]), .Q(q_int[5]));
  datapath_latch_sramsp_4096_64 uDQ6 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[5]), .D(d_int_bmux[6]), .DFTRAMBYP(1'b0), .mem_path(mem_path[6]), .XQ(Xq|Xd_int[6]), .Q(q_int[6]));
  datapath_latch_sramsp_4096_64 uDQ7 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[6]), .D(d_int_bmux[7]), .DFTRAMBYP(1'b0), .mem_path(mem_path[7]), .XQ(Xq|Xd_int[7]), .Q(q_int[7]));
  datapath_latch_sramsp_4096_64 uDQ8 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[7]), .D(d_int_bmux[8]), .DFTRAMBYP(1'b0), .mem_path(mem_path[8]), .XQ(Xq|Xd_int[8]), .Q(q_int[8]));
  datapath_latch_sramsp_4096_64 uDQ9 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[8]), .D(d_int_bmux[9]), .DFTRAMBYP(1'b0), .mem_path(mem_path[9]), .XQ(Xq|Xd_int[9]), .Q(q_int[9]));
  datapath_latch_sramsp_4096_64 uDQ10 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[9]), .D(d_int_bmux[10]), .DFTRAMBYP(1'b0), .mem_path(mem_path[10]), .XQ(Xq|Xd_int[10]), .Q(q_int[10]));
  datapath_latch_sramsp_4096_64 uDQ11 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[10]), .D(d_int_bmux[11]), .DFTRAMBYP(1'b0), .mem_path(mem_path[11]), .XQ(Xq|Xd_int[11]), .Q(q_int[11]));
  datapath_latch_sramsp_4096_64 uDQ12 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[11]), .D(d_int_bmux[12]), .DFTRAMBYP(1'b0), .mem_path(mem_path[12]), .XQ(Xq|Xd_int[12]), .Q(q_int[12]));
  datapath_latch_sramsp_4096_64 uDQ13 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[12]), .D(d_int_bmux[13]), .DFTRAMBYP(1'b0), .mem_path(mem_path[13]), .XQ(Xq|Xd_int[13]), .Q(q_int[13]));
  datapath_latch_sramsp_4096_64 uDQ14 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[13]), .D(d_int_bmux[14]), .DFTRAMBYP(1'b0), .mem_path(mem_path[14]), .XQ(Xq|Xd_int[14]), .Q(q_int[14]));
  datapath_latch_sramsp_4096_64 uDQ15 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[14]), .D(d_int_bmux[15]), .DFTRAMBYP(1'b0), .mem_path(mem_path[15]), .XQ(Xq|Xd_int[15]), .Q(q_int[15]));
  datapath_latch_sramsp_4096_64 uDQ16 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[15]), .D(d_int_bmux[16]), .DFTRAMBYP(1'b0), .mem_path(mem_path[16]), .XQ(Xq|Xd_int[16]), .Q(q_int[16]));
  datapath_latch_sramsp_4096_64 uDQ17 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[16]), .D(d_int_bmux[17]), .DFTRAMBYP(1'b0), .mem_path(mem_path[17]), .XQ(Xq|Xd_int[17]), .Q(q_int[17]));
  datapath_latch_sramsp_4096_64 uDQ18 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[17]), .D(d_int_bmux[18]), .DFTRAMBYP(1'b0), .mem_path(mem_path[18]), .XQ(Xq|Xd_int[18]), .Q(q_int[18]));
  datapath_latch_sramsp_4096_64 uDQ19 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[18]), .D(d_int_bmux[19]), .DFTRAMBYP(1'b0), .mem_path(mem_path[19]), .XQ(Xq|Xd_int[19]), .Q(q_int[19]));
  datapath_latch_sramsp_4096_64 uDQ20 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[19]), .D(d_int_bmux[20]), .DFTRAMBYP(1'b0), .mem_path(mem_path[20]), .XQ(Xq|Xd_int[20]), .Q(q_int[20]));
  datapath_latch_sramsp_4096_64 uDQ21 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[20]), .D(d_int_bmux[21]), .DFTRAMBYP(1'b0), .mem_path(mem_path[21]), .XQ(Xq|Xd_int[21]), .Q(q_int[21]));
  datapath_latch_sramsp_4096_64 uDQ22 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[21]), .D(d_int_bmux[22]), .DFTRAMBYP(1'b0), .mem_path(mem_path[22]), .XQ(Xq|Xd_int[22]), .Q(q_int[22]));
  datapath_latch_sramsp_4096_64 uDQ23 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[22]), .D(d_int_bmux[23]), .DFTRAMBYP(1'b0), .mem_path(mem_path[23]), .XQ(Xq|Xd_int[23]), .Q(q_int[23]));
  datapath_latch_sramsp_4096_64 uDQ24 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[23]), .D(d_int_bmux[24]), .DFTRAMBYP(1'b0), .mem_path(mem_path[24]), .XQ(Xq|Xd_int[24]), .Q(q_int[24]));
  datapath_latch_sramsp_4096_64 uDQ25 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[24]), .D(d_int_bmux[25]), .DFTRAMBYP(1'b0), .mem_path(mem_path[25]), .XQ(Xq|Xd_int[25]), .Q(q_int[25]));
  datapath_latch_sramsp_4096_64 uDQ26 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[25]), .D(d_int_bmux[26]), .DFTRAMBYP(1'b0), .mem_path(mem_path[26]), .XQ(Xq|Xd_int[26]), .Q(q_int[26]));
  datapath_latch_sramsp_4096_64 uDQ27 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[26]), .D(d_int_bmux[27]), .DFTRAMBYP(1'b0), .mem_path(mem_path[27]), .XQ(Xq|Xd_int[27]), .Q(q_int[27]));
  datapath_latch_sramsp_4096_64 uDQ28 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[27]), .D(d_int_bmux[28]), .DFTRAMBYP(1'b0), .mem_path(mem_path[28]), .XQ(Xq|Xd_int[28]), .Q(q_int[28]));
  datapath_latch_sramsp_4096_64 uDQ29 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[28]), .D(d_int_bmux[29]), .DFTRAMBYP(1'b0), .mem_path(mem_path[29]), .XQ(Xq|Xd_int[29]), .Q(q_int[29]));
  datapath_latch_sramsp_4096_64 uDQ30 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[29]), .D(d_int_bmux[30]), .DFTRAMBYP(1'b0), .mem_path(mem_path[30]), .XQ(Xq|Xd_int[30]), .Q(q_int[30]));
  datapath_latch_sramsp_4096_64 uDQ31 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[30]), .D(d_int_bmux[31]), .DFTRAMBYP(1'b0), .mem_path(mem_path[31]), .XQ(Xq|Xd_int[31]), .Q(q_int[31]));
  datapath_latch_sramsp_4096_64 uDQ32 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[33]), .D(d_int_bmux[32]), .DFTRAMBYP(1'b0), .mem_path(mem_path[32]), .XQ(Xq|Xd_int[32]), .Q(q_int[32]));
  datapath_latch_sramsp_4096_64 uDQ33 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[34]), .D(d_int_bmux[33]), .DFTRAMBYP(1'b0), .mem_path(mem_path[33]), .XQ(Xq|Xd_int[33]), .Q(q_int[33]));
  datapath_latch_sramsp_4096_64 uDQ34 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[35]), .D(d_int_bmux[34]), .DFTRAMBYP(1'b0), .mem_path(mem_path[34]), .XQ(Xq|Xd_int[34]), .Q(q_int[34]));
  datapath_latch_sramsp_4096_64 uDQ35 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[36]), .D(d_int_bmux[35]), .DFTRAMBYP(1'b0), .mem_path(mem_path[35]), .XQ(Xq|Xd_int[35]), .Q(q_int[35]));
  datapath_latch_sramsp_4096_64 uDQ36 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[37]), .D(d_int_bmux[36]), .DFTRAMBYP(1'b0), .mem_path(mem_path[36]), .XQ(Xq|Xd_int[36]), .Q(q_int[36]));
  datapath_latch_sramsp_4096_64 uDQ37 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[38]), .D(d_int_bmux[37]), .DFTRAMBYP(1'b0), .mem_path(mem_path[37]), .XQ(Xq|Xd_int[37]), .Q(q_int[37]));
  datapath_latch_sramsp_4096_64 uDQ38 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[39]), .D(d_int_bmux[38]), .DFTRAMBYP(1'b0), .mem_path(mem_path[38]), .XQ(Xq|Xd_int[38]), .Q(q_int[38]));
  datapath_latch_sramsp_4096_64 uDQ39 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[40]), .D(d_int_bmux[39]), .DFTRAMBYP(1'b0), .mem_path(mem_path[39]), .XQ(Xq|Xd_int[39]), .Q(q_int[39]));
  datapath_latch_sramsp_4096_64 uDQ40 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[41]), .D(d_int_bmux[40]), .DFTRAMBYP(1'b0), .mem_path(mem_path[40]), .XQ(Xq|Xd_int[40]), .Q(q_int[40]));
  datapath_latch_sramsp_4096_64 uDQ41 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[42]), .D(d_int_bmux[41]), .DFTRAMBYP(1'b0), .mem_path(mem_path[41]), .XQ(Xq|Xd_int[41]), .Q(q_int[41]));
  datapath_latch_sramsp_4096_64 uDQ42 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[43]), .D(d_int_bmux[42]), .DFTRAMBYP(1'b0), .mem_path(mem_path[42]), .XQ(Xq|Xd_int[42]), .Q(q_int[42]));
  datapath_latch_sramsp_4096_64 uDQ43 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[44]), .D(d_int_bmux[43]), .DFTRAMBYP(1'b0), .mem_path(mem_path[43]), .XQ(Xq|Xd_int[43]), .Q(q_int[43]));
  datapath_latch_sramsp_4096_64 uDQ44 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[45]), .D(d_int_bmux[44]), .DFTRAMBYP(1'b0), .mem_path(mem_path[44]), .XQ(Xq|Xd_int[44]), .Q(q_int[44]));
  datapath_latch_sramsp_4096_64 uDQ45 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[46]), .D(d_int_bmux[45]), .DFTRAMBYP(1'b0), .mem_path(mem_path[45]), .XQ(Xq|Xd_int[45]), .Q(q_int[45]));
  datapath_latch_sramsp_4096_64 uDQ46 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[47]), .D(d_int_bmux[46]), .DFTRAMBYP(1'b0), .mem_path(mem_path[46]), .XQ(Xq|Xd_int[46]), .Q(q_int[46]));
  datapath_latch_sramsp_4096_64 uDQ47 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[48]), .D(d_int_bmux[47]), .DFTRAMBYP(1'b0), .mem_path(mem_path[47]), .XQ(Xq|Xd_int[47]), .Q(q_int[47]));
  datapath_latch_sramsp_4096_64 uDQ48 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[49]), .D(d_int_bmux[48]), .DFTRAMBYP(1'b0), .mem_path(mem_path[48]), .XQ(Xq|Xd_int[48]), .Q(q_int[48]));
  datapath_latch_sramsp_4096_64 uDQ49 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[50]), .D(d_int_bmux[49]), .DFTRAMBYP(1'b0), .mem_path(mem_path[49]), .XQ(Xq|Xd_int[49]), .Q(q_int[49]));
  datapath_latch_sramsp_4096_64 uDQ50 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[51]), .D(d_int_bmux[50]), .DFTRAMBYP(1'b0), .mem_path(mem_path[50]), .XQ(Xq|Xd_int[50]), .Q(q_int[50]));
  datapath_latch_sramsp_4096_64 uDQ51 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[52]), .D(d_int_bmux[51]), .DFTRAMBYP(1'b0), .mem_path(mem_path[51]), .XQ(Xq|Xd_int[51]), .Q(q_int[51]));
  datapath_latch_sramsp_4096_64 uDQ52 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[53]), .D(d_int_bmux[52]), .DFTRAMBYP(1'b0), .mem_path(mem_path[52]), .XQ(Xq|Xd_int[52]), .Q(q_int[52]));
  datapath_latch_sramsp_4096_64 uDQ53 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[54]), .D(d_int_bmux[53]), .DFTRAMBYP(1'b0), .mem_path(mem_path[53]), .XQ(Xq|Xd_int[53]), .Q(q_int[53]));
  datapath_latch_sramsp_4096_64 uDQ54 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[55]), .D(d_int_bmux[54]), .DFTRAMBYP(1'b0), .mem_path(mem_path[54]), .XQ(Xq|Xd_int[54]), .Q(q_int[54]));
  datapath_latch_sramsp_4096_64 uDQ55 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[56]), .D(d_int_bmux[55]), .DFTRAMBYP(1'b0), .mem_path(mem_path[55]), .XQ(Xq|Xd_int[55]), .Q(q_int[55]));
  datapath_latch_sramsp_4096_64 uDQ56 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[57]), .D(d_int_bmux[56]), .DFTRAMBYP(1'b0), .mem_path(mem_path[56]), .XQ(Xq|Xd_int[56]), .Q(q_int[56]));
  datapath_latch_sramsp_4096_64 uDQ57 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[58]), .D(d_int_bmux[57]), .DFTRAMBYP(1'b0), .mem_path(mem_path[57]), .XQ(Xq|Xd_int[57]), .Q(q_int[57]));
  datapath_latch_sramsp_4096_64 uDQ58 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[59]), .D(d_int_bmux[58]), .DFTRAMBYP(1'b0), .mem_path(mem_path[58]), .XQ(Xq|Xd_int[58]), .Q(q_int[58]));
  datapath_latch_sramsp_4096_64 uDQ59 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[60]), .D(d_int_bmux[59]), .DFTRAMBYP(1'b0), .mem_path(mem_path[59]), .XQ(Xq|Xd_int[59]), .Q(q_int[59]));
  datapath_latch_sramsp_4096_64 uDQ60 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[61]), .D(d_int_bmux[60]), .DFTRAMBYP(1'b0), .mem_path(mem_path[60]), .XQ(Xq|Xd_int[60]), .Q(q_int[60]));
  datapath_latch_sramsp_4096_64 uDQ61 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[62]), .D(d_int_bmux[61]), .DFTRAMBYP(1'b0), .mem_path(mem_path[61]), .XQ(Xq|Xd_int[61]), .Q(q_int[61]));
  datapath_latch_sramsp_4096_64 uDQ62 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[63]), .D(d_int_bmux[62]), .DFTRAMBYP(1'b0), .mem_path(mem_path[62]), .XQ(Xq|Xd_int[62]), .Q(q_int[62]));
  datapath_latch_sramsp_4096_64 uDQ63 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(1'b0), .D(d_int_bmux[63]), .DFTRAMBYP(1'b0), .mem_path(mem_path[63]), .XQ(Xq|Xd_int[63]|1'b0), .Q(q_int[63]));


reg clk_s;

always @ (clk_)
    clk_s <= clk_;

// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
	always @ (VDDCE or VDDPE or VSSE or clk_s) begin
		if (VDDCE !== 1'b1) begin
			$display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
        Xq = 1'b1; q_update = 1'b1;
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (VDDPE !== 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        Xq = 1'b1; q_update = 1'b1;
		if (ret1n_ !== 1'b0)
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE !== 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        Xq = 1'b1; q_update = 1'b1;
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
// If ARM_NEG_MODEL is defined at Simulator Command Line, it Selects the NEGATIVE Model
`ifdef ARM_NEG_MODEL

`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sramsp_4096_64 (VDDCE, VDDPE, VSSE, q, clk, cen, gwen, a, d, stov, ema, emaw, 
    emas, ret1n, rawl, rawlm, wabl, wablm);
`else
module sramsp_4096_64 (q, clk, cen, gwen, a, d, stov, ema, emaw, emas, ret1n, rawl, 
    rawlm, wabl, wablm);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 64;
  parameter WORDS = 4096;
  parameter MUX = 16;
  parameter MEM_WIDTH = 1024; // redun block size 16, 512 on left, 512 on right
  parameter MEM_HEIGHT = 256;
  parameter WP_SIZE = 64 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;
  parameter UPMP_WIDTH = 0;
  parameter ARM_DUMMY_CYCLE_WIDTH = `ARM_MEM_WIDTH;
  parameter ARM_LOCAL_OFFSET_TIME = `ARM_OFFSET_TIME;

`ifdef ARM_DISABLE_EMA_CHECK
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 1;
`else
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 0;
`endif

  parameter ARM_REF_EMA_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMA_VALUE;
  parameter ARM_REF_EMAW_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAW_VALUE;
  parameter ARM_REF_EMAS_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAS_VALUE;
  parameter ROWS = 256;

  output [63:0] q;
  input  clk;
  input  cen;
  input  gwen;
  input [11:0] a;
  input [63:0] d;
  input  stov;
  input [2:0] ema;
  input [1:0] emaw;
  input  emas;
  input  ret1n;
  input  rawl;
  input [1:0] rawlm;
  input  wabl;
  input [1:0] wablm;
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
  reg pre_charge_st;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [1023:0] row, row_t;
  reg LAST_clk;
  reg [1023:0] mem [0:255];
  reg [1023:0] row_mask;
  reg [1023:0] new_data;
  reg [1023:0] data_out;
  reg [63:0] readLatch0;
  reg [63:0] shifted_readLatch0;
  wire [63:0] q_int;
  reg [63:0] q_int_delayed;
  reg Xq, q_update;
  reg Xd_sh, d_sh_update;
  wire [63:0] d_int_bmux;
  reg [63:0] mem_path;
  reg [63:0] mem_path_d;
  reg [63:0] writeEnable;

  reg NOT_cen, NOT_gwen, NOT_a11, NOT_a10, NOT_a9, NOT_a8, NOT_a7, NOT_a6, NOT_a5;
  reg NOT_a4, NOT_a3, NOT_a2, NOT_a1, NOT_a0, NOT_d63, NOT_d62, NOT_d61, NOT_d60, NOT_d59;
  reg NOT_d58, NOT_d57, NOT_d56, NOT_d55, NOT_d54, NOT_d53, NOT_d52, NOT_d51, NOT_d50;
  reg NOT_d49, NOT_d48, NOT_d47, NOT_d46, NOT_d45, NOT_d44, NOT_d43, NOT_d42, NOT_d41;
  reg NOT_d40, NOT_d39, NOT_d38, NOT_d37, NOT_d36, NOT_d35, NOT_d34, NOT_d33, NOT_d32;
  reg NOT_d31, NOT_d30, NOT_d29, NOT_d28, NOT_d27, NOT_d26, NOT_d25, NOT_d24, NOT_d23;
  reg NOT_d22, NOT_d21, NOT_d20, NOT_d19, NOT_d18, NOT_d17, NOT_d16, NOT_d15, NOT_d14;
  reg NOT_d13, NOT_d12, NOT_d11, NOT_d10, NOT_d9, NOT_d8, NOT_d7, NOT_d6, NOT_d5, NOT_d4;
  reg NOT_d3, NOT_d2, NOT_d1, NOT_d0, NOT_stov, NOT_ema2, NOT_ema1, NOT_ema0, NOT_emaw1;
  reg NOT_emaw0, NOT_emas, NOT_ret1n, NOT_rawl, NOT_rawlm1, NOT_rawlm0, NOT_wabl, NOT_wablm1;
  reg NOT_wablm0;
  reg NOT_clk_PER, NOT_clk_MINH, NOT_clk_MINL;
  reg clk0_int;

  wire [63:0] q_;
  wire [63:0] q_out;
 wire  clk_;
 wire  dclk;
  wire  cen_;
 wire  dcen;
  reg  cen_int;
  reg  cen_p2;
  wire  gwen_;
 wire  dgwen;
  reg  gwen_int;
  wire [11:0] a_;
 wire [11:0] da;
  reg [11:0] a_int;
  wire [63:0] d_;
 wire [63:0] dd;
  reg [63:0] d_int;
  reg [63:0] Xd_int;
  wire  stov_;
 wire  dstov;
  reg  stov_int;
  wire [2:0] ema_;
 wire [2:0] dema;
  reg [2:0] ema_int;
  wire [1:0] emaw_;
 wire [1:0] demaw;
  reg [1:0] emaw_int;
  wire  emas_;
 wire  demas;
  reg  emas_int;
  wire  ret1n_;
 wire  dret1n;
  reg  ret1n_int;
  wire  rawl_;
 wire  drawl;
  reg  rawl_int;
  wire [1:0] rawlm_;
 wire [1:0] drawlm;
  reg [1:0] rawlm_int;
  wire  wabl_;
 wire  dwabl;
  reg  wabl_int;
  wire [1:0] wablm_;
 wire [1:0] dwablm;
  reg [1:0] wablm_int;

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
  buf B46(q[46], q_[46]);
  buf B47(q[47], q_[47]);
  buf B48(q[48], q_[48]);
  buf B49(q[49], q_[49]);
  buf B50(q[50], q_[50]);
  buf B51(q[51], q_[51]);
  buf B52(q[52], q_[52]);
  buf B53(q[53], q_[53]);
  buf B54(q[54], q_[54]);
  buf B55(q[55], q_[55]);
  buf B56(q[56], q_[56]);
  buf B57(q[57], q_[57]);
  buf B58(q[58], q_[58]);
  buf B59(q[59], q_[59]);
  buf B60(q[60], q_[60]);
  buf B61(q[61], q_[61]);
  buf B62(q[62], q_[62]);
  buf B63(q[63], q_[63]);
  buf B64(clk_, dclk);
  buf B65(cen_, dcen);
  buf B66(gwen_, dgwen);
  buf B67(a_[0],da[0]);
  buf B68(a_[1],da[1]);
  buf B69(a_[2],da[2]);
  buf B70(a_[3],da[3]);
  buf B71(a_[4],da[4]);
  buf B72(a_[5],da[5]);
  buf B73(a_[6],da[6]);
  buf B74(a_[7],da[7]);
  buf B75(a_[8],da[8]);
  buf B76(a_[9],da[9]);
  buf B77(a_[10],da[10]);
  buf B78(a_[11],da[11]);
  buf B79(d_[0],dd[0]);
  buf B80(d_[1],dd[1]);
  buf B81(d_[2],dd[2]);
  buf B82(d_[3],dd[3]);
  buf B83(d_[4],dd[4]);
  buf B84(d_[5],dd[5]);
  buf B85(d_[6],dd[6]);
  buf B86(d_[7],dd[7]);
  buf B87(d_[8],dd[8]);
  buf B88(d_[9],dd[9]);
  buf B89(d_[10],dd[10]);
  buf B90(d_[11],dd[11]);
  buf B91(d_[12],dd[12]);
  buf B92(d_[13],dd[13]);
  buf B93(d_[14],dd[14]);
  buf B94(d_[15],dd[15]);
  buf B95(d_[16],dd[16]);
  buf B96(d_[17],dd[17]);
  buf B97(d_[18],dd[18]);
  buf B98(d_[19],dd[19]);
  buf B99(d_[20],dd[20]);
  buf B100(d_[21],dd[21]);
  buf B101(d_[22],dd[22]);
  buf B102(d_[23],dd[23]);
  buf B103(d_[24],dd[24]);
  buf B104(d_[25],dd[25]);
  buf B105(d_[26],dd[26]);
  buf B106(d_[27],dd[27]);
  buf B107(d_[28],dd[28]);
  buf B108(d_[29],dd[29]);
  buf B109(d_[30],dd[30]);
  buf B110(d_[31],dd[31]);
  buf B111(d_[32],dd[32]);
  buf B112(d_[33],dd[33]);
  buf B113(d_[34],dd[34]);
  buf B114(d_[35],dd[35]);
  buf B115(d_[36],dd[36]);
  buf B116(d_[37],dd[37]);
  buf B117(d_[38],dd[38]);
  buf B118(d_[39],dd[39]);
  buf B119(d_[40],dd[40]);
  buf B120(d_[41],dd[41]);
  buf B121(d_[42],dd[42]);
  buf B122(d_[43],dd[43]);
  buf B123(d_[44],dd[44]);
  buf B124(d_[45],dd[45]);
  buf B125(d_[46],dd[46]);
  buf B126(d_[47],dd[47]);
  buf B127(d_[48],dd[48]);
  buf B128(d_[49],dd[49]);
  buf B129(d_[50],dd[50]);
  buf B130(d_[51],dd[51]);
  buf B131(d_[52],dd[52]);
  buf B132(d_[53],dd[53]);
  buf B133(d_[54],dd[54]);
  buf B134(d_[55],dd[55]);
  buf B135(d_[56],dd[56]);
  buf B136(d_[57],dd[57]);
  buf B137(d_[58],dd[58]);
  buf B138(d_[59],dd[59]);
  buf B139(d_[60],dd[60]);
  buf B140(d_[61],dd[61]);
  buf B141(d_[62],dd[62]);
  buf B142(d_[63],dd[63]);
  buf B143(stov_, dstov);
  buf B144(ema_[0],dema[0]);
  buf B145(ema_[1],dema[1]);
  buf B146(ema_[2],dema[2]);
  buf B147(emaw_[0],demaw[0]);
  buf B148(emaw_[1],demaw[1]);
  buf B149(emas_, demas);
  buf B150(ret1n_, dret1n);
  buf B151(rawl_, drawl);
  buf B152(rawlm_[0],drawlm[0]);
  buf B153(rawlm_[1],drawlm[1]);
  buf B154(wabl_, dwabl);
  buf B155(wablm_[0],dwablm[0]);
  buf B156(wablm_[1],dwablm[1]);

`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

   assign q_out = q_int;
  assign q_ = (ret1n_ | pre_charge_st) & ~corrupt_power ? ((stov_ ? (q_int_delayed) : (q_out))) : {64{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
  begin
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
	uDQ0.Q = $random;
	uDQ1.Q = $random;
	uDQ2.Q = $random;
	uDQ3.Q = $random;
	uDQ4.Q = $random;
	uDQ5.Q = $random;
	uDQ6.Q = $random;
	uDQ7.Q = $random;
	uDQ8.Q = $random;
	uDQ9.Q = $random;
	uDQ10.Q = $random;
	uDQ11.Q = $random;
	uDQ12.Q = $random;
	uDQ13.Q = $random;
	uDQ14.Q = $random;
	uDQ15.Q = $random;
	uDQ16.Q = $random;
	uDQ17.Q = $random;
	uDQ18.Q = $random;
	uDQ19.Q = $random;
	uDQ20.Q = $random;
	uDQ21.Q = $random;
	uDQ22.Q = $random;
	uDQ23.Q = $random;
	uDQ24.Q = $random;
	uDQ25.Q = $random;
	uDQ26.Q = $random;
	uDQ27.Q = $random;
	uDQ28.Q = $random;
	uDQ29.Q = $random;
	uDQ30.Q = $random;
	uDQ31.Q = $random;
	uDQ32.Q = $random;
	uDQ33.Q = $random;
	uDQ34.Q = $random;
	uDQ35.Q = $random;
	uDQ36.Q = $random;
	uDQ37.Q = $random;
	uDQ38.Q = $random;
	uDQ39.Q = $random;
	uDQ40.Q = $random;
	uDQ41.Q = $random;
	uDQ42.Q = $random;
	uDQ43.Q = $random;
	uDQ44.Q = $random;
	uDQ45.Q = $random;
	uDQ46.Q = $random;
	uDQ47.Q = $random;
	uDQ48.Q = $random;
	uDQ49.Q = $random;
	uDQ50.Q = $random;
	uDQ51.Q = $random;
	uDQ52.Q = $random;
	uDQ53.Q = $random;
	uDQ54.Q = $random;
	uDQ55.Q = $random;
	uDQ56.Q = $random;
	uDQ57.Q = $random;
	uDQ58.Q = $random;
	uDQ59.Q = $random;
	uDQ60.Q = $random;
	uDQ61.Q = $random;
	uDQ62.Q = $random;
	uDQ63.Q = $random;

  end
`endif

  always @ (posedge clk_) begin
      if(ema_ !== ARM_REF_EMA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for ema is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of ema", ema_, ARM_REF_EMA_VALUE, $time);
  end
  always @ (posedge clk_) begin
      if(emaw_ !== ARM_REF_EMAW_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for emaw is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of emaw", emaw_, ARM_REF_EMAW_VALUE, $time);
  end
  always @ (posedge clk_) begin
      if(emas_ !== ARM_REF_EMAS_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for emas is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of emas", emas_, ARM_REF_EMAS_VALUE, $time);
  end
	always @ (stov_) begin
		if(clk_ == 1'b1) begin
			Xq = 1'b1; q_update = 1'b1;
			#0; q_update = 1'b0;
			Xq = 1'b0;
		end
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
	reg [11:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[63], 15'b000000000000000, wordtemp[62],
          15'b000000000000000, wordtemp[61], 15'b000000000000000, wordtemp[60], 15'b000000000000000, wordtemp[59],
          15'b000000000000000, wordtemp[58], 15'b000000000000000, wordtemp[57], 15'b000000000000000, wordtemp[56],
          15'b000000000000000, wordtemp[55], 15'b000000000000000, wordtemp[54], 15'b000000000000000, wordtemp[53],
          15'b000000000000000, wordtemp[52], 15'b000000000000000, wordtemp[51], 15'b000000000000000, wordtemp[50],
          15'b000000000000000, wordtemp[49], 15'b000000000000000, wordtemp[48], 15'b000000000000000, wordtemp[47],
          15'b000000000000000, wordtemp[46], 15'b000000000000000, wordtemp[45], 15'b000000000000000, wordtemp[44],
          15'b000000000000000, wordtemp[43], 15'b000000000000000, wordtemp[42], 15'b000000000000000, wordtemp[41],
          15'b000000000000000, wordtemp[40], 15'b000000000000000, wordtemp[39], 15'b000000000000000, wordtemp[38],
          15'b000000000000000, wordtemp[37], 15'b000000000000000, wordtemp[36], 15'b000000000000000, wordtemp[35],
          15'b000000000000000, wordtemp[34], 15'b000000000000000, wordtemp[33], 15'b000000000000000, wordtemp[32],
          15'b000000000000000, wordtemp[31], 15'b000000000000000, wordtemp[30], 15'b000000000000000, wordtemp[29],
          15'b000000000000000, wordtemp[28], 15'b000000000000000, wordtemp[27], 15'b000000000000000, wordtemp[26],
          15'b000000000000000, wordtemp[25], 15'b000000000000000, wordtemp[24], 15'b000000000000000, wordtemp[23],
          15'b000000000000000, wordtemp[22], 15'b000000000000000, wordtemp[21], 15'b000000000000000, wordtemp[20],
          15'b000000000000000, wordtemp[19], 15'b000000000000000, wordtemp[18], 15'b000000000000000, wordtemp[17],
          15'b000000000000000, wordtemp[16], 15'b000000000000000, wordtemp[15], 15'b000000000000000, wordtemp[14],
          15'b000000000000000, wordtemp[13], 15'b000000000000000, wordtemp[12], 15'b000000000000000, wordtemp[11],
          15'b000000000000000, wordtemp[10], 15'b000000000000000, wordtemp[9], 15'b000000000000000, wordtemp[8],
          15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6], 15'b000000000000000, wordtemp[5],
          15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3], 15'b000000000000000, wordtemp[2],
          15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
`ifdef ARM_BACKDOOR_NOCEN
`else
    end
`endif
  end
  endtask

  task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	 for (i=0;i<WORDS;i=i+1) begin
	 Atemp = i;
	 mux_address = (Atemp & 4'b1111);
      row_address = (Atemp >> 4);
      row = mem[row_address];
        writeEnable = {64{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_d = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", mem_path_d);
     end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [11:0] load_addr;
	input [63:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[63], 15'b000000000000000, wordtemp[62],
          15'b000000000000000, wordtemp[61], 15'b000000000000000, wordtemp[60], 15'b000000000000000, wordtemp[59],
          15'b000000000000000, wordtemp[58], 15'b000000000000000, wordtemp[57], 15'b000000000000000, wordtemp[56],
          15'b000000000000000, wordtemp[55], 15'b000000000000000, wordtemp[54], 15'b000000000000000, wordtemp[53],
          15'b000000000000000, wordtemp[52], 15'b000000000000000, wordtemp[51], 15'b000000000000000, wordtemp[50],
          15'b000000000000000, wordtemp[49], 15'b000000000000000, wordtemp[48], 15'b000000000000000, wordtemp[47],
          15'b000000000000000, wordtemp[46], 15'b000000000000000, wordtemp[45], 15'b000000000000000, wordtemp[44],
          15'b000000000000000, wordtemp[43], 15'b000000000000000, wordtemp[42], 15'b000000000000000, wordtemp[41],
          15'b000000000000000, wordtemp[40], 15'b000000000000000, wordtemp[39], 15'b000000000000000, wordtemp[38],
          15'b000000000000000, wordtemp[37], 15'b000000000000000, wordtemp[36], 15'b000000000000000, wordtemp[35],
          15'b000000000000000, wordtemp[34], 15'b000000000000000, wordtemp[33], 15'b000000000000000, wordtemp[32],
          15'b000000000000000, wordtemp[31], 15'b000000000000000, wordtemp[30], 15'b000000000000000, wordtemp[29],
          15'b000000000000000, wordtemp[28], 15'b000000000000000, wordtemp[27], 15'b000000000000000, wordtemp[26],
          15'b000000000000000, wordtemp[25], 15'b000000000000000, wordtemp[24], 15'b000000000000000, wordtemp[23],
          15'b000000000000000, wordtemp[22], 15'b000000000000000, wordtemp[21], 15'b000000000000000, wordtemp[20],
          15'b000000000000000, wordtemp[19], 15'b000000000000000, wordtemp[18], 15'b000000000000000, wordtemp[17],
          15'b000000000000000, wordtemp[16], 15'b000000000000000, wordtemp[15], 15'b000000000000000, wordtemp[14],
          15'b000000000000000, wordtemp[13], 15'b000000000000000, wordtemp[12], 15'b000000000000000, wordtemp[11],
          15'b000000000000000, wordtemp[10], 15'b000000000000000, wordtemp[9], 15'b000000000000000, wordtemp[8],
          15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6], 15'b000000000000000, wordtemp[5],
          15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3], 15'b000000000000000, wordtemp[2],
          15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask

  task dumpaddr;
	output [63:0] dump_data;
	input [11:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_d = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
   	dump_data = mem_path_d;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWrite;
  begin
    if (wabl_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (^wablm_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (rawl_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (^rawlm_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if (ret1n_int === 1'b0 && cen_int === 1'b0) begin
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(ema_int), (emaw_int), (emas_int)} === 1'bx) begin
  if(isBitX(emas_int)) begin 
        Xq = 1'b1; q_update = 1'b1;
  end
  if(isBitX(emaw_int) && cen_int === 1'b0) begin 
    if (gwen_int === 1'b0)
      failedWrite(0);
  end
  if(isBitX(ema_int)) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
  end
    end else if (^{cen_int, (stov_int && !cen_int), rawl_int, rawlm_int, wabl_int, wablm_int} === 1'bx) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if ((a_int >= WORDS) && (cen_int === 1'b0)) begin
        Xq = gwen_int !== 1'b1 ? 1'b0 : 1'b1; q_update = gwen_int !== 1'b1 ? 1'b0 : 1'b1;
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
      if (gwen_int !== 1'b1)
        failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if (cen_int === 1'b0) begin
      mux_address = (a_int & 4'b1111);
      row_address = (a_int >> 4);
      if (row_address > 255)
        row = {1024{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {64{gwen_int}};
      if (gwen_int !== 1'b1) begin
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, d_int[63], 15'b000000000000000, d_int[62],
          15'b000000000000000, d_int[61], 15'b000000000000000, d_int[60], 15'b000000000000000, d_int[59],
          15'b000000000000000, d_int[58], 15'b000000000000000, d_int[57], 15'b000000000000000, d_int[56],
          15'b000000000000000, d_int[55], 15'b000000000000000, d_int[54], 15'b000000000000000, d_int[53],
          15'b000000000000000, d_int[52], 15'b000000000000000, d_int[51], 15'b000000000000000, d_int[50],
          15'b000000000000000, d_int[49], 15'b000000000000000, d_int[48], 15'b000000000000000, d_int[47],
          15'b000000000000000, d_int[46], 15'b000000000000000, d_int[45], 15'b000000000000000, d_int[44],
          15'b000000000000000, d_int[43], 15'b000000000000000, d_int[42], 15'b000000000000000, d_int[41],
          15'b000000000000000, d_int[40], 15'b000000000000000, d_int[39], 15'b000000000000000, d_int[38],
          15'b000000000000000, d_int[37], 15'b000000000000000, d_int[36], 15'b000000000000000, d_int[35],
          15'b000000000000000, d_int[34], 15'b000000000000000, d_int[33], 15'b000000000000000, d_int[32],
          15'b000000000000000, d_int[31], 15'b000000000000000, d_int[30], 15'b000000000000000, d_int[29],
          15'b000000000000000, d_int[28], 15'b000000000000000, d_int[27], 15'b000000000000000, d_int[26],
          15'b000000000000000, d_int[25], 15'b000000000000000, d_int[24], 15'b000000000000000, d_int[23],
          15'b000000000000000, d_int[22], 15'b000000000000000, d_int[21], 15'b000000000000000, d_int[20],
          15'b000000000000000, d_int[19], 15'b000000000000000, d_int[18], 15'b000000000000000, d_int[17],
          15'b000000000000000, d_int[16], 15'b000000000000000, d_int[15], 15'b000000000000000, d_int[14],
          15'b000000000000000, d_int[13], 15'b000000000000000, d_int[12], 15'b000000000000000, d_int[11],
          15'b000000000000000, d_int[10], 15'b000000000000000, d_int[9], 15'b000000000000000, d_int[8],
          15'b000000000000000, d_int[7], 15'b000000000000000, d_int[6], 15'b000000000000000, d_int[5],
          15'b000000000000000, d_int[4], 15'b000000000000000, d_int[3], 15'b000000000000000, d_int[2],
          15'b000000000000000, d_int[1], 15'b000000000000000, d_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xq = 1'b0; q_update = 1'b1;
      end
    if (wabl_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (^wablm_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (rawl_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (^rawlm_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
      if( isBitX(gwen_int) )  begin
        Xq = 1'b1; q_update = 1'b1;
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
  always @ (VDDCE) begin
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
  always @ (ret1n_ or  VDDPE or VDDCE or VSSE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st == 1'b1 && (cen_ === 1'bx || clk_ === 1'bx)) begin
      failedWrite(0);
        Q_latch_corrupt;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        Q_latch_corrupt;
    end else if (ret1n_ === 1'b0 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        Q_latch_corrupt;
    end else if (ret1n_ === 1'b1 && ret1n_int !== 1'bx && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        Q_latch_corrupt;
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && VDDPE !== 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(0);
    end else if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
        Q_latch_corrupt;
      q_int_delayed = {64{1'bx}};
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 0;
    end else begin
      pre_charge_st = 0;
`else     
    end else begin
`endif
if ($realtime != 0)  Q_latch_corrupt;
      q_int_delayed = {64{1'bx}};
      cen_int = 1'bx;
      gwen_int = 1'bx;
      a_int = {12{1'bx}};
      d_int = {64{1'bx}};
      stov_int = 1'bx;
      ema_int = {3{1'bx}};
      emaw_int = {2{1'bx}};
      emas_int = 1'bx;
      ret1n_int = 1'bx;
      rawl_int = 1'bx;
      rawlm_int = {2{1'bx}};
      wabl_int = 1'bx;
      wablm_int = {2{1'bx}};
    end
    ret1n_int = ret1n_;
  end
   reg   ret1n_s;
`ifdef POWER_PINS
   reg   VDDCE_s;
   reg   VDDPE_s;
`endif
`ifdef POWER_PINS
	always @ (ret1n_ or VDDCE or VDDPE) begin 
`else
	always @ (ret1n_) begin 
`endif
 	ret1n_s <= ret1n_;
`ifdef POWER_PINS
 	VDDCE_s <= VDDCE;
 	VDDPE_s <= VDDPE;
`endif
	end
`ifdef POWER_PINS
	always @ (ret1n_s or VDDCE_s or VDDPE_s) begin 
`else
	always @ (ret1n_s) begin 
`endif
        Xq = 1'b0;
        Xd_int = {64{1'b0}};
        q_update = 1'b0;
	end
// Q_latch corruption
// -----------------------------
  task Q_latch_corrupt;
    begin
	uDQ0.Q = 1'bx;
	uDQ1.Q = 1'bx;
	uDQ2.Q = 1'bx;
	uDQ3.Q = 1'bx;
	uDQ4.Q = 1'bx;
	uDQ5.Q = 1'bx;
	uDQ6.Q = 1'bx;
	uDQ7.Q = 1'bx;
	uDQ8.Q = 1'bx;
	uDQ9.Q = 1'bx;
	uDQ10.Q = 1'bx;
	uDQ11.Q = 1'bx;
	uDQ12.Q = 1'bx;
	uDQ13.Q = 1'bx;
	uDQ14.Q = 1'bx;
	uDQ15.Q = 1'bx;
	uDQ16.Q = 1'bx;
	uDQ17.Q = 1'bx;
	uDQ18.Q = 1'bx;
	uDQ19.Q = 1'bx;
	uDQ20.Q = 1'bx;
	uDQ21.Q = 1'bx;
	uDQ22.Q = 1'bx;
	uDQ23.Q = 1'bx;
	uDQ24.Q = 1'bx;
	uDQ25.Q = 1'bx;
	uDQ26.Q = 1'bx;
	uDQ27.Q = 1'bx;
	uDQ28.Q = 1'bx;
	uDQ29.Q = 1'bx;
	uDQ30.Q = 1'bx;
	uDQ31.Q = 1'bx;
	uDQ32.Q = 1'bx;
	uDQ33.Q = 1'bx;
	uDQ34.Q = 1'bx;
	uDQ35.Q = 1'bx;
	uDQ36.Q = 1'bx;
	uDQ37.Q = 1'bx;
	uDQ38.Q = 1'bx;
	uDQ39.Q = 1'bx;
	uDQ40.Q = 1'bx;
	uDQ41.Q = 1'bx;
	uDQ42.Q = 1'bx;
	uDQ43.Q = 1'bx;
	uDQ44.Q = 1'bx;
	uDQ45.Q = 1'bx;
	uDQ46.Q = 1'bx;
	uDQ47.Q = 1'bx;
	uDQ48.Q = 1'bx;
	uDQ49.Q = 1'bx;
	uDQ50.Q = 1'bx;
	uDQ51.Q = 1'bx;
	uDQ52.Q = 1'bx;
	uDQ53.Q = 1'bx;
	uDQ54.Q = 1'bx;
	uDQ55.Q = 1'bx;
	uDQ56.Q = 1'bx;
	uDQ57.Q = 1'bx;
	uDQ58.Q = 1'bx;
	uDQ59.Q = 1'bx;
	uDQ60.Q = 1'bx;
	uDQ61.Q = 1'bx;
	uDQ62.Q = 1'bx;
	uDQ63.Q = 1'bx;

    end
  endtask



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
`ifdef POWER_PINS
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
`else     
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
`endif
      // no cycle in retention mode or during external power down
`ifdef POWER_PINS
    end else if ((VDDCE === 1'bx || VDDCE === 1'bz)) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
  end else if (ret1n_ == 1'b1 && VDDPE !== 1'b1) begin
  end else if (VSSE !== 1'b0) begin
`endif
  end else begin
    if ((clk_ === 1'bx || clk_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if ((clk_ === 1'b1 || clk_ === 1'b0) && LAST_clk === 1'bx) begin
       d_sh_update = 1'b0;  Xd_sh = 1'b0;
       Xd_int = {64{1'b0}};
       Xq = 1'b0; q_update = 1'b0; 
    end else if (clk_ === 1'b1 && LAST_clk === 1'b0) begin
      cen_int = cen_;
      stov_int = stov_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      if (cen_int != 1'b1) begin
        gwen_int = gwen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      cen_int = cen_;
      stov_int = stov_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      if (cen_int != 1'b1) begin
        gwen_int = gwen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      if (cen_int === 1'b0 && gwen_int === 1'b1) 
         q_int_delayed = {64{1'bx}};
    readWrite;
    end else if (clk_ === 1'b0 && LAST_clk === 1'b1) begin
      q_int_delayed = q_int;
      q_update = 1'b0;
      d_sh_update = 1'b0;
      Xq = 1'b0;
       Xd_int = {64{1'b0}};
    end
  end
    LAST_clk = clk_;
  end

  assign d_int_bmux = d_;

  datapath_latch_sramsp_4096_64 uDQ0 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(1'b0), .D(d_int_bmux[0]), .DFTRAMBYP(1'b0), .mem_path(mem_path[0]), .XQ(Xq|Xd_int[0]|1'b0), .Q(q_int[0]));
  datapath_latch_sramsp_4096_64 uDQ1 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[0]), .D(d_int_bmux[1]), .DFTRAMBYP(1'b0), .mem_path(mem_path[1]), .XQ(Xq|Xd_int[1]), .Q(q_int[1]));
  datapath_latch_sramsp_4096_64 uDQ2 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[1]), .D(d_int_bmux[2]), .DFTRAMBYP(1'b0), .mem_path(mem_path[2]), .XQ(Xq|Xd_int[2]), .Q(q_int[2]));
  datapath_latch_sramsp_4096_64 uDQ3 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[2]), .D(d_int_bmux[3]), .DFTRAMBYP(1'b0), .mem_path(mem_path[3]), .XQ(Xq|Xd_int[3]), .Q(q_int[3]));
  datapath_latch_sramsp_4096_64 uDQ4 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[3]), .D(d_int_bmux[4]), .DFTRAMBYP(1'b0), .mem_path(mem_path[4]), .XQ(Xq|Xd_int[4]), .Q(q_int[4]));
  datapath_latch_sramsp_4096_64 uDQ5 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[4]), .D(d_int_bmux[5]), .DFTRAMBYP(1'b0), .mem_path(mem_path[5]), .XQ(Xq|Xd_int[5]), .Q(q_int[5]));
  datapath_latch_sramsp_4096_64 uDQ6 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[5]), .D(d_int_bmux[6]), .DFTRAMBYP(1'b0), .mem_path(mem_path[6]), .XQ(Xq|Xd_int[6]), .Q(q_int[6]));
  datapath_latch_sramsp_4096_64 uDQ7 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[6]), .D(d_int_bmux[7]), .DFTRAMBYP(1'b0), .mem_path(mem_path[7]), .XQ(Xq|Xd_int[7]), .Q(q_int[7]));
  datapath_latch_sramsp_4096_64 uDQ8 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[7]), .D(d_int_bmux[8]), .DFTRAMBYP(1'b0), .mem_path(mem_path[8]), .XQ(Xq|Xd_int[8]), .Q(q_int[8]));
  datapath_latch_sramsp_4096_64 uDQ9 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[8]), .D(d_int_bmux[9]), .DFTRAMBYP(1'b0), .mem_path(mem_path[9]), .XQ(Xq|Xd_int[9]), .Q(q_int[9]));
  datapath_latch_sramsp_4096_64 uDQ10 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[9]), .D(d_int_bmux[10]), .DFTRAMBYP(1'b0), .mem_path(mem_path[10]), .XQ(Xq|Xd_int[10]), .Q(q_int[10]));
  datapath_latch_sramsp_4096_64 uDQ11 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[10]), .D(d_int_bmux[11]), .DFTRAMBYP(1'b0), .mem_path(mem_path[11]), .XQ(Xq|Xd_int[11]), .Q(q_int[11]));
  datapath_latch_sramsp_4096_64 uDQ12 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[11]), .D(d_int_bmux[12]), .DFTRAMBYP(1'b0), .mem_path(mem_path[12]), .XQ(Xq|Xd_int[12]), .Q(q_int[12]));
  datapath_latch_sramsp_4096_64 uDQ13 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[12]), .D(d_int_bmux[13]), .DFTRAMBYP(1'b0), .mem_path(mem_path[13]), .XQ(Xq|Xd_int[13]), .Q(q_int[13]));
  datapath_latch_sramsp_4096_64 uDQ14 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[13]), .D(d_int_bmux[14]), .DFTRAMBYP(1'b0), .mem_path(mem_path[14]), .XQ(Xq|Xd_int[14]), .Q(q_int[14]));
  datapath_latch_sramsp_4096_64 uDQ15 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[14]), .D(d_int_bmux[15]), .DFTRAMBYP(1'b0), .mem_path(mem_path[15]), .XQ(Xq|Xd_int[15]), .Q(q_int[15]));
  datapath_latch_sramsp_4096_64 uDQ16 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[15]), .D(d_int_bmux[16]), .DFTRAMBYP(1'b0), .mem_path(mem_path[16]), .XQ(Xq|Xd_int[16]), .Q(q_int[16]));
  datapath_latch_sramsp_4096_64 uDQ17 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[16]), .D(d_int_bmux[17]), .DFTRAMBYP(1'b0), .mem_path(mem_path[17]), .XQ(Xq|Xd_int[17]), .Q(q_int[17]));
  datapath_latch_sramsp_4096_64 uDQ18 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[17]), .D(d_int_bmux[18]), .DFTRAMBYP(1'b0), .mem_path(mem_path[18]), .XQ(Xq|Xd_int[18]), .Q(q_int[18]));
  datapath_latch_sramsp_4096_64 uDQ19 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[18]), .D(d_int_bmux[19]), .DFTRAMBYP(1'b0), .mem_path(mem_path[19]), .XQ(Xq|Xd_int[19]), .Q(q_int[19]));
  datapath_latch_sramsp_4096_64 uDQ20 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[19]), .D(d_int_bmux[20]), .DFTRAMBYP(1'b0), .mem_path(mem_path[20]), .XQ(Xq|Xd_int[20]), .Q(q_int[20]));
  datapath_latch_sramsp_4096_64 uDQ21 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[20]), .D(d_int_bmux[21]), .DFTRAMBYP(1'b0), .mem_path(mem_path[21]), .XQ(Xq|Xd_int[21]), .Q(q_int[21]));
  datapath_latch_sramsp_4096_64 uDQ22 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[21]), .D(d_int_bmux[22]), .DFTRAMBYP(1'b0), .mem_path(mem_path[22]), .XQ(Xq|Xd_int[22]), .Q(q_int[22]));
  datapath_latch_sramsp_4096_64 uDQ23 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[22]), .D(d_int_bmux[23]), .DFTRAMBYP(1'b0), .mem_path(mem_path[23]), .XQ(Xq|Xd_int[23]), .Q(q_int[23]));
  datapath_latch_sramsp_4096_64 uDQ24 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[23]), .D(d_int_bmux[24]), .DFTRAMBYP(1'b0), .mem_path(mem_path[24]), .XQ(Xq|Xd_int[24]), .Q(q_int[24]));
  datapath_latch_sramsp_4096_64 uDQ25 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[24]), .D(d_int_bmux[25]), .DFTRAMBYP(1'b0), .mem_path(mem_path[25]), .XQ(Xq|Xd_int[25]), .Q(q_int[25]));
  datapath_latch_sramsp_4096_64 uDQ26 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[25]), .D(d_int_bmux[26]), .DFTRAMBYP(1'b0), .mem_path(mem_path[26]), .XQ(Xq|Xd_int[26]), .Q(q_int[26]));
  datapath_latch_sramsp_4096_64 uDQ27 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[26]), .D(d_int_bmux[27]), .DFTRAMBYP(1'b0), .mem_path(mem_path[27]), .XQ(Xq|Xd_int[27]), .Q(q_int[27]));
  datapath_latch_sramsp_4096_64 uDQ28 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[27]), .D(d_int_bmux[28]), .DFTRAMBYP(1'b0), .mem_path(mem_path[28]), .XQ(Xq|Xd_int[28]), .Q(q_int[28]));
  datapath_latch_sramsp_4096_64 uDQ29 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[28]), .D(d_int_bmux[29]), .DFTRAMBYP(1'b0), .mem_path(mem_path[29]), .XQ(Xq|Xd_int[29]), .Q(q_int[29]));
  datapath_latch_sramsp_4096_64 uDQ30 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[29]), .D(d_int_bmux[30]), .DFTRAMBYP(1'b0), .mem_path(mem_path[30]), .XQ(Xq|Xd_int[30]), .Q(q_int[30]));
  datapath_latch_sramsp_4096_64 uDQ31 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[30]), .D(d_int_bmux[31]), .DFTRAMBYP(1'b0), .mem_path(mem_path[31]), .XQ(Xq|Xd_int[31]), .Q(q_int[31]));
  datapath_latch_sramsp_4096_64 uDQ32 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[33]), .D(d_int_bmux[32]), .DFTRAMBYP(1'b0), .mem_path(mem_path[32]), .XQ(Xq|Xd_int[32]), .Q(q_int[32]));
  datapath_latch_sramsp_4096_64 uDQ33 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[34]), .D(d_int_bmux[33]), .DFTRAMBYP(1'b0), .mem_path(mem_path[33]), .XQ(Xq|Xd_int[33]), .Q(q_int[33]));
  datapath_latch_sramsp_4096_64 uDQ34 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[35]), .D(d_int_bmux[34]), .DFTRAMBYP(1'b0), .mem_path(mem_path[34]), .XQ(Xq|Xd_int[34]), .Q(q_int[34]));
  datapath_latch_sramsp_4096_64 uDQ35 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[36]), .D(d_int_bmux[35]), .DFTRAMBYP(1'b0), .mem_path(mem_path[35]), .XQ(Xq|Xd_int[35]), .Q(q_int[35]));
  datapath_latch_sramsp_4096_64 uDQ36 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[37]), .D(d_int_bmux[36]), .DFTRAMBYP(1'b0), .mem_path(mem_path[36]), .XQ(Xq|Xd_int[36]), .Q(q_int[36]));
  datapath_latch_sramsp_4096_64 uDQ37 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[38]), .D(d_int_bmux[37]), .DFTRAMBYP(1'b0), .mem_path(mem_path[37]), .XQ(Xq|Xd_int[37]), .Q(q_int[37]));
  datapath_latch_sramsp_4096_64 uDQ38 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[39]), .D(d_int_bmux[38]), .DFTRAMBYP(1'b0), .mem_path(mem_path[38]), .XQ(Xq|Xd_int[38]), .Q(q_int[38]));
  datapath_latch_sramsp_4096_64 uDQ39 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[40]), .D(d_int_bmux[39]), .DFTRAMBYP(1'b0), .mem_path(mem_path[39]), .XQ(Xq|Xd_int[39]), .Q(q_int[39]));
  datapath_latch_sramsp_4096_64 uDQ40 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[41]), .D(d_int_bmux[40]), .DFTRAMBYP(1'b0), .mem_path(mem_path[40]), .XQ(Xq|Xd_int[40]), .Q(q_int[40]));
  datapath_latch_sramsp_4096_64 uDQ41 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[42]), .D(d_int_bmux[41]), .DFTRAMBYP(1'b0), .mem_path(mem_path[41]), .XQ(Xq|Xd_int[41]), .Q(q_int[41]));
  datapath_latch_sramsp_4096_64 uDQ42 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[43]), .D(d_int_bmux[42]), .DFTRAMBYP(1'b0), .mem_path(mem_path[42]), .XQ(Xq|Xd_int[42]), .Q(q_int[42]));
  datapath_latch_sramsp_4096_64 uDQ43 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[44]), .D(d_int_bmux[43]), .DFTRAMBYP(1'b0), .mem_path(mem_path[43]), .XQ(Xq|Xd_int[43]), .Q(q_int[43]));
  datapath_latch_sramsp_4096_64 uDQ44 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[45]), .D(d_int_bmux[44]), .DFTRAMBYP(1'b0), .mem_path(mem_path[44]), .XQ(Xq|Xd_int[44]), .Q(q_int[44]));
  datapath_latch_sramsp_4096_64 uDQ45 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[46]), .D(d_int_bmux[45]), .DFTRAMBYP(1'b0), .mem_path(mem_path[45]), .XQ(Xq|Xd_int[45]), .Q(q_int[45]));
  datapath_latch_sramsp_4096_64 uDQ46 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[47]), .D(d_int_bmux[46]), .DFTRAMBYP(1'b0), .mem_path(mem_path[46]), .XQ(Xq|Xd_int[46]), .Q(q_int[46]));
  datapath_latch_sramsp_4096_64 uDQ47 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[48]), .D(d_int_bmux[47]), .DFTRAMBYP(1'b0), .mem_path(mem_path[47]), .XQ(Xq|Xd_int[47]), .Q(q_int[47]));
  datapath_latch_sramsp_4096_64 uDQ48 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[49]), .D(d_int_bmux[48]), .DFTRAMBYP(1'b0), .mem_path(mem_path[48]), .XQ(Xq|Xd_int[48]), .Q(q_int[48]));
  datapath_latch_sramsp_4096_64 uDQ49 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[50]), .D(d_int_bmux[49]), .DFTRAMBYP(1'b0), .mem_path(mem_path[49]), .XQ(Xq|Xd_int[49]), .Q(q_int[49]));
  datapath_latch_sramsp_4096_64 uDQ50 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[51]), .D(d_int_bmux[50]), .DFTRAMBYP(1'b0), .mem_path(mem_path[50]), .XQ(Xq|Xd_int[50]), .Q(q_int[50]));
  datapath_latch_sramsp_4096_64 uDQ51 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[52]), .D(d_int_bmux[51]), .DFTRAMBYP(1'b0), .mem_path(mem_path[51]), .XQ(Xq|Xd_int[51]), .Q(q_int[51]));
  datapath_latch_sramsp_4096_64 uDQ52 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[53]), .D(d_int_bmux[52]), .DFTRAMBYP(1'b0), .mem_path(mem_path[52]), .XQ(Xq|Xd_int[52]), .Q(q_int[52]));
  datapath_latch_sramsp_4096_64 uDQ53 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[54]), .D(d_int_bmux[53]), .DFTRAMBYP(1'b0), .mem_path(mem_path[53]), .XQ(Xq|Xd_int[53]), .Q(q_int[53]));
  datapath_latch_sramsp_4096_64 uDQ54 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[55]), .D(d_int_bmux[54]), .DFTRAMBYP(1'b0), .mem_path(mem_path[54]), .XQ(Xq|Xd_int[54]), .Q(q_int[54]));
  datapath_latch_sramsp_4096_64 uDQ55 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[56]), .D(d_int_bmux[55]), .DFTRAMBYP(1'b0), .mem_path(mem_path[55]), .XQ(Xq|Xd_int[55]), .Q(q_int[55]));
  datapath_latch_sramsp_4096_64 uDQ56 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[57]), .D(d_int_bmux[56]), .DFTRAMBYP(1'b0), .mem_path(mem_path[56]), .XQ(Xq|Xd_int[56]), .Q(q_int[56]));
  datapath_latch_sramsp_4096_64 uDQ57 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[58]), .D(d_int_bmux[57]), .DFTRAMBYP(1'b0), .mem_path(mem_path[57]), .XQ(Xq|Xd_int[57]), .Q(q_int[57]));
  datapath_latch_sramsp_4096_64 uDQ58 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[59]), .D(d_int_bmux[58]), .DFTRAMBYP(1'b0), .mem_path(mem_path[58]), .XQ(Xq|Xd_int[58]), .Q(q_int[58]));
  datapath_latch_sramsp_4096_64 uDQ59 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[60]), .D(d_int_bmux[59]), .DFTRAMBYP(1'b0), .mem_path(mem_path[59]), .XQ(Xq|Xd_int[59]), .Q(q_int[59]));
  datapath_latch_sramsp_4096_64 uDQ60 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[61]), .D(d_int_bmux[60]), .DFTRAMBYP(1'b0), .mem_path(mem_path[60]), .XQ(Xq|Xd_int[60]), .Q(q_int[60]));
  datapath_latch_sramsp_4096_64 uDQ61 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[62]), .D(d_int_bmux[61]), .DFTRAMBYP(1'b0), .mem_path(mem_path[61]), .XQ(Xq|Xd_int[61]), .Q(q_int[61]));
  datapath_latch_sramsp_4096_64 uDQ62 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[63]), .D(d_int_bmux[62]), .DFTRAMBYP(1'b0), .mem_path(mem_path[62]), .XQ(Xq|Xd_int[62]), .Q(q_int[62]));
  datapath_latch_sramsp_4096_64 uDQ63 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(1'b0), .D(d_int_bmux[63]), .DFTRAMBYP(1'b0), .mem_path(mem_path[63]), .XQ(Xq|Xd_int[63]|1'b0), .Q(q_int[63]));



  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (cen_int === 1'bx || clk0_int === 1'bx || rawl_int === 1'bx || rawlm_int[0] === 1'bx || 
      rawlm_int[1] === 1'bx || ret1n_int === 1'bx || (stov_int && !cen_int) === 1'bx || 
      wabl_int === 1'bx || wablm_int[0] === 1'bx || wablm_int[1] === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    	 mem_path = {64{1'bx}};
      q_int_delayed = {64{1'bx}};
      failedWrite(0);
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
        failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else begin
      #0;
      readWrite;
   end
      #0;
        Xq = 1'b0; q_update = 1'b0;
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
        Xq = 1'b1; q_update = 1'b1;
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (VDDPE !== 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        Xq = 1'b1; q_update = 1'b1;
		if (ret1n_ !== 1'b0)
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE !== 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        Xq = 1'b1; q_update = 1'b1;
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
  always @ NOT_gwen begin
    gwen_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a11 begin
    a_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a10 begin
    a_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a9 begin
    a_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a8 begin
    a_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a7 begin
    a_int[7] = 1'bx;
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
  always @ NOT_d63 begin
    d_int[63] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d62 begin
    d_int[62] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d61 begin
    d_int[61] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d60 begin
    d_int[60] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d59 begin
    d_int[59] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d58 begin
    d_int[58] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d57 begin
    d_int[57] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d56 begin
    d_int[56] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d55 begin
    d_int[55] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d54 begin
    d_int[54] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d53 begin
    d_int[53] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d52 begin
    d_int[52] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d51 begin
    d_int[51] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d50 begin
    d_int[50] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d49 begin
    d_int[49] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d48 begin
    d_int[48] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d47 begin
    d_int[47] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d46 begin
    d_int[46] = 1'bx;
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
  always @ NOT_stov begin
    stov_int = 1'bx;
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


  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1;

  wire stoveq0aret1neq1aceneq0, stoveq1aret1neq1aceneq0, ret1neq1, rawleq1awableq1aret1neq1aceneq0;
  wire rawleq0awableq1aret1neq1aceneq0, rawleq1awableq0aret1neq1aceneq0, rawleq0awableq0aret1neq1aceneq0;
  wire ret1neq1aceneq0agweneq0, ret1neq1aceneq0, ret1neq1agweneq0aceneq0;

  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;


  assign stoveq0aret1neq1aceneq0 = !stov&&ret1n&&!cen;
  assign stoveq1aret1neq1aceneq0 = stov&&ret1n&&!cen;
  assign rawleq1awableq1aret1neq1aceneq0 = rawl&&wabl&&ret1n&&!cen;
  assign rawleq0awableq1aret1neq1aceneq0 = !rawl&&wabl&&ret1n&&!cen;
  assign rawleq1awableq0aret1neq1aceneq0 = rawl&&!wabl&&ret1n&&!cen;
  assign rawleq0awableq0aret1neq1aceneq0 = !rawl&&!wabl&&ret1n&&!cen;
  assign ret1neq1aceneq0agweneq0 = ret1n&&!cen&&!gwen;
  assign ret1neq1agweneq0aceneq0 = ret1n&&!gwen&&!cen;

  assign ret1neq1 = ret1n;
  assign ret1neq1aceneq0 = ret1n&&!cen;

  specify

    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge clk, `ARM_MEM_PERIOD, NOT_clk_PER);
   `else
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_PERIOD, NOT_clk_PER);
   `endif


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge clk, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(negedge clk, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
   `else
       $width(posedge clk &&& stoveq0aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(posedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(negedge clk &&& stoveq0aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
       $width(negedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
   `endif

    $setuphold(posedge clk &&& ret1neq1, posedge cen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cen,,,dclk,dcen);
    $setuphold(posedge clk &&& ret1neq1, negedge cen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cen,,,dclk,dcen);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge gwen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_gwen,,,dclk,dgwen);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge gwen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_gwen,,,dclk,dgwen);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11,,,dclk,da[11]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10,,,dclk,da[10]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9,,,dclk,da[9]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8,,,dclk,da[8]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7,,,dclk,da[7]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6,,,dclk,da[6]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5,,,dclk,da[5]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4,,,dclk,da[4]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3,,,dclk,da[3]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2,,,dclk,da[2]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1,,,dclk,da[1]);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0,,,dclk,da[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[63], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d63,,,dclk,dd[63]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[62], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d62,,,dclk,dd[62]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[61], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d61,,,dclk,dd[61]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[60], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d60,,,dclk,dd[60]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[59], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d59,,,dclk,dd[59]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[58], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d58,,,dclk,dd[58]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[57], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d57,,,dclk,dd[57]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[56], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d56,,,dclk,dd[56]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[55], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d55,,,dclk,dd[55]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[54], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d54,,,dclk,dd[54]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[53], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d53,,,dclk,dd[53]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[52], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d52,,,dclk,dd[52]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[51], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d51,,,dclk,dd[51]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[50], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d50,,,dclk,dd[50]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[49], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d49,,,dclk,dd[49]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[48], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d48,,,dclk,dd[48]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[47], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d47,,,dclk,dd[47]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[46], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d46,,,dclk,dd[46]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[45], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d45,,,dclk,dd[45]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[44], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d44,,,dclk,dd[44]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[43], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d43,,,dclk,dd[43]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[42], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d42,,,dclk,dd[42]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[41], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d41,,,dclk,dd[41]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[40], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d40,,,dclk,dd[40]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[39], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d39,,,dclk,dd[39]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[38], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d38,,,dclk,dd[38]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[37], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d37,,,dclk,dd[37]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[36], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d36,,,dclk,dd[36]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[35], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d35,,,dclk,dd[35]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[34], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d34,,,dclk,dd[34]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[33], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d33,,,dclk,dd[33]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[32], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d32,,,dclk,dd[32]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[31], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d31,,,dclk,dd[31]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[30], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d30,,,dclk,dd[30]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[29], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d29,,,dclk,dd[29]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[28], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d28,,,dclk,dd[28]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[27], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d27,,,dclk,dd[27]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[26], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d26,,,dclk,dd[26]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[25], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d25,,,dclk,dd[25]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[24], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d24,,,dclk,dd[24]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[23], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d23,,,dclk,dd[23]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[22], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d22,,,dclk,dd[22]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[21], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d21,,,dclk,dd[21]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[20], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d20,,,dclk,dd[20]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[19], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d19,,,dclk,dd[19]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[18], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d18,,,dclk,dd[18]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[17], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d17,,,dclk,dd[17]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[16], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d16,,,dclk,dd[16]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d15,,,dclk,dd[15]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d14,,,dclk,dd[14]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d13,,,dclk,dd[13]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d12,,,dclk,dd[12]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d11,,,dclk,dd[11]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d10,,,dclk,dd[10]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d9,,,dclk,dd[9]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d8,,,dclk,dd[8]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d7,,,dclk,dd[7]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d6,,,dclk,dd[6]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d5,,,dclk,dd[5]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d4,,,dclk,dd[4]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d3,,,dclk,dd[3]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d2,,,dclk,dd[2]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d1,,,dclk,dd[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d0,,,dclk,dd[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[63], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d63,,,dclk,dd[63]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[62], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d62,,,dclk,dd[62]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[61], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d61,,,dclk,dd[61]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[60], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d60,,,dclk,dd[60]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[59], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d59,,,dclk,dd[59]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[58], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d58,,,dclk,dd[58]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[57], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d57,,,dclk,dd[57]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[56], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d56,,,dclk,dd[56]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[55], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d55,,,dclk,dd[55]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[54], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d54,,,dclk,dd[54]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[53], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d53,,,dclk,dd[53]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[52], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d52,,,dclk,dd[52]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[51], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d51,,,dclk,dd[51]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[50], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d50,,,dclk,dd[50]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[49], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d49,,,dclk,dd[49]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[48], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d48,,,dclk,dd[48]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[47], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d47,,,dclk,dd[47]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[46], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d46,,,dclk,dd[46]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[45], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d45,,,dclk,dd[45]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[44], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d44,,,dclk,dd[44]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[43], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d43,,,dclk,dd[43]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[42], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d42,,,dclk,dd[42]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[41], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d41,,,dclk,dd[41]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[40], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d40,,,dclk,dd[40]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[39], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d39,,,dclk,dd[39]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[38], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d38,,,dclk,dd[38]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[37], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d37,,,dclk,dd[37]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[36], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d36,,,dclk,dd[36]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[35], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d35,,,dclk,dd[35]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[34], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d34,,,dclk,dd[34]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[33], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d33,,,dclk,dd[33]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[32], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d32,,,dclk,dd[32]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[31], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d31,,,dclk,dd[31]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[30], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d30,,,dclk,dd[30]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[29], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d29,,,dclk,dd[29]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[28], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d28,,,dclk,dd[28]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[27], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d27,,,dclk,dd[27]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[26], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d26,,,dclk,dd[26]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[25], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d25,,,dclk,dd[25]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[24], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d24,,,dclk,dd[24]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[23], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d23,,,dclk,dd[23]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[22], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d22,,,dclk,dd[22]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[21], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d21,,,dclk,dd[21]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[20], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d20,,,dclk,dd[20]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[19], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d19,,,dclk,dd[19]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[18], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d18,,,dclk,dd[18]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[17], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d17,,,dclk,dd[17]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[16], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d16,,,dclk,dd[16]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d15,,,dclk,dd[15]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d14,,,dclk,dd[14]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d13,,,dclk,dd[13]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d12,,,dclk,dd[12]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d11,,,dclk,dd[11]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d10,,,dclk,dd[10]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d9,,,dclk,dd[9]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d8,,,dclk,dd[8]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d7,,,dclk,dd[7]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d6,,,dclk,dd[6]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d5,,,dclk,dd[5]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d4,,,dclk,dd[4]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d3,,,dclk,dd[3]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d2,,,dclk,dd[2]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d1,,,dclk,dd[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d0,,,dclk,dd[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge stov, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_stov,,,dclk,dstov);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge stov, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_stov,,,dclk,dstov);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge ema[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema2,,,dclk,dema[2]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge ema[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema1,,,dclk,dema[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge ema[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema0,,,dclk,dema[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge ema[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema2,,,dclk,dema[2]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge ema[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema1,,,dclk,dema[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge ema[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ema0,,,dclk,dema[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge emaw[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw1,,,dclk,demaw[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge emaw[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw0,,,dclk,demaw[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge emaw[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw1,,,dclk,demaw[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge emaw[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaw0,,,dclk,demaw[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge emas, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emas,,,dclk,demas);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge emas, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emas,,,dclk,demas);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawl,,,dclk,drawl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawl,,,dclk,drawl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawlm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm1,,,dclk,drawlm[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawlm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm0,,,dclk,drawlm[0]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawlm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm1,,,dclk,drawlm[1]);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawlm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm0,,,dclk,drawlm[0]);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, posedge wabl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wabl,,,dclk,dwabl);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, negedge wabl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wabl,,,dclk,dwabl);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, posedge wablm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm1,,,dclk,dwablm[1]);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, posedge wablm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm0,,,dclk,dwablm[0]);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, negedge wablm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm1,,,dclk,dwablm[1]);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, negedge wablm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm0,,,dclk,dwablm[0]);
    $setuphold(negedge ret1n, negedge cen, 0.000, `ARM_MEM_HOLD, NOT_ret1n,,,dret1n,dcen);
    $setuphold(posedge ret1n, negedge cen, 0.000, `ARM_MEM_HOLD, NOT_ret1n,,,dret1n,dcen);
    $setuphold(posedge cen, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n,,,dcen,dret1n);
    $setuphold(posedge cen, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n,,,dcen,dret1n);
  endspecify


endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sramsp_4096_64 (VDDCE, VDDPE, VSSE, q, clk, cen, gwen, a, d, stov, ema, emaw, 
    emas, ret1n, rawl, rawlm, wabl, wablm);
`else
module sramsp_4096_64 (q, clk, cen, gwen, a, d, stov, ema, emaw, emas, ret1n, rawl, 
    rawlm, wabl, wablm);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 64;
  parameter WORDS = 4096;
  parameter MUX = 16;
  parameter MEM_WIDTH = 1024; // redun block size 16, 512 on left, 512 on right
  parameter MEM_HEIGHT = 256;
  parameter WP_SIZE = 64 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;
  parameter UPMP_WIDTH = 0;
  parameter ARM_DUMMY_CYCLE_WIDTH = `ARM_MEM_WIDTH;
  parameter ARM_LOCAL_OFFSET_TIME = `ARM_OFFSET_TIME;

`ifdef ARM_DISABLE_EMA_CHECK
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 1;
`else
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 0;
`endif

  parameter ARM_REF_EMA_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMA_VALUE;
  parameter ARM_REF_EMAW_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAW_VALUE;
  parameter ARM_REF_EMAS_VALUE = `SRAM_SP_HDE_SVT_MVT_ARM_REF_EMAS_VALUE;
  parameter ROWS = 256;

  output [63:0] q;
  input  clk;
  input  cen;
  input  gwen;
  input [11:0] a;
  input [63:0] d;
  input  stov;
  input [2:0] ema;
  input [1:0] emaw;
  input  emas;
  input  ret1n;
  input  rawl;
  input [1:0] rawlm;
  input  wabl;
  input [1:0] wablm;
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
  reg pre_charge_st;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [1023:0] row, row_t;
  reg LAST_clk;
  reg [1023:0] mem [0:255];
  reg [1023:0] row_mask;
  reg [1023:0] new_data;
  reg [1023:0] data_out;
  reg [63:0] readLatch0;
  reg [63:0] shifted_readLatch0;
  wire [63:0] q_int;
  reg [63:0] q_int_delayed;
  reg Xq, q_update;
  reg Xd_sh, d_sh_update;
  wire [63:0] d_int_bmux;
  reg [63:0] mem_path;
  reg [63:0] mem_path_d;
  reg [63:0] writeEnable;

  reg NOT_cen, NOT_gwen, NOT_a11, NOT_a10, NOT_a9, NOT_a8, NOT_a7, NOT_a6, NOT_a5;
  reg NOT_a4, NOT_a3, NOT_a2, NOT_a1, NOT_a0, NOT_d63, NOT_d62, NOT_d61, NOT_d60, NOT_d59;
  reg NOT_d58, NOT_d57, NOT_d56, NOT_d55, NOT_d54, NOT_d53, NOT_d52, NOT_d51, NOT_d50;
  reg NOT_d49, NOT_d48, NOT_d47, NOT_d46, NOT_d45, NOT_d44, NOT_d43, NOT_d42, NOT_d41;
  reg NOT_d40, NOT_d39, NOT_d38, NOT_d37, NOT_d36, NOT_d35, NOT_d34, NOT_d33, NOT_d32;
  reg NOT_d31, NOT_d30, NOT_d29, NOT_d28, NOT_d27, NOT_d26, NOT_d25, NOT_d24, NOT_d23;
  reg NOT_d22, NOT_d21, NOT_d20, NOT_d19, NOT_d18, NOT_d17, NOT_d16, NOT_d15, NOT_d14;
  reg NOT_d13, NOT_d12, NOT_d11, NOT_d10, NOT_d9, NOT_d8, NOT_d7, NOT_d6, NOT_d5, NOT_d4;
  reg NOT_d3, NOT_d2, NOT_d1, NOT_d0, NOT_stov, NOT_ema2, NOT_ema1, NOT_ema0, NOT_emaw1;
  reg NOT_emaw0, NOT_emas, NOT_ret1n, NOT_rawl, NOT_rawlm1, NOT_rawlm0, NOT_wabl, NOT_wablm1;
  reg NOT_wablm0;
  reg NOT_clk_PER, NOT_clk_MINH, NOT_clk_MINL;
  reg clk0_int;

  wire [63:0] q_;
  wire [63:0] q_out;

 wire  clk_;
  wire  cen_;
  reg  cen_int;
  reg  cen_p2;
  wire  gwen_;
  reg  gwen_int;
  wire [11:0] a_;
  reg [11:0] a_int;
  wire [63:0] d_;
  reg [63:0] d_int;
  reg [63:0] Xd_int;
  wire  stov_;
  reg  stov_int;
  wire [2:0] ema_;
  reg [2:0] ema_int;
  wire [1:0] emaw_;
  reg [1:0] emaw_int;
  wire  emas_;
  reg  emas_int;
  wire  ret1n_;
  reg  ret1n_int;
  wire  rawl_;
  reg  rawl_int;
  wire [1:0] rawlm_;
  reg [1:0] rawlm_int;
  wire  wabl_;
  reg  wabl_int;
  wire [1:0] wablm_;
  reg [1:0] wablm_int;

  buf B157(q[0], q_[0]);
  buf B158(q[1], q_[1]);
  buf B159(q[2], q_[2]);
  buf B160(q[3], q_[3]);
  buf B161(q[4], q_[4]);
  buf B162(q[5], q_[5]);
  buf B163(q[6], q_[6]);
  buf B164(q[7], q_[7]);
  buf B165(q[8], q_[8]);
  buf B166(q[9], q_[9]);
  buf B167(q[10], q_[10]);
  buf B168(q[11], q_[11]);
  buf B169(q[12], q_[12]);
  buf B170(q[13], q_[13]);
  buf B171(q[14], q_[14]);
  buf B172(q[15], q_[15]);
  buf B173(q[16], q_[16]);
  buf B174(q[17], q_[17]);
  buf B175(q[18], q_[18]);
  buf B176(q[19], q_[19]);
  buf B177(q[20], q_[20]);
  buf B178(q[21], q_[21]);
  buf B179(q[22], q_[22]);
  buf B180(q[23], q_[23]);
  buf B181(q[24], q_[24]);
  buf B182(q[25], q_[25]);
  buf B183(q[26], q_[26]);
  buf B184(q[27], q_[27]);
  buf B185(q[28], q_[28]);
  buf B186(q[29], q_[29]);
  buf B187(q[30], q_[30]);
  buf B188(q[31], q_[31]);
  buf B189(q[32], q_[32]);
  buf B190(q[33], q_[33]);
  buf B191(q[34], q_[34]);
  buf B192(q[35], q_[35]);
  buf B193(q[36], q_[36]);
  buf B194(q[37], q_[37]);
  buf B195(q[38], q_[38]);
  buf B196(q[39], q_[39]);
  buf B197(q[40], q_[40]);
  buf B198(q[41], q_[41]);
  buf B199(q[42], q_[42]);
  buf B200(q[43], q_[43]);
  buf B201(q[44], q_[44]);
  buf B202(q[45], q_[45]);
  buf B203(q[46], q_[46]);
  buf B204(q[47], q_[47]);
  buf B205(q[48], q_[48]);
  buf B206(q[49], q_[49]);
  buf B207(q[50], q_[50]);
  buf B208(q[51], q_[51]);
  buf B209(q[52], q_[52]);
  buf B210(q[53], q_[53]);
  buf B211(q[54], q_[54]);
  buf B212(q[55], q_[55]);
  buf B213(q[56], q_[56]);
  buf B214(q[57], q_[57]);
  buf B215(q[58], q_[58]);
  buf B216(q[59], q_[59]);
  buf B217(q[60], q_[60]);
  buf B218(q[61], q_[61]);
  buf B219(q[62], q_[62]);
  buf B220(q[63], q_[63]);
  buf B221(clk_, clk);
  buf B222(cen_, cen);
  buf B223(gwen_, gwen);
  buf B224(a_[0], a[0]);
  buf B225(a_[1], a[1]);
  buf B226(a_[2], a[2]);
  buf B227(a_[3], a[3]);
  buf B228(a_[4], a[4]);
  buf B229(a_[5], a[5]);
  buf B230(a_[6], a[6]);
  buf B231(a_[7], a[7]);
  buf B232(a_[8], a[8]);
  buf B233(a_[9], a[9]);
  buf B234(a_[10], a[10]);
  buf B235(a_[11], a[11]);
  buf B236(d_[0], d[0]);
  buf B237(d_[1], d[1]);
  buf B238(d_[2], d[2]);
  buf B239(d_[3], d[3]);
  buf B240(d_[4], d[4]);
  buf B241(d_[5], d[5]);
  buf B242(d_[6], d[6]);
  buf B243(d_[7], d[7]);
  buf B244(d_[8], d[8]);
  buf B245(d_[9], d[9]);
  buf B246(d_[10], d[10]);
  buf B247(d_[11], d[11]);
  buf B248(d_[12], d[12]);
  buf B249(d_[13], d[13]);
  buf B250(d_[14], d[14]);
  buf B251(d_[15], d[15]);
  buf B252(d_[16], d[16]);
  buf B253(d_[17], d[17]);
  buf B254(d_[18], d[18]);
  buf B255(d_[19], d[19]);
  buf B256(d_[20], d[20]);
  buf B257(d_[21], d[21]);
  buf B258(d_[22], d[22]);
  buf B259(d_[23], d[23]);
  buf B260(d_[24], d[24]);
  buf B261(d_[25], d[25]);
  buf B262(d_[26], d[26]);
  buf B263(d_[27], d[27]);
  buf B264(d_[28], d[28]);
  buf B265(d_[29], d[29]);
  buf B266(d_[30], d[30]);
  buf B267(d_[31], d[31]);
  buf B268(d_[32], d[32]);
  buf B269(d_[33], d[33]);
  buf B270(d_[34], d[34]);
  buf B271(d_[35], d[35]);
  buf B272(d_[36], d[36]);
  buf B273(d_[37], d[37]);
  buf B274(d_[38], d[38]);
  buf B275(d_[39], d[39]);
  buf B276(d_[40], d[40]);
  buf B277(d_[41], d[41]);
  buf B278(d_[42], d[42]);
  buf B279(d_[43], d[43]);
  buf B280(d_[44], d[44]);
  buf B281(d_[45], d[45]);
  buf B282(d_[46], d[46]);
  buf B283(d_[47], d[47]);
  buf B284(d_[48], d[48]);
  buf B285(d_[49], d[49]);
  buf B286(d_[50], d[50]);
  buf B287(d_[51], d[51]);
  buf B288(d_[52], d[52]);
  buf B289(d_[53], d[53]);
  buf B290(d_[54], d[54]);
  buf B291(d_[55], d[55]);
  buf B292(d_[56], d[56]);
  buf B293(d_[57], d[57]);
  buf B294(d_[58], d[58]);
  buf B295(d_[59], d[59]);
  buf B296(d_[60], d[60]);
  buf B297(d_[61], d[61]);
  buf B298(d_[62], d[62]);
  buf B299(d_[63], d[63]);
  buf B300(stov_, stov);
  buf B301(ema_[0], ema[0]);
  buf B302(ema_[1], ema[1]);
  buf B303(ema_[2], ema[2]);
  buf B304(emaw_[0], emaw[0]);
  buf B305(emaw_[1], emaw[1]);
  buf B306(emas_, emas);
  buf B307(ret1n_, ret1n);
  buf B308(rawl_, rawl);
  buf B309(rawlm_[0], rawlm[0]);
  buf B310(rawlm_[1], rawlm[1]);
  buf B311(wabl_, wabl);
  buf B312(wablm_[0], wablm[0]);
  buf B313(wablm_[1], wablm[1]);

`ifdef POWER_PINS
  assign corrupt_power = bad_power;
`else
  assign corrupt_power = 1'b0;
`endif

   `ifdef ARM_FAULT_MODELING
     sramsp_4096_64_error_injection u1(.CLK(clk_), .Q_out(q_out), .A(a_int), .CEN(cen_int), .GWEN(gwen_int), .WEN(gwen_int), .Q_in(q_int));
  `else
   assign q_out = q_int;
  `endif
  assign q_ = (ret1n_ | pre_charge_st) & ~corrupt_power ? ((stov_ ? (q_int_delayed) : (q_out))) : {64{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial
  begin
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
	uDQ0.Q = $random;
	uDQ1.Q = $random;
	uDQ2.Q = $random;
	uDQ3.Q = $random;
	uDQ4.Q = $random;
	uDQ5.Q = $random;
	uDQ6.Q = $random;
	uDQ7.Q = $random;
	uDQ8.Q = $random;
	uDQ9.Q = $random;
	uDQ10.Q = $random;
	uDQ11.Q = $random;
	uDQ12.Q = $random;
	uDQ13.Q = $random;
	uDQ14.Q = $random;
	uDQ15.Q = $random;
	uDQ16.Q = $random;
	uDQ17.Q = $random;
	uDQ18.Q = $random;
	uDQ19.Q = $random;
	uDQ20.Q = $random;
	uDQ21.Q = $random;
	uDQ22.Q = $random;
	uDQ23.Q = $random;
	uDQ24.Q = $random;
	uDQ25.Q = $random;
	uDQ26.Q = $random;
	uDQ27.Q = $random;
	uDQ28.Q = $random;
	uDQ29.Q = $random;
	uDQ30.Q = $random;
	uDQ31.Q = $random;
	uDQ32.Q = $random;
	uDQ33.Q = $random;
	uDQ34.Q = $random;
	uDQ35.Q = $random;
	uDQ36.Q = $random;
	uDQ37.Q = $random;
	uDQ38.Q = $random;
	uDQ39.Q = $random;
	uDQ40.Q = $random;
	uDQ41.Q = $random;
	uDQ42.Q = $random;
	uDQ43.Q = $random;
	uDQ44.Q = $random;
	uDQ45.Q = $random;
	uDQ46.Q = $random;
	uDQ47.Q = $random;
	uDQ48.Q = $random;
	uDQ49.Q = $random;
	uDQ50.Q = $random;
	uDQ51.Q = $random;
	uDQ52.Q = $random;
	uDQ53.Q = $random;
	uDQ54.Q = $random;
	uDQ55.Q = $random;
	uDQ56.Q = $random;
	uDQ57.Q = $random;
	uDQ58.Q = $random;
	uDQ59.Q = $random;
	uDQ60.Q = $random;
	uDQ61.Q = $random;
	uDQ62.Q = $random;
	uDQ63.Q = $random;

  end
`endif

  always @ (posedge clk_) begin
      if(ema_ !== ARM_REF_EMA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for ema is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of ema", ema_, ARM_REF_EMA_VALUE, $time);
  end
  always @ (posedge clk_) begin
      if(emaw_ !== ARM_REF_EMAW_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for emaw is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of emaw", emaw_, ARM_REF_EMAW_VALUE, $time);
  end
  always @ (posedge clk_) begin
      if(emas_ !== ARM_REF_EMAS_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK==0) && ret1n_ === 1'b1 && ((cen_int === 1'b0 && clk_ === 1'b1  )    )) 
      $display("Warning: Set Value for emas is %0d and is not equal to %0d in %m at %0t. Please refer README for correct value of emas", emas_, ARM_REF_EMAS_VALUE, $time);
  end
	always @ (stov_) begin
		if(clk_ == 1'b1) begin
			Xq = 1'b1; q_update = 1'b1;
			#0; q_update = 1'b0;
			Xq = 1'b0;
		end
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
	reg [11:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[63], 15'b000000000000000, wordtemp[62],
          15'b000000000000000, wordtemp[61], 15'b000000000000000, wordtemp[60], 15'b000000000000000, wordtemp[59],
          15'b000000000000000, wordtemp[58], 15'b000000000000000, wordtemp[57], 15'b000000000000000, wordtemp[56],
          15'b000000000000000, wordtemp[55], 15'b000000000000000, wordtemp[54], 15'b000000000000000, wordtemp[53],
          15'b000000000000000, wordtemp[52], 15'b000000000000000, wordtemp[51], 15'b000000000000000, wordtemp[50],
          15'b000000000000000, wordtemp[49], 15'b000000000000000, wordtemp[48], 15'b000000000000000, wordtemp[47],
          15'b000000000000000, wordtemp[46], 15'b000000000000000, wordtemp[45], 15'b000000000000000, wordtemp[44],
          15'b000000000000000, wordtemp[43], 15'b000000000000000, wordtemp[42], 15'b000000000000000, wordtemp[41],
          15'b000000000000000, wordtemp[40], 15'b000000000000000, wordtemp[39], 15'b000000000000000, wordtemp[38],
          15'b000000000000000, wordtemp[37], 15'b000000000000000, wordtemp[36], 15'b000000000000000, wordtemp[35],
          15'b000000000000000, wordtemp[34], 15'b000000000000000, wordtemp[33], 15'b000000000000000, wordtemp[32],
          15'b000000000000000, wordtemp[31], 15'b000000000000000, wordtemp[30], 15'b000000000000000, wordtemp[29],
          15'b000000000000000, wordtemp[28], 15'b000000000000000, wordtemp[27], 15'b000000000000000, wordtemp[26],
          15'b000000000000000, wordtemp[25], 15'b000000000000000, wordtemp[24], 15'b000000000000000, wordtemp[23],
          15'b000000000000000, wordtemp[22], 15'b000000000000000, wordtemp[21], 15'b000000000000000, wordtemp[20],
          15'b000000000000000, wordtemp[19], 15'b000000000000000, wordtemp[18], 15'b000000000000000, wordtemp[17],
          15'b000000000000000, wordtemp[16], 15'b000000000000000, wordtemp[15], 15'b000000000000000, wordtemp[14],
          15'b000000000000000, wordtemp[13], 15'b000000000000000, wordtemp[12], 15'b000000000000000, wordtemp[11],
          15'b000000000000000, wordtemp[10], 15'b000000000000000, wordtemp[9], 15'b000000000000000, wordtemp[8],
          15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6], 15'b000000000000000, wordtemp[5],
          15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3], 15'b000000000000000, wordtemp[2],
          15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
  	end
`ifdef ARM_BACKDOOR_NOCEN
`else
    end
`endif
  end
  endtask

  task dumpmem;
	input [1000*8-1:0] filename_dump;
	integer i, dump_file_desc;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	 for (i=0;i<WORDS;i=i+1) begin
	 Atemp = i;
	 mux_address = (Atemp & 4'b1111);
      row_address = (Atemp >> 4);
      row = mem[row_address];
        writeEnable = {64{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_d = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
   	$fdisplay(dump_file_desc, "%b", mem_path_d);
     end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [11:0] load_addr;
	input [63:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, wordtemp[63], 15'b000000000000000, wordtemp[62],
          15'b000000000000000, wordtemp[61], 15'b000000000000000, wordtemp[60], 15'b000000000000000, wordtemp[59],
          15'b000000000000000, wordtemp[58], 15'b000000000000000, wordtemp[57], 15'b000000000000000, wordtemp[56],
          15'b000000000000000, wordtemp[55], 15'b000000000000000, wordtemp[54], 15'b000000000000000, wordtemp[53],
          15'b000000000000000, wordtemp[52], 15'b000000000000000, wordtemp[51], 15'b000000000000000, wordtemp[50],
          15'b000000000000000, wordtemp[49], 15'b000000000000000, wordtemp[48], 15'b000000000000000, wordtemp[47],
          15'b000000000000000, wordtemp[46], 15'b000000000000000, wordtemp[45], 15'b000000000000000, wordtemp[44],
          15'b000000000000000, wordtemp[43], 15'b000000000000000, wordtemp[42], 15'b000000000000000, wordtemp[41],
          15'b000000000000000, wordtemp[40], 15'b000000000000000, wordtemp[39], 15'b000000000000000, wordtemp[38],
          15'b000000000000000, wordtemp[37], 15'b000000000000000, wordtemp[36], 15'b000000000000000, wordtemp[35],
          15'b000000000000000, wordtemp[34], 15'b000000000000000, wordtemp[33], 15'b000000000000000, wordtemp[32],
          15'b000000000000000, wordtemp[31], 15'b000000000000000, wordtemp[30], 15'b000000000000000, wordtemp[29],
          15'b000000000000000, wordtemp[28], 15'b000000000000000, wordtemp[27], 15'b000000000000000, wordtemp[26],
          15'b000000000000000, wordtemp[25], 15'b000000000000000, wordtemp[24], 15'b000000000000000, wordtemp[23],
          15'b000000000000000, wordtemp[22], 15'b000000000000000, wordtemp[21], 15'b000000000000000, wordtemp[20],
          15'b000000000000000, wordtemp[19], 15'b000000000000000, wordtemp[18], 15'b000000000000000, wordtemp[17],
          15'b000000000000000, wordtemp[16], 15'b000000000000000, wordtemp[15], 15'b000000000000000, wordtemp[14],
          15'b000000000000000, wordtemp[13], 15'b000000000000000, wordtemp[12], 15'b000000000000000, wordtemp[11],
          15'b000000000000000, wordtemp[10], 15'b000000000000000, wordtemp[9], 15'b000000000000000, wordtemp[8],
          15'b000000000000000, wordtemp[7], 15'b000000000000000, wordtemp[6], 15'b000000000000000, wordtemp[5],
          15'b000000000000000, wordtemp[4], 15'b000000000000000, wordtemp[3], 15'b000000000000000, wordtemp[2],
          15'b000000000000000, wordtemp[1], 15'b000000000000000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask

  task dumpaddr;
	output [63:0] dump_data;
	input [11:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [11:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
     if (cen_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 4'b1111);
       row_address = (Atemp >> 4);
       row = mem[row_address];
        writeEnable = {64{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_d = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
   	dump_data = mem_path_d;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWrite;
  begin
    if (wabl_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (^wablm_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (rawl_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (^rawlm_int === 1'bx)
      begin
        d_int = {64{1'bx}};
        failedWrite(0);
      end
    if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if (ret1n_int === 1'b0 && cen_int === 1'b0) begin
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(ema_int), (emaw_int), (emas_int)} === 1'bx) begin
  if(isBitX(emas_int)) begin 
        Xq = 1'b1; q_update = 1'b1;
  end
  if(isBitX(emaw_int) && cen_int === 1'b0) begin 
    if (gwen_int === 1'b0)
      failedWrite(0);
  end
  if(isBitX(ema_int)) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
  end
    end else if (^{cen_int, (stov_int && !cen_int), rawl_int, rawlm_int, wabl_int, wablm_int} === 1'bx) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if ((a_int >= WORDS) && (cen_int === 1'b0)) begin
        Xq = gwen_int !== 1'b1 ? 1'b0 : 1'b1; q_update = gwen_int !== 1'b1 ? 1'b0 : 1'b1;
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
      if (gwen_int !== 1'b1)
        failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if (cen_int === 1'b0) begin
      mux_address = (a_int & 4'b1111);
      row_address = (a_int >> 4);
      if (row_address > 255)
        row = {1024{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {64{gwen_int}};
      if (gwen_int !== 1'b1) begin
        row_mask =  ( {15'b000000000000000, writeEnable[63], 15'b000000000000000, writeEnable[62],
          15'b000000000000000, writeEnable[61], 15'b000000000000000, writeEnable[60],
          15'b000000000000000, writeEnable[59], 15'b000000000000000, writeEnable[58],
          15'b000000000000000, writeEnable[57], 15'b000000000000000, writeEnable[56],
          15'b000000000000000, writeEnable[55], 15'b000000000000000, writeEnable[54],
          15'b000000000000000, writeEnable[53], 15'b000000000000000, writeEnable[52],
          15'b000000000000000, writeEnable[51], 15'b000000000000000, writeEnable[50],
          15'b000000000000000, writeEnable[49], 15'b000000000000000, writeEnable[48],
          15'b000000000000000, writeEnable[47], 15'b000000000000000, writeEnable[46],
          15'b000000000000000, writeEnable[45], 15'b000000000000000, writeEnable[44],
          15'b000000000000000, writeEnable[43], 15'b000000000000000, writeEnable[42],
          15'b000000000000000, writeEnable[41], 15'b000000000000000, writeEnable[40],
          15'b000000000000000, writeEnable[39], 15'b000000000000000, writeEnable[38],
          15'b000000000000000, writeEnable[37], 15'b000000000000000, writeEnable[36],
          15'b000000000000000, writeEnable[35], 15'b000000000000000, writeEnable[34],
          15'b000000000000000, writeEnable[33], 15'b000000000000000, writeEnable[32],
          15'b000000000000000, writeEnable[31], 15'b000000000000000, writeEnable[30],
          15'b000000000000000, writeEnable[29], 15'b000000000000000, writeEnable[28],
          15'b000000000000000, writeEnable[27], 15'b000000000000000, writeEnable[26],
          15'b000000000000000, writeEnable[25], 15'b000000000000000, writeEnable[24],
          15'b000000000000000, writeEnable[23], 15'b000000000000000, writeEnable[22],
          15'b000000000000000, writeEnable[21], 15'b000000000000000, writeEnable[20],
          15'b000000000000000, writeEnable[19], 15'b000000000000000, writeEnable[18],
          15'b000000000000000, writeEnable[17], 15'b000000000000000, writeEnable[16],
          15'b000000000000000, writeEnable[15], 15'b000000000000000, writeEnable[14],
          15'b000000000000000, writeEnable[13], 15'b000000000000000, writeEnable[12],
          15'b000000000000000, writeEnable[11], 15'b000000000000000, writeEnable[10],
          15'b000000000000000, writeEnable[9], 15'b000000000000000, writeEnable[8],
          15'b000000000000000, writeEnable[7], 15'b000000000000000, writeEnable[6],
          15'b000000000000000, writeEnable[5], 15'b000000000000000, writeEnable[4],
          15'b000000000000000, writeEnable[3], 15'b000000000000000, writeEnable[2],
          15'b000000000000000, writeEnable[1], 15'b000000000000000, writeEnable[0]} << mux_address);
        new_data =  ( {15'b000000000000000, d_int[63], 15'b000000000000000, d_int[62],
          15'b000000000000000, d_int[61], 15'b000000000000000, d_int[60], 15'b000000000000000, d_int[59],
          15'b000000000000000, d_int[58], 15'b000000000000000, d_int[57], 15'b000000000000000, d_int[56],
          15'b000000000000000, d_int[55], 15'b000000000000000, d_int[54], 15'b000000000000000, d_int[53],
          15'b000000000000000, d_int[52], 15'b000000000000000, d_int[51], 15'b000000000000000, d_int[50],
          15'b000000000000000, d_int[49], 15'b000000000000000, d_int[48], 15'b000000000000000, d_int[47],
          15'b000000000000000, d_int[46], 15'b000000000000000, d_int[45], 15'b000000000000000, d_int[44],
          15'b000000000000000, d_int[43], 15'b000000000000000, d_int[42], 15'b000000000000000, d_int[41],
          15'b000000000000000, d_int[40], 15'b000000000000000, d_int[39], 15'b000000000000000, d_int[38],
          15'b000000000000000, d_int[37], 15'b000000000000000, d_int[36], 15'b000000000000000, d_int[35],
          15'b000000000000000, d_int[34], 15'b000000000000000, d_int[33], 15'b000000000000000, d_int[32],
          15'b000000000000000, d_int[31], 15'b000000000000000, d_int[30], 15'b000000000000000, d_int[29],
          15'b000000000000000, d_int[28], 15'b000000000000000, d_int[27], 15'b000000000000000, d_int[26],
          15'b000000000000000, d_int[25], 15'b000000000000000, d_int[24], 15'b000000000000000, d_int[23],
          15'b000000000000000, d_int[22], 15'b000000000000000, d_int[21], 15'b000000000000000, d_int[20],
          15'b000000000000000, d_int[19], 15'b000000000000000, d_int[18], 15'b000000000000000, d_int[17],
          15'b000000000000000, d_int[16], 15'b000000000000000, d_int[15], 15'b000000000000000, d_int[14],
          15'b000000000000000, d_int[13], 15'b000000000000000, d_int[12], 15'b000000000000000, d_int[11],
          15'b000000000000000, d_int[10], 15'b000000000000000, d_int[9], 15'b000000000000000, d_int[8],
          15'b000000000000000, d_int[7], 15'b000000000000000, d_int[6], 15'b000000000000000, d_int[5],
          15'b000000000000000, d_int[4], 15'b000000000000000, d_int[3], 15'b000000000000000, d_int[2],
          15'b000000000000000, d_int[1], 15'b000000000000000, d_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[1008], data_out[992], data_out[976], data_out[960],
          data_out[944], data_out[928], data_out[912], data_out[896], data_out[880],
          data_out[864], data_out[848], data_out[832], data_out[816], data_out[800],
          data_out[784], data_out[768], data_out[752], data_out[736], data_out[720],
          data_out[704], data_out[688], data_out[672], data_out[656], data_out[640],
          data_out[624], data_out[608], data_out[592], data_out[576], data_out[560],
          data_out[544], data_out[528], data_out[512], data_out[496], data_out[480],
          data_out[464], data_out[448], data_out[432], data_out[416], data_out[400],
          data_out[384], data_out[368], data_out[352], data_out[336], data_out[320],
          data_out[304], data_out[288], data_out[272], data_out[256], data_out[240],
          data_out[224], data_out[208], data_out[192], data_out[176], data_out[160],
          data_out[144], data_out[128], data_out[112], data_out[96], data_out[80],
          data_out[64], data_out[48], data_out[32], data_out[16], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path = {shifted_readLatch0[63], shifted_readLatch0[62], shifted_readLatch0[61],
          shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58], shifted_readLatch0[57],
          shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54], shifted_readLatch0[53],
          shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50], shifted_readLatch0[49],
          shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46], shifted_readLatch0[45],
          shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42], shifted_readLatch0[41],
          shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38], shifted_readLatch0[37],
          shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34], shifted_readLatch0[33],
          shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30], shifted_readLatch0[29],
          shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26], shifted_readLatch0[25],
          shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22], shifted_readLatch0[21],
          shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18], shifted_readLatch0[17],
          shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xq = 1'b0; q_update = 1'b1;
      end
    if (wabl_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (^wablm_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (rawl_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
    if (^rawlm_int === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    end
      if( isBitX(gwen_int) )  begin
        Xq = 1'b1; q_update = 1'b1;
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
  always @ (VDDCE) begin
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
  always @ (ret1n_ or  VDDPE or VDDCE or VSSE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st == 1'b1 && (cen_ === 1'bx || clk_ === 1'bx)) begin
      failedWrite(0);
        Q_latch_corrupt;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        Q_latch_corrupt;
    end else if (ret1n_ === 1'b0 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        Q_latch_corrupt;
    end else if (ret1n_ === 1'b1 && ret1n_int !== 1'bx && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        Q_latch_corrupt;
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && VDDPE !== 1'b1) begin
        $display("Warning: Illegal value for VDDPE %b in %m at %0t", VDDPE, $time);
        failedWrite(0);
    end else if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
        Q_latch_corrupt;
      q_int_delayed = {64{1'bx}};
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st = 0;
    end else begin
      pre_charge_st = 0;
`else     
    end else begin
`endif
if ($realtime != 0)  Q_latch_corrupt;
      q_int_delayed = {64{1'bx}};
      cen_int = 1'bx;
      gwen_int = 1'bx;
      a_int = {12{1'bx}};
      d_int = {64{1'bx}};
      stov_int = 1'bx;
      ema_int = {3{1'bx}};
      emaw_int = {2{1'bx}};
      emas_int = 1'bx;
      ret1n_int = 1'bx;
      rawl_int = 1'bx;
      rawlm_int = {2{1'bx}};
      wabl_int = 1'bx;
      wablm_int = {2{1'bx}};
    end
    ret1n_int = ret1n_;
  end
   reg   ret1n_s;
`ifdef POWER_PINS
   reg   VDDCE_s;
   reg   VDDPE_s;
`endif
`ifdef POWER_PINS
	always @ (ret1n_ or VDDCE or VDDPE) begin 
`else
	always @ (ret1n_) begin 
`endif
 	ret1n_s <= ret1n_;
`ifdef POWER_PINS
 	VDDCE_s <= VDDCE;
 	VDDPE_s <= VDDPE;
`endif
	end
`ifdef POWER_PINS
	always @ (ret1n_s or VDDCE_s or VDDPE_s) begin 
`else
	always @ (ret1n_s) begin 
`endif
        Xq = 1'b0;
        Xd_int = {64{1'b0}};
        q_update = 1'b0;
	end
// Q_latch corruption
// -----------------------------
  task Q_latch_corrupt;
    begin
	uDQ0.Q = 1'bx;
	uDQ1.Q = 1'bx;
	uDQ2.Q = 1'bx;
	uDQ3.Q = 1'bx;
	uDQ4.Q = 1'bx;
	uDQ5.Q = 1'bx;
	uDQ6.Q = 1'bx;
	uDQ7.Q = 1'bx;
	uDQ8.Q = 1'bx;
	uDQ9.Q = 1'bx;
	uDQ10.Q = 1'bx;
	uDQ11.Q = 1'bx;
	uDQ12.Q = 1'bx;
	uDQ13.Q = 1'bx;
	uDQ14.Q = 1'bx;
	uDQ15.Q = 1'bx;
	uDQ16.Q = 1'bx;
	uDQ17.Q = 1'bx;
	uDQ18.Q = 1'bx;
	uDQ19.Q = 1'bx;
	uDQ20.Q = 1'bx;
	uDQ21.Q = 1'bx;
	uDQ22.Q = 1'bx;
	uDQ23.Q = 1'bx;
	uDQ24.Q = 1'bx;
	uDQ25.Q = 1'bx;
	uDQ26.Q = 1'bx;
	uDQ27.Q = 1'bx;
	uDQ28.Q = 1'bx;
	uDQ29.Q = 1'bx;
	uDQ30.Q = 1'bx;
	uDQ31.Q = 1'bx;
	uDQ32.Q = 1'bx;
	uDQ33.Q = 1'bx;
	uDQ34.Q = 1'bx;
	uDQ35.Q = 1'bx;
	uDQ36.Q = 1'bx;
	uDQ37.Q = 1'bx;
	uDQ38.Q = 1'bx;
	uDQ39.Q = 1'bx;
	uDQ40.Q = 1'bx;
	uDQ41.Q = 1'bx;
	uDQ42.Q = 1'bx;
	uDQ43.Q = 1'bx;
	uDQ44.Q = 1'bx;
	uDQ45.Q = 1'bx;
	uDQ46.Q = 1'bx;
	uDQ47.Q = 1'bx;
	uDQ48.Q = 1'bx;
	uDQ49.Q = 1'bx;
	uDQ50.Q = 1'bx;
	uDQ51.Q = 1'bx;
	uDQ52.Q = 1'bx;
	uDQ53.Q = 1'bx;
	uDQ54.Q = 1'bx;
	uDQ55.Q = 1'bx;
	uDQ56.Q = 1'bx;
	uDQ57.Q = 1'bx;
	uDQ58.Q = 1'bx;
	uDQ59.Q = 1'bx;
	uDQ60.Q = 1'bx;
	uDQ61.Q = 1'bx;
	uDQ62.Q = 1'bx;
	uDQ63.Q = 1'bx;

    end
  endtask



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
`ifdef POWER_PINS
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
`else     
  if (ret1n_ == 1'b0 || corrupt_power !== 1'b0) begin
`endif
      // no cycle in retention mode or during external power down
`ifdef POWER_PINS
    end else if ((VDDCE === 1'bx || VDDCE === 1'bz)) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
  end else if (ret1n_ == 1'b1 && VDDPE !== 1'b1) begin
  end else if (VSSE !== 1'b0) begin
`endif
  end else begin
    if ((clk_ === 1'bx || clk_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else if ((clk_ === 1'b1 || clk_ === 1'b0) && LAST_clk === 1'bx) begin
       d_sh_update = 1'b0;  Xd_sh = 1'b0;
       Xd_int = {64{1'b0}};
       Xq = 1'b0; q_update = 1'b0; 
    end else if (clk_ === 1'b1 && LAST_clk === 1'b0) begin
      cen_int = cen_;
      stov_int = stov_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      if (cen_int != 1'b1) begin
        gwen_int = gwen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      cen_int = cen_;
      stov_int = stov_;
      ema_int = ema_;
      emaw_int = emaw_;
      emas_int = emas_;
      ret1n_int = ret1n_;
      rawl_int = rawl_;
      rawlm_int = rawlm_;
      wabl_int = wabl_;
      wablm_int = wablm_;
      if (cen_int != 1'b1) begin
        gwen_int = gwen_;
        a_int = a_;
        d_int = d_;
      end
      clk0_int = 1'b0;
      if (cen_int === 1'b0 && gwen_int === 1'b1) 
         q_int_delayed = {64{1'bx}};
    readWrite;
    end else if (clk_ === 1'b0 && LAST_clk === 1'b1) begin
      q_int_delayed = q_int;
      q_update = 1'b0;
      d_sh_update = 1'b0;
      Xq = 1'b0;
       Xd_int = {64{1'b0}};
    end
  end
    LAST_clk = clk_;
  end

  assign d_int_bmux = d_;

  datapath_latch_sramsp_4096_64 uDQ0 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(1'b0), .D(d_int_bmux[0]), .DFTRAMBYP(1'b0), .mem_path(mem_path[0]), .XQ(Xq|Xd_int[0]|1'b0), .Q(q_int[0]));
  datapath_latch_sramsp_4096_64 uDQ1 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[0]), .D(d_int_bmux[1]), .DFTRAMBYP(1'b0), .mem_path(mem_path[1]), .XQ(Xq|Xd_int[1]), .Q(q_int[1]));
  datapath_latch_sramsp_4096_64 uDQ2 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[1]), .D(d_int_bmux[2]), .DFTRAMBYP(1'b0), .mem_path(mem_path[2]), .XQ(Xq|Xd_int[2]), .Q(q_int[2]));
  datapath_latch_sramsp_4096_64 uDQ3 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[2]), .D(d_int_bmux[3]), .DFTRAMBYP(1'b0), .mem_path(mem_path[3]), .XQ(Xq|Xd_int[3]), .Q(q_int[3]));
  datapath_latch_sramsp_4096_64 uDQ4 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[3]), .D(d_int_bmux[4]), .DFTRAMBYP(1'b0), .mem_path(mem_path[4]), .XQ(Xq|Xd_int[4]), .Q(q_int[4]));
  datapath_latch_sramsp_4096_64 uDQ5 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[4]), .D(d_int_bmux[5]), .DFTRAMBYP(1'b0), .mem_path(mem_path[5]), .XQ(Xq|Xd_int[5]), .Q(q_int[5]));
  datapath_latch_sramsp_4096_64 uDQ6 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[5]), .D(d_int_bmux[6]), .DFTRAMBYP(1'b0), .mem_path(mem_path[6]), .XQ(Xq|Xd_int[6]), .Q(q_int[6]));
  datapath_latch_sramsp_4096_64 uDQ7 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[6]), .D(d_int_bmux[7]), .DFTRAMBYP(1'b0), .mem_path(mem_path[7]), .XQ(Xq|Xd_int[7]), .Q(q_int[7]));
  datapath_latch_sramsp_4096_64 uDQ8 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[7]), .D(d_int_bmux[8]), .DFTRAMBYP(1'b0), .mem_path(mem_path[8]), .XQ(Xq|Xd_int[8]), .Q(q_int[8]));
  datapath_latch_sramsp_4096_64 uDQ9 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[8]), .D(d_int_bmux[9]), .DFTRAMBYP(1'b0), .mem_path(mem_path[9]), .XQ(Xq|Xd_int[9]), .Q(q_int[9]));
  datapath_latch_sramsp_4096_64 uDQ10 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[9]), .D(d_int_bmux[10]), .DFTRAMBYP(1'b0), .mem_path(mem_path[10]), .XQ(Xq|Xd_int[10]), .Q(q_int[10]));
  datapath_latch_sramsp_4096_64 uDQ11 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[10]), .D(d_int_bmux[11]), .DFTRAMBYP(1'b0), .mem_path(mem_path[11]), .XQ(Xq|Xd_int[11]), .Q(q_int[11]));
  datapath_latch_sramsp_4096_64 uDQ12 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[11]), .D(d_int_bmux[12]), .DFTRAMBYP(1'b0), .mem_path(mem_path[12]), .XQ(Xq|Xd_int[12]), .Q(q_int[12]));
  datapath_latch_sramsp_4096_64 uDQ13 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[12]), .D(d_int_bmux[13]), .DFTRAMBYP(1'b0), .mem_path(mem_path[13]), .XQ(Xq|Xd_int[13]), .Q(q_int[13]));
  datapath_latch_sramsp_4096_64 uDQ14 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[13]), .D(d_int_bmux[14]), .DFTRAMBYP(1'b0), .mem_path(mem_path[14]), .XQ(Xq|Xd_int[14]), .Q(q_int[14]));
  datapath_latch_sramsp_4096_64 uDQ15 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[14]), .D(d_int_bmux[15]), .DFTRAMBYP(1'b0), .mem_path(mem_path[15]), .XQ(Xq|Xd_int[15]), .Q(q_int[15]));
  datapath_latch_sramsp_4096_64 uDQ16 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[15]), .D(d_int_bmux[16]), .DFTRAMBYP(1'b0), .mem_path(mem_path[16]), .XQ(Xq|Xd_int[16]), .Q(q_int[16]));
  datapath_latch_sramsp_4096_64 uDQ17 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[16]), .D(d_int_bmux[17]), .DFTRAMBYP(1'b0), .mem_path(mem_path[17]), .XQ(Xq|Xd_int[17]), .Q(q_int[17]));
  datapath_latch_sramsp_4096_64 uDQ18 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[17]), .D(d_int_bmux[18]), .DFTRAMBYP(1'b0), .mem_path(mem_path[18]), .XQ(Xq|Xd_int[18]), .Q(q_int[18]));
  datapath_latch_sramsp_4096_64 uDQ19 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[18]), .D(d_int_bmux[19]), .DFTRAMBYP(1'b0), .mem_path(mem_path[19]), .XQ(Xq|Xd_int[19]), .Q(q_int[19]));
  datapath_latch_sramsp_4096_64 uDQ20 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[19]), .D(d_int_bmux[20]), .DFTRAMBYP(1'b0), .mem_path(mem_path[20]), .XQ(Xq|Xd_int[20]), .Q(q_int[20]));
  datapath_latch_sramsp_4096_64 uDQ21 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[20]), .D(d_int_bmux[21]), .DFTRAMBYP(1'b0), .mem_path(mem_path[21]), .XQ(Xq|Xd_int[21]), .Q(q_int[21]));
  datapath_latch_sramsp_4096_64 uDQ22 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[21]), .D(d_int_bmux[22]), .DFTRAMBYP(1'b0), .mem_path(mem_path[22]), .XQ(Xq|Xd_int[22]), .Q(q_int[22]));
  datapath_latch_sramsp_4096_64 uDQ23 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[22]), .D(d_int_bmux[23]), .DFTRAMBYP(1'b0), .mem_path(mem_path[23]), .XQ(Xq|Xd_int[23]), .Q(q_int[23]));
  datapath_latch_sramsp_4096_64 uDQ24 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[23]), .D(d_int_bmux[24]), .DFTRAMBYP(1'b0), .mem_path(mem_path[24]), .XQ(Xq|Xd_int[24]), .Q(q_int[24]));
  datapath_latch_sramsp_4096_64 uDQ25 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[24]), .D(d_int_bmux[25]), .DFTRAMBYP(1'b0), .mem_path(mem_path[25]), .XQ(Xq|Xd_int[25]), .Q(q_int[25]));
  datapath_latch_sramsp_4096_64 uDQ26 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[25]), .D(d_int_bmux[26]), .DFTRAMBYP(1'b0), .mem_path(mem_path[26]), .XQ(Xq|Xd_int[26]), .Q(q_int[26]));
  datapath_latch_sramsp_4096_64 uDQ27 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[26]), .D(d_int_bmux[27]), .DFTRAMBYP(1'b0), .mem_path(mem_path[27]), .XQ(Xq|Xd_int[27]), .Q(q_int[27]));
  datapath_latch_sramsp_4096_64 uDQ28 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[27]), .D(d_int_bmux[28]), .DFTRAMBYP(1'b0), .mem_path(mem_path[28]), .XQ(Xq|Xd_int[28]), .Q(q_int[28]));
  datapath_latch_sramsp_4096_64 uDQ29 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[28]), .D(d_int_bmux[29]), .DFTRAMBYP(1'b0), .mem_path(mem_path[29]), .XQ(Xq|Xd_int[29]), .Q(q_int[29]));
  datapath_latch_sramsp_4096_64 uDQ30 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[29]), .D(d_int_bmux[30]), .DFTRAMBYP(1'b0), .mem_path(mem_path[30]), .XQ(Xq|Xd_int[30]), .Q(q_int[30]));
  datapath_latch_sramsp_4096_64 uDQ31 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[30]), .D(d_int_bmux[31]), .DFTRAMBYP(1'b0), .mem_path(mem_path[31]), .XQ(Xq|Xd_int[31]), .Q(q_int[31]));
  datapath_latch_sramsp_4096_64 uDQ32 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[33]), .D(d_int_bmux[32]), .DFTRAMBYP(1'b0), .mem_path(mem_path[32]), .XQ(Xq|Xd_int[32]), .Q(q_int[32]));
  datapath_latch_sramsp_4096_64 uDQ33 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[34]), .D(d_int_bmux[33]), .DFTRAMBYP(1'b0), .mem_path(mem_path[33]), .XQ(Xq|Xd_int[33]), .Q(q_int[33]));
  datapath_latch_sramsp_4096_64 uDQ34 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[35]), .D(d_int_bmux[34]), .DFTRAMBYP(1'b0), .mem_path(mem_path[34]), .XQ(Xq|Xd_int[34]), .Q(q_int[34]));
  datapath_latch_sramsp_4096_64 uDQ35 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[36]), .D(d_int_bmux[35]), .DFTRAMBYP(1'b0), .mem_path(mem_path[35]), .XQ(Xq|Xd_int[35]), .Q(q_int[35]));
  datapath_latch_sramsp_4096_64 uDQ36 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[37]), .D(d_int_bmux[36]), .DFTRAMBYP(1'b0), .mem_path(mem_path[36]), .XQ(Xq|Xd_int[36]), .Q(q_int[36]));
  datapath_latch_sramsp_4096_64 uDQ37 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[38]), .D(d_int_bmux[37]), .DFTRAMBYP(1'b0), .mem_path(mem_path[37]), .XQ(Xq|Xd_int[37]), .Q(q_int[37]));
  datapath_latch_sramsp_4096_64 uDQ38 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[39]), .D(d_int_bmux[38]), .DFTRAMBYP(1'b0), .mem_path(mem_path[38]), .XQ(Xq|Xd_int[38]), .Q(q_int[38]));
  datapath_latch_sramsp_4096_64 uDQ39 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[40]), .D(d_int_bmux[39]), .DFTRAMBYP(1'b0), .mem_path(mem_path[39]), .XQ(Xq|Xd_int[39]), .Q(q_int[39]));
  datapath_latch_sramsp_4096_64 uDQ40 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[41]), .D(d_int_bmux[40]), .DFTRAMBYP(1'b0), .mem_path(mem_path[40]), .XQ(Xq|Xd_int[40]), .Q(q_int[40]));
  datapath_latch_sramsp_4096_64 uDQ41 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[42]), .D(d_int_bmux[41]), .DFTRAMBYP(1'b0), .mem_path(mem_path[41]), .XQ(Xq|Xd_int[41]), .Q(q_int[41]));
  datapath_latch_sramsp_4096_64 uDQ42 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[43]), .D(d_int_bmux[42]), .DFTRAMBYP(1'b0), .mem_path(mem_path[42]), .XQ(Xq|Xd_int[42]), .Q(q_int[42]));
  datapath_latch_sramsp_4096_64 uDQ43 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[44]), .D(d_int_bmux[43]), .DFTRAMBYP(1'b0), .mem_path(mem_path[43]), .XQ(Xq|Xd_int[43]), .Q(q_int[43]));
  datapath_latch_sramsp_4096_64 uDQ44 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[45]), .D(d_int_bmux[44]), .DFTRAMBYP(1'b0), .mem_path(mem_path[44]), .XQ(Xq|Xd_int[44]), .Q(q_int[44]));
  datapath_latch_sramsp_4096_64 uDQ45 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[46]), .D(d_int_bmux[45]), .DFTRAMBYP(1'b0), .mem_path(mem_path[45]), .XQ(Xq|Xd_int[45]), .Q(q_int[45]));
  datapath_latch_sramsp_4096_64 uDQ46 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[47]), .D(d_int_bmux[46]), .DFTRAMBYP(1'b0), .mem_path(mem_path[46]), .XQ(Xq|Xd_int[46]), .Q(q_int[46]));
  datapath_latch_sramsp_4096_64 uDQ47 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[48]), .D(d_int_bmux[47]), .DFTRAMBYP(1'b0), .mem_path(mem_path[47]), .XQ(Xq|Xd_int[47]), .Q(q_int[47]));
  datapath_latch_sramsp_4096_64 uDQ48 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[49]), .D(d_int_bmux[48]), .DFTRAMBYP(1'b0), .mem_path(mem_path[48]), .XQ(Xq|Xd_int[48]), .Q(q_int[48]));
  datapath_latch_sramsp_4096_64 uDQ49 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[50]), .D(d_int_bmux[49]), .DFTRAMBYP(1'b0), .mem_path(mem_path[49]), .XQ(Xq|Xd_int[49]), .Q(q_int[49]));
  datapath_latch_sramsp_4096_64 uDQ50 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[51]), .D(d_int_bmux[50]), .DFTRAMBYP(1'b0), .mem_path(mem_path[50]), .XQ(Xq|Xd_int[50]), .Q(q_int[50]));
  datapath_latch_sramsp_4096_64 uDQ51 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[52]), .D(d_int_bmux[51]), .DFTRAMBYP(1'b0), .mem_path(mem_path[51]), .XQ(Xq|Xd_int[51]), .Q(q_int[51]));
  datapath_latch_sramsp_4096_64 uDQ52 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[53]), .D(d_int_bmux[52]), .DFTRAMBYP(1'b0), .mem_path(mem_path[52]), .XQ(Xq|Xd_int[52]), .Q(q_int[52]));
  datapath_latch_sramsp_4096_64 uDQ53 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[54]), .D(d_int_bmux[53]), .DFTRAMBYP(1'b0), .mem_path(mem_path[53]), .XQ(Xq|Xd_int[53]), .Q(q_int[53]));
  datapath_latch_sramsp_4096_64 uDQ54 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[55]), .D(d_int_bmux[54]), .DFTRAMBYP(1'b0), .mem_path(mem_path[54]), .XQ(Xq|Xd_int[54]), .Q(q_int[54]));
  datapath_latch_sramsp_4096_64 uDQ55 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[56]), .D(d_int_bmux[55]), .DFTRAMBYP(1'b0), .mem_path(mem_path[55]), .XQ(Xq|Xd_int[55]), .Q(q_int[55]));
  datapath_latch_sramsp_4096_64 uDQ56 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[57]), .D(d_int_bmux[56]), .DFTRAMBYP(1'b0), .mem_path(mem_path[56]), .XQ(Xq|Xd_int[56]), .Q(q_int[56]));
  datapath_latch_sramsp_4096_64 uDQ57 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[58]), .D(d_int_bmux[57]), .DFTRAMBYP(1'b0), .mem_path(mem_path[57]), .XQ(Xq|Xd_int[57]), .Q(q_int[57]));
  datapath_latch_sramsp_4096_64 uDQ58 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[59]), .D(d_int_bmux[58]), .DFTRAMBYP(1'b0), .mem_path(mem_path[58]), .XQ(Xq|Xd_int[58]), .Q(q_int[58]));
  datapath_latch_sramsp_4096_64 uDQ59 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[60]), .D(d_int_bmux[59]), .DFTRAMBYP(1'b0), .mem_path(mem_path[59]), .XQ(Xq|Xd_int[59]), .Q(q_int[59]));
  datapath_latch_sramsp_4096_64 uDQ60 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[61]), .D(d_int_bmux[60]), .DFTRAMBYP(1'b0), .mem_path(mem_path[60]), .XQ(Xq|Xd_int[60]), .Q(q_int[60]));
  datapath_latch_sramsp_4096_64 uDQ61 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[62]), .D(d_int_bmux[61]), .DFTRAMBYP(1'b0), .mem_path(mem_path[61]), .XQ(Xq|Xd_int[61]), .Q(q_int[61]));
  datapath_latch_sramsp_4096_64 uDQ62 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(q_int[63]), .D(d_int_bmux[62]), .DFTRAMBYP(1'b0), .mem_path(mem_path[62]), .XQ(Xq|Xd_int[62]), .Q(q_int[62]));
  datapath_latch_sramsp_4096_64 uDQ63 (.CLK(clk), .Q_update(q_update), .D_update(d_sh_update), .SE(1'b0), .SI(1'b0), .D(d_int_bmux[63]), .DFTRAMBYP(1'b0), .mem_path(mem_path[63]), .XQ(Xq|Xd_int[63]|1'b0), .Q(q_int[63]));



  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if (cen_int === 1'bx || clk0_int === 1'bx || rawl_int === 1'bx || rawlm_int[0] === 1'bx || 
      rawlm_int[1] === 1'bx || ret1n_int === 1'bx || (stov_int && !cen_int) === 1'bx || 
      wabl_int === 1'bx || wablm_int[0] === 1'bx || wablm_int[1] === 1'bx) begin
        Xq = 1'b1; q_update = 1'b1;
    	 mem_path = {64{1'bx}};
      q_int_delayed = {64{1'bx}};
      failedWrite(0);
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
        failedWrite(0);
        Xq = 1'b1; q_update = 1'b1;
    end else begin
      #0;
      readWrite;
   end
      #0;
        Xq = 1'b0; q_update = 1'b0;
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
        Xq = 1'b1; q_update = 1'b1;
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (VDDPE !== 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        Xq = 1'b1; q_update = 1'b1;
		if (ret1n_ !== 1'b0)
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE !== 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        Xq = 1'b1; q_update = 1'b1;
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
  always @ NOT_gwen begin
    gwen_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a11 begin
    a_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a10 begin
    a_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a9 begin
    a_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a8 begin
    a_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_a7 begin
    a_int[7] = 1'bx;
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
  always @ NOT_d63 begin
    d_int[63] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d62 begin
    d_int[62] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d61 begin
    d_int[61] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d60 begin
    d_int[60] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d59 begin
    d_int[59] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d58 begin
    d_int[58] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d57 begin
    d_int[57] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d56 begin
    d_int[56] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d55 begin
    d_int[55] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d54 begin
    d_int[54] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d53 begin
    d_int[53] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d52 begin
    d_int[52] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d51 begin
    d_int[51] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d50 begin
    d_int[50] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d49 begin
    d_int[49] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d48 begin
    d_int[48] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d47 begin
    d_int[47] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d46 begin
    d_int[46] = 1'bx;
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
  always @ NOT_stov begin
    stov_int = 1'bx;
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


  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1;
  wire stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1;

  wire stoveq0aret1neq1aceneq0, stoveq1aret1neq1aceneq0, ret1neq1, rawleq1awableq1aret1neq1aceneq0;
  wire rawleq0awableq1aret1neq1aceneq0, rawleq1awableq0aret1neq1aceneq0, rawleq0awableq0aret1neq1aceneq0;
  wire ret1neq1aceneq0agweneq0, ret1neq1aceneq0, ret1neq1agweneq0aceneq0;

  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&!emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&!emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&!emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&!ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&!ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&!ema[0]&&emaw[1]&&emaw[0]&&emas;
  assign stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1 = 
  !stov&&ret1n&&!cen&&ema[2]&&ema[1]&&ema[0]&&emaw[1]&&emaw[0]&&emas;


  assign stoveq0aret1neq1aceneq0 = !stov&&ret1n&&!cen;
  assign stoveq1aret1neq1aceneq0 = stov&&ret1n&&!cen;
  assign rawleq1awableq1aret1neq1aceneq0 = rawl&&wabl&&ret1n&&!cen;
  assign rawleq0awableq1aret1neq1aceneq0 = !rawl&&wabl&&ret1n&&!cen;
  assign rawleq1awableq0aret1neq1aceneq0 = rawl&&!wabl&&ret1n&&!cen;
  assign rawleq0awableq0aret1neq1aceneq0 = !rawl&&!wabl&&ret1n&&!cen;
  assign ret1neq1aceneq0agweneq0 = ret1n&&!cen&&!gwen;
  assign ret1neq1agweneq0aceneq0 = ret1n&&!gwen&&!cen;

  assign ret1neq1 = ret1n;
  assign ret1neq1aceneq0 = ret1n&&!cen;

  specify

    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[45] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[44] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[43] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[42] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[41] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[40] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[39] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[38] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[37] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[36] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[35] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[34] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[33] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[32] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[31] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[30] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[29] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[28] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[27] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[26] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[25] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[24] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[23] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[22] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[21] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[20] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[19] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[18] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[17] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[16] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (cen == 1'b0 && ret1n == 1'b1 && gwen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge clk, `ARM_MEM_PERIOD, NOT_clk_PER);
   `else
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq0aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq0aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq0aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq0aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq0aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq0aret1neq1aceneq0aema2eq1aema1eq1aema0eq1aemaw1eq1aemaw0eq1aemaseq1, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(posedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_PERIOD, NOT_clk_PER);
       $period(negedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_PERIOD, NOT_clk_PER);
   `endif


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge clk, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(negedge clk, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
   `else
       $width(posedge clk &&& stoveq0aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(posedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINH);
       $width(negedge clk &&& stoveq0aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
       $width(negedge clk &&& stoveq1aret1neq1aceneq0, `ARM_MEM_WIDTH, 0, NOT_clk_MINL);
   `endif

    $setuphold(posedge clk &&& ret1neq1, posedge cen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cen);
    $setuphold(posedge clk &&& ret1neq1, negedge cen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cen);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge gwen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_gwen);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge gwen, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_gwen);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, posedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq1aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq1aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq1awableq0aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a11);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a10);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a9);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a8);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a7);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a6);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a5);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a4);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a3);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a2);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a1);
    $setuphold(posedge clk &&& rawleq0awableq0aret1neq1aceneq0, negedge a[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_a0);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[63], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d63);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[62], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d62);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[61], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d61);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[60], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d60);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[59], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d59);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[58], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d58);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[57], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d57);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[56], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d56);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[55], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d55);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[54], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d54);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[53], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d53);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[52], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d52);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[51], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d51);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[50], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d50);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[49], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d49);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[48], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d48);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[47], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d47);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[46], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d46);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[45], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d45);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[44], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d44);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[43], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d43);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[42], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d42);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[41], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d41);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[40], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d40);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[39], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d39);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[38], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d38);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[37], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d37);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[36], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d36);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[35], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d35);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[34], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d34);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[33], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d33);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[32], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d32);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[31], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d31);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[30], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d30);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[29], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d29);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[28], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d28);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[27], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d27);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[26], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d26);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[25], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d25);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[24], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d24);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[23], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d23);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[22], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d22);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[21], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d21);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[20], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d20);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[19], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d19);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[18], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d18);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[17], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d17);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[16], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d16);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d15);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d14);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d13);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d12);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d11);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d10);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d9);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d8);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d7);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d6);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d5);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d4);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d3);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d2);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d1);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, posedge d[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d0);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[63], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d63);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[62], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d62);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[61], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d61);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[60], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d60);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[59], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d59);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[58], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d58);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[57], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d57);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[56], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d56);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[55], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d55);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[54], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d54);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[53], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d53);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[52], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d52);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[51], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d51);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[50], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d50);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[49], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d49);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[48], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d48);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[47], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d47);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[46], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d46);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[45], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d45);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[44], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d44);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[43], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d43);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[42], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d42);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[41], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d41);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[40], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d40);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[39], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d39);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[38], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d38);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[37], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d37);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[36], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d36);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[35], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d35);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[34], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d34);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[33], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d33);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[32], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d32);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[31], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d31);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[30], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d30);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[29], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d29);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[28], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d28);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[27], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d27);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[26], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d26);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[25], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d25);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[24], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d24);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[23], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d23);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[22], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d22);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[21], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d21);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[20], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d20);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[19], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d19);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[18], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d18);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[17], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d17);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[16], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d16);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d15);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d14);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d13);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d12);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d11);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d10);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d9);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d8);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d7);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d6);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d5);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d4);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d3);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d2);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d1);
    $setuphold(posedge clk &&& ret1neq1aceneq0agweneq0, negedge d[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge stov, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_stov);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge stov, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_stov);
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
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawl);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawlm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, posedge rawlm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm0);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawlm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm1);
    $setuphold(posedge clk &&& ret1neq1aceneq0, negedge rawlm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_rawlm0);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, posedge wabl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wabl);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, negedge wabl, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wabl);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, posedge wablm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm1);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, posedge wablm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm0);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, negedge wablm[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm1);
    $setuphold(posedge clk &&& ret1neq1agweneq0aceneq0, negedge wablm[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wablm0);
    $setuphold(negedge ret1n, negedge cen, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge ret1n, negedge cen, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cen, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cen, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
  endspecify


endmodule
`endcelldefine
`endif
`endif
`ifdef ARM_FAULT_MODELING
`timescale 1ns/1ps
module sramsp_4096_64_error_injection (Q_out, Q_in, CLK, A, CEN, WEN, GWEN);
   output [63:0] Q_out;
   input [63:0] Q_in;
   input CLK;
   input [11:0] A;
   input CEN;
   input WEN;
   input GWEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter FIRST_RED_ROW_FAULT = 2'd3;
   parameter NO_RED_FAULT = 2'd0;
   reg [63:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [22:0] fault_table [255:0];
   reg [22:0] fault_entry;
initial
begin
   `ifdef sramsp_4096_64_pre_pend_path
      `define pre_pend_path `sramsp_4096_64_pre_pend_path
   `else
      `ifdef DUT
         `define pre_pend_path TB.DUT_inst.CHIP.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST
      `else
          `define pre_pend_path TB.CHIP.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST
      `endif
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.u1.add_fault(12'd3718,6'd6,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [11:0] address;
      input [5:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 255)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[10:5] = bitPlace;
            fault_entry[22:11] = address;
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
   for (i = 0; i < 256; i=i+1)
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
   inout [63:0] q_int;
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
   output [63:0] Q_output;
   reg list_complete;
   integer i;
   reg [5:0] FRA_reg;
   reg [7:0] row_address;
   reg [3:0] column_address;
   reg [5:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
   reg [5:0] msb_bit_calc;
begin
   entry_found = 1'b0;
   list_complete = 1'b0;
   i = 0;
   Q_output = Q_in;
   while(!list_complete)
   begin
      fault_entry = fault_table[i];
      {row_address, column_address, bitPlace, fault_type, red_fault, valid} = fault_entry;
      FRA_reg = row_address/4;
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault === NO_RED_FAULT)
         begin
            if (row_address == A[11:4] && column_address == A[3:0])
            begin
               if (bitPlace < 32)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 32 )
                  bit_error(Q_output,fault_type, bitPlace);
            end
         end
      end
      else
         list_complete = 1'b1;
      end
   end
   endtask
   always @ (Q_in or CLK or A or CEN or WEN or GWEN)
   begin
   if (CEN === 1'b0 && &WEN === 1'b1 && GWEN === 1'b1)
      error_injection_on_output(Q_out);
   else
      Q_out = Q_in;
   end
endmodule
`endif
