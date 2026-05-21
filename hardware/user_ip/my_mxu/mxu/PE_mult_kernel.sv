/*
 * Posit 乘法器内核：无编解码 (No Encoder/Decoder)
 * 功能：接收两个解码后的 Posit 分量，完成乘法计算，输出待编码的 Posit 分量
 * 说明：保留 ALIGN_WIDTH 对齐逻辑，移除不必要的桶形移位器
 */
`include "registers.svh"
import posit_types_pkg::*;

module PE_mult_kernel #(
    parameter int unsigned n_i = 16,                // 输入Posit字长
    parameter int unsigned es_i = 2,                // 输入指数大小
    parameter int unsigned n_o = 16,                // 输出Posit字长
    parameter int unsigned es_o = 2,                // 输出指数大小
    parameter int unsigned ALIGN_WIDTH = 14         // 对齐位宽
)(
    // 时钟与复位
    input  logic clk_i,
    input  logic rstn_i,
    
    // 流水线使能信号
    input  logic wgt_en_i_1, //这个是weight update的控制信号
    input  logic en_i_1, en_i_2, en_i_3, //这个是计算流水线的控制信号

    input  logic data_mode_i, //0=posit, 1=int

    // ================= 输入接口 (解码后的格式 / INT 复用格式) =================
    input  logic                                                     act_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               act_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              act_mant_i,

    input  logic                                                     wgt_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               wgt_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              wgt_mant_i,

    // ================= 输出接口 (待编码的格式 / INT 复用格式) =================
    output  logic                                                    act_sign_o,
    output  logic signed [get_exp_width_i(n_i, es_i):0]              act_rg_exp_o,
    output  logic        [get_mant_width_i(n_i, es_i):0]             act_mant_o,

    output  logic                                                    wgt_sign_o,
    output  logic signed [get_exp_width_i(n_i, es_i):0]              wgt_rg_exp_o,
    output  logic        [get_mant_width_i(n_i, es_i):0]             wgt_mant_o,

    output  logic                                                    acc_sign_o,   // INT: 无效
    output  logic signed [get_max_exp_width(n_i, es_i, n_o, es_o):0] acc_rg_exp_o, // INT: 无效
    output  logic        [get_mant_width_o(n_o, es_o)+2:0]           acc_mant_o    // INT: Result (2-cycle latency)
);

    // ================= 局部参数定义 =================
    localparam int unsigned EXP_WIDTH_I  = get_exp_width_i(n_i, es_i);
    localparam int unsigned MANT_WIDTH_I = get_mant_width_i(n_i, es_i);
    localparam int unsigned EXP_WIDTH_O  = get_exp_width_o(n_o, es_o);
    localparam int unsigned MANT_WIDTH_O = get_mant_width_o(n_o, es_o);
    localparam int unsigned EXP_WIDTH    = get_max_exp_width(n_i, es_i, n_o, es_o);

    // ================= Pipeline 0: 输入寄存器 =================
    logic                                        pipe0_act_sign;
    logic signed [EXP_WIDTH_I:0]                 pipe0_act_rg_exp;
    logic        [MANT_WIDTH_I:0]                pipe0_act_mant;
    logic                                        pipe1_act_sign;
    logic signed [EXP_WIDTH_I:0]                 pipe1_act_rg_exp;
    logic        [MANT_WIDTH_I:0]                pipe1_act_mant;
    logic                                        pipe2_act_sign;
    logic signed [EXP_WIDTH_I:0]                 pipe2_act_rg_exp;
    logic        [MANT_WIDTH_I:0]                pipe2_act_mant;
    

    logic                                        pipe0_wgt_sign;
    logic signed [EXP_WIDTH_I:0]                 pipe0_wgt_rg_exp;
    logic        [MANT_WIDTH_I:0]                pipe0_wgt_mant;

    `FFLARN(pipe0_act_sign,      act_sign_i,         en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_act_rg_exp,    act_rg_exp_i,       en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_act_mant,      act_mant_i,         en_i_1,  0,  clk_i,  rstn_i)

    `FFLARN(pipe1_act_sign,      pipe0_act_sign,     en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_act_rg_exp,    pipe0_act_rg_exp,   en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_act_mant,      pipe0_act_mant,     en_i_2,  0,  clk_i,  rstn_i)

    `FFLARN(pipe2_act_sign,      pipe1_act_sign,     en_i_3,  0,  clk_i,  rstn_i)
    `FFLARN(pipe2_act_rg_exp,    pipe1_act_rg_exp,   en_i_3,  0,  clk_i,  rstn_i)
    `FFLARN(pipe2_act_mant,      pipe1_act_mant,     en_i_3,  0,  clk_i,  rstn_i)

    `FFLARN(pipe0_wgt_sign,      wgt_sign_i,      wgt_en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_wgt_rg_exp,    wgt_rg_exp_i,    wgt_en_i_1,  0,  clk_i,  rstn_i)
    `FFLARN(pipe0_wgt_mant,      wgt_mant_i,      wgt_en_i_1,  0,  clk_i,  rstn_i)

    assign wgt_sign_o   = pipe0_wgt_sign;
    assign wgt_rg_exp_o = pipe0_wgt_rg_exp;
    assign wgt_mant_o   = pipe0_wgt_mant;

    // ================= 组合逻辑：乘法与对齐 =================
    
    // 1. 符号处理
    logic         prod_sign;
    assign prod_sign = pipe0_act_sign ^ pipe0_wgt_sign;

    // 2. 指数加法
    logic signed [EXP_WIDTH:0] rg_exp_prod;
    assign rg_exp_prod = signed'(pipe0_act_rg_exp) + signed'(pipe0_wgt_rg_exp);

    // 3. 尾数乘法 (Booth)
    localparam int unsigned MUL_WIDTH = 2 * (MANT_WIDTH_I + 1);
    logic [MUL_WIDTH-1:0] mul_sum, mul_carry;

    zzc_radix4_booth_multiplier #(
        .WIDTH_A(MANT_WIDTH_I + 1),
        .WIDTH_B(MANT_WIDTH_I + 1)
    ) u_radix4_booth_multiplier (
        .mode(data_mode_i),
        .operand_a(pipe0_act_mant),
        .operand_b(pipe0_wgt_mant),
        .sum_o    (mul_sum),
        .carry_o  (mul_carry)
    );

    // 4. 指数最大值 (即乘积指数本身)
    logic signed [EXP_WIDTH:0] rg_exp_max;
    assign rg_exp_max = rg_exp_prod;

    // 5. Booth 结果合并
    logic [MUL_WIDTH-1:0] mants_prod;
    assign mants_prod = mul_sum + mul_carry;

    // 6. 尾数位宽适配 (保留 ALIGN_WIDTH 逻辑)
    logic [ALIGN_WIDTH-1:0] product_aligned;

    if (ALIGN_WIDTH > MUL_WIDTH) begin
        assign product_aligned = mants_prod << (ALIGN_WIDTH - MUL_WIDTH);
    end
    else begin
        assign product_aligned = mants_prod >> (MUL_WIDTH - ALIGN_WIDTH);
    end

    // 7. 结果直接传递 (移除桶形移位器)
    localparam int unsigned SUM_WIDTH = ALIGN_WIDTH;
    logic [SUM_WIDTH:0] sum_result;
    
    // 符号扩展 (乘积为正，高位补0)
    assign sum_result = {1'b0, product_aligned}; 

    // ================= Pipeline 1: 寄存中间结果 =================
    logic               pipe1_prod_sign;
    logic [SUM_WIDTH:0] pipe1_sum_result;
    logic signed [EXP_WIDTH:0] pipe1_rg_exp_max;
    logic [MUL_WIDTH-1:0] pipe1_mants_prod; // INT 模式：原始有符号乘积

    `FFLARN(pipe1_prod_sign,    prod_sign,      en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_sum_result,   sum_result,     en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_rg_exp_max,   rg_exp_max,     en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_mants_prod,   mants_prod,     en_i_2,  0,  clk_i,  rstn_i)

    // ================= 组合逻辑：归一化与舍入 =================
    logic               final_sign;
    logic [SUM_WIDTH-1:0] sum_c;

    assign final_sign = pipe1_prod_sign;
    assign sum_c      = pipe1_sum_result[SUM_WIDTH-1:0];

    // 尾数归一化
    logic signed [EXP_WIDTH:0] rg_exp_adjust;
    logic signed [EXP_WIDTH:0] final_rg_exp;
    logic [SUM_WIDTH-1:0] sum_norm;

    mantissa_norm #(
        .WIDTH        (SUM_WIDTH),
        .EXP_WIDTH    (EXP_WIDTH),
        .DECIMAL_POINT(2)
    ) u_mantissa_norm (
        .operand_i (sum_c),
        .exp_adjust(rg_exp_adjust),
        .result_o  (sum_norm)
    );

    assign final_rg_exp = pipe1_rg_exp_max + rg_exp_adjust;

    // 舍入逻辑
    logic [MANT_WIDTH_O+2:0] final_mant;

    if (SUM_WIDTH > MANT_WIDTH_O + 3) begin : gen_round_trunc
        logic sticky_bit;
        assign sticky_bit = |sum_norm[SUM_WIDTH-MANT_WIDTH_O-3:0];
        assign final_mant = {sum_norm[SUM_WIDTH-1:SUM_WIDTH-MANT_WIDTH_O-2], sticky_bit};
    end
    else begin : gen_round_pad
        assign final_mant = sum_norm << (MANT_WIDTH_O + 3 - SUM_WIDTH);
    end

    // ================= Pipeline 2: 输出寄存器 =================
    logic                          pipe2_final_sign;
    logic signed [EXP_WIDTH:0]     pipe2_final_rg_exp;
    logic [MANT_WIDTH_O+2:0]       pipe2_final_mant;

    `FFLARN(pipe2_final_sign,   final_sign,   en_i_3, 0, clk_i, rstn_i)
    `FFLARN(pipe2_final_rg_exp, final_rg_exp, en_i_3, 0, clk_i, rstn_i)
    `FFLARN(pipe2_final_mant,   final_mant,   en_i_3, 0, clk_i, rstn_i)

    // ================= 【INT 模式】结果预抽取（旁路 Pipe2，2 周期延迟） =================
    logic signed [MUL_WIDTH-1:0]    int_prod_signed;
    logic        [MANT_WIDTH_O+2:0] int_final_mant_comb;

    assign int_prod_signed     = signed'(pipe1_mants_prod);
    assign int_final_mant_comb = int_prod_signed[MANT_WIDTH_O+2:0];

    // ================= 输出连接 (核心修改：Mux 选择) =================
    assign act_sign_o   = pipe2_act_sign;
    assign act_rg_exp_o = pipe2_act_rg_exp;
    assign act_mant_o   = data_mode_i ? pipe1_act_mant : pipe2_act_mant;

    always_comb begin
        if (data_mode_i) begin
            // INT 模式 (2 周期 Latency)：旁路 Pipe2
            acc_sign_o   = '0;
            acc_rg_exp_o = '0;
            acc_mant_o   = int_final_mant_comb;
        end else begin
            // Posit 模式 (3 周期 Latency)：走 Pipe2
            acc_sign_o   = pipe2_final_sign;
            acc_rg_exp_o = pipe2_final_rg_exp;
            acc_mant_o   = pipe2_final_mant;
        end
    end

endmodule