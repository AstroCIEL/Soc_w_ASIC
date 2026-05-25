// ============================================================================
// scheduler 顶层模块
// ----------------------------------------------------------------------------
// 功能概述：
//   1) 通过流式接口逐行接收一个 ROW_COUNT x COL_COUNT 的 0/1 掩码矩阵
//      （每一行代表该行在各列上是否存在任务）。
//   2) 将 COL_COUNT 列按 GROUP_SIZE 一组进行分组（共 GROUP_COUNT 组），
//      采用贪心策略使每组内列的 OR 之和（即该组覆盖的行数）尽可能小，
//      以平衡各组负载。
//   3) 按分组依次输出所有任务 (row, col)，并附带分组号、lane、slot
//      等调度信息供下游使用。
// 状态机：S_IDLE -> S_LOAD -> S_RUN_V4 -> S_EMIT -> S_DONE
// ============================================================================
module scheduler #(
    parameter int ROW_COUNT   = 16,                       // 矩阵行数
    parameter int COL_COUNT   = 16,                       // 矩阵列数
    parameter int GROUP_SIZE  = 4,                        // 每个分组包含的列数
    parameter int GROUP_COUNT = COL_COUNT / GROUP_SIZE,   // 分组总数
    parameter int ROW_W       = $clog2(ROW_COUNT),        // 行索引位宽
    parameter int COL_W       = $clog2(COL_COUNT),        // 列索引位宽
    parameter int GROUP_W     = $clog2(GROUP_COUNT),      // 分组索引位宽
    parameter int LANE_W      = $clog2(GROUP_SIZE),       // 组内 lane 索引位宽
    parameter int SLOT_W      = $clog2(ROW_COUNT),        // 时间槽位宽
    parameter int POP_W       = $clog2(ROW_COUNT + 1),    // popcount 位宽（最多 ROW_COUNT）
    parameter int TOTAL_W     = $clog2(ROW_COUNT * COL_COUNT + 1) // 任务总数位宽
)(
    input  logic                 clk_i,                   // 时钟
    input  logic                 rstn_i,                  // 异步低有效复位

    input  logic                 start_i,                 // 启动调度流程（高电平触发一次任务）

    // -------------------- 输入流：逐行掩码 --------------------
    input  logic                 in_valid_i,              // 输入数据有效
    output logic                 in_ready_o,              // 模块准备好接收
    input  logic [COL_COUNT-1:0] in_row_mask_i,           // 当前行的列掩码（每位代表该列是否有任务）
    input  logic [ROW_W-1:0]     in_row_idx_i,            // 当前行的行号（必须按顺序 0..ROW_COUNT-1）
    input  logic                 in_last_i,               // 是否为最后一行（与 row_idx == ROW_COUNT-1 必须一致）

    // -------------------- 输出流：调度后的任务 --------------------
    output logic                 out_valid_o,             // 输出有效
    input  logic                 out_ready_i,             // 下游就绪
    output logic [GROUP_W-1:0]   out_group_o,             // 任务所属的分组号
    output logic [LANE_W-1:0]    out_lane_o,              // 组内 lane 号（同一 slot 内的并行通道）
    output logic [SLOT_W-1:0]    out_slot_o,              // 时间槽号
    output logic [ROW_W-1:0]     out_row_o,               // 任务对应的行号
    output logic [COL_W-1:0]     out_col_o,               // 任务对应的列号
    output logic                 out_group_last_o,        // 是否为当前分组的最后一个任务
    output logic                 out_last_o,              // 是否为整次调度的最后一个任务

    // -------------------- 状态指示 --------------------
    output logic                 busy_o,                  // 调度进行中
    output logic                 done_o,                  // 调度完成
    output logic                 error_o                  // 出现错误（如行号不连续/last 不匹配）
);

    // 顶层状态机的状态定义
    typedef enum logic [2:0] {
        S_IDLE,      // 空闲，等待 start_i
        S_LOAD,      // 加载阶段：流式接收掩码矩阵
        S_RUN_V4,    // 分组阶段：贪心算法将列分组
        S_EMIT,      // 发射阶段：按分组输出任务流
        S_DONE,      // 完成
        S_ERROR      // 错误（输入协议异常）
    } sched_state_e;

    sched_state_e state_q, state_d; // _q 当前态，_d 次态

    // ---- 子模块 1：mask_stream_loader 的握手与输出 ----
    logic loader_start;                              // 启动 loader
    logic loader_done;                               // loader 完成
    logic loader_error;                              // loader 检测到错误
    logic [ROW_COUNT-1:0] col_bits [COL_COUNT];      // 按列重新组织后的位图（col_bits[c][r]=mask[r][c]）
    logic [POP_W-1:0] col_popcnt [COL_COUNT];        // 每一列的 1 的个数
    logic [TOTAL_W-1:0] total_task_count;            // 整个矩阵的任务总数

    // ---- 子模块 2：v4_group_engine 的握手与输出 ----
    logic v4_start;                                  // 启动分组引擎
    logic v4_done;                                   // 分组引擎完成
    logic [COL_W-1:0] group_col_idx [GROUP_COUNT][GROUP_SIZE]; // 每组包含的列号
    logic [POP_W-1:0] group_cost [GROUP_COUNT];      // 每组的代价（组内列 OR 后的 popcount）
    logic [ROW_COUNT-1:0] group_or_bits [GROUP_COUNT]; // 每组覆盖到的行位图

    // ---- 子模块 3：task_stream_emitter 的握手 ----
    logic emitter_start;
    logic emitter_done;

    // 由状态转移沿生成各子模块的 start 脉冲
    assign loader_start  = (state_q == S_IDLE) && start_i;                  // 进入 LOAD 的瞬间
    assign v4_start      = (state_q == S_LOAD) && (state_d == S_RUN_V4);    // 进入 RUN_V4 的瞬间
    assign emitter_start = (state_q == S_RUN_V4) && (state_d == S_EMIT);    // 进入 EMIT 的瞬间

    // 对外状态指示
    assign busy_o  = (state_q != S_IDLE) && (state_q != S_DONE) && (state_q != S_ERROR);
    assign done_o  = (state_q == S_DONE);
    assign error_o = (state_q == S_ERROR) || loader_error;

    // -------------------- 顶层状态机：次态逻辑（组合） --------------------
    always_comb begin
        state_d = state_q;
        unique case (state_q)
            S_IDLE: begin
                // 收到启动信号后进入加载阶段
                if (start_i) begin
                    state_d = S_LOAD;
                end
            end
            S_LOAD: begin
                // 加载阶段如出错则跳到 ERROR，否则等待 loader_done 进入分组阶段
                if (loader_error) begin
                    state_d = S_ERROR;
                end else if (loader_done) begin
                    state_d = S_RUN_V4;
                end
            end
            S_RUN_V4: begin
                // 分组完成后进入任务发射阶段
                if (v4_done) begin
                    state_d = S_EMIT;
                end
            end
            S_EMIT: begin
                // 全部任务发射完毕进入 DONE
                if (emitter_done) begin
                    state_d = S_DONE;
                end
            end
            S_DONE: begin
                // 等待上位机撤销 start_i 后回到 IDLE，准备下一次调度
                if (!start_i) begin
                    state_d = S_IDLE;
                end
            end
            S_ERROR: begin
                // 同样等待 start_i 撤销，避免重复触发
                if (!start_i) begin
                    state_d = S_IDLE;
                end
            end
            default: begin
                state_d = S_IDLE;
            end
        endcase
    end

    // -------------------- 顶层状态机：状态寄存器 --------------------
    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            state_q <= S_IDLE;
        end else begin
            state_q <= state_d;
        end
    end

    // -------------------- 子模块 1：掩码流加载器 --------------------
    mask_stream_loader #(
        .ROW_COUNT(ROW_COUNT),
        .COL_COUNT(COL_COUNT),
        .ROW_W(ROW_W),
        .POP_W(POP_W),
        .TOTAL_W(TOTAL_W)
    ) u_mask_stream_loader (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .start_i(loader_start),
        .in_valid_i(in_valid_i),
        .in_ready_o(in_ready_o),
        .in_row_mask_i(in_row_mask_i),
        .in_row_idx_i(in_row_idx_i),
        .in_last_i(in_last_i),
        .load_done_o(loader_done),
        .load_error_o(loader_error),
        .col_bits_o(col_bits),
        .col_popcnt_o(col_popcnt),
        .total_task_count_o(total_task_count)
    );

    v4_group_engine #(
        .ROW_COUNT(ROW_COUNT),
        .COL_COUNT(COL_COUNT),
        .GROUP_SIZE(GROUP_SIZE),
        .GROUP_COUNT(GROUP_COUNT),
        .COL_W(COL_W),
        .POP_W(POP_W)
    ) u_v4_group_engine (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .start_i(v4_start),
        .col_bits_i(col_bits),                // 输入：列位图
        .col_popcnt_i(col_popcnt),             // 输入：列 popcount
        .done_o(v4_done),
        .group_col_idx_o(group_col_idx),       // 输出：每组的列索引
        .group_cost_o(group_cost),             // 输出：每组覆盖的行数
        .group_or_bits_o(group_or_bits)        // 输出：每组覆盖到的行位图
    );

    // -------------------- 子模块 3：任务发射器 --------------------
    // 遍历每个分组，按 (row, lane) 顺序扫描组内各列的位图，
    // 将每个 bit=1 的位置作为一个任务输出。
    task_stream_emitter #(
        .ROW_COUNT(ROW_COUNT),
        .COL_COUNT(COL_COUNT),
        .GROUP_SIZE(GROUP_SIZE),
        .GROUP_COUNT(GROUP_COUNT),
        .ROW_W(ROW_W),
        .COL_W(COL_W),
        .GROUP_W(GROUP_W),
        .LANE_W(LANE_W),
        .SLOT_W(SLOT_W),
        .POP_W(POP_W),
        .TOTAL_W(TOTAL_W)
    ) u_task_stream_emitter (
        .clk_i(clk_i),
        .rstn_i(rstn_i),
        .start_i(emitter_start),
        .col_bits_i(col_bits),
        .col_popcnt_i(col_popcnt),
        .total_task_count_i(total_task_count),
        .group_col_idx_i(group_col_idx),
        .out_ready_i(out_ready_i),
        .out_valid_o(out_valid_o),
        .out_group_o(out_group_o),
        .out_lane_o(out_lane_o),
        .out_slot_o(out_slot_o),
        .out_row_o(out_row_o),
        .out_col_o(out_col_o),
        .out_group_last_o(out_group_last_o),
        .out_last_o(out_last_o),
        .done_o(emitter_done)
    );

