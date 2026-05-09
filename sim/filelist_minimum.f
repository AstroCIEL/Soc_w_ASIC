
// Technology
-f ../hardware/tech/filelist_sim.f

// IPs (order matters: dependencies first)
-f ../hardware/ip/common_cells/filelist.f
-f ../hardware/ip/obi/filelist.f
-f ../hardware/ip/apb/filelist.f
-f ../hardware/ip/axi/filelist.f
-f ../hardware/ip/axi_stream/filelist.f
-f ../hardware/ip/axi_slice/filelist.f
-f ../hardware/ip/register_interface/filelist.f
-f ../hardware/ip/axi_riscv_atomics/filelist.f
-f ../hardware/ip/axi2apb/filelist.f
-f ../hardware/ip/fpnew/filelist.f
-f ../hardware/ip/fpu_div_sqrt_mvp/filelist.f
-f ../hardware/ip/cva6/filelist.f
-f ../hardware/ip/ara/filelist.f
-f ../hardware/ip/riscv-dbg/filelist.f
-f ../hardware/ip/apb_timer/filelist.f
-f ../hardware/ip/apb_uart/filelist.f
-f ../hardware/ip/rv_plic/filelist.f
-f ../hardware/ip/iDMA/filelist.f
-f ../hardware/ip/axi2mem_burst/filelist.f

// soc (minimum configuration)
-f ../hardware/soc/filelist_minimum.f

// user ip
-f ../hardware/user_ip/default_slave/filelist_sim.f

// tb
../tb/common/SimJTAG.sv
../tb/common/uartdpi.sv
../tb/ara_tb.sv
