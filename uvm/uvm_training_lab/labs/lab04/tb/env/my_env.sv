class my_env extends uvm_env;
	
	`uvm_component_utils(my_env)

	master_agent m_agent;

	function new(string name = "", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_agent = master_agent::type_id::create("m_agent", this);
	endfunction

endclass:my_env
