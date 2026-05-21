`include "registers.svh"

//PE_line：由多个PE组成一行，互相之间没有直接的连线；行为相同，因此共享控制信号的寄存器
import posit_types_pkg::*;
module PE_line #(
    parameter int unsigned PE_NUM = 16,
    parameter int unsigned n_i = 8,
    parameter int unsigned es_i = 2,
    parameter int unsigned n_o = 16,
    parameter int unsigned es_o = 2,
    parameter int unsigned ALIGN_WIDTH = 14
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic data_mode_i,//0=posit, 1=int

    input  logic wgt_update_en_i,
    output logic wgt_update_en_o,

    input  logic calc_start_i,
    output logic calc_done_o,

// ================= 输入接口 (使用结构体) =================
    // 定义具体的结构体类型
    input  posit_in_t   act_i[PE_NUM-1:0],
    input  posit_in_t   wgt_i[PE_NUM-1:0],
    input  posit_acc_t  acc_i[PE_NUM-1:0],

    // ================= 输出接口 (使用结构体) =================
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

    PE_kernel #(
        .n_i(n_i),
        .es_i(es_i),
        .n_o(n_o),
        .es_o(es_o),
        .ALIGN_WIDTH(ALIGN_WIDTH)
    ) u_pe_kernel (
        .clk_i       (clk_i),
        .rstn_i      (rstn_i),
        .wgt_en_i_1  (wgt_en_i_1),
        .en_i_1      (en_i_1),
        .en_i_2      (en_i_2),
        .en_i_3      (en_i_3),
        .data_mode_i (data_mode_i),//0=posit, 1=int

        .act_sign_i  (act_i[i].sign),
        .act_rg_exp_i(act_i[i].rg_exp),
        .act_mant_i  (act_i[i].mant),

        .wgt_sign_i  (wgt_i[i].sign),
        .wgt_rg_exp_i(wgt_i[i].rg_exp),
        .wgt_mant_i  (wgt_i[i].mant),

        .acc_sign_i  (acc_i[i].sign),
        .acc_rg_exp_i(acc_i[i].rg_exp),
        .acc_mant_i  (acc_i[i].mant),

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