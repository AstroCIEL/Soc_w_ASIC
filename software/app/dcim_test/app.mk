# minimum_dcim SoC: use sim/filelist_minimum_dcim.f (not default my_mxu_axu filelist)

DCIM_TEST_TOPO ?= 3
DCIM_POST_START_CYCLES ?= 200
DCIM_POST_LOAD_CYCLES ?= 10
DCIM_CPU_IO_TRACE ?= 0

# Golden vector generation knobs
DCIM_TYPE ?= INT16
DCIM_ACC ?= 3
DCIM_WD1 ?= 4
DCIM_CH_IN ?= 64
DCIM_CH_OUT ?= 64
DCIM_R ?= 4
DCIM_ACT_ROWS ?= 12
DCIM_WEI_ROWS ?= 8
DCIM_ACT_ROW_ORDER ?= normal
DCIM_SEED ?= 1

DCIM_GENDIR := $(BUILD_DIR)/app/dcim_test/gen
DCIM_GENHDR := $(DCIM_GENDIR)/input_data.h
DCIM_GENSCRIPT := $(APP_DIR_dcim_test)/golden/gen_dcim_golden_data.py
DCIM_GENCFG := $(DCIM_GENDIR)/.gen_cfg
DCIM_GENCFG_TXT := TYPE=$(DCIM_TYPE) ACC=$(DCIM_ACC) WD1=$(DCIM_WD1) CH_IN=$(DCIM_CH_IN) CH_OUT=$(DCIM_CH_OUT) R=$(DCIM_R) ACT_ROWS=$(DCIM_ACT_ROWS) WEI_ROWS=$(DCIM_WEI_ROWS) ACT_ROW_ORDER=$(DCIM_ACT_ROW_ORDER) SEED=$(DCIM_SEED) TOPO=$(DCIM_TEST_TOPO)

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
	    --type $(DCIM_TYPE) \
	    --acc $(DCIM_ACC) \
	    --wd1 $(DCIM_WD1) \
	    --ch-in $(DCIM_CH_IN) \
	    --ch-out $(DCIM_CH_OUT) \
	    --r $(DCIM_R) \
	    --act-rows $(DCIM_ACT_ROWS) \
	    --wei-rows $(DCIM_WEI_ROWS) \
	    --act-row-order $(DCIM_ACT_ROW_ORDER) \
	    --seed $(DCIM_SEED) \
	    --topo $(DCIM_TEST_TOPO)

$(BUILD_DIR)/app/dcim_test/main.c.o: $(DCIM_GENHDR)
$(BUILD_DIR)/app/dcim_test/main.c.o: RISCV_CCFLAGS += -I$(DCIM_GENDIR)

dcim_test_SRCS := \
    $(APP_DIR_dcim_test)/main.c \
    $(SOC_DIR)/src/dcim.c

dcim_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf \
    -I$(DCIM_GENDIR) \
    -DDCIM_TEST_TOPO=$(DCIM_TEST_TOPO) \
    -DDCIM_CPU_IO_TRACE=$(DCIM_CPU_IO_TRACE)

# rules.mk compiles dcim.c with RISCV_CCFLAGS; keep trace level consistent.
$(BUILD_DIR)/soc/src/dcim.c.o: RISCV_CCFLAGS += -DDCIM_CPU_IO_TRACE=$(DCIM_CPU_IO_TRACE)

ifneq ($(DCIM_POST_START_CYCLES),)
dcim_test_CFLAGS += -DDCIM_POST_START_CYCLES=$(DCIM_POST_START_CYCLES)ULL
endif

ifneq ($(DCIM_POST_LOAD_CYCLES),)
dcim_test_CFLAGS += -DDCIM_POST_LOAD_CYCLES=$(DCIM_POST_LOAD_CYCLES)ULL
endif

# Backward compatible knob (legacy name)
ifneq ($(DCIM_WAIT_CYCLES),)
dcim_test_CFLAGS += -DDCIM_WAIT_CYCLES=$(DCIM_WAIT_CYCLES)ULL
endif
