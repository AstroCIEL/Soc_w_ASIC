//这个版本的sram宽度是128，放了8个
//测了posit16,测了int
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

localparam int SEMI_TRANS_ADDR_W = $clog2(SEMI_TRANS_BUFFER_DEPTH);
localparam int ROW_DATA_WIDTH = 2 * BANK_WIDTH;
localparam int BUFFER_NUM_BANKS = LANE_NUM * 2;
localparam int BUFFER_ADDR_WIDTH = 8;
localparam int BUFFER_FLAT_DATA_WIDTH = BUFFER_NUM_BANKS * BANK_WIDTH;
localparam int BUFFER_FLAT_ADDR_WIDTH = BUFFER_NUM_BANKS * BUFFER_ADDR_WIDTH;

initial begin
    if (BANK_WIDTH != 128) begin
        $fatal(1, "mxu_top_v2: rf2p_256_128_wrapper requires BANK_WIDTH=128");
    end
    if (LANE_NUM != 4) begin
        $fatal(1, "mxu_top_v2: current wrapper mapping expects LANE_NUM=4");
    end
    if (ADDR_WIDTH != BUFFER_ADDR_WIDTH) begin
        $fatal(1, "mxu_top_v2: rf2p_256_128 has 256 rows, ADDR_WIDTH must be 8");
    end
end

logic [LANE_NUM-1:0]       wgt_buf_cen;
logic [LANE_NUM-1:0]       wgt_buf_wen;
logic [ADDR_WIDTH-1:0]     wgt_buf_addr [LANE_NUM-1:0];
logic [ROW_DATA_WIDTH-1:0] wgt_buf_dout [LANE_NUM-1:0];

logic [LANE_NUM-1:0]       act_buf_cen;
logic [LANE_NUM-1:0]       act_buf_wen;
logic [ADDR_WIDTH-1:0]     act_buf_addr [LANE_NUM-1:0];
logic [ROW_DATA_WIDTH-1:0] act_buf_dout [LANE_NUM-1:0];

logic [LANE_NUM-1:0]       out_buf_cen;
logic [LANE_NUM-1:0]       out_buf_wen;
logic [ADDR_WIDTH-1:0]     out_buf_addr [LANE_NUM-1:0];
logic [ROW_DATA_WIDTH-1:0] out_buf_din  [LANE_NUM-1:0];

logic [BUFFER_NUM_BANKS-1:0]       wgt_acc_rd_req;
logic [BUFFER_FLAT_ADDR_WIDTH-1:0] wgt_acc_rd_addr;
logic [BUFFER_FLAT_DATA_WIDTH-1:0] wgt_acc_rd_data;
logic [BUFFER_NUM_BANKS-1:0]       wgt_acc_wr_req;
logic [BUFFER_FLAT_ADDR_WIDTH-1:0] wgt_acc_wr_addr;
logic [BUFFER_FLAT_DATA_WIDTH-1:0] wgt_acc_wr_data;

logic [BUFFER_NUM_BANKS-1:0]       act_acc_rd_req;
logic [BUFFER_FLAT_ADDR_WIDTH-1:0] act_acc_rd_addr;
logic [BUFFER_FLAT_DATA_WIDTH-1:0] act_acc_rd_data;
logic [BUFFER_NUM_BANKS-1:0]       act_acc_wr_req;
logic [BUFFER_FLAT_ADDR_WIDTH-1:0] act_acc_wr_addr;
logic [BUFFER_FLAT_DATA_WIDTH-1:0] act_acc_wr_data;

logic [BUFFER_NUM_BANKS-1:0]       out_acc_rd_req;
logic [BUFFER_FLAT_ADDR_WIDTH-1:0] out_acc_rd_addr;
logic [BUFFER_FLAT_DATA_WIDTH-1:0] out_acc_rd_data_unused;
logic [BUFFER_NUM_BANKS-1:0]       out_acc_wr_req;
logic [BUFFER_FLAT_ADDR_WIDTH-1:0] out_acc_wr_addr;
logic [BUFFER_FLAT_DATA_WIDTH-1:0] out_acc_wr_data;

logic                  core_in_valid_lower;
logic                  core_in_valid_upper;
logic [BANK_WIDTH-1:0] core_data_in_lower [LANE_NUM-1:0];
logic [BANK_WIDTH-1:0] core_data_in_upper [LANE_NUM-1:0];
logic [1:0]            core_front_rotator_sel;
logic [SEMI_TRANS_ADDR_W-1:0]
                       core_semi_transposer_addr_in [LANE_NUM-1:0];
