module pipe_ctrl#(
	parameter PIPE_DEPTH = 1
)(
	input	logic clk,
	input	logic rstn,
	input	logic clr,
	input	logic ena,

	input	logic up_valid,
	output	logic up_ready,
	output	logic dn_valid,
	input	logic dn_ready
);

	logic [PIPE_DEPTH-1:0] valid_pipe;
	logic [PIPE_DEPTH-1:0] ready_pipe;
	generate
		for(genvar k=0; k<PIPE_DEPTH; k++) begin
			if(k==0) begin
				pipe_ctrl_kernel u_pipe_ctrl_kernel(
					.clk(clk),  .rstn(rstn),    .clr(clr),	.ena(ena),
					.up_valid(up_valid),    .up_ready(up_ready),
					.dn_valid(valid_pipe[0]),    .dn_ready(ready_pipe[0])
				);
			end else begin
				pipe_ctrl_kernel u_pipe_ctrl_kernel(
					.clk(clk),  .rstn(rstn),    .clr(clr),  .ena(ena),
					.up_valid(valid_pipe[k-1]),    .up_ready(ready_pipe[k-1]),
					.dn_valid(valid_pipe[k]),    .dn_ready(ready_pipe[k])
				);
			end
		end
	endgenerate

	assign dn_valid = valid_pipe[PIPE_DEPTH-1];
	assign ready_pipe[PIPE_DEPTH-1] = dn_ready;

endmodule

