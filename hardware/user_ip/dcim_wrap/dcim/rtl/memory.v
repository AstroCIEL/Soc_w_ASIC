module dcim_memory#(
	parameter	DP = 128,	// SRAM DEPTH
	parameter	CYCLE = 8, 	// CH_IN * CH_OUT * WD1 = CYCLE * WIDTH
	parameter	CH_IN = 16,
	parameter	CH_OUT = 16,
	parameter	WD1 = 4,

	parameter	EXT_DATA_WIDTH = 64,

	localparam	WD = CH_IN * CH_OUT * WD1 / CYCLE,
	localparam	ADDR_WD = $clog2(DP),
	localparam	EXT_ADDR_WIDTH = $clog2(DP * WD / EXT_DATA_WIDTH)
)(
	input  							clk,
	input  							rstn,
	input  							clr,
	input  							ena,

	input  [ADDR_WD-1: 0]			addr_load,
	input  							load,
	input							swap,
	input							cfg_sel,

	input							ext_req,
	input							ext_we,
	input  [EXT_ADDR_WIDTH-1: 0] 	ext_addr,
	input  [EXT_DATA_WIDTH/8-1: 0]	ext_byte_ena,
	input  [EXT_DATA_WIDTH-1: 0] 	ext_wdata,
	output [EXT_DATA_WIDTH-1: 0] 	ext_rdata,

	output 							dn_valid,
	output [CH_IN*CH_OUT*WD1-1: 0]	dn_data,

	// voltage: 0.8v
	input  [2: 0]					cfg_ema,	// default: 3'b100
	input  [1: 0]					cfg_emaw,	// default: 2'b01
	input							cfg_emas,	// default: 1'b0
	input  [1: 0]					cfg_wablm,	// default: 2'b01
	input  [1: 0]					cfg_rawlm	// default: 2'b00

);
	wire mid_valid, mid_ready;
	wire [WD-1: 0] mid_data;
	wire fsm_req, fsm_we;
	wire [ADDR_WD-1: 0] fsm_addr;

	mem_wrap_rf128x128 #(
		.EXT_DATA_WIDTH(EXT_DATA_WIDTH),
		.INT_DATA_WIDTH(WD),
		.DEPTH(DP)
	) u_mem_wrap (
		.clk(clk),
		.rstn(rstn),
		.clr(clr),
		.ena(ena),
		.cfg_sel(cfg_sel),
		
		.ext_req(ext_req),
		.ext_we(ext_we),
		.ext_addr(ext_addr),
		.ext_byte_ena(ext_byte_ena),
		.ext_wdata(ext_wdata),
		.ext_rdata(ext_rdata),

		.int_req(fsm_req),
		.int_we(fsm_we),
		.int_addr(fsm_addr),
		.int_bit_ena('1),
		.int_wdata('0),
		.int_rdata(mid_data),
		
		.cfg_ema(cfg_ema),
		.cfg_emaw(cfg_emaw),
		.cfg_emas(cfg_emas),
		.cfg_rawlm(cfg_rawlm),
		.cfg_wablm(cfg_wablm)
	);

	load_fsm#(
		.ADDR_WD(ADDR_WD), .CYCLE(CYCLE)
	) u_load_fsm(
		.clk(clk), .rstn(rstn), .clr(clr), .ena(ena),
		.load(load),		
		.req(fsm_req),
		.we(fsm_we),
		.base_addr(addr_load),
		.addr(fsm_addr)
	);

	pipe_ctrl u_load_pipe_ctrl(
		.clk(clk), .rstn(rstn), .clr(clr), .ena(ena),
		.up_valid(fsm_req), 	.up_ready(),
		.dn_valid(mid_valid),	.dn_ready(1'b1)
	);

	ppCache#(.CH_IN(CH_IN), .CH_OUT(CH_OUT), .WD1(WD1), .CYCLE(CYCLE)) u_ppCache(
		.clk(clk), .rstn(rstn), .clr(clr), .ena(ena),
		.swap(swap),
		.up_valid(mid_valid), .up_data(mid_data),
		.dn_valid(dn_valid),  .dn_data(dn_data)
	);

endmodule

module load_fsm#(
	parameter ADDR_WD = 8,
	parameter CYCLE = 8
)(
	input clk,
	input rstn,
	input clr,
	input ena,
	input load,
	input [ADDR_WD-1: 0] base_addr,
	output [ADDR_WD-1: 0] addr,
	output req,
	output we
);
	localparam IDLE = 1'b0;
	localparam ST_LOAD = 1'b1;
	reg state;
	wire load_cnt_done;
	wire [$clog2(CYCLE)-1: 0] w_load_cnt;
	reg [ADDR_WD-1: 0]		base_addr_q;

	always@(posedge clk) begin
		if(clr) begin
			base_addr_q <= 0;
		end else if(ena && (state==IDLE) && load) begin
			base_addr_q <= base_addr;
		end else begin
			base_addr_q <= base_addr_q;
		end
	end

	always@(posedge clk or negedge rstn) begin
		if(~rstn) begin
			state <= IDLE;
		end else if(clr) begin
			state <= IDLE;
		end else if(ena) begin
			case(state)
				IDLE: begin
					state <= load? ST_LOAD: state;
				end
				ST_LOAD: begin
					state <= load_cnt_done? IDLE: state;
				end
				default: begin
					state <= IDLE;
				end
			endcase
		end else begin
			state <= state;
		end
	end

	dcim_counter#(.UBD(CYCLE)) u_load_counter(
		.clk(clk), .rstn(rstn), .clr(clr), .ena((state==ST_LOAD)),
		.cnt_done(load_cnt_done),
		.cnt(w_load_cnt)
	);

	assign req = (state==ST_LOAD);
	assign we = 1'b0;	// Read Only.
	assign addr = base_addr_q + w_load_cnt;

endmodule
