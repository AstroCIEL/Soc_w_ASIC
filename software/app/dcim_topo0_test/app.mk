# Topo0/TOPO1(2'b00) multi-macro DCIM test

TOPO0_DCIM_TEST_TOPO ?= 0
TOPO0_DCIM_POST_START_CYCLES ?= 200
TOPO0_DCIM_POST_LOAD_CYCLES ?= 10
TOPO0_DCIM_CPU_IO_TRACE ?= 0
TOPO0_DCIM_VERIFY_RW ?= 1

# Golden vector generation knobs
TOPO0_DCIM_TYPE ?= INT16
TOPO0_DCIM_ACC ?= 3
TOPO0_DCIM_WD1 ?= 4
TOPO0_DCIM_CH_IN ?= 64
TOPO0_DCIM_CH_OUT ?= 64
TOPO0_DCIM_R ?= 4
TOPO0_DCIM_ACT_ROWS ?= 24
TOPO0_DCIM_WEI_ROWS ?= 8
TOPO0_DCIM_ACT_ROW_ORDER ?= normal
TOPO0_DCIM_SEED ?= 1

DCIM_GENDIR := $(BUILD_DIR)/app/dcim_topo0_test/gen
DCIM_GENHDR := $(DCIM_GENDIR)/input_data.h
DCIM_GENSCRIPT := $(APP_DIR_dcim_topo0_test)/golden/gen_dcim_topo0_golden_data.py
DCIM_GENCFG := $(DCIM_GENDIR)/.gen_cfg
DCIM_GENCFG_TXT := TYPE=$(TOPO0_DCIM_TYPE) ACC=$(TOPO0_DCIM_ACC) WD1=$(TOPO0_DCIM_WD1) CH_IN=$(TOPO0_DCIM_CH_IN) CH_OUT=$(TOPO0_DCIM_CH_OUT) R=$(TOPO0_DCIM_R) ACT_ROWS=$(TOPO0_DCIM_ACT_ROWS) WEI_ROWS=$(TOPO0_DCIM_WEI_ROWS) ACT_ROW_ORDER=$(TOPO0_DCIM_ACT_ROW_ORDER) SEED=$(TOPO0_DCIM_SEED) TOPO=$(TOPO0_DCIM_TEST_TOPO)

.PHONY: FORCE

$(DCIM_GENCFG): FORCE
	@mkdir -p $(dir $@)
	@printf "%s\n" "$(DCIM_GENCFG_TXT)" > $@

$(DCIM_GENHDR): $(DCIM_GENSCRIPT) $(DCIM_GENCFG)
	@mkdir -p $(dir $@)
	@if [ ! -f $(DCIM_GENCFG) ] || [ "$$(cat $(DCIM_GENCFG))" != "$(DCIM_GENCFG_TXT)" ]; then \
	    printf "%s\n" "$(DCIM_GENCFG_TXT)" > $(DCIM_GENCFG); \
	fi
	python3 $(DCIM_GENSCRIPT) \
	    --outdir $(DCIM_GENDIR) \
	    --type $(TOPO0_DCIM_TYPE) \
	    --acc $(TOPO0_DCIM_ACC) \
	    --wd1 $(TOPO0_DCIM_WD1) \
	    --ch-in $(TOPO0_DCIM_CH_IN) \
	    --ch-out $(TOPO0_DCIM_CH_OUT) \
	    --r $(TOPO0_DCIM_R) \
	    --act-rows $(TOPO0_DCIM_ACT_ROWS) \
	    --wei-rows $(TOPO0_DCIM_WEI_ROWS) \
	    --act-row-order $(TOPO0_DCIM_ACT_ROW_ORDER) \
	    --seed $(TOPO0_DCIM_SEED) \
	    --topo $(TOPO0_DCIM_TEST_TOPO)

$(BUILD_DIR)/app/dcim_topo0_test/main.c.o: $(DCIM_GENHDR)
$(BUILD_DIR)/app/dcim_topo0_test/main.c.o: RISCV_CCFLAGS += -I$(DCIM_GENDIR)

dcim_topo0_test_SRCS := \
    $(APP_DIR_dcim_topo0_test)/main.c \
    $(SOC_DIR)/src/dcim.c

dcim_topo0_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf \
    -I$(DCIM_GENDIR) \
    -DDCIM_TEST_TOPO=$(TOPO0_DCIM_TEST_TOPO) \
    -DDCIM_CPU_IO_TRACE=$(TOPO0_DCIM_CPU_IO_TRACE) \
    -DDCIM_VERIFY_RW=$(TOPO0_DCIM_VERIFY_RW)

# rules.mk compiles dcim.c with RISCV_CCFLAGS; keep trace level consistent.
$(BUILD_DIR)/soc/src/dcim.c.o: RISCV_CCFLAGS += -DDCIM_CPU_IO_TRACE=$(TOPO0_DCIM_CPU_IO_TRACE)

ifneq ($(TOPO0_DCIM_POST_START_CYCLES),)
dcim_topo0_test_CFLAGS += -DDCIM_POST_START_CYCLES=$(TOPO0_DCIM_POST_START_CYCLES)ULL
endif

ifneq ($(TOPO0_DCIM_POST_LOAD_CYCLES),)
dcim_topo0_test_CFLAGS += -DDCIM_POST_LOAD_CYCLES=$(TOPO0_DCIM_POST_LOAD_CYCLES)ULL
endif
