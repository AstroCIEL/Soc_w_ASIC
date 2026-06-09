// AXU RTL filelist wrapper for mixed MXU gate simulation.
// Keep hardware/user_ip/my_axu/filelist_axu_top_sim.f unchanged, but provide
// packages first because that file comments them out.

${ROOT}/hardware/user_ip/my_axu/pdpu/pdpu_cf_math_pkg.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/pdpu_pkg.sv
${ROOT}/hardware/user_ip/my_axu/pkgs/posit_types_pkg.sv

-f ${ROOT}/hardware/user_ip/my_axu/filelist_axu_top_sim.f
