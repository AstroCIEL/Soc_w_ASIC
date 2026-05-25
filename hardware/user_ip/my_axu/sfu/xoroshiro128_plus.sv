/*
0403 longxin：生成在(0,2^n)内平均分布的整数，用于boxmuller生成高斯分布。
*/

module xoroshiro128_plus #(
    parameter  int unsigned N = 16  // 输出N位随机数，和转换器一致
)(
    input  logic clk_i,
    input  logic rstn_i,
    input  logic [63:0] SEED_HIGH,
    input  logic [63:0] SEED_LOW,
    input  logic seed_load_i,
    input  logic next_i,
    output logic [N-1:0] u1_o,  // 随机数1
    output logic [N-1:0] u2_o   // 随机数2
);

    logic [63:0] s0_reg, s1_reg;
    logic [63:0] s0_next, s1_next;
    logic [63:0] result_next;

    function automatic [63:0] rotl(input [63:0] x, input [5:0] k);
        return ((x << k) | (x >> (64 - k))) & 64'hFFFFFFFFFFFFFFFF;
    endfunction

    always_comb begin
        result_next = (s0_reg + s1_reg) & 64'hFFFFFFFFFFFFFFFF;
        //下面限制不能为0是为了后续输入ln
        if (result_next == 64'h0) result_next = 64'h1;

        s1_next = s1_reg ^ s0_reg;
        s0_next = (rotl(s0_reg, 24) ^ s1_next ^ (s1_next << 16)) & 64'hFFFFFFFFFFFFFFFF;
        s1_next = rotl(s1_next, 37);
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            s0_reg <= SEED_HIGH;
            s1_reg <= SEED_LOW;
            u1_o <= '0;
            u2_o <= '0;
        end else if (seed_load_i) begin
            s0_reg <= SEED_HIGH;
            s1_reg <= SEED_LOW;
            u1_o <= '0;
            u2_o <= '0;
        end else if (next_i) begin
            s0_reg <= s0_next;
            s1_reg <= s1_next;
            // u1_o <= result_next[63 -: N];  // 取高N位
            // u2_o <= result_next[63-N -: N]; // 
            //对齐python软件的逻辑
            u2_o <= result_next[N-1:0];  // 取低N位
            u1_o <= result_next[2*N-1:N]; // 取次低N位
        end
    end
endmodule