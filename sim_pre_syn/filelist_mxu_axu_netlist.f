// Mixed RTL/gate simulation filelist for local MXU/AXU netlist validation
//
// Partitioning:
//   - SoC and testbench: RTL
//   - mxu_top and axu_top: synthesized gate-level netlists from sim_pre_syn/netlist
//
// Required environment variables:
//   ROOT     — Soc_w_ASIC project root directory
//   PDK_ROOT — PDK installation root for std-cell Verilog models

+define+ARM_DISABLE_EMA_CHECK
+define+FUNCTIONAL
+define+UNIT_DELAY

// Standard cell Verilog simulation models (PDK), following post-synthesis gate sim
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140sghvt/v/tcbn22ullbwp7t30p140sghvt.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140sg/v/tcbn22ullbwp7t30p140sg.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140sglvt/v/tcbn22ullbwp7t30p140sglvt.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140lvt/v/tcbn22ullbwp7t30p140lvt.v
-v ${PDK_ROOT}/stdcell/tcbn22ullbwp7t30p140ulvt/v/tcbn22ullbwp7t30p140ulvt.v

// Technology models for the surrounding RTL SoC/testbench.
// Keep RTL sim hierarchy here because tb/ariane_soc_tb.sv uses XMRs into the
// RTL tc_sram hierarchy for preload.
-f ${ROOT}/hardware/tech/filelist_sim.f

// SoC RTL
-f ${ROOT}/hardware/soc/filelist_minimum_my_mxu_axu.f

// User IPs: replace MXU and AXU internals with local netlists.
-f ${ROOT}/sim_pre_syn/filelist_axu_netlist_only.f
-f ${ROOT}/sim_pre_syn/filelist_mxu_netlist_only.f


// SRAM buffer models used outside the MXU netlist. rf2p is provided by
// hardware/tech/filelist_sim.f, so use a local no-rf2p list to avoid overrides.
-f ${ROOT}/sim_pre_syn/filelist_sram_buffer_no_rf2p.f

// Testbench
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/ariane_soc_tb.sv
