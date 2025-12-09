# Makefile
.PHONY: compile run clean sim help cleanall

compile:
	@echo "编译项目..."
	./scripts/compile.sh

run:
	@echo "运行仿真..."
	./scripts/run.sh $(ARGS)

clean:
	@echo "清理生成文件..."
	rm -rf build/ wave/ logs/ *.log *.fsdb *.vcd csrc

sim:
	@echo "using verdi to sim..."
	./scripts/verdi.sh


cleanall:
	@echo "clean all file..."
	rm -rf build/ wave/ logs/ *.log *.fsdb *.vcd csrc/ novas* verdiLog/

help:
	@echo "可用目标:"
	@echo "  compile    - 编译项目"
	@echo "  run        - 运行仿真 (使用 ARGS= 传递参数)"
	@echo "  clean      - 清理生成文件"
	@echo "  help       - 显示此帮助"
	
# 使用示例:
# make compile
# make run ARGS="-t smoke_test -w fsdb"
