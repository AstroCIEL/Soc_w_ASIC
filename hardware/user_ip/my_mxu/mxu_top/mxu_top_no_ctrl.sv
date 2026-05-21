module mxu_top_no_ctrl #(
    parameter LANE_NUM       =  4,
    parameter BANK_WIDTH     = 128,

    parameter SEMI_TRANS_DATA_WIDTH   =  8,
    parameter SEMI_TRANS_BUFFER_WIDTH = 16,
    parameter SEMI_TRANS_BUFFER_DEPTH = 16,

    parameter SA_PE_NUM      = 16,
    parameter SA_LINE_NUM    = 16,
    parameter SA_N_I         = 16,
    parameter SA_ES_I        =  2,
    parameter SA_N_O         = 16,
    parameter SA_ES_O        =  2,
    parameter SA_ALIGN_WIDTH = 14
)(
    input  logic                  clk_i,
    input  logic                  rstn_i,

    input  logic                  in_valid_lower_i,
    input  logic                  in_valid_upper_i,
    input  logic [BANK_WIDTH-1:0] data_in_lower_i  [LANE_NUM-1:0],
    input  logic [BANK_WIDTH-1:0] data_in_upper_i  [LANE_NUM-1:0],
    input  logic [1:0]            front_rotator_sel_i,

    
    input  logic [$clog2(SEMI_TRANS_BUFFER_DEPTH)-1:0] semi_transposer_addr_in_i [LANE_NUM-1:0],
    input  logic                                       semi_transposer_start_putout_i,
    output logic [SEMI_TRANS_BUFFER_DEPTH-1:0]         semi_transposer_lower_wr_done_mask_o [LANE_NUM-1:0],
    output logic [SEMI_TRANS_BUFFER_DEPTH-1:0]         semi_transposer_upper_wr_done_mask_o [LANE_NUM-1:0],
    output logic                                       semi_transposer_lower_valid_o,
    output logic                                       semi_transposer_upper_valid_o,

    input  logic                  sa_top_data_flow_mode_i,//0=FF, 1=BP    
    input  logic                  sa_top_data_type_mode_i,//0=posit, 1=int
    // input  logic                  sa_top_wgt_update_en_i,
    // input  logic                  sa_top_calc_start_i,
    input  logic                  sa_top_act_or_wg_i,//0表示输入的是act，1表示输入的是wgt

    output logic                  sa_top_wgt_update_done_o [LANE_NUM-1:0],
    // output logic                  sa_top_calc_done_o [LANE_NUM-1:0],

    input  logic [1:0]            back_rotator_sel_i,
    output logic [BANK_WIDTH-1:0] data_out_lower_o [LANE_NUM-1:0],
    output logic [BANK_WIDTH-1:0] data_out_upper_o [LANE_NUM-1:0],
    output logic                  data_out_lower_valid_o,
    output logic                  data_out_upper_valid_o,

    output logic                  compute_done_o
);

// ---------------------------------------------------------------------------
// u_rotator_front_lower — 实例前缀信号（模块间互不直连）
// ---------------------------------------------------------------------------
logic        u_rotator_front_lower_clk;
logic        u_rotator_front_lower_rst_n;
logic        u_rotator_front_lower_in_valid;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_A;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_B;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_C;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_D;
logic [1:0]  u_rotator_front_lower_sel;
logic        u_rotator_front_lower_out_valid;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_out1;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_out2;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_out3;
logic [BANK_WIDTH-1:0] u_rotator_front_lower_out4;

assign u_rotator_front_lower_clk      = clk_i;
assign u_rotator_front_lower_rst_n    = rstn_i;
assign u_rotator_front_lower_in_valid = in_valid_lower_i;
assign u_rotator_front_lower_A        = data_in_lower_i[3];
assign u_rotator_front_lower_B        = data_in_lower_i[2];
assign u_rotator_front_lower_C        = data_in_lower_i[1];
assign u_rotator_front_lower_D        = data_in_lower_i[0];
assign u_rotator_front_lower_sel      = front_rotator_sel_i;

