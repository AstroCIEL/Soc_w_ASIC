module default_slave #(
    parameter logic [63:0] IRQ_SET_OFFSET = 64'h0000_0000, // write here -> raise irq
    parameter logic [63:0] IRQ_ACK_OFFSET = 64'h0000_0010  // write here -> clear irq
) (
    input  logic        clk_i,
    input  logic        rst,

    // Simplified AXI-like interface (from axi2mem)
    input  logic        axi_req,
    input  logic        axi_we,
    input  logic [63:0] axi_addr,
    input  logic [63:0] axi_wdata,
    output logic [63:0] axi_rdata,

    output logic        irq_o
);



endmodule
