#####################################################################################
# Description:  Innovus Add Halo & Place/Route Blockage Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# a halo is an area that prevents the placement of blocks and standard cells within the specified halo distance from the edges of a hard macro, black box, or committed partition in order to reduce congestion
# one example of halo usage is to prevent M1 power rails from routing to Macro edges too close, only rails that can attach to a power ring will be allowed to enter halo ranges, however, due to M1 power rails are only 0.1um width, if the horizontal power ring of one block is much wider than M1 power rail, it is likely that M1 power rail will be connected to the corner of a block ring, volunable to DRC
# use "deleteHaloFromBlock" command to delete halos
# radix = {left bottom right top}
addHaloToBlock [list $macro_halo_spc_4 $macro_halo_spc_4 $macro_halo_spc_4 $macro_halo_spc_4] -allMacro

# create cell placement blockages that can be placed
# name:     specify the name of the placement blockage
# box:      specify the coordinate of the blockage area
# type:     possible value: hard | soft | partial | macroOnly, default: hard
#           hard:       neither standard cell instances nor macros may be placed in the blockage
#           soft:       neither standard cell instances nor macros may be placed in the blockage during `place_opt_design`, but these may be placed during in-place optimization, CTS or ECO placement
#           partial:    in conjunction with `-density` parameter, create a placement blockage that has a maximum density as specified
#           macroOnly:  keep macros out of the placement blockage
# density:  specify the maximum density allowed for partial or soft blockages
# createPlaceBlockage -name setdensity_blk1 -box 300 50 500 500 -type Partial -density 75

# the object area prevents routing of specified metal layers, signal routes, and hierarchical instances in this area
# use "deleteRouteBlk" command to delete blocks
# cover:        specify that a routing blockage of the same size as the specified block instance (-inst name) will be created on top of the instance
# exceptpgnet:  the routing blockage is to be applied on a signal net routing and not on power or ground net routing
# spacing:      specify the minimum spacing allowed between the blockage and any other routing shape
# cutLayer:     specify the cut layer, list of cut layers, or all cut layers on which the routing blockage is to be applied
# partial:      specify the density for partial routing blockages, range [0,100]
foreach {sram_inst} $sram_domain {
    createRouteBlk -cover -inst $sram_inst -exceptpgnet -layer {M1 M2 M3 M4} -spacing $macro_halo_spc
}
