###############################################################################
# TSMC 22nm ULL Standard Cell Library Setup
# Family: 7t30p140 (unified)
# Active Vt: SGHVT only (others commented out for future use)
# Local copies in syn/lib/
###############################################################################

set LIB_BASE ${PROJ_ROOT}/../tsmc22-frontend

# --------------------------------------------------------------------------
# MAX libraries (slow-slow, 0.72V, 125C — setup analysis)
# --------------------------------------------------------------------------
set DB_MAX_STDCELLS [list \
    ${LIB_BASE}/db/sghvt/tcbn22ullbwp7t30p140sghvtssg0p72v125c.db \
]
# set DB_MAX_STDCELLS [list \
#     ${LIB_BASE}/db/sg/tcbn22ullbwp7t30p140sgssg0p72v125c.db \
#     ${LIB_BASE}/db/sghvt/tcbn22ullbwp7t30p140sghvtssg0p72v125c.db \
#     ${LIB_BASE}/db/sglvt/tcbn22ullbwp7t30p140sglvtssg0p72v125c.db \
#     ${LIB_BASE}/db/lvt/tcbn22ullbwp7t30p140lvtssg0p72v125c.db \
#     ${LIB_BASE}/db/ulvt/tcbn22ullbwp7t30p140ulvtssg0p72v125c.db \
# ]

# --------------------------------------------------------------------------
# MIN libraries (fast-fast, 0.88V, -40C — hold analysis)
# --------------------------------------------------------------------------
set DB_MIN_STDCELLS [list \
    ${LIB_BASE}/db/sghvt/tcbn22ullbwp7t30p140sghvtffg0p88vm40c.db \
]
# set DB_MIN_STDCELLS [list \
#     ${LIB_BASE}/db/sg/tcbn22ullbwp7t30p140sgffg0p88vm40c.db \
#     ${LIB_BASE}/db/sghvt/tcbn22ullbwp7t30p140sghvtffg0p88vm40c.db \
#     ${LIB_BASE}/db/sglvt/tcbn22ullbwp7t30p140sglvtffg0p88vm40c.db \
#     ${LIB_BASE}/db/lvt/tcbn22ullbwp7t30p140lvtffg0p88vm40c.db \
#     ${LIB_BASE}/db/ulvt/tcbn22ullbwp7t30p140ulvtffg0p88vm40c.db \
# ]

# --------------------------------------------------------------------------
# Memory macro .db files
# --------------------------------------------------------------------------
set SRAM_1024x64_ROOT ${LIB_BASE}/sram/be_1024x64_rvt

set DB_MAX_MEM [list \
    ${SRAM_1024x64_ROOT}/be_1024x64_rvt_ssg_cworstt_0p81v_0p81v_125c.db \
]
set DB_MIN_MEM [list \
    ${SRAM_1024x64_ROOT}/be_1024x64_rvt_ffg_cbestt_0p99v_0p99v_m40c.db \
]
set DB_MEM [concat $DB_MAX_MEM $DB_MIN_MEM]
# TODO: add rf_128x46, rf_128x128 when macros are available

# --------------------------------------------------------------------------
# Target & Link Library (list/concat style)
# --------------------------------------------------------------------------
set target_library $DB_MAX_STDCELLS
set link_library   [concat "*" $DB_MAX_STDCELLS $DB_MIN_STDCELLS $DB_MAX_MEM $DB_MIN_MEM]

# --------------------------------------------------------------------------
# Min library mapping (MMMC: max <-> min)
# --------------------------------------------------------------------------
# Standard cells
foreach max_db $DB_MAX_STDCELLS min_db $DB_MIN_STDCELLS {
    set_min_library $max_db -min_version $min_db
}
# Memory macros
foreach max_db $DB_MAX_MEM min_db $DB_MIN_MEM {
    set_min_library $max_db -min_version $min_db
}

# --------------------------------------------------------------------------
# Search path
# --------------------------------------------------------------------------
set search_path [list . \
    ${LIB_BASE}/db/sghvt \
    ${SRAM_1024x64_ROOT} \
]

# --------------------------------------------------------------------------
puts "=================================================================="
puts "  TSMC 22nm ULL Library Setup (7t30p140 family)"
puts "  Active Vt : SGHVT"
puts "  MAX corner: SSG 0.72V 125C (setup)"
puts "  MIN corner: FFG 0.88V -40C (hold)"
puts "=================================================================="
puts "  target_library (MAX):"
foreach lib $DB_MAX_STDCELLS { puts "    $lib" }
puts "  min_library (MIN):"
foreach lib $DB_MIN_STDCELLS { puts "    $lib" }
puts "  memory MAX .db:"
foreach lib $DB_MAX_MEM { puts "    $lib" }
puts "  memory MIN .db:"
foreach lib $DB_MIN_MEM { puts "    $lib" }
puts "=================================================================="
