// Local AXU replacement for mixed RTL/gate simulation
//
// Do not include hardware/user_ip/my_axu/filelist_axu_top_sim.f here: that
// would compile the RTL axu_top together with the gate-level replacement.

${ROOT}/sim_pre_syn/netlist_wrapper/axu_top_netlist_shim.sv
${ROOT}/sim_pre_syn/netlist/axu_top_netlist.v
${ROOT}/hardware/user_ip/my_axu/axu_top_wrapper.sv
