###############################################################################
# Ariane SoC Synthesis Makefile
###############################################################################

SHELL      := /bin/bash
DC_SHELL   := dcnxt_shell -64 -topographical_mode
SYN_ROOT   := $(shell pwd)
PROJ_ROOT  := $(shell cd .. && pwd)
BUILD_DIR  := $(SYN_ROOT)/build

SOC_CONFIG ?= minimum_my_mxu_axu


PDK_ROOT   ?= $(HOME)/workspace/work2026_2/work_for_tapeout_2026_v2/tsmc22
export PDK_ROOT

# Checkpoint to resume from (NONE = full compile from RTL)
# Valid: NONE, post_constraints, post_compile
INCR_CHECKPOINT ?= NONE

# Block(s) to recompile in hier mode (empty = assemble-only from cached DDCs)
# Use hierarchical instance paths from setup/blocks.tcl, e.g.:
#   BLOCK=i_ara_system
#   BLOCK=i_ariane_peripherals/i_default_slave
#   BLOCK="i_ara_system i_dm_top"
BLOCK ?=

.PHONY: all flat flat_verbose hier gen_filelist check clean help

all: help

# ---------------------------------------------------------------------------
# gen_filelist: parse filelist.f → build/input.tcl
# ---------------------------------------------------------------------------
gen_filelist:
	@mkdir -p $(BUILD_DIR)
	python3 $(PROJ_ROOT)/scripts/gen_filelist.py \
		$(SYN_ROOT)/filelist.f \
		$(PROJ_ROOT) \
		--var SOC_CONFIG=$(SOC_CONFIG) \
		--format dc \
		-o $(BUILD_DIR)/input.tcl

# ---------------------------------------------------------------------------
# flat: flat synthesis
#   INCR_CHECKPOINT=NONE               → full compile from RTL (default)
#   INCR_CHECKPOINT=post_constraints   → resume: compile_ultra -incremental + report
#   INCR_CHECKPOINT=post_compile       → resume: re-run reports only
# ---------------------------------------------------------------------------
flat: gen_filelist
	@mkdir -p $(BUILD_DIR)/WORK
	@if [ "$(INCR_CHECKPOINT)" != "NONE" ]; then \
		if ! ls "$(BUILD_DIR)/outputs/"*_$(INCR_CHECKPOINT).ddc 2>/dev/null | grep -q .; then \
			echo "ERROR: No checkpoint DDC for '$(INCR_CHECKPOINT)' in $(BUILD_DIR)/outputs/."; \
			echo "       Run 'make flat' first (without INCR_CHECKPOINT)."; \
			exit 1; \
		fi; \
	fi
	$(DC_SHELL) \
		-x "set PDK_ROOT $(PDK_ROOT); \
		    set SYN_ROOT $(SYN_ROOT); \
		    set BUILD_DIR $(BUILD_DIR); \
		    set SYN_MODE flat; \
		    set INCR_CHECKPOINT $(INCR_CHECKPOINT); \
		    set HIER_COMPILE_BLOCKS {}" \
		-f $(SYN_ROOT)/scripts/synth.tcl \
		2>&1 | tee $(BUILD_DIR)/flat_$(INCR_CHECKPOINT).log
	@echo "===== Flat synthesis done (INCR_CHECKPOINT=$(INCR_CHECKPOINT)). See build/ ====="

flat_verbose: gen_filelist
	@mkdir -p $(BUILD_DIR)/WORK
	@if [ "$(INCR_CHECKPOINT)" != "NONE" ]; then \
		if ! ls "$(BUILD_DIR)/outputs/"*_$(INCR_CHECKPOINT).ddc 2>/dev/null | grep -q .; then \
			echo "ERROR: No checkpoint DDC for '$(INCR_CHECKPOINT)' in $(BUILD_DIR)/outputs/."; \
			echo "       Run 'make flat' first (without INCR_CHECKPOINT)."; \
			exit 1; \
		fi; \
	fi
	$(DC_SHELL) \
		-x "set PDK_ROOT $(PDK_ROOT); \
		    set SYN_ROOT $(SYN_ROOT); \
		    set BUILD_DIR $(BUILD_DIR); \
		    set SYN_MODE flat; \
		    set INCR_CHECKPOINT $(INCR_CHECKPOINT); \
		    set HIER_COMPILE_BLOCKS {}; \
		    set message_level info; \
		    set verbose true ; \
			set optimize_report_level high" \
		-f $(SYN_ROOT)/scripts/synth.tcl \
		2>&1 | tee $(BUILD_DIR)/flat_verbose_$(INCR_CHECKPOINT).log
	@echo "===== Flat verbose synthesis done (INCR_CHECKPOINT=$(INCR_CHECKPOINT)). See build/ ====="


