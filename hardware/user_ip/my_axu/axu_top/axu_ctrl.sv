module axu_ctrl #(
    parameter int unsigned NUM_LANE       = 64,
    parameter int unsigned ELEM_WIDTH     = 16,
    parameter int unsigned BANK_WIDTH     = 128,
    parameter int unsigned BANK_NUM       = (NUM_LANE * ELEM_WIDTH) / BANK_WIDTH,
    parameter int unsigned ADDR_WIDTH     = 8,
    parameter int unsigned CFG_ADDR_WIDTH = 4,
    parameter int unsigned SFU_LANE       = NUM_LANE / 2,
    parameter int unsigned SFU_NUM_ITER   = 7,
    parameter int unsigned NLI_NUM_LANES  = SFU_LANE,
    parameter int unsigned NLI_NUM_MACROS = 10,
    parameter int unsigned NLI_NUM_MICROS = 32
) (
    input  logic clk_i,
    input  logic rstn_i,

    input  logic                        cfg_set_i,
    input  logic [CFG_ADDR_WIDTH-1:0]   cfg_addr_i,
    input  logic [ADDR_WIDTH-1:0]       cfg_data_i,
    input  logic                        start_i,

    output logic                        calc_done_o,
    output logic                        busy_o,
    output logic                        done_o,

    output logic [BANK_NUM-1:0]         op_a_buf_cen_o,
    output logic [BANK_NUM-1:0]         op_a_buf_wen_o,
    output logic [ADDR_WIDTH-1:0]       op_a_buf_addr_o [BANK_NUM-1:0],
    input  logic [BANK_WIDTH-1:0]       op_a_buf_dout_i [BANK_NUM-1:0],

    output logic [BANK_NUM-1:0]         op_b_buf_cen_o,
    output logic [BANK_NUM-1:0]         op_b_buf_wen_o,
    output logic [ADDR_WIDTH-1:0]       op_b_buf_addr_o [BANK_NUM-1:0],
    input  logic [BANK_WIDTH-1:0]       op_b_buf_dout_i [BANK_NUM-1:0],

    output logic [BANK_NUM-1:0]         out_buf_cen_o,
    output logic [BANK_NUM-1:0]         out_buf_wen_o,
    output logic [ADDR_WIDTH-1:0]       out_buf_addr_o  [BANK_NUM-1:0],
    output logic [BANK_WIDTH-1:0]       out_buf_din_o   [BANK_NUM-1:0],

    output logic [2:0]                  vpu_func_sel_o,
    output logic                        vpu_start_o,
    output logic [ELEM_WIDTH-1:0]       vpu_vec_a_posit_o [NUM_LANE-1:0],
    output logic [ELEM_WIDTH-1:0]       vpu_vec_b_posit_o [NUM_LANE-1:0],
    input  logic                        vpu_calc_done_i,
    input  logic                        vpu_busy_i,
    input  logic                        vpu_done_i,
    input  logic [ELEM_WIDTH-1:0]       vpu_vec_result_posit_i [NUM_LANE-1:0],
    input  logic [ELEM_WIDTH-1:0]       vpu_reduction_result_posit_i,

    output logic [1:0]                  sfu_sel_o,
    output logic                        sfu_start_o,
    output logic [ELEM_WIDTH-1:0]       sfu_data_o [SFU_LANE-1:0],
    output logic [63:0]                 sfu_seed_high_o [SFU_LANE-1:0],
    output logic [63:0]                 sfu_seed_low_o [SFU_LANE-1:0],
    input  logic                        sfu_done_i,
    input  logic [ELEM_WIDTH-1:0]       sfu_result0_i [SFU_LANE-1:0],
    input  logic [ELEM_WIDTH-1:0]       sfu_result1_i [SFU_LANE-1:0],
    output logic                        sfu_seed_load_o,

    output logic                              nli_clr_o,
    output logic                              nli_up_valid_o,
    input  logic                              nli_up_ready_i,
    input  logic                              nli_dn_valid_i,
    output logic                              nli_dn_ready_o,
    output logic [ELEM_WIDTH-1:0]             nli_input_data_o  [NLI_NUM_LANES-1:0],
    input  logic [ELEM_WIDTH-1:0]             nli_output_data_i [NLI_NUM_LANES-1:0],
    output logic                              nli_mul_lut_wr_en_o,
    output logic [$clog2(NLI_NUM_MACROS)-1:0] nli_mul_lut_wr_addr_o,
    output logic [ELEM_WIDTH-1:0]             nli_mul_lut_wr_data_o,
    output logic                              nli_y_bounds_lut_wr_en_o,
    output logic [$clog2((NLI_NUM_MACROS-2)*NLI_NUM_MICROS+2)-1:0] nli_y_bounds_lut_wr_addr_o,
    output logic [ELEM_WIDTH-1:0]             nli_y_bounds_lut_wr_data_o,
    output logic [ELEM_WIDTH-1:0]             nli_macro_bounds_o [0:NLI_NUM_MACROS],

    output logic                        sch_start_o,
    output logic                        sch_clear_o,
    output logic [ADDR_WIDTH-1:0]       sch_inbuf_base_o,
    output logic [ADDR_WIDTH-1:0]       sch_obuf_base_o,
    input  logic                        sch_busy_i,
    input  logic                        sch_done_i
);

    localparam int unsigned ELEM_PER_BANK       = BANK_WIDTH / ELEM_WIDTH;
    localparam int unsigned NUM_FULL            = 1 << $clog2(NUM_LANE);
    localparam int unsigned REDSUM_LEVEL        = $clog2(NUM_FULL);
    localparam int unsigned LAT_ADD_SUB         = 2;
    localparam int unsigned LAT_MUL             = 2;
    localparam int unsigned LAT_CMP             = 1;
    localparam int unsigned LAT_REDUCE_MAX      = 1;
    localparam int unsigned LAT_REDUCE_SUM      = 2 * REDSUM_LEVEL;
    localparam int unsigned MAX_LATENCY         = LAT_REDUCE_SUM;
    localparam int unsigned LAT_SFU_ITP         = 1;
    localparam int unsigned LAT_SFU_RNG         = 1;
    // localparam int unsigned LAT_SFU_CORDIC      = 3 * SFU_NUM_ITER;
    localparam int unsigned MAX_SFU_LATENCY     = LAT_SFU_RNG;
    localparam int unsigned SEED_WORD_WIDTH     = 64;
    localparam int unsigned SEED_WORDS_PER_BANK = BANK_WIDTH / SEED_WORD_WIDTH;

    localparam int unsigned NLI_MACRO_IDX_W      = $clog2(NLI_NUM_MACROS);
    localparam int unsigned NLI_Y_BOUNDS_DEPTH   = (NLI_NUM_MACROS-2)*NLI_NUM_MICROS + 2;
    localparam int unsigned NLI_Y_BOUNDS_ENTRIES = NLI_Y_BOUNDS_DEPTH + 1;
    localparam int unsigned NLI_IVAL_IDX_W       = $clog2(NLI_Y_BOUNDS_ENTRIES);
    localparam int unsigned NLI_LUT_CNT_W        = (NLI_IVAL_IDX_W > NLI_MACRO_IDX_W) ?
                                                   (NLI_IVAL_IDX_W + 1) : (NLI_MACRO_IDX_W + 1);
    localparam int unsigned NLI_TOKENS_PER_ROW = BANK_NUM * ELEM_PER_BANK;
    localparam int unsigned NLI_SLOT_W         = (NLI_TOKENS_PER_ROW > 1) ? $clog2(NLI_TOKENS_PER_ROW) : 1;

    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_FUNC_SEL               = CFG_ADDR_WIDTH'(0);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OP_A_BASE_ADDR         = CFG_ADDR_WIDTH'(1);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OP_B_BASE_ADDR         = CFG_ADDR_WIDTH'(2);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_VEC_OUT_BASE_ADDR      = CFG_ADDR_WIDTH'(3);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_REDUCE_OUT_BASE_ADDR   = CFG_ADDR_WIDTH'(4);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_BATCH_SIZE             = CFG_ADDR_WIDTH'(5);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_UNIT_SEL               = CFG_ADDR_WIDTH'(6);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_SFU_SEED_HIGH_BASE_ADDR = CFG_ADDR_WIDTH'(7);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_SFU_SEED_LOW_BASE_ADDR  = CFG_ADDR_WIDTH'(8);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_SFU_SEED_LOAD           = CFG_ADDR_WIDTH'(9);

    localparam logic [1:0] UNIT_VPU = 2'd0;
    localparam logic [1:0] UNIT_SFU = 2'd1;
    localparam logic [1:0] UNIT_NLI = 2'd2;
    localparam logic [1:0] UNIT_SCH = 2'd3;

    localparam logic [2:0] VPU_ADD        = 3'd0;
    localparam logic [2:0] VPU_SUB        = 3'd1;
    localparam logic [2:0] VPU_MUL        = 3'd2;
    localparam logic [2:0] VPU_MAX_EW     = 3'd3;
    localparam logic [2:0] VPU_MIN_EW     = 3'd4;
    localparam logic [2:0] VPU_REDUCE_MAX = 3'd5;
    localparam logic [2:0] VPU_REDUCE_SUM = 3'd6;

    // localparam logic [1:0] SFU_CORDIC = 2'd0;
    localparam logic [1:0] SFU_RNG    = 2'd1;
    localparam logic [1:0] SFU_ITP    = 2'd2;

    localparam logic [2:0] NLI_LOAD_MULT = 3'd0;
    localparam logic [2:0] NLI_LOAD_YBND = 3'd1;
    localparam logic [2:0] NLI_COMPUTE   = 3'd2;

    localparam logic [2:0] SCH_RUN = 3'd0;

    typedef enum logic [4:0] {
        ST_IDLE,
        ST_RUN,
        ST_DRAIN,
        ST_DONE,
        ST_SEED_HIGH_REQ,
        ST_SEED_HIGH_CAP,
        ST_SEED_LOW_REQ,
        ST_SEED_LOW_CAP,
        ST_SEED_APPLY,
        ST_NLI_LUT_REQ,
        ST_NLI_LUT_CAP,
        ST_NLI_LUT_WR,
        ST_NLI_MACRO_REQ,
        ST_NLI_MACRO_CAP,
        ST_NLI_FLUSH,
        ST_NLI_COMPUTE,
        ST_NLI_DRAIN,
        ST_SCH_RUN,
        ST_SCH_WAIT
    } state_e;

    state_e state_q, state_d;

    logic [1:0]              unit_sel_reg;
    logic [2:0]              func_sel_reg;
    logic [ADDR_WIDTH-1:0]   op_a_base_addr_reg;
    logic [ADDR_WIDTH-1:0]   op_b_base_addr_reg;
    logic [ADDR_WIDTH-1:0]   vec_out_base_addr_reg;
    logic [ADDR_WIDTH-1:0]   reduce_out_base_addr_reg;
    logic [ADDR_WIDTH-1:0]   batch_size_reg;
    logic [ADDR_WIDTH-1:0]   sfu_seed_high_base_addr_reg;
    logic [ADDR_WIDTH-1:0]   sfu_seed_low_base_addr_reg;

    logic [ADDR_WIDTH-1:0]   read_cnt_q;
    logic [ADDR_WIDTH-1:0]   launch_cnt_q;
    logic [ADDR_WIDTH-1:0]   write_cnt_q;
    logic [ADDR_WIDTH-1:0]   read_req_batch_q;
    logic [ADDR_WIDTH-1:0]   read_data_batch_q;
    logic [ADDR_WIDTH-1:0]   launch_batch_q;
    logic [ADDR_WIDTH-1:0]   launch_batch;
    logic [ADDR_WIDTH-1:0]   result_batch;
    logic [ADDR_WIDTH-1:0]   read_addr;
    logic [ADDR_WIDTH-1:0]   op_b_read_addr;
    logic [ADDR_WIDTH-1:0]   write_addr;

    logic                    unit_sel_valid;
    logic                    is_vpu_op;
    logic                    is_sfu_op;
    logic                    is_nli_op;
    logic                    is_sch_op;
    logic                    is_nli_load_mult;
    logic                    is_nli_load_ybnd;
    logic                    is_nli_load_lut;
    logic                    is_nli_compute;
    // logic                    is_sfu_cordic;
    logic                    is_sfu_rng;
    logic                    is_sfu_itp;
    logic                    sfu_need_input_read;
    logic                    vpu_func_sel_valid;
    logic                    sfu_func_sel_valid;
    logic                    nli_func_sel_valid;
    logic                    sch_func_sel_valid;
    logic                    func_sel_valid;
    logic                    is_elementwise;
    logic                    is_reduction;
    logic                    need_op_b;
    logic                    write_vector;
    logic                    write_scalar;
    logic                    start_accepted;
    logic                    seed_load_accepted;
    logic                    read_req_fire;
    logic                    read_data_valid_q;
    logic                    launch_valid_q;
    logic                    rng_launch_fire;
    logic                    launch_fire;
    logic                    write_fire;
    logic                    all_read_issued;
    logic                    all_launched;
    logic                    last_write_fire;
    logic                    result_tag_valid;

    logic [MAX_LATENCY-1:0]     tag_valid_q;
    logic [ADDR_WIDTH-1:0]      tag_batch_q [MAX_LATENCY-1:0];
    logic [MAX_SFU_LATENCY-1:0] sfu_tag_valid_q;
    logic [ADDR_WIDTH-1:0]      sfu_tag_batch_q [MAX_SFU_LATENCY-1:0];

    logic [NLI_LUT_CNT_W-1:0]   nli_load_cnt_q;
    logic [NLI_SLOT_W-1:0]      nli_slot_q;
    logic [BANK_NUM*BANK_WIDTH-1:0] nli_row_buf_q;
    logic [ADDR_WIDTH-1:0]      nli_read_cnt_q;
    logic [ADDR_WIDTH-1:0]      nli_write_cnt_q;
    logic                       nli_read_data_valid_q;
    logic                       nli_last_read_q;
    logic                       nli_read_fire;
    logic                       nli_write_fire;
    logic                       nli_last_write_fire;
    logic [BANK_NUM*BANK_WIDTH-1:0] op_b_dout_flat;
    logic [BANK_NUM*BANK_WIDTH-1:0] op_a_dout_flat;

    assign unit_sel_valid      = (unit_sel_reg == UNIT_VPU) || (unit_sel_reg == UNIT_SFU) ||
                                 (unit_sel_reg == UNIT_NLI) || (unit_sel_reg == UNIT_SCH);
    assign is_vpu_op           = (unit_sel_reg == UNIT_VPU);
    assign is_sfu_op           = (unit_sel_reg == UNIT_SFU);
    assign is_nli_op           = (unit_sel_reg == UNIT_NLI);
    assign is_sch_op           = (unit_sel_reg == UNIT_SCH);
    assign is_nli_load_mult    = is_nli_op && (func_sel_reg == NLI_LOAD_MULT);
    assign is_nli_load_ybnd    = is_nli_op && (func_sel_reg == NLI_LOAD_YBND);
    assign is_nli_load_lut     = is_nli_load_mult || is_nli_load_ybnd;
    assign is_nli_compute      = is_nli_op && (func_sel_reg == NLI_COMPUTE);
    // assign is_sfu_cordic       = is_sfu_op && (func_sel_reg[1:0] == SFU_CORDIC);
    assign is_sfu_rng          = is_sfu_op && (func_sel_reg[1:0] == SFU_RNG);
    assign is_sfu_itp          = is_sfu_op && (func_sel_reg[1:0] == SFU_ITP);
    // assign sfu_need_input_read = is_sfu_cordic || is_sfu_itp;
    assign sfu_need_input_read = is_sfu_itp;
    assign vpu_func_sel_valid  = (func_sel_reg <= VPU_REDUCE_SUM);
    // assign sfu_func_sel_valid  = (func_sel_reg[1:0] == SFU_CORDIC) ||
    //                              (func_sel_reg[1:0] == SFU_RNG)    ||
    //                              (func_sel_reg[1:0] == SFU_ITP);

    assign sfu_func_sel_valid  = (func_sel_reg[1:0] == SFU_RNG)    ||
                                 (func_sel_reg[1:0] == SFU_ITP);


    assign nli_func_sel_valid  = (func_sel_reg == NLI_LOAD_MULT) ||
                                 (func_sel_reg == NLI_LOAD_YBND) ||
                                 (func_sel_reg == NLI_COMPUTE);
    assign sch_func_sel_valid  = (func_sel_reg == SCH_RUN);
    assign func_sel_valid      = unit_sel_valid &&
                                 ((is_vpu_op && vpu_func_sel_valid) ||
                                  (is_sfu_op && sfu_func_sel_valid) ||
                                  (is_nli_op && nli_func_sel_valid) ||
                                  (is_sch_op && sch_func_sel_valid));
    assign is_elementwise      = is_vpu_op &&
                                 ((func_sel_reg == VPU_ADD)    ||
                                  (func_sel_reg == VPU_SUB)    ||
                                  (func_sel_reg == VPU_MUL)    ||
                                  (func_sel_reg == VPU_MAX_EW) ||
                                  (func_sel_reg == VPU_MIN_EW));
    assign is_reduction        = is_vpu_op &&
                                 ((func_sel_reg == VPU_REDUCE_MAX) ||
                                  (func_sel_reg == VPU_REDUCE_SUM));
    assign need_op_b           = is_elementwise;
    assign write_vector        = is_elementwise || is_sfu_op;
    assign write_scalar        = is_reduction;
    assign start_accepted      = (state_q == ST_IDLE) && start_i && !cfg_set_i && func_sel_valid;
    assign seed_load_accepted  = (state_q == ST_IDLE) && cfg_set_i &&
                                 (cfg_addr_i == CFG_SFU_SEED_LOAD) && cfg_data_i[0];
    assign all_read_issued     = (read_cnt_q == batch_size_reg);
    assign all_launched        = (launch_cnt_q == batch_size_reg);
    assign read_req_fire       = (state_q == ST_RUN) && !all_read_issued &&
                                 (is_vpu_op || (is_sfu_op && sfu_need_input_read));
    assign rng_launch_fire     = (state_q == ST_RUN) && is_sfu_rng && !all_launched;
    assign launch_fire         = is_sfu_rng ? rng_launch_fire : launch_valid_q;
    assign launch_batch        = is_sfu_rng ? launch_cnt_q : launch_batch_q;
    assign write_fire          = is_nli_op ? 1'b0 :
                                 is_vpu_op ? vpu_calc_done_i : sfu_done_i;
    assign last_write_fire     = write_fire && result_tag_valid &&
                                 (write_cnt_q == batch_size_reg - ADDR_WIDTH'(1));
    assign read_addr           = (state_q == ST_SEED_HIGH_REQ) ? sfu_seed_high_base_addr_reg :
                                 (state_q == ST_SEED_LOW_REQ)  ? sfu_seed_low_base_addr_reg  :
                                 (state_q == ST_NLI_LUT_REQ)   ? (op_a_base_addr_reg + ADDR_WIDTH'(nli_load_cnt_q / NLI_TOKENS_PER_ROW)) :
                                 ((state_q == ST_NLI_COMPUTE) || (state_q == ST_NLI_DRAIN)) ?
                                                                 (op_a_base_addr_reg + nli_read_cnt_q) :
                                                                 (op_a_base_addr_reg + read_cnt_q);
    assign op_b_read_addr      = (state_q == ST_SEED_HIGH_REQ) ? sfu_seed_high_base_addr_reg :
                                 (state_q == ST_SEED_LOW_REQ)  ? sfu_seed_low_base_addr_reg  :
                                 (state_q == ST_NLI_MACRO_REQ) ? op_b_base_addr_reg :
                                                                 (op_b_base_addr_reg + read_cnt_q);
    assign write_addr          = is_nli_op ? (vec_out_base_addr_reg + nli_write_cnt_q) :
                                 write_vector ?
                                 (vec_out_base_addr_reg + result_batch) :
                                 (reduce_out_base_addr_reg + result_batch);

    assign busy_o           = (state_q != ST_IDLE);
    assign done_o           = (state_q == ST_DONE);
    assign calc_done_o      = is_nli_op ? nli_write_fire : write_fire;
    assign vpu_func_sel_o   = func_sel_reg;
    assign vpu_start_o      = launch_fire && is_vpu_op;
    assign sfu_sel_o        = func_sel_reg[1:0];
    assign sfu_start_o      = launch_fire && is_sfu_op;
    assign sfu_seed_load_o  = (state_q == ST_SEED_APPLY);

    assign sch_start_o      = (state_q == ST_SCH_RUN);
    assign sch_clear_o      = 1'b0;
    assign sch_inbuf_base_o = op_a_base_addr_reg;
    assign sch_obuf_base_o  = vec_out_base_addr_reg;

    logic                       nli_launch_seen_q;

    logic [2:0]                 nli_flush_cnt_q;

    assign nli_clr_o        = (state_q == ST_NLI_MACRO_REQ) ||
                              (state_q == ST_NLI_MACRO_CAP) ||
                              (state_q == ST_NLI_FLUSH);
    assign nli_dn_ready_o   = ((state_q == ST_NLI_COMPUTE) || (state_q == ST_NLI_DRAIN));
    assign nli_read_fire    = (state_q == ST_NLI_COMPUTE) && !nli_last_read_q &&
                              (nli_read_cnt_q < batch_size_reg);
    assign nli_write_fire   = nli_dn_valid_i && nli_dn_ready_o;
    assign nli_last_write_fire = nli_write_fire &&
                                 (nli_write_cnt_q == batch_size_reg - ADDR_WIDTH'(1));

    assign nli_mul_lut_wr_en_o      = (state_q == ST_NLI_LUT_WR) && is_nli_load_mult;
    assign nli_mul_lut_wr_addr_o    = nli_load_cnt_q[NLI_MACRO_IDX_W-1:0];
    assign nli_mul_lut_wr_data_o    = nli_row_buf_q[nli_slot_q * ELEM_WIDTH +: ELEM_WIDTH];
    assign nli_y_bounds_lut_wr_en_o = (state_q == ST_NLI_LUT_WR) && is_nli_load_ybnd;
    assign nli_y_bounds_lut_wr_addr_o = nli_load_cnt_q[NLI_IVAL_IDX_W-1:0];
    assign nli_y_bounds_lut_wr_data_o = nli_row_buf_q[nli_slot_q * ELEM_WIDTH +: ELEM_WIDTH];

    assign nli_up_valid_o = nli_read_data_valid_q;

    always_comb begin
        for (int bank = 0; bank < BANK_NUM; bank++) begin
            op_a_dout_flat[bank*BANK_WIDTH +: BANK_WIDTH] = op_a_buf_dout_i[bank];
            op_b_dout_flat[bank*BANK_WIDTH +: BANK_WIDTH] = op_b_buf_dout_i[bank];
        end
    end

    always_comb begin
        for (int lane = 0; lane < NLI_NUM_LANES; lane++) begin
            if (nli_read_data_valid_q && ((lane / ELEM_PER_BANK) < BANK_NUM)) begin
                nli_input_data_o[lane] =
                    op_a_buf_dout_i[lane / ELEM_PER_BANK][(lane % ELEM_PER_BANK) * ELEM_WIDTH +: ELEM_WIDTH];
            end else begin
                nli_input_data_o[lane] = '0;
            end
        end
    end

    always_comb begin
        if (is_sfu_op) begin
            unique case (func_sel_reg[1:0])
                // SFU_CORDIC: result_batch = sfu_tag_batch_q[LAT_SFU_CORDIC-1];
                SFU_RNG:    result_batch = sfu_tag_batch_q[LAT_SFU_RNG-1];
                SFU_ITP:    result_batch = sfu_tag_batch_q[LAT_SFU_ITP-1];
                default:    result_batch = '0;
            endcase
        end else begin
            unique case (func_sel_reg)
                VPU_ADD, VPU_SUB: result_batch = tag_batch_q[LAT_ADD_SUB-1];
                VPU_MUL:          result_batch = tag_batch_q[LAT_MUL-1];
                VPU_MAX_EW,
                VPU_MIN_EW:       result_batch = tag_batch_q[LAT_CMP-1];
                VPU_REDUCE_MAX:   result_batch = tag_batch_q[LAT_REDUCE_MAX-1];
                VPU_REDUCE_SUM:   result_batch = tag_batch_q[LAT_REDUCE_SUM-1];
                default:          result_batch = '0;
            endcase
        end
    end
                

// SFU_CORDIC: result_tag_valid = sfu_tag_valid_q[LAT_SFU_CORDIC-1];
    always_comb begin
        if (is_sfu_op) begin
            unique case (func_sel_reg[1:0])
                SFU_RNG:    result_tag_valid = sfu_tag_valid_q[LAT_SFU_RNG-1];
                SFU_ITP:    result_tag_valid = sfu_tag_valid_q[LAT_SFU_ITP-1];
                default:    result_tag_valid = 1'b0;
            endcase
        end else begin
            unique case (func_sel_reg)
                VPU_ADD, VPU_SUB: result_tag_valid = tag_valid_q[LAT_ADD_SUB-1];
                VPU_MUL:          result_tag_valid = tag_valid_q[LAT_MUL-1];
                VPU_MAX_EW,
                VPU_MIN_EW:       result_tag_valid = tag_valid_q[LAT_CMP-1];
                VPU_REDUCE_MAX:   result_tag_valid = tag_valid_q[LAT_REDUCE_MAX-1];
                VPU_REDUCE_SUM:   result_tag_valid = tag_valid_q[LAT_REDUCE_SUM-1];
                default:          result_tag_valid = 1'b0;
            endcase
        end
    end

    initial begin
        if ((BANK_WIDTH % ELEM_WIDTH) != 0) begin
            $fatal(1, "axu_ctrl: BANK_WIDTH must be an integer multiple of ELEM_WIDTH");
        end
        if ((BANK_WIDTH % SEED_WORD_WIDTH) != 0) begin
            $fatal(1, "axu_ctrl: BANK_WIDTH must be an integer multiple of 64 for SFU seeds");
        end
        if (NUM_LANE * ELEM_WIDTH != BANK_NUM * BANK_WIDTH) begin
            $fatal(1, "axu_ctrl: NUM_LANE/ELEM_WIDTH must match BANK_NUM/BANK_WIDTH");
        end
        if ((SFU_LANE * 2) != NUM_LANE) begin
            $fatal(1, "axu_ctrl: SFU_LANE must be exactly half of NUM_LANE");
        end
        if ((2 * BANK_NUM * SEED_WORDS_PER_BANK) < SFU_LANE) begin
            $fatal(1, "axu_ctrl: op_a/op_b buffer width is insufficient for one-cycle SFU seed load");
        end
        if (MAX_LATENCY == 0) begin
            $fatal(1, "axu_ctrl: MAX_LATENCY must be nonzero");
        end
        if (MAX_SFU_LATENCY == 0) begin
            $fatal(1, "axu_ctrl: MAX_SFU_LATENCY must be nonzero");
        end
    end

    always_comb begin
        state_d = state_q;

        unique case (state_q)
            ST_IDLE: begin
                if (seed_load_accepted) begin
                    state_d = ST_SEED_HIGH_REQ;
                end else if (start_i && !cfg_set_i && func_sel_valid) begin
                    if (batch_size_reg == '0 && !is_nli_load_lut && !is_sch_op) begin
                        state_d = ST_DONE;
                    end else if (is_nli_load_lut) begin
                        state_d = ST_NLI_LUT_REQ;
                    end else if (is_nli_compute) begin
                        state_d = ST_NLI_MACRO_REQ;
                    end else if (is_sch_op) begin
                        state_d = ST_SCH_RUN;
                    end else begin
                        state_d = ST_RUN;
                    end
                end
            end

            ST_SEED_HIGH_REQ: begin
                state_d = ST_SEED_HIGH_CAP;
            end

            ST_SEED_HIGH_CAP: begin
                state_d = ST_SEED_LOW_REQ;
            end

            ST_SEED_LOW_REQ: begin
                state_d = ST_SEED_LOW_CAP;
            end

            ST_SEED_LOW_CAP: begin
                state_d = ST_SEED_APPLY;
            end

            ST_SEED_APPLY: begin
                state_d = ST_DONE;
            end

            ST_RUN: begin
                if (all_launched) begin
                    state_d = last_write_fire ? ST_DONE : ST_DRAIN;
                end
            end

            ST_DRAIN: begin
                if (last_write_fire) begin
                    state_d = ST_DONE;
                end
            end

            ST_NLI_LUT_REQ: begin
                state_d = ST_NLI_LUT_CAP;
            end

            ST_NLI_LUT_CAP: begin
                state_d = ST_NLI_LUT_WR;
            end

            ST_NLI_LUT_WR: begin
                if ((is_nli_load_mult && (nli_load_cnt_q == NLI_LUT_CNT_W'(NLI_NUM_MACROS-1))) ||
                    (is_nli_load_ybnd && (nli_load_cnt_q == NLI_LUT_CNT_W'(NLI_Y_BOUNDS_ENTRIES-1)))) begin
                    state_d = ST_DONE;
                end else if (nli_slot_q == NLI_SLOT_W'(NLI_TOKENS_PER_ROW-1)) begin
                    state_d = ST_NLI_LUT_REQ;
                end else begin
                    state_d = ST_NLI_LUT_WR;
                end
            end

            ST_NLI_MACRO_REQ: begin
                state_d = ST_NLI_MACRO_CAP;
            end

            ST_NLI_MACRO_CAP: begin
                state_d = ST_NLI_FLUSH;
            end

            ST_NLI_FLUSH: begin
                if (nli_flush_cnt_q == 3'd5) begin
                    state_d = ST_NLI_COMPUTE;
                end
            end

            ST_NLI_COMPUTE: begin
                if (nli_last_read_q || (nli_read_cnt_q == batch_size_reg)) begin
                    state_d = nli_last_write_fire ? ST_DONE : ST_NLI_DRAIN;
                end
            end

            ST_NLI_DRAIN: begin
                if (nli_last_write_fire) begin
                    state_d = ST_DONE;
                end
            end

            ST_SCH_RUN: begin
                state_d = ST_SCH_WAIT;
            end

            ST_SCH_WAIT: begin
                if (sch_done_i) begin
                    state_d = ST_DONE;
                end
            end

            ST_DONE: begin
                state_d = ST_IDLE;
            end

            default: begin
                state_d = ST_IDLE;
            end
        endcase
    end

    always_comb begin
        op_a_buf_cen_o = '1;
        op_a_buf_wen_o = '0;
        op_b_buf_cen_o = '1;
        op_b_buf_wen_o = '0;
        out_buf_cen_o  = '1;
        out_buf_wen_o  = '0;

        for (int bank = 0; bank < BANK_NUM; bank++) begin
            op_a_buf_addr_o[bank] = read_addr;
            op_b_buf_addr_o[bank] = op_b_read_addr;
            out_buf_addr_o[bank]  = write_addr;
            out_buf_din_o[bank]   = '0;
        end

        if (read_req_fire) begin
            op_a_buf_cen_o = '0;
            if (need_op_b) begin
                op_b_buf_cen_o = '0;
            end
        end

        if ((state_q == ST_SEED_HIGH_REQ) || (state_q == ST_SEED_LOW_REQ)) begin
            op_a_buf_cen_o = '0;
            op_b_buf_cen_o = '0;
        end

        if (state_q == ST_NLI_LUT_REQ) begin
            op_a_buf_cen_o = '0;
        end

        if (state_q == ST_NLI_MACRO_REQ) begin
            op_b_buf_cen_o = '0;
        end

        if (nli_read_fire) begin
            op_a_buf_cen_o = '0;
        end

        if (is_nli_op && nli_write_fire) begin
            out_buf_cen_o = '0;
            out_buf_wen_o = '1;
            for (int bank = 0; bank < BANK_NUM; bank++) begin
                for (int elem = 0; elem < ELEM_PER_BANK; elem++) begin
                    if ((bank * ELEM_PER_BANK + elem) < NLI_NUM_LANES) begin
                        out_buf_din_o[bank][elem * ELEM_WIDTH +: ELEM_WIDTH] =
                            nli_output_data_i[bank * ELEM_PER_BANK + elem];
                    end
                end
            end
        end else if (write_fire && result_tag_valid) begin
            if (write_vector) begin
                out_buf_cen_o = '0;
                out_buf_wen_o = '1;
                for (int bank = 0; bank < BANK_NUM; bank++) begin
                    for (int elem = 0; elem < ELEM_PER_BANK; elem++) begin
                        if (is_sfu_op) begin
                            if ((bank * ELEM_PER_BANK + elem) < SFU_LANE) begin
                                out_buf_din_o[bank][elem * ELEM_WIDTH +: ELEM_WIDTH] =
                                    sfu_result0_i[bank * ELEM_PER_BANK + elem];
                            end else begin
                                out_buf_din_o[bank][elem * ELEM_WIDTH +: ELEM_WIDTH] =
                                    sfu_result1_i[bank * ELEM_PER_BANK + elem - SFU_LANE];
                            end
                        end else begin
                            out_buf_din_o[bank][elem * ELEM_WIDTH +: ELEM_WIDTH] =
                                vpu_vec_result_posit_i[bank * ELEM_PER_BANK + elem];
                        end
                    end
                end
            end else if (write_scalar) begin
                out_buf_cen_o[0] = 1'b0;
                out_buf_wen_o[0] = 1'b1;
                out_buf_din_o[0][0 +: ELEM_WIDTH] = vpu_reduction_result_posit_i;
            end
        end
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            state_q                     <= ST_IDLE;
            unit_sel_reg                <= UNIT_VPU;
            func_sel_reg                <= VPU_ADD;
            op_a_base_addr_reg          <= '0;
            op_b_base_addr_reg          <= '0;
            vec_out_base_addr_reg       <= '0;
            reduce_out_base_addr_reg    <= '0;
            batch_size_reg              <= '0;
            sfu_seed_high_base_addr_reg <= '0;
            sfu_seed_low_base_addr_reg  <= '0;
            read_cnt_q                  <= '0;
            launch_cnt_q                <= '0;
            write_cnt_q                 <= '0;
            read_req_batch_q            <= '0;
            read_data_batch_q           <= '0;
            launch_batch_q              <= '0;
            read_data_valid_q           <= 1'b0;
            launch_valid_q              <= 1'b0;
            tag_valid_q                 <= '0;
            sfu_tag_valid_q             <= '0;
            for (int stage = 0; stage < MAX_LATENCY; stage++) begin
                tag_batch_q[stage] <= '0;
            end
            for (int stage = 0; stage < MAX_SFU_LATENCY; stage++) begin
                sfu_tag_batch_q[stage] <= '0;
            end
            for (int lane = 0; lane < NUM_LANE; lane++) begin
                vpu_vec_a_posit_o[lane] <= '0;
                vpu_vec_b_posit_o[lane] <= '0;
            end
            for (int lane = 0; lane < SFU_LANE; lane++) begin
                sfu_data_o[lane]      <= '0;
                sfu_seed_high_o[lane] <= '0;
                sfu_seed_low_o[lane]  <= '0;
            end
            nli_load_cnt_q        <= '0;
            nli_slot_q            <= '0;
            nli_row_buf_q         <= '0;
            nli_read_cnt_q        <= '0;
            nli_write_cnt_q       <= '0;
            nli_read_data_valid_q <= 1'b0;
            nli_last_read_q       <= 1'b0;
            nli_launch_seen_q     <= 1'b0;
            nli_flush_cnt_q       <= '0;
            for (int i = 0; i <= NLI_NUM_MACROS; i++) begin
                nli_macro_bounds_o[i] <= '0;
            end
        end else begin
            state_q <= state_d;

            if ((state_q == ST_IDLE) && cfg_set_i && !seed_load_accepted) begin
                unique case (cfg_addr_i)
                    CFG_FUNC_SEL:               func_sel_reg                <= cfg_data_i[2:0];
                    CFG_OP_A_BASE_ADDR:         op_a_base_addr_reg          <= cfg_data_i;
                    CFG_OP_B_BASE_ADDR:         op_b_base_addr_reg          <= cfg_data_i;
                    CFG_VEC_OUT_BASE_ADDR:      vec_out_base_addr_reg       <= cfg_data_i;
                    CFG_REDUCE_OUT_BASE_ADDR:   reduce_out_base_addr_reg    <= cfg_data_i;
                    CFG_BATCH_SIZE:             batch_size_reg              <= cfg_data_i;
                    CFG_UNIT_SEL:               unit_sel_reg                <= cfg_data_i[1:0];
                    CFG_SFU_SEED_HIGH_BASE_ADDR: sfu_seed_high_base_addr_reg <= cfg_data_i;
                    CFG_SFU_SEED_LOW_BASE_ADDR:  sfu_seed_low_base_addr_reg  <= cfg_data_i;
                    default:;
                endcase
            end

            if (start_accepted) begin
                read_cnt_q        <= '0;
                launch_cnt_q      <= '0;
                write_cnt_q       <= '0;
                read_req_batch_q  <= '0;
                read_data_batch_q <= '0;
                launch_batch_q    <= '0;
                read_data_valid_q <= 1'b0;
                launch_valid_q    <= 1'b0;
                tag_valid_q       <= '0;
                sfu_tag_valid_q   <= '0;
                for (int stage = 0; stage < MAX_LATENCY; stage++) begin
                    tag_batch_q[stage] <= '0;
                end
                for (int stage = 0; stage < MAX_SFU_LATENCY; stage++) begin
                    sfu_tag_batch_q[stage] <= '0;
                end
                nli_load_cnt_q        <= '0;
                nli_slot_q            <= '0;
                nli_row_buf_q         <= '0;
                nli_read_cnt_q        <= '0;
                nli_write_cnt_q       <= '0;
                nli_read_data_valid_q <= 1'b0;
                nli_last_read_q       <= 1'b0;
                nli_launch_seen_q     <= 1'b0;
                nli_flush_cnt_q       <= '0;
            end else if (!is_nli_op) begin
                read_data_valid_q <= read_req_fire;
                launch_valid_q    <= read_data_valid_q;

                if (read_req_fire) begin
                    read_req_batch_q  <= read_cnt_q;
                    read_data_batch_q <= read_cnt_q;
                    read_cnt_q        <= read_cnt_q + ADDR_WIDTH'(1);
                end

                if (read_data_valid_q) begin
                    launch_batch_q <= read_data_batch_q;
                    if (is_sfu_op) begin
                        for (int lane = 0; lane < SFU_LANE; lane++) begin
                            sfu_data_o[lane] <=
                                op_a_buf_dout_i[lane / ELEM_PER_BANK][(lane % ELEM_PER_BANK) * ELEM_WIDTH +: ELEM_WIDTH];
                        end
                    end else begin
                        for (int bank = 0; bank < BANK_NUM; bank++) begin
                            for (int elem = 0; elem < ELEM_PER_BANK; elem++) begin
                                vpu_vec_a_posit_o[bank * ELEM_PER_BANK + elem] <=
                                    op_a_buf_dout_i[bank][elem * ELEM_WIDTH +: ELEM_WIDTH];
                                vpu_vec_b_posit_o[bank * ELEM_PER_BANK + elem] <= need_op_b ?
                                    op_b_buf_dout_i[bank][elem * ELEM_WIDTH +: ELEM_WIDTH] : '0;
                            end
                        end
                    end
                end

                tag_valid_q[0] <= launch_fire && is_vpu_op;
                tag_batch_q[0] <= launch_batch;
                for (int stage = 1; stage < MAX_LATENCY; stage++) begin
                    tag_valid_q[stage] <= tag_valid_q[stage-1];
                    tag_batch_q[stage] <= tag_batch_q[stage-1];
                end

                sfu_tag_valid_q[0] <= launch_fire && is_sfu_op;
                sfu_tag_batch_q[0] <= launch_batch;
                for (int stage = 1; stage < MAX_SFU_LATENCY; stage++) begin
                    sfu_tag_valid_q[stage] <= sfu_tag_valid_q[stage-1];
                    sfu_tag_batch_q[stage] <= sfu_tag_batch_q[stage-1];
                end

                if (launch_fire) begin
                    launch_cnt_q <= launch_cnt_q + ADDR_WIDTH'(1);
                end

                if (write_fire && result_tag_valid) begin
                    write_cnt_q <= write_cnt_q + ADDR_WIDTH'(1);
                end
            end else begin
                if (state_q == ST_NLI_LUT_CAP) begin
                    nli_row_buf_q <= op_a_dout_flat;
                    nli_slot_q    <= '0;
                end

                if (state_q == ST_NLI_LUT_WR) begin
                    nli_load_cnt_q <= nli_load_cnt_q + NLI_LUT_CNT_W'(1);
                    nli_slot_q     <= nli_slot_q + NLI_SLOT_W'(1);
                end

                if (state_q == ST_NLI_MACRO_CAP) begin
                    for (int i = 0; i <= NLI_NUM_MACROS; i++) begin
                        nli_macro_bounds_o[i] <= op_b_dout_flat[i * ELEM_WIDTH +: ELEM_WIDTH];
                    end
                end

                if (state_q == ST_NLI_FLUSH) begin
                    nli_flush_cnt_q <= nli_flush_cnt_q + 3'd1;
                end

                if (nli_read_fire) begin
                    nli_read_cnt_q  <= nli_read_cnt_q + ADDR_WIDTH'(1);
                    nli_last_read_q <= (nli_read_cnt_q == batch_size_reg - ADDR_WIDTH'(1));
                end

                nli_read_data_valid_q <= nli_read_fire;

                if (nli_up_valid_o && nli_up_ready_i) begin
                    nli_launch_seen_q <= 1'b1;
                end

                if (nli_write_fire) begin
                    nli_write_cnt_q <= nli_write_cnt_q + ADDR_WIDTH'(1);
                end
            end

            if (state_q == ST_SEED_HIGH_CAP) begin
                for (int bank = 0; bank < BANK_NUM; bank++) begin
                    for (int word = 0; word < SEED_WORDS_PER_BANK; word++) begin
                        if ((bank * SEED_WORDS_PER_BANK + word) < SFU_LANE) begin
                            sfu_seed_high_o[bank * SEED_WORDS_PER_BANK + word] <=
                                op_a_buf_dout_i[bank][word * SEED_WORD_WIDTH +: SEED_WORD_WIDTH];
                        end
                        if ((BANK_NUM * SEED_WORDS_PER_BANK + bank * SEED_WORDS_PER_BANK + word) < SFU_LANE) begin
                            sfu_seed_high_o[BANK_NUM * SEED_WORDS_PER_BANK + bank * SEED_WORDS_PER_BANK + word] <=
                                op_b_buf_dout_i[bank][word * SEED_WORD_WIDTH +: SEED_WORD_WIDTH];
                        end
                    end
                end
            end

            if (state_q == ST_SEED_LOW_CAP) begin
                for (int bank = 0; bank < BANK_NUM; bank++) begin
                    for (int word = 0; word < SEED_WORDS_PER_BANK; word++) begin
                        if ((bank * SEED_WORDS_PER_BANK + word) < SFU_LANE) begin
                            sfu_seed_low_o[bank * SEED_WORDS_PER_BANK + word] <=
                                op_a_buf_dout_i[bank][word * SEED_WORD_WIDTH +: SEED_WORD_WIDTH];
                        end
                        if ((BANK_NUM * SEED_WORDS_PER_BANK + bank * SEED_WORDS_PER_BANK + word) < SFU_LANE) begin
                            sfu_seed_low_o[BANK_NUM * SEED_WORDS_PER_BANK + bank * SEED_WORDS_PER_BANK + word] <=
                                op_b_buf_dout_i[bank][word * SEED_WORD_WIDTH +: SEED_WORD_WIDTH];
                        end
                    end
                end
            end

            if (write_fire && !result_tag_valid) begin
                $fatal(1, "axu_ctrl: result valid arrived without a matching batch tag");
            end
        end
    end

endmodule
