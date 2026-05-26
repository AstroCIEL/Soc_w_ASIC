// Single-port SRAM (synthesizable).
// One read/write port shared between writes and reads on each cycle.
// On a write cycle (cen=0, wen=1): mem[addr] <= din, dout reflects din next cycle.
// On a read  cycle (cen=0, wen=0): dout <= mem[addr] next cycle.
// Memory has no power-on initialization; contents are loaded at runtime via wen.

module sp_sram #(
    parameter int DATA_WIDTH = 128,
    parameter int ADDR_WIDTH = 9
) (
    input  logic                  clk,
    input  logic                  cen,    // chip enable, active low
    input  logic                  wen,    // write enable, active high (1=write, 0=read)
    input  logic [ADDR_WIDTH-1:0] addr,
    input  logic [DATA_WIDTH-1:0] din,
    output logic [DATA_WIDTH-1:0] dout
);

    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    always_ff @(posedge clk) begin
        if (!cen) begin
            if (wen) begin
                mem[addr] <= din;
                dout      <= din;
            end else begin
                dout <= mem[addr];
            end
        end
    end

endmodule
