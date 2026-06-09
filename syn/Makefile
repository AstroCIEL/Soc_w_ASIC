# 使用教程：快速综合一个小模块来检查脚本是否正确
#
# 目的：
#   在正式综合 mxu_top / axu_top / ariane_soc_top 之前，先选择一个较小的模块跑通流程，
#   用来快速确认：
#     1. SYN_TARGET=custom 是否能正确选择顶层模块；
#     2. BUILD_TAG 是否能生成独立 build 目录，避免和其它综合任务冲突；
#     3. NETLIST_NAMESPACE_PREFIX 是否能让输出网表里的内部子模块带上指定前缀；
#     4. change_names / uniquify 相关控制是否能正常执行。
#
# 示例：综合 scheduler 这个小模块
#  
# 进入对应目录：          
#   cd /data/home/zch_zhou28/workspace/work2026_2/work_for_tapeout_2026_v2/Soc_w_ASIC/syn
# clean一下要用到的目录： 
#   make clean SYN_TARGET=custom TOP_MODULE=scheduler BUILD_TAG=probe_scheduler
# 综合：               
#   make flat  SYN_TARGET=custom TOP_MODULE=scheduler BUILD_TAG=probe_scheduler NETLIST_NAMESPACE_PREFIX=probe__
#
# 说明：
#   SYN_TARGET=custom
#       表示不使用 mxu/axu/top 的默认映射，而是手动指定 TOP_MODULE。
#   TOP_MODULE=scheduler
#       表示本次 elaborate/compile 的顶层模块是 scheduler。
#   BUILD_TAG=probe_scheduler
#       表示输出目录为 ./build_probe_scheduler，避免覆盖 build_mxu、build_axu、build_top。
#   NETLIST_NAMESPACE_PREFIX=probe__
#       表示若 uniquify 生效，内部子模块应被改名为 probe__<原模块名>_<序号> 形式。
#
# 快速检查：
#   1. 看日志中是否有目标和 namespace 信息：
#        grep -E "SYN_TARGET|TOP_MODULE|NAMESPACE_PREFIX|namespace|change_names" build_probe_scheduler/flat_NONE.log
#
#   2. 看网表是否生成：
#        ls build_probe_scheduler/outputs/*_netlist.v
#
#   3. 看网表中是否出现 probe__ 前缀的 module：
#        grep -n "^module probe__" build_probe_scheduler/outputs/*_netlist.v | head
#
#   4. 如果没有 probe__ 前缀，先检查日志中是否显示：
#        [namespace] pre-compile style = probe__%s_%d
#        [namespace] post-compile: uniquify_naming_style = probe__%s_%d
#        [namespace] pre-output: uniquify_naming_style = probe__%s_%d
#
# 注意：
#   - 小模块必须已经在 syn/filelist.f 展开的源文件集合中，否则 DC 无法 elaborate。
#   - 如果 scheduler 因依赖过多或约束不适合而失败，可以换成 vpu_top_no_ctrl、pdpu_top
#     等已经在 filelist 中、且相对完整的小顶层模块。
#   - 这只是脚本正确性 smoke test；最终仍需分别运行 SYN_TARGET=mxu 和 SYN_TARGET=axu，
#     再比较两个输出网表的 module 名交集，确认重名模块冲突已经消失。
#
# 常用正式综合命令：
#
#   1. 综合 mxu_top，输出到 ./build_mxu，并默认使用 mxu__ 前缀隔离内部子模块：
#        make clean SYN_TARGET=mxu
#        make flat  SYN_TARGET=mxu
#
#      检查 MXU 网表是否生成、是否有 mxu__ 前缀：
#        ls build_mxu/outputs/*_netlist.v
#        grep -n "^module mxu__" build_mxu/outputs/*_netlist.v | head
#
#   2. 综合 axu_top，输出到 ./build_axu，并默认使用 axu__ 前缀隔离内部子模块：
#        make clean SYN_TARGET=axu
#        make flat  SYN_TARGET=axu
#
#      检查 AXU 网表是否生成、是否有 axu__ 前缀：
#        ls build_axu/outputs/*_netlist.v
#        grep -n "^module axu__" build_axu/outputs/*_netlist.v | head
#
#   3. 综合 ariane_soc_top，输出到 ./build_top，默认不做 uniquify / change_names：
#        make clean SYN_TARGET=top
#        make flat  SYN_TARGET=top
#
#      检查顶层网表是否生成，并确认日志中显示 namespace/change_names 被关闭：
#        ls build_top/outputs/*_netlist.v
#        grep -E "namespace|change_names|TOP_MODULE|SYN_TARGET" build_top/flat_NONE.log
#
#   4. 如果需要从 checkpoint 继续，例如 MXU 从 post_constraints 继续：
#        make flat SYN_TARGET=mxu INCR_CHECKPOINT=post_constraints
#
#   5. 如果希望 MXU 和 AXU 同时综合，可以在两个 terminal 分别运行：
#        make flat SYN_TARGET=mxu
#        make flat SYN_TARGET=axu
#      它们会分别写入 build_mxu 和 build_axu，不会互相覆盖。
#
###############################################################################
# Ariane SoC Synthesis Makefile
###############################################################################

