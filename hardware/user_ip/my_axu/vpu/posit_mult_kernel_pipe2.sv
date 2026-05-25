/*
 * 20260505: 【修复版】
 * Posit 乘法器内核：无编解码
 * 真正两级流水线：输入+乘法 = 第1拍；归一化+舍入=第2拍
 * 延迟：2 时钟周期
 */
`include "registers.svh"
import posit_types_pkg::*;

module posit_mult_kernel_pipe2 #(
    parameter int unsigned n_i = 16,
    parameter int unsigned es_i = 2,
    parameter int unsigned n_o = 16,
    parameter int unsigned es_o = 2,
    parameter int unsigned ALIGN_WIDTH = 14
)(
    input  logic clk_i,
    input  logic rstn_i,
    
    // 2级流水线使能
    input  logic en_i_1,
    input  logic en_i_2,

    // 输入
    input  logic                                                     a_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               a_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              a_mant_i,
    input  logic                                                     b_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               b_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              b_mant_i,

    // 输出
    output  logic                                                    c_sign_o,
    output  logic signed [get_max_exp_width(n_i, es_i, n_o, es_o):0] c_rg_exp_o,
    output  logic        [get_mant_width_o(n_o, es_o)+2:0]           c_mant_o
);

    // 参数
    localparam int unsigned EXP_WIDTH_I  = get_exp_width_i(n_i, es_i);
    localparam int unsigned MANT_WIDTH_I = get_mant_width_i(n_i, es_i);
    localparam int unsigned EXP_WIDTH    = get_max_exp_width(n_i, es_i, n_o, es_o);
    localparam int unsigned MUL_WIDTH    = 2 * (MANT_WIDTH_I + 1);
    localparam int unsigned SUM_WIDTH     = ALIGN_WIDTH;
    localparam int unsigned MANT_WIDTH_O = get_mant_width_o(n_o, es_o);

    //==========================================================================
    // 第1级流水线 (第1拍)：输入锁存 + 乘法运算
    //==========================================================================
    logic pipe0_a_sign, pipe0_b_sign;
    logic signed [EXP_WIDTH_I:0] pipe0_a_exp, pipe0_b_exp;
    logic        [MANT_WIDTH_I:0] pipe0_a_mant, pipe0_b_mant;

    // 锁存输入数据（第1拍）
    `FFLARN(pipe0_a_sign,      a_sign_i,     en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_a_exp,    a_rg_exp_i,   en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_a_mant,      a_mant_i,     en_i_1,  0,  clk_i,  rstn_i)

    `FFLARN(pipe0_b_sign,      b_sign_i,     en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_b_exp,    b_rg_exp_i,   en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_b_mant,      b_mant_i,     en_i_1,  0,  clk_i,  rstn_i)

    // 组合逻辑：乘法运算
    logic                      prod_sign;
    logic signed [EXP_WIDTH:0] prod_exp;
    logic [MUL_WIDTH-1:0]      mul_sum, mul_carry, mants_prod;
    logic [SUM_WIDTH-1:0]      product_aligned;

    assign prod_sign = pipe0_a_sign ^ pipe0_b_sign;
    assign prod_exp  = pipe0_a_exp + pipe0_b_exp;

    radix4_booth_multiplier #(
        .WIDTH_A(MANT_WIDTH_I + 1),
        .WIDTH_B(MANT_WIDTH_I + 1)
    ) u_radix4_booth_multiplier (
        .operand_a(pipe0_a_mant),
        .operand_b(pipe0_b_mant),
        .sum_o(mul_sum),
        .carry_o(mul_carry)
    );

    assign mants_prod = mul_sum + mul_carry;

    // 位宽适配
    if (ALIGN_WIDTH > MUL_WIDTH) begin
        assign product_aligned = mants_prod << (ALIGN_WIDTH - MUL_WIDTH);
    end
    else begin
        assign product_aligned = mants_prod >> (MUL_WIDTH - ALIGN_WIDTH);
    end

    //==========================================================================
    // 第2级流水线 (第2拍)：归一化 + 舍入 + 输出锁存
    //==========================================================================
    // 第1级结果锁存
    logic                      pipe1_sign;
    logic signed [EXP_WIDTH:0] pipe1_exp;
    logic [SUM_WIDTH-1:0]      pipe1_mant;

    `FFLARN(pipe1_sign,   prod_sign,      en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_mant,   product_aligned,    en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_exp,   prod_exp,     en_i_2,  0,  clk_i,  rstn_i)

    // 组合逻辑：归一化 + 舍入
    logic signed [EXP_WIDTH:0] exp_adj, final_exp;
    logic [SUM_WIDTH-1:0]      norm_mant;
    logic [MANT_WIDTH_O+2:0]   final_mant;

    mantissa_norm #(
        .WIDTH(SUM_WIDTH),
        .EXP_WIDTH(EXP_WIDTH),
        .DECIMAL_POINT(2)
    ) u_norm (
        .operand_i(pipe1_mant),
        .exp_adjust(exp_adj),
        .result_o(norm_mant)
    );

    assign final_exp = pipe1_exp + exp_adj;

    // 舍入
    if (SUM_WIDTH > MANT_WIDTH_O + 3) begin : gen_round_trunc
        logic sticky_bit;
        assign sticky_bit = |norm_mant[SUM_WIDTH-MANT_WIDTH_O-3:0];
        assign final_mant = {norm_mant[SUM_WIDTH-1:SUM_WIDTH-MANT_WIDTH_O-2], sticky_bit};
    end
    else begin : gen_round_pad
        assign final_mant = norm_mant << (MANT_WIDTH_O + 3 - SUM_WIDTH);
    end

    // 最终输出
    assign c_sign_o   = pipe1_sign;
    assign c_rg_exp_o = final_exp;
    assign c_mant_o   = final_mant;

endmodule