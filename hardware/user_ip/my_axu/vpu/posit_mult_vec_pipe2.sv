/*
 * 20260505: 【修复版】
 * 适配真正2级流水线内核
 * 延迟：calc_start_i → 2个时钟周期输出结果
 */
`include "registers.svh"
import posit_types_pkg::*;

module posit_mult_vec_pipe2 #(
    parameter int unsigned NUM_MULT = 16,
    parameter int unsigned n_i = 16,
    parameter int unsigned es_i = 2,
    parameter int unsigned n_o = 16,
    parameter int unsigned es_o = 2,
    parameter int unsigned ALIGN_WIDTH = 14
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic calc_start_i,

    input  logic [n_i-1:0] vec_a_i[NUM_MULT-1:0],
    input  logic [n_i-1:0] vec_b_i[NUM_MULT-1:0],
    output logic [n_o-1:0] vec_c_o[NUM_MULT-1:0],

    output logic calc_done_o
);

    localparam int unsigned EXP_I_W      = get_exp_width_i(n_i, es_i) + 1;
    localparam int unsigned MANT_I_W     = get_mant_width_i(n_i, es_i) + 1;
    localparam int unsigned ACC_EXP_W    = get_max_exp_width(n_i, es_i, n_o, es_o) + 1;
    localparam int unsigned ACC_MANT_W   = get_mant_width_o(n_o, es_o) + 3;

    //==========================================================================
    // 2级流水线使能（严格2拍）
    // en_i_1 = 第1拍
    // en_i_2 = 第2拍 → 输出完成
    //==========================================================================
    logic en_i_1, en_i_2;
    assign en_i_1 = calc_start_i;
    `FFARN(en_i_2, en_i_1, 0, clk_i, rstn_i)
    `FFARN(calc_done_o, en_i_2, 0,  clk_i,  rstn_i)
    
    // 完成信号 = 第2级使能（2拍输出，无额外延迟）
    // assign calc_done_o = en_i_2;

    // 内部信号
    logic a_sign_i[NUM_MULT-1:0], b_sign_i[NUM_MULT-1:0], c_sign_o[NUM_MULT-1:0];
    logic [EXP_I_W-1:0]   a_rg_exp_i[NUM_MULT-1:0], b_rg_exp_i[NUM_MULT-1:0];
    logic [MANT_I_W-1:0]  a_mant_i[NUM_MULT-1:0], b_mant_i[NUM_MULT-1:0];
    logic [ACC_EXP_W-1:0] c_rg_exp_o[NUM_MULT-1:0];
    logic [ACC_MANT_W-1:0] c_mant_o[NUM_MULT-1:0];

    // 解码器
    generate
        for (genvar i = 0; i < NUM_MULT; i++) begin:gen_decoder
            posit_decoder #(.n(n_i), .es(es_i)) u_a (.operand_i(vec_a_i[i]), .sign_o(a_sign_i[i]), .rg_exp_o(a_rg_exp_i[i]), .mant_norm_o(a_mant_i[i]));
            posit_decoder #(.n(n_i), .es(es_i)) u_b (.operand_i(vec_b_i[i]), .sign_o(b_sign_i[i]), .rg_exp_o(b_rg_exp_i[i]), .mant_norm_o(b_mant_i[i]));
        end
    endgenerate

    // 并行乘法内核
    generate
        for (genvar i = 0; i < NUM_MULT; i++) begin:gen_mult
            posit_mult_kernel_pipe2 #(
                .n_i(n_i),.es_i(es_i),.n_o(n_o),.es_o(es_o),.ALIGN_WIDTH(ALIGN_WIDTH)
            ) u_kernel (
                .clk_i(clk_i),.rstn_i(rstn_i),
                .en_i_1(en_i_1),.en_i_2(en_i_2),
                .a_sign_i(a_sign_i[i]),.a_rg_exp_i(a_rg_exp_i[i]),.a_mant_i(a_mant_i[i]),
                .b_sign_i(b_sign_i[i]),.b_rg_exp_i(b_rg_exp_i[i]),.b_mant_i(b_mant_i[i]),
                .c_sign_o(c_sign_o[i]),.c_rg_exp_o(c_rg_exp_o[i]),.c_mant_o(c_mant_o[i])
            );
        end
    endgenerate

    // 编码器
    generate
        for (genvar i = 0; i < NUM_MULT; i++) begin:gen_encoder
            posit_encoder #(
                .n(n_o),.es(es_o),.EXP_WIDTH(ACC_EXP_W-1),.MANT_WIDTH(ACC_MANT_W-1)
            ) u_c (.sign_i(c_sign_o[i]),.rg_exp_i(c_rg_exp_o[i]),.mant_norm_i(c_mant_o[i]),.result_o(vec_c_o[i]));
        end
    endgenerate

endmodule