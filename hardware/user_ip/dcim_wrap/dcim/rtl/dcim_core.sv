module dcim_core #(
	parameter 		WD1 	= 4,
    parameter 		CH_IN 	= 64,
    parameter 		CH_OUT 	= 64,
    parameter 		SRAM_DP = 128,
    parameter 		CYCLE 	= 8,
	parameter		EXT_DATA_WIDTH = 64,
    localparam 		SRAM_WD = CH_IN * CH_OUT * WD1 / CYCLE, // 128-bit
    localparam 		ADDR_WD = $clog2(SRAM_DP),
	localparam		EXT_ADDR_WIDTH = $clog2(SRAM_DP * SRAM_WD / EXT_DATA_WIDTH),
    localparam 		WD2 	= 2*WD1 + $clog2(CH_IN)

)(
	input 	logic 							clk,
    input 	logic 							rstn,
    input 	logic 							clr,
    input 	logic 							ena,

	input 	logic [2: 0] 					mode_cal,

	input 	logic  							load_wei,
	input 	logic  				  			swap_wei,
	input 	logic [ADDR_WD-1: 0]			addr_load,

	input 	logic							ext_req_wei,
	input 	logic							ext_we_wei,
	input	logic [EXT_ADDR_WIDTH-1: 0]		ext_addr_wei,
	input	logic [EXT_DATA_WIDTH/8-1: 0]	ext_byte_ena_wei,
	input 	logic [EXT_DATA_WIDTH-1: 0]		ext_wdata_wei,
	output	logic [EXT_DATA_WIDTH-1: 0]		ext_rdata_wei,
	input	logic							cfg_sel_wei,

	input 	logic [2: 0]					cfg_ema,
	input 	logic [1: 0]					cfg_emaw,
	input 	logic							cfg_emas,
	input	logic							cfg_wabl,
	input 	logic [1: 0]					cfg_wablm,
	input	logic							cfg_rawl,
	input 	logic [1: 0]					cfg_rawlm,

	input 	logic  							up_valid_cal,
	output 	logic							up_ready_cal,
    input 	logic  [CH_IN*WD1-1: 0] 		up_data_cal,

	output 	logic							dn_valid,
	input 	logic  							dn_ready,
    output	logic [CH_OUT*WD2-1: 0] 		dn_data

);

	logic mid_valid_wei;
	logic [CH_IN*CH_OUT*WD1-1: 0] mid_data_wei;
	logic w_ready_cal;

	dcim_memory#(
		.DP(SRAM_DP),
		.CH_IN(CH_IN), .CH_OUT(CH_OUT),
		.WD1(WD1), .CYCLE(CYCLE),
		.EXT_DATA_WIDTH(EXT_DATA_WIDTH)
	) u_memory(
		.clk(clk), .rstn(rstn), .clr(clr), .ena(ena),
		.addr_load(addr_load),
		.load(load_wei),
		.swap(swap_wei),
		.cfg_sel(cfg_sel_wei),

		.ext_req(ext_req_wei),
		.ext_we(ext_we_wei),
		.ext_addr(ext_addr_wei),
		.ext_byte_ena(ext_byte_ena_wei),
		.ext_wdata(ext_wdata_wei),
		.ext_rdata(ext_rdata_wei),

		.dn_valid(mid_valid_wei), .dn_data(mid_data_wei),
		.cfg_ema(cfg_ema),
		.cfg_emaw(cfg_emaw),
		.cfg_emas(cfg_emas),
		.cfg_rawl(cfg_rawl),
		.cfg_rawlm(cfg_rawlm),
		.cfg_wabl(cfg_wabl),
		.cfg_wablm(cfg_wablm)
	);

    calculate_core #(
        .WD1(WD1), .CH_IN(CH_IN), .CH_OUT(CH_OUT)
    ) u_calculate_core (
        .clk(clk), .rstn(rstn), .clr(clr), .ena(ena), .mode(mode_cal),
        .up_valid(up_valid_cal && mid_valid_wei), .up_ready(w_ready_cal),
        .up_data1(up_data_cal),  .up_data2(mid_data_wei),
        .dn_valid(dn_valid), .dn_ready(dn_ready),
		.dn_data(dn_data)
    );

	always_comb begin
		up_ready_cal = w_ready_cal & mid_valid_wei;
	end

endmodule
