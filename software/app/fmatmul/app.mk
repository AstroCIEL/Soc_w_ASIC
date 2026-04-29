# fmatmul application (C = A*B, A=[MxN], B=[NxP], C=[MxP])
fmatmul_SRCS       := $(APP_DIR_fmatmul)/main.c \
                      $(APP_DIR_fmatmul)/kernel/fmatmul.c
fmatmul_EXTRA_OBJS := $(BUILD_DIR)/app/fmatmul/data.S.o

PYTHON ?= python3

$(BUILD_DIR)/app/fmatmul/data.S: $(APP_DIR_fmatmul)/script/gen_data.py
	@mkdir -p $(dir $@)
	cd $(APP_DIR_fmatmul) && $(PYTHON) script/gen_data.py 32 32 32 > $@
