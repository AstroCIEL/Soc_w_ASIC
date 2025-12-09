`timescale 1ns/1ps
module my_reg (
    input logic clk,
    input logic rst,
    input logic signed [15:0] d_in,
    input logic load,
    output logic signed [15:0] q_out
);

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            q_out <= 16'b0;
        end else if (load) begin
            q_out <= d_in;
        end
    end
endmodule
