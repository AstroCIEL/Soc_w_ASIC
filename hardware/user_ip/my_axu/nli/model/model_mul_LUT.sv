// Macro multiply-factor LUT, single-read + external write-port initialization.
// Backed by a synthesizable sp_sram. The single port is shared between writes
// (init) and reads: when wr_en is asserted the cycle performs a write;
// otherwise it performs a read controlled by rd_req. The caller must avoid
// asserting wr_en and rd_req in the same cycle (typically: writes only during init).
// LUT contents must be loaded at runtime through the wr_en/wr_addr/wr_data
// interface; file-based initialization is no longer supported.

module model_mul_LUT #(
	parameter NUM_MACROS = 10,
	parameter WIDTH = 16,
	localparam MACRO_INDEX_WIDTH = $clog2(NUM_MACROS)
)(
	input 	logic 							clk,

	// External init / write port
	input 	logic 							wr_en,
	input 	logic [MACRO_INDEX_WIDTH-1: 0]	wr_addr,
	input 	logic [WIDTH-1: 0] 				wr_data,

	// Read port
	input 	logic 							rd_req,
	input 	logic [MACRO_INDEX_WIDTH-1: 0]	rd_addr,
	output  logic [WIDTH-1: 0] 				rd_data
);

	logic 							cen;
	logic 							wen;
	logic [MACRO_INDEX_WIDTH-1: 0]	addr;
	logic [WIDTH-1: 0]				din;
	logic [WIDTH-1: 0]				dout;

	assign cen  = ~(wr_en | rd_req);
	assign wen  = wr_en;
	assign addr = wr_en ? wr_addr : rd_addr;
	assign din  = wr_data;

	sp_sram #(
		.DATA_WIDTH (WIDTH),
		.ADDR_WIDTH (MACRO_INDEX_WIDTH)
	) u_sp_sram (
		.clk  (clk),
		.cen  (cen),
		.wen  (wen),
		.addr (addr),
		.din  (din),
		.dout (dout)
	);

	assign rd_data = dout;

endmodule
