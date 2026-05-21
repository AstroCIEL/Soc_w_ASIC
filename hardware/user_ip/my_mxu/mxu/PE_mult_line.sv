/*
 * Posit 乘法器内核：无编解码 (No Encoder/Decoder)
 * 功能：接收两个解码后的 Posit 分量，完成乘法计算，输出待编码的 Posit 分量
 * 流水线结构：3 级 (Input Register -> Multiply -> Normalize/Round -> Output Register)
 */
`include "registers.svh"
import posit_types_pkg::*;

module PE_mult_line #(
    parameter int unsigned PE_NUM = 16,
    parameter int unsigned n_i = 16,                // Posit 字长 (输入输出一致)
    parameter int unsigned es_i = 2,
    parameter int unsigned n_o = 16,                // 输出Posit字长
    parameter int unsigned es_o = 2,                // 输出指数大小
    parameter int unsigned ALIGN_WIDTH = 14         // 指数大小 (输入输出一致)
)(
    // 时钟与复位
    input  logic clk_i,
    input  logic rstn_i,
    input  logic data_mode_i,//0=posit, 1=int
    
    // 流水线使能信号
    input  logic wgt_update_en_i,
    output logic wgt_update_en_o,

    input  logic calc_start_i,
    output logic calc_done_o,


    input  posit_in_t   act_i[PE_NUM-1:0],
    input  posit_in_t   wgt_i[PE_NUM-1:0],

    output posit_in_t   act_o[PE_NUM-1:0],
    output posit_in_t   wgt_o[PE_NUM-1:0],
    output posit_acc_t  acc_o[PE_NUM-1:0]
);




    logic en_i_1, en_i_2, en_i_3, en_i_4;
    
    assign en_i_1 = calc_start_i;
    `FFARN(en_i_2,      en_i_1,          0,  clk_i,  rstn_i)
    `FFARN(en_i_3,      en_i_2,          0,  clk_i,  rstn_i)
    `FFARN(en_i_4,      en_i_3,          0,  clk_i,  rstn_i)
//int mode: en_i_3, posit mode: en_i_4
assign calc_done_o = data_mode_i?en_i_3: en_i_4;

    logic wgt_en_i_1;
    assign wgt_en_i_1 = wgt_update_en_i;
    `FFARN(wgt_update_en_o,   wgt_en_i_1,   0,  clk_i,  rstn_i)




generate
    for(genvar i = 0; i < PE_NUM; i++) begin : gen_pe

PE_mult_kernel #(
    .n_i(n_i),
    .es_i(es_i),
    .n_o(n_o),
    .es_o(es_o),
    .ALIGN_WIDTH(ALIGN_WIDTH)
) u_PE_mult_kernel (
    // 时钟与复位
    .clk_i(clk_i),
    .rstn_i(rstn_i),
    
    // 流水线使能信号
    .wgt_en_i_1(wgt_en_i_1),
    .en_i_1(en_i_1), 
    .en_i_2(en_i_2), 
    .en_i_3(en_i_3),
    .data_mode_i (data_mode_i),//0=posit, 1=int


    // ================= 输入接口 (解码后的格式) =================
    .act_sign_i  (act_i[i].sign),
    .act_rg_exp_i(act_i[i].rg_exp),
    .act_mant_i  (act_i[i].mant),

    .wgt_sign_i  (wgt_i[i].sign),
    .wgt_rg_exp_i(wgt_i[i].rg_exp),
    .wgt_mant_i  (wgt_i[i].mant),

    // ================= 输出接口 (待编码的格式) =================
    .act_sign_o  (act_o[i].sign),
    .act_rg_exp_o(act_o[i].rg_exp),
    .act_mant_o  (act_o[i].mant),

    .wgt_sign_o  (wgt_o[i].sign),
    .wgt_rg_exp_o(wgt_o[i].rg_exp),
    .wgt_mant_o  (wgt_o[i].mant),

    .acc_sign_o  (acc_o[i].sign),
    .acc_rg_exp_o(acc_o[i].rg_exp),
    .acc_mant_o  (acc_o[i].mant)
);


    end

    endgenerate
endmodule