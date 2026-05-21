module rotator #(
    parameter WIDTH = 128  // 数据位宽，默认128bit
) (
    input  logic             clk,       // 时钟
    input  logic             rst_n,     // 异步低电平复位
    input  logic             in_valid,  // 输入数据有效信号（高电平有效）
    input  logic [WIDTH-1:0] A, B, C, D,// 四个输入数据
    input  logic [1:0]       sel,       // 旋转选择：00=ABCD, 01=BCDA, 10=CDAB, 11=DABC
    output logic             out_valid, // 输出数据有效信号（比in_valid晚一拍）
    output logic [WIDTH-1:0] out1, out2, out3, out4 // 寄存器输出
);

// 内部组合逻辑变量
logic [WIDTH-1:0] next_out1, next_out2, next_out3, next_out4;

// ---------------------------
// 组合逻辑：根据sel选择旋转模式
// ---------------------------
always_comb begin
    case (sel)
        2'b00: {next_out1, next_out2, next_out3, next_out4} = {A, B, C, D};
        2'b01: {next_out1, next_out2, next_out3, next_out4} = {B, C, D, A};
        2'b10: {next_out1, next_out2, next_out3, next_out4} = {C, D, A, B};
        2'b11: {next_out1, next_out2, next_out3, next_out4} = {D, A, B, C};
        default: {next_out1, next_out2, next_out3, next_out4} = {A, B, C, D};
    endcase
end

// ---------------------------
// 时序逻辑：寄存器输出 + 有效信号同步
// ---------------------------
always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        out1      <= '0;
        out2      <= '0;
        out3      <= '0;
        out4      <= '0;
        out_valid <= '0;
    end else begin
        // 数据通路：无论是否valid都更新（若需低功耗可加使能）
        out1 <= next_out1;
        out2 <= next_out2;
        out3 <= next_out3;
        out4 <= next_out4;
        // 有效信号：打一拍同步
        out_valid <= in_valid;
    end
end

endmodule