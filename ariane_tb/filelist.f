// ariane_tb filelist - all paths relative to ariane_tb/
// Uses ariane_testharness (with ara_system inside) as testbench

// Technology
-f ../hardware/tech/filelist_sim.f

// IPs (order matters: dependencies first)
-f ../hardware/ip/common_cells/filelist.f
-f ../hardware/ip/obi/filelist.f
-f ../hardware/ip/apb/filelist.f
-f ../hardware/ip/axi/filelist.f
-f ../hardware/ip/axi_slice/filelist.f
-f ../hardware/ip/register_interface/filelist.f
-f ../hardware/ip/axi_riscv_atomics/filelist.f
-f ../hardware/ip/axi2apb/filelist.f
-f ../hardware/ip/fpnew/filelist.f
-f ../hardware/ip/fpu_div_sqrt_mvp/filelist.f
-f ../hardware/ip/cva6/filelist.f
// ariane_axi_pkg needs axi_pkg + cva6_config_pkg; axi_lite_interface needs ariane_axi_pkg
ariane/ariane_axi_pkg.sv
../hardware/ip/axi/src/axi_lite_interface.sv
-f ../hardware/ip/ara/filelist.f
-f ../hardware/ip/riscv-dbg/filelist.f
-f ../hardware/ip/clint/filelist.f
-f ../hardware/ip/apb_timer/filelist.f
-f ../hardware/ip/apb_uart/filelist.f

// rv_plic (paths in its filelist are relative to project root,
// so we list files directly with ariane_tb-relative paths)
../hardware/ip/rv_plic/src/top_pkg.sv
../hardware/ip/rv_plic/src/tlul_pkg.sv
../hardware/ip/rv_plic/src/rv_plic_reg_pkg.sv
../hardware/ip/rv_plic/src/prim_subreg.sv
../hardware/ip/rv_plic/src/prim_subreg_ext.sv
../hardware/ip/rv_plic/src/plic_regmap.sv
../hardware/ip/rv_plic/src/rv_plic_gateway.sv
../hardware/ip/rv_plic/src/rv_plic_target.sv
../hardware/ip/rv_plic/src/rv_plic_reg_top.sv
../hardware/ip/rv_plic/src/rv_plic.sv
../hardware/ip/rv_plic/src/plic_top.sv

// SoC components (only ara_system + axi_inval_filter, NOT ara_soc)
../hardware/soc/src/cva6_accel_first_pass_decoder.sv
../hardware/soc/src/axi_inval_filter.sv
../hardware/soc/src/ara_system.sv
../hardware/soc/src/ctrl_registers.sv

// Ariane testharness components
ariane/ariane_soc_pkg.sv
ariane/ariane_axi_soc_pkg.sv
ariane/ariane_peripherals.sv
bootrom/bootrom.sv
common/uart.sv
common/SimJTAG.sv
ariane/ariane_testharness.sv



// Testbench top (from ariane_tb/tb/)
tb/uartdpi/uartdpi.sv
tb/mock_uart.sv
tb/ara_tb.sv
tb/ara_tb_verilator.sv
