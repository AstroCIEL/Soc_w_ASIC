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
//       Instance Name:              sram128x128
//       Words:                      128
//       Bits:                       128
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
//       Creation Date:  Fri Jan 31 07:29:54 2025
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
module sram128x128 (VDDCE, VDDPE, VSSE, q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, 
    wabl, wablm, rawl, rawlm);
`else
module sram128x128 (q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, wabl, wablm, rawl, 
    rawlm);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 128;
  parameter WORDS = 128;
  parameter MUX = 2;
  parameter MEM_WIDTH = 256; // redun block size 2, 128 on left, 128 on right
  parameter MEM_HEIGHT = 64;
  parameter WP_SIZE = 128 ;
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

  output [127:0] q;
  input  clk;
  input  cen;
  input  wen;
  input [6:0] a;
  input [127:0] d;
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
  reg [255:0] mem [0:63];
  reg [255:0] row, row_t;
  reg LAST_clk;
  reg [255:0] row_mask;
  reg [255:0] new_data;
  reg [255:0] data_out;
  reg [127:0] readLatch0;
  reg [127:0] shifted_readLatch0;
  reg [127:0] q_int;
  reg [127:0] writeEnable;
  reg clk0_int;

  wire [127:0] q_;
  wire [127:0] q_out;
 wire  clk_;
  wire  cen_;
  reg  cen_int;
  reg  cen_p2;
  wire  wen_;
  reg  wen_int;
  wire [6:0] a_;
  reg [6:0] a_int;
  wire [127:0] d_;
  reg [127:0] d_int;
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
  assign q[64] = q_[64]; 
  assign q[65] = q_[65]; 
  assign q[66] = q_[66]; 
  assign q[67] = q_[67]; 
  assign q[68] = q_[68]; 
  assign q[69] = q_[69]; 
  assign q[70] = q_[70]; 
  assign q[71] = q_[71]; 
  assign q[72] = q_[72]; 
  assign q[73] = q_[73]; 
  assign q[74] = q_[74]; 
  assign q[75] = q_[75]; 
  assign q[76] = q_[76]; 
  assign q[77] = q_[77]; 
  assign q[78] = q_[78]; 
  assign q[79] = q_[79]; 
  assign q[80] = q_[80]; 
  assign q[81] = q_[81]; 
  assign q[82] = q_[82]; 
  assign q[83] = q_[83]; 
  assign q[84] = q_[84]; 
  assign q[85] = q_[85]; 
  assign q[86] = q_[86]; 
  assign q[87] = q_[87]; 
  assign q[88] = q_[88]; 
  assign q[89] = q_[89]; 
  assign q[90] = q_[90]; 
  assign q[91] = q_[91]; 
  assign q[92] = q_[92]; 
  assign q[93] = q_[93]; 
  assign q[94] = q_[94]; 
  assign q[95] = q_[95]; 
  assign q[96] = q_[96]; 
  assign q[97] = q_[97]; 
  assign q[98] = q_[98]; 
  assign q[99] = q_[99]; 
  assign q[100] = q_[100]; 
  assign q[101] = q_[101]; 
  assign q[102] = q_[102]; 
  assign q[103] = q_[103]; 
  assign q[104] = q_[104]; 
  assign q[105] = q_[105]; 
  assign q[106] = q_[106]; 
  assign q[107] = q_[107]; 
  assign q[108] = q_[108]; 
  assign q[109] = q_[109]; 
  assign q[110] = q_[110]; 
  assign q[111] = q_[111]; 
  assign q[112] = q_[112]; 
  assign q[113] = q_[113]; 
  assign q[114] = q_[114]; 
  assign q[115] = q_[115]; 
  assign q[116] = q_[116]; 
  assign q[117] = q_[117]; 
  assign q[118] = q_[118]; 
  assign q[119] = q_[119]; 
  assign q[120] = q_[120]; 
  assign q[121] = q_[121]; 
  assign q[122] = q_[122]; 
  assign q[123] = q_[123]; 
  assign q[124] = q_[124]; 
  assign q[125] = q_[125]; 
  assign q[126] = q_[126]; 
  assign q[127] = q_[127]; 
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
  assign d_[64] = d[64];
  assign d_[65] = d[65];
  assign d_[66] = d[66];
  assign d_[67] = d[67];
  assign d_[68] = d[68];
  assign d_[69] = d[69];
  assign d_[70] = d[70];
  assign d_[71] = d[71];
  assign d_[72] = d[72];
  assign d_[73] = d[73];
  assign d_[74] = d[74];
  assign d_[75] = d[75];
  assign d_[76] = d[76];
  assign d_[77] = d[77];
  assign d_[78] = d[78];
  assign d_[79] = d[79];
  assign d_[80] = d[80];
  assign d_[81] = d[81];
  assign d_[82] = d[82];
  assign d_[83] = d[83];
  assign d_[84] = d[84];
  assign d_[85] = d[85];
  assign d_[86] = d[86];
  assign d_[87] = d[87];
  assign d_[88] = d[88];
  assign d_[89] = d[89];
  assign d_[90] = d[90];
  assign d_[91] = d[91];
  assign d_[92] = d[92];
  assign d_[93] = d[93];
  assign d_[94] = d[94];
  assign d_[95] = d[95];
  assign d_[96] = d[96];
  assign d_[97] = d[97];
  assign d_[98] = d[98];
  assign d_[99] = d[99];
  assign d_[100] = d[100];
  assign d_[101] = d[101];
  assign d_[102] = d[102];
  assign d_[103] = d[103];
  assign d_[104] = d[104];
  assign d_[105] = d[105];
  assign d_[106] = d[106];
  assign d_[107] = d[107];
  assign d_[108] = d[108];
  assign d_[109] = d[109];
  assign d_[110] = d[110];
  assign d_[111] = d[111];
  assign d_[112] = d[112];
  assign d_[113] = d[113];
  assign d_[114] = d[114];
  assign d_[115] = d[115];
  assign d_[116] = d[116];
  assign d_[117] = d[117];
  assign d_[118] = d[118];
  assign d_[119] = d[119];
  assign d_[120] = d[120];
  assign d_[121] = d[121];
  assign d_[122] = d[122];
  assign d_[123] = d[123];
  assign d_[124] = d[124];
  assign d_[125] = d[125];
  assign d_[126] = d[126];
  assign d_[127] = d[127];
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
     sram128x128_error_injection u1(.CLK(clk_), .Q_out(q_out), .A(a_int), .CEN(cen_int), .WEN(wen_int), .Q_in(q_int));
   `else
     assign q_out = q_int;
   `endif
  assign `ARM_UD_SEQ q_ = (ret1n_ | pre_charge_st) & ~corrupt_power ? ((q_out)) : {128{1'bx}};

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
        writeEnable = {128{1'b1}};
        row_mask =  ( {1'b0, writeEnable[127], 1'b0, writeEnable[126], 1'b0, writeEnable[125],
          1'b0, writeEnable[124], 1'b0, writeEnable[123], 1'b0, writeEnable[122], 1'b0, writeEnable[121],
          1'b0, writeEnable[120], 1'b0, writeEnable[119], 1'b0, writeEnable[118], 1'b0, writeEnable[117],
          1'b0, writeEnable[116], 1'b0, writeEnable[115], 1'b0, writeEnable[114], 1'b0, writeEnable[113],
          1'b0, writeEnable[112], 1'b0, writeEnable[111], 1'b0, writeEnable[110], 1'b0, writeEnable[109],
          1'b0, writeEnable[108], 1'b0, writeEnable[107], 1'b0, writeEnable[106], 1'b0, writeEnable[105],
          1'b0, writeEnable[104], 1'b0, writeEnable[103], 1'b0, writeEnable[102], 1'b0, writeEnable[101],
          1'b0, writeEnable[100], 1'b0, writeEnable[99], 1'b0, writeEnable[98], 1'b0, writeEnable[97],
          1'b0, writeEnable[96], 1'b0, writeEnable[95], 1'b0, writeEnable[94], 1'b0, writeEnable[93],
          1'b0, writeEnable[92], 1'b0, writeEnable[91], 1'b0, writeEnable[90], 1'b0, writeEnable[89],
          1'b0, writeEnable[88], 1'b0, writeEnable[87], 1'b0, writeEnable[86], 1'b0, writeEnable[85],
          1'b0, writeEnable[84], 1'b0, writeEnable[83], 1'b0, writeEnable[82], 1'b0, writeEnable[81],
          1'b0, writeEnable[80], 1'b0, writeEnable[79], 1'b0, writeEnable[78], 1'b0, writeEnable[77],
          1'b0, writeEnable[76], 1'b0, writeEnable[75], 1'b0, writeEnable[74], 1'b0, writeEnable[73],
          1'b0, writeEnable[72], 1'b0, writeEnable[71], 1'b0, writeEnable[70], 1'b0, writeEnable[69],
          1'b0, writeEnable[68], 1'b0, writeEnable[67], 1'b0, writeEnable[66], 1'b0, writeEnable[65],
          1'b0, writeEnable[64], 1'b0, writeEnable[63], 1'b0, writeEnable[62], 1'b0, writeEnable[61],
          1'b0, writeEnable[60], 1'b0, writeEnable[59], 1'b0, writeEnable[58], 1'b0, writeEnable[57],
          1'b0, writeEnable[56], 1'b0, writeEnable[55], 1'b0, writeEnable[54], 1'b0, writeEnable[53],
          1'b0, writeEnable[52], 1'b0, writeEnable[51], 1'b0, writeEnable[50], 1'b0, writeEnable[49],
          1'b0, writeEnable[48], 1'b0, writeEnable[47], 1'b0, writeEnable[46], 1'b0, writeEnable[45],
          1'b0, writeEnable[44], 1'b0, writeEnable[43], 1'b0, writeEnable[42], 1'b0, writeEnable[41],
          1'b0, writeEnable[40], 1'b0, writeEnable[39], 1'b0, writeEnable[38], 1'b0, writeEnable[37],
          1'b0, writeEnable[36], 1'b0, writeEnable[35], 1'b0, writeEnable[34], 1'b0, writeEnable[33],
          1'b0, writeEnable[32], 1'b0, writeEnable[31], 1'b0, writeEnable[30], 1'b0, writeEnable[29],
          1'b0, writeEnable[28], 1'b0, writeEnable[27], 1'b0, writeEnable[26], 1'b0, writeEnable[25],
          1'b0, writeEnable[24], 1'b0, writeEnable[23], 1'b0, writeEnable[22], 1'b0, writeEnable[21],
          1'b0, writeEnable[20], 1'b0, writeEnable[19], 1'b0, writeEnable[18], 1'b0, writeEnable[17],
          1'b0, writeEnable[16], 1'b0, writeEnable[15], 1'b0, writeEnable[14], 1'b0, writeEnable[13],
          1'b0, writeEnable[12], 1'b0, writeEnable[11], 1'b0, writeEnable[10], 1'b0, writeEnable[9],
          1'b0, writeEnable[8], 1'b0, writeEnable[7], 1'b0, writeEnable[6], 1'b0, writeEnable[5],
          1'b0, writeEnable[4], 1'b0, writeEnable[3], 1'b0, writeEnable[2], 1'b0, writeEnable[1],
          1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[127], 1'b0, wordtemp[126], 1'b0, wordtemp[125],
          1'b0, wordtemp[124], 1'b0, wordtemp[123], 1'b0, wordtemp[122], 1'b0, wordtemp[121],
          1'b0, wordtemp[120], 1'b0, wordtemp[119], 1'b0, wordtemp[118], 1'b0, wordtemp[117],
          1'b0, wordtemp[116], 1'b0, wordtemp[115], 1'b0, wordtemp[114], 1'b0, wordtemp[113],
          1'b0, wordtemp[112], 1'b0, wordtemp[111], 1'b0, wordtemp[110], 1'b0, wordtemp[109],
          1'b0, wordtemp[108], 1'b0, wordtemp[107], 1'b0, wordtemp[106], 1'b0, wordtemp[105],
          1'b0, wordtemp[104], 1'b0, wordtemp[103], 1'b0, wordtemp[102], 1'b0, wordtemp[101],
          1'b0, wordtemp[100], 1'b0, wordtemp[99], 1'b0, wordtemp[98], 1'b0, wordtemp[97],
          1'b0, wordtemp[96], 1'b0, wordtemp[95], 1'b0, wordtemp[94], 1'b0, wordtemp[93],
          1'b0, wordtemp[92], 1'b0, wordtemp[91], 1'b0, wordtemp[90], 1'b0, wordtemp[89],
          1'b0, wordtemp[88], 1'b0, wordtemp[87], 1'b0, wordtemp[86], 1'b0, wordtemp[85],
          1'b0, wordtemp[84], 1'b0, wordtemp[83], 1'b0, wordtemp[82], 1'b0, wordtemp[81],
          1'b0, wordtemp[80], 1'b0, wordtemp[79], 1'b0, wordtemp[78], 1'b0, wordtemp[77],
          1'b0, wordtemp[76], 1'b0, wordtemp[75], 1'b0, wordtemp[74], 1'b0, wordtemp[73],
          1'b0, wordtemp[72], 1'b0, wordtemp[71], 1'b0, wordtemp[70], 1'b0, wordtemp[69],
          1'b0, wordtemp[68], 1'b0, wordtemp[67], 1'b0, wordtemp[66], 1'b0, wordtemp[65],
          1'b0, wordtemp[64], 1'b0, wordtemp[63], 1'b0, wordtemp[62], 1'b0, wordtemp[61],
          1'b0, wordtemp[60], 1'b0, wordtemp[59], 1'b0, wordtemp[58], 1'b0, wordtemp[57],
          1'b0, wordtemp[56], 1'b0, wordtemp[55], 1'b0, wordtemp[54], 1'b0, wordtemp[53],
          1'b0, wordtemp[52], 1'b0, wordtemp[51], 1'b0, wordtemp[50], 1'b0, wordtemp[49],
          1'b0, wordtemp[48], 1'b0, wordtemp[47], 1'b0, wordtemp[46], 1'b0, wordtemp[45],
          1'b0, wordtemp[44], 1'b0, wordtemp[43], 1'b0, wordtemp[42], 1'b0, wordtemp[41],
          1'b0, wordtemp[40], 1'b0, wordtemp[39], 1'b0, wordtemp[38], 1'b0, wordtemp[37],
          1'b0, wordtemp[36], 1'b0, wordtemp[35], 1'b0, wordtemp[34], 1'b0, wordtemp[33],
          1'b0, wordtemp[32], 1'b0, wordtemp[31], 1'b0, wordtemp[30], 1'b0, wordtemp[29],
          1'b0, wordtemp[28], 1'b0, wordtemp[27], 1'b0, wordtemp[26], 1'b0, wordtemp[25],
          1'b0, wordtemp[24], 1'b0, wordtemp[23], 1'b0, wordtemp[22], 1'b0, wordtemp[21],
          1'b0, wordtemp[20], 1'b0, wordtemp[19], 1'b0, wordtemp[18], 1'b0, wordtemp[17],
          1'b0, wordtemp[16], 1'b0, wordtemp[15], 1'b0, wordtemp[14], 1'b0, wordtemp[13],
          1'b0, wordtemp[12], 1'b0, wordtemp[11], 1'b0, wordtemp[10], 1'b0, wordtemp[9],
          1'b0, wordtemp[8], 1'b0, wordtemp[7], 1'b0, wordtemp[6], 1'b0, wordtemp[5],
          1'b0, wordtemp[4], 1'b0, wordtemp[3], 1'b0, wordtemp[2], 1'b0, wordtemp[1],
          1'b0, wordtemp[0]} << mux_address);
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
        writeEnable = {128{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[254], data_out[252], data_out[250], data_out[248], data_out[246],
          data_out[244], data_out[242], data_out[240], data_out[238], data_out[236],
          data_out[234], data_out[232], data_out[230], data_out[228], data_out[226],
          data_out[224], data_out[222], data_out[220], data_out[218], data_out[216],
          data_out[214], data_out[212], data_out[210], data_out[208], data_out[206],
          data_out[204], data_out[202], data_out[200], data_out[198], data_out[196],
          data_out[194], data_out[192], data_out[190], data_out[188], data_out[186],
          data_out[184], data_out[182], data_out[180], data_out[178], data_out[176],
          data_out[174], data_out[172], data_out[170], data_out[168], data_out[166],
          data_out[164], data_out[162], data_out[160], data_out[158], data_out[156],
          data_out[154], data_out[152], data_out[150], data_out[148], data_out[146],
          data_out[144], data_out[142], data_out[140], data_out[138], data_out[136],
          data_out[134], data_out[132], data_out[130], data_out[128], data_out[126],
          data_out[124], data_out[122], data_out[120], data_out[118], data_out[116],
          data_out[114], data_out[112], data_out[110], data_out[108], data_out[106],
          data_out[104], data_out[102], data_out[100], data_out[98], data_out[96],
          data_out[94], data_out[92], data_out[90], data_out[88], data_out[86], data_out[84],
          data_out[82], data_out[80], data_out[78], data_out[76], data_out[74], data_out[72],
          data_out[70], data_out[68], data_out[66], data_out[64], data_out[62], data_out[60],
          data_out[58], data_out[56], data_out[54], data_out[52], data_out[50], data_out[48],
          data_out[46], data_out[44], data_out[42], data_out[40], data_out[38], data_out[36],
          data_out[34], data_out[32], data_out[30], data_out[28], data_out[26], data_out[24],
          data_out[22], data_out[20], data_out[18], data_out[16], data_out[14], data_out[12],
          data_out[10], data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[127], shifted_readLatch0[126], shifted_readLatch0[125],
          shifted_readLatch0[124], shifted_readLatch0[123], shifted_readLatch0[122],
          shifted_readLatch0[121], shifted_readLatch0[120], shifted_readLatch0[119],
          shifted_readLatch0[118], shifted_readLatch0[117], shifted_readLatch0[116],
          shifted_readLatch0[115], shifted_readLatch0[114], shifted_readLatch0[113],
          shifted_readLatch0[112], shifted_readLatch0[111], shifted_readLatch0[110],
          shifted_readLatch0[109], shifted_readLatch0[108], shifted_readLatch0[107],
          shifted_readLatch0[106], shifted_readLatch0[105], shifted_readLatch0[104],
          shifted_readLatch0[103], shifted_readLatch0[102], shifted_readLatch0[101],
          shifted_readLatch0[100], shifted_readLatch0[99], shifted_readLatch0[98],
          shifted_readLatch0[97], shifted_readLatch0[96], shifted_readLatch0[95], shifted_readLatch0[94],
          shifted_readLatch0[93], shifted_readLatch0[92], shifted_readLatch0[91], shifted_readLatch0[90],
          shifted_readLatch0[89], shifted_readLatch0[88], shifted_readLatch0[87], shifted_readLatch0[86],
          shifted_readLatch0[85], shifted_readLatch0[84], shifted_readLatch0[83], shifted_readLatch0[82],
          shifted_readLatch0[81], shifted_readLatch0[80], shifted_readLatch0[79], shifted_readLatch0[78],
          shifted_readLatch0[77], shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74],
          shifted_readLatch0[73], shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70],
          shifted_readLatch0[69], shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66],
          shifted_readLatch0[65], shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62],
          shifted_readLatch0[61], shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58],
          shifted_readLatch0[57], shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54],
          shifted_readLatch0[53], shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50],
          shifted_readLatch0[49], shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46],
          shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42],
          shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38],
          shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34],
          shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30],
          shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26],
          shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22],
          shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18],
          shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14],
          shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10],
          shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6],
          shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2],
          shifted_readLatch0[1], shifted_readLatch0[0]};
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
	input [127:0] load_data;
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
        writeEnable = {128{1'b1}};
        row_mask =  ( {1'b0, writeEnable[127], 1'b0, writeEnable[126], 1'b0, writeEnable[125],
          1'b0, writeEnable[124], 1'b0, writeEnable[123], 1'b0, writeEnable[122], 1'b0, writeEnable[121],
          1'b0, writeEnable[120], 1'b0, writeEnable[119], 1'b0, writeEnable[118], 1'b0, writeEnable[117],
          1'b0, writeEnable[116], 1'b0, writeEnable[115], 1'b0, writeEnable[114], 1'b0, writeEnable[113],
          1'b0, writeEnable[112], 1'b0, writeEnable[111], 1'b0, writeEnable[110], 1'b0, writeEnable[109],
          1'b0, writeEnable[108], 1'b0, writeEnable[107], 1'b0, writeEnable[106], 1'b0, writeEnable[105],
          1'b0, writeEnable[104], 1'b0, writeEnable[103], 1'b0, writeEnable[102], 1'b0, writeEnable[101],
          1'b0, writeEnable[100], 1'b0, writeEnable[99], 1'b0, writeEnable[98], 1'b0, writeEnable[97],
          1'b0, writeEnable[96], 1'b0, writeEnable[95], 1'b0, writeEnable[94], 1'b0, writeEnable[93],
          1'b0, writeEnable[92], 1'b0, writeEnable[91], 1'b0, writeEnable[90], 1'b0, writeEnable[89],
          1'b0, writeEnable[88], 1'b0, writeEnable[87], 1'b0, writeEnable[86], 1'b0, writeEnable[85],
          1'b0, writeEnable[84], 1'b0, writeEnable[83], 1'b0, writeEnable[82], 1'b0, writeEnable[81],
          1'b0, writeEnable[80], 1'b0, writeEnable[79], 1'b0, writeEnable[78], 1'b0, writeEnable[77],
          1'b0, writeEnable[76], 1'b0, writeEnable[75], 1'b0, writeEnable[74], 1'b0, writeEnable[73],
          1'b0, writeEnable[72], 1'b0, writeEnable[71], 1'b0, writeEnable[70], 1'b0, writeEnable[69],
          1'b0, writeEnable[68], 1'b0, writeEnable[67], 1'b0, writeEnable[66], 1'b0, writeEnable[65],
          1'b0, writeEnable[64], 1'b0, writeEnable[63], 1'b0, writeEnable[62], 1'b0, writeEnable[61],
          1'b0, writeEnable[60], 1'b0, writeEnable[59], 1'b0, writeEnable[58], 1'b0, writeEnable[57],
          1'b0, writeEnable[56], 1'b0, writeEnable[55], 1'b0, writeEnable[54], 1'b0, writeEnable[53],
          1'b0, writeEnable[52], 1'b0, writeEnable[51], 1'b0, writeEnable[50], 1'b0, writeEnable[49],
          1'b0, writeEnable[48], 1'b0, writeEnable[47], 1'b0, writeEnable[46], 1'b0, writeEnable[45],
          1'b0, writeEnable[44], 1'b0, writeEnable[43], 1'b0, writeEnable[42], 1'b0, writeEnable[41],
          1'b0, writeEnable[40], 1'b0, writeEnable[39], 1'b0, writeEnable[38], 1'b0, writeEnable[37],
          1'b0, writeEnable[36], 1'b0, writeEnable[35], 1'b0, writeEnable[34], 1'b0, writeEnable[33],
          1'b0, writeEnable[32], 1'b0, writeEnable[31], 1'b0, writeEnable[30], 1'b0, writeEnable[29],
          1'b0, writeEnable[28], 1'b0, writeEnable[27], 1'b0, writeEnable[26], 1'b0, writeEnable[25],
          1'b0, writeEnable[24], 1'b0, writeEnable[23], 1'b0, writeEnable[22], 1'b0, writeEnable[21],
          1'b0, writeEnable[20], 1'b0, writeEnable[19], 1'b0, writeEnable[18], 1'b0, writeEnable[17],
          1'b0, writeEnable[16], 1'b0, writeEnable[15], 1'b0, writeEnable[14], 1'b0, writeEnable[13],
          1'b0, writeEnable[12], 1'b0, writeEnable[11], 1'b0, writeEnable[10], 1'b0, writeEnable[9],
          1'b0, writeEnable[8], 1'b0, writeEnable[7], 1'b0, writeEnable[6], 1'b0, writeEnable[5],
          1'b0, writeEnable[4], 1'b0, writeEnable[3], 1'b0, writeEnable[2], 1'b0, writeEnable[1],
          1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[127], 1'b0, wordtemp[126], 1'b0, wordtemp[125],
          1'b0, wordtemp[124], 1'b0, wordtemp[123], 1'b0, wordtemp[122], 1'b0, wordtemp[121],
          1'b0, wordtemp[120], 1'b0, wordtemp[119], 1'b0, wordtemp[118], 1'b0, wordtemp[117],
          1'b0, wordtemp[116], 1'b0, wordtemp[115], 1'b0, wordtemp[114], 1'b0, wordtemp[113],
          1'b0, wordtemp[112], 1'b0, wordtemp[111], 1'b0, wordtemp[110], 1'b0, wordtemp[109],
          1'b0, wordtemp[108], 1'b0, wordtemp[107], 1'b0, wordtemp[106], 1'b0, wordtemp[105],
          1'b0, wordtemp[104], 1'b0, wordtemp[103], 1'b0, wordtemp[102], 1'b0, wordtemp[101],
          1'b0, wordtemp[100], 1'b0, wordtemp[99], 1'b0, wordtemp[98], 1'b0, wordtemp[97],
          1'b0, wordtemp[96], 1'b0, wordtemp[95], 1'b0, wordtemp[94], 1'b0, wordtemp[93],
          1'b0, wordtemp[92], 1'b0, wordtemp[91], 1'b0, wordtemp[90], 1'b0, wordtemp[89],
          1'b0, wordtemp[88], 1'b0, wordtemp[87], 1'b0, wordtemp[86], 1'b0, wordtemp[85],
          1'b0, wordtemp[84], 1'b0, wordtemp[83], 1'b0, wordtemp[82], 1'b0, wordtemp[81],
          1'b0, wordtemp[80], 1'b0, wordtemp[79], 1'b0, wordtemp[78], 1'b0, wordtemp[77],
          1'b0, wordtemp[76], 1'b0, wordtemp[75], 1'b0, wordtemp[74], 1'b0, wordtemp[73],
          1'b0, wordtemp[72], 1'b0, wordtemp[71], 1'b0, wordtemp[70], 1'b0, wordtemp[69],
          1'b0, wordtemp[68], 1'b0, wordtemp[67], 1'b0, wordtemp[66], 1'b0, wordtemp[65],
          1'b0, wordtemp[64], 1'b0, wordtemp[63], 1'b0, wordtemp[62], 1'b0, wordtemp[61],
          1'b0, wordtemp[60], 1'b0, wordtemp[59], 1'b0, wordtemp[58], 1'b0, wordtemp[57],
          1'b0, wordtemp[56], 1'b0, wordtemp[55], 1'b0, wordtemp[54], 1'b0, wordtemp[53],
          1'b0, wordtemp[52], 1'b0, wordtemp[51], 1'b0, wordtemp[50], 1'b0, wordtemp[49],
          1'b0, wordtemp[48], 1'b0, wordtemp[47], 1'b0, wordtemp[46], 1'b0, wordtemp[45],
          1'b0, wordtemp[44], 1'b0, wordtemp[43], 1'b0, wordtemp[42], 1'b0, wordtemp[41],
          1'b0, wordtemp[40], 1'b0, wordtemp[39], 1'b0, wordtemp[38], 1'b0, wordtemp[37],
          1'b0, wordtemp[36], 1'b0, wordtemp[35], 1'b0, wordtemp[34], 1'b0, wordtemp[33],
          1'b0, wordtemp[32], 1'b0, wordtemp[31], 1'b0, wordtemp[30], 1'b0, wordtemp[29],
          1'b0, wordtemp[28], 1'b0, wordtemp[27], 1'b0, wordtemp[26], 1'b0, wordtemp[25],
          1'b0, wordtemp[24], 1'b0, wordtemp[23], 1'b0, wordtemp[22], 1'b0, wordtemp[21],
          1'b0, wordtemp[20], 1'b0, wordtemp[19], 1'b0, wordtemp[18], 1'b0, wordtemp[17],
          1'b0, wordtemp[16], 1'b0, wordtemp[15], 1'b0, wordtemp[14], 1'b0, wordtemp[13],
          1'b0, wordtemp[12], 1'b0, wordtemp[11], 1'b0, wordtemp[10], 1'b0, wordtemp[9],
          1'b0, wordtemp[8], 1'b0, wordtemp[7], 1'b0, wordtemp[6], 1'b0, wordtemp[5],
          1'b0, wordtemp[4], 1'b0, wordtemp[3], 1'b0, wordtemp[2], 1'b0, wordtemp[1],
          1'b0, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [127:0] dump_data;
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
        writeEnable = {128{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[254], data_out[252], data_out[250], data_out[248], data_out[246],
          data_out[244], data_out[242], data_out[240], data_out[238], data_out[236],
          data_out[234], data_out[232], data_out[230], data_out[228], data_out[226],
          data_out[224], data_out[222], data_out[220], data_out[218], data_out[216],
          data_out[214], data_out[212], data_out[210], data_out[208], data_out[206],
          data_out[204], data_out[202], data_out[200], data_out[198], data_out[196],
          data_out[194], data_out[192], data_out[190], data_out[188], data_out[186],
          data_out[184], data_out[182], data_out[180], data_out[178], data_out[176],
          data_out[174], data_out[172], data_out[170], data_out[168], data_out[166],
          data_out[164], data_out[162], data_out[160], data_out[158], data_out[156],
          data_out[154], data_out[152], data_out[150], data_out[148], data_out[146],
          data_out[144], data_out[142], data_out[140], data_out[138], data_out[136],
          data_out[134], data_out[132], data_out[130], data_out[128], data_out[126],
          data_out[124], data_out[122], data_out[120], data_out[118], data_out[116],
          data_out[114], data_out[112], data_out[110], data_out[108], data_out[106],
          data_out[104], data_out[102], data_out[100], data_out[98], data_out[96],
          data_out[94], data_out[92], data_out[90], data_out[88], data_out[86], data_out[84],
          data_out[82], data_out[80], data_out[78], data_out[76], data_out[74], data_out[72],
          data_out[70], data_out[68], data_out[66], data_out[64], data_out[62], data_out[60],
          data_out[58], data_out[56], data_out[54], data_out[52], data_out[50], data_out[48],
          data_out[46], data_out[44], data_out[42], data_out[40], data_out[38], data_out[36],
          data_out[34], data_out[32], data_out[30], data_out[28], data_out[26], data_out[24],
          data_out[22], data_out[20], data_out[18], data_out[16], data_out[14], data_out[12],
          data_out[10], data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[127], shifted_readLatch0[126], shifted_readLatch0[125],
          shifted_readLatch0[124], shifted_readLatch0[123], shifted_readLatch0[122],
          shifted_readLatch0[121], shifted_readLatch0[120], shifted_readLatch0[119],
          shifted_readLatch0[118], shifted_readLatch0[117], shifted_readLatch0[116],
          shifted_readLatch0[115], shifted_readLatch0[114], shifted_readLatch0[113],
          shifted_readLatch0[112], shifted_readLatch0[111], shifted_readLatch0[110],
          shifted_readLatch0[109], shifted_readLatch0[108], shifted_readLatch0[107],
          shifted_readLatch0[106], shifted_readLatch0[105], shifted_readLatch0[104],
          shifted_readLatch0[103], shifted_readLatch0[102], shifted_readLatch0[101],
          shifted_readLatch0[100], shifted_readLatch0[99], shifted_readLatch0[98],
          shifted_readLatch0[97], shifted_readLatch0[96], shifted_readLatch0[95], shifted_readLatch0[94],
          shifted_readLatch0[93], shifted_readLatch0[92], shifted_readLatch0[91], shifted_readLatch0[90],
          shifted_readLatch0[89], shifted_readLatch0[88], shifted_readLatch0[87], shifted_readLatch0[86],
          shifted_readLatch0[85], shifted_readLatch0[84], shifted_readLatch0[83], shifted_readLatch0[82],
          shifted_readLatch0[81], shifted_readLatch0[80], shifted_readLatch0[79], shifted_readLatch0[78],
          shifted_readLatch0[77], shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74],
          shifted_readLatch0[73], shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70],
          shifted_readLatch0[69], shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66],
          shifted_readLatch0[65], shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62],
          shifted_readLatch0[61], shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58],
          shifted_readLatch0[57], shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54],
          shifted_readLatch0[53], shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50],
          shifted_readLatch0[49], shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46],
          shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42],
          shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38],
          shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34],
          shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30],
          shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26],
          shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22],
          shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18],
          shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14],
          shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10],
          shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6],
          shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2],
          shifted_readLatch0[1], shifted_readLatch0[0]};
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
      d_int = {128{1'bx}};
    if (^rawlm_ === 1'bx)
      d_int = {128{1'bx}};
    if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_int === 1'b0 && cen_int === 1'b0) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{cen_int, ema_int, emaw_int, emas_int, ret1n_int, wabl_int, wablm_int, rawl_int, rawlm_int} === 1'bx) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if ((a_int >= WORDS) && (cen_int === 1'b0)) begin
      q_int = wen_int !== 1'b1 ? q_int : {128{1'bx}};
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
     if (wen_int !== 1)
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (cen_int === 1'b0) begin
      mux_address = (a_int & 1'b1);
      row_address = (a_int >> 1);
      if (row_address > 63)
        row = {256{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {128{wen_int}};
      if (wen_int !== 1'b1) begin
        row_mask =  ( {1'b0, writeEnable[127], 1'b0, writeEnable[126], 1'b0, writeEnable[125],
          1'b0, writeEnable[124], 1'b0, writeEnable[123], 1'b0, writeEnable[122], 1'b0, writeEnable[121],
          1'b0, writeEnable[120], 1'b0, writeEnable[119], 1'b0, writeEnable[118], 1'b0, writeEnable[117],
          1'b0, writeEnable[116], 1'b0, writeEnable[115], 1'b0, writeEnable[114], 1'b0, writeEnable[113],
          1'b0, writeEnable[112], 1'b0, writeEnable[111], 1'b0, writeEnable[110], 1'b0, writeEnable[109],
          1'b0, writeEnable[108], 1'b0, writeEnable[107], 1'b0, writeEnable[106], 1'b0, writeEnable[105],
          1'b0, writeEnable[104], 1'b0, writeEnable[103], 1'b0, writeEnable[102], 1'b0, writeEnable[101],
          1'b0, writeEnable[100], 1'b0, writeEnable[99], 1'b0, writeEnable[98], 1'b0, writeEnable[97],
          1'b0, writeEnable[96], 1'b0, writeEnable[95], 1'b0, writeEnable[94], 1'b0, writeEnable[93],
          1'b0, writeEnable[92], 1'b0, writeEnable[91], 1'b0, writeEnable[90], 1'b0, writeEnable[89],
          1'b0, writeEnable[88], 1'b0, writeEnable[87], 1'b0, writeEnable[86], 1'b0, writeEnable[85],
          1'b0, writeEnable[84], 1'b0, writeEnable[83], 1'b0, writeEnable[82], 1'b0, writeEnable[81],
          1'b0, writeEnable[80], 1'b0, writeEnable[79], 1'b0, writeEnable[78], 1'b0, writeEnable[77],
          1'b0, writeEnable[76], 1'b0, writeEnable[75], 1'b0, writeEnable[74], 1'b0, writeEnable[73],
          1'b0, writeEnable[72], 1'b0, writeEnable[71], 1'b0, writeEnable[70], 1'b0, writeEnable[69],
          1'b0, writeEnable[68], 1'b0, writeEnable[67], 1'b0, writeEnable[66], 1'b0, writeEnable[65],
          1'b0, writeEnable[64], 1'b0, writeEnable[63], 1'b0, writeEnable[62], 1'b0, writeEnable[61],
          1'b0, writeEnable[60], 1'b0, writeEnable[59], 1'b0, writeEnable[58], 1'b0, writeEnable[57],
          1'b0, writeEnable[56], 1'b0, writeEnable[55], 1'b0, writeEnable[54], 1'b0, writeEnable[53],
          1'b0, writeEnable[52], 1'b0, writeEnable[51], 1'b0, writeEnable[50], 1'b0, writeEnable[49],
          1'b0, writeEnable[48], 1'b0, writeEnable[47], 1'b0, writeEnable[46], 1'b0, writeEnable[45],
          1'b0, writeEnable[44], 1'b0, writeEnable[43], 1'b0, writeEnable[42], 1'b0, writeEnable[41],
          1'b0, writeEnable[40], 1'b0, writeEnable[39], 1'b0, writeEnable[38], 1'b0, writeEnable[37],
          1'b0, writeEnable[36], 1'b0, writeEnable[35], 1'b0, writeEnable[34], 1'b0, writeEnable[33],
          1'b0, writeEnable[32], 1'b0, writeEnable[31], 1'b0, writeEnable[30], 1'b0, writeEnable[29],
          1'b0, writeEnable[28], 1'b0, writeEnable[27], 1'b0, writeEnable[26], 1'b0, writeEnable[25],
          1'b0, writeEnable[24], 1'b0, writeEnable[23], 1'b0, writeEnable[22], 1'b0, writeEnable[21],
          1'b0, writeEnable[20], 1'b0, writeEnable[19], 1'b0, writeEnable[18], 1'b0, writeEnable[17],
          1'b0, writeEnable[16], 1'b0, writeEnable[15], 1'b0, writeEnable[14], 1'b0, writeEnable[13],
          1'b0, writeEnable[12], 1'b0, writeEnable[11], 1'b0, writeEnable[10], 1'b0, writeEnable[9],
          1'b0, writeEnable[8], 1'b0, writeEnable[7], 1'b0, writeEnable[6], 1'b0, writeEnable[5],
          1'b0, writeEnable[4], 1'b0, writeEnable[3], 1'b0, writeEnable[2], 1'b0, writeEnable[1],
          1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, d_int[127], 1'b0, d_int[126], 1'b0, d_int[125], 1'b0, d_int[124],
          1'b0, d_int[123], 1'b0, d_int[122], 1'b0, d_int[121], 1'b0, d_int[120], 1'b0, d_int[119],
          1'b0, d_int[118], 1'b0, d_int[117], 1'b0, d_int[116], 1'b0, d_int[115], 1'b0, d_int[114],
          1'b0, d_int[113], 1'b0, d_int[112], 1'b0, d_int[111], 1'b0, d_int[110], 1'b0, d_int[109],
          1'b0, d_int[108], 1'b0, d_int[107], 1'b0, d_int[106], 1'b0, d_int[105], 1'b0, d_int[104],
          1'b0, d_int[103], 1'b0, d_int[102], 1'b0, d_int[101], 1'b0, d_int[100], 1'b0, d_int[99],
          1'b0, d_int[98], 1'b0, d_int[97], 1'b0, d_int[96], 1'b0, d_int[95], 1'b0, d_int[94],
          1'b0, d_int[93], 1'b0, d_int[92], 1'b0, d_int[91], 1'b0, d_int[90], 1'b0, d_int[89],
          1'b0, d_int[88], 1'b0, d_int[87], 1'b0, d_int[86], 1'b0, d_int[85], 1'b0, d_int[84],
          1'b0, d_int[83], 1'b0, d_int[82], 1'b0, d_int[81], 1'b0, d_int[80], 1'b0, d_int[79],
          1'b0, d_int[78], 1'b0, d_int[77], 1'b0, d_int[76], 1'b0, d_int[75], 1'b0, d_int[74],
          1'b0, d_int[73], 1'b0, d_int[72], 1'b0, d_int[71], 1'b0, d_int[70], 1'b0, d_int[69],
          1'b0, d_int[68], 1'b0, d_int[67], 1'b0, d_int[66], 1'b0, d_int[65], 1'b0, d_int[64],
          1'b0, d_int[63], 1'b0, d_int[62], 1'b0, d_int[61], 1'b0, d_int[60], 1'b0, d_int[59],
          1'b0, d_int[58], 1'b0, d_int[57], 1'b0, d_int[56], 1'b0, d_int[55], 1'b0, d_int[54],
          1'b0, d_int[53], 1'b0, d_int[52], 1'b0, d_int[51], 1'b0, d_int[50], 1'b0, d_int[49],
          1'b0, d_int[48], 1'b0, d_int[47], 1'b0, d_int[46], 1'b0, d_int[45], 1'b0, d_int[44],
          1'b0, d_int[43], 1'b0, d_int[42], 1'b0, d_int[41], 1'b0, d_int[40], 1'b0, d_int[39],
          1'b0, d_int[38], 1'b0, d_int[37], 1'b0, d_int[36], 1'b0, d_int[35], 1'b0, d_int[34],
          1'b0, d_int[33], 1'b0, d_int[32], 1'b0, d_int[31], 1'b0, d_int[30], 1'b0, d_int[29],
          1'b0, d_int[28], 1'b0, d_int[27], 1'b0, d_int[26], 1'b0, d_int[25], 1'b0, d_int[24],
          1'b0, d_int[23], 1'b0, d_int[22], 1'b0, d_int[21], 1'b0, d_int[20], 1'b0, d_int[19],
          1'b0, d_int[18], 1'b0, d_int[17], 1'b0, d_int[16], 1'b0, d_int[15], 1'b0, d_int[14],
          1'b0, d_int[13], 1'b0, d_int[12], 1'b0, d_int[11], 1'b0, d_int[10], 1'b0, d_int[9],
          1'b0, d_int[8], 1'b0, d_int[7], 1'b0, d_int[6], 1'b0, d_int[5], 1'b0, d_int[4],
          1'b0, d_int[3], 1'b0, d_int[2], 1'b0, d_int[1], 1'b0, d_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[254], data_out[252], data_out[250], data_out[248], data_out[246],
          data_out[244], data_out[242], data_out[240], data_out[238], data_out[236],
          data_out[234], data_out[232], data_out[230], data_out[228], data_out[226],
          data_out[224], data_out[222], data_out[220], data_out[218], data_out[216],
          data_out[214], data_out[212], data_out[210], data_out[208], data_out[206],
          data_out[204], data_out[202], data_out[200], data_out[198], data_out[196],
          data_out[194], data_out[192], data_out[190], data_out[188], data_out[186],
          data_out[184], data_out[182], data_out[180], data_out[178], data_out[176],
          data_out[174], data_out[172], data_out[170], data_out[168], data_out[166],
          data_out[164], data_out[162], data_out[160], data_out[158], data_out[156],
          data_out[154], data_out[152], data_out[150], data_out[148], data_out[146],
          data_out[144], data_out[142], data_out[140], data_out[138], data_out[136],
          data_out[134], data_out[132], data_out[130], data_out[128], data_out[126],
          data_out[124], data_out[122], data_out[120], data_out[118], data_out[116],
          data_out[114], data_out[112], data_out[110], data_out[108], data_out[106],
          data_out[104], data_out[102], data_out[100], data_out[98], data_out[96],
          data_out[94], data_out[92], data_out[90], data_out[88], data_out[86], data_out[84],
          data_out[82], data_out[80], data_out[78], data_out[76], data_out[74], data_out[72],
          data_out[70], data_out[68], data_out[66], data_out[64], data_out[62], data_out[60],
          data_out[58], data_out[56], data_out[54], data_out[52], data_out[50], data_out[48],
          data_out[46], data_out[44], data_out[42], data_out[40], data_out[38], data_out[36],
          data_out[34], data_out[32], data_out[30], data_out[28], data_out[26], data_out[24],
          data_out[22], data_out[20], data_out[18], data_out[16], data_out[14], data_out[12],
          data_out[10], data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[127], shifted_readLatch0[126], shifted_readLatch0[125],
          shifted_readLatch0[124], shifted_readLatch0[123], shifted_readLatch0[122],
          shifted_readLatch0[121], shifted_readLatch0[120], shifted_readLatch0[119],
          shifted_readLatch0[118], shifted_readLatch0[117], shifted_readLatch0[116],
          shifted_readLatch0[115], shifted_readLatch0[114], shifted_readLatch0[113],
          shifted_readLatch0[112], shifted_readLatch0[111], shifted_readLatch0[110],
          shifted_readLatch0[109], shifted_readLatch0[108], shifted_readLatch0[107],
          shifted_readLatch0[106], shifted_readLatch0[105], shifted_readLatch0[104],
          shifted_readLatch0[103], shifted_readLatch0[102], shifted_readLatch0[101],
          shifted_readLatch0[100], shifted_readLatch0[99], shifted_readLatch0[98],
          shifted_readLatch0[97], shifted_readLatch0[96], shifted_readLatch0[95], shifted_readLatch0[94],
          shifted_readLatch0[93], shifted_readLatch0[92], shifted_readLatch0[91], shifted_readLatch0[90],
          shifted_readLatch0[89], shifted_readLatch0[88], shifted_readLatch0[87], shifted_readLatch0[86],
          shifted_readLatch0[85], shifted_readLatch0[84], shifted_readLatch0[83], shifted_readLatch0[82],
          shifted_readLatch0[81], shifted_readLatch0[80], shifted_readLatch0[79], shifted_readLatch0[78],
          shifted_readLatch0[77], shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74],
          shifted_readLatch0[73], shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70],
          shifted_readLatch0[69], shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66],
          shifted_readLatch0[65], shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62],
          shifted_readLatch0[61], shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58],
          shifted_readLatch0[57], shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54],
          shifted_readLatch0[53], shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50],
          shifted_readLatch0[49], shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46],
          shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42],
          shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38],
          shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34],
          shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30],
          shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26],
          shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22],
          shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18],
          shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14],
          shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10],
          shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6],
          shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2],
          shifted_readLatch0[1], shifted_readLatch0[0]};
      end
    if (rawl_ === 1'bx)
        q_int = {128{1'bx}};
    if (^rawlm_ === 1'bx)
        q_int = {128{1'bx}};
      if( isBitX(wen_int) ) begin
        q_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {128{1'bx}};
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
      q_int = {128{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (VDDPE !== 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        q_int = {128{1'bx}};
		if (ret1n_ !== 1'b0)
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE !== 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        q_int = {128{1'bx}};
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
module sram128x128 (VDDCE, VDDPE, VSSE, q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, 
    wabl, wablm, rawl, rawlm);
`else
module sram128x128 (q, clk, cen, wen, a, d, ema, emaw, emas, ret1n, wabl, wablm, rawl, 
    rawlm);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 128;
  parameter WORDS = 128;
  parameter MUX = 2;
  parameter MEM_WIDTH = 256; // redun block size 2, 128 on left, 128 on right
  parameter MEM_HEIGHT = 64;
  parameter WP_SIZE = 128 ;
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

  output [127:0] q;
  input  clk;
  input  cen;
  input  wen;
  input [6:0] a;
  input [127:0] d;
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
  reg [255:0] mem [0:63];
  reg [255:0] row, row_t;
  reg LAST_clk;
  reg [255:0] row_mask;
  reg [255:0] new_data;
  reg [255:0] data_out;
  reg [127:0] readLatch0;
  reg [127:0] shifted_readLatch0;
  reg [127:0] q_int;
  reg [127:0] writeEnable;

  reg NOT_cen, NOT_wen, NOT_a6, NOT_a5, NOT_a4, NOT_a3, NOT_a2, NOT_a1, NOT_a0, NOT_d127;
  reg NOT_d126, NOT_d125, NOT_d124, NOT_d123, NOT_d122, NOT_d121, NOT_d120, NOT_d119;
  reg NOT_d118, NOT_d117, NOT_d116, NOT_d115, NOT_d114, NOT_d113, NOT_d112, NOT_d111;
  reg NOT_d110, NOT_d109, NOT_d108, NOT_d107, NOT_d106, NOT_d105, NOT_d104, NOT_d103;
  reg NOT_d102, NOT_d101, NOT_d100, NOT_d99, NOT_d98, NOT_d97, NOT_d96, NOT_d95, NOT_d94;
  reg NOT_d93, NOT_d92, NOT_d91, NOT_d90, NOT_d89, NOT_d88, NOT_d87, NOT_d86, NOT_d85;
  reg NOT_d84, NOT_d83, NOT_d82, NOT_d81, NOT_d80, NOT_d79, NOT_d78, NOT_d77, NOT_d76;
  reg NOT_d75, NOT_d74, NOT_d73, NOT_d72, NOT_d71, NOT_d70, NOT_d69, NOT_d68, NOT_d67;
  reg NOT_d66, NOT_d65, NOT_d64, NOT_d63, NOT_d62, NOT_d61, NOT_d60, NOT_d59, NOT_d58;
  reg NOT_d57, NOT_d56, NOT_d55, NOT_d54, NOT_d53, NOT_d52, NOT_d51, NOT_d50, NOT_d49;
  reg NOT_d48, NOT_d47, NOT_d46, NOT_d45, NOT_d44, NOT_d43, NOT_d42, NOT_d41, NOT_d40;
  reg NOT_d39, NOT_d38, NOT_d37, NOT_d36, NOT_d35, NOT_d34, NOT_d33, NOT_d32, NOT_d31;
  reg NOT_d30, NOT_d29, NOT_d28, NOT_d27, NOT_d26, NOT_d25, NOT_d24, NOT_d23, NOT_d22;
  reg NOT_d21, NOT_d20, NOT_d19, NOT_d18, NOT_d17, NOT_d16, NOT_d15, NOT_d14, NOT_d13;
  reg NOT_d12, NOT_d11, NOT_d10, NOT_d9, NOT_d8, NOT_d7, NOT_d6, NOT_d5, NOT_d4, NOT_d3;
  reg NOT_d2, NOT_d1, NOT_d0, NOT_ema2, NOT_ema1, NOT_ema0, NOT_emaw1, NOT_emaw0, NOT_emas;
  reg NOT_ret1n, NOT_wabl, NOT_wablm1, NOT_wablm0, NOT_rawl, NOT_rawlm1, NOT_rawlm0;
  reg NOT_clk_PER, NOT_clk_MINH, NOT_clk_MINL;
  reg clk0_int;

  wire [127:0] q_;
  wire [127:0] q_out;
 wire  clk_;
  wire  cen_;
  reg  cen_int;
  reg  cen_p2;
  wire  wen_;
  reg  wen_int;
  wire [6:0] a_;
  reg [6:0] a_int;
  wire [127:0] d_;
  reg [127:0] d_int;
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
  buf B64(q[64], q_[64]);
  buf B65(q[65], q_[65]);
  buf B66(q[66], q_[66]);
  buf B67(q[67], q_[67]);
  buf B68(q[68], q_[68]);
  buf B69(q[69], q_[69]);
  buf B70(q[70], q_[70]);
  buf B71(q[71], q_[71]);
  buf B72(q[72], q_[72]);
  buf B73(q[73], q_[73]);
  buf B74(q[74], q_[74]);
  buf B75(q[75], q_[75]);
  buf B76(q[76], q_[76]);
  buf B77(q[77], q_[77]);
  buf B78(q[78], q_[78]);
  buf B79(q[79], q_[79]);
  buf B80(q[80], q_[80]);
  buf B81(q[81], q_[81]);
  buf B82(q[82], q_[82]);
  buf B83(q[83], q_[83]);
  buf B84(q[84], q_[84]);
  buf B85(q[85], q_[85]);
  buf B86(q[86], q_[86]);
  buf B87(q[87], q_[87]);
  buf B88(q[88], q_[88]);
  buf B89(q[89], q_[89]);
  buf B90(q[90], q_[90]);
  buf B91(q[91], q_[91]);
  buf B92(q[92], q_[92]);
  buf B93(q[93], q_[93]);
  buf B94(q[94], q_[94]);
  buf B95(q[95], q_[95]);
  buf B96(q[96], q_[96]);
  buf B97(q[97], q_[97]);
  buf B98(q[98], q_[98]);
  buf B99(q[99], q_[99]);
  buf B100(q[100], q_[100]);
  buf B101(q[101], q_[101]);
  buf B102(q[102], q_[102]);
  buf B103(q[103], q_[103]);
  buf B104(q[104], q_[104]);
  buf B105(q[105], q_[105]);
  buf B106(q[106], q_[106]);
  buf B107(q[107], q_[107]);
  buf B108(q[108], q_[108]);
  buf B109(q[109], q_[109]);
  buf B110(q[110], q_[110]);
  buf B111(q[111], q_[111]);
  buf B112(q[112], q_[112]);
  buf B113(q[113], q_[113]);
  buf B114(q[114], q_[114]);
  buf B115(q[115], q_[115]);
  buf B116(q[116], q_[116]);
  buf B117(q[117], q_[117]);
  buf B118(q[118], q_[118]);
  buf B119(q[119], q_[119]);
  buf B120(q[120], q_[120]);
  buf B121(q[121], q_[121]);
  buf B122(q[122], q_[122]);
  buf B123(q[123], q_[123]);
  buf B124(q[124], q_[124]);
  buf B125(q[125], q_[125]);
  buf B126(q[126], q_[126]);
  buf B127(q[127], q_[127]);
  buf B128(clk_, clk);
  buf B129(cen_, cen);
  buf B130(wen_, wen);
  buf B131(a_[0], a[0]);
  buf B132(a_[1], a[1]);
  buf B133(a_[2], a[2]);
  buf B134(a_[3], a[3]);
  buf B135(a_[4], a[4]);
  buf B136(a_[5], a[5]);
  buf B137(a_[6], a[6]);
  buf B138(d_[0], d[0]);
  buf B139(d_[1], d[1]);
  buf B140(d_[2], d[2]);
  buf B141(d_[3], d[3]);
  buf B142(d_[4], d[4]);
  buf B143(d_[5], d[5]);
  buf B144(d_[6], d[6]);
  buf B145(d_[7], d[7]);
  buf B146(d_[8], d[8]);
  buf B147(d_[9], d[9]);
  buf B148(d_[10], d[10]);
  buf B149(d_[11], d[11]);
  buf B150(d_[12], d[12]);
  buf B151(d_[13], d[13]);
  buf B152(d_[14], d[14]);
  buf B153(d_[15], d[15]);
  buf B154(d_[16], d[16]);
  buf B155(d_[17], d[17]);
  buf B156(d_[18], d[18]);
  buf B157(d_[19], d[19]);
  buf B158(d_[20], d[20]);
  buf B159(d_[21], d[21]);
  buf B160(d_[22], d[22]);
  buf B161(d_[23], d[23]);
  buf B162(d_[24], d[24]);
  buf B163(d_[25], d[25]);
  buf B164(d_[26], d[26]);
  buf B165(d_[27], d[27]);
  buf B166(d_[28], d[28]);
  buf B167(d_[29], d[29]);
  buf B168(d_[30], d[30]);
  buf B169(d_[31], d[31]);
  buf B170(d_[32], d[32]);
  buf B171(d_[33], d[33]);
  buf B172(d_[34], d[34]);
  buf B173(d_[35], d[35]);
  buf B174(d_[36], d[36]);
  buf B175(d_[37], d[37]);
  buf B176(d_[38], d[38]);
  buf B177(d_[39], d[39]);
  buf B178(d_[40], d[40]);
  buf B179(d_[41], d[41]);
  buf B180(d_[42], d[42]);
  buf B181(d_[43], d[43]);
  buf B182(d_[44], d[44]);
  buf B183(d_[45], d[45]);
  buf B184(d_[46], d[46]);
  buf B185(d_[47], d[47]);
  buf B186(d_[48], d[48]);
  buf B187(d_[49], d[49]);
  buf B188(d_[50], d[50]);
  buf B189(d_[51], d[51]);
  buf B190(d_[52], d[52]);
  buf B191(d_[53], d[53]);
  buf B192(d_[54], d[54]);
  buf B193(d_[55], d[55]);
  buf B194(d_[56], d[56]);
  buf B195(d_[57], d[57]);
  buf B196(d_[58], d[58]);
  buf B197(d_[59], d[59]);
  buf B198(d_[60], d[60]);
  buf B199(d_[61], d[61]);
  buf B200(d_[62], d[62]);
  buf B201(d_[63], d[63]);
  buf B202(d_[64], d[64]);
  buf B203(d_[65], d[65]);
  buf B204(d_[66], d[66]);
  buf B205(d_[67], d[67]);
  buf B206(d_[68], d[68]);
  buf B207(d_[69], d[69]);
  buf B208(d_[70], d[70]);
  buf B209(d_[71], d[71]);
  buf B210(d_[72], d[72]);
  buf B211(d_[73], d[73]);
  buf B212(d_[74], d[74]);
  buf B213(d_[75], d[75]);
  buf B214(d_[76], d[76]);
  buf B215(d_[77], d[77]);
  buf B216(d_[78], d[78]);
  buf B217(d_[79], d[79]);
  buf B218(d_[80], d[80]);
  buf B219(d_[81], d[81]);
  buf B220(d_[82], d[82]);
  buf B221(d_[83], d[83]);
  buf B222(d_[84], d[84]);
  buf B223(d_[85], d[85]);
  buf B224(d_[86], d[86]);
  buf B225(d_[87], d[87]);
  buf B226(d_[88], d[88]);
  buf B227(d_[89], d[89]);
  buf B228(d_[90], d[90]);
  buf B229(d_[91], d[91]);
  buf B230(d_[92], d[92]);
  buf B231(d_[93], d[93]);
  buf B232(d_[94], d[94]);
  buf B233(d_[95], d[95]);
  buf B234(d_[96], d[96]);
  buf B235(d_[97], d[97]);
  buf B236(d_[98], d[98]);
  buf B237(d_[99], d[99]);
  buf B238(d_[100], d[100]);
  buf B239(d_[101], d[101]);
  buf B240(d_[102], d[102]);
  buf B241(d_[103], d[103]);
  buf B242(d_[104], d[104]);
  buf B243(d_[105], d[105]);
  buf B244(d_[106], d[106]);
  buf B245(d_[107], d[107]);
  buf B246(d_[108], d[108]);
  buf B247(d_[109], d[109]);
  buf B248(d_[110], d[110]);
  buf B249(d_[111], d[111]);
  buf B250(d_[112], d[112]);
  buf B251(d_[113], d[113]);
  buf B252(d_[114], d[114]);
  buf B253(d_[115], d[115]);
  buf B254(d_[116], d[116]);
  buf B255(d_[117], d[117]);
  buf B256(d_[118], d[118]);
  buf B257(d_[119], d[119]);
  buf B258(d_[120], d[120]);
  buf B259(d_[121], d[121]);
  buf B260(d_[122], d[122]);
  buf B261(d_[123], d[123]);
  buf B262(d_[124], d[124]);
  buf B263(d_[125], d[125]);
  buf B264(d_[126], d[126]);
  buf B265(d_[127], d[127]);
  buf B266(ema_[0], ema[0]);
  buf B267(ema_[1], ema[1]);
  buf B268(ema_[2], ema[2]);
  buf B269(emaw_[0], emaw[0]);
  buf B270(emaw_[1], emaw[1]);
  buf B271(emas_, emas);
  buf B272(ret1n_, ret1n);
  buf B273(wabl_, wabl);
  buf B274(wablm_[0], wablm[0]);
  buf B275(wablm_[1], wablm[1]);
  buf B276(rawl_, rawl);
  buf B277(rawlm_[0], rawlm[0]);
  buf B278(rawlm_[1], rawlm[1]);

   `ifdef ARM_FAULT_MODELING
     sram128x128_error_injection u1(.CLK(clk_), .Q_out(q_out), .A(a_int), .CEN(cen_int), .WEN(wen_int), .Q_in(q_int));
   `else
     assign q_out = q_int;
   `endif
  assign q_ = (ret1n_ | pre_charge_st) & ~corrupt_power ? ((q_out)) : {128{1'bx}};

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
        writeEnable = {128{1'b1}};
        row_mask =  ( {1'b0, writeEnable[127], 1'b0, writeEnable[126], 1'b0, writeEnable[125],
          1'b0, writeEnable[124], 1'b0, writeEnable[123], 1'b0, writeEnable[122], 1'b0, writeEnable[121],
          1'b0, writeEnable[120], 1'b0, writeEnable[119], 1'b0, writeEnable[118], 1'b0, writeEnable[117],
          1'b0, writeEnable[116], 1'b0, writeEnable[115], 1'b0, writeEnable[114], 1'b0, writeEnable[113],
          1'b0, writeEnable[112], 1'b0, writeEnable[111], 1'b0, writeEnable[110], 1'b0, writeEnable[109],
          1'b0, writeEnable[108], 1'b0, writeEnable[107], 1'b0, writeEnable[106], 1'b0, writeEnable[105],
          1'b0, writeEnable[104], 1'b0, writeEnable[103], 1'b0, writeEnable[102], 1'b0, writeEnable[101],
          1'b0, writeEnable[100], 1'b0, writeEnable[99], 1'b0, writeEnable[98], 1'b0, writeEnable[97],
          1'b0, writeEnable[96], 1'b0, writeEnable[95], 1'b0, writeEnable[94], 1'b0, writeEnable[93],
          1'b0, writeEnable[92], 1'b0, writeEnable[91], 1'b0, writeEnable[90], 1'b0, writeEnable[89],
          1'b0, writeEnable[88], 1'b0, writeEnable[87], 1'b0, writeEnable[86], 1'b0, writeEnable[85],
          1'b0, writeEnable[84], 1'b0, writeEnable[83], 1'b0, writeEnable[82], 1'b0, writeEnable[81],
          1'b0, writeEnable[80], 1'b0, writeEnable[79], 1'b0, writeEnable[78], 1'b0, writeEnable[77],
          1'b0, writeEnable[76], 1'b0, writeEnable[75], 1'b0, writeEnable[74], 1'b0, writeEnable[73],
          1'b0, writeEnable[72], 1'b0, writeEnable[71], 1'b0, writeEnable[70], 1'b0, writeEnable[69],
          1'b0, writeEnable[68], 1'b0, writeEnable[67], 1'b0, writeEnable[66], 1'b0, writeEnable[65],
          1'b0, writeEnable[64], 1'b0, writeEnable[63], 1'b0, writeEnable[62], 1'b0, writeEnable[61],
          1'b0, writeEnable[60], 1'b0, writeEnable[59], 1'b0, writeEnable[58], 1'b0, writeEnable[57],
          1'b0, writeEnable[56], 1'b0, writeEnable[55], 1'b0, writeEnable[54], 1'b0, writeEnable[53],
          1'b0, writeEnable[52], 1'b0, writeEnable[51], 1'b0, writeEnable[50], 1'b0, writeEnable[49],
          1'b0, writeEnable[48], 1'b0, writeEnable[47], 1'b0, writeEnable[46], 1'b0, writeEnable[45],
          1'b0, writeEnable[44], 1'b0, writeEnable[43], 1'b0, writeEnable[42], 1'b0, writeEnable[41],
          1'b0, writeEnable[40], 1'b0, writeEnable[39], 1'b0, writeEnable[38], 1'b0, writeEnable[37],
          1'b0, writeEnable[36], 1'b0, writeEnable[35], 1'b0, writeEnable[34], 1'b0, writeEnable[33],
          1'b0, writeEnable[32], 1'b0, writeEnable[31], 1'b0, writeEnable[30], 1'b0, writeEnable[29],
          1'b0, writeEnable[28], 1'b0, writeEnable[27], 1'b0, writeEnable[26], 1'b0, writeEnable[25],
          1'b0, writeEnable[24], 1'b0, writeEnable[23], 1'b0, writeEnable[22], 1'b0, writeEnable[21],
          1'b0, writeEnable[20], 1'b0, writeEnable[19], 1'b0, writeEnable[18], 1'b0, writeEnable[17],
          1'b0, writeEnable[16], 1'b0, writeEnable[15], 1'b0, writeEnable[14], 1'b0, writeEnable[13],
          1'b0, writeEnable[12], 1'b0, writeEnable[11], 1'b0, writeEnable[10], 1'b0, writeEnable[9],
          1'b0, writeEnable[8], 1'b0, writeEnable[7], 1'b0, writeEnable[6], 1'b0, writeEnable[5],
          1'b0, writeEnable[4], 1'b0, writeEnable[3], 1'b0, writeEnable[2], 1'b0, writeEnable[1],
          1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[127], 1'b0, wordtemp[126], 1'b0, wordtemp[125],
          1'b0, wordtemp[124], 1'b0, wordtemp[123], 1'b0, wordtemp[122], 1'b0, wordtemp[121],
          1'b0, wordtemp[120], 1'b0, wordtemp[119], 1'b0, wordtemp[118], 1'b0, wordtemp[117],
          1'b0, wordtemp[116], 1'b0, wordtemp[115], 1'b0, wordtemp[114], 1'b0, wordtemp[113],
          1'b0, wordtemp[112], 1'b0, wordtemp[111], 1'b0, wordtemp[110], 1'b0, wordtemp[109],
          1'b0, wordtemp[108], 1'b0, wordtemp[107], 1'b0, wordtemp[106], 1'b0, wordtemp[105],
          1'b0, wordtemp[104], 1'b0, wordtemp[103], 1'b0, wordtemp[102], 1'b0, wordtemp[101],
          1'b0, wordtemp[100], 1'b0, wordtemp[99], 1'b0, wordtemp[98], 1'b0, wordtemp[97],
          1'b0, wordtemp[96], 1'b0, wordtemp[95], 1'b0, wordtemp[94], 1'b0, wordtemp[93],
          1'b0, wordtemp[92], 1'b0, wordtemp[91], 1'b0, wordtemp[90], 1'b0, wordtemp[89],
          1'b0, wordtemp[88], 1'b0, wordtemp[87], 1'b0, wordtemp[86], 1'b0, wordtemp[85],
          1'b0, wordtemp[84], 1'b0, wordtemp[83], 1'b0, wordtemp[82], 1'b0, wordtemp[81],
          1'b0, wordtemp[80], 1'b0, wordtemp[79], 1'b0, wordtemp[78], 1'b0, wordtemp[77],
          1'b0, wordtemp[76], 1'b0, wordtemp[75], 1'b0, wordtemp[74], 1'b0, wordtemp[73],
          1'b0, wordtemp[72], 1'b0, wordtemp[71], 1'b0, wordtemp[70], 1'b0, wordtemp[69],
          1'b0, wordtemp[68], 1'b0, wordtemp[67], 1'b0, wordtemp[66], 1'b0, wordtemp[65],
          1'b0, wordtemp[64], 1'b0, wordtemp[63], 1'b0, wordtemp[62], 1'b0, wordtemp[61],
          1'b0, wordtemp[60], 1'b0, wordtemp[59], 1'b0, wordtemp[58], 1'b0, wordtemp[57],
          1'b0, wordtemp[56], 1'b0, wordtemp[55], 1'b0, wordtemp[54], 1'b0, wordtemp[53],
          1'b0, wordtemp[52], 1'b0, wordtemp[51], 1'b0, wordtemp[50], 1'b0, wordtemp[49],
          1'b0, wordtemp[48], 1'b0, wordtemp[47], 1'b0, wordtemp[46], 1'b0, wordtemp[45],
          1'b0, wordtemp[44], 1'b0, wordtemp[43], 1'b0, wordtemp[42], 1'b0, wordtemp[41],
          1'b0, wordtemp[40], 1'b0, wordtemp[39], 1'b0, wordtemp[38], 1'b0, wordtemp[37],
          1'b0, wordtemp[36], 1'b0, wordtemp[35], 1'b0, wordtemp[34], 1'b0, wordtemp[33],
          1'b0, wordtemp[32], 1'b0, wordtemp[31], 1'b0, wordtemp[30], 1'b0, wordtemp[29],
          1'b0, wordtemp[28], 1'b0, wordtemp[27], 1'b0, wordtemp[26], 1'b0, wordtemp[25],
          1'b0, wordtemp[24], 1'b0, wordtemp[23], 1'b0, wordtemp[22], 1'b0, wordtemp[21],
          1'b0, wordtemp[20], 1'b0, wordtemp[19], 1'b0, wordtemp[18], 1'b0, wordtemp[17],
          1'b0, wordtemp[16], 1'b0, wordtemp[15], 1'b0, wordtemp[14], 1'b0, wordtemp[13],
          1'b0, wordtemp[12], 1'b0, wordtemp[11], 1'b0, wordtemp[10], 1'b0, wordtemp[9],
          1'b0, wordtemp[8], 1'b0, wordtemp[7], 1'b0, wordtemp[6], 1'b0, wordtemp[5],
          1'b0, wordtemp[4], 1'b0, wordtemp[3], 1'b0, wordtemp[2], 1'b0, wordtemp[1],
          1'b0, wordtemp[0]} << mux_address);
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
        writeEnable = {128{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[254], data_out[252], data_out[250], data_out[248], data_out[246],
          data_out[244], data_out[242], data_out[240], data_out[238], data_out[236],
          data_out[234], data_out[232], data_out[230], data_out[228], data_out[226],
          data_out[224], data_out[222], data_out[220], data_out[218], data_out[216],
          data_out[214], data_out[212], data_out[210], data_out[208], data_out[206],
          data_out[204], data_out[202], data_out[200], data_out[198], data_out[196],
          data_out[194], data_out[192], data_out[190], data_out[188], data_out[186],
          data_out[184], data_out[182], data_out[180], data_out[178], data_out[176],
          data_out[174], data_out[172], data_out[170], data_out[168], data_out[166],
          data_out[164], data_out[162], data_out[160], data_out[158], data_out[156],
          data_out[154], data_out[152], data_out[150], data_out[148], data_out[146],
          data_out[144], data_out[142], data_out[140], data_out[138], data_out[136],
          data_out[134], data_out[132], data_out[130], data_out[128], data_out[126],
          data_out[124], data_out[122], data_out[120], data_out[118], data_out[116],
          data_out[114], data_out[112], data_out[110], data_out[108], data_out[106],
          data_out[104], data_out[102], data_out[100], data_out[98], data_out[96],
          data_out[94], data_out[92], data_out[90], data_out[88], data_out[86], data_out[84],
          data_out[82], data_out[80], data_out[78], data_out[76], data_out[74], data_out[72],
          data_out[70], data_out[68], data_out[66], data_out[64], data_out[62], data_out[60],
          data_out[58], data_out[56], data_out[54], data_out[52], data_out[50], data_out[48],
          data_out[46], data_out[44], data_out[42], data_out[40], data_out[38], data_out[36],
          data_out[34], data_out[32], data_out[30], data_out[28], data_out[26], data_out[24],
          data_out[22], data_out[20], data_out[18], data_out[16], data_out[14], data_out[12],
          data_out[10], data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[127], shifted_readLatch0[126], shifted_readLatch0[125],
          shifted_readLatch0[124], shifted_readLatch0[123], shifted_readLatch0[122],
          shifted_readLatch0[121], shifted_readLatch0[120], shifted_readLatch0[119],
          shifted_readLatch0[118], shifted_readLatch0[117], shifted_readLatch0[116],
          shifted_readLatch0[115], shifted_readLatch0[114], shifted_readLatch0[113],
          shifted_readLatch0[112], shifted_readLatch0[111], shifted_readLatch0[110],
          shifted_readLatch0[109], shifted_readLatch0[108], shifted_readLatch0[107],
          shifted_readLatch0[106], shifted_readLatch0[105], shifted_readLatch0[104],
          shifted_readLatch0[103], shifted_readLatch0[102], shifted_readLatch0[101],
          shifted_readLatch0[100], shifted_readLatch0[99], shifted_readLatch0[98],
          shifted_readLatch0[97], shifted_readLatch0[96], shifted_readLatch0[95], shifted_readLatch0[94],
          shifted_readLatch0[93], shifted_readLatch0[92], shifted_readLatch0[91], shifted_readLatch0[90],
          shifted_readLatch0[89], shifted_readLatch0[88], shifted_readLatch0[87], shifted_readLatch0[86],
          shifted_readLatch0[85], shifted_readLatch0[84], shifted_readLatch0[83], shifted_readLatch0[82],
          shifted_readLatch0[81], shifted_readLatch0[80], shifted_readLatch0[79], shifted_readLatch0[78],
          shifted_readLatch0[77], shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74],
          shifted_readLatch0[73], shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70],
          shifted_readLatch0[69], shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66],
          shifted_readLatch0[65], shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62],
          shifted_readLatch0[61], shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58],
          shifted_readLatch0[57], shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54],
          shifted_readLatch0[53], shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50],
          shifted_readLatch0[49], shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46],
          shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42],
          shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38],
          shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34],
          shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30],
          shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26],
          shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22],
          shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18],
          shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14],
          shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10],
          shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6],
          shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2],
          shifted_readLatch0[1], shifted_readLatch0[0]};
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
	input [127:0] load_data;
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
        writeEnable = {128{1'b1}};
        row_mask =  ( {1'b0, writeEnable[127], 1'b0, writeEnable[126], 1'b0, writeEnable[125],
          1'b0, writeEnable[124], 1'b0, writeEnable[123], 1'b0, writeEnable[122], 1'b0, writeEnable[121],
          1'b0, writeEnable[120], 1'b0, writeEnable[119], 1'b0, writeEnable[118], 1'b0, writeEnable[117],
          1'b0, writeEnable[116], 1'b0, writeEnable[115], 1'b0, writeEnable[114], 1'b0, writeEnable[113],
          1'b0, writeEnable[112], 1'b0, writeEnable[111], 1'b0, writeEnable[110], 1'b0, writeEnable[109],
          1'b0, writeEnable[108], 1'b0, writeEnable[107], 1'b0, writeEnable[106], 1'b0, writeEnable[105],
          1'b0, writeEnable[104], 1'b0, writeEnable[103], 1'b0, writeEnable[102], 1'b0, writeEnable[101],
          1'b0, writeEnable[100], 1'b0, writeEnable[99], 1'b0, writeEnable[98], 1'b0, writeEnable[97],
          1'b0, writeEnable[96], 1'b0, writeEnable[95], 1'b0, writeEnable[94], 1'b0, writeEnable[93],
          1'b0, writeEnable[92], 1'b0, writeEnable[91], 1'b0, writeEnable[90], 1'b0, writeEnable[89],
          1'b0, writeEnable[88], 1'b0, writeEnable[87], 1'b0, writeEnable[86], 1'b0, writeEnable[85],
          1'b0, writeEnable[84], 1'b0, writeEnable[83], 1'b0, writeEnable[82], 1'b0, writeEnable[81],
          1'b0, writeEnable[80], 1'b0, writeEnable[79], 1'b0, writeEnable[78], 1'b0, writeEnable[77],
          1'b0, writeEnable[76], 1'b0, writeEnable[75], 1'b0, writeEnable[74], 1'b0, writeEnable[73],
          1'b0, writeEnable[72], 1'b0, writeEnable[71], 1'b0, writeEnable[70], 1'b0, writeEnable[69],
          1'b0, writeEnable[68], 1'b0, writeEnable[67], 1'b0, writeEnable[66], 1'b0, writeEnable[65],
          1'b0, writeEnable[64], 1'b0, writeEnable[63], 1'b0, writeEnable[62], 1'b0, writeEnable[61],
          1'b0, writeEnable[60], 1'b0, writeEnable[59], 1'b0, writeEnable[58], 1'b0, writeEnable[57],
          1'b0, writeEnable[56], 1'b0, writeEnable[55], 1'b0, writeEnable[54], 1'b0, writeEnable[53],
          1'b0, writeEnable[52], 1'b0, writeEnable[51], 1'b0, writeEnable[50], 1'b0, writeEnable[49],
          1'b0, writeEnable[48], 1'b0, writeEnable[47], 1'b0, writeEnable[46], 1'b0, writeEnable[45],
          1'b0, writeEnable[44], 1'b0, writeEnable[43], 1'b0, writeEnable[42], 1'b0, writeEnable[41],
          1'b0, writeEnable[40], 1'b0, writeEnable[39], 1'b0, writeEnable[38], 1'b0, writeEnable[37],
          1'b0, writeEnable[36], 1'b0, writeEnable[35], 1'b0, writeEnable[34], 1'b0, writeEnable[33],
          1'b0, writeEnable[32], 1'b0, writeEnable[31], 1'b0, writeEnable[30], 1'b0, writeEnable[29],
          1'b0, writeEnable[28], 1'b0, writeEnable[27], 1'b0, writeEnable[26], 1'b0, writeEnable[25],
          1'b0, writeEnable[24], 1'b0, writeEnable[23], 1'b0, writeEnable[22], 1'b0, writeEnable[21],
          1'b0, writeEnable[20], 1'b0, writeEnable[19], 1'b0, writeEnable[18], 1'b0, writeEnable[17],
          1'b0, writeEnable[16], 1'b0, writeEnable[15], 1'b0, writeEnable[14], 1'b0, writeEnable[13],
          1'b0, writeEnable[12], 1'b0, writeEnable[11], 1'b0, writeEnable[10], 1'b0, writeEnable[9],
          1'b0, writeEnable[8], 1'b0, writeEnable[7], 1'b0, writeEnable[6], 1'b0, writeEnable[5],
          1'b0, writeEnable[4], 1'b0, writeEnable[3], 1'b0, writeEnable[2], 1'b0, writeEnable[1],
          1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, wordtemp[127], 1'b0, wordtemp[126], 1'b0, wordtemp[125],
          1'b0, wordtemp[124], 1'b0, wordtemp[123], 1'b0, wordtemp[122], 1'b0, wordtemp[121],
          1'b0, wordtemp[120], 1'b0, wordtemp[119], 1'b0, wordtemp[118], 1'b0, wordtemp[117],
          1'b0, wordtemp[116], 1'b0, wordtemp[115], 1'b0, wordtemp[114], 1'b0, wordtemp[113],
          1'b0, wordtemp[112], 1'b0, wordtemp[111], 1'b0, wordtemp[110], 1'b0, wordtemp[109],
          1'b0, wordtemp[108], 1'b0, wordtemp[107], 1'b0, wordtemp[106], 1'b0, wordtemp[105],
          1'b0, wordtemp[104], 1'b0, wordtemp[103], 1'b0, wordtemp[102], 1'b0, wordtemp[101],
          1'b0, wordtemp[100], 1'b0, wordtemp[99], 1'b0, wordtemp[98], 1'b0, wordtemp[97],
          1'b0, wordtemp[96], 1'b0, wordtemp[95], 1'b0, wordtemp[94], 1'b0, wordtemp[93],
          1'b0, wordtemp[92], 1'b0, wordtemp[91], 1'b0, wordtemp[90], 1'b0, wordtemp[89],
          1'b0, wordtemp[88], 1'b0, wordtemp[87], 1'b0, wordtemp[86], 1'b0, wordtemp[85],
          1'b0, wordtemp[84], 1'b0, wordtemp[83], 1'b0, wordtemp[82], 1'b0, wordtemp[81],
          1'b0, wordtemp[80], 1'b0, wordtemp[79], 1'b0, wordtemp[78], 1'b0, wordtemp[77],
          1'b0, wordtemp[76], 1'b0, wordtemp[75], 1'b0, wordtemp[74], 1'b0, wordtemp[73],
          1'b0, wordtemp[72], 1'b0, wordtemp[71], 1'b0, wordtemp[70], 1'b0, wordtemp[69],
          1'b0, wordtemp[68], 1'b0, wordtemp[67], 1'b0, wordtemp[66], 1'b0, wordtemp[65],
          1'b0, wordtemp[64], 1'b0, wordtemp[63], 1'b0, wordtemp[62], 1'b0, wordtemp[61],
          1'b0, wordtemp[60], 1'b0, wordtemp[59], 1'b0, wordtemp[58], 1'b0, wordtemp[57],
          1'b0, wordtemp[56], 1'b0, wordtemp[55], 1'b0, wordtemp[54], 1'b0, wordtemp[53],
          1'b0, wordtemp[52], 1'b0, wordtemp[51], 1'b0, wordtemp[50], 1'b0, wordtemp[49],
          1'b0, wordtemp[48], 1'b0, wordtemp[47], 1'b0, wordtemp[46], 1'b0, wordtemp[45],
          1'b0, wordtemp[44], 1'b0, wordtemp[43], 1'b0, wordtemp[42], 1'b0, wordtemp[41],
          1'b0, wordtemp[40], 1'b0, wordtemp[39], 1'b0, wordtemp[38], 1'b0, wordtemp[37],
          1'b0, wordtemp[36], 1'b0, wordtemp[35], 1'b0, wordtemp[34], 1'b0, wordtemp[33],
          1'b0, wordtemp[32], 1'b0, wordtemp[31], 1'b0, wordtemp[30], 1'b0, wordtemp[29],
          1'b0, wordtemp[28], 1'b0, wordtemp[27], 1'b0, wordtemp[26], 1'b0, wordtemp[25],
          1'b0, wordtemp[24], 1'b0, wordtemp[23], 1'b0, wordtemp[22], 1'b0, wordtemp[21],
          1'b0, wordtemp[20], 1'b0, wordtemp[19], 1'b0, wordtemp[18], 1'b0, wordtemp[17],
          1'b0, wordtemp[16], 1'b0, wordtemp[15], 1'b0, wordtemp[14], 1'b0, wordtemp[13],
          1'b0, wordtemp[12], 1'b0, wordtemp[11], 1'b0, wordtemp[10], 1'b0, wordtemp[9],
          1'b0, wordtemp[8], 1'b0, wordtemp[7], 1'b0, wordtemp[6], 1'b0, wordtemp[5],
          1'b0, wordtemp[4], 1'b0, wordtemp[3], 1'b0, wordtemp[2], 1'b0, wordtemp[1],
          1'b0, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [127:0] dump_data;
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
        writeEnable = {128{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[254], data_out[252], data_out[250], data_out[248], data_out[246],
          data_out[244], data_out[242], data_out[240], data_out[238], data_out[236],
          data_out[234], data_out[232], data_out[230], data_out[228], data_out[226],
          data_out[224], data_out[222], data_out[220], data_out[218], data_out[216],
          data_out[214], data_out[212], data_out[210], data_out[208], data_out[206],
          data_out[204], data_out[202], data_out[200], data_out[198], data_out[196],
          data_out[194], data_out[192], data_out[190], data_out[188], data_out[186],
          data_out[184], data_out[182], data_out[180], data_out[178], data_out[176],
          data_out[174], data_out[172], data_out[170], data_out[168], data_out[166],
          data_out[164], data_out[162], data_out[160], data_out[158], data_out[156],
          data_out[154], data_out[152], data_out[150], data_out[148], data_out[146],
          data_out[144], data_out[142], data_out[140], data_out[138], data_out[136],
          data_out[134], data_out[132], data_out[130], data_out[128], data_out[126],
          data_out[124], data_out[122], data_out[120], data_out[118], data_out[116],
          data_out[114], data_out[112], data_out[110], data_out[108], data_out[106],
          data_out[104], data_out[102], data_out[100], data_out[98], data_out[96],
          data_out[94], data_out[92], data_out[90], data_out[88], data_out[86], data_out[84],
          data_out[82], data_out[80], data_out[78], data_out[76], data_out[74], data_out[72],
          data_out[70], data_out[68], data_out[66], data_out[64], data_out[62], data_out[60],
          data_out[58], data_out[56], data_out[54], data_out[52], data_out[50], data_out[48],
          data_out[46], data_out[44], data_out[42], data_out[40], data_out[38], data_out[36],
          data_out[34], data_out[32], data_out[30], data_out[28], data_out[26], data_out[24],
          data_out[22], data_out[20], data_out[18], data_out[16], data_out[14], data_out[12],
          data_out[10], data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[127], shifted_readLatch0[126], shifted_readLatch0[125],
          shifted_readLatch0[124], shifted_readLatch0[123], shifted_readLatch0[122],
          shifted_readLatch0[121], shifted_readLatch0[120], shifted_readLatch0[119],
          shifted_readLatch0[118], shifted_readLatch0[117], shifted_readLatch0[116],
          shifted_readLatch0[115], shifted_readLatch0[114], shifted_readLatch0[113],
          shifted_readLatch0[112], shifted_readLatch0[111], shifted_readLatch0[110],
          shifted_readLatch0[109], shifted_readLatch0[108], shifted_readLatch0[107],
          shifted_readLatch0[106], shifted_readLatch0[105], shifted_readLatch0[104],
          shifted_readLatch0[103], shifted_readLatch0[102], shifted_readLatch0[101],
          shifted_readLatch0[100], shifted_readLatch0[99], shifted_readLatch0[98],
          shifted_readLatch0[97], shifted_readLatch0[96], shifted_readLatch0[95], shifted_readLatch0[94],
          shifted_readLatch0[93], shifted_readLatch0[92], shifted_readLatch0[91], shifted_readLatch0[90],
          shifted_readLatch0[89], shifted_readLatch0[88], shifted_readLatch0[87], shifted_readLatch0[86],
          shifted_readLatch0[85], shifted_readLatch0[84], shifted_readLatch0[83], shifted_readLatch0[82],
          shifted_readLatch0[81], shifted_readLatch0[80], shifted_readLatch0[79], shifted_readLatch0[78],
          shifted_readLatch0[77], shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74],
          shifted_readLatch0[73], shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70],
          shifted_readLatch0[69], shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66],
          shifted_readLatch0[65], shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62],
          shifted_readLatch0[61], shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58],
          shifted_readLatch0[57], shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54],
          shifted_readLatch0[53], shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50],
          shifted_readLatch0[49], shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46],
          shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42],
          shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38],
          shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34],
          shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30],
          shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26],
          shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22],
          shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18],
          shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14],
          shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10],
          shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6],
          shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2],
          shifted_readLatch0[1], shifted_readLatch0[0]};
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
      d_int = {128{1'bx}};
    if (^rawlm_ === 1'bx)
      d_int = {128{1'bx}};
    if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_int === 1'b0 && cen_int === 1'b0) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{cen_int, ema_int, emaw_int, emas_int, ret1n_int, wabl_int, wablm_int, rawl_int, rawlm_int} === 1'bx) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if ((a_int >= WORDS) && (cen_int === 1'b0)) begin
      q_int = wen_int !== 1'b1 ? q_int : {128{1'bx}};
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
     if (wen_int !== 1)
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (cen_int === 1'b0) begin
      mux_address = (a_int & 1'b1);
      row_address = (a_int >> 1);
      if (row_address > 63)
        row = {256{1'bx}};
      else
        row = mem[row_address];
        writeEnable = ~ {128{wen_int}};
      if (wen_int !== 1'b1) begin
        row_mask =  ( {1'b0, writeEnable[127], 1'b0, writeEnable[126], 1'b0, writeEnable[125],
          1'b0, writeEnable[124], 1'b0, writeEnable[123], 1'b0, writeEnable[122], 1'b0, writeEnable[121],
          1'b0, writeEnable[120], 1'b0, writeEnable[119], 1'b0, writeEnable[118], 1'b0, writeEnable[117],
          1'b0, writeEnable[116], 1'b0, writeEnable[115], 1'b0, writeEnable[114], 1'b0, writeEnable[113],
          1'b0, writeEnable[112], 1'b0, writeEnable[111], 1'b0, writeEnable[110], 1'b0, writeEnable[109],
          1'b0, writeEnable[108], 1'b0, writeEnable[107], 1'b0, writeEnable[106], 1'b0, writeEnable[105],
          1'b0, writeEnable[104], 1'b0, writeEnable[103], 1'b0, writeEnable[102], 1'b0, writeEnable[101],
          1'b0, writeEnable[100], 1'b0, writeEnable[99], 1'b0, writeEnable[98], 1'b0, writeEnable[97],
          1'b0, writeEnable[96], 1'b0, writeEnable[95], 1'b0, writeEnable[94], 1'b0, writeEnable[93],
          1'b0, writeEnable[92], 1'b0, writeEnable[91], 1'b0, writeEnable[90], 1'b0, writeEnable[89],
          1'b0, writeEnable[88], 1'b0, writeEnable[87], 1'b0, writeEnable[86], 1'b0, writeEnable[85],
          1'b0, writeEnable[84], 1'b0, writeEnable[83], 1'b0, writeEnable[82], 1'b0, writeEnable[81],
          1'b0, writeEnable[80], 1'b0, writeEnable[79], 1'b0, writeEnable[78], 1'b0, writeEnable[77],
          1'b0, writeEnable[76], 1'b0, writeEnable[75], 1'b0, writeEnable[74], 1'b0, writeEnable[73],
          1'b0, writeEnable[72], 1'b0, writeEnable[71], 1'b0, writeEnable[70], 1'b0, writeEnable[69],
          1'b0, writeEnable[68], 1'b0, writeEnable[67], 1'b0, writeEnable[66], 1'b0, writeEnable[65],
          1'b0, writeEnable[64], 1'b0, writeEnable[63], 1'b0, writeEnable[62], 1'b0, writeEnable[61],
          1'b0, writeEnable[60], 1'b0, writeEnable[59], 1'b0, writeEnable[58], 1'b0, writeEnable[57],
          1'b0, writeEnable[56], 1'b0, writeEnable[55], 1'b0, writeEnable[54], 1'b0, writeEnable[53],
          1'b0, writeEnable[52], 1'b0, writeEnable[51], 1'b0, writeEnable[50], 1'b0, writeEnable[49],
          1'b0, writeEnable[48], 1'b0, writeEnable[47], 1'b0, writeEnable[46], 1'b0, writeEnable[45],
          1'b0, writeEnable[44], 1'b0, writeEnable[43], 1'b0, writeEnable[42], 1'b0, writeEnable[41],
          1'b0, writeEnable[40], 1'b0, writeEnable[39], 1'b0, writeEnable[38], 1'b0, writeEnable[37],
          1'b0, writeEnable[36], 1'b0, writeEnable[35], 1'b0, writeEnable[34], 1'b0, writeEnable[33],
          1'b0, writeEnable[32], 1'b0, writeEnable[31], 1'b0, writeEnable[30], 1'b0, writeEnable[29],
          1'b0, writeEnable[28], 1'b0, writeEnable[27], 1'b0, writeEnable[26], 1'b0, writeEnable[25],
          1'b0, writeEnable[24], 1'b0, writeEnable[23], 1'b0, writeEnable[22], 1'b0, writeEnable[21],
          1'b0, writeEnable[20], 1'b0, writeEnable[19], 1'b0, writeEnable[18], 1'b0, writeEnable[17],
          1'b0, writeEnable[16], 1'b0, writeEnable[15], 1'b0, writeEnable[14], 1'b0, writeEnable[13],
          1'b0, writeEnable[12], 1'b0, writeEnable[11], 1'b0, writeEnable[10], 1'b0, writeEnable[9],
          1'b0, writeEnable[8], 1'b0, writeEnable[7], 1'b0, writeEnable[6], 1'b0, writeEnable[5],
          1'b0, writeEnable[4], 1'b0, writeEnable[3], 1'b0, writeEnable[2], 1'b0, writeEnable[1],
          1'b0, writeEnable[0]} << mux_address);
        new_data =  ( {1'b0, d_int[127], 1'b0, d_int[126], 1'b0, d_int[125], 1'b0, d_int[124],
          1'b0, d_int[123], 1'b0, d_int[122], 1'b0, d_int[121], 1'b0, d_int[120], 1'b0, d_int[119],
          1'b0, d_int[118], 1'b0, d_int[117], 1'b0, d_int[116], 1'b0, d_int[115], 1'b0, d_int[114],
          1'b0, d_int[113], 1'b0, d_int[112], 1'b0, d_int[111], 1'b0, d_int[110], 1'b0, d_int[109],
          1'b0, d_int[108], 1'b0, d_int[107], 1'b0, d_int[106], 1'b0, d_int[105], 1'b0, d_int[104],
          1'b0, d_int[103], 1'b0, d_int[102], 1'b0, d_int[101], 1'b0, d_int[100], 1'b0, d_int[99],
          1'b0, d_int[98], 1'b0, d_int[97], 1'b0, d_int[96], 1'b0, d_int[95], 1'b0, d_int[94],
          1'b0, d_int[93], 1'b0, d_int[92], 1'b0, d_int[91], 1'b0, d_int[90], 1'b0, d_int[89],
          1'b0, d_int[88], 1'b0, d_int[87], 1'b0, d_int[86], 1'b0, d_int[85], 1'b0, d_int[84],
          1'b0, d_int[83], 1'b0, d_int[82], 1'b0, d_int[81], 1'b0, d_int[80], 1'b0, d_int[79],
          1'b0, d_int[78], 1'b0, d_int[77], 1'b0, d_int[76], 1'b0, d_int[75], 1'b0, d_int[74],
          1'b0, d_int[73], 1'b0, d_int[72], 1'b0, d_int[71], 1'b0, d_int[70], 1'b0, d_int[69],
          1'b0, d_int[68], 1'b0, d_int[67], 1'b0, d_int[66], 1'b0, d_int[65], 1'b0, d_int[64],
          1'b0, d_int[63], 1'b0, d_int[62], 1'b0, d_int[61], 1'b0, d_int[60], 1'b0, d_int[59],
          1'b0, d_int[58], 1'b0, d_int[57], 1'b0, d_int[56], 1'b0, d_int[55], 1'b0, d_int[54],
          1'b0, d_int[53], 1'b0, d_int[52], 1'b0, d_int[51], 1'b0, d_int[50], 1'b0, d_int[49],
          1'b0, d_int[48], 1'b0, d_int[47], 1'b0, d_int[46], 1'b0, d_int[45], 1'b0, d_int[44],
          1'b0, d_int[43], 1'b0, d_int[42], 1'b0, d_int[41], 1'b0, d_int[40], 1'b0, d_int[39],
          1'b0, d_int[38], 1'b0, d_int[37], 1'b0, d_int[36], 1'b0, d_int[35], 1'b0, d_int[34],
          1'b0, d_int[33], 1'b0, d_int[32], 1'b0, d_int[31], 1'b0, d_int[30], 1'b0, d_int[29],
          1'b0, d_int[28], 1'b0, d_int[27], 1'b0, d_int[26], 1'b0, d_int[25], 1'b0, d_int[24],
          1'b0, d_int[23], 1'b0, d_int[22], 1'b0, d_int[21], 1'b0, d_int[20], 1'b0, d_int[19],
          1'b0, d_int[18], 1'b0, d_int[17], 1'b0, d_int[16], 1'b0, d_int[15], 1'b0, d_int[14],
          1'b0, d_int[13], 1'b0, d_int[12], 1'b0, d_int[11], 1'b0, d_int[10], 1'b0, d_int[9],
          1'b0, d_int[8], 1'b0, d_int[7], 1'b0, d_int[6], 1'b0, d_int[5], 1'b0, d_int[4],
          1'b0, d_int[3], 1'b0, d_int[2], 1'b0, d_int[1], 1'b0, d_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
      end else begin
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[254], data_out[252], data_out[250], data_out[248], data_out[246],
          data_out[244], data_out[242], data_out[240], data_out[238], data_out[236],
          data_out[234], data_out[232], data_out[230], data_out[228], data_out[226],
          data_out[224], data_out[222], data_out[220], data_out[218], data_out[216],
          data_out[214], data_out[212], data_out[210], data_out[208], data_out[206],
          data_out[204], data_out[202], data_out[200], data_out[198], data_out[196],
          data_out[194], data_out[192], data_out[190], data_out[188], data_out[186],
          data_out[184], data_out[182], data_out[180], data_out[178], data_out[176],
          data_out[174], data_out[172], data_out[170], data_out[168], data_out[166],
          data_out[164], data_out[162], data_out[160], data_out[158], data_out[156],
          data_out[154], data_out[152], data_out[150], data_out[148], data_out[146],
          data_out[144], data_out[142], data_out[140], data_out[138], data_out[136],
          data_out[134], data_out[132], data_out[130], data_out[128], data_out[126],
          data_out[124], data_out[122], data_out[120], data_out[118], data_out[116],
          data_out[114], data_out[112], data_out[110], data_out[108], data_out[106],
          data_out[104], data_out[102], data_out[100], data_out[98], data_out[96],
          data_out[94], data_out[92], data_out[90], data_out[88], data_out[86], data_out[84],
          data_out[82], data_out[80], data_out[78], data_out[76], data_out[74], data_out[72],
          data_out[70], data_out[68], data_out[66], data_out[64], data_out[62], data_out[60],
          data_out[58], data_out[56], data_out[54], data_out[52], data_out[50], data_out[48],
          data_out[46], data_out[44], data_out[42], data_out[40], data_out[38], data_out[36],
          data_out[34], data_out[32], data_out[30], data_out[28], data_out[26], data_out[24],
          data_out[22], data_out[20], data_out[18], data_out[16], data_out[14], data_out[12],
          data_out[10], data_out[8], data_out[6], data_out[4], data_out[2], data_out[0]};
        shifted_readLatch0 = readLatch0;
        q_int = {shifted_readLatch0[127], shifted_readLatch0[126], shifted_readLatch0[125],
          shifted_readLatch0[124], shifted_readLatch0[123], shifted_readLatch0[122],
          shifted_readLatch0[121], shifted_readLatch0[120], shifted_readLatch0[119],
          shifted_readLatch0[118], shifted_readLatch0[117], shifted_readLatch0[116],
          shifted_readLatch0[115], shifted_readLatch0[114], shifted_readLatch0[113],
          shifted_readLatch0[112], shifted_readLatch0[111], shifted_readLatch0[110],
          shifted_readLatch0[109], shifted_readLatch0[108], shifted_readLatch0[107],
          shifted_readLatch0[106], shifted_readLatch0[105], shifted_readLatch0[104],
          shifted_readLatch0[103], shifted_readLatch0[102], shifted_readLatch0[101],
          shifted_readLatch0[100], shifted_readLatch0[99], shifted_readLatch0[98],
          shifted_readLatch0[97], shifted_readLatch0[96], shifted_readLatch0[95], shifted_readLatch0[94],
          shifted_readLatch0[93], shifted_readLatch0[92], shifted_readLatch0[91], shifted_readLatch0[90],
          shifted_readLatch0[89], shifted_readLatch0[88], shifted_readLatch0[87], shifted_readLatch0[86],
          shifted_readLatch0[85], shifted_readLatch0[84], shifted_readLatch0[83], shifted_readLatch0[82],
          shifted_readLatch0[81], shifted_readLatch0[80], shifted_readLatch0[79], shifted_readLatch0[78],
          shifted_readLatch0[77], shifted_readLatch0[76], shifted_readLatch0[75], shifted_readLatch0[74],
          shifted_readLatch0[73], shifted_readLatch0[72], shifted_readLatch0[71], shifted_readLatch0[70],
          shifted_readLatch0[69], shifted_readLatch0[68], shifted_readLatch0[67], shifted_readLatch0[66],
          shifted_readLatch0[65], shifted_readLatch0[64], shifted_readLatch0[63], shifted_readLatch0[62],
          shifted_readLatch0[61], shifted_readLatch0[60], shifted_readLatch0[59], shifted_readLatch0[58],
          shifted_readLatch0[57], shifted_readLatch0[56], shifted_readLatch0[55], shifted_readLatch0[54],
          shifted_readLatch0[53], shifted_readLatch0[52], shifted_readLatch0[51], shifted_readLatch0[50],
          shifted_readLatch0[49], shifted_readLatch0[48], shifted_readLatch0[47], shifted_readLatch0[46],
          shifted_readLatch0[45], shifted_readLatch0[44], shifted_readLatch0[43], shifted_readLatch0[42],
          shifted_readLatch0[41], shifted_readLatch0[40], shifted_readLatch0[39], shifted_readLatch0[38],
          shifted_readLatch0[37], shifted_readLatch0[36], shifted_readLatch0[35], shifted_readLatch0[34],
          shifted_readLatch0[33], shifted_readLatch0[32], shifted_readLatch0[31], shifted_readLatch0[30],
          shifted_readLatch0[29], shifted_readLatch0[28], shifted_readLatch0[27], shifted_readLatch0[26],
          shifted_readLatch0[25], shifted_readLatch0[24], shifted_readLatch0[23], shifted_readLatch0[22],
          shifted_readLatch0[21], shifted_readLatch0[20], shifted_readLatch0[19], shifted_readLatch0[18],
          shifted_readLatch0[17], shifted_readLatch0[16], shifted_readLatch0[15], shifted_readLatch0[14],
          shifted_readLatch0[13], shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10],
          shifted_readLatch0[9], shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6],
          shifted_readLatch0[5], shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2],
          shifted_readLatch0[1], shifted_readLatch0[0]};
      end
    if (rawl_ === 1'bx)
        q_int = {128{1'bx}};
    if (^rawlm_ === 1'bx)
        q_int = {128{1'bx}};
      if( isBitX(wen_int) ) begin
        q_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {128{1'bx}};
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && cen_p2 === 1'b0 ) begin
      failedWrite(0);
        q_int = {128{1'bx}};
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
      q_int = {128{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
      cen_int = 1'bx;
      wen_int = 1'bx;
      a_int = {7{1'bx}};
      d_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
      failedWrite(0);
    end else if (cen_int === 1'b0 && (^a_int) === 1'bx) begin
        failedWrite(0);
        q_int = {128{1'bx}};
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
        q_int = {128{1'bx}};
			failedWrite(0);
			bad_VDDCE = 1'b1;
		end else begin
			bad_VDDCE = 1'b0;
		end
		if (VDDPE !== 1'b1) begin
			$display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
        q_int = {128{1'bx}};
		if (ret1n_ !== 1'b0)
			failedWrite(0);
			bad_VDDPE = 1'b1;
		end else begin
			bad_VDDPE = 1'b0;
		end
		if (VSSE !== 1'b0) begin
			$display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
        q_int = {128{1'bx}};
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
  always @ NOT_d127 begin
    d_int[127] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d126 begin
    d_int[126] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d125 begin
    d_int[125] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d124 begin
    d_int[124] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d123 begin
    d_int[123] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d122 begin
    d_int[122] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d121 begin
    d_int[121] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d120 begin
    d_int[120] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d119 begin
    d_int[119] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d118 begin
    d_int[118] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d117 begin
    d_int[117] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d116 begin
    d_int[116] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d115 begin
    d_int[115] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d114 begin
    d_int[114] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d113 begin
    d_int[113] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d112 begin
    d_int[112] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d111 begin
    d_int[111] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d110 begin
    d_int[110] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d109 begin
    d_int[109] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d108 begin
    d_int[108] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d107 begin
    d_int[107] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d106 begin
    d_int[106] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d105 begin
    d_int[105] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d104 begin
    d_int[104] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d103 begin
    d_int[103] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d102 begin
    d_int[102] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d101 begin
    d_int[101] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d100 begin
    d_int[100] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d99 begin
    d_int[99] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d98 begin
    d_int[98] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d97 begin
    d_int[97] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d96 begin
    d_int[96] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d95 begin
    d_int[95] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d94 begin
    d_int[94] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d93 begin
    d_int[93] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d92 begin
    d_int[92] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d91 begin
    d_int[91] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d90 begin
    d_int[90] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d89 begin
    d_int[89] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d88 begin
    d_int[88] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d87 begin
    d_int[87] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d86 begin
    d_int[86] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d85 begin
    d_int[85] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d84 begin
    d_int[84] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d83 begin
    d_int[83] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d82 begin
    d_int[82] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d81 begin
    d_int[81] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d80 begin
    d_int[80] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d79 begin
    d_int[79] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d78 begin
    d_int[78] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d77 begin
    d_int[77] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d76 begin
    d_int[76] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d75 begin
    d_int[75] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d74 begin
    d_int[74] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d73 begin
    d_int[73] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d72 begin
    d_int[72] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d71 begin
    d_int[71] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d70 begin
    d_int[70] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d69 begin
    d_int[69] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d68 begin
    d_int[68] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d67 begin
    d_int[67] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d66 begin
    d_int[66] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d65 begin
    d_int[65] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_d64 begin
    d_int[64] = 1'bx;
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b0 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b0 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b0)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
       (posedge clk => (q[127] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[126] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[125] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[124] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[123] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[122] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[121] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[120] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[119] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[118] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[117] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[116] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[115] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[114] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[113] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[112] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[111] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[110] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[109] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[108] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[107] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[106] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[105] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[104] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[103] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[102] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[101] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[100] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[99] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[98] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[97] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[96] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[95] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[94] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[93] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[92] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[91] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[90] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[89] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[88] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[87] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[86] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[85] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[84] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[83] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[82] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[81] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[80] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[79] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[78] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[77] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[76] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[75] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[74] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[73] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[72] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[71] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[70] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[69] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[68] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[67] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[66] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[65] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[64] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[63] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[62] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[61] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[60] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[59] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[58] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[57] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[56] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[55] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[54] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[53] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[52] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[51] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[50] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[49] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[48] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[47] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && cen == 1'b0 && wen == 1'b1 && ema[2] == 1'b1 && ema[1] == 1'b1 && ema[0] == 1'b1)
       (posedge clk => (q[46] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
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
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[127], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d127);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[126], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d126);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[125], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d125);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[124], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d124);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[123], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d123);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[122], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d122);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[121], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d121);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[120], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d120);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[119], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d119);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[118], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d118);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[117], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d117);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[116], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d116);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[115], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d115);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[114], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d114);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[113], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d113);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[112], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d112);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[111], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d111);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[110], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d110);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[109], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d109);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[108], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d108);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[107], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d107);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[106], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d106);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[105], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d105);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[104], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d104);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[103], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d103);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[102], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d102);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[101], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d101);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[100], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d100);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[99], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d99);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[98], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d98);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[97], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d97);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[96], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d96);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[95], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d95);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[94], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d94);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[93], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d93);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[92], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d92);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[91], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d91);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[90], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d90);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[89], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d89);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[88], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d88);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[87], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d87);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[86], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d86);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[85], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d85);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[84], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d84);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[83], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d83);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[82], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d82);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[81], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d81);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[80], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d80);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[79], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d79);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[78], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d78);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[77], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d77);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[76], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d76);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[75], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d75);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[74], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d74);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[73], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d73);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[72], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d72);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[71], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d71);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[70], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d70);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[69], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d69);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[68], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d68);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[67], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d67);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[66], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d66);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[65], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d65);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[64], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d64);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[63], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d63);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[62], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d62);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[61], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d61);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[60], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d60);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[59], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d59);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[58], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d58);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[57], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d57);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[56], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d56);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[55], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d55);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[54], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d54);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[53], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d53);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[52], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d52);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[51], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d51);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[50], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d50);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[49], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d49);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[48], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d48);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[47], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d47);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, posedge d[46], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d46);
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
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[127], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d127);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[126], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d126);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[125], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d125);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[124], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d124);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[123], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d123);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[122], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d122);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[121], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d121);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[120], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d120);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[119], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d119);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[118], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d118);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[117], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d117);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[116], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d116);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[115], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d115);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[114], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d114);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[113], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d113);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[112], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d112);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[111], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d111);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[110], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d110);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[109], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d109);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[108], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d108);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[107], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d107);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[106], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d106);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[105], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d105);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[104], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d104);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[103], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d103);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[102], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d102);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[101], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d101);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[100], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d100);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[99], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d99);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[98], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d98);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[97], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d97);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[96], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d96);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[95], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d95);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[94], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d94);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[93], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d93);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[92], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d92);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[91], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d91);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[90], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d90);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[89], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d89);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[88], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d88);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[87], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d87);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[86], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d86);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[85], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d85);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[84], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d84);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[83], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d83);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[82], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d82);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[81], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d81);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[80], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d80);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[79], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d79);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[78], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d78);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[77], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d77);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[76], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d76);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[75], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d75);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[74], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d74);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[73], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d73);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[72], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d72);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[71], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d71);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[70], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d70);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[69], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d69);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[68], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d68);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[67], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d67);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[66], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d66);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[65], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d65);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[64], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d64);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[63], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d63);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[62], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d62);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[61], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d61);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[60], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d60);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[59], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d59);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[58], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d58);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[57], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d57);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[56], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d56);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[55], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d55);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[54], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d54);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[53], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d53);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[52], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d52);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[51], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d51);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[50], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d50);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[49], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d49);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[48], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d48);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[47], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d47);
    $setuphold(posedge clk &&& ret1neq1aceneq0aweneq0, negedge d[46], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_d46);
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
module sram128x128_error_injection (Q_out, Q_in, CLK, A, CEN, WEN);
   output [127:0] Q_out;
   input [127:0] Q_in;
   input CLK;
   input [6:0] A;
   input CEN;
   input WEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [127:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [18:0] fault_table [63:0];
   reg [18:0] fault_entry;
initial
begin
   `ifdef sram128x128_pre_pend_path
      `define pre_pend_path `sram128x128_pre_pend_path
   `else
      `ifdef DUT
         `define pre_pend_path TB.DUT_inst.CHIP.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST
      `else
          `define pre_pend_path TB.CHIP.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST
      `endif
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.u1.add_fault(7'd2,7'd70,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [6:0] address;
      input [6:0] bitPlace;
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
            fault_entry[11:5] = bitPlace;
            fault_entry[18:12] = address;
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
   inout [127:0] q_int;
   input [1:0] fault_type;
   input [6:0] bitLoc;
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
   output [127:0] Q_output;
   reg list_complete;
   integer i;
   reg [5:0] row_address;
   reg [0:0] column_address;
   reg [6:0] bitPlace;
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
      i = i + 1;
      if (valid == 1'b1)
      begin
         if (red_fault === NO_RED_FAULT)
         begin
            if (row_address == A[6:1] && column_address == A[0:0])
            begin
               if (bitPlace < 64)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 64 )
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
