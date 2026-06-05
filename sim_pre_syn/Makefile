# MXU/AXU local gate netlist mixed simulation (VCS)
#
# This directory is for pre-backend hierarchical validation:
#   - SoC/testbench remain RTL
#   - mxu_top and axu_top are replaced by synthesized gate netlists in ./netlist
#
# Common targets:
#   make compile                  # compile mixed RTL/gate simulation
#   make run APP=<name>           # compile + run
#   make run app=<name>           # compatible lowercase app variable
#   make vcs / make vcs-run       # aliases for sim/Makefile habits
#   make verdi                    # open Verdi waveform database
#   make clean                    # remove local build artifacts


#  -n 是dry run，纸打印将要执行的命令，但不真正执行
#  -C 是cd的意思，先进入到指定的文件夹，然后执行
#
#
#

SHELL    := /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export ROOT := $(abspath $(ROOT_DIR)/..)

FILELIST ?= filelist_mxu_axu_netlist.f
TB_DIR   := ../tb
DPI_DIR  := $(TB_DIR)/dpi
DPI_SRCS := $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) \
            $(wildcard $(DPI_DIR)/*.c)

APP ?= ../software/build/bin/my_axu_test
app ?= $(APP)

PDK_ROOT ?= $(HOME)/workspace/work2026_2/work_for_tapeout_2026_v2/tsmc22
export PDK_ROOT

FESVR_ROOT := $(HOME)/tools/riscv

VCS_HOME   ?= /home/EDAtools/synopsys/vcs/V-2023.12-SP1
VERDI_HOME ?= /home/EDAtools/synopsys/verdi/V-2023.12-SP1
VCS        := $(VCS_HOME)/bin/vcs
VERDI      := $(VERDI_HOME)/bin/verdi

GCC_HOME := /data/home/rh_xu30/Work/ara_soc_vpu/tools/gcc-install
CXX      := $(GCC_HOME)/bin/g++
CC       := $(GCC_HOME)/bin/gcc

VCS_BUILD := $(ROOT_DIR)/build/vcs-mxu-axu-netlist
VCS_TOP   := ariane_soc_tb
VCS_BIN   := $(VCS_BUILD)/simv

VCS_FLAGS := \
  -full64 -sverilog \
  -timescale=1ns/1ps \
  -v2k_generate \
  -debug_access+all -kdb \
  -DVCS \
  +vcs+lic+wait \
  +warn=noTFIPC \
  +warn=noTFIPC-L \
  +warn=noUII-L \
  -error=noUCTLAB \
  +notimingchecks \
  -f $(FILELIST) \
  -top $(VCS_TOP) \
  -CFLAGS "-std=c++17 -I$(DPI_DIR) -I$(FESVR_ROOT)/include" \
  -LDFLAGS "-L$(FESVR_ROOT)/lib -lfesvr -lutil -Wl,-rpath,$(GCC_HOME)/lib64 -Wl,-rpath,$(FESVR_ROOT)/lib" \
  $(DPI_SRCS) \
  -Mdir=$(VCS_BUILD)/csrc \
  -o $(VCS_BIN) \
  -cc $(GCC_HOME)/bin/gcc \
  -cpp $(GCC_HOME)/bin/g++

VCS_RUN_FLAGS := \
  +vcs+lic+wait \
  +PRELOAD=$(app) \
  +notimingchecks

VCS_WAVE_FLAGS := $(VCS_RUN_FLAGS) \
  +fsdbfile+waveform.fsdb \
  -ucli -do "fsdbDumpvars 0 $(VCS_TOP); run; exit;"

.PHONY: all compile run vcs vcs-run vcs-wave verdi clean

all: compile

compile: $(VCS_BIN)

vcs: compile

$(VCS_BIN): $(FILELIST) filelist_mxu_netlist_only.f filelist_axu_netlist_only.f filelist_sram_buffer_no_rf2p.f netlist_wrapper/mxu_top_netlist_shim.sv netlist_wrapper/axu_top_netlist_shim.sv netlist/mxu_top_netlist.v netlist/axu_top_netlist.v
	@if [ ! -f "$(ROOT_DIR)/netlist/mxu_top_netlist.v" ]; then \
		echo "ERROR: MXU gate netlist not found: $(ROOT_DIR)/netlist/mxu_top_netlist.v"; \
		exit 1; \
	fi
	@if [ ! -f "$(ROOT_DIR)/netlist/axu_top_netlist.v" ]; then \
		echo "ERROR: AXU gate netlist not found: $(ROOT_DIR)/netlist/axu_top_netlist.v"; \
		exit 1; \
	fi
	mkdir -p $(VCS_BUILD)/csrc
	cd $(ROOT_DIR) && $(VCS) $(VCS_FLAGS)

run: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_RUN_FLAGS)

vcs-run: run

vcs-wave: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_WAVE_FLAGS)

verdi:
	cd $(ROOT_DIR) && $(VERDI) -dbdir $(VCS_BUILD)/simv.daidir \
	  -ssf waveform.fsdb

clean:
	rm -rf $(VCS_BUILD) *.fsdb *.fst *.vcd ucli.key novas.* verdiLog
