module stage1 #(
    parameter   NUM_MACROS = 10,
    localparam  MACRO_INDEX_WIDTH = $clog2(NUM_MACROS),
    parameter   DATA_WIDTH = 8,
    parameter   SUBTRACT_LATENCY = 2
)(
    input   logic                           clk,
    input   logic                           rstn,
    input   logic                           clr,
    input   logic [DATA_WIDTH-1: 0]         macro_bounds [0: NUM_MACROS],
    input   logic [DATA_WIDTH-1: 0]         input_data,
    output  logic [MACRO_INDEX_WIDTH-1: 0]  macro_index,
    output  logic [DATA_WIDTH-1: 0]         macro_delta,

    input   logic                           up_valid,
    output  logic                           up_ready,
    output  logic                           dn_valid,
    input   logic                           dn_ready
);

    logic [MACRO_INDEX_WIDTH-1: 0]  macro_index_pipe0;
    logic [DATA_WIDTH-1: 0]         input_data_clamped_pipe0;
    logic [DATA_WIDTH-1: 0]         lower_bound_pipe0;

    logic [DATA_WIDTH-1: 0]         macro_delta_intermediate;
    logic [MACRO_INDEX_WIDTH-1: 0]  macro_index_intermediate;
    logic [NUM_MACROS: 0]           greater_equal_signals;
    logic                           max_flag;
    logic                           min_flag;
    logic                           all_zeros;

    // Pipeline 1 
    genvar i;
    generate
        // greater_equal = (data1 >= data2)
        for(i=0; i<=NUM_MACROS; i++) begin: gen_comparators
            nli_compareGreaterEqual u_comparator(
                .data1(input_data),
                .data2(macro_bounds[i]),
                .greater_equal(greater_equal_signals[i])
            );
        end
    endgenerate

    priority_encoder #(
        .DATA_WIDTH(NUM_MACROS)
    ) u_priority_encoder(
        .input_data(greater_equal_signals[NUM_MACROS-1:0]),
        .first_one_index(macro_index_intermediate),
        .all_zeros(all_zeros)
    );
    assign max_flag = greater_equal_signals[NUM_MACROS];
    assign min_flag = all_zeros;
    assign macro_index_pipe0 = max_flag? NUM_MACROS-1: (min_flag? 0: macro_index_intermediate);
    assign input_data_clamped_pipe0 = max_flag? macro_bounds[NUM_MACROS]: (min_flag? macro_bounds[0]: input_data);
    assign lower_bound_pipe0 = macro_bounds[macro_index_pipe0];


    logic [MACRO_INDEX_WIDTH-1: 0]  macro_index_pipe1;
    logic [DATA_WIDTH-1: 0]         input_data_clamped_pipe1;
    logic [DATA_WIDTH-1: 0]         lower_bound_pipe1;
    logic                           valid_pipe1;
    logic                           ready_pipe1;
    
    dff #(.WIDTH(MACRO_INDEX_WIDTH + 2*DATA_WIDTH), .DEPTH(1)) u_dff_pipe1(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in({macro_index_pipe0, input_data_clamped_pipe0, lower_bound_pipe0}),
        .data_out({macro_index_pipe1, input_data_clamped_pipe1, lower_bound_pipe1})
    );

    pipe_ctrl #(.PIPE_DEPTH(1)) u_pipe1_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(clr),  .ena(1'b1),
        .up_valid(up_valid),    .up_ready(up_ready),
        .dn_valid(valid_pipe1),    .dn_ready(ready_pipe1)
    );

    // pipeline 2
    logic [MACRO_INDEX_WIDTH-1: 0]  macro_index_pipe2;
    nli_subtract u_subtract(
        .clk(clk),  .rstn(rstn),
        .valid(valid_pipe1 & ready_pipe1),
        .data1(input_data_clamped_pipe1),
        .data2(lower_bound_pipe1),
        .result(macro_delta)
    );

    dff #(.WIDTH(MACRO_INDEX_WIDTH), .DEPTH(SUBTRACT_LATENCY)) u_dff_pipe2(
        .clk(clk),  .rstn(rstn),    .ena(1'b1),
        .data_in(macro_index_pipe1),
        .data_out(macro_index_pipe2)
    );

    pipe_ctrl #(.PIPE_DEPTH(SUBTRACT_LATENCY)) u_pipe2_ctrl(
        .clk(clk),  .rstn(rstn),    .clr(clr),  .ena(1'b1),
        .up_valid(valid_pipe1),    .up_ready(ready_pipe1),
        .dn_valid(dn_valid),    .dn_ready(dn_ready)
    );

    assign macro_index = macro_index_pipe2;

endmodule
