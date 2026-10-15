# Simulation template configuration
# Override on the command line, for example:
#   make compile TESTNAME=tb_pc_counter COMPILE_EXTRA='+memcblk -j8'
#   make compile GEN_FILELIST=0

TESTNAME ?= dma_controller_tb
GEN_FILELIST ?= 1
COMPILE_EXTRA ?= -j8 -timescale=1ns/1ps
SIM_EXTRA ?=
FILELIST_AUTO ?= build/filelist.auto.f
FILELIST_MANUAL ?= build/filelist.manual.f
FSDB ?= sim/$(TESTNAME).fsdb

export TESTNAME GEN_FILELIST COMPILE_EXTRA SIM_EXTRA
export FILELIST_AUTO FILELIST_MANUAL FSDB

.PHONY: compile sim verdi verdireload clean cleansim cleanall help

compile:
	@echo "vcs编译中……"
	@mkdir -p build/
	@env TESTNAME='$(TESTNAME)' GEN_FILELIST='$(GEN_FILELIST)' COMPILE_EXTRA='$(COMPILE_EXTRA)' FILELIST_AUTO='$(FILELIST_AUTO)' FILELIST_MANUAL='$(FILELIST_MANUAL)' tclsh script/vcs_compile.tcl

sim: compile
	@echo "正在产生fsdb文件……"
	@mkdir -p sim/
	@env TESTNAME='$(TESTNAME)' SIM_EXTRA='$(SIM_EXTRA)' FSDB='$(FSDB)' tclsh script/sim.tcl

verdi:
	@echo "启动verdi中……"
	@mkdir -p sim/
	@env TESTNAME='$(TESTNAME)' GEN_FILELIST='$(GEN_FILELIST)' FSDB='$(FSDB)' FILELIST_AUTO='$(FILELIST_AUTO)' FILELIST_MANUAL='$(FILELIST_MANUAL)' tclsh script/verdi.tcl > sim/verdi_$(TESTNAME).log 2>&1 &
	@echo "已进入后台运行"

verdireload:
	@echo "加载波形中……"
	@mkdir -p sim/verdiLog
	@cd sim/verdiLog && verdi -nologo -ssr novas_autosave.ses

help:
	@echo "make compile [TESTNAME=tb_name] [GEN_FILELIST=0|1] [COMPILE_EXTRA='+memcblk -j8']"
	@echo "make sim [SIM_EXTRA='+arg'] [FSDB=dump.fsdb]"
	@echo "make verdi [FSDB=sim/dump.fsdb]"
	@echo "GEN_FILELIST=0 时使用 build/filelist.manual.f，不会覆盖自动 filelist。"

clean:
	@echo "正在清理build文件（build/）……"
	@find build/ -mindepth 1 -maxdepth 1 ! -name 'filelist.manual.f' -exec rm -rf {} +

cleansim:
	@echo "正在清理仿真文件（sim/）……"
	@rm -rf sim/

cleanall:
	@echo "正在清理生成文件（build/、sim/）……"
	@rm -rf build/ sim/
