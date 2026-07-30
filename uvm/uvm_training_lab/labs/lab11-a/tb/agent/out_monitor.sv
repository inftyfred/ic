class out_monitor extends uvm_monitor;

    `uvm_component_utils(out_monitor)

    virtual dut_interface m_vif;

    uvm_blocking_put_port #(my_transaction) m2s_port;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        m2s_port = new("m2s_port", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        `uvm_info("TRACE", $sformatf("%m"), UVM_MEDIUM);
        if(!uvm_config_db#(virtual dut_interface)::get(this, "", "m_vif", m_vif)) begin
            `uvm_fatal("CONFIG_FATAL", "Out monitor can not get dut_interface")
        end
    endfunction

    virtual task run_phase(uvm_phase phase);

        my_transaction tr;
        int active_port;
        logic [7:0] temp;
        int count;

        forever begin
            active_port = -1;
            count = 0;

            tr = my_transaction::type_id::create("tr");

            //wait for bus active
            while(1) begin
                @(m_vif.omonitor_cb);
                foreach(m_vif.omonitor_cb.frameo_n[i]) begin
                    if(m_vif.omonitor_cb.frameo_n[i] == 0) begin
                        active_port = i;
                    end
                end
                if(active_port != -1) begin
                    break;
                end
            end

            tr.da = active_port;

            //get the payload
            forever begin
                if(m_vif.omonitor_cb.valido_n[tr.da] == 0) begin
                    temp[count] = m_vif.omonitor_cb.dout[tr.da];
                    count++;
                    if(count == 8) begin
                        tr.payload.push_back(temp);
                        count = 0;
                    end
                end

                if(m_vif.omonitor_cb.valido_n[tr.da]) begin
                    if(count != 0) begin
                        tr.payload.push_back(temp);
                        `uvm_warning("PAYLOAD_WARNING", "Payload not byte aligned !!!")
                    end
                    `uvm_info("Out_Monitor", {"\n", "out monitor got An Output Transaction:\n", tr.sprint()}, UVM_HIGH)
                    `uvm_info("Out_Monitor", "Now Out Monitor send the transaction to the Scoreboard", UVM_HIGH)
                    this.m2s_port.put(tr);
                    break;
                end
                @(m_vif.omonitor_cb);
            end

            // `uvm_info("Out_Monitor", {"\n", "out monitor got An Output Transaction:\n", tr.sprint()}, UVM_MEDIUM)
            // `uvm_info("Out_Monitor", "Now Out Monitor send the transaction to the Scoreboard", UVM_MEDIUM)
            // this.m2s_port.put(tr);
        end
    endtask

endclass:out_monitor