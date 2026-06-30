// IPs
-f ${ROOT}/hardware/ip/filelist.f

${ROOT}/hardware/soc/minimum_dcim/cva6_config_pkg.sv
${ROOT}/hardware/soc/minimum_dcim/ariane_soc_pkg.sv

-f ${ROOT}/hardware/soc/common/filelist.f

${ROOT}/hardware/soc/minimum_dcim/cva6_accel_first_pass_decoder.sv
${ROOT}/hardware/soc/minimum_dcim/ara_system.sv
${ROOT}/hardware/soc/minimum_dcim/ariane_peripherals.sv
${ROOT}/hardware/soc/minimum_dcim/ariane_soc_top.sv

// Add User IP
-f ${ROOT}/hardware/user_ip/dcim_wrap/filelist_sim.f
