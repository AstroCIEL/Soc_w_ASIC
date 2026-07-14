module act_mux #(
	parameter	WIDTH	= 256,
	parameter	NUM		= 4
)(
	input	logic [1: 0]		cfg_topo,
	input	logic [WIDTH-1: 0]	up_data[NUM],
	output	logic [WIDTH-1: 0]	dn_data[NUM]
);

	localparam TOPO1 = 2'b00;
	localparam TOPO2 = 2'b10;
	localparam TOPO3 = 2'b11;

	always_comb begin
		case(cfg_topo)
			TOPO1: begin
				for(int i=0; i<NUM; i++) begin
					dn_data[i] = up_data[i];
				end
			end
			TOPO2: begin
				for(int i=0; i<NUM; i++) begin
					dn_data[i] = up_data[i/2];
				end
			end
			TOPO3: begin
				for(int i=0; i<NUM; i++) begin
					dn_data[i] = up_data[i/4];
				end
			end
			default: begin
				for(int i=0; i<NUM; i++) begin
					dn_data[i] = '0;
				end
			end
		endcase
	end

endmodule
