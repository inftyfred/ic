# Makefil
# 目录配置
SCRIPTS_DIR = ./scripts
#默认附加参数 支持通过命令行添加额外的临时参数  如：+vcs+finish+500us
DEFAULT_ARGS_COMPILE = -cm line+tgl
DEFAULT_ARGS_RUN = -cm line+tgl +UVM_TESTNAME=mcdt_test 
DEFAULT_ARGS_SIM = 

.PHONY: all compile run clean sim simreload help cleanall cov

all: compile run

compile:
	@echo "编译项目..."
	ARGS="$(DEFAULT_ARGS_COMPILE) $(ARGS)"		\
	$(SCRIPTS_DIR)/compile.sh 

run:
	@echo "运行仿真..."
	ARGS="$(DEFAULT_ARGS_RUN) $(ARGS)"		\
	$(SCRIPTS_DIR)/run.sh 

clean:
	@echo "清理生成文件..."
	rm -rf build/ wave/ logs/ *.log *.fsdb *.vcd csrc

sim:
	@echo "using verdi to sim..."
	ARGS="$(DEFAULT_ARGS_SIM) $(ARGS)"		\
	$(SCRIPTS_DIR)/verdi.sh 

simreload:
	@echo "using verdi to reload wave..."
	$(SCRIPTS_DIR)/verdi.sh --reload

cov:
	@echo "using dve look coverage"
	dve -covdir build/simv.vdb -full64 &   

cleanall:
	@echo "clean all file..."
	rm -rf build/ wave/ logs/ *.log *.fsdb *.vcd csrc/ novas* verdiLog/ fsdb_wave/ DVEfiles/ vdCovLog/

help:
	@echo "可用目标:"
	@echo "  compile    - 编译项目 (使用 ARGS= 传递参数)"
	@echo "  run        - 运行仿真 (使用 ARGS= 传递参数)"
	@echo "  sim        - 使用verdi查看波形(使用 ARGS= 传递参数)"
	@echo "  simreload  - 加载之前的波形文件（verdiLog/*ses）"
	@echo "  clean      - 清理生成文件,不包括verdi波形文件"
	@echo "  cleanall   - 清理所有生成的文件"
	@echo "  help       - 显示此帮助"
	
# 使用示例:
# make compile
# make run ARGS="+seed=60"
