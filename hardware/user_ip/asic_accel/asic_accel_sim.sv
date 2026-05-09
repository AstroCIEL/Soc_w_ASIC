module asic_accel (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        axi_req_i,
    input  logic        axi_we_i,
    input  logic [63:0] axi_addr_i,
    input  logic [63:0] axi_wdata_i,
    output logic [63:0] axi_rdata_o,
    output logic        irq_o
);

localparam logic [11:0] REG_CMD      = 12'h000;
localparam logic [11:0] REG_STATUS   = 12'h008;
localparam logic [11:0] REG_OP_A     = 12'h010;
localparam logic [11:0] REG_OP_B     = 12'h018;
localparam logic [11:0] REG_RESULT   = 12'h020;
localparam logic [11:0] REG_CYCLECNT = 12'h028;
localparam logic [11:0] REG_IRQ_MASK = 12'h030;
localparam logic [11:0] REG_IRQ_STAT = 12'h038;

logic [63:0] op_a_q, op_b_q, result_q, cycle_cnt_q, axi_rdata_q;
logic [15:0] busy_cycles_q;
logic        busy_q, done_q, irq_mask_q, irq_status_q;

wire [11:0] reg_off = axi_addr_i[11:0];
wire        cmd_start = axi_req_i && axi_we_i && (reg_off == REG_CMD) && axi_wdata_i[0];
wire        cmd_clear_done = axi_req_i && axi_we_i && (reg_off == REG_CMD) && axi_wdata_i[1];

always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
        op_a_q       <= '0;
        op_b_q       <= '0;
        result_q     <= '0;
        cycle_cnt_q  <= '0;
        axi_rdata_q  <= '0;
        busy_cycles_q <= '0;
        busy_q       <= 1'b0;
        done_q       <= 1'b0;
        irq_mask_q   <= 1'b0;
        irq_status_q <= 1'b0;
    end else begin
        if (axi_req_i && axi_we_i) begin
            unique case (reg_off)
                REG_OP_A:     op_a_q     <= axi_wdata_i;
                REG_OP_B:     op_b_q     <= axi_wdata_i;
                REG_IRQ_MASK: irq_mask_q <= axi_wdata_i[0];
                REG_IRQ_STAT: if (axi_wdata_i[0]) irq_status_q <= 1'b0;
                default: ;
            endcase
        end else if (axi_req_i) begin
            unique case (reg_off)
                REG_STATUS:   axi_rdata_q <= {62'b0, done_q, busy_q};
                REG_OP_A:     axi_rdata_q <= op_a_q;
                REG_OP_B:     axi_rdata_q <= op_b_q;
                REG_RESULT:   axi_rdata_q <= result_q;
                REG_CYCLECNT: axi_rdata_q <= cycle_cnt_q;
                REG_IRQ_MASK: axi_rdata_q <= {63'b0, irq_mask_q};
                REG_IRQ_STAT: axi_rdata_q <= {63'b0, irq_status_q};
                default:      axi_rdata_q <= 64'h0;
            endcase
        end

        if (cmd_clear_done) begin
            done_q       <= 1'b0;
            irq_status_q <= 1'b0;
        end

        if (cmd_start && !busy_q) begin
            busy_q        <= 1'b1;
            done_q        <= 1'b0;
            cycle_cnt_q   <= '0;
            busy_cycles_q <= 16'd16;
        end

        if (busy_q) begin
            cycle_cnt_q <= cycle_cnt_q + 64'd1;
            if (busy_cycles_q == 16'd0) begin
                busy_q       <= 1'b0;
                done_q       <= 1'b1;
                result_q     <= (op_a_q * op_b_q) + op_a_q + op_b_q;
                irq_status_q <= 1'b1;
            end else begin
                busy_cycles_q <= busy_cycles_q - 16'd1;
            end
        end
    end
end

assign axi_rdata_o = axi_rdata_q;
assign irq_o = irq_status_q & irq_mask_q;

endmodule
