dcim_rw_test_SRCS := \
    $(APP_DIR_dcim_rw_test)/main.c \
    $(SOC_DIR)/src/dcim.c

dcim_rw_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf

