# Per-app build description for the DMA reg64_1d memcpy demo.
dma_reg64_1d_test_SRCS := $(APP_DIR_dma_reg64_1d_test)/main.c

# Note: dma_reg64_1d.c is already included in RUNTIME_SRCS_C, no need for EXTRA_OBJS

# Custom CFLAGS: use medlow code model, disable builtin printf
dma_reg64_1d_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf

# Appended after RISCV_LDFLAGS (see software/Makefile)
dma_reg64_1d_test_LDFLAGS := -Wl,--no-relax
