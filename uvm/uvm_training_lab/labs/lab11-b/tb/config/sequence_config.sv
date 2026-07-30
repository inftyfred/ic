class sequence_config extends uvm_object;

    int item_num = 5;

    function new(string name = "sequence_config");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sequence_config)
        `uvm_field_int(item_num, UVM_ALL_ON)
    `uvm_object_utils_end

endclass:sequence_config