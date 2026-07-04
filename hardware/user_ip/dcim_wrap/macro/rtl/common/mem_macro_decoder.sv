// Layer 2: bank decode.
// Maps one external port access (read or write) onto per-macro request enables.
// bit_ena / byte_ena remain the final bit-level write mask inside rf_wrap.
//
// Bank index uses slice/shift only (no dividers, no comparators); widths must be power-of-2.
module mem_macro_decoder #(
	parameter PORT_WIDTH     = 64,
	parameter INT_DATA_WIDTH = 2048,
	parameter MACRO_WIDTH    = 128,
	localparam INT_SHIFT       = $clog2(INT_DATA_WIDTH),
	localparam PORT_SHIFT      = $clog2(PORT_WIDTH),
	localparam MACRO_SHIFT     = $clog2(MACRO_WIDTH),
	localparam W_RATIO         = INT_DATA_WIDTH / MACRO_WIDTH,
	localparam CHUNK_OFF_WIDTH = INT_SHIFT - PORT_SHIFT,
	localparam MACRO_IDX_WIDTH = INT_SHIFT - MACRO_SHIFT
)(
	input  logic                       port_narrow,
	input  logic [CHUNK_OFF_WIDTH-1:0] port_off,
	output logic [W_RATIO-1:0]         macro_ena
);

	generate
		if (PORT_WIDTH <= MACRO_WIDTH) begin : gen_port_le_macro
			// 情况 1: 多个 Port 访问才能填满 1 个 Macro
			// 折算比例: 1 个 Macro 包含几个 Port 宽度？
			localparam PORTS_PER_MACRO = MACRO_WIDTH / PORT_WIDTH;
			
			logic [MACRO_IDX_WIDTH-1:0] target_idx;
			
			always_comb begin
				// 物理意义: 将小粒度的 port_off 缩小，找到其归属的大 Macro 索引
				target_idx = port_off[CHUNK_OFF_WIDTH-1 -: MACRO_IDX_WIDTH]; 
				
				if (port_narrow) macro_ena = 1'b1 << target_idx;
				else             macro_ena = '1;
			end

		end else begin : gen_port_gt_macro
			// 情况 2: 1 个 Port 访问会同时覆盖多个 Macro
			// 折算比例: 1 个 Port 包含几个 Macro 宽度？
			localparam MACROS_PER_PORT = PORT_WIDTH / MACRO_WIDTH;
			
			logic [W_RATIO-1:0]         base_mask;
			logic [MACRO_IDX_WIDTH-1:0] base_idx;
			
			always_comb begin
				// 1. 掩码形态: 需要同时使能的 Macro 数量 (例如 4 个 Macro，就是 4'b1111)
				base_mask = {MACROS_PER_PORT{1'b1}};
				
				// 2. 起始位置: 将大粒度的 port_off 放大，定位到 Macro 级别的起始 Base 索引
				base_idx = port_off << (PORT_SHIFT - MACRO_SHIFT);
				
				// 3. 最终使能: 将 4'b1111 平移到对应的 Base 索引处
				if (port_narrow) macro_ena = base_mask << base_idx;
				else             macro_ena = '1;
			end
		end
	endgenerate

	initial begin
		if (INT_DATA_WIDTH <= PORT_WIDTH) begin
			$error("mem_bank_map: INT_DATA_WIDTH must be > PORT_WIDTH");
		end
		if (INT_DATA_WIDTH % PORT_WIDTH != 0) begin
			$error("mem_bank_map: INT_DATA_WIDTH must be an integer multiple of PORT_WIDTH");
		end
		if (INT_DATA_WIDTH % MACRO_WIDTH != 0) begin
			$error("mem_bank_map: INT_DATA_WIDTH must be an integer multiple of MACRO_WIDTH");
		end
		if (PORT_WIDTH > MACRO_WIDTH) begin
			if (PORT_WIDTH % MACRO_WIDTH != 0) begin
				$error("mem_bank_map: PORT_WIDTH and MACRO_WIDTH must be integer multiples");
			end
		end else if (PORT_WIDTH < MACRO_WIDTH) begin
			if (MACRO_WIDTH % PORT_WIDTH != 0) begin
				$error("mem_bank_map: PORT_WIDTH and MACRO_WIDTH must be integer multiples");
			end
		end
		if ((1 << INT_SHIFT) != INT_DATA_WIDTH) begin
			$error("mem_bank_map: INT_DATA_WIDTH must be a power of 2");
		end
		if ((1 << PORT_SHIFT) != PORT_WIDTH) begin
			$error("mem_bank_map: PORT_WIDTH must be a power of 2");
		end
		if ((1 << MACRO_SHIFT) != MACRO_WIDTH) begin
			$error("mem_bank_map: MACRO_WIDTH must be a power of 2");
		end
	end

endmodule
