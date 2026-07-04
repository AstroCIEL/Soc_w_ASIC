// Layer 1: width / protocol adapter.
// Maps a narrow external port onto one INT_DATA_WIDTH word.
// Bit placement uses slice/shift only (no multipliers); widths must be power-of-2.
module mem_width_adapter #(
	parameter EXT_DATA_WIDTH = 64,
	parameter INT_DATA_WIDTH = 2048,
	parameter DEPTH          = 128,
	localparam INT_ADDR_WIDTH = $clog2(DEPTH),
	localparam EXT_SHIFT      = $clog2(EXT_DATA_WIDTH),
	localparam INT_SHIFT      = $clog2(INT_DATA_WIDTH),
	localparam OFF_ADDR_WIDTH = INT_SHIFT - EXT_SHIFT,
	localparam EXT_ADDR_WIDTH = INT_ADDR_WIDTH + OFF_ADDR_WIDTH
)(
	input  logic                       clk,
	input  logic                       rstn,
	input  logic                       clr,
	input  logic                       ena,

	input  logic                       req,
	input  logic                       we,

	input  logic [EXT_DATA_WIDTH-1:0]  ext_wdata,
	output logic [EXT_DATA_WIDTH-1:0]  ext_rdata,
	input  logic [EXT_DATA_WIDTH/8-1:0] ext_byte_ena,
	input  logic [EXT_ADDR_WIDTH-1:0]  ext_addr,

	output logic [INT_DATA_WIDTH-1:0]  int_wdata,
	input  logic [INT_DATA_WIDTH-1:0]  int_rdata,
	output logic [INT_DATA_WIDTH-1:0]  int_bit_ena,
	output logic [INT_ADDR_WIDTH-1:0]  int_addr,

	output logic [OFF_ADDR_WIDTH-1:0]  port_off
);

	logic [OFF_ADDR_WIDTH-1:0] off_addr;
	logic [OFF_ADDR_WIDTH-1:0] off_addr_ff;

	always_comb begin
		int_addr = ext_addr[EXT_ADDR_WIDTH-1: OFF_ADDR_WIDTH];
		off_addr = ext_addr[OFF_ADDR_WIDTH-1: 0];
		port_off = off_addr;
	end

	always_ff @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			off_addr_ff <= '0;
		end else if (clr) begin
			off_addr_ff <= '0;
		end else if (ena && req && (~we)) begin
			off_addr_ff <= off_addr;
		end
	end

	always_comb begin
		ext_rdata = int_rdata[off_addr_ff << EXT_SHIFT +: EXT_DATA_WIDTH];

		int_wdata   = '0;
		int_bit_ena = '0;

		if (ena && req) begin
			int_wdata[off_addr << EXT_SHIFT +: EXT_DATA_WIDTH] = ext_wdata;

			for (int i = 0; i < EXT_DATA_WIDTH / 8; i++) begin
				int_bit_ena[(off_addr << EXT_SHIFT) + i * 8 +: 8] = {8{ext_byte_ena[i]}};
			end
		end
	end

	initial begin
		if (INT_DATA_WIDTH < EXT_DATA_WIDTH) begin
			$error("mem_map: INT_DATA_WIDTH must be >= EXT_DATA_WIDTH");
		end
		if (INT_DATA_WIDTH % EXT_DATA_WIDTH != 0) begin
			$error("mem_map: INT_DATA_WIDTH must be an integer multiple of EXT_DATA_WIDTH");
		end
		if ((1 << EXT_SHIFT) != EXT_DATA_WIDTH) begin
			$error("mem_map: EXT_DATA_WIDTH must be a power of 2");
		end
		if ((1 << INT_SHIFT) != INT_DATA_WIDTH) begin
			$error("mem_map: INT_DATA_WIDTH must be a power of 2");
		end
	end

endmodule
