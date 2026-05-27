//现在完全不需要cordic模块，因此相关代码全部注释掉
module sfu_top_no_ctrl #(
    parameter int unsigned LANES       = 64,
    parameter int unsigned POSIT_N     = 16,
    parameter int unsigned POSIT_ES    = 2,
    parameter int unsigned RAND_N      = 16,
    parameter int unsigned ALIGN_WIDTH = 32,
    parameter int unsigned NUM_ITER    = 7
)(
    input  logic                     clk_i,
    input  logic                     rstn_i,
    input  logic                     start_i,
    input  logic                     seed_load_i,
    input  logic [1:0]               sel_i,
    output logic                     done_o,

    input  logic [POSIT_N-1:0]       data_i      [LANES-1:0],
    input  logic [63:0]              seed_high_i [LANES-1:0],
    input  logic [63:0]              seed_low_i  [LANES-1:0],

    output logic [POSIT_N-1:0]       result0_o   [LANES-1:0],
    output logic [POSIT_N-1:0]       result1_o   [LANES-1:0]
);



    // localparam logic [1:0] SEL_CORDIC = 2'd0;

//这里实际上只剩下两个状态，但是为了保持最小改动，不把位宽减少。
    localparam logic  [1:0] SEL_RNG    = 2'd1;
    localparam logic  [1:0] SEL_ITP    = 2'd2;
    localparam int unsigned RNG_COPY_WIDTH = (RAND_N < POSIT_N) ? RAND_N : POSIT_N;
    localparam int unsigned RNG_PAD_WIDTH  = (POSIT_N > RAND_N) ? (POSIT_N - RAND_N) : 0;
    localparam int unsigned ITP_COPY_WIDTH = (POSIT_N < RAND_N) ? POSIT_N : RAND_N;
    localparam int unsigned ITP_PAD_WIDTH  = (RAND_N > POSIT_N) ? (RAND_N - POSIT_N) : 0;

    // logic cordic_start;
    logic rng_next;
    logic itp_active;

    logic [1:0] op_sel_q;
    logic rng_done_q;
    logic itp_done_q;

    // logic [LANES-1:0] cordic_done;

    // logic [POSIT_N-1:0] cordic_sin [LANES-1:0];
    // logic [POSIT_N-1:0] cordic_cos [LANES-1:0];
    logic [RAND_N-1:0]  rng_u1     [LANES-1:0];
    logic [RAND_N-1:0]  rng_u2     [LANES-1:0];
    logic [RAND_N-1:0]  itp_int    [LANES-1:0];
    logic [POSIT_N-1:0] itp_posit  [LANES-1:0];

    // assign cordic_start = start_i && (sel_i == SEL_CORDIC);
    assign rng_next     = start_i && (sel_i == SEL_RNG);
    assign itp_active   = start_i && (sel_i == SEL_ITP);

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // op_sel_q   <= SEL_CORDIC;
            rng_done_q <= 1'b0;
            itp_done_q <= 1'b0;
        end else begin
            if (start_i) begin
                op_sel_q <= sel_i;
            end
            rng_done_q <= rng_next;
            itp_done_q <= itp_active;
        end
    end

    always_comb begin
        unique case (op_sel_q)
            // SEL_CORDIC: done_o = &cordic_done;
            SEL_RNG:    done_o = rng_done_q;
            SEL_ITP:    done_o = itp_done_q;
            default:    done_o = 1'b0;
        endcase
    end

    generate
        for (genvar lane = 0; lane < LANES; lane++) begin : sfu_lane_gen
            if (RAND_N > POSIT_N) begin : gen_itp_int_extend
                assign itp_int[lane] = {{ITP_PAD_WIDTH{1'b0}}, data_i[lane]};
            end else begin : gen_itp_int_truncate
                assign itp_int[lane] = data_i[lane][RAND_N-1:0];
            end

            // cordic_sin_cos #(
            //     .n_i         (POSIT_N),
            //     .es_i        (POSIT_ES),
            //     .n_o         (POSIT_N),
            //     .es_o        (POSIT_ES),
            //     .ALIGN_WIDTH (ALIGN_WIDTH),
            //     .NUM_ITER    (NUM_ITER)
            // ) u_cordic_sin_cos (
            //     .clk_i        (clk_i),
            //     .rstn_i       (rstn_i),
            //     .calc_start_i (cordic_start),
            //     .calc_done_o  (cordic_done[lane]),
            //     .theta_i      (data_i[lane]),
            //     .sin_o        (cordic_sin[lane]),
            //     .cos_o        (cordic_cos[lane])
            // );

            xoroshiro128_plus #(
                .N (RAND_N)
            ) u_xoroshiro128_plus (
                .clk_i       (clk_i),
                .rstn_i      (rstn_i),
                .SEED_HIGH   (seed_high_i[lane]),
                .SEED_LOW    (seed_low_i[lane]),
                .seed_load_i (seed_load_i),
                .next_i      (rng_next),
                .u1_o        (rng_u1[lane]),
                .u2_o        (rng_u2[lane])
            );

            int_to_posit #(
                .N  (RAND_N),
                .n  (POSIT_N),
                .es (POSIT_ES)
            ) u_int_to_posit (
                .clk_i   (clk_i),
                .rstn_i  (rstn_i),
                .int_i   (itp_int[lane]),
                .posit_o (itp_posit[lane])
            );

            always_comb begin
                unique case (op_sel_q)
                    // SEL_CORDIC: begin
                    //     result0_o[lane] = cordic_sin[lane];
                    //     result1_o[lane] = cordic_cos[lane];
                    // end
                    SEL_RNG: begin
                        result0_o[lane] = '0;
                        result1_o[lane] = '0;
                        result0_o[lane][RNG_COPY_WIDTH-1:0] = rng_u1[lane][RNG_COPY_WIDTH-1:0];
                        result1_o[lane][RNG_COPY_WIDTH-1:0] = rng_u2[lane][RNG_COPY_WIDTH-1:0];
                    end
                    SEL_ITP: begin
                        result0_o[lane] = itp_posit[lane];
                        result1_o[lane] = '0;
                    end
                    default: begin
                        result0_o[lane] = '0;
                        result1_o[lane] = '0;
                    end
                endcase
            end
        end
    endgenerate

endmodule
