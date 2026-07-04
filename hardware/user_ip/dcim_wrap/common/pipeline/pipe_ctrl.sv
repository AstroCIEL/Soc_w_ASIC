module pipe_ctrl #(
	parameter DEPTH = 1 // DEPTH >= 1
)(
	input	logic	clk,
	input	logic	rstn,
	input	logic	clr,
	input	logic	ena,

	input	logic	up_valid,
	output	logic	up_ready,
	output	logic	dn_valid,
	input	logic	dn_ready
);

	logic	inst_valid [DEPTH+1];
	logic	inst_ready [DEPTH+1];

	genvar d;
	generate
		for(d=0; d<DEPTH; d++) begin:GenPipeCtrlSignle
			pipe_ctrl_single u_pipe_ctrl_single(
				.clk(clk),
				.rstn(rstn),
				.clr(clr),
				.ena(ena),
				.up_valid(inst_valid[d]	),
				.up_ready(inst_ready[d]	),
				.dn_valid(inst_valid[d+1]),
				.dn_ready(inst_ready[d+1])
			);
		end
	endgenerate

	always_comb begin /* verilator lint_off ALWCOMBORDER */
		inst_valid[0] = up_valid;
		up_ready = inst_ready[0];
		dn_valid = inst_valid[DEPTH];
		inst_ready[DEPTH] = dn_ready;
	end

endmodule

module pipe_ctrl_single (
	input	logic	clk,
	input	logic	rstn,
	input	logic	clr,
	input	logic	ena,

	input 	logic	up_valid,
	output	logic	up_ready,
	output	logic	dn_valid,
	input	logic	dn_ready
);

	logic r_valid;

	always_ff @(posedge clk or negedge rstn) begin
		if(~rstn) begin
			r_valid <= 1'b0;
		end else if(clr) begin
			r_valid <= 1'b0;
		end else if(ena) begin
			r_valid <= up_valid | (r_valid & (~dn_ready));
		end
	end

	always_comb begin
		up_ready = dn_ready | (~r_valid);
		dn_valid = r_valid;
	end

endmodule

