# Per-app build description.  Required variable:
#   $(APP)_SRCS        -- list of sources (absolute paths).
# Optional variables:
#   $(APP)_CFLAGS      -- extra compiler flags for this app
#   $(APP)_EXTRA_OBJS  -- extra pre-built objects to link in

AXU_TEST_MODE  ?= all
AXU_TEST_CASE  ?= all
AXU_WS         := $(ROOT_DIR)/../zzc_workspace_axu
AXU_DATA_DIR   := $(AXU_WS)/test_data
AXU_GOLDEN_DIR := $(AXU_WS)/golden_result
AXU_GENDIR     := $(BUILD_DIR)/app/my_axu_test/gen
AXU_GENHDR     := $(AXU_GENDIR)/input_data.h
AXU_GEN_SCRIPT := $(AXU_WS)/file_format_transform/gen_input_data_axu.py

$(AXU_GENHDR): $(AXU_GEN_SCRIPT)
	@mkdir -p $(dir $@)
	python3 $(AXU_GEN_SCRIPT) --mode $(AXU_TEST_MODE) \
	    --case $(AXU_TEST_CASE) \
	    --data-dir $(AXU_DATA_DIR) \
	    --golden-dir $(AXU_GOLDEN_DIR) \
	    --out $@

$(BUILD_DIR)/app/my_axu_test/main.c.o: $(AXU_GENHDR)
$(BUILD_DIR)/app/my_axu_test/main.c.o: RISCV_CCFLAGS += -I$(AXU_GENDIR)

# Add conditional compilation flag for specific test cases
ifneq ($(AXU_TEST_CASE),all)
$(BUILD_DIR)/app/my_axu_test/main.c.o: RISCV_CCFLAGS += -DAXU_TEST_CASE_$(AXU_TEST_CASE)
endif

my_axu_test_SRCS := \
    $(APP_DIR_my_axu_test)/main.c \
    $(SOC_DIR)/src/my_axu.c

my_axu_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf -I$(AXU_GENDIR)
ifneq ($(AXU_TEST_CASE),all)
my_axu_test_CFLAGS += -DAXU_TEST_CASE_$(AXU_TEST_CASE)
endif
