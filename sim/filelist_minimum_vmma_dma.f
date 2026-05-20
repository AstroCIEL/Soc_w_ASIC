
// Technology
-f ${ROOT}/hardware/tech/filelist_sim.f

// soc: fourth variant — minimum + VMMA (internal DMA)
-f ${ROOT}/hardware/soc/filelist_minimum_vmma_dma.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist_sim.f
-f ${ROOT}/hardware/user_ip/vmma/filelist_sim.f

// tb
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_tb.sv
