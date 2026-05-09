module asic_dma_accel (
    input  logic       clk_i,
    input  logic       rst_ni,
    AXI_BUS.Slave      cfg,
    AXI_BUS.Master     mst,
    output logic       irq_o
);

localparam logic [11:0] REG_CMD      = 12'h000;
localparam logic [11:0] REG_STATUS   = 12'h008;
localparam logic [11:0] REG_SRC_ADDR = 12'h010;
localparam logic [11:0] REG_DST_ADDR = 12'h018;
localparam logic [11:0] REG_LENGTH   = 12'h020;
localparam logic [11:0] REG_CYCLECNT = 12'h028;
localparam logic [11:0] REG_IRQ_MASK = 12'h030;
localparam logic [11:0] REG_IRQ_STAT = 12'h038;
localparam logic [11:0] REG_RESULT   = 12'h040;

typedef enum logic [2:0] {
    S_IDLE,
    S_AR,
    S_R,
    S_AW,
    S_W,
    S_B
} state_t;

logic        cfg_req, cfg_we;
logic [63:0] cfg_addr, cfg_wdata, cfg_rdata, cfg_rdata_q;

logic [63:0] src_addr_q, dst_addr_q, len_q, cycle_cnt_q;
logic        busy_q, done_q, irq_mask_q, irq_status_q;
logic [63:0] read_data_q;
logic [63:0] result_q;
state_t      state_q;

axi2mem #(
    .AXI_ID_WIDTH   ( $bits(cfg.aw_id)  ),
    .AXI_ADDR_WIDTH ( 64                ),
    .AXI_DATA_WIDTH ( 64                ),
    .AXI_USER_WIDTH ( 1                 )
) i_cfg_axi2mem (
    .clk_i  ( clk_i      ),
    .rst_ni ( rst_ni     ),
    .slave  ( cfg        ),
    .req_o  ( cfg_req    ),
    .we_o   ( cfg_we     ),
    .addr_o ( cfg_addr   ),
    .be_o   (            ),
    .user_o (            ),
    .data_o ( cfg_wdata  ),
    .user_i ( '0         ),
    .data_i ( cfg_rdata  )
);

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        src_addr_q   <= '0;
        dst_addr_q   <= '0;
        len_q        <= 64'd8;
        cycle_cnt_q  <= '0;
        cfg_rdata_q  <= '0;
        result_q     <= '0;
        busy_q       <= 1'b0;
        done_q       <= 1'b0;
        irq_mask_q   <= 1'b0;
        irq_status_q <= 1'b0;
        read_data_q  <= '0;
        state_q      <= S_IDLE;
    end else begin
        if (cfg_req) begin
            if (cfg_we) begin
                unique case (cfg_addr[11:0])
                    REG_CMD: begin
                        if (cfg_wdata[1]) begin
                            done_q       <= 1'b0;
                            irq_status_q <= 1'b0;
                        end
                    end
                    REG_SRC_ADDR: src_addr_q <= cfg_wdata;
                    REG_DST_ADDR: dst_addr_q <= cfg_wdata;
                    REG_LENGTH:   len_q      <= cfg_wdata;
                    REG_IRQ_MASK: irq_mask_q <= cfg_wdata[0];
                    REG_IRQ_STAT: if (cfg_wdata[0]) irq_status_q <= 1'b0;
                    default: ;
                endcase
            end else begin
                unique case (cfg_addr[11:0])
                    REG_STATUS:   cfg_rdata_q <= {62'b0, done_q, busy_q};
                    REG_SRC_ADDR: cfg_rdata_q <= src_addr_q;
                    REG_DST_ADDR: cfg_rdata_q <= dst_addr_q;
                    REG_LENGTH:   cfg_rdata_q <= len_q;
                    REG_CYCLECNT: cfg_rdata_q <= cycle_cnt_q;
                    REG_IRQ_MASK: cfg_rdata_q <= {63'b0, irq_mask_q};
                    REG_IRQ_STAT: cfg_rdata_q <= {63'b0, irq_status_q};
                    REG_RESULT:   cfg_rdata_q <= result_q;
                    default:      cfg_rdata_q <= 64'h0;
                endcase
            end
        end

        if (busy_q) begin
            cycle_cnt_q <= cycle_cnt_q + 64'd1;
        end

        unique case (state_q)
            S_IDLE: begin
                if (cfg_req && cfg_we && (cfg_addr[11:0] == REG_CMD) && cfg_wdata[0] && !busy_q) begin
                    busy_q      <= 1'b1;
                    done_q      <= 1'b0;
                    cycle_cnt_q <= '0;
                    state_q     <= S_AR;
                end
            end
            S_AR: begin
                if (mst.ar_ready) state_q <= S_R;
            end
            S_R: begin
                if (mst.r_valid) begin
                    read_data_q <= mst.r_data;
                    state_q <= S_AW;
                end
            end
            S_AW: begin
                if (mst.aw_ready) state_q <= S_W;
            end
            S_W: begin
                if (mst.w_ready) state_q <= S_B;
            end
            S_B: begin
                if (mst.b_valid) begin
                    busy_q       <= 1'b0;
                    done_q       <= 1'b1;
                    irq_status_q <= 1'b1;
                    result_q     <= read_data_q + 64'd1;
                    state_q      <= S_IDLE;
                end
            end
            default: state_q <= S_IDLE;
        endcase
    end
end

assign cfg_rdata = cfg_rdata_q;

assign mst.aw_id     = '0;
assign mst.aw_addr   = dst_addr_q;
assign mst.aw_len    = 8'd0;
assign mst.aw_size   = 3'b011;
assign mst.aw_burst  = 2'b01;
assign mst.aw_lock   = '0;
assign mst.aw_cache  = '0;
assign mst.aw_prot   = '0;
assign mst.aw_region = '0;
assign mst.aw_user   = '0;
assign mst.aw_qos    = '0;
assign mst.aw_valid  = (state_q == S_AW);

assign mst.w_data    = read_data_q + 64'd1;
assign mst.w_strb    = 8'hFF;
assign mst.w_last    = 1'b1;
assign mst.w_user    = '0;
assign mst.w_valid   = (state_q == S_W);

assign mst.b_ready   = (state_q == S_B);

assign mst.ar_id     = '0;
assign mst.ar_addr   = src_addr_q;
assign mst.ar_len    = 8'd0;
assign mst.ar_size   = 3'b011;
assign mst.ar_burst  = 2'b01;
assign mst.ar_lock   = '0;
assign mst.ar_cache  = '0;
assign mst.ar_prot   = '0;
assign mst.ar_region = '0;
assign mst.ar_user   = '0;
assign mst.ar_qos    = '0;
assign mst.ar_valid  = (state_q == S_AR);

assign mst.r_ready   = (state_q == S_R);

assign irq_o = irq_mask_q & irq_status_q;

endmodule
