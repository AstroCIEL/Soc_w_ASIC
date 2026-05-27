module stage2#(
    parameter   NUM_MACROS = 8,
    parameter   NUM_MICROS = 32,
    localparam  MICRO_INDEX_WIDTH = $clog2(NUM_MICROS), // 5 bits.
    localparam  MACRO_INDEX_WIDTH = $clog2(NUM_MACROS),

    localparam  NUM_INTERVALS = (NUM_MACROS-2)*NUM_MICROS + 2,
    localparam  INTERVAL_INDEX_WIDTH = $clog2(NUM_INTERVALS),

    parameter   DATA_WIDTH = 8,
    parameter   MULTIPLY_LATENCY = 2,
    parameter   SUBTRACT_LATENCY = 2
)(
    input   logic                               clk,
    input   logic                               rstn,
    input   logic                               clr,
    input   logic [MACRO_INDEX_WIDTH-1: 0]      macro_index,
    input   logic [DATA_WIDTH-1: 0]             macro_delta,
    output  logic [INTERVAL_INDEX_WIDTH-1: 0]   interval_index,
    output  logic [DATA_WIDTH-1: 0]             interval_delta,

    output  logic                               rd_mul_req,
    output  logic [MACRO_INDEX_WIDTH-1: 0]      rd_mul_addr,
    input   logic [DATA_WIDTH-1: 0]             rd_mul_data,

    input   logic                               up_valid,
    output  logic                               up_ready,
    output  logic                               dn_valid,
    input   logic                               dn_ready
);
    // Pipeline1 Read MACRO MUL Factors from SRAM
    assign rd_mul_req = up_valid;
    assign rd_mul_addr = macro_index;
    logic valid_pipe1, ready_pipe1;
    logic [MACRO_INDEX_WIDTH-1: 0]  macro_index_pipe1;
    logic [DATA_WIDTH-1: 0]         macro_delta_pipe1;

    dff #(.WIDTH(DATA_WIDTH+MACRO_INDEX_WIDTH), .DEPTH(1)) u_dff_pipe1(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in({macro_index, macro_delta}),
        .data_out({macro_index_pipe1, macro_delta_pipe1})
    );

    pipe_ctrl #(.PIPE_DEPTH(1)) u_pipe1_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(1'b0), .ena(1'b1),
        .up_valid(up_valid),    .up_ready(up_ready),
        .dn_valid(valid_pipe1),    .dn_ready(ready_pipe1)
    );
    
    // Pipeline2 Multiply
    logic [DATA_WIDTH-1: 0] u;
    logic [MACRO_INDEX_WIDTH-1: 0]  macro_index_pipe3;
    logic valid_pipe2, ready_pipe2;
    nli_multiply u_multiply(
        .clk(clk),  .rstn(rstn),
        .valid(valid_pipe1 & ready_pipe1),
        .data1(macro_delta_pipe1),
        .data2(rd_mul_data),
        .result(u)
    );

    logic [DATA_WIDTH-1: 0] u_dff;
    dff #(.WIDTH(DATA_WIDTH), .DEPTH(1)) u_dff_pipe2_u(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in(u),
        .data_out(u_dff)
    );

    dff #(.WIDTH(MACRO_INDEX_WIDTH), .DEPTH(MULTIPLY_LATENCY+1)) u_dff_pipe2(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in(macro_index_pipe1),
        .data_out(macro_index_pipe3)
    );

    pipe_ctrl #(.PIPE_DEPTH(MULTIPLY_LATENCY+1)) u_pipe2_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(1'b0), .ena(1'b1),
        .up_valid(valid_pipe1),    .up_ready(ready_pipe1),
        .dn_valid(valid_pipe2),    .dn_ready(ready_pipe2)
    );

    //Pipeline3 Floor and Subtract
    logic [INTERVAL_INDEX_WIDTH-1: 0] interval_index_temp;
    logic valid_pipe3, ready_pipe3;
    logic [DATA_WIDTH-1: 0]        u_floor_posit;
    logic [MICRO_INDEX_WIDTH-1: 0] micro_index;
    nli_floor u_floor(
        .clk_i(clk),
		.rstn_i(rstn),
        .data(u),
        .result_posit(u_floor_posit),
        .result_int(micro_index)
    );

    nli_subtract u_subtract(
        .clk(clk),  .rstn(rstn),
        .valid(valid_pipe2 & ready_pipe2),
        .data1(u_dff),
        .data2(u_floor_posit),
        .result(interval_delta)
    );

    // number of micros in macros: 1 , 32, 32, ..., 32, 1
    /* verilator lint_off WIDTHEXPAND */
    assign interval_index_temp = (macro_index_pipe3==0)? 0: 1 + (macro_index_pipe3-1)*NUM_MICROS + micro_index;

    dff #(.WIDTH(INTERVAL_INDEX_WIDTH), .DEPTH(SUBTRACT_LATENCY)) u_dff_pipe3(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in(interval_index_temp),
        .data_out(interval_index)
    );

    pipe_ctrl #(.PIPE_DEPTH(SUBTRACT_LATENCY)) u_pipe3_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(1'b0), .ena(1'b1),
        .up_valid(valid_pipe2),    .up_ready(ready_pipe2),
        .dn_valid(dn_valid),    .dn_ready(dn_ready)
    );

endmodule