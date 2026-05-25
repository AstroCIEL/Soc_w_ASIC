// Y-bounds LUT, dual-read + external write-port initialization.
// Backed by ARM Memory Compiler generated sramdp_272_16 (via wrapper).
// Port A is shared between writes (initialization) and read path 0;
// Port B is dedicated to read path 1. The caller must guarantee wr_en and
// rd_req0 are not asserted in the same cycle (typically: writes happen
// during init while rd_req* are quiet).
// LUT contents must be loaded at runtime through the wr_en/wr_addr/wr_data
// interface; file-based initialization is no longer supported.

module model_y_bounds_LUT #(
	parameter NUM_INTERVALS = 258,
	parameter WIDTH = 16,
	localparam Y_BOUNDS_INDEX_WIDTH = $clog2(NUM_INTERVALS+1)
)(
	input 	logic 								clk,

	// External init / write port (single write address per cycle)
	input 	logic 								wr_en,
	input 	logic [Y_BOUNDS_INDEX_WIDTH-1: 0]	wr_addr,
	input 	logic [WIDTH-1: 0] 					wr_data,

	// Read path 0 (shares dp_sram port A with the write port)
	input 	logic 								rd_req0,
	input 	logic [Y_BOUNDS_INDEX_WIDTH-1: 0]	rd_addr0,
	output  logic [WIDTH-1: 0] 					rd_data0,

	// Read path 1 (dp_sram port B, read-only)
	input 	logic 								rd_req1,
	input 	logic [Y_BOUNDS_INDEX_WIDTH-1: 0]	rd_addr1,
	output  logic [WIDTH-1: 0] 					rd_data1
);

	// Port A combined control: enabled on either a write or read-0 request.
	logic 								cen_a;
	logic 								wen_a;
	logic [Y_BOUNDS_INDEX_WIDTH-1: 0]	addr_a;
	logic [WIDTH-1: 0]					din_a;
	logic [WIDTH-1: 0]					dout_a;

	assign cen_a  = ~(wr_en | rd_req0);
	assign wen_a  = wr_en;
	assign addr_a = wr_en ? wr_addr : rd_addr0;
	assign din_a  = wr_data;

	// Port B: pure read for rd_addr1.
	logic 								cen_b;
	logic [Y_BOUNDS_INDEX_WIDTH-1: 0]	addr_b;
	logic [WIDTH-1: 0]					dout_b;

	assign cen_b  = ~rd_req1;
	assign addr_b = rd_addr1;

	sramdp_272_16_wrapper #(
		.DATA_WIDTH (WIDTH),
		.ADDR_WIDTH (Y_BOUNDS_INDEX_WIDTH),
		.DEPTH      (NUM_INTERVALS+1)
	) u_sramdp_wrapper (
		.clk    (clk),

		.cen_a  (cen_a),
		.wen_a  (wen_a),
		.addr_a (addr_a),
		.din_a  (din_a),
		.dout_a (dout_a),

		.cen_b  (cen_b),
		.wen_b  (1'b0),
		.addr_b (addr_b),
		.din_b  ('0),
		.dout_b (dout_b)
	);

	assign rd_data0 = dout_a;
	assign rd_data1 = dout_b;

endmodule
