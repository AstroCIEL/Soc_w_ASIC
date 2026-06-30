# minimum_dcim SoC: use sim/filelist_minimum_dcim.f (not default my_mxu_axu filelist)

DCIM_TEST_TOPO ?= 3
DCIM_POST_START_CYCLES ?= 200

dcim_test_SRCS := \
    $(APP_DIR_dcim_test)/main.c \
    $(SOC_DIR)/src/dcim.c

dcim_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf \
    -DDCIM_TEST_TOPO=$(DCIM_TEST_TOPO) \
    -DDCIM_CPU_IO_TRACE=1

# Optional: fixed post-START delay cycles before reading output
# make dcim_test DCIM_POST_START_CYCLES=200

ifneq ($(DCIM_POST_START_CYCLES),)
dcim_test_CFLAGS += -DDCIM_POST_START_CYCLES=$(DCIM_POST_START_CYCLES)ULL
endif

# Backward compatible knob (legacy name)
ifneq ($(DCIM_WAIT_CYCLES),)
dcim_test_CFLAGS += -DDCIM_WAIT_CYCLES=$(DCIM_WAIT_CYCLES)ULL
endif
