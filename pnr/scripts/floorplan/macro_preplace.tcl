#####################################################################################
# Description:  Innovus Place Hard Macro Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# placeInstance instance_name location [orientation] [{-fixed | -placed | -softFixed}]
# location:     lower-left coordinate (x,y)        
# orientation:  R0 (default), R90, R180, R270, MX, MX90, MY, or MY90
placeInstance $main_mem     520 15  R0
placeInstance $dcache_tag0  150 300 R0
placeInstance $dcache_tag1  35  300 MY
placeInstance $icache_tag0  260 300 MY
placeInstance $icache_tag1  380 300 R0
placeInstance $dcache_data0 150 15  R0
placeInstance $dcache_data1 35  15  MY
placeInstance $icache_data0 380 15  R0
placeInstance $icache_data1 260 15  MY


