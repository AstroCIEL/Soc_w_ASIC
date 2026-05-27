module mxu_ctrl #(
    parameter int LANE_NUM                = 4,
    parameter int BANK_WIDTH              = 128,
    parameter int SEMI_TRANS_BUFFER_DEPTH = 16,
    parameter int ADDR_WIDTH              = 9,
    parameter int CFG_ADDR_WIDTH          = 4,
    parameter int ROW_DATA_WIDTH          = 2 * BANK_WIDTH
)(
    input  logic clk_i,
    input  logic rstn_i,

    // 主机端配置和命令握手。仅当控制器处于空闲状态时才接受配置写入
    input  logic                        cfg_set_i,
    input  logic [CFG_ADDR_WIDTH-1:0]   cfg_addr_i,
    input  logic [ADDR_WIDTH-1:0]       cfg_data_i,
    input  logic                        start_i,
    output logic                        busy_o,
    output logic                        done_o,

    // 输入缓冲区保存完整的16-bit元素行。每个lane每拍读出16个16-bit元素
    output logic [LANE_NUM-1:0]         wgt_buf_cen_o,
    output logic [LANE_NUM-1:0]         wgt_buf_wen_o,
    output logic [ADDR_WIDTH-1:0]       wgt_buf_addr_o [LANE_NUM-1:0],
    input  logic [ROW_DATA_WIDTH-1:0]   wgt_buf_dout_i [LANE_NUM-1:0],

    output logic [LANE_NUM-1:0]         act_buf_cen_o,
    output logic [LANE_NUM-1:0]         act_buf_wen_o,
    output logic [ADDR_WIDTH-1:0]       act_buf_addr_o [LANE_NUM-1:0],
    input  logic [ROW_DATA_WIDTH-1:0]   act_buf_dout_i [LANE_NUM-1:0],

    // 输出缓冲区同样以完整16-bit元素行写回
    output logic [LANE_NUM-1:0]         out_buf_cen_o,
    output logic [LANE_NUM-1:0]         out_buf_wen_o,
    output logic [ADDR_WIDTH-1:0]       out_buf_addr_o [LANE_NUM-1:0],
    output logic [ROW_DATA_WIDTH-1:0]   out_buf_din_o  [LANE_NUM-1:0],

    // 直接驱动`mxu_top_no_ctrl`的接口。lower/upper仅在这里作为8-bit拆分视图存在
    output logic                        in_valid_lower_o,
    output logic                        in_valid_upper_o,
    output logic [BANK_WIDTH-1:0]       data_in_lower_o [LANE_NUM-1:0],
    output logic [BANK_WIDTH-1:0]       data_in_upper_o [LANE_NUM-1:0],
    output logic [1:0]                  front_rotator_sel_o,
    output logic [$clog2(SEMI_TRANS_BUFFER_DEPTH)-1:0]
                                        semi_transposer_addr_in_o [LANE_NUM-1:0],
    output logic                        semi_transposer_start_putout_o,
    output logic                        sa_top_data_flow_mode_o,
    output logic                        sa_top_data_type_mode_o,
    output logic                        sa_top_act_or_wg_o,
    output logic [1:0]                  back_rotator_sel_o,

    // `mxu_top_no_ctrl`返回的状态和结果流
    input  logic                        sa_top_wgt_update_done_i [LANE_NUM-1:0],
    input  logic [BANK_WIDTH-1:0]       data_out_lower_i         [LANE_NUM-1:0],
    input  logic [BANK_WIDTH-1:0]       data_out_upper_i         [LANE_NUM-1:0],
    input  logic                        data_out_lower_valid_i,
    input  logic                        data_out_upper_valid_i,
    input  logic                        compute_done_i
);

