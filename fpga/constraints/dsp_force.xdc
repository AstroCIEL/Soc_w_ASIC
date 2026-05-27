# -----------------------------------------------------------------------------
# DSP inference guidance for MXU compute hierarchy
# -----------------------------------------------------------------------------
# Goal: reduce LUT pressure by steering arithmetic mapping into DSP48 resources.
# This does not change RTL algorithm or array sizes; it only guides synthesis.
#
# NOTE:
# XDC does not support Tcl control flow (if/foreach). Keep commands declarative.

set_property USE_DSP yes [get_cells -hier -filter {ORIG_REF_NAME =~ "mxu_top*" || REF_NAME =~ "mxu_top*"}]
set_property USE_DSP yes [get_cells -hier -filter {ORIG_REF_NAME =~ "mxu_top_no_ctrl*" || REF_NAME =~ "mxu_top_no_ctrl*"}]
set_property USE_DSP yes [get_cells -hier -filter {ORIG_REF_NAME =~ "Systolic_Array*" || REF_NAME =~ "Systolic_Array*"}]
set_property USE_DSP yes [get_cells -hier -filter {ORIG_REF_NAME =~ "PE_kernel*" || REF_NAME =~ "PE_kernel*"}]
set_property USE_DSP yes [get_cells -hier -filter {ORIG_REF_NAME =~ "zzc_adder*" || REF_NAME =~ "zzc_adder*"}]
