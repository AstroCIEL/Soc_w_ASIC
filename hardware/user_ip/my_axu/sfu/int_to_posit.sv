/*
将生成的在（0，2^N)上均匀分布的N位无符号整数k转换为(0,1)区间内的posit，即将k/(2^N)->posit
思路：由于是正数，sign=0。右移直到全为0，即得到MSB，右移位数-1=posit的rg_exp，被右移出去的位即为mant。 然后输入encoder进行编码。
*/

module int_to_posit #(
    parameter int unsigned N     = 16,     // 输入整数位宽
    parameter int unsigned n     = 16,     // 输出posit位宽（固定16）
    parameter int unsigned es    = 2       // 输出posit es（固定2）
)(
    input  logic             clk_i,
    input  logic             rstn_i,
    // 输入：N位均匀随机整数 (来自xoroshiro128_plus)
    input  logic [N-1:0]     int_i,
    // 输出：编码后的posit16_2 (0,1)区间
    output logic [n-1:0]     posit_o
);

    // ==============================================
    // 本地参数：匹配 posit_encoder 端口
    // ==============================================
    localparam int unsigned nd       = $clog2(n - 1);       // 4 for 16bit
    localparam int unsigned EXP_WIDTH  = nd + es;           // 4+2=6
    localparam int unsigned MANT_WIDTH = n - es - 3;        // 16-2-3=11
    localparam int unsigned FULL_MANT  = MANT_WIDTH + 1;        // 12bit (encoder输入)

    // ==============================================
    // 步骤1：安全处理 → 禁止输入为0 (Box-Muller 要求,有ln函数)
    // ==============================================
    logic [N-1:0] int_norm;
    assign int_norm = (int_i == '0) ? {{N-1{1'b0}}, 1'b1} : int_i;

    // ==============================================
    // 步骤2：找最高有效位MSB的位置 k (0~N-1)
    // ==============================================
    logic [$clog2(N)-1:0] msb_pos;
    logic                  valid;
    // 优先编码器：纯组合逻辑，找最高位1
    always_comb begin
        valid  = 1'b0;
        msb_pos = '0;
        for (int i = N-1; i >= 0; i--) begin
            if (int_norm[i]) begin
                msb_pos = i[$clog2(N)-1:0];
                valid   = 1'b1;
                break;
            end
        end
    end

    // ==============================================
    // 步骤3：归一化 → 提取尾数 (对齐你的encoder要求)
    // ==============================================
    // 左移：把MSB移到最高位，提取有效尾数
    logic [N-1:0] int_shifted;
    assign int_shifted = int_norm << (N - 1 - msb_pos);

    // 取高12位作为encoder的mant_norm输入 (12bit)
    logic [FULL_MANT-1:0] mant_norm;
    assign mant_norm = int_shifted[N-1 -: FULL_MANT];

    // ==============================================
    // 步骤4：计算 regime exponent (核心：rg_exp = k - N)
    // ==============================================
    logic signed [EXP_WIDTH:0] rg_exp;
    localparam int unsigned EXT_WIDTH = EXP_WIDTH + 1 - $clog2(N);
    
    // 零扩展 + 有符号转换（标准SV语法，无报错）
    wire [EXP_WIDTH:0] msb_extended = { {EXT_WIDTH{1'b0}}, msb_pos };
    wire [EXP_WIDTH:0] N_extended   = (EXP_WIDTH+1)'(N);
    
    assign rg_exp = signed'(msb_extended) - signed'(N_extended);
    // ==============================================
    // 步骤5：固定符号位 → 正数 (0)
    // ==============================================
    logic sign;
    assign sign = 1'b0;

    logic sign_q;
    logic signed [EXP_WIDTH:0] rg_exp_q;
    logic [FULL_MANT-1:0] mant_norm_q;

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            sign_q      <= 1'b0;
            rg_exp_q    <= '0;
            mant_norm_q <= '0;
        end else begin
            sign_q      <= sign;
            rg_exp_q    <= rg_exp;
            mant_norm_q <= mant_norm;
        end
    end

    // ==============================================
    // 步骤6：实例化你现成的 posit_encoder (直接对接！)
    // ==============================================
    posit_encoder #(
        .n      (n),
        .es     (es)
    ) u_posit_encoder (
        .sign_i      (sign_q),
        .rg_exp_i    (rg_exp_q),
        .mant_norm_i (mant_norm_q),
        .result_o    (posit_o)
    );

endmodule