localparam int SEMI_TRANS_ADDR_W = $clog2(SEMI_TRANS_BUFFER_DEPTH);
localparam int ELEM_WIDTH = ROW_DATA_WIDTH / BANK_WIDTH * 8;
localparam int ELEM_NUM = ROW_DATA_WIDTH / ELEM_WIDTH;
// localparam int ACT_TO_BACK_SEL_LATENCY_INT   = 1 + 2 * SEMI_TRANS_BUFFER_DEPTH;
// localparam int ACT_TO_BACK_SEL_LATENCY_POSIT = 1 + 3 * SEMI_TRANS_BUFFER_DEPTH;
// 数据通路在 SA -> rotator_back 之间加了 1 级流水（见 mxu_top_no_ctrl.sv 中 *_q 寄存器），
// 因此对应的 back_rotator_sel 管线也要延后同样的拍数
localparam int ROT_BACK_DATA_EXTRA_LATENCY   = 1;
localparam int ACT_TO_BACK_SEL_LATENCY_INT   =  2 * SEMI_TRANS_BUFFER_DEPTH + ROT_BACK_DATA_EXTRA_LATENCY;
localparam int ACT_TO_BACK_SEL_LATENCY_POSIT =  3 * SEMI_TRANS_BUFFER_DEPTH + ROT_BACK_DATA_EXTRA_LATENCY;
localparam int ACT_TO_BACK_SEL_PIPE_DEPTH    = ACT_TO_BACK_SEL_LATENCY_POSIT + 1;

// 软件可见的配置映射。地址0..12存储9位块基地址或批量大小值；
// 地址13..14仅使用cfg_data_i[0]位
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_WGT_TILE0_BASE_ADDR = 4'd0;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_WGT_TILE1_BASE_ADDR = 4'd1;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_WGT_TILE2_BASE_ADDR = 4'd2;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_WGT_TILE3_BASE_ADDR = 4'd3;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_ACT_TILE0_BASE_ADDR = 4'd4;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_ACT_TILE1_BASE_ADDR = 4'd5;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_ACT_TILE2_BASE_ADDR = 4'd6;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_ACT_TILE3_BASE_ADDR = 4'd7;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OUT_TILE0_BASE_ADDR = 4'd8;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OUT_TILE1_BASE_ADDR = 4'd9;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OUT_TILE2_BASE_ADDR = 4'd10;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_OUT_TILE3_BASE_ADDR = 4'd11;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_ACT_BATCHSIZE_M     = 4'd12;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_SA_DATA_FLOW_MODE   = 4'd13;
localparam logic [CFG_ADDR_WIDTH-1:0] CFG_SA_DATA_TYPE_MODE   = 4'd14;

// 主时序器镜像原始手动测试平台流程：
// 读取权重，启动半转置器输出，等待脉动阵列权重更新完成，
// 读取激活值，然后将有效结果写入输出缓冲区
typedef enum logic [3:0] {
    ST_IDLE,
    ST_WGT_REQ,
    ST_WGT_SEND,
    ST_WAIT_SEMI_FULL,
    ST_START_PUTOUT,
    ST_WAIT_WGT_DONE,
    ST_GAP,
    ST_ACT_REQ,
    ST_ACT_SEND,
    ST_WAIT_COMPUTE_DONE,
    ST_OUT_WRITE,
    ST_DONE
} state_e;

state_e state_q, state_d;

logic [ADDR_WIDTH-1:0] wgt_tile_base_addr_reg [LANE_NUM-1:0];
logic [ADDR_WIDTH-1:0] act_tile_base_addr_reg [LANE_NUM-1:0];
logic [ADDR_WIDTH-1:0] out_tile_base_addr_reg [LANE_NUM-1:0];
logic [ADDR_WIDTH-1:0] act_tile_batchsize_M_reg;
logic                  sa_top_data_flow_mode_reg;
logic                  sa_top_data_type_mode_reg;

