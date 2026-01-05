//------------------------------------------------------------------------------
// Description: DMA Frontend Configuration Registers
// Author:      Zhantong Zhu <zhu_20021122@stu.pku.edu.cn> [Peking University]
//------------------------------------------------------------------------------

module dma_regs #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic,
    parameter int unsigned AXI_ADDR_WIDTH = 64
) (
    input logic clk_i,
    input logic rst_ni,

    // Bus Interface
    input  reg_req_t req_i,
    output reg_rsp_t rsp_o,

    // DMA Control Signals
    output logic [AXI_ADDR_WIDTH-1:0] src_addr_o,
    output logic [AXI_ADDR_WIDTH-1:0] dst_addr_o,
    output logic [AXI_ADDR_WIDTH-1:0] length_o,
    output logic [              31:0] config_o,
    output logic                      launch_o,

    // DMA Status Signals
    input logic busy_i,
    input logic error_i,
    input logic ready_i
);

    logic [31:0] src_addr_lo, src_addr_hi;
    logic [31:0] dst_addr_lo, dst_addr_hi;
    logic [31:0] length_lo, length_hi;
    logic [31:0] config_reg;
    logic        launch_q;

    assign src_addr_o = {src_addr_hi, src_addr_lo};
    assign dst_addr_o = {dst_addr_hi, dst_addr_lo};
    assign length_o   = {length_hi, length_lo};
    assign config_o   = config_reg;
    assign launch_o   = launch_q;

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            src_addr_lo <= '0;
            src_addr_hi <= '0;
            dst_addr_lo <= '0;
            dst_addr_hi <= '0;
            length_lo   <= '0;
            length_hi   <= '0;
            config_reg  <= '0;
            launch_q    <= 1'b0;
        end else begin
            launch_q <= 1'b0;  // Auto-clear launch signal

            if (req_i.valid && req_i.write) begin
            unique case (req_i.addr[7:0])
                8'h00:   src_addr_lo <= req_i.wdata[31:0];
                8'h08:   src_addr_hi <= req_i.wdata[31:0];
                8'h10:   dst_addr_lo <= req_i.wdata[31:0];
                8'h18:   dst_addr_hi <= req_i.wdata[31:0];
                8'h20:   length_lo <= req_i.wdata[31:0];
                8'h28:   length_hi <= req_i.wdata[31:0];
                8'h30:   config_reg <= req_i.wdata[31:0];
                8'h38:   launch_q <= 1'b1;
                default: ;
            endcase
            end
        end
    end

    always_comb begin
        rsp_o.ready = 1'b1;
        rsp_o.error = 1'b0;
        rsp_o.rdata = '0;

        if (req_i.valid && !req_i.write) begin
            unique case (req_i.addr[7:0])
            8'h00: rsp_o.rdata = {32'b0, src_addr_lo};
            8'h08: rsp_o.rdata = {32'b0, src_addr_hi};
            8'h10: rsp_o.rdata = {32'b0, dst_addr_lo};
            8'h18: rsp_o.rdata = {32'b0, dst_addr_hi};
            8'h20: rsp_o.rdata = {32'b0, length_lo};
            8'h28: rsp_o.rdata = {32'b0, length_hi};
            8'h30: rsp_o.rdata = {32'b0, config_reg};
            8'h40:
            rsp_o.rdata = {
                32'b0, 29'b0, ready_i, error_i, busy_i
            };  // Status: [2]=Ready, [1]=Error, [0]=Busy
            default: rsp_o.error = 1'b1;
            endcase
        end
    end

endmodule
