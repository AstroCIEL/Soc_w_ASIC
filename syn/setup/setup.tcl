###############################################################################
#   PDK_ROOT        — PDK installation root
#   SYN_ROOT        — absolute path of the syn/ directory
#   BUILD_DIR       — build output directory 
#   INCR_MODE       — 0 = full flow, 1 = incremental from a checkpoint
#   INCR_CHECKPOINT — checkpoint name to resume from (used when INCR_MODE=1)
###############################################################################

# ===========================================================================
# 1. Design identity
# ===========================================================================

set TOP_MODULE ariane_soc_top

# SRAM macro reference names — marked dont_touch after elaborate
# 增加mxu的sram宏名称rf2p_256_128
set SRAM_MACROS [list \
    sram_l2_16384x64         \
    rf_dcache_half_64x128    \
    rf_icache_64x128         \
    rf_vrf_64x64             \
    rf_icache_tag_64x48      \
    rf_dcache_tag_64x46      \
    rf2p_256_128 \
    sramdp_272_16 \
]

# ===========================================================================
# 2. Active MCMM scenarios
#    Add the scenario names you want to enable to ACTIVE_SCENARIOS.
#    Available scenario names (defined in scripts/mmmc.tcl):
#      Setup (max-delay, SSG corners):
#        func_ssg_0c      — SSG 0.72V   0°C
#        func_ssg_125c    — SSG 0.72V 125°C
#        func_ssg_m40c    — SSG 0.72V −40°C
#      Hold (min-delay, FFG corners):
#        func_ffg_0c      — FFG 0.88V   0°C
#        func_ffg_125c    — FFG 0.88V 125°C
#        func_ffg_m40c    — FFG 0.88V −40°C
#      Typical (TT corners):
#        func_tt_25c      — TT  0.80V  25°C
#        func_tt_85c      — TT  0.80V  85°C
#
#    Quick single-corner example (worst-case setup only):
#      set ACTIVE_SCENARIOS { func_ssg_125c }
#    Full sign-off (all corners):
#      set ACTIVE_SCENARIOS { func_ssg_0c func_ssg_125c func_ssg_m40c
#                             func_ffg_0c func_ffg_125c func_ffg_m40c
#                             func_tt_25c func_tt_85c }
# ===========================================================================

set ACTIVE_SCENARIOS {
    func_ssg_m40c
    func_ffg_125c
    func_tt_25c
}

# ===========================================================================
# 3. compile_ultra options
#    Add option strings to COMPILE_OPTIONS to enable them.
#    Available options:
#      -gate_clock                — insert clock-gating cells
#      -no_autoungroup            — preserve hierarchy (recommended for debug)
#      -no_boundary_optimization  — disable boundary cell removal
#      -timing                    — prioritize timing over area during mapping
#      -scan                      — enable scan insertion
#      -retime                    — enable retiming
#      -area_high_effort_script   — higher-effort area optimization
# ===========================================================================
# 0525：开启clockgating
set COMPILE_OPTIONS {
    -no_autoungroup
    -no_boundary_optimization
    -timing
    -gate_clock   
}

# Parallel threads for compile_ultra
set COMPILE_MAX_CORES 8

# ===========================================================================
# 4. Report options
# ===========================================================================

set MAX_PATHS 20   ;# timing paths per report_timing call

# ===========================================================================
# 5. Checkpoints
#    Set ENABLE_CHECKPOINTS 1 to write DDC snapshots after each phase.
#    INCR_CHECKPOINT (passed by Makefile) names the phase to resume from.
#
#    Checkpoint phases (in order):
#      post_elab        — after elaborate + link + dont_touch; before constraints
#      post_constraints — after MCMM setup + TLU+; before compile
#      post_compile     — after compile_ultra; before reports
#      final            — after final outputs + reports; resume at final outputs
#
#    To resume from a checkpoint:
#      make syn_incr INCR_CHECKPOINT=post_elab        → re-apply constraints + compile + report
#      make syn_incr INCR_CHECKPOINT=post_constraints → compile_ultra -incremental + report
#      make syn_incr INCR_CHECKPOINT=post_compile     → re-run reports only
#      make syn_incr INCR_CHECKPOINT=final            → re-run final outputs + reports only
# ===========================================================================

set ENABLE_CHECKPOINTS 1
