
// Technology
-f ${ROOT}/hardware/tech/filelist_sim.f

// soc: third variant — minimum + ASIC (internal DMA), RTL under hardware/soc/minimum_asic_dma/
-f ${ROOT}/hardware/soc/filelist_minimum_asic_dma.f

// user ip
-f ${ROOT}/hardware/user_ip/default_slave/filelist_sim.f
-f ${ROOT}/hardware/user_ip/asic_dma_accel/filelist_sim.f

// tb
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_tb.sv
