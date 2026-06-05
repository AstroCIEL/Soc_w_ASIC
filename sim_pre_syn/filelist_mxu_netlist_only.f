// Local MXU replacement for mixed RTL/gate simulation
//
// Do not include hardware/user_ip/my_mxu/filelist_mxu_top_sim.f here: that
// would compile the RTL mxu_top together with the gate-level replacement.

${ROOT}/sim_pre_syn/netlist_wrapper/mxu_top_netlist_shim.sv
${ROOT}/sim_pre_syn/netlist/mxu_top_netlist.v
${ROOT}/hardware/user_ip/my_mxu/mxu_top_wrapper.sv
