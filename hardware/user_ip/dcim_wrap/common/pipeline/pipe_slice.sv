module pipe_slice_fwd #(
	parameter WIDTH = 1
)(
	input	logic				clk,
	input	logic				rstn,
	input	logic				clr,
	input	logic				ena,

	input	logic				up_valid,
	output	logic				up_ready,
	input	logic [WIDTH-1: 0]	up_data,

	output	logic				dn_valid,
	input	logic				dn_ready,
	output	logic [WIDTH-1: 0]	dn_data
);

	logic	r_valid;

	always_ff @(posedge clk or negedge rstn) begin
		if(~rstn) begin
			r_valid <= 1'b0;
		end else if(clr) begin
			r_valid <= 1'b0;
		end else if(ena) begin
			r_valid <= up_valid | (r_valid & (~dn_ready));
		end
	end

	always_ff @(posedge clk) begin
		if(ena && up_valid && up_ready) begin
			dn_data <= up_data;
		end
	end

	always_comb begin
		up_ready = dn_ready | (~r_valid);
		dn_valid = r_valid;
	end

endmodule


module pipe_slice_bwd #(
	parameter	WIDTH = 1
)(
	input	logic				clk,
	input	logic				rstn,
	input	logic				clr,
	input	logic				ena,

	input	logic				up_valid,
	output	logic				up_ready,
	input	logic [WIDTH-1: 0]	up_data,

	output	logic				dn_valid,
	input	logic				dn_ready,
	output	logic [WIDTH-1 :0]	dn_data
);

	logic				r_ready;
	logic [WIDTH-1: 0]	r_data;
	
	always_ff @(posedge clk or negedge rstn) begin
		if(~rstn) begin
			r_ready <= 1'b1;
		end else if(clr) begin
			r_ready <= 1'b1;
		end else if(ena) begin
			r_ready <= dn_ready | (r_ready &(~up_valid));
		end
	end

	always_ff @(posedge clk) begin
		if(ena && up_valid && r_ready && (~dn_ready)) begin
			r_data <= up_data;
		end
	end

	always_comb begin
		up_ready = r_ready;
		dn_valid = up_valid | (~r_ready);
		dn_data = r_ready? up_data: r_data;
	end

endmodule


module pipe_slice_full #(
	parameter	WIDTH = 1
)(
	input	logic				clk,
	input	logic				rstn,
	input	logic				clr,
	input	logic				ena,

	input	logic				up_valid,
	output	logic				up_ready,
	input	logic [WIDTH-1: 0]	up_data,

	output	logic				dn_valid,
	input	logic				dn_ready,
	output	logic [WIDTH-1: 0]	dn_data
);

	logic				mid_valid;
	logic				mid_ready;
	logic [WIDTH-1 : 0]	mid_data;

	// 思考为什么bwd模块要放在fwd模块前面而不是反过来

	pipe_slice_bwd #(
		.WIDTH(WIDTH)
	) u_pipe_slice_bwd (
		.clk(clk),	.rstn(rstn),	.clr(clr),	.ena(ena),
		.up_valid(up_valid),	.up_ready(up_ready),	.up_data(up_data),
		.dn_valid(mid_valid),	.dn_ready(mid_ready),	.dn_data(mid_data)
	);


	pipe_slice_fwd #(
		.WIDTH(WIDTH)
	) u_pipe_slice_fwd (
		.clk(clk),	.rstn(rstn),	.clr(clr),	.ena(ena),
		.up_valid(mid_valid),	.up_ready(mid_ready),	.up_data(mid_data),
		.dn_valid(dn_valid),	.dn_ready(dn_ready),	.dn_data(dn_data)
	);

endmodule
