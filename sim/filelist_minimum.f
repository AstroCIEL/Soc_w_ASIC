
// Technology
-f ${ROOT}/hardware/tech/filelist_sim.f

// soc (minimum configuration)
-f ${ROOT}/hardware/soc/filelist_minimum.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist.f

// tb
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_tb.sv
