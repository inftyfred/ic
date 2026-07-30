class agent_config extends uvm_object;
    function new(string name = "agent_config");
        super.new(name);
    endfunction //new()

    uvm_active_passive_enum is_active = UVM_ACTIVE;
    int unsigned pad_cycles = 5;
    virtual dut_interface m_vif;

    `uvm_object_utils_begin(agent_config)
        `uvm_field_enum(uvm_active_passive_enum, is_active, UVM_ALL_ON)
        `uvm_field_int(pad_cycles, UVM_ALL_ON)
    `uvm_object_utils_end

endclass //agent_config extends uvm_object