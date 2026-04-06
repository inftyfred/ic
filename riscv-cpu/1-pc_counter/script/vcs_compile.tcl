#!/usr/bin/env tclsh
# vcs_compile.tcl
# 功能：生成 VCS 编译仿真命令并直接执行
set script_dir [file dirname [file normalize [info script]]]
set root_dir [file dirname $script_dir]
set build_dir  [file join $root_dir "build"]
# ============================================================
#  用户可配置参数
# ============================================================
if {[catch {exec tclsh [file join $script_dir "generate_filelist.tcl"]} output]} {
    puts "ERROR: generate_filelist.tcl failed"
    puts $output
    exit 1
}
puts $output
# --- 基本路径 ---
set filelist [file join $build_dir "filelist.f"]
set log_file [file join $build_dir "compile.log"]
set simv_dir [file join $build_dir "simv"]

# --- 编译选项 ---
set vcs_flags [list \
    -R              \
    -full64         \
    +v2k            \
    -sverilog       \
	-debug_access+all		
]

# --- 波形 ---
set wave_flags [list \
    -fsdb           \
    "+define+FSDB"  \
]

# --- 链接选项 ---
set ld_flags [list \
    "-LDFLAGS -Wl,--no-as-needed"
]

# --- 额外 define（可选）---
# 例如: set extra_defines [list "+define+DEBUG" "+define+SIM"]
set extra_defines [list "-j8"]

# ============================================================
#  拼接命令
# ============================================================

set cmd_parts [list "vcs"]

foreach f $vcs_flags  { lappend cmd_parts $f }
foreach f $wave_flags { lappend cmd_parts $f }

lappend cmd_parts "-f" $filelist
lappend cmd_parts "-l" $log_file
lappend cmd_parts "-o" $simv_dir

foreach f $ld_flags        { lappend cmd_parts $f }
foreach d $extra_defines   { lappend cmd_parts $d }

set vcs_cmd [join $cmd_parts " "]

# ============================================================
#  打印并执行
# ============================================================

puts "========================================="
puts " VCS Command"
puts "========================================="
puts $vcs_cmd
puts "========================================="
puts "Running..."
puts ""

set ret [catch {exec bash -c "$vcs_cmd 2>&1"} output]
puts $output

if {$ret != 0} {
    puts "\n========================================="
    puts " VCS exited with error (code $ret)"
    puts "========================================="
    exit 1
} else {
    puts "\n========================================="
    puts " VCS finished successfully"
    puts "========================================="
}

