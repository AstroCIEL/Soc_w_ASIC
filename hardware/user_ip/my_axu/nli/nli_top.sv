module nli_top#(
	// Vectorization
	parameter   NUM_LANES   = 32,
	// Original NLI parameters
	parameter 	NUM_MACROS = 10,
	localparam 	MACRO_INDEX_WIDTH = $clog2(NUM_MACROS), // =4
	parameter 	NUM_MICROS = 32,
	localparam 	INTERVAL_INDEX_WIDTH = $clog2((NUM_MACROS-2)*NUM_MICROS + 2), // =9
	parameter 	DATA_WIDTH = 16
)(
	input	logic		 				clk,
	input	logic		 				rstn,
	input	logic		 				clr,
	input   logic [DATA_WIDTH-1: 0] 	macro_bounds [0: NUM_MACROS],

	// Lockstep handshake shared by all NUM_LANES lanes.
	input	logic		 				up_valid,
	output	logic						up_ready,
	output	logic						dn_valid,
	input	logic						dn_ready,

	input	logic [DATA_WIDTH-1: 0] 	input_data  [0: NUM_LANES-1],
	output	logic [DATA_WIDTH-1: 0] 	output_data [0: NUM_LANES-1],

	// External init / write ports for the two LUTs. These are broadcast to
	// every per-lane LUT copy so all 32 copies stay bit-identical.
	input	logic							    mul_lut_wr_en,
	input	logic [MACRO_INDEX_WIDTH-1: 0]	    mul_lut_wr_addr,
	input	logic [DATA_WIDTH-1: 0]			    mul_lut_wr_data,

	input	logic							    y_bounds_lut_wr_en,
	input	logic [INTERVAL_INDEX_WIDTH-1: 0]	y_bounds_lut_wr_addr,
	input	logic [DATA_WIDTH-1: 0]			    y_bounds_lut_wr_data
);

	// Per-lane internal control buses. Each lane has private LUT read paths
	// because the per-lane input_data lands on different macro/interval
	// indices.
	logic 								rd_mul_req			[0: NUM_LANES-1];
	logic [MACRO_INDEX_WIDTH-1: 0] 		rd_mul_addr			[0: NUM_LANES-1];
	logic [DATA_WIDTH-1: 0] 			rd_mul_data			[0: NUM_LANES-1];

	logic 								rd_interval_y0_req	[0: NUM_LANES-1];
	logic [INTERVAL_INDEX_WIDTH-1: 0] 	rd_interval_y0_addr	[0: NUM_LANES-1];
	logic [DATA_WIDTH-1: 0] 			rd_interval_y0_data	[0: NUM_LANES-1];

	logic 								rd_interval_y1_req	[0: NUM_LANES-1];
	logic [INTERVAL_INDEX_WIDTH-1: 0] 	rd_interval_y1_addr	[0: NUM_LANES-1];
	logic [DATA_WIDTH-1: 0] 			rd_interval_y1_data	[0: NUM_LANES-1];

	// Per-lane handshake outputs from each nli instance. Because every lane
	// gets identical control signals, parameters, and LUT contents, these are
	// guaranteed to be identical across all i, so we expose lane 0 to the
	// outside world.
	logic 								up_ready_lane		[0: NUM_LANES-1];
	logic 								dn_valid_lane		[0: NUM_LANES-1];

	assign up_ready = up_ready_lane[0];
	assign dn_valid = dn_valid_lane[0];

	genvar i;
	generate
		for (i = 0; i < NUM_LANES; i++) begin: nli_lane
			nli #(
				.NUM_MACROS(NUM_MACROS),
				.NUM_MICROS(NUM_MICROS),
				.DATA_WIDTH(DATA_WIDTH),
				.SUBTRACT_LATENCY(2),
				.MULTIPLY_LATENCY(2),
				.ADD_LATENCY(2)
			) u_nli (
				.clk(clk),
				.rstn(rstn),
				.clr(clr),
				.macro_bounds(macro_bounds),

				.input_data (input_data[i]),
				.output_data(output_data[i]),

				.up_valid(up_valid),
				.up_ready(up_ready_lane[i]),
				.dn_valid(dn_valid_lane[i]),
				.dn_ready(dn_ready),

				.rd_mul_req (rd_mul_req[i]),
				.rd_mul_addr(rd_mul_addr[i]),
				.rd_mul_data(rd_mul_data[i]),

				.rd_interval_y0_req (rd_interval_y0_req[i]),
				.rd_interval_y0_addr(rd_interval_y0_addr[i]),
				.rd_interval_y0_data(rd_interval_y0_data[i]),
				.rd_interval_y1_req (rd_interval_y1_req[i]),
				.rd_interval_y1_addr(rd_interval_y1_addr[i]),
				.rd_interval_y1_data(rd_interval_y1_data[i])
			);

		model_mul_LUT #(
			.NUM_MACROS(NUM_MACROS),
			.WIDTH(DATA_WIDTH)
		) u_model_mul_LUT (
			.clk(clk),
			// Broadcast write port: identical wr_* on every lane copy.
			.wr_en  (mul_lut_wr_en),
			.wr_addr(mul_lut_wr_addr),
			.wr_data(mul_lut_wr_data),
			// Per-lane read port
			.rd_req (rd_mul_req[i]),
			.rd_addr(rd_mul_addr[i]),
			.rd_data(rd_mul_data[i])
		);

		model_y_bounds_LUT #(
			.NUM_INTERVALS((NUM_MACROS-2)*NUM_MICROS + 2),
			.WIDTH(DATA_WIDTH)
		) u_model_y_bounds_LUT (
			.clk(clk),
			// Broadcast write port: identical wr_* on every lane copy.
			.wr_en  (y_bounds_lut_wr_en),
			.wr_addr(y_bounds_lut_wr_addr),
			.wr_data(y_bounds_lut_wr_data),
			// Per-lane dual read ports
			.rd_req0 (rd_interval_y0_req[i]),
			.rd_addr0(rd_interval_y0_addr[i]),
			.rd_data0(rd_interval_y0_data[i]),
			.rd_req1 (rd_interval_y1_req[i]),
			.rd_addr1(rd_interval_y1_addr[i]),
			.rd_data1(rd_interval_y1_data[i])
		);
		end
	endgenerate

endmodule
