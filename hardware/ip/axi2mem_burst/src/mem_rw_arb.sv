// Copyright 2024 HUJIYONG. SPDX-License-Identifier: SHL-0.51
//
// mem_rw_arb.sv
// -------------
// 2-to-1 memory port arbiter with burst-sticky scheduling.
//
// Policy:
//   - Keep serving the currently selected port as long as it has a pending
//     request — this keeps bursts unbroken.
//   - If the currently selected port has no request this cycle, switch to
//     the other port (if it has a request).
//   - If neither port has a request, idle.
//
// The downstream SRAM is assumed single-cycle, always-accept (no backpressure).
// Response latency is 1 cycle: rvalid asserted one cycle after ANY granted
// request (read or write), as required by the axi_to_mem protocol.

module mem_rw_arb #(
    parameter int unsigned AddrWidth = 64,
    parameter int unsigned DataWidth = 64
) (
    input  logic                     clk_i,
    input  logic                     rst_ni,

    // Port 0 (read port from axi_to_mem_split)
    input  logic                     p0_req_i,
    output logic                     p0_gnt_o,
    input  logic [AddrWidth-1:0]     p0_addr_i,
    input  logic [DataWidth-1:0]     p0_wdata_i,
    input  logic [DataWidth/8-1:0]   p0_strb_i,
    input  logic                     p0_we_i,
    output logic                     p0_rvalid_o,
    output logic [DataWidth-1:0]     p0_rdata_o,

    // Port 1 (write port from axi_to_mem_split)
    input  logic                     p1_req_i,
    output logic                     p1_gnt_o,
    input  logic [AddrWidth-1:0]     p1_addr_i,
    input  logic [DataWidth-1:0]     p1_wdata_i,
    input  logic [DataWidth/8-1:0]   p1_strb_i,
    input  logic                     p1_we_i,
    output logic                     p1_rvalid_o,
    output logic [DataWidth-1:0]     p1_rdata_o,

    // Single SRAM port (always accepts, 1-cycle read latency)
    output logic                     mem_req_o,
    output logic                     mem_we_o,
    output logic [AddrWidth-1:0]     mem_addr_o,
    output logic [DataWidth/8-1:0]   mem_be_o,
    output logic [DataWidth-1:0]     mem_wdata_o,
    input  logic [DataWidth-1:0]     mem_rdata_i
);

    // ----------------------------------------------------------------
    // Arbitration: burst-sticky
    // ----------------------------------------------------------------
    logic sel;          // 0 = port0 selected, 1 = port1 selected
    logic last_sel_q;   // last selected port (for sticky)

    always_comb begin
        if (last_sel_q == 1'b0) begin
            // Last served port 0 — stay sticky unless port 0 has no request
            if (p0_req_i)
                sel = 1'b0;
            else if (p1_req_i)
                sel = 1'b1;
            else
                sel = 1'b0;
        end else begin
            // Last served port 1 — stay sticky unless port 1 has no request
            if (p1_req_i)
                sel = 1'b1;
            else if (p0_req_i)
                sel = 1'b0;
            else
                sel = 1'b1;
        end
    end

    // Remember which port was last granted
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            last_sel_q <= 1'b0;
        end else if (p0_req_i || p1_req_i) begin
            last_sel_q <= sel;
        end
    end

    // ----------------------------------------------------------------
    // Grant signals
    // ----------------------------------------------------------------
    assign p0_gnt_o = (sel == 1'b0) && p0_req_i;
    assign p1_gnt_o = (sel == 1'b1) && p1_req_i;

    // ----------------------------------------------------------------
    // Mux to SRAM
    // ----------------------------------------------------------------
    assign mem_req_o   = (sel == 1'b0) ? p0_req_i   : p1_req_i;
    assign mem_we_o    = (sel == 1'b0) ? p0_we_i    : p1_we_i;
    assign mem_addr_o  = (sel == 1'b0) ? p0_addr_i  : p1_addr_i;
    assign mem_be_o    = (sel == 1'b0) ? p0_strb_i  : p1_strb_i;
    assign mem_wdata_o = (sel == 1'b0) ? p0_wdata_i : p1_wdata_i;

    // ----------------------------------------------------------------
    // Response routing (1-cycle latency).
    // axi_to_mem expects rvalid for EVERY granted request (read OR write).
    // ----------------------------------------------------------------
    logic rvalid_q;
    logic rsel_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            rvalid_q <= 1'b0;
            rsel_q   <= 1'b0;
        end else begin
            if (p0_gnt_o) begin
                rvalid_q <= 1'b1;
                rsel_q   <= 1'b0;
            end else if (p1_gnt_o) begin
                rvalid_q <= 1'b1;
                rsel_q   <= 1'b1;
            end else begin
                rvalid_q <= 1'b0;
            end
        end
    end

    assign p0_rvalid_o = rvalid_q && (rsel_q == 1'b0);
    assign p1_rvalid_o = rvalid_q && (rsel_q == 1'b1);
    assign p0_rdata_o  = mem_rdata_i;
    assign p1_rdata_o  = mem_rdata_i;

endmodule
