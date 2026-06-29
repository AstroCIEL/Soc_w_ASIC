module mem_map #(
	parameter	EXT_DATA_WIDTH	= 64,
	parameter	INT_DATA_WIDTH	= 2048,
	parameter	DEPTH			= 128,
	localparam	INT_ADDR_WIDTH	= $clog2(DEPTH),
	localparam	OFF_ADDR_WIDTH	= $clog2(INT_DATA_WIDTH / EXT_DATA_WIDTH),
	localparam	EXT_ADDR_WIDTH	= INT_ADDR_WIDTH + OFF_ADDR_WIDTH
)(
	input	logic							clk,
	input	logic							rstn,
	input	logic							clr,
	input	logic							ena,

	input	logic							req,
	input	logic							we,

	input	logic	[EXT_DATA_WIDTH-1: 0]	ext_wdata,
	output	logic	[EXT_DATA_WIDTH-1: 0]	ext_rdata,
	input	logic	[EXT_DATA_WIDTH/8-1: 0]	ext_byte_ena,	// Byte Enable
	input	logic	[EXT_ADDR_WIDTH-1: 0]	ext_addr,

	output	logic	[INT_DATA_WIDTH-1: 0]	int_wdata,
	input	logic	[INT_DATA_WIDTH-1: 0]	int_rdata,
	output	logic	[INT_DATA_WIDTH-1: 0]	int_bit_ena,	// Bit Enable
	output	logic	[INT_ADDR_WIDTH-1: 0]	int_addr
);

	logic	[OFF_ADDR_WIDTH-1: 0]	off_addr;
	logic	[OFF_ADDR_WIDTH-1: 0]	off_addr_ff;

	always_comb begin
		int_addr = ext_addr[EXT_ADDR_WIDTH-1: OFF_ADDR_WIDTH];
		off_addr = ext_addr[OFF_ADDR_WIDTH-1: 0];
	end

	always_ff @(posedge clk or negedge rstn) begin
		if(~rstn) begin
			off_addr_ff <= '0;
		end else if(clr) begin
			off_addr_ff <= '0;
		end else if(ena && req && (~we)) begin
			off_addr_ff <= off_addr;
		end
	end

	always_comb begin
		ext_rdata = int_rdata [off_addr_ff*EXT_DATA_WIDTH +: EXT_DATA_WIDTH];

		int_wdata = 0;
		int_bit_ena = 0;

		if(ena && req) begin
			int_wdata[off_addr*EXT_DATA_WIDTH +: EXT_DATA_WIDTH] = ext_wdata;

			for(int i=0; i<EXT_DATA_WIDTH/8; i++) begin
				int_bit_ena[off_addr*EXT_DATA_WIDTH + i*8 +: 8] = {8{ext_byte_ena[i]}};
			end
		end
	end

endmodule
