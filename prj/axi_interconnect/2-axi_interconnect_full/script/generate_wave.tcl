# UCLI waveform setup. TESTNAME and FSDB are supplied by sim.tcl.
set tb_name $::env(TESTNAME)
set fsdb_name $::env(FSDB)

# Expand Tcl variables before passing the Verilog system-task calls to UCLI.
set dumpfile_cmd [format {$fsdbDumpfile("%s")} $fsdb_name]
set dumpvars_cmd [format {$fsdbDumpvars(0, %s, "+all")} $tb_name]
call $dumpfile_cmd
call $dumpvars_cmd
run

# Exit UCLI after the testbench finishes; otherwise simv can wait at the
# interactive prompt and make appears to hang.
quit
