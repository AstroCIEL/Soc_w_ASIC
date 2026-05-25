`include "registers.svh"
import posit_types_pkg::*;

module posit_add_kernel_pipe2 #(
    parameter int unsigned n_i = 16,
    parameter int unsigned es_i = 2,
    parameter int unsigned n_o = 16,
    parameter int unsigned es_o = 2,
    parameter int unsigned ALIGN_WIDTH = 32
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic en_i_1,
    input  logic en_i_2,

    input  logic                                                     a_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               a_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              a_mant_i,
    input  logic                                                     b_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               b_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              b_mant_i,

    output  logic                                                    sum_sign_o,
    output  logic signed [get_max_exp_width(n_i, es_i, n_o, es_o):0] sum_rg_exp_o,
    output  logic        [get_mant_width_o(n_o, es_o)+2:0]           sum_mant_o
);

    localparam int unsigned EXP_WIDTH_I  = get_exp_width_i(n_i, es_i);
    localparam int unsigned MANT_WIDTH_I = get_mant_width_i(n_i, es_i);
    localparam int unsigned MANT_WIDTH_O = get_mant_width_o(n_o, es_o);
    localparam int unsigned EXP_WIDTH    = get_max_exp_width(n_i, es_i, n_o, es_o);
    localparam int unsigned CARRY_WIDTH  = $clog2(2);
    localparam int unsigned SUM_WIDTH    = ALIGN_WIDTH + CARRY_WIDTH;
    localparam int unsigned SHIFT_WIDTH  = $clog2(ALIGN_WIDTH + 1);

    // ======================================
    // 第1级寄存器
    // ======================================
    logic                        a_sign_r;
    logic signed [EXP_WIDTH_I:0] a_rg_exp_r;
    logic        [MANT_WIDTH_I:0] a_mant_r;
    logic                        b_sign_r;
    logic signed [EXP_WIDTH_I:0] b_rg_exp_r;
    logic        [MANT_WIDTH_I:0] b_mant_r;

    `FFLARN(a_sign_r,    a_sign_i,    en_i_1, 0, clk_i, rstn_i)
    `FFLARN(a_rg_exp_r,  a_rg_exp_i,  en_i_1, 0, clk_i, rstn_i)
    `FFLARN(a_mant_r,    a_mant_i,    en_i_1, 0, clk_i, rstn_i)
    `FFLARN(b_sign_r,    b_sign_i,    en_i_1, 0, clk_i, rstn_i)
    `FFLARN(b_rg_exp_r,  b_rg_exp_i,  en_i_1, 0, clk_i, rstn_i)
    `FFLARN(b_mant_r,    b_mant_i,    en_i_1, 0, clk_i, rstn_i)

    // ======================================
    // 组合逻辑：全运算（全部用 assign 连续赋值）
    // ======================================
    logic [1:0] signs;
    assign signs[0] = a_sign_r;
    assign signs[1] = b_sign_r;

    logic signed [1:0][EXP_WIDTH:0] rg_exp_items;
    assign rg_exp_items[0] = a_rg_exp_r;
    assign rg_exp_items[1] = b_rg_exp_r;
    
    logic signed [EXP_WIDTH:0] rg_exp_max;
    comparator #(.WIDTH(EXP_WIDTH)) u_max_comparator (
        .operand_a(rg_exp_items[0]), 
        .operand_b(rg_exp_items[1]), 
        .result_o(rg_exp_max)
    );

    logic [1:0][ALIGN_WIDTH-1:0] operand_aligned;
    assign operand_aligned[0] = (ALIGN_WIDTH > MANT_WIDTH_I + 1) ? 
        (a_mant_r << (ALIGN_WIDTH - MANT_WIDTH_I - 1)) : 
        (a_mant_r >> (MANT_WIDTH_I + 1 - ALIGN_WIDTH));
    assign operand_aligned[1] = (ALIGN_WIDTH > MANT_WIDTH_I + 1) ? 
        (b_mant_r << (ALIGN_WIDTH - MANT_WIDTH_I - 1)) : 
        (b_mant_r >> (MANT_WIDTH_I + 1 - ALIGN_WIDTH));

    logic [1:0][EXP_WIDTH:0] rg_exp_diff;
    logic [1:0][SHIFT_WIDTH-1:0] shift_amount;
    logic [1:0][ALIGN_WIDTH-1:0] operand_shifted;
    generate
        for (genvar z=0; z<2; z++) assign rg_exp_diff[z] = unsigned'(rg_exp_max - rg_exp_items[z]);
        for (genvar s=0; s<2; s++) begin
            assign shift_amount[s] = |rg_exp_diff[s][EXP_WIDTH:SHIFT_WIDTH] ? ALIGN_WIDTH : rg_exp_diff[s][SHIFT_WIDTH-1:0];
            barrel_shifter #(.WIDTH(ALIGN_WIDTH), .SHIFT_WIDTH(SHIFT_WIDTH), .MODE(1'b1)) u_shifter (
                .operand_i(operand_aligned[s]), .shift_amount(shift_amount[s]), .result_o(operand_shifted[s])
            );
        end
    endgenerate

    logic [1:0][SUM_WIDTH:0] mantissa_comp;
    generate for (genvar y=0; y<2; y++) 
        assign mantissa_comp[y] = signs[y] ? (~operand_shifted[y] + 1'b1) : operand_shifted[y]; 
    endgenerate


    // logic [SUM_WIDTH:0] sum_result;
    // assign sum_result = mantissa_comp[0] + mantissa_comp[1];
    //上面两行直接相加，和下面用csa_tree都是对的。
    logic [SUM_WIDTH:0] csa_sum, csa_carry, sum_result;
    //TODO:N=2的时候时直通的，这个csa_tree没必要
    csa_tree #(
        .N(2), .WIDTH_I(SUM_WIDTH+1), .WIDTH_O(SUM_WIDTH+1)
    ) u_csa_tree (
        .operands_i(mantissa_comp), .sum_o(csa_sum), .carry_o(csa_carry)
    );
    assign sum_result = csa_sum + csa_carry;

    logic final_sign;
    logic [SUM_WIDTH-1:0] sum_abs;
    assign final_sign = sum_result[SUM_WIDTH];
    assign sum_abs    = final_sign ? (~sum_result + 1'b1) : sum_result[SUM_WIDTH-1:0];

    logic signed [EXP_WIDTH:0] rg_exp_adjust;
    logic [SUM_WIDTH-1:0] sum_norm;
    mantissa_norm #(.WIDTH(SUM_WIDTH), .EXP_WIDTH(EXP_WIDTH), .DECIMAL_POINT(CARRY_WIDTH+1)) u_norm (
        .operand_i(sum_abs), .exp_adjust(rg_exp_adjust), .result_o(sum_norm)
    );

    logic signed [EXP_WIDTH:0] final_rg_exp;
    logic [MANT_WIDTH_O+2:0] final_mant;
    assign final_rg_exp = rg_exp_max + rg_exp_adjust;
    assign final_mant = (SUM_WIDTH > MANT_WIDTH_O+3) ? 
        {sum_norm[SUM_WIDTH-1:SUM_WIDTH-MANT_WIDTH_O-2], |sum_norm[SUM_WIDTH-MANT_WIDTH_O-3:0]} : 
        (sum_norm << (MANT_WIDTH_O+3-SUM_WIDTH));

    // ======================================
    // 第2级寄存器
    // ======================================
    `FFLARN(sum_sign_o,    final_sign,    en_i_2, 0, clk_i, rstn_i)
    `FFLARN(sum_rg_exp_o,  final_rg_exp,  en_i_2, 0, clk_i, rstn_i)
    `FFLARN(sum_mant_o,    final_mant,    en_i_2, 0, clk_i, rstn_i)

endmodule