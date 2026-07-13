
// Technology
-f ${ROOT}/hardware/tech/filelist_sim.f

// soc (minimum_dco configuration)
-f ${ROOT}/hardware/soc/filelist_minimum_dco.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist.f

// tb
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_minimum_dco_tb.sv
