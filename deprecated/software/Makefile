# Copyright 2019 ETH Zurich and University of Bologna.
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

# Author: Matheus Cavalcante, ETH Zurich
#         Samuel Riedel, ETH Zurich

SHELL = /usr/bin/env bash
ROOT_DIR  := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# ---------------------------------------------------------------------------
# Directory layout
# ---------------------------------------------------------------------------
APP_DIR    := $(ROOT_DIR)/app
SDK_DIR    := $(ROOT_DIR)/sdk
TESTS_DIR  := $(APP_DIR)/riscv-tests/isa
TOOLS_DIR  := $(ROOT_DIR)/tools
BUILD_DIR  := $(ROOT_DIR)/build

# ---------------------------------------------------------------------------
# Include the SDK build system
# ---------------------------------------------------------------------------
include $(SDK_DIR)/mk/toolchain.mk
include $(SDK_DIR)/mk/rules.mk
include $(APP_DIR)/riscv_tests.mk
include $(APP_DIR)/default_args.mk

# ---------------------------------------------------------------------------
# Discover applications
# Every directory under app/ that contains main.c or main.cpp is treated
# as a buildable application.  The path relative to APP_DIR becomes the
# application name (e.g. app/hello_world/main.c → hello_world).
# ---------------------------------------------------------------------------
APPS := $(patsubst $(APP_DIR)/%/main.c,%,$(shell find $(APP_DIR) -name "main.c"))
APPS += $(patsubst $(APP_DIR)/%/main.cpp,%,$(shell find $(APP_DIR) -name "main.cpp"))

# Final ELF binaries live under build/bin/
BIN_DIR := $(BUILD_DIR)/bin

# Build a list of binary targets, excluding the special "benchmarks" wrapper
BINARIES := $(filter-out $(BIN_DIR)/benchmarks, $(addprefix $(BIN_DIR)/,$(APPS)))

# ---------------------------------------------------------------------------
# RISC-V ISA tests
# ---------------------------------------------------------------------------
CVA6_EXTENSIONS := rv64ui rv64uc rv64um rv64uf rv64ud rv64si
CVA6_BINARIES   := $(addprefix $(BIN_DIR)/, $(cva6_tests))
ARA_EXTENSIONS  := rv64uv
ARA_BINARIES    := $(addprefix $(BIN_DIR)/, $(ara_tests))

