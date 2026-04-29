# fdotproduct application
fdotproduct_SRCS       := $(APP_DIR_fdotproduct)/main.c \
                          $(APP_DIR_fdotproduct)/kernel/fdotproduct.c
fdotproduct_EXTRA_OBJS := $(BUILD_DIR)/app/fdotproduct/data.S.o

PYTHON ?= python3

$(BUILD_DIR)/app/fdotproduct/data.S: $(APP_DIR_fdotproduct)/script/gen_data.py
	@mkdir -p $(dir $@)
	cd $(APP_DIR_fdotproduct) && $(PYTHON) script/gen_data.py 512 > $@
