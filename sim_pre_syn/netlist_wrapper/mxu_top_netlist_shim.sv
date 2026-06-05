module mxu_top #(
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
    input  logic                      clk_i,
    input  logic                      rstn_i,

    input  logic                      cfg_set_i,
    input  logic [CFG_ADDR_WIDTH-1:0] cfg_addr_i,
    input  logic [ADDR_WIDTH-1:0]     cfg_data_i,
    input  logic                      start_i,

    input  logic                      wgt_acc_rd_port_sel_i,
    input  logic                      wgt_acc_wr_port_sel_i,
    input  logic                      wgt_axi_req_i,
    input  logic                      wgt_axi_write_en_i,
    input  logic [AXI_ADDR_WIDTH-1:0] wgt_axi_addr_i,
    input  logic [AXI_DATA_WIDTH/8-1:0]
                                      wgt_axi_byte_en_i,
    input  logic [AXI_DATA_WIDTH-1:0] wgt_axi_wdata_i,
    output logic [AXI_DATA_WIDTH-1:0] wgt_axi_rdata_o,

    input  logic                      act_acc_rd_port_sel_i,
    input  logic                      act_acc_wr_port_sel_i,
    input  logic                      act_axi_req_i,
    input  logic                      act_axi_write_en_i,
    input  logic [AXI_ADDR_WIDTH-1:0] act_axi_addr_i,
    input  logic [AXI_DATA_WIDTH/8-1:0]
                                      act_axi_byte_en_i,
    input  logic [AXI_DATA_WIDTH-1:0] act_axi_wdata_i,
    output logic [AXI_DATA_WIDTH-1:0] act_axi_rdata_o,

    input  logic                      out_acc_rd_port_sel_i,
    input  logic                      out_acc_wr_port_sel_i,
    input  logic                      out_axi_req_i,
    input  logic                      out_axi_write_en_i,
    input  logic [AXI_ADDR_WIDTH-1:0] out_axi_addr_i,
    input  logic [AXI_DATA_WIDTH/8-1:0]
                                      out_axi_byte_en_i,
    input  logic [AXI_DATA_WIDTH-1:0] out_axi_wdata_i,
    output logic [AXI_DATA_WIDTH-1:0] out_axi_rdata_o,

    output logic                      busy_o,
    output logic                      done_o
);

    mxu_top_gate u_mxu_top_gate (
        .clk_i                 (clk_i),
        .rstn_i                (rstn_i),
        .cfg_set_i             (cfg_set_i),
        .cfg_addr_i            (cfg_addr_i),
        .cfg_data_i            (cfg_data_i),
        .start_i               (start_i),
        .wgt_acc_rd_port_sel_i (wgt_acc_rd_port_sel_i),
        .wgt_acc_wr_port_sel_i (wgt_acc_wr_port_sel_i),
        .wgt_axi_req_i         (wgt_axi_req_i),
        .wgt_axi_write_en_i    (wgt_axi_write_en_i),
        .wgt_axi_addr_i        (wgt_axi_addr_i),
        .wgt_axi_byte_en_i     (wgt_axi_byte_en_i),
        .wgt_axi_wdata_i       (wgt_axi_wdata_i),
        .wgt_axi_rdata_o       (wgt_axi_rdata_o),
        .act_acc_rd_port_sel_i (act_acc_rd_port_sel_i),
        .act_acc_wr_port_sel_i (act_acc_wr_port_sel_i),
        .act_axi_req_i         (act_axi_req_i),
        .act_axi_write_en_i    (act_axi_write_en_i),
        .act_axi_addr_i        (act_axi_addr_i),
        .act_axi_byte_en_i     (act_axi_byte_en_i),
        .act_axi_wdata_i       (act_axi_wdata_i),
        .act_axi_rdata_o       (act_axi_rdata_o),
        .out_acc_rd_port_sel_i (out_acc_rd_port_sel_i),
        .out_acc_wr_port_sel_i (out_acc_wr_port_sel_i),
        .out_axi_req_i         (out_axi_req_i),
        .out_axi_write_en_i    (out_axi_write_en_i),
        .out_axi_addr_i        (out_axi_addr_i),
        .out_axi_byte_en_i     (out_axi_byte_en_i),
        .out_axi_wdata_i       (out_axi_wdata_i),
        .out_axi_rdata_o       (out_axi_rdata_o),
        .busy_o                (busy_o),
        .done_o                (done_o)
    );

endmodule