rotator #(
    .WIDTH (BANK_WIDTH)
) u_rotator_front_lower (
    .clk       (u_rotator_front_lower_clk),
    .rst_n     (u_rotator_front_lower_rst_n),
    .in_valid  (u_rotator_front_lower_in_valid),
    .A         (u_rotator_front_lower_A),
    .B         (u_rotator_front_lower_B),
    .C         (u_rotator_front_lower_C),
    .D         (u_rotator_front_lower_D),
    .sel       (u_rotator_front_lower_sel),
    .out_valid (u_rotator_front_lower_out_valid),
    .out1      (u_rotator_front_lower_out1),
    .out2      (u_rotator_front_lower_out2),
    .out3      (u_rotator_front_lower_out3),
    .out4      (u_rotator_front_lower_out4)
);

// ---------------------------------------------------------------------------
// u_rotator_front_upper
// ---------------------------------------------------------------------------
logic                  u_rotator_front_upper_clk;
logic                  u_rotator_front_upper_rst_n;
logic                  u_rotator_front_upper_in_valid;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_A;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_B;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_C;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_D;
logic            [1:0] u_rotator_front_upper_sel;
logic                  u_rotator_front_upper_out_valid;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_out1;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_out2;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_out3;
logic [BANK_WIDTH-1:0] u_rotator_front_upper_out4;

assign u_rotator_front_upper_clk      = clk_i;
assign u_rotator_front_upper_rst_n    = rstn_i;
assign u_rotator_front_upper_in_valid = in_valid_upper_i;
assign u_rotator_front_upper_A        = data_in_upper_i[3];
assign u_rotator_front_upper_B        = data_in_upper_i[2];
assign u_rotator_front_upper_C        = data_in_upper_i[1];
assign u_rotator_front_upper_D        = data_in_upper_i[0];
assign u_rotator_front_upper_sel      = front_rotator_sel_i;

rotator #(
    .WIDTH (BANK_WIDTH)
) u_rotator_front_upper (
    .clk       (u_rotator_front_upper_clk),
    .rst_n     (u_rotator_front_upper_rst_n),
    .in_valid  (u_rotator_front_upper_in_valid),
    .A         (u_rotator_front_upper_A),
    .B         (u_rotator_front_upper_B),
    .C         (u_rotator_front_upper_C),
    .D         (u_rotator_front_upper_D),
    .sel       (u_rotator_front_upper_sel),
    .out_valid (u_rotator_front_upper_out_valid),
    .out1      (u_rotator_front_upper_out1),
    .out2      (u_rotator_front_upper_out2),
    .out3      (u_rotator_front_upper_out3),
    .out4      (u_rotator_front_upper_out4)
);

// ---------------------------------------------------------------------------
// u_semi_transposer_lower / u_semi_transposer_upper（每 lane 一组前缀信号）
// ---------------------------------------------------------------------------
logic        u_semi_transposer_lower_clk_i            [LANE_NUM-1:0];
logic        u_semi_transposer_lower_rstn_i           [LANE_NUM-1:0];
logic        u_semi_transposer_lower_wr_en_i          [LANE_NUM-1:0];
logic [3:0]  u_semi_transposer_lower_addr_in_i        [LANE_NUM-1:0];
logic        u_semi_transposer_lower_start_putout_i   [LANE_NUM-1:0];
logic [SEMI_TRANS_DATA_WIDTH-1:0]
             u_semi_transposer_lower_data_in          [LANE_NUM-1:0][SEMI_TRANS_BUFFER_WIDTH-1:0];
logic [SEMI_TRANS_DATA_WIDTH-1:0]
             u_semi_transposer_lower_data_out         [LANE_NUM-1:0][SEMI_TRANS_BUFFER_WIDTH-1:0];
