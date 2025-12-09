//////////////////////////////////////////////////////////////////////////////////
// Designer:        Zhantong Zhu [Peking University] <zhu_20021122@stu.pku.edu.cn>
// Acknowledgement: Cursor + Claude
// Description:     Testbench for TPU-Lite-SoC
//////////////////////////////////////////////////////////////////////////////////

// resolution should be set to 1 ps for correct simulation of HyperRAM
`timescale 1ps / 1ps

module tpu_lite_soc_tb;
    logic       sys_clk_i, rstn_i;

    tpu_lite_soc i_tpu_lite_soc(
        .sys_clk_i          (sys_clk_i),
        .rstn_i             (rstn_i)
    );

    always #1000 sys_clk_i = ~sys_clk_i;

    initial begin
        sys_clk_i = 1'b1;
        rstn_i = 1'b0;

        #20000
        rstn_i = 1'b1;

        // Load memory
        // $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_axi.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[0].main_mem_inst.sram_inst.mem);
        $readmemh("/project/ztzhu/TPU-Lite-SoC/sim/test_dma.hex", i_tpu_lite_soc.i_main_mem_wrapper.gen_main_mem[0].main_mem_inst.sram_inst.mem);
        $display("Main memory initialized");

        #20000000
        $finish;
    end

    initial begin
        $fsdbDumpfile("waveform.fsdb");
        $fsdbDumpvars("+all");
        $fsdbDumpMDA();
    end

endmodule
