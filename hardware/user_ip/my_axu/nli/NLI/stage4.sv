module stage4 #(
    parameter DATA_WIDTH = 8,
    parameter ADD_LATENCY = 2,
    parameter MULTIPLY_LATENCY = 2
)(
    input   logic                   clk,
    input   logic                   rstn,
    input   logic                   clr,
    input   logic [DATA_WIDTH-1: 0] interval_delta,
    input   logic [DATA_WIDTH-1: 0] y0,
    input   logic [DATA_WIDTH-1: 0] interval_y,
    output  logic [DATA_WIDTH-1: 0] output_data,

    input   logic                   up_valid,
    output  logic                   up_ready,
    output  logic                   dn_valid,
    input   logic                   dn_ready
);

    // Pipeline1 Multiply
    logic [DATA_WIDTH-1: 0] delta_y;
    logic [DATA_WIDTH-1: 0] y0_pipe1;
    logic valid_pipe1, ready_pipe1;
    nli_multiply u_multiply(
        .clk(clk),
        .rstn(rstn),
        .valid(up_valid & up_ready),
        .data1(interval_delta),
        .data2(interval_y),
        .result(delta_y)
    );

    dff #(.WIDTH(DATA_WIDTH), .DEPTH(MULTIPLY_LATENCY)) u_dff_pipe(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in(y0),
        .data_out(y0_pipe1)
    );

    pipe_ctrl #(.PIPE_DEPTH(MULTIPLY_LATENCY)) u_pipe1_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(clr),  .ena(1'b1),
        .up_valid(up_valid),        .up_ready(up_ready),
        .dn_valid(valid_pipe1),    .dn_ready(ready_pipe1)
    );

    // Pipeline2 Add
    nli_add u_add(
        .clk(clk),
        .rstn(rstn),
        .valid(valid_pipe1 & ready_pipe1),
        .data1(y0_pipe1),
        .data2(delta_y),
        .result(output_data)
    );

    pipe_ctrl #(.PIPE_DEPTH(ADD_LATENCY)) u_pipe2_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(clr),  .ena(1'b1),
        .up_valid(valid_pipe1),    .up_ready(ready_pipe1),
        .dn_valid(dn_valid),    .dn_ready(dn_ready)
    );
endmodule