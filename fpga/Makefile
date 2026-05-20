# Vivado FPGA build flow for ariane_soc_top on AXU15EG

PROJECT  := ariane_soc_top
PART     := xczu15eg-ffvb1156-2-i
TOP      := ariane_soc_top_wrapper
ROOT     := $(realpath ..)
BUILD    := build
REPORTS  := $(BUILD)/reports
JOBS     ?= 32
export JOBS

all: $(BUILD)/$(PROJECT).bit

# Step 0: Generate sources.tcl from filelist.f
$(BUILD)/sources.tcl: filelist.f scripts/gen_vivado_filelist.py
	@mkdir -p $(BUILD) $(REPORTS)
	python3 scripts/gen_vivado_filelist.py filelist.f $(ROOT) -o $(BUILD)/sources.tcl

# Step 1: Create Vivado project
$(BUILD)/$(PROJECT).xpr: flow/01-create_project.tcl $(BUILD)/sources.tcl
	@mkdir -p $(REPORTS)
	cd $(BUILD) && vivado -mode batch -source ../flow/01-create_project.tcl 2>&1 | tee ../$(REPORTS)/01-create_project.log

# Step 2-4: Synthesis → Implementation + Bitstream → Netlist 
$(BUILD)/$(PROJECT).bit: $(BUILD)/$(PROJECT).xpr flow/02-synth.tcl flow/03-run.tcl flow/04-netlist.tcl
	@mkdir -p $(REPORTS)
	cd $(BUILD) && vivado -mode batch -source ../flow/02-synth.tcl    $(PROJECT).xpr 2>&1 | tee ../$(REPORTS)/02-synth.log
	cd $(BUILD) && vivado -mode batch -source ../flow/03-run.tcl      $(PROJECT).xpr 2>&1 | tee ../$(REPORTS)/03-bit.log
	cd $(BUILD) && vivado -mode batch -source ../flow/04-netlist.tcl  $(PROJECT).xpr 2>&1 | tee ../$(REPORTS)/04-netlist.log

# Open project in GUI
gui: $(BUILD)/$(PROJECT).xpr
	cd $(BUILD) && vivado $(PROJECT).xpr

# Step 5: Program FPGA
pgm: flow/05-pgm.tcl $(BUILD)/$(PROJECT).bit
	@mkdir -p $(REPORTS)
	cd $(BUILD) && vivado -quiet -nolog -mode batch -source ../flow/05-pgm.tcl -tclargs $(PART) $(PROJECT).bit 2>&1 | tee ../$(REPORTS)/05-pgm.log

clean:
	rm -rf $(BUILD)

.PHONY: all gui pgm clean