# ---------------------------------------------------------------------------
# hier: hierarchical block-level synthesis
#   BLOCK=<paths>                      → recompile specified blocks + assemble top
#   BLOCK= (empty)                     → assemble top from cached block DDCs only
#   INCR_CHECKPOINT=NONE               → full elaborate from RTL (default)
#   INCR_CHECKPOINT=post_constraints   → resume: compile + report
#   INCR_CHECKPOINT=post_compile       → resume: re-run reports only
# ---------------------------------------------------------------------------
hier: gen_filelist
	@mkdir -p $(BUILD_DIR)/WORK $(BUILD_DIR)/blocks
	@if [ "$(INCR_CHECKPOINT)" != "NONE" ]; then \
		if ! ls "$(BUILD_DIR)/outputs/"*_$(INCR_CHECKPOINT).ddc 2>/dev/null | grep -q .; then \
			echo "ERROR: No checkpoint DDC for '$(INCR_CHECKPOINT)' in $(BUILD_DIR)/outputs/."; \
			echo "       Run 'make hier' first (without INCR_CHECKPOINT)."; \
			exit 1; \
		fi; \
	fi
	$(DC_SHELL) \
		-x "set PDK_ROOT $(PDK_ROOT); \
		    set SYN_ROOT $(SYN_ROOT); \
		    set BUILD_DIR $(BUILD_DIR); \
		    set SYN_MODE hier; \
		    set INCR_CHECKPOINT $(INCR_CHECKPOINT); \
		    set HIER_COMPILE_BLOCKS {$(BLOCK)}" \
		-f $(SYN_ROOT)/scripts/synth.tcl \
		2>&1 | tee $(BUILD_DIR)/hier_$(INCR_CHECKPOINT).log
	@echo "===== Hierarchical synthesis done (INCR_CHECKPOINT=$(INCR_CHECKPOINT)). See build/ ====="

# ---------------------------------------------------------------------------
# check: verify all source files in filelist.f exist
# ---------------------------------------------------------------------------
check:
	@echo "--- Filelist integrity check ---"
	@python3 $(PROJ_ROOT)/scripts/gen_filelist.py \
		$(SYN_ROOT)/filelist.f $(PROJ_ROOT) \
		--format dc -o /dev/null && \
		echo "gen_filelist.py parse OK"
	@count=0; err=0; \
	while IFS= read -r f; do \
		if [ ! -f "$$f" ]; then echo "MISSING: $$f"; err=1; fi; \
		count=$$((count+1)); \
	done < <(python3 $(PROJ_ROOT)/scripts/gen_filelist.py \
		$(SYN_ROOT)/filelist.f $(PROJ_ROOT) --format dc -o /dev/null --check 2>/dev/null); \
	echo "Total source files checked: $$count"; \
	if [ "$$err" -eq 0 ]; then echo "All files exist."; else echo "Some files are MISSING!"; exit 1; fi

# ---------------------------------------------------------------------------
# clean
# ---------------------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR)
	rm -f *.svf *.pvl *.syn *.mr *.log command.log default.svf
	rm -rf alib-52

# ---------------------------------------------------------------------------
# help
# ---------------------------------------------------------------------------
help:
	@echo "Ara SoC DC NXT Synthesis"
	@echo ""
	@echo "Targets:"
	@echo "  make flat                       Flat synthesis from RTL"
	@echo "  make hier                       Hierarchical block-level synthesis"
	@echo "  make gen_filelist               Parse filelist.f → build/input.tcl"
	@echo "  make check                      Verify filelist integrity"
	@echo "  make clean                      Remove build/"
	@echo ""
	@echo "Variables:"
	@echo "  PDK_ROOT=<path>                 PDK root (default: \$$HOME/workspace/tsmc22)"
	@echo "  INCR_CHECKPOINT=<phase>         Checkpoint to resume from (both modes):"
	@echo "                                    post_constraints, post_compile"
	@echo "  BLOCK=<hier_path>               Block(s) to recompile (hier only):"
	@echo "                                    i_ara_system"
	@echo "                                    i_ariane_peripherals"
	@echo "                                    i_dm_top"
	@echo "                                    i_axi_xbar"
	@echo "                                    i_ariane_peripherals/i_default_slave"
	@echo ""
	@echo "Examples:"
	@echo "  make flat                                         Full flat from RTL"
	@echo "  make flat INCR_CHECKPOINT=post_constraints        Flat: resume from constraints"
	@echo "  make flat INCR_CHECKPOINT=post_compile            Flat: re-run reports only"
	@echo "  make hier BLOCK=i_ara_system                      Hier: recompile one block"
	@echo "  make hier BLOCK=\"i_ara_system i_dm_top\"           Hier: recompile multiple"
	@echo "  make hier                                         Hier: assemble-only"
	@echo "  make hier INCR_CHECKPOINT=post_constraints        Hier: resume from constraints"
