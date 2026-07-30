package pkg_sequence;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import pkg_config::*;
  import pkg_transaction::*;
  import pkg_agent::*;

  `include "sequence/my_sequence_lib.sv"
  `include "sequence/my_sequence.sv"
  `include "sequence/sa6_sequence.sv"
  `include "sequence/da3_sequence.sv"
  `include "sequence/sa6_da3_sequence.sv"
endpackage