endmodule


// ============================================================================
// mask_stream_loader：掩码流加载器
// ----------------------------------------------------------------------------
// 通过 valid/ready 握手接口逐行接收 in_row_mask_i（COL_COUNT bit），
// 将其按"列优先"方式重组，得到：
//   - col_bits_o[c][r]   : 第 c 列在第 r 行的位
//   - col_popcnt_o[c]    : 第 c 列上 1 的总数
//   - total_task_count_o : 全矩阵 1 的总数（即任务总数）
// 同时校验输入协议：
//   - 行号必须严格按 0,1,...,ROW_COUNT-1 顺序到达
//   - in_last_i 必须且只能与最后一行同拍出现
// 出现协议错误时拉高 load_error_o，并停止接收。
// ============================================================================
module mask_stream_loader #(
    parameter int ROW_COUNT = 16,
    parameter int COL_COUNT = 16,
    parameter int ROW_W     = $clog2(ROW_COUNT),
    parameter int POP_W     = $clog2(ROW_COUNT + 1),
    parameter int TOTAL_W   = $clog2(ROW_COUNT * COL_COUNT + 1)
)(
    input  logic                 clk_i,
    input  logic                 rstn_i,
    input  logic                 start_i,               // 启动加载
    input  logic                 in_valid_i,            // 输入握手
    output logic                 in_ready_o,
    input  logic [COL_COUNT-1:0] in_row_mask_i,         // 当前行的列掩码
    input  logic [ROW_W-1:0]     in_row_idx_i,          // 当前行号
    input  logic                 in_last_i,             // 末行标志
    output logic                 load_done_o,           // 加载完成（单周期脉冲）
    output logic                 load_error_o,          // 加载出错（锁存直到下次 start）
    output logic [ROW_COUNT-1:0] col_bits_o [COL_COUNT],
    output logic [POP_W-1:0]     col_popcnt_o [COL_COUNT],
    output logic [TOTAL_W-1:0]   total_task_count_o
);

    logic loading_q;                       // 是否正在接收数据
    logic [ROW_W:0] row_count_q;           // 期望的下一行行号
    logic accept_row;                      // 当前拍是否完成一次行握手
    logic [TOTAL_W-1:0] row_task_count;    // 当前行包含的任务数（in_row_mask_i 的 popcount）

    // 仅在加载中且未结束未出错时才能接收
    assign in_ready_o = loading_q && !load_done_o && !load_error_o;
    assign accept_row = in_valid_i && in_ready_o;

    integer col_idx_comb;
    integer col_idx_ff;

    // 组合计算当前行 mask 的 popcount
    always_comb begin
        row_task_count = '0;
        for (col_idx_comb = 0; col_idx_comb < COL_COUNT; col_idx_comb++) begin
            row_task_count = row_task_count + {{(TOTAL_W-1){1'b0}}, in_row_mask_i[col_idx_comb]};
        end
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // 复位：清空所有寄存器与输出
            loading_q <= 1'b0;
            row_count_q <= '0;
            load_done_o <= 1'b0;
            load_error_o <= 1'b0;
            total_task_count_o <= '0;
            for (col_idx_ff = 0; col_idx_ff < COL_COUNT; col_idx_ff++) begin
                col_bits_o[col_idx_ff] <= '0;
                col_popcnt_o[col_idx_ff] <= '0;
            end
        end else begin
            load_done_o <= 1'b0; // done 默认每拍清零，仅在收尾那一拍拉高

            if (start_i) begin
                // 启动一次新的加载：清空累加器
                loading_q <= 1'b1;
                row_count_q <= '0;
                load_error_o <= 1'b0;
                total_task_count_o <= '0;
                for (col_idx_ff = 0; col_idx_ff < COL_COUNT; col_idx_ff++) begin
                    col_bits_o[col_idx_ff] <= '0;
                    col_popcnt_o[col_idx_ff] <= '0;
                end
            end else if (accept_row) begin
                // 校验行号是否符合期望
                if (in_row_idx_i != row_count_q[ROW_W-1:0]) begin
                    load_error_o <= 1'b1;
                    loading_q <= 1'b0;
                end else begin
                    // 将当前行 bit 写入对应列的相应位，并累加每列 popcount
                    for (col_idx_ff = 0; col_idx_ff < COL_COUNT; col_idx_ff++) begin
                        col_bits_o[col_idx_ff][in_row_idx_i] <= in_row_mask_i[col_idx_ff];
                        col_popcnt_o[col_idx_ff] <= col_popcnt_o[col_idx_ff] + {{(POP_W-1){1'b0}}, in_row_mask_i[col_idx_ff]};
                    end
                    // 累加全局任务总数
                    total_task_count_o <= total_task_count_o + row_task_count;

                    if (row_count_q == ROW_COUNT - 1) begin
                        // 已到最后一行：last 必须为 1
                        if (in_last_i) begin
                            load_done_o <= 1'b1;
                            loading_q <= 1'b0;
                        end else begin
                            load_error_o <= 1'b1;
                            loading_q <= 1'b0;
                        end
                    end else begin
                        // 非最后一行：last 不能为 1，否则报错
                        if (in_last_i) begin
                            load_error_o <= 1'b1;
                            loading_q <= 1'b0;
                        end else begin
                            row_count_q <= row_count_q + 1'b1;
                        end
                    end
                end
            end
        end
    end

endmodule


// ============================================================================
// candidate_score_array：候选列打分与最优选择（组合逻辑）
// ----------------------------------------------------------------------------
// 在分组贪心算法中用于"挑下一列"。
// 两种工作模式（mode_i）：
//   1) MODE_SEED   (1'b0)：为新的一组挑选种子列
//      —— 在 ungrouped_mask_i 标记的可选列中，选 col_popcnt 最小的一列
//      （等于让"轻负担"的列先成组，方便后面填充）。
//   2) MODE_EXPAND (1'b1)：为已有种子的组挑选下一个组员
//      —— 选会让组的 OR 位图新增 1 的个数（add_cost）最小的列；
//      若并列，则选 col_popcnt 最大的列（既然要付出一样的覆盖代价，
//      优先吸收更多任务，让该列贡献的有效工作更多）。
// 输入：
//   - col_bits_i / col_popcnt_i ：所有列的位图与 popcount
//   - ungrouped_mask_i          ：哪些列尚未被分到任何组（候选集合）
//   - cur_group_or_i            ：当前组已有列 OR 后的位图
// 输出：
//   - best_valid_o   ：是否存在有效候选
//   - best_col_o     ：被选中的列号
//   - best_add_cost_o：若把它加入组，会新增多少行覆盖
//   - best_popcnt_o  ：该列自身的 popcount
// 注意：这是纯组合逻辑，遍历 COL_COUNT 列做线性扫描。
// ============================================================================
module candidate_score_array #(
    parameter int ROW_COUNT = 16,
    parameter int COL_COUNT = 16,
    parameter int COL_W     = $clog2(COL_COUNT),
    parameter int POP_W     = $clog2(ROW_COUNT + 1)
)(
    input  logic [ROW_COUNT-1:0] col_bits_i [COL_COUNT],
    input  logic [POP_W-1:0]     col_popcnt_i [COL_COUNT],
    input  logic [COL_COUNT-1:0] ungrouped_mask_i,
    input  logic [ROW_COUNT-1:0] cur_group_or_i,
    input  logic                 mode_i,
    output logic                 best_valid_o,
    output logic [COL_W-1:0]     best_col_o,
    output logic [POP_W-1:0]     best_add_cost_o,
    output logic [POP_W-1:0]     best_popcnt_o
);

    localparam logic MODE_SEED   = 1'b0;
    localparam logic MODE_EXPAND = 1'b1;

    // popcount 函数：对 ROW_COUNT 位向量做位计数
    function automatic logic [POP_W-1:0] popcount(input logic [ROW_COUNT-1:0] bits);
        logic [POP_W-1:0] count;
        integer bit_idx;
        begin
            count = '0;
            for (bit_idx = 0; bit_idx < ROW_COUNT; bit_idx++) begin
                count = count + {{(POP_W-1){1'b0}}, bits[bit_idx]};
            end
            popcount = count;
        end
    endfunction

    integer col_idx_ff;
    logic [ROW_COUNT-1:0] add_bits;        // 该列相对于当前组 OR 的"新增 bit"
    logic [POP_W-1:0] candidate_add_cost;  // add_bits 的 popcount
    logic candidate_better;                // 该候选是否优于当前最佳

    always_comb begin
        // 默认无效
        best_valid_o = 1'b0;
        best_col_o = '0;
        best_add_cost_o = '0;
        best_popcnt_o = '0;

        // 线性遍历所有列；优先级编码器形式（同分时取低位 col_idx）
        for (col_idx_ff = 0; col_idx_ff < COL_COUNT; col_idx_ff++) begin
            if (ungrouped_mask_i[col_idx_ff]) begin // 仅考虑未分组的列
                add_bits = col_bits_i[col_idx_ff] & ~cur_group_or_i; // 新增覆盖位
                candidate_add_cost = popcount(add_bits);
                candidate_better = 1'b0;

                if (!best_valid_o) begin
                    // 第一个候选直接采纳
                    candidate_better = 1'b1;
                end else if (mode_i == MODE_SEED) begin
                    // SEED：比较列自身 popcount，更小者胜
                    if (col_popcnt_i[col_idx_ff] < best_popcnt_o) begin
                        candidate_better = 1'b1;
                    end
                end else if (mode_i == MODE_EXPAND) begin
                    // EXPAND：先看新增代价更小者胜；
                    //         若并列，则 popcount 更大者胜（同代价收益更高）
                    if (candidate_add_cost < best_add_cost_o) begin
                        candidate_better = 1'b1;
                    end else if ((candidate_add_cost == best_add_cost_o) &&
                                 (col_popcnt_i[col_idx_ff] > best_popcnt_o)) begin
                        candidate_better = 1'b1;
                    end
                end

                if (candidate_better) begin
                    best_valid_o = 1'b1;
                    best_col_o = col_idx_ff[COL_W-1:0];
                    best_add_cost_o = candidate_add_cost;
                    best_popcnt_o = col_popcnt_i[col_idx_ff];
                end
            end
        end
    end

endmodule


// ============================================================================
// v4_group_engine：分组引擎（贪心算法状态机）
// ----------------------------------------------------------------------------
// 把 COL_COUNT 列依次分入 GROUP_COUNT 个分组，每组 GROUP_SIZE 个列。
// 算法（每一组的处理流程）：
//   1) SELECT_SEED  : 用 SEED 模式从剩余未分组列中选 popcount 最小的列
//                     —— 作为本组的"种子"
//   2) COMMIT_SEED  : 把种子提交到当前组的 lane 0，并标记为已分组
//   3) 重复 GROUP_SIZE-1 次：
//      - SELECT_EXPAND : 用 EXPAND 模式选与当前组 OR 增量最小的列
//      - COMMIT_EXPAND : 提交到 lane lane_idx_q，更新组 OR
//   4) COMMIT_GROUP : 记录本组的 cost = popcount(组 OR) 与 OR 位图，
//                     切换到下一组（若是最后一组则进入 G_DONE）
// 若中途 best_valid 失效（候选用尽），提前结束本组并完成。
// ============================================================================
module v4_group_engine #(
    parameter int ROW_COUNT   = 16,
    parameter int COL_COUNT   = 16,
    parameter int GROUP_SIZE  = 4,
    parameter int GROUP_COUNT = COL_COUNT / GROUP_SIZE,
    parameter int COL_W       = $clog2(COL_COUNT),
    parameter int POP_W       = $clog2(ROW_COUNT + 1)
)(
    input  logic                 clk_i,
    input  logic                 rstn_i,
    input  logic                 start_i,
    input  logic [ROW_COUNT-1:0] col_bits_i [COL_COUNT],
    input  logic [POP_W-1:0]     col_popcnt_i [COL_COUNT],
    output logic                 done_o,
    output logic [COL_W-1:0]     group_col_idx_o [GROUP_COUNT][GROUP_SIZE],
    output logic [POP_W-1:0]     group_cost_o [GROUP_COUNT],
    output logic [ROW_COUNT-1:0] group_or_bits_o [GROUP_COUNT]
);

    // 当 GROUP_COUNT/GROUP_SIZE 为 1 时 $clog2 会得到 0，强制使用 1 位避免负位宽
    localparam int GROUP_IDX_W = (GROUP_COUNT <= 1) ? 1 : $clog2(GROUP_COUNT);
    localparam int LANE_IDX_W  = (GROUP_SIZE <= 1) ? 1 : $clog2(GROUP_SIZE);

    // 分组引擎内部的状态机定义
    typedef enum logic [2:0] {
        G_IDLE,            // 空闲
        G_INIT,            // 初始化所有计数器与输出
        G_SELECT_SEED,     // 选种子（组合查找一拍 -> 寄存）
        G_COMMIT_SEED,     // 提交种子到 lane 0
        G_SELECT_EXPAND,   // 选下一个组员
        G_COMMIT_EXPAND,   // 提交组员到 lane lane_idx_q
        G_COMMIT_GROUP,    // 收尾本组并切到下一组
        G_DONE             // 全部分组完成
    } group_state_e;

    function automatic logic [POP_W-1:0] popcount(input logic [ROW_COUNT-1:0] bits);
        logic [POP_W-1:0] count;
        integer bit_idx;
        begin
            count = '0;
            for (bit_idx = 0; bit_idx < ROW_COUNT; bit_idx++) begin
                count = count + {{(POP_W-1){1'b0}}, bits[bit_idx]};
            end
            popcount = count;
        end
    endfunction

    group_state_e state_q;
    logic [COL_COUNT-1:0] ungrouped_mask_q;     // 哪些列还未分组（1=可选）
    logic [ROW_COUNT-1:0] cur_group_or_q;       // 当前组累计的行覆盖位图
    logic [ROW_COUNT-1:0] next_group_or;        // 若把 selected_col_q 加入后的 OR
    logic [GROUP_IDX_W-1:0] group_idx_q;        // 当前正在填充的组号
    logic [LANE_IDX_W-1:0] lane_idx_q;          // 当前组的 lane 指针（0..GROUP_SIZE-1）
    logic [COL_W-1:0] selected_col_q;           // 上一拍打分结果暂存

    // 打分器使用的连接信号
    logic score_mode;
    logic best_valid;
    logic [COL_W-1:0] best_col;
    logic [POP_W-1:0] best_add_cost;
    logic [POP_W-1:0] best_popcnt;

    // SELECT_EXPAND 状态时打分器用 EXPAND 模式，否则用 SEED 模式
    assign score_mode = (state_q == G_SELECT_EXPAND);
    // 把 selected_col_q 这一列并入当前组后的 OR
    assign next_group_or = cur_group_or_q | col_bits_i[selected_col_q];

    candidate_score_array #(
        .ROW_COUNT(ROW_COUNT),
        .COL_COUNT(COL_COUNT),
        .COL_W(COL_W),
        .POP_W(POP_W)
    ) u_candidate_score_array (
        .col_bits_i(col_bits_i),
        .col_popcnt_i(col_popcnt_i),
        .ungrouped_mask_i(ungrouped_mask_q),
        .cur_group_or_i(cur_group_or_q),
        .mode_i(score_mode),
        .best_valid_o(best_valid),
        .best_col_o(best_col),
        .best_add_cost_o(best_add_cost),
        .best_popcnt_o(best_popcnt)
    );

    integer group_idx;
    integer lane_idx;

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // 复位：清空所有内部状态与输出
            state_q <= G_IDLE;
            done_o <= 1'b0;
            ungrouped_mask_q <= '0;
            cur_group_or_q <= '0;
            group_idx_q <= '0;
            lane_idx_q <= '0;
            selected_col_q <= '0;
            for (group_idx = 0; group_idx < GROUP_COUNT; group_idx++) begin
                group_cost_o[group_idx] <= '0;
                group_or_bits_o[group_idx] <= '0;
                for (lane_idx = 0; lane_idx < GROUP_SIZE; lane_idx++) begin
                    group_col_idx_o[group_idx][lane_idx] <= '0;
                end
            end
        end else begin
            done_o <= 1'b0; // done 仅在 G_DONE 状态持续保持

            unique case (state_q)
                G_IDLE: begin
                    if (start_i) begin
                        state_q <= G_INIT;
                    end
                end
                G_INIT: begin
                    // 初始：所有列都可选；清空所有分组结果
                    ungrouped_mask_q <= {COL_COUNT{1'b1}};
                    cur_group_or_q <= '0;
                    group_idx_q <= '0;
                    lane_idx_q <= '0;
                    selected_col_q <= '0;
                    for (group_idx = 0; group_idx < GROUP_COUNT; group_idx++) begin
                        group_cost_o[group_idx] <= '0;
                        group_or_bits_o[group_idx] <= '0;
                        for (lane_idx = 0; lane_idx < GROUP_SIZE; lane_idx++) begin
                            group_col_idx_o[group_idx][lane_idx] <= '0;
                        end
                    end
                    state_q <= G_SELECT_SEED;
                end
                G_SELECT_SEED: begin
                    // 打分器组合给出 best_*，本拍寄存 selected_col_q
                    if (best_valid) begin
                        selected_col_q <= best_col;
                        state_q <= G_COMMIT_SEED;
                    end else begin
                        // 没有可选列：直接结束（剩余分组保持 0）
                        state_q <= G_DONE;
                    end
                end
                G_COMMIT_SEED: begin
                    // 种子放入 lane 0，更新组 OR、ungrouped、lane 指针
                    group_col_idx_o[group_idx_q][0] <= selected_col_q;
                    cur_group_or_q <= col_bits_i[selected_col_q];
                    ungrouped_mask_q[selected_col_q] <= 1'b0;
                    lane_idx_q <= {{(LANE_IDX_W-1){1'b0}}, 1'b1}; // lane = 1
                    if (GROUP_SIZE == 1) begin
                        // 每组只有 1 列时直接收尾
                        state_q <= G_COMMIT_GROUP;
                    end else begin
                        state_q <= G_SELECT_EXPAND;
                    end
                end
                G_SELECT_EXPAND: begin
                    // 选下一个组员
                    if (best_valid) begin
                        selected_col_q <= best_col;
                        state_q <= G_COMMIT_EXPAND;
                    end else begin
                        // 候选用尽（一般是 ungrouped 为空），提前收尾本组
                        state_q <= G_COMMIT_GROUP;
                    end
                end
                G_COMMIT_EXPAND: begin
                    // 提交本次扩展
                    group_col_idx_o[group_idx_q][lane_idx_q] <= selected_col_q;
                    cur_group_or_q <= next_group_or;
                    ungrouped_mask_q[selected_col_q] <= 1'b0;
                    if (lane_idx_q == GROUP_SIZE - 1) begin
                        // 本组 lane 已填满，记录 cost/or 后切组
                        group_cost_o[group_idx_q] <= popcount(next_group_or);
                        group_or_bits_o[group_idx_q] <= next_group_or;
                        state_q <= G_COMMIT_GROUP;
                    end else begin
                        lane_idx_q <= lane_idx_q + 1'b1;
                        state_q <= G_SELECT_EXPAND;
                    end
                end
                G_COMMIT_GROUP: begin
                    // GROUP_SIZE==1 时上面没机会写 cost/or，这里补上
                    if (GROUP_SIZE == 1) begin
                        group_cost_o[group_idx_q] <= popcount(cur_group_or_q);
                        group_or_bits_o[group_idx_q] <= cur_group_or_q;
                    end
                    cur_group_or_q <= '0;
                    lane_idx_q <= '0;
                    if (group_idx_q == GROUP_COUNT - 1) begin
                        state_q <= G_DONE;
                    end else begin
                        group_idx_q <= group_idx_q + 1'b1;
                        state_q <= G_SELECT_SEED;
                    end
                end
                G_DONE: begin
                    done_o <= 1'b1;
                    if (!start_i) begin
                        state_q <= G_IDLE;
                    end
                end
                default: begin
                    state_q <= G_IDLE;
                end
            endcase
        end
    end

endmodule


// ============================================================================
// task_stream_emitter：任务发射器（流式输出调度结果）
// ----------------------------------------------------------------------------
// 在分组结果（group_col_idx_i）确定后，遍历每个分组、按 (row, lane) 的
// 嵌套顺序扫描组内各列的位图，每遇到一个 bit=1 就生成一个任务输出：
//   - out_group  : 组号
//   - out_lane   : 组内同时并行的通道号（task_count_in_group % GROUP_SIZE）
//   - out_slot   : 时间槽（task_count_in_group / GROUP_SIZE）
//   - out_row/col: 任务对应的原始行/列
//   - out_group_last: 是否为该组的最后一个任务
//   - out_last      : 是否为本次调度的最后一个任务
//
// 扫描顺序约定（lane 内嵌套于 row 之上）：
//   for row in 0..ROW_COUNT-1
//       for src_lane in 0..GROUP_SIZE-1
//           取该 lane 在当前 row 处的 bit；为 1 则发射一个任务
// 这样保证同一 row 上不同列产生的任务连续输出，方便下游打包。
// 状态机：E_IDLE -> E_INIT_GROUP -> E_SCAN -> (下一组循环) -> E_DONE
// ============================================================================
module task_stream_emitter #(
    parameter int ROW_COUNT   = 16,
    parameter int COL_COUNT   = 16,
    parameter int GROUP_SIZE  = 4,
    parameter int GROUP_COUNT = COL_COUNT / GROUP_SIZE,
    parameter int ROW_W       = $clog2(ROW_COUNT),
    parameter int COL_W       = $clog2(COL_COUNT),
    parameter int GROUP_W     = $clog2(GROUP_COUNT),
    parameter int LANE_W      = $clog2(GROUP_SIZE),
    parameter int SLOT_W      = $clog2(ROW_COUNT),
    parameter int POP_W       = $clog2(ROW_COUNT + 1),
    parameter int TOTAL_W     = $clog2(ROW_COUNT * COL_COUNT + 1)
)(
    input  logic                 clk_i,
    input  logic                 rstn_i,
    input  logic                 start_i,
    input  logic [ROW_COUNT-1:0] col_bits_i [COL_COUNT],          // 各列位图
    input  logic [POP_W-1:0]     col_popcnt_i [COL_COUNT],         // 各列 popcount
    input  logic [TOTAL_W-1:0]   total_task_count_i,               // 全局任务总数
    input  logic [COL_W-1:0]     group_col_idx_i [GROUP_COUNT][GROUP_SIZE], // 各组组员
    input  logic                 out_ready_i,
    output logic                 out_valid_o,
    output logic [GROUP_W-1:0]   out_group_o,
    output logic [LANE_W-1:0]    out_lane_o,
    output logic [SLOT_W-1:0]    out_slot_o,
    output logic [ROW_W-1:0]     out_row_o,
    output logic [COL_W-1:0]     out_col_o,
    output logic                 out_group_last_o,
    output logic                 out_last_o,
    output logic                 done_o
);

    localparam int GROUP_IDX_W = (GROUP_COUNT <= 1) ? 1 : $clog2(GROUP_COUNT);
    localparam int LANE_IDX_W  = (GROUP_SIZE <= 1) ? 1 : $clog2(GROUP_SIZE);
    // 每组最多产生 ROW_COUNT * GROUP_SIZE 个任务
    localparam int TASK_CNT_W  = $clog2(ROW_COUNT * GROUP_SIZE + 1);

    typedef enum logic [1:0] {
        E_IDLE,
        E_INIT_GROUP,   // 开始处理新一组前的初始化
        E_SCAN,         // 在当前组内扫描行/lane
        E_DONE
    } emit_state_e;

    emit_state_e state_q;
    logic [GROUP_IDX_W-1:0] emit_group_q;            // 当前正在发射的组号
    logic [ROW_W-1:0] scan_row_q;                    // 扫描行游标
    logic [LANE_IDX_W-1:0] scan_src_lane_q;          // 扫描的组内 lane 游标
    logic [TASK_CNT_W-1:0] task_count_in_group_q;    // 当前组已发射任务数
    logic [TOTAL_W-1:0] emitted_total_count_q;       // 全局已发射任务数
    logic [TASK_CNT_W-1:0] group_task_total_q;       // 当前组任务总数（在 E_INIT_GROUP 锁存）

    logic [TASK_CNT_W-1:0] current_group_task_total; // 组合计算：当前组任务总数
    logic [COL_W-1:0] src_col;                       // 当前正在扫描的列号
    logic [SLOT_W-1:0] next_slot;                    // 即将输出任务的 slot
    logic current_bit_is_task;                       // 当前 (row, lane) 是否为任务
    logic at_group_scan_end;                         // 当前组扫描已到末尾
    logic output_fire;                               // 一次成功的输出握手

    assign output_fire = out_valid_o && out_ready_i;
    // 当前要看的列 = 当前组的第 scan_src_lane_q 个组员
    assign src_col = group_col_idx_i[emit_group_q][scan_src_lane_q];
    // slot = 已发射任务数 / GROUP_SIZE（高位部分），lane = 低 LANE_W 位
    assign next_slot = task_count_in_group_q >> LANE_W;
    assign current_bit_is_task = col_bits_i[src_col][scan_row_q];
    assign at_group_scan_end = (scan_row_q == ROW_COUNT - 1) && (scan_src_lane_q == GROUP_SIZE - 1);

    integer lane_idx;
    // 组合计算当前组所有组员的 popcount 之和（即该组的任务总数）
    always_comb begin
        current_group_task_total = '0;
        for (lane_idx = 0; lane_idx < GROUP_SIZE; lane_idx++) begin
            current_group_task_total = current_group_task_total + col_popcnt_i[group_col_idx_i[emit_group_q][lane_idx]];
        end
    end

    always_ff @(posedge clk_i or negedge rstn_i) begin
        if (!rstn_i) begin
            // 复位：清空所有寄存器与输出
            state_q <= E_IDLE;
            emit_group_q <= '0;
            scan_row_q <= '0;
            scan_src_lane_q <= '0;
            task_count_in_group_q <= '0;
            emitted_total_count_q <= '0;
            group_task_total_q <= '0;
            out_valid_o <= 1'b0;
            out_group_o <= '0;
            out_lane_o <= '0;
            out_slot_o <= '0;
            out_row_o <= '0;
            out_col_o <= '0;
            out_group_last_o <= 1'b0;
            out_last_o <= 1'b0;
            done_o <= 1'b0;
        end else begin
            done_o <= 1'b0;

            // 一次握手成功后立即撤销 valid，等待下一拍生成新任务
            if (output_fire) begin
                out_valid_o <= 1'b0;
            end

            unique case (state_q)
                E_IDLE: begin
                    out_valid_o <= 1'b0;
                    if (start_i) begin
                        // 初始化游标
                        emit_group_q <= '0;
                        scan_row_q <= '0;
                        scan_src_lane_q <= '0;
                        task_count_in_group_q <= '0;
                        emitted_total_count_q <= '0;
                        if (total_task_count_i == '0) begin
                            // 整个矩阵为 0：直接完成
                            state_q <= E_DONE;
                        end else begin
                            state_q <= E_INIT_GROUP;
                        end
                    end
                end
                E_INIT_GROUP: begin
                    // 进入新一组：复位扫描游标，并锁存本组任务总数
                    scan_row_q <= '0;
                    scan_src_lane_q <= '0;
                    task_count_in_group_q <= '0;
                    group_task_total_q <= current_group_task_total;
                    if (current_group_task_total == '0) begin
                        // 空组：直接跳到下一组（或结束）
                        if (emit_group_q == GROUP_COUNT - 1) begin
                            state_q <= E_DONE;
                        end else begin
                            emit_group_q <= emit_group_q + 1'b1;
                            // 保持在 E_INIT_GROUP，下一拍会重新计算 current_group_task_total
                        end
                    end else begin
                        state_q <= E_SCAN;
                    end
                end
                E_SCAN: begin
                    // 只有输出空闲（!valid）或下游正在接收（ready）时才前进游标
                    if (!out_valid_o || out_ready_i) begin
                        // 若当前 (row, lane) 处有任务，则生成一拍输出
                        if (current_bit_is_task) begin
                            out_valid_o <= 1'b1;
                            out_group_o <= emit_group_q[GROUP_W-1:0];
                            out_lane_o <= task_count_in_group_q[LANE_W-1:0];
                            out_slot_o <= next_slot;
                            out_row_o <= scan_row_q;
                            out_col_o <= src_col;
                            // group_last：是本组的最后一个任务
                            out_group_last_o <= (task_count_in_group_q == group_task_total_q - 1'b1);
                            // last：是全局最后一个任务
                            out_last_o <= (emitted_total_count_q == total_task_count_i - 1'b1);
                            task_count_in_group_q <= task_count_in_group_q + 1'b1;
                            emitted_total_count_q <= emitted_total_count_q + 1'b1;
                        end

                        // 推进扫描游标：lane 在内层循环（先把同一 row 各 lane 走完）
                        if (at_group_scan_end) begin
                            // 本组扫描完毕，切换到下一组或结束
                            if (emit_group_q == GROUP_COUNT - 1) begin
                                state_q <= E_DONE;
                            end else begin
                                emit_group_q <= emit_group_q + 1'b1;
                                state_q <= E_INIT_GROUP;
                            end
                        end else if (scan_src_lane_q == GROUP_SIZE - 1) begin
                            // 同一 row 的 lane 走完，进入下一 row
                            scan_src_lane_q <= '0;
                            scan_row_q <= scan_row_q + 1'b1;
                        end else begin
                            // 还在当前 row，移动到下一 lane
                            scan_src_lane_q <= scan_src_lane_q + 1'b1;
                        end
                    end
                end
                E_DONE: begin
                    // 等最后一拍数据真正被下游接走，再拉 done
                    if (!out_valid_o || out_ready_i) begin
                        done_o <= 1'b1;
                        if (!start_i) begin
                            state_q <= E_IDLE;
                        end
                    end
                end
                default: begin
                    state_q <= E_IDLE;
                end
            endcase
        end
    end

endmodule
