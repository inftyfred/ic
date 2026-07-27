class my_monitor extends uvm_monitor;

	`uvm_component_utils(my_monitor)

	virtual dut_interface m_vif;

	function new(string name = "", uvm_component parent);
		super.new(name, parent);
	endfunction

	virtual function void build_phase(uvm_phase phase);
		super.build_phase(phase);
		`uvm_info("TRACE", $sformatf("%m"), UVM_HIGH)
		if(!uvm_config_db#(virtual dut_interface)::get(this, "", "m_vif", m_vif)) begin
			`uvm_fatal("DRIVER_FATAL", "my_monitor can not get dut_interface!!!")
		end
	endfunction

	virtual task run_phase(uvm_phase phase);
		my_transaction tr;
		int active_port;
		logic [7:0] temp;
		int count;

		forever begin
			`uvm_info("MON_RUN_PHASE", "Monitor run !", UVM_MEDIUM)
			active_port = -1;
			count = 0;
			#100;

			tr = my_transaction::type_id::create("tr");
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
		end
	endtask

endclass:my_monitor
