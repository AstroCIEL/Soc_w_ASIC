#####################################################################################
# Description:  Innovus Floorplan Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

set die_sizex 700
set die_sizey 700

# floorPlan [-d {W H Left Bottom Right Top}] [-s {W H Left Bottom Right Top}] [-su {aspectRatio stdCellDensity Left Bottom Right Top}]
# -d:               specify die size and spacing to core boundary, die box width == W, die box height == H, {Left Bottom Right Top} == spacing to core boundary
# -s:               specify core size and spacing to die boundary, core box width == W, core box height == H, {Left Bottom Right Top} == spacing to die boundary
# -su:              determine the core size by standard cell density, aspectRatio == height / width, {Left Bottom Right Top} == spacing to die boundary
# -coreMarginsBy:   specify whether the core margins are calculated using the core-to-IO boundary or the core-to-die boundary, possible value: {io | die}, default: io
# - -noSnapToGrid:  specify that the core box (or die box) boundary will not be snapped to the nearest metal pitch even if the if the specified die/ core box size is not an integer multiple of the smallest metal pitch, this prevents the input floorplan boxes from being changed
floorPlan -d $die_sizex $die_sizey 3.5 3.5 3.5 3.5
# floorPlan -su 1 0.7 100 100 100 100
