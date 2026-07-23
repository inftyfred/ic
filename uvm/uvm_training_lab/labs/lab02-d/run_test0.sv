import uvm_pkg::*;
`include "uvm_pkg.sv"
`include "uvm_macros.svh"
module hello_world_example;  
   initial begin 
     `uvm_info ("info1","Hello World! lee-2017-7-25", UVM_LOW)
     `uvm_info("Gwj Test info2","Hello this is a test",UVM_LOW)
   end 
endmodule: hello_world_example

