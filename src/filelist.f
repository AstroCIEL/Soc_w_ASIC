///////////////////////////////////////////////////////////////////////////////
// Description:  RTL Source Filelist
// Author:       Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
// Acknowledge:  Zhantong Zhu [Peking University]
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Include && Package
///////////////////////////////////////////////////////////////////////////////
+incdir+src/soc/misc/include/
+incdir+src/soc/soc_axi/include/

// WARNING: ORDER is important !!!
src/soc/cpu_cva6/include/config_pkg.sv
src/soc/cpu_cva6/include/cv64a6_config_pkg.sv
src/soc/cpu_cva6/include/riscv_pkg.sv
src/soc/cpu_cva6/include/ariane_pkg.sv
src/soc/cpu_cva6/include/wt_cache_pkg.sv
src/soc/cpu_cva6/include/std_cache_pkg.sv
src/soc/cpu_cva6/include/instr_tracer_pkg.sv
src/soc/cpu_cva6/include/fpnew_pkg.sv
src/soc/cpu_cva6/include/acc_pkg.sv
src/soc/cpu_cva6/include/cvxif_pkg.sv
src/soc/cpu_cva6/include/cvxif_instr_pkg.sv
src/soc/soc_pkg.sv
src/soc/soc_axi/axi_bus/include/axi_pkg.sv
src/soc/soc_axi/axi_bus/include/ariane_axi_pkg.sv
src/soc/soc_axi/axi_bus/include/ariane_axi_soc_pkg.sv
src/soc/soc_axi/axi_bus/include/axi_intf.sv
src/soc/soc_axi/dma/idma_pkg.sv
src/soc/soc_axi/reg_bus/reg_intf.sv
src/soc/soc_axi/riscv-dbg/dm_pkg.sv
src/soc/misc/cf_math_pkg.sv

///////////////////////////////////////////////////////////////////////////////
// Testbench
///////////////////////////////////////////////////////////////////////////////

src/tb/test_soc_mlp_first_layer_tb.sv

///////////////////////////////////////////////////////////////////////////////
// SoC
///////////////////////////////////////////////////////////////////////////////

src/soc/tpu_lite_soc.sv
src/soc/soc_axi/peripheral.sv

// AXI Bus
src/soc/soc_axi/axi_bus/axi_multicut.sv
src/soc/soc_axi/axi_bus/axi_cut.sv
src/soc/soc_axi/axi_bus/axi_join.sv
src/soc/soc_axi/axi_bus/axi_delayer.sv
src/soc/soc_axi/axi_bus/axi_id_prepend.sv
src/soc/soc_axi/axi_bus/axi_atop_filter.sv
src/soc/soc_axi/axi_bus/axi_err_slv.sv
src/soc/soc_axi/axi_bus/axi_mux.sv
src/soc/soc_axi/axi_bus/axi_demux.sv
src/soc/soc_axi/axi_bus/axi_xbar.sv
src/soc/soc_axi/axi_bus/axi_fifo.sv
src/soc/soc_axi/axi_bus/axi_dw_converter.sv
src/soc/soc_axi/axi_bus/axi_dw_downsizer.sv
src/soc/soc_axi/axi_bus/axi_dw_upsizer.sv
src/soc/soc_axi/axi_bus/axi_burst_splitter.sv
src/soc/soc_axi/axi_bus/axi_serializer.sv
src/soc/soc_axi/axi_bus/axi_lite_interface.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_ar_buffer.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_aw_buffer.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_b_buffer.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_r_buffer.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_w_buffer.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_single_slice.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_slice.sv
src/soc/soc_axi/axi_bus/axi_slice/axi_slice_wrap.sv

// Bus Converter
src/soc/soc_axi/bus_converter/axi2mem.sv
src/soc/soc_axi/bus_converter/axi2mem_multi_cycle_read.sv
src/soc/soc_axi/bus_converter/apb_to_reg.sv
src/soc/soc_axi/bus_converter/axi2apb_64_32.sv
src/soc/soc_axi/bus_converter/axi_to_axi_lite.sv
src/soc/soc_axi/bus_converter/axi_to_reg.sv
src/soc/soc_axi/bus_converter/axi_lite_to_reg.sv

