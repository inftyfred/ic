#############################
# User variables
#############################
TB       = tb1
SEED     = 1
DFILES   = ../mcdt/v1/{arbiter.v,slave_fifo.v,mcdt.v}
VFILES   = $(TB).v


#############################
# Environment variables
#############################
VCOMP                = vlogan -full64 -sverilog -timescale=1ps/1ps -nc -l comp.log 
ELAB                 = vcs -full64 -debug_all -l elab.log -sim_res=1ps 
RUN                  = $(TB).simv -l run.log -sml +ntb_random_seed=$(SEED)

comp:
	$(VCOMP) $(DFILES) $(VFILES)

elab: 
	$(ELAB) -top $(TB) -o $(TB).simv

run:
	$(RUN) 

rung:
	$(RUN) -gui

clean:
	rm -rf AN.DB DVEfiles csrc *.simv *.simv.daidir ucli.key
	rm -rf *.log* *.vpd 


