UVM_HOME    = /home/infty/ic/uvm/uvm_training_lab/uvm-1.1d

include /home/infty/ic/uvm/uvm_training_lab/uvm-1.1d/examples/Makefile.vcs

all: comp run 

comp:
	$(VCS) +incdir+./ \
		test.sv

run:
	$(SIMV) +UVM_TESTNAME=my_test 
    ##$(CHECK)

clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log