// RISC-V Debug Module
src/soc/soc_axi/riscv-dbg/dm_csrs.sv
src/soc/soc_axi/riscv-dbg/dmi_cdc.sv
src/soc/soc_axi/riscv-dbg/dmi_jtag.sv
src/soc/soc_axi/riscv-dbg/dmi_jtag_tap.sv
src/soc/soc_axi/riscv-dbg/dm_mem.sv
src/soc/soc_axi/riscv-dbg/dm_sba.sv
src/soc/soc_axi/riscv-dbg/dm_top.sv
src/soc/soc_axi/riscv-dbg/debug_rom.sv

// Core-local Interrupt Controller
src/soc/soc_axi/clint.sv

// BootROM
src/soc/soc_axi/bootrom.sv

// Main Memory
src/soc/soc_axi/main_mem/main_mem_wrapper.sv

// Platform-Level Interrupt Controller
src/soc/soc_axi/rv_plic/plic_regmap.sv
src/soc/soc_axi/rv_plic/rv_plic_gateway.sv
src/soc/soc_axi/rv_plic/rv_plic_target.sv
src/soc/soc_axi/rv_plic/plic_top.sv

// Timer
src/soc/soc_axi/apb_timer/apb_timer.sv
src/soc/soc_axi/apb_timer/timer.sv

// UART
src/soc/soc_axi/apb_uart/apb_uart.sv
src/soc/soc_axi/apb_uart/slib_clock_div.sv
src/soc/soc_axi/apb_uart/slib_counter.sv
src/soc/soc_axi/apb_uart/slib_edge_detect.sv
src/soc/soc_axi/apb_uart/slib_fifo.sv
src/soc/soc_axi/apb_uart/slib_input_filter.sv
src/soc/soc_axi/apb_uart/slib_input_sync.sv
src/soc/soc_axi/apb_uart/slib_mv_filter.sv
src/soc/soc_axi/apb_uart/uart_baudgen.sv
src/soc/soc_axi/apb_uart/uart_interrupt.sv
src/soc/soc_axi/apb_uart/uart_receiver.sv
src/soc/soc_axi/apb_uart/uart_transmitter.sv

// Clk
src/soc/soc_axi/clk/dco_regs.sv

// Common Cells
src/soc/misc/rstgen.sv
src/soc/misc/rstgen_bypass.sv
src/soc/misc/addr_decode.sv
src/soc/misc/counter.sv
src/soc/misc/delta_counter.sv
src/soc/misc/fall_through_register.sv
src/soc/misc/stream_arbiter.sv
src/soc/misc/stream_arbiter_flushable.sv
src/soc/misc/stream_mux.sv
src/soc/misc/stream_demux.sv
src/soc/misc/stream_register.sv
src/soc/misc/stream_fifo.sv
src/soc/misc/stream_fifo_optimal_wrap.sv
src/soc/misc/passthrough_stream_fifo.sv
src/soc/misc/cdc_2phase.sv
src/soc/misc/cdc_fifo_2phase.sv
src/soc/misc/cdc_fifo_gray.sv
src/soc/misc/binary_to_gray.sv
src/soc/misc/gray_to_binary.sv
src/soc/misc/spill_register_flushable.sv
src/soc/misc/spill_register.sv
src/soc/misc/fifo_v1.sv
src/soc/misc/fifo_v2.sv
src/soc/misc/fifo_v3.sv
src/soc/misc/stream_delay.sv
src/soc/misc/lfsr.sv
src/soc/misc/lfsr_8bit.sv
src/soc/misc/lfsr_16bit.sv
src/soc/misc/lzc.sv
src/soc/misc/cluster_clk_cells.sv
src/soc/misc/pulp_clk_cells.sv
src/soc/misc/id_queue.sv
src/soc/misc/onehot_to_bin.sv
src/soc/misc/sync.sv
src/soc/misc/rr_arb_tree.sv
src/soc/misc/shift_reg.sv
src/soc/misc/unread.sv
src/soc/misc/popcount.sv
src/soc/misc/exp_backoff.sv
src/soc/misc/tc_sram.sv

// Technology-Specific Cells
src/soc/tech_specific/tc_clk.v
src/soc/tech_specific/tc_sram.v
// src/soc/tech_specific/DCO.v
// src/soc/sram/TSMC_RF_BITMASK_128x128/VERILOG/FPGA/TSMC_RF_BITMASK_128x128.v
// src/soc/sram/TSMC_RF_BITMASK_128x46/VERILOG/FPGA/TSMC_RF_BITMASK_128x46.v
// src/soc/sram/TSMC_SRAM_BITMASK_1024x64/VERILOG/FPGA/TSMC_SRAM_BITMASK_1024x64.v

