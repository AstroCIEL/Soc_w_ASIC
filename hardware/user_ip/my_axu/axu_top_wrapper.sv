module axu_top_wrapper #(
    parameter int unsigned NUM_LANE        = 64,
    parameter int unsigned ELEM_WIDTH      = 16,
    parameter int unsigned ES              = 2,
    parameter int unsigned BANK_WIDTH      = 128,
    parameter int unsigned BANK_NUM        = (NUM_LANE * ELEM_WIDTH) / BANK_WIDTH,
    parameter int unsigned ADDR_WIDTH      = 8,
    parameter int unsigned CFG_ADDR_WIDTH  = 4,
    parameter int unsigned ALIGN_WIDTH     = 14,
    parameter int unsigned ACC_ALIGN_WIDTH = 32,
    parameter int unsigned SFU_LANE        = NUM_LANE / 2,
    parameter int unsigned SFU_RAND_N      = ELEM_WIDTH,
    parameter int unsigned SFU_ALIGN_WIDTH = ACC_ALIGN_WIDTH,
    parameter int unsigned SFU_NUM_ITER    = 7,
    parameter int unsigned NLI_NUM_LANES   = SFU_LANE,
    parameter int unsigned NLI_NUM_MACROS  = 10,
    parameter int unsigned NLI_NUM_MICROS  = 32,
    parameter int unsigned AXI_ADDR_WIDTH  = 64,
    parameter int unsigned AXI_DATA_WIDTH  = 64
)(
    input  logic       clk_i,
    input  logic       rst_ni,

    AXI_BUS.Slave      cfg,
    AXI_BUS.Slave      op_a_buf,
    AXI_BUS.Slave      op_b_buf,
    AXI_BUS.Slave      out_buf,

    output logic       irq_o
);

localparam logic [11:0] REG_CTRL        = 12'h000;
localparam logic [11:0] REG_STATUS      = 12'h008;
localparam logic [11:0] REG_OP_A_BUF_CTL = 12'h010;
localparam logic [11:0] REG_OP_B_BUF_CTL = 12'h018;
localparam logic [11:0] REG_OUT_BUF_CTL = 12'h020;
localparam logic [11:0] REG_CFG_WRITE   = 12'h030;
localparam logic [11:0] REG_IRQ_MASK    = 12'h038;
localparam logic [11:0] REG_IRQ_STAT    = 12'h040;

logic                                cfg_req;
logic                                cfg_we;
logic [AXI_ADDR_WIDTH-1:0]           cfg_addr;
logic [AXI_DATA_WIDTH-1:0]           cfg_wdata;
logic [AXI_DATA_WIDTH-1:0]           cfg_rdata;
logic [AXI_DATA_WIDTH-1:0]           cfg_rdata_q;

logic                                op_a_buf_req;
logic                                op_a_buf_we;
logic [AXI_ADDR_WIDTH-1:0]           op_a_buf_addr;
logic [AXI_DATA_WIDTH/8-1:0]         op_a_buf_be;
logic [AXI_DATA_WIDTH-1:0]           op_a_buf_wdata;
logic [AXI_DATA_WIDTH-1:0]           op_a_buf_rdata;

logic                                op_b_buf_req;
logic                                op_b_buf_we;
logic [AXI_ADDR_WIDTH-1:0]           op_b_buf_addr;
logic [AXI_DATA_WIDTH/8-1:0]         op_b_buf_be;
logic [AXI_DATA_WIDTH-1:0]           op_b_buf_wdata;
logic [AXI_DATA_WIDTH-1:0]           op_b_buf_rdata;

logic                                out_buf_req;
logic                                out_buf_we;
logic [AXI_ADDR_WIDTH-1:0]           out_buf_addr;
logic [AXI_DATA_WIDTH/8-1:0]         out_buf_be;
logic [AXI_DATA_WIDTH-1:0]           out_buf_wdata;
logic [AXI_DATA_WIDTH-1:0]           out_buf_rdata;

logic                                op_a_acc_rd_port_sel_q;
logic                                op_a_acc_wr_port_sel_q;
logic                                op_b_acc_rd_port_sel_q;
logic                                op_b_acc_wr_port_sel_q;
logic                                out_acc_rd_port_sel_q;
logic                                out_acc_wr_port_sel_q;
logic                                done_sticky_q;
logic                                irq_mask_q;
logic                                irq_status_q;

logic                                axu_busy;
logic                                axu_done;
logic                                axu_calc_done;
logic                                start_pulse;
logic                                cfg_set_pulse;
logic [CFG_ADDR_WIDTH-1:0]           axu_cfg_addr;
logic [ADDR_WIDTH-1:0]               axu_cfg_data;

