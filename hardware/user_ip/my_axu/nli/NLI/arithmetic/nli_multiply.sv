module nli_multiply(
	input	logic   		clk,
	input	logic   		rstn,
	input	logic			valid,
	input	logic [15: 0]	data1,
	input	logic [15: 0]	data2,
	output	logic [15: 0]	result
);

	logic [15: 0] result_posit_vec [0:0];
	logic [15: 0] data1_vec [0:0];
	logic [15: 0] data2_vec [0:0];
	assign data1_vec[0] = data1;
	assign data2_vec[0] = data2;
	posit_mult_vec_pipe2 #(
		.NUM_MULT(1)
	) u_post_multiply(
		.clk_i(clk),
		.rstn_i(rstn),
		.calc_start_i(valid),
		.calc_done_o(),
		.vec_a_i(data1_vec),
		.vec_b_i(data2_vec),
		.vec_c_o(result_posit_vec)
	);

	assign result = result_posit_vec[0];

endmodule