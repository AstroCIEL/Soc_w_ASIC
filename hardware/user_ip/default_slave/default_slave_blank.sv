module default_slave #(
    parameter logic [63:0] IRQ_SET_OFFSET = 64'h0000_0000,
    parameter logic [63:0] IRQ_ACK_OFFSET = 64'h0000_0010 
) (
    input  logic        clk_i,
    input  logic        rst,

    // 接收总线请求
    input  logic        axi_req,
    input  logic        axi_we,
    input  logic [63:0] axi_addr,
    input  logic [63:0] axi_wdata,
    
    // 必须有确定的输出响应，防止总线悬空卡死
    output logic [63:0] axi_rdata,
    output logic        irq_o
);

    // 中断引脚直接拉死为0
    assign irq_o = 1'b0;

    // 简易的总线响应逻辑：只要有请求，立刻给回确定的数据
    always_ff @(posedge clk_i or posedge rst) begin
        if (rst) begin
            axi_rdata <= 64'h0;
        end else begin
            if (axi_req) begin
                if (axi_we) begin
                    // 写操作：因为是空壳，直接忽略写入的数据，什么都不做
                    axi_rdata <= 64'h0; 
                end else begin
                    // 读操作：返回全 0（或者 0xDEADBEEF 等魔数方便 debug）
                    axi_rdata <= 64'h0123_4567_89AB_89AB; 
                end
            end
        end
    end

endmodule
