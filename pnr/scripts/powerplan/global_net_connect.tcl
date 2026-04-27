#####################################################################################
# Description:  Innovus Connect Power & Ground Net Globally Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# connects PG pins or 1'b0/1'b1 pins to the specified global net, which is either a power or ground net
# pgpin:    specify that the power and ground pins listed with the -pin parameter are to be connected
# sinst:    connect pins in a single instance to a global net
globalNetConnect VDD -type pgpin -pin VDD -all -override
globalNetConnect VSS -type pgpin -pin VSS -all -override

foreach {sram_inst} $sram_domain {
    globalNetConnect VDD_SRAM -type pgpin -pin VDDCE -sinst $sram_inst -override
    globalNetConnect VDD_SRAM -type pgpin -pin VDDPE -sinst $sram_inst -override
    globalNetConnect VSS      -type pgpin -pin VSSE  -sinst $sram_inst -override
}

# connect VDD to tiehi pins & VSS to tielo pins
# tiehi: 1'b1
# tielo: 1'b0
globalNetConnect VDD -type tiehi
globalNetConnect VSS -type tielo

