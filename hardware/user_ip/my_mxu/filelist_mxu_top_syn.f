+incdir+${ROOT}/hardware/user_ip/my_mxu/pkgs
+incdir+${ROOT}/hardware/user_ip/my_mxu/pdpu

${ROOT}/hardware/user_ip/my_mxu/pdpu/pdpu_cf_math_pkg.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/pdpu_pkg.sv
${ROOT}/hardware/user_ip/my_mxu/pkgs/posit_types_pkg.sv

${ROOT}/hardware/user_ip/my_mxu/pdpu/barrel_shifter.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/booth_encoder.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/comparator.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/compressor_3to2.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/compressor_4to2.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/counter_5to3.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/fulladder.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/gen_product.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/gen_prods.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/csa_tree.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/comp_tree.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/lzc.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/mantissa_norm.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/radix4_booth_multiplier.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/posit_decoder.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/posit_encoder.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/pdpu_top.sv
${ROOT}/hardware/user_ip/my_mxu/pdpu/pdpu_top_pipelined.sv

${ROOT}/hardware/user_ip/my_mxu/mxu/zzc_booth_encoder.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/zzc_gen_product.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/zzc_gen_prods.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/zzc_radix4_booth_multiplier.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/zzc_adder.sv

${ROOT}/hardware/user_ip/my_mxu/mxu/PE_kernel.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/PE_line.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/PE_mult_kernel.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/PE_mult_line.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/PE_mac_kernel.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/PE_mac_line.sv

${ROOT}/hardware/user_ip/my_mxu/mxu/Systolic_Array.sv
${ROOT}/hardware/user_ip/my_mxu/mxu/SA_top.sv

${ROOT}/hardware/user_ip/my_mxu/stu/semi_transposer.sv
${ROOT}/hardware/user_ip/my_mxu/stu/rotator.sv
//已经加了db等工艺文件，filelist中不需要加compiler生成的.v
// ${ROOT}/hardware/user_ip/sram_buffer/rf2p_256_128.v
// ${ROOT}/hardware/user_ip/sram_buffer/rf2p_256_128_wrapper.sv

${ROOT}/hardware/user_ip/my_mxu/mxu_top/mxu_top_no_ctrl.sv
${ROOT}/hardware/user_ip/my_mxu/mxu_top/mxu_ctrl.sv
${ROOT}/hardware/user_ip/my_mxu/mxu_top/mxu_top.sv

${ROOT}/hardware/user_ip/my_mxu/mxu_top_wrapper.sv


