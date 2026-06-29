+incdir+${ROOT}/hardware/user_ip/dcim/src/inc/

// Include AXI2MEM Interface
${ROOT}/hardware/user_ip/dcim/dcim_wrap.sv

// DCIM RTL
${ROOT}/hardware/user_ip/dcim/src/rtl/accumulateArray.v
${ROOT}/hardware/user_ip/dcim/src/rtl/adderTree.v
${ROOT}/hardware/user_ip/dcim/src/rtl/calculate_core.v
${ROOT}/hardware/user_ip/dcim/src/rtl/dcim_core.sv
${ROOT}/hardware/user_ip/dcim/src/rtl/dcim.sv
${ROOT}/hardware/user_ip/dcim/src/rtl/maArray.v
${ROOT}/hardware/user_ip/dcim/src/rtl/memory.v
${ROOT}/hardware/user_ip/dcim/src/rtl/mergeArray.v
${ROOT}/hardware/user_ip/dcim/src/rtl/multiplier.v
${ROOT}/hardware/user_ip/dcim/src/rtl/postProcess.v
${ROOT}/hardware/user_ip/dcim/src/rtl/ppCache.v

// Common RTL
${ROOT}/hardware/user_ip/dcim/src/common/counter.v
${ROOT}/hardware/user_ip/dcim/src/common/dff.v
${ROOT}/hardware/user_ip/dcim/src/common/mem_map.sv
${ROOT}/hardware/user_ip/dcim/src/common/mem_wrap.sv
${ROOT}/hardware/user_ip/dcim/src/common/model_mem.sv
${ROOT}/hardware/user_ip/dcim/src/common/pipe_ctrl.sv
${ROOT}/hardware/user_ip/dcim/src/common/pipe_slice.sv
${ROOT}/hardware/user_ip/dcim/src/common/rf_wrap_128x128.sv

// RegisterFile Verilog Model
${ROOT}/hardware/user_ip/dcim/src/macro/verilog/rf128x128.v
