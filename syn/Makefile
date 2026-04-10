###############################################################################
# Ara SoC Synthesis Makefile
###############################################################################

DC_SHELL   := dc_shell
TOP_MODULE := ara_soc
NR_LANES   := 4
VLEN       := 4096
SCRIPT_DIR := $(shell pwd)
PROJ_ROOT  := $(shell cd .. && pwd)
REPORT_DIR := $(SCRIPT_DIR)/reports
OUTPUT_DIR := $(SCRIPT_DIR)/outputs

.PHONY: syn check clean help

syn:
	@mkdir -p WORK reports outputs
	$(DC_SHELL) \
		-x "set PROJ_ROOT $(PROJ_ROOT); \
		    set SCRIPT_DIR $(SCRIPT_DIR); \
		    set TOP_MODULE $(TOP_MODULE); \
		    set NR_LANES $(NR_LANES); \
		    set VLEN $(VLEN); \
		    set REPORT_DIR $(REPORT_DIR); \
		    set OUTPUT_DIR $(OUTPUT_DIR)" \
		-f dc_script.tcl \
		2>&1 | tee syn.log
	@echo "===== Synthesis done. Check reports/ and outputs/ ====="

check:
	@echo "--- Filelist check (recursive) ---"
	@count=0; \
	while IFS= read -r f; do \
		if [ ! -f "$$f" ]; then echo "MISSING: $$f"; err=1; fi; \
		count=$$((count+1)); \
	done < <(cd $(SCRIPT_DIR) && python3 -c " \
import os, sys \
def parse(fpath, base): \
    d = os.path.dirname(os.path.abspath(fpath)) \
    for line in open(fpath): \
        line = line.strip() \
        if not line or line.startswith('//'): continue \
        if line.startswith('-f '): \
            parse(os.path.normpath(os.path.join(d, line[3:].strip())), base) \
        elif line.startswith('+'): continue \
        else: print(os.path.normpath(os.path.join(d, line))) \
parse('filelist.f', '.') \
	"); \
	echo "Total source files: $$count"; \
	if [ "$${err:-0}" -eq 0 ]; then echo "All files exist."; else echo "Some files are MISSING!"; exit 1; fi

clean:
	rm -rf WORK reports outputs
	rm -f syn.log *.svf *.pvl *.syn *.mr *.log command.log default.svf
	rm -rf alib-52

help:
	@echo "Ara SoC Synthesis Flow"
	@echo "  make syn                      - Run DC synthesis"
	@echo "  make check                    - Verify filelist integrity"
	@echo "  make clean                    - Remove all generated files"
	@echo ""
	@echo "Customization:"
	@echo "  make syn TOP_MODULE=xxx       - Override top module"
	@echo "  make syn NR_LANES=2 VLEN=512  - Override design parameters"
	@echo "  make syn DC_SHELL=dc_shell-t  - Use topographical mode"