logic [LANE_NUM-1:0] u_semi_transposer_lower_valid_o;
logic [15:0] u_semi_transposer_lower_wr_done_mask_o   [LANE_NUM-1:0];

logic        u_semi_transposer_upper_clk_i           [LANE_NUM-1:0];
logic        u_semi_transposer_upper_rstn_i          [LANE_NUM-1:0];
logic        u_semi_transposer_upper_wr_en_i         [LANE_NUM-1:0];
logic [3:0]  u_semi_transposer_upper_addr_in_i       [LANE_NUM-1:0];
logic        u_semi_transposer_upper_start_putout_i  [LANE_NUM-1:0];
logic [SEMI_TRANS_DATA_WIDTH-1:0]
             u_semi_transposer_upper_data_in         [LANE_NUM-1:0][SEMI_TRANS_BUFFER_WIDTH-1:0];
logic [SEMI_TRANS_DATA_WIDTH-1:0]
             u_semi_transposer_upper_data_out        [LANE_NUM-1:0][SEMI_TRANS_BUFFER_WIDTH-1:0];
logic [LANE_NUM-1:0] u_semi_transposer_upper_valid_o;
logic [15:0] u_semi_transposer_upper_wr_done_mask_o  [LANE_NUM-1:0];

// 与原先 rotator→lane 对应一致：out1→lane3 … out4→lane0；每 lane 128bit 按小端字节序拆成 16×8 送入 semi_transposer
logic [BANK_WIDTH-1:0] u_front_lower_lane_word [LANE_NUM-1:0];
logic [BANK_WIDTH-1:0] u_front_upper_lane_word [LANE_NUM-1:0];

assign u_front_lower_lane_word[3] = u_rotator_front_lower_out1;
assign u_front_lower_lane_word[2] = u_rotator_front_lower_out2;
assign u_front_lower_lane_word[1] = u_rotator_front_lower_out3;
assign u_front_lower_lane_word[0] = u_rotator_front_lower_out4;

assign u_front_upper_lane_word[3] = u_rotator_front_upper_out1;
assign u_front_upper_lane_word[2] = u_rotator_front_upper_out2;
assign u_front_upper_lane_word[1] = u_rotator_front_upper_out3;
assign u_front_upper_lane_word[0] = u_rotator_front_upper_out4;

generate
    for (genvar lane = 0; lane < LANE_NUM; lane++) begin : map_front_to_semi_in
        for (genvar b = 0; b < SEMI_TRANS_BUFFER_WIDTH; b++) begin : map_word_to_bytes
            assign u_semi_transposer_lower_data_in[lane][b] =
                u_front_lower_lane_word[lane][b * SEMI_TRANS_DATA_WIDTH +: SEMI_TRANS_DATA_WIDTH];
            assign u_semi_transposer_upper_data_in[lane][b] =
                u_front_upper_lane_word[lane][b * SEMI_TRANS_DATA_WIDTH +: SEMI_TRANS_DATA_WIDTH];
        end
    end
endgenerate

