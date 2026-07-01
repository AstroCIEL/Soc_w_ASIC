+define+SIM
+define+ARM_UD_MODEL

// Technology
-f ${ROOT}/hardware/tech/filelist_sim.f

// soc: minimum + DCIM wrap
-f ${ROOT}/hardware/soc/filelist_minimum_dcim.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist.f

// tb
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_tb.sv
