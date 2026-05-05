# Copyright 2020 ETH Zurich and University of Bologna.
#
# SPDX-License-Identifier: Apache-2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Author: Samuel Riedel, ETH Zurich
#         Matheus Cavalcante, ETH Zurich

# toolchain.mk -- Toolchain detection, compiler flags, and defines.
# Included by the top-level Makefile; should NOT be included directly by
# individual application Makefiles.

SHELL = /usr/bin/env bash

# ---------------------------------------------------------------------------
# Path helpers
# ---------------------------------------------------------------------------
_SDK_MK_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
SDK_DIR     := $(abspath $(_SDK_MK_DIR)/..)

ARA_DIR := $(shell git rev-parse --show-toplevel 2>/dev/null || echo $$ARA_DIR)

# ---------------------------------------------------------------------------
# Ara configuration
# ---------------------------------------------------------------------------
ifndef config
	ifdef ARA_CONFIGURATION
		config := $(ARA_CONFIGURATION)
	else
		config := default
	endif
endif

include $(ARA_DIR)/config/$(config).mk

# ---------------------------------------------------------------------------
# Install directories  (all overridable)
# ---------------------------------------------------------------------------
INSTALL_DIR         ?= $(ARA_DIR)/install
LLVM_INSTALL_DIR    ?= $(INSTALL_DIR)/riscv-llvm
ISA_SIM_INSTALL_DIR ?= $(INSTALL_DIR)/riscv-isa-sim

# Pre-installed toolchain directory (from user home)
USER_TOOLS_DIR      ?= $(HOME)/tools/riscv

# ---------------------------------------------------------------------------
# Architecture parameters
# ---------------------------------------------------------------------------
RISCV_XLEN   ?= 64
RISCV_ABI    ?= lp64d
RISCV_TARGET ?= riscv$(RISCV_XLEN)-unknown-elf

# ---------------------------------------------------------------------------
# Toolchain detection (priority order)
# 1. Project-local built LLVM ($(LLVM_INSTALL_DIR)/bin) - best compatibility
# 2. User pre-installed GCC ($(USER_TOOLS_DIR)/bin) - stable, already working
# 3. System pre-installed toolchain (/opt/riscv-llvm/...) - fallback
#
# Note: We avoid using pre-installed LLVM that may have dynamic library issues
#       on older systems (e.g., libtinfo.so.6 missing on CentOS 7)
# ---------------------------------------------------------------------------

# Check for project-local LLVM built from source (most compatible)
ifneq ($(wildcard $(LLVM_INSTALL_DIR)/bin/clang),)
  # Use LLVM toolchain with GCC sysroot and LLD (libgcc debug info stripped)
  GCC_SYSROOT   ?= $(USER_TOOLS_DIR)/bin/../riscv64-unknown-elf
  RISCV_PREFIX  ?= $(LLVM_INSTALL_DIR)/bin/
  # -fuse-ld=lld is defined in LLVM_FLAGS; stripped libgcc avoids DWARF5 issues
  RISCV_CC      ?= $(RISCV_PREFIX)clang --target=$(RISCV_TARGET) --sysroot=$(GCC_SYSROOT)
  RISCV_CXX     ?= $(RISCV_PREFIX)clang++ --target=$(RISCV_TARGET) --sysroot=$(GCC_SYSROOT)
  RISCV_OBJDUMP ?= $(RISCV_PREFIX)llvm-objdump
  RISCV_OBJCOPY ?= $(RISCV_PREFIX)llvm-objcopy
  RISCV_AS      ?= $(RISCV_PREFIX)llvm-as
  RISCV_AR      ?= $(RISCV_PREFIX)llvm-ar
  RISCV_LD      ?= $(RISCV_PREFIX)ld.lld
  RISCV_STRIP   ?= $(RISCV_PREFIX)llvm-strip
  $(info Using project-local LLVM toolchain: $(LLVM_INSTALL_DIR) with LLD)
# Check for user pre-installed GCC toolchain (stable fallback)
else ifneq ($(wildcard $(USER_TOOLS_DIR)/bin/riscv64-unknown-elf-gcc),)
  RISCV_PREFIX  ?= $(USER_TOOLS_DIR)/bin/riscv64-unknown-elf-
  RISCV_CC      ?= $(RISCV_PREFIX)gcc
  RISCV_CXX     ?= $(RISCV_PREFIX)g++
  RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump
  RISCV_OBJCOPY ?= $(RISCV_PREFIX)objcopy
  RISCV_AS      ?= $(RISCV_PREFIX)as
  RISCV_AR      ?= $(RISCV_PREFIX)ar
  RISCV_LD      ?= $(RISCV_PREFIX)ld
  RISCV_STRIP   ?= $(RISCV_PREFIX)strip
  $(info Using user GCC toolchain: $(USER_TOOLS_DIR))