SHELL      := /bin/bash
DC_SHELL   := dcnxt_shell -64 -topographical_mode
SYN_ROOT   := $(shell pwd)
PROJ_ROOT  := $(shell cd .. && pwd)

SOC_CONFIG ?= minimum_my_mxu_axu

# Synthesis target selector:
#   mxu    -> TOP_MODULE=mxu_top, enable mxu__ namespace by default
#   axu    -> TOP_MODULE=axu_top, enable axu__ namespace by default
#   top    -> TOP_MODULE=ariane_soc_top, disable namespace/change_names by default
#   custom -> requires TOP_MODULE=<module_name>
SYN_TARGET ?= axu
TOP_MODULE ?=
BUILD_TAG  ?= $(SYN_TARGET)
BUILD_DIR  ?= $(SYN_ROOT)/build_$(BUILD_TAG)

NETLIST_NAMESPACE_PREFIX ?=
NETLIST_UNIQUIFY_ENABLE ?= auto
NETLIST_CHANGE_NAMES_ENABLE ?= auto

PDK_ROOT   ?= $(HOME)/workspace/work2026_2/work_for_tapeout_2026_v2/tsmc22
export PDK_ROOT

# Checkpoint to resume from (NONE = full compile from RTL)
# Valid: NONE, post_constraints, post_compile
INCR_CHECKPOINT ?= NONE

.PHONY: all flat flat_verbose gen_filelist check clean help

all: help

# ---------------------------------------------------------------------------
# gen_filelist: parse filelist.f → build/input.tcl
# ---------------------------------------------------------------------------
gen_filelist:
	@mkdir -p $(BUILD_DIR)
	python3 $(PROJ_ROOT)/scripts/gen_filelist.py \
		$(SYN_ROOT)/filelist.f \
		$(PROJ_ROOT) \
		--var SOC_CONFIG=$(SOC_CONFIG) \
		--format dc \
		-o $(BUILD_DIR)/input.tcl

# ---------------------------------------------------------------------------
# flat: flat synthesis
#   INCR_CHECKPOINT=NONE               → full compile from RTL (default)
#   INCR_CHECKPOINT=post_constraints   → resume: compile_ultra -incremental + report
#   INCR_CHECKPOINT=post_compile       → resume: re-run reports only
# ---------------------------------------------------------------------------
flat: gen_filelist
	@mkdir -p $(BUILD_DIR)/WORK
	@if [ "$(INCR_CHECKPOINT)" != "NONE" ]; then \
		if ! ls "$(BUILD_DIR)/outputs/"*_$(INCR_CHECKPOINT).ddc 2>/dev/null | grep -q .; then \
			echo "ERROR: No checkpoint DDC for '$(INCR_CHECKPOINT)' in $(BUILD_DIR)/outputs/."; \
			echo "       Run 'make flat SYN_TARGET=$(SYN_TARGET)' first (without INCR_CHECKPOINT)."; \
			exit 1; \
		fi; \
	fi
	$(DC_SHELL) \
		-x "set PDK_ROOT \"$(PDK_ROOT)\"; \
		    set SYN_ROOT \"$(SYN_ROOT)\"; \
		    set BUILD_DIR \"$(BUILD_DIR)\"; \
		    set SYN_MODE flat; \
		    set SYN_TARGET \"$(SYN_TARGET)\"; \
		    set TOP_MODULE_OVERRIDE \"$(TOP_MODULE)\"; \
		    set NETLIST_NAMESPACE_PREFIX_OVERRIDE \"$(NETLIST_NAMESPACE_PREFIX)\"; \
		    set NETLIST_UNIQUIFY_ENABLE \"$(NETLIST_UNIQUIFY_ENABLE)\"; \
		    set NETLIST_CHANGE_NAMES_ENABLE \"$(NETLIST_CHANGE_NAMES_ENABLE)\"; \
		    set INCR_CHECKPOINT \"$(INCR_CHECKPOINT)\"" \
		-f $(SYN_ROOT)/scripts/synth.tcl \
		2>&1 | tee $(BUILD_DIR)/flat_$(INCR_CHECKPOINT).log
	@echo "===== Flat synthesis done (SYN_TARGET=$(SYN_TARGET), INCR_CHECKPOINT=$(INCR_CHECKPOINT)). See $(BUILD_DIR)/ ====="

