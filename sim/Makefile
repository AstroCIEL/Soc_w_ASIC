# ariane_tb – Simulation Makefile (VCS + Verilator)
#
# VCS:
#   make vcs                      # compile
#   make vcs-run app=<name>       # compile + run
#   make vcs-wave app=<name>      # compile + run with FSDB waveform
#   make verdi                    # open Verdi waveform
#
# Verilator:
#   make verilate                 # elaborate + compile C++
#   make verilator-run app=<name> # run simulation
#   make verilator-wave app=<name># run simulation with FST waveform
#
#   make clean                    # remove all build artifacts

SHELL    := /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ── Shared paths ──────────────────────────────────────────────────────────────
FILELIST        := filelist.f
VERIL_FILELIST  := filelist_verilator.f
TB_DIR   := ../tb
DPI_DIR  := $(TB_DIR)/dpi
# Exclude SimDTM.cc (requires fesvr library which may not be available)
# elfloader.cc now uses system elf.h instead of fesvr
DPI_SRCS := $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) \
            $(wildcard $(DPI_DIR)/*.c)


app      ?= ../software/build/bin/hello_world

FESVR_ROOT  := ../install/riscv-llvm

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  VCS                                                                      ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
# Synopsys VCS/Verdi installation paths
VCS_HOME   := /home/EDAtools/synopsys/vcs/V-2023.12-SP1
VERDI_HOME := /home/EDAtools/synopsys/verdi/V-2023.12-SP1

VCS   := $(VCS_HOME)/bin/vcs
VERDI := $(VERDI_HOME)/bin/verdi

# GCC 11 for C++17 support (required for DPI compilation)
GCC_HOME := /data/home/rh_xu30/Work/ara_soc_vpu/tools/gcc-install
CXX      := $(GCC_HOME)/bin/g++
CC       := $(GCC_HOME)/bin/gcc

VCS_BUILD := $(ROOT_DIR)/build/vcs
VCS_TOP   := ara_tb
VCS_BIN   := $(VCS_BUILD)/simv


VCS_FLAGS := \
  -full64 -sverilog \
  -timescale=1ns/1ps \
  -debug_access+all -kdb \
  -DVCS \
  +vcs+lic+wait \
  +lint=TFIPC-L \
  +warn=noUII-L \
  -error=noUCTLAB \
  -f $(FILELIST) \
  -top $(VCS_TOP) \
  -CFLAGS "-std=c++17 -I$(DPI_DIR)" \
  -LDFLAGS "-lutil -Wl,-rpath,$(GCC_HOME)/lib64" \
  $(DPI_SRCS) \
  -Mdir=$(VCS_BUILD)/csrc \
  -o $(VCS_BIN) \
  -cc $(GCC_HOME)/bin/gcc \
  -cpp $(GCC_HOME)/bin/g++

VCS_RUN_FLAGS := \
  +vcs+lic+wait \
  +PRELOAD=$(app)

VCS_WAVE_FLAGS := $(VCS_RUN_FLAGS) \
  +fsdbfile+waveform.fsdb \
  -ucli -do "fsdbDumpvars 0 $(VCS_TOP); run; exit;"

.PHONY: all vcs vcs-run vcs-wave verdi verilate verilator-run verilator-wave clean

all: vcs

vcs: $(VCS_BIN)

$(VCS_BIN): $(FILELIST)
	mkdir -p $(VCS_BUILD)/csrc
	cd $(ROOT_DIR) && $(VCS) $(VCS_FLAGS)

vcs-run: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_RUN_FLAGS)

vcs-wave: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_WAVE_FLAGS)

verdi:
	cd $(ROOT_DIR) && $(VERDI) -dbdir $(VCS_BUILD)/simv.daidir \
	  -ssf waveform.fsdb

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Verilator                                                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VERILATOR  := verilator
OBJCACHE   := $(shell which ccache 2>/dev/null)

VERIL_BUILD := $(ROOT_DIR)/build/verilator
VERIL_TOP   := ara_tb_verilator

# ── Verilator C++ sources ──────────────────────────────────────────────────
TB_CPP_DIR  := $(TB_DIR)/verilator
TB_CPP_MAIN := $(TB_CPP_DIR)/ara_tb.cpp
TB_CPP_SRCS := \
  $(wildcard $(TB_CPP_DIR)/lowrisc_dv_verilator_memutil_dpi/cpp/*.cc) \
  $(wildcard $(TB_CPP_DIR)/lowrisc_dv_verilator_memutil_verilator/cpp/*.cc)

# DPI C/C++ sources (reuse DPI_DIR; exclude SimDTM.cc like VCS)
VERIL_DPI_SRCS := $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) \
                  $(wildcard $(DPI_DIR)/*.c)

VERIL_BIN := $(VERIL_BUILD)/V$(VERIL_TOP)

VERIL_FLAGS := \
  --cc --exe \
  --no-timing \
  --timescale 1ns/1ps \
  --top-module $(VERIL_TOP) \
  --trace-fst \
  -f $(VERIL_FILELIST) \
  +define+VERILATOR \
  --Mdir $(VERIL_BUILD) \
  -Wno-ENUMVALUE \
  -Wno-WIDTHEXPAND \
  -Wno-WIDTHTRUNC \
  -Wno-COMBDLY \
  -CFLAGS "-std=c++17 -I$(DPI_DIR) -I$(TB_CPP_DIR)" \
  -LDFLAGS "-lutil -L$(GCC_HOME)/lib64 -Wl,-rpath,$(GCC_HOME)/lib64" \
  $(if $(OBJCACHE),--objcache $(OBJCACHE),) \
  $(VERIL_DPI_SRCS) \
  $(TB_CPP_MAIN) $(TB_CPP_SRCS)

VERIL_RUN_FLAGS  := +PRELOAD=$(app)
VERIL_WAVE_FLAGS := $(VERIL_RUN_FLAGS) +trace+waveform.fst

verilate: $(VERIL_BIN)

$(VERIL_BIN): $(VERIL_FILELIST)
	mkdir -p $(VERIL_BUILD)
	cd $(ROOT_DIR) && $(VERILATOR) $(VERIL_FLAGS)
	$(MAKE) -j 24 -C $(VERIL_BUILD) -f V$(VERIL_TOP).mk \
	  OPT_FAST="-O0" OPT_SLOW="-O0" OPT_DBG="-O0" \
	  CXX="$(CXX)" CC="$(CC)"

verilator-run: $(VERIL_BIN)
	cd $(ROOT_DIR) && $(VERIL_BIN) $(VERIL_RUN_FLAGS)

verilator-wave: $(VERIL_BIN)
	cd $(ROOT_DIR) && $(VERIL_BIN) $(VERIL_WAVE_FLAGS)

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Clean                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
clean:
	rm -rf $(VCS_BUILD) $(VERIL_BUILD) *.fsdb *.fst *.vcd ucli.key novas.*
