#!/usr/bin/env tclsh
# gen_filelist.tcl
# 功能：收集 src/ 和 tb/ 下所有 .sv 和 .v 文件，
#       生成 filelist.f 到 build/ 目录（绝对路径 + incdir）

set script_dir [file dirname [file normalize [info script]]]
set root_dir   [file dirname $script_dir]          ;# script 的上一级，即项目根目录

set build_dir  [file join $root_dir "build"]
set src_dir    [file join $root_dir "src"]
set tb_dir     [file join $root_dir "tb"]

# ---------- 创建 build 目录（如不存在）----------
if {![file isdirectory $build_dir]} {
    file mkdir $build_dir
    puts "Created directory: $build_dir"
}

# ---------- 递归收集指定目录下的 .sv / .v 文件 ----------
proc collect_hdl_files {dir} {
    set result [list]
    if {![file isdirectory $dir]} {
        puts "Warning: directory not found, skipping: $dir"
        return $result
    }
    set entries [glob -nocomplain -directory $dir -tails -- *]
    foreach entry $entries {
        set full_path [file join $dir $entry]
        if {[file isdirectory $full_path]} {
            set result [concat $result [collect_hdl_files $full_path]]
        } else {
            set ext [string tolower [file extension $entry]]
            if {$ext eq ".sv" || $ext eq ".v"} {
                lappend result $full_path
            }
        }
    }
    return $result
}

# ---------- 收集文件 ----------
set all_files [list]
foreach dir [list $src_dir $tb_dir] {
    set all_files [concat $all_files [collect_hdl_files $dir]]
}

if {[llength $all_files] == 0} {
    puts "Warning: no .sv or .v files found in src/ or tb/"
}

# ---------- 写入 filelist.f ----------
set flist_path [file join $build_dir "filelist.f"]
set fd [open $flist_path "w"]

# 写入 incdir（如果有子目录也需要递归加入）
proc collect_subdirs {dir} {
    set result [list]
    if {![file isdirectory $dir]} { return $result }
    lappend result [file normalize $dir]
    set entries [glob -nocomplain -directory $dir -tails -- *]
    foreach entry $entries {
        set full_path [file join $dir $entry]
        if {[file isdirectory $full_path]} {
            set result [concat $result [collect_subdirs $full_path]]
        }
    }
    return $result
}

# 写入 incdir（src 和 tb 下所有子目录）
set incdir_dirs [list]
foreach dir [list $src_dir $tb_dir] {
    set incdir_dirs [concat $incdir_dirs [collect_subdirs $dir]]
}

foreach d $incdir_dirs {
    puts $fd "+incdir+[file normalize $d]"
}

puts $fd ""  ;# 空行分隔

# 写入源文件（绝对路径）
foreach f $all_files {
    puts $fd [file normalize $f]
}
close $fd

puts "Generated: $flist_path  ([llength $all_files] files, [llength $incdir_dirs] incdirs)"

















































































