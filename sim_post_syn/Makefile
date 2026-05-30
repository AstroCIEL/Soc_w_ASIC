# ariane_tb – Simulation Makefile (VCS + Verilator)
#
# RTL simulation:
#   make compile                   # VCS compile (RTL)
#   make run APP=<name>            # compile + run
#   make run app=<name>            # also supported for compatibility
#   make verdi                     # open Verdi waveform
#
# Gate-level (post-synthesis) simulation:
#   make compile-gate              # VCS compile (gate netlist + SDF)
#   make run-gate APP=<name>       # compile + run gate-level
#   make run-gate app=<name>       # also supported for compatibility
#   make verdi-gate                # open Verdi waveform (gate)
#
# Verilator (legacy):
#   make verilate                  # elaborate + compile C++
#   make verilator-run APP=<name>  # run simulation
#   make verilator-wave APP=<name> # run simulation with FST waveform
#
#   make clean                     # remove all build artifacts

SHELL    := /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export ROOT := $(abspath $(ROOT_DIR)/..)

# ── Shared paths ──────────────────────────────────────────────────────────────
TB_DIR   := ../tb
DPI_DIR  := $(TB_DIR)/dpi
DPI_SRCS := $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) \
            $(wildcard $(DPI_DIR)/*.c)

APP      ?= ../software/build/bin/hello_world
app      ?= $(APP)


PDK_ROOT    ?= $(HOME)/workspace/work2026_2/work_for_tapeout_2026_v2/tsmc22
export PDK_ROOT

FESVR_ROOT  := $(HOME)/tools/riscv

# GCC 11 for C++17 support (required for DPI compilation)
GCC_HOME := /data/home/rh_xu30/Work/ara_soc_vpu/tools/gcc-install
CXX      := $(GCC_HOME)/bin/g++
CC       := $(GCC_HOME)/bin/gcc


# Synthesis build directory (for gate-level netlist + SDF)
SYN_BUILD   ?= $(ROOT)/syn/build
export SYN_BUILD

# SDF annotation (set USE_SDF=1 to enable back-annotated timing)
USE_SDF      ?= 1
SDF_SCENARIO ?= func_tt_25c

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  VCS – Common flags                                                        ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VCS   := vcs
VERDI := verdi
VCS_TOP := ariane_soc_tb

VCS_COMMON_FLAGS := \
  -full64 -sverilog \
  -timescale=1ns/1ps \
  -debug_access+all -kdb \
  -DVCS \
  +vcs+lic+wait \
  +lint=TFIPC-L \
  +warn=noUII-L \
  -error=noUCTLAB \
  -top $(VCS_TOP) \
  -CFLAGS "-std=c++17 -I$(DPI_DIR) -I$(FESVR_ROOT)/include" \
  -LDFLAGS "-L$(FESVR_ROOT)/lib -lfesvr -lutil -Wl,-rpath,$(GCC_HOME)/lib64 -Wl,-rpath,$(FESVR_ROOT)/lib" \
  $(DPI_SRCS) 
  # -Mdir=$(VCS_BUILD)/csrc 
  # -o $(VCS_BIN) 
  # -cc $(GCC_HOME)/bin/gcc 
  # -cpp $(GCC_HOME)/bin/g++

VCS_RUN_FLAGS := \
  +vcs+lic+wait \
  +PRELOAD=$(app)

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  VCS – RTL simulation                                                     ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VCS_BUILD := $(ROOT_DIR)/build/vcs
VCS_BIN   := $(VCS_BUILD)/simv

VCS_RTL_FLAGS := $(VCS_COMMON_FLAGS) \
  +notimingchecks \
  -f filelist.f \
  -Mdir=$(VCS_BUILD)/csrc \
  -o $(VCS_BIN) \
  -cc $(GCC_HOME)/bin/gcc \
  -cpp $(GCC_HOME)/bin/g++

.PHONY: all compile run verdi compile-gate run-gate verdi-gate \
        verilate verilator-run verilator-wave clean

all: compile

compile: $(VCS_BIN)

$(VCS_BIN): filelist.f
	mkdir -p $(VCS_BUILD)/csrc
	cd $(ROOT_DIR) && $(VCS) $(VCS_RTL_FLAGS)

run: $(VCS_BIN)
	cd $(ROOT_DIR) && $(VCS_BIN) $(VCS_RUN_FLAGS)

verdi:
	cd $(ROOT_DIR) && $(VERDI) -dbdir $(VCS_BUILD)/simv.daidir \
	  -ssf waveform.fsdb

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  VCS – Gate-level (post-synthesis) simulation                              ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
GATE_BUILD := $(ROOT_DIR)/build/vcs-gate
GATE_BIN   := $(GATE_BUILD)/simv
GATE_SDF   := $(SYN_BUILD)/outputs/scenarios/$(SDF_SCENARIO)/ariane_soc_top.sdf

ifeq ($(USE_SDF),1)
  GATE_SDF_FLAGS := +neg_tchk -negdelay -sdf max:$(VCS_TOP).dut:$(GATE_SDF)
else
  GATE_SDF_FLAGS := +notimingchecks
endif

GATE_VCS_FLAGS := $(VCS_COMMON_FLAGS) \
  $(GATE_SDF_FLAGS) \
  -f filelist_gatesim.f \
  -Mdir=$(GATE_BUILD)/csrc \
  -o $(GATE_BIN) \
  -cc $(GCC_HOME)/bin/gcc \
  -cpp $(GCC_HOME)/bin/g++

compile-gate: $(GATE_BIN)

$(GATE_BIN): filelist_gatesim.f
	@if [ ! -f "$(SYN_BUILD)/outputs/ariane_soc_top_netlist.v" ]; then \
		echo "ERROR: Gate netlist not found: $(SYN_BUILD)/outputs/ariane_soc_top_netlist.v"; \
		echo "       Run 'make flat' or 'make hier' in syn/ first."; \
		exit 1; \
	fi
	@if [ ! -f "$(GATE_SDF)" ]; then \
		echo "WARNING: SDF not found: $(GATE_SDF)"; \
		echo "         Gate sim will run without timing annotation."; \
	fi
	mkdir -p $(GATE_BUILD)/csrc
	cd $(ROOT_DIR) && $(VCS) $(GATE_VCS_FLAGS)

run-gate: $(GATE_BIN)
	cd $(ROOT_DIR) && $(GATE_BIN) $(VCS_RUN_FLAGS)

verdi-gate:
	cd $(ROOT_DIR) && $(VERDI) -dbdir $(GATE_BUILD)/simv.daidir \
	  -ssf waveform.fsdb

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Verilator                                                                ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
VERILATOR  := verilator
OBJCACHE   := $(shell which ccache 2>/dev/null)

VERIL_BUILD := $(ROOT_DIR)/build/verilator
VERIL_TOP   := ariane_soc_tb_verilator

# ── Verilator C++ sources ──────────────────────────────────────────────────
TB_CPP_DIR  := $(TB_DIR)/verilator
TB_CPP_MAIN := $(TB_CPP_DIR)/ariane_soc_tb.cpp
TB_CPP_SRCS := \
  $(wildcard $(TB_CPP_DIR)/lowrisc_dv_verilator_memutil_dpi/cpp/*.cc) \
  $(wildcard $(TB_CPP_DIR)/lowrisc_dv_verilator_memutil_verilator/cpp/*.cc)

# DPI C/C++ sources (reuse DPI_DIR; exclude SimDTM like VCS)
VERIL_DPI_SRCS := $(filter-out $(DPI_DIR)/SimDTM.cc, $(wildcard $(DPI_DIR)/*.cc)) \
                  $(wildcard $(DPI_DIR)/*.c)

VERIL_BIN := $(VERIL_BUILD)/V$(VERIL_TOP)

VERIL_FLAGS := \
  --cc --exe \
  --no-timing \
  --timescale 1ns/1ps \
  --top-module $(VERIL_TOP) \
  --trace-fst \
  -f filelist_verilator.f \
  +define+VERILATOR \
  --Mdir $(VERIL_BUILD) \
  -Wno-ENUMVALUE \
  -Wno-WIDTHEXPAND \
  -Wno-WIDTHTRUNC \
  -Wno-COMBDLY \
  -CFLAGS "-std=c++17 -I$(DPI_DIR) -I$(TB_CPP_DIR) -I$(FESVR_ROOT)/include" \
  -LDFLAGS "-L$(FESVR_ROOT)/lib -lfesvr -lelf -lutil" \
  $(if $(OBJCACHE),--objcache $(OBJCACHE),) \
  $(VERIL_DPI_SRCS) \
  $(TB_CPP_MAIN) $(TB_CPP_SRCS)

VERIL_RUN_FLAGS  := +PRELOAD=$(app)
VERIL_WAVE_FLAGS := $(VERIL_RUN_FLAGS) +trace+waveform.fst

verilate: $(VERIL_BIN)

$(VERIL_BIN): filelist_verilator.f
	mkdir -p $(VERIL_BUILD)
	cd $(ROOT_DIR) && $(VERILATOR) $(VERIL_FLAGS)
	$(MAKE) -j 24 -C $(VERIL_BUILD) -f V$(VERIL_TOP).mk \
	  OPT_FAST="-O0" OPT_SLOW="-O0" OPT_DBG="-O0" \
	  $(if $(OBJCACHE),CXX="$(OBJCACHE) g++" CC="$(OBJCACHE) gcc",)

verilator-run: $(VERIL_BIN)
	cd $(ROOT_DIR) && $(VERIL_BIN) $(VERIL_RUN_FLAGS)

verilator-wave: $(VERIL_BIN)
	cd $(ROOT_DIR) && $(VERIL_BIN) $(VERIL_WAVE_FLAGS)

# ╔═══════════════════════════════════════════════════════════════════════════╗
# ║  Clean                                                                    ║
# ╚═══════════════════════════════════════════════════════════════════════════╝
clean:
	rm -rf $(VCS_BUILD) $(GATE_BUILD) $(VERIL_BUILD) *.fsdb *.fst *.vcd ucli.key novas.*
