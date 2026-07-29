class master_agent extends uvm_agent;

	`uvm_component_utils(master_agent)

	my_sequencer m_seqr;
	my_driver	 m_driv;
	my_monitor   m_moni;
	agent_config m_agent_config;
	// `ifdef GET
	// 	uvm_blocking_get_export #(my_transaction) m_a2r_export;
	// `else
	uvm_blocking_put_export #(my_transaction) m_a2r_export;
	//`endif 

	function new(string name = "", uvm_component parent);
		super.new(name, parent);
		this.m_a2r_export = new("m_a2r_export", this);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(agent_config)::get(this, "", "m_agent_config", m_agent_config)) begin
			`uvm_fatal("CONFIG_FATAL", "master_agent can not get the configuration !!!")
		end

		is_active = m_agent_config.is_active;

		uvm_config_db#(int unsigned)::set(this, "m_driv", "pad_cycles", m_agent_config.pad_cycles);
		uvm_config_db#(virtual dut_interface)::set(this, "m_driv", "m_vif", m_agent_config.m_vif);
		uvm_config_db#(virtual dut_interface)::set(this, "m_moni", "m_vif", m_agent_config.m_vif);

		if(is_active == UVM_ACTIVE) begin
			m_seqr = my_sequencer::type_id::create("m_seqr", this);
			m_driv = my_driver::type_id::create("m_driv", this);
		end
		m_moni = my_monitor::type_id::create("m_moni", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		if(is_active == UVM_ACTIVE)
			m_driv.seq_item_port.connect(m_seqr.seq_item_export);
		m_moni.m2r_port.connect(this.m_a2r_export);
	endfunction

endclass:master_agent