logic                  core_semi_transposer_start_putout;
logic [SEMI_TRANS_BUFFER_DEPTH-1:0]
                       core_semi_transposer_lower_wr_done_mask [LANE_NUM-1:0];
logic [SEMI_TRANS_BUFFER_DEPTH-1:0]
                       core_semi_transposer_upper_wr_done_mask [LANE_NUM-1:0];
logic                  core_semi_transposer_lower_valid;
logic                  core_semi_transposer_upper_valid;
logic                  core_sa_top_data_flow_mode;
logic                  core_sa_top_data_type_mode;
logic                  core_sa_top_act_or_wg;
logic                  core_sa_top_wgt_update_done [LANE_NUM-1:0];
logic [1:0]            core_back_rotator_sel;
logic [BANK_WIDTH-1:0] core_data_out_lower [LANE_NUM-1:0];
logic [BANK_WIDTH-1:0] core_data_out_upper [LANE_NUM-1:0];
logic                  core_data_out_lower_valid;
logic                  core_data_out_upper_valid;
logic                  core_compute_done;

generate
    for (genvar lane = 0; lane < LANE_NUM; lane++) begin : gen_buffer_map
        assign wgt_acc_rd_req[lane*2 + 0] = ~wgt_buf_cen[lane] && !wgt_buf_wen[lane];
        assign wgt_acc_rd_req[lane*2 + 1] = ~wgt_buf_cen[lane] && !wgt_buf_wen[lane];
        assign wgt_acc_rd_addr[(lane*2 + 0)*BUFFER_ADDR_WIDTH +: BUFFER_ADDR_WIDTH] = wgt_buf_addr[lane];
        assign wgt_acc_rd_addr[(lane*2 + 1)*BUFFER_ADDR_WIDTH +: BUFFER_ADDR_WIDTH] = wgt_buf_addr[lane];
        assign wgt_buf_dout[lane] = {
            wgt_acc_rd_data[(lane*2 + 0)*BANK_WIDTH +: BANK_WIDTH],
            wgt_acc_rd_data[(lane*2 + 1)*BANK_WIDTH +: BANK_WIDTH]
        };

        assign act_acc_rd_req[lane*2 + 0] = ~act_buf_cen[lane] && !act_buf_wen[lane];
        assign act_acc_rd_req[lane*2 + 1] = ~act_buf_cen[lane] && !act_buf_wen[lane];
        assign act_acc_rd_addr[(lane*2 + 0)*BUFFER_ADDR_WIDTH +: BUFFER_ADDR_WIDTH] = act_buf_addr[lane];
        assign act_acc_rd_addr[(lane*2 + 1)*BUFFER_ADDR_WIDTH +: BUFFER_ADDR_WIDTH] = act_buf_addr[lane];
        assign act_buf_dout[lane] = {
            act_acc_rd_data[(lane*2 + 0)*BANK_WIDTH +: BANK_WIDTH],
            act_acc_rd_data[(lane*2 + 1)*BANK_WIDTH +: BANK_WIDTH]
        };

        assign out_acc_wr_req[lane*2 + 0] = ~out_buf_cen[lane] && out_buf_wen[lane];
        assign out_acc_wr_req[lane*2 + 1] = ~out_buf_cen[lane] && out_buf_wen[lane];
        assign out_acc_wr_addr[(lane*2 + 0)*BUFFER_ADDR_WIDTH +: BUFFER_ADDR_WIDTH] = out_buf_addr[lane];
        assign out_acc_wr_addr[(lane*2 + 1)*BUFFER_ADDR_WIDTH +: BUFFER_ADDR_WIDTH] = out_buf_addr[lane];
        assign out_acc_wr_data[(lane*2 + 0)*BANK_WIDTH +: BANK_WIDTH] = out_buf_din[lane][BANK_WIDTH +: BANK_WIDTH];
        assign out_acc_wr_data[(lane*2 + 1)*BANK_WIDTH +: BANK_WIDTH] = out_buf_din[lane][0 +: BANK_WIDTH];
    end
endgenerate

assign wgt_acc_wr_req  = '0;
assign wgt_acc_wr_addr = '0;
assign wgt_acc_wr_data = '0;
assign act_acc_wr_req  = '0;
assign act_acc_wr_addr = '0;
assign act_acc_wr_data = '0;
assign out_acc_rd_req  = '0;
assign out_acc_rd_addr = '0;

