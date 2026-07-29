class my_monitor extends uvm_monitor;

	`uvm_component_utils(my_monitor)

	virtual dut_interface m_vif;
	my_transaction tr;

	`ifdef PUT
		uvm_blocking_put_port #(my_transaction) m2r_port;
	`elsif GET
		uvm_blocking_get_imp #(my_transaction, my_monitor) i_m2r_import;
		my_transaction tr_fifo[$];
	`else
		uvm_blocking_put_port #(my_transaction) m2r_port;
	`endif  

	function new(string name = "", uvm_component parent);
		super.new(name, parent);
		`ifdef GET
			this.i_m2r_import = new("i_m2r_import", this);
		`else 
			this.m2r_port = new("m2r_port", this);		
		`endif	
	endfunction

	`ifdef GET
		virtual task get(output my_transaction mtr);
			while(tr_fifo.size() == 0) @(m_vif.imonitor_cb);
			mtr = tr_fifo.pop_front();
			`uvm_info("MONI_REPORT", {"\n", "monitor have been sent a transaction:\n", mtr.sprint()}, UVM_MEDIUM)
		endtask

	`endif


	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("TRACE", $sformatf("%m"), UVM_HIGH)
		if(!uvm_config_db#(virtual dut_interface)::get(this, "", "m_vif", m_vif)) begin
			`uvm_fatal("DRIVER_FATAL", "my_monitor can not get dut_interface!!!")
		end

		tr = my_transaction::type_id::create("tr");
	endfunction

	virtual task run_phase(uvm_phase phase);
		
		int active_port;
		logic [7:0] temp;
		int count;

		forever begin
			`uvm_info("MON_RUN_PHASE", "Monitor run !", UVM_MEDIUM)
			active_port = -1;
			count = 0;
			#100;

			
			//wait for bus active
			while(1) begin
				@(m_vif.imonitor_cb);
				foreach(m_vif.imonitor_cb.frame_n[i]) begin
					if(m_vif.imonitor_cb.frame_n[i] == 0) begin
						active_port = i;
					end
				end
				if(active_port != -1) begin
					break;
				end
			end

			//get the active port
			tr.sa = active_port;
			//get the target addr
			for(int i = 0; i < 4; i++) begin
				tr.da[i] = m_vif.imonitor_cb.din[tr.sa];
				@(m_vif.imonitor_cb);
			end

			//get the payload
			forever begin
				if(m_vif.imonitor_cb.valid_n[tr.sa] == 0) begin
					temp[count] = m_vif.imonitor_cb.din[tr.sa];
					count++;
					if(count == 8) begin
						tr.payload.push_back(temp);
						count = 0;
					end
				end

				if(m_vif.imonitor_cb.frame_n[tr.sa]) begin
					if(count != 0) begin
						tr.payload.push_back(temp);
						`uvm_warning("PAYLOAD WARING", "Payload not byte aligned !!!")
					end
					break;
				end
				@(m_vif.imonitor_cb);
			end
			`uvm_info("Monitor", {"\n", "Monitor Got An Input Transaction:\n", tr.sprint()}, UVM_MEDIUM)
			`ifndef GET
				`uvm_info("Monitor", "Now monitot send the transaction to the reference mdoel!", UVM_MEDIUM)
				this.m2r_port.put(tr);
			`else
				tr_fifo.push_back(tr);
			`endif 
		end
	endtask

endclass:my_monitor
