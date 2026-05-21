import posit_types_pkg::*;

module SA_top #(
    parameter int unsigned LINE_NUM = 16,
    parameter int unsigned PE_NUM = 16,
    parameter int unsigned n_i = 16,
    parameter int unsigned es_i = 2,
    parameter int unsigned n_o = 16,
    parameter int unsigned es_o = 2,
    parameter int unsigned ALIGN_WIDTH = 14
)(
    input  logic clk_i,
    input  logic rstn_i,

    input logic data_flow_mode_i,
    input logic data_type_mode_i,

    input  logic wgt_update_en_i,
    output logic wgt_update_en_o,

    input  logic calc_start_i,
    output logic calc_done_o,

    input  logic             data_sel_i,
    input  logic [n_i-1:0]  data_i[PE_NUM-1:0],

    output logic [n_o-1:0] operand_acc_o[PE_NUM-1:0]
);

// Width helpers for int bypass
localparam int unsigned MANT_WIDTH_I = get_mant_width_i(n_i, es_i); // posit_in_t.mant = [MANT_WIDTH_I:0]
localparam int unsigned MANT_WIDTH_O = get_mant_width_o(n_o, es_o); // posit_acc_t.mant = [MANT_WIDTH_O+2:0]

posit_in_t   act_i [PE_NUM-1:0];
posit_in_t   wgt_i [PE_NUM-1:0];
posit_in_t   act_o [PE_NUM-1:0];
posit_in_t   wgt_o [PE_NUM-1:0];

posit_acc_t  acc_i [PE_NUM-1:0];
posit_acc_t  acc_o [PE_NUM-1:0];

logic [ACC_EXP_W-2:0] acc_dec_rg_exp[PE_NUM-1:0];

// Intermediate wires: posit decoder outputs and encoder output
posit_in_t      data_dec [PE_NUM-1:0];  // 单组解码输出，组合同时送往 wgt_i 和 act_i
logic [n_o-1:0] acc_enc  [PE_NUM-1:0];

generate
    for(genvar i=0;i<PE_NUM;i=i+1) begin:decoder_gen

        posit_decoder #(
            .n(n_i),
            .es(es_i)
        ) u_data_decoder(
            .operand_i  (data_i[i]),
            .sign_o     (data_dec[i].sign),
            .rg_exp_o   (data_dec[i].rg_exp),
            .mant_norm_o(data_dec[i].mant)
        );

        posit_encoder #(
            .n(n_o),
            .es(es_o),
            .EXP_WIDTH(ACC_EXP_W-1),
            .MANT_WIDTH(ACC_MANT_W-1)
        ) u_acc_encoder(
            .sign_i       (acc_o[i].sign),
            .rg_exp_i     (acc_o[i].rg_exp),
            .mant_norm_i  (acc_o[i].mant),
            .result_o     (acc_enc[i])
        );

        // --- 输入旁路：int 模式直接将 data_i 低位映射到 mant，跳过 decoder ---
        // act_i 和 wgt_i 均来自同一组合解码输出
        // SA 内部由 wgt_update_en_i / calc_start_i 决定实际采样哪一路
        assign act_i[i].sign   = data_type_mode_i ? '0                        : data_dec[i].sign;
        assign act_i[i].rg_exp = data_type_mode_i ? '0                        : data_dec[i].rg_exp;
        assign act_i[i].mant   = data_type_mode_i ? data_i[i][MANT_WIDTH_I:0] : data_dec[i].mant;

        assign wgt_i[i].sign   = data_type_mode_i ? '0                        : data_dec[i].sign;
        assign wgt_i[i].rg_exp = data_type_mode_i ? '0                        : data_dec[i].rg_exp;
        assign wgt_i[i].mant   = data_type_mode_i ? data_i[i][MANT_WIDTH_I:0] : data_dec[i].mant;

        // --- 输出旁路：int 模式将 acc mant 符号扩展输出，跳过 encoder ---
        assign operand_acc_o[i] = data_type_mode_i
            ? {{(n_o - MANT_WIDTH_O - 3){acc_o[i].mant[MANT_WIDTH_O+2]}}, acc_o[i].mant}
            : acc_enc[i];
    end
endgenerate



Systolic_Array #(
    .LINE_NUM    (LINE_NUM),
    .PE_NUM      (PE_NUM),
    .n_i         (n_i ),
    .es_i        (es_i ),
    .n_o         (n_o),
    .es_o        (es_o ),
    .ALIGN_WIDTH (ALIGN_WIDTH)
) u_SA(
    .clk_i          (clk_i),
    .rstn_i         (rstn_i),
    .data_flow_mode_i(data_flow_mode_i),
    .data_type_mode_i(data_type_mode_i),//0=posit, 1=int

    .wgt_update_en_i(wgt_update_en_i),
    .wgt_update_en_o(wgt_update_en_o),
    
    .calc_start_i   (calc_start_i),
    .calc_done_o    (calc_done_o),

    .act_i          (act_i),
    .wgt_i          (wgt_i),

    .acc_o          (acc_o)
);



endmodule
