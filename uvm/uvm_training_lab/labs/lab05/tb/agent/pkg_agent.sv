package pkg_agent;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import pkg_config::*;
  import pkg_transaction::*;  // 关键：导入 transaction
  

  `include "agent/my_sequencer.sv"
  `include "agent/my_driver.sv"
  `include "agent/my_driver_count.sv"
  `include "agent/my_monitor.sv"
  `include "agent/master_agent.sv"
endpackage