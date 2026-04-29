# dotproduct application
dotproduct_SRCS       := $(APP_DIR_dotproduct)/main.c \
                         $(APP_DIR_dotproduct)/kernel/dotproduct.c
dotproduct_EXTRA_OBJS := $(BUILD_DIR)/app/dotproduct/data.S.o

PYTHON ?= python3

$(BUILD_DIR)/app/dotproduct/data.S: $(APP_DIR_dotproduct)/script/gen_data.py
	@mkdir -p $(dir $@)
	cd $(APP_DIR_dotproduct) && $(PYTHON) script/gen_data.py 512 > $@
