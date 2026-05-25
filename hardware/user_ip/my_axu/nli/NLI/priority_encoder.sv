//[MSB, LSB]: 000011111 -> first_one_index = 4
module priority_encoder #(
    parameter  DATA_WIDTH = 8,
    localparam MACRO_INDEX_WIDTH = $clog2(DATA_WIDTH)
)(
    input   logic [DATA_WIDTH-1:0]       input_data,
    output  logic [MACRO_INDEX_WIDTH-1:0] first_one_index,
    output  logic                   all_zeros
);
    always_comb begin
        first_one_index = 0;
        all_zeros = 1;
        for(int i = DATA_WIDTH-1; i >= 0; i--) begin
            if(input_data[i]) begin
                first_one_index = i[MACRO_INDEX_WIDTH-1:0];
                all_zeros = 0;
                break;
            end
        end
    end
endmodule