# ---------------------------------------------------------------------------
# Per-application overrides  (add more as needed)
# ---------------------------------------------------------------------------
ifeq ($(ENV_DEFINES),)
$(BIN_DIR)/fft:  ENV_DEFINES += -DFFT_SAMPLES=$(subst ",,$(firstword $(def_args_fft)))
$(BIN_DIR)/fft%: ENV_DEFINES += -DFFT_SAMPLES=$(subst ",,$(firstword $(def_args_fft)))
endif

# ===================================================================
#  Targets
# ===================================================================

.PHONY: all clean format riscv_tests

all: $(BINARIES)

# ---------------------------------------------------------------------------
# Linker-script generation  (real file target – only rebuilds when inputs
# change, supporting incremental builds)
# ---------------------------------------------------------------------------
LINKER_SCRIPT := $(SDK_DIR)/scripts/link.ld

$(LINKER_SCRIPT): $(SDK_DIR)/scripts/arch.link.ld $(SDK_DIR)/scripts/align_sections.sh $(ARA_DIR)/config/$(config).mk
	chmod +x $(SDK_DIR)/scripts/align_sections.sh
	cp $(SDK_DIR)/scripts/arch.link.ld $@
	$(SDK_DIR)/scripts/align_sections.sh $(nr_lanes) $@

# ---------------------------------------------------------------------------
# Data generation
# ---------------------------------------------------------------------------
# Each app may have a script/gen_data.py.  The generated data.S is placed
# inside $(BUILD_DIR)/app/<name>/ so the source tree stays clean.
#
# When old_data=1 is set, the pre-committed data.S from the source tree
# is copied into the build directory instead of regenerating.
#
# Dependencies are set so that data.S is only regenerated when the
# generator script or default_args.mk changes (incremental-build safe).
ifneq ($(old_data),1)
define app_gen_data_template
# Determine the generator script path (may not exist for all apps).
_gen_script_$1 := $$(wildcard $(APP_DIR)/$1/script/gen_data.py)

$(BUILD_DIR)/app/$1/data.S: $$(_gen_script_$1) $(APP_DIR)/default_args.mk
	@mkdir -p $$(dir $$@)
	cd $(APP_DIR)/$1 && \
	  if [ -f script/gen_data.py ]; then \
	    $$(PYTHON) script/gen_data.py $(subst ",,$(def_args_$1)) > $$@ ; \
	  else \
	    touch $$@ ; \
	  fi
endef
else
define app_gen_data_template
$(BUILD_DIR)/app/$1/data.S: $(APP_DIR)/$1/data.S
	@mkdir -p $$(dir $$@)
	cp $$< $$@
endef
endif
$(foreach app,$(APPS),$(eval $(call app_gen_data_template,$(app))))

# ---------------------------------------------------------------------------
# Application build template
# ---------------------------------------------------------------------------
# For each app we:
#   1. Discover all C/C++/ASM sources under its source directory.
#   2. Map every source to its out-of-tree object under $(BUILD_DIR)/app/<name>/.
#   3. Link the objects together with the runtime into $(BIN_DIR)/<name>.
#
# Layout inside build/:
#   build/
#     bin/<app>            – final ELF
#     bin/<app>.dump       – disassembly
#     app/<app>/**/*.o     – intermediate objects (mirrors source tree)
#     app/<app>/data.S     – generated data
#     sdk/src/*.o          – runtime objects
# ---------------------------------------------------------------------------
define app_compile_template
_srcs_$1 := $$(shell find -L $(APP_DIR)/$1 \( -name "*.c" -o -name "*.cpp" -o -name "*.S" \) ! -name "data.S")
_objs_$1 := $$(patsubst $(ROOT_DIR)/%,$(BUILD_DIR)/%,$$(_srcs_$1:%=%.o))

$(BIN_DIR)/$1: $$(_objs_$1) $(BUILD_DIR)/app/$1/data.S.o $(RUNTIME_OBJS) $(LINKER_SCRIPT)
	@mkdir -p $$(dir $$@)
	$$(RISCV_CC) $$(RISCV_CCFLAGS) -o $$@ $$(_objs_$1) $(BUILD_DIR)/app/$1/data.S.o $(RUNTIME_OBJS) $$(RISCV_LDFLAGS)
	$$(RISCV_OBJDUMP) $$(RISCV_OBJDUMP_FLAGS) -D $$@ > $$@.dump
	$$(RISCV_STRIP) $$@ -S --strip-unneeded
endef
$(foreach app,$(APPS),$(eval $(call app_compile_template,$(app))))

# Convenience targets: `make hello_world` ≡ `make build/bin/hello_world`
.PHONY: $(APPS)
$(APPS): % : $(BIN_DIR)/%

# ---------------------------------------------------------------------------
# RISC-V ISA tests  (assembly tests compiled with LLVM)
# ---------------------------------------------------------------------------
riscv_tests: $(CVA6_BINARIES) $(ARA_BINARIES)

define rvtest_compile_template
$(BIN_DIR)/$(1)-ara-%: $(TESTS_DIR)/$(1)/%.$(2) $(RUNTIME_OBJS) $(LINKER_SCRIPT)
	@mkdir -p $$(dir $$@)
	$$(RISCV_CC) -I$(SDK_DIR)/include \
	  -I$$(TESTS_DIR)/macros/scalar -I$$(TESTS_DIR)/macros/vector \
	  $$(RISCV_CCFLAGS) $$(RISCV_LDFLAGS) -o $$@ $$< $(RUNTIME_OBJS)
	$$(RISCV_OBJDUMP) $$(RISCV_OBJDUMP_FLAGS) -D $$@ > $$@.dump
	$$(RISCV_STRIP) $$@ -S --strip-unneeded
endef
# CVA6 tests are assembly; Ara tests are C
$(foreach ext, $(CVA6_EXTENSIONS), $(eval $(call rvtest_compile_template,$(ext),S)))
$(foreach ext, $(ARA_EXTENSIONS),  $(eval $(call rvtest_compile_template,$(ext),c)))

# ---------------------------------------------------------------------------
# Formatting
# ---------------------------------------------------------------------------
format:
	$(LLVM_INSTALL_DIR)/bin/clang-format -style=file -i \
	  $$(find $(APP_DIR) $(SDK_DIR) | grep -E "\.[h,c,cpp]$$")
	$(LLVM_INSTALL_DIR)/bin/clang-format -style=file -i \
	  $$(find $(TESTS_DIR)/rv64uv | grep -E "\.[h,c,cpp]$$")

# ---------------------------------------------------------------------------
# Clean  (simply nuke the entire build directory)
# ---------------------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR)
	rm -f $(LINKER_SCRIPT)
