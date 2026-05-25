module zzc_adder #(
    parameter int unsigned WIDTH_A = 16,
    parameter int unsigned WIDTH_B = 16,
    parameter int unsigned WIDTH_O = 16
)(
    input  logic                    mode,      // 0=无符号加法, 1=有符号加法
    input  logic [WIDTH_A-1:0]      operand_a,
    input  logic [WIDTH_B-1:0]      operand_b,
    output logic [WIDTH_O-1:0]      sum_o
);

    // 计算内部计算位宽：取输入最大位宽与输出位宽中的最大值
    localparam int unsigned MAX_IN = (WIDTH_A > WIDTH_B) ? WIDTH_A : WIDTH_B;
    localparam int unsigned C      = (MAX_IN > WIDTH_O) ? MAX_IN : WIDTH_O;

    logic        [C-1:0] a_ext_u, b_ext_u;      // 无符号扩展操作数
    logic signed [C-1:0] a_ext_s, b_ext_s;      // 有符号扩展操作数
    logic        [C-1:0] sum_int;               // 内部和

    // 无符号扩展（高位补0），直接赋值即可
    assign a_ext_u = operand_a;
    assign b_ext_u = operand_b;

    // 有符号扩展（符号扩展），$signed 再赋给更宽的 signed 向量会自动扩展符号位
    assign a_ext_s = $signed(operand_a);
    assign b_ext_s = $signed(operand_b);

    // 根据 mode 选择有符号或无符号加法，结果存入无符号向量以保留原始位模式
    always_comb begin
        if (mode)
            sum_int = a_ext_s + b_ext_s;
        else
            sum_int = a_ext_u + b_ext_u;
    end

    // 输出截取低 WIDTH_O 位
    assign sum_o = sum_int[WIDTH_O-1:0];

endmodule