// FPGA filelist for ariane_soc_top_wrapper on AXU15EG
// Usage: -f ${ROOT}/fpga/filelist.f

// IPs + SoC (same as simulation/synthesis)
-f ${ROOT}/hardware/soc/filelist_minimum.f

// Technology cells — FPGA specific
-f ${ROOT}/hardware/tech/filelist_fpga.f

// Default slave (synthesis stub)
-f ${ROOT}/hardware/user_ip/default_slave/filelist.f

// FPGA top-level wrapper
${ROOT}/fpga/ariane_soc_top_wrapper.sv
