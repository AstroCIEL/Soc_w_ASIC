# Copyright 2020 ETH Zurich and University of Bologna.
#
# SPDX-License-Identifier: Apache-2.0
#
# rules.mk -- Pattern rules for out-of-tree compilation.
#
# All intermediate objects (.o) are placed under $(BUILD_DIR), mirroring
# the source-tree layout.  No build artefact is ever written into the
# source directories.
#
# Requires:
#   toolchain.mk  – included beforehand (provides SDK_DIR, flags, etc.)
#   ROOT_DIR      – absolute path to the software project root
#   BUILD_DIR     – absolute path to the build output directory

BUILD_DIR ?= $(ROOT_DIR)/build

# ---------------------------------------------------------------------------
# Runtime sources & objects  (placed under $(BUILD_DIR)/sdk/src/)
# ---------------------------------------------------------------------------
RUNTIME_SRCS_C := $(SDK_DIR)/src/printf.c \
                  $(SDK_DIR)/src/string.c \
                  $(SDK_DIR)/src/serial.c \
                  $(SDK_DIR)/src/util.c

RUNTIME_SRCS_S := $(SDK_DIR)/src/crt0.S

# Map  $(ROOT_DIR)/X  →  $(BUILD_DIR)/X
RUNTIME_OBJS := $(patsubst $(ROOT_DIR)/%,$(BUILD_DIR)/%,$(RUNTIME_SRCS_C:.c=.c.o)) \
                $(patsubst $(ROOT_DIR)/%,$(BUILD_DIR)/%,$(RUNTIME_SRCS_S:.S=.S.o))

# Hook: callers may append extra runtime objects built elsewhere.
EXTRA_RUNTIME_OBJS ?=
RUNTIME_OBJS += $(EXTRA_RUNTIME_OBJS)

# ---------------------------------------------------------------------------
# Pattern rules  (LLVM, out-of-tree)
# ---------------------------------------------------------------------------
# Sources living under ROOT_DIR  →  objects under BUILD_DIR.
$(BUILD_DIR)/%.S.o: $(ROOT_DIR)/%.S
	@mkdir -p $(dir $@)
	$(RISCV_CC) $(RISCV_CCFLAGS) -c $< -o $@

$(BUILD_DIR)/%.c.o: $(ROOT_DIR)/%.c
	@mkdir -p $(dir $@)
	$(RISCV_CC) $(RISCV_CCFLAGS) -c $< -o $@

$(BUILD_DIR)/%.cpp.o: $(ROOT_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(RISCV_CXX) $(RISCV_CXXFLAGS) -c $< -o $@

# Generated sources that already live inside BUILD_DIR  (e.g. data.S).
$(BUILD_DIR)/%.S.o: $(BUILD_DIR)/%.S
	@mkdir -p $(dir $@)
	$(RISCV_CC) $(RISCV_CCFLAGS) -c $< -o $@

# ---------------------------------------------------------------------------
# Linker-script preprocessing
# ---------------------------------------------------------------------------
%.ld: %.ld.c
	$(RISCV_CC) -P -E $(DEFINES) $< -o $@
