#!/usr/bin/env tclsh
set script_dir [file dirname [file normalize [info script]]]
set root_dir [file dirname $script_dir]
set build_dir [file join $root_dir "build"]
proc env_default {name default} {
    if {[info exists ::env($name)] && $::env($name) ne ""} { return $::env($name) }
    return $default
}
set gen_filelist [env_default GEN_FILELIST 1]
set auto_filelist [file normalize [file join $root_dir [env_default FILELIST_AUTO build/filelist.auto.f]]]
set manual_filelist [file normalize [file join $root_dir [env_default FILELIST_MANUAL build/filelist.manual.f]]]
if {$gen_filelist ni {0 1}} { error "GEN_FILELIST must be 0 or 1" }
# Always refresh only the automatic filelist and initialize the manual filelist
# when missing; an existing manual filelist is never overwritten.
if {[catch {exec tclsh [file join $script_dir generate_filelist.tcl]} output]} { puts $output; exit 1 }
puts $output
if {$gen_filelist} {
    set filelist $auto_filelist
} else {
    set filelist $manual_filelist
    puts "Using manual filelist: $filelist"
}
set testname [env_default TESTNAME tb_pc_counter]
set log_file [file join $build_dir "compile_${testname}.log"]
set ucli_key [file join $build_dir ucli.key]
set simv_path [file join $build_dir simv]
set vcs_flags [list -R -full64 +v2k -sverilog -debug_access+all]
set wave_flags [list -fsdb +define+FSDB]
set ld_flags [list "-LDFLAGS -Wl,--no-as-needed"]
set extra [env_default COMPILE_EXTRA ""]
set cmd_parts [list vcs {*}$vcs_flags {*}$wave_flags -f $filelist -l $log_file -o $simv_path {*}$ld_flags "-Mdir=$build_dir/csrc"]
if {$extra ne ""} { foreach arg $extra { lappend cmd_parts $arg } }
set vcs_cmd [join $cmd_parts " "]
puts "VCS Command: $vcs_cmd"
cd $build_dir
if {[catch {exec bash -c "$vcs_cmd 2>&1"} output]} { puts $output; exit 1 }
puts $output
