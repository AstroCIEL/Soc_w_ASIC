module axu_top #(
    parameter int unsigned NUM_LANE        = 64,
    parameter int unsigned ELEM_WIDTH      = 16,
    parameter int unsigned ES              = 2,
    parameter int unsigned BANK_WIDTH      = 128,
    parameter int unsigned BANK_NUM        = (NUM_LANE * ELEM_WIDTH) / BANK_WIDTH,//64*16/128=8
    parameter int unsigned ADDR_WIDTH      = 8,
    parameter int unsigned CFG_ADDR_WIDTH  = 4,
    parameter int unsigned ALIGN_WIDTH     = 14,
    parameter int unsigned ACC_ALIGN_WIDTH = 32,
    parameter int unsigned SFU_LANE        = NUM_LANE / 2,
    parameter int unsigned SFU_RAND_N      = ELEM_WIDTH,
    parameter int unsigned SFU_ALIGN_WIDTH = ACC_ALIGN_WIDTH,
    parameter int unsigned SFU_NUM_ITER    = 7,
    parameter int unsigned NLI_NUM_LANES   = SFU_LANE,
    parameter int unsigned NLI_NUM_MACROS  = 10,
    parameter int unsigned NLI_NUM_MICROS  = 32,
    parameter string       OP_A_INIT_FILE  = "",
    parameter string       OP_B_INIT_FILE  = "",
    parameter string       OUT_INIT_FILE   = "",
    parameter string       OP_A_DUMP_FILE  = "",
    parameter string       OP_B_DUMP_FILE  = "",
    parameter string       OUT_DUMP_FILE   = "",
    parameter int          BUF_AXI_ADDR_WIDTH = 64,
    parameter int          BUF_AXI_DATA_WIDTH = 64
) (
    input  logic                      clk_i,
    input  logic                      rstn_i,

    input  logic                      cfg_set_i,
    input  logic [CFG_ADDR_WIDTH-1:0] cfg_addr_i,
    input  logic [ADDR_WIDTH-1:0]     cfg_data_i,
    input  logic                      start_i,
    input  logic                      dump_i,

    output logic                      calc_done_o,
    output logic                      busy_o,
    output logic                      done_o,

    // op_a_buf AXI side (rf2p_256_128_wrapper.axi_*)
    input  logic                                 op_a_acc_rd_port_sel_i,
    input  logic                                 op_a_acc_wr_port_sel_i,
    input  logic                                 op_a_axi_req_i,
    input  logic                                 op_a_axi_write_en_i,
    input  logic [BUF_AXI_ADDR_WIDTH-1:0]        op_a_axi_addr_i,
    input  logic [BUF_AXI_DATA_WIDTH/8-1:0]      op_a_axi_byte_en_i,
    input  logic [BUF_AXI_DATA_WIDTH-1:0]        op_a_axi_wdata_i,
    output logic [BUF_AXI_DATA_WIDTH-1:0]        op_a_axi_rdata_o,

    // op_b_buf AXI side
    input  logic                                 op_b_acc_rd_port_sel_i,
    input  logic                                 op_b_acc_wr_port_sel_i,
    input  logic                                 op_b_axi_req_i,
    input  logic                                 op_b_axi_write_en_i,
    input  logic [BUF_AXI_ADDR_WIDTH-1:0]        op_b_axi_addr_i,
    input  logic [BUF_AXI_DATA_WIDTH/8-1:0]      op_b_axi_byte_en_i,
    input  logic [BUF_AXI_DATA_WIDTH-1:0]        op_b_axi_wdata_i,
    output logic [BUF_AXI_DATA_WIDTH-1:0]        op_b_axi_rdata_o,

    // out_buf AXI side
    input  logic                                 out_acc_rd_port_sel_i,
    input  logic                                 out_acc_wr_port_sel_i,
    input  logic                                 out_axi_req_i,
    input  logic                                 out_axi_write_en_i,
    input  logic [BUF_AXI_ADDR_WIDTH-1:0]        out_axi_addr_i,
    input  logic [BUF_AXI_DATA_WIDTH/8-1:0]      out_axi_byte_en_i,
    input  logic [BUF_AXI_DATA_WIDTH-1:0]        out_axi_wdata_i,
    output logic [BUF_AXI_DATA_WIDTH-1:0]        out_axi_rdata_o
);

    localparam int unsigned ELEM_PER_BANK = BANK_WIDTH / ELEM_WIDTH;

    initial begin
        if ((BANK_WIDTH % ELEM_WIDTH) != 0) begin
            $fatal(1, "axu_top: BANK_WIDTH must be an integer multiple of ELEM_WIDTH");
        end
        if (NUM_LANE * ELEM_WIDTH != BANK_NUM * BANK_WIDTH) begin
            $fatal(1, "axu_top: NUM_LANE/ELEM_WIDTH must match BANK_NUM/BANK_WIDTH");
        end
        if (ELEM_PER_BANK == 0) begin
            $fatal(1, "axu_top: ELEM_PER_BANK must be nonzero");
        end
        if ((SFU_LANE * 2) != NUM_LANE) begin
            $fatal(1, "axu_top: SFU_LANE must be exactly half of NUM_LANE");
        end
    end

    logic [BANK_NUM-1:0]   op_a_buf_cen;
    logic [BANK_NUM-1:0]   op_a_buf_wen;
    logic [ADDR_WIDTH-1:0] op_a_buf_addr [BANK_NUM-1:0];
    logic [BANK_WIDTH-1:0] op_a_buf_dout [BANK_NUM-1:0];

    logic [BANK_NUM-1:0]   op_b_buf_cen;
    logic [BANK_NUM-1:0]   op_b_buf_wen;
    logic [ADDR_WIDTH-1:0] op_b_buf_addr [BANK_NUM-1:0];
    logic [BANK_WIDTH-1:0] op_b_buf_dout [BANK_NUM-1:0];

    logic [BANK_NUM-1:0]   out_buf_cen;
    logic [BANK_NUM-1:0]   out_buf_wen;
    logic [ADDR_WIDTH-1:0] out_buf_addr [BANK_NUM-1:0];
    logic [BANK_WIDTH-1:0] out_buf_din  [BANK_NUM-1:0];
    logic [BANK_WIDTH-1:0] out_buf_dout [BANK_NUM-1:0];
    logic [2:0]              vpu_func_sel;
    logic                    vpu_start;
    logic [ELEM_WIDTH-1:0]   vpu_vec_a_posit [NUM_LANE-1:0];
    logic [ELEM_WIDTH-1:0]   vpu_vec_b_posit [NUM_LANE-1:0];
    logic                    vpu_calc_done;
    logic                    vpu_busy;
    logic                    vpu_done;
    logic [ELEM_WIDTH-1:0]   vpu_vec_result_posit [NUM_LANE-1:0];
    logic [ELEM_WIDTH-1:0]   vpu_reduction_result_posit;

    logic [1:0]              sfu_sel;
    logic                    sfu_start;
    logic                    sfu_seed_load;
    logic                    sfu_done;
    logic [ELEM_WIDTH-1:0]   sfu_data [SFU_LANE-1:0];
    logic [63:0]             sfu_seed_high [SFU_LANE-1:0];
    logic [63:0]             sfu_seed_low [SFU_LANE-1:0];
    logic [ELEM_WIDTH-1:0]   sfu_result0 [SFU_LANE-1:0];
    logic [ELEM_WIDTH-1:0]   sfu_result1 [SFU_LANE-1:0];

    localparam int unsigned NLI_MACRO_IDX_W = $clog2(NLI_NUM_MACROS);
    localparam int unsigned NLI_Y_BOUNDS_DEPTH   = (NLI_NUM_MACROS-2)*NLI_NUM_MICROS + 2;
    localparam int unsigned NLI_Y_BOUNDS_ENTRIES = NLI_Y_BOUNDS_DEPTH + 1;
    localparam int unsigned NLI_IVAL_IDX_W       = $clog2(NLI_Y_BOUNDS_ENTRIES);

    logic                          nli_clr;
    logic                          nli_up_valid;
    logic                          nli_up_ready;
    logic                          nli_dn_valid;
    logic                          nli_dn_ready;
    logic [ELEM_WIDTH-1:0]         nli_input_data  [NLI_NUM_LANES-1:0];
    logic [ELEM_WIDTH-1:0]         nli_output_data [NLI_NUM_LANES-1:0];
    logic                          nli_mul_lut_wr_en;
    logic [NLI_MACRO_IDX_W-1:0]    nli_mul_lut_wr_addr;
    logic [ELEM_WIDTH-1:0]         nli_mul_lut_wr_data;
    logic                          nli_y_bounds_lut_wr_en;
    logic [NLI_IVAL_IDX_W-1:0]     nli_y_bounds_lut_wr_addr;
    logic [ELEM_WIDTH-1:0]         nli_y_bounds_lut_wr_data;
    logic [ELEM_WIDTH-1:0]         nli_macro_bounds [0:NLI_NUM_MACROS];

    // -------------------------------------------------------------------------
    // I/O buffers backed by rf2p_256_128_wrapper (8 banks of 128 bit x 256 word
    // forming one 1024 bit x 256 word buffer per wrapper instance).
    //
    // axu_ctrl drives BANK_NUM independent banks (default 8), each BANK_WIDTH
    // bits wide. We flatten the per-bank control/address/data signals and pass
    // them to rf2p_256_128_wrapper, which maps each logical bank to one physical
    // rf2p_256_128.
    


    // -------------------------------------------------------------------------
    localparam int WRP_NB           = 8;
    localparam int WRP_BANK_DATA_W  = 128;
    localparam int WRP_BANK_ADDR_W  = ADDR_WIDTH;
    localparam int WRP_DATA_W       = WRP_NB * WRP_BANK_DATA_W;

    initial begin
        if (BANK_WIDTH != WRP_BANK_DATA_W) begin
            $fatal(1, "axu_top: expected BANK_WIDTH (=%0d) to equal WRP_BANK_DATA_W (=%0d)",
                   BANK_WIDTH, WRP_BANK_DATA_W);
        end
        if (BANK_NUM != WRP_NB) begin
            $fatal(1, "axu_top: expected BANK_NUM (=%0d) to equal WRP_NB (=%0d)",
                   BANK_NUM, WRP_NB);
        end
    end

    // ---- Scheduler control / data signals ----------------------------------
    localparam int unsigned SCH_MAX_TASKS = 256;
    logic                          sch_start;
    logic                          sch_clear;
    logic [ADDR_WIDTH-1:0]         sch_inbuf_base;
    logic [ADDR_WIDTH-1:0]         sch_obuf_base;
    logic                          sch_busy;
    logic                          sch_done;
    logic                          sch_error;
    logic [$clog2(SCH_MAX_TASKS+1)-1:0] sch_task_count;
    logic                          sch_inbuf_rd_req;
    logic [ADDR_WIDTH-1:0]         sch_inbuf_rd_addr;
    logic [WRP_BANK_DATA_W-1:0]    sch_inbuf_rd_data;
    logic                          sch_obuf_wr_req;
    logic [ADDR_WIDTH-1:0]         sch_obuf_wr_addr;
    logic [WRP_BANK_DATA_W-1:0]    sch_obuf_wr_data;



    // ---- Driving signals exposed for the sim-only loader/dumper FSM --------
    // op_a / op_b: wrapper acc_wr port is driven by loader during init,
    // and tied to zero (no writes) afterwards. axu_ctrl drives the acc_rd port.
    logic                          op_a_loader_wr_req;
    logic [WRP_BANK_ADDR_W-1:0]    op_a_loader_wr_addr;
    logic [WRP_DATA_W-1:0]         op_a_loader_wr_data;
    logic                          op_b_loader_wr_req;
    logic [WRP_BANK_ADDR_W-1:0]    op_b_loader_wr_addr;
    logic [WRP_DATA_W-1:0]         op_b_loader_wr_data;
    // out_buf: wrapper acc_wr port is driven by axu_ctrl during normal operation,
    // and by an init-time clearer that zeroes every row at startup.
    // wrapper acc_rd port is driven by dumper during dump.
    logic                          out_clear_wr_req;
    logic [WRP_BANK_ADDR_W-1:0]    out_clear_wr_addr;
    logic                          out_clear_busy;
    logic                          out_dumper_rd_req;
    logic [WRP_BANK_ADDR_W-1:0]    out_dumper_rd_addr;
    logic [WRP_DATA_W-1:0]         out_dumper_rd_data;

    // Default tie-off so synthesizable code path has well defined drivers
    // even when no sim FSM is present.
    initial begin
        op_a_loader_wr_req  = 1'b0;
        op_a_loader_wr_addr = '0;
        op_a_loader_wr_data = '0;
        op_b_loader_wr_req  = 1'b0;
        op_b_loader_wr_addr = '0;
        op_b_loader_wr_data = '0;
        out_clear_wr_req    = 1'b0;
        out_clear_wr_addr   = '0;
        out_clear_busy      = 1'b0;
        out_dumper_rd_req   = 1'b0;
        out_dumper_rd_addr  = '0;
    end

    // ---- op_a_buf wrapper ---------------------------------------------------
    logic [WRP_NB-1:0]                       op_a_acc_rd_req;
    logic [WRP_NB*WRP_BANK_ADDR_W-1:0]       op_a_acc_rd_addr;
    logic [WRP_NB*WRP_BANK_DATA_W-1:0]       op_a_acc_rd_data;
    logic [WRP_NB-1:0]                       op_a_acc_wr_req;
    logic [WRP_NB*WRP_BANK_ADDR_W-1:0]       op_a_acc_wr_addr;
    logic [WRP_NB*WRP_BANK_DATA_W-1:0]       op_a_acc_wr_data;

    always_comb begin
        op_a_acc_rd_req  = '0;
        op_a_acc_rd_addr = '0;
        if (sch_busy) begin
            op_a_acc_rd_req[0] = sch_inbuf_rd_req;
            op_a_acc_rd_addr[0 +: WRP_BANK_ADDR_W] = sch_inbuf_rd_addr;
        end else begin
            for (int b = 0; b < WRP_NB; b++) begin
                op_a_acc_rd_req[b] = ~op_a_buf_cen[b];
                op_a_acc_rd_addr[b*WRP_BANK_ADDR_W +: WRP_BANK_ADDR_W] = op_a_buf_addr[b];
            end
        end
    end

    genvar gen_op_a_bank;
    generate
        for (gen_op_a_bank = 0; gen_op_a_bank < WRP_NB; gen_op_a_bank++) begin : gen_op_a_dout
            assign op_a_buf_dout[gen_op_a_bank] = op_a_acc_rd_data[gen_op_a_bank*WRP_BANK_DATA_W +: WRP_BANK_DATA_W];
        end
    endgenerate

    assign sch_inbuf_rd_data = op_a_acc_rd_data[0 +: WRP_BANK_DATA_W];
    assign op_a_acc_wr_req  = {WRP_NB{op_a_loader_wr_req}};
    assign op_a_acc_wr_addr = {WRP_NB{op_a_loader_wr_addr}};
    assign op_a_acc_wr_data = op_a_loader_wr_data;

    rf2p_256_128_wrapper #(
        .AXI_ADDR_WIDTH  (BUF_AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH  (BUF_AXI_DATA_WIDTH),
        .BANK_DATA_WIDTH (WRP_BANK_DATA_W),
        .NUM_BANKS       (WRP_NB),
        .BANK_ADDR_WIDTH (WRP_BANK_ADDR_W)
    ) u_op_a_buf (
        .clk_i             (clk_i),
        .rstn_i            (rstn_i),
        .acc_rd_port_sel_i (op_a_acc_rd_port_sel_i),
        .acc_wr_port_sel_i (op_a_acc_wr_port_sel_i),
        .axi_req_i         (op_a_axi_req_i),
        .axi_write_en_i    (op_a_axi_write_en_i),
        .axi_addr_i        (op_a_axi_addr_i),
        .axi_byte_en_i     (op_a_axi_byte_en_i),
        .axi_wdata_i       (op_a_axi_wdata_i),
        .axi_rdata_o       (op_a_axi_rdata_o),
        .acc_rd_req_i      (op_a_acc_rd_req),
        .acc_rd_addr_i     (op_a_acc_rd_addr),
        .acc_rd_data_o     (op_a_acc_rd_data),
        .acc_wr_req_i      (op_a_acc_wr_req),
        .acc_wr_addr_i     (op_a_acc_wr_addr),
        .acc_wr_data_i     (op_a_acc_wr_data)
    );

    // ---- op_b_buf wrapper ---------------------------------------------------
    logic [WRP_NB-1:0]                       op_b_acc_rd_req;
    logic [WRP_NB*WRP_BANK_ADDR_W-1:0]       op_b_acc_rd_addr;
    logic [WRP_NB*WRP_BANK_DATA_W-1:0]       op_b_acc_rd_data;
    logic [WRP_NB-1:0]                       op_b_acc_wr_req;
    logic [WRP_NB*WRP_BANK_ADDR_W-1:0]       op_b_acc_wr_addr;
    logic [WRP_NB*WRP_BANK_DATA_W-1:0]       op_b_acc_wr_data;

    always_comb begin
        op_b_acc_rd_req  = '0;
        op_b_acc_rd_addr = '0;
        for (int b = 0; b < WRP_NB; b++) begin
            op_b_acc_rd_req[b] = ~op_b_buf_cen[b];
            op_b_acc_rd_addr[b*WRP_BANK_ADDR_W +: WRP_BANK_ADDR_W] = op_b_buf_addr[b];
        end
    end

    genvar gen_op_b_bank;
    generate
        for (gen_op_b_bank = 0; gen_op_b_bank < WRP_NB; gen_op_b_bank++) begin : gen_op_b_dout
            assign op_b_buf_dout[gen_op_b_bank] = op_b_acc_rd_data[gen_op_b_bank*WRP_BANK_DATA_W +: WRP_BANK_DATA_W];
        end
    endgenerate

    assign op_b_acc_wr_req  = {WRP_NB{op_b_loader_wr_req}};
    assign op_b_acc_wr_addr = {WRP_NB{op_b_loader_wr_addr}};
    assign op_b_acc_wr_data = op_b_loader_wr_data;

    rf2p_256_128_wrapper #(
        .AXI_ADDR_WIDTH  (BUF_AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH  (BUF_AXI_DATA_WIDTH),
        .BANK_DATA_WIDTH (WRP_BANK_DATA_W),
        .NUM_BANKS       (WRP_NB),
        .BANK_ADDR_WIDTH (WRP_BANK_ADDR_W)
    ) u_op_b_buf (
        .clk_i             (clk_i),
        .rstn_i            (rstn_i),
        .acc_rd_port_sel_i (op_b_acc_rd_port_sel_i),
        .acc_wr_port_sel_i (op_b_acc_wr_port_sel_i),
        .axi_req_i         (op_b_axi_req_i),
        .axi_write_en_i    (op_b_axi_write_en_i),
        .axi_addr_i        (op_b_axi_addr_i),
        .axi_byte_en_i     (op_b_axi_byte_en_i),
        .axi_wdata_i       (op_b_axi_wdata_i),
        .axi_rdata_o       (op_b_axi_rdata_o),
        .acc_rd_req_i      (op_b_acc_rd_req),
        .acc_rd_addr_i     (op_b_acc_rd_addr),
        .acc_rd_data_o     (op_b_acc_rd_data),
        .acc_wr_req_i      (op_b_acc_wr_req),
        .acc_wr_addr_i     (op_b_acc_wr_addr),
        .acc_wr_data_i     (op_b_acc_wr_data)
    );

    // ---- out_buf wrapper ----------------------------------------------------
    logic [WRP_NB-1:0]                       out_acc_rd_req;
    logic [WRP_NB*WRP_BANK_ADDR_W-1:0]       out_acc_rd_addr;
    logic [WRP_NB*WRP_BANK_DATA_W-1:0]       out_acc_rd_data;
    logic [WRP_NB-1:0]                       out_acc_wr_req;
    logic [WRP_NB*WRP_BANK_ADDR_W-1:0]       out_acc_wr_addr;
    logic [WRP_NB*WRP_BANK_DATA_W-1:0]       out_acc_wr_data;

    assign out_acc_rd_req  = {WRP_NB{out_dumper_rd_req}};
    assign out_acc_rd_addr = {WRP_NB{out_dumper_rd_addr}};
    assign out_dumper_rd_data = out_acc_rd_data;

    always_comb begin
        out_acc_wr_req  = '0;
        out_acc_wr_addr = '0;
        out_acc_wr_data = '0;
        if (out_clear_busy) begin
            out_acc_wr_req  = {WRP_NB{out_clear_wr_req}};
            out_acc_wr_addr = {WRP_NB{out_clear_wr_addr}};
            out_acc_wr_data = '0;
        end else if (sch_busy) begin
            out_acc_wr_req[0] = sch_obuf_wr_req;
            out_acc_wr_addr[0 +: WRP_BANK_ADDR_W] = sch_obuf_wr_addr;
            out_acc_wr_data[0 +: WRP_BANK_DATA_W] = sch_obuf_wr_data;
        end else begin
            for (int b = 0; b < WRP_NB; b++) begin
                out_acc_wr_req[b] = ~out_buf_cen[b] & out_buf_wen[b];
                out_acc_wr_addr[b*WRP_BANK_ADDR_W +: WRP_BANK_ADDR_W] = out_buf_addr[b];
                out_acc_wr_data[b*WRP_BANK_DATA_W +: WRP_BANK_DATA_W] = out_buf_din[b];
            end
        end
    end

    genvar gen_out_bank;
    generate
        for (gen_out_bank = 0; gen_out_bank < WRP_NB; gen_out_bank++) begin : gen_out_dout
            assign out_buf_dout[gen_out_bank] = out_acc_rd_data[gen_out_bank*WRP_BANK_DATA_W +: WRP_BANK_DATA_W];
        end
    endgenerate

    rf2p_256_128_wrapper #(
        .AXI_ADDR_WIDTH  (BUF_AXI_ADDR_WIDTH),
        .AXI_DATA_WIDTH  (BUF_AXI_DATA_WIDTH),
        .BANK_DATA_WIDTH (WRP_BANK_DATA_W),
        .NUM_BANKS       (WRP_NB),
        .BANK_ADDR_WIDTH (WRP_BANK_ADDR_W)
    ) u_out_buf (
        .clk_i             (clk_i),
        .rstn_i            (rstn_i),
        .acc_rd_port_sel_i (out_acc_rd_port_sel_i),
        .acc_wr_port_sel_i (out_acc_wr_port_sel_i),
        .axi_req_i         (out_axi_req_i),
        .axi_write_en_i    (out_axi_write_en_i),
        .axi_addr_i        (out_axi_addr_i),
        .axi_byte_en_i     (out_axi_byte_en_i),
        .axi_wdata_i       (out_axi_wdata_i),
        .axi_rdata_o       (out_axi_rdata_o),
        .acc_rd_req_i      (out_acc_rd_req),
        .acc_rd_addr_i     (out_acc_rd_addr),
        .acc_rd_data_o     (out_acc_rd_data),
        .acc_wr_req_i      (out_acc_wr_req),
        .acc_wr_addr_i     (out_acc_wr_addr),
        .acc_wr_data_i     (out_acc_wr_data)
    );

    axu_ctrl #(
        .NUM_LANE       (NUM_LANE),
        .ELEM_WIDTH     (ELEM_WIDTH),
        .BANK_WIDTH     (BANK_WIDTH),
        .BANK_NUM       (BANK_NUM),
        .ADDR_WIDTH     (ADDR_WIDTH),
        .CFG_ADDR_WIDTH (CFG_ADDR_WIDTH),
        .SFU_LANE       (SFU_LANE),
        .NLI_NUM_LANES  (NLI_NUM_LANES),
        .NLI_NUM_MACROS (NLI_NUM_MACROS),
        .NLI_NUM_MICROS (NLI_NUM_MICROS)
    ) u_axu_ctrl (
        .clk_i                         (clk_i),
        .rstn_i                        (rstn_i),
        .cfg_set_i                     (cfg_set_i),
        .cfg_addr_i                    (cfg_addr_i),
        .cfg_data_i                    (cfg_data_i),
        .start_i                       (start_i),
        .calc_done_o                   (calc_done_o),
        .busy_o                        (busy_o),
        .done_o                        (done_o),
        .op_a_buf_cen_o                (op_a_buf_cen),
        .op_a_buf_wen_o                (op_a_buf_wen),
        .op_a_buf_addr_o               (op_a_buf_addr),
        .op_a_buf_dout_i               (op_a_buf_dout),
        .op_b_buf_cen_o                (op_b_buf_cen),
        .op_b_buf_wen_o                (op_b_buf_wen),
        .op_b_buf_addr_o               (op_b_buf_addr),
        .op_b_buf_dout_i               (op_b_buf_dout),
        .out_buf_cen_o                 (out_buf_cen),
        .out_buf_wen_o                 (out_buf_wen),
        .out_buf_addr_o                (out_buf_addr),
        .out_buf_din_o                 (out_buf_din),
        .vpu_func_sel_o                (vpu_func_sel),
        .vpu_start_o                   (vpu_start),
        .vpu_vec_a_posit_o             (vpu_vec_a_posit),
        .vpu_vec_b_posit_o             (vpu_vec_b_posit),
        .vpu_calc_done_i               (vpu_calc_done),
        .vpu_busy_i                    (vpu_busy),
        .vpu_done_i                    (vpu_done),
        .vpu_vec_result_posit_i        (vpu_vec_result_posit),
        .vpu_reduction_result_posit_i  (vpu_reduction_result_posit),
        .sfu_sel_o                     (sfu_sel),
        .sfu_start_o                   (sfu_start),
        .sfu_seed_load_o               (sfu_seed_load),
        .sfu_data_o                    (sfu_data),
        .sfu_seed_high_o               (sfu_seed_high),
        .sfu_seed_low_o                (sfu_seed_low),
        .sfu_done_i                    (sfu_done),
        .sfu_result0_i                 (sfu_result0),
        .sfu_result1_i                 (sfu_result1),
        .nli_clr_o                     (nli_clr),
        .nli_up_valid_o                (nli_up_valid),
        .nli_up_ready_i                (nli_up_ready),
        .nli_dn_valid_i                (nli_dn_valid),
        .nli_dn_ready_o                (nli_dn_ready),
        .nli_input_data_o              (nli_input_data),
        .nli_output_data_i             (nli_output_data),
        .nli_mul_lut_wr_en_o           (nli_mul_lut_wr_en),
        .nli_mul_lut_wr_addr_o         (nli_mul_lut_wr_addr),
        .nli_mul_lut_wr_data_o         (nli_mul_lut_wr_data),
        .nli_y_bounds_lut_wr_en_o      (nli_y_bounds_lut_wr_en),
        .nli_y_bounds_lut_wr_addr_o    (nli_y_bounds_lut_wr_addr),
        .nli_y_bounds_lut_wr_data_o    (nli_y_bounds_lut_wr_data),
        .nli_macro_bounds_o            (nli_macro_bounds),
        .sch_start_o                   (sch_start),
        .sch_clear_o                   (sch_clear),
        .sch_inbuf_base_o              (sch_inbuf_base),
        .sch_obuf_base_o               (sch_obuf_base),
        .sch_busy_i                    (sch_busy),
        .sch_done_i                    (sch_done)
    );

    vpu_top_no_ctrl #(
        .NUM_LANE        (NUM_LANE),
        .n               (ELEM_WIDTH),
        .es              (ES),
        .ALIGN_WIDTH     (ALIGN_WIDTH),
        .ACC_ALIGN_WIDTH (ACC_ALIGN_WIDTH)
    ) u_vpu_top_no_ctrl (
        .clk_i                     (clk_i),
        .rstn_i                    (rstn_i),
        .func_sel_i                (vpu_func_sel),
        .start_i                   (vpu_start),
        .vec_a_posit_i             (vpu_vec_a_posit),
        .vec_b_posit_i             (vpu_vec_b_posit),
        .calc_done_o               (vpu_calc_done),
        .busy_o                    (vpu_busy),
        .done_o                    (vpu_done),
        .vec_result_posit_o        (vpu_vec_result_posit),
        .reduction_result_posit_o  (vpu_reduction_result_posit)
    );

    sfu_top_no_ctrl #(
        .LANES       (SFU_LANE),
        .POSIT_N     (ELEM_WIDTH),
        .POSIT_ES    (ES),
        .RAND_N      (SFU_RAND_N),
        .ALIGN_WIDTH (SFU_ALIGN_WIDTH),
        .NUM_ITER    (SFU_NUM_ITER)
    ) u_sfu_top_no_ctrl (
        .clk_i       (clk_i),
        .rstn_i      (rstn_i),
        .start_i     (sfu_start),
        .seed_load_i (sfu_seed_load),
        .sel_i       (sfu_sel),
        .done_o      (sfu_done),
        .data_i      (sfu_data),
        .seed_high_i (sfu_seed_high),
        .seed_low_i  (sfu_seed_low),
        .result0_o   (sfu_result0),
        .result1_o   (sfu_result1)
    );



    nli_top #(
        .NUM_LANES   (NLI_NUM_LANES),
        .NUM_MACROS  (NLI_NUM_MACROS),
        .NUM_MICROS  (NLI_NUM_MICROS),
        .DATA_WIDTH  (ELEM_WIDTH),
        .MACRO_BOUNDS_FILE (""),
        .MUL_LUT_FILE      (""),
        .Y_BOUNDS_LUT_FILE ("")
    ) u_nli_top_no_ctrl(
        .clk          (clk_i),
        .rstn         (rstn_i),
        .clr          (nli_clr),
        .macro_bounds (nli_macro_bounds),
        .up_valid     (nli_up_valid),
        .up_ready     (nli_up_ready),
        .dn_valid     (nli_dn_valid),
        .dn_ready     (nli_dn_ready),
        .input_data   (nli_input_data),
        .output_data  (nli_output_data),
        .mul_lut_wr_en        (nli_mul_lut_wr_en),
        .mul_lut_wr_addr      (nli_mul_lut_wr_addr),
        .mul_lut_wr_data      (nli_mul_lut_wr_data),
        .y_bounds_lut_wr_en   (nli_y_bounds_lut_wr_en),
        .y_bounds_lut_wr_addr (nli_y_bounds_lut_wr_addr),
        .y_bounds_lut_wr_data (nli_y_bounds_lut_wr_data)
    );

    // ---- scheduler_buf_wrapper instance (bank0 of op_a_buf / out_buf) ------
    scheduler_buf_wrapper #(
        .ROW_COUNT  (16),
        .COL_COUNT  (16),
        .GROUP_SIZE (4),
        .IBANK_AW   (WRP_BANK_ADDR_W),
        .IBANK_DW   (WRP_BANK_DATA_W),
        .MAX_TASKS  (SCH_MAX_TASKS)
    ) u_scheduler_buf_wrapper (
        .clk_i             (clk_i),
        .rst_ni            (rstn_i),
        .start_i           (sch_start),
        .clear_i           (sch_clear),
        .inbuf_base_addr_i (sch_inbuf_base),
        .obuf_base_addr_i  (sch_obuf_base),
        .busy_o            (sch_busy),
        .done_o            (sch_done),
        .error_o           (sch_error),
        .task_count_o      (sch_task_count),
        .inbuf_rd_req_o    (sch_inbuf_rd_req),
        .inbuf_rd_addr_o   (sch_inbuf_rd_addr),
        .inbuf_rd_data_i   (sch_inbuf_rd_data),
        .obuf_wr_req_o     (sch_obuf_wr_req),
        .obuf_wr_addr_o    (sch_obuf_wr_addr),
        .obuf_wr_data_o    (sch_obuf_wr_data)
    );

    // =========================================================================
    // Simulation-only loader/dumper for INIT_FILE and DUMP_FILE support.
    // Stripped during synthesis via synopsys translate_off/on.
    // =========================================================================
    // synopsys translate_off
    logic dump_done;
    logic init_done_op_a;
    logic init_done_op_b;
    logic init_done_out_clear;

    initial begin
        dump_done = 1'b0;
        init_done_op_a = 1'b0;
        init_done_op_b = 1'b0;
        init_done_out_clear = 1'b0;
    end

    // Combine all per-buffer init_done flags into a single signal
    wire init_done = init_done_op_a & init_done_op_b & init_done_out_clear;

    // ---- Loader for op_a_buf ------------------------------------------------
    initial begin
        automatic int fd;
        automatic int scan_status;
        automatic int token_idx;
        automatic int row_addr;
        automatic logic [ELEM_WIDTH-1:0] token;
        automatic logic [WRP_DATA_W-1:0] row_data;
        automatic int tokens_per_row;

        op_a_loader_wr_req  = 1'b0;
        op_a_loader_wr_addr = '0;
        op_a_loader_wr_data = '0;

        tokens_per_row = WRP_DATA_W / ELEM_WIDTH;

        // Wait for reset release
        wait (rstn_i === 1'b1);
        @(posedge clk_i);

        if (OP_A_INIT_FILE != "") begin
            fd = $fopen(OP_A_INIT_FILE, "r");
            if (fd == 0) begin
                $fatal(1, "axu_top loader: failed to open OP_A_INIT_FILE %s", OP_A_INIT_FILE);
            end

            row_addr = 0;
            token_idx = 0;
            row_data = '0;

            while (!$feof(fd) && row_addr < (1 << ADDR_WIDTH)) begin
                scan_status = $fscanf(fd, "%h", token);
                if (scan_status == 1) begin
                    row_data[token_idx * ELEM_WIDTH +: ELEM_WIDTH] = token;
                    token_idx++;

                    if (token_idx == tokens_per_row) begin
                        // Write the assembled row via wrapper acc write port
                        op_a_loader_wr_req  = 1'b1;
                        op_a_loader_wr_addr = row_addr[ADDR_WIDTH-1:0];
                        op_a_loader_wr_data = row_data;
                        @(posedge clk_i);
                        op_a_loader_wr_req  = 1'b0;

                        row_addr++;
                        token_idx = 0;
                        row_data = '0;
                    end
                end else if (scan_status == -1) begin
                    break;
                end else begin
                    void'($fgetc(fd));
                end
            end

            if (token_idx != 0) begin
                $warning("axu_top loader: OP_A_INIT_FILE ends with incomplete row (%0d/%0d tokens)",
                         token_idx, tokens_per_row);
            end

            $fclose(fd);
        end

        // Ensure one cycle of idle before signalling done
        @(posedge clk_i);
        init_done_op_a = 1'b1;
    end

    // ---- Loader for op_b_buf ------------------------------------------------
    initial begin
        automatic int fd;
        automatic int scan_status;
        automatic int token_idx;
        automatic int row_addr;
        automatic logic [ELEM_WIDTH-1:0] token;
        automatic logic [WRP_DATA_W-1:0] row_data;
        automatic int tokens_per_row;

        op_b_loader_wr_req  = 1'b0;
        op_b_loader_wr_addr = '0;
        op_b_loader_wr_data = '0;

        tokens_per_row = WRP_DATA_W / ELEM_WIDTH;

        wait (rstn_i === 1'b1);
        @(posedge clk_i);

        if (OP_B_INIT_FILE != "") begin
            fd = $fopen(OP_B_INIT_FILE, "r");
            if (fd == 0) begin
                $fatal(1, "axu_top loader: failed to open OP_B_INIT_FILE %s", OP_B_INIT_FILE);
            end

            row_addr = 0;
            token_idx = 0;
            row_data = '0;

            while (!$feof(fd) && row_addr < (1 << ADDR_WIDTH)) begin
                scan_status = $fscanf(fd, "%h", token);
                if (scan_status == 1) begin
                    row_data[token_idx * ELEM_WIDTH +: ELEM_WIDTH] = token;
                    token_idx++;

                    if (token_idx == tokens_per_row) begin
                        op_b_loader_wr_req  = 1'b1;
                        op_b_loader_wr_addr = row_addr[ADDR_WIDTH-1:0];
                        op_b_loader_wr_data = row_data;
                        @(posedge clk_i);
                        op_b_loader_wr_req  = 1'b0;

                        row_addr++;
                        token_idx = 0;
                        row_data = '0;
                    end
                end else if (scan_status == -1) begin
                    break;
                end else begin
                    void'($fgetc(fd));
                end
            end

            if (token_idx != 0) begin
                $warning("axu_top loader: OP_B_INIT_FILE ends with incomplete row (%0d/%0d tokens)",
                         token_idx, tokens_per_row);
            end

            $fclose(fd);
        end

        @(posedge clk_i);
        init_done_op_b = 1'b1;
    end

    // ---- Clearer for out_buf (zero-init all 256 rows) -----------------------
    // rf2p_256_128 internal mem is X after power-on; axu_ctrl only writes the
    // rows it actively produces, so unused rows would dump as X. Initialize the
    // entire out_buf to 0 to match sp_sram's $readmemh-style zero default.
    initial begin
        automatic int row_addr;

        out_clear_busy    = 1'b0;
        out_clear_wr_req  = 1'b0;
        out_clear_wr_addr = '0;

        wait (rstn_i === 1'b1);
        @(posedge clk_i);

        out_clear_busy = 1'b1;
        for (row_addr = 0; row_addr < (1 << ADDR_WIDTH); row_addr++) begin
            out_clear_wr_req  = 1'b1;
            out_clear_wr_addr = row_addr[ADDR_WIDTH-1:0];
            @(posedge clk_i);
        end
        out_clear_wr_req  = 1'b0;
        out_clear_wr_addr = '0;
        @(posedge clk_i);
        out_clear_busy = 1'b0;
        init_done_out_clear = 1'b1;
    end

    // ---- Dumper for out_buf -------------------------------------------------
    initial begin
        automatic int fd;
        automatic int row_addr;
        automatic int token_idx;
        automatic int tokens_per_row;
        automatic logic [WRP_DATA_W-1:0] row_data;
        automatic logic [ELEM_WIDTH-1:0] token;
        automatic logic dump_i_prev;

        out_dumper_rd_req  = 1'b0;
        out_dumper_rd_addr = '0;
        dump_i_prev = 1'b0;

        tokens_per_row = WRP_DATA_W / ELEM_WIDTH;

        forever begin
            @(posedge clk_i);
            if (dump_i && !dump_i_prev) begin
                // Rising edge of dump_i
                if (OUT_DUMP_FILE != "") begin
                    fd = $fopen(OUT_DUMP_FILE, "w");
                    if (fd == 0) begin
                        $fatal(1, "axu_top dumper: failed to open OUT_DUMP_FILE %s", OUT_DUMP_FILE);
                    end

                    for (row_addr = 0; row_addr < (1 << ADDR_WIDTH); row_addr++) begin
                        // Issue read request on this cycle's setup time
                        out_dumper_rd_req  = 1'b1;
                        out_dumper_rd_addr = row_addr[ADDR_WIDTH-1:0];
                        // Cycle 1: edge latches the request into rf2p_256_128 Port A
                        @(posedge clk_i);
                        // Cycle 2: qa (acc_rd_data) has settled, sample it
                        @(posedge clk_i);
                        row_data = out_dumper_rd_data;

                        // Write tokens to file
                        for (token_idx = 0; token_idx < tokens_per_row; token_idx++) begin
                            token = row_data[token_idx * ELEM_WIDTH +: ELEM_WIDTH];
                            if (token_idx != 0) begin
                                $fwrite(fd, "  ");
                            end
                            $fwrite(fd, "%04h", token);
                        end
                        $fwrite(fd, "\n");
                    end

                    out_dumper_rd_req  = 1'b0;
                    out_dumper_rd_addr = '0;
                    $fclose(fd);
                    dump_done = 1'b1;
                end
            end
            dump_i_prev = dump_i;
        end
    end
    // synopsys translate_on

endmodule
