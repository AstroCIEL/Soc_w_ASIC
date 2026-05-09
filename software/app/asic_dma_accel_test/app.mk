asic_dma_accel_test_SRCS := \
    $(APP_DIR_asic_dma_accel_test)/main.c \
    $(SOC_DIR)/src/asic_dma_accel.c

asic_dma_accel_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf
