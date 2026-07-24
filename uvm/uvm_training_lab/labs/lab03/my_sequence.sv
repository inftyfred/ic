class my_sequence extends uvm_sequence #(my_transaction);

	`uvm_object_utils(my_sequence)

	function new(string name = "my_sequence");
		super.new(name);
	endfunction

	virtual task body();
		
		if(starting_phase != null)
			starting_phase.raise_objection(this);//控制body的启动
		
		repeat(10) begin
			`uvm_do(req)  //do代表调用一次transaction
		end

		#100;
		if(starting_phase != null)
			starting_phase.drop_objection(this);//控制body的停止
	endtask


endclass:my_sequence
