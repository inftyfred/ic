class my_reference_model extends uvm_component;

    `uvm_component_utils(my_reference_model)

    `ifdef GET
        uvm_blocking_get_port #(my_transaction) m2r_port;
    `else
        uvm_blocking_put_imp #(my_transaction, my_reference_model) i_m2r_imp;
    `endif 

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
        `ifdef GET
            this.m2r_port = new("m2r_port", this);
        `else
            this.i_m2r_imp = new("i_m2r_imp", this);
        `endif
    endfunction

    `ifndef GET
        task put(my_transaction tr);
            `uvm_info("REF_REPORT", {"\n", "master agent have been sent a transaction:\n", tr.sprint()}, UVM_MEDIUM)
        endtask
    `else    
        virtual task run_phase(uvm_phase phase);
            my_transaction tr;
            forever begin
                //if(m2r_port.can_get()) begin
                    m2r_port.get(tr);
                    `uvm_info("REF_REPORT", {"\n", "Get transaction from monitor:\n", tr.sprint()}, UVM_MEDIUM)
                //end
            end
        endtask
    `endif
    

endclass:my_reference_model