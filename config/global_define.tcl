#####################################################################################
# Description:  Global Definition File for Synthesis and Physical Implementation
# Modifier:     Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
# Acknowledge:  Columbia University, System Level Design Group
#####################################################################################

# -----------------------------------------------------------------------------------
# Design Specific Library Setup
# -----------------------------------------------------------------------------------
# The rm_foundry_lib_dirs directory should contain the std cell libraries of various VT strenghts (ulvt, lvt, svt, ehv)
set metal_option            1P9M_6X1Z1U
set rm_foundry_kit_dirs     /work/home/yihan/pdks/tsmc/tsmc22ull
set rm_foundry_lib_dirs     /work/home/wumeng/pdks/tsmc/tsmc22ull/${std_lib}_110a/digital 
set base_lib_dir            ${rm_foundry_lib_dirs}/Front_End/timing_power_noise/NLDM/${std_lib}_110b
set base_aocv_dir           ${rm_foundry_lib_dirs}/Front_End/SBOCV/CCS/${std_lib}_110a
set base_gds_dir            ${rm_foundry_lib_dirs}/Back_End/gds/${std_lib}_110a

# Library parameters
# PVT corners of std cells
set std_tt_0p80v_25c_opcond  tt0p8v25c
set std_tt_0p80v_85c_opcond  tt0p8v85c
set std_ss_0p72v_m40c_opcond ssg0p72vm40c
set std_ss_0p72v_0c_opcond   ssg0p72v0c
set std_ss_0p72v_125c_opcond ssg0p72v125c
set std_ff_0p88v_m40c_opcond ffg0p88vm40c
set std_ff_0p88v_0c_opcond   ffg0p88v0c
set std_ff_0p88v_125c_opcond ffg0p88v125c

# PVT corners of SRAM cells
set ram_tt_0p80v_25c_opcond  _tt_typical_0p80v_0p80v_25c
set ram_tt_0p80v_85c_opcond  _tt_typical_0p80v_0p80v_85c
set ram_ss_0p72v_m40c_opcond _ssg_cworstt_0p72v_0p72v_m40c
set ram_ss_0p72v_0c_opcond   _ssg_cworstt_0p72v_0p72v_0c
set ram_ss_0p72v_125c_opcond _ssg_cworstt_0p72v_0p72v_125c
set ram_ff_0p88v_m40c_opcond _ffg_cbestt_0p88v_0p88v_m40c
set ram_ff_0p88v_0c_opcond   _ffg_cbestt_0p88v_0p88v_0c
set ram_ff_0p88v_125c_opcond _ffg_cbestt_0p88v_0p88v_125c

# -----------------------------------------------------------------------------------
# Path to library directories
# -----------------------------------------------------------------------------------
set rm_sram_lib_dirs                ../../src/sram
set rm_macro_dirs                   ../../src/macro

# -----------------------------------------------------------------------------------
# P&R Technology File Locations
# -----------------------------------------------------------------------------------
set innovus_techfiles    /work/home/tyjia/common/TSMC_22NM_ULL/RC_QRC_cln22ulp_1p9m_6x1z1u_ut-alrdl_9corners_shrink_1.0p3a

# Provide files for INNOVUS Quantus Extraction tool 
set rm_max_qrc_file            ${innovus_techfiles}/RC_QRC_cln22ulp_1p09m+ut-alrdl_6x1z1u_rcworst/qrcTechFile
set rm_typ_qrc_file            ${innovus_techfiles}/RC_QRC_cln22ulp_1p09m+ut-alrdl_6x1z1u_typical/qrcTechFile
set rm_min_qrc_file            ${innovus_techfiles}/RC_QRC_cln22ulp_1p09m+ut-alrdl_6x1z1u_rcbest/qrcTechFile

# Provide files for INNOVUS LEF Tech files
set rm_lef_layer_map           /work/home/wumeng/T22/digital_flow/map_file/streamOut.map
set rm_lef_tech_file           ${innovus_techfiles}/../tn22clpr001e2_1_1_1a/PRTF_Innovus_22nm_001_Cad_V11_1a/PR_tech/Cadence/LefHeader/HVH/PRTF_Innovus_22nm_9M_6X1Z1URDL_9T.11_1a.tlef

