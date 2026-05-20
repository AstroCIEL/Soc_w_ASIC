// cd iDMA
// make -j4 \
//   IDMA_BACKEND_IDS="rw_axi rw_axi_rw_axis rw_obi rw_axil rw_init rw_tilelink" \
//   IDMA_FE_IDS="reg32_1d reg32_2d reg32_3d reg64_1d reg64_2d reg64_3d" \
//   idma_hw_all

+incdir+${ROOT}/hardware/ip/iDMA/include

// -----------------------------------------------------------------------
// Packages — keep these FIRST so later modules can see their types
// -----------------------------------------------------------------------
${ROOT}/hardware/ip/iDMA/src/idma_pkg.sv

${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reg_pkg.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_synth_pkg.sv

${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_1d_reg_pkg.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_2d_reg_pkg.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_3d_reg_pkg.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_1d_reg_pkg.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_2d_reg_pkg.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_3d_reg_pkg.sv

${ROOT}/hardware/ip/iDMA/src/frontend/inst64/idma_inst64_snitch_pkg.sv

${ROOT}/hardware/ip/iDMA/src/midend/idma_mp_midend_synth_pkg.sv
${ROOT}/hardware/ip/iDMA/src/midend/idma_rt_midend_synth_pkg.sv

// -----------------------------------------------------------------------
// Backend modules
// -----------------------------------------------------------------------
${ROOT}/hardware/ip/iDMA/src/backend/idma_axi_write.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_dataflow_element.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_axis_read.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_obi_read.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_tilelink_read.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_axi_read.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_tilelink_write.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_axis_write.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_legalizer_pow2_splitter.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_obi_write.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_init_write.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_axil_read.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_legalizer_page_splitter.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_channel_coupler.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_obi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_init.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_axi_rw_axis.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_rw_axi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_axil.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_init.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_tilelink.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_init.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_rw_axi_rw_axis.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_axil.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_axi_rw_axis.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_axi_rw_axis.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_rw_axil.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_axi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_rw_obi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_axi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_tilelink.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_obi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_tilelink.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_axil.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_obi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_axi.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_rw_tilelink.sv
${ROOT}/hardware/ip/iDMA/src/backend/interface/idma_backend_rw_init.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_axil_write.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_init_read.sv
${ROOT}/hardware/ip/iDMA/src/backend/idma_error_handler.sv

// -----------------------------------------------------------------------
// Frontend modules
// -----------------------------------------------------------------------
${ROOT}/hardware/ip/iDMA/src/frontend/idma_transfer_id_gen.sv

${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_ar_gen_prefetch.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reader.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reshaper.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reg_wrapper.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reg_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reader_gater.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_synth.sv
${ROOT}/hardware/ip/iDMA/src/frontend/desc64/idma_desc64_ar_gen.sv

${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_2d_reg_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_2d_reg_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_2d_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_1d_reg_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_3d_reg_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_1d_reg_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_3d_reg_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_1d_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_3d_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_2d_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg64_3d_top.sv
${ROOT}/hardware/ip/iDMA/src/frontend/reg/idma_reg32_1d_top.sv

${ROOT}/hardware/ip/iDMA/src/frontend/inst64/idma_inst64_events.sv
${ROOT}/hardware/ip/iDMA/src/frontend/inst64/idma_inst64_top.sv

// -----------------------------------------------------------------------
// Midend modules
// -----------------------------------------------------------------------
${ROOT}/hardware/ip/iDMA/src/midend/idma_mp_split_midend.sv
${ROOT}/hardware/ip/iDMA/src/midend/idma_nd_midend_synth.sv
${ROOT}/hardware/ip/iDMA/src/midend/idma_mp_midend_synth.sv
${ROOT}/hardware/ip/iDMA/src/midend/idma_rt_midend_synth.sv
${ROOT}/hardware/ip/iDMA/src/midend/idma_nd_midend.sv
${ROOT}/hardware/ip/iDMA/src/midend/idma_rt_midend.sv
${ROOT}/hardware/ip/iDMA/src/midend/idma_mp_dist_midend.sv
