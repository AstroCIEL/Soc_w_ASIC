// Post-PnR functional sim: stdcells (power-pin), IO pads, compiled memories.
// PDK_ROOT matches hardware/user_ip/dcim_wrap/filelist/top/filelist_sim2.f

// Standard cells — use *_pwr.v because io_top_flat.v / DCO_flat.v / dcim_flat.v
// connect .VDD/.VSS on every leaf.
/data/data_dell/PDK_Tech/TSMC_22NM_RF_ULL/IP/Std_Cell/tcbn22ullbwp7t30p140_110b/digital/Front_End/verilog/tcbn22ullbwp7t30p140_110a/tcbn22ullbwp7t30p140_pwr.v
/data/data_dell/PDK_Tech/TSMC_22NM_RF_ULL/IP/Std_Cell/tcbn22ullbwp7t30p140lvt_110b/digital/Front_End/verilog/tcbn22ullbwp7t30p140lvt_110a/tcbn22ullbwp7t30p140lvt_pwr.v
/data/data_dell/PDK_Tech/TSMC_22NM_RF_ULL/IP/Std_Cell/tcbn22ullbwp7t30p140hvt_110b/digital/Front_End/verilog/tcbn22ullbwp7t30p140hvt_110a/tcbn22ullbwp7t30p140hvt_pwr.v

// IO pads (PDDWUW0408SDGH_*, PVDD*/PVSS*/PVDD2POC_*). Power-pin model required.
/data/data_dell/PDK_Tech/TSMC_22NM_RF_ULL/IP/IO/tphn22ullgv2od3_c171206/digital/Front_End/verilog/tphn22ullgv2od3_c171206.v

// SoC compiled memories (need +define+POWER_PINS +define+ARM_UD_MODEL)
${ROOT}/hardware/tech/syn/sram_l2_4096x64.v
${ROOT}/hardware/tech/syn/rf_dcache_half_64x128.v
${ROOT}/hardware/tech/syn/rf_dcache_tag_64x46.v
${ROOT}/hardware/tech/syn/rf_icache_64x128.v
${ROOT}/hardware/tech/syn/rf_icache_tag_64x48.v

// DCIM / wrap compiled register files (lowercase ports, as in the netlist)
${ROOT}/hardware/user_ip/dcim_wrap/macro/ip/rf64x128/verilog/rf64x128.v
${ROOT}/hardware/user_ip/dcim_wrap/macro/ip/rf128x128/verilog/rf128x128.v
