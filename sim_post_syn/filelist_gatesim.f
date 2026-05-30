// Gate-level (post-synthesis) simulation filelist
// Usage: vcs -f filelist_gatesim.f
//
// Required environment variables:
//   ROOT       — project root directory
//   PDK_ROOT   — PDK installation root (for std-cell Verilog models)
//   SYN_BUILD  — synthesis build directory (default: ${ROOT}/syn/build)

+define+ARM_DISABLE_EMA_CHECK
+define+FUNCTIONAL
+define+UNIT_DELAY
+define+GATE_SIM

// Standard cell Verilog simulation models (PDK) — all Vt variants
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140sghvt/v/tcbn22ullbwp7t30p140sghvt.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140sg/v/tcbn22ullbwp7t30p140sg.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140sglvt/v/tcbn22ullbwp7t30p140sglvt.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140lvt/v/tcbn22ullbwp7t30p140lvt.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140ulvt/v/tcbn22ullbwp7t30p140ulvt.v

// SRAM macros + tech wrappers
-f ${ROOT}/hardware/tech/filelist_simsyn.f

-f ${ROOT}/hardware/user_ip/sram_buffer/filelist_syn.f



// Synthesized gate-level netlist
${SYN_BUILD}/outputs/ariane_soc_top_netlist.v

// Testbench
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_tb.sv
