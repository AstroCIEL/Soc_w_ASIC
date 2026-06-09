simSetSimulator "-vcssv" -exec \
           "/data/home/zch_zhou28/workspace/work2026_2/work_for_tapeout_2026_v2/Soc_w_ASIC/sim_pre_syn/build/vcs-mxu-axu-netlist/simv" \
           -args \
           "+vcs+lic+wait +PRELOAD=../software/build/bin/mxu_idma_gbuf_test +notimingchecks"
debImport "-dbdir" \
          "/data/home/zch_zhou28/workspace/work2026_2/work_for_tapeout_2026_v2/Soc_w_ASIC/sim_pre_syn/build/vcs-mxu-axu-netlist/simv.daidir"
debLoadSimResult \
           /data/home/zch_zhou28/workspace/work2026_2/work_for_tapeout_2026_v2/Soc_w_ASIC/sim_pre_syn/waveform.fsdb
wvCreateWindow
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
srcHBSelect "ariane_soc_tb.dut" -win $_nTrace1
srcSetScope "ariane_soc_tb.dut" -delim "." -win $_nTrace1
verdiSetActWin -dock widgetDock_<Inst._Tree>
srcHBSelect "ariane_soc_tb.dut" -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals" -win $_nTrace1
srcSetScope "ariane_soc_tb.dut.i_ariane_peripherals" -delim "." -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals" -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper" -win \
           $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper" -win \
           $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper" -win \
           $_nTrace1
srcSetScope "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper" -delim "." \
           -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper" -win \
           $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top" \
           -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top" \
           -win $_nTrace1
srcSetScope "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top" \
           -delim "." -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top" \
           -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate" \
           -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_axu_ctrl" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_axu_ctrl" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_axu_ctrl" \
           -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_nli_top_no_ctrl" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_nli_top_no_ctrl" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_nli_top_no_ctrl" \
           -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_out_buf" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_out_buf" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_axu_top_wrapper.u_axu_top.u_axu_top_gate.u_out_buf" \
           -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper" -win \
           $_nTrace1
srcSetScope "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper" -delim "." \
           -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper" -win \
           $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top" \
           -win $_nTrace1
srcSetScope "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top" \
           -delim "." -win $_nTrace1
srcHBSelect "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top" \
           -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate" \
           -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl" \
           -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl.sa_lane_gen_1__u_sa_top" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl.sa_lane_gen_1__u_sa_top" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl.sa_lane_gen_1__u_sa_top" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl.sa_lane_gen_1__u_sa_top" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl.sa_lane_gen_1__u_sa_top.decoder_gen_0__u_acc_encoder" \
           -win $_nTrace1
srcSetScope \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl.sa_lane_gen_1__u_sa_top.decoder_gen_0__u_acc_encoder" \
           -delim "." -win $_nTrace1
srcHBSelect \
           "ariane_soc_tb.dut.i_ariane_peripherals.i_mxu_top_wrapper.i_mxu_top.u_mxu_top_gate.u_mxu_top_no_ctrl.sa_lane_gen_1__u_sa_top.decoder_gen_0__u_acc_encoder" \
           -win $_nTrace1
srcDeselectAll -win $_nTrace1
verdiSetActWin -dock widgetDock_MTB_SOURCE_TAB_1
debExit
