#####################################################################################
# Description:  Innovus Routing Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# set the native RC extraction mode
# engine:               possible value: preRoute | postRoute, default: preRoute
# effortLevel:          possible value: low | medium | high | signoff, default: low
setExtractRCMode    -engine                 postRoute \
                    -effortLevel            medium

# run routing or postroute via or wire optimization using the NanoRoute router
# if specified without any arguments, it runs global and detail routing
routeDesign

# optimize setup, hold and drv
# uncomment the following commands for further optimization
optDesign    -postRoute -setup -hold
# optDesign   -postRoute -drv
# optDesign   -postRoute -incr
# optDesign   -postRoute -hold
timeDesign   -outDir ../${rm_core_top}/reports/postRoute \
             -expandedViews \
             -postRoute
report_power -o ../${rm_core_top}/reports/postRoute \
             -view func_tt_0p80v_25c
exec ../scripts/extract_report.csh ../${rm_core_top}/reports/postRoute

