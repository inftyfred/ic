class my_driver_count extends my_driver;

    `uvm_component_utils(my_driver_count)

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual task run_phase(uvm_phase phase);
        int i = 0;
        forever begin
            seq_item_port.get_next_item(req);
            i+=1;
            `uvm_info("DRV_RUN_PHASE", req.sprint(), UVM_MEDIUM)
            #100;
            `uvm_info("DRV_RUN_PHASE", $sformatf("Driver get the %0dth item!", i), UVM_MEDIUM)
            seq_item_port.item_done();
        end
    endtask

endclass:my_driver_count