//////////////////////////////////////////////////////////////////////////////////
// Designer:        Zhantong Zhu [Peking University] <zhu_20021122@stu.pku.edu.cn>
// Acknowledgement: GitHub Copilot
// Description:     Testbench for TPU-Lite
//////////////////////////////////////////////////////////////////////////////////

// resolution should be set to 1 ps
`timescale 1ps / 1ps

module tpu_tb;

    localparam int AXI_ADDR_WIDTH = 64;
    localparam int AXI_DATA_WIDTH = 64;

    localparam longint TPU_BASE_ADDR = 64'h4000_0000;
    localparam longint TPU_END_ADDR  = 64'h4001_7008;

    logic       clk, rstn_i;
    logic [63:0] axi_rdata_o;
    logic [63:0] axi_wdata_i;
    logic        axi_req_i;
    logic        axi_we_i;
    logic [63:0] axi_addr_i;

    logic [63:0] write_data;

    tpu i_tpu (
        .clk        (clk),
        .rst        (~rstn_i),
        .axi_en     (axi_req_i),
        .axi_we     (axi_we_i),
        .axi_addr   (axi_addr_i),
        .axi_wdata  (axi_wdata_i),
        .axi_rdata  (axi_rdata_o)
    );

    always #1000 clk = ~clk;

    // Task for AXI write
    task axi_write(input logic [AXI_ADDR_WIDTH-1:0] addr, input logic [AXI_DATA_WIDTH-1:0] data);
        @(posedge clk);
        #200;
        axi_req_i = 1;
        axi_we_i = 1;
        axi_addr_i = addr;
        axi_wdata_i = data;
        @(posedge clk);
        #200;
        axi_req_i = 0;
        axi_we_i = 0;
        axi_wdata_i = data + 1; // Wrong data to verify write
    endtask

    // Task for AXI read
    task axi_read(input logic [AXI_ADDR_WIDTH-1:0] addr, output logic [AXI_DATA_WIDTH-1:0] data);
        @(posedge clk);
        #200;
        axi_req_i = 1;
        axi_we_i = 0;
        axi_addr_i = addr;
        @(posedge clk);
        #200;
        axi_req_i = 0;
        data = axi_rdata_o;
    endtask


    initial begin
        clk = 1'b1;
        rstn_i = 1'b0;

        #20000
        rstn_i = 1'b1;

        // Sequential write from TPU base to end address
        $display("\n=== TPU Write Test ===");
        for (longint addr = TPU_BASE_ADDR; addr < TPU_END_ADDR; addr += 8) begin
            
            write_data = addr + 64'hA5A5_A5A5_A5A5A5; // Example data pattern
            axi_write(addr, write_data);
        end
        $display("TPU Write Test Completed.");

        $display("\n=== TPU Read Test ===");

        $display("\n=== Test Complete ===\n");
        $finish;
    end

    initial begin
        $fsdbDumpfile("waveform.fsdb");
        $fsdbDumpvars("+all");
        $fsdbDumpMDA();
    end

endmodule