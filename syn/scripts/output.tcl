###############################################################################
# syn/scripts/output.tcl
# Post-compile output export and report generation.
###############################################################################

# ---------------------------------------------------------------------------
# output_post_compile
#   Exports gate-level netlist, floorplan, DEF, and per-scenario timing files
#   (SPEF, SDF, SDC).
#
#   Args:
#     top_module       - top-level module name
#     elab_name        - elaborated design name (used for filenames)
#     output_dir       - directory for output files
#     active_scenarios - list of scenario names
# ---------------------------------------------------------------------------
proc output_post_compile {top_module elab_name output_dir active_scenarios} {
    current_design $top_module
    change_names -rules verilog -hier

    # Structural outputs (scenario-independent)
    write -f verilog -hierarchy -output ${output_dir}/${elab_name}_netlist.v
    write_floorplan -all ${output_dir}/${elab_name}.fp
    write_def -output ${output_dir}/${elab_name}.def
    saif_map -type ptpx -write_map ${output_dir}/${elab_name}.mapped.SAIF.namemap


    write_parasitics -output ${output_dir}/${elab_name}.spef

    # Do not write topographical net RC as per-net set_load/set_resistance in SDC.
    set_app_var write_sdc_output_lumped_net_capacitance false
    set_app_var write_sdc_output_net_resistance false

    # Per-scenario timing outputs (SDF, SDC, environment vary by corner)
    set scen_dir ${output_dir}/scenarios
    file mkdir ${scen_dir}

    foreach s $active_scenarios {
        puts "   exporting scenario: $s"
        mmmc_current_scenario $s
        set sd ${scen_dir}/${s}
        file mkdir ${sd}

        write_sdf                    ${sd}/${elab_name}.sdf
        write_sdc -nosplit           ${sd}/${elab_name}.sdc
        write_environment -format dctcl -output ${sd}/${elab_name}.environment.tcl
    }
}

# ---------------------------------------------------------------------------
# output_reports
#   Generates QoR summary reports and per-scenario timing/power reports.
#
#   Args:
#     report_dir       - directory for report files
#     active_scenarios - list of scenario names
#     max_paths        - max timing paths to report
# ---------------------------------------------------------------------------
proc output_reports {report_dir active_scenarios max_paths} {
    # Summary reports (scenario-independent)
    report_area   -hier -nosplit                                    > ${report_dir}/area.rpt
    report_qor                                                      > ${report_dir}/qor.rpt
    report_resources  -hierarchy                                    > ${report_dir}/resources_postcompile.rpt
    report_clock_gating -nosplit                                    > ${report_dir}/clock_gating.rpt
    report_congestion                                               > ${report_dir}/congestion.rpt

    # Per-scenario reports
    set scen_dir ${report_dir}/scenarios
    file mkdir ${scen_dir}

    foreach s $active_scenarios {
        puts "   reporting scenario: $s"
        mmmc_current_scenario $s
        set sd ${scen_dir}/${s}
        file mkdir ${sd}

        report_clocks                                                     > ${sd}/clocks.rpt
        report_power  -nosplit                                            > ${sd}/power.rpt
        report_threshold_voltage_group -nosplit                           > ${sd}/threshold_voltage_group.rpt
        report_constraint -all_violators -nosplit                         > ${sd}/violations.rpt
        report_timing -delay max -nosplit -max_paths ${max_paths}         > ${sd}/timing_max.rpt
        report_timing -delay min -nosplit -max_paths ${max_paths}         > ${sd}/timing_min.rpt
        report_timing -transition_time -nosplit -max_paths ${max_paths}   > ${sd}/timing_transition.rpt
    }
}
