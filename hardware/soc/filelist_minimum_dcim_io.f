// IPs
-f ${ROOT}/hardware/ip/filelist.f

${ROOT}/hardware/soc/minimum_dcim_io/cva6_config_pkg.sv
${ROOT}/hardware/soc/minimum_dcim_io/ariane_soc_pkg.sv

-f ${ROOT}/hardware/soc/common/filelist.f

${ROOT}/hardware/soc/minimum_dcim_io/cva6_accel_first_pass_decoder.sv
${ROOT}/hardware/soc/minimum_dcim_io/ara_system.sv
${ROOT}/hardware/soc/minimum_dcim_io/ariane_peripherals.sv
${ROOT}/hardware/soc/minimum_dcim_io/ariane_soc_top.sv
${ROOT}/hardware/soc/minimum_dcim_io/io_top.sv

// Add User IP
${ROOT}/hardware/tech/wrapper/dco_wrapper.v
