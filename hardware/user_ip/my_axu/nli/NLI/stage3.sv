module stage3#(
    parameter   NUM_MACROS = 8,
    parameter   NUM_MICROS = 8,
    parameter   DATA_WIDTH = 8,
    localparam  NUM_INTERVALS = (NUM_MACROS-2)*NUM_MICROS + 2,
    localparam  INTERVAL_INDEX_WIDTH = $clog2(NUM_INTERVALS),
    localparam  Y_BOUDNS_INDEX_WIDTH = $clog2(NUM_INTERVALS+1),
    parameter   SUBTRACT_LATENCY = 2
)(
    input   logic                               clk,
    input   logic                               rstn,
    input   logic                               clr,
    input   logic [INTERVAL_INDEX_WIDTH-1: 0]   interval_index,
    input   logic [DATA_WIDTH-1: 0]             interval_delta_in,

    output  logic [DATA_WIDTH-1: 0]             interval_y,
    output  logic [DATA_WIDTH-1: 0]             y0,
    output  logic [DATA_WIDTH-1: 0]             interval_delta_out,

    input   logic                               up_valid,
    output  logic                               up_ready,
    output  logic                               dn_valid,
    input   logic                               dn_ready,

    output  logic                               rd_interval_y0_req,
    output  logic [Y_BOUDNS_INDEX_WIDTH-1: 0]   rd_interval_y0_addr,
    input   logic [DATA_WIDTH-1: 0]             rd_interval_y0_data,
    output  logic                               rd_interval_y1_req,
    output  logic [Y_BOUDNS_INDEX_WIDTH-1: 0]   rd_interval_y1_addr,
    input   logic [DATA_WIDTH-1: 0]             rd_interval_y1_data
);

    // Pipeline1 Read Interval Y Bounds from SRAM
    logic [DATA_WIDTH-1: 0] interval_delta_pipe1;
    logic valid_pipe1, ready_pipe1;
    assign rd_interval_y0_req = up_valid;
    assign rd_interval_y1_req = up_valid;
    assign rd_interval_y0_addr = interval_index;
    assign rd_interval_y1_addr = interval_index + 1;

    dff #(.WIDTH(DATA_WIDTH), .DEPTH(1)) u_dff_pipe1(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in(interval_delta_in),
        .data_out(interval_delta_pipe1)
    );

    pipe_ctrl #(.PIPE_DEPTH(1)) u_pipe1_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(1'b0), .ena(1'b1),
        .up_valid(up_valid),    .up_ready(up_ready),
        .dn_valid(valid_pipe1),    .dn_ready(ready_pipe1)
    );


    // Pipeline2 Subtract
    nli_subtract u_subtract(
        .clk(clk),  .rstn(rstn),
        .valid(valid_pipe1 & ready_pipe1),
        .data1(rd_interval_y1_data),
        .data2(rd_interval_y0_data),
        .result(interval_y)
    );

    dff #(.WIDTH(2*DATA_WIDTH), .DEPTH(SUBTRACT_LATENCY)) u_dff_pipe(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in({interval_delta_pipe1, rd_interval_y0_data}),
        .data_out({interval_delta_out, y0})
    );

    pipe_ctrl #(.PIPE_DEPTH(SUBTRACT_LATENCY)) u_pipe2_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(1'b0), .ena(1'b1),
        .up_valid(valid_pipe1),    .up_ready(ready_pipe1),
        .dn_valid(dn_valid),    .dn_ready(dn_ready)
    );


endmodule