asic_accel_test_SRCS := \
    $(APP_DIR_asic_accel_test)/main.c \
    $(SOC_DIR)/src/asic_accel.c

asic_accel_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf
