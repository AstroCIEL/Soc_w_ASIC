// Layer 3: physical macro wrapper (64-row macro depth variant).
// Per-macro request is driven by macro_ena; be is the bit-level write mask only.
module mem_phy_array_rf64x128 #(
	parameter DATA_WIDTH    = 512,
	parameter DATA_DEPTH    = 64,
	localparam MACRO_WIDTH  = 128,
	localparam MACRO_DEPTH  = 64,
	localparam W_RATIO      = DATA_WIDTH / MACRO_WIDTH,
	localparam D_RATIO      = DATA_DEPTH / MACRO_DEPTH,
	localparam ADDR_WIDTH   = $clog2(DATA_DEPTH),
	localparam MACRO_ADDRW  = $clog2(MACRO_DEPTH),
	localparam OFFSET_WIDTH = ADDR_WIDTH - MACRO_ADDRW
)(
	input  logic                   clk,
	input  logic                   rstn,
	input  logic                   clr,
	input  logic                   ena,
	input  logic                   req,
	input  logic                   we,
	input  logic [W_RATIO-1:0]     macro_ena,
	input  logic [DATA_WIDTH-1:0]  be,
	input  logic [DATA_WIDTH-1:0]  wdata,
	output logic [DATA_WIDTH-1:0]  rdata,
	input  logic [ADDR_WIDTH-1:0]  addr,

	input  logic [2:0]             cfg_ema,
	input  logic [1:0]             cfg_emaw,
	input  logic                   cfg_emas,
	input  logic [1:0]             cfg_wablm,
	input  logic [1:0]             cfg_rawlm
);

	logic [MACRO_WIDTH-1:0] w_rdata [W_RATIO][D_RATIO];
	logic macro_req [W_RATIO][D_RATIO];

	generate
		if (OFFSET_WIDTH > 0) begin : GenReqSegment
			always_comb begin
				for (int w = 0; w < W_RATIO; w++) begin
					for (int d = 0; d < D_RATIO; d++) begin
						macro_req[w][d] = 1'b0;
					end
				end

				if (ena && req) begin
					for (int w = 0; w < W_RATIO; w++) begin
						if (macro_ena[w]) begin
							macro_req[w][addr[ADDR_WIDTH-1: MACRO_ADDRW]] = 1'b1;
						end
					end
				end
			end
		end else begin : GenReqNoSegment
			always_comb begin
				for (int w = 0; w < W_RATIO; w++) begin
					macro_req[w][0] = 1'b0;
				end

				if (ena && req) begin
					for (int w = 0; w < W_RATIO; w++) begin
						if (macro_ena[w]) begin
							macro_req[w][0] = 1'b1;
						end
					end
				end
			end
		end
	endgenerate

	generate
		if (OFFSET_WIDTH > 0) begin : GenAddrSegment

			logic [OFFSET_WIDTH-1:0] addr_offset_q;

			always_ff @(posedge clk or negedge rstn) begin
				if (~rstn) begin
					addr_offset_q <= '0;
				end else if (clr) begin
					addr_offset_q <= '0;
				end else if (ena & req & ~we) begin
					addr_offset_q <= addr[ADDR_WIDTH-1: MACRO_ADDRW];
				end
			end

			always_comb begin
				for (int w = 0; w < W_RATIO; w++) begin
					rdata[w * MACRO_WIDTH +: MACRO_WIDTH] = w_rdata[w][addr_offset_q];
				end
			end

		end else begin : GenAddrNoSegment

			always_comb begin
				for (int w = 0; w < W_RATIO; w++) begin
					rdata[w * MACRO_WIDTH +: MACRO_WIDTH] = w_rdata[w][0];
				end
			end

		end
	endgenerate

	genvar w_idx, d_idx;
	generate
		for (w_idx = 0; w_idx < W_RATIO; w_idx++) begin : GenWidth
			for (d_idx = 0; d_idx < D_RATIO; d_idx++) begin : GenDepth

			`ifdef MODEL_MEM

				model_mem #(
					.DEPTH(MACRO_DEPTH),
					.DATA_WIDTH(MACRO_WIDTH)
				) u_model_mem (
					.clk   (clk),
					.req   (macro_req[w_idx][d_idx]),
					.we    (we),
					.addr  (addr[MACRO_ADDRW-1:0]),
					.be    (be[w_idx * MACRO_WIDTH +: MACRO_WIDTH]),
					.wdata (wdata[w_idx * MACRO_WIDTH +: MACRO_WIDTH]),
					.rdata (w_rdata[w_idx][d_idx])
				);

			`else

				rf64x128 u_rf (
					.clk   (clk),
					.cen   (~macro_req[w_idx][d_idx]),
					.gwen  (~we),
					.wen   (~be[w_idx * MACRO_WIDTH +: MACRO_WIDTH]),
					.a     (addr[MACRO_ADDRW-1:0]),
					.d     (wdata[w_idx * MACRO_WIDTH +: MACRO_WIDTH]),
					.q     (w_rdata[w_idx][d_idx]),
					.ret1n (1'b1),
					.ema   (cfg_ema),
					.emaw  (cfg_emaw),
					.emas  (cfg_emas),
					.rawl  (1'b0),
					.wabl  (1'b1),
					.rawlm (cfg_rawlm),
					.wablm (cfg_wablm)
				);

			`endif
			end
		end
	endgenerate

	initial begin
		if (DATA_WIDTH % MACRO_WIDTH != 0) begin
			$error("rf_wrap_64x128: DATA_WIDTH must be an integer multiple of MACRO_WIDTH");
		end
		if (DATA_DEPTH % MACRO_DEPTH != 0) begin
			$error("rf_wrap_64x128: DATA_DEPTH must be an integer multiple of MACRO_DEPTH");
		end
	end

endmodule
