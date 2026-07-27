class my_sequence extends uvm_sequence #(my_transaction);

	`uvm_object_utils(my_sequence)

	sequence_config m_sequence_config;
	int item_num;

	function new(string name = "my_sequence");
		super.new(name);
	endfunction

	function void pre_randomize();
		if(!uvm_config_db #(sequence_config)::get(m_sequencer, "", "sequence_config", m_sequence_config)) begin
			`uvm_fatal("SEQUENCE_FATAL", "The sequence can not get sequence config")
		end
	endfunction

	virtual task body();
		
		if(starting_phase != null)
			starting_phase.raise_objection(this);//控制body的启动
		
		item_num = m_sequence_config.item_num;
		`uvm_info("sequence body", $sformatf("item=%0d", item_num), UVM_MEDIUM)
		repeat(item_num) begin
			`uvm_do(req)  //do代表调用一次transaction
		end

		#100;
		if(starting_phase != null)
			starting_phase.drop_objection(this);//控制body的停止
	endtask


endclass:my_sequence
