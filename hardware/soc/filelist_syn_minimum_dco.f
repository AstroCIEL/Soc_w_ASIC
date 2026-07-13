// IPs
-f ${ROOT}/hardware/ip/filelist.f

${ROOT}/hardware/soc/minimum_dco/cva6_config_pkg.sv
${ROOT}/hardware/soc/minimum_dco/ariane_soc_pkg.sv

-f ${ROOT}/hardware/soc/common/filelist.f

${ROOT}/hardware/soc/minimum_dco/cva6_accel_first_pass_decoder.sv
${ROOT}/hardware/soc/minimum_dco/ara_system.sv
${ROOT}/hardware/soc/minimum_dco/ariane_peripherals.sv
${ROOT}/hardware/soc/minimum_dco/ariane_soc_top.sv

// DCO macro + wrapper (synthesis netlist)
${ROOT}/hardware/tech/syn/DCO.v
${ROOT}/hardware/tech/wrapper/dco_wrapper.v
