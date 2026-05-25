+incdir+${ROOT}/hardware/user_ip/my_axu/pkgs
+incdir+${ROOT}/hardware/user_ip/my_axu/pdpu

// ${ROOT}/hardware/user_ip/my_axu/pdpu/pdpu_cf_math_pkg.sv
// ${ROOT}/hardware/user_ip/my_axu/pdpu/pdpu_pkg.sv
// ${ROOT}/hardware/user_ip/my_axu/pkgs/posit_types_pkg.sv

${ROOT}/hardware/user_ip/my_axu/pdpu/barrel_shifter.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/booth_encoder.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/comparator.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/compressor_3to2.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/compressor_4to2.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/counter_5to3.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/fulladder.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/gen_product.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/gen_prods.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/csa_tree.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/comp_tree.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/lzc.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/mantissa_norm.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/radix4_booth_multiplier.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/posit_decoder.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/posit_encoder.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/pdpu_top.sv
${ROOT}/hardware/user_ip/my_axu/pdpu/pdpu_top_pipelined.sv

${ROOT}/hardware/user_ip/my_axu/mem_bm/sp_sram.sv

// NOTE: rf2p_256_128 SRAM modules are commented out here.
// They will be included by the SoC-level sim filelist (e.g., sim/filelist_minimum_my_axu.f)
// which references hardware/user_ip/sram_buffer/rf2p_256_128*.sv (shared with MXU).
// Do NOT uncomment these lines unless running standalone axu_top simulation.
// ${ROOT}/hardware/user_ip/my_axu/sram/rf2p_256_128.v
// ${ROOT}/hardware/user_ip/my_axu/sram/rf2p_256_128_wrapper.sv
// ${ROOT}/hardware/user_ip/my_axu/sram/sramdp_272_16.v
// ${ROOT}/hardware/user_ip/my_axu/sram/sramdp_272_16_wrapper.sv


${ROOT}/hardware/user_ip/my_axu/mxu/zzc_adder.sv
${ROOT}/hardware/user_ip/my_axu/mxu/zzc_radix4_booth_multiplier.sv
${ROOT}/hardware/user_ip/my_axu/mxu/zzc_booth_encoder.sv
${ROOT}/hardware/user_ip/my_axu/mxu/zzc_gen_product.sv
${ROOT}/hardware/user_ip/my_axu/mxu/zzc_gen_prods.sv

${ROOT}/hardware/user_ip/my_axu/vpu/posit_add_sub_kernel.sv
${ROOT}/hardware/user_ip/my_axu/vpu/posit_add_sub.sv
${ROOT}/hardware/user_ip/my_axu/vpu/posit_mult_kernel_pipe2.sv
${ROOT}/hardware/user_ip/my_axu/vpu/posit_mult_vec_pipe2.sv
${ROOT}/hardware/user_ip/my_axu/vpu/posit_acc_add_kernel_pipe2.sv
${ROOT}/hardware/user_ip/my_axu/vpu/posit_sum_kernel.sv
${ROOT}/hardware/user_ip/my_axu/vpu/posit_max.sv
${ROOT}/hardware/user_ip/my_axu/vpu/posit_floor.sv
${ROOT}/hardware/user_ip/my_axu/vpu/CompareGreaterEqual.sv
${ROOT}/hardware/user_ip/my_axu/vpu/vpu_top_no_ctrl.sv

${ROOT}/hardware/user_ip/my_axu/vpu/posit_add_kernel.sv


${ROOT}/hardware/user_ip/my_axu/sfu/cordic_mac_kernel.sv
${ROOT}/hardware/user_ip/my_axu/sfu/cordic_sin_cos.sv
${ROOT}/hardware/user_ip/my_axu/sfu/xoroshiro128_plus.sv
${ROOT}/hardware/user_ip/my_axu/sfu/int_to_posit.sv
${ROOT}/hardware/user_ip/my_axu/sfu/sfu_top_no_ctrl.sv

${ROOT}/hardware/user_ip/my_axu/nli/model/model_mul_LUT.sv
${ROOT}/hardware/user_ip/my_axu/nli/model/model_y_bounds_LUT.sv

${ROOT}/hardware/user_ip/my_axu/nli/NLI/dff.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/priority_encoder.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/pipe_ctrl_kernel.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/pipe_ctrl.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/arithmetic/nli_add.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/arithmetic/nli_subtract.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/arithmetic/nli_multiply.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/arithmetic/nli_floor.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/arithmetic/nli_compareGreaterEqual.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/stage1.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/stage2.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/stage3.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/stage4.sv
${ROOT}/hardware/user_ip/my_axu/nli/NLI/nli.sv
${ROOT}/hardware/user_ip/my_axu/nli/nli_top.sv

${ROOT}/hardware/user_ip/my_axu/axu_top/axu_ctrl.sv
${ROOT}/hardware/user_ip/my_axu/axu_top/axu_top.sv

${ROOT}/hardware/user_ip/my_axu/scheduler/scheduler.sv
${ROOT}/hardware/user_ip/my_axu/scheduler/scheduler_buf_wrapper.sv


${ROOT}/hardware/user_ip/my_axu/axu_top_wrapper.sv
