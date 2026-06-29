module out_receive #(
	parameter	OUT_DATA_WIDTH	= 1024,
	parameter	OUT_DEPTH		= 64,
	localparam	OUT_ADDR_WIDTH	= $clog2(OUT_DEPTH),
	localparam	OUT_LENG_WIDTH	= $clog2(OUT_DEPTH+1)
) (
	input	logic						clk,
	input	logic						rstn,
	input	logic						clr,
	input	logic						ena,

	input	logic [OUT_LENG_WIDTH-1: 0]	cfg_out_length,

	input	logic						dcim_valid_out,
	input	logic						dcim_ready_out,

	output	logic						int_req_out,
	output	logic [OUT_ADDR_WIDTH-1: 0]	int_addr_out,
	output	logic						int_we_out
);

	always_comb begin
		int_we_out = 1'b1;
		int_req_out	= ena && dcim_valid_out && dcim_ready_out;
	end

	counter_cfg #(.UBD_MAX(OUT_DEPTH)) u_counter_cfg(
		.clk(clk),
		.rstn(rstn),
		.clr(clr),
		.ena(ena && dcim_valid_out && dcim_ready_out),
		.ubd(cfg_out_length),
		.cnt(int_addr_out),
		.cnt_done()
	);

endmodule
