`ifdef MODEL_MEM

module model_mem #(
	parameter	DATA_WIDTH = 128,
	parameter	DEPTH = 128,
	localparam	ADDR_WIDTH = $clog2(DEPTH)
)(
	input	logic					clk,
	input	logic					req,
	input	logic					we,
	input	logic [DATA_WIDTH-1: 0]	be,
	input	logic [ADDR_WIDTH-1: 0]	addr,
	input	logic [DATA_WIDTH-1: 0]	wdata,
	output	logic [DATA_WIDTH-1: 0]	rdata
);

	logic [DATA_WIDTH-1: 0]	mem [DEPTH];

	always_ff @(posedge clk) begin
		if (req) begin
			if (we) begin
				mem[addr] <= (wdata & be) | (mem[addr] & ~be);
			end else begin
				rdata <= mem[addr];
			end
		end
	end

endmodule

`endif