# -----------------------------------------------------------------------------------
# Technology Library Setup
# -----------------------------------------------------------------------------------
# Path for Lef libs
set rm_lef_reflib [concat ${rm_lef_tech_file} ${rm_foundry_lib_dirs}/Back_End/lef/${std_lib}_110a/lef/${std_lib}.lef \
		/work/home/wumeng/pdks/tsmc/tsmc22ull/tphn22ullgv2od3_c171206_110b/digital/Back_End/lef/tphn22ullgv2od3_c171206_120a/mt_2/9m/9M_6X2Z/lef/tphn22ullgv2od3_c171206_9lm.lef \
		/work/home/wumeng/pdks/tsmc/tsmc22ull/tpbn22v_110a/digital/Back_End/lef/tpbn22v_110a/cup/9m/9M_6X1Z1U/lef/tpbn22v_9lm.lef  \
		]

# Add memory lef libraries
foreach sram ${sram_insts} { \
  set rm_lef_reflib [concat $rm_lef_reflib ${rm_sram_lib_dirs}/${sram}/${sram}.lef] \
}

# Add macro lef libraries
foreach macro ${macro_insts} { \
  set rm_lef_reflib [concat $rm_lef_reflib ${rm_macro_dirs}/${macro}/${macro}.lef] \
}

# Set this multiplier (eg. 2) to the desired width and spacing of the clock-tree routing
set rm_clock_routing_width_multiplier   2
set rm_clock_routing_spacing_multiplier 2

# -----------------------------------------------------------------------------------
# Cell Specific Setup
# The numerical values in the [] brackets in the associated comment are some reasonable examples the user may adopt
# -----------------------------------------------------------------------------------
# This section contains lists of cells which are used, or excluded, by specific parts of the implementation flow

# Tie cells used to provide logic-1 and logic-0. Variable used in ICC flow steps
set rm_tie_hi_lo_list [list TIEH${cell_ext} \
                            TIEL${cell_ext} ]

# Output pin on the above-mentioned tie cells
set rm_tie_cell_pin     "Z"


# These lists contains all the cells available for use by Clock Tree Synthesis (CTS)
# CTS only uses one Vt for better path matching across a die. These lists are
# referenced only during clock_opt

foreach cell $cell_ext { 
  set rm_clock_buf_cap_cell [concat CKBD1${cell} CKBD2${cell} CKBD3${cell} CKBD4${cell} CKBD8${cell} CKBD12${cell} CKBD16${cell} CKBD20${cell}]
}

foreach cell $cell_ext { 
  set rm_clock_inv_cap_cell [concat INVD1${cell} INVD2${cell} INVD3${cell} INVD4${cell} INVD8${cell} INVD12${cell} INVD16${cell} INVD20${cell}]
}

#PREICG  - active high scan-enable
#POSTICG - active low asynchronous scan-enable
set rm_clock_icg_cell [list CKLNQD1${cell_ext}  CKLNQD2${cell_ext}  CKLNQD4${cell_ext}  CKLNQD8${cell_ext} \
			                CKLNQD16${cell_ext} CKLNQD20${cell_ext} CKLNQD1${cell_ext}  CKLHQD2${cell_ext} \
			                CKLHQD4${cell_ext}  CKLHQD8${cell_ext}  CKLHQD16${cell_ext} CKLHQD20${cell_ext} ]

# If delay cells are needed they are referenced from this list
set rm_logic_delay_cell [list   DEL025D1${cell_ext}  DEL050MD1${cell_ext} DEL075MD1${cell_ext} DEL100MD1${cell_ext} \
				                DEL150MD1${cell_ext} DEL200MD1${cell_ext} DEL250MD1${cell_ext}  ]
set rm_clock_delay_cell [list   BUFFD2${cell_ext} BUFFD4${cell_ext} BUFFD8${cell_ext} BUFFD12${cell_ext} BUFFD16${cell_ext} ]

# List of hold-fixing delay cells. User may use the list in $rm_logic_delay_cell in combination with other delay or buffer cells
set hold_fixing_cells [concat $rm_logic_delay_cell $rm_clock_delay_cell ]

