//////////////////////////////////////////////////////////////////////////////////
// scheduler_buf_wrapper
//   - 从 inbuf 按行读出 16×16 掩码，转为 scheduler 流式输入
//   - 捕获 scheduler 输出，每 task 16b {group,lane,row,col}，4 个打包为 64b 写 obuf
//
// inbuf 布局：128b 行，[COL_COUNT-1:0] = 该行列掩码；地址 = inbuf_base + row
// obuf 布局：每个 128b 行的低 64b 含 4×16b task，[16*(k+1)-1:16*k] = 第 k 个 task；
//            地址 = obuf_base + pack_idx
//////////////////////////////////////////////////////////////////////////////////

module scheduler_buf_wrapper #(
    parameter int ROW_COUNT         = 16,
    parameter int COL_COUNT         = 16,
    parameter int GROUP_SIZE        = 4,
    parameter int IBANK_AW          = 8,   //inbuf bank address width
    parameter int IBANK_DW          = 128, //inbuf bank data width
    parameter int MAX_TASKS         = 256  //maximum number of tasks
) (
    input  logic clk_i,
    input  logic rst_ni,

    input  logic start_i,
    input  logic clear_i,

    // Sampled on the cycle start_i is high in ST_IDLE; held for the run.
    input  logic [IBANK_AW-1:0] inbuf_base_addr_i,
    input  logic [IBANK_AW-1:0] obuf_base_addr_i,

    output logic                           busy_o,
    output logic                           done_o,
    output logic                           error_o,
    output logic [$clog2(MAX_TASKS+1)-1:0] task_count_o,

    output logic                inbuf_rd_req_o,
    output logic [IBANK_AW-1:0] inbuf_rd_addr_o,
    input  logic [IBANK_DW-1:0] inbuf_rd_data_i,

    output logic                obuf_wr_req_o,
    output logic [IBANK_AW-1:0] obuf_wr_addr_o,
    output logic [IBANK_DW-1:0] obuf_wr_data_o
);

    localparam int COL_W      = $clog2(COL_COUNT);
    localparam int ROW_W      = $clog2(ROW_COUNT);
    localparam int ROW_CNT_W  = $clog2(ROW_COUNT);
    localparam int GROUP_W    = $clog2(COL_COUNT / GROUP_SIZE);
    localparam int LANE_W     = $clog2(GROUP_SIZE);
    localparam int SLOT_W     = $clog2(ROW_COUNT);
    localparam int TASK_CNT_W = $clog2(MAX_TASKS + 1);
    localparam int WORD_IDX_W = $clog2((MAX_TASKS + 3) / 4 + 1);

    typedef enum logic [2:0] {
        ST_IDLE,
        ST_RD_REQ,
        ST_RD_WAIT,
        ST_STREAM,
        ST_OBUF_WR,
        ST_FINISH
    } buf_st_e;

    buf_st_e st_q;

    logic [ROW_CNT_W-1:0] row_cnt_q;
    logic [COL_COUNT-1:0] row_mask_q;

    logic [TASK_CNT_W-1:0] task_cnt_q;
    logic [1:0]            pack_slot_q;
    logic [63:0]           pack64_q;      // accumulates current pack
    logic [WORD_IDX_W-1:0] word_idx_q;   // index of next pack to write

    // Registers that hold the pack to be written in ST_OBUF_WR
    logic [63:0]           wr_pack_q;     // pack data including last task
    logic [WORD_IDX_W-1:0] wr_word_idx_q; // word index captured before increment
    logic                  wr_last_q;     // 1 = this pack contains scheduler_out_last

    // Base addresses sampled at start_i; held for the whole run.
    logic [IBANK_AW-1:0] inbuf_base_q;
    logic [IBANK_AW-1:0] obuf_base_q;

    logic scheduler_in_valid;
    logic scheduler_in_ready;
    logic [COL_COUNT-1:0] scheduler_in_row_mask;
    logic [ROW_W-1:0]     scheduler_in_row_idx;
    logic                 scheduler_in_last;

    logic scheduler_out_valid;
    logic scheduler_out_ready;
    logic [GROUP_W-1:0] scheduler_out_group;
    logic [LANE_W-1:0]  scheduler_out_lane;
    logic [SLOT_W-1:0]  scheduler_out_slot;
    logic [ROW_W-1:0]   scheduler_out_row;
    logic [COL_W-1:0]  scheduler_out_col;
    logic               scheduler_out_last;

    logic scheduler_busy;
    logic scheduler_done;
    logic scheduler_error;

    logic [15:0] task_half16;
    logic        task_fire;
    // pack64 with current task merged in (combinational)
    logic [63:0] pack64_nxt;

    // Each field occupies exactly 4 bits: zero-extend group and lane to 4b.
    assign task_half16 = { {(4-GROUP_W){1'b0}}, scheduler_out_group,
                           {(4-LANE_W){1'b0}},  scheduler_out_lane,
                           scheduler_out_row,
                           scheduler_out_col };
    assign task_fire = scheduler_out_valid && scheduler_out_ready;

    // Back-pressure: only accept scheduler output when we can process it
    assign scheduler_out_ready = (st_q == ST_STREAM);

    // Combinational: next pack value including the current firing task
    always_comb begin
        pack64_nxt = pack64_q;
        if ((st_q == ST_STREAM) && task_fire)
            pack64_nxt[pack_slot_q*16 +: 16] = task_half16;
    end

    assign scheduler_in_valid    = (st_q == ST_STREAM);
    assign scheduler_in_row_mask = row_mask_q;
    assign scheduler_in_row_idx  = row_cnt_q[ROW_W-1:0];
    assign scheduler_in_last     = (row_cnt_q == ROW_COUNT - 1);

    assign busy_o       = (st_q != ST_IDLE) || scheduler_busy;
    assign done_o       = (st_q == ST_FINISH);
    assign error_o      = scheduler_error;
    assign task_count_o = task_cnt_q;

    scheduler #(
        .ROW_COUNT  ( ROW_COUNT  ),
        .COL_COUNT  ( COL_COUNT  ),
        .GROUP_SIZE ( GROUP_SIZE )
    ) u_scheduler (
        .clk_i            ( clk_i ),
        .rstn_i           ( rst_ni ),
        .start_i          ( start_i ),
        .in_valid_i       ( scheduler_in_valid ),
        .in_ready_o       ( scheduler_in_ready ),
        .in_row_mask_i    ( scheduler_in_row_mask ),
        .in_row_idx_i     ( scheduler_in_row_idx ),
        .in_last_i        ( scheduler_in_last ),
        .out_valid_o      ( scheduler_out_valid ),
        .out_ready_i      ( scheduler_out_ready ),
        .out_group_o      ( scheduler_out_group ),
        .out_lane_o       ( scheduler_out_lane ),
        .out_slot_o       ( scheduler_out_slot ),
        .out_row_o        ( scheduler_out_row ),
        .out_col_o        ( scheduler_out_col ),
        .out_group_last_o ( ),
        .out_last_o       ( scheduler_out_last ),
        .busy_o           ( scheduler_busy ),
        .done_o           ( scheduler_done ),
        .error_o          ( scheduler_error )
    );

    // Combinational: inbuf read / obuf write drives
    always_comb begin
        inbuf_rd_req_o  = 1'b0;
        inbuf_rd_addr_o = inbuf_base_q + {{(IBANK_AW-ROW_CNT_W){1'b0}}, row_cnt_q};
        obuf_wr_req_o   = 1'b0;
        obuf_wr_addr_o  = obuf_base_q + {{(IBANK_AW-WORD_IDX_W){1'b0}}, wr_word_idx_q};
        // Pack lives in the low 64b of the 128b obuf line; high half is unused.
        obuf_wr_data_o  = {{(IBANK_DW-64){1'b0}}, wr_pack_q};

        if (st_q == ST_RD_REQ) begin
            inbuf_rd_req_o = 1'b1;
        end

        if (st_q == ST_OBUF_WR) begin
            obuf_wr_req_o = 1'b1;
        end
    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            st_q          <= ST_IDLE;
            row_cnt_q     <= '0;
            row_mask_q    <= '0;
            task_cnt_q    <= '0;
            pack_slot_q   <= '0;
            pack64_q      <= '0;
            word_idx_q    <= '0;
            wr_pack_q     <= '0;
            wr_word_idx_q <= '0;
            wr_last_q     <= 1'b0;
            inbuf_base_q  <= '0;
            obuf_base_q   <= '0;
        end else begin
            if (clear_i) begin
                st_q          <= ST_IDLE;
                row_cnt_q     <= '0;
                task_cnt_q    <= '0;
                pack_slot_q   <= '0;
                pack64_q      <= '0;
                word_idx_q    <= '0;
                wr_pack_q     <= '0;
                wr_word_idx_q <= '0;
                wr_last_q     <= 1'b0;
                inbuf_base_q  <= '0;
                obuf_base_q   <= '0;
            end else begin
                unique case (st_q)
                    ST_IDLE: begin
                        if (start_i) begin
                            st_q          <= ST_RD_REQ;
                            row_cnt_q     <= '0;
                            task_cnt_q    <= '0;
                            pack_slot_q   <= '0;
                            pack64_q      <= '0;
                            word_idx_q    <= '0;
                            wr_pack_q     <= '0;
                            wr_word_idx_q <= '0;
                            wr_last_q     <= 1'b0;
                            inbuf_base_q  <= inbuf_base_addr_i;
                            obuf_base_q   <= obuf_base_addr_i;
                        end
                    end

                    ST_RD_REQ: begin
                        st_q <= ST_RD_WAIT;
                    end

                    ST_RD_WAIT: begin
                        // 128b read data; low COL_COUNT bits are the column mask
                        row_mask_q <= inbuf_rd_data_i[0 +: COL_COUNT];
                        st_q       <= ST_STREAM;
                    end

                    ST_STREAM: begin
                        // Feed rows into scheduler
                        if (scheduler_in_valid && scheduler_in_ready) begin
                            if (row_cnt_q == ROW_COUNT - 1) begin
                                // Last row accepted; do not move to ST_RD_REQ.
                                // Stay in ST_STREAM and wait for task output to finish.
                                // (Suppress re-presenting this row: scheduler ignores
                                //  in_valid once in_last was accepted and it is busy.)
                            end else begin
                                row_cnt_q <= row_cnt_q + 1'b1;
                                st_q      <= ST_RD_REQ;
                            end
                        end

                        // Collect tasks from scheduler
                        if (task_fire) begin
                            task_cnt_q <= task_cnt_q + 1'b1;

                            if (pack_slot_q == 2'd3 || scheduler_out_last) begin
                                // Capture full pack (including this task) via pack64_nxt,
                                // and record the word index BEFORE incrementing.
                                wr_pack_q     <= pack64_nxt;
                                wr_word_idx_q <= word_idx_q;
                                wr_last_q     <= scheduler_out_last;
                                word_idx_q    <= word_idx_q + 1'b1;
                                pack_slot_q   <= '0;
                                pack64_q      <= '0;
                                // Only transition to OBUF_WR; ST_FINISH is handled from there
                                st_q          <= ST_OBUF_WR;
                            end else begin
                                // Accumulate task into current pack using combinational nxt
                                pack64_q    <= pack64_nxt;
                                pack_slot_q <= pack_slot_q + 2'd1;
                            end
                        end
                        // Note: no separate ST_FINISH branch here;
                        // completion is determined in ST_OBUF_WR via wr_last_q.
                    end

                    ST_OBUF_WR: begin
                        // obuf write is purely combinational (1 cycle).
                        // Decide next state based on whether this was the last pack.
                        if (wr_last_q) begin
                            st_q <= ST_FINISH;
                        end else begin
                            st_q <= ST_STREAM;
                        end
                    end

                    ST_FINISH: begin
                        st_q <= ST_IDLE;
                    end

                    default: st_q <= ST_IDLE;
                endcase
            end
        end
    end

endmodule
