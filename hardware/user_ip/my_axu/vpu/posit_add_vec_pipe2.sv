`include "registers.svh"
import posit_types_pkg::*;
/*
 20260505：
 适配posit_add_kernel_pipe2.sv, 两级流水线，输入输出为posit格式，带encoder、decoder。
*/
module posit_add_vec_pipe2 #(
    parameter int unsigned NUM_ADDER = 16,
    parameter int unsigned n = 16,
    parameter int unsigned es = 2,
    parameter int unsigned ALIGN_WIDTH = 14
)(
    input  logic         clk_i,
    input  logic         rstn_i,
    input  logic         calc_start_i,   // t0 有效
    output logic         calc_done_o,    // t2 与结果同步有效

    input  logic [n-1:0]  vec_a_posit_i [NUM_ADDER-1:0],
    input  logic [n-1:0]  vec_b_posit_i [NUM_ADDER-1:0],
    output logic [n-1:0]  vec_sum_posit_o[NUM_ADDER-1:0]
);

    localparam int unsigned EXP_WIDTH_I  = get_exp_width_i(n, es);
    localparam int unsigned MANT_WIDTH_I = get_mant_width_i(n, es);
    localparam int unsigned MAX_EXP_W    = get_max_exp_width(n, es, n, es);
    localparam int unsigned MANT_WIDTH_O = get_mant_width_o(n, es);

    logic                         a_sign  [NUM_ADDER-1:0];
    logic signed [EXP_WIDTH_I:0]  a_rg_exp[NUM_ADDER-1:0];
    logic        [MANT_WIDTH_I:0] a_mant  [NUM_ADDER-1:0];
    logic                         b_sign  [NUM_ADDER-1:0];
    logic signed [EXP_WIDTH_I:0]  b_rg_exp[NUM_ADDER-1:0];
    logic        [MANT_WIDTH_I:0] b_mant  [NUM_ADDER-1:0];

    logic                           sum_sign  [NUM_ADDER-1:0];
    logic signed [MAX_EXP_W:0]      sum_rg_exp[NUM_ADDER-1:0];
    logic        [MANT_WIDTH_O+2:0] sum_mant  [NUM_ADDER-1:0];

    // ===================== 核心：2级流水线使能链（精准2拍） =====================
    logic en_i_1, en_i_2;
    assign en_i_1 = calc_start_i;                  // t0：第1级使能
    `FFARN(en_i_2, en_i_1, 0, clk_i, rstn_i);      // t1：第2级使能
    `FFARN(calc_done_o, en_i_2, 0, clk_i, rstn_i); // t2：done 输出（和结果同步）

    // 解码：纯组合逻辑（0延迟）
generate
    for (genvar i = 0; i < NUM_ADDER; i++) begin:gen_decoder
        posit_decoder #(.n(n), .es(es)) u_dec_a (
            .operand_i(vec_a_posit_i[i]), .sign_o(a_sign[i]), .rg_exp_o(a_rg_exp[i]), .mant_norm_o(a_mant[i])
        );
        posit_decoder #(.n(n), .es(es)) u_dec_b (
            .operand_i(vec_b_posit_i[i]), .sign_o(b_sign[i]), .rg_exp_o(b_rg_exp[i]), .mant_norm_o(b_mant[i])
        );
    end
endgenerate

    // 加法内核：2级流水线 → t2 输出结果
generate
    for (genvar i = 0; i < NUM_ADDER; i++) begin:gen_adder
        posit_add_kernel_pipe2 #(
            .n_i(n), .es_i(es), .n_o(n), .es_o(es), .ALIGN_WIDTH(ALIGN_WIDTH)
        ) u_kernel (
            .clk_i(clk_i), .rstn_i(rstn_i),
            .en_i_1(en_i_1), .en_i_2(en_i_2),
            .a_sign_i(a_sign[i]), .a_rg_exp_i(a_rg_exp[i]), .a_mant_i(a_mant[i]),
            .b_sign_i(b_sign[i]), .b_rg_exp_i(b_rg_exp[i]), .b_mant_i(b_mant[i]),
            .sum_sign_o(sum_sign[i]), .sum_rg_exp_o(sum_rg_exp[i]), .sum_mant_o(sum_mant[i])
        );
    end
endgenerate

    // 编码：纯组合逻辑（0延迟）
generate
    for (genvar i = 0; i < NUM_ADDER; i++) begin:gen_encoder
        posit_encoder #(.n(n), .es(es), .EXP_WIDTH(MAX_EXP_W), .MANT_WIDTH(MANT_WIDTH_O+2)) u_enc (
            .sign_i(sum_sign[i]), .rg_exp_i(sum_rg_exp[i]), .mant_norm_i(sum_mant[i]), .result_o(vec_sum_posit_o[i])
        ); 
    end
endgenerate

endmodule