// 行计数器索引当前块的行。`semi_addr_cnt_q`有意跟随延迟的输入有效信号，
// 以匹配前旋转器的一个周期延迟
logic [ADDR_WIDTH-1:0] wgt_row_cnt_q;
logic [ADDR_WIDTH-1:0] act_row_cnt_q;
logic [ADDR_WIDTH-1:0] out_row_cnt_q;
logic [SEMI_TRANS_ADDR_W-1:0] semi_addr_cnt_q;
logic in_valid_lower_d1_q;
logic wgt_done_seen_q;
logic output_seen_q;

logic wgt_send_last;
logic act_send_last;
logic wgt_has_next;
logic act_has_next;
logic [ADDR_WIDTH-1:0] wgt_buf_row_addr;
logic [1:0] wgt_send_group;
logic [1:0] wgt_req_group;
logic [ADDR_WIDTH-1:0] wgt_req_intra_row;
logic [1:0] semi_write_group;
logic [1:0] semi_write_intra_row;
logic [ADDR_WIDTH-1:0] act_buf_row_addr;
logic [ADDR_WIDTH-1:0] act_chunk_size;
logic [ADDR_WIDTH-1:0] act_chunk_size_safe;

// 用计数器替代除法/取模：在 cfg-time 寄存 chunk_size_safe，并维护 3 组同步递增的
// (group, intra) 计数器，精确复现 R/C 与 R%C 的语义，消除动态 9-bit 除法器/取模器。
logic [ADDR_WIDTH-1:0] act_chunk_size_safe_q;
logic [ADDR_WIDTH-1:0] act_send_group_q;
logic [ADDR_WIDTH-1:0] act_send_intra_q;
logic [ADDR_WIDTH-1:0] act_req_group_q;
logic [ADDR_WIDTH-1:0] act_req_intra_q;
logic [ADDR_WIDTH-1:0] out_write_group_q;
logic [ADDR_WIDTH-1:0] out_write_intra_q;
logic [1:0] act_back_sel_pipe_q [ACT_TO_BACK_SEL_PIPE_DEPTH-1:0];
logic [ACT_TO_BACK_SEL_PIPE_DEPTH-1:0] act_back_sel_valid_pipe_q;
logic wgt_done_active;
logic output_valid;
logic output_write_fire;
logic start_accepted;

// 出口流水切割（性能与时序友好）：把 out_buf_* 组合输出改为寄存器输出
// 写 SRAM 的 cen/wen/addr/din 全部经 _q FF 后再驱动 out_buf_*_o，
// 让长组合路径（output_valid + state_q + per-lane 译码 + 除法/取模）
// 整段被 FF 切断，缓解 u_out_buffer/ab/wenb/cenb 上的 setup 违例。
logic [LANE_NUM-1:0]       out_buf_cen_d, out_buf_cen_q;
logic [LANE_NUM-1:0]       out_buf_wen_d, out_buf_wen_q;
logic [ADDR_WIDTH-1:0]     out_buf_addr_d [LANE_NUM-1:0];
logic [ADDR_WIDTH-1:0]     out_buf_addr_q [LANE_NUM-1:0];
logic [ROW_DATA_WIDTH-1:0] out_buf_din_d  [LANE_NUM-1:0];
logic [ROW_DATA_WIDTH-1:0] out_buf_din_q  [LANE_NUM-1:0];

