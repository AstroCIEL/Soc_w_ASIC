module adapt_cfg #(
	parameter	EXT_DATA_WIDTH	= 64,
	parameter	ACT_DEPTH		= 64,
	parameter	OUT_DEPTH		= 64,

	localparam	EXT_ADDR_WIDTH	= 7,
	localparam	ACT_LENG_WIDTH	= $clog2(ACT_DEPTH+1),
	localparam	OUT_LENG_WIDTH	= $clog2(OUT_DEPTH+1)
)(
	input	logic						clk,
	input	logic						rstn,

	input	logic						ext_req,
	input	logic						ext_we,
	input	logic [EXT_ADDR_WIDTH-1: 0]	ext_addr,
	input	logic [EXT_DATA_WIDTH-1: 0]	ext_wdata,
	output	logic [EXT_DATA_WIDTH-1: 0]	ext_rdata,

	input	logic						ctrl_start,

	output	logic						cfg_ena,
	output	logic [1: 0]				cfg_topo,
	output	logic [2: 0]				cfg_mode,
	output	logic [2: 0]				cfg_acc,
	output	logic 						cfg_loop,
	output	logic [ACT_LENG_WIDTH-1: 0]	cfg_act_length,
	output	logic [OUT_LENG_WIDTH-1: 0] cfg_out_length,
	output	logic						cfg_act_sel,
	output	logic						cfg_out_sel,
	output	logic						cfg_wei_sel,

	output	logic [2: 0]				cfg_ema,
	output	logic [1: 0]				cfg_emaw,
	output	logic						cfg_emas,
	output	logic [1: 0]				cfg_wablm,
	output	logic [1: 0]				cfg_rawlm
);

	always_ff @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			cfg_ena			<= '0;
			cfg_topo		<= '0;
			cfg_mode		<= '0;
			cfg_acc			<= '0;
			cfg_loop		<= '0;
			cfg_act_length	<= '0;
			cfg_out_length	<= '0;
			cfg_act_sel		<= '0;
			cfg_out_sel		<= '0;
			cfg_wei_sel		<= '0;
			cfg_ema			<= 3'b100;
			cfg_emaw		<= 2'b01;
			cfg_emas		<= 1'b0;
			cfg_wablm		<= 2'b01;
			cfg_rawlm		<= 2'b00;
		end else if (ext_req && ext_we) begin
			case (ext_addr[6:3])
				4'h0: 	cfg_ena			<= ext_wdata[0];
				4'h1: 	cfg_topo		<= ext_wdata[1:0];
				4'h2: 	cfg_mode		<= ext_wdata[2:0];
				4'h3: 	cfg_acc			<= ext_wdata[2:0];
				4'h4: 	cfg_loop		<= ext_wdata[0];
				4'h5: 	cfg_act_length	<= ext_wdata[ACT_LENG_WIDTH-1:0];
				4'h6: 	cfg_out_length	<= ext_wdata[OUT_LENG_WIDTH-1:0];
				4'h7: 	cfg_act_sel		<= ext_wdata[0];
				4'h8: 	cfg_out_sel		<= ext_wdata[0];
				4'h9: 	cfg_wei_sel		<= ext_wdata[0];
				4'hA:	cfg_ema			<= ext_wdata[2: 0];
				4'hB:	cfg_emaw		<= ext_wdata[1: 0];
				4'hC:	cfg_emas		<= ext_wdata[0];
				4'hD:	cfg_wablm		<= ext_wdata[1: 0];
				4'hE:	cfg_rawlm		<= ext_wdata[1: 0];
				default: ; // 保持不变
			endcase
		end else if(ctrl_start) begin	// 收到启动脉冲后自动将buffer读写权限变为内部
			cfg_act_sel <= 1'b0;
			cfg_out_sel <= 1'b0;
			cfg_wei_sel <= 1'b0;
		end
	end

	logic [EXT_DATA_WIDTH-1: 0] ext_rdata_combo;

	always_comb begin
		ext_rdata_combo = '0; // 默认高位全部自动补 0
		case (ext_addr[6:3])
			4'h0: 	ext_rdata_combo[0]                  = cfg_ena;
			4'h1: 	ext_rdata_combo[1:0]                = cfg_topo;
			4'h2: 	ext_rdata_combo[2:0]                = cfg_mode;
			4'h3: 	ext_rdata_combo[2:0]                = cfg_acc;
			4'h4: 	ext_rdata_combo[0]                  = cfg_loop;
			4'h5: 	ext_rdata_combo[ACT_LENG_WIDTH-1: 0]= cfg_act_length;
			4'h6: 	ext_rdata_combo[OUT_LENG_WIDTH-1: 0]= cfg_out_length;
			4'h7: 	ext_rdata_combo[0]                  = cfg_act_sel;
			4'h8: 	ext_rdata_combo[0]                  = cfg_out_sel;
			4'h9: 	ext_rdata_combo[0]				  	= cfg_wei_sel;
			4'hA:	ext_rdata_combo[2: 0]				= cfg_ema;
			4'hB:	ext_rdata_combo[1: 0]				= cfg_emaw;
			4'hC:	ext_rdata_combo[0]					= cfg_emas;
			4'hD:	ext_rdata_combo[1: 0]				= cfg_wablm;
			4'hE:	ext_rdata_combo[1: 0]				= cfg_rawlm;
			default: ext_rdata_combo                  	= '0;
		endcase
	end

	// ==========================================
	// 3. 读数据打拍 (Read Data Pipeline) - 慢一拍返回
	// ==========================================
	always_ff @(posedge clk or negedge rstn) begin
		if (~rstn) begin
			ext_rdata <= '0;
		end else if (ext_req && ~ext_we) begin
			ext_rdata <= ext_rdata_combo; // 在有效的读请求下，锁存并输出组合逻辑的值
		end else begin
			ext_rdata <= '0; // 没有读请求时总线清零，避免数据残留
		end
	end
	
endmodule
