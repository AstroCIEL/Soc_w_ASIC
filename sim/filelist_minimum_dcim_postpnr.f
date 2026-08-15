+define+SIM
+define+ARM_UD_MODEL
+define+POWER_PINS
+define+FUNCTIONAL
+define+GATE_SIM
+notimingchecks
-delay_mode unit

// Stdcell / IO / memory models
-f ${ROOT}/hardware/tech/filelist_sim_postpnr.f

// Post-PnR flattened netlists (DCO and dcim stay as instances inside io_top)
${ROOT}/netlist_postPNR/DCO_flat.v
${ROOT}/netlist_postPNR/dcim_flat.v
${ROOT}/netlist_postPNR/io_top_flat.v

// tb
${ROOT}/tb/common/SimJTAG.sv
${ROOT}/tb/common/uartdpi.sv
${ROOT}/tb/io_top_postpnr_tb.sv
