SCRIPTS_DIR = ./scripts
DEFAULT_ARGS_COMPILE = -cm line+tgl
DEFAULT_ARGS_RUN     = -cm line+tgl
.DEFAULT_ARGS_SIM    =

.PHONY: all compile run clean sim simreload help cleanall

all: compile run

compile:
	@echo "Compile project..."
	ARGS="$(DEFAULT_ARGS_COMPILE) $(ARGS)" $(SCRIPTS_DIR)/compile.sh

run:
	@echo "Run simulation..."
	ARGS="$(DEFAULT_ARGS_RUN) $(ARGS)" $(SCRIPTS_DIR)/run.sh

clean:
	rm -rf build/ wave/ logs/ *.log *.fsdb *.vcd csrc fsdb_wave/

sim:
	@echo "using verdi to sim..."
	ARGS="$(DEFAULT_ARGS_SIM) $(ARGS)" $(SCRIPTS_DIR)/verdi.sh

simreload:
	$(SCRIPTS_DIR)/verdi.sh --reload

cleanall: clean
	rm -rf novas* verdiLog/

help:
	@echo "make compile | make run | make sim | make clean"
