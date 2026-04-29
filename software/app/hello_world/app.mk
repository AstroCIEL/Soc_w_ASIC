# Per-app build description.  Required variable:
#   $(APP)_SRCS        -- list of sources (absolute paths).
# Optional variables:
#   $(APP)_CFLAGS      -- extra compiler flags for this app
#   $(APP)_EXTRA_OBJS  -- extra pre-built objects to link in

hello_world_SRCS := $(APP_DIR_hello_world)/main.c
