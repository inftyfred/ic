# ic
ic study


## structure of prj



--ic

--systemverilog

..verilog

	.src

	.tb

	.makefile

	.scripts

## scripts

- compile.sh: vcs compile
- run.sh: run code and generate fsdb file
- verdi.sh: use verdi to sim and look wave
- used by makefile

## makefile
use:
	`make [commend]`

commend can be :
- compile
- run
- sim
- clean		: clean compile and run files
- cleanall  : clean all files(include sim files)
- help







