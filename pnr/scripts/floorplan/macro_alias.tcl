#####################################################################################
# Description:  Innovus Macro Alias Definition Script
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Zhantong Zhu [Peking University]
#####################################################################################

# macro alias
set main_mem i_sram
set dcache_tag0 i_cpu/gen_cache_wt.i_cache_subsystem/i_wt_dcache/i_wt_dcache_mem/gen_tag_srams[0].i_tag_sram
set dcache_tag1 i_cpu/gen_cache_wt.i_cache_subsystem/i_wt_dcache/i_wt_dcache_mem/gen_tag_srams[1].i_tag_sram
set icache_tag0 i_cpu/gen_cache_wt.i_cache_subsystem/i_cva6_icache/gen_sram[0].i_tag_sram
set icache_tag1 i_cpu/gen_cache_wt.i_cache_subsystem/i_cva6_icache/gen_sram[1].i_tag_sram
set dcache_data0 i_cpu/gen_cache_wt.i_cache_subsystem/i_wt_dcache/i_wt_dcache_mem/gen_data_banks[0].i_data_sram
set dcache_data1 i_cpu/gen_cache_wt.i_cache_subsystem/i_wt_dcache/i_wt_dcache_mem/gen_data_banks[1].i_data_sram
set icache_data0 i_cpu/gen_cache_wt.i_cache_subsystem/i_cva6_icache/gen_sram[0].i_data_sram
set icache_data1 i_cpu/gen_cache_wt.i_cache_subsystem/i_cva6_icache/gen_sram[1].i_data_sram

set sram_domain [list \
    $main_mem \
    $dcache_tag0 $dcache_data0 \
    $dcache_tag1 $dcache_data1 \
    $icache_tag0 $icache_data0 \
    $icache_tag1 $icache_data1 \
]

