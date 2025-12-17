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
    localparam int NUM_TRANSFER_SIZES = 3;
    localparam int TRANSFER_SIZES[NUM_TRANSFER_SIZES] = '{32, 64, 128};
    localparam longint LOG_BASE_ADDR = 64'h8000D100;
    localparam longint ERROR_FLAG_BASE_ADDR = 64'h8000E000;
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
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_dma.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[0].main_mem_inst.sram_inst.mem);
        $display("Main memory initialized");

        // Wait for program execution
        #20000000

        // Read and display results for each transfer test
        $display("\n=== DMA Transfer Test Results ===");
        for (int t = 0; t < NUM_TRANSFER_SIZES; t++) begin
            automatic longint log_addr = LOG_BASE_ADDR + t * 16;
            automatic longint error_addr = ERROR_FLAG_BASE_ADDR + t * 8;
            
            automatic longint start_cycle_addr = log_addr;
            automatic longint end_cycle_addr = log_addr + 8;
            
            // Calculate which 8KB macro and word offset within that macro
            // Each macro is 8KB = 8192 bytes = 1024 64-bit words
            automatic longint start_offset = start_cycle_addr - MEM_BASE_ADDR;
            automatic int start_macro_idx = int'(start_offset / 8192);
            automatic int start_word_idx = int'((start_offset % 8192) / 8);
            
            automatic longint end_offset = end_cycle_addr - MEM_BASE_ADDR;
            automatic int end_macro_idx = int'(end_offset / 8192);
            automatic int end_word_idx = int'((end_offset % 8192) / 8);
            
            automatic longint error_offset = error_addr - MEM_BASE_ADDR;
            automatic int error_macro_idx = int'(error_offset / 8192);
            automatic int error_word_idx = int'((error_offset % 8192) / 8);
            
            automatic logic [63:0] start_cycle = 
                i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[6].main_mem_inst.sram_inst.mem[start_word_idx];
            
            automatic logic [63:0] end_cycle = 
                i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[6].main_mem_inst.sram_inst.mem[end_word_idx];
            
            automatic logic [63:0] error_flag = 
                i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[7].main_mem_inst.sram_inst.mem[error_word_idx];
            
            automatic longint elapsed_cycles = end_cycle - start_cycle;
            automatic int transfer_size = TRANSFER_SIZES[t];
            automatic int transfer_bytes = transfer_size * 8;
            
            $display("\nTest %0d: Transfer Size = %0d elements (%0d bytes)", 
                     t, transfer_size, transfer_bytes);
            $display("  Start Cycle:   %0d", start_cycle);
            $display("  End Cycle:     %0d", end_cycle);
            $display("  Elapsed:       %0d cycles", elapsed_cycles);
            
            if (error_flag == 64'hABABABABABABABAB) begin
                $display("  Status:        PASS");
            end else begin
                $display("  Status:        FAIL (Error Flag = 0x%016h)", error_flag);
            end
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