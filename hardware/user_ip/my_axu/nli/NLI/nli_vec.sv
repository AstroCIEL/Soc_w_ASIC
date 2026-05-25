module nli_vec#(
	parameter   NUM_VEC = 32,
    parameter   NUM_MACROS = 10,
    parameter   NUM_MICROS = 32,
    parameter   DATA_WIDTH = 16,
    localparam  NUM_INTERVALS = (NUM_MACROS-2)*NUM_MICROS + 2,
    localparam  MACRO_INDEX_WIDTH = $clog2(NUM_MACROS),
    localparam  INTERVAL_INDEX_WIDTH = $clog2(NUM_INTERVALS),

    parameter   SUBTRACT_LATENCY = 2,
    parameter   MULTIPLY_LATENCY = 2,
    parameter   ADD_LATENCY = 2
)(
    input   logic                               clk,
    input   logic                               rstn,
    input   logic                               clr,
    input   logic [DATA_WIDTH-1: 0]             macro_bounds [0: NUM_MACROS],

    input   logic [DATA_WIDTH-1: 0]             input_data	[0: NUM_VEC-1],
    output  logic [DATA_WIDTH-1: 0]             output_data	[0: NUM_VEC-1],

    input   logic                               up_valid,
    output  logic                               up_ready,
    output  logic                               dn_valid,
    input   logic                               dn_ready,

    output  logic                               rd_mul_req	[0: NUM_VEC-1],
    output  logic [MACRO_INDEX_WIDTH-1: 0]      rd_mul_addr	[0: NUM_VEC-1], 
    input   logic [DATA_WIDTH-1: 0]             rd_mul_data	[0: NUM_VEC-1],

    output  logic                               rd_interval_y0_req	[0: NUM_VEC-1],
    output  logic [INTERVAL_INDEX_WIDTH-1: 0]   rd_interval_y0_addr	[0: NUM_VEC-1],
    input   logic [DATA_WIDTH-1: 0]             rd_interval_y0_data	[0: NUM_VEC-1],
    output  logic                               rd_interval_y1_req	[0: NUM_VEC-1],
    output  logic [INTERVAL_INDEX_WIDTH-1: 0]   rd_interval_y1_addr	[0: NUM_VEC-1],
    input   logic [DATA_WIDTH-1: 0]             rd_interval_y1_data	[0: NUM_VEC-1]
);

	genvar i;
	generate
		for (i = 0; i < NUM_VEC; i++) begin: gen_vec
			nli #(
				.NUM_MACROS(NUM_MACROS),
				.NUM_MICROS(NUM_MICROS),
				.DATA_WIDTH(DATA_WIDTH),
				.SUBTRACT_LATENCY(SUBTRACT_LATENCY),
				.MULTIPLY_LATENCY(MULTIPLY_LATENCY),
				.ADD_LATENCY(ADD_LATENCY)
			) u_nli(
				.clk(clk),
				.rstn(rstn),
				.clr(clr),
				.macro_bounds(macro_bounds),

				.input_data(input_data[i]),
				.output_data(output_data[i]),

				.up_valid(up_valid),
				.up_ready(up_ready),
				.dn_valid(dn_valid),
				.dn_ready(dn_ready),

				.rd_mul_req(rd_mul_req[i]),
				.rd_mul_addr(rd_mul_addr[i]),
				.rd_mul_data(rd_mul_data[i]),

				.rd_interval_y0_req(rd_interval_y0_req[i]),
				.rd_interval_y0_addr(rd_interval_y0_addr[i]),
				.rd_interval_y0_data(rd_interval_y0_data[i]),
				.rd_interval_y1_req(rd_interval_y1_req[i]),
				.rd_interval_y1_addr(rd_interval_y1_addr[i]),
				.rd_interval_y1_data(rd_interval_y1_data[i])
			);
		end
	endgenerate

endmodule