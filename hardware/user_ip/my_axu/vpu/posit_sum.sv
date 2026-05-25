`include "registers.svh"
import posit_types_pkg::*;

/*
 20260508:
 Posit 向量reduction求和顶层包装模块
 功能：INPUT_NUM 个原始Posit输入 → 输出求和结果（原始Posit）
 结构：Decoder数组 → 流水线求和Kernel → Encoder
 使能：与posit_add_vec完全一致的3级打拍 + calc_done_o
*/
module posit_sum #(
    parameter int unsigned INPUT_NUM   = 16, //求和输入数量
    parameter int unsigned n_i         = 16,
    parameter int unsigned es_i        = 2,
    parameter int unsigned n_o         = 16,
    parameter int unsigned es_o        = 2,
    parameter int unsigned ALIGN_WIDTH = 32
)(
    // 时钟与复位
    input  logic         clk_i,
    input  logic         rstn_i,
    // 控制信号
    input  logic         calc_start_i,
    output logic         calc_done_o,
    
    // 顶层输入：原始Posit数
    input  logic [INPUT_NUM-1:0][n_i-1:0]  posit_data_i,

    // 顶层输出：求和结果（Posit格式）
    output logic [n_o-1:0]                 posit_sum_o
);

// ======================== 本地参数 ========================
localparam int unsigned EXP_WIDTH_I    = get_exp_width_i(n_i, es_i); //=6
localparam int unsigned MANT_WIDTH_I   = get_mant_width_i(n_i, es_i); //=11
localparam int unsigned MAX_EXP_W       = get_max_exp_width(n_i, es_i, n_o, es_o); //=7
localparam int unsigned MANT_WIDTH_O   = get_mant_width_o(n_o, es_o);  

// ======================== 内部信号 ========================
// 解码后分量
logic [INPUT_NUM-1:0]                     dec_sign;
// logic signed [INPUT_NUM-1:0]  [EXP_WIDTH_I:0]   dec_rg_exp;
// logic [INPUT_NUM-1:0]        [MANT_WIDTH_I:0]  dec_mant_norm;
logic signed [INPUT_NUM-1:0]  [EXP_WIDTH_I:0]   dec_rg_exp; 
logic [INPUT_NUM-1:0]        [MANT_WIDTH_O+2:0]  dec_mant_norm; //改为acc精度

// 求和核输出分量
logic                                     sum_sign;
logic signed [MAX_EXP_W:0]                sum_rg_exp;
logic        [MANT_WIDTH_O+2:0]           sum_mant_norm;


// ======================== Step1: 批量Posit解码 ========================
generate
    for (genvar i = 0; i < INPUT_NUM; i++) begin : gen_decoder_array
        posit_decoder #(
            .n(n_i),
            .es(es_i),
            // .EXP_WIDTH(MAX_EXP_W), 即使指定了EXP_WIDTH,rg_exp_o还是只有低7位有效。
            .MANT_WIDTH(MANT_WIDTH_O + 2)
        ) u_dec (
            .operand_i    (posit_data_i[i]),
            .sign_o       (dec_sign[i]),
            .rg_exp_o     (dec_rg_exp[i]),
            .mant_norm_o  (dec_mant_norm[i])
        );
    end
endgenerate

// ======================== Step2: 流水线求和核 ========================
//0510 把dec_rg_exp补到8位(符号位拓展)
logic signed [INPUT_NUM-1:0][MAX_EXP_W:0] dec_rg_exp_sxt;
generate
  for (genvar i = 0; i < INPUT_NUM; i++) begin : gen_rg_exp_sxt
    assign dec_rg_exp_sxt[i] = $signed(dec_rg_exp[i]);
  end
endgenerate

posit_sum_kernel #(
    .n_i         (n_i),
    .es_i        (es_i),
    .n_o         (n_o),
    .es_o        (es_o),
    .ALIGN_WIDTH (ALIGN_WIDTH),
    .INPUT_NUM   (INPUT_NUM)
) u_sum_kernel (
    .clk_i       (clk_i),
    .rstn_i      (rstn_i),
    .calc_start_i(calc_start_i),
    .calc_done_o(calc_done_o),

    .a_sign_i    (dec_sign),
    .a_rg_exp_i  (dec_rg_exp_sxt), //dec_rg_exp拓展符号位之后再输入a
    .a_mant_i    (dec_mant_norm),

    .sum_sign_o  (sum_sign),
    .sum_rg_exp_o(sum_rg_exp),
    .sum_mant_o  (sum_mant_norm)
);

// ======================== Step3: 编码回Posit ========================
posit_encoder #(
    .n(n_o),
    .es(es_o),
    .EXP_WIDTH(MAX_EXP_W),
    .MANT_WIDTH(MANT_WIDTH_O + 2)
) u_enc (
    .sign_i       (sum_sign),
    .rg_exp_i     (sum_rg_exp),
    .mant_norm_i  (sum_mant_norm),
    .result_o     (posit_sum_o)
);

endmodule