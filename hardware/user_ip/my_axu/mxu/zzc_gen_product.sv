// Generate partial product according to radix-4 booth encoding result.
// mode=0: unsigned — zero-extend multiplicand, one's-complement negate, sign = neg
// mode=1: signed  — sign-extend multiplicand, one's-complement negate, sign = neg
// Both modes use one's-complement negation to avoid overflow of the minimum signed value.
// The +1 correction (sign) is accumulated by the caller (zzc_gen_prods).
module zzc_gen_product #(
    parameter int unsigned WIDTH = 16
)(
    input  logic             mode,         // 0=unsigned, 1=signed
    input  logic [WIDTH-1:0] multiplicand,
    input  logic [2:0]       code,
    output logic [WIDTH:0]   partial_prod,
    output logic             sign
);
    logic neg, zero, one, two;
    zzc_booth_encoder u_booth_encoder(
        .code(code),
        .neg (neg),
        .zero(zero),
        .one (one),
        .two (two)
    );

    logic [WIDTH:0] temp_prod;
    always_comb begin
        if (one) begin
            // unsigned: zero-extend; signed: sign-extend
            temp_prod = mode ? {multiplicand[WIDTH-1], multiplicand}
                             : {1'b0,                  multiplicand};
        end else if (two) begin
            // unsigned: {A,0}; signed: arithmetic left-shift (preserve sign bit)
            temp_prod = mode ? {multiplicand[WIDTH-1], multiplicand[WIDTH-2:0], 1'b0}
                             : {multiplicand, 1'b0};
        end else begin
            temp_prod = '0;
        end
    end

    // Both modes use one's-complement negate; the +1 correction is accumulated
    // externally via `sign`.  This avoids 17-bit overflow when negating the
    // minimum signed value (-2^WIDTH or -2^(WIDTH+1)), e.g. A=-32768 with two=1
    // would overflow if we computed (~temp + 1) in WIDTH+1 bits.
    assign partial_prod = neg ? ~temp_prod : temp_prod;
    assign sign         = neg;
endmodule
