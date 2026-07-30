class my_test extends uvm_test;
	
	`uvm_component_utils(my_test)

	my_env m_env;
	env_config m_env_config;
	sequence_config m_sequence_config;
	my_sequence m_sequence;

	function new(string name = "", uvm_component parent);
		super.new(name, parent);
		m_env_config = new("m_env_config");
		m_sequence_config = new("m_sequence_config");
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		m_env = my_env::type_id::create("m_env", this);

		my_sequence_lib::add_typewide_sequence(sa6_sequence::get_type());
		my_sequence_lib::add_typewide_sequence(da3_sequence::get_type());

		//config 启动sequence
		uvm_config_db#(uvm_object_wrapper)::set(
						this, "*.m_seqr.run_phase", 
						"default_sequence", my_sequence_lib::get_type());

		//uvm_config_db#(int)::set(this, "*.m_seqr", "item_num", 10);

		m_env_config.is_coverage 	= 1;
		m_env_config.is_check		= 1;
		m_env_config.m_agent_config.is_active = UVM_ACTIVE;
		m_env_config.m_agent_config.pad_cycles = 10;

		m_sequence_config.item_num = 5;

		uvm_config_db#(sequence_config)::set(this, "m_env.m_agent.m_seqr", "sequence_config", m_sequence_config);

		if(!uvm_config_db#(virtual dut_interface)::get(this, "", "top_if", m_env_config.m_agent_config.m_vif)) begin
			`uvm_fatal("CONFIG_ERROR", "test can not get the indterface")
		end

		uvm_config_db#(env_config)::set(this, "m_env", "env_config", m_env_config);

	endfunction

	virtual function void start_of_simulation_phase(uvm_phase phase);
		super.start_of_simulation_phase(phase);
		uvm_top.print_topology(uvm_default_table_printer); //打印uvm结构 table or tree
	endfunction

	// virtual task run_phase(uvm_phase phase);
	// 	super.run_phase(phase);//可有可无
	// 	m_sequence = my_sequence::type_id::create("m_sequence");
	// 	phase.raise_objection(this);
	// 	m_sequence.start(m_env.m_agent.m_seqr);
	// 	phase.drop_objection(this);
	// endtask

endclass:my_test