generate
    for (genvar i = 0; i < LANE_NUM; i = i + 1) begin : semi_transposer_lane_gen
        assign u_semi_transposer_lower_clk_i[i]   = clk_i;
        assign u_semi_transposer_lower_rstn_i[i]  = rstn_i;
        assign u_semi_transposer_lower_start_putout_i[i] = (sa_top_act_or_wg_i==0)?  0:semi_transposer_start_putout_i;
        assign u_semi_transposer_lower_wr_en_i[i] = (sa_top_act_or_wg_i==0)?  0: u_rotator_front_lower_out_valid;
        assign u_semi_transposer_lower_addr_in_i[i] = (sa_top_act_or_wg_i==0)?  0:semi_transposer_addr_in_i[i];

        semi_transposer #(
            .DATA_WIDTH   (SEMI_TRANS_DATA_WIDTH),
            .BUFFER_WIDTH (SEMI_TRANS_BUFFER_WIDTH),
            .BUFFER_DEPTH (SEMI_TRANS_BUFFER_DEPTH)
        ) u_semi_transposer_lower (
            .clk_i           (u_semi_transposer_lower_clk_i[i]),
            .rstn_i          (u_semi_transposer_lower_rstn_i[i]),
            .wr_en_i         (u_semi_transposer_lower_wr_en_i[i]),
            .addr_in_i       (u_semi_transposer_lower_addr_in_i[i]),
            .start_putout_i  (u_semi_transposer_lower_start_putout_i[i]),
            .data_in         (u_semi_transposer_lower_data_in[i]),
            .data_out        (u_semi_transposer_lower_data_out[i]),
            .valid_o         (u_semi_transposer_lower_valid_o[i]),
            .wr_done_mask_o  (u_semi_transposer_lower_wr_done_mask_o[i])
        );

        assign u_semi_transposer_upper_clk_i[i]  = clk_i;
        assign u_semi_transposer_upper_rstn_i[i] = rstn_i;
        assign u_semi_transposer_upper_start_putout_i[i] = (sa_top_act_or_wg_i==0)?  0:semi_transposer_start_putout_i;
        assign u_semi_transposer_upper_wr_en_i[i] = (sa_top_act_or_wg_i==0)?  0:u_rotator_front_upper_out_valid;
        assign u_semi_transposer_upper_addr_in_i[i] = (sa_top_act_or_wg_i==0)?  0:semi_transposer_addr_in_i[i];
        semi_transposer #(
            .DATA_WIDTH   (SEMI_TRANS_DATA_WIDTH),
            .BUFFER_WIDTH (SEMI_TRANS_BUFFER_WIDTH),
            .BUFFER_DEPTH (SEMI_TRANS_BUFFER_DEPTH)
        ) u_semi_transposer_upper (
            .clk_i           (u_semi_transposer_upper_clk_i[i]),
            .rstn_i          (u_semi_transposer_upper_rstn_i[i]),
            .wr_en_i         (u_semi_transposer_upper_wr_en_i[i]),
            .addr_in_i       (u_semi_transposer_upper_addr_in_i[i]),
            .start_putout_i  (u_semi_transposer_upper_start_putout_i[i]),
            .data_in         (u_semi_transposer_upper_data_in[i]),
            .data_out        (u_semi_transposer_upper_data_out[i]),
            .valid_o         (u_semi_transposer_upper_valid_o[i]),
            .wr_done_mask_o  (u_semi_transposer_upper_wr_done_mask_o[i])
        );

        assign semi_transposer_lower_wr_done_mask_o[i] = u_semi_transposer_lower_wr_done_mask_o[i];
        assign semi_transposer_upper_wr_done_mask_o[i] = u_semi_transposer_upper_wr_done_mask_o[i];
    end
endgenerate

assign semi_transposer_lower_valid_o = |u_semi_transposer_lower_valid_o;
assign semi_transposer_upper_valid_o = |u_semi_transposer_upper_valid_o;

// ---------------------------------------------------------------------------
// u_sa_top（每 lane）
// ---------------------------------------------------------------------------
logic       [LANE_NUM-1:0]  u_sa_top_clk_i              ;
logic       [LANE_NUM-1:0]  u_sa_top_rstn_i             ;
logic       [LANE_NUM-1:0]  u_sa_top_data_flow_mode_i   ;
logic       [LANE_NUM-1:0]  u_sa_top_data_type_mode_i   ;
logic       [LANE_NUM-1:0]  u_sa_top_wgt_update_en_i    ;
logic       [LANE_NUM-1:0]  u_sa_top_wgt_update_en_o    ;
logic       [LANE_NUM-1:0]  u_sa_top_calc_start_i       ;
logic       [LANE_NUM-1:0]  u_sa_top_calc_done_o        ;
logic       [LANE_NUM-1:0]  u_sa_top_act_or_wg_i        ;
logic [SA_N_I-1:0] u_sa_top_data_i       [LANE_NUM-1:0][SA_PE_NUM-1:0];
logic [SA_N_O-1:0] u_sa_top_operand_acc_o [LANE_NUM-1:0][SA_PE_NUM-1:0];

