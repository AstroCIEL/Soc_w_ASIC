/*
 * 改进版 PDPU 内核：无编解码 (No Encoder/Decoder)
 * 功能：接收解码后的 Posit 分量，完成乘累加计算，输出待编码的 Posit 分量
 * 适用场景：Weight Stationary 脉动阵列内部 PE，消除中间舍入误差
 * 【时序优化版】逻辑重平衡：拆分Pipe0→Pipe1长路径，平衡两级组合逻辑延迟
 * 【纯MAC版本】无Act/Wgt脉动传递逻辑
 */
`include "registers.svh"
import posit_types_pkg::*;

module PE_mac_kernel #(
    parameter int unsigned n_i = 16,                 // 输入Posit字长
    parameter int unsigned es_i = 2,                // 输入指数大小
    parameter int unsigned n_o = 16,                // 输出Posit字长
    parameter int unsigned es_o = 2,                // 输出指数大小
    parameter int unsigned ALIGN_WIDTH = 14         // 对齐位宽
)(
    // 时钟与复位
    input  logic clk_i,
    input  logic rstn_i,
    
    // 流水线使能信号
    input  logic wgt_en_i_1, // weight update控制信号
    input  logic en_i_1, en_i_2, en_i_3, // 计算流水线控制信号

    input  logic data_mode_i, //0=posit, 1=int

    // ================= 输入接口 (解码后的格式 / INT 复用格式) =================
    input  logic                                                     act_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               act_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              act_mant_i,

    input  logic                                                     wgt_sign_i,
    input  logic signed [get_exp_width_i(n_i, es_i):0]               wgt_rg_exp_i,
    input  logic        [get_mant_width_i(n_i, es_i):0]              wgt_mant_i,

    input  logic                                                     acc_sign_i,
    input  logic signed [get_max_exp_width(n_i, es_i, n_o, es_o):0]  acc_rg_exp_i,
    input  logic        [get_mant_width_o(n_o, es_o)+2:0]            acc_mant_i,

    // ================= 输出接口 (待编码的格式 / INT 复用格式) =================
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
    localparam int unsigned MUL_WIDTH    = 2 * (MANT_WIDTH_I + 1);
    localparam int unsigned CARRY_WIDTH  = $clog2(2);
    localparam int unsigned SUM_WIDTH    = ALIGN_WIDTH + CARRY_WIDTH;
    localparam int unsigned SHIFT_WIDTH  = $clog2(ALIGN_WIDTH + 1);

    // ================= 流水线寄存器信号声明 =================
    // ---------- Pipe0: 输入寄存器 ----------
    logic                                        pipe0_act_sign;
    logic signed [EXP_WIDTH_I:0]                 pipe0_act_rg_exp;
    logic        [MANT_WIDTH_I:0]                pipe0_act_mant;
    logic                                        pipe0_wgt_sign;
    logic signed [EXP_WIDTH_I:0]                 pipe0_wgt_rg_exp;
    logic        [MANT_WIDTH_I:0]                pipe0_wgt_mant;
    logic                                        pipe0_acc_sign;
    logic signed [EXP_WIDTH:0]                   pipe0_acc_rg_exp;
    logic        [MANT_WIDTH_O+2:0]              pipe0_acc_mant;

    // ---------- Pipe1: 中间结果寄存器 (优化版，寄存乘法半成品) ----------
    // 乘法结果与指数信息
    logic [MUL_WIDTH-1:0]                        pipe1_mants_prod;
    logic signed [EXP_WIDTH:0]                   pipe1_rg_exp_max;
    logic signed [1:0][EXP_WIDTH:0]              pipe1_rg_exp_diff;
    // 累加器原始输入与符号
    logic                                        pipe1_acc_sign;
    logic        [MANT_WIDTH_O+2:0]              pipe1_acc_mant;
    logic                                        pipe1_signs_ab;

    // ---------- Pipe2: 输出寄存器 ----------
    logic                                        pipe2_final_sign;
    logic signed [EXP_WIDTH:0]                   pipe2_final_rg_exp;
    logic        [MANT_WIDTH_O+2:0]              pipe2_final_mant;

    // ****************************************************************
    // Pipeline 0: 输入寄存 (完全保留原逻辑)
    // ****************************************************************
    `FFLARN(pipe0_act_sign,      act_sign_i,     en_i_1,       0,  clk_i,  rstn_i)
    `FFLARN(pipe0_act_rg_exp,    act_rg_exp_i,   en_i_1,       0,  clk_i,  rstn_i)
    `FFLARN(pipe0_act_mant,      act_mant_i,     en_i_1,       0,  clk_i,  rstn_i)

    `FFLARN(pipe0_wgt_sign,      wgt_sign_i,     wgt_en_i_1,   0,  clk_i,  rstn_i)
    `FFLARN(pipe0_wgt_rg_exp,    wgt_rg_exp_i,   wgt_en_i_1,   0,  clk_i,  rstn_i)
    `FFLARN(pipe0_wgt_mant,      wgt_mant_i,     wgt_en_i_1,   0,  clk_i,  rstn_i)

    `FFLARN(pipe0_acc_sign,      acc_sign_i,     en_i_1,       0,  clk_i,  rstn_i)
    `FFLARN(pipe0_acc_rg_exp,    acc_rg_exp_i,   en_i_1,       0,  clk_i,  rstn_i)
    `FFLARN(pipe0_acc_mant,      acc_mant_i,     en_i_1,       0,  clk_i,  rstn_i)

    // ****************************************************************
    // Pipe0 → Pipe1 组合逻辑 (精简版，仅保留乘法+指数计算)
    // ****************************************************************
    // 1. 符号位计算
    logic         signs_ab;
    assign signs_ab = pipe0_act_sign ^ pipe0_wgt_sign;

    // 2. 乘积指数加法
    logic signed [EXP_WIDTH:0] rg_exp_prod;
    assign rg_exp_prod = signed'(pipe0_act_rg_exp) + signed'(pipe0_wgt_rg_exp);

    // 3. 基4Booth尾数乘法
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

    // 4. 指数比较，找最大值
    logic signed [1:0][EXP_WIDTH:0] rg_exp_items;
    assign rg_exp_items[0] = rg_exp_prod;
    assign rg_exp_items[1] = signed'(pipe0_acc_rg_exp);

    logic signed [EXP_WIDTH:0] rg_exp_max;
    comp_tree #(
        .N    (2),
        .WIDTH(EXP_WIDTH)
    ) u_comp_tree (
        .operands_i(rg_exp_items),
        .result_o  (rg_exp_max)
    );

    // 5. Booth乘法结果合并
    logic [MUL_WIDTH-1:0] mants_prod;
    assign mants_prod = mul_sum + mul_carry;

    // 6. 预计算指数差（移位量）
    logic [1:0][EXP_WIDTH:0] rg_exp_diff;
    generate
        genvar z;
        for (z = 0; z < 2; z++) begin
            assign rg_exp_diff[z] = unsigned'(rg_exp_max - rg_exp_items[z]);
        end
    endgenerate

    // ****************************************************************
    // Pipeline 1: 中间结果寄存 (优化版)
    // ****************************************************************
    // 乘法结果与指数信息寄存
    `FFLARN(pipe1_mants_prod,    mants_prod,         en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_rg_exp_max,    rg_exp_max,         en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_rg_exp_diff[0],rg_exp_diff[0],     en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_rg_exp_diff[1],rg_exp_diff[1],     en_i_2,  0,  clk_i,  rstn_i)

    // 累加器原始输入与符号寄存
    `FFLARN(pipe1_acc_sign,      pipe0_acc_sign,     en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_acc_mant,      pipe0_acc_mant,     en_i_2,  0,  clk_i,  rstn_i)
    `FFLARN(pipe1_signs_ab,      signs_ab,           en_i_2,  0,  clk_i,  rstn_i)

    // ****************************************************************
    // Pipe1 → Pipe2 组合逻辑 (增强版，原长路径拆分至此)
    // ****************************************************************
    // 1. 尾数位宽适配与对齐
    logic [1:0][ALIGN_WIDTH-1:0] product;
    logic [1:0][ALIGN_WIDTH-1:0] product_shifted;
    logic [1:0][SHIFT_WIDTH-1:0] shift_amount;

    // 乘积位宽适配
    if (ALIGN_WIDTH > MUL_WIDTH) begin
        assign product[0] = pipe1_mants_prod << (ALIGN_WIDTH - MUL_WIDTH);
    end
    else begin
        assign product[0] = pipe1_mants_prod >> (MUL_WIDTH - ALIGN_WIDTH);
    end

    // 累加值位宽适配
    if (ALIGN_WIDTH > (MANT_WIDTH_O+2) + 2) begin
        assign product[1] = pipe1_acc_mant << (ALIGN_WIDTH - (MANT_WIDTH_O+2) - 2);
    end
    else begin
        assign product[1] = pipe1_acc_mant >> ((MANT_WIDTH_O+2) + 2 - ALIGN_WIDTH);
    end

    // 2. 桶形移位器指数对齐
    generate
        genvar s;
        if (EXP_WIDTH + 1 > SHIFT_WIDTH) begin : gen_shift_limited
            for (s = 0; s < 2; s++) begin
                assign shift_amount[s] = (|pipe1_rg_exp_diff[s][EXP_WIDTH:SHIFT_WIDTH]) ? ALIGN_WIDTH : pipe1_rg_exp_diff[s][SHIFT_WIDTH-1:0];
                barrel_shifter #(
                    .WIDTH      (ALIGN_WIDTH),
                    .SHIFT_WIDTH(SHIFT_WIDTH),
                    .MODE       (1'b1)
                ) u_barrel_shifter (
                    .operand_i   (product[s]),
                    .shift_amount(shift_amount[s]),
                    .result_o    (product_shifted[s])
                );
            end
        end
        else begin : gen_shift_direct
            for (s = 0; s < 2; s++) begin
                barrel_shifter #(
                    .WIDTH      (ALIGN_WIDTH),
                    .SHIFT_WIDTH(EXP_WIDTH + 1),
                    .MODE       (1'b1)
                ) u_barrel_shifter (
                    .operand_i   (product[s]),
                    .shift_amount(pipe1_rg_exp_diff[s]),
                    .result_o    (product_shifted[s])
                );
            end
        end
    endgenerate

    // 3. 补码转换与CSA树累加
    logic [1:0][SUM_WIDTH:0] mantissa, mantissa_comp;
    logic [1:0]               signs_delayed;
    assign signs_delayed = {pipe1_acc_sign, pipe1_signs_ab};

    generate
        genvar y;
        for (y = 0; y < 2; y++) begin
            assign mantissa[y]      = product_shifted[y];
            assign mantissa_comp[y] = signs_delayed[y] ? (~mantissa[y] + 1'b1) : mantissa[y];
        end
    endgenerate

    logic [SUM_WIDTH:0] csa_sum, csa_carry;
    assign csa_sum = mantissa_comp[0];
    assign csa_carry = mantissa_comp[1];

    // ---------- 【INT 模式】操作数准备 (显式符号扩展) ----------
    logic signed [SUM_WIDTH:0] int_op_a;
    logic signed [SUM_WIDTH:0] int_op_b;

    // 对乘法结果 (pipe1_mants_prod) 进行符号扩展
    always_comb begin
        int_op_a = signed'(pipe1_mants_prod[SUM_WIDTH:0]);
    end

    // 对累加器输入 (pipe1_acc_mant) 进行符号扩展
    always_comb begin
        int_op_b = '0;
        int_op_b[MANT_WIDTH_O+2:0] = pipe1_acc_mant[MANT_WIDTH_O+2:0];
        if (pipe1_acc_mant[MANT_WIDTH_O+2]) begin
            int_op_b[SUM_WIDTH:MANT_WIDTH_O+3] = '1;
        end
    end

    // ---------- 【核心 Mux】加法器输入选择 ----------
    logic [SUM_WIDTH:0] adder_a, adder_b;
    logic [SUM_WIDTH:0] adder_result;

    always_comb begin
        if (data_mode_i) begin
            // INT 模式：直接计算 (Product + Acc)
            adder_a = int_op_a;
            adder_b = int_op_b;
        end else begin
            // Posit 模式：原有通路 (CSA Sum + Carry)
            adder_a = csa_sum;
            adder_b = csa_carry;
        end
    end

    // 【共享】唯一的加法器实例
    zzc_adder #(
        .WIDTH_A(SUM_WIDTH + 1),
        .WIDTH_B(SUM_WIDTH + 1),
        .WIDTH_O(SUM_WIDTH + 1)
    ) u_zzc_adder (
        .mode     (data_mode_i),
        .operand_a(adder_a),
        .operand_b(adder_b),
        .sum_o    (adder_result)
    );

    // Posit 通路继续使用 sum_result 别名
    logic [SUM_WIDTH:0] sum_result;
    assign sum_result = adder_result;

    // ****************************************************************
    // 原有归一化+舍入逻辑 (仅修改输入源)
    // ****************************************************************
    // 符号修正与绝对值转换
    logic               final_sign;
    logic [SUM_WIDTH-1:0] sum_c;
    assign final_sign = sum_result[SUM_WIDTH];
    assign sum_c      = final_sign ? (~sum_result + 1'b1) : sum_result[SUM_WIDTH-1:0];

    // 尾数归一化
    logic signed [EXP_WIDTH:0] rg_exp_adjust;
    logic signed [EXP_WIDTH:0] final_rg_exp;
    logic [SUM_WIDTH-1:0] sum_norm;
    mantissa_norm #(
        .WIDTH        (SUM_WIDTH),
        .EXP_WIDTH    (EXP_WIDTH),
        .DECIMAL_POINT(CARRY_WIDTH + 2)
    ) u_mantissa_norm (
        .operand_i (sum_c),
        .exp_adjust(rg_exp_adjust),
        .result_o  (sum_norm)
    );

    // 指数更新
    assign final_rg_exp = pipe1_rg_exp_max + rg_exp_adjust;

    // 舍入与位宽适配
    logic [MANT_WIDTH_O+2:0] final_mant;
    if (SUM_WIDTH > MANT_WIDTH_O + 3) begin : gen_round_trunc
        logic sticky_bit;
        assign sticky_bit = |sum_norm[SUM_WIDTH-MANT_WIDTH_O-3:0];
        assign final_mant = {sum_norm[SUM_WIDTH-1:SUM_WIDTH-MANT_WIDTH_O-2], sticky_bit};
    end
    else begin : gen_round_pad
        assign final_mant = sum_norm << (MANT_WIDTH_O + 3 - SUM_WIDTH);
    end

    // ****************************************************************
    // Pipeline 2: 输出寄存器
    // ****************************************************************
    `FFLARN(pipe2_final_sign,    final_sign,          en_i_3,  0,  clk_i,  rstn_i)
    `FFLARN(pipe2_final_rg_exp,  final_rg_exp,        en_i_3,  0,  clk_i,  rstn_i)
    `FFLARN(pipe2_final_mant,    final_mant,          en_i_3,  0,  clk_i,  rstn_i)

    // ****************************************************************
    // 【INT 模式】结果预抽取（旁路 Pipe2，2 周期延迟）
    // ****************************************************************
    logic signed [SUM_WIDTH:0]   adder_result_signed;
    logic        [MANT_WIDTH_O+2:0] int_final_mant_comb;

    assign adder_result_signed = signed'(adder_result);
    assign int_final_mant_comb = adder_result_signed[MANT_WIDTH_O+2:0];

    // ****************************************************************
    // 输出端口连接 (核心修改：最终 Mux 选择)
    // ****************************************************************
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