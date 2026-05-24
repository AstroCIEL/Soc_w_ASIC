# ===========================================================================
# 1. Library naming
# ===========================================================================

set _mmmc_PREFIX tcbn22ullbwp7t30p140

set _mmmc_STD_VTS {
    sghvt
    sg
    sglvt
    lvt
    ulvt
}

# ===========================================================================
# 2. Corner definitions
# ===========================================================================

# SRAM corner mapping: stdcell_corner → sram_corner suffix
array set _mmmc_SRAM_CORNER {
    tt0p8v25c       tt_typical_0p80v_0p80v_25c
    tt0p8v85c       tt_typical_0p80v_0p80v_85c
    ssg0p72v0c      ssg_cworstt_0p72v_0p72v_0c
    ssg0p72v125c    ssg_cworstt_0p72v_0p72v_125c
    ssg0p72vm40c    ssg_cworstt_0p72v_0p72v_m40c
    ffg0p88v0c      ffg_cbestt_0p88v_0p88v_0c
    ffg0p88v125c    ffg_cbestt_0p88v_0p88v_125c
    ffg0p88vm40c    ffg_cbestt_0p88v_0p88v_m40c
}

# ===========================================================================
# 3. Master scenario table
#    Maps scenario name → {corner  delay_type}
#    delay_type: max = setup, min = hold, typ = typical
# ===========================================================================

set _mmmc_SCENARIO_DEF(func_ssg_0c)   [list ssg0p72v0c   max]
set _mmmc_SCENARIO_DEF(func_ssg_125c) [list ssg0p72v125c max]
set _mmmc_SCENARIO_DEF(func_ssg_m40c) [list ssg0p72vm40c max]
set _mmmc_SCENARIO_DEF(func_ffg_0c)   [list ffg0p88v0c   min]
set _mmmc_SCENARIO_DEF(func_ffg_125c) [list ffg0p88v125c min]
set _mmmc_SCENARIO_DEF(func_ffg_m40c) [list ffg0p88vm40c min]
set _mmmc_SCENARIO_DEF(func_tt_25c)   [list tt0p8v25c    typ]
set _mmmc_SCENARIO_DEF(func_tt_85c)   [list tt0p8v85c    typ]

proc mmmc_known_scenarios {} {
    global _mmmc_SCENARIO_DEF
    return [lsort [array names _mmmc_SCENARIO_DEF]]
}

proc mmmc_check_scenario_names {names} {
    global _mmmc_SCENARIO_DEF
    if {[llength $names] == 0} {
        error "ACTIVE_SCENARIOS is empty. Add at least one scenario name to setup/setup.tcl."
    }
    foreach name $names {
        if {![info exists _mmmc_SCENARIO_DEF($name)]} {
            error "Unknown scenario '$name' in ACTIVE_SCENARIOS. Known: [mmmc_known_scenarios]"
        }
    }
}

# ===========================================================================
# 4. Library path helpers
# ===========================================================================

proc mmmc_std_libs_db {corner} {
    global PDK_ROOT _mmmc_PREFIX _mmmc_STD_VTS
    set libs {}
    foreach vt $_mmmc_STD_VTS {
        lappend libs ${PDK_ROOT}/stdcell/${_mmmc_PREFIX}${vt}/lib/${_mmmc_PREFIX}${vt}${corner}.db
    }
    return $libs
}

proc mmmc_sram_libs_db {corner sram_macros} {
    global PDK_ROOT _mmmc_SRAM_CORNER
    set mem_corner $_mmmc_SRAM_CORNER($corner)
    set libs {}
    foreach macro $sram_macros {
        lappend libs ${PDK_ROOT}/sram/${macro}_${mem_corner}.db
    }
    return $libs
}

proc mmmc_all_libs_db {corner sram_macros} {
    return [concat [mmmc_std_libs_db $corner] [mmmc_sram_libs_db $corner $sram_macros]]
}

# Union of standard-cell libs across all active scenarios (no duplicates)
proc mmmc_all_active_std_libs {} {
    global ACTIVE_SCENARIOS _mmmc_SCENARIO_DEF
    set libs {}
    set seen {}
    foreach name $ACTIVE_SCENARIOS {
        set corner [lindex $_mmmc_SCENARIO_DEF($name) 0]
        if {[lsearch -exact $seen $corner] >= 0} { continue }
        lappend seen $corner
        set libs [concat $libs [mmmc_std_libs_db $corner]]
    }
    return $libs
}

# Union of all libs (std + SRAM) across all active scenarios (no duplicates)
proc mmmc_all_active_libs {sram_macros} {
    global ACTIVE_SCENARIOS _mmmc_SCENARIO_DEF
    set libs {}
    set seen {}
    foreach name $ACTIVE_SCENARIOS {
        set corner [lindex $_mmmc_SCENARIO_DEF($name) 0]
        if {[lsearch -exact $seen $corner] >= 0} { continue }
        lappend seen $corner
        set libs [concat $libs [mmmc_all_libs_db $corner $sram_macros]]
    }
    return $libs
}

proc mmmc_check_lib_files {libs} {
    foreach lib_path $libs {
        if {![file exists $lib_path]} {
            error "Timing library file not found: $lib_path"
        }
    }
}

# ===========================================================================
# 5. Operating condition helper
# ===========================================================================

proc mmmc_set_operating_conditions {corner sram_macros} {
    foreach lib_path [mmmc_all_libs_db $corner $sram_macros] {
        mmmc_check_lib_files [list $lib_path]
        set lib_name [file rootname [file tail $lib_path]]
        if {[sizeof_collection [get_libs -quiet ${lib_name}]] == 0} {
            read_db $lib_path
        }
        set lib_obj [get_libs -quiet ${lib_name}]
        if {[sizeof_collection $lib_obj] == 0} {
            error "Library '$lib_name' not loaded after read_db $lib_path"
        }
        set oc [get_attribute $lib_obj default_operating_conditions]
        if {$oc eq ""} {
            error "Library '$lib_name' has no default_operating_conditions"
        }
        set_operating_conditions $oc -library ${lib_name}
    }
}

# ===========================================================================
# 6. Global library setup (call before elaborate / read_ddc)
# ===========================================================================

proc mmmc_setup_global_libs {sram_macros} {
    global PDK_ROOT target_library link_library search_path

    set target_library [mmmc_all_active_std_libs]
    set link_library   [concat "*" [mmmc_all_active_libs $sram_macros]]
    mmmc_check_lib_files [lrange $link_library 1 end]

    set search_path [list . \
        ${PDK_ROOT}/stdcell \
        ${PDK_ROOT}/sram    \
    ]

    puts "== \[mmmc\] Global libs: [llength $target_library] target, [llength $link_library] link"
}

# ===========================================================================
# 7. MCMM scenario creation
# ===========================================================================

proc mmmc_scenario_collection {name {required 1}} {
    if {[catch {set scenario [get_scenarios $name]}]} {
        set scenario ""
    }
    if {$scenario eq ""} {
        if {$required} { error "Required scenario does not exist: $name" }
        return ""
    }
    return $scenario
}

proc mmmc_current_scenario {name} {
    current_scenario [mmmc_scenario_collection $name]
}

proc mmmc_set_active_scenarios {names} {
    mmmc_check_scenario_names $names
    foreach name $names {
        mmmc_scenario_collection $name
    }
    set_active_scenarios $names
}

# Create or refresh a single named scenario.
proc _mmmc_setup_scenario {name constraints_file sram_macros} {
    global _mmmc_SCENARIO_DEF target_library link_library

    set corner [lindex $_mmmc_SCENARIO_DEF($name) 0]

    if {[mmmc_scenario_collection $name 0] eq ""} {
        create_scenario $name
    } else {
        puts "    reusing existing scenario: $name"
    }
    mmmc_current_scenario $name

    mmmc_set_operating_conditions $corner $sram_macros

    source $constraints_file
}

# Public entry point — create all scenarios listed in ACTIVE_SCENARIOS.
proc mmmc_create_scenarios {constraints_file sram_macros} {
    global ACTIVE_SCENARIOS _mmmc_SCENARIO_DEF

    mmmc_check_scenario_names $ACTIVE_SCENARIOS
    puts "== \[mmmc\] Creating scenarios ======================================="
    foreach name $ACTIVE_SCENARIOS {
        set corner [lindex $_mmmc_SCENARIO_DEF($name) 0]
        set dtype  [lindex $_mmmc_SCENARIO_DEF($name) 1]
        puts "    $name  corner=$corner  type=$dtype"
        _mmmc_setup_scenario $name $constraints_file $sram_macros
    }
    mmmc_set_active_scenarios $ACTIVE_SCENARIOS
    puts "== \[mmmc\] Active: $ACTIVE_SCENARIOS"
    puts "=================================================================="
}
