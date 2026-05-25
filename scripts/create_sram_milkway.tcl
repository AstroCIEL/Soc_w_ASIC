###############################################################################
# create_sram_milkway.tcl
#
# Generate Milkyway reference library (FRAM+CEL) for SRAM macros.
# Output is usable by DC topographical mode.
#
# Usage:
#   cd $HOME/workspace/tsmc22/sram/milkway
#   Milkyway -galaxy -nullDisplay -tcl -file <path>/create_sram_milkway.tcl
###############################################################################

set PDK_ROOT  [file normalize [file join $::env(HOME) workspace tsmc22]]
set SRAM_DIR  ${PDK_ROOT}/sram
set TECH_FILE ${PDK_ROOT}/tech/VHV/PRTF_ICC2_22nm_9M_6X2RUTRDL_9T.11_1a.tf
set OUT_DIR   ${SRAM_DIR}/milkway
set LIB_NAME  sram_macro_milkway

set SRAM_MACROS [list \
    sram_l2_16384x64      \
    rf_dcache_half_64x128 \
    rf_icache_64x128      \
    rf_vrf_64x64          \
    rf_icache_tag_64x48   \
    rf_dcache_tag_64x46   \
    rf2p_256_128 \
    sramdp_272_16 \
]

###############################################################################

proc check_file {path} {
    if {![file exists $path]} {
        puts "ERROR: file not found: $path"
        exit 1
    }
}

###############################################################################

check_file $TECH_FILE
file mkdir $OUT_DIR

set cell_lefs {}
foreach macro $SRAM_MACROS {
    set lef_file ${SRAM_DIR}/${macro}.lef
    check_file $lef_file
    lappend cell_lefs $lef_file
}

set mw_lib ${OUT_DIR}/${LIB_NAME}
if {[file exists $mw_lib]} {
    file delete -force $mw_lib
}

puts "== SRAM Milkyway generation (for DC topo) ============================"
puts "   TECH     : $TECH_FILE"
puts "   Cell LEFs: [llength $cell_lefs] files"
puts "   MW lib   : $mw_lib"
puts "======================================================================"

create_mw_lib \
    -technology $TECH_FILE \
    $mw_lib

open_mw_lib $mw_lib

read_lef \
    -cell_lef_files $cell_lefs

close_mw_lib

foreach junk [glob -nocomplain -directory $OUT_DIR *.tcl *.sum *.script *.site_def *.clf Milkyway.log.* Milkyway.tcl.*] {
    file delete -force $junk
}

puts "======================================================================"
puts "== Done. Output: $mw_lib"
exit
