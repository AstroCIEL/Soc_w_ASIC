// Master filelist - all paths relative to sim/

// Technology
-f ../hardware/tech/filelist_sim.f

// IPs (order matters: dependencies first)
-f ../hardware/ip/common_cells/filelist.f
-f ../hardware/ip/apb/filelist.f
-f ../hardware/ip/axi/filelist.f
-f ../hardware/ip/fpnew/filelist.f
-f ../hardware/ip/fpu_div_sqrt_mvp/filelist.f
-f ../hardware/ip/cva6/filelist.f
-f ../hardware/ip/ara/filelist.f

// SoC
-f ../hardware/soc/filelist.f

// Testbench
../tb/mock_uart.sv
../tb/ara_testharness.sv
../tb/ara_tb.sv
../tb/ara_tb_verilator.sv
