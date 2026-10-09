SCRIPTS_DIR = ./scripts
DEFAULT_ARGS_COMPILE =
DEFAULT_ARGS_RUN =

.PHONY: all compile run clean help

all: compile run

compile:
	@ARGS="$(DEFAULT_ARGS_COMPILE) $(ARGS)" $(SCRIPTS_DIR)/compile.sh

run:
	@ARGS="$(DEFAULT_ARGS_RUN) $(ARGS)" $(SCRIPTS_DIR)/run.sh

clean:
	rm -rf build/ logs/ fsdb_wave/ csrc/ *.log

help:
	@echo "make compile | make run | make all | make clean"
