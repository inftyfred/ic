class my_test_driver_info extends my_test;

    `uvm_component_utils(my_test_driver_info)

    driver_info_callback drv_info_cb;

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        drv_info_cb = new();

        uvm_callbacks#(my_driver, driver_base_callback)::add(m_env.m_agent.m_driv, drv_info_cb);
    endfunction

endclass