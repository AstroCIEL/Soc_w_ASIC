// SRAM buffer support for mixed MXU gate / SoC RTL simulation.
//
// rf2p_256_128 and rf2p_256_128_wrapper are intentionally excluded here
// because hardware/tech/filelist_sim.f already provides them, and the SoC
// testbench expects the RTL-sim SRAM hierarchy for L2 preload.

// ${ROOT}/hardware/user_ip/sram_buffer/rf2p_256_128.v
// ${ROOT}/hardware/user_ip/sram_buffer/rf2p_256_128_wrapper.sv
// ${ROOT}/hardware/user_ip/sram_buffer/sram_4096_64.v
${ROOT}/hardware/user_ip/sram_buffer/sramsp_4096_64.v
${ROOT}/hardware/user_ip/sram_buffer/global_buffer.sv
${ROOT}/hardware/user_ip/sram_buffer/sramdp_272_16.v
${ROOT}/hardware/user_ip/sram_buffer/sramdp_272_16_wrapper.sv
