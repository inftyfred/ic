class env_config extends uvm_object;

    int is_coverage = 0; //是否收集覆盖率信息
    int is_check    = 0; //是否启用scoreboard
    agent_config m_agent_config;

    function new(string name = "env_config");
        super.new(name);
        m_agent_config = new("m_agent_config");
    endfunction

    `uvm_object_utils_begin(env_config)
        `uvm_field_int(is_coverage, UVM_ALL_ON)
        `uvm_field_int(is_check, UVM_ALL_ON)
        `uvm_field_object(m_agent_config, UVM_ALL_ON)
    `uvm_object_utils_end


endclass:env_config