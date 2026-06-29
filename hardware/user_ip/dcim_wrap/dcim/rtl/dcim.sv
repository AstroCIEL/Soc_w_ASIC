`timescale 1ns / 1ps

`include "para.v"

module dcim #(
    parameter 	WD1 			= 4,
    parameter 	CH_IN 			= 64,
    parameter 	CH_OUT 			= 64,
    parameter 	SRAM_DP 		= 128,
    parameter 	CYCLE 			= 8,
    parameter 	ACC 			= 4,
	parameter	EXT_DATA_WIDTH 	= 64,
    
    localparam 	SRAM_WD 		= CH_IN * CH_OUT * WD1 / CYCLE, // 128-bit
    localparam 	ADDR_WD 		= $clog2(SRAM_DP),
	localparam	EXT_ADDR_WIDTH 	= $clog2(SRAM_DP * SRAM_WD / EXT_DATA_WIDTH),
    localparam 	TILE_WD 		= CH_IN * CH_OUT * WD1,         // 1024-bit
    localparam 	ACC_UBD_WD 		= $clog2(ACC+1),
    localparam 	WD2 			= 2*WD1 + $clog2(CH_IN),
    localparam 	WD3 			= WD2 + $clog2(ACC)
)(
    input	logic							clk,
    input 	logic							rstn,
    input 	logic							clr,
    input 	logic							ena,
    
	input  	logic [2: 0] 					mode_cal,
	input  	logic [ACC_UBD_WD-1: 0] 		acc,
	input  	logic							load_wei,
	input	logic				  			swap_wei,
	input 	logic [ADDR_WD-1: 0]			addr_load,
	input	logic							cfg_sel_wei,// 1 for externel

	input	logic							ext_req_wei,
    input  	logic							ext_we_wei,
    input  	logic [EXT_ADDR_WIDTH-1: 0] 	ext_addr_wei,
    input 	logic [EXT_DATA_WIDTH/8-1: 0] 	ext_byte_ena_wei,
    input  	logic [EXT_DATA_WIDTH-1: 0] 	ext_wdata_wei,
	output	logic [EXT_DATA_WIDTH-1: 0] 	ext_rdata_wei,
	
	// voltage: 0.8v
	input	logic [2: 0]					cfg_ema,	// default: 3'b100
	input	logic [1: 0]					cfg_emaw,	// default: 2'b01
	input	logic							cfg_emas,	// default: 1'b0
	input	logic [1: 0]					cfg_wablm,	// default: 2'b01
	input	logic [1: 0]					cfg_rawlm,	// default: 2'b00

	input  	logic							up_valid_cal,
	output 	logic							up_ready_cal,
    input 	logic [CH_IN*WD1-1: 0] 			up_data_cal, 
    
	output 	logic							dn_valid,
	input  	logic							dn_ready,
    output 	logic [CH_OUT*WD3-1: 0] 		dn_data
);
	logic mid_valid_cal, mid_ready_cal;
	logic [CH_OUT*WD2-1: 0] mid_data_cal;

	logic  [CH_IN*WD1-1: 0]		up_data_cal_int;
	logic						up_valid_cal_int, w_up_valid_cal;
	logic						up_ready_cal_int, w_up_ready_cal;
	logic  [CH_OUT*WD3-1: 0]	dn_data_int;
	logic						dn_valid_int, w_dn_valid;
	logic						dn_ready_int, w_dn_ready;


	pipe_slice_full #(
		.WIDTH(CH_IN*WD1)
	) u_pipe_slice_full_up(
		.clk(clk),	.rstn(rstn),	.clr(clr),	.ena(ena),
		.up_valid(w_up_valid_cal),
		.up_ready(w_up_ready_cal),
		.up_data(up_data_cal),
		.dn_valid(up_valid_cal_int),
		.dn_ready(up_ready_cal_int),
		.dn_data(up_data_cal_int)
	);

	dcim_core #(
		.WD1(WD1),
		.CH_IN(CH_IN),
		.CH_OUT(CH_OUT),
		.SRAM_DP(SRAM_DP),
		.CYCLE(CYCLE),
		.EXT_DATA_WIDTH(EXT_DATA_WIDTH)
	) u_dcim_core (
		.clk(clk),	.rstn(rstn),	.clr(clr),	.ena(ena),	.mode_cal(mode_cal),
	
		.load_wei(load_wei),	.swap_wei(swap_wei),
		.addr_load(addr_load),

		.ext_req_wei(ext_req_wei),
		.ext_we_wei(ext_we_wei),	
		.ext_addr_wei(ext_addr_wei),	
		.ext_byte_ena_wei(ext_byte_ena_wei),
		.ext_wdata_wei(ext_wdata_wei),
		.ext_rdata_wei(ext_rdata_wei),
		.cfg_sel_wei(cfg_sel_wei),

		.up_valid_cal(up_valid_cal_int),
		.up_ready_cal(up_ready_cal_int),
		.up_data_cal(up_data_cal_int),

		.dn_valid(mid_valid_cal),
		.dn_ready(mid_ready_cal),
		.dn_data(mid_data_cal),
		
		.cfg_ema(cfg_ema),
		.cfg_emaw(cfg_emaw),
		.cfg_emas(cfg_emas),
		.cfg_rawlm(cfg_rawlm),
		.cfg_wablm(cfg_wablm)

	);

	postProcess #(
		.WD1(WD1), .CH_IN(CH_IN), .CH_OUT(CH_OUT), .ACC(ACC)
	) u_postProcess (
		.clk(clk), .rstn(rstn), .clr(clr), .ena(ena), .mode(mode_cal), .acc(acc),
		.up_valid(mid_valid_cal), .up_ready(mid_ready_cal),
		.up_data(mid_data_cal),
		.dn_valid(dn_valid_int), .dn_ready(dn_ready_int), .dn_data(dn_data_int)
	);

	pipe_slice_full #(
		.WIDTH(CH_OUT*WD3)
	) u_pipe_slice_full_dn(
		.clk(clk),	.rstn(rstn),	.clr(clr),	.ena(ena),

		.up_valid(dn_valid_int),
		.up_ready(dn_ready_int),
		.up_data(dn_data_int),

		.dn_valid(w_dn_valid),
		.dn_ready(w_dn_ready),
		.dn_data(dn_data)
	);

	always_comb begin
		dn_valid = w_dn_valid & ena;
		w_dn_ready = dn_ready & ena;
		w_up_valid_cal = up_valid_cal & ena;
		up_ready_cal = w_up_ready_cal & ena;
	end

endmodule