# Filler cells used for density compliance
set rm_fill_cells [list FILL2${cell_ext}   FILL3${cell_ext}  DCAP8${cell_ext} \
                        DCAP16${cell_ext}  DCAP32${cell_ext} DCAP64${cell_ext} ]

## Tap cell to be used in design planning
set rm_tap_cell TAPCELLBWP7T30P140

## Distance in um between Tap cells
set rm_tap_cell_distance   60	;# maximum distance of 66um
## Offset between Tap cells
set rm_tap_cell_offset     0	;# [0]

## Endcap cells
set endcap_left     [list BOUNDARY_LEFTBWP7T30P140 ]
set endcap_right    [list BOUNDARY_RIGHTBWP7T30P140 ]
set dcap_cell       [list DCAP4${cell_ext}]

## Antenna diode cells
set antenna_cell    [list ANTENNA${cell_ext}]

## I/O filler & PAD cells
set IO_fill_cell    [list PCORNER PFILLER20 PFILLER10 PFILLER5 PFILLER1 PFILLER05 PFILLER0005 PRCUT]
set PAD_cell        [list PAD52D6GU PAD53D6NU PAD63D1GU PAD63D1NU PAD73D6GU PAD73D6NU]

## List of physical only cells to be excluded from the LVS netlist. This list would typically include tap, filler, antenna and boundary cells
set lvs_exclude_cells [concat ${rm_tap_cell} ${rm_fill_cells} ${endcap_left} ${endcap_right} ${dcap_cell} ${IO_fill_cell} ${PAD_cell}]

# -----------------------------------------------------------------------------------
# Design Clock Period 
# The numerical values in the [] brackets in the associated comment are some reasonable examples the user may adopt
# -----------------------------------------------------------------------------------
set rm_max_transition                   0.15    ;# maximum rise/fall signal transition time in ns [0.250]
set rm_max_clock_transition             0.1     ;# maximum rise/fall clock transition time in ns [0.150]
set rm_max_pad_transition               0.3     ;# maximum rise/fall pad transition time in ns [1.00]
set rm_clock_latency                    0.1     ;# Predicted clock insertion delay in ns [1.00]
set rm_icg_latency                      0.07    ;# Latency in ns for integrated clock gating cell [0.07]
set rm_rz_setup_margin                  0.05    ;# in ns. Setup margin [0.05]
set rm_setup_margin                     0.05    ;# in ns. Setup margin [0.05]
set rm_hold_margin                      0.1     ;# in ns. Hold margin [0.075]
set rm_clock_uncertainty                0.1     ;# in ns. Pre-CTS clock skew estimate [0.1]
set rm_period_jitter                    0.01    ;# Cycle jitter (rise-to-rise) +/- N ns [0.03]
set rm_pre_cts_clock_uncertainty        0.2     ;# in ns. Pre-CTS clock skew estimate [0.1]
set rm_post_cts_clock_uncertainty       0.175   ;# in ns. Post-CTS clock skew estimate [0.075]

# ---------------------------------------------------------------------------------------------------
# Parameters used in Timing Characterization
# The numerical values in the [] brackets in the associated comment are some reasonable examples the user may adopt
# ---------------------------------------------------------------------------------------------------

set rm_load_value                       0.2                 ;# Capacitive load in pF placed on all outputs [0.04]
set rm_driving_cell                     BUFFD4${cell_ext}   ;# The driving cell for all inputs
set rm_driving_pin                      "Z"                 ;# The output pin of the driving cell
set rm_clock_driving_cell               BUFFD4${cell_ext}   ;# The driving cell for all inputs
set rm_clock_driving_pin                "Z"                 ;# The output pin of the clock driving cell
set rm_dcd_jitter                       0.05                ;# Duty cycle distortion as a percentage of the whole
                                                            ;# cycle - +/- N%. Affects the falling edge
                                                            ;# of the clock [0.05]
