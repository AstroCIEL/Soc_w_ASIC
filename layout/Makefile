#####################################################################################
# Description:  Virtuoso Startup Makefile
# Author:     	Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
#####################################################################################

########### USAGE #############
# b make virtuoso
# 	=> open virtuoso GUI
#
# b make dummy 	 IN_GDS=<in_gds> \
# 				OUT_GDS=<in_top_cell> \
# 				[IN_TOP=<in_top_cell> \
# 				OUT_TOP=<out_top_cell>]
# 	=> add dummy and auto merge to a new GDSII
###############################

IN_GDS ?=
IN_TOP ?= $(basename $(notdir $(IN_GDS)))
USER_DEFINED_IN_TOP := $(if $(filter-out file,$(origin IN_TOP)),yes,no)

OUT_GDS ?=
OUT_TOP ?= $(basename $(notdir $(OUT_GDS)))
USER_DEFINED_OUT_TOP := $(if $(filter-out file,$(origin OUT_TOP)),yes,no)


virtuoso: 
	cd workspace && \
	virtuoso

dummy:
ifndef IN_GDS
	$(error ERROR! `IN_GDS` variable is not defined. Please specify input GDS path by IN_GDS=<path_to_gds_file>)
else
ifndef OUT_GDS
	$(error ERROR! `OUT_GDS` variable is not defined. Please specify input GDS path by OUT_GDS=<path_to_gds_file>)
else
ifeq ($(USER_DEFINED_IN_TOP),no)
	$(warning WARNING: `IN_TOP` variable is not explicitly defined. Using default value "$(IN_TOP)")
endif
ifeq ($(USER_DEFINED_OUT_TOP),no)
	$(warning WARNING: `OUT_TOP` variable is not explicitly defined. Using default value "$(OUT_TOP)")
endif
	@sed -i -e 's#LAYOUT PATH "[^"]*"#LAYOUT PATH "../../$(IN_GDS)"#g' dummy/scripts/Dummy_FEOL_Calibre_22nm_001.13a
	@sed -i -e 's#LAYOUT PATH "[^"]*"#LAYOUT PATH "../../$(IN_GDS)"#g' dummy/scripts/Dummy_BEOL_Calibre_22nm_001.13a
	@sed -i -e 's#LAYOUT PRIMARY "[^"]*"#LAYOUT PRIMARY "$(IN_TOP)"#g' dummy/scripts/Dummy_FEOL_Calibre_22nm_001.13a
	@sed -i -e 's#LAYOUT PRIMARY "[^"]*"#LAYOUT PRIMARY "$(IN_TOP)"#g' dummy/scripts/Dummy_BEOL_Calibre_22nm_001.13a
	$(shell chmod +x dummy/scripts/run_dummy.csh)
	dummy/scripts/run_dummy.csh $(IN_GDS) $(IN_TOP) $(OUT_GDS) $(OUT_TOP)
endif
endif

.PHONY: dummy
