###############################################################################
# Read RTL Design Sources
# Recursively parses filelist.f (supports -f, +incdir+, +define+, //)
###############################################################################

# --------------------------------------------------------------------------
# Helper: recursively parse a filelist.f
#   Handles: -f <sub-filelist>, +incdir+, +define+, // comments, blank lines
#   All file/incdir paths are resolved relative to $base_dir (syn/).
#   Only -f targets are resolved relative to the parent filelist's directory,
#   so nested filelists can be found correctly.
# --------------------------------------------------------------------------
proc parse_filelist {flist_path base_dir} {
    set incdirs {}
    set defines {}
    set files   {}

    set flist_dir [file dirname [file normalize $flist_path]]

    set fp [open $flist_path r]
    while {[gets $fp line] >= 0} {
        set line [string trim $line]
        if {$line eq "" || [string match "//*" $line]} { continue }

        if {[string match "-f *" $line]} {
            # -f paths are relative to the current filelist's directory
            set sub [string trim [string range $line 3 end]]
            set sub_path [file normalize "${flist_dir}/${sub}"]
            set sub_result [parse_filelist $sub_path $base_dir]
            set incdirs [concat $incdirs [lindex $sub_result 0]]
            set defines [concat $defines [lindex $sub_result 1]]
            set files   [concat $files   [lindex $sub_result 2]]
        } elseif {[string match "+incdir+*" $line]} {
            set dir [string range $line 8 end]
            lappend incdirs [file normalize "${base_dir}/${dir}"]
        } elseif {[string match "+define+*" $line]} {
            lappend defines $line
        } else {
            lappend files [file normalize "${base_dir}/${line}"]
        }
    }
    close $fp
    return [list $incdirs $defines $files]
}

# --------------------------------------------------------------------------
# Parse the synthesis filelist
# All source/incdir paths resolve relative to SCRIPT_DIR (syn/)
# --------------------------------------------------------------------------
set result [parse_filelist "${SCRIPT_DIR}/filelist.f" ${SCRIPT_DIR}]

set all_incdirs [lindex $result 0]
set all_defines [lindex $result 1]
set all_files   [lindex $result 2]

# --------------------------------------------------------------------------
# Build analyze options string
# --------------------------------------------------------------------------
set analyze_opts "+define+SYNTHESIS"
foreach d $all_defines {
    append analyze_opts " ${d}"
}
foreach d $all_incdirs {
    append analyze_opts " +incdir+${d}"
}

# --------------------------------------------------------------------------
# Separate .sv and .v files, analyze in order
# --------------------------------------------------------------------------
set sv_files {}
set v_files  {}
foreach f $all_files {
    if {[file extension $f] eq ".v"} {
        lappend v_files $f
    } else {
        lappend sv_files $f
    }
}

puts "=================================================================="
puts "  Reading [llength $sv_files] SystemVerilog + [llength $v_files] Verilog files"
puts "  Include dirs: [llength $all_incdirs]"
puts "  Defines:      $all_defines"
puts "=================================================================="

if {[llength $sv_files] > 0} {
    analyze -format sverilog -vcs $analyze_opts -library WORK $sv_files
}
if {[llength $v_files] > 0} {
    analyze -format verilog  -vcs $analyze_opts -library WORK $v_files
}