set rm_ocv_derate_factor                0.05                ;# %. 0.10 = 10%, 0.05 = 5% [0.05]
set rm_critical_range                   0.1                 ;# Critical range. % of the rm_clock_period [0.1]
set rm_icg_name       		            $rm_clock_icg_cell  ;# Name of ICG cell
set rm_max_fanout                       16                  ;# Maximum fanout threshold [32]
set rm_cts_max_fanout                   16                  ;# Maximum fanout threshold [16]

# -----------------------------------------------------------------------------------
# Tool reporting defaults
# The numerical values in the [] brackets in the associated comment are some reasonable examples the user may adopt
# -----------------------------------------------------------------------------------
# Provide the number of significant digits when reporting the precision of timing and area reports 
set report_default_significant_digits 4   ;# [3.0]

# -----------------------------------------------------------------------------------
# Floorplan Control Setup
# The numerical values in the [] brackets in the associated comment are some reasonable examples the user may adopt
# -----------------------------------------------------------------------------------
set rm_core_utilization  0.5    ;# utilization ratio of the macro floorplan [0.5]
set rm_aspect_ratio      1		;# height-to-width ratio of the macro floorplan [1.00]
set rm_fp_exists         0      ;# Set this to 1 if you want synthesis to read in floorplanning scripts [0] 
set rm_fp_clustering     1      ;# Set this variable to 1 to enable local clustering of cells
                                ;# Usually clustering is the default option. But, for small designs, taking it out
                                ;# is better for routing [1]

# -----------------------------------------------------------------------------------
# Set Host Options
# -----------------------------------------------------------------------------------
# Logical names of libraries
set base_tt_0p80v_25c_lib      [list ${std_lib}${std_tt_0p80v_25c_opcond} ]
set base_tt_0p80v_85c_lib      [list ${std_lib}${std_tt_0p80v_85c_opcond} ]
set base_ss_0p72v_m40c_lib     [list ${std_lib}${std_ss_0p72v_m40c_opcond}]
set base_ss_0p72v_0c_lib       [list ${std_lib}${std_ss_0p72v_0c_opcond}  ]
set base_ss_0p72v_125c_lib     [list ${std_lib}${std_ss_0p72v_125c_opcond}]
set base_ff_0p88v_m40c_lib     [list ${std_lib}${std_ff_0p88v_m40c_opcond}]
set base_ff_0p88v_0c_lib       [list ${std_lib}${std_ff_0p88v_0c_opcond}  ]
set base_ff_0p88v_125c_lib     [list ${std_lib}${std_ff_0p88v_125c_opcond}]

# IO Libs
set io_lib /work/home/wumeng/pdks/tsmc/tsmc22ull/tphn22ullgv2od3_c171206_110b/digital/Front_End/timing_power_noise/NLDM/tphn22ullgv2od3_c171206_120a/tphn22ullgv2od3_c171206

# -----------------------------------------------------------------------------------
# Nominal Library Set
# -----------------------------------------------------------------------------------
# TT(Typical-Typical) 0p80V 25C Libs
set tt_0p80v_25c_libs  [list ${base_lib_dir}/${base_tt_0p80v_25c_lib}.lib \
                             ${io_lib}tt0p8v2p5v25c.lib]

# TT(Typical-Typical) 0p80V 85C Libs
set tt_0p80v_85c_libs  [list ${base_lib_dir}/${base_tt_0p80v_85c_lib}.lib \
                             ${io_lib}tt0p8v2p5v85c.lib]

# FF(Fast-Fast) 0p88V 125C Libs
set ff_0p88v_125c_libs [list ${base_lib_dir}/${base_ff_0p88v_125c_lib}.lib \
                             ${io_lib}ffg0p88v2p75v125c.lib]

# FF(Fast-Fast) 0p88V 0C Libs
set ff_0p88v_0c_libs   [list ${base_lib_dir}/${base_ff_0p88v_0c_lib}.lib \
                             ${io_lib}ffg0p88v2p75v0c.lib]

# FF(Fast-Fast) 0p88V m40C Libs
set ff_0p88v_m40c_libs [list ${base_lib_dir}/${base_ff_0p88v_m40c_lib}.lib \
                             ${io_lib}ffg0p88v2p75vm40c.lib]

