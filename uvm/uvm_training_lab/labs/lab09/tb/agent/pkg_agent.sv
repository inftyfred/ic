package pkg_agent;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  import pkg_config::*;
  import pkg_transaction::*;  
  import pkg_reference_model::*;
  import pkg_scoreboard::*;
  

  `include "agent/my_sequencer.sv"
  `include "agent/my_driver.sv"
  `include "agent/my_driver_count.sv"
  `include "agent/my_monitor.sv"
  `include "agent/out_monitor.sv"
  `include "agent/slave_agent.sv"
  `include "agent/master_agent.sv"
endpackage