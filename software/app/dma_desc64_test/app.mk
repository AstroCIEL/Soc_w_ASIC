# Per-app build description for the DMA desc64 memcpy demo.
dma_desc64_test_SRCS := $(APP_DIR_dma_desc64_test)/main.c

# Note: dma_desc64.c is already included in RUNTIME_SRCS_C, no need for EXTRA_OBJS

# Custom CFLAGS: use medlow code model, disable builtin printf
dma_desc64_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf

# Custom LDFLAGS: add --no-relax to avoid relocation issues
dma_desc64_test_LDFLAGS := -static -nostartfiles -nostdlib -Wl,--gc-sections -Wl,--no-relax \
    -T$(SCRIPTS_DIR)/link.ld -L$(HOME)/tools/riscv/lib/gcc/riscv64-unknown-elf/13.2.0 \
    -lm -lgcc