# Fallback to system paths
else
  RISCV_PREFIX  ?= /opt/riscv-llvm/xbin/riscv64-unknown-elf-
  RISCV_CC      ?= $(RISCV_PREFIX)clang
  RISCV_CXX     ?= $(RISCV_PREFIX)clang++
  RISCV_OBJDUMP ?= $(RISCV_PREFIX)llvm-objdump
  RISCV_OBJCOPY ?= $(RISCV_PREFIX)llvm-objcopy
  RISCV_AS      ?= $(RISCV_PREFIX)llvm-as
  RISCV_AR      ?= $(RISCV_PREFIX)llvm-ar
  RISCV_LD      ?= $(RISCV_PREFIX)ld.lld
  RISCV_STRIP   ?= $(RISCV_PREFIX)llvm-strip
  $(info Using system toolchain)
endif

# ---------------------------------------------------------------------------
# Spike ISA simulator
# ---------------------------------------------------------------------------
RISCV_SIM     ?= $(ISA_SIM_INSTALL_DIR)/bin/spike
vlen_spike    := $(shell vlen=$$(grep vlen $(ARA_DIR)/config/$(config).mk | cut -d" " -f3) && echo "$$(( $$vlen < 4096 ? $$vlen : 4096 ))")
RISCV_SIM_OPT ?= --isa=rv64gcv_zfh --varch="vlen:$(vlen_spike),elen:64"

# ---------------------------------------------------------------------------
# Python
# ---------------------------------------------------------------------------
PYTHON ?= python3

# ---------------------------------------------------------------------------
# Preprocessor defines  (all additive – callers may append to DEFINES)
# ---------------------------------------------------------------------------
ENV_DEFINES ?=
ifeq ($(vcd_dump),1)
ENV_DEFINES += -DVCD_DUMP=1
endif
MAKE_DEFINES = -DNR_LANES=$(nr_lanes) -DVLEN=$(vlen)
DEFINES += $(ENV_DEFINES) $(MAKE_DEFINES)

# ---------------------------------------------------------------------------
# Compiler / linker flags
# ---------------------------------------------------------------------------
RISCV_WARNINGS += -Wunused-variable -Wall -Wextra -Wno-unused-command-line-argument

# LLVM-specific flags (used with Clang)
# Using LLD with stripped libgcc (debug info removed to avoid DWARF5 reloc issues)
LLVM_FLAGS   ?= -march=rv64gcv_zfh_zvfh -mabi=$(RISCV_ABI) -mno-relax -fuse-ld=lld
LLVM_V_FLAGS ?= -fno-vectorize -mllvm -scalable-vectorization=off \
                -mllvm -riscv-v-vector-bits-min=0 -mno-implicit-float

# GCC-specific flags (fallback when Clang unavailable)
GCC_FLAGS    ?= -march=rv64gcv_zfh -mabi=$(RISCV_ABI) -mno-relax

# Detect if using LLVM/GCC based on RISCV_CC name
USING_CLANG := $(if $(findstring clang,$(RISCV_CC)),1,0)

ifeq ($(USING_CLANG),1)
  # Clang flags
  RISCV_ARCH_FLAGS ?= $(LLVM_FLAGS) $(LLVM_V_FLAGS)
else
  # GCC flags (fallback)
  RISCV_ARCH_FLAGS ?= $(GCC_FLAGS)
endif

RISCV_FLAGS   ?= $(RISCV_ARCH_FLAGS) -mcmodel=medany \
                 -I$(SDK_DIR)/include -O3 -ffast-math -fno-common \
                 -fno-builtin-printf $(DEFINES) $(RISCV_WARNINGS)

RISCV_CCFLAGS  ?= $(RISCV_FLAGS) -ffunction-sections -fdata-sections -std=gnu99
RISCV_CXXFLAGS ?= $(RISCV_FLAGS) -ffunction-sections -fdata-sections
# Include libgcc path and use libgcc instead of compiler-rt
RISCV_LDFLAGS  ?= -static -nostartfiles -lm -Wl,--gc-sections \
                  -T$(SDK_DIR)/scripts/link.ld \
                  -L$(USER_TOOLS_DIR)/lib/gcc/riscv64-unknown-elf/13.2.0 \
                  -rtlib=libgcc

RISCV_OBJDUMP_FLAGS ?= $(if $(findstring clang,$(RISCV_CC)),--mattr=v,-M no-aliases)