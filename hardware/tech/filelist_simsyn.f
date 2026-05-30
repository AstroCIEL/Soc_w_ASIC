${ROOT}/hardware/tech/syn/rf_dcache_half_64x128.v
${ROOT}/hardware/tech/syn/rf_dcache_tag_64x46.v
${ROOT}/hardware/tech/syn/rf_icache_64x128.v
${ROOT}/hardware/tech/syn/rf_icache_tag_64x48.v
${ROOT}/hardware/tech/syn/rf_vrf_64x64.v
${ROOT}/hardware/tech/syn/sram_l2_16384x64.v
${ROOT}/hardware/tech/syn/sram_l2_4096x64.v

// Technology cells - ASIC synthesis
${ROOT}/hardware/tech/syn/tc_sram.sv
${ROOT}/hardware/tech/syn/tc_clk.sv
${ROOT}/hardware/tech/syn/tc_pwr.sv

// Wrappers
${ROOT}/hardware/tech/wrapper/tc_sram_wrapper.sv
${ROOT}/hardware/tech/wrapper/paired_sram_wrapper.sv
${ROOT}/hardware/tech/wrapper/sram_cache.sv
${ROOT}/hardware/tech/wrapper/hpdcache_tc_sram.sv
${ROOT}/hardware/tech/wrapper/vrf_mem_wrapper.sv



// Technology cells - simulation
${ROOT}/hardware/tech/sim/rf2p_256_128.v
//${ROOT}/hardware/tech/sim/sram_4096_64.v

// Wrappers

${ROOT}/hardware/tech/wrapper/rf2p_256_128_wrapper.sv