always_comb begin
    if (sa_top_act_or_wg_i == 1'b1) begin //输入的是wgt
        for (int lane = 0; lane < LANE_NUM; lane = lane + 1) begin
            for (int pe = 0; pe < SA_PE_NUM; pe = pe + 1) begin
                if (sa_top_data_type_mode_i) begin//输入的是int
                    // u_sa_top_data_i[lane][pe] = {{(SA_N_I-8){1'b0}}, u_semi_transposer_lower_data_out[lane][pe]};
                    u_sa_top_data_i[lane][pe] = signed'(u_semi_transposer_lower_data_out[lane][pe]);
                end else begin//输入的是posit
                    u_sa_top_data_i[lane][pe] = {u_semi_transposer_upper_data_out[lane][pe], u_semi_transposer_lower_data_out[lane][pe]};
                end
            end
        end
    end else begin //输入的是act
        for (int pe = 0; pe < SA_PE_NUM; pe = pe + 1) begin
            if (sa_top_data_type_mode_i) begin //输入的是int
                // u_sa_top_data_i[0][pe] = {{(SA_N_I-8){1'b0}}, u_rotator_front_lower_out4[pe*8+:8]};
                // u_sa_top_data_i[1][pe] = {{(SA_N_I-8){1'b0}}, u_rotator_front_lower_out3[pe*8+:8]};
                // u_sa_top_data_i[2][pe] = {{(SA_N_I-8){1'b0}}, u_rotator_front_lower_out2[pe*8+:8]};
                // u_sa_top_data_i[3][pe] = {{(SA_N_I-8){1'b0}}, u_rotator_front_lower_out1[pe*8+:8]};
                u_sa_top_data_i[0][pe] = signed'(u_rotator_front_lower_out4[pe*8+:8]);
                u_sa_top_data_i[1][pe] = signed'(u_rotator_front_lower_out3[pe*8+:8]);
                u_sa_top_data_i[2][pe] = signed'(u_rotator_front_lower_out2[pe*8+:8]);
                u_sa_top_data_i[3][pe] = signed'(u_rotator_front_lower_out1[pe*8+:8]);    

            end else begin //输入的是posit
                u_sa_top_data_i[0][pe] = {u_rotator_front_upper_out4[pe*8+:8], u_rotator_front_lower_out4[pe*8+:8]};
                u_sa_top_data_i[1][pe] = {u_rotator_front_upper_out3[pe*8+:8], u_rotator_front_lower_out3[pe*8+:8]};
                u_sa_top_data_i[2][pe] = {u_rotator_front_upper_out2[pe*8+:8], u_rotator_front_lower_out2[pe*8+:8]};
                u_sa_top_data_i[3][pe] = {u_rotator_front_upper_out1[pe*8+:8], u_rotator_front_lower_out1[pe*8+:8]};
            end
        end
    end
end


generate
    for (genvar i = 0; i < LANE_NUM; i = i + 1) begin : sa_lane_gen
        assign u_sa_top_clk_i[i]  = clk_i;
        assign u_sa_top_rstn_i[i] = rstn_i;

        assign u_sa_top_data_flow_mode_i[i] = sa_top_data_flow_mode_i;
        assign u_sa_top_data_type_mode_i[i] = sa_top_data_type_mode_i;
        assign u_sa_top_wgt_update_en_i[i] = (sa_top_act_or_wg_i==1)? semi_transposer_lower_valid_o : 0;
        //输入的是wgt，则从transposer的出口接受数据+数据有效信号
        assign u_sa_top_calc_start_i[i] = (sa_top_act_or_wg_i==0)? u_rotator_front_lower_out_valid:0;
        //输入的是act，则从rotator的出口接受数据+数据有效信号
        assign u_sa_top_act_or_wg_i[i] = sa_top_act_or_wg_i;
        SA_top #(
            .LINE_NUM    (SA_LINE_NUM),
            .PE_NUM      (SA_PE_NUM),
            .n_i         (SA_N_I),
            .es_i        (SA_ES_I),
            .n_o         (SA_N_O),
            .es_o        (SA_ES_O),
            .ALIGN_WIDTH (SA_ALIGN_WIDTH)
        ) u_sa_top (
            .clk_i            (u_sa_top_clk_i[i]),
            .rstn_i           (u_sa_top_rstn_i[i]),
            .data_flow_mode_i (u_sa_top_data_flow_mode_i[i]),
            .data_type_mode_i (u_sa_top_data_type_mode_i[i]),
            .wgt_update_en_i  (u_sa_top_wgt_update_en_i[i]),
            .wgt_update_en_o  (u_sa_top_wgt_update_en_o[i]),
            .calc_start_i     (u_sa_top_calc_start_i[i]),
            .calc_done_o      (u_sa_top_calc_done_o[i]),
            .data_sel_i       (u_sa_top_act_or_wg_i[i]),
            .data_i           (u_sa_top_data_i[i]),
            .operand_acc_o    (u_sa_top_operand_acc_o[i])
        );
    end
