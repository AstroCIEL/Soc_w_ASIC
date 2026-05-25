module nli_floor(
	input	logic [15: 0]	data,
	output	logic [15: 0]	result_posit,
	output	logic [4: 0]	result_int
);
	posit_floor u_floor(
		.posit_i(data),
		.posit_o(result_posit),
		.int_o(result_int)
	);

endmodule