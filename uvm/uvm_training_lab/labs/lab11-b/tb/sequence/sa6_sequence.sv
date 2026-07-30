class sa6_sequence extends uvm_sequence #(my_transaction);

	`uvm_object_utils(sa6_sequence)
    //`uvm_add_to_seq_lib(sa6_sequence, my_sequence_lib)

	sequence_config m_sequence_config;
	int item_num = 5;

	function new(string name = "sa6_sequence");
		super.new(name);
	endfunction

	virtual task body();
		
		my_transaction tr;

		if(!uvm_config_db #(sequence_config)::get(m_sequencer, "", "sequence_config", m_sequence_config)) begin
			`uvm_fatal("SEQUENCE_FATAL", "The sa6 sequence can not get sequence config")
		end

		if(starting_phase != null)
			starting_phase.raise_objection(this);//控制body的启动
		
		item_num = m_sequence_config.item_num;
		`uvm_info("sequence body", $sformatf("item=%0d", item_num), UVM_MEDIUM)
		repeat(item_num) begin
			//`uvm_do(req)  //do代表调用一次transaction
			tr = my_transaction::type_id::create("tr");
			start_item(tr);
			tr.randomize() with {tr.sa == 6;};
			finish_item(tr);

			get_response(rsp);

			`uvm_info("SEQUENCE_RESPOSE", {"\n","Get Respose:\n", rsp.sprint()}, UVM_MEDIUM)

		end

		#100;
		if(starting_phase != null)
			starting_phase.drop_objection(this);//控制body的停止
	endtask


endclass:sa6_sequence
