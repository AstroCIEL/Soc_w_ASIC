SHELL    = /usr/bin/env bash
ROOT_DIR := $(patsubst %/,%, $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

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
.PHONY: all clean $(APPS)

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
	    $$(_objs_$1) $$($1_EXTRA_OBJS) $(RUNTIME_OBJS) $$(RISCV_LDFLAGS)
	$$(RISCV_OBJDUMP) $$(RISCV_OBJDUMP_FLAGS) -D $$@ > $$@.dump
endef
$(foreach app,$(APPS),$(eval $(call app_compile_template,$(app))))

# Convenience targets: `make hello_world` ≡ `make build/bin/hello_world`
$(APPS): % : $(BIN_DIR)/%

clean:
	rm -rf $(BUILD_DIR)
