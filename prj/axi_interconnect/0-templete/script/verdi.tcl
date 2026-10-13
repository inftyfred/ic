#!/usr/bin/env tclsh
# Launch Verdi with the selected FSDB and filelist.
proc env_default {name default} {
    if {[info exists ::env($name)] && $::env($name) ne ""} {
        return $::env($name)
    }
    return $default
}

set script_dir [file dirname [file normalize [info script]]]
set root_dir [file dirname $script_dir]
set testname [env_default TESTNAME tb_pc_counter]
set fsdb [env_default FSDB "sim/${testname}.fsdb"]
set gen_filelist [env_default GEN_FILELIST 1]
set auto_name [env_default FILELIST_AUTO build/filelist.auto.f]
set manual_name [env_default FILELIST_MANUAL build/filelist.manual.f]

proc root_path {root path} {
    if {[file pathtype $path] eq "absolute"} { return [file normalize $path] }
    return [file normalize [file join $root $path]]
}

set fsdb_path [root_path $root_dir $fsdb]
# Keep automatic and manual filelists independent. This call only creates the
# manual filelist when missing and never changes an existing one.
if {[catch {exec tclsh [file join $script_dir generate_filelist.tcl]} output]} {
    puts $output
    exit 1
}
puts $output
if {$gen_filelist eq "1"} {
    set filelist_path [root_path $root_dir $auto_name]
} elseif {$gen_filelist eq "0"} {
    set filelist_path [root_path $root_dir $manual_name]
} else {
    error "GEN_FILELIST must be 0 or 1, got: $gen_filelist"
}

if {![file exists $filelist_path]} { error "filelist not found: $filelist_path" }
if {![file exists $fsdb_path]} { error "FSDB not found: $fsdb_path" }

set cmd [list verdi -nologo -f $filelist_path -ssf $fsdb_path -2001 -sverilog -top $testname]
if {$argc > 0} { foreach arg $argv { lappend cmd $arg } }
puts "Verdi testbench: $testname"
puts "Verdi filelist: $filelist_path"
puts "Verdi FSDB: $fsdb_path"
set sim_dir [file join $root_dir sim]
file mkdir $sim_dir
cd $sim_dir
if {[catch {exec {*}$cmd} output]} {
    puts $output
    exit 1
}
puts $output
