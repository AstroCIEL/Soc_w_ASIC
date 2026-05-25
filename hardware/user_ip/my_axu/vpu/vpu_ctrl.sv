module vpu_ctrl #(
    parameter int unsigned NUM_LANE       = 64,
    parameter int unsigned ELEM_WIDTH     = 16,
    parameter int unsigned BANK_WIDTH     = 128,
    parameter int unsigned BANK_NUM       = (NUM_LANE * ELEM_WIDTH) / BANK_WIDTH,
    parameter int unsigned ADDR_WIDTH     = 8,
    parameter int unsigned CFG_ADDR_WIDTH = 4
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
    input  logic [ELEM_WIDTH-1:0]       vpu_reduction_result_posit_i
);

    localparam int unsigned ELEM_PER_BANK = BANK_WIDTH / ELEM_WIDTH;
    localparam int unsigned NUM_FULL       = 1 << $clog2(NUM_LANE);
    localparam int unsigned REDSUM_LEVEL   = $clog2(NUM_FULL);
    localparam int unsigned LAT_ADD_SUB    = 2;
    localparam int unsigned LAT_MUL        = 2;
    localparam int unsigned LAT_CMP        = 1;
    localparam int unsigned LAT_REDUCE_MAX = 1;
    localparam int unsigned LAT_REDUCE_SUM = 2 * REDSUM_LEVEL;
    localparam int unsigned MAX_LATENCY    = LAT_REDUCE_SUM;

    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_FUNC_SEL             = CFG_ADDR_WIDTH'(0);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OP_A_BASE_ADDR       = CFG_ADDR_WIDTH'(1);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OP_B_BASE_ADDR       = CFG_ADDR_WIDTH'(2);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_VEC_OUT_BASE_ADDR    = CFG_ADDR_WIDTH'(3);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_REDUCE_OUT_BASE_ADDR = CFG_ADDR_WIDTH'(4);
    localparam logic [CFG_ADDR_WIDTH-1:0] CFG_BATCH_SIZE           = CFG_ADDR_WIDTH'(5);

    localparam logic [2:0] VPU_ADD        = 3'd0;
    localparam logic [2:0] VPU_SUB        = 3'd1;
    localparam logic [2:0] VPU_MUL        = 3'd2;
    localparam logic [2:0] VPU_MAX_EW     = 3'd3;
    localparam logic [2:0] VPU_MIN_EW     = 3'd4;
    localparam logic [2:0] VPU_REDUCE_MAX = 3'd5;
    localparam logic [2:0] VPU_REDUCE_SUM = 3'd6;

    typedef enum logic [1:0] {
        ST_IDLE,
        ST_RUN,
        ST_DRAIN,
        ST_DONE
    } state_e;

    state_e state_q, state_d;

    logic [2:0]            func_sel_reg;
    logic [ADDR_WIDTH-1:0] op_a_base_addr_reg;
    logic [ADDR_WIDTH-1:0] op_b_base_addr_reg;
    logic [ADDR_WIDTH-1:0] vec_out_base_addr_reg;
    logic [ADDR_WIDTH-1:0] reduce_out_base_addr_reg;
    logic [ADDR_WIDTH-1:0] batch_size_reg;

    logic [ADDR_WIDTH-1:0] read_cnt_q;
    logic [ADDR_WIDTH-1:0] launch_cnt_q;
    logic [ADDR_WIDTH-1:0] write_cnt_q;
    logic [ADDR_WIDTH-1:0] read_req_batch_q;
    logic [ADDR_WIDTH-1:0] read_data_batch_q;
    logic [ADDR_WIDTH-1:0] launch_batch_q;
    logic [ADDR_WIDTH-1:0] result_batch;
    logic [ADDR_WIDTH-1:0] read_addr;
    logic [ADDR_WIDTH-1:0] write_addr;

    logic func_sel_valid;
    logic is_elementwise;
    logic is_reduction;
    logic need_op_b;
    logic write_vector;
    logic write_scalar;
    logic start_accepted;
    logic read_req_fire;
    logic read_data_valid_q;
    logic launch_valid_q;
    logic launch_fire;
    logic write_fire;
    logic all_read_issued;
    logic all_launched;
    logic last_write_fire;
    logic result_tag_valid;

    logic [MAX_LATENCY-1:0] tag_valid_q;
    logic [ADDR_WIDTH-1:0]  tag_batch_q [MAX_LATENCY-1:0];

    assign func_sel_valid = (func_sel_reg <= VPU_REDUCE_SUM);
    assign is_elementwise = (func_sel_reg == VPU_ADD)    ||
                            (func_sel_reg == VPU_SUB)    ||
                            (func_sel_reg == VPU_MUL)    ||
                            (func_sel_reg == VPU_MAX_EW) ||
                            (func_sel_reg == VPU_MIN_EW);
    assign is_reduction   = (func_sel_reg == VPU_REDUCE_MAX) ||
                            (func_sel_reg == VPU_REDUCE_SUM);
    assign need_op_b      = is_elementwise;
    assign write_vector   = is_elementwise;
    assign write_scalar   = is_reduction;
    assign start_accepted = (state_q == ST_IDLE) && start_i && !cfg_set_i && func_sel_valid;
    assign all_read_issued = (read_cnt_q == batch_size_reg);
    assign all_launched    = (launch_cnt_q == batch_size_reg);
    assign read_req_fire   = (state_q == ST_RUN) && !all_read_issued;
    assign launch_fire     = launch_valid_q;
    assign write_fire      = vpu_calc_done_i;
    assign last_write_fire = write_fire && (write_cnt_q == batch_size_reg - ADDR_WIDTH'(1));
    assign read_addr       = op_a_base_addr_reg + read_cnt_q;
    assign write_addr      = write_vector ?
                             (vec_out_base_addr_reg + result_batch) :
                             (reduce_out_base_addr_reg + result_batch);

    assign busy_o         = (state_q != ST_IDLE);
    assign done_o         = (state_q == ST_DONE);
    assign calc_done_o    = write_fire;
    assign vpu_func_sel_o = func_sel_reg;
    assign vpu_start_o    = launch_fire;

    always_comb begin
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

    always_comb begin
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

    initial begin
        if ((BANK_WIDTH % ELEM_WIDTH) != 0) begin
            $fatal(1, "vpu_ctrl: BANK_WIDTH must be an integer multiple of ELEM_WIDTH");
        end
        if (NUM_LANE * ELEM_WIDTH != BANK_NUM * BANK_WIDTH) begin
            $fatal(1, "vpu_ctrl: NUM_LANE/ELEM_WIDTH must match BANK_NUM/BANK_WIDTH");
        end
        if (MAX_LATENCY == 0) begin
            $fatal(1, "vpu_ctrl: MAX_LATENCY must be nonzero");
        end
    end

    always_comb begin
        state_d = state_q;

        unique case (state_q)
            ST_IDLE: begin
                if (start_i && !cfg_set_i && func_sel_valid) begin
                    state_d = (batch_size_reg == '0) ? ST_DONE : ST_RUN;
                end
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
            op_b_buf_addr_o[bank] = op_b_base_addr_reg + read_cnt_q;
            out_buf_addr_o[bank]  = write_addr;
            out_buf_din_o[bank]   = '0;
        end

        if (read_req_fire) begin
            op_a_buf_cen_o = '0;
            if (need_op_b) begin
                op_b_buf_cen_o = '0;
            end
        end

        if (write_fire && result_tag_valid) begin
            if (write_vector) begin
                out_buf_cen_o = '0;
                out_buf_wen_o = '1;
                for (int bank = 0; bank < BANK_NUM; bank++) begin
                    for (int elem = 0; elem < ELEM_PER_BANK; elem++) begin
                        out_buf_din_o[bank][elem * ELEM_WIDTH +: ELEM_WIDTH] =
                            vpu_vec_result_posit_i[bank * ELEM_PER_BANK + elem];
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
            state_q                  <= ST_IDLE;
            func_sel_reg             <= VPU_ADD;
            op_a_base_addr_reg       <= '0;
            op_b_base_addr_reg       <= '0;
            vec_out_base_addr_reg    <= '0;
            reduce_out_base_addr_reg <= '0;
            batch_size_reg           <= '0;
            read_cnt_q               <= '0;
            launch_cnt_q             <= '0;
            write_cnt_q              <= '0;
            read_req_batch_q         <= '0;
            read_data_batch_q        <= '0;
            launch_batch_q           <= '0;
            read_data_valid_q        <= 1'b0;
            launch_valid_q           <= 1'b0;
            tag_valid_q              <= '0;
            for (int stage = 0; stage < MAX_LATENCY; stage++) begin
                tag_batch_q[stage] <= '0;
            end
            for (int lane = 0; lane < NUM_LANE; lane++) begin
                vpu_vec_a_posit_o[lane] <= '0;
                vpu_vec_b_posit_o[lane] <= '0;
            end
        end else begin
            state_q <= state_d;

            if ((state_q == ST_IDLE) && cfg_set_i) begin
                unique case (cfg_addr_i)
                    CFG_FUNC_SEL:             func_sel_reg             <= cfg_data_i[2:0];
                    CFG_OP_A_BASE_ADDR:       op_a_base_addr_reg       <= cfg_data_i;
                    CFG_OP_B_BASE_ADDR:       op_b_base_addr_reg       <= cfg_data_i;
                    CFG_VEC_OUT_BASE_ADDR:    vec_out_base_addr_reg    <= cfg_data_i;
                    CFG_REDUCE_OUT_BASE_ADDR: reduce_out_base_addr_reg <= cfg_data_i;
                    CFG_BATCH_SIZE:           batch_size_reg           <= cfg_data_i;
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
                for (int stage = 0; stage < MAX_LATENCY; stage++) begin
                    tag_batch_q[stage] <= '0;
                end
            end else begin
                read_data_valid_q <= read_req_fire;
                launch_valid_q    <= read_data_valid_q;
                if (read_req_fire) begin
                    read_req_batch_q  <= read_cnt_q;
                    read_data_batch_q <= read_cnt_q;
                    read_cnt_q        <= read_cnt_q + ADDR_WIDTH'(1);
                end

                if (read_data_valid_q) begin
                    launch_batch_q <= read_data_batch_q;
                    for (int bank = 0; bank < BANK_NUM; bank++) begin
                        for (int elem = 0; elem < ELEM_PER_BANK; elem++) begin
                            vpu_vec_a_posit_o[bank * ELEM_PER_BANK + elem] <=
                                op_a_buf_dout_i[bank][elem * ELEM_WIDTH +: ELEM_WIDTH];
                            vpu_vec_b_posit_o[bank * ELEM_PER_BANK + elem] <= need_op_b ?
                                op_b_buf_dout_i[bank][elem * ELEM_WIDTH +: ELEM_WIDTH] : '0;
                        end
                    end
                end

                tag_valid_q[0] <= launch_fire;
                tag_batch_q[0] <= launch_batch_q;
                for (int stage = 1; stage < MAX_LATENCY; stage++) begin
                    tag_valid_q[stage] <= tag_valid_q[stage-1];
                    tag_batch_q[stage] <= tag_batch_q[stage-1];
                end

                if (launch_fire) begin
                    launch_cnt_q <= launch_cnt_q + ADDR_WIDTH'(1);
                end

                if (write_fire && result_tag_valid) begin
                    write_cnt_q <= write_cnt_q + ADDR_WIDTH'(1);
                end
            end

            if (write_fire && !result_tag_valid) begin
                $fatal(1, "vpu_ctrl: result valid arrived without a matching batch tag");
            end
        end
    end

endmodule
