class my_reference_model extends uvm_component;

    `uvm_component_utils(my_reference_model)

    uvm_blocking_get_port #(my_transaction) m2r_port;
    uvm_blocking_put_port #(my_transaction) r2s_port;

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
        this.m2r_port = new("m2r_port", this);
        this.r2s_port = new("r2s_port", this);
    endfunction
 
    virtual task run_phase(uvm_phase phase);
        my_transaction tr;
        forever begin
            m2r_port.get(tr);
            `uvm_info("REF_REPORT", {"\n", "Get transaction from monitor:\n", tr.sprint()}, UVM_MEDIUM)
            r2s_port.put(tr);
        end
    endtask
    

endclass:my_reference_model