flat_verbose: gen_filelist
	@mkdir -p $(BUILD_DIR)/WORK
	@if [ "$(INCR_CHECKPOINT)" != "NONE" ]; then \
		if ! ls "$(BUILD_DIR)/outputs/"*_$(INCR_CHECKPOINT).ddc 2>/dev/null | grep -q .; then \
			echo "ERROR: No checkpoint DDC for '$(INCR_CHECKPOINT)' in $(BUILD_DIR)/outputs/."; \
			echo "       Run 'make flat SYN_TARGET=$(SYN_TARGET)' first (without INCR_CHECKPOINT)."; \
			exit 1; \
		fi; \
	fi
	$(DC_SHELL) \
		-x "set PDK_ROOT \"$(PDK_ROOT)\"; \
		    set SYN_ROOT \"$(SYN_ROOT)\"; \
		    set BUILD_DIR \"$(BUILD_DIR)\"; \
		    set SYN_MODE flat; \
		    set SYN_TARGET \"$(SYN_TARGET)\"; \
		    set TOP_MODULE_OVERRIDE \"$(TOP_MODULE)\"; \
		    set NETLIST_NAMESPACE_PREFIX_OVERRIDE \"$(NETLIST_NAMESPACE_PREFIX)\"; \
		    set NETLIST_UNIQUIFY_ENABLE \"$(NETLIST_UNIQUIFY_ENABLE)\"; \
		    set NETLIST_CHANGE_NAMES_ENABLE \"$(NETLIST_CHANGE_NAMES_ENABLE)\"; \
		    set INCR_CHECKPOINT \"$(INCR_CHECKPOINT)\"; \
		    set message_level info; \
		    set verbose true; \
		    set optimize_report_level high" \
		-f $(SYN_ROOT)/scripts/synth.tcl \
		2>&1 | tee $(BUILD_DIR)/flat_verbose_$(INCR_CHECKPOINT).log
	@echo "===== Flat verbose synthesis done (SYN_TARGET=$(SYN_TARGET), INCR_CHECKPOINT=$(INCR_CHECKPOINT)). See $(BUILD_DIR)/ ====="

# ---------------------------------------------------------------------------
# check: verify all source files in filelist.f exist
# ---------------------------------------------------------------------------
check:
	@echo "--- Filelist integrity check ---"
	@python3 $(PROJ_ROOT)/scripts/gen_filelist.py \
		$(SYN_ROOT)/filelist.f $(PROJ_ROOT) \
		--format dc -o /dev/null && \
		echo "gen_filelist.py parse OK"
	@count=0; err=0; \
	while IFS= read -r f; do \
		if [ ! -f "$$f" ]; then echo "MISSING: $$f"; err=1; fi; \
		count=$$((count+1)); \
	done < <(python3 $(PROJ_ROOT)/scripts/gen_filelist.py \
		$(SYN_ROOT)/filelist.f $(PROJ_ROOT) --format dc -o /dev/null --check 2>/dev/null); \
	echo "Total source files checked: $$count"; \
	if [ "$$err" -eq 0 ]; then echo "All files exist."; else echo "Some files are MISSING!"; exit 1; fi

# ---------------------------------------------------------------------------
# clean
# ---------------------------------------------------------------------------
clean:
	rm -rf $(BUILD_DIR)
	rm -f *.svf *.pvl *.syn *.mr *.log command.log default.svf
	rm -rf alib-52

# ---------------------------------------------------------------------------
# help
# ---------------------------------------------------------------------------
help:
	@echo "Ara SoC DC NXT Synthesis"
	@echo ""
	@echo "Targets:"
	@echo "  make flat                       Flat synthesis from RTL"
	@echo "  make flat_verbose               Flat synthesis with verbose DC logging"
	@echo "  make gen_filelist               Parse filelist.f → build/input.tcl"
	@echo "  make check                      Verify filelist integrity"
	@echo "  make clean                      Remove selected build directory"
	@echo ""
	@echo "Variables:"
	@echo "  SYN_TARGET=<mxu|axu|top|custom> Target selector (default: axu)"
	@echo "  TOP_MODULE=<module>             Required only for SYN_TARGET=custom; overrides target map"
	@echo "  BUILD_TAG=<tag>                 Build directory suffix (default: SYN_TARGET)"
	@echo "  BUILD_DIR=<path>                Build directory (default: build_<BUILD_TAG>)"
	@echo "  NETLIST_NAMESPACE_PREFIX=<pfx>  Override uniquify prefix"
	@echo "  NETLIST_UNIQUIFY_ENABLE=<auto|0|1>       Namespace control (default: auto)"
	@echo "  NETLIST_CHANGE_NAMES_ENABLE=<auto|0|1>   change_names control (default: auto)"
	@echo "  PDK_ROOT=<path>                 PDK root (default: \$$HOME/workspace/tsmc22)"
	@echo "  INCR_CHECKPOINT=<phase>         NONE, post_constraints, post_compile"
	@echo ""
	@echo "Examples:"
	@echo "  make flat SYN_TARGET=mxu"
	@echo "  make flat SYN_TARGET=axu"
	@echo "  make flat SYN_TARGET=top"
	@echo "  make flat SYN_TARGET=custom TOP_MODULE=pdpu_top BUILD_TAG=probe NETLIST_NAMESPACE_PREFIX=probe__"
	@echo "  make flat SYN_TARGET=mxu INCR_CHECKPOINT=post_constraints"
