#####################################################################################
# Description:  Innovus Place Standard Cell Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# delete ite cells from the netlist and reconnect the tie input pins back to 1'b1 and 1'b0, use this command if there are existing tie cells in design
deleteTieHiLo

# place_detail_preroute_as_obs: specify layers on which preroute are taken as OBS, default: ""
setPlaceMode -place_detail_preroute_as_obs {6}

# perform pre-placement optimization and place standard cells
place_opt_design

# add instances of specified tie-off cells, use this command after placing the standard cells in the flow
addTieHiLo

# execute pre-cts flow with both placement and pre-cts optimization, provide better integration between placement and optimization to achieve faster runtime and better PPA
# increamental: incrementally improve the existing placement based on the critical timing paths and congestion, then re-optimize the netlist based on the new placement
place_opt_design      -incremental
timeDesign            -expandedViews \
                      -preCTS \
                      -outDir ../${rm_core_top}/reports/postPlace
report_power          -view func_tt_0p80v_25c \
                      -o ../${rm_core_top}/reports/postPlace
exec ../scripts/extract_report.csh ../${rm_core_top}/reports/postPlace

