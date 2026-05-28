mxu_idma_gbuf_test_SRCS := \
    $(APP_DIR_mxu_idma_gbuf_test)/main.c \
    $(SOC_DIR)/src/my_mxu.c

mxu_idma_gbuf_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf
