// Synthesis filelist - all paths relative to syn/

// Technology (synthesis)
-f ../hardware/tech/filelist_syn.f

// IPs (order matters: dependencies first)
-f ../hardware/ip/common_cells/filelist.f
-f ../hardware/ip/apb/filelist.f
-f ../hardware/ip/axi/filelist.f
-f ../hardware/ip/fpnew/filelist.f
-f ../hardware/ip/fpu_div_sqrt_mvp/filelist.f
-f ../hardware/ip/cva6/filelist.f
-f ../hardware/ip/ara/filelist.f

// SoC
-f ../hardware/soc/filelist.f