rf2p_256_128_wrapper #(
    .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH  (AXI_DATA_WIDTH),
    .BANK_DATA_WIDTH (BANK_WIDTH),
    .NUM_BANKS       (BUFFER_NUM_BANKS),
    .BANK_ADDR_WIDTH (BUFFER_ADDR_WIDTH)
) u_wgt_buffer (
    .clk_i             (clk_i),
    .rstn_i            (rstn_i),
    .acc_rd_port_sel_i (wgt_acc_rd_port_sel_i),
    .acc_wr_port_sel_i (wgt_acc_wr_port_sel_i),
    .axi_req_i         (wgt_axi_req_i),
    .axi_write_en_i    (wgt_axi_write_en_i),
    .axi_addr_i        (wgt_axi_addr_i),
    .axi_byte_en_i     (wgt_axi_byte_en_i),
    .axi_wdata_i       (wgt_axi_wdata_i),
    .axi_rdata_o       (wgt_axi_rdata_o),
    .acc_rd_req_i      (wgt_acc_rd_req),
    .acc_rd_addr_i     (wgt_acc_rd_addr),
    .acc_rd_data_o     (wgt_acc_rd_data),
    .acc_wr_req_i      (wgt_acc_wr_req),
    .acc_wr_addr_i     (wgt_acc_wr_addr),
    .acc_wr_data_i     (wgt_acc_wr_data)
);

rf2p_256_128_wrapper #(
    .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH  (AXI_DATA_WIDTH),
    .BANK_DATA_WIDTH (BANK_WIDTH),
    .NUM_BANKS       (BUFFER_NUM_BANKS),
    .BANK_ADDR_WIDTH (BUFFER_ADDR_WIDTH)
) u_act_buffer (
    .clk_i             (clk_i),
    .rstn_i            (rstn_i),
    .acc_rd_port_sel_i (act_acc_rd_port_sel_i),
    .acc_wr_port_sel_i (act_acc_wr_port_sel_i),
    .axi_req_i         (act_axi_req_i),
    .axi_write_en_i    (act_axi_write_en_i),
    .axi_addr_i        (act_axi_addr_i),
    .axi_byte_en_i     (act_axi_byte_en_i),
    .axi_wdata_i       (act_axi_wdata_i),
    .axi_rdata_o       (act_axi_rdata_o),
    .acc_rd_req_i      (act_acc_rd_req),
    .acc_rd_addr_i     (act_acc_rd_addr),
    .acc_rd_data_o     (act_acc_rd_data),
    .acc_wr_req_i      (act_acc_wr_req),
    .acc_wr_addr_i     (act_acc_wr_addr),
    .acc_wr_data_i     (act_acc_wr_data)
);

rf2p_256_128_wrapper #(
    .AXI_ADDR_WIDTH  (AXI_ADDR_WIDTH),
    .AXI_DATA_WIDTH  (AXI_DATA_WIDTH),
    .BANK_DATA_WIDTH (BANK_WIDTH),
    .NUM_BANKS       (BUFFER_NUM_BANKS),
    .BANK_ADDR_WIDTH (BUFFER_ADDR_WIDTH)
) u_out_buffer (
    .clk_i             (clk_i),
    .rstn_i            (rstn_i),
    .acc_rd_port_sel_i (out_acc_rd_port_sel_i),
    .acc_wr_port_sel_i (out_acc_wr_port_sel_i),
    .axi_req_i         (out_axi_req_i),
    .axi_write_en_i    (out_axi_write_en_i),
    .axi_addr_i        (out_axi_addr_i),
    .axi_byte_en_i     (out_axi_byte_en_i),
    .axi_wdata_i       (out_axi_wdata_i),
    .axi_rdata_o       (out_axi_rdata_o),
    .acc_rd_req_i      (out_acc_rd_req),
    .acc_rd_addr_i     (out_acc_rd_addr),
    .acc_rd_data_o     (out_acc_rd_data_unused),
    .acc_wr_req_i      (out_acc_wr_req),
    .acc_wr_addr_i     (out_acc_wr_addr),
    .acc_wr_data_i     (out_acc_wr_data)
);

