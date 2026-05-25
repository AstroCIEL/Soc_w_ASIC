module pipe_ctrl_kernel(
	input	logic clk,
	input	logic rstn,
	input	logic clr,
	input	logic ena,

	input	logic up_valid,
	output	logic up_ready,
	output	logic dn_valid,
	input	logic dn_ready
);

	logic r_valid;
	logic pipe_ena;
	assign pipe_ena = ena & (dn_ready | (~r_valid));

	always_ff @(posedge clk or negedge rstn) begin
		if(~rstn) begin
			r_valid <= 1'b0;
		end else if(clr) begin
			r_valid <= 1'b0;
		end else if(pipe_ena) begin
			r_valid <= up_valid;
		end else begin
			r_valid <= r_valid;
		end
	end

	assign up_ready = ena & pipe_ena;
	assign dn_valid = ena & r_valid;

endmodule