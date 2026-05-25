
// Technology (synthesis)
-f ${ROOT}/hardware/tech/filelist_syn.f

// soc (SOC_CONFIG set by make: maximum, minimum, minimum_my_mxu, ...)
-f ${ROOT}/hardware/soc/filelist_${SOC_CONFIG}.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist.f
-f ${ROOT}/hardware/soc/filelist_syn_${SOC_CONFIG}.f

