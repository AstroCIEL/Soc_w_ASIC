module dcim_wrap #(
	parameter	AXI_DATA_WIDTH 		= 64,
	parameter	AXI_ADDR_WIDTH 		= 64,

	localparam	ACT_DATA_WIDTH 		= 256,
	localparam  ACT_DEPTH			= 64,
	localparam	ACT_ADDR_WIDTH		= $clog2(ACT_DEPTH),
	localparam	ACT_LENG_WIDTH		= $clog2(ACT_DEPTH + 1),
	localparam	EXT_ACT_ADDR_WIDTH 	= $clog2(ACT_DATA_WIDTH * ACT_DEPTH / AXI_DATA_WIDTH),

	localparam  OUT_DATA_WIDTH 		= 1024,
	localparam  OUT_DEPTH			= 64,
	localparam	OUT_ADDR_WIDTH		= $clog2(OUT_DEPTH),
	localparam	OUT_LENG_WIDTH		= $clog2(OUT_DEPTH + 1),
	localparam  EXT_OUT_ADDR_WIDTH 	= $clog2(OUT_DATA_WIDTH * OUT_DEPTH / AXI_DATA_WIDTH),

	localparam  WEI_DATA_WIDTH 		= 2048,
	localparam	WEI_DEPTH			= 128,
	localparam	WEI_ADDR_WIDTH		= $clog2(WEI_DEPTH),
	localparam  EXT_WEI_ADDR_WIDTH 	= $clog2(WEI_DATA_WIDTH * WEI_DEPTH / AXI_DATA_WIDTH),

	localparam  EXT_CTRL_ADDR_WIDTH	= 5,
	localparam	EXT_CFG_ADDR_WIDTH	= 7,

	localparam	WD1					= 4,
	localparam	CH_IN				= 64,
	localparam	CH_OUT				= 64,
	localparam	SRAM_DP				= 128,
	localparam	CYCLE				= 8,
	localparam	ACC					= 4,
	localparam	SRAM_WD				= CH_IN * CH_OUT * WD1 / CYCLE,
	localparam	EXT_ADDR_WIDTH_WEI	= $clog2(SRAM_DP * SRAM_WD / AXI_DATA_WIDTH),
	localparam	ADDR_WD				= $clog2(SRAM_DP),
	localparam	ACC_UBD_WD			= $clog2(ACC + 1)
)(
	input	logic							clk,
	input	logic							rstn,

	input	logic							axi_req,
	input	logic							axi_we,
	input	logic [AXI_ADDR_WIDTH-1: 0]		axi_addr,
	input	logic [AXI_DATA_WIDTH/8-1: 0]	axi_be,
	input	logic [AXI_DATA_WIDTH-1: 0]		axi_wdata,
	output	logic [AXI_DATA_WIDTH-1: 0]		axi_rdata
);
	// Adapt Decode Signals
	logic						ext_req_ctrl;
	logic						ext_req_cfg;
	logic						ext_req_act[4];
	logic						ext_req_out[4];
	logic						ext_req_wei[4];

	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_ctrl;
	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_cfg;
	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_act[4];
	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_out[4];
	logic [AXI_DATA_WIDTH-1: 0]	ext_rdata_wei[4];

	// Adapt Cfg Signals
	logic						cfg_ena;
	logic [1: 0]				cfg_topo;
	logic [2: 0]				cfg_mode;
	logic [2: 0]				cfg_acc;
	logic 						cfg_loop;
	logic [ACT_LENG_WIDTH-1: 0]	cfg_act_length;
	logic [OUT_LENG_WIDTH-1: 0]	cfg_out_length;
	logic						cfg_act_sel;
	logic						cfg_out_sel;
	logic						cfg_wei_sel;
	logic [2: 0]				cfg_ema;
	logic [1: 0]				cfg_emaw;
	logic						cfg_emas;
	logic [1: 0]				cfg_wablm;
	logic [1: 0]				cfg_rawlm;

	// Adapt Ctrl Signals
	logic						ctrl_clr;
	logic						ctrl_start;
	logic						ctrl_dcim_load;
	logic						ctrl_dcim_swap;

	logic						dcim_valid_cal[4];
	logic						dcim_ready_cal[4];
	logic						dcim_valid_out[4];
	logic						dcim_ready_out[4];

	// Internal ACT Buffer Signals, Driven by Adapt Ctrl
	logic						int_req_act[4];
	logic						int_we_act[4];
	logic [ACT_ADDR_WIDTH-1: 0]	int_addr_act;
	logic [ACT_DATA_WIDTH-1: 0]	int_be_act[4];
	logic [ACT_DATA_WIDTH-1: 0]	int_wdata_act[4];
	logic [ACT_DATA_WIDTH-1: 0]	int_rdata_act[4];

	// Internal OUT Buffer Signals, Driven by DCIM
	logic						int_req_out[4];
	logic						int_we_out[4];
	logic [OUT_ADDR_WIDTH-1: 0]	int_addr_out[4];
	logic [OUT_DATA_WIDTH-1: 0]	int_be_out[4];
	logic [OUT_DATA_WIDTH-1: 0]	int_wdata_out[4];
	logic [OUT_DATA_WIDTH-1: 0]	int_rdata_out[4];

	// ACT Data Muxed.
	logic [ACT_DATA_WIDTH-1: 0]	int_rdata_act_muxed[4];

	assign ext_rdata_ctrl = '0;

	always_comb begin
		for (int i=0; i<4; i++) begin
			int_be_act[i]    = '1;
			int_wdata_act[i] = '0;
			int_be_out[i]    = '1;

			// Ready to receive result when out buffer is in internal mode
			dcim_ready_out[i] = ~cfg_out_sel;
		end
	end

	adapt_decode #(
		.AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
		.AXI_DATA_WIDTH(AXI_DATA_WIDTH)
	) u_adapt_decode (
		.clk            (clk),
		.rstn           (rstn),

		.axi_req        (axi_req),
		.axi_addr       (axi_addr),
		.axi_rdata      (axi_rdata),

		.ext_req_ctrl   (ext_req_ctrl),
		.ext_req_cfg    (ext_req_cfg),
		.ext_req_act    (ext_req_act),
		.ext_req_out    (ext_req_out),
		.ext_req_wei    (ext_req_wei),

		.ext_rdata_ctrl (ext_rdata_ctrl),
		.ext_rdata_cfg  (ext_rdata_cfg),
		.ext_rdata_act  (ext_rdata_act),
		.ext_rdata_out  (ext_rdata_out),
		.ext_rdata_wei  (ext_rdata_wei)
	);

	adapt_cfg #(
		.EXT_DATA_WIDTH (AXI_DATA_WIDTH),
		.ACT_DEPTH      (ACT_DEPTH),
		.OUT_DEPTH      (OUT_DEPTH)
	) u_adapt_cfg (
		.clk            (clk),
		.rstn           (rstn),

		.ext_req        (ext_req_cfg),
		.ext_we         (axi_we),
		.ext_addr       (axi_addr[EXT_CFG_ADDR_WIDTH-1: 0]),
		.ext_wdata      (axi_wdata),
		.ext_rdata      (ext_rdata_cfg),

		.ctrl_start     (ctrl_start),

		.cfg_ena        (cfg_ena),
		.cfg_topo       (cfg_topo),
		.cfg_mode       (cfg_mode),
		.cfg_acc        (cfg_acc),
		.cfg_loop       (cfg_loop),
		.cfg_act_length (cfg_act_length),
		.cfg_out_length (cfg_out_length),
		.cfg_act_sel    (cfg_act_sel),
		.cfg_out_sel    (cfg_out_sel),
		.cfg_wei_sel    (cfg_wei_sel),
		.cfg_ema        (cfg_ema),
		.cfg_emaw       (cfg_emaw),
		.cfg_emas       (cfg_emas),
		.cfg_wablm      (cfg_wablm),
		.cfg_rawlm      (cfg_rawlm)
	);

	adapt_ctrl #(
		.ACT_DEPTH(ACT_DEPTH)
	) u_adapt_ctrl (
		.clk            (clk),
		.rstn           (rstn),
		.ena            (cfg_ena),

		.ext_addr       (axi_addr[EXT_CTRL_ADDR_WIDTH-1: 0]),
		.ext_req        (ext_req_ctrl),
		.ext_we         (axi_we),

		.cfg_loop       (cfg_loop),
		.cfg_topo       (cfg_topo),
		.cfg_act_length (cfg_act_length),

		.ctrl_clr       (ctrl_clr),
		.ctrl_start     (ctrl_start),

		.int_req_act    (int_req_act),
		.int_we_act     (int_we_act),
		.int_addr_act   (int_addr_act),

		.ctrl_dcim_load (ctrl_dcim_load),
		.ctrl_dcim_swap (ctrl_dcim_swap),

		.dcim_valid_cal (dcim_valid_cal),
		.dcim_ready_cal (dcim_ready_cal)
	);

	act_mux #(
		.WIDTH(ACT_DATA_WIDTH),
		.NUM  (4)
	) u_act_mux_act (
		.cfg_topo (cfg_topo),
		.up_data  (int_rdata_act),
		.dn_data  (int_rdata_act_muxed)
	);

	genvar i;
	generate
		for (i=0; i<4; i++) begin : GenArray
			mem_wrap #(
				.EXT_DATA_WIDTH(AXI_DATA_WIDTH),
				.INT_DATA_WIDTH(ACT_DATA_WIDTH),
				.DEPTH        (ACT_DEPTH)
			) u_mem_wrap_act (
				.clk          (clk),
				.rstn         (rstn),
				.clr          (ctrl_clr),
				.ena          (cfg_ena),

				.ext_req      (ext_req_act[i]),
				.ext_we       (axi_we),
				.ext_addr     (axi_addr[EXT_ACT_ADDR_WIDTH-1: 0]),
				.ext_wdata    (axi_wdata),
				.ext_rdata    (ext_rdata_act[i]),
				.ext_byte_ena (axi_be),

				.int_req      (int_req_act[i]),
				.int_we       (int_we_act[i]),
				.int_addr     (int_addr_act),
				.int_wdata    (int_wdata_act[i]),
				.int_rdata    (int_rdata_act[i]),
				.int_bit_ena  (int_be_act[i]),

				.cfg_sel      (cfg_act_sel),
				.cfg_ema      (cfg_ema),
				.cfg_emaw     (cfg_emaw),
				.cfg_emas     (cfg_emas),
				.cfg_wablm    (cfg_wablm),
				.cfg_rawlm    (cfg_rawlm)
			);

			mem_wrap #(
				.EXT_DATA_WIDTH(AXI_DATA_WIDTH),
				.INT_DATA_WIDTH(OUT_DATA_WIDTH),
				.DEPTH        (OUT_DEPTH)
			) u_mem_wrap_out (
				.clk          (clk),
				.rstn         (rstn),
				.clr          (ctrl_clr),
				.ena          (cfg_ena),

				.ext_req      (ext_req_out[i]),
				.ext_we       (axi_we),
				.ext_addr     (axi_addr[EXT_OUT_ADDR_WIDTH-1: 0]),
				.ext_wdata    (axi_wdata),
				.ext_rdata    (ext_rdata_out[i]),
				.ext_byte_ena (axi_be),

				.int_req      (int_req_out[i]),
				.int_we       (int_we_out[i]),
				.int_addr     (int_addr_out[i]),
				.int_wdata    (int_wdata_out[i]),
				.int_rdata    (int_rdata_out[i]),
				.int_bit_ena  (int_be_out[i]),

				.cfg_sel      (cfg_out_sel),
				.cfg_ema      (cfg_ema),
				.cfg_emaw     (cfg_emaw),
				.cfg_emas     (cfg_emas),
				.cfg_wablm    (cfg_wablm),
				.cfg_rawlm    (cfg_rawlm)
			);

			out_receive #(
				.OUT_DATA_WIDTH(OUT_DATA_WIDTH),
				.OUT_DEPTH     (OUT_DEPTH)
			) u_out_receive (
				.clk            (clk),
				.rstn           (rstn),
				.clr            (ctrl_clr),
				.ena            (cfg_ena),
				.cfg_out_length (cfg_out_length),
				.dcim_valid_out (dcim_valid_out[i]),
				.dcim_ready_out (dcim_ready_out[i]),
				.int_req_out    (int_req_out[i]),
				.int_we_out     (int_we_out[i]),
				.int_addr_out   (int_addr_out[i])
			);

			dcim #(
				.WD1           (WD1),
				.CH_IN         (CH_IN),
				.CH_OUT        (CH_OUT),
				.SRAM_DP       (SRAM_DP),
				.CYCLE         (CYCLE),
				.ACC           (ACC),
				.EXT_DATA_WIDTH(AXI_DATA_WIDTH)
			) u_dcim (
				.clk              (clk),
				.rstn             (rstn),
				.clr              (ctrl_clr),
				.ena              (cfg_ena),

				.mode_cal         (cfg_mode),
				.acc              (cfg_acc[ACC_UBD_WD-1: 0]),
				.load_wei         (ctrl_dcim_load),
				.swap_wei         (ctrl_dcim_swap),
				.addr_load        ({{(ADDR_WD-ACT_ADDR_WIDTH){1'b0}}, int_addr_act}),
				.cfg_sel_wei      (cfg_wei_sel),

				.ext_req_wei      (ext_req_wei[i]),
				.ext_we_wei       (axi_we),
				.ext_addr_wei     (axi_addr[EXT_ADDR_WIDTH_WEI-1: 0]),
				.ext_byte_ena_wei (axi_be),
				.ext_wdata_wei    (axi_wdata),
				.ext_rdata_wei    (ext_rdata_wei[i]),

				.cfg_ema          (cfg_ema),
				.cfg_emaw         (cfg_emaw),
				.cfg_emas         (cfg_emas),
				.cfg_wablm        (cfg_wablm),
				.cfg_rawlm        (cfg_rawlm),

				.up_valid_cal     (dcim_valid_cal[i]),
				.up_ready_cal     (dcim_ready_cal[i]),
				.up_data_cal      (int_rdata_act_muxed[i]),

				.dn_valid         (dcim_valid_out[i]),
				.dn_ready         (dcim_ready_out[i]),
				.dn_data          (int_wdata_out[i])
			);
		end
	endgenerate

endmodule
