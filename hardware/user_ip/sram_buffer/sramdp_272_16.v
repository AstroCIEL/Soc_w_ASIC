/* verilog_memcomp Version: c0.4.19-EAC */
/* common_memcomp Version: c0.4.19-EAC */
/* lang compiler Version: 4.14.4-EAC Mar 31 2020 06:59:59 */
//
//       CONFIDENTIAL AND PROPRIETARY SOFTWARE OF ARM PHYSICAL IP, INC.
//      
//       Copyright (c) 1993 - 2026 ARM Physical IP, Inc.  All Rights Reserved.
//      
//       Use of this Software is subject to the terms and conditions of the
//       applicable license agreement with ARM Physical IP, Inc.
//       In addition, this Software is protected by patents, copyright law 
//       and international treaties.
//      
//       The copyright notice(s) in this Software does not indicate actual or
//       intended publication of this Software.
//
//      Verilog model for High Density Dual Port SRAM SVT SVT Compiler
//
//       Instance Name:              sramdp_272_16
//       Words:                      272
//       Bits:                       16
//       Mux:                        4
//       Drive:                      6
//       Write Mask:                 Off
//       Write Thru:                 Off
//       Extra Margin Adjustment:    On
//       Test Muxes                  On
//       Power Gating:               Off
//       Retention:                  On
//       Pipeline:                   Off
//       Read Disturb Test:	        Off
//       
//       Creation Date:  Fri May 22 21:36:31 2026
//       Version: 	r0p1
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

