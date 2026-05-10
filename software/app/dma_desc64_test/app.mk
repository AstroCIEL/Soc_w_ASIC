# Per-app build description for the DMA desc64 memcpy demo.
dma_desc64_test_SRCS := $(APP_DIR_dma_desc64_test)/main.c

# Note: dma_desc64.c is already included in RUNTIME_SRCS_C, no need for EXTRA_OBJS

# Custom CFLAGS: use medlow code model, disable builtin printf
dma_desc64_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf

# Appended after RISCV_LDFLAGS (see software/Makefile)
dma_desc64_test_LDFLAGS := -Wl,--no-relax