mxu_ctrl #(
    .LANE_NUM                (LANE_NUM),
    .BANK_WIDTH              (BANK_WIDTH),
    .SEMI_TRANS_BUFFER_DEPTH (SEMI_TRANS_BUFFER_DEPTH),
    .ADDR_WIDTH              (ADDR_WIDTH),
    .CFG_ADDR_WIDTH          (CFG_ADDR_WIDTH),
    .ROW_DATA_WIDTH          (ROW_DATA_WIDTH)
) u_mxu_ctrl (
    .clk_i                         (clk_i),
    .rstn_i                        (rstn_i),
    .cfg_set_i                     (cfg_set_i),
    .cfg_addr_i                    (cfg_addr_i),
    .cfg_data_i                    (cfg_data_i),
    .start_i                       (start_i),
    .busy_o                        (busy_o),
    .done_o                        (done_o),
    .wgt_buf_cen_o                 (wgt_buf_cen),
    .wgt_buf_wen_o                 (wgt_buf_wen),
    .wgt_buf_addr_o                (wgt_buf_addr),
    .wgt_buf_dout_i                (wgt_buf_dout),
    .act_buf_cen_o                 (act_buf_cen),
    .act_buf_wen_o                 (act_buf_wen),
    .act_buf_addr_o                (act_buf_addr),
    .act_buf_dout_i                (act_buf_dout),
    .out_buf_cen_o                 (out_buf_cen),
    .out_buf_wen_o                 (out_buf_wen),
    .out_buf_addr_o                (out_buf_addr),
    .out_buf_din_o                 (out_buf_din),
    .in_valid_lower_o              (core_in_valid_lower),
    .in_valid_upper_o              (core_in_valid_upper),
    .data_in_lower_o               (core_data_in_lower),
    .data_in_upper_o               (core_data_in_upper),
    .front_rotator_sel_o           (core_front_rotator_sel),
    .semi_transposer_addr_in_o     (core_semi_transposer_addr_in),
    .semi_transposer_start_putout_o(core_semi_transposer_start_putout),
    .sa_top_data_flow_mode_o       (core_sa_top_data_flow_mode),
    .sa_top_data_type_mode_o       (core_sa_top_data_type_mode),
    .sa_top_act_or_wg_o            (core_sa_top_act_or_wg),
    .back_rotator_sel_o            (core_back_rotator_sel),
    .sa_top_wgt_update_done_i      (core_sa_top_wgt_update_done),
    .data_out_lower_i              (core_data_out_lower),
    .data_out_upper_i              (core_data_out_upper),
    .data_out_lower_valid_i        (core_data_out_lower_valid),
    .data_out_upper_valid_i        (core_data_out_upper_valid),
    .compute_done_i                (core_compute_done)
);

mxu_top_no_ctrl #(
    .LANE_NUM                (LANE_NUM),
    .BANK_WIDTH              (BANK_WIDTH),
    .SEMI_TRANS_DATA_WIDTH   (SEMI_TRANS_DATA_WIDTH),
    .SEMI_TRANS_BUFFER_WIDTH (SEMI_TRANS_BUFFER_WIDTH),
    .SEMI_TRANS_BUFFER_DEPTH (SEMI_TRANS_BUFFER_DEPTH),
    .SA_PE_NUM               (SA_PE_NUM),
    .SA_LINE_NUM             (SA_LINE_NUM),
    .SA_N_I                  (SA_N_I),
    .SA_ES_I                 (SA_ES_I),
    .SA_N_O                  (SA_N_O),
    .SA_ES_O                 (SA_ES_O),
    .SA_ALIGN_WIDTH          (SA_ALIGN_WIDTH)
) u_mxu_top_no_ctrl (
    .clk_i                                  (clk_i),
    .rstn_i                                 (rstn_i),
    .in_valid_lower_i                       (core_in_valid_lower),
    .in_valid_upper_i                       (core_in_valid_upper),
    .data_in_lower_i                        (core_data_in_lower),
    .data_in_upper_i                        (core_data_in_upper),
    .front_rotator_sel_i                    (core_front_rotator_sel),
    .semi_transposer_addr_in_i              (core_semi_transposer_addr_in),
    .semi_transposer_start_putout_i         (core_semi_transposer_start_putout),
    .semi_transposer_lower_wr_done_mask_o   (core_semi_transposer_lower_wr_done_mask),
    .semi_transposer_upper_wr_done_mask_o   (core_semi_transposer_upper_wr_done_mask),
    .semi_transposer_lower_valid_o          (core_semi_transposer_lower_valid),
    .semi_transposer_upper_valid_o          (core_semi_transposer_upper_valid),
    .sa_top_data_flow_mode_i                (core_sa_top_data_flow_mode),//0=FF, 1=BP
    .sa_top_data_type_mode_i                (core_sa_top_data_type_mode),//0=posit, 1=int
    .sa_top_act_or_wg_i                     (core_sa_top_act_or_wg),
    .sa_top_wgt_update_done_o               (core_sa_top_wgt_update_done),
    .back_rotator_sel_i                     (core_back_rotator_sel),
    .data_out_lower_o                       (core_data_out_lower),
    .data_out_upper_o                       (core_data_out_upper),
    .data_out_lower_valid_o                 (core_data_out_lower_valid),
    .data_out_upper_valid_o                 (core_data_out_upper_valid),
    .compute_done_o                         (core_compute_done)
);

endmodule