# SS(Slow-Slow) 0p72V 125C Libs
set ss_0p72v_125c_libs [list ${base_lib_dir}/${base_ss_0p72v_125c_lib}.lib \
                             ${io_lib}ssg0p72v2p25v125c.lib]

# SS(Slow-Slow) 0p72V 0C Libs
set ss_0p72v_0c_libs   [list ${base_lib_dir}/${base_ss_0p72v_0c_lib}.lib \
                             ${io_lib}ssg0p72v2p25v0c.lib]

# SS(Slow-Slow) 0p72V m40C Libs
set ss_0p72v_m40c_libs [list ${base_lib_dir}/${base_ss_0p72v_m40c_lib}.lib \
                             ${io_lib}ssg0p72v2p25vm40c.lib]

# SRAM Libs
foreach sram ${sram_insts} { 
  set tt_0p80v_25c_libs  [concat $tt_0p80v_25c_libs  ${rm_sram_lib_dirs}/${sram}/${sram}${ram_tt_0p80v_25c_opcond}.lib] 
  set tt_0p80v_85c_libs  [concat $tt_0p80v_85c_libs  ${rm_sram_lib_dirs}/${sram}/${sram}${ram_tt_0p80v_85c_opcond}.lib] 
  set ff_0p88v_125c_libs [concat $ff_0p88v_125c_libs ${rm_sram_lib_dirs}/${sram}/${sram}${ram_ff_0p88v_125c_opcond}.lib] 
  set ff_0p88v_0c_libs   [concat $ff_0p88v_0c_libs   ${rm_sram_lib_dirs}/${sram}/${sram}${ram_ff_0p88v_0c_opcond}.lib]
  set ff_0p88v_m40c_libs [concat $ff_0p88v_m40c_libs ${rm_sram_lib_dirs}/${sram}/${sram}${ram_ff_0p88v_m40c_opcond}.lib] 
  set ss_0p72v_125c_libs [concat $ss_0p72v_125c_libs ${rm_sram_lib_dirs}/${sram}/${sram}${ram_ss_0p72v_125c_opcond}.lib] 
  set ss_0p72v_0c_libs   [concat $ss_0p72v_0c_libs   ${rm_sram_lib_dirs}/${sram}/${sram}${ram_ss_0p72v_0c_opcond}.lib]
  set ss_0p72v_m40c_libs [concat $ss_0p72v_m40c_libs ${rm_sram_lib_dirs}/${sram}/${sram}${ram_ss_0p72v_m40c_opcond}.lib] 
}

# MACRO Libs
foreach macro ${macro_insts} {
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_tt_0p80v_25c.lib"]} {
    set tt_0p80v_25c_libs  [concat $tt_0p80v_25c_libs  ${rm_macro_dirs}/${macro}/${macro}_tt_0p80v_25c.lib]
  }
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_tt_0p80v_85c.lib"]} {
    set tt_0p80v_85c_libs  [concat $tt_0p80v_85c_libs  ${rm_macro_dirs}/${macro}/${macro}_tt_0p80v_85c.lib]
  }
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_ff_0p88v_125c.lib"]} {
    set ff_0p88v_125c_libs [concat $ff_0p88v_125c_libs ${rm_macro_dirs}/${macro}/${macro}_ff_0p88v_125c.lib]
  } 
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_ff_0p88v_0c.lib"]} {
    set ff_0p88v_0c_libs   [concat $ff_0p88v_0c_libs   ${rm_macro_dirs}/${macro}/${macro}_ff_0p88v_0c.lib]
  }
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_ff_0p88v_m40c.lib"]} {
    set ff_0p88v_m40c_libs [concat $ff_0p88v_m40c_libs ${rm_macro_dirs}/${macro}/${macro}_ff_0p88v_m40c.lib]
  }
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_ss_0p72v_125c.lib"]} {
    set ss_0p72v_125c_libs [concat $ss_0p72v_125c_libs ${rm_macro_dirs}/${macro}/${macro}_ss_0p72v_125c.lib]
  }
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_ss_0p72v_0c.lib"]} {
    set ss_0p72v_0c_libs   [concat $ss_0p72v_0c_libs   ${rm_macro_dirs}/${macro}/${macro}_ss_0p72v_0c.lib]
  }
  if {[file exists "${rm_macro_dirs}/${macro}/${macro}_ss_0p72v_m40c.lib"]} {
    set ss_0p72v_m40c_libs [concat $ss_0p72v_m40c_libs ${rm_macro_dirs}/${macro}/${macro}_ss_0p72v_m40c.lib]
  }
}

