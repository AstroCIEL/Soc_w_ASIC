// FPGA filelist for ariane_soc_top_wrapper on AXU15EG
// Usage: -f ${ROOT}/fpga/filelist.f

// Technology cells — FPGA specific
-f ${ROOT}/hardware/tech/filelist_fpga.f

// IPs + SoC (same as simulation/synthesis)
-f ${ROOT}/hardware/soc/filelist_minimum_my_mxu.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist.f
-f ${ROOT}/hardware/user_ip/my_mxu/filelist_mxu_top_sim.f

// FPGA top-level wrapper
${ROOT}/fpga/ariane_soc_top_wrapper.sv
