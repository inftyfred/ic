class my_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(my_scoreboard)

    uvm_blocking_get_port #(my_transaction) r2s_port;
    uvm_blocking_get_port #(my_transaction) s_a2s_port;

    function new(string name = "", uvm_component parent);
        super.new(name, parent);
        r2s_port = new("r2s_port", this);
        s_a2s_port = new("s_a2s_port", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        my_transaction dut_output_tr;
        my_transaction expected_tr;
        forever begin
            `uvm_info("SCOREBOARD", "Now waiting for getting the transaction from slave agent and reference model", UVM_MEDIUM)
            fork
                r2s_port.get(expected_tr);
                s_a2s_port.get(dut_output_tr);
            join
                `uvm_info("CHECK", "DUT has completed a transaction, Now check the output...", UVM_MEDIUM)
            if(expected_tr.compare(dut_output_tr)) begin
                `uvm_info("CHECK", "checking is done. The result matches the expected value !", UVM_MEDIUM)
            end else begin
                `uvm_info("CHECK", "checking is done, The result does not match the expexted value! Please check you DUT", UVM_MEDIUM)
            end
        end
    endtask
endclass