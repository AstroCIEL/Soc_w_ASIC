// Generate all partial products for zzc_radix4_booth_multiplier.
// mode=0 (unsigned): zero-extend multiplier B, modified sign-extension packing (same as gen_prods).
// mode=1 (signed):   sign-extend multiplier B, per-group true-value computation in WIDTH_A+2 bits,
//                    then sign-extend + shift.  The WIDTH_A+2-bit buffer eliminates overflow when
//                    negating the minimum value (e.g. 2*(-32768) → +65536 needs 18 bits).
module zzc_gen_prods #(
    parameter int unsigned WIDTH_A = 16,
    parameter int unsigned WIDTH_B = 16,
    // do not change
    parameter int unsigned COUNT  = (WIDTH_B+2)/2,      // partial product count (same for both modes)
    parameter int unsigned WIDTH_O = WIDTH_A + WIDTH_B  // output bit-width
)(
    input  logic                            mode,        // 0=unsigned, 1=signed
    input  logic [WIDTH_A-1:0]             operand_a,
    input  logic [WIDTH_B-1:0]             operand_b,
    output logic [COUNT-1:0][WIDTH_O-1:0]  partial_prods
);
    // -----------------------------------------------------------------------
    // Multiplier extension: zero-extend for unsigned, sign-extend for signed.
    // Total width = WIDTH_B + 3 bits [WIDTH_B+2 : 0]
    // -----------------------------------------------------------------------
    logic [WIDTH_B+2:0] multiplier;
    always_comb begin
        if (mode)
            multiplier = {{2{operand_b[WIDTH_B-1]}}, operand_b, 1'b0};
        else
            multiplier = {2'b00, operand_b, 1'b0};
    end

    // -----------------------------------------------------------------------
    // Booth codes and per-group partial products
    // -----------------------------------------------------------------------
    logic [COUNT-1:0][2:0]      codes;
    logic [COUNT-1:0][WIDTH_A:0] temp_prods;   // WIDTH_A+1 bits each
    logic [COUNT-1:0]            signs;         // one's-complement correction bit (= neg, for both modes)

    assign codes[0] = multiplier[2:0];
    zzc_gen_product #(.WIDTH(WIDTH_A)) u0_gen_product (
        .mode        (mode),
        .multiplicand(operand_a),
        .code        (codes[0]),
        .partial_prod(temp_prods[0]),
        .sign        (signs[0])
    );

    generate
        genvar i;
        for (i = 1; i < COUNT-1; i++) begin : g_mid
            assign codes[i] = multiplier[2*i+2 : 2*i];
            zzc_gen_product #(.WIDTH(WIDTH_A)) u_gen_product (
                .mode        (mode),
                .multiplicand(operand_a),
                .code        (codes[i]),
                .partial_prod(temp_prods[i]),
                .sign        (signs[i])
            );
        end
    endgenerate

    assign codes[COUNT-1] = multiplier[2*COUNT : 2*COUNT-2];
    zzc_gen_product #(.WIDTH(WIDTH_A)) ulast_gen_product (
        .mode        (mode),
        .multiplicand(operand_a),
        .code        (codes[COUNT-1]),
        .partial_prod(temp_prods[COUNT-1]),
        .sign        (signs[COUNT-1])
    );

    // -----------------------------------------------------------------------
    // Unsigned packing: modified sign-extension (identical to original gen_prods)
    // -----------------------------------------------------------------------
    logic [COUNT-1:0][WIDTH_O-1:0] pp_u;

    assign pp_u[0] = {{(WIDTH_O-WIDTH_A-4){1'b0}}, ~signs[0], signs[0], signs[0], temp_prods[0]};

    generate
        genvar j;
        for (j = 1; j < COUNT-1; j++) begin : g_pp_u_mid
            assign pp_u[j] = WIDTH_O'({1'b1, ~signs[j], temp_prods[j], 1'b0, signs[j-1]}) << (2*j-2);
        end
    endgenerate

    assign pp_u[COUNT-1] = WIDTH_O'({temp_prods[COUNT-1], 1'b0, signs[COUNT-2]}) << (2*COUNT-4);

    // -----------------------------------------------------------------------
    // Signed packing: one's-complement + correction → true value in WIDTH_A+2 bits.
    //
    // temp_prods[k]  = one's complement of the raw partial product (WIDTH_A+1 bits).
    // signs[k]       = neg_k (the +1 correction needed to obtain two's complement).
    //
    // True value = temp_prods[k] + signs[k].  We first sign-extend temp_prods[k]
    // to WIDTH_A+2 bits (adds one guard bit) before adding signs[k], so the result
    // can never overflow even for the worst case A = -2^(WIDTH_A-1), two=1, neg=1,
    // where one's-complement value = 2^WIDTH_A - 1 and adding 1 gives 2^WIDTH_A,
    // which fits in WIDTH_A+2 bits but NOT in WIDTH_A+1 bits.
    //
    // After obtaining the WIDTH_A+2-bit true value, sign-extend to WIDTH_O bits
    // and shift left by 2*k.  Truncation of bits above WIDTH_O is correct by
    // modular arithmetic (the total sum is guaranteed within WIDTH_O bits).
    // -----------------------------------------------------------------------
    logic [COUNT-1:0][WIDTH_A+1:0] pp_s_ext;  // WIDTH_A+2 bits (true two's-complement value)
    logic [COUNT-1:0][WIDTH_O-1:0] pp_s;

    generate
        genvar k;
        for (k = 0; k < COUNT; k++) begin : g_pp_s
            // Sign-extend temp_prods[k] by 1 bit, then add the 1-bit correction.
            assign pp_s_ext[k] = {{1{temp_prods[k][WIDTH_A]}}, temp_prods[k]}
                                 + {{(WIDTH_A+1){1'b0}}, signs[k]};
            // Sign-extend the WIDTH_A+2-bit true value to WIDTH_O bits, then shift.
            assign pp_s[k] = (WIDTH_O)'({{(WIDTH_O-WIDTH_A-2){pp_s_ext[k][WIDTH_A+1]}},
                                          pp_s_ext[k]}) << (2*k);
        end
    endgenerate

    // -----------------------------------------------------------------------
    // MUX output based on mode
    // -----------------------------------------------------------------------
    generate
        genvar m;
        for (m = 0; m < COUNT; m++) begin : g_mux
            assign partial_prods[m] = mode ? pp_s[m] : pp_u[m];
        end
    endgenerate

endmodule
