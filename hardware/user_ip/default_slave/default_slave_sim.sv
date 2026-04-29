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

// ---------------------------------------------------------------------------
// Address space simulation
// Use 16-bit word index → 65536 × 64-bit entries = 512 KB modelled space.
// Full 64-bit address is logged; lower bits [18:3] select the array entry
// (byte-addressed, 8 bytes per 64-bit word).
// ---------------------------------------------------------------------------
localparam int unsigned MEM_DEPTH = 65536; // 2^16

logic [63:0] mem [0:MEM_DEPTH-1];

// Log-file handle (simulation only)
integer log_fd;

// -----------------------------------------------------------------------
// Initialise memory and open log file at simulation start
// -----------------------------------------------------------------------
initial begin : init_block
    integer i;
    log_fd = $fopen("default_slave_access.log", "w");
    if (log_fd == 0) begin
        $display("[default_slave] WARNING: failed to open log file default_slave_access.log");
    end else begin
        $fdisplay(log_fd, "=========================================");
        $fdisplay(log_fd, "  default_slave Access Log");
        $fdisplay(log_fd, "  Address space base : 0x4000_0000");
        $fdisplay(log_fd, "  Modelled depth     : %0d x 64-bit words", MEM_DEPTH);
        $fdisplay(log_fd, "  Format: [time_ns] OP addr=<hex> idx=<dec> data=<hex>");
        $fdisplay(log_fd, "=========================================");
    end
    for (i = 0; i < MEM_DEPTH; i = i + 1) begin
        mem[i] = 64'h0000_0000_0000_0000;
    end
end

// -----------------------------------------------------------------------
// Address → array index
// Byte address, 8 bytes per entry → divide by 8 (shift right 3).
// Use lower 19 bits so the index wraps within MEM_DEPTH (16-bit).
// -----------------------------------------------------------------------
wire [15:0] mem_idx = axi_addr[18:3];

// -----------------------------------------------------------------------
// IRQ state. Compare against the low bits of axi_addr (offsets inside
// this slave's region). A write to IRQ_SET_OFFSET raises irq_o; a write
// to IRQ_ACK_OFFSET clears it.
// -----------------------------------------------------------------------
logic irq_q;
assign irq_o = irq_q;

wire [11:0] offset = axi_addr[11:0];

// -----------------------------------------------------------------------
// Read / Write logic
// -----------------------------------------------------------------------
always @(posedge clk_i or posedge rst) begin
    if (rst) begin
        axi_rdata <= 64'h0;
        irq_q     <= 1'b0;
    end else begin
        if (axi_req) begin
            if (axi_we) begin
                // ----- WRITE -----
                mem[mem_idx] <= axi_wdata;
                if (offset == IRQ_SET_OFFSET[11:0]) begin
                    irq_q <= 1'b1;
                end else if (offset == IRQ_ACK_OFFSET[11:0]) begin
                    irq_q <= 1'b0;
                end
                if (log_fd != 0) begin
                    $fdisplay(log_fd,
                        "[%0t ns] WRITE  addr=0x%016h  idx=%0d  wdata=0x%016h  irq=%0b",
                        $time, axi_addr, mem_idx, axi_wdata, irq_q);
                end
            end else begin
                // ----- READ -----
                axi_rdata <= mem[mem_idx];
                if (log_fd != 0) begin
                    $fdisplay(log_fd,
                        "[%0t ns] READ   addr=0x%016h  idx=%0d  rdata=0x%016h",
                        $time, axi_addr, mem_idx, mem[mem_idx]);
                end
            end
        end
    end
end

// -----------------------------------------------------------------------
// Close log file at end of simulation
// -----------------------------------------------------------------------
final begin
    if (log_fd != 0) begin
        $fdisplay(log_fd, "=========================================");
        $fdisplay(log_fd, "  Simulation ended at %0t ns", $time);
        $fdisplay(log_fd, "=========================================");
        $fclose(log_fd);
    end
end

endmodule
