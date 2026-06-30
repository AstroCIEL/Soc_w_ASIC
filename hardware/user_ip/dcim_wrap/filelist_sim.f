+incdir+${ROOT}/hardware/user_ip/dcim_wrap/dcim/inc/

// Top wrapper (adapt + buffers + 4x dcim)
${ROOT}/hardware/user_ip/dcim_wrap/dcim_wrap.sv

// Adapt layer
${ROOT}/hardware/user_ip/dcim_wrap/adapt/adapt_decode.sv
${ROOT}/hardware/user_ip/dcim_wrap/adapt/adapt_cfg.sv
${ROOT}/hardware/user_ip/dcim_wrap/adapt/adapt_ctrl.sv
${ROOT}/hardware/user_ip/dcim_wrap/adapt/act_mux.sv
${ROOT}/hardware/user_ip/dcim_wrap/adapt/out_receive.sv

// Common
${ROOT}/hardware/user_ip/dcim_wrap/common/counter.v
${ROOT}/hardware/user_ip/dcim_wrap/common/dff.v
${ROOT}/hardware/user_ip/dcim_wrap/common/mem_map.sv
${ROOT}/hardware/user_ip/dcim_wrap/common/mem_wrap.sv
${ROOT}/hardware/user_ip/dcim_wrap/common/model_mem.sv
${ROOT}/hardware/user_ip/dcim_wrap/common/pipe_ctrl.sv
${ROOT}/hardware/user_ip/dcim_wrap/common/pipe_slice.sv
${ROOT}/hardware/user_ip/dcim_wrap/common/rf_wrap_64x128.sv
${ROOT}/hardware/user_ip/dcim_wrap/common/rf_wrap_128x128.sv

// DCIM compute core
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/accumulateArray.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/adderTree.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/calculate_core.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/dcim_core.sv
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/dcim.sv
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/maArray.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/memory.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/mergeArray.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/multiplier.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/postProcess.v
${ROOT}/hardware/user_ip/dcim_wrap/dcim/rtl/ppCache.v

// RegisterFile Verilog model
${ROOT}/hardware/user_ip/dcim_wrap/macro/verilog/rf128x128.v
