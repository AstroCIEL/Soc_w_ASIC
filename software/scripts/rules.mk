BUILD_DIR ?= $(ROOT_DIR)/build


RISCV_INCLUDES := -I$(SDK_DIR)/include \
                  -I$(SOC_DIR)/include \
                  -I$(COMMON_DIR)/include

LINK_SCRIPT    := $(SCRIPTS_DIR)/link.ld

RUNTIME_SRCS_C := $(SDK_DIR)/src/syscalls.c \
                  $(SDK_DIR)/src/printf.c \
                  $(SDK_DIR)/src/util.c \
                  $(SOC_DIR)/src/serial.c \
                  $(SOC_DIR)/src/soc_ctrl.c \
                  $(SOC_DIR)/src/plic.c \
                  $(SOC_DIR)/src/clint.c \
                  $(SOC_DIR)/src/dma_reg64_1d.c \
                  $(SOC_DIR)/src/dma_desc64.c \
                  $(COMMON_DIR)/src/hook.c

RUNTIME_SRCS_S := $(SDK_DIR)/src/crt0.S \
                  $(SDK_DIR)/src/handlers.S \
                  $(SDK_DIR)/src/vectors.S

# Map  $(BSP_DIR)/X  →  $(BUILD_DIR)/X
RUNTIME_OBJS := $(patsubst $(BSP_DIR)/%,$(BUILD_DIR)/%,$(RUNTIME_SRCS_C:.c=.c.o)) \
                $(patsubst $(BSP_DIR)/%,$(BUILD_DIR)/%,$(RUNTIME_SRCS_S:.S=.S.o))

# Hook: callers may append extra runtime objects built elsewhere.
EXTRA_RUNTIME_OBJS ?=
RUNTIME_OBJS += $(EXTRA_RUNTIME_OBJS)

# ---------------------------------------------------------------------------
# Pattern rules  (LLVM, out-of-tree)
# ---------------------------------------------------------------------------
# Sources living under BSP_DIR  →  objects under BUILD_DIR.
DEPFLAGS = -MMD -MP -MF $@.d -MT $@

$(BUILD_DIR)/%.S.o: $(BSP_DIR)/%.S
	@mkdir -p $(dir $@)
	$(RISCV_CC) $(RISCV_CCFLAGS) $(DEPFLAGS) -c $< -o $@

$(BUILD_DIR)/%.c.o: $(BSP_DIR)/%.c
	@mkdir -p $(dir $@)
	$(RISCV_CC) $(RISCV_CCFLAGS) $(DEPFLAGS) -c $< -o $@

$(BUILD_DIR)/%.cpp.o: $(BSP_DIR)/%.cpp
	@mkdir -p $(dir $@)
	$(RISCV_CXX) $(RISCV_CXXFLAGS) $(DEPFLAGS) -c $< -o $@

# Generated sources that already live inside BUILD_DIR  (e.g. data.S).
$(BUILD_DIR)/%.S.o: $(BUILD_DIR)/%.S
	@mkdir -p $(dir $@)
	$(RISCV_CC) $(RISCV_CCFLAGS) $(DEPFLAGS) -c $< -o $@

# ---------------------------------------------------------------------------
# Linker-script preprocessing
# ---------------------------------------------------------------------------
%.ld: %.ld.c
	$(RISCV_CC) -P -E $(DEFINES) $< -o $@

-include $(shell find $(BUILD_DIR) -name '*.d' 2>/dev/null)