module datapath_latch_sramdp_272_16 (CLK,Q_update,D_update,SE,SI,D,DFTRAMBYP,mem_path,XQ,Q);
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
      #0;
      if (XQ===1'b0) begin
         if (DFTRAMBYP===1'b1)
           Q=D_int;
         else
           Q=mem_path;
      end
      else
        Q=1'bx;
   end
endmodule // datapath_latch_sramdp_272_16

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
module sramdp_272_16 (VDDCE, VDDPE, VSSE, cenya, wenya, aya, cenyb, wenyb, ayb, qa,
    qb, soa, sob, clka, cena, wena, aa, da, clkb, cenb, wenb, ab, db, emaa, emawa,
    emasa, emab, emawb, emasb, tena, tcena, twena, taa, tda, tenb, tcenb, twenb, tab,
    tdb, ret1n, sia, sea, dftrambyp, sib, seb, colldisn);
`else
module sramdp_272_16 (cenya, wenya, aya, cenyb, wenyb, ayb, qa, qb, soa, sob, clka,
    cena, wena, aa, da, clkb, cenb, wenb, ab, db, emaa, emawa, emasa, emab, emawb,
    emasb, tena, tcena, twena, taa, tda, tenb, tcenb, twenb, tab, tdb, ret1n, sia,
    sea, dftrambyp, sib, seb, colldisn);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 16;
  parameter WORDS = 272;
  parameter MUX = 4;
  parameter MEM_WIDTH = 64; // redun block size 4, 32 on left, 32 on right
  parameter MEM_HEIGHT = 68;
  parameter WP_SIZE = 16 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

`ifdef ARM_DISABLE_EMA_CHECK
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 1;
`else
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 0;
`endif

  parameter ARM_REF_EMAA_VALUE = 2**UPM_WIDTH-1;
  parameter ARM_REF_EMAWA_VALUE = 2**UPMW_WIDTH-1;
  parameter ARM_REF_EMASA_VALUE = 2**UPMS_WIDTH-1;
  parameter ARM_REF_EMAB_VALUE = 2**UPM_WIDTH-1;
  parameter ARM_REF_EMAWB_VALUE = 2**UPMW_WIDTH-1;
  parameter ARM_REF_EMASB_VALUE = 2**UPMS_WIDTH-1;

  output  cenya;
  output  wenya;
  output [8:0] aya;
  output  cenyb;
  output  wenyb;
  output [8:0] ayb;
  output [15:0] qa;
  output [15:0] qb;
  output [1:0] soa;
  output [1:0] sob;
  input  clka;
  input  cena;
  input  wena;
  input [8:0] aa;
  input [15:0] da;
  input  clkb;
  input  cenb;
  input  wenb;
  input [8:0] ab;
  input [15:0] db;
  input [2:0] emaa;
  input [1:0] emawa;
  input  emasa;
  input [2:0] emab;
  input [1:0] emawb;
  input  emasb;
  input  tena;
  input  tcena;
  input  twena;
  input [8:0] taa;
  input [15:0] tda;
  input  tenb;
  input  tcenb;
  input  twenb;
  input [8:0] tab;
  input [15:0] tdb;
  input  ret1n;
  input [1:0] sia;
  input  sea;
  input  dftrambyp;
  input [1:0] sib;
  input  seb;
  input  colldisn;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  reg pre_charge_st;
  reg pre_charge_st_a;
  reg pre_charge_st_b;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [63:0] mem [0:67];
  reg [63:0] row, row_t;
  reg LAST_clka;
  reg [63:0] row_mask;
  reg [63:0] new_data;
  reg [63:0] data_out;
  reg [15:0] readLatch0;
  reg [15:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [15:0] readLatch1;
  reg [15:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_clkb;
  wire [15:0] qa_int;
  reg Xqa, qa_update;
  reg Xda_sh, da_sh_update;
  wire [15:0] da_int_bmux;
  reg [15:0] mem_path_A;
  wire [15:0] qb_int;
  reg Xqb, qb_update;
  reg Xdb_sh, db_sh_update;
  wire [15:0] db_int_bmux;
  reg [15:0] mem_path_B;
  reg [15:0] writeEnable;
  real previous_clka;
  real previous_clkb;
  initial previous_clka = 0;
  initial previous_clkb = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;
  reg clk0_int;
  reg clk1_int;

  wire  cenya_;
  wire  wenya_;
  wire [8:0] aya_;
  wire  cenyb_;
  wire  wenyb_;
  wire [8:0] ayb_;
  wire [15:0] qa_;
  wire [15:0] qb_;
  wire [1:0] soa_;
  wire [1:0] sob_;
 wire  clka_;
  wire  cena_;
  reg  cena_int;
  reg  cena_p2;
  wire  wena_;
  reg  wena_int;
  wire [8:0] aa_;
  reg [8:0] aa_int;
  wire [15:0] da_;
  reg [15:0] da_int;
 wire  clkb_;
  wire  cenb_;
  reg  cenb_int;
  reg  cenb_p2;
  wire  wenb_;
  reg  wenb_int;
  wire [8:0] ab_;
  reg [8:0] ab_int;
  wire [15:0] db_;
  reg [15:0] db_int;
  wire [2:0] emaa_;
  reg [2:0] emaa_int;
  wire [1:0] emawa_;
  reg [1:0] emawa_int;
  wire  emasa_;
  reg  emasa_int;
  wire [2:0] emab_;
  reg [2:0] emab_int;
  wire [1:0] emawb_;
  reg [1:0] emawb_int;
  wire  emasb_;
  reg  emasb_int;
  wire  tena_;
  reg  tena_int;
  wire  tcena_;
  reg  tcena_int;
  reg  tcena_p2;
  wire  twena_;
  reg  twena_int;
  wire [8:0] taa_;
  reg [8:0] taa_int;
  wire [15:0] tda_;
  reg [15:0] tda_int;
  wire  tenb_;
  reg  tenb_int;
  wire  tcenb_;
  reg  tcenb_int;
  reg  tcenb_p2;
  wire  twenb_;
  reg  twenb_int;
  wire [8:0] tab_;
  reg [8:0] tab_int;
  wire [15:0] tdb_;
  reg [15:0] tdb_int;
  wire  ret1n_;
  reg  ret1n_int;
  wire [1:0] sia_;
  wire [1:0] sia_int;
  wire  sea_;
  reg  sea_int;
  wire  dftrambyp_;
  reg  dftrambyp_int;
  reg  dftrambyp_p2;
  wire [1:0] sib_;
  wire [1:0] sib_int;
  wire  seb_;
  reg  seb_int;
  wire  colldisn_;
  reg  colldisn_int;

  assign cenya = cenya_; 
  assign wenya = wenya_; 
  assign aya[0] = aya_[0]; 
  assign aya[1] = aya_[1]; 
  assign aya[2] = aya_[2]; 
  assign aya[3] = aya_[3]; 
  assign aya[4] = aya_[4]; 
  assign aya[5] = aya_[5]; 
  assign aya[6] = aya_[6]; 
  assign aya[7] = aya_[7]; 
  assign aya[8] = aya_[8]; 
  assign cenyb = cenyb_; 
  assign wenyb = wenyb_; 
  assign ayb[0] = ayb_[0]; 
  assign ayb[1] = ayb_[1]; 
  assign ayb[2] = ayb_[2]; 
  assign ayb[3] = ayb_[3]; 
  assign ayb[4] = ayb_[4]; 
  assign ayb[5] = ayb_[5]; 
  assign ayb[6] = ayb_[6]; 
  assign ayb[7] = ayb_[7]; 
  assign ayb[8] = ayb_[8]; 
  assign qa[0] = qa_[0]; 
  assign qa[1] = qa_[1]; 
  assign qa[2] = qa_[2]; 
  assign qa[3] = qa_[3]; 
  assign qa[4] = qa_[4]; 
  assign qa[5] = qa_[5]; 
  assign qa[6] = qa_[6]; 
  assign qa[7] = qa_[7]; 
  assign qa[8] = qa_[8]; 
  assign qa[9] = qa_[9]; 
  assign qa[10] = qa_[10]; 
  assign qa[11] = qa_[11]; 
  assign qa[12] = qa_[12]; 
  assign qa[13] = qa_[13]; 
  assign qa[14] = qa_[14]; 
  assign qa[15] = qa_[15]; 
  assign qb[0] = qb_[0]; 
  assign qb[1] = qb_[1]; 
  assign qb[2] = qb_[2]; 
  assign qb[3] = qb_[3]; 
  assign qb[4] = qb_[4]; 
  assign qb[5] = qb_[5]; 
  assign qb[6] = qb_[6]; 
  assign qb[7] = qb_[7]; 
  assign qb[8] = qb_[8]; 
  assign qb[9] = qb_[9]; 
  assign qb[10] = qb_[10]; 
  assign qb[11] = qb_[11]; 
  assign qb[12] = qb_[12]; 
  assign qb[13] = qb_[13]; 
  assign qb[14] = qb_[14]; 
  assign qb[15] = qb_[15]; 
  assign soa[0] = soa_[0]; 
  assign soa[1] = soa_[1]; 
  assign sob[0] = sob_[0]; 
  assign sob[1] = sob_[1]; 
  assign clka_ = clka;
  assign cena_ = cena;
  assign wena_ = wena;
  assign aa_[0] = aa[0];
  assign aa_[1] = aa[1];
  assign aa_[2] = aa[2];
  assign aa_[3] = aa[3];
  assign aa_[4] = aa[4];
  assign aa_[5] = aa[5];
  assign aa_[6] = aa[6];
  assign aa_[7] = aa[7];
  assign aa_[8] = aa[8];
  assign da_[0] = da[0];
  assign da_[1] = da[1];
  assign da_[2] = da[2];
  assign da_[3] = da[3];
  assign da_[4] = da[4];
  assign da_[5] = da[5];
  assign da_[6] = da[6];
  assign da_[7] = da[7];
  assign da_[8] = da[8];
  assign da_[9] = da[9];
  assign da_[10] = da[10];
  assign da_[11] = da[11];
  assign da_[12] = da[12];
  assign da_[13] = da[13];
  assign da_[14] = da[14];
  assign da_[15] = da[15];
  assign clkb_ = clkb;
  assign cenb_ = cenb;
  assign wenb_ = wenb;
  assign ab_[0] = ab[0];
  assign ab_[1] = ab[1];
  assign ab_[2] = ab[2];
  assign ab_[3] = ab[3];
  assign ab_[4] = ab[4];
  assign ab_[5] = ab[5];
  assign ab_[6] = ab[6];
  assign ab_[7] = ab[7];
  assign ab_[8] = ab[8];
  assign db_[0] = db[0];
  assign db_[1] = db[1];
  assign db_[2] = db[2];
  assign db_[3] = db[3];
  assign db_[4] = db[4];
  assign db_[5] = db[5];
  assign db_[6] = db[6];
  assign db_[7] = db[7];
  assign db_[8] = db[8];
  assign db_[9] = db[9];
  assign db_[10] = db[10];
  assign db_[11] = db[11];
  assign db_[12] = db[12];
  assign db_[13] = db[13];
  assign db_[14] = db[14];
  assign db_[15] = db[15];
  assign emaa_[0] = emaa[0];
  assign emaa_[1] = emaa[1];
  assign emaa_[2] = emaa[2];
  assign emawa_[0] = emawa[0];
  assign emawa_[1] = emawa[1];
  assign emasa_ = emasa;
  assign emab_[0] = emab[0];
  assign emab_[1] = emab[1];
  assign emab_[2] = emab[2];
  assign emawb_[0] = emawb[0];
  assign emawb_[1] = emawb[1];
  assign emasb_ = emasb;
  assign tena_ = tena;
  assign tcena_ = tcena;
  assign twena_ = twena;
  assign taa_[0] = taa[0];
  assign taa_[1] = taa[1];
  assign taa_[2] = taa[2];
  assign taa_[3] = taa[3];
  assign taa_[4] = taa[4];
  assign taa_[5] = taa[5];
  assign taa_[6] = taa[6];
  assign taa_[7] = taa[7];
  assign taa_[8] = taa[8];
  assign tda_[0] = tda[0];
  assign tda_[1] = tda[1];
  assign tda_[2] = tda[2];
  assign tda_[3] = tda[3];
  assign tda_[4] = tda[4];
  assign tda_[5] = tda[5];
  assign tda_[6] = tda[6];
  assign tda_[7] = tda[7];
  assign tda_[8] = tda[8];
  assign tda_[9] = tda[9];
  assign tda_[10] = tda[10];
  assign tda_[11] = tda[11];
  assign tda_[12] = tda[12];
  assign tda_[13] = tda[13];
  assign tda_[14] = tda[14];
  assign tda_[15] = tda[15];
  assign tenb_ = tenb;
  assign tcenb_ = tcenb;
  assign twenb_ = twenb;
  assign tab_[0] = tab[0];
  assign tab_[1] = tab[1];
  assign tab_[2] = tab[2];
  assign tab_[3] = tab[3];
  assign tab_[4] = tab[4];
  assign tab_[5] = tab[5];
  assign tab_[6] = tab[6];
  assign tab_[7] = tab[7];
  assign tab_[8] = tab[8];
  assign tdb_[0] = tdb[0];
  assign tdb_[1] = tdb[1];
  assign tdb_[2] = tdb[2];
  assign tdb_[3] = tdb[3];
  assign tdb_[4] = tdb[4];
  assign tdb_[5] = tdb[5];
  assign tdb_[6] = tdb[6];
  assign tdb_[7] = tdb[7];
  assign tdb_[8] = tdb[8];
  assign tdb_[9] = tdb[9];
  assign tdb_[10] = tdb[10];
  assign tdb_[11] = tdb[11];
  assign tdb_[12] = tdb[12];
  assign tdb_[13] = tdb[13];
  assign tdb_[14] = tdb[14];
  assign tdb_[15] = tdb[15];
  assign ret1n_ = ret1n;
  assign sia_[0] = sia[0];
  assign sia_[1] = sia[1];
  assign sea_ = sea;
  assign dftrambyp_ = dftrambyp;
  assign sib_[0] = sib[0];
  assign sib_[1] = sib[1];
  assign seb_ = seb;
  assign colldisn_ = colldisn;

  assign `ARM_UD_DP cenya_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tena_ ? cena_ : tcena_)) : 1'bx;
  assign `ARM_UD_DP wenya_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tena_ ? wena_ : twena_)) : 1'bx;
  assign `ARM_UD_DP aya_ = (ret1n_ | pre_charge_st) ? ({9{dftrambyp_}} & (tena_ ? aa_ : taa_)) : {9{1'bx}};
  assign `ARM_UD_DP cenyb_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tenb_ ? cenb_ : tcenb_)) : 1'bx;
  assign `ARM_UD_DP wenyb_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tenb_ ? wenb_ : twenb_)) : 1'bx;
  assign `ARM_UD_DP ayb_ = (ret1n_ | pre_charge_st) ? ({9{dftrambyp_}} & (tenb_ ? ab_ : tab_)) : {9{1'bx}};
   `ifdef ARM_FAULT_MODELING
     sramdp_272_16_error_injection u1(.CLK(clka_), .Q_out(qa_), .A(aa_int), .CEN(cena_int), .DFTRAMBYP(dftrambyp_int), .SE(sea_int), .WEN(wena_int), .Q_in(qa_int));
  `else
  assign `ARM_UD_SEQ qa_ = (ret1n_ | pre_charge_st) ? ((qa_int)) : {16{1'bx}};
  `endif
  assign `ARM_UD_SEQ qb_ = (ret1n_ | pre_charge_st) ? ((qb_int)) : {16{1'bx}};
  assign `ARM_UD_DP soa_ = (ret1n_ | pre_charge_st) ? ({qa_[8], qa_[7]}) : {2{1'bx}};
  assign `ARM_UD_DP sob_ = (ret1n_ | pre_charge_st) ? ({qb_[8], qb_[7]}) : {2{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial begin
    #0;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emaa_ !== ARM_REF_EMAA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emaa is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emaa", emaa_, ARM_REF_EMAA_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_) begin
      if(emawa_ !== ARM_REF_EMAWA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emawa is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emawa", emawa_, ARM_REF_EMAWA_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emasa_ !== ARM_REF_EMASA_VALUE  && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emasa is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emasa", emasa_, ARM_REF_EMASA_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emab_ !== ARM_REF_EMAB_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emab is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emab", emab_, ARM_REF_EMAB_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_) begin
      if(emawb_ !== ARM_REF_EMAWB_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emawb is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emawb", emawb_, ARM_REF_EMAWB_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emasb_ !== ARM_REF_EMASB_VALUE  && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emasb is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emasb", emasb_, ARM_REF_EMASB_VALUE, $time);
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

  function isBit1;
    input bitval;
    begin
      isBit1 = ( bitval===1'b1 ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
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
	reg [8:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xqa = 1'b0; qa_update = 1'b1;
   	$fdisplay(dump_file_desc, "%b", mem_path_A);
  end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [8:0] load_addr;
	input [15:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [15:0] dump_data;
	input [8:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xqa = 1'b0; qa_update = 1'b1;
   	dump_data = mem_path_A;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWriteA;
  begin
    if (wena_int !== 1'b1 && dftrambyp_int=== 1'b0 && sea_int === 1'bx) begin
      failedWrite(0);
    end else if (dftrambyp_int=== 1'b0 && sea_int === 1'b1) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_int === 1'b0 && (cena_int === 1'b0 || dftrambyp_int === 1'b1)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(emaa_int & isBit1(dftrambyp_int)), (emawa_int & isBit1(dftrambyp_int)), (emasa_int & isBit1(dftrambyp_int))} === 1'bx) begin
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (^{(cena_int & !isBit1(dftrambyp_int)), emaa_int, emawa_int, emasa_int, ret1n_int} === 1'bx) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if ((aa_int >= WORDS) && (cena_int === 1'b0) && dftrambyp_int === 1'b0) begin
        Xqa = wena_int !== 1'b1 ? 1'b0 : 1'b1; qa_update = wena_int !== 1'b1 ? 1'b0 : 1'b1;
    end else if (cena_int === 1'b0 && (^aa_int) === 1'bx && dftrambyp_int === 1'b0) begin
     if (wena_int !== 1)
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (cena_int === 1'b0 || dftrambyp_int === 1'b1) begin
      if(isBitX(dftrambyp_int) || isBitX(sea_int))
        da_int = {16{1'bx}};

      mux_address = (aa_int & 2'b11);
      row_address = (aa_int >> 2);
      if (dftrambyp_int !== 1'b1) begin
      if (row_address > 67)
        row = {64{1'bx}};
      else
        row = mem[row_address];
      end
      if(isBitX(dftrambyp_int) || (isBitX(wena_int) && dftrambyp_int!==1)) begin
        writeEnable = {16{1'bx}};
        da_int = {16{1'bx}};
      end else
          writeEnable = ~ {16{wena_int}};
      if (wena_int !== 1'b1 || dftrambyp_int === 1'b1 || dftrambyp_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, da_int[15], 3'b000, da_int[14], 3'b000, da_int[13],
          3'b000, da_int[12], 3'b000, da_int[11], 3'b000, da_int[10], 3'b000, da_int[9],
          3'b000, da_int[8], 3'b000, da_int[7], 3'b000, da_int[6], 3'b000, da_int[5],
          3'b000, da_int[4], 3'b000, da_int[3], 3'b000, da_int[2], 3'b000, da_int[1],
          3'b000, da_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (dftrambyp_int === 1'b1 && sea_int === 1'b0) begin
        end else if (wena_int !== 1'b1 && dftrambyp_int === 1'b1 && sea_int === 1'bx) begin
        	Xqa = 1'b1; qa_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xqa = 1'b0; qa_update = 1'b1;
      end
      if (dftrambyp_int === 1'b1) begin
        	Xqa = 1'b0; qa_update = 1'b1;
      end
      if( isBitX(wena_int) && dftrambyp_int !== 1'b1) begin
        Xqa = 1'b1; qa_update = 1'b1;
      end
      if( isBitX(dftrambyp_int) ) begin
        Xqa = 1'b1; qa_update = 1'b1;
      end
      if( isBitX(sea_int) && dftrambyp_int === 1'b1 ) begin
        Xqa = 1'b1; qa_update = 1'b1;
      end
    end
  end
  endtask
  always @ (cena_ or tcena_ or tena_ or dftrambyp_ or clka_) begin
  	if(clka_ == 1'b0) begin
  		cena_p2 = cena_;
  		tcena_p2 = tcena_;
  		dftrambyp_p2 = dftrambyp_;
  	end
  end

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
`ifdef POWER_PINS
  always @ (ret1n_ or VDDPE or VDDCE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_a == 1'b1 && (cena_ === 1'bx || tcena_ === 1'bx || dftrambyp_ === 1'bx || clka_ === 1'bx)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && (cena_p2 === 1'b0 || tcena_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && (cena_p2 === 1'b0 || tcena_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_a = 1;
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
        Xqa = 1'b1; qa_update = 1'b1;
      cena_int = 1'bx;
      wena_int = 1'bx;
      aa_int = {9{1'bx}};
      da_int = {16{1'bx}};
      emaa_int = {3{1'bx}};
      emawa_int = {2{1'bx}};
      emasa_int = 1'bx;
      tena_int = 1'bx;
      tcena_int = 1'bx;
      twena_int = 1'bx;
      taa_int = {9{1'bx}};
      tda_int = {16{1'bx}};
      ret1n_int = 1'bx;
      sea_int = 1'bx;
      dftrambyp_int = 1'bx;
      colldisn_int = 1'bx;
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_a == 1'b1) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        Xqa = 1'b1; qa_update = 1'b1;
      cena_int = 1'bx;
      wena_int = 1'bx;
      aa_int = {9{1'bx}};
      da_int = {16{1'bx}};
      emaa_int = {3{1'bx}};
      emawa_int = {2{1'bx}};
      emasa_int = 1'bx;
      tena_int = 1'bx;
      tcena_int = 1'bx;
      twena_int = 1'bx;
      taa_int = {9{1'bx}};
      tda_int = {16{1'bx}};
      ret1n_int = 1'bx;
      sea_int = 1'bx;
      dftrambyp_int = 1'bx;
      colldisn_int = 1'bx;
    end
    ret1n_int = ret1n_;
    #0;
        qa_update = 1'b0;
  end


  always @ clka_ begin
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
  if (ret1n_ == 1'b0) begin
`else     
  if (ret1n_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((clka_ === 1'bx || clka_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if ((clka_ === 1'b1 || clka_ === 1'b0) && LAST_clka === 1'bx) begin
       da_sh_update = 1'b0;  Xda_sh = 1'b0;
       Xqa = 1'b0; qa_update = 1'b0; 
    end else if (clka_ === 1'b1 && LAST_clka === 1'b0) begin
      sea_int = sea_;
      dftrambyp_int = dftrambyp_;
      cena_int = tena_ ? cena_ : tcena_;
      emaa_int = emaa_;
      emawa_int = emawa_;
      emasa_int = emasa_;
      tena_int = tena_;
      twena_int = twena_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cena_int != 1'b1) begin
        wena_int = tena_ ? wena_ : twena_;
        aa_int = tena_ ? aa_ : taa_;
        da_int = tena_ ? da_ : tda_;
        tcena_int = tcena_;
        taa_int = taa_;
        tda_int = tda_;
        dftrambyp_int = dftrambyp_;
      end
      clk0_int = 1'b0;
      if (dftrambyp_=== 1'b1 && sea_ === 1'b1) begin
        Xqa = 1'b0; qa_update = 1'b1;
      end else begin
      cena_int = tena_ ? cena_ : tcena_;
      emaa_int = emaa_;
      emawa_int = emawa_;
      emasa_int = emasa_;
      tena_int = tena_;
      twena_int = twena_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cena_int != 1'b1) begin
        wena_int = tena_ ? wena_ : twena_;
        aa_int = tena_ ? aa_ : taa_;
        da_int = tena_ ? da_ : tda_;
        tcena_int = tcena_;
        taa_int = taa_;
        tda_int = tda_;
        dftrambyp_int = dftrambyp_;
      end
      clk0_int = 1'b0;
      if (cena_int === 1'b0) previous_clka = $realtime;
    readWriteA;
      end
    #0;
      if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && colldisn_int === 1'b1 && row_contention(aa_int,
        ab_int, wena_int, wenb_int)) begin
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
	      if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          da_int = {16{1'bx}};
          readWriteA;
          db_int = {16{1'bx}};
          readWriteB;
	      end
        end else if (wena_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqb = 1'b1; qb_update = 1'b1;
		end
        end else if (wenb_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqa = 1'b1; qa_update = 1'b1;
		end
        end else begin
          readWriteB;
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          readWriteB;
          readWriteA;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(wena_int !== 1'b1) && (wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((wena_int !== 1'b1) && !(wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && (colldisn_int === 1'b0 || colldisn_int 
       === 1'bx)  && row_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
        if (wenb_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          db_int = {16{1'bx}};
          readWriteB;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        Xqb = 1'b1; qb_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (wena_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          da_int = {16{1'bx}};
          readWriteA;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        Xqa = 1'b1; qa_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (clka_ === 1'b0 && LAST_clka === 1'b1) begin
      qa_update = 1'b0;
      da_sh_update = 1'b0;
      Xqa = 1'b0;
    end
  end
    LAST_clka = clka_;
  end

  assign sia_int = sea_ ? sia_ : {2{1'b0}};
  assign da_int_bmux = tena_ ? da_ : tda_;

  datapath_latch_sramdp_272_16 uDQA0 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(sia_int[0]), .D(da_int_bmux[0]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[0]), .XQ(Xqa), .Q(qa_int[0]));
  datapath_latch_sramdp_272_16 uDQA1 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[0]), .D(da_int_bmux[1]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[1]), .XQ(Xqa), .Q(qa_int[1]));
  datapath_latch_sramdp_272_16 uDQA2 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[1]), .D(da_int_bmux[2]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[2]), .XQ(Xqa), .Q(qa_int[2]));
  datapath_latch_sramdp_272_16 uDQA3 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[2]), .D(da_int_bmux[3]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[3]), .XQ(Xqa), .Q(qa_int[3]));
  datapath_latch_sramdp_272_16 uDQA4 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[3]), .D(da_int_bmux[4]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[4]), .XQ(Xqa), .Q(qa_int[4]));
  datapath_latch_sramdp_272_16 uDQA5 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[4]), .D(da_int_bmux[5]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[5]), .XQ(Xqa), .Q(qa_int[5]));
  datapath_latch_sramdp_272_16 uDQA6 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[5]), .D(da_int_bmux[6]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[6]), .XQ(Xqa), .Q(qa_int[6]));
  datapath_latch_sramdp_272_16 uDQA7 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[6]), .D(da_int_bmux[7]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[7]), .XQ(Xqa), .Q(qa_int[7]));
  datapath_latch_sramdp_272_16 uDQA8 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[9]), .D(da_int_bmux[8]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[8]), .XQ(Xqa), .Q(qa_int[8]));
  datapath_latch_sramdp_272_16 uDQA9 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[10]), .D(da_int_bmux[9]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[9]), .XQ(Xqa), .Q(qa_int[9]));
  datapath_latch_sramdp_272_16 uDQA10 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[11]), .D(da_int_bmux[10]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[10]), .XQ(Xqa), .Q(qa_int[10]));
  datapath_latch_sramdp_272_16 uDQA11 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[12]), .D(da_int_bmux[11]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[11]), .XQ(Xqa), .Q(qa_int[11]));
  datapath_latch_sramdp_272_16 uDQA12 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[13]), .D(da_int_bmux[12]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[12]), .XQ(Xqa), .Q(qa_int[12]));
  datapath_latch_sramdp_272_16 uDQA13 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[14]), .D(da_int_bmux[13]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[13]), .XQ(Xqa), .Q(qa_int[13]));
  datapath_latch_sramdp_272_16 uDQA14 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[15]), .D(da_int_bmux[14]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[14]), .XQ(Xqa), .Q(qa_int[14]));
  datapath_latch_sramdp_272_16 uDQA15 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(sia_int[1]), .D(da_int_bmux[15]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[15]), .XQ(Xqa), .Q(qa_int[15]));



  task readWriteB;
  begin
    if (wenb_int !== 1'b1 && dftrambyp_int=== 1'b0 && seb_int === 1'bx) begin
      failedWrite(1);
    end else if (dftrambyp_int=== 1'b0 && seb_int === 1'b1) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_int === 1'b0 && (cenb_int === 1'b0 || dftrambyp_int === 1'b1)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(emab_int & isBit1(dftrambyp_int)), (emawb_int & isBit1(dftrambyp_int)), (emasb_int & isBit1(dftrambyp_int))} === 1'bx) begin
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (^{(cenb_int & !isBit1(dftrambyp_int)), emab_int, emawb_int, emasb_int, ret1n_int} === 1'bx) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if ((ab_int >= WORDS) && (cenb_int === 1'b0) && dftrambyp_int === 1'b0) begin
        Xqb = wenb_int !== 1'b1 ? 1'b0 : 1'b1; qb_update = wenb_int !== 1'b1 ? 1'b0 : 1'b1;
    end else if (cenb_int === 1'b0 && (^ab_int) === 1'bx && dftrambyp_int === 1'b0) begin
     if (wenb_int !== 1)
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (cenb_int === 1'b0 || dftrambyp_int === 1'b1) begin
      if(isBitX(dftrambyp_int) || isBitX(seb_int))
        db_int = {16{1'bx}};

      mux_address = (ab_int & 2'b11);
      row_address = (ab_int >> 2);
      if (dftrambyp_int !== 1'b1) begin
      if (row_address > 67)
        row = {64{1'bx}};
      else
        row = mem[row_address];
      end
      if(isBitX(dftrambyp_int) || (isBitX(wenb_int) && dftrambyp_int!==1)) begin
        writeEnable = {16{1'bx}};
        db_int = {16{1'bx}};
      end else
          writeEnable = ~ {16{wenb_int}};
      if (wenb_int !== 1'b1 || dftrambyp_int === 1'b1 || dftrambyp_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, db_int[15], 3'b000, db_int[14], 3'b000, db_int[13],
          3'b000, db_int[12], 3'b000, db_int[11], 3'b000, db_int[10], 3'b000, db_int[9],
          3'b000, db_int[8], 3'b000, db_int[7], 3'b000, db_int[6], 3'b000, db_int[5],
          3'b000, db_int[4], 3'b000, db_int[3], 3'b000, db_int[2], 3'b000, db_int[1],
          3'b000, db_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (dftrambyp_int === 1'b1 && seb_int === 1'b0) begin
        end else if (wenb_int !== 1'b1 && dftrambyp_int === 1'b1 && seb_int === 1'bx) begin
        	Xqb = 1'b1; qb_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[15], shifted_readLatch1[14], shifted_readLatch1[13],
          shifted_readLatch1[12], shifted_readLatch1[11], shifted_readLatch1[10], shifted_readLatch1[9],
          shifted_readLatch1[8], shifted_readLatch1[7], shifted_readLatch1[6], shifted_readLatch1[5],
          shifted_readLatch1[4], shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
          shifted_readLatch1[0]};
        	Xqb = 1'b0; qb_update = 1'b1;
      end
      if (dftrambyp_int === 1'b1) begin
        	Xqb = 1'b0; qb_update = 1'b1;
      end
      if( isBitX(wenb_int) && dftrambyp_int !== 1'b1) begin
        Xqb = 1'b1; qb_update = 1'b1;
      end
      if( isBitX(dftrambyp_int) ) begin
        Xqb = 1'b1; qb_update = 1'b1;
      end
      if( isBitX(seb_int) && dftrambyp_int === 1'b1 ) begin
        Xqb = 1'b1; qb_update = 1'b1;
      end
    end
  end
  endtask
  always @ (cenb_ or tcenb_ or tenb_ or dftrambyp_ or clkb_) begin
  	if(clkb_ == 1'b0) begin
  		cenb_p2 = cenb_;
  		tcenb_p2 = tcenb_;
  		dftrambyp_p2 = dftrambyp_;
  	end
  end

`ifdef POWER_PINS
  always @ (ret1n_ or VDDPE or VDDCE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_b == 1'b1 && (cenb_ === 1'bx || tcenb_ === 1'bx || dftrambyp_ === 1'bx || clkb_ === 1'bx)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && (cenb_p2 === 1'b0 || tcenb_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && (cenb_p2 === 1'b0 || tcenb_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_b = 1;
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(1);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
        Xqb = 1'b1; qb_update = 1'b1;
      cenb_int = 1'bx;
      wenb_int = 1'bx;
      ab_int = {9{1'bx}};
      db_int = {16{1'bx}};
      emab_int = {3{1'bx}};
      emawb_int = {2{1'bx}};
      emasb_int = 1'bx;
      tenb_int = 1'bx;
      tcenb_int = 1'bx;
      twenb_int = 1'bx;
      tab_int = {9{1'bx}};
      tdb_int = {16{1'bx}};
      ret1n_int = 1'bx;
      seb_int = 1'bx;
      colldisn_int = 1'bx;
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_b == 1'b1) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        Xqb = 1'b1; qb_update = 1'b1;
      cenb_int = 1'bx;
      wenb_int = 1'bx;
      ab_int = {9{1'bx}};
      db_int = {16{1'bx}};
      emab_int = {3{1'bx}};
      emawb_int = {2{1'bx}};
      emasb_int = 1'bx;
      tenb_int = 1'bx;
      tcenb_int = 1'bx;
      twenb_int = 1'bx;
      tab_int = {9{1'bx}};
      tdb_int = {16{1'bx}};
      ret1n_int = 1'bx;
      seb_int = 1'bx;
      colldisn_int = 1'bx;
    end
    ret1n_int = ret1n_;
    #0;
        qb_update = 1'b0;
  end


  always @ clkb_ begin
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
  if (ret1n_ == 1'b0) begin
`else     
  if (ret1n_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((clkb_ === 1'bx || clkb_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if ((clkb_ === 1'b1 || clkb_ === 1'b0) && LAST_clkb === 1'bx) begin
       db_sh_update = 1'b0;  Xdb_sh = 1'b0;
       Xqb = 1'b0; qb_update = 1'b0; 
    end else if (clkb_ === 1'b1 && LAST_clkb === 1'b0) begin
      dftrambyp_int = dftrambyp_;
      seb_int = seb_;
      cenb_int = tenb_ ? cenb_ : tcenb_;
      emab_int = emab_;
      emawb_int = emawb_;
      emasb_int = emasb_;
      tenb_int = tenb_;
      twenb_int = twenb_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cenb_int != 1'b1) begin
        wenb_int = tenb_ ? wenb_ : twenb_;
        ab_int = tenb_ ? ab_ : tab_;
        db_int = tenb_ ? db_ : tdb_;
        tcenb_int = tcenb_;
        tab_int = tab_;
        tdb_int = tdb_;
      end
      clk1_int = 1'b0;
      if (dftrambyp_=== 1'b1 && seb_ === 1'b1) begin
        Xqb = 1'b0; qb_update = 1'b1;
      end else begin
      cenb_int = tenb_ ? cenb_ : tcenb_;
      emab_int = emab_;
      emawb_int = emawb_;
      emasb_int = emasb_;
      tenb_int = tenb_;
      twenb_int = twenb_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cenb_int != 1'b1) begin
        wenb_int = tenb_ ? wenb_ : twenb_;
        ab_int = tenb_ ? ab_ : tab_;
        db_int = tenb_ ? db_ : tdb_;
        tcenb_int = tcenb_;
        tab_int = tab_;
        tdb_int = tdb_;
      end
      clk1_int = 1'b0;
      if (cenb_int === 1'b0) previous_clkb = $realtime;
    readWriteB;
      end
    #0;
      if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && colldisn_int === 1'b1 && row_contention(aa_int,
        ab_int, wena_int, wenb_int)) begin
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
	      if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          da_int = {16{1'bx}};
          readWriteA;
          db_int = {16{1'bx}};
          readWriteB;
	      end
        end else if (wena_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqb = 1'b1; qb_update = 1'b1;
		end
        end else if (wenb_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqa = 1'b1; qa_update = 1'b1;
		end
        end else begin
          readWriteA;
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          readWriteA;
          readWriteB;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(wena_int !== 1'b1) && (wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((wena_int !== 1'b1) && !(wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && (colldisn_int === 1'b0 || colldisn_int 
       === 1'bx)  && row_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
        if (wena_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          da_int = {16{1'bx}};
          readWriteA;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        Xqa = 1'b1; qa_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (wenb_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          db_int = {16{1'bx}};
          readWriteB;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        Xqb = 1'b1; qb_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (clkb_ === 1'b0 && LAST_clkb === 1'b1) begin
      qb_update = 1'b0;
      db_sh_update = 1'b0;
      Xqb = 1'b0;
    end
  end
    LAST_clkb = clkb_;
  end

  assign sib_int = seb_ ? sib_ : {2{1'b0}};
  assign db_int_bmux = tenb_ ? db_ : tdb_;

  datapath_latch_sramdp_272_16 uDQB0 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(sib_int[0]), .D(db_int_bmux[0]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[0]), .XQ(Xqb), .Q(qb_int[0]));
  datapath_latch_sramdp_272_16 uDQB1 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[0]), .D(db_int_bmux[1]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[1]), .XQ(Xqb), .Q(qb_int[1]));
  datapath_latch_sramdp_272_16 uDQB2 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[1]), .D(db_int_bmux[2]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[2]), .XQ(Xqb), .Q(qb_int[2]));
  datapath_latch_sramdp_272_16 uDQB3 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[2]), .D(db_int_bmux[3]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[3]), .XQ(Xqb), .Q(qb_int[3]));
  datapath_latch_sramdp_272_16 uDQB4 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[3]), .D(db_int_bmux[4]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[4]), .XQ(Xqb), .Q(qb_int[4]));
  datapath_latch_sramdp_272_16 uDQB5 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[4]), .D(db_int_bmux[5]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[5]), .XQ(Xqb), .Q(qb_int[5]));
  datapath_latch_sramdp_272_16 uDQB6 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[5]), .D(db_int_bmux[6]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[6]), .XQ(Xqb), .Q(qb_int[6]));
  datapath_latch_sramdp_272_16 uDQB7 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[6]), .D(db_int_bmux[7]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[7]), .XQ(Xqb), .Q(qb_int[7]));
  datapath_latch_sramdp_272_16 uDQB8 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[9]), .D(db_int_bmux[8]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[8]), .XQ(Xqb), .Q(qb_int[8]));
  datapath_latch_sramdp_272_16 uDQB9 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[10]), .D(db_int_bmux[9]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[9]), .XQ(Xqb), .Q(qb_int[9]));
  datapath_latch_sramdp_272_16 uDQB10 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[11]), .D(db_int_bmux[10]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[10]), .XQ(Xqb), .Q(qb_int[10]));
  datapath_latch_sramdp_272_16 uDQB11 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[12]), .D(db_int_bmux[11]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[11]), .XQ(Xqb), .Q(qb_int[11]));
  datapath_latch_sramdp_272_16 uDQB12 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[13]), .D(db_int_bmux[12]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[12]), .XQ(Xqb), .Q(qb_int[12]));
  datapath_latch_sramdp_272_16 uDQB13 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[14]), .D(db_int_bmux[13]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[13]), .XQ(Xqb), .Q(qb_int[13]));
  datapath_latch_sramdp_272_16 uDQB14 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[15]), .D(db_int_bmux[14]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[14]), .XQ(Xqb), .Q(qb_int[14]));
  datapath_latch_sramdp_272_16 uDQB15 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(sib_int[1]), .D(db_int_bmux[15]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[15]), .XQ(Xqb), .Q(qb_int[15]));


// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
 always @ (VDDCE or VDDPE or VSSE) begin
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
 end
`endif

  function row_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[8:2] == ab[8:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [8:0] aa;
    input [8:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction


endmodule
`endcelldefine
`else
`celldefine
// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
module sramdp_272_16 (VDDCE, VDDPE, VSSE, cenya, wenya, aya, cenyb, wenyb, ayb, qa,
    qb, soa, sob, clka, cena, wena, aa, da, clkb, cenb, wenb, ab, db, emaa, emawa,
    emasa, emab, emawb, emasb, tena, tcena, twena, taa, tda, tenb, tcenb, twenb, tab,
    tdb, ret1n, sia, sea, dftrambyp, sib, seb, colldisn);
`else
module sramdp_272_16 (cenya, wenya, aya, cenyb, wenyb, ayb, qa, qb, soa, sob, clka,
    cena, wena, aa, da, clkb, cenb, wenb, ab, db, emaa, emawa, emasa, emab, emawb,
    emasb, tena, tcena, twena, taa, tda, tenb, tcenb, twenb, tab, tdb, ret1n, sia,
    sea, dftrambyp, sib, seb, colldisn);
`endif

  parameter ASSERT_PREFIX = "";
  parameter BITS = 16;
  parameter WORDS = 272;
  parameter MUX = 4;
  parameter MEM_WIDTH = 64; // redun block size 4, 32 on left, 32 on right
  parameter MEM_HEIGHT = 68;
  parameter WP_SIZE = 16 ;
  parameter UPM_WIDTH = 3;
  parameter UPMW_WIDTH = 2;
  parameter UPMS_WIDTH = 1;

`ifdef ARM_DISABLE_EMA_CHECK
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 1;
`else
parameter ARM_LOCAL_DISABLE_EMA_CHECK = 0;
`endif

  parameter ARM_REF_EMAA_VALUE = 2**UPM_WIDTH-1;
  parameter ARM_REF_EMAWA_VALUE = 2**UPMW_WIDTH-1;
  parameter ARM_REF_EMASA_VALUE = 2**UPMS_WIDTH-1;
  parameter ARM_REF_EMAB_VALUE = 2**UPM_WIDTH-1;
  parameter ARM_REF_EMAWB_VALUE = 2**UPMW_WIDTH-1;
  parameter ARM_REF_EMASB_VALUE = 2**UPMS_WIDTH-1;

  output  cenya;
  output  wenya;
  output [8:0] aya;
  output  cenyb;
  output  wenyb;
  output [8:0] ayb;
  output [15:0] qa;
  output [15:0] qb;
  output [1:0] soa;
  output [1:0] sob;
  input  clka;
  input  cena;
  input  wena;
  input [8:0] aa;
  input [15:0] da;
  input  clkb;
  input  cenb;
  input  wenb;
  input [8:0] ab;
  input [15:0] db;
  input [2:0] emaa;
  input [1:0] emawa;
  input  emasa;
  input [2:0] emab;
  input [1:0] emawb;
  input  emasb;
  input  tena;
  input  tcena;
  input  twena;
  input [8:0] taa;
  input [15:0] tda;
  input  tenb;
  input  tcenb;
  input  twenb;
  input [8:0] tab;
  input [15:0] tdb;
  input  ret1n;
  input [1:0] sia;
  input  sea;
  input  dftrambyp;
  input [1:0] sib;
  input  seb;
  input  colldisn;
`ifdef POWER_PINS
  inout VDDCE;
  inout VDDPE;
  inout VSSE;
`endif

  reg pre_charge_st;
  reg pre_charge_st_a;
  reg pre_charge_st_b;
  integer row_address;
  integer mux_address;
  initial row_address = 0;
  initial mux_address = 0;
  reg [63:0] mem [0:67];
  reg [63:0] row, row_t;
  reg LAST_clka;
  reg [63:0] row_mask;
  reg [63:0] new_data;
  reg [63:0] data_out;
  reg [15:0] readLatch0;
  reg [15:0] shifted_readLatch0;
  reg  read_mux_sel0_p2;
  reg [15:0] readLatch1;
  reg [15:0] shifted_readLatch1;
  reg  read_mux_sel1_p2;
  reg LAST_clkb;
  wire [15:0] qa_int;
  reg Xqa, qa_update;
  reg Xda_sh, da_sh_update;
  wire [15:0] da_int_bmux;
  reg [15:0] mem_path_A;
  wire [15:0] qb_int;
  reg Xqb, qb_update;
  reg Xdb_sh, db_sh_update;
  wire [15:0] db_int_bmux;
  reg [15:0] mem_path_B;
  reg [15:0] writeEnable;
  real previous_clka;
  real previous_clkb;
  initial previous_clka = 0;
  initial previous_clkb = 0;
  reg READ_WRITE, WRITE_WRITE, READ_READ, ROW_CC, COL_CC;
  reg READ_WRITE_1, WRITE_WRITE_1, READ_READ_1;
  reg  cont_flag0_int;
  reg  cont_flag1_int;
  initial cont_flag0_int = 1'b0;
  initial cont_flag1_int = 1'b0;

  reg NOT_cena, NOT_wena, NOT_aa8, NOT_aa7, NOT_aa6, NOT_aa5, NOT_aa4, NOT_aa3, NOT_aa2;
  reg NOT_aa1, NOT_aa0, NOT_da15, NOT_da14, NOT_da13, NOT_da12, NOT_da11, NOT_da10;
  reg NOT_da9, NOT_da8, NOT_da7, NOT_da6, NOT_da5, NOT_da4, NOT_da3, NOT_da2, NOT_da1;
  reg NOT_da0, NOT_cenb, NOT_wenb, NOT_ab8, NOT_ab7, NOT_ab6, NOT_ab5, NOT_ab4, NOT_ab3;
  reg NOT_ab2, NOT_ab1, NOT_ab0, NOT_db15, NOT_db14, NOT_db13, NOT_db12, NOT_db11;
  reg NOT_db10, NOT_db9, NOT_db8, NOT_db7, NOT_db6, NOT_db5, NOT_db4, NOT_db3, NOT_db2;
  reg NOT_db1, NOT_db0, NOT_emaa2, NOT_emaa1, NOT_emaa0, NOT_emawa1, NOT_emawa0, NOT_emasa;
  reg NOT_emab2, NOT_emab1, NOT_emab0, NOT_emawb1, NOT_emawb0, NOT_emasb, NOT_tena;
  reg NOT_tcena, NOT_twena, NOT_taa8, NOT_taa7, NOT_taa6, NOT_taa5, NOT_taa4, NOT_taa3;
  reg NOT_taa2, NOT_taa1, NOT_taa0, NOT_tda15, NOT_tda14, NOT_tda13, NOT_tda12, NOT_tda11;
  reg NOT_tda10, NOT_tda9, NOT_tda8, NOT_tda7, NOT_tda6, NOT_tda5, NOT_tda4, NOT_tda3;
  reg NOT_tda2, NOT_tda1, NOT_tda0, NOT_tenb, NOT_tcenb, NOT_twenb, NOT_tab8, NOT_tab7;
  reg NOT_tab6, NOT_tab5, NOT_tab4, NOT_tab3, NOT_tab2, NOT_tab1, NOT_tab0, NOT_tdb15;
  reg NOT_tdb14, NOT_tdb13, NOT_tdb12, NOT_tdb11, NOT_tdb10, NOT_tdb9, NOT_tdb8, NOT_tdb7;
  reg NOT_tdb6, NOT_tdb5, NOT_tdb4, NOT_tdb3, NOT_tdb2, NOT_tdb1, NOT_tdb0, NOT_sia1;
  reg NOT_sia0, NOT_sea, NOT_dftrambyp_clkb, NOT_dftrambyp_clka, NOT_ret1n, NOT_sib1;
  reg NOT_sib0, NOT_seb, NOT_colldisn;
  reg NOT_clka_PER, NOT_clka_MINH, NOT_clka_MINL, NOT_CONTA, NOT_clkb_PER, NOT_clkb_MINH;
  reg NOT_clkb_MINL, NOT_CONTB;
  reg clk0_int;
  reg clk1_int;

  wire  cenya_;
  wire  wenya_;
  wire [8:0] aya_;
  wire  cenyb_;
  wire  wenyb_;
  wire [8:0] ayb_;
  wire [15:0] qa_;
  wire [15:0] qb_;
  wire [1:0] soa_;
  wire [1:0] sob_;
 wire  clka_;
  wire  cena_;
  reg  cena_int;
  reg  cena_p2;
  wire  wena_;
  reg  wena_int;
  wire [8:0] aa_;
  reg [8:0] aa_int;
  wire [15:0] da_;
  reg [15:0] da_int;
 wire  clkb_;
  wire  cenb_;
  reg  cenb_int;
  reg  cenb_p2;
  wire  wenb_;
  reg  wenb_int;
  wire [8:0] ab_;
  reg [8:0] ab_int;
  wire [15:0] db_;
  reg [15:0] db_int;
  wire [2:0] emaa_;
  reg [2:0] emaa_int;
  wire [1:0] emawa_;
  reg [1:0] emawa_int;
  wire  emasa_;
  reg  emasa_int;
  wire [2:0] emab_;
  reg [2:0] emab_int;
  wire [1:0] emawb_;
  reg [1:0] emawb_int;
  wire  emasb_;
  reg  emasb_int;
  wire  tena_;
  reg  tena_int;
  wire  tcena_;
  reg  tcena_int;
  reg  tcena_p2;
  wire  twena_;
  reg  twena_int;
  wire [8:0] taa_;
  reg [8:0] taa_int;
  wire [15:0] tda_;
  reg [15:0] tda_int;
  wire  tenb_;
  reg  tenb_int;
  wire  tcenb_;
  reg  tcenb_int;
  reg  tcenb_p2;
  wire  twenb_;
  reg  twenb_int;
  wire [8:0] tab_;
  reg [8:0] tab_int;
  wire [15:0] tdb_;
  reg [15:0] tdb_int;
  wire  ret1n_;
  reg  ret1n_int;
  wire [1:0] sia_;
  wire [1:0] sia_int;
  wire  sea_;
  reg  sea_int;
  wire  dftrambyp_;
  reg  dftrambyp_int;
  reg  dftrambyp_p2;
  wire [1:0] sib_;
  wire [1:0] sib_int;
  wire  seb_;
  reg  seb_int;
  wire  colldisn_;
  reg  colldisn_int;

  buf B0(cenya, cenya_);
  buf B1(wenya, wenya_);
  buf B2(aya[0], aya_[0]);
  buf B3(aya[1], aya_[1]);
  buf B4(aya[2], aya_[2]);
  buf B5(aya[3], aya_[3]);
  buf B6(aya[4], aya_[4]);
  buf B7(aya[5], aya_[5]);
  buf B8(aya[6], aya_[6]);
  buf B9(aya[7], aya_[7]);
  buf B10(aya[8], aya_[8]);
  buf B11(cenyb, cenyb_);
  buf B12(wenyb, wenyb_);
  buf B13(ayb[0], ayb_[0]);
  buf B14(ayb[1], ayb_[1]);
  buf B15(ayb[2], ayb_[2]);
  buf B16(ayb[3], ayb_[3]);
  buf B17(ayb[4], ayb_[4]);
  buf B18(ayb[5], ayb_[5]);
  buf B19(ayb[6], ayb_[6]);
  buf B20(ayb[7], ayb_[7]);
  buf B21(ayb[8], ayb_[8]);
  buf B22(qa[0], qa_[0]);
  buf B23(qa[1], qa_[1]);
  buf B24(qa[2], qa_[2]);
  buf B25(qa[3], qa_[3]);
  buf B26(qa[4], qa_[4]);
  buf B27(qa[5], qa_[5]);
  buf B28(qa[6], qa_[6]);
  buf B29(qa[7], qa_[7]);
  buf B30(qa[8], qa_[8]);
  buf B31(qa[9], qa_[9]);
  buf B32(qa[10], qa_[10]);
  buf B33(qa[11], qa_[11]);
  buf B34(qa[12], qa_[12]);
  buf B35(qa[13], qa_[13]);
  buf B36(qa[14], qa_[14]);
  buf B37(qa[15], qa_[15]);
  buf B38(qb[0], qb_[0]);
  buf B39(qb[1], qb_[1]);
  buf B40(qb[2], qb_[2]);
  buf B41(qb[3], qb_[3]);
  buf B42(qb[4], qb_[4]);
  buf B43(qb[5], qb_[5]);
  buf B44(qb[6], qb_[6]);
  buf B45(qb[7], qb_[7]);
  buf B46(qb[8], qb_[8]);
  buf B47(qb[9], qb_[9]);
  buf B48(qb[10], qb_[10]);
  buf B49(qb[11], qb_[11]);
  buf B50(qb[12], qb_[12]);
  buf B51(qb[13], qb_[13]);
  buf B52(qb[14], qb_[14]);
  buf B53(qb[15], qb_[15]);
  buf B54(soa[0], soa_[0]);
  buf B55(soa[1], soa_[1]);
  buf B56(sob[0], sob_[0]);
  buf B57(sob[1], sob_[1]);
  buf B58(clka_, clka);
  buf B59(cena_, cena);
  buf B60(wena_, wena);
  buf B61(aa_[0], aa[0]);
  buf B62(aa_[1], aa[1]);
  buf B63(aa_[2], aa[2]);
  buf B64(aa_[3], aa[3]);
  buf B65(aa_[4], aa[4]);
  buf B66(aa_[5], aa[5]);
  buf B67(aa_[6], aa[6]);
  buf B68(aa_[7], aa[7]);
  buf B69(aa_[8], aa[8]);
  buf B70(da_[0], da[0]);
  buf B71(da_[1], da[1]);
  buf B72(da_[2], da[2]);
  buf B73(da_[3], da[3]);
  buf B74(da_[4], da[4]);
  buf B75(da_[5], da[5]);
  buf B76(da_[6], da[6]);
  buf B77(da_[7], da[7]);
  buf B78(da_[8], da[8]);
  buf B79(da_[9], da[9]);
  buf B80(da_[10], da[10]);
  buf B81(da_[11], da[11]);
  buf B82(da_[12], da[12]);
  buf B83(da_[13], da[13]);
  buf B84(da_[14], da[14]);
  buf B85(da_[15], da[15]);
  buf B86(clkb_, clkb);
  buf B87(cenb_, cenb);
  buf B88(wenb_, wenb);
  buf B89(ab_[0], ab[0]);
  buf B90(ab_[1], ab[1]);
  buf B91(ab_[2], ab[2]);
  buf B92(ab_[3], ab[3]);
  buf B93(ab_[4], ab[4]);
  buf B94(ab_[5], ab[5]);
  buf B95(ab_[6], ab[6]);
  buf B96(ab_[7], ab[7]);
  buf B97(ab_[8], ab[8]);
  buf B98(db_[0], db[0]);
  buf B99(db_[1], db[1]);
  buf B100(db_[2], db[2]);
  buf B101(db_[3], db[3]);
  buf B102(db_[4], db[4]);
  buf B103(db_[5], db[5]);
  buf B104(db_[6], db[6]);
  buf B105(db_[7], db[7]);
  buf B106(db_[8], db[8]);
  buf B107(db_[9], db[9]);
  buf B108(db_[10], db[10]);
  buf B109(db_[11], db[11]);
  buf B110(db_[12], db[12]);
  buf B111(db_[13], db[13]);
  buf B112(db_[14], db[14]);
  buf B113(db_[15], db[15]);
  buf B114(emaa_[0], emaa[0]);
  buf B115(emaa_[1], emaa[1]);
  buf B116(emaa_[2], emaa[2]);
  buf B117(emawa_[0], emawa[0]);
  buf B118(emawa_[1], emawa[1]);
  buf B119(emasa_, emasa);
  buf B120(emab_[0], emab[0]);
  buf B121(emab_[1], emab[1]);
  buf B122(emab_[2], emab[2]);
  buf B123(emawb_[0], emawb[0]);
  buf B124(emawb_[1], emawb[1]);
  buf B125(emasb_, emasb);
  buf B126(tena_, tena);
  buf B127(tcena_, tcena);
  buf B128(twena_, twena);
  buf B129(taa_[0], taa[0]);
  buf B130(taa_[1], taa[1]);
  buf B131(taa_[2], taa[2]);
  buf B132(taa_[3], taa[3]);
  buf B133(taa_[4], taa[4]);
  buf B134(taa_[5], taa[5]);
  buf B135(taa_[6], taa[6]);
  buf B136(taa_[7], taa[7]);
  buf B137(taa_[8], taa[8]);
  buf B138(tda_[0], tda[0]);
  buf B139(tda_[1], tda[1]);
  buf B140(tda_[2], tda[2]);
  buf B141(tda_[3], tda[3]);
  buf B142(tda_[4], tda[4]);
  buf B143(tda_[5], tda[5]);
  buf B144(tda_[6], tda[6]);
  buf B145(tda_[7], tda[7]);
  buf B146(tda_[8], tda[8]);
  buf B147(tda_[9], tda[9]);
  buf B148(tda_[10], tda[10]);
  buf B149(tda_[11], tda[11]);
  buf B150(tda_[12], tda[12]);
  buf B151(tda_[13], tda[13]);
  buf B152(tda_[14], tda[14]);
  buf B153(tda_[15], tda[15]);
  buf B154(tenb_, tenb);
  buf B155(tcenb_, tcenb);
  buf B156(twenb_, twenb);
  buf B157(tab_[0], tab[0]);
  buf B158(tab_[1], tab[1]);
  buf B159(tab_[2], tab[2]);
  buf B160(tab_[3], tab[3]);
  buf B161(tab_[4], tab[4]);
  buf B162(tab_[5], tab[5]);
  buf B163(tab_[6], tab[6]);
  buf B164(tab_[7], tab[7]);
  buf B165(tab_[8], tab[8]);
  buf B166(tdb_[0], tdb[0]);
  buf B167(tdb_[1], tdb[1]);
  buf B168(tdb_[2], tdb[2]);
  buf B169(tdb_[3], tdb[3]);
  buf B170(tdb_[4], tdb[4]);
  buf B171(tdb_[5], tdb[5]);
  buf B172(tdb_[6], tdb[6]);
  buf B173(tdb_[7], tdb[7]);
  buf B174(tdb_[8], tdb[8]);
  buf B175(tdb_[9], tdb[9]);
  buf B176(tdb_[10], tdb[10]);
  buf B177(tdb_[11], tdb[11]);
  buf B178(tdb_[12], tdb[12]);
  buf B179(tdb_[13], tdb[13]);
  buf B180(tdb_[14], tdb[14]);
  buf B181(tdb_[15], tdb[15]);
  buf B182(ret1n_, ret1n);
  buf B183(sia_[0], sia[0]);
  buf B184(sia_[1], sia[1]);
  buf B185(sea_, sea);
  buf B186(dftrambyp_, dftrambyp);
  buf B187(sib_[0], sib[0]);
  buf B188(sib_[1], sib[1]);
  buf B189(seb_, seb);
  buf B190(colldisn_, colldisn);

  assign cenya_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tena_ ? cena_ : tcena_)) : 1'bx;
  assign wenya_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tena_ ? wena_ : twena_)) : 1'bx;
  assign aya_ = (ret1n_ | pre_charge_st) ? ({9{dftrambyp_}} & (tena_ ? aa_ : taa_)) : {9{1'bx}};
  assign cenyb_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tenb_ ? cenb_ : tcenb_)) : 1'bx;
  assign wenyb_ = (ret1n_ | pre_charge_st) ? (dftrambyp_ & (tenb_ ? wenb_ : twenb_)) : 1'bx;
  assign ayb_ = (ret1n_ | pre_charge_st) ? ({9{dftrambyp_}} & (tenb_ ? ab_ : tab_)) : {9{1'bx}};
   `ifdef ARM_FAULT_MODELING
     sramdp_272_16_error_injection u1(.CLK(clka_), .Q_out(qa_), .A(aa_int), .CEN(cena_int), .DFTRAMBYP(dftrambyp_int), .SE(sea_int), .WEN(wena_int), .Q_in(qa_int));
  `else
  assign qa_ = (ret1n_ | pre_charge_st) ? ((qa_int)) : {16{1'bx}};
  `endif
  assign qb_ = (ret1n_ | pre_charge_st) ? ((qb_int)) : {16{1'bx}};
  assign soa_ = (ret1n_ | pre_charge_st) ? ({qa_[8], qa_[7]}) : {2{1'bx}};
  assign sob_ = (ret1n_ | pre_charge_st) ? ({qb_[8], qb_[7]}) : {2{1'bx}};

// If INITIALIZE_MEMORY is defined at Simulator Command Line, it Initializes the Memory with all ZEROS.
`ifdef INITIALIZE_MEMORY
  integer i;
  initial begin
    #0;
    for (i = 0; i < MEM_HEIGHT; i = i + 1)
      mem[i] = {MEM_WIDTH{1'b0}};
  end
`endif
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emaa_ !== ARM_REF_EMAA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emaa is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emaa", emaa_, ARM_REF_EMAA_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_) begin
      if(emawa_ !== ARM_REF_EMAWA_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emawa is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emawa", emawa_, ARM_REF_EMAWA_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emasa_ !== ARM_REF_EMASA_VALUE  && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emasa is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emasa", emasa_, ARM_REF_EMASA_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emab_ !== ARM_REF_EMAB_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emab is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emab", emab_, ARM_REF_EMAB_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_) begin
      if(emawb_ !== ARM_REF_EMAWB_VALUE && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emawb is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emawb", emawb_, ARM_REF_EMAWB_VALUE, $time);
  end
  always @ (posedge clka_ or posedge clkb_ ) begin
      if(emasb_ !== ARM_REF_EMASB_VALUE  && (ARM_LOCAL_DISABLE_EMA_CHECK == 0) &&  (((cena_int === 1'b0 &&  clka_ === 1'b1) ||(cenb_int === 1'b0 && clkb_ === 1'b1)) && ret1n_ === 1'b1  && (dftrambyp_int === 1'b0 || dftrambyp_int === 1'b1))) 
      $display("Warning: Set Value for emasb is %d and is not equal to %d in %m at %0t. Please refer README for correct value of emasb", emasb_, ARM_REF_EMASB_VALUE, $time);
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

  function isBit1;
    input bitval;
    begin
      isBit1 = ( bitval===1'b1 ) ? 1'b1 : 1'b0;
    end
  endfunction


task loadmem;
	input [1000*8-1:0] filename;
	reg [BITS-1:0] memld [0:WORDS-1];
	integer i;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
	$readmemb(filename, memld);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  wordtemp = memld[i];
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
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
	reg [8:0] Atemp;
  begin
	dump_file_desc = $fopen(filename_dump);
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  for (i=0;i<WORDS;i=i+1) begin
	  Atemp = i;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xqa = 1'b0; qa_update = 1'b1;
   	$fdisplay(dump_file_desc, "%b", mem_path_A);
  end
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
    $fclose(dump_file_desc);
  end
  endtask

task loadaddr;
	input [8:0] load_addr;
	input [15:0] load_data;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  wordtemp = load_data;
	  Atemp = load_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, wordtemp[15], 3'b000, wordtemp[14], 3'b000, wordtemp[13],
          3'b000, wordtemp[12], 3'b000, wordtemp[11], 3'b000, wordtemp[10], 3'b000, wordtemp[9],
          3'b000, wordtemp[8], 3'b000, wordtemp[7], 3'b000, wordtemp[6], 3'b000, wordtemp[5],
          3'b000, wordtemp[4], 3'b000, wordtemp[3], 3'b000, wordtemp[2], 3'b000, wordtemp[1],
          3'b000, wordtemp[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        mem[row_address] = row;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  	end
  endtask

task dumpaddr;
	output [15:0] dump_data;
	input [8:0] dump_addr;
	reg [BITS-1:0] wordtemp;
	reg [8:0] Atemp;
  begin
`ifdef ARM_BACKDOOR_NOCEN
`else
	if (cena_ === 1'b1 && cenb_ === 1'b1) begin
`endif
	  Atemp = dump_addr;
	  mux_address = (Atemp & 2'b11);
      row_address = (Atemp >> 2);
      row = mem[row_address];
        writeEnable = {16{1'b1}};
        data_out = (row >> (mux_address));
        readLatch0 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xqa = 1'b0; qa_update = 1'b1;
   	dump_data = mem_path_A;
`ifdef ARM_BACKDOOR_NOCEN
`else
  	end
`endif
  end
  endtask


  task readWriteA;
  begin
    if (wena_int !== 1'b1 && dftrambyp_int=== 1'b0 && sea_int === 1'bx) begin
      failedWrite(0);
    end else if (dftrambyp_int=== 1'b0 && sea_int === 1'b1) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_int === 1'b0 && (cena_int === 1'b0 || dftrambyp_int === 1'b1)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(emaa_int & isBit1(dftrambyp_int)), (emawa_int & isBit1(dftrambyp_int)), (emasa_int & isBit1(dftrambyp_int))} === 1'bx) begin
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (^{(cena_int & !isBit1(dftrambyp_int)), emaa_int, emawa_int, emasa_int, ret1n_int} === 1'bx) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if ((aa_int >= WORDS) && (cena_int === 1'b0) && dftrambyp_int === 1'b0) begin
        Xqa = wena_int !== 1'b1 ? 1'b0 : 1'b1; qa_update = wena_int !== 1'b1 ? 1'b0 : 1'b1;
    end else if (cena_int === 1'b0 && (^aa_int) === 1'bx && dftrambyp_int === 1'b0) begin
     if (wena_int !== 1)
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (cena_int === 1'b0 || dftrambyp_int === 1'b1) begin
      if(isBitX(dftrambyp_int) || isBitX(sea_int))
        da_int = {16{1'bx}};

      mux_address = (aa_int & 2'b11);
      row_address = (aa_int >> 2);
      if (dftrambyp_int !== 1'b1) begin
      if (row_address > 67)
        row = {64{1'bx}};
      else
        row = mem[row_address];
      end
      if(isBitX(dftrambyp_int) || (isBitX(wena_int) && dftrambyp_int!==1)) begin
        writeEnable = {16{1'bx}};
        da_int = {16{1'bx}};
      end else
          writeEnable = ~ {16{wena_int}};
      if (wena_int !== 1'b1 || dftrambyp_int === 1'b1 || dftrambyp_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, da_int[15], 3'b000, da_int[14], 3'b000, da_int[13],
          3'b000, da_int[12], 3'b000, da_int[11], 3'b000, da_int[10], 3'b000, da_int[9],
          3'b000, da_int[8], 3'b000, da_int[7], 3'b000, da_int[6], 3'b000, da_int[5],
          3'b000, da_int[4], 3'b000, da_int[3], 3'b000, da_int[2], 3'b000, da_int[1],
          3'b000, da_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (dftrambyp_int === 1'b1 && sea_int === 1'b0) begin
        end else if (wena_int !== 1'b1 && dftrambyp_int === 1'b1 && sea_int === 1'bx) begin
        	Xqa = 1'b1; qa_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch0 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch0 = readLatch0;
        mem_path_A = {shifted_readLatch0[15], shifted_readLatch0[14], shifted_readLatch0[13],
          shifted_readLatch0[12], shifted_readLatch0[11], shifted_readLatch0[10], shifted_readLatch0[9],
          shifted_readLatch0[8], shifted_readLatch0[7], shifted_readLatch0[6], shifted_readLatch0[5],
          shifted_readLatch0[4], shifted_readLatch0[3], shifted_readLatch0[2], shifted_readLatch0[1],
          shifted_readLatch0[0]};
        	Xqa = 1'b0; qa_update = 1'b1;
      end
      if (dftrambyp_int === 1'b1) begin
        	Xqa = 1'b0; qa_update = 1'b1;
      end
      if( isBitX(wena_int) && dftrambyp_int !== 1'b1) begin
        Xqa = 1'b1; qa_update = 1'b1;
      end
      if( isBitX(dftrambyp_int) ) begin
        Xqa = 1'b1; qa_update = 1'b1;
      end
      if( isBitX(sea_int) && dftrambyp_int === 1'b1 ) begin
        Xqa = 1'b1; qa_update = 1'b1;
      end
    end
  end
  endtask
  always @ (cena_ or tcena_ or tena_ or dftrambyp_ or clka_) begin
  	if(clka_ == 1'b0) begin
  		cena_p2 = cena_;
  		tcena_p2 = tcena_;
  		dftrambyp_p2 = dftrambyp_;
  	end
  end

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
`ifdef POWER_PINS
  always @ (ret1n_ or VDDPE or VDDCE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_a == 1'b1 && (cena_ === 1'bx || tcena_ === 1'bx || dftrambyp_ === 1'bx || clka_ === 1'bx)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && (cena_p2 === 1'b0 || tcena_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && (cena_p2 === 1'b0 || tcena_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_a = 1;
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(0);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
        Xqa = 1'b1; qa_update = 1'b1;
      cena_int = 1'bx;
      wena_int = 1'bx;
      aa_int = {9{1'bx}};
      da_int = {16{1'bx}};
      emaa_int = {3{1'bx}};
      emawa_int = {2{1'bx}};
      emasa_int = 1'bx;
      tena_int = 1'bx;
      tcena_int = 1'bx;
      twena_int = 1'bx;
      taa_int = {9{1'bx}};
      tda_int = {16{1'bx}};
      ret1n_int = 1'bx;
      sea_int = 1'bx;
      dftrambyp_int = 1'bx;
      colldisn_int = 1'bx;
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_a == 1'b1) begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_a = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        Xqa = 1'b1; qa_update = 1'b1;
      cena_int = 1'bx;
      wena_int = 1'bx;
      aa_int = {9{1'bx}};
      da_int = {16{1'bx}};
      emaa_int = {3{1'bx}};
      emawa_int = {2{1'bx}};
      emasa_int = 1'bx;
      tena_int = 1'bx;
      tcena_int = 1'bx;
      twena_int = 1'bx;
      taa_int = {9{1'bx}};
      tda_int = {16{1'bx}};
      ret1n_int = 1'bx;
      sea_int = 1'bx;
      dftrambyp_int = 1'bx;
      colldisn_int = 1'bx;
    end
    ret1n_int = ret1n_;
    #0;
        qa_update = 1'b0;
  end


  always @ clka_ begin
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
  if (ret1n_ == 1'b0) begin
`else     
  if (ret1n_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((clka_ === 1'bx || clka_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if ((clka_ === 1'b1 || clka_ === 1'b0) && LAST_clka === 1'bx) begin
       da_sh_update = 1'b0;  Xda_sh = 1'b0;
       Xqa = 1'b0; qa_update = 1'b0; 
    end else if (clka_ === 1'b1 && LAST_clka === 1'b0) begin
      sea_int = sea_;
      dftrambyp_int = dftrambyp_;
      cena_int = tena_ ? cena_ : tcena_;
      emaa_int = emaa_;
      emawa_int = emawa_;
      emasa_int = emasa_;
      tena_int = tena_;
      twena_int = twena_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cena_int != 1'b1) begin
        wena_int = tena_ ? wena_ : twena_;
        aa_int = tena_ ? aa_ : taa_;
        da_int = tena_ ? da_ : tda_;
        tcena_int = tcena_;
        taa_int = taa_;
        tda_int = tda_;
        dftrambyp_int = dftrambyp_;
      end
      clk0_int = 1'b0;
      if (dftrambyp_=== 1'b1 && sea_ === 1'b1) begin
        Xqa = 1'b0; qa_update = 1'b1;
      end else begin
      cena_int = tena_ ? cena_ : tcena_;
      emaa_int = emaa_;
      emawa_int = emawa_;
      emasa_int = emasa_;
      tena_int = tena_;
      twena_int = twena_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cena_int != 1'b1) begin
        wena_int = tena_ ? wena_ : twena_;
        aa_int = tena_ ? aa_ : taa_;
        da_int = tena_ ? da_ : tda_;
        tcena_int = tcena_;
        taa_int = taa_;
        tda_int = tda_;
        dftrambyp_int = dftrambyp_;
      end
      clk0_int = 1'b0;
      if (cena_int === 1'b0) previous_clka = $realtime;
    readWriteA;
      end
    #0;
      if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && colldisn_int === 1'b1 && row_contention(aa_int,
        ab_int, wena_int, wenb_int)) begin
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
	      if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          da_int = {16{1'bx}};
          readWriteA;
          db_int = {16{1'bx}};
          readWriteB;
	      end
        end else if (wena_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqb = 1'b1; qb_update = 1'b1;
		end
        end else if (wenb_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqa = 1'b1; qa_update = 1'b1;
		end
        end else begin
          readWriteB;
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          readWriteB;
          readWriteA;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(wena_int !== 1'b1) && (wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((wena_int !== 1'b1) && !(wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && (colldisn_int === 1'b0 || colldisn_int 
       === 1'bx)  && row_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
        if (wenb_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          db_int = {16{1'bx}};
          readWriteB;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        Xqb = 1'b1; qb_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (wena_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          da_int = {16{1'bx}};
          readWriteA;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        Xqa = 1'b1; qa_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (clka_ === 1'b0 && LAST_clka === 1'b1) begin
      qa_update = 1'b0;
      da_sh_update = 1'b0;
      Xqa = 1'b0;
    end
  end
    LAST_clka = clka_;
  end

  reg globalNotifier0;
  initial globalNotifier0 = 1'b0;

  always @ globalNotifier0 begin
    if ($realtime == 0) begin
    end else if ((emaa_int[0] === 1'bx & dftrambyp_int === 1'b1) || (emaa_int[1] === 1'bx & dftrambyp_int === 1'b1) || 
      (emaa_int[2] === 1'bx & dftrambyp_int === 1'b1) || (emasa_int === 1'bx & dftrambyp_int === 1'b1) || 
      (emawa_int[0] === 1'bx & dftrambyp_int === 1'b1) || (emawa_int[1] === 1'bx & dftrambyp_int === 1'b1)
      ) begin
        Xqa = 1'b1; qa_update = 1'b1;
    end else if ((cena_int === 1'bx & dftrambyp_int === 1'b0) || clk0_int === 1'bx || 
      emaa_int[0] === 1'bx || emaa_int[1] === 1'bx || emaa_int[2] === 1'bx || emasa_int === 1'bx || 
      emawa_int[0] === 1'bx || emawa_int[1] === 1'bx || ret1n_int === 1'bx) begin
        Xqa = 1'b1; qa_update = 1'b1;
      failedWrite(0);
    end else if (tena_int === 1'bx) begin
      if(((cena_ === 1'b1 & tcena_ === 1'b1) & dftrambyp_int === 1'b0) | (dftrambyp_int === 1'b1 & sea_int === 1'b1)) begin
      end else begin
        Xqa = 1'b1; qa_update = 1'b1;
      if (dftrambyp_int === 1'b0) begin
          failedWrite(0);
      end
      end
    end else if (cena_int === 1'b0 && (^aa_int) === 1'bx && dftrambyp_int === 1'b0) begin
        failedWrite(0);
        Xqa = 1'b1; qa_update = 1'b1;
    end else if  (cont_flag0_int === 1'bx && colldisn_int === 1'b1 &&  (cena_int !== 1'b1 && ((tenb_ ? cenb_ : tcenb_) !== 1'b1) && dftrambyp_ !== 1'b1) 
     && row_contention(tenb_ ? ab_ : tab_, aa_int, wena_int, tenb_ ? wenb_ : twenb_)) begin
      cont_flag0_int = 1'b0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
	      if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          da_int = {16{1'bx}};
          readWriteA;
          db_int = {16{1'bx}};
          readWriteB;
	      end
        end else if (wena_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqb = 1'b1; qb_update = 1'b1;
		end
        end else if (wenb_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqa = 1'b1; qa_update = 1'b1;
		end
        end else begin
          readWriteB;
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          readWriteB;
          readWriteA;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(wena_int !== 1'b1) && (wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((wena_int !== 1'b1) && !(wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
    end else if  ((cena_int !== 1'b1 && ((tenb_ ? cenb_ : tcenb_) !== 1'b1) && dftrambyp_ !== 1'b1) && cont_flag0_int === 1'bx && (colldisn_int === 1'b0 
     || colldisn_int === 1'bx) && row_contention(tenb_ ? ab_ : tab_, aa_int, wena_int, tenb_ ? wenb_ : twenb_)) begin
      cont_flag0_int = 1'b0;
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
        if (wenb_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          db_int = {16{1'bx}};
          readWriteB;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        Xqb = 1'b1; qb_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE_1 = 1;
          READ_READ_1 = 1;
        end
        if (wena_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          da_int = {16{1'bx}};
          readWriteA;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        Xqa = 1'b1; qa_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      #0;#0;
      readWriteA;
   end
      #0;#0;#0;
        Xqa = 1'b0; qa_update = 1'b0;
    globalNotifier0 = 1'b0;
  end

  assign sia_int = sea_ ? sia_ : {2{1'b0}};
  assign da_int_bmux = tena_ ? da_ : tda_;

  datapath_latch_sramdp_272_16 uDQA0 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(sia_int[0]), .D(da_int_bmux[0]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[0]), .XQ(Xqa), .Q(qa_int[0]));
  datapath_latch_sramdp_272_16 uDQA1 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[0]), .D(da_int_bmux[1]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[1]), .XQ(Xqa), .Q(qa_int[1]));
  datapath_latch_sramdp_272_16 uDQA2 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[1]), .D(da_int_bmux[2]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[2]), .XQ(Xqa), .Q(qa_int[2]));
  datapath_latch_sramdp_272_16 uDQA3 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[2]), .D(da_int_bmux[3]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[3]), .XQ(Xqa), .Q(qa_int[3]));
  datapath_latch_sramdp_272_16 uDQA4 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[3]), .D(da_int_bmux[4]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[4]), .XQ(Xqa), .Q(qa_int[4]));
  datapath_latch_sramdp_272_16 uDQA5 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[4]), .D(da_int_bmux[5]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[5]), .XQ(Xqa), .Q(qa_int[5]));
  datapath_latch_sramdp_272_16 uDQA6 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[5]), .D(da_int_bmux[6]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[6]), .XQ(Xqa), .Q(qa_int[6]));
  datapath_latch_sramdp_272_16 uDQA7 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[6]), .D(da_int_bmux[7]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[7]), .XQ(Xqa), .Q(qa_int[7]));
  datapath_latch_sramdp_272_16 uDQA8 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[9]), .D(da_int_bmux[8]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[8]), .XQ(Xqa), .Q(qa_int[8]));
  datapath_latch_sramdp_272_16 uDQA9 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[10]), .D(da_int_bmux[9]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[9]), .XQ(Xqa), .Q(qa_int[9]));
  datapath_latch_sramdp_272_16 uDQA10 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[11]), .D(da_int_bmux[10]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[10]), .XQ(Xqa), .Q(qa_int[10]));
  datapath_latch_sramdp_272_16 uDQA11 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[12]), .D(da_int_bmux[11]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[11]), .XQ(Xqa), .Q(qa_int[11]));
  datapath_latch_sramdp_272_16 uDQA12 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[13]), .D(da_int_bmux[12]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[12]), .XQ(Xqa), .Q(qa_int[12]));
  datapath_latch_sramdp_272_16 uDQA13 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[14]), .D(da_int_bmux[13]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[13]), .XQ(Xqa), .Q(qa_int[13]));
  datapath_latch_sramdp_272_16 uDQA14 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(qa_int[15]), .D(da_int_bmux[14]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[14]), .XQ(Xqa), .Q(qa_int[14]));
  datapath_latch_sramdp_272_16 uDQA15 (.CLK(clka), .Q_update(qa_update), .D_update(da_sh_update), .SE(sea_), .SI(sia_int[1]), .D(da_int_bmux[15]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_A[15]), .XQ(Xqa), .Q(qa_int[15]));



  task readWriteB;
  begin
    if (wenb_int !== 1'b1 && dftrambyp_int=== 1'b0 && seb_int === 1'bx) begin
      failedWrite(1);
    end else if (dftrambyp_int=== 1'b0 && seb_int === 1'b1) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_int === 1'bx || ret1n_int === 1'bz) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_int === 1'b0 && (cenb_int === 1'b0 || dftrambyp_int === 1'b1)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_int === 1'b0) begin
      // no cycle in retention mode
    end else if (^{(emab_int & isBit1(dftrambyp_int)), (emawb_int & isBit1(dftrambyp_int)), (emasb_int & isBit1(dftrambyp_int))} === 1'bx) begin
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (^{(cenb_int & !isBit1(dftrambyp_int)), emab_int, emawb_int, emasb_int, ret1n_int} === 1'bx) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if ((ab_int >= WORDS) && (cenb_int === 1'b0) && dftrambyp_int === 1'b0) begin
        Xqb = wenb_int !== 1'b1 ? 1'b0 : 1'b1; qb_update = wenb_int !== 1'b1 ? 1'b0 : 1'b1;
    end else if (cenb_int === 1'b0 && (^ab_int) === 1'bx && dftrambyp_int === 1'b0) begin
     if (wenb_int !== 1)
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (cenb_int === 1'b0 || dftrambyp_int === 1'b1) begin
      if(isBitX(dftrambyp_int) || isBitX(seb_int))
        db_int = {16{1'bx}};

      mux_address = (ab_int & 2'b11);
      row_address = (ab_int >> 2);
      if (dftrambyp_int !== 1'b1) begin
      if (row_address > 67)
        row = {64{1'bx}};
      else
        row = mem[row_address];
      end
      if(isBitX(dftrambyp_int) || (isBitX(wenb_int) && dftrambyp_int!==1)) begin
        writeEnable = {16{1'bx}};
        db_int = {16{1'bx}};
      end else
          writeEnable = ~ {16{wenb_int}};
      if (wenb_int !== 1'b1 || dftrambyp_int === 1'b1 || dftrambyp_int === 1'bx) begin
        row_mask =  ( {3'b000, writeEnable[15], 3'b000, writeEnable[14], 3'b000, writeEnable[13],
          3'b000, writeEnable[12], 3'b000, writeEnable[11], 3'b000, writeEnable[10],
          3'b000, writeEnable[9], 3'b000, writeEnable[8], 3'b000, writeEnable[7], 3'b000, writeEnable[6],
          3'b000, writeEnable[5], 3'b000, writeEnable[4], 3'b000, writeEnable[3], 3'b000, writeEnable[2],
          3'b000, writeEnable[1], 3'b000, writeEnable[0]} << mux_address);
        new_data =  ( {3'b000, db_int[15], 3'b000, db_int[14], 3'b000, db_int[13],
          3'b000, db_int[12], 3'b000, db_int[11], 3'b000, db_int[10], 3'b000, db_int[9],
          3'b000, db_int[8], 3'b000, db_int[7], 3'b000, db_int[6], 3'b000, db_int[5],
          3'b000, db_int[4], 3'b000, db_int[3], 3'b000, db_int[2], 3'b000, db_int[1],
          3'b000, db_int[0]} << mux_address);
        row = (row & ~row_mask) | (row_mask & (~row_mask | new_data));
        if (dftrambyp_int === 1'b1 && seb_int === 1'b0) begin
        end else if (wenb_int !== 1'b1 && dftrambyp_int === 1'b1 && seb_int === 1'bx) begin
        	Xqb = 1'b1; qb_update = 1'b1;
        end else begin
        mem[row_address] = row;
        end
      end else begin
        data_out = (row >> (mux_address%4));
        readLatch1 = {data_out[60], data_out[56], data_out[52], data_out[48], data_out[44],
          data_out[40], data_out[36], data_out[32], data_out[28], data_out[24], data_out[20],
          data_out[16], data_out[12], data_out[8], data_out[4], data_out[0]};
        shifted_readLatch1 = readLatch1;
        mem_path_B = {shifted_readLatch1[15], shifted_readLatch1[14], shifted_readLatch1[13],
          shifted_readLatch1[12], shifted_readLatch1[11], shifted_readLatch1[10], shifted_readLatch1[9],
          shifted_readLatch1[8], shifted_readLatch1[7], shifted_readLatch1[6], shifted_readLatch1[5],
          shifted_readLatch1[4], shifted_readLatch1[3], shifted_readLatch1[2], shifted_readLatch1[1],
          shifted_readLatch1[0]};
        	Xqb = 1'b0; qb_update = 1'b1;
      end
      if (dftrambyp_int === 1'b1) begin
        	Xqb = 1'b0; qb_update = 1'b1;
      end
      if( isBitX(wenb_int) && dftrambyp_int !== 1'b1) begin
        Xqb = 1'b1; qb_update = 1'b1;
      end
      if( isBitX(dftrambyp_int) ) begin
        Xqb = 1'b1; qb_update = 1'b1;
      end
      if( isBitX(seb_int) && dftrambyp_int === 1'b1 ) begin
        Xqb = 1'b1; qb_update = 1'b1;
      end
    end
  end
  endtask
  always @ (cenb_ or tcenb_ or tenb_ or dftrambyp_ or clkb_) begin
  	if(clkb_ == 1'b0) begin
  		cenb_p2 = cenb_;
  		tcenb_p2 = tcenb_;
  		dftrambyp_p2 = dftrambyp_;
  	end
  end

`ifdef POWER_PINS
  always @ (ret1n_ or VDDPE or VDDCE) begin
`else     
  always @ ret1n_ begin
`endif
`ifdef POWER_PINS
    if (ret1n_ == 1'b1 && ret1n_int == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 && pre_charge_st_b == 1'b1 && (cenb_ === 1'bx || tcenb_ === 1'bx || dftrambyp_ === 1'bx || clkb_ === 1'bx)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end
`else     
`endif
`ifdef POWER_PINS
`else     
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`endif
    if (ret1n_ === 1'bx || ret1n_ === 1'bz) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_ === 1'b0 && ret1n_int === 1'b1 && (cenb_p2 === 1'b0 || tcenb_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if (ret1n_ === 1'b1 && ret1n_int === 1'b0 && (cenb_p2 === 1'b0 || tcenb_p2 === 1'b0 || dftrambyp_p2 === 1'b1)) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end
`ifdef POWER_PINS
    if (ret1n_ == 1'b0 && VDDCE == 1'b1 && VDDPE == 1'b1) begin
      pre_charge_st_b = 1;
      pre_charge_st = 1;
    end else if (ret1n_ == 1'b0 && VDDPE == 1'b0) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
      if (VDDCE != 1'b1) begin
        failedWrite(1);
      end
`else     
    if (ret1n_ == 1'b0) begin
`endif
        Xqb = 1'b1; qb_update = 1'b1;
      cenb_int = 1'bx;
      wenb_int = 1'bx;
      ab_int = {9{1'bx}};
      db_int = {16{1'bx}};
      emab_int = {3{1'bx}};
      emawb_int = {2{1'bx}};
      emasb_int = 1'bx;
      tenb_int = 1'bx;
      tcenb_int = 1'bx;
      twenb_int = 1'bx;
      tab_int = {9{1'bx}};
      tdb_int = {16{1'bx}};
      ret1n_int = 1'bx;
      seb_int = 1'bx;
      colldisn_int = 1'bx;
`ifdef POWER_PINS
    end else if (ret1n_ == 1'b1 && VDDCE == 1'b1 && VDDPE == 1'b1 &&  pre_charge_st_b == 1'b1) begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
    end else begin
      pre_charge_st_b = 0;
      pre_charge_st = 0;
`else     
    end else begin
`endif
        Xqb = 1'b1; qb_update = 1'b1;
      cenb_int = 1'bx;
      wenb_int = 1'bx;
      ab_int = {9{1'bx}};
      db_int = {16{1'bx}};
      emab_int = {3{1'bx}};
      emawb_int = {2{1'bx}};
      emasb_int = 1'bx;
      tenb_int = 1'bx;
      tcenb_int = 1'bx;
      twenb_int = 1'bx;
      tab_int = {9{1'bx}};
      tdb_int = {16{1'bx}};
      ret1n_int = 1'bx;
      seb_int = 1'bx;
      colldisn_int = 1'bx;
    end
    ret1n_int = ret1n_;
    #0;
        qb_update = 1'b0;
  end


  always @ clkb_ begin
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
  if (ret1n_ == 1'b0) begin
`else     
  if (ret1n_ == 1'b0) begin
`endif
      // no cycle in retention mode
  end else begin
    if ((clkb_ === 1'bx || clkb_ === 1'bz) && ret1n_ !== 1'b0) begin
      failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if ((clkb_ === 1'b1 || clkb_ === 1'b0) && LAST_clkb === 1'bx) begin
       db_sh_update = 1'b0;  Xdb_sh = 1'b0;
       Xqb = 1'b0; qb_update = 1'b0; 
    end else if (clkb_ === 1'b1 && LAST_clkb === 1'b0) begin
      dftrambyp_int = dftrambyp_;
      seb_int = seb_;
      cenb_int = tenb_ ? cenb_ : tcenb_;
      emab_int = emab_;
      emawb_int = emawb_;
      emasb_int = emasb_;
      tenb_int = tenb_;
      twenb_int = twenb_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cenb_int != 1'b1) begin
        wenb_int = tenb_ ? wenb_ : twenb_;
        ab_int = tenb_ ? ab_ : tab_;
        db_int = tenb_ ? db_ : tdb_;
        tcenb_int = tcenb_;
        tab_int = tab_;
        tdb_int = tdb_;
      end
      clk1_int = 1'b0;
      if (dftrambyp_=== 1'b1 && seb_ === 1'b1) begin
        Xqb = 1'b0; qb_update = 1'b1;
      end else begin
      cenb_int = tenb_ ? cenb_ : tcenb_;
      emab_int = emab_;
      emawb_int = emawb_;
      emasb_int = emasb_;
      tenb_int = tenb_;
      twenb_int = twenb_;
      ret1n_int = ret1n_;
      colldisn_int = colldisn_;
      if (dftrambyp_=== 1'b1 || cenb_int != 1'b1) begin
        wenb_int = tenb_ ? wenb_ : twenb_;
        ab_int = tenb_ ? ab_ : tab_;
        db_int = tenb_ ? db_ : tdb_;
        tcenb_int = tcenb_;
        tab_int = tab_;
        tdb_int = tdb_;
      end
      clk1_int = 1'b0;
      if (cenb_int === 1'b0) previous_clkb = $realtime;
    readWriteB;
      end
    #0;
      if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && colldisn_int === 1'b1 && row_contention(aa_int,
        ab_int, wena_int, wenb_int)) begin
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
	      if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          da_int = {16{1'bx}};
          readWriteA;
          db_int = {16{1'bx}};
          readWriteB;
	      end
        end else if (wena_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqb = 1'b1; qb_update = 1'b1;
		end
        end else if (wenb_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqa = 1'b1; qa_update = 1'b1;
		end
        end else begin
          readWriteA;
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          readWriteA;
          readWriteB;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(wena_int !== 1'b1) && (wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((wena_int !== 1'b1) && !(wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
      end else if (((previous_clka == previous_clkb)) && (cena_int !== 1'b1 && cenb_int !== 1'b1 && dftrambyp_ !== 1'b1) && (colldisn_int === 1'b0 || colldisn_int 
       === 1'bx)  && row_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
        if (wena_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          da_int = {16{1'bx}};
          readWriteA;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        Xqa = 1'b1; qa_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (wenb_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          db_int = {16{1'bx}};
          readWriteB;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        Xqb = 1'b1; qb_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
      end
    end else if (clkb_ === 1'b0 && LAST_clkb === 1'b1) begin
      qb_update = 1'b0;
      db_sh_update = 1'b0;
      Xqb = 1'b0;
    end
  end
    LAST_clkb = clkb_;
  end

  reg globalNotifier1;
  initial globalNotifier1 = 1'b0;

  always @ globalNotifier1 begin
    if ($realtime == 0) begin
    end else if ((emab_int[0] === 1'bx & dftrambyp_int === 1'b1) || (emab_int[1] === 1'bx & dftrambyp_int === 1'b1) || 
      (emab_int[2] === 1'bx & dftrambyp_int === 1'b1) || (emasb_int === 1'bx & dftrambyp_int === 1'b1) || 
      (emawb_int[0] === 1'bx & dftrambyp_int === 1'b1) || (emawb_int[1] === 1'bx & dftrambyp_int === 1'b1)
      ) begin
        Xqb = 1'b1; qb_update = 1'b1;
    end else if ((cenb_int === 1'bx & dftrambyp_int === 1'b0) || clk1_int === 1'bx || 
      emab_int[0] === 1'bx || emab_int[1] === 1'bx || emab_int[2] === 1'bx || emasb_int === 1'bx || 
      emawb_int[0] === 1'bx || emawb_int[1] === 1'bx || ret1n_int === 1'bx) begin
        Xqb = 1'b1; qb_update = 1'b1;
      failedWrite(1);
    end else if (tenb_int === 1'bx) begin
      if(((cenb_ === 1'b1 & tcenb_ === 1'b1) & dftrambyp_int === 1'b0) | (dftrambyp_int === 1'b1 & seb_int === 1'b1)) begin
      end else begin
        Xqb = 1'b1; qb_update = 1'b1;
      if (dftrambyp_int === 1'b0) begin
          failedWrite(1);
      end
      end
    end else if (cenb_int === 1'b0 && (^ab_int) === 1'bx && dftrambyp_int === 1'b0) begin
        failedWrite(1);
        Xqb = 1'b1; qb_update = 1'b1;
    end else if  (cont_flag1_int === 1'bx && colldisn_int === 1'b1 &&  (cenb_int !== 1'b1 && ((tena_ ? cena_ : tcena_) !== 1'b1) && dftrambyp_ !== 1'b1) 
     && row_contention(tena_ ? aa_ : taa_, ab_int, wenb_int, tena_ ? wena_ : twena_)) begin
      cont_flag1_int = 1'b0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
	      if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: both writes fail in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          WRITE_WRITE = 1;
          da_int = {16{1'bx}};
          readWriteA;
          db_int = {16{1'bx}};
          readWriteB;
	      end
        end else if (wena_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write A succeeds, read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqb = 1'b1; qb_update = 1'b1;
		end
        end else if (wenb_int !== 1'b1) begin
		if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: write B succeeds, read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE = 1;
        Xqa = 1'b1; qa_update = 1'b1;
		end
        end else begin
          readWriteA;
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: both reads succeed in %m at %0t",ASSERT_PREFIX, $time);
`endif
          COL_CC = 1;
          READ_READ = 1;
        end
        if (!is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          readWriteA;
          readWriteB;
        if (wena_int !== 1'b1 && wenb_int !== 1'b1) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          WRITE_WRITE = 1;
        end else if (!(wena_int !== 1'b1) && (wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: write B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else if ((wena_int !== 1'b1) && !(wenb_int !== 1'b1)) begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, write A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_WRITE = 1;
        end else begin
`ifdef ARM_MESSAGES
          $display("%s row contention: read B succeeds, read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
        end
        end
    end else if  ((cenb_int !== 1'b1 && ((tena_ ? cena_ : tcena_) !== 1'b1) && dftrambyp_ !== 1'b1) && cont_flag1_int === 1'bx && (colldisn_int === 1'b0 
     || colldisn_int === 1'bx) && row_contention(tena_ ? aa_ : taa_, ab_int, wenb_int, tena_ ? wena_ : twena_)) begin
      cont_flag1_int = 1'b0;
          ROW_CC = 1;
          READ_READ_1 = 0;
          READ_WRITE_1 = 0;
          WRITE_WRITE_1 = 0;
        if (col_contention(aa_int, ab_int)) begin
          COL_CC = 1;
        end
        if (wena_int !== 1'b1) begin
          $display("%s contention: write A fails in %m at %0t",ASSERT_PREFIX, $time);
          WRITE_WRITE_1 = 1;
          da_int = {16{1'bx}};
          readWriteA;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read A fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          READ_WRITE_1 = 1;
        Xqa = 1'b1; qa_update = 1'b1;
        end else begin
          readWriteA;
`ifdef ARM_MESSAGES
          $display("%s contention: read A succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          READ_READ_1 = 1;
          READ_WRITE_1 = 1;
        end
        if (wenb_int !== 1'b1) begin
          $display("%s contention: write B fails in %m at %0t",ASSERT_PREFIX, $time);
          if(WRITE_WRITE_1)
            WRITE_WRITE = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
          db_int = {16{1'bx}};
          readWriteB;
        end else if (is_contention(aa_int, ab_int, wena_int, wenb_int)) begin
          $display("%s contention: read B fails in %m at %0t",ASSERT_PREFIX, $time);
          COL_CC = 1;
          if(READ_WRITE_1) begin
            READ_WRITE = 1;
            READ_WRITE_1 = 0;
          end
        Xqb = 1'b1; qb_update = 1'b1;
        end else begin
          readWriteB;
`ifdef ARM_MESSAGES
          $display("%s contention: read B succeeds in %m at %0t",ASSERT_PREFIX, $time);
`endif
          if(READ_READ_1) begin
            READ_READ = 1;
            READ_READ_1 = 0;
          end
        end
    end else begin
      #0;#0;
      readWriteB;
   end
      #0;#0;#0;
        Xqb = 1'b0; qb_update = 1'b0;
    globalNotifier1 = 1'b0;
  end

  assign sib_int = seb_ ? sib_ : {2{1'b0}};
  assign db_int_bmux = tenb_ ? db_ : tdb_;

  datapath_latch_sramdp_272_16 uDQB0 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(sib_int[0]), .D(db_int_bmux[0]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[0]), .XQ(Xqb), .Q(qb_int[0]));
  datapath_latch_sramdp_272_16 uDQB1 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[0]), .D(db_int_bmux[1]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[1]), .XQ(Xqb), .Q(qb_int[1]));
  datapath_latch_sramdp_272_16 uDQB2 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[1]), .D(db_int_bmux[2]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[2]), .XQ(Xqb), .Q(qb_int[2]));
  datapath_latch_sramdp_272_16 uDQB3 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[2]), .D(db_int_bmux[3]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[3]), .XQ(Xqb), .Q(qb_int[3]));
  datapath_latch_sramdp_272_16 uDQB4 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[3]), .D(db_int_bmux[4]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[4]), .XQ(Xqb), .Q(qb_int[4]));
  datapath_latch_sramdp_272_16 uDQB5 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[4]), .D(db_int_bmux[5]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[5]), .XQ(Xqb), .Q(qb_int[5]));
  datapath_latch_sramdp_272_16 uDQB6 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[5]), .D(db_int_bmux[6]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[6]), .XQ(Xqb), .Q(qb_int[6]));
  datapath_latch_sramdp_272_16 uDQB7 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[6]), .D(db_int_bmux[7]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[7]), .XQ(Xqb), .Q(qb_int[7]));
  datapath_latch_sramdp_272_16 uDQB8 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[9]), .D(db_int_bmux[8]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[8]), .XQ(Xqb), .Q(qb_int[8]));
  datapath_latch_sramdp_272_16 uDQB9 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[10]), .D(db_int_bmux[9]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[9]), .XQ(Xqb), .Q(qb_int[9]));
  datapath_latch_sramdp_272_16 uDQB10 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[11]), .D(db_int_bmux[10]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[10]), .XQ(Xqb), .Q(qb_int[10]));
  datapath_latch_sramdp_272_16 uDQB11 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[12]), .D(db_int_bmux[11]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[11]), .XQ(Xqb), .Q(qb_int[11]));
  datapath_latch_sramdp_272_16 uDQB12 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[13]), .D(db_int_bmux[12]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[12]), .XQ(Xqb), .Q(qb_int[12]));
  datapath_latch_sramdp_272_16 uDQB13 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[14]), .D(db_int_bmux[13]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[13]), .XQ(Xqb), .Q(qb_int[13]));
  datapath_latch_sramdp_272_16 uDQB14 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(qb_int[15]), .D(db_int_bmux[14]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[14]), .XQ(Xqb), .Q(qb_int[14]));
  datapath_latch_sramdp_272_16 uDQB15 (.CLK(clkb), .Q_update(qb_update), .D_update(db_sh_update), .SE(seb_), .SI(sib_int[1]), .D(db_int_bmux[15]), .DFTRAMBYP(dftrambyp_), .mem_path(mem_path_B[15]), .XQ(Xqb), .Q(qb_int[15]));


// If POWER_PINS is defined at Simulator Command Line, it selects the module definition with Power Ports
`ifdef POWER_PINS
 always @ (VDDCE or VDDPE or VSSE) begin
    if (VDDCE === 1'bx || VDDCE === 1'bz)
      $display("Warning: Unknown value for VDDCE %b in %m at %0t", VDDCE, $time);
    if (VDDPE === 1'bx || VDDPE === 1'bz)
      $display("Warning: Unknown value for VDDPE %b in %m at %0t", VDDPE, $time);
    if (VSSE === 1'bx || VSSE === 1'bz)
      $display("Warning: Unknown value for VSSE %b in %m at %0t", VSSE, $time);
 end
`endif

  function row_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
    reg sameRow;
    reg sameMux;
    reg anyWrite;
  begin
    anyWrite = ((& wena) === 1'b1 && (& wenb) === 1'b1) ? 1'b0 : 1'b1;
    sameMux = (aa[1:0] == ab[1:0]) ? 1'b1 : 1'b0;
    if (aa[8:2] == ab[8:2]) begin
      sameRow = 1'b1;
    end else begin
      sameRow = 1'b0;
    end
    if (sameRow == 1'b1 && anyWrite == 1'b1)
      row_contention = 1'b1;
    else if (sameRow == 1'b1 && sameMux == 1'b1)
      row_contention = 1'b1;
    else
      row_contention = 1'b0;
  end
  endfunction

  function col_contention;
    input [8:0] aa;
    input [8:0] ab;
  begin
    if (aa[1:0] == ab[1:0])
      col_contention = 1'b1;
    else
      col_contention = 1'b0;
  end
  endfunction

  function is_contention;
    input [8:0] aa;
    input [8:0] ab;
    input  wena;
    input  wenb;
    reg result;
  begin
    if ((& wena) === 1'b1 && (& wenb) === 1'b1) begin
      result = 1'b0;
    end else if (aa == ab) begin
      result = 1'b1;
    end else begin
      result = 1'b0;
    end
    is_contention = result;
  end
  endfunction

   wire conta_flag = (cena_int !== 1'b1 && ((tenb_ ? cenb_ : tcenb_) !== 1'b1)) && ((colldisn_int === 1'b1 && is_contention(tenb_ ? ab_ : tab_, aa_int, tenb_ ? wenb_ : twenb_, wena_int)) ||
              ((colldisn_int === 1'b0 || colldisn_int === 1'bx) && row_contention(tenb_ ? ab_ : tab_, aa_int, tenb_ ? wenb_ : twenb_, wena_int)));
   wire contb_flag = (cenb_int !== 1'b1 && ((tena_ ? cena_ : tcena_) !== 1'b1)) && ((colldisn_int === 1'b1 && is_contention(tena_ ? aa_ : taa_, ab_int, tena_ ? wena_ : twena_, wenb_int)) ||
              ((colldisn_int === 1'b0 || colldisn_int === 1'bx) && row_contention(tena_ ? aa_ : taa_, ab_int, tena_ ? wena_ : twena_, wenb_int)));

  always @ NOT_cena begin
    cena_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_wena begin
    wena_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa8 begin
    aa_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa7 begin
    aa_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa6 begin
    aa_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa5 begin
    aa_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa4 begin
    aa_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa3 begin
    aa_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa2 begin
    aa_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa1 begin
    aa_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_aa0 begin
    aa_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da15 begin
    da_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da14 begin
    da_int[14] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da13 begin
    da_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da12 begin
    da_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da11 begin
    da_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da10 begin
    da_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da9 begin
    da_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da8 begin
    da_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da7 begin
    da_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da6 begin
    da_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da5 begin
    da_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da4 begin
    da_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da3 begin
    da_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da2 begin
    da_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da1 begin
    da_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_da0 begin
    da_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_cenb begin
    cenb_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_wenb begin
    wenb_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab8 begin
    ab_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab7 begin
    ab_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab6 begin
    ab_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab5 begin
    ab_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab4 begin
    ab_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab3 begin
    ab_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab2 begin
    ab_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab1 begin
    ab_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_ab0 begin
    ab_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db15 begin
    db_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db14 begin
    db_int[14] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db13 begin
    db_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db12 begin
    db_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db11 begin
    db_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db10 begin
    db_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db9 begin
    db_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db8 begin
    db_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db7 begin
    db_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db6 begin
    db_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db5 begin
    db_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db4 begin
    db_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db3 begin
    db_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db2 begin
    db_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db1 begin
    db_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_db0 begin
    db_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_emaa2 begin
    emaa_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emaa1 begin
    emaa_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emaa0 begin
    emaa_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emawa1 begin
    emawa_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emawa0 begin
    emawa_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emasa begin
    emasa_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_emab2 begin
    emab_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_emab1 begin
    emab_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_emab0 begin
    emab_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_emawb1 begin
    emawb_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_emawb0 begin
    emawb_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_emasb begin
    emasb_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tena begin
    tena_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tcena begin
    cena_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_twena begin
    wena_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa8 begin
    aa_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa7 begin
    aa_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa6 begin
    aa_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa5 begin
    aa_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa4 begin
    aa_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa3 begin
    aa_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa2 begin
    aa_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa1 begin
    aa_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_taa0 begin
    aa_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda15 begin
    da_int[15] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda14 begin
    da_int[14] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda13 begin
    da_int[13] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda12 begin
    da_int[12] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda11 begin
    da_int[11] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda10 begin
    da_int[10] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda9 begin
    da_int[9] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda8 begin
    da_int[8] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda7 begin
    da_int[7] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda6 begin
    da_int[6] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda5 begin
    da_int[5] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda4 begin
    da_int[4] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda3 begin
    da_int[3] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda2 begin
    da_int[2] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda1 begin
    da_int[1] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tda0 begin
    da_int[0] = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_tenb begin
    tenb_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tcenb begin
    cenb_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_twenb begin
    wenb_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab8 begin
    ab_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab7 begin
    ab_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab6 begin
    ab_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab5 begin
    ab_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab4 begin
    ab_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab3 begin
    ab_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab2 begin
    ab_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab1 begin
    ab_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tab0 begin
    ab_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb15 begin
    db_int[15] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb14 begin
    db_int[14] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb13 begin
    db_int[13] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb12 begin
    db_int[12] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb11 begin
    db_int[11] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb10 begin
    db_int[10] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb9 begin
    db_int[9] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb8 begin
    db_int[8] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb7 begin
    db_int[7] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb6 begin
    db_int[6] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb5 begin
    db_int[5] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb4 begin
    db_int[4] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb3 begin
    db_int[3] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb2 begin
    db_int[2] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb1 begin
    db_int[1] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_tdb0 begin
    db_int[0] = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_sia1 begin
        Xqa = 1'b1; qa_update = 1'b1;
  end
  always @ NOT_sia0 begin
        Xqa = 1'b1; qa_update = 1'b1;
  end
  always @ NOT_sea begin
        Xqa = 1'b1; qa_update = 1'b1;
    sea_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_dftrambyp_clkb begin
    dftrambyp_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_dftrambyp_clka begin
    dftrambyp_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_ret1n begin
    ret1n_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_sib1 begin
        Xqb = 1'b1; qb_update = 1'b1;
  end
  always @ NOT_sib0 begin
        Xqb = 1'b1; qb_update = 1'b1;
  end
  always @ NOT_seb begin
        Xqb = 1'b1; qb_update = 1'b1;
    seb_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_colldisn begin
    colldisn_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end

  always @ NOT_clka_PER begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_clka_MINH begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_clka_MINL begin
    clk0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_CONTA begin
    cont_flag0_int = 1'bx;
    if ( globalNotifier0 === 1'b0 ) globalNotifier0 = 1'bx;
  end
  always @ NOT_clkb_PER begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_clkb_MINH begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_clkb_MINL begin
    clk1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end
  always @ NOT_CONTB begin
    cont_flag1_int = 1'bx;
    if ( globalNotifier1 === 1'b0 ) globalNotifier1 = 1'bx;
  end


  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq0aemaa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq0aemaa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq1aemaa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq1aemaa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq0aemaa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq0aemaa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq1aemaa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq1aemaa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1;
  wire conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1;
  wire ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1;
  wire ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq0aemab0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq0aemab0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq1aemab0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq1aemab0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq0aemab0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq0aemab0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq1aemab0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq1aemab0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1;
  wire contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1;
  wire ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp;
  wire ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp;
  wire ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp;
  wire ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp;
  wire ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp;

  wire ret1neq1atenaeq1, ret1neq1atenaeq1acenaeq0, ret1neq1atenaeq1acenaeq0acolldisneq0;
  wire ret1neq1atenaeq1acenaeq0acolldisneq1, ret1neq1atenbeq1, ret1neq1atenbeq1acenbeq0;
  wire ret1neq1atenbeq1acenbeq0acolldisneq0, ret1neq1atenbeq1acenbeq0acolldisneq1;
  wire ret1neq1atenaeq0, ret1neq1atenaeq0atcenaeq0, ret1neq1atenaeq0atcenaeq0acolldisneq0;
  wire ret1neq1atenaeq0atcenaeq0acolldisneq1, ret1neq1atenbeq0, ret1neq1atenbeq0atcenbeq0;
  wire ret1neq1atenbeq0atcenbeq0acolldisneq0, ret1neq1atenbeq0atcenbeq0acolldisneq1;
  wire ret1neq1aseaeq1, ret1neq1asebeq1, ret1neq1, ret1neq1aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcp;
  wire ret1neq1aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcp;

  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&!emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&!emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1 = 
  ret1n&&((!dftrambyp&&((tena&&!cena)||(!tena&&!tcena)))||dftrambyp)&&emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&emawa[0]&&emasa;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq0aemaa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&!emaa[2]&&!emaa[1]&&!emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq0aemaa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&!emaa[2]&&!emaa[1]&&emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq1aemaa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&!emaa[2]&&emaa[1]&&!emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq1aemaa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&!emaa[2]&&emaa[1]&&emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq0aemaa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&emaa[2]&&!emaa[1]&&!emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq0aemaa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&emaa[2]&&!emaa[1]&&emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq1aemaa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&emaa[2]&&emaa[1]&&!emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq1aemaa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&wena)||(!tena&&!tcena&&twena))&&emaa[2]&&emaa[1]&&emaa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&!emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&emaa[0]&&!emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&!emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&!emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&!emaa[1]&&emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&!emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1 = 
  ret1n&&!dftrambyp&&((tena&&!cena&&!wena)||(!tena&&!tcena&&!twena))&&emaa[2]&&emaa[1]&&emaa[0]&&emawa[1]&&emawa[0] && conta_flag;
  assign ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp = 
  ret1n&&tena&&((dftrambyp&&!sea)||(!cena&&!dftrambyp&&!wena));
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&!emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&emawb[1]&&!emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&!emab[2]&&emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1 = 
  ret1n&&((!dftrambyp&&((tenb&&!cenb)||(!tenb&&!tcenb)))||dftrambyp)&&emab[2]&&emab[1]&&emab[0]&&emawb[1]&&emawb[0]&&emasb;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq0aemab0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&!emab[2]&&!emab[1]&&!emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq0aemab0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&!emab[2]&&!emab[1]&&emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq1aemab0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&!emab[2]&&emab[1]&&!emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq1aemab0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&!emab[2]&&emab[1]&&emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq0aemab0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&emab[2]&&!emab[1]&&!emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq0aemab0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&emab[2]&&!emab[1]&&emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq1aemab0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&emab[2]&&emab[1]&&!emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq1aemab0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&wenb)||(!tenb&&!tcenb&&twenb))&&emab[2]&&emab[1]&&emab[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&!emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&!emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&emab[0]&&!emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&emab[0]&&emawb[1]&&!emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&!emab[2]&&emab[1]&&emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&!emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&!emab[1]&&emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&!emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1 = 
  ret1n&&!dftrambyp&&((tenb&&!cenb&&!wenb)||(!tenb&&!tcenb&&!twenb))&&emab[2]&&emab[1]&&emab[0]&&emawb[1]&&emawb[0] && contb_flag;
  assign ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp = 
  ret1n&&tenb&&((dftrambyp&&!seb)||(!cenb&&!dftrambyp&&!wenb));
  assign ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp = 
  ret1n&&(((tena&&!cena&&!dftrambyp)||(!tena&&!tcena&&!dftrambyp))||dftrambyp);
  assign ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp = 
  ret1n&&(((tenb&&!cenb&&!dftrambyp)||(!tenb&&!tcenb&&!dftrambyp))||dftrambyp);
  assign ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp = 
  ret1n&&!tena&&((dftrambyp&&!sea)||(!tcena&&!dftrambyp&&!twena));
  assign ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp = 
  ret1n&&!tenb&&((dftrambyp&&!seb)||(!tcenb&&!dftrambyp&&!twenb));

  assign ret1neq1atenaeq1acenaeq0acolldisneq0 = ret1n&&tena&&!cena&&!colldisn;
  assign ret1neq1atenaeq1acenaeq0acolldisneq1 = ret1n&&tena&&!cena&&colldisn;
  assign ret1neq1atenbeq1acenbeq0acolldisneq0 = ret1n&&tenb&&!cenb&&!colldisn;
  assign ret1neq1atenbeq1acenbeq0acolldisneq1 = ret1n&&tenb&&!cenb&&colldisn;
  assign ret1neq1atenaeq0atcenaeq0acolldisneq0 = ret1n&&!tena&&!tcena&&!colldisn;
  assign ret1neq1atenaeq0atcenaeq0acolldisneq1 = ret1n&&!tena&&!tcena&&colldisn;
  assign ret1neq1atenbeq0atcenbeq0acolldisneq0 = ret1n&&!tenb&&!tcenb&&!colldisn;
  assign ret1neq1atenbeq0atcenbeq0acolldisneq1 = ret1n&&!tenb&&!tcenb&&colldisn;
  assign ret1neq1aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcp = ret1n&&((tena&&!cena)||(!tena&&!tcena));
  assign ret1neq1aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcp = ret1n&&((tenb&&!cenb)||(!tenb&&!tcenb));

  assign ret1neq1atenaeq1acenaeq0 = ret1n&&tena&&!cena;
  assign ret1neq1atenbeq1acenbeq0 = ret1n&&tenb&&!cenb;
  assign ret1neq1atenaeq0atcenaeq0 = ret1n&&!tena&&!tcena;
  assign ret1neq1atenbeq0atcenbeq0 = ret1n&&!tenb&&!tcenb;

  assign ret1neq1atenaeq1 = ret1n&&tena;
  assign ret1neq1atenbeq1 = ret1n&&tenb;
  assign ret1neq1atenaeq0 = ret1n&&!tena;
  assign ret1neq1atenbeq0 = ret1n&&!tenb;
  assign ret1neq1aseaeq1 = ret1n&&sea;
  assign ret1neq1asebeq1 = ret1n&&seb;
  assign ret1neq1 = ret1n;

  specify

    if (dftrambyp == 1'b1 && tena == 1'b1)
       (cena +=> cenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (tcena +=> cenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tcena == 1'b0 && cena == 1'b1)
       (tena +=> cenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tcena == 1'b1 && cena == 1'b0)
       (tena -=> cenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> cenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (wena +=> wenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (twena +=> wenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && twena == 1'b0 && wena == 1'b1)
       (tena +=> wenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && twena == 1'b1 && wena == 1'b0)
       (tena -=> wenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> wenya) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[8] +=> aya[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[7] +=> aya[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[6] +=> aya[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[5] +=> aya[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[4] +=> aya[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[3] +=> aya[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[2] +=> aya[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[1] +=> aya[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b1)
       (aa[0] +=> aya[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[8] +=> aya[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[7] +=> aya[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[6] +=> aya[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[5] +=> aya[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[4] +=> aya[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[3] +=> aya[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[2] +=> aya[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[1] +=> aya[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tena == 1'b0)
       (taa[0] +=> aya[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[8] == 1'b0 && aa[8] == 1'b1)
       (tena +=> aya[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[7] == 1'b0 && aa[7] == 1'b1)
       (tena +=> aya[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[6] == 1'b0 && aa[6] == 1'b1)
       (tena +=> aya[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[5] == 1'b0 && aa[5] == 1'b1)
       (tena +=> aya[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[4] == 1'b0 && aa[4] == 1'b1)
       (tena +=> aya[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[3] == 1'b0 && aa[3] == 1'b1)
       (tena +=> aya[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[2] == 1'b0 && aa[2] == 1'b1)
       (tena +=> aya[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[1] == 1'b0 && aa[1] == 1'b1)
       (tena +=> aya[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[0] == 1'b0 && aa[0] == 1'b1)
       (tena +=> aya[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[8] == 1'b1 && aa[8] == 1'b0)
       (tena -=> aya[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[7] == 1'b1 && aa[7] == 1'b0)
       (tena -=> aya[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[6] == 1'b1 && aa[6] == 1'b0)
       (tena -=> aya[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[5] == 1'b1 && aa[5] == 1'b0)
       (tena -=> aya[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[4] == 1'b1 && aa[4] == 1'b0)
       (tena -=> aya[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[3] == 1'b1 && aa[3] == 1'b0)
       (tena -=> aya[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[2] == 1'b1 && aa[2] == 1'b0)
       (tena -=> aya[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[1] == 1'b1 && aa[1] == 1'b0)
       (tena -=> aya[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && taa[0] == 1'b1 && aa[0] == 1'b0)
       (tena -=> aya[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> aya[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (cenb +=> cenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tcenb +=> cenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tcenb == 1'b0 && cenb == 1'b1)
       (tenb +=> cenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tcenb == 1'b1 && cenb == 1'b0)
       (tenb -=> cenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> cenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (wenb +=> wenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (twenb +=> wenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && twenb == 1'b0 && wenb == 1'b1)
       (tenb +=> wenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && twenb == 1'b1 && wenb == 1'b0)
       (tenb -=> wenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> wenyb) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[8] +=> ayb[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[7] +=> ayb[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[6] +=> ayb[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[5] +=> ayb[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[4] +=> ayb[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[3] +=> ayb[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[2] +=> ayb[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[1] +=> ayb[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b1)
       (ab[0] +=> ayb[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[8] +=> ayb[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[7] +=> ayb[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[6] +=> ayb[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[5] +=> ayb[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[4] +=> ayb[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[3] +=> ayb[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[2] +=> ayb[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[1] +=> ayb[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tenb == 1'b0)
       (tab[0] +=> ayb[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[8] == 1'b0 && ab[8] == 1'b1)
       (tenb +=> ayb[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[7] == 1'b0 && ab[7] == 1'b1)
       (tenb +=> ayb[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[6] == 1'b0 && ab[6] == 1'b1)
       (tenb +=> ayb[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[5] == 1'b0 && ab[5] == 1'b1)
       (tenb +=> ayb[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[4] == 1'b0 && ab[4] == 1'b1)
       (tenb +=> ayb[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[3] == 1'b0 && ab[3] == 1'b1)
       (tenb +=> ayb[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[2] == 1'b0 && ab[2] == 1'b1)
       (tenb +=> ayb[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[1] == 1'b0 && ab[1] == 1'b1)
       (tenb +=> ayb[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[0] == 1'b0 && ab[0] == 1'b1)
       (tenb +=> ayb[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[8] == 1'b1 && ab[8] == 1'b0)
       (tenb -=> ayb[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[7] == 1'b1 && ab[7] == 1'b0)
       (tenb -=> ayb[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[6] == 1'b1 && ab[6] == 1'b0)
       (tenb -=> ayb[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[5] == 1'b1 && ab[5] == 1'b0)
       (tenb -=> ayb[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[4] == 1'b1 && ab[4] == 1'b0)
       (tenb -=> ayb[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[3] == 1'b1 && ab[3] == 1'b0)
       (tenb -=> ayb[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[2] == 1'b1 && ab[2] == 1'b0)
       (tenb -=> ayb[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[1] == 1'b1 && ab[1] == 1'b0)
       (tenb -=> ayb[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b1 && tab[0] == 1'b1 && ab[0] == 1'b0)
       (tenb -=> ayb[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[8]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[7]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[6]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[5]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[4]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[3]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[2]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[1]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1)
       (dftrambyp +=> ayb[0]) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (qa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[15] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[14] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[13] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[12] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[11] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[10] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[9] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[8] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[7] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[6] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[5] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[4] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[3] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[2] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (qb[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b0 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b0)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b0 && emaa[0] == 1'b1)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b0)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tena == 1'b1 && cena == 1'b0 && wena == 1'b1) || (tena == 1'b0 && tcena == 1'b0 && twena == 1'b1)) && emaa[2] == 1'b1 && emaa[1] == 1'b1 && emaa[0] == 1'b1)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (soa[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clka => (soa[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b0 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b0)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b0 && emab[0] == 1'b1)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b0)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (dftrambyp == 1'b0 && ret1n == 1'b1 && ((tenb == 1'b1 && cenb == 1'b0 && wenb == 1'b1) || (tenb == 1'b0 && tcenb == 1'b0 && twenb == 1'b1)) && emab[2] == 1'b1 && emab[1] == 1'b1 && emab[0] == 1'b1)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (sob[1] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);
    if (ret1n == 1'b1 && dftrambyp == 1'b1)
       (posedge clkb => (sob[0] : 1'b0)) = (`ARM_MEM_PROP, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP, `ARM_MEM_RETAIN, `ARM_MEM_PROP);


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge clka, `ARM_MEM_PERIOD, NOT_clka_PER);
   `else
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq0, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
       $period(posedge clka &&& ret1neq1aopopdftrambypeq0aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcpcpodftrambypeq1cpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1aemasaeq1, `ARM_MEM_PERIOD, NOT_clka_PER);
   `endif

   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $period(posedge clkb, `ARM_MEM_PERIOD, NOT_clkb_PER);
   `else
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq0, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
       $period(posedge clkb &&& ret1neq1aopopdftrambypeq0aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcpcpodftrambypeq1cpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1aemasbeq1, `ARM_MEM_PERIOD, NOT_clkb_PER);
   `endif


   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge clka, `ARM_MEM_WIDTH, 0, NOT_clka_MINH);
       $width(negedge clka, `ARM_MEM_WIDTH, 0, NOT_clka_MINL);
   `else
       $width(posedge clka &&& ret1neq1, `ARM_MEM_WIDTH, 0, NOT_clka_MINH);
       $width(negedge clka &&& ret1neq1, `ARM_MEM_WIDTH, 0, NOT_clka_MINL);
   `endif

   // Define SDTC only if back-annotating SDF file generated by Design Compiler
   `ifdef NO_SDTC
       $width(posedge clkb, `ARM_MEM_WIDTH, 0, NOT_clkb_MINH);
       $width(negedge clkb, `ARM_MEM_WIDTH, 0, NOT_clkb_MINL);
   `else
       $width(posedge clkb &&& ret1neq1, `ARM_MEM_WIDTH, 0, NOT_clkb_MINH);
       $width(negedge clkb &&& ret1neq1, `ARM_MEM_WIDTH, 0, NOT_clkb_MINL);
   `endif


    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq0aemaa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq0aemaa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq1aemaa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq0aemaa1eq1aemaa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq0aemaa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq0aemaa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq1aemaa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq1cpooptenaeq0atcenaeq0atwenaeq1cpcpaemaa2eq1aemaa1eq1aemaa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq0aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq0, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq0aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq0aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq0aemaa0eq1aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq0aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);
    $setuphold(posedge clkb &&& conta_ret1neq1adftrambypeq0aopoptenaeq1acenaeq0awenaeq0cpooptenaeq0atcenaeq0atwenaeq0cpcpaemaa2eq1aemaa1eq1aemaa0eq1aemawa1eq1aemawa0eq1, posedge clka, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTA);

    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq0aemab0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq0aemab0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq1aemab0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq0aemab1eq1aemab0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq0aemab0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq0aemab0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq1aemab0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq1cpooptenbeq0atcenbeq0atwenbeq1cpcpaemab2eq1aemab1eq1aemab0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq0aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq0, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq0aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq0aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq0aemab0eq1aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq0aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);
    $setuphold(posedge clka &&& contb_ret1neq1adftrambypeq0aopoptenbeq1acenbeq0awenbeq0cpooptenbeq0atcenbeq0atwenbeq0cpcpaemab2eq1aemab1eq1aemab0eq1aemawb1eq1aemawb0eq1, posedge clkb, 
    `ARM_MEM_COLLISION, 0.000, NOT_CONTB);

    $setuphold(posedge clka &&& ret1neq1atenaeq1, posedge cena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cena);
    $setuphold(posedge clka &&& ret1neq1atenaeq1, negedge cena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cena);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0, posedge wena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wena);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0, negedge wena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wena);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, posedge aa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, posedge aa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq0, negedge aa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq1acenaeq0acolldisneq1, negedge aa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_aa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da15);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da14);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da13);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da12);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da11);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da10);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da9);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da8);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da7);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da6);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da5);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da4);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da3);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da2);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da1);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, posedge da[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da0);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da15);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da14);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da13);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da12);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da11);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da10);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da9);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da8);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da7);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da6);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da5);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da4);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da3);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da2);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da1);
    $setuphold(posedge clka &&& ret1neq1atenaeq1aopopdftrambypeq1aseaeq0cpoopcenaeq0adftrambypeq0awenaeq0cpcp, negedge da[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_da0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1, posedge cenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1, negedge cenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_cenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0, posedge wenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0, negedge wenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_wenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, posedge ab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, posedge ab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq0, negedge ab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1acenbeq0acolldisneq1, negedge ab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_ab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db15);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db14);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db13);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db12);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db11);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db10);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db9);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, posedge db[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db15);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db14);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db13);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db12);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db11);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db10);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db9);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq1aopopdftrambypeq1asebeq0cpoopcenbeq0adftrambypeq0awenbeq0cpcp, negedge db[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_db0);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emaa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaa2);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emaa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaa1);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emaa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaa0);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emaa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaa2);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emaa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaa1);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emaa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emaa0);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emawa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawa1);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emawa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawa0);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emawa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawa1);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emawa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawa0);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emasa, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emasa);
    $setuphold(posedge clka &&& ret1neq1aopopoptenaeq1acenaeq0adftrambypeq0cpooptenaeq0atcenaeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emasa, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emasa);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emab2);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emab1);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emab0);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emab2);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emab1);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emab0);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emawb[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawb1);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emawb[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawb0);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emawb[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawb1);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emawb[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emawb0);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, posedge emasb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emasb);
    $setuphold(posedge clkb &&& ret1neq1aopopoptenbeq1acenbeq0adftrambypeq0cpooptenbeq0atcenbeq0adftrambypeq0cpcpodftrambypeq1cp, negedge emasb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_emasb);
    $setuphold(posedge clka &&& ret1neq1, posedge tena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tena);
    $setuphold(posedge clka &&& ret1neq1, negedge tena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tena);
    $setuphold(posedge clka &&& ret1neq1atenaeq0, posedge tcena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tcena);
    $setuphold(posedge clka &&& ret1neq1atenaeq0, negedge tcena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tcena);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0, posedge twena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_twena);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0, negedge twena, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_twena);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, posedge taa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, posedge taa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq0, negedge taa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa8);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa7);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa6);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa5);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa4);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa3);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa2);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa1);
    $setuphold(posedge clka &&& ret1neq1atenaeq0atcenaeq0acolldisneq1, negedge taa[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_taa0);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda15);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda14);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda13);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda12);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda11);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda10);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda9);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda8);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda7);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda6);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda5);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda4);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda3);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda2);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda1);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, posedge tda[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda0);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda15);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda14);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda13);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda12);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda11);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda10);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda9);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda8);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda7);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda6);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda5);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda4);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda3);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda2);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda1);
    $setuphold(posedge clka &&& ret1neq1atenaeq0aopopdftrambypeq1aseaeq0cpooptcenaeq0adftrambypeq0atwenaeq0cpcp, negedge tda[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tda0);
    $setuphold(posedge clkb &&& ret1neq1, posedge tenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tenb);
    $setuphold(posedge clkb &&& ret1neq1, negedge tenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0, posedge tcenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tcenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0, negedge tcenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tcenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0, posedge twenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_twenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0, negedge twenb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_twenb);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, posedge tab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, posedge tab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq0, negedge tab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0atcenbeq0acolldisneq1, negedge tab[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tab0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb15);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb14);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb13);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb12);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb11);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb10);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb9);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, posedge tdb[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb0);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[15], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb15);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[14], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb14);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[13], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb13);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[12], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb12);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[11], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb11);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[10], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb10);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[9], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb9);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[8], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb8);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[7], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb7);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[6], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb6);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[5], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb5);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[4], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb4);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[3], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb3);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[2], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb2);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb1);
    $setuphold(posedge clkb &&& ret1neq1atenbeq0aopopdftrambypeq1asebeq0cpooptcenbeq0adftrambypeq0atwenbeq0cpcp, negedge tdb[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_tdb0);
    $setuphold(posedge clka &&& ret1neq1aseaeq1, posedge sia[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sia1);
    $setuphold(posedge clka &&& ret1neq1aseaeq1, posedge sia[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sia0);
    $setuphold(posedge clka &&& ret1neq1aseaeq1, negedge sia[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sia1);
    $setuphold(posedge clka &&& ret1neq1aseaeq1, negedge sia[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sia0);
    $setuphold(posedge clka &&& ret1neq1, posedge sea, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sea);
    $setuphold(posedge clka &&& ret1neq1, negedge sea, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sea);
    $setuphold(posedge clkb &&& ret1neq1, posedge dftrambyp, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_dftrambyp_clkb);
    $setuphold(posedge clkb &&& ret1neq1, negedge dftrambyp, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_dftrambyp_clkb);
    $setuphold(posedge clka &&& ret1neq1, posedge dftrambyp, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_dftrambyp_clka);
    $setuphold(posedge clka &&& ret1neq1, negedge dftrambyp, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_dftrambyp_clka);
    $setuphold(posedge clkb &&& ret1neq1asebeq1, posedge sib[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sib1);
    $setuphold(posedge clkb &&& ret1neq1asebeq1, posedge sib[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sib0);
    $setuphold(posedge clkb &&& ret1neq1asebeq1, negedge sib[1], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sib1);
    $setuphold(posedge clkb &&& ret1neq1asebeq1, negedge sib[0], `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_sib0);
    $setuphold(posedge clkb &&& ret1neq1, posedge seb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_seb);
    $setuphold(posedge clkb &&& ret1neq1, negedge seb, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_seb);
    $setuphold(posedge clka &&& ret1neq1aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcp, posedge colldisn, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_colldisn);
    $setuphold(posedge clka &&& ret1neq1aopoptenaeq1acenaeq0cpooptenaeq0atcenaeq0cpcp, negedge colldisn, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_colldisn);
    $setuphold(posedge clkb &&& ret1neq1aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcp, posedge colldisn, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_colldisn);
    $setuphold(posedge clkb &&& ret1neq1aopoptenbeq1acenbeq0cpooptenbeq0atcenbeq0cpcp, negedge colldisn, `ARM_MEM_SETUP, `ARM_MEM_HOLD, NOT_colldisn);
    $setuphold(negedge ret1n, negedge cena, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge ret1n, negedge cena, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(negedge ret1n, negedge cenb, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge ret1n, negedge cenb, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(negedge ret1n, negedge tcena, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge ret1n, negedge tcena, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(negedge ret1n, negedge tcenb, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge ret1n, negedge tcenb, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(negedge dftrambyp, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(negedge dftrambyp, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge tcenb, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge tcenb, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cenb, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cenb, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge tcena, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge tcena, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cena, posedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge cena, negedge ret1n, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(posedge ret1n, posedge dftrambyp, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
    $setuphold(negedge ret1n, posedge dftrambyp, 0.000, `ARM_MEM_HOLD, NOT_ret1n);
  endspecify


endmodule
`endcelldefine
`endif
`timescale 1ns/1ps
module sramdp_272_16_error_injection (Q_out, Q_in, CLK, A, CEN, DFTRAMBYP, SE, WEN);
   output [15:0] Q_out;
   input [15:0] Q_in;
   input CLK;
   input [8:0] A;
   input CEN;
   input DFTRAMBYP;
   input SE;
   input WEN;
   parameter LEFT_RED_COLUMN_FAULT = 2'd1;
   parameter RIGHT_RED_COLUMN_FAULT = 2'd2;
   parameter NO_RED_FAULT = 2'd0;
   reg [15:0] Q_out;
   reg entry_found;
   reg list_complete;
   reg [17:0] fault_table [67:0];
   reg [17:0] fault_entry;
initial
begin
   `ifdef DUT
      `define pre_pend_path TB.DUT_inst.CHIP
   `else
       `define pre_pend_path TB.CHIP
   `endif
   `ifdef ARM_NONREPAIRABLE_FAULT
      `pre_pend_path.SMARCHCHKBVCD_LVISION_MBISTPG_ASSEMBLY_UNDER_TEST_INST.MEM0_MEM_INST.u1.add_fault(9'd109,4'd6,2'd1,2'd0);
   `endif
end
   task add_fault;
   //This task injects fault in memory
      input [8:0] address;
      input [3:0] bitPlace;
      input [1:0] fault_type;
      input [1:0] red_fault;
 
      integer i;
      reg done;
   begin
      done = 1'b0;
      i = 0;
      while ((!done) && i < 67)
      begin
         fault_entry = fault_table[i];
         if (fault_entry[0] === 1'b0 || fault_entry[0] === 1'bx)
         begin
            fault_entry[0] = 1'b1;
            fault_entry[2:1] = red_fault;
            fault_entry[4:3] = fault_type;
            fault_entry[8:5] = bitPlace;
            fault_entry[17:9] = address;
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
   for (i = 0; i < 68; i=i+1)
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
   inout [15:0] q_int;
   input [1:0] fault_type;
   input [3:0] bitLoc;
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
   output [15:0] Q_output;
   reg list_complete;
   integer i;
   reg [6:0] row_address;
   reg [1:0] column_address;
   reg [3:0] bitPlace;
   reg [1:0] fault_type;
   reg [1:0] red_fault;
   reg valid;
   reg [2:0] msb_bit_calc;
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
            if (row_address == A[8:2] && column_address == A[1:0])
            begin
               if (bitPlace < 8)
                  bit_error(Q_output,fault_type, bitPlace);
               else if (bitPlace >= 8 )
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
   if (CEN === 1'b0 && &WEN === 1'b1 && DFTRAMBYP === 1'b0 && SE === 1'b0)
      error_injection_on_output(Q_out);
   else
      Q_out = Q_in;
   end
endmodule