# -----------------------------------------------------------------------------------
# AOCV(Advanced On-Chip Variation) Library Definitions
# -----------------------------------------------------------------------------------
# TT 0.80V 25C
set tt_0p80v_25c_aocv  [list ${base_aocv_dir}/${std_tt_0p80v_25c_opcond}/clock_p_data_p/${base_tt_0p80v_25c_lib}_hold_P_P_ccs.aocvm]

# TT 0.80V 85C
set tt_0p80v_85c_aocv  [list ${base_aocv_dir}/${std_tt_0p80v_85c_opcond}/clock_p_data_p/${base_tt_0p80v_85c_lib}_hold_P_P_ccs.aocvm]

# SS 0.72V 125C
set ss_0p72v_125c_aocv [list ${base_aocv_dir}/${std_ss_0p72v_125c_opcond}/clock_p_data_p/${base_ss_0p72v_125c_lib}_hold_P_P_ccs.aocvm]

# SS 0.72V 0C
set ss_0p72v_0c_aocv   [list ${base_aocv_dir}/${std_ss_0p72v_0c_opcond}/clock_p_data_p/${base_ss_0p72v_0c_lib}_hold_P_P_ccs.aocvm]

# SS 0.72V m40C
set ss_0p72v_m40c_aocv [list ${base_aocv_dir}/${std_ss_0p72v_m40c_opcond}/clock_p_data_p/${base_ss_0p72v_m40c_lib}_hold_P_P_ccs.aocvm]

# FF 0.88V m40C
set ff_0p88v_m40c_aocv [list ${base_aocv_dir}/${std_ff_0p88v_m40c_opcond}/clock_p_data_p/${base_ff_0p88v_m40c_lib}_hold_P_P_ccs.aocvm]

# FF 0.88V 0C
set ff_0p88v_0c_aocv   [list ${base_aocv_dir}/${std_ff_0p88v_0c_opcond}/clock_p_data_p/${base_ff_0p88v_m40c_lib}_hold_P_P_ccs.aocvm]

# FF 0.88V 125C
set ff_0p88v_125c_aocv [list ${base_aocv_dir}/${std_ff_0p88v_125c_opcond}/clock_p_data_p/${base_ff_0p88v_125c_lib}_hold_P_P_ccs.aocvm]

# -----------------------------------------------------------------------------------
# MMMC (Multi-Mode Multi-Corner) Definitions
# -----------------------------------------------------------------------------------
# Technology definition
set tech(process_node)              "22"
set tech(pdk_lib_path)              $rm_foundry_lib_dirs
set tech(lib_list_ss_0p72v_125c)    $ss_0p72v_125c_libs
set tech(lib_list_ss_0p72v_0c)      $ss_0p72v_0c_libs
set tech(lib_list_ss_0p72v_m40c)    $ss_0p72v_m40c_libs
set tech(lib_list_ff_0p88v_m40c)    $ff_0p88v_m40c_libs
set tech(lib_list_ff_0p88v_0c)      $ff_0p88v_0c_libs
set tech(lib_list_ff_0p88v_125c)    $ff_0p88v_125c_libs
set tech(lib_list_tt_0p80v_25c)     $tt_0p80v_25c_libs
set tech(lib_list_tt_0p80v_85c)     $tt_0p80v_85c_libs
set tech(aocv_list_ss_0p72v_125c)   $ss_0p72v_125c_aocv
set tech(aocv_list_ss_0p72v_0c)     $ss_0p72v_0c_aocv
set tech(aocv_list_ss_0p72v_m40c)   $ss_0p72v_m40c_aocv
set tech(aocv_list_ff_0p88v_m40c)   $ff_0p88v_m40c_aocv
set tech(aocv_list_ff_0p88v_0c)     $ff_0p88v_0c_aocv
set tech(aocv_list_ff_0p88v_125c)   $ff_0p88v_125c_aocv
set tech(aocv_list_tt_0p80v_25c)    $tt_0p80v_25c_aocv
set tech(aocv_list_tt_0p80v_85c)    $tt_0p80v_85c_aocv
set tech(lef_list)                  $rm_lef_reflib
set tech(pdk_tech_path)             $rm_foundry_kit_dirs
set tech(tech_file_wc)              $rm_max_qrc_file
set tech(tech_file_typ)             $rm_typ_qrc_file
set tech(tech_file_bc)              $rm_min_qrc_file
set tech(driving_cell_lib)          $std_lib
set tech(driving_cell)              $rm_driving_cell
set tech(driving_pin)               $rm_driving_pin

