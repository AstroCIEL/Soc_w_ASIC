`include "registers.svh"
import posit_types_pkg::*;

/*
 20260508：
 Posit 解码格式 流水线求和核 (二叉树 + 级联2级流水线)
 功能：INPUT_NUM个解码格式posit求和，全流水线化，支持连续输入
 使能：跟随数据同步打拍，保证流水线对齐
*/
module posit_sum_kernel #(
    parameter int unsigned n_i         = 16,
    parameter int unsigned es_i        = 2,
    parameter int unsigned n_o         = 16,
    parameter int unsigned es_o        = 2,
    parameter int unsigned ALIGN_WIDTH = 32,
    parameter int unsigned INPUT_NUM   = 16  // 任意输入数
)(
    input  logic clk_i,
    input  logic rstn_i,

    input  logic calc_start_i,
    output logic calc_done_o,

    // 输入：INPUT_NUM个解码格式posit（流水输入）
    // input  logic [INPUT_NUM-1:0]                                    a_sign_i,
    // input  logic signed [INPUT_NUM-1:0][get_exp_width_i(n_i, es_i):0] a_rg_exp_i,
    // input  logic        [INPUT_NUM-1:0][get_mant_width_i(n_i, es_i):0] a_mant_i,
    //输入的解码后格式改成acc精度
    input  logic [INPUT_NUM-1:0]                                    a_sign_i,
    input  logic signed [INPUT_NUM-1:0][get_max_exp_width(n_i, es_i, n_o, es_o):0] a_rg_exp_i,
    input  logic        [INPUT_NUM-1:0][get_mant_width_o(n_o, es_o)+2:0] a_mant_i, 

    // 输出：流水线求和结果
    output  logic                                                    sum_sign_o,
    output  logic signed [get_max_exp_width(n_i, es_i, n_o, es_o):0] sum_rg_exp_o,
    output  logic        [get_mant_width_o(n_o, es_o)+2:0]           sum_mant_o
);

// ======================== 基础参数 ========================
// localparam int unsigned EXP_O_W  = get_max_exp_width(n_i, es_i, n_o, es_o)+1; 
// localparam int unsigned MANT_O_W = get_mant_width_o(n_o, es_o) + 3;

// ======================== 树结构参数 ========================
localparam int unsigned NUM_FULL   = 1 << $clog2(INPUT_NUM);  // 补全到2^n
localparam int unsigned TREE_LEVEL = $clog2(NUM_FULL);        // 树层数

// ======================== 流水线使能打拍 ========================
// 每一层需要2级使能，总使能打拍深度 = TREE_LEVEL * 2
logic [TREE_LEVEL:0] pipe_en;
logic [TREE_LEVEL-1:0] pipe_en_d1;

// 第0级使能：直接接输入
assign pipe_en[0] = calc_start_i;

// 树状流水线节点
posit_acc_t tree [TREE_LEVEL+1][NUM_FULL-1:0]; //指数8bit, mant14bit

// ======================== 第0层：输入赋值 + 补0 ========================
generate
    for (genvar i = 0; i < NUM_FULL; i++) begin
        if(i<INPUT_NUM)begin
            assign tree[0][i].sign   =  a_sign_i[i] ;
            assign tree[0][i].rg_exp =  a_rg_exp_i[i];  
            assign tree[0][i].mant   =  a_mant_i[i]<<2;
        end else begin
            assign tree[0][i].sign   = 1'b0;
            assign tree[0][i].rg_exp = -8'sd60;  //0的rg_exp=11000100=-60 
            assign tree[0][i].mant   = '0;
        end
    end
endgenerate

// ======================== 流水线二叉归并树（核心） ========================
generate
    for (genvar L = 0; L < TREE_LEVEL; L++) begin : gen_pipe_tree
        // 当前层节点数量
        localparam int unsigned NODES = NUM_FULL >> (L+1);
        
        for (genvar i = 0; i < NODES; i++) begin : gen_pipe_adder
            // =======方法一：直接截断==================
            // posit_in_t left; //7位rg_exp, 12位mant
            // assign left.sign  = tree[L][2*i].sign;
            // assign left.rg_exp= tree[L][2*i].rg_exp; //直接截取低位
            // assign left.mant = tree[L][2*i].mant[ACC_MANT_W-1:ACC_MANT_W-MANT_I_W]; //截取高位
            // posit_in_t right;
            // assign right.sign  = tree[L][2*i+1].sign;
            // assign right.rg_exp= tree[L][2*i+1].rg_exp; //直接截取低位
            // assign right.mant = tree[L][2*i+1].mant[ACC_MANT_W-1:ACC_MANT_W-MANT_I_W]; //截取高位
            // posit_acc_t sum_node;
            //====================================

            // //================法二：RNE==================
            // // 取左右节点
            // posit_in_t left;
            // assign left.sign  = tree[L][2*i].sign;
            // assign left.rg_exp= tree[L][2*i].rg_exp;

            // // ======================== 尾数：Round to Nearest Even 舍入 ========================
            // logic [MANT_I_W-1:0] left_mant_msb;
            // logic                left_round_bit;
            // logic                left_sticky_bit;
            // logic                left_round_en;
            // assign left_mant_msb   = tree[L][2*i].mant[ACC_MANT_W-1 : ACC_MANT_W - MANT_I_W];
            // assign left_round_bit   = tree[L][2*i].mant[ACC_MANT_W - MANT_I_W - 1];
            // assign left_sticky_bit  = |tree[L][2*i].mant[ACC_MANT_W - MANT_I_W - 2 : 0];
            // assign left_round_en    = left_round_bit & (left_sticky_bit | left_mant_msb[0]);
            // assign left.mant        = left_mant_msb + left_round_en;

            // posit_in_t right;
            // assign right.sign  = tree[L][2*i+1].sign;
            // assign right.rg_exp= tree[L][2*i+1].rg_exp;

            // // ======================== 尾数：Round to Nearest Even 舍入 ========================
            // logic [MANT_I_W-1:0] right_mant_msb;
            // logic                right_round_bit;
            // logic                right_sticky_bit;
            // logic                right_round_en;
            // assign right_mant_msb   = tree[L][2*i+1].mant[ACC_MANT_W-1 : ACC_MANT_W - MANT_I_W];
            // assign right_round_bit   = tree[L][2*i+1].mant[ACC_MANT_W - MANT_I_W - 1];
            // assign right_sticky_bit  = |tree[L][2*i+1].mant[ACC_MANT_W - MANT_I_W - 2 : 0];
            // assign right_round_en    = right_round_bit & (right_sticky_bit | right_mant_msb[0]);
            // assign right.mant        = right_mant_msb + right_round_en;

            // posit_acc_t sum_node;
            // //========================================

           

            // // 复用2周期流水线加法核
            // posit_add_kernel_pipe2 #(
            //     .n_i(n_i), .es_i(es_i), .n_o(n_o), .es_o(es_o), .ALIGN_WIDTH(ALIGN_WIDTH)
            // ) u_adder (
            //     .clk_i(clk_i),
            //     .rstn_i(rstn_i),
            //     // 使用当前层的同步使能
            //     .en_i_1(pipe_en[L]),
            //     .en_i_2(pipe_en_d1[L]),

            //     .a_sign_i(left.sign),
            //     .a_rg_exp_i(left.rg_exp),
            //     .a_mant_i(left.mant),

            //     .b_sign_i(right.sign),
            //     .b_rg_exp_i(right.rg_exp),
            //     .b_mant_i(right.mant),

            //     .sum_sign_o(sum_node.sign),
            //     .sum_rg_exp_o(sum_node.rg_exp),
            //     .sum_mant_o(sum_node.mant)
            // );


            //==============法三：用posit_acc_add_kernel_pipe2,不需要截断/RNE，直接作为输入=====================
            posit_acc_t left; //acc精度 8位rg_exp, 14位mant
            assign left= tree[L][2*i]; //尾数符合1.f形式
            posit_acc_t right;
            assign right  = tree[L][2*i+1];
            posit_acc_t sum_node;

            posit_acc_add_kernel_pipe2 #(
                .n_i(n_i), .es_i(es_i), .n_o(n_o), .es_o(es_o), .ALIGN_WIDTH(ALIGN_WIDTH)
            ) u_adder (
                .clk_i(clk_i),
                .rstn_i(rstn_i),
                // 使用当前层的同步使能
                .en_i_1(pipe_en[L]),
                .en_i_2(pipe_en_d1[L]),

                .a_sign_i(left.sign),
                .a_rg_exp_i(left.rg_exp),
                .a_mant_i(left.mant),

                .b_sign_i(right.sign),
                .b_rg_exp_i(right.rg_exp),
                .b_mant_i(right.mant),

                .sum_sign_o(sum_node.sign),
                .sum_rg_exp_o(sum_node.rg_exp),
                .sum_mant_o(sum_node.mant)
            );
            //=========================================================


            // 存入当前流水线层
            assign tree[L+1][i] = sum_node;
        end

        // 使能信号同步打拍传递,对齐树的每一层
        `FFARN(pipe_en_d1[L], pipe_en[L],   0, clk_i, rstn_i);
        `FFARN(pipe_en[L+1],     pipe_en_d1[L], 0, clk_i, rstn_i);
    end
endgenerate

// ======================== 最终输出 ========================
assign calc_done_o = pipe_en[TREE_LEVEL]; //输出有效信号

assign sum_sign_o   = tree[TREE_LEVEL][0].sign;
assign sum_rg_exp_o = tree[TREE_LEVEL][0].rg_exp;
assign sum_mant_o   = tree[TREE_LEVEL][0].mant;

endmodule