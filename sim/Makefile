# Ara SoC – Verilator simulation Makefile
# Usage:
#   make verilate          # elaborate + compile (default)
#   make compile           # C++ incremental compile only (skip elaboration)
#   make simv              # run simulation (hello_world by default)
#   make simv app=<name>   # run a different application
#   make clean             # remove build artifacts

SHELL    := /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ── Tools ─────────────────────────────────────────────────────────────────────
VERILATOR := /opt/verilator/bin/verilator
OBJCACHE  := $(shell which ccache 2>/dev/null)

# ── Design parameters ─────────────────────────────────────────────────────────
NR_LANES ?= 4
VLEN     ?= 4096

# ── Paths ─────────────────────────────────────────────────────────────────────
VERIL_BUILD := $(ROOT_DIR)/build/verilator
VERIL_TOP   := ara_tb_verilator
FILELIST    := $(ROOT_DIR)/filelist.f
TB_DIR      := $(ROOT_DIR)/../tb
app_path    ?= $(ROOT_DIR)/../software/build/bin
app         ?= hello_world

# TB C++ sources
TB_CPP_DIRS := $(TB_DIR)/verilator/lowrisc_dv_verilator_memutil_dpi/cpp \
               $(TB_DIR)/verilator/lowrisc_dv_verilator_memutil_verilator/cpp \
               $(TB_DIR)/verilator/lowrisc_dv_verilator_simutil_verilator/cpp
TB_CPP_MAIN := $(TB_DIR)/verilator/ara_tb.cpp

# Verilator warning suppression
VERIL_WFLAGS := -Wno-fatal \
  -Wno-PINCONNECTEMPTY -Wno-BLKANDNBLK  -Wno-CASEINCOMPLETE \
  -Wno-CMPCONST       -Wno-LATCH        -Wno-LITENDIAN \
  -Wno-UNOPTFLAT      -Wno-UNPACKED     -Wno-UNSIGNED \
  -Wno-WIDTH          -Wno-WIDTHCONCAT   -Wno-ENUMVALUE \
  -Wno-COMBDLY

# Intermediate products
VERIL_MK  := $(VERIL_BUILD)/V$(VERIL_TOP).mk
VERIL_BIN := $(VERIL_BUILD)/V$(VERIL_TOP)

# Include Verilator-generated RTL dependency file (--MMD).
# First run: file doesn't exist, -include silently skips.
# Subsequent runs: Make sees all .sv/.svh/.v prerequisites automatically.
-include $(VERIL_BUILD)/V$(VERIL_TOP)__ver.d

# ── Targets ───────────────────────────────────────────────────────────────────
.PHONY: all verilate compile simv clean

all: verilate

verilate: $(VERIL_BIN)

# Verilator elaboration — --MMD produces .d files for RTL dependency tracking
$(VERIL_MK): $(FILELIST)
	mkdir -p $(VERIL_BUILD)
	$(VERILATOR) \
	  -f $(FILELIST) \
	  --MMD \
	  -GNrLanes=$(NR_LANES) -GVLEN=$(VLEN) \
	  +define+NR_LANES=$(NR_LANES) +define+VLEN=$(VLEN) \
	  -O3 $(VERIL_WFLAGS) \
	  $(TB_DIR)/verilator/waiver.vlt \
	  --Mdir $(VERIL_BUILD) \
	  -I$(TB_DIR)/dpi \
	  --compiler clang \
	  -CFLAGS "-DTOPLEVEL_NAME=$(VERIL_TOP) -DNR_LANES=$(NR_LANES)" \
	  $(addprefix -CFLAGS -I,$(TB_CPP_DIRS)) \
	  -LDFLAGS "-lelf" \
	  --exe $(addsuffix /*.cc,$(TB_CPP_DIRS)) $(TB_CPP_MAIN) \
	  --cc --top-module $(VERIL_TOP)

# C++ compilation — generated Makefile tracks .cpp/.h deps via .d files
$(VERIL_BIN): $(VERIL_MK)
	cd $(VERIL_BUILD) && OBJCACHE='$(OBJCACHE)' \
	  make -j$$(nproc) -f V$(VERIL_TOP).mk VK_PCH_I_FAST= VK_PCH_I_SLOW=
	@echo "=== Build complete: $@ ==="

compile:
	cd $(VERIL_BUILD) && OBJCACHE='$(OBJCACHE)' \
	  make -j$$(nproc) -f V$(VERIL_TOP).mk VK_PCH_I_FAST= VK_PCH_I_SLOW=

simv:
	$(VERIL_BUILD)/V$(VERIL_TOP) -l ram,$(app_path)/$(app),elf

clean:
	rm -rf $(VERIL_BUILD)
