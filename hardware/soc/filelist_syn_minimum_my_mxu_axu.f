// minimum_my_mxu_axu: synthesis-only user_ip (SoC RTL is in filelist_minimum_my_mxu_axu.f).
// Hard macros: rf2p_256_128, sramdp_272_16 — link tsmc22/sram/*.db via syn/setup/setup.tcl.

-f ${ROOT}/hardware/user_ip/my_mxu/filelist_mxu_top_syn.f
-f ${ROOT}/hardware/user_ip/my_axu/filelist_axu_top_syn.f
