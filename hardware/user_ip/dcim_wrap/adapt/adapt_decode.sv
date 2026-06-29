module adapt_decode #(
	parameter	AXI_ADDR_WIDTH	= 64,
	parameter	AXI_DATA_WIDTH	= 64
)(
	input	logic						clk,
	input	logic						rstn,

	input	logic						axi_req,
	input	logic [AXI_ADDR_WIDTH-1: 0]	axi_addr,
	output	logic [AXI_DATA_WIDTH-1: 0]	axi_rdata,

	output	logic						ext_req_ctrl,
	output	logic						ext_req_cfg,
	output	logic						ext_req_act[4],
	output	logic						ext_req_out[4],
	output	logic						ext_req_wei[4],

	input	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_ctrl,
	input	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_cfg,
	input	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_act[4],
	input	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_out[4],
	input	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_wei[4]
);

	logic [2: 0] region_sel;
	always_comb begin
		region_sel 		= axi_addr[19: 17];

		ext_req_ctrl 	= (region_sel == 3'b000) && axi_req;

		ext_req_cfg	 	= (region_sel == 3'b001) && axi_req;

		ext_req_act[0]	= (region_sel == 3'b010) && (axi_addr[12: 11] == 2'b00) && axi_req;
		ext_req_act[1]	= (region_sel == 3'b010) && (axi_addr[12: 11] == 2'b01) && axi_req;
		ext_req_act[2]	= (region_sel == 3'b010) && (axi_addr[12: 11] == 2'b10) && axi_req;
		ext_req_act[3]	= (region_sel == 3'b010) && (axi_addr[12: 11] == 2'b11) && axi_req;

		ext_req_out[0]	= (region_sel == 3'b011) && (axi_addr[14: 13] == 2'b00) && axi_req;
		ext_req_out[1]	= (region_sel == 3'b011) && (axi_addr[14: 13] == 2'b01) && axi_req;
		ext_req_out[2]	= (region_sel == 3'b011) && (axi_addr[14: 13] == 2'b10) && axi_req;
		ext_req_out[3]	= (region_sel == 3'b011) && (axi_addr[14: 13] == 2'b11) && axi_req;

		ext_req_wei[0]	= (region_sel == 3'b100) && (axi_addr[16: 15] == 2'b00) && axi_req;
		ext_req_wei[1]	= (region_sel == 3'b100) && (axi_addr[16: 15] == 2'b01) && axi_req;
		ext_req_wei[2]	= (region_sel == 3'b100) && (axi_addr[16: 15] == 2'b10) && axi_req;
		ext_req_wei[3]	= (region_sel == 3'b100) && (axi_addr[16: 15] == 2'b11) && axi_req;
	end

	logic req_ctrl_q;
	logic req_cfg_q;
	logic req_act_q[4];
	logic req_out_q[4];
	logic req_wei_q[4];

	always_ff @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			req_cfg_q    <= 1'b0;
			req_ctrl_q   <= 1'b0;
			for (int i=0; i<4; i++) begin
				req_act_q[i] <= 1'b0;
				req_out_q[i] <= 1'b0;
				req_wei_q[i] <= 1'b0;
			end
		end else begin
			req_cfg_q    <= ext_req_cfg;
			req_ctrl_q   <= ext_req_ctrl;
			for (int i=0; i<4; i++) begin
				req_act_q[i] <= ext_req_act[i];
				req_out_q[i] <= ext_req_out[i];
				req_wei_q[i] <= ext_req_wei[i];
			end
		end
	end

	always_comb begin
		axi_rdata = '0;
		if (req_ctrl_q) begin
			axi_rdata = ext_rdata_ctrl;
		end else if (req_cfg_q) begin
			axi_rdata = ext_rdata_cfg;
		end else if (req_wei_q[0]) begin
			axi_rdata = ext_rdata_wei[0];
		end else if (req_wei_q[1]) begin
			axi_rdata = ext_rdata_wei[1];
		end else if (req_wei_q[2]) begin
			axi_rdata = ext_rdata_wei[2];
		end else if (req_wei_q[3]) begin
			axi_rdata = ext_rdata_wei[3];
		end else if (req_act_q[0]) begin
			axi_rdata = ext_rdata_act[0];
		end else if (req_act_q[1]) begin
			axi_rdata = ext_rdata_act[1];
		end else if (req_act_q[2]) begin
			axi_rdata = ext_rdata_act[2];
		end else if (req_act_q[3]) begin
			axi_rdata = ext_rdata_act[3];
		end else if (req_out_q[0]) begin
			axi_rdata = ext_rdata_out[0];
		end else if (req_out_q[1]) begin
			axi_rdata = ext_rdata_out[1];
		end else if (req_out_q[2]) begin
			axi_rdata = ext_rdata_out[2];
		end else if (req_out_q[3]) begin
			axi_rdata = ext_rdata_out[3];
		end
	end

endmodule
