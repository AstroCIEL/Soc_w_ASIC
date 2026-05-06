# Per-app build description for the DMA reg64_1d memcpy demo.
dma_reg64_1d_test_SRCS := $(APP_DIR_dma_reg64_1d_test)/main.c

# Extra runtime objects needed for this app (DMA specific)
dma_reg64_1d_test_EXTRA_OBJS := $(BUILD_DIR)/soc/src/dma_reg64_1d.c.o

# Custom CFLAGS: use medlow code model, disable builtin printf
dma_reg64_1d_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf

# Custom LDFLAGS: add --no-relax to avoid relocation issues
dma_reg64_1d_test_LDFLAGS := -static -nostartfiles -nostdlib -Wl,--gc-sections -Wl,--no-relax \
    -T$(SCRIPTS_DIR)/link.ld -L$(HOME)/tools/riscv/lib/gcc/riscv64-unknown-elf/13.2.0 \
    -lm -lgcc