axi2mem #(
    .AXI_ID_WIDTH   ( $bits(cfg.aw_id) ),
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    .AXI_USER_WIDTH ( 1 )
) i_cfg_axi2mem (
    .clk_i  ( clk_i ),
    .rst_ni ( rst_ni ),
    .slave  ( cfg ),
    .req_o  ( cfg_req ),
    .we_o   ( cfg_we ),
    .addr_o ( cfg_addr ),
    .be_o   ( ),
    .user_o ( ),
    .data_o ( cfg_wdata ),
    .user_i ( '0 ),
    .data_i ( cfg_rdata )
);

axi2mem #(
    .AXI_ID_WIDTH   ( $bits(op_a_buf.aw_id) ),
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    .AXI_USER_WIDTH ( 1 )
) i_op_a_buf_axi2mem (
    .clk_i  ( clk_i ),
    .rst_ni ( rst_ni ),
    .slave  ( op_a_buf ),
    .req_o  ( op_a_buf_req ),
    .we_o   ( op_a_buf_we ),
    .addr_o ( op_a_buf_addr ),
    .be_o   ( op_a_buf_be ),
    .user_o ( ),
    .data_o ( op_a_buf_wdata ),
    .user_i ( '0 ),
    .data_i ( op_a_buf_rdata )
);

axi2mem #(
    .AXI_ID_WIDTH   ( $bits(op_b_buf.aw_id) ),
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    .AXI_USER_WIDTH ( 1 )
) i_op_b_buf_axi2mem (
    .clk_i  ( clk_i ),
    .rst_ni ( rst_ni ),
    .slave  ( op_b_buf ),
    .req_o  ( op_b_buf_req ),
    .we_o   ( op_b_buf_we ),
    .addr_o ( op_b_buf_addr ),
    .be_o   ( op_b_buf_be ),
    .user_o ( ),
    .data_o ( op_b_buf_wdata ),
    .user_i ( '0 ),
    .data_i ( op_b_buf_rdata )
);

axi2mem #(
    .AXI_ID_WIDTH   ( $bits(out_buf.aw_id) ),
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    .AXI_USER_WIDTH ( 1 )
) i_out_buf_axi2mem (
    .clk_i  ( clk_i ),
    .rst_ni ( rst_ni ),
    .slave  ( out_buf ),
    .req_o  ( out_buf_req ),
    .we_o   ( out_buf_we ),
    .addr_o ( out_buf_addr ),
    .be_o   ( out_buf_be ),
    .user_o ( ),
    .data_o ( out_buf_wdata ),
    .user_i ( '0 ),
    .data_i ( out_buf_rdata )
);

assign start_pulse   = cfg_req && cfg_we && (cfg_addr[11:0] == REG_CTRL) && cfg_wdata[0];
assign cfg_set_pulse = cfg_req && cfg_we && (cfg_addr[11:0] == REG_CFG_WRITE);
assign axu_cfg_addr  = cfg_wdata[0 +: CFG_ADDR_WIDTH];
assign axu_cfg_data  = cfg_wdata[8 +: ADDR_WIDTH];
assign cfg_rdata     = cfg_rdata_q;
assign irq_o         = irq_status_q & irq_mask_q;

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        op_a_acc_rd_port_sel_q <= 1'b0;
        op_a_acc_wr_port_sel_q <= 1'b0;
        op_b_acc_rd_port_sel_q <= 1'b0;
        op_b_acc_wr_port_sel_q <= 1'b0;
        out_acc_rd_port_sel_q  <= 1'b0;
        out_acc_wr_port_sel_q  <= 1'b0;
        done_sticky_q          <= 1'b0;
        irq_mask_q             <= 1'b0;
        irq_status_q           <= 1'b0;
        cfg_rdata_q            <= '0;
    end else begin
        if (start_pulse) begin
            done_sticky_q <= 1'b0;
            irq_status_q  <= 1'b0;
        end

        if (axu_done) begin
            done_sticky_q <= 1'b1;
            irq_status_q  <= 1'b1;
        end

        if (cfg_req && cfg_we) begin
            unique case (cfg_addr[11:0])
                REG_CTRL: begin
                    if (cfg_wdata[1]) begin
                        done_sticky_q <= 1'b0;
                        irq_status_q  <= 1'b0;
                    end
                end
                REG_OP_A_BUF_CTL: begin
                    op_a_acc_rd_port_sel_q <= cfg_wdata[0];
                    op_a_acc_wr_port_sel_q <= cfg_wdata[1];
                end
                REG_OP_B_BUF_CTL: begin
                    op_b_acc_rd_port_sel_q <= cfg_wdata[0];
                    op_b_acc_wr_port_sel_q <= cfg_wdata[1];
                end
                REG_OUT_BUF_CTL: begin
                    out_acc_rd_port_sel_q <= cfg_wdata[0];
                    out_acc_wr_port_sel_q <= cfg_wdata[1];
                end
                REG_IRQ_MASK: begin
                    irq_mask_q <= cfg_wdata[0];
                end
                REG_IRQ_STAT: begin
                    if (cfg_wdata[0]) begin
                        irq_status_q <= 1'b0;
                    end
                end
                default: ;
            endcase
        end

        if (cfg_req && !cfg_we) begin
            unique case (cfg_addr[11:0])
                REG_STATUS: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-3){1'b0}}, axu_calc_done, done_sticky_q, axu_busy};
                end
                REG_OP_A_BUF_CTL: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-2){1'b0}}, op_a_acc_wr_port_sel_q, op_a_acc_rd_port_sel_q};
                end
                REG_OP_B_BUF_CTL: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-2){1'b0}}, op_b_acc_wr_port_sel_q, op_b_acc_rd_port_sel_q};
                end
                REG_OUT_BUF_CTL: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-2){1'b0}}, out_acc_wr_port_sel_q, out_acc_rd_port_sel_q};
                end
                REG_IRQ_MASK: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-1){1'b0}}, irq_mask_q};
                end
                REG_IRQ_STAT: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-1){1'b0}}, irq_status_q};
                end
                default: begin
                    cfg_rdata_q <= '0;
                end
            endcase
        end
    end
end

axu_top #(
    .NUM_LANE        (NUM_LANE),
    .ELEM_WIDTH      (ELEM_WIDTH),
    .ES              (ES),
    .BANK_WIDTH      (BANK_WIDTH),
    .BANK_NUM        (BANK_NUM),
    .ADDR_WIDTH      (ADDR_WIDTH),
    .CFG_ADDR_WIDTH  (CFG_ADDR_WIDTH),
    .ALIGN_WIDTH     (ALIGN_WIDTH),
    .ACC_ALIGN_WIDTH (ACC_ALIGN_WIDTH),
    .SFU_LANE        (SFU_LANE),
    .SFU_RAND_N      (SFU_RAND_N),
    .SFU_ALIGN_WIDTH (SFU_ALIGN_WIDTH),
    .SFU_NUM_ITER    (SFU_NUM_ITER),
    .NLI_NUM_LANES   (NLI_NUM_LANES),
    .NLI_NUM_MACROS  (NLI_NUM_MACROS),
    .NLI_NUM_MICROS  (NLI_NUM_MICROS),
    // .OP_A_INIT_FILE  (""),
    // .OP_B_INIT_FILE  (""),
    // .OUT_INIT_FILE   (""),
    // .OP_A_DUMP_FILE  (""),
    // .OP_B_DUMP_FILE  (""),
    // .OUT_DUMP_FILE   (""),
    .BUF_AXI_ADDR_WIDTH (AXI_ADDR_WIDTH),
    .BUF_AXI_DATA_WIDTH (AXI_DATA_WIDTH)
) u_axu_top (
    .clk_i                 (clk_i),
    .rstn_i                (rst_ni),
    .cfg_set_i             (cfg_set_pulse),
    .cfg_addr_i            (axu_cfg_addr),
    .cfg_data_i            (axu_cfg_data),
    .start_i               (start_pulse),
    .dump_i                (1'b0),
    .calc_done_o           (axu_calc_done),
    .busy_o                (axu_busy),
    .done_o                (axu_done),
    .op_a_acc_rd_port_sel_i (op_a_acc_rd_port_sel_q),
    .op_a_acc_wr_port_sel_i (op_a_acc_wr_port_sel_q),
    .op_a_axi_req_i         (op_a_buf_req),
    .op_a_axi_write_en_i    (op_a_buf_we),
    .op_a_axi_addr_i        (op_a_buf_addr),
    .op_a_axi_byte_en_i     (op_a_buf_be),
    .op_a_axi_wdata_i       (op_a_buf_wdata),
    .op_a_axi_rdata_o       (op_a_buf_rdata),
    .op_b_acc_rd_port_sel_i (op_b_acc_rd_port_sel_q),
    .op_b_acc_wr_port_sel_i (op_b_acc_wr_port_sel_q),
    .op_b_axi_req_i         (op_b_buf_req),
    .op_b_axi_write_en_i    (op_b_buf_we),
    .op_b_axi_addr_i        (op_b_buf_addr),
    .op_b_axi_byte_en_i     (op_b_buf_be),
    .op_b_axi_wdata_i       (op_b_buf_wdata),
    .op_b_axi_rdata_o       (op_b_buf_rdata),
    .out_acc_rd_port_sel_i  (out_acc_rd_port_sel_q),
    .out_acc_wr_port_sel_i  (out_acc_wr_port_sel_q),
    .out_axi_req_i          (out_buf_req),
    .out_axi_write_en_i     (out_buf_we),
    .out_axi_addr_i         (out_buf_addr),
    .out_axi_byte_en_i      (out_buf_be),
    .out_axi_wdata_i        (out_buf_wdata),
    .out_axi_rdata_o        (out_buf_rdata)
);

endmodule
