class my_transaction extends uvm_sequence_item;

	rand bit [3:0] sa;
	rand bit [3:0] da;
	rand reg [7:0] payload[$];

	`uvm_object_utils_begin(my_transaction)
		`uvm_field_int(sa, UVM_ALL_ON)
		`uvm_field_int(da, UVM_ALL_ON)
		`uvm_field_queue_int(payload, UVM_ALL_ON)
	`uvm_object_utils_end

	constraint Limit{
		sa inside {[0:15]};
		da inside {[0:15]};
		payload.size() inside {[2:4]};
	}

	function new (string name = "my_transaction");
		super.new(name);
	endfunction

endclass:my_transaction
