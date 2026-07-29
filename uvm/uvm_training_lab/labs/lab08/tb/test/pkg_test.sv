package pkg_test;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import pkg_config::*;
  import pkg_transaction::*;
  import pkg_agent::*;
  import pkg_sequence::*;
  import pkg_env::*;

  `include "test/my_test.sv"
  `include "test/my_test_type_da3.sv"
  `include "test/my_test_inst_da3.sv"
  `include "test/my_test_driver.sv"
endpackage