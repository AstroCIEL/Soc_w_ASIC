#####################################################################################
# Description:  User-Specific Definition file
# Author:       Siris Li <mingxuanli_siris@163.com> [Peking University]
#####################################################################################

# Top module name
# ONLY ONE SPACE between 'rm_core_top' keyword and module name!
set rm_core_top soc

# Clock name
set rm_clock_pin clk

# Target clock period in ns
set rm_clock_period 2

# List the names of the SRAMs instantiated in design
# Directory format: src/sram/<name>/
# Dont comment this variable
# If no extra sram instances, leave a blank list
# ONLY ONE SPACE bwtween 'list' keyword and sram name!
set sram_insts [list sram128x128 sram128x46 sram1024x64]

# List the names of the MACROs instantiated in design
# Directory format: src/macro/<name>/
# Dont comment this variable
# If no extra macro instances, leave a blank list
# ONLY ONE SPACE bwtween 'list' keyword and macro name!
set macro_insts [list ]

# Choose voltage threshold
# Possible value: bwp7t30p140lvt, bwp7t30p140hvt, bwp7t30p140
# ONLY ONE SPACE bwtween 'std_lib' keyword and std_lib name!
set std_lib tcbn22ullbwp7t30p140
set cell_ext [list BWP7T30P140]

# Specify active analysis view for timing analysis
# The variable values format must be func_<corner>
# possible func_<corner> value:
# func_ss_0p72v_m40c | func_ss_0p72v_0c | func_ss_0p72v_125c |
# func_ff_0p88v_m40c | func_ff_0p88v_0c | func_ff_0p88v_125c |
# func_tt_0p80v_25c  | func_tt_0p80v_85c
set proj(analysis_view,setup) "func_tt_0p80v_25c func_tt_0p80v_85c" 
set proj(analysis_view,hold)  "func_tt_0p80v_25c func_tt_0p80v_85c"

# Define synthesis optimization level
# Possible value: none | standard | extreme
# Choose extreme when timing constraint is tight
# Standard is enough for most cases
# None is the fastest theoretically
set syn_opt_level standard
