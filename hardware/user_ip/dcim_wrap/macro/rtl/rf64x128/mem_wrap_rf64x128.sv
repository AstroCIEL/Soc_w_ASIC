// Top integration wrapper for the suggested three-layer hierarchy:
//   mem_map      - width adapter (ext path)
//   mem_bank_map - per-macro request decode (ext read/write)
//   rf_wrap_*    - physical macro array
//
// Drop-in compatible port list with src/common/mem_wrap.sv.
module mem_wrap_rf64x128 #(
	parameter EXT_DATA_WIDTH = 64,
	parameter INT_DATA_WIDTH = 2048,
	parameter DEPTH          = 128,
	parameter MACRO_WIDTH    = 128,

	localparam INT_ADDR_WIDTH = $clog2(DEPTH),
	localparam EXT_ADDR_WIDTH = $clog2(DEPTH * INT_DATA_WIDTH / EXT_DATA_WIDTH),
	localparam W_RATIO        = INT_DATA_WIDTH / MACRO_WIDTH,
	localparam PORT_OFF_WIDTH = $clog2(INT_DATA_WIDTH / EXT_DATA_WIDTH)
)(
	input  logic                       clk,
	input  logic                       rstn,
	input  logic                       clr,
	input  logic                       ena,

	input  logic                       ext_req,
	input  logic                       ext_we,

	input  logic [EXT_ADDR_WIDTH-1:0]  ext_addr,
	input  logic [EXT_DATA_WIDTH-1:0]  ext_wdata,
	output logic [EXT_DATA_WIDTH-1:0]  ext_rdata,
	input  logic [EXT_DATA_WIDTH/8-1:0] ext_byte_ena,

	input  logic                       int_req,
	input  logic                       int_we,

	input  logic [INT_ADDR_WIDTH-1:0]  int_addr,
	input  logic [INT_DATA_WIDTH-1:0]  int_wdata,
	output logic [INT_DATA_WIDTH-1:0]  int_rdata,
	input  logic [INT_DATA_WIDTH-1:0]  int_bit_ena,

	input  logic                       cfg_sel,

	input  logic [2:0]                 cfg_ema,
	input  logic [1:0]                 cfg_emaw,
	input  logic                       cfg_emas,
	input  logic [1:0]                 cfg_wablm,
	input  logic [1:0]                 cfg_rawlm
);

	logic [INT_ADDR_WIDTH-1:0]  ext_row_addr;
	logic [INT_DATA_WIDTH-1:0]  ext_wdata_mapped;
	logic [INT_DATA_WIDTH-1:0]  ext_rdata_mapped;
	logic [INT_DATA_WIDTH-1:0]  ext_bit_ena_mapped;
	logic [PORT_OFF_WIDTH-1:0]  port_off;
	logic [W_RATIO-1:0]         ext_macro_ena;
	logic [W_RATIO-1:0]         macro_ena;

	logic                       req;
	logic                       we;
	logic [INT_ADDR_WIDTH-1:0]  addr;
	logic [INT_DATA_WIDTH-1:0]  be;
	logic [INT_DATA_WIDTH-1:0]  wdata;
	logic [INT_DATA_WIDTH-1:0]  rdata;

	mem_width_adapter #(
		.EXT_DATA_WIDTH(EXT_DATA_WIDTH),
		.INT_DATA_WIDTH(INT_DATA_WIDTH),
		.DEPTH(DEPTH)
	) u_mem_width_adapter (
		.clk          (clk),
		.rstn         (rstn),
		.clr          (clr),
		.ena          (ena),
		.req          (ext_req),
		.we           (ext_we),
		.ext_addr     (ext_addr),
		.ext_wdata    (ext_wdata),
		.ext_rdata    (ext_rdata),
		.ext_byte_ena (ext_byte_ena),
		.int_addr     (ext_row_addr),
		.int_wdata    (ext_wdata_mapped),
		.int_rdata    (ext_rdata_mapped),
		.int_bit_ena  (ext_bit_ena_mapped),
		.port_off     (port_off)
	);

	mem_macro_decoder #(
		.PORT_WIDTH    (EXT_DATA_WIDTH),
		.INT_DATA_WIDTH(INT_DATA_WIDTH),
		.MACRO_WIDTH   (MACRO_WIDTH)
	) u_macro_decoder (
		.port_narrow(cfg_sel && ext_req),
		.port_off   (port_off),
		.macro_ena  (ext_macro_ena)
	);

	mem_phy_array_rf64x128 #(
		.DATA_WIDTH(INT_DATA_WIDTH),
		.DATA_DEPTH(DEPTH)
	) u_rf_wrap (
		.clk      (clk),
		.rstn     (rstn),
		.clr      (clr),
		.ena      (ena),
		.req      (req),
		.we       (we),
		.addr     (addr),
		.wdata    (wdata),
		.be       (be),
		.macro_ena (macro_ena),
		.rdata    (rdata),
		.cfg_ema  (cfg_ema),
		.cfg_emaw (cfg_emaw),
		.cfg_emas (cfg_emas),
		.cfg_rawlm (cfg_rawlm),
		.cfg_wablm (cfg_wablm)
	);

	always_comb begin
		req  = cfg_sel ? ext_req : int_req;
		we   = cfg_sel ? ext_we  : int_we;
		addr = cfg_sel ? ext_row_addr : int_addr;
		wdata = cfg_sel ? ext_wdata_mapped : int_wdata;
		be   = cfg_sel ? ext_bit_ena_mapped : int_bit_ena;

		macro_ena = cfg_sel ? ext_macro_ena : {W_RATIO{1'b1}};

		ext_rdata_mapped = rdata;
		int_rdata        = rdata;
	end

	initial begin
		if (INT_DATA_WIDTH < EXT_DATA_WIDTH) begin
			$error("mem_wrap: INT_DATA_WIDTH must be >= EXT_DATA_WIDTH");
		end
		if (INT_DATA_WIDTH % EXT_DATA_WIDTH != 0) begin
			$error("mem_wrap: INT_DATA_WIDTH must be an integer multiple of EXT_DATA_WIDTH");
		end
		if (INT_DATA_WIDTH % MACRO_WIDTH != 0) begin
			$error("mem_wrap: INT_DATA_WIDTH must be an integer multiple of MACRO_WIDTH");
		end
		if (EXT_DATA_WIDTH > MACRO_WIDTH) begin
			if (EXT_DATA_WIDTH % MACRO_WIDTH != 0) begin
				$error("mem_wrap: EXT_DATA_WIDTH and MACRO_WIDTH must be integer multiples");
			end
		end else if (EXT_DATA_WIDTH < MACRO_WIDTH) begin
			if (MACRO_WIDTH % EXT_DATA_WIDTH != 0) begin
				$error("mem_wrap: EXT_DATA_WIDTH and MACRO_WIDTH must be integer multiples");
			end
		end
	end

endmodule
