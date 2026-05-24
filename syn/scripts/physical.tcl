# ===========================================================================
# 1. Physical library naming
# ===========================================================================

set _phys_STACK  VHV
set _phys_PREFIX tcbn22ullbwp7t30p140

set _phys_VTS {
    sghvt
    sg
    sglvt
    lvt
    ulvt
}

# ===========================================================================
# 2. Path definitions
# ===========================================================================

set _phys_MW_TECH_FILE  ${PDK_ROOT}/tech/${_phys_STACK}/PRTF_ICC2_22nm_9M_6X2RUTRDL_9T.11_1a.tf
set _phys_MW_DESIGN_LIB ${OUTPUT_DIR}/${TOP_MODULE}.mw

set _phys_MW_REFERENCE_LIBS {}
foreach _vt $_phys_VTS {
    set _lib ${_phys_PREFIX}${_vt}
    lappend _phys_MW_REFERENCE_LIBS \
        ${PDK_ROOT}/stdcell/${_lib}/milkyway/${_lib}_110a/cell_frame_${_phys_STACK}_0d5_0/${_lib}
}
unset _vt _lib

lappend _phys_MW_REFERENCE_LIBS \
    ${PDK_ROOT}/sram/milkway/sram_macro_milkway

set _phys_TLUPLUS_MAX ${PDK_ROOT}/starrc/cln22ulp_1p09m+ut-alrdl_6x1z1u_rcworst.tluplus
set _phys_TLUPLUS_MIN ${PDK_ROOT}/starrc/cln22ulp_1p09m+ut-alrdl_6x1z1u_rcbest.tluplus
set _phys_TLUPLUS_TYP ${PDK_ROOT}/starrc/cln22ulp_1p09m+ut-alrdl_6x1z1u_typical.tluplus
set _phys_TLUPLUS_MAP ${PDK_ROOT}/starrc/star_rcxt.mapping

puts "== \[physical\] Topographical setup ===================================="
puts "   stack             : $_phys_STACK"
puts "   MW_TECH_FILE      : $_phys_MW_TECH_FILE"
puts "   MW_DESIGN_LIB     : $_phys_MW_DESIGN_LIB"
foreach _r $_phys_MW_REFERENCE_LIBS { puts "   mw_ref_lib        : $_r" }
puts "   TLUPLUS_MAX       : $_phys_TLUPLUS_MAX"
puts "   TLUPLUS_MIN       : $_phys_TLUPLUS_MIN"
puts "   TLUPLUS_TYP       : $_phys_TLUPLUS_TYP"
puts "=================================================================="
unset _r

# ===========================================================================
# 3. Physical collateral checks
# ===========================================================================

proc physical_check_files {paths} {
    foreach path $paths {
        if {![file exists $path]} {
            error "Physical collateral not found: $path"
        }
    }
}

proc physical_check_dirs {paths} {
    foreach path $paths {
        if {![file isdirectory $path]} {
            error "Physical reference library not found: $path"
        }
    }
}

# ===========================================================================
# 4. Milkyway design library setup
# ===========================================================================

proc physical_open_mw_lib {} {
    global _phys_MW_TECH_FILE _phys_MW_DESIGN_LIB _phys_MW_REFERENCE_LIBS

    physical_check_files [list $_phys_MW_TECH_FILE]
    physical_check_dirs  $_phys_MW_REFERENCE_LIBS

    if {![file isdirectory $_phys_MW_DESIGN_LIB]} {
        create_mw_lib \
            -technology           $_phys_MW_TECH_FILE \
            -mw_reference_library $_phys_MW_REFERENCE_LIBS \
            $_phys_MW_DESIGN_LIB
    }
    open_mw_lib $_phys_MW_DESIGN_LIB
    puts "== \[physical\] Milkyway lib open: $_phys_MW_DESIGN_LIB"
}

# ===========================================================================
# 5. TLU+ binding (call after MCMM scenarios are created)
# ===========================================================================

# Bind TLU+ for a single scenario.
# TT scenarios use the typical parasitics file for both max and min.
proc _physical_set_tluplus_scenario {scenario} {
    global _phys_TLUPLUS_MAX _phys_TLUPLUS_MIN _phys_TLUPLUS_TYP _phys_TLUPLUS_MAP

    mmmc_current_scenario $scenario

    if {[string match "func_tt_*" $scenario]} {
        set max_file $_phys_TLUPLUS_TYP
        set min_file $_phys_TLUPLUS_TYP
    } else {
        set max_file $_phys_TLUPLUS_MAX
        set min_file $_phys_TLUPLUS_MIN
    }

    physical_check_files [list $max_file $min_file $_phys_TLUPLUS_MAP]

    puts "   TLU+ $scenario : max=[file tail $max_file]"
    set_tlu_plus_files \
        -max_tluplus  $max_file \
        -min_tluplus  $min_file \
        -tech2itf_map $_phys_TLUPLUS_MAP
}

# Bind TLU+ for a list of scenarios, then run the sanity check.
proc physical_set_tluplus {scenarios} {
    puts "== \[physical\] Binding TLU+ files =================================="
    foreach s $scenarios {
        _physical_set_tluplus_scenario $s
    }
    check_tlu_plus_files
    puts "=================================================================="
}
