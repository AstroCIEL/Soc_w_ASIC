#####################################################################################
# Description:  Innovus Add Power/Ground Pin Label Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# create a power/ground pin as per the specified coordinates of the physical shape, the net name is assumed to be the same as the pin name
# -geom <layername> <llx> <lly> <urx> <ury>:    specify the geometry of the physical pin
# <layername>:                                  specify the layer one which the power/ground pin will be created
# <llx>:                                        specify the lower-left x coordinate, in microns, of the power/ground pin
# <lly>:                                        specify the lower-left y coordinate, in microns, of the power/ground pin
# <urx>:                                        specify the upper-right x coordinate, in microns, of the power/ground pin
# <ury>:                                        specify the upper-right y coordinate, in microns, of the power/ground pin
for { set i 0 } { $i <= 50 } {incr i} {
    set initX           [expr 13.5 + $i * 24]
    set initY           3.5
    set stripeHeight    693
    set stripeWidth     2
    createPGPin         VSS \
                        -geom M8 \
                        $initX $initY \
                        [expr $initX + $stripeWidth] [expr $initY + $stripeHeight]
}
f
for { set i 0 } { $i <= 50 } {incr i} {
    set initX           [expr 25.5 + $i * 24]
    set initY           3.5
    set stripeHeight    693
    set stripeWidth     2
    createPGPin         VDD \
                        -geom M8 \
                        $initX $initY \
                        [expr $initX + $stripeWidth] [expr $initY + $stripeHeight]
}


