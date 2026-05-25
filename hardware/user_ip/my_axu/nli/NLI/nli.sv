module nli#(
    parameter   NUM_MACROS = 10,
    parameter   NUM_MICROS = 32,
    parameter   DATA_WIDTH = 16,
    localparam  NUM_INTERVALS = (NUM_MACROS-2)*NUM_MICROS + 2,
    localparam  MACRO_INDEX_WIDTH = $clog2(NUM_MACROS),
    localparam  INTERVAL_INDEX_WIDTH = $clog2(NUM_INTERVALS),

    parameter   SUBTRACT_LATENCY = 2,
    parameter   MULTIPLY_LATENCY = 2,
    parameter   ADD_LATENCY = 2
)(
    input   logic                               clk,
    input   logic                               rstn,
    input   logic                               clr,
    input   logic [DATA_WIDTH-1: 0]             macro_bounds [0: NUM_MACROS],

    input   logic [DATA_WIDTH-1: 0]             input_data,
    output  logic [DATA_WIDTH-1: 0]             output_data,

    input   logic                               up_valid,
    output  logic                               up_ready,
    output  logic                               dn_valid,
    input   logic                               dn_ready,

    output  logic                               rd_mul_req,
    output  logic [MACRO_INDEX_WIDTH-1: 0]      rd_mul_addr, 
    input   logic [DATA_WIDTH-1: 0]             rd_mul_data,

    output  logic                               rd_interval_y0_req,
    output  logic [INTERVAL_INDEX_WIDTH-1: 0]   rd_interval_y0_addr,
    input   logic [DATA_WIDTH-1: 0]             rd_interval_y0_data,
    output  logic                               rd_interval_y1_req,
    output  logic [INTERVAL_INDEX_WIDTH-1: 0]   rd_interval_y1_addr,
    input   logic [DATA_WIDTH-1: 0]             rd_interval_y1_data
);

    logic [MACRO_INDEX_WIDTH-1: 0]      macro_index;
    logic [DATA_WIDTH-1: 0]             macro_delta;
    logic                               lower_bound;
    logic                               upper_bound;
    logic [INTERVAL_INDEX_WIDTH-1: 0]   interval_index;
    logic [DATA_WIDTH-1: 0]             interval_delta_2_3;
    logic [DATA_WIDTH-1: 0]             interval_y;
    logic [DATA_WIDTH-1: 0]             y0;

    logic  valid_1_2, ready_1_2;
    logic  valid_2_3, ready_2_3;
    logic  valid_3_4, ready_3_4;

    stage1 #(
        .NUM_MACROS(NUM_MACROS),
        .DATA_WIDTH(DATA_WIDTH),
        .SUBTRACT_LATENCY(SUBTRACT_LATENCY)
    ) u_stage1(
        .clk(clk),  .rstn(rstn), .clr(clr),
        .macro_bounds(macro_bounds),
        .input_data(input_data),
        .macro_index(macro_index),
        .macro_delta(macro_delta),
        .up_valid(up_valid),
        .up_ready(up_ready),
        .dn_valid(valid_1_2),
        .dn_ready(ready_1_2)
    );

    stage2 #(
        .NUM_MACROS(NUM_MACROS),
        .NUM_MICROS(NUM_MICROS),
        .DATA_WIDTH(DATA_WIDTH),
        .MULTIPLY_LATENCY(MULTIPLY_LATENCY),
        .SUBTRACT_LATENCY(SUBTRACT_LATENCY)
    ) u_stage2(
        .clk(clk),  .rstn(rstn), .clr(clr),
        .macro_index(macro_index),
        .macro_delta(macro_delta),
        .interval_index(interval_index),
        .interval_delta(interval_delta_2_3),
        .rd_mul_req(rd_mul_req),
        .rd_mul_addr(rd_mul_addr),
        .rd_mul_data(rd_mul_data),
        .up_valid(valid_1_2),
        .up_ready(ready_1_2),
        .dn_valid(valid_2_3),
        .dn_ready(ready_2_3)
    );

    logic [DATA_WIDTH-1: 0] interval_delta_3_4;
    stage3 #(
        .NUM_MACROS(NUM_MACROS),
        .NUM_MICROS(NUM_MICROS),
        .DATA_WIDTH(DATA_WIDTH),
        .SUBTRACT_LATENCY(SUBTRACT_LATENCY)
    ) u_stage3(
        .clk(clk),  .rstn(rstn), .clr(clr),
        .interval_index(interval_index),
        .interval_delta_in(interval_delta_2_3),
        .interval_y(interval_y),
        .y0(y0),
        .interval_delta_out(interval_delta_3_4),
        .rd_interval_y0_req(rd_interval_y0_req),
        .rd_interval_y0_addr(rd_interval_y0_addr),
        .rd_interval_y0_data(rd_interval_y0_data),
        .rd_interval_y1_req(rd_interval_y1_req),
        .rd_interval_y1_addr(rd_interval_y1_addr),
        .rd_interval_y1_data(rd_interval_y1_data),
        .up_valid(valid_2_3),
        .up_ready(ready_2_3),
        .dn_valid(valid_3_4),
        .dn_ready(ready_3_4) 
    );

    stage4 #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADD_LATENCY(ADD_LATENCY),
        .MULTIPLY_LATENCY(MULTIPLY_LATENCY)
    ) u_stage4(
        .clk(clk),  .rstn(rstn), .clr(clr),
        .interval_delta(interval_delta_3_4),
        .y0(y0),
        .interval_y(interval_y),
        .output_data(output_data),
        .up_valid(valid_3_4),
        .up_ready(ready_3_4),
        .dn_valid(dn_valid),
        .dn_ready(dn_ready)
    );

endmodule