import posit_types_pkg::*;

/*
 * Posit16_2 向下取整 (floor)
 * Decoder -> 按 rg_exp 截断尾数小数位 -> Encoder
 *
 * 解码 mant：bit[MANT_WIDTH] 为隐藏 1，bit[MANT_WIDTH-1:0] 为小数位；
 * 小数位中“位权宽于 rg_exp”的低位一律置 0（正数 floor）。
 * 负数若截断产生余数，则向 -inf 方向进 1（尾数加 2^(MANT_WIDTH-rg_exp)）。
 * int_o：5-bit 无符号整数，表示 floor 结果，取值区间 [0, 32)（即 0~31）；
 * 负数 floor 结果输出 0；NaR 输出 0；≥32 饱和为 31。
 */



module posit_floor #(
    parameter int unsigned n  = 16,
    parameter int unsigned es = 2
)(
    input  logic              clk_i,
    input  logic              rstn_i,

    
    input  logic [n-1:0]      posit_i,
    output logic [n-1:0]      posit_o,
    output logic [4:0]        int_o
);

    localparam int unsigned EXP_WIDTH  = get_exp_width_i(n, es);
    localparam int unsigned MANT_WIDTH = get_mant_width_i(n, es);
    localparam int unsigned FULL_MANT  = MANT_WIDTH + 1;
    localparam logic [FULL_MANT-1:0] MANT_ONE = 1'b1 << MANT_WIDTH;

    localparam logic [n-1:0] NAR_POSIT = {1'b1, {(n-1){1'b0}}};

    logic                        sign;
    logic signed [EXP_WIDTH:0]   rg_exp;
    logic        [FULL_MANT-1:0] mant;



    posit_decoder #(
        .n (n),
        .es(es)
    ) u_decoder (
        .operand_i   (posit_i),
        .sign_o      (sign),
        .rg_exp_o    (rg_exp),
        .mant_norm_o (mant)
    );


    logic                        sign_ff;
    logic signed [EXP_WIDTH:0]   rg_exp_ff;
    logic        [FULL_MANT-1:0] mant_ff;
    logic        [n-1:0]         posit_i_ff;

`FFARN(sign_ff,     sign,    1'b0, clk_i, rstn_i)
`FFARN(rg_exp_ff,   rg_exp,  '0,   clk_i, rstn_i)
`FFARN(mant_ff,     mant,    '0,   clk_i, rstn_i)
`FFARN(posit_i_ff,  posit_i, '0,   clk_i, rstn_i)


    logic is_nar;
    logic is_zero;
    logic signed [EXP_WIDTH:0] frac_bits_s;
    logic                      frac_valid;
    logic [MANT_WIDTH-1:0]     frac_mask;
    logic [MANT_WIDTH-1:0]     rem;
    logic [FULL_MANT-1:0]      mant_cleared;
    logic [FULL_MANT:0]        mant_wide;
    logic                      floor_to_neg_one;

    assign is_nar       = (posit_i_ff == NAR_POSIT);
    assign is_zero      = ~mant_ff[MANT_WIDTH];
    assign frac_bits_s  = MANT_WIDTH - rg_exp_ff;
    assign frac_valid   = (rg_exp_ff >= 0) && (rg_exp_ff < MANT_WIDTH);

    always_comb begin
        if (frac_valid)
            frac_mask = (1'b1 << FULL_MANT'(frac_bits_s)) - 1;
        else if (rg_exp_ff < 0)
            frac_mask = {MANT_WIDTH{1'b1}};
        else
            frac_mask = {MANT_WIDTH{1'b0}};
    end

    assign rem          = mant_ff[MANT_WIDTH-1:0] & frac_mask;
    assign mant_cleared = {mant_ff[MANT_WIDTH], mant_ff[MANT_WIDTH-1:0] & ~frac_mask};

    always_comb begin
        if (frac_valid && sign_ff && |rem)
            mant_wide = {1'b0, mant_cleared} + (FULL_MANT'(1'b1) << FULL_MANT'(frac_bits_s));
        else
            mant_wide = {1'b0, mant_cleared};
    end

  // |x| < 1 的负数：截断后需落到 -1
    assign floor_to_neg_one = sign_ff && !is_zero && (rg_exp_ff < 0) && (mant_wide == '0);

    logic                      floor_sign;
    logic signed [EXP_WIDTH:0] floor_rg_exp;
    logic [FULL_MANT-1:0]      floor_mant;

    always_comb begin
        if (is_zero || (mant_wide == '0 && !floor_to_neg_one) ||
            (!sign_ff && (rg_exp_ff < 0))) begin
            floor_sign   = 1'b0;
            floor_rg_exp = '0;
            floor_mant   = '0;
        end else if (floor_to_neg_one) begin
            floor_sign   = 1'b1;
            floor_rg_exp = '0;
            floor_mant   = MANT_ONE;
        end else begin
            floor_sign   = sign_ff;
            floor_rg_exp = rg_exp_ff;
            floor_mant   = mant_wide[FULL_MANT-1:0];
        end
    end

    logic [n-1:0] encoded_o;

    posit_encoder #(
        .n (n),
        .es(es)
    ) u_encoder (
        .sign_i      (floor_sign),
        .rg_exp_i    (floor_rg_exp),
        .mant_norm_i (floor_mant),
        .result_o    (encoded_o)
    );

    assign posit_o = is_nar ? posit_i_ff : encoded_o;

    // ======================================
    // 5-bit 无符号整数输出，取值 [0, 32) -> 0~31
    // 幅值：mant * 2^(rg_exp - MANT_WIDTH)，仅非负 floor 结果有效
    // ======================================
    localparam int unsigned INT_WIDTH     = 5;
    localparam int unsigned INT_MAG_WIDTH = FULL_MANT + EXP_WIDTH + 1;
    localparam int unsigned INT_MAX       = (1 << INT_WIDTH) - 1; // 31

    logic [INT_MAG_WIDTH-1:0] int_mag_u;
    logic [INT_WIDTH-1:0]     int_sat;

    always_comb begin
        int_mag_u = '0;
        if (!is_nar && !floor_sign && floor_mant[MANT_WIDTH]) begin
            if (floor_rg_exp >= MANT_WIDTH)
                int_mag_u = floor_mant << (floor_rg_exp - MANT_WIDTH);
            else if (floor_rg_exp >= 0)
                int_mag_u = floor_mant >> (MANT_WIDTH - floor_rg_exp);
        end
    end

    always_comb begin
        if (is_nar || floor_sign)
            int_sat = '0;
        else if (int_mag_u >= (INT_MAX + 1))
            int_sat = INT_MAX;
        else
            int_sat = int_mag_u[INT_WIDTH-1:0];
    end

    assign int_o = int_sat;

endmodule