endgenerate

generate
    for (genvar gi = 0; gi < LANE_NUM; gi = gi + 1) begin : sa_top_out_map
        assign sa_top_wgt_update_done_o[gi] = u_sa_top_wgt_update_en_o[gi];
        // assign sa_top_calc_done_o[gi]      = u_sa_top_calc_done_o[gi];
    end
endgenerate

logic sa_calc_done;
assign sa_calc_done = |u_sa_top_calc_done_o;
// ---------------------------------------------------------------------------
// u_rotator_back_lower / u_rotator_back_upper
// ---------------------------------------------------------------------------
logic        u_rotator_back_lower_clk;
logic        u_rotator_back_lower_rst_n;
logic        u_rotator_back_lower_in_valid;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_A;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_B;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_C;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_D;
logic [1:0]  u_rotator_back_lower_sel;
logic        u_rotator_back_lower_out_valid;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_out1;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_out2;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_out3;
logic [BANK_WIDTH-1:0] u_rotator_back_lower_out4;

assign u_rotator_back_lower_clk   = clk_i;
assign u_rotator_back_lower_rst_n = rstn_i;

rotator #(
    .WIDTH (BANK_WIDTH)
) u_rotator_back_lower (
    .clk       (u_rotator_back_lower_clk),
    .rst_n     (u_rotator_back_lower_rst_n),
    .in_valid  (u_rotator_back_lower_in_valid),
    .A         (u_rotator_back_lower_A),
    .B         (u_rotator_back_lower_B),
    .C         (u_rotator_back_lower_C),
    .D         (u_rotator_back_lower_D),
    .sel       (u_rotator_back_lower_sel),
    .out_valid (u_rotator_back_lower_out_valid),
    .out1      (u_rotator_back_lower_out1),
    .out2      (u_rotator_back_lower_out2),
    .out3      (u_rotator_back_lower_out3),
    .out4      (u_rotator_back_lower_out4)
);

logic        u_rotator_back_upper_clk;
logic        u_rotator_back_upper_rst_n;
logic        u_rotator_back_upper_in_valid;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_A;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_B;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_C;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_D;
logic [1:0]  u_rotator_back_upper_sel;
logic        u_rotator_back_upper_out_valid;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_out1;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_out2;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_out3;
logic [BANK_WIDTH-1:0] u_rotator_back_upper_out4;

assign u_rotator_back_upper_clk   = clk_i;
assign u_rotator_back_upper_rst_n = rstn_i;

