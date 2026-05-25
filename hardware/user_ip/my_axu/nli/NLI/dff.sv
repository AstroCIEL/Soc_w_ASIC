module dff#(
	parameter WIDTH = 8,
	parameter DEPTH = 10
)(
	input 	logic clk,
	input 	logic rstn,
	input 	logic ena,
	input 	logic [WIDTH-1:0] data_in,
	output 	logic [WIDTH-1:0] data_out
);

	generate
		if(DEPTH > 0) begin
			logic [WIDTH-1: 0] r_data [0: DEPTH-1];

			always_ff @(posedge clk or negedge rstn) begin
				if(~rstn) begin
					for(int i=0; i<DEPTH; i++) begin
						r_data[i] <= '0;
					end
				end else if(ena) begin
					r_data[0] <= data_in;
					for(int i=1; i<DEPTH; i++) begin
						r_data[i] <= r_data[i-1];
					end
				end else begin
					for(int i=0; i<DEPTH; i++) begin
						r_data[i] <= r_data[i];
					end
				end
			end

			assign data_out = r_data[DEPTH-1];
		end else begin
			assign data_out = data_in;
		end
	endgenerate


endmodule