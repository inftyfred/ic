class my_driver extends uvm_driver #(my_transaction);

	`uvm_component_utils(my_driver)

	function new(string name = "my_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual task reset_phase(uvm_phase phase);
		phase.raise_objection(this);
		#100;
		`uvm_info("DRV_RESET_PHASE","Now driver reset the DUT...", UVM_MEDIUM)
		phase.drop_objection(this);
	endtask

	virtual task configure_phase(uvm_phase phase);
		phase.raise_objection(this);
		#100;
		`uvm_info("DRV_CONFIGURE_PHASE", "Now driver config the DUT...", UVM_MEDIUM)
		phase.drop_objection(this);
	endtask

	virtual task run_phase(uvm_phase phase);
		#3000;
		`uvm_info("DRV", "Driver run_phase started!", UVM_LOW)
		forever begin
			seq_item_port.get_next_item(req); //获取一个transaction，通过req引用
			`uvm_info("DRV_RUN_PHASE", req.sprint(), UVM_MEDIUM) //打印transaction信息
			#100
			seq_item_port.item_done(); //通知sequencer该事务已经处理完毕
		end
	endtask


endclass:my_driver
