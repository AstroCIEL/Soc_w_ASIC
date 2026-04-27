#####################################################################################
# Description:  Innovus Add Pin Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################
getPinAssignMode -pinEditInBatch -quiet
setPinAssignMode -pinEditInBatch true
editPin -fixOverlap 1 -spreadDirection clockwise -edge 2 -layer 3 -spreadType side -pin {clk_led rst_n tck tdi tdo tms}
editPin -use CLOCK -fixOverlap 1 -unit MICRON -spreadDirection clockwise -edge 2 -layer 5 -spreadType center -spacing 0.1 -pin clk
setPinAssignMode -pinEditInBatch false
