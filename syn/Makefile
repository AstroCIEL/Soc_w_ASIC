###############################################################################
# Ariane SoC Synthesis Makefile
###############################################################################

SHELL      := /bin/bash
DC_SHELL   := dcnxt_shell -64 -topographical_mode
SYN_ROOT   := $(shell pwd)
PROJ_ROOT  := $(shell cd .. && pwd)
BUILD_DIR  := $(SYN_ROOT)/build

PDK_ROOT   ?= $(HOME)/workspace/work2026_2/work_for_tapeout_2026_v2/tsmc22
export PDK_ROOT

# SoC RTL configuration: selects hardware/soc/filelist_<SOC_CONFIG>.f via syn/filelist.f
SOC_CONFIG ?= minimum_my_mxu_axu
SOC_FILELIST := $(PROJ_ROOT)/hardware/soc/filelist_$(SOC_CONFIG).f
export SOC_CONFIG

GEN_FILELIST := python3 $(PROJ_ROOT)/scripts/gen_filelist.py \
	$(SYN_ROOT)/filelist.f $(PROJ_ROOT) --format dc \
	--var SOC_CONFIG=$(SOC_CONFIG)

# Checkpoint to resume from (for syn_incr); valid: post_elab post_constraints post_compile final
INCR_CHECKPOINT ?= post_constraints

.PHONY: all syn syn_incr gen_filelist check clean help

all: syn

# ---------------------------------------------------------------------------
# gen_filelist: parse filelist.f → build/input.tcl
# ---------------------------------------------------------------------------
gen_filelist:
	@if [ ! -f "$(SOC_FILELIST)" ]; then \
		echo "ERROR: SOC_CONFIG='$(SOC_CONFIG)' -> missing $(SOC_FILELIST)"; \
		echo "       Available:"; \
		ls -1 $(PROJ_ROOT)/hardware/soc/filelist_*.f 2>/dev/null \
			| sed 's|.*/filelist_||;s|\.f$$||' | sed 's/^/         /'; \
		exit 1; \
	fi
	@mkdir -p $(BUILD_DIR)
	$(GEN_FILELIST) -o $(BUILD_DIR)/input.tcl

# ---------------------------------------------------------------------------
# syn: full synthesis from RTL
# ---------------------------------------------------------------------------
syn: gen_filelist
	@mkdir -p $(BUILD_DIR)/WORK
	$(DC_SHELL) \
		-x "set PDK_ROOT $(PDK_ROOT); \
		    set SYN_ROOT $(SYN_ROOT); \
		    set BUILD_DIR $(BUILD_DIR); \
		    set INCR_MODE 0; \
		    set INCR_CHECKPOINT post_constraints" \
		-f $(SYN_ROOT)/scripts/synth.tcl \
		2>&1 | tee $(BUILD_DIR)/syn.log
	@echo "===== Synthesis done (SOC_CONFIG=$(SOC_CONFIG)). See build/ ====="

# ---------------------------------------------------------------------------
# syn_incr: incremental re-run from a saved checkpoint DDC
# ---------------------------------------------------------------------------
syn_incr:
	@mkdir -p $(BUILD_DIR)/WORK
	@if ls "$(BUILD_DIR)/outputs/"*_$(INCR_CHECKPOINT).ddc 2>/dev/null | grep -q .; then \
		true; \
	else \
		echo "ERROR: No checkpoint DDC for '$(INCR_CHECKPOINT)' in $(BUILD_DIR)/outputs/."; \
		echo "       Run 'make syn' first, or choose a valid INCR_CHECKPOINT."; \
		exit 1; fi
	$(DC_SHELL) \
		-x "set PDK_ROOT $(PDK_ROOT); \
		    set SYN_ROOT $(SYN_ROOT); \
		    set BUILD_DIR $(BUILD_DIR); \
		    set INCR_MODE 1; \
		    set INCR_CHECKPOINT $(INCR_CHECKPOINT)" \
		-f $(SYN_ROOT)/scripts/synth.tcl \
		2>&1 | tee $(BUILD_DIR)/syn_incr_$(INCR_CHECKPOINT).log
	@echo "===== Incremental synthesis done (SOC_CONFIG=$(SOC_CONFIG), from $(INCR_CHECKPOINT)). See build/ ====="

# ---------------------------------------------------------------------------
# check: verify all source files in filelist.f exist
# ---------------------------------------------------------------------------
check:
	@echo "--- Filelist integrity check (SOC_CONFIG=$(SOC_CONFIG)) ---"
	@if [ ! -f "$(SOC_FILELIST)" ]; then \
		echo "ERROR: SOC_CONFIG='$(SOC_CONFIG)' -> missing $(SOC_FILELIST)"; \
		exit 1; \
	fi
	@$(GEN_FILELIST) -o /dev/null && echo "gen_filelist.py parse OK"
	@count=0; err=0; \
	while IFS= read -r f; do \
		if [ ! -f "$$f" ]; then echo "MISSING: $$f"; err=1; fi; \
		count=$$((count+1)); \
	done < <($(GEN_FILELIST) -o /dev/null --check 2>/dev/null); \
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
	@echo "  make gen_filelist               Parse filelist.f → build/input.tcl"
	@echo "  make syn                        Full synthesis from RTL"
	@echo "  make syn_incr                   Incremental (default: post_constraints)"
	@echo "  make check                      Verify filelist integrity"
	@echo "  make clean                      Remove build/"
	@echo ""
	@echo "Variables:"
	@echo "  SOC_CONFIG=<name>               SoC filelist (default: maximum)"
	@echo "                                    uses hardware/soc/filelist_<name>.f"
	@echo "  PDK_ROOT=<path>                 PDK root (default: \$$HOME/workspace/tsmc22)"
	@echo "  INCR_CHECKPOINT=<phase>         Checkpoint to resume from:"
	@echo "                                    post_elab        (re-apply constraints + compile)"
	@echo "                                    post_constraints (compile -incremental)  [default]"
	@echo "                                    post_compile     (reports only)"
	@echo "                                    final            (outputs + reports only)"
	@echo ""
	@echo "Examples:"
	@echo "  make syn SOC_CONFIG=minimum_my_mxu"
	@echo "  make check SOC_CONFIG=minimum"
	@echo "  make syn PDK_ROOT=/path/to/pdk SOC_CONFIG=maximum"
	@echo "  make syn_incr INCR_CHECKPOINT=post_elab SOC_CONFIG=minimum_my_mxu"
