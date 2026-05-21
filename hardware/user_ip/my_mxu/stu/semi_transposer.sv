module semi_transposer #(
    parameter DATA_WIDTH    = 16,
    parameter BUFFER_WIDTH  = 16,
    parameter BUFFER_DEPTH  = 16
)(
    input  logic clk_i,
    input  logic rstn_i,

    // 控制信号
    input  logic                  wr_en_i,       // 新增：写使能
    input  logic [3:0]            addr_in_i,     // 新增：输入行地址
    input  logic                  start_putout_i,

    // 数据输入输出
    input  logic [DATA_WIDTH-1:0] data_in  [BUFFER_WIDTH-1:0],
    output logic [DATA_WIDTH-1:0] data_out [BUFFER_WIDTH-1:0],
    output logic                  valid_o,
    output logic [15:0]           wr_done_mask_o // 新增：写入完成指示器
);

// =========================================================================
// 状态定义与内部信号声明
// =========================================================================
typedef enum logic [1:0] {
    IDLE,   // 空闲/可写入状态
    FULL,   // 数据就绪（16行已写满）
    OUTPUT  // 读出中
} state_e;

state_e state_q, state_d;

logic [15:0] wr_done_mask_q, wr_done_mask_d; // 内部写入指示器
logic [3:0]  out_cnt_q, out_cnt_d;            // 输出行计数器 (0~15)

// 存储阵列：16列 x 16行
// col_mem[col_idx][row_idx]
logic [DATA_WIDTH-1:0] col_mem [BUFFER_WIDTH-1:0][BUFFER_DEPTH-1:0];

// 输出端寄存器
logic [DATA_WIDTH-1:0] data_out_q [BUFFER_WIDTH-1:0], data_out_d [BUFFER_WIDTH-1:0];
logic valid_q, valid_d;

// =========================================================================
// 组合逻辑：状态跳转与数据通路计算
// =========================================================================
always_comb begin
    // 默认值保持不变
    state_d         = state_q;
    wr_done_mask_d  = wr_done_mask_q;
    out_cnt_d       = out_cnt_q;
    valid_d         = 1'b0;

    // 输出数据通路默认赋值
    for (int i = 0; i < BUFFER_WIDTH; i++) begin
        data_out_d[i] = data_out_q[i];
    end

    unique case (state_q)
        IDLE: begin
            out_cnt_d = 4'd15;

            // 处理写入逻辑
            if (wr_en_i) begin
                // 标记对应行已写入 (允许覆盖写入)
                wr_done_mask_d = wr_done_mask_q | (16'b1 << addr_in_i);
            end

            // 检查是否写满 (Mask 全1)
            // 注意：如果当前周期正在写入最后一行，wr_done_mask_d 已经更新
            if (&wr_done_mask_d) begin
                state_d = FULL;
            end
        end

        FULL: begin
            // 在此状态下，忽略 wr_en_i，防止数据被破坏
            // 等待输出命令
            if (start_putout_i) begin
                state_d = OUTPUT;
            end
        end

        OUTPUT: begin
            // 核心置换逻辑：读取存储阵列
            for (int i = 0; i < BUFFER_WIDTH; i++) begin
                // 利用位宽自动截断实现 (out_cnt + i) % 16
                data_out_d[i] = col_mem[i][out_cnt_q + 4'(i)];
            end
            
            valid_d   = 1'b1;
            out_cnt_d = out_cnt_q - 1'b1;

            if (out_cnt_q == 4'd0) begin
                state_d         = IDLE;
                wr_done_mask_d  = '0; // 清空指示器，准备下一轮写入
            end
        end

        default:;
    endcase
end

// =========================================================================
// 时序逻辑：状态更新、寄存器堆写入
// =========================================================================
always_ff @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        state_q         <= IDLE;
        wr_done_mask_q  <= '0;
        out_cnt_q       <= '0;
        valid_q         <= 1'b0;
        
        // 复位输出数据
        for (int i = 0; i < BUFFER_WIDTH; i++) begin
            data_out_q[i] <= '0;
        end
    end else begin
        state_q         <= state_d;
        wr_done_mask_q  <= wr_done_mask_d;
        out_cnt_q       <= out_cnt_d;
        valid_q         <= valid_d;
        data_out_q      <= data_out_d;

        // =================================================================
        // 写入逻辑：仅在 IDLE 状态且 wr_en_i 有效时写入
        // =================================================================
        if (wr_en_i && (state_q == IDLE)) begin
            for (int i = 0; i < BUFFER_WIDTH; i++) begin
                // data_in[i] 写入第 i 列
                // addr_in_i 指定写入哪一行
                col_mem[i][addr_in_i] <= data_in[i];
            end
        end
    end
end

// =========================================================================
// 输出连接
// =========================================================================
assign data_out      = data_out_q;
assign valid_o       = valid_q;
assign wr_done_mask_o = wr_done_mask_q;

endmodule