#####################################################################################
# Description:  Behavorial-level Simulation Script
# Author:     	Mingxuan Li <mingxuanli_siris@163.com> [Peking University]
#####################################################################################

### check whether TOP is defined
ifndef TOP
$(error ERROR!!! TOP variable is not defined. Please define the top-level module name by TOP=<name>_tb)
endif

### check whether TOP is testbench
CHECK_SUFFIX = $(shell echo ${TOP} | grep -q "_tb" && echo "yes" || echo "no")
ifneq (${CHECK_SUFFIX}, yes)
$(error ERROR!!! TOP variable is not suffixed by "_tb". Please define the top-level module name by TOP=<name>_tb)
endif

### Makefile absolute dir
ifndef SRC_DIR
export SRC_DIR = $(PWD)/../src
endif

### define memory initialization file
ifndef INIT_MEM
INIT_MEM = init_mem.hex
$(warning WARNING! INIT_MEM variable not defined, using default name: ${INIT_MEM})
endif

SRC_LIST = -file ${SRC_DIR}/filelist.f		### Filelist of Source RTL, RTL must be absolute dir!!!

VCS_OPTIONS = -full64						### run under 64-bit mode
VCS_OPTIONS += +v2k							### enable new Verilog constructs in the 1364-2001 standard
VCS_OPTIONS += -sverilog					### enable systemberilog syntax
VCS_OPTIONS += -l compile.log				### name of log file
VCS_OPTIONS += -timescale=1ps/1ps			### timescale for all RTL
VCS_OPTIONS += +notimingcheck				### neglect timing
VCS_OPTIONS += -assert svaext				### enable systemverilog assertion
VCS_OPTIONS += +lint=TFIPC-L				### print out detailed information of unconnected ports
VCS_OPTIONS += +lint=PCWM					### details about port connection width mismatch
VCS_OPTIONS += +define+SIM					### test for this definition in RTL using the `ifdef compiler directive
VCS_OPTIONS += -debug_access+dmptf			### enable dumping of ports and internal nodes/memories
VCS_OPTIONS += -debug_region+cell+encrypt	### apply debug capabilities to modules, programs, packages, and interfaces

vcs:
	sed -i '94s|\$readmemh(".*", init_val);|\$readmemh("${SRC_DIR}/../sim/${INIT_MEM}", init_val);|' ${SRC_DIR}/soc/misc/tc_sram.sv
	mkdir -p build && \
	cd build && rm -rf * && \
	csh -c "vcs ${VCS_OPTIONS} ${SRC_LIST} -top ${TOP} -R"

verdi: vcs
	cd build && \
	csh -c "verdi -sv +define+SIM ${SRC_LIST} -top ${TOP} -ssf waveform.fsdb"

clean:
	rm -rf build/*


.PHONY: clean
