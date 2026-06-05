###############################################################################
# syn/setup/blocks.tcl
# Block partition definition for hierarchical synthesis.
#
# HIER_BLOCKS defines blocks to be compiled independently.
# When only one block's RTL changes, only that block is recompiled,
# then the top-level design is reassembled from cached block DDCs.
#
# Each entry: {hier_path  ref_name  description}
#   hier_path  — hierarchical instance path from TOP_MODULE (slash-separated)
#   ref_name   — the module name (for identification / logging)
#   description— human-readable label
#
# IMPORTANT:
#   - Paths use "/" as separator (DC convention for hierarchical names)
#   - Blocks can be at ANY depth in the hierarchy
#   - If a parent block is also listed, the child is compiled as part of
#     the parent (child entries take priority for sub-block isolation)
#   - Order matters: children should be listed AFTER parents
#
# EXAMPLES:
#   Top-level sub-blocks:
#     {i_ara_system  ara_system  "CVA6 + Ara vector core"}
#
#   Nested sub-block (2 levels deep):
#     {i_ariane_peripherals/i_default_slave  default_slave  "Default slave"}
#
#   Deep nesting (3+ levels):
#     {i_ara_system/i_ariane/i_cache_subsys  cache_subsys  "L1 caches"}
#
###############################################################################

# ---------------------------------------------------------------------------
# HIER_BLOCKS definition
# ---------------------------------------------------------------------------
set HIER_BLOCKS {
    {i_ara_system                                              ara_system          "CVA6 + Ara vector processor core"}
    {i_axi_xbar                                                axi_xbar_intf       "AXI crossbar interconnect"}
    {i_ariane_peripherals/i_mxu_top_wrapper/i_mxu_top          mxu_top             "MXU top"}
    {i_ariane_peripherals/i_axu_top_wrapper/u_axu_top          axu_top             "AXU top"}

}
