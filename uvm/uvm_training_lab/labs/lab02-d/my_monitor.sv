class my_monitor extends uvm_monitor;

	`uvm_component_utils(my_monitor)

	function new(string name = "", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task reset_phase(uvm_phase phase);
		#150;
		`uvm_info("MON_RESET_PHASE", "Monitor rest!", UVM_MEDIUM)
	endtask
	
	virtual task run_phase(uvm_phase phase);
		forever begin
			`uvm_info("MON_RUN_PHASE", "Monitor run !", UVM_MEDIUM)
			#100;
		end
	endtask

endclass:my_monitor
