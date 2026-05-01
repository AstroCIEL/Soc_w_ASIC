// cd iDMA
// make -j4 \
//   IDMA_BACKEND_IDS="rw_axi rw_axi_rw_axis rw_obi rw_axil rw_init rw_tilelink" \
//   IDMA_FE_IDS="reg32_1d reg32_2d reg32_3d reg64_1d reg64_2d reg64_3d" \
//   idma_hw_all

+incdir+../hardware/ip/iDMA/include

// -----------------------------------------------------------------------
// Packages — keep these FIRST so later modules can see their types
// -----------------------------------------------------------------------
../hardware/ip/iDMA/src/idma_pkg.sv

../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reg_pkg.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_synth_pkg.sv

../hardware/ip/iDMA/src/frontend/reg/idma_reg32_1d_reg_pkg.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg32_2d_reg_pkg.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg32_3d_reg_pkg.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_1d_reg_pkg.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_2d_reg_pkg.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_3d_reg_pkg.sv

../hardware/ip/iDMA/src/frontend/inst64/idma_inst64_snitch_pkg.sv

../hardware/ip/iDMA/src/midend/idma_mp_midend_synth_pkg.sv
../hardware/ip/iDMA/src/midend/idma_rt_midend_synth_pkg.sv

// -----------------------------------------------------------------------
// Backend modules
// -----------------------------------------------------------------------
../hardware/ip/iDMA/src/backend/idma_axi_write.sv
../hardware/ip/iDMA/src/backend/idma_dataflow_element.sv
../hardware/ip/iDMA/src/backend/idma_axis_read.sv
../hardware/ip/iDMA/src/backend/idma_obi_read.sv
../hardware/ip/iDMA/src/backend/idma_tilelink_read.sv
../hardware/ip/iDMA/src/backend/idma_axi_read.sv
../hardware/ip/iDMA/src/backend/idma_tilelink_write.sv
../hardware/ip/iDMA/src/backend/idma_axis_write.sv
../hardware/ip/iDMA/src/backend/idma_legalizer_pow2_splitter.sv
../hardware/ip/iDMA/src/backend/idma_obi_write.sv
../hardware/ip/iDMA/src/backend/idma_init_write.sv
../hardware/ip/iDMA/src/backend/idma_axil_read.sv
../hardware/ip/iDMA/src/backend/idma_legalizer_page_splitter.sv
../hardware/ip/iDMA/src/backend/idma_channel_coupler.sv
../hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_obi.sv
../hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_init.sv
../hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_axi_rw_axis.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_rw_axi.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_axil.sv
../hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_init.sv
../hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_tilelink.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_init.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_rw_axi_rw_axis.sv
../hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_axil.sv
../hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_axi_rw_axis.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_axi_rw_axis.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_rw_axil.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_axi.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_rw_obi.sv
../hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_axi.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_tilelink.sv
../hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_obi.sv
../hardware/ip/iDMA/src/backend/interface/idma_transport_layer_rw_tilelink.sv
../hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_axil.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_synth_rw_obi.sv
../hardware/ip/iDMA/src/backend/interface/idma_legalizer_rw_axi.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_rw_tilelink.sv
../hardware/ip/iDMA/src/backend/interface/idma_backend_rw_init.sv
../hardware/ip/iDMA/src/backend/idma_axil_write.sv
../hardware/ip/iDMA/src/backend/idma_init_read.sv
../hardware/ip/iDMA/src/backend/idma_error_handler.sv

// -----------------------------------------------------------------------
// Frontend modules
// -----------------------------------------------------------------------
../hardware/ip/iDMA/src/frontend/idma_transfer_id_gen.sv

../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_ar_gen_prefetch.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reader.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_top.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reshaper.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reg_wrapper.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reg_top.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_reader_gater.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_synth.sv
../hardware/ip/iDMA/src/frontend/desc64/idma_desc64_ar_gen.sv

../hardware/ip/iDMA/src/frontend/reg/idma_reg32_2d_reg_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_2d_reg_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg32_2d_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg32_1d_reg_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg32_3d_reg_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_1d_reg_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_3d_reg_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_1d_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg32_3d_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_2d_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg64_3d_top.sv
../hardware/ip/iDMA/src/frontend/reg/idma_reg32_1d_top.sv

../hardware/ip/iDMA/src/frontend/inst64/idma_inst64_events.sv
../hardware/ip/iDMA/src/frontend/inst64/idma_inst64_top.sv

// -----------------------------------------------------------------------
// Midend modules
// -----------------------------------------------------------------------
../hardware/ip/iDMA/src/midend/idma_mp_split_midend.sv
../hardware/ip/iDMA/src/midend/idma_nd_midend_synth.sv
../hardware/ip/iDMA/src/midend/idma_mp_midend_synth.sv
../hardware/ip/iDMA/src/midend/idma_rt_midend_synth.sv
../hardware/ip/iDMA/src/midend/idma_nd_midend.sv
../hardware/ip/iDMA/src/midend/idma_rt_midend.sv
../hardware/ip/iDMA/src/midend/idma_mp_dist_midend.sv
