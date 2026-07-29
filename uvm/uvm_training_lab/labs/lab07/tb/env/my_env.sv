class my_env extends uvm_env;
	
	`uvm_component_utils(my_env)

	master_agent m_agent;
	env_config m_env_config;
	my_reference_model m_reference_model;

	function new(string name = "", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);

		if(!uvm_config_db#(env_config)::get(this, "", "env_config", m_env_config)) begin
			`uvm_fatal("CONFIG_FATAL", "ENV can not get the configuration!!!");
		end

		uvm_config_db#(agent_config)::set(this, "m_agent", "m_agent_config", m_env_config.m_agent_config);

		if(m_env_config.is_coverage) begin
			`uvm_info("COVERAGE_ENABLE", "The function coverage is enabled for this testcase", UVM_MEDIUM)
		end
		if(m_env_config.is_check) begin
			`uvm_info("CHECK_ENABLE", "The check function is enabled for this testcase", UVM_MEDIUM)
		end

		m_agent = master_agent::type_id::create("m_agent", this);
		m_reference_model = my_reference_model::type_id::create("m_reference_model", this);
	endfunction

	virtual function void connect_phase(uvm_phase phase);
		super.connect_phase(phase);
		`uvm_info("ENV", "Connect the agent and reference model...", UVM_MEDIUM)
		`ifdef GET
			m_reference_model.m2r_port.connect(m_agent.m_a2r_export);
			//m_agent.m_a2r_export.connect(m_reference_model.m2r_port);
		`else
			m_agent.m_a2r_export.connect(m_reference_model.i_m2r_imp);
		`endif
	endfunction

endclass:my_env