// DMA Engine
src/soc/soc_axi/dma/dma_regs.sv
src/soc/soc_axi/dma/dma_wrapper.sv
src/soc/soc_axi/dma/idma_axi_read.sv
src/soc/soc_axi/dma/idma_axi_write.sv
src/soc/soc_axi/dma/idma_backend.sv
// src/soc/soc_axi/dma/idma_backend_synth.sv
src/soc/soc_axi/dma/idma_channel_coupler.sv
src/soc/soc_axi/dma/idma_dataflow_element.sv
src/soc/soc_axi/dma/idma_error_handler.sv
src/soc/soc_axi/dma/idma_legalizer.sv
src/soc/soc_axi/dma/idma_legalizer_page_splitter.sv
src/soc/soc_axi/dma/idma_transport.sv



///////////////////////////////////////////////////////////////////////////////
// CVA6 CPU Core
///////////////////////////////////////////////////////////////////////////////

src/soc/cpu_cva6/cva6.sv

// Floating Point Unit
src/soc/cpu_cva6/fpu/fpnew_cast_multi.sv
src/soc/cpu_cva6/fpu/fpnew_classifier.sv
src/soc/cpu_cva6/fpu/fpnew_divsqrt_multi.sv
src/soc/cpu_cva6/fpu/fpnew_fma_multi.sv
src/soc/cpu_cva6/fpu/fpnew_fma.sv
src/soc/cpu_cva6/fpu/fpnew_noncomp.sv
src/soc/cpu_cva6/fpu/fpnew_opgroup_block.sv
src/soc/cpu_cva6/fpu/fpnew_opgroup_fmt_slice.sv
src/soc/cpu_cva6/fpu/fpnew_opgroup_multifmt_slice.sv
src/soc/cpu_cva6/fpu/fpnew_rounding.sv
src/soc/cpu_cva6/fpu/fpnew_top.sv
src/soc/cpu_cva6/fpu/fpu_div_sqrt_mvp/defs_div_sqrt_mvp.sv
src/soc/cpu_cva6/fpu/fpu_div_sqrt_mvp/control_mvp.sv
src/soc/cpu_cva6/fpu/fpu_div_sqrt_mvp/div_sqrt_top_mvp.sv
src/soc/cpu_cva6/fpu/fpu_div_sqrt_mvp/iteration_div_sqrt_mvp.sv
src/soc/cpu_cva6/fpu/fpu_div_sqrt_mvp/norm_div_sqrt_mvp.sv
src/soc/cpu_cva6/fpu/fpu_div_sqrt_mvp/nrbd_nrsc_mvp.sv
src/soc/cpu_cva6/fpu/fpu_div_sqrt_mvp/preprocess_mvp.sv

// CVXIF
src/soc/cpu_cva6/cvxif_fu.sv
src/soc/cpu_cva6/cvxif_example/cvxif_example_coprocessor.sv
src/soc/cpu_cva6/cvxif_example/instr_decoder.sv

// Top-level Source Files (not necessarily instantiated at the top of the cva6).
src/soc/cpu_cva6/alu.sv
src/soc/cpu_cva6/fpu_wrap.sv
src/soc/cpu_cva6/branch_unit.sv
src/soc/cpu_cva6/compressed_decoder.sv
src/soc/cpu_cva6/controller.sv
src/soc/cpu_cva6/csr_buffer.sv
src/soc/cpu_cva6/csr_regfile.sv
src/soc/cpu_cva6/decoder.sv
src/soc/cpu_cva6/ex_stage.sv
src/soc/cpu_cva6/instr_realign.sv
src/soc/cpu_cva6/id_stage.sv
src/soc/cpu_cva6/issue_read_operands.sv
src/soc/cpu_cva6/issue_stage.sv
src/soc/cpu_cva6/load_unit.sv
src/soc/cpu_cva6/load_store_unit.sv
src/soc/cpu_cva6/lsu_bypass.sv
src/soc/cpu_cva6/mult.sv
src/soc/cpu_cva6/multiplier.sv
src/soc/cpu_cva6/serdiv.sv
src/soc/cpu_cva6/perf_counters.sv
src/soc/cpu_cva6/ariane_regfile_ff.sv
src/soc/cpu_cva6/ariane_regfile_fpga.sv
src/soc/cpu_cva6/scoreboard.sv
src/soc/cpu_cva6/store_buffer.sv
src/soc/cpu_cva6/amo_buffer.sv
src/soc/cpu_cva6/store_unit.sv
src/soc/cpu_cva6/commit_stage.sv
src/soc/cpu_cva6/axi_shim.sv
src/soc/cpu_cva6/cva6_accel_first_pass_decoder_stub.sv
src/soc/cpu_cva6/acc_dispatcher.sv

