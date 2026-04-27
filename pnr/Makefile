#####################################################################################
# Description:  Innovus Physical Implementation Makefile
# Author:     	Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
#####################################################################################

# check whether TOP is defined
ifndef TOP
$(error ERROR! TOP variable is not defined. Please define the top-level module name by TOP=<name>. Attention! TOP should be the same as rm_core_top in config/user_define.tcl)
endif

# check whether TOP equals to rm_core_top
RM_CORE_TOP = $(shell grep -oP 'set rm_core_top \K.*' ../config/user_define.tcl)
ifneq (${TOP},${RM_CORE_TOP})
$(error ERROR! Dismatch between TOP and rm_core_top. TOP=${TOP}, rm_core_top=${RM_CORE_TOP})
endif

VALID_STAGE = Floorplan Powerplan Place CTS Route Signoff

innovus:
	cd logs && /cadtools/cadence/innovus20.10/bin/innovus -execute "source ../../config/user_define.tcl; source ../../config/global_define.tcl; setLibraryUnit -cap 1pf -time 1ns; set_global timing_derate_spatial_distance_unit 1nm; init_design; source ../scripts/init_pnr.tcl; win" -log ${TOP}.log -overwrite

restore:
ifndef STAGE
	$(error ERROR! STAGE variable is not defined. Please define the restoring stage by STAGE=<Floorplan|Powerplan|Place|CTS|Route|Signoff>)
else
ifeq ($(filter ${STAGE},${VALID_STAGE}),)
	$(error ERROR! Unknown restoring stage. Choose among "Floorplan", "Powerplan", "Place", "CTS", "Route", "Signoff")
else
	cd logs && /cadtools/cadence/innovus20.10/bin/innovus -execute "source ../../config/user_define.tcl; source ../../config/global_define.tcl; source ../scripts/floorplan/macro_alias.tcl; setLibraryUnit -cap 1pf -time 1ns; set_global timing_derate_spatial_distance_unit 1nm; restoreDesign ../${TOP}/backup/${TOP}_post${STAGE}.enc.dat ${TOP}; source ../scripts/init_pnr_${OPT_LEVEL}.tcl; win" -log ${TOP}.log -overwrite
endif
endif
