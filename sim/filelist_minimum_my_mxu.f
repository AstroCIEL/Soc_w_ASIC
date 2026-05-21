
// Technology
-f ${ROOT}/hardware/tech/filelist_sim.f

// soc (minimum_my_mxu configuration)
-f ${ROOT}/hardware/soc/filelist_minimum_my_mxu.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist.f
-f ${ROOT}/hardware/user_ip/my_mxu/filelist_mxu_top_sim.f

// tb
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_tb.sv
