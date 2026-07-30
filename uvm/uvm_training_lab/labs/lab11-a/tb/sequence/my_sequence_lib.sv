class my_sequence_lib extends uvm_sequence_library #(my_transaction);

    `uvm_object_utils(my_sequence_lib)

    `uvm_sequence_library_utils(my_sequence_lib)

    function new(string name = "my_seuqence_lib");
        super.new(name);

        init_sequence_library();
        
    endfunction

endclass:my_sequence_lib