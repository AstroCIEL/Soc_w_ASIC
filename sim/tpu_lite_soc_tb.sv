//////////////////////////////////////////////////////////////////////////////////
// Designer:        Zhantong Zhu [Peking University] <zhu_20021122@stu.pku.edu.cn>
// Acknowledgement: GitHub Copilot
// Description:     Testbench for TPU-Lite-SoC
//////////////////////////////////////////////////////////////////////////////////

// resolution should be set to 1 ps for correct simulation of HyperRAM
`timescale 1ps / 1ps

module tpu_lite_soc_tb;
    logic       sys_clk_i, rstn_i;
    
    // Test parameters from C code
    localparam longint ERROR_FLAG_BASE_ADDR = 64'h8000D100;
    localparam longint MEM_BASE_ADDR = 64'h80000000;
    
    // Define error address for TPU AXI test
    longint error_offset;
    int error_macro_idx;
    int error_word_idx;
    logic [63:0] error_flag;
    
    tpu_lite_soc i_tpu_lite_soc(
        .sys_clk_i          (sys_clk_i),
        .rstn_i             (rstn_i),
        .jtag_tck_i         (1'b0),
        .jtag_tms_i         (1'b0),
        .jtag_tdi_i         (1'b0),
        .jtag_tdo_o         (),
        .uart_rx_i          (1'b1),
        .uart_tx_o          ()
    );

    always #1000 sys_clk_i = ~sys_clk_i;

    initial begin
        sys_clk_i = 1'b1;
        rstn_i = 1'b0;

        #20000
        rstn_i = 1'b1;

        // Load memory
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_tpu_dma_0.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[0].main_mem_inst.sram_inst.mem);
        $display("Main memory initialized");

        // Wait for program execution
        #20000000

        // Read and display results for each transfer test
        $display("\n=== TPU AXI Transfer Test Results ===");

        error_offset = ERROR_FLAG_BASE_ADDR - MEM_BASE_ADDR;
        error_macro_idx = int'(error_offset / 8192);
        error_word_idx = int'((error_offset % 8192) / 8);
        
        error_flag = i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[6].main_mem_inst.sram_inst.mem[error_word_idx];
        
        if (error_flag === 64'hABABABABABABABAB) begin
            $display("  Status:        PASS");
        end else begin
            $display("  Status:        FAIL (Error Flag = 0x%016h)", error_flag);
        end
        
        $display("\n=== Test Complete ===\n");
        $finish;
    end

    initial begin
        $fsdbDumpfile("waveform.fsdb");
        $fsdbDumpvars("+all");
        $fsdbDumpMDA();
    end

endmodule