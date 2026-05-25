`include "registers.svh"
import posit_types_pkg::*;

/*
 * Posit >= 比较器（纯组合逻辑）
 * 规则：与 posit_max 一致，将 Posit 位模式按有符号数直接比较
 * 输出：1 表示 a_i >= b_i，0 表示 a_i < b_i
 */
module CompareGreaterEqual #(
    parameter int unsigned N = 16
)(
    input  logic [N-1:0] a_i,
    input  logic [N-1:0] b_i,
    output logic         ge_o
);

    assign ge_o = signed'(a_i) >= signed'(b_i);

endmodule