// Frontend
src/soc/cpu_cva6/frontend/btb.sv
src/soc/cpu_cva6/frontend/bht.sv
src/soc/cpu_cva6/frontend/ras.sv
src/soc/cpu_cva6/frontend/instr_scan.sv
src/soc/cpu_cva6/frontend/instr_queue.sv
src/soc/cpu_cva6/frontend/frontend.sv

// Cache Subsystem
src/soc/cpu_cva6/cache_subsystem/wt_dcache_ctrl.sv
src/soc/cpu_cva6/cache_subsystem/wt_dcache_mem.sv
src/soc/cpu_cva6/cache_subsystem/wt_dcache_missunit.sv
src/soc/cpu_cva6/cache_subsystem/wt_dcache_wbuffer.sv
src/soc/cpu_cva6/cache_subsystem/wt_dcache.sv
src/soc/cpu_cva6/cache_subsystem/cva6_icache.sv
src/soc/cpu_cva6/cache_subsystem/wt_cache_subsystem.sv
src/soc/cpu_cva6/cache_subsystem/wt_axi_adapter.sv
src/soc/cpu_cva6/cache_subsystem/tag_cmp.sv
src/soc/cpu_cva6/cache_subsystem/axi_adapter.sv
src/soc/cpu_cva6/cache_subsystem/miss_handler.sv
src/soc/cpu_cva6/cache_subsystem/cache_ctrl.sv
src/soc/cpu_cva6/cache_subsystem/cva6_icache_axi_wrapper.sv
src/soc/cpu_cva6/cache_subsystem/std_cache_subsystem.sv
src/soc/cpu_cva6/cache_subsystem/std_nbdcache.sv

// Physical Memory Protection
src/soc/cpu_cva6/pmp/src/pmp.sv
src/soc/cpu_cva6/pmp/src/pmp_entry.sv

// MMU Sv39
src/soc/cpu_cva6/mmu_sv39/mmu.sv
src/soc/cpu_cva6/mmu_sv39/ptw.sv
src/soc/cpu_cva6/mmu_sv39/tlb.sv

// MMU Sv32
src/soc/cpu_cva6/mmu_sv32/cva6_mmu_sv32.sv
src/soc/cpu_cva6/mmu_sv32/cva6_ptw_sv32.sv
src/soc/cpu_cva6/mmu_sv32/cva6_tlb_sv32.sv
src/soc/cpu_cva6/mmu_sv32/cva6_shared_tlb_sv32.sv

///////////////////////////////////////////////////////////////////////////////
// TPU
///////////////////////////////////////////////////////////////////////////////

src/tpu/tpu.sv
src/tpu/ctrl_and_mem/axi_interface.sv
src/tpu/ctrl_and_mem/control_unit.sv
src/tpu/ctrl_and_mem/instruction_cache.sv
src/tpu/ctrl_and_mem/status_reg.sv
src/tpu/ctrl_and_mem/systolic_data_rearranger.sv
src/tpu/ctrl_and_mem/systolic_data_rearranger_FIFO.sv
src/tpu/ctrl_and_mem/unified_buffer.sv
src/tpu/systolic_array/int.sv
src/tpu/systolic_array/pe.sv
src/tpu/systolic_array/systolic_array_4x16x16.sv
src/tpu/systolic_array/systolic.sv
src/tpu/vpu/pipe_register.sv
src/tpu/vpu/vpe_adder.sv
src/tpu/vpu/vpe_bias.sv
src/tpu/vpu/vpe_dequanter.sv
src/tpu/vpu/vpe_psum_cache.sv
src/tpu/vpu/vpe_relu.sv
src/tpu/vpu/vpe.sv
src/tpu/vpu/vpu_channel.sv
src/tpu/vpu/vpu.sv