# MMMC variables
set proj(corners) "tt_0p80v_25c tt_0p80v_85c ss_0p72v_m40c ss_0p72v_0c ss_0p72v_125c ff_0p88v_m40c ff_0p88v_0c ff_0p88v_125c"

# Set operating conditions values for each corner
# The variable format must be proj(<corner>,P/V/T)
# Use same values that are specified in liberty file
set proj(ss_0p72v_125c,P) "1"
set proj(ss_0p72v_125c,T) "125"
set proj(ss_0p72v_125c,V) "0.72"

set proj(ss_0p72v_0c,P) "1"
set proj(ss_0p72v_0c,T) "0"
set proj(ss_0p72v_0c,V) "0.72"

set proj(ss_0p72v_m40c,P) "1"
set proj(ss_0p72v_m40c,T) "-40"
set proj(ss_0p72v_m40c,V) "0.72"

set proj(tt_0p80v_25c,P) "1"
set proj(tt_0p80v_25c,T) "25"
set proj(tt_0p80v_25c,V) "0.8"

set proj(tt_0p80v_85c,P) "1"
set proj(tt_0p80v_85c,T) "85"
set proj(tt_0p80v_85c,V) "0.8"

set proj(ff_0p88v_m40c,P) "1"
set proj(ff_0p88v_m40c,T) "-40"
set proj(ff_0p88v_m40c,V) "0.88"

set proj(ff_0p88v_0c,P) "1"
set proj(ff_0p88v_0c,T) "0"
set proj(ff_0p88v_0c,V) "0.88"

set proj(ff_0p88v_125c,P) "1"
set proj(ff_0p88v_125c,T) "125"
set proj(ff_0p88v_125c,V) "0.88"

# Set liberty libraries for each corner
# The varialbe format must be proj(library_set,<corner>)
set proj(library_set,ss_0p72v_m40c) $tech(lib_list_ss_0p72v_m40c)
set proj(library_set,ss_0p72v_0c)   $tech(lib_list_ss_0p72v_0c)
set proj(library_set,ss_0p72v_125c) $tech(lib_list_ss_0p72v_125c)
set proj(library_set,tt_0p80v_25c)  $tech(lib_list_tt_0p80v_25c)
set proj(library_set,tt_0p80v_85c)  $tech(lib_list_tt_0p80v_85c)
set proj(library_set,ff_0p88v_m40c) $tech(lib_list_ff_0p88v_m40c)
set proj(library_set,ff_0p88v_0c)   $tech(lib_list_ff_0p88v_0c)
set proj(library_set,ff_0p88v_125c) $tech(lib_list_ff_0p88v_125c)

# Set aocv libraries for each corner
# The variable format must be proj(library_aocv,<corner>)
set proj(library_aocv,ss_0p72v_m40c) $tech(aocv_list_ss_0p72v_m40c)
set proj(library_aocv,ss_0p72v_0c)   $tech(aocv_list_ss_0p72v_0c)
set proj(library_aocv,ss_0p72v_125c) $tech(aocv_list_ss_0p72v_125c)
set proj(library_aocv,tt_0p80v_25c)  $tech(aocv_list_tt_0p80v_25c)
set proj(library_aocv,tt_0p80v_85c)  $tech(aocv_list_tt_0p80v_85c)
set proj(library_aocv,ff_0p88v_m40c) $tech(aocv_list_ff_0p88v_m40c)
set proj(library_aocv,ff_0p88v_0c)   $tech(aocv_list_ff_0p88v_0c)
set proj(library_aocv,ff_0p88v_125c) $tech(aocv_list_ff_0p88v_125c)

