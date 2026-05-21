# Per-app build description.  Required variable:
#   $(APP)_SRCS        -- list of sources (absolute paths).
# Optional variables:
#   $(APP)_CFLAGS      -- extra compiler flags for this app
#   $(APP)_EXTRA_OBJS  -- extra pre-built objects to link in

MXU_TEST_MODE  ?= posit_bp
MXU_WS         := $(ROOT_DIR)/../zzc_workspace_mxu
MXU_GENDIR     := $(BUILD_DIR)/app/my_mxu_test/gen
MXU_GENHDR     := $(MXU_GENDIR)/input_data.h
MXU_GEN_SCRIPT := $(MXU_WS)/file_format_transform/gen_input_data.py

$(MXU_GENHDR): $(MXU_GEN_SCRIPT)
	@mkdir -p $(dir $@)
	python3 $(MXU_GEN_SCRIPT) --mode $(MXU_TEST_MODE) --workspace $(MXU_WS) --out $@

$(BUILD_DIR)/app/my_mxu_test/main.c.o: $(MXU_GENHDR)
$(BUILD_DIR)/app/my_mxu_test/main.c.o: RISCV_CCFLAGS += -I$(MXU_GENDIR)

my_mxu_test_SRCS := \
    $(APP_DIR_my_mxu_test)/main.c \
    $(SOC_DIR)/src/my_mxu.c

my_mxu_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf -I$(MXU_GENDIR)
