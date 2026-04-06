
set script_dir [file normalize [file dirname [info script]]]
set sim_dir [file join [file dirname $script_dir] "build"]

set wave_tcl_dir [file join $script_dir "generate_wave.tcl"]
set sim_log_dir [file join $sim_dir "sim.log"]
set cmd "$sim_dir/simv -ucli -i $wave_tcl_dir -l sim_log_dir"

if {[catch {eval exec $cmd} output]} {
    puts "ERROR: $output"
    exit 1
}
puts $output

