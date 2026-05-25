module nli_add (
	input	logic                   clk,
	input	logic                   rstn,
	input 	logic                   valid,
	input 	logic [15: 0] data1,
	input 	logic [15: 0] data2,
	output 	logic [15: 0] result
);
	posit_add_sub u_posit_add(
    	.clk_i(clk),
    	.rstn_i(rstn),
   		.calc_start_i(valid),
    	.calc_done_o(),
    	.add_sub_mode(1'b0),
    	.a_posit_i(data1),   // 加数A
    	.b_posit_i(data2),   // 加数B
		.sum_posit_o(result)
	);
endmodule