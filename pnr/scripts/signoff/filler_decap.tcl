#####################################################################################
# Description:  Innovus Add Filler and Decap Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# EXPERIMENTAL FUNCTION!
# specify ILM (Interface Logic Model) data directory for the specified block
# DONT COMMENT or CHANGE the following commands unless you are familiar with ILM !!!
if {$ilm_block ne {}} {
    unflattenIlm
}

# insert filler cell instances in the gap between standard cell instances
addFiller -cell ${rm_fill_cells} -prefix DECAP

# preprocess the design for the NanoRoute router and launch ECO routing within the router
# fix_drc: allow NanoRoute to fix only the DRC's on existing DRC markers in the design
ecoRoute  -fix_drc

# optimize timing
# uncomment these commands for further optimization
# may cause some filler/decap removed
# optDesign -outDir ../${rm_core_top}/reports/postSignoff -postRoute -setup -hold
# optDesign -outDir ../${rm_core_top}/reports/postSignoff -postRoute -drv
# optDesign -outDir ../${rm_core_top}/reports/postSignoff -postRoute -incr
# optDesign -outDir ../${rm_core_top}/reports/postSignoff -postRoute -hold

# check DRC
verify_drc

