class slave_agent extends uvm_agent;

    `uvm_component_utils(slave_agent)

    out_monitor m_moni;

    agent_config m_agent_config;

    uvm_blocking_put_export #(my_transaction) s_a2s_export;


    function new(string name = "", uvm_component parent);
        super.new(name, parent);
        this.s_a2s_export = new("s_a2s_export", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db#(agent_config)::get(this, "", "m_agent_config", m_agent_config)) begin
            `uvm_fatal("CONFIG_FATAL", "slave_agent can not get the configuration")
        end

        uvm_config_db#(virtual dut_interface)::set(this, "m_moni", "m_vif", m_agent_config.m_vif);

        m_moni = out_monitor::type_id::create("m_moni", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        m_moni.m2s_port.connect(this.s_a2s_export);
    endfunction

endclass:slave_agent