module mxu_top_wrapper #(
    parameter int LANE_NUM                = 4,
    parameter int BANK_WIDTH              = 128,
    parameter int SEMI_TRANS_DATA_WIDTH   = 8,
    parameter int SEMI_TRANS_BUFFER_WIDTH = 16,
    parameter int SEMI_TRANS_BUFFER_DEPTH = 16,
    parameter int SA_PE_NUM               = 16,
    parameter int SA_LINE_NUM             = 16,
    parameter int SA_N_I                  = 16,
    parameter int SA_ES_I                 = 2,
    parameter int SA_N_O                  = 16,
    parameter int SA_ES_O                 = 2,
    parameter int SA_ALIGN_WIDTH          = 14,
    parameter int ADDR_WIDTH              = 8,
    parameter int CFG_ADDR_WIDTH          = 4,
    parameter int AXI_ADDR_WIDTH          = 64,
    parameter int AXI_DATA_WIDTH          = 64
)(
    input  logic       clk_i,
    input  logic       rst_ni,

    AXI_BUS.Slave      cfg,
    AXI_BUS.Slave      wgtbuf,
    AXI_BUS.Slave      actbuf,
    AXI_BUS.Slave      outbuf,

    output logic       irq_o
);

localparam logic [11:0] REG_CTRL        = 12'h000;
localparam logic [11:0] REG_STATUS      = 12'h008;
localparam logic [11:0] REG_WGT_BUF_CTL = 12'h010;
localparam logic [11:0] REG_ACT_BUF_CTL = 12'h018;
localparam logic [11:0] REG_OUT_BUF_CTL = 12'h020;
localparam logic [11:0] REG_CFG_WRITE   = 12'h030;
localparam logic [11:0] REG_IRQ_MASK    = 12'h038;
localparam logic [11:0] REG_IRQ_STAT    = 12'h040;
/*
建议 cfg 地址窗口大小：4 KiB。
建议寄存器 offset 如下，后续 software 必须完全一致：

0x000 CTRL
  bit 0：START，写 1 后 wrapper 给 mxu_top.start_i 一个单周期脉冲。
  bit 1：CLR_DONE，写 1 清除 done/irq sticky 状态。

0x008 STATUS
  bit 0：BUSY，对应 mxu_top.busy_o。
  bit 1：DONE，可用 mxu_top.done_o 或 wrapper 内 sticky done。

0x010 WGT_BUF_CTL
  bit 0：wgt_acc_rd_port_sel_i。1 表示 weight buffer 读端交给 MXU 内核。
  bit 1：wgt_acc_wr_port_sel_i。通常 CPU 写 weight 时为 0，MXU 计算时按设计需要设置。

0x018 ACT_BUF_CTL
  bit 0：act_acc_rd_port_sel_i。
  bit 1：act_acc_wr_port_sel_i。

0x020 OUT_BUF_CTL
  bit 0：out_acc_rd_port_sel_i。
  bit 1：out_acc_wr_port_sel_i。MXU 写 output 时应交给 MXU。

0x030 CFG_WRITE
  bit [3:0]：cfg_addr_i。
  bit [15:8]：cfg_data_i。
  CPU 每次写该寄存器时，wrapper 对 mxu_top.cfg_set_i 拉高一个周期。

0x038 IRQ_MASK
  bit 0：done irq enable。

0x040 IRQ_STAT
  bit 0：done irq sticky，写 1 清除。
*/

logic                                cfg_req;
logic                                cfg_we;
logic [AXI_ADDR_WIDTH-1:0]           cfg_addr;
logic [AXI_DATA_WIDTH-1:0]           cfg_wdata;
logic [AXI_DATA_WIDTH-1:0]           cfg_rdata;
logic [AXI_DATA_WIDTH-1:0]           cfg_rdata_q;

logic                                wgtbuf_req;
logic                                wgtbuf_we;
logic [AXI_ADDR_WIDTH-1:0]           wgtbuf_addr;
logic [AXI_DATA_WIDTH/8-1:0]         wgtbuf_be;
logic [AXI_DATA_WIDTH-1:0]           wgtbuf_wdata;
logic [AXI_DATA_WIDTH-1:0]           wgtbuf_rdata;

logic                                actbuf_req;
logic                                actbuf_we;
logic [AXI_ADDR_WIDTH-1:0]           actbuf_addr;
logic [AXI_DATA_WIDTH/8-1:0]         actbuf_be;
logic [AXI_DATA_WIDTH-1:0]           actbuf_wdata;
logic [AXI_DATA_WIDTH-1:0]           actbuf_rdata;

logic                                outbuf_req;
logic                                outbuf_we;
logic [AXI_ADDR_WIDTH-1:0]           outbuf_addr;
logic [AXI_DATA_WIDTH/8-1:0]         outbuf_be;
logic [AXI_DATA_WIDTH-1:0]           outbuf_wdata;
logic [AXI_DATA_WIDTH-1:0]           outbuf_rdata;

logic                                wgt_acc_rd_port_sel_q;
logic                                wgt_acc_wr_port_sel_q;
logic                                act_acc_rd_port_sel_q;
logic                                act_acc_wr_port_sel_q;
logic                                out_acc_rd_port_sel_q;
logic                                out_acc_wr_port_sel_q;
logic                                done_sticky_q;
logic                                irq_mask_q;
logic                                irq_status_q;

logic                                mxu_busy;
logic                                mxu_done;
logic                                start_pulse;
logic                                cfg_set_pulse;
logic [CFG_ADDR_WIDTH-1:0]           mxu_cfg_addr;
logic [ADDR_WIDTH-1:0]               mxu_cfg_data;

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
    .AXI_ID_WIDTH   ( $bits(wgtbuf.aw_id) ),
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    .AXI_USER_WIDTH ( 1 )
) i_wgtbuf_axi2mem (
    .clk_i  ( clk_i ),
    .rst_ni ( rst_ni ),
    .slave  ( wgtbuf ),
    .req_o  ( wgtbuf_req ),
    .we_o   ( wgtbuf_we ),
    .addr_o ( wgtbuf_addr ),
    .be_o   ( wgtbuf_be ),
    .user_o ( ),
    .data_o ( wgtbuf_wdata ),
    .user_i ( '0 ),
    .data_i ( wgtbuf_rdata )
);

axi2mem #(
    .AXI_ID_WIDTH   ( $bits(actbuf.aw_id) ),
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    .AXI_USER_WIDTH ( 1 )
) i_actbuf_axi2mem (
    .clk_i  ( clk_i ),
    .rst_ni ( rst_ni ),
    .slave  ( actbuf ),
    .req_o  ( actbuf_req ),
    .we_o   ( actbuf_we ),
    .addr_o ( actbuf_addr ),
    .be_o   ( actbuf_be ),
    .user_o ( ),
    .data_o ( actbuf_wdata ),
    .user_i ( '0 ),
    .data_i ( actbuf_rdata )
);

axi2mem #(
    .AXI_ID_WIDTH   ( $bits(outbuf.aw_id) ),
    .AXI_ADDR_WIDTH ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH ( AXI_DATA_WIDTH ),
    .AXI_USER_WIDTH ( 1 )
) i_outbuf_axi2mem (
    .clk_i  ( clk_i ),
    .rst_ni ( rst_ni ),
    .slave  ( outbuf ),
    .req_o  ( outbuf_req ),
    .we_o   ( outbuf_we ),
    .addr_o ( outbuf_addr ),
    .be_o   ( outbuf_be ),
    .user_o ( ),
    .data_o ( outbuf_wdata ),
    .user_i ( '0 ),
    .data_i ( outbuf_rdata )
);

assign start_pulse   = cfg_req && cfg_we && (cfg_addr[11:0] == REG_CTRL) && cfg_wdata[0];
assign cfg_set_pulse = cfg_req && cfg_we && (cfg_addr[11:0] == REG_CFG_WRITE);
assign mxu_cfg_addr  = cfg_wdata[0 +: CFG_ADDR_WIDTH];
assign mxu_cfg_data  = cfg_wdata[8 +: ADDR_WIDTH];
assign cfg_rdata     = cfg_rdata_q;
assign irq_o         = irq_status_q & irq_mask_q;

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        wgt_acc_rd_port_sel_q <= 1'b0;
        wgt_acc_wr_port_sel_q <= 1'b0;
        act_acc_rd_port_sel_q <= 1'b0;
        act_acc_wr_port_sel_q <= 1'b0;
        out_acc_rd_port_sel_q <= 1'b0;
        out_acc_wr_port_sel_q <= 1'b0;
        done_sticky_q         <= 1'b0;
        irq_mask_q            <= 1'b0;
        irq_status_q          <= 1'b0;
        cfg_rdata_q           <= '0;
    end else begin
        if (start_pulse) begin
            done_sticky_q <= 1'b0;
            irq_status_q  <= 1'b0;
        end

        if (mxu_done) begin
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
                REG_WGT_BUF_CTL: begin
                    wgt_acc_rd_port_sel_q <= cfg_wdata[0];
                    wgt_acc_wr_port_sel_q <= cfg_wdata[1];
                end
                REG_ACT_BUF_CTL: begin
                    act_acc_rd_port_sel_q <= cfg_wdata[0];
                    act_acc_wr_port_sel_q <= cfg_wdata[1];
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
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-2){1'b0}}, done_sticky_q, mxu_busy};
                end
                REG_WGT_BUF_CTL: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-2){1'b0}}, wgt_acc_wr_port_sel_q, wgt_acc_rd_port_sel_q};
                end
                REG_ACT_BUF_CTL: begin
                    cfg_rdata_q <= {{(AXI_DATA_WIDTH-2){1'b0}}, act_acc_wr_port_sel_q, act_acc_rd_port_sel_q};
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

mxu_top #(
    .LANE_NUM                ( LANE_NUM ),
    .BANK_WIDTH              ( BANK_WIDTH ),
    .SEMI_TRANS_DATA_WIDTH   ( SEMI_TRANS_DATA_WIDTH ),
    .SEMI_TRANS_BUFFER_WIDTH ( SEMI_TRANS_BUFFER_WIDTH ),
    .SEMI_TRANS_BUFFER_DEPTH ( SEMI_TRANS_BUFFER_DEPTH ),
    .SA_PE_NUM               ( SA_PE_NUM ),
    .SA_LINE_NUM             ( SA_LINE_NUM ),
    .SA_N_I                  ( SA_N_I ),
    .SA_ES_I                 ( SA_ES_I ),
    .SA_N_O                  ( SA_N_O ),
    .SA_ES_O                 ( SA_ES_O ),
    .SA_ALIGN_WIDTH          ( SA_ALIGN_WIDTH ),
    .ADDR_WIDTH              ( ADDR_WIDTH ),
    .CFG_ADDR_WIDTH          ( CFG_ADDR_WIDTH ),
    .AXI_ADDR_WIDTH          ( AXI_ADDR_WIDTH ),
    .AXI_DATA_WIDTH          ( AXI_DATA_WIDTH )
) i_mxu_top (
    .clk_i                 ( clk_i ),
    .rstn_i                ( rst_ni ),
    .cfg_set_i             ( cfg_set_pulse ),
    .cfg_addr_i            ( mxu_cfg_addr ),
    .cfg_data_i            ( mxu_cfg_data ),
    .start_i               ( start_pulse ),
    .wgt_acc_rd_port_sel_i ( wgt_acc_rd_port_sel_q ),
    .wgt_acc_wr_port_sel_i ( wgt_acc_wr_port_sel_q ),
    .wgt_axi_req_i         ( wgtbuf_req ),
    .wgt_axi_write_en_i    ( wgtbuf_we ),
    .wgt_axi_addr_i        ( wgtbuf_addr ),
    .wgt_axi_byte_en_i     ( wgtbuf_be ),
    .wgt_axi_wdata_i       ( wgtbuf_wdata ),
    .wgt_axi_rdata_o       ( wgtbuf_rdata ),
    .act_acc_rd_port_sel_i ( act_acc_rd_port_sel_q ),
    .act_acc_wr_port_sel_i ( act_acc_wr_port_sel_q ),
    .act_axi_req_i         ( actbuf_req ),
    .act_axi_write_en_i    ( actbuf_we ),
    .act_axi_addr_i        ( actbuf_addr ),
    .act_axi_byte_en_i     ( actbuf_be ),
    .act_axi_wdata_i       ( actbuf_wdata ),
    .act_axi_rdata_o       ( actbuf_rdata ),
    .out_acc_rd_port_sel_i ( out_acc_rd_port_sel_q ),
    .out_acc_wr_port_sel_i ( out_acc_wr_port_sel_q ),
    .out_axi_req_i         ( outbuf_req ),
    .out_axi_write_en_i    ( outbuf_we ),
    .out_axi_addr_i        ( outbuf_addr ),
    .out_axi_byte_en_i     ( outbuf_be ),
    .out_axi_wdata_i       ( outbuf_wdata ),
    .out_axi_rdata_o       ( outbuf_rdata ),
    .busy_o                ( mxu_busy ),
    .done_o                ( mxu_done )
);

endmodule