# Set techfiles for each corner
# The variable format must be proj(techfile,<corner>)
set proj(techfile,ss_0p72v_m40c) $tech(tech_file_wc)
set proj(techfile,ss_0p72v_0c)   $tech(tech_file_wc)
set proj(techfile,ss_0p72v_125c) $tech(tech_file_wc)
set proj(techfile,tt_0p80v_25c)  $tech(tech_file_typ)
set proj(techfile,tt_0p80v_85c)  $tech(tech_file_typ)
set proj(techfile,ff_0p88v_m40c) $tech(tech_file_bc)
set proj(techfile,ff_0p88v_0c)   $tech(tech_file_bc)
set proj(techfile,ff_0p88v_125c) $tech(tech_file_bc)

# Specify one sdc file for design's operation mode
set proj(constraints,func) ../../config/constraints_${rm_core_top}.sdc

# specify RTL directory
# 'pwd' == [syn|pnr]/logs
set SRC_DIR [exec pwd]/../../src

# specify MACRO & SRAM GDS directory
set sram_gds  [list ]
set macro_gds [list ]
foreach sram ${sram_insts} {
    set sram_gds  [concat ${sram_gds} [glob -nocomplain -directory ${rm_sram_lib_dirs}/${sram} *.gds *.gds2]]
}
foreach macro ${macro_insts} {
    set macro_gds [concat ${macro_gds} [glob -nocomplain -directory ${rm_macro_dirs}/${macro} *.gds *.gds2]]
}
set gds_list [concat  ${base_gds_dir}/${std_lib}.gds \
                            ${sram_gds} ${macro_gds} \
                            /work/home/wumeng/pdks/tsmc/tsmc22ull/tphn22ullgv2od3_c171206_110b/digital/Back_End/gds/tphn22ullgv2od3_c171206_120a/mt_2/9m/9M_6X2Z/tphn22ullgv2od3_c171206.gds \
                            /work/home/wumeng/pdks/tsmc/tsmc22ull/tpbn22v_110a/digital/Back_End/gds/tpbn22v_110a/cup/9m/9M_6X1Z1U/tpbn22v.gds]

# -----------------------------------------------------------------------------------
# Innovus Global TCL Variables
# -----------------------------------------------------------------------------------
set init_verilog            "../../syn/${rm_core_top}/${rm_core_top}_postsyn.v"
set init_lef_file           "${rm_lef_reflib}"
set init_mmmc_file          "../scripts/pnr_mmmc.tcl"
set init_top_cell           "${rm_core_top}"
set init_design_uniquify    {1}

set cell_height             0.7
set macro_halo_spc          [expr 1 * $cell_height]
set macro_halo_spc_4        [expr 4 * $cell_height]
set macro_halo_spc_2        [expr 2 * $cell_height]

# -----------------------------------------------------------------------------------
# v2lvs converting option
# -----------------------------------------------------------------------------------

set v2lvs_option "\
    -s ${rm_foundry_lib_dirs}/Back_End/spice/${std_lib}_110a/${std_lib}_110a.spi \
    -s /work/home/wumeng/pdks/tsmc/tsmc22ull/tphn22ullgv2od3_c171206_110b/digital/Back_End/spice/tphn22ullgv2od3_c171206_120a/tphn22ullgv2od3_c171206.spi \
    -s /project/common/ncc/foundry/tsmc/TSMC_22nm_ULL/PDK/PDK_20211230_LO_0.8V_2.5V_1P9M_6X1Z1U_UT_ALRDL/Calibre/lvs/source.added"

foreach sram ${sram_insts} {
    set cdl_dir [file normalize ${rm_sram_lib_dirs}/${sram}]
    set v2lvs_option "${v2lvs_option} -s ${cdl_dir}/${sram}.cdl"
}

foreach macro ${macro_insts} {
    set cdl_dir [file normalize ${rm_macro_dirs}/${macro}]
    set v2lvs_option "${v2lvs_option} -s ${cdl_dir}/${macro}.cdl"
}

