module adapt_ctrl #(
	parameter	ACT_DEPTH		= 64,

	localparam	ACT_LENG_WIDTH	= $clog2(ACT_DEPTH+1),
	localparam	ACT_ADDR_WIDTH	= $clog2(ACT_DEPTH),

	localparam	CTRL_ADDR_WIDTH	= 5

)(
	input	logic							clk,
	input	logic							rstn,
	input	logic							ena,

	input	logic	[CTRL_ADDR_WIDTH-1: 0]	ext_addr,
	input	logic							ext_req,
	input	logic							ext_we,

	input	logic							cfg_loop,
	input	logic	[1: 0]					cfg_topo,

	input	logic	[ACT_LENG_WIDTH-1: 0]	cfg_act_length,

	output	logic							ctrl_clr,
	output	logic							ctrl_start,

	output	logic							int_req_act [4],
	output	logic							int_we_act	[4],
	output	logic	[ACT_ADDR_WIDTH-1: 0]	int_addr_act,

	output	logic							ctrl_dcim_load,
	output	logic							ctrl_dcim_swap,

	output	logic							dcim_valid_cal[4],
	input	logic							dcim_ready_cal[4]
);

	localparam TOPO1 = 2'b00;
	localparam TOPO2 = 2'b10;
	localparam TOPO3 = 2'b11;

	logic [ACT_ADDR_WIDTH-1: 0]	w_cnt;
	logic						w_up_ready;
	logic						w_cnt_done;
	logic						w_valid_cal;
	logic						w_ready_cal;
	logic						act_issue;
	logic						act_read_req;

	localparam	STATE_IDLE 	= 1'b0;
	localparam	STATE_RUN	= 1'b1;
	logic state, n_state;

	always_comb begin
		ctrl_start		= (ext_addr[4: 3] == 2'b00) && ext_req && ext_we;
		ctrl_clr		= (ext_addr[4: 3] == 2'b01) && ext_req && ext_we;
		ctrl_dcim_load	= (ext_addr[4: 3] == 2'b10) && ext_req && ext_we;
		ctrl_dcim_swap	= (ext_addr[4: 3] == 2'b11) && ext_req && ext_we;

		act_issue = (state == STATE_RUN) && w_up_ready;
		int_addr_act = w_cnt;

		for (int i=0; i<4; i++) begin
			int_we_act[i] = 1'b0;
			int_req_act[i] = act_issue;
			dcim_valid_cal[i] = w_valid_cal;
		end

		act_read_req = int_req_act[0] | int_req_act[1] | int_req_act[2] | int_req_act[3];

		w_ready_cal = 1'b1;
		for (int i=0; i<4; i++) begin
			w_ready_cal &= dcim_ready_cal[i];
		end
	end

	always_comb begin
		case(state)
			STATE_IDLE: begin
				n_state = ctrl_start? STATE_RUN: STATE_IDLE;
			end
			STATE_RUN: begin
				if(cfg_loop) begin
					n_state = STATE_RUN;
				end else if(w_cnt_done) begin
					n_state = STATE_IDLE;
				end else begin
					n_state = STATE_RUN;
				end
			end
			default: begin
				n_state = STATE_IDLE;
			end
		endcase
	end

	always_ff @(posedge clk or negedge rstn) begin
		if(~rstn) begin
			state <= STATE_IDLE;
		end else if(ctrl_clr) begin
			state <= STATE_IDLE;
		end else if(ena) begin
			state <= n_state;
		end
	end

	dcim_counter_cfg #(.UBD_MAX(ACT_DEPTH)) u_counter_cfg(
		.clk(clk),
		.rstn(rstn),
		.clr(ctrl_clr),
		.ena(ena && act_read_req && w_up_ready),
		.ubd(cfg_act_length),
		.cnt(w_cnt),
		.cnt_done(w_cnt_done)
	);

	pipe_ctrl #(.DEPTH(1)) u_pipe_ctrl (
		.clk(clk),
		.rstn(rstn),
		.clr(ctrl_clr),
		.ena(ena),
		.up_valid(act_read_req),
		.up_ready(w_up_ready),
		.dn_valid(w_valid_cal),
		.dn_ready(w_ready_cal)
	);

endmodule
