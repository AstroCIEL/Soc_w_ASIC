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
    localparam int NUM_TRANSFER_SIZES = 4;
    localparam int TRANSFER_SIZES[NUM_TRANSFER_SIZES] = '{16, 64, 256, 1024};
    localparam longint LOG_BASE_ADDR = 64'h8000D200;
    localparam longint ERROR_FLAG_ADDR = 64'h8000D100;
    localparam longint MEM_BASE_ADDR = 64'h80000000;

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
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_speed_comparison.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[0].main_mem_inst.sram_inst.mem);
        $display("Main memory initialized");

        // Wait for program execution
        #20000000

        // Check Error Flag
        // ERROR_FLAG_ADDR = 0x8000D100 -> Offset 0xD100 = 53504 -> Macro 6
        begin
            automatic longint error_offset = ERROR_FLAG_ADDR - MEM_BASE_ADDR;
            automatic int error_word_idx = int'((error_offset % 8192) / 8);
            automatic logic [63:0] error_flag = 
                i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[6].main_mem_inst.sram_inst.mem[error_word_idx];
            
            if (error_flag == 64'hABABABABABABABAB) begin
                $display("\nStatus: PASS (Error Flag = 0x%016h)", error_flag);
            end else begin
                $display("\nStatus: FAIL (Error Flag = 0x%016h)", error_flag);
            end
        end

        // Read and display results for each transfer test
        $display("\n=== TPU Transfer Speed Comparison Results ===");
        $display("Size(words) | CPU Write | CPU Read | DMA Write | DMA Read");
        
        for (int t = 0; t < NUM_TRANSFER_SIZES; t++) begin
            // Each log entry is 5 * 8 bytes = 40 bytes
            automatic longint log_addr = LOG_BASE_ADDR + t * 40;
            
            // We need to read 5 values. All are in Macro 6 (0xD200+)
            automatic longint val[5];
            
            for (int i = 0; i < 5; i++) begin
                automatic longint addr = log_addr + i * 8;
                automatic longint offset = addr - MEM_BASE_ADDR;
                automatic int word_idx = int'((offset % 8192) / 8);
                val[i] = i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[6].main_mem_inst.sram_inst.mem[word_idx];
            end
            
            $display("%11d | %9d | %8d | %9d | %8d", 
                     val[0], val[1], val[2], val[3], val[4]);
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