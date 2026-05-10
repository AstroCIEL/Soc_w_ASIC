vmma_test_SRCS := \
    $(APP_DIR_vmma_test)/main.c \
    $(SOC_DIR)/src/vmma.c

vmma_test_CFLAGS := -mcmodel=medlow -fno-builtin-printf
# Y lives far from W/X: WT D$ + prefetch can install a valid line for Y before DMA
# writeback; reading that line then misses DRAM. 0x8001F800 is in the TB stack-guard page.
vmma_test_LDFLAGS := -Wl,--section-start=.vmma_dma_out=0x8001F800