assign wgt_send_last     = wgt_row_cnt_q == ADDR_WIDTH'(SEMI_TRANS_BUFFER_DEPTH - 1);
assign act_send_last     = (act_tile_batchsize_M_reg != '0) &&
                           (act_row_cnt_q == act_tile_batchsize_M_reg - ADDR_WIDTH'(1));
assign wgt_has_next      = !wgt_send_last;
assign act_has_next      = (act_tile_batchsize_M_reg != '0) &&
                           (act_row_cnt_q < act_tile_batchsize_M_reg - ADDR_WIDTH'(1));
assign wgt_buf_row_addr  = ((state_q == ST_WGT_SEND) && wgt_has_next) ?
                           wgt_row_cnt_q + ADDR_WIDTH'(1) : wgt_row_cnt_q;
assign wgt_send_group      = wgt_row_cnt_q[3:2];
assign wgt_req_group       = wgt_buf_row_addr[3:2];
assign wgt_req_intra_row   = ADDR_WIDTH'(wgt_buf_row_addr[1:0]);
assign semi_write_group     = semi_addr_cnt_q[3:2];
assign semi_write_intra_row = semi_addr_cnt_q[1:0];
assign act_buf_row_addr     = ((state_q == ST_ACT_SEND) && act_has_next) ?
                              act_row_cnt_q + ADDR_WIDTH'(1) : act_row_cnt_q;
assign act_chunk_size       = act_tile_batchsize_M_reg >> 2;
assign act_chunk_size_safe  = (act_chunk_size == '0) ? ADDR_WIDTH'(1) : act_chunk_size;
// 注意：原本基于 act_chunk_size_safe 的 4 个动态除法器和 1 个取模器已被
// (group, intra) 计数器（act_send_*_q / act_req_*_q / out_write_*_q）替代。
assign output_valid         = data_out_lower_valid_i | data_out_upper_valid_i;
assign output_write_fire = ((state_q == ST_WAIT_COMPUTE_DONE) || (state_q == ST_OUT_WRITE)) && output_valid;
assign start_accepted    = (state_q == ST_IDLE) && start_i && !cfg_set_i;

initial begin
    if (ELEM_WIDTH != 16 || ELEM_NUM * 8 != BANK_WIDTH) begin
        $fatal(1, "mxu_ctrl: expected ROW_DATA_WIDTH to describe BANK_WIDTH/8 16-bit elements");
    end
end

always_comb begin
    // `sa_top_wgt_update_done_i`是一个解包数组，因此显式进行归约操作，
    // 而不是依赖于工具相关的数组类型转换
    wgt_done_active = 1'b0;
    for (int lane = 0; lane < LANE_NUM; lane++) begin
        wgt_done_active |= sa_top_wgt_update_done_i[lane];
    end
end

always_comb begin
    // 状态转换与输出生成分开，以便SRAM请求/发送阶段易于审计1周期的读取延迟
    state_d = state_q;

    unique case (state_q)
        ST_IDLE: begin
            if (start_i && !cfg_set_i) begin
                state_d = ST_WGT_REQ;
            end
        end

        ST_WGT_REQ: begin
            state_d = ST_WGT_SEND;
        end

        ST_WGT_SEND: begin
            state_d = wgt_send_last ? ST_WAIT_SEMI_FULL : ST_WGT_SEND;
        end

        ST_WAIT_SEMI_FULL: begin
            state_d = ST_START_PUTOUT;
        end

        ST_START_PUTOUT: begin
            state_d = ST_WAIT_WGT_DONE;
        end

        ST_WAIT_WGT_DONE: begin
            if (wgt_done_seen_q && !wgt_done_active) begin
                state_d = ST_GAP;
            end
        end

        ST_GAP: begin
            state_d = (act_tile_batchsize_M_reg == '0) ? ST_DONE : ST_ACT_REQ;
        end

        ST_ACT_REQ: begin
            state_d = ST_ACT_SEND;
        end

        ST_ACT_SEND: begin
            state_d = act_send_last ? ST_WAIT_COMPUTE_DONE : ST_ACT_SEND;
        end

        ST_WAIT_COMPUTE_DONE: begin
            if (output_valid) begin
                state_d = ST_OUT_WRITE;
            end else if (compute_done_i) begin
                state_d = ST_DONE;
            end
        end

        ST_OUT_WRITE: begin
            if (output_seen_q && !output_valid) begin
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
    // 默认所有SRAM端口为空闲状态(`cen=1`)。下面的活跃状态仅启用该周期所需的缓冲区
    busy_o                         = state_q != ST_IDLE;
    done_o                         = state_q == ST_DONE;
    in_valid_lower_o               = 1'b0;
    in_valid_upper_o               = 1'b0;
    front_rotator_sel_o            = 2'b00;
    semi_transposer_start_putout_o = state_q == ST_START_PUTOUT;
    sa_top_data_flow_mode_o        = sa_top_data_flow_mode_reg;
    sa_top_data_type_mode_o        = sa_top_data_type_mode_reg;
    sa_top_act_or_wg_o             = 1'b0;
    back_rotator_sel_o             = 2'b00;
    if (sa_top_data_type_mode_reg) begin
        if (act_back_sel_valid_pipe_q[ACT_TO_BACK_SEL_LATENCY_INT]) begin
            back_rotator_sel_o = act_back_sel_pipe_q[ACT_TO_BACK_SEL_LATENCY_INT];
        end
    end else begin
        if (act_back_sel_valid_pipe_q[ACT_TO_BACK_SEL_LATENCY_POSIT]) begin
            back_rotator_sel_o = act_back_sel_pipe_q[ACT_TO_BACK_SEL_LATENCY_POSIT];
        end
    end

    wgt_buf_cen_o = '1;
    wgt_buf_wen_o = '0;
    act_buf_cen_o = '1;
    act_buf_wen_o = '0;
    out_buf_cen_d = '1;
    out_buf_wen_d = '0;

    for (int lane = 0; lane < LANE_NUM; lane++) begin
        wgt_buf_addr_o[lane]             = wgt_tile_base_addr_reg[(lane[1:0] - wgt_req_group) & 2'b11] + wgt_req_intra_row;
        act_buf_addr_o[lane]             = act_tile_base_addr_reg[(lane[1:0] - act_req_group_q[1:0]) & 2'b11] + act_req_intra_q;
        out_buf_addr_d[lane]             = out_tile_base_addr_reg[(lane[1:0] - out_write_group_q[1:0]) & 2'b11] + out_write_intra_q;
        out_buf_din_d[lane]              = '0;
        data_in_lower_o[lane]            = '0;
        data_in_upper_o[lane]            = '0;
        if ((state_q == ST_WGT_SEND) || (state_q == ST_WAIT_SEMI_FULL)) begin
            semi_transposer_addr_in_o[lane] = {((lane[1:0] + semi_write_group) & 2'b11), semi_write_intra_row};
        end else begin
            semi_transposer_addr_in_o[lane] = semi_addr_cnt_q;
        end
    end

    unique case (state_q)
        ST_WGT_REQ: begin
            // 发起同步SRAM读取。数据在ST_WGT_SEND阶段被消费
            sa_top_act_or_wg_o = 1'b1;
            wgt_buf_cen_o      = '0;
        end

        ST_WGT_SEND: begin
            sa_top_act_or_wg_o  = 1'b1;
            in_valid_lower_o    = 1'b1;
            in_valid_upper_o    = !sa_top_data_type_mode_reg;
            front_rotator_sel_o = 2'b00 - wgt_send_group;
            if (wgt_has_next) begin
                wgt_buf_cen_o = '0;
            end
            for (int lane = 0; lane < LANE_NUM; lane++) begin
                for (int pe = 0; pe < ELEM_NUM; pe++) begin
                    if (sa_top_data_type_mode_reg) begin
                        data_in_lower_o[lane][pe * 8 +: 8] = wgt_buf_dout_i[lane][pe * 8 +: 8];
                    end else begin
                        data_in_lower_o[lane][pe * 8 +: 8] = wgt_buf_dout_i[lane][pe * ELEM_WIDTH +: 8];
                        data_in_upper_o[lane][pe * 8 +: 8] = wgt_buf_dout_i[lane][pe * ELEM_WIDTH + 8 +: 8];
                    end
                end
            end
        end

        ST_WAIT_SEMI_FULL,
        ST_START_PUTOUT,
        ST_WAIT_WGT_DONE: begin
            sa_top_act_or_wg_o = 1'b1;
        end

        ST_ACT_REQ: begin
            // 激活数据绕过mxu_top_no_ctrl内部的半转置器
            act_buf_cen_o = '0;
        end

        ST_ACT_SEND: begin
            in_valid_lower_o   = 1'b1;
            in_valid_upper_o   = !sa_top_data_type_mode_reg;
            front_rotator_sel_o = 2'b00 - act_send_group_q[1:0];
            if (act_has_next) begin
                act_buf_cen_o = '0;
            end
            for (int lane = 0; lane < LANE_NUM; lane++) begin
                for (int pe = 0; pe < ELEM_NUM; pe++) begin
                    if (sa_top_data_type_mode_reg) begin
                        data_in_lower_o[lane][pe * 8 +: 8] = act_buf_dout_i[lane][pe * 8 +: 8];
                    end else begin
                        data_in_lower_o[lane][pe * 8 +: 8] = act_buf_dout_i[lane][pe * ELEM_WIDTH +: 8];
                        data_in_upper_o[lane][pe * 8 +: 8] = act_buf_dout_i[lane][pe * ELEM_WIDTH + 8 +: 8];
                    end
                end
            end
        end

        ST_WAIT_COMPUTE_DONE,
        ST_OUT_WRITE: begin
            // 结果有效信号可能在compute_done_i之前到达；写入每个有效输出行，
            // 并在有效突发信号撤销后完成
            if (output_valid) begin
                out_buf_cen_d = '0;
                out_buf_wen_d = '1;
                for (int lane = 0; lane < LANE_NUM; lane++) begin
                    for (int pe = 0; pe < ELEM_NUM; pe++) begin
                        out_buf_din_d[lane][pe * ELEM_WIDTH +: 8]     = data_out_lower_i[lane][pe * 8 +: 8];
                        out_buf_din_d[lane][pe * ELEM_WIDTH + 8 +: 8] = data_out_upper_i[lane][pe * 8 +: 8];
                    end
                end
            end
        end

        default:;
    endcase
end

// 端口 = 寄存后的输出（注意外部接口形状不变）
assign out_buf_cen_o  = out_buf_cen_q;
assign out_buf_wen_o  = out_buf_wen_q;
generate
    for (genvar lane = 0; lane < LANE_NUM; lane++) begin : gen_out_buf_port_q
        assign out_buf_addr_o[lane] = out_buf_addr_q[lane];
        assign out_buf_din_o[lane]  = out_buf_din_q[lane];
    end
endgenerate

// 把 out_buf_* 组合输出寄存一拍，作为最终送出 mxu_ctrl 的端口值
always_ff @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        out_buf_cen_q <= '1;     // SRAM cen=1 = idle，安全默认
        out_buf_wen_q <= '0;
        for (int lane = 0; lane < LANE_NUM; lane++) begin
            out_buf_addr_q[lane] <= '0;
            out_buf_din_q[lane]  <= '0;
        end
    end else begin
        out_buf_cen_q  <= out_buf_cen_d;
        out_buf_wen_q  <= out_buf_wen_d;
        for (int lane = 0; lane < LANE_NUM; lane++) begin
            out_buf_addr_q[lane] <= out_buf_addr_d[lane];
            out_buf_din_q[lane]  <= out_buf_din_d[lane];
        end
    end
end

always_ff @(posedge clk_i or negedge rstn_i) begin
    if (!rstn_i) begin
        state_q                   <= ST_IDLE;
        wgt_row_cnt_q             <= '0;
        act_row_cnt_q             <= '0;
        out_row_cnt_q             <= '0;
        semi_addr_cnt_q           <= '0;
        in_valid_lower_d1_q       <= 1'b0;
        wgt_done_seen_q           <= 1'b0;
        output_seen_q             <= 1'b0;
        act_tile_batchsize_M_reg  <= '0;
        sa_top_data_flow_mode_reg <= 1'b0;
        sa_top_data_type_mode_reg <= 1'b0;
        for (int lane = 0; lane < LANE_NUM; lane++) begin
            wgt_tile_base_addr_reg[lane] <= '0;
            act_tile_base_addr_reg[lane] <= '0;
            out_tile_base_addr_reg[lane] <= '0;
        end
        for (int pipe_idx = 0; pipe_idx < ACT_TO_BACK_SEL_PIPE_DEPTH; pipe_idx++) begin
            act_back_sel_pipe_q[pipe_idx] <= '0;
        end
        act_back_sel_valid_pipe_q <= '0;
        act_chunk_size_safe_q <= ADDR_WIDTH'(1);
        act_send_group_q      <= '0;
        act_send_intra_q      <= '0;
        act_req_group_q       <= '0;
        act_req_intra_q       <= '0;
        out_write_group_q     <= '0;
        out_write_intra_q     <= '0;
    end else begin
        state_q             <= state_d;
        in_valid_lower_d1_q <= in_valid_lower_o;

        if (state_q == ST_IDLE && cfg_set_i) begin
            // 忙碌时忽略配置写入，以保持正在处理的块的自一致性
            unique case (cfg_addr_i)
                CFG_WGT_TILE0_BASE_ADDR: wgt_tile_base_addr_reg[0] <= cfg_data_i;
                CFG_WGT_TILE1_BASE_ADDR: wgt_tile_base_addr_reg[1] <= cfg_data_i;
                CFG_WGT_TILE2_BASE_ADDR: wgt_tile_base_addr_reg[2] <= cfg_data_i;
                CFG_WGT_TILE3_BASE_ADDR: wgt_tile_base_addr_reg[3] <= cfg_data_i;
                CFG_ACT_TILE0_BASE_ADDR: act_tile_base_addr_reg[0] <= cfg_data_i;
                CFG_ACT_TILE1_BASE_ADDR: act_tile_base_addr_reg[1] <= cfg_data_i;
                CFG_ACT_TILE2_BASE_ADDR: act_tile_base_addr_reg[2] <= cfg_data_i;
                CFG_ACT_TILE3_BASE_ADDR: act_tile_base_addr_reg[3] <= cfg_data_i;
                CFG_OUT_TILE0_BASE_ADDR: out_tile_base_addr_reg[0] <= cfg_data_i;
                CFG_OUT_TILE1_BASE_ADDR: out_tile_base_addr_reg[1] <= cfg_data_i;
                CFG_OUT_TILE2_BASE_ADDR: out_tile_base_addr_reg[2] <= cfg_data_i;
                CFG_OUT_TILE3_BASE_ADDR: out_tile_base_addr_reg[3] <= cfg_data_i;
                CFG_ACT_BATCHSIZE_M:     act_tile_batchsize_M_reg  <= cfg_data_i;
                CFG_SA_DATA_FLOW_MODE:   sa_top_data_flow_mode_reg <= cfg_data_i[0];
                CFG_SA_DATA_TYPE_MODE:   sa_top_data_type_mode_reg <= cfg_data_i[0];
                default:;
            endcase
        end

        if (start_accepted) begin
            // 新命令总是从每个配置块的第零行开始
            wgt_row_cnt_q       <= '0;
            act_row_cnt_q       <= '0;
            out_row_cnt_q       <= '0;
            semi_addr_cnt_q     <= '0;
            in_valid_lower_d1_q <= 1'b0;
            wgt_done_seen_q     <= 1'b0;
            output_seen_q       <= 1'b0;
            for (int pipe_idx = 0; pipe_idx < ACT_TO_BACK_SEL_PIPE_DEPTH; pipe_idx++) begin
                act_back_sel_pipe_q[pipe_idx] <= '0;
            end
            act_back_sel_valid_pipe_q <= '0;
            // 用当前已生效的 M 寄存 C = max(M/4, 1)；在整个计算期间保持不变
            act_chunk_size_safe_q <= act_chunk_size_safe;
            act_send_group_q      <= '0;
            act_send_intra_q      <= '0;
            act_req_group_q       <= '0;
            act_req_intra_q       <= '0;
            out_write_group_q     <= '0;
            out_write_intra_q     <= '0;
        end else begin
            act_back_sel_pipe_q[0]       <= (state_q == ST_ACT_SEND) ? act_send_group_q[1:0] : 2'b00;
            act_back_sel_valid_pipe_q[0] <= (state_q == ST_ACT_SEND);
            for (int pipe_idx = 1; pipe_idx < ACT_TO_BACK_SEL_PIPE_DEPTH; pipe_idx++) begin
                act_back_sel_pipe_q[pipe_idx]       <= act_back_sel_pipe_q[pipe_idx - 1];
                act_back_sel_valid_pipe_q[pipe_idx] <= act_back_sel_valid_pipe_q[pipe_idx - 1];
            end

            if (state_q == ST_WGT_SEND && !wgt_send_last) begin
                wgt_row_cnt_q <= wgt_row_cnt_q + ADDR_WIDTH'(1);
            end

            if (state_q == ST_ACT_SEND && !act_send_last) begin
                act_row_cnt_q <= act_row_cnt_q + ADDR_WIDTH'(1);
            end

            if (output_write_fire) begin
                out_row_cnt_q <= out_row_cnt_q + ADDR_WIDTH'(1);
                output_seen_q <= 1'b1;
            end

            if (in_valid_lower_d1_q) begin
                // 半转置器写入地址必须与旋转器输出有效信号对齐，
                // 该信号比mxu输入有效信号晚一个周期
                semi_addr_cnt_q <= semi_addr_cnt_q + SEMI_TRANS_ADDR_W'(1);
            end

            if (state_q == ST_WAIT_WGT_DONE && wgt_done_active) begin
                wgt_done_seen_q <= 1'b1;
            end

            // (group, intra) 计数器同步递增：精确等价于 R/C, R%C
            // ---- act_send_* 与 act_row_cnt_q 同步（条件：ST_ACT_SEND && !act_send_last）
            if (state_q == ST_ACT_SEND && !act_send_last) begin
                if (act_send_intra_q == act_chunk_size_safe_q - ADDR_WIDTH'(1)) begin
                    act_send_intra_q <= '0;
                    act_send_group_q <= act_send_group_q + ADDR_WIDTH'(1);
                end else begin
                    act_send_intra_q <= act_send_intra_q + ADDR_WIDTH'(1);
                end
            end

            // ---- act_req_* 提前 send 1 拍（条件：ST_ACT_REQ || ST_ACT_SEND && act_has_next）
            //      ST_ACT_REQ 当拍 cnt=0，下一拍变 ST_ACT_SEND，req 需要 = 1；
            //      ST_ACT_SEND 内随 send 同步前进。
            if ((state_q == ST_ACT_REQ) ||
                (state_q == ST_ACT_SEND && act_has_next)) begin
                if (act_req_intra_q == act_chunk_size_safe_q - ADDR_WIDTH'(1)) begin
                    act_req_intra_q <= '0;
                    act_req_group_q <= act_req_group_q + ADDR_WIDTH'(1);
                end else begin
                    act_req_intra_q <= act_req_intra_q + ADDR_WIDTH'(1);
                end
            end

            // ---- out_write_* 与 out_row_cnt_q 同步（条件：output_write_fire）
            if (output_write_fire) begin
                if (out_write_intra_q == act_chunk_size_safe_q - ADDR_WIDTH'(1)) begin
                    out_write_intra_q <= '0;
                    out_write_group_q <= out_write_group_q + ADDR_WIDTH'(1);
                end else begin
                    out_write_intra_q <= out_write_intra_q + ADDR_WIDTH'(1);
                end
            end
        end

        if (state_q == ST_DONE) begin
            output_seen_q <= 1'b0;
        end
    end
end

endmodule
