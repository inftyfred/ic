#!/usr/bin/env tclsh
set script_dir [file dirname [file normalize [info script]]]
set root_dir [file dirname $script_dir]
proc env_default {name default} {
    if {[info exists ::env($name)] && $::env($name) ne ""} { return $::env($name) }
    return $default
}
set testname [env_default TESTNAME tb_pc_counter]
set fsdb [env_default FSDB "sim/${testname}.fsdb"]
set sim_extra [env_default SIM_EXTRA ""]
set build_dir [file join $root_dir build]
set wave_tcl [file join $script_dir generate_wave.tcl]
set fsdb_path $fsdb
if {[file pathtype $fsdb_path] ne "absolute"} {
    set fsdb_path [file normalize [file join $root_dir $fsdb_path]]
}
file mkdir [file dirname $fsdb_path]
set log_file [file join $root_dir sim "sim_${testname}.log"]
set cmd [list [file join $build_dir simv] -ucli -i $wave_tcl -l $log_file]
if {$sim_extra ne ""} { foreach arg $sim_extra { lappend cmd $arg } }
set ::env(TESTNAME) $testname
set ::env(FSDB) $fsdb_path
puts "Simulation testbench: $testname"
puts "Simulation command: [join $cmd { }]"
cd $build_dir
if {[catch {exec {*}$cmd} output]} { puts $output; exit 1 }
puts $output