rotator #(
    .WIDTH (BANK_WIDTH)
) u_rotator_back_upper (
    .clk       (u_rotator_back_upper_clk),
    .rst_n     (u_rotator_back_upper_rst_n),
    .in_valid  (u_rotator_back_upper_in_valid),
    .A         (u_rotator_back_upper_A),
    .B         (u_rotator_back_upper_B),
    .C         (u_rotator_back_upper_C),
    .D         (u_rotator_back_upper_D),
    .sel       (u_rotator_back_upper_sel),
    .out_valid (u_rotator_back_upper_out_valid),
    .out1      (u_rotator_back_upper_out1),
    .out2      (u_rotator_back_upper_out2),
    .out3      (u_rotator_back_upper_out3),
    .out4      (u_rotator_back_upper_out4)
);

assign u_rotator_back_upper_in_valid = sa_calc_done;
assign u_rotator_back_lower_in_valid = sa_calc_done;

logic [BANK_WIDTH-1:0] u_rotator_back_upper_data_i [LANE_NUM-1:0];
logic [BANK_WIDTH-1:0] u_rotator_back_lower_data_i [LANE_NUM-1:0];
generate
  for (genvar lane=0; lane<LANE_NUM; lane=lane+1) begin : lane_bit_extract
    // 提取每个PE的高8bit并拼接成128bit
    for (genvar pe=0; pe<SA_PE_NUM; pe=pe+1) begin : upper_bit_extract
      assign u_rotator_back_upper_data_i[lane][(pe+1)*8-1 -: 8] = u_sa_top_operand_acc_o[lane][pe][15:8];
    end
    
    // 提取每个PE的低8bit并拼接成128bit
    for (genvar pe=0; pe<SA_PE_NUM; pe=pe+1) begin : lower_bit_extract
      assign u_rotator_back_lower_data_i[lane][(pe+1)*8-1 -: 8] = u_sa_top_operand_acc_o[lane][pe][7:0];
    end
  end
endgenerate
assign u_rotator_back_upper_A = u_rotator_back_upper_data_i[3];
assign u_rotator_back_upper_B = u_rotator_back_upper_data_i[2];
assign u_rotator_back_upper_C = u_rotator_back_upper_data_i[1];
assign u_rotator_back_upper_D = u_rotator_back_upper_data_i[0];

assign u_rotator_back_lower_A = u_rotator_back_lower_data_i[3];
assign u_rotator_back_lower_B = u_rotator_back_lower_data_i[2];
assign u_rotator_back_lower_C = u_rotator_back_lower_data_i[1];
assign u_rotator_back_lower_D = u_rotator_back_lower_data_i[0];

assign u_rotator_back_lower_sel = back_rotator_sel_i;
assign u_rotator_back_upper_sel = back_rotator_sel_i;

// 顶层输出仍接到后端 rotator，便于边界完整（数据通路未与前级 semi/SA 相连）
assign data_out_lower_o[3] = u_rotator_back_lower_out1;
assign data_out_lower_o[2] = u_rotator_back_lower_out2;
assign data_out_lower_o[1] = u_rotator_back_lower_out3;
assign data_out_lower_o[0] = u_rotator_back_lower_out4;

assign data_out_upper_o[3] = u_rotator_back_upper_out1;
assign data_out_upper_o[2] = u_rotator_back_upper_out2;
assign data_out_upper_o[1] = u_rotator_back_upper_out3;
assign data_out_upper_o[0] = u_rotator_back_upper_out4;

assign data_out_lower_valid_o = u_rotator_back_lower_out_valid;
assign data_out_upper_valid_o = u_rotator_back_upper_out_valid;

logic data_out_lower_valid_o_ff;
always_ff @(posedge clk_i) begin
    if (!rstn_i) begin
        data_out_lower_valid_o_ff <= 0;
    end
    else begin
        data_out_lower_valid_o_ff <= data_out_lower_valid_o;
    end
end

assign compute_done_o = data_out_lower_valid_o_ff & data_out_lower_valid_o;

endmodule
