module mem_wrap #(
	parameter	EXT_DATA_WIDTH	= 64,
	parameter	INT_DATA_WIDTH	= 2048,
	parameter	DEPTH			= 128,

	localparam	INT_ADDR_WIDTH	= $clog2(DEPTH),
	localparam	EXT_ADDR_WIDTH	= $clog2(DEPTH * INT_DATA_WIDTH / EXT_DATA_WIDTH)
)(
	input	logic							clk,
	input	logic							rstn,
	input	logic							clr,
	input	logic							ena,

	input	logic							ext_req,
	input	logic							ext_we,

	input	logic	[EXT_ADDR_WIDTH-1: 0]	ext_addr,
	input	logic	[EXT_DATA_WIDTH-1: 0]	ext_wdata,
	output	logic	[EXT_DATA_WIDTH-1: 0]	ext_rdata,
	input	logic	[EXT_DATA_WIDTH/8-1: 0]	ext_byte_ena,

	input	logic							int_req,
	input	logic							int_we,

	input	logic	[INT_ADDR_WIDTH-1: 0]	int_addr,
	input	logic	[INT_DATA_WIDTH-1: 0]	int_wdata,
	output	logic	[INT_DATA_WIDTH-1: 0]	int_rdata,
	input	logic	[INT_DATA_WIDTH-1: 0]	int_bit_ena,

	input	logic							cfg_sel,

	// voltage: 0.8v
	input	logic [2: 0]					cfg_ema,	// default: 3'b100
	input	logic [1: 0]					cfg_emaw,	// default: 2'b01
	input	logic							cfg_emas,	// default: 1'b0
	input	logic [1: 0]					cfg_wablm,	// default: 2'b01
	input	logic [1: 0]					cfg_rawlm	// default: 2'b00

);
	logic	[INT_ADDR_WIDTH-1: 0]	ext_addr_mapped;
	logic	[INT_DATA_WIDTH-1: 0]	ext_wdata_mapped;
	logic	[INT_DATA_WIDTH-1: 0]	ext_rdata_mapped;
	logic	[INT_DATA_WIDTH-1: 0]	ext_bit_ena_mapped;

	logic							req;
	logic							we;
	logic	[INT_ADDR_WIDTH-1: 0]	addr;
	logic	[INT_DATA_WIDTH-1: 0]	be;
	logic	[INT_DATA_WIDTH-1: 0]	wdata;
	logic	[INT_DATA_WIDTH-1: 0]	rdata;

	mem_map #(
		.EXT_DATA_WIDTH(EXT_DATA_WIDTH),
		.INT_DATA_WIDTH(INT_DATA_WIDTH),
		.DEPTH(DEPTH)
	) u_mem_map (
		.clk(clk),
		.rstn(rstn),
		.clr(clr),
		.ena(ena),

		.req(ext_req),
		.we(ext_we),
		
		.ext_addr(ext_addr),
		.ext_wdata(ext_wdata),
		.ext_rdata(ext_rdata),
		.ext_byte_ena(ext_byte_ena),

		.int_addr(ext_addr_mapped),
		.int_wdata(ext_wdata_mapped),
		.int_rdata(ext_rdata_mapped),
		.int_bit_ena(ext_bit_ena_mapped)
	);


	generate
		if (DEPTH <= 64) begin : GenRfWrap64
			rf_wrap_64x128 #(
				.DATA_WIDTH(INT_DATA_WIDTH),
				.DATA_DEPTH(DEPTH)
			) u_rf_wrap (
				.clk     (clk),
				.rstn    (rstn),
				.clr     (clr),
				.ena     (ena),
				.req     (req),
				.we      (we),
				.addr    (addr),
				.wdata   (wdata),
				.be      (be),
				.rdata   (rdata),
				.cfg_ema (cfg_ema),
				.cfg_emaw(cfg_emaw),
				.cfg_emas(cfg_emas),
				.cfg_rawlm(cfg_rawlm),
				.cfg_wablm(cfg_wablm)
			);
		end else begin : GenRfWrap128
			rf_wrap_128x128 #(
				.DATA_WIDTH(INT_DATA_WIDTH),
				.DATA_DEPTH(DEPTH)
			) u_rf_wrap (
				.clk     (clk),
				.rstn    (rstn),
				.clr     (clr),
				.ena     (ena),
				.req     (req),
				.we      (we),
				.addr    (addr),
				.wdata   (wdata),
				.be      (be),
				.rdata   (rdata),
				.cfg_ema (cfg_ema),
				.cfg_emaw(cfg_emaw),
				.cfg_emas(cfg_emas),
				.cfg_rawlm(cfg_rawlm),
				.cfg_wablm(cfg_wablm)
			);
		end
	endgenerate

	always_comb begin
		req 	= cfg_sel? ext_req: int_req;
		we		= cfg_sel? ext_we: int_we;
		addr	= cfg_sel? ext_addr_mapped: int_addr;
		wdata	= cfg_sel? ext_wdata_mapped: int_wdata;
		be		= cfg_sel? ext_bit_ena_mapped: int_bit_ena;

		ext_rdata_mapped = rdata;
		int_rdata = rdata;
	end

endmodule
