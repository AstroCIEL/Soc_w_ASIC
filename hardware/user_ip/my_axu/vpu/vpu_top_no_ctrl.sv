`include "registers.svh"
import posit_types_pkg::*;

module vpu_top_no_ctrl #(
    parameter int unsigned NUM_LANE        = 64,
    parameter int unsigned n               = 16,
    parameter int unsigned es              = 2,
    parameter int unsigned ALIGN_WIDTH     = 14,
    parameter int unsigned ACC_ALIGN_WIDTH = 32
)(
    input  logic         clk_i,
    input  logic         rstn_i,

    input  logic [2:0]   func_sel_i,
    input  logic         start_i,

    input  logic [n-1:0] vec_a_posit_i [NUM_LANE-1:0],
    input  logic [n-1:0] vec_b_posit_i [NUM_LANE-1:0],

    output logic         calc_done_o,
    output logic         busy_o,
    output logic         done_o,

    output logic [n-1:0] vec_result_posit_o [NUM_LANE-1:0],
    output logic [n-1:0] reduction_result_posit_o
);

    localparam logic [2:0] VPU_ADD        = 3'd0;
    localparam logic [2:0] VPU_SUB        = 3'd1;
    localparam logic [2:0] VPU_MUL        = 3'd2;
    localparam logic [2:0] VPU_MAX_EW     = 3'd3;
    localparam logic [2:0] VPU_MIN_EW     = 3'd4;
    localparam logic [2:0] VPU_REDUCE_MAX = 3'd5;
    localparam logic [2:0] VPU_REDUCE_SUM = 3'd6;

    localparam int unsigned EXP_WIDTH_I  = get_exp_width_i(n, es);
    localparam int unsigned MANT_WIDTH_I = get_mant_width_i(n, es);
    localparam int unsigned MAX_EXP_W    = get_max_exp_width(n, es, n, es);
    localparam int unsigned MANT_WIDTH_O = get_mant_width_o(n, es);
    localparam int unsigned NUM_FULL     = 1 << $clog2(NUM_LANE);
    localparam int unsigned REDSUM_LEVEL = $clog2(NUM_FULL);
    localparam int unsigned LAT_REDUCE_SUM = 2 * REDSUM_LEVEL;

    logic [2:0] func_sel_q;
    logic       add_sub_mode_q;
    logic       func_sel_valid;
    logic       accept_start;
    logic       current_done;

    assign func_sel_valid = (func_sel_i <= VPU_REDUCE_SUM);
    assign accept_start   = start_i && func_sel_valid;

    logic                         a_sign   [NUM_LANE-1:0];
    logic signed [EXP_WIDTH_I:0]  a_rg_exp [NUM_LANE-1:0];
    logic        [MANT_WIDTH_I:0] a_mant   [NUM_LANE-1:0];
    logic                         b_sign   [NUM_LANE-1:0];
    logic signed [EXP_WIDTH_I:0]  b_rg_exp [NUM_LANE-1:0];
    logic        [MANT_WIDTH_I:0] b_mant   [NUM_LANE-1:0];

    generate
        for (genvar i = 0; i < NUM_LANE; i++) begin : gen_shared_decoder
            posit_decoder #(
                .n(n),
                .es(es)
            ) u_dec_a (
                .operand_i   (vec_a_posit_i[i]),
                .sign_o      (a_sign[i]),
                .rg_exp_o    (a_rg_exp[i]),
                .mant_norm_o (a_mant[i])
            );

            posit_decoder #(
                .n(n),
                .es(es)
            ) u_dec_b (
                .operand_i   (vec_b_posit_i[i]),
                .sign_o      (b_sign[i]),
                .rg_exp_o    (b_rg_exp[i]),
                .mant_norm_o (b_mant[i])
            );
        end
    endgenerate

    logic addsub_en_1, addsub_en_2, addsub_done;
    logic mult_en_1,   mult_en_2,   mult_done;
    logic cmp_en_1,    cmp_done;
    logic rmax_en_1,   rmax_done;
    logic rsum_start,  rsum_done;
    logic [LAT_REDUCE_SUM-1:0] rsum_valid_q;

    assign addsub_en_1 = accept_start && ((func_sel_i == VPU_ADD) || (func_sel_i == VPU_SUB));
    assign mult_en_1   = accept_start &&  (func_sel_i == VPU_MUL);
    assign cmp_en_1    = accept_start && ((func_sel_i == VPU_MAX_EW) || (func_sel_i == VPU_MIN_EW));
    assign rmax_en_1   = accept_start &&  (func_sel_i == VPU_REDUCE_MAX);
    assign rsum_start  = accept_start &&  (func_sel_i == VPU_REDUCE_SUM);

    `FFARN(addsub_en_2, addsub_en_1, 1'b0, clk_i, rstn_i)
    `FFARN(addsub_done, addsub_en_2, 1'b0, clk_i, rstn_i)
    `FFARN(mult_en_2,   mult_en_1,   1'b0, clk_i, rstn_i)
    `FFARN(mult_done,   mult_en_2,   1'b0, clk_i, rstn_i)
    `FFARN(cmp_done,    cmp_en_1,    1'b0, clk_i, rstn_i)
    `FFARN(rmax_done,   rmax_en_1,   1'b0, clk_i, rstn_i)

    logic                           addsub_sign   [NUM_LANE-1:0];
    logic signed [MAX_EXP_W:0]      addsub_rg_exp [NUM_LANE-1:0];
    logic        [MANT_WIDTH_O+2:0] addsub_mant   [NUM_LANE-1:0];
    logic                           add_sub_mode_kernel;

    assign add_sub_mode_kernel = addsub_en_1 ? (func_sel_i == VPU_SUB) : add_sub_mode_q;

    generate
        for (genvar i = 0; i < NUM_LANE; i++) begin : gen_addsub_kernel
            posit_add_sub_kernel #(
                .n_i         (n),
                .es_i        (es),
                .n_o         (n),
                .es_o        (es),
                .ALIGN_WIDTH (ALIGN_WIDTH)
            ) u_addsub_kernel (
                .clk_i        (clk_i),
                .rstn_i       (rstn_i),
                .en_i_1       (addsub_en_1),
                .en_i_2       (addsub_en_2),
                .add_sub_mode (add_sub_mode_kernel),
                .a_sign_i     (a_sign[i]),
                .a_rg_exp_i   (a_rg_exp[i]),
                .a_mant_i     (a_mant[i]),
                .b_sign_i     (b_sign[i]),
                .b_rg_exp_i   (b_rg_exp[i]),
                .b_mant_i     (b_mant[i]),
                .sum_sign_o   (addsub_sign[i]),
                .sum_rg_exp_o (addsub_rg_exp[i]),
                .sum_mant_o   (addsub_mant[i])
            );
        end
    endgenerate

    logic                           mult_sign   [NUM_LANE-1:0];
    logic signed [MAX_EXP_W:0]      mult_rg_exp [NUM_LANE-1:0];
    logic        [MANT_WIDTH_O+2:0] mult_mant   [NUM_LANE-1:0];

    generate
        for (genvar i = 0; i < NUM_LANE; i++) begin : gen_mult_kernel
            posit_mult_kernel_pipe2 #(
                .n_i         (n),
                .es_i        (es),
                .n_o         (n),
                .es_o        (es),
                .ALIGN_WIDTH (ALIGN_WIDTH)
            ) u_mult_kernel (
                .clk_i      (clk_i),
                .rstn_i     (rstn_i),
                .en_i_1     (mult_en_1),
                .en_i_2     (mult_en_2),
                .a_sign_i   (a_sign[i]),
                .a_rg_exp_i (a_rg_exp[i]),
                .a_mant_i   (a_mant[i]),
                .b_sign_i   (b_sign[i]),
                .b_rg_exp_i (b_rg_exp[i]),
                .b_mant_i   (b_mant[i]),
                .c_sign_o   (mult_sign[i]),
                .c_rg_exp_o (mult_rg_exp[i]),
                .c_mant_o   (mult_mant[i])
            );
        end
    endgenerate

    logic [NUM_LANE-1:0]                          sum_sign_i;
    logic signed [NUM_LANE-1:0][MAX_EXP_W:0]      sum_rg_exp_i;
    logic        [NUM_LANE-1:0][MANT_WIDTH_O+2:0] sum_mant_i;

    generate
        for (genvar i = 0; i < NUM_LANE; i++) begin : gen_sum_input_adapt
            assign sum_sign_i[i]   = a_sign[i];
            assign sum_rg_exp_i[i] = $signed(a_rg_exp[i]);
            if (MANT_WIDTH_O + 3 >= MANT_WIDTH_I + 1) begin : gen_sum_mant_pad
                assign sum_mant_i[i] = {{(MANT_WIDTH_O + 3 - MANT_WIDTH_I - 1){1'b0}}, a_mant[i]};
            end else begin : gen_sum_mant_trunc
                assign sum_mant_i[i] = a_mant[i][MANT_WIDTH_I:MANT_WIDTH_I-MANT_WIDTH_O-2];
            end
        end
    endgenerate

    logic                           rsum_sign;
    logic signed [MAX_EXP_W:0]      rsum_rg_exp;
    logic        [MANT_WIDTH_O+2:0] rsum_mant;
    logic [n-1:0]                   rsum_posit_result;

    posit_sum_kernel #(
        .n_i         (n),
        .es_i        (es),
        .n_o         (n),
        .es_o        (es),
        .ALIGN_WIDTH (ACC_ALIGN_WIDTH),
        .INPUT_NUM   (NUM_LANE)
    ) u_sum_kernel (
        .clk_i        (clk_i),
        .rstn_i       (rstn_i),
        .calc_start_i (rsum_start),
        .calc_done_o  (rsum_done),
        .a_sign_i     (sum_sign_i),
        .a_rg_exp_i   (sum_rg_exp_i),
        .a_mant_i     (sum_mant_i),
        .sum_sign_o   (rsum_sign),
        .sum_rg_exp_o (rsum_rg_exp),
        .sum_mant_o   (rsum_mant)
    );

    logic [n-1:0] cmp_max_comb    [NUM_LANE-1:0];
    logic [n-1:0] cmp_min_comb    [NUM_LANE-1:0];
    logic [n-1:0] cmp_result_q    [NUM_LANE-1:0];
    logic [n-1:0] reduce_max_comb;
    logic [n-1:0] reduce_max_q;

    generate
        for (genvar i = 0; i < NUM_LANE; i++) begin : gen_elementwise_compare
            assign cmp_max_comb[i] = ($signed(vec_a_posit_i[i]) > $signed(vec_b_posit_i[i])) ?
                                     vec_a_posit_i[i] : vec_b_posit_i[i];
            assign cmp_min_comb[i] = ($signed(vec_a_posit_i[i]) < $signed(vec_b_posit_i[i])) ?
                                     vec_a_posit_i[i] : vec_b_posit_i[i];

            always_ff @(posedge clk_i or negedge rstn_i) begin
                if (!rstn_i) begin
                    cmp_result_q[i] <= '0;
                end else if (cmp_en_1) begin
                    cmp_result_q[i] <= (func_sel_i == VPU_MAX_EW) ? cmp_max_comb[i] : cmp_min_comb[i];
                end
            end
        end
    endgenerate

    posit_max #(
        .N         (n),
        .INPUT_NUM (NUM_LANE)
    ) u_reduce_max (
        .data_i (vec_a_posit_i),
        .max_o  (reduce_max_comb)
    );

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            reduce_max_q <= '0;
        end else if (rmax_en_1) begin
            reduce_max_q <= reduce_max_comb;
        end
    end

    logic                           vec_enc_sign   [NUM_LANE-1:0];
    logic signed [MAX_EXP_W:0]      vec_enc_rg_exp [NUM_LANE-1:0];
    logic        [MANT_WIDTH_O+2:0] vec_enc_mant   [NUM_LANE-1:0];
    logic [n-1:0]                   vec_encoded_result [NUM_LANE-1:0];

    generate
        for (genvar i = 0; i < NUM_LANE; i++) begin : gen_vector_encoder
            always_comb begin
                vec_enc_sign[i]   = 1'b0;
                vec_enc_rg_exp[i] = '0;
                vec_enc_mant[i]   = '0;

                unique case (func_sel_q)
                    VPU_ADD, VPU_SUB: begin
                        vec_enc_sign[i]   = addsub_sign[i];
                        vec_enc_rg_exp[i] = addsub_rg_exp[i];
                        vec_enc_mant[i]   = addsub_mant[i];
                    end
                    VPU_MUL: begin
                        vec_enc_sign[i]   = mult_sign[i];
                        vec_enc_rg_exp[i] = mult_rg_exp[i];
                        vec_enc_mant[i]   = mult_mant[i];
                    end
                    default: begin
                        vec_enc_sign[i]   = 1'b0;
                        vec_enc_rg_exp[i] = '0;
                        vec_enc_mant[i]   = '0;
                    end
                endcase
            end

            posit_encoder #(
                .n          (n),
                .es         (es),
                .EXP_WIDTH  (MAX_EXP_W),
                .MANT_WIDTH (MANT_WIDTH_O + 2)
            ) u_vec_encoder (
                .sign_i      (vec_enc_sign[i]),
                .rg_exp_i    (vec_enc_rg_exp[i]),
                .mant_norm_i (vec_enc_mant[i]),
                .result_o    (vec_encoded_result[i])
            );
        end
    endgenerate

    posit_encoder #(
        .n          (n),
        .es         (es),
        .EXP_WIDTH  (MAX_EXP_W),
        .MANT_WIDTH (MANT_WIDTH_O + 2)
    ) u_reduce_sum_encoder (
        .sign_i      (rsum_sign),
        .rg_exp_i    (rsum_rg_exp),
        .mant_norm_i (rsum_mant),
        .result_o    (rsum_posit_result)
    );

    always_comb begin
        unique case (func_sel_q)
            VPU_ADD, VPU_SUB: current_done = addsub_done;
            VPU_MUL:          current_done = mult_done;
            VPU_MAX_EW,
            VPU_MIN_EW:       current_done = cmp_done;
            VPU_REDUCE_MAX:   current_done = rmax_done;
            VPU_REDUCE_SUM:   current_done = rsum_done;
            default:          current_done = 1'b0;
        endcase
    end

    assign calc_done_o = current_done;
    assign done_o      = current_done;
    assign busy_o      = addsub_en_1 || addsub_en_2 || addsub_done ||
                         mult_en_1   || mult_en_2   || mult_done   ||
                         cmp_en_1    || cmp_done    ||
                         rmax_en_1   || rmax_done   ||
                         rsum_start  || (|rsum_valid_q);

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            func_sel_q      <= VPU_ADD;
            add_sub_mode_q  <= 1'b0;
            rsum_valid_q    <= '0;
        end else begin
            rsum_valid_q <= {rsum_valid_q[LAT_REDUCE_SUM-2:0], rsum_start};
            if (accept_start) begin
                func_sel_q     <= func_sel_i;
                add_sub_mode_q <= (func_sel_i == VPU_SUB);
            end
        end
    end

    always_comb begin
        reduction_result_posit_o = '0;
        for (int i = 0; i < NUM_LANE; i++) begin
            vec_result_posit_o[i] = '0;
        end

        unique case (func_sel_q)
            VPU_ADD, VPU_SUB, VPU_MUL: begin
                for (int i = 0; i < NUM_LANE; i++) begin
                    vec_result_posit_o[i] = vec_encoded_result[i];
                end
            end
            VPU_MAX_EW, VPU_MIN_EW: begin
                for (int i = 0; i < NUM_LANE; i++) begin
                    vec_result_posit_o[i] = cmp_result_q[i];
                end
            end
            VPU_REDUCE_MAX: begin
                reduction_result_posit_o = reduce_max_q;
            end
            VPU_REDUCE_SUM: begin
                reduction_result_posit_o = rsum_posit_result;
            end
            default: begin
                reduction_result_posit_o = '0;
                for (int i = 0; i < NUM_LANE; i++) begin
                    vec_result_posit_o[i] = '0;
                end
            end
        endcase
    end

endmodule
