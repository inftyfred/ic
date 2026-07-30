class my_driver extends uvm_driver #(my_transaction);

	`uvm_component_utils(my_driver)
	`uvm_register_cb(my_driver, driver_base_callback)

	virtual dut_interface m_vif;
	int unsigned pad_cycles;

	function new(string name = "my_driver", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		if(!uvm_config_db#(virtual dut_interface)::get(this, "", "m_vif", m_vif)) begin//获取接口
			`uvm_fatal("DRIVER_FATAL", "my_driver can not get dut_interface!!!")
		end
		if(!uvm_config_db#(int unsigned)::get(this, "", "pad_cycles", pad_cycles)) begin
			`uvm_fatal("DRIVER_FATAL", "my_driver can not get pad_cycles !!!")
		end
	endfunction

	virtual task pre_reset_phase(uvm_phase phase);

		super.pre_reset_phase(phase);
		`uvm_info("TRACE", $sformatf("%m"), UVM_MEDIUM);
		phase.raise_objection(this);
		m_vif.driver_cb.frame_n <= 'x;
		m_vif.driver_cb.valid_n <= 'x;
		m_vif.driver_cb.din		<= 'x;
		m_vif.driver_cb.reset_n	<= 'x;
		phase.drop_objection(this);

	endtask

	virtual task reset_phase(uvm_phase phase);

		super.reset_phase(phase);
		`uvm_info("TRACE", $sformatf("%m"), UVM_MEDIUM);
		phase.raise_objection(this);
		m_vif.driver_cb.frame_n <= '1;
		m_vif.driver_cb.valid_n <= '1;
		m_vif.driver_cb.din		<= '0;
		m_vif.driver_cb.reset_n	<= '1;
		repeat(5)@(m_vif.driver_cb);
		m_vif.driver_cb.reset_n <= '0;
		repeat(5)@(m_vif.driver_cb);
		m_vif.driver_cb.reset_n <= '1;
		phase.drop_objection(this);

	endtask

	virtual task run_phase(uvm_phase phase);
		logic	[7:0]	temp;
		`uvm_info("DRV", "Driver run_phase started!", UVM_LOW)		
		repeat(15)@(m_vif.driver_cb);
		forever begin
			seq_item_port.get_next_item(req); //获取一个transaction，通过req引用
			`uvm_info("\nDRV_RUN_PHASE", req.sprint(), UVM_MEDIUM) //打印transaction信息
			`uvm_do_callbacks(my_driver, driver_base_callback, pre_send(this));
			#100;
			//send address
			m_vif.driver_cb.frame_n[req.sa] <= 1'b0;
			for(int i = 0; i < 4; i++) begin
				m_vif.driver_cb.din[req.sa] <= 1'b1;
				@(m_vif.driver_cb);
			end
			//send pad
			m_vif.driver_cb.din[req.sa] <= 1'b1;
			m_vif.driver_cb.valid_n[req.sa] <= 1'b1;
			repeat(pad_cycles) @(m_vif.driver_cb); //使用变量
			//send payload
			while(!m_vif.driver_cb.busy_n[req.sa])@(m_vif.driver_cb);
			foreach(req.payload[index]) begin
				temp = req.payload[index];
				for(int i = 0; i < 8; i++) begin
					m_vif.driver_cb.din[req.sa] <= temp[i];
					m_vif.driver_cb.valid_n[req.sa] <= 1'b0;
					m_vif.driver_cb.frame_n[req.sa] <= ((req.payload.size()-1 == index) && (i==7));
					@(m_vif.driver_cb);
				end
			end
			m_vif.driver_cb.valid_n[req.sa] <= 1'b1;

			//response
			rsp = my_transaction::type_id::create("rsq");
			$cast(rsp, req.clone());
			rsp.set_id_info(req); //关联事务与响应
			seq_item_port.put_response(rsp);

			`uvm_do_callbacks(my_driver, driver_base_callback, post_send());

			seq_item_port.item_done(); //通知sequencer该事务已经处理完毕
		end
	endtask

endclass:my_driver
