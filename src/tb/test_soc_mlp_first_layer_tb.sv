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
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_0.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[0].main_mem_inst.sram_inst.mem);
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_1.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[1].main_mem_inst.sram_inst.mem);
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_2.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[2].main_mem_inst.sram_inst.mem);
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_3.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[3].main_mem_inst.sram_inst.mem);
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_4.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[4].main_mem_inst.sram_inst.mem);
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_5.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[5].main_mem_inst.sram_inst.mem);
        // $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_6.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[6].main_mem_inst.sram_inst.mem);
        // $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_7.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[7].main_mem_inst.sram_inst.mem);
        // $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_mlp_first_layer_8.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[8].main_mem_inst.sram_inst.mem);
        
        $display("Main memory initialized");

        // Wait for program execution
        #200000000

        $display("\n=== Checking MLP Inference Results ===\n");
        if (i_tpu_lite_soc.i_cpu.issue_stage_i.i_issue_read_operands.gen_asic_regfile.i_ariane_regfile.mem[18] === 64'hDEAD) begin
            $display("Inference results mismatch!");
        end
        else if (i_tpu_lite_soc.i_cpu.issue_stage_i.i_issue_read_operands.gen_asic_regfile.i_ariane_regfile.mem[18] === 64'hABAB) begin
            $display("Inference results match golden results!");
        end
        else begin
            $display("Unexpected result code: 0x%h", i_tpu_lite_soc.i_cpu.issue_stage_i.i_issue_read_operands.gen_asic_regfile.i_ariane_regfile.mem[18]);
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
