`include "registers.svh"
//PE_line：由多个PE组成一行，互相之间没有直接的连线；行为相同，因此共享控制信号的寄存器
import posit_types_pkg::*;

module Systolic_Array #(
    parameter int unsigned LINE_NUM = 16,
    parameter int unsigned PE_NUM = 16,
    parameter int unsigned n_i = 8,
    parameter int unsigned es_i = 2,
    parameter int unsigned n_o = 16,
    parameter int unsigned es_o = 2,
    parameter int unsigned ALIGN_WIDTH = 16
)(
    input  logic clk_i,
    input  logic rstn_i,

    input  logic data_flow_mode_i,//0=FF, 1=BP
    input  logic data_type_mode_i,//0=posit, 1=int

    input  logic wgt_update_en_i,
    output logic wgt_update_en_o,

    input  logic calc_start_i,
    output logic calc_done_o,

// ================= 输入接口 (使用结构体) =================
    // 定义具体的结构体类型
    input  posit_in_t   act_i[PE_NUM-1:0],
    input  posit_in_t   wgt_i[PE_NUM-1:0],


    // ================= 输出接口 (使用结构体) =================


    output posit_acc_t  acc_o[PE_NUM-1:0]
);
localparam  DATAFLOW_MODE_FF = 1'b0;
localparam  DATAFLOW_MODE_BP = 1'b1;
localparam  DATATYPE_MODE_POSIT = 1'b0;
localparam  DATATYPE_MODE_INT = 1'b1;

logic[LINE_NUM-1:0] wgt_update_en_i_mid;
logic[LINE_NUM-1:0] wgt_update_en_o_mid;
logic[LINE_NUM-1:0] calc_start_i_mid;
logic[LINE_NUM-1:0] calc_done_o_mid;



assign wgt_update_en_i_mid[0] = wgt_update_en_i;
assign calc_start_i_mid[0] = calc_start_i;
generate
    for(genvar i=1; i<LINE_NUM; i++) begin: gen_en_reg
        assign wgt_update_en_i_mid[i] = wgt_update_en_o? 0 : wgt_update_en_o_mid[i-1];
        assign calc_start_i_mid[i] = calc_done_o_mid[i-1];
    end
endgenerate

assign wgt_update_en_o = wgt_update_en_o_mid[LINE_NUM-1];
assign calc_done_o = calc_done_o_mid[LINE_NUM-1];


//中间信号
    posit_in_t   act_i_mid[LINE_NUM-1:0][PE_NUM-1:0];
    posit_in_t   wgt_i_mid[LINE_NUM-1:0][PE_NUM-1:0];
    posit_acc_t  acc_i_mid[LINE_NUM-1:0][PE_NUM-1:0];

//中间信号
    posit_in_t   act_o_mid[LINE_NUM-1:0][PE_NUM-1:0];
    posit_in_t   wgt_o_mid[LINE_NUM-1:0][PE_NUM-1:0];
    posit_acc_t  acc_o_mid[LINE_NUM-1:0][PE_NUM-1:0];



//DiP数据流
//====================================================================
//FF模式下：act斜传
//BP模式下：act竖传
assign act_i_mid[0] = act_i;
generate
    for(genvar i = 1; i < LINE_NUM; i++) begin 
        for(genvar j = 0; j < PE_NUM; j++) begin 
            assign act_i_mid[i][j] = (data_flow_mode_i == DATAFLOW_MODE_FF)? act_o_mid[i-1][(j+1)%PE_NUM] : 
                                     (data_flow_mode_i == DATAFLOW_MODE_BP)? act_o_mid[i-1][j] : '0;
        end
    end
endgenerate
// generate 
//     for(genvar j = 0; j < PE_NUM; j++) begin 
//         assign act_o[j] = (data_flow_mode_i == DATAFLOW_MODE_FF)? act_o_mid[LINE_NUM-1][(j+1)%PE_NUM] : 
//                           (data_flow_mode_i == DATAFLOW_MODE_BP)? act_o_mid[LINE_NUM-1][j]: '0;
//     end
// endgenerate




//====================================================================
//FF模式下：acc竖传
//BP模式下：acc斜传
// assign acc_i_mid[0] = acc_i;
generate
    for(genvar i = 1; i < LINE_NUM; i++) begin 
        for(genvar j = 0; j < PE_NUM; j++) begin 
            assign acc_i_mid[i][j] = (data_flow_mode_i == DATAFLOW_MODE_FF)? acc_o_mid[i-1][j] : 
                                     (data_flow_mode_i == DATAFLOW_MODE_BP)? acc_o_mid[i-1][(j+1)%PE_NUM] : '0;
        end
    end
endgenerate
generate 
    for(genvar j = 0; j < PE_NUM; j++) begin 
        assign acc_o[j] = (data_flow_mode_i == DATAFLOW_MODE_FF)? acc_o_mid[LINE_NUM-1][j] : 
                          (data_flow_mode_i == DATAFLOW_MODE_BP)? acc_o_mid[LINE_NUM-1][(j+1)%PE_NUM] : '0;
    end
endgenerate





//====================================================================
//wgt竖传
assign wgt_i_mid[0] = wgt_i;
generate
    for(genvar i = 1; i < LINE_NUM; i++) begin : gen_wgt_shift
        assign wgt_i_mid[i] = wgt_o_mid[i-1];
    end
endgenerate
// assign wgt_o = wgt_o_mid[LINE_NUM-1];

//====================================================================
PE_mult_line #(
        .PE_NUM(PE_NUM),
        .n_i(n_i),
        .es_i(es_i),
        .n_o(n_o),
        .es_o(es_o),
        .ALIGN_WIDTH(ALIGN_WIDTH)
) u_PE_mult_line (
        .clk_i          (clk_i),
        .rstn_i         (rstn_i),
        .data_mode_i    (data_type_mode_i),
        .wgt_update_en_i(wgt_update_en_i_mid[0]),
        .wgt_update_en_o(wgt_update_en_o_mid[0]),
        .calc_start_i   (calc_start_i_mid[0]   ),
        .calc_done_o    (calc_done_o_mid[0]    ),

        .act_i(act_i_mid[0]),
        .wgt_i(wgt_i_mid[0]),

        .act_o(act_o_mid[0]),
        .wgt_o(wgt_o_mid[0]),
        .acc_o(acc_o_mid[0])

);

generate
    for(genvar i = 1; i < LINE_NUM-1; i++) begin : gen_line
    PE_line #(
        .PE_NUM(PE_NUM),
        .n_i(n_i),
        .es_i(es_i),
        .n_o(n_o),
        .es_o(es_o),
        .ALIGN_WIDTH(ALIGN_WIDTH)
    ) u_pe_line (
        .clk_i          (clk_i),
        .rstn_i         (rstn_i),
        .data_mode_i    (data_type_mode_i),
        .wgt_update_en_i(wgt_update_en_i_mid[i]),
        .wgt_update_en_o(wgt_update_en_o_mid[i]),
        .calc_start_i   (calc_start_i_mid[i]   ),
        .calc_done_o    (calc_done_o_mid[i]    ),

        .act_i(act_i_mid[i]),
        .wgt_i(wgt_i_mid[i]),
        .acc_i(acc_i_mid[i]),
        .act_o(act_o_mid[i]),
        .wgt_o(wgt_o_mid[i]),
        .acc_o(acc_o_mid[i])
    );
    end
endgenerate

PE_mac_line #(
        .PE_NUM(PE_NUM),
        .n_i(n_i),
        .es_i(es_i),
        .n_o(n_o),
        .es_o(es_o),
        .ALIGN_WIDTH(ALIGN_WIDTH)
) u_PE_mac_line (
        .clk_i          (clk_i),
        .rstn_i         (rstn_i),
        .data_mode_i    (data_type_mode_i),
        .wgt_update_en_i(wgt_update_en_i_mid[LINE_NUM-1]),
        .wgt_update_en_o(wgt_update_en_o_mid[LINE_NUM-1]),
        .calc_start_i   (calc_start_i_mid[LINE_NUM-1]   ),
        .calc_done_o    (calc_done_o_mid[LINE_NUM-1]    ),

        .act_i(act_i_mid[LINE_NUM-1]),
        .wgt_i(wgt_i_mid[LINE_NUM-1]),
        .acc_i(acc_i_mid[LINE_NUM-1]),

        .acc_o(acc_o_mid[LINE_NUM-1])
);
endmodule