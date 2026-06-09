###############################################################################
# syn/scripts/check-env.tcl
# Environment and configuration sanity checks.
# Sourced at the very start of synth.tcl, after setup.tcl has been loaded.
###############################################################################

puts "== \[check-env\] Checking environment =================================="

# ---------------------------------------------------------------------------
# PDK_ROOT must exist
# ---------------------------------------------------------------------------
if {![info exists PDK_ROOT] || $PDK_ROOT eq ""} {
    error "PDK_ROOT is not set. Pass it via: make flat PDK_ROOT=/path/to/pdk"
}
if {![file isdirectory $PDK_ROOT]} {
    error "PDK_ROOT does not exist or is not a directory: $PDK_ROOT"
}

# ---------------------------------------------------------------------------
# SYN_ROOT must exist
# ---------------------------------------------------------------------------
if {![info exists SYN_ROOT] || $SYN_ROOT eq ""} {
    error "SYN_ROOT is not set."
}
if {![file isdirectory $SYN_ROOT]} {
    error "SYN_ROOT does not exist: $SYN_ROOT"
}

# ---------------------------------------------------------------------------
# BUILD_DIR must be set
# ---------------------------------------------------------------------------
if {![info exists BUILD_DIR] || $BUILD_DIR eq ""} {
    error "BUILD_DIR is not set."
}

# ---------------------------------------------------------------------------
# Target and top module validation
# ---------------------------------------------------------------------------
if {![info exists SYN_TARGET] || $SYN_TARGET eq ""} {
    error "SYN_TARGET is not set."
}
if {[lsearch -exact {mxu axu top custom} $SYN_TARGET] < 0} {
    error "SYN_TARGET must be one of mxu, axu, top, custom; got: $SYN_TARGET"
}

if {![info exists TOP_MODULE] || $TOP_MODULE eq ""} {
    error "TOP_MODULE is not set."
}

if {![info exists SRAM_MACROS]} {
    error "SRAM_MACROS is not set."
}

# ---------------------------------------------------------------------------
# SYN_MODE is retained for compatibility, but only flat is supported.
# ---------------------------------------------------------------------------
if {![info exists SYN_MODE]} {
    error "SYN_MODE is not set."
}
if {$SYN_MODE ne "flat"} {
    error "Only SYN_MODE=flat is supported; got: $SYN_MODE"
}

# ---------------------------------------------------------------------------
# INCR_CHECKPOINT validation
# ---------------------------------------------------------------------------
if {![info exists INCR_CHECKPOINT] || $INCR_CHECKPOINT eq ""} {
    error "INCR_CHECKPOINT is not set."
}

set VALID_CHECKPOINTS {NONE post_constraints post_compile}
if {[lsearch -exact $VALID_CHECKPOINTS $INCR_CHECKPOINT] < 0} {
    error "Unknown INCR_CHECKPOINT '$INCR_CHECKPOINT'. Valid values: $VALID_CHECKPOINTS"
}

# ---------------------------------------------------------------------------
# Namespace controls
# ---------------------------------------------------------------------------
if {![info exists NETLIST_UNIQUIFY_ENABLE] || $NETLIST_UNIQUIFY_ENABLE eq ""} {
    error "NETLIST_UNIQUIFY_ENABLE is not set."
}
if {[lsearch -exact {auto 0 1} $NETLIST_UNIQUIFY_ENABLE] < 0} {
    error "NETLIST_UNIQUIFY_ENABLE must be auto, 0, or 1; got: $NETLIST_UNIQUIFY_ENABLE"
}

if {![info exists NETLIST_CHANGE_NAMES_ENABLE] || $NETLIST_CHANGE_NAMES_ENABLE eq ""} {
    error "NETLIST_CHANGE_NAMES_ENABLE is not set."
}
if {[lsearch -exact {0 1} $NETLIST_CHANGE_NAMES_ENABLE] < 0} {
    error "NETLIST_CHANGE_NAMES_ENABLE must resolve to 0 or 1; got: $NETLIST_CHANGE_NAMES_ENABLE"
}

if {$NETLIST_UNIQUIFY_ENABLE eq "1" && (![info exists NETLIST_NAMESPACE_PREFIX] || $NETLIST_NAMESPACE_PREFIX eq "")} {
    error "NETLIST_NAMESPACE_PREFIX must be non-empty when NETLIST_UNIQUIFY_ENABLE=1."
}

if {$NETLIST_UNIQUIFY_ENABLE eq "auto" && [info exists NETLIST_NAMESPACE_PREFIX] && $NETLIST_NAMESPACE_PREFIX ne ""} {
    puts "   Namespace uniquify auto-enabled by prefix: $NETLIST_NAMESPACE_PREFIX"
}

if {![info exists ENABLE_CHECKPOINTS]} {
    error "ENABLE_CHECKPOINTS is not set."
}
if {[lsearch -exact {0 1} $ENABLE_CHECKPOINTS] < 0} {
    error "ENABLE_CHECKPOINTS must be 0 or 1, got: $ENABLE_CHECKPOINTS"
}

if {![info exists COMPILE_MAX_CORES]} {
    error "COMPILE_MAX_CORES is not set."
}
if {![string is integer -strict $COMPILE_MAX_CORES] || $COMPILE_MAX_CORES < 1} {
    error "COMPILE_MAX_CORES must be a positive integer, got: $COMPILE_MAX_CORES"
}

if {![info exists MAX_PATHS]} {
    error "MAX_PATHS is not set."
}
if {![string is integer -strict $MAX_PATHS] || $MAX_PATHS < 1} {
    error "MAX_PATHS must be a positive integer, got: $MAX_PATHS"
}

if {![info exists COMPILE_OPTIONS]} {
    error "COMPILE_OPTIONS is not set."
}

# ---------------------------------------------------------------------------
# ACTIVE_SCENARIOS must be a non-empty subset of the master scenario list
# (master list is the union of all scenario groups defined in mmmc.tcl)
# ---------------------------------------------------------------------------
set ALL_KNOWN_SCENARIOS {
    func_ssg_0c
    func_ssg_125c
    func_ssg_m40c
    func_ffg_0c
    func_ffg_125c
    func_ffg_m40c
    func_tt_25c
    func_tt_85c
}

if {![info exists ACTIVE_SCENARIOS] || [llength $ACTIVE_SCENARIOS] == 0} {
    error "ACTIVE_SCENARIOS is empty. Add at least one scenario name to setup/setup.tcl."
}
foreach s $ACTIVE_SCENARIOS {
    if {[lsearch -exact $ALL_KNOWN_SCENARIOS $s] < 0} {
        error "Unknown scenario '$s' in ACTIVE_SCENARIOS. Known: $ALL_KNOWN_SCENARIOS"
    }
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
puts "   PDK_ROOT          : $PDK_ROOT"
puts "   SYN_ROOT          : $SYN_ROOT"
puts "   BUILD_DIR         : $BUILD_DIR"
puts "   SYN_MODE          : $SYN_MODE"
if {$INCR_CHECKPOINT ne "NONE"} {
puts "   INCR_CHECKPOINT   : $INCR_CHECKPOINT"
}
puts "   SYN_TARGET        : $SYN_TARGET"
puts "   TOP_MODULE        : $TOP_MODULE"
puts "   NAMESPACE_PREFIX  : $NETLIST_NAMESPACE_PREFIX"
puts "   UNIQUIFY_ENABLE   : $NETLIST_UNIQUIFY_ENABLE"
puts "   CHANGE_NAMES      : $NETLIST_CHANGE_NAMES_ENABLE"
puts "   ACTIVE_SCENARIOS  : $ACTIVE_SCENARIOS"
puts "   ENABLE_CHECKPOINTS: $ENABLE_CHECKPOINTS"
puts "   COMPILE_OPTIONS   : $COMPILE_OPTIONS"
puts "   COMPILE_MAX_CORES : $COMPILE_MAX_CORES"
puts "   MAX_PATHS         : $MAX_PATHS"
puts "== \[check-env\] OK ====================================================="
