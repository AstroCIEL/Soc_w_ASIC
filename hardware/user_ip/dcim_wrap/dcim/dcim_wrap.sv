module dcim_wrap#(
	parameter	AXI_DATA_WIDTH 	= 64,
	parameter	AXI_ADDR_WIDTH	= 64,

 	parameter 	WD1 			= 4,
    parameter 	CH_IN 			= 64,
    parameter 	CH_OUT 			= 64,
    parameter 	SRAM_DP 		= 128,
    parameter 	CYCLE 			= 8,
    parameter 	ACC 			= 4,
	// SRAM TOTAL 32768 Byte / 32K Byte
    localparam 	SRAM_WD 		= CH_IN * CH_OUT * WD1 / CYCLE, // 2048-bit
    localparam 	ADDR_WD 		= $clog2(SRAM_DP),
	localparam	EXT_ADDR_WIDTH 	= $clog2(SRAM_DP * SRAM_WD / AXI_DATA_WIDTH),
    localparam 	TILE_WD 		= CH_IN * CH_OUT * WD1,         // 16384-bit
    localparam 	ACC_UBD_WD 		= $clog2(ACC+1),
    localparam 	WD2 			= 2*WD1 + $clog2(CH_IN),
    localparam 	WD3 			= WD2 + $clog2(ACC)

)(
	input	logic	clk_i,
	input	logic	rst_ni,
	AXI_BUS.slave	axi_bus
);

	logic							axi_req_wei;
	logic							axi_we_wei;
	logic	[AXI_ADDR_WIDTH-1: 0]	axi_addr_wei;
	logic	[AXI_DATA_WIDTH/8-1: 0]	axi_be_wei;
	logic	[AXI_DATA_WIDTH-1: 0]	axi_wdata_wei;
	logic	[AXI_DATA_WIDTH-1: 0]	axi_rdata_wei;

	axi2mem #(
   		.AXI_ID_WIDTH   ( $bits(axi_bus.aw_id) ),
   		.AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    	.AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    	.AXI_USER_WIDTH ( 1 )
	) i_op_a_buf_axi2mem (
    	.clk_i  ( clk_i ),
    	.rst_ni ( rst_ni ),
    	.slave  ( axi_bus ),
    	.req_o  ( axi_req_wei ),
    	.we_o   ( axi_we_wei ),
    	.addr_o ( axi_addr_wei ),
    	.be_o   ( axi_be_wei ),
    	.user_o ( ),
    	.data_o ( axi_wdata_wei ),
    	.user_i ( '0 ),
    	.data_i ( axi_rdata_wei )
	);

	dcim #(
		.WD1(WD1),
		.CH_IN(CH_IN),
		.CH_OUT(CH_OUT),
		.SRAM_DP(SRAM_DP),
		.CYCLE(CYCLE),
		.ACC(ACC),
		.EXT_DATA_WIDTH(AXI_DATA_WIDTH)
	) u_dcim (
		.clk(clk_i),
		.rstn(rst_ni),

		.clr(1'b0),
		.ena(1'b1),
		.mode_cal(3'b000),
		.acc('0),
		.load_wei(1'b0),
		.swap_wei(1'b0),
		.addr_load('0),
		.cfg_sel_wei(1'b1),	// 1 for externel

		.ext_req_wei(axi_req_wei),
		.ext_we_wei(axi_we_wei),
		.ext_addr_wei(axi_addr_wei[EXT_DATA_W]),
		.ext_byte_ena_wei(axi_be_wei),
		.ext_wdata_wei(axi_wdata_wei),
		.ext_rdata_wei(axi_rdata_wei),

		.cfg_ema(3'b100),
		.cfg_emaw(2'b01),
		.cfg_emas(1'b0),
		.cfg_wablm(2'b01),
		.cfg_rawlm(2'b00),

		.up_valid_cal(1'b0),
		.up_ready_cal(),
		.up_data_cal('0),

		.dn_valid(),
		.dn_ready(1'b1),
		.dn_data()
	);


endmodule
