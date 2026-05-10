SHELL    = /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

.PHONY: all clean
all:

# ---------------------------------------------------------------------------
# Hardware Config
# ---------------------------------------------------------------------------
# Number of vector lanes
nr_lanes ?= 2

# Length of each vector register (in bits)
# Constraints: VLEN > 128
vlen ?= 2048

# Dump VCD traces from applications that honor the VCD_DUMP compile guard.
vcd_dump ?= 0

# ---------------------------------------------------------------------------
# Preprocessor defines  (all additive – app/soc makefiles may append)
# ---------------------------------------------------------------------------
MAKE_DEFINES := -DNR_LANES=$(nr_lanes) -DVLEN=$(vlen)
DEFINES      += $(ENV_DEFINES) $(MAKE_DEFINES)

# ---------------------------------------------------------------------------
# Directory layout
# ---------------------------------------------------------------------------


BSP_DIR     := $(ROOT_DIR)
APP_DIR     := $(BSP_DIR)/app
SDK_DIR     := $(BSP_DIR)/sdk
SOC_DIR     := $(BSP_DIR)/soc
SCRIPTS_DIR := $(BSP_DIR)/scripts
BUILD_DIR   := $(BSP_DIR)/build
BIN_DIR     := $(BUILD_DIR)/bin

# ---------------------------------------------------------------------------
# Include the BSP build system
# ---------------------------------------------------------------------------
include $(SCRIPTS_DIR)/toolchain.mk
include $(SCRIPTS_DIR)/rules.mk

# ---------------------------------------------------------------------------
# Application discovery
# ---------------------------------------------------------------------------
APP_MKS := $(wildcard $(APP_DIR)/*/app.mk)
APPS    := $(patsubst $(APP_DIR)/%/app.mk,%,$(APP_MKS))

define app_include
APP                := $1
APP_DIR_$1         := $(APP_DIR)/$1
include $(APP_DIR)/$1/app.mk
endef
$(foreach app,$(APPS),$(eval $(call app_include,$(app))))

BINARIES := $(addprefix $(BIN_DIR)/,$(APPS))

# ===================================================================
#  Targets
# ===================================================================
.PHONY: $(APPS)

all: $(BINARIES)

# ---------------------------------------------------------------------------
# Per-app build rule
#   sources   : $($(1)_SRCS)          (absolute paths expected)
#   cflags    : $($(1)_CFLAGS)        (optional)
#   extra objs: $($(1)_EXTRA_OBJS)    (optional, already-built .o)
#
# Sources are mapped to objects under $(BUILD_DIR) mirroring the layout
# relative to $(BSP_DIR).
# ---------------------------------------------------------------------------
define app_compile_template
_objs_$1 := $$(patsubst $(BSP_DIR)/%,$(BUILD_DIR)/%,$$($1_SRCS:%=%.o))

$(BIN_DIR)/$1: $$(_objs_$1) $$($1_EXTRA_OBJS) $(RUNTIME_OBJS) $(SCRIPTS_DIR)/link.ld
	@mkdir -p $$(dir $$@)
	$$(RISCV_CC) $$(RISCV_CCFLAGS) $$($1_CFLAGS) -o $$@ \
	    $$(_objs_$1) $$($1_EXTRA_OBJS) $(RUNTIME_OBJS) \
	    $$(RISCV_LDFLAGS) $$(if $$($1_LDFLAGS),$$($1_LDFLAGS),)
	$$(RISCV_OBJDUMP) $$(RISCV_OBJDUMP_FLAGS) -D $$@ > $$@.dump
endef
$(foreach app,$(APPS),$(eval $(call app_compile_template,$(app))))

# Convenience targets: `make hello_world` ≡ `make build/bin/hello_world`
$(APPS): % : $(BIN_DIR)/%

clean:
	rm -rf $(BUILD_DIR)
