`include "registers.svh"
import posit_types_pkg::*;

/*
 20260508：
 Posit 全局最大值比较器 (树状二叉归并结构)
 特性：利用Posit编码全局单调特性，直接无符号二进制比较，无encoder/decoder
 结构：纯组合逻辑，二叉树归并，层数 O(log2(INPUT_NUM))
 输入：任意数量的Posit格式数
 输出：全局最大的Posit值
*/
module posit_max #(
    // Posit 位宽
    parameter int unsigned N     = 16,
    // 输入Posit的数量（参数化，可任意配置）
    parameter int unsigned INPUT_NUM = 8
)(
    // 输入：INPUT_NUM 个 N 位 Posit 数据
    input  logic [N-1:0] data_i [INPUT_NUM-1:0],
    // 输出：全局最大值
    output logic [N-1:0] max_o
);

    // ======================================
    // 树状比较器核心参数计算
    // ======================================
    // 补全为 2 的整数次幂（非2^n输入自动填充最小值）
    localparam int unsigned NUM_FULL   = 1 << $clog2(INPUT_NUM);
    // 归并树总层数
    localparam int unsigned TREE_LEVEL = $clog2(NUM_FULL);
    localparam logic [N-1:0] MIN_POSIT = {1'b1, {(N-2){1'b0}}, 1'b1}; //posit格式的最小值，01111……的补码

    // ======================================
    // 树状层级存储数组
    // level[0]    : 输入层（补全后）
    // level[level]：输出层（最大值）
    // ======================================
    logic [N-1:0] level [TREE_LEVEL+1][NUM_FULL-1:0];

    // 输入层初始化：真实输入 + 填充MIN_POSIT
     generate
        for (genvar i = 0; i < NUM_FULL; i++) begin
            if (i < INPUT_NUM) begin
                assign level[0][i] = data_i[i];
            end else begin
                // 填充Posit最小值,不影响最大值比较
                assign level[0][i] = MIN_POSIT;
            end
        end
    endgenerate

    // ======================================
    // 二叉归并树核心：逐层两两比较取大值
    // 纯组合逻辑，并行运算
    // ======================================
    generate
        for (genvar L = 1; L <= TREE_LEVEL; L++) begin : gen_tree_level
            // 当前层节点数 = 上一层 / 2
            for (genvar i = 0; i < NUM_FULL/(1<<L); i++) begin : gen_compare
                // // 左节点
                // logic [N-1:0] left  = level[L-1][2*i];
                // // 右节点
                // logic [N-1:0] right = level[L-1][2*i+1];

                // // Posit单调特性：直接无符号比较，取大值
                // assign level[L][i] = (left > right) ? left : right;
                assign level[L][i] = ( signed'(level[L-1][2*i]) > signed'(level[L-1][2*i+1]) ) ? 
                                     level[L-1][2*i] : level[L-1][2*i+1]; //按照有符号数的规则进行比较
            end
        end
    endgenerate

    // ======================================
    // 树的根节点 = 全局最大值
    // ======================================
    assign max_o = level[TREE_LEVEL][0];

endmodule