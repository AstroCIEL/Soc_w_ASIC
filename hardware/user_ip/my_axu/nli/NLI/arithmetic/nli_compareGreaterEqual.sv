module nli_compareGreaterEqual(
	input	logic [15: 0]	data1,
	input	logic [15: 0]	data2,
	output	logic			greater_equal
);
	CompareGreaterEqual u_comparator(
		.a_i(data1),
		.b_i(data2),
		.ge_o(greater_equal)
	);
endmodule