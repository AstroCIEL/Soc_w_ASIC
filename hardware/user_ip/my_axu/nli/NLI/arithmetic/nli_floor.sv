module nli_floor(
	input  logic              clk_i,
    input  logic              rstn_i,
	input	logic [15: 0]	data,
	output	logic [15: 0]	result_posit,
	output	logic [4: 0]	result_int
);
	posit_floor u_floor(
		.clk_i(clk_i),
		.rstn_i(rstn_i),
		.posit_i(data),
		.posit_o(result_posit),
		.int_o(result_int)
	);

endmodule