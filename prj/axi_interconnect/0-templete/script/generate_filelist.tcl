#!/usr/bin/env tclsh
# Generate the automatic file list. Manual filelists are never overwritten.
set script_dir [file dirname [file normalize [info script]]]
set root_dir [file dirname $script_dir]
set build_dir [file join $root_dir "build"]
set output_name [expr {[info exists ::env(FILELIST_AUTO)] ? $::env(FILELIST_AUTO) : "build/filelist.auto.f"}]
set flist_path [file normalize [file join $root_dir $output_name]]
set src_dir [file join $root_dir "src"]
set tb_dir [file join $root_dir "tb"]
file mkdir $build_dir

proc collect_hdl_files {dir} {
    set result [list]
    if {![file isdirectory $dir]} { return $result }
    foreach entry [glob -nocomplain -directory $dir -tails -- *] {
        set full_path [file join $dir $entry]
        if {[file isdirectory $full_path]} {
            set result [concat $result [collect_hdl_files $full_path]]
        } elseif {[string tolower [file extension $entry]] in {".sv" ".v"}} {
            lappend result [file normalize $full_path]
        }
    }
    return $result
}
proc collect_subdirs {dir} {
    set result [list]
    if {![file isdirectory $dir]} { return $result }
    lappend result [file normalize $dir]
    foreach entry [glob -nocomplain -directory $dir -tails -- *] {
        set full_path [file join $dir $entry]
        if {[file isdirectory $full_path]} { set result [concat $result [collect_subdirs $full_path]] }
    }
    return $result
}

set all_files [list]
set incdirs [list]
foreach dir [list $src_dir $tb_dir] {
    set all_files [concat $all_files [collect_hdl_files $dir]]
    set incdirs [concat $incdirs [collect_subdirs $dir]]
}
set fd [open $flist_path w]
foreach d $incdirs { puts $fd "+incdir+$d" }
puts $fd ""
foreach f $all_files { puts $fd $f }
close $fd

# Initialize the manual filelist once. Never overwrite it after creation.
set manual_name [expr {[info exists ::env(FILELIST_MANUAL)] ? $::env(FILELIST_MANUAL) : "build/filelist.manual.f"}]
set manual_path [file normalize [file join $root_dir $manual_name]]
if {![file exists $manual_path]} {
    set manual_fd [open $manual_path w]
    puts $manual_fd "# Manual filelist. Edit this file when GEN_FILELIST=0."
    foreach d $incdirs { puts $manual_fd "+incdir+$d" }
    puts $manual_fd ""
    foreach f $all_files { puts $manual_fd $f }
    close $manual_fd
    puts "Initialized manual filelist: $manual_path"
} else {
    puts "Manual filelist exists, keeping it: $manual_path"
}
puts "Generated: $flist_path ([llength $all_files] files, [llength $incdirs] incdirs)"
