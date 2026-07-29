class my_test_inst_da3 extends my_test;

    `uvm_component_utils(my_test_inst_da3)

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        set_inst_override_by_type("m_env.m_agent.m_seqr.*", my_transaction::get_type(), my_transaction_da3::get_type());
    endfunction 

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);
        factory.print();
    endfunction

endclass