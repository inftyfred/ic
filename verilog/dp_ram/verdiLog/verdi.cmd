debImport "-2001" "-sverilog" "/home/infty/ic/verilog/dp_ram/tb/tb_syncfifo.v" \
          "/home/infty/ic/verilog/dp_ram/src/dp_ram.v" \
          "/home/infty/ic/verilog/dp_ram/src/syncfifo.v"
debLoadSimResult /home/infty/ic/verilog/dp_ram/build/syncfifo.fsdb
wvCreateWindow
srcHBSelect "tb_syncfifo.u_syncfifo" -win $_nTrace1
srcHBSelect "tb_syncfifo" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
srcDeselectAll -win $_nTrace1
debReload
debRestoreSession /home/infty/ic/verilog/dp_ram/verdiLog/novas_autosave.ses
srcDeselectAll -win $_nTrace1
wvZoomOut -win $_nWave3
wvZoomIn -win $_nWave3
wvSetOptions -win $_nWave3 -hierName on
wvSetOptions -win $_nWave3 -hierName off
wvSetOptions -win $_nWave3 -hierName on
wvSetOptions -win $_nWave3 -hierName off
wvSetOptions -win $_nWave3 -hierName on
wvSetOptions -win $_nWave3 -hierName off
wvGetSignalOpen -win $_nWave3
wvGetSignalSetScope -win $_nWave3 "/tb_syncfifo"
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 8 )} 
wvGetSignalOpen -win $_nWave3
wvGetSignalSetOptions -win $_nWave3 -input on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -output on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -input off
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -output off
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -all on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -output on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -inout on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -net on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -register on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -all on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -inout on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -all on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -net on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -all on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -register on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -all on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 13)}
wvGetSignalOpen -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 14)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 14)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"u_syncfifo" \
{/tb_syncfifo/u_syncfifo/fifo_rst} \
{/tb_syncfifo/u_syncfifo/clock} \
{/tb_syncfifo/u_syncfifo/read_enable} \
{/tb_syncfifo/u_syncfifo/write_enable} \
{/tb_syncfifo/u_syncfifo/write_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/read_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/full} \
{/tb_syncfifo/u_syncfifo/fifo_counter\[8:0\]} \
{/tb_syncfifo/u_syncfifo/read_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/write_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/write_allow} \
{/tb_syncfifo/error_count\[31:0\]} \
{/tb_syncfifo/u_syncfifo/read_allow} \
{/tb_syncfifo/empty} \
}
wvAddSignal -win $_nWave3 -group {"G2" \
}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 14 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 14)}
wvGetSignalNavigateScope -win $_nWave3 -prev "/tb_syncfifo"
wvGetSignalClose -win $_nWave3
wvSetCursor -win $_nWave3 566292.991543 -snap {("u_syncfifo" 14)}
wvSetCursor -win $_nWave3 49888.711381 -snap {("u_syncfifo" 9)}
wvGetSignalOpen -win $_nWave3
wvGetSignalSetScope -win $_nWave3 "/tb_syncfifo"
wvGetSignalSetScope -win $_nWave3 "/tb_syncfifo"
wvGetSignalSetOptions -win $_nWave3 -input on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvSetPosition -win $_nWave3 {("u_syncfifo" 15)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 15)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"u_syncfifo" \
{/tb_syncfifo/u_syncfifo/fifo_rst} \
{/tb_syncfifo/u_syncfifo/clock} \
{/tb_syncfifo/u_syncfifo/read_enable} \
{/tb_syncfifo/u_syncfifo/write_enable} \
{/tb_syncfifo/u_syncfifo/write_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/read_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/full} \
{/tb_syncfifo/u_syncfifo/fifo_counter\[8:0\]} \
{/tb_syncfifo/u_syncfifo/read_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/write_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/write_allow} \
{/tb_syncfifo/error_count\[31:0\]} \
{/tb_syncfifo/u_syncfifo/read_allow} \
{/tb_syncfifo/empty} \
{/LOGIC_LOW} \
}
wvAddSignal -win $_nWave3 -group {"G2" \
}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 15 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 15)}
wvGetSignalSetOptions -win $_nWave3 -output on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -inout on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -net on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -all on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -net on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetOptions -win $_nWave3 -register on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalClose -win $_nWave3
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("G2" 0)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 14)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 5 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 2)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 2)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 2)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 1)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 0)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
srcTraceConnectivity "tb_syncfifo.u_syncfifo.write_data\[7:0\]" -win $_nTrace1
wvSetPosition -win $_nWave3 {("u_syncfifo" 2)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 0)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 0)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 1)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 2)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 2)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 1)}
srcTraceConnectivity "tb_syncfifo.u_syncfifo.write_data\[7:0\]" -win $_nTrace1
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 3 4 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 4 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 2)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 1)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 0)}
srcTraceConnectivity "tb_syncfifo.u_syncfifo.read_enable" -win $_nTrace1
wvSetPosition -win $_nWave3 {("u_syncfifo" 3)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 5 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 3 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 9 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 9)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 8)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 10 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 10)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 9)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 8)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvMoveSelected -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 4)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 5)}
srcDeselectAll -win $_nTrace1
debReload
wvSetCursor -win $_nWave3 62503.424497 -snap {("u_syncfifo" 10)}
wvDisplayGridCount -win $_nWave3 -off
wvGetSignalClose -win $_nWave3
wvReloadFile -win $_nWave3
srcDeselectAll -win $_nTrace1
srcHBSelect "tb_syncfifo.empty_fifo_test" -win $_nTrace1
srcHBSelect "tb_syncfifo.u_syncfifo" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_syncfifo.u_syncfifo" -delim "."
srcHBSelect "tb_syncfifo.u_syncfifo" -win $_nTrace1
srcHBSelect "tb_syncfifo" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_syncfifo" -delim "."
srcHBSelect "tb_syncfifo" -win $_nTrace1
srcHBSelect "tb_syncfifo.u_syncfifo.u_dp_ram_1" -win $_nTrace1
srcSetScope -win $_nTrace1 "tb_syncfifo.u_syncfifo.u_dp_ram_1" -delim "."
srcHBSelect "tb_syncfifo.u_syncfifo.u_dp_ram_1" -win $_nTrace1
srcDeselectAll -win $_nTrace1
srcSelect -signal "memory" -line 30 -pos 1 -win $_nTrace1
srcAddSelectedToWave -clipboard -win $_nTrace1
wvDrop -win $_nWave3
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSetCursor -win $_nWave3 38793.047487 -snap {("u_syncfifo" 6)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvExpandBus -win $_nWave3 {("u_syncfifo" 6)}
wvScrollDown -win $_nWave3 5
wvScrollUp -win $_nWave3 34
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 474 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 474)}
wvExpandBus -win $_nWave3 {("u_syncfifo" 474)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 525)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 474 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 474)}
wvCollapseBus -win $_nWave3 {("u_syncfifo" 474)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 474)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 517)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 474 )} 
wvScrollUp -win $_nWave3 474
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvCollapseBus -win $_nWave3 {("u_syncfifo" 6)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSetCursor -win $_nWave3 43019.967065 -snap {("u_syncfifo" 7)}
wvZoomAll -win $_nWave3
wvSetCursor -win $_nWave3 622460.935655 -snap {("u_syncfifo" 6)}
wvSetCursor -win $_nWave3 677154.155942 -snap {("u_syncfifo" 6)}
wvSetCursor -win $_nWave3 1565267.875852 -snap {("u_syncfifo" 6)}
wvZoom -win $_nWave3 1433743.703255 1565267.875852
wvGetSignalOpen -win $_nWave3
wvGetSignalSetScope -win $_nWave3 "/tb_syncfifo/u_syncfifo/u_dp_ram_1"
wvGetSignalSetOptions -win $_nWave3 -all on
wvGetSignalSetSignalFilter -win $_nWave3 "*"
wvGetSignalSetScope -win $_nWave3 "/tb_syncfifo/u_syncfifo/u_dp_ram_1"
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"u_syncfifo" \
{/tb_syncfifo/u_syncfifo/fifo_rst} \
{/tb_syncfifo/u_syncfifo/clock} \
{/tb_syncfifo/u_syncfifo/read_enable} \
{/tb_syncfifo/u_syncfifo/write_enable} \
{/tb_syncfifo/u_syncfifo/write_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/memory\[510:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/memory\[510:0\]} \
{/tb_syncfifo/u_syncfifo/write_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/read_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/read_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/full} \
{/tb_syncfifo/u_syncfifo/fifo_counter\[8:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/write_allow} \
{/tb_syncfifo/error_count\[31:0\]} \
{/tb_syncfifo/u_syncfifo/read_allow} \
{/tb_syncfifo/empty} \
}
wvAddSignal -win $_nWave3 -group {"G2" \
}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 7 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvAddSignal -win $_nWave3 -clear
wvAddSignal -win $_nWave3 -group {"u_syncfifo" \
{/tb_syncfifo/u_syncfifo/fifo_rst} \
{/tb_syncfifo/u_syncfifo/clock} \
{/tb_syncfifo/u_syncfifo/read_enable} \
{/tb_syncfifo/u_syncfifo/write_enable} \
{/tb_syncfifo/u_syncfifo/write_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/memory\[510:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/memory\[510:0\]} \
{/tb_syncfifo/u_syncfifo/write_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/read_addr\[8:0\]} \
{/tb_syncfifo/u_syncfifo/read_data\[7:0\]} \
{/tb_syncfifo/u_syncfifo/full} \
{/tb_syncfifo/u_syncfifo/fifo_counter\[8:0\]} \
{/tb_syncfifo/u_syncfifo/u_dp_ram_1/write_allow} \
{/tb_syncfifo/error_count\[31:0\]} \
{/tb_syncfifo/u_syncfifo/read_allow} \
{/tb_syncfifo/empty} \
}
wvAddSignal -win $_nWave3 -group {"G2" \
}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 7 )} 
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvGetSignalClose -win $_nWave3
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 7 )} 
wvCut -win $_nWave3
wvSetPosition -win $_nWave3 {("u_syncfifo" 7)}
wvSetPosition -win $_nWave3 {("u_syncfifo" 6)}
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSelectSignal -win $_nWave3 {( "u_syncfifo" 6 )} 
wvSetRadix -win $_nWave3 -format UDec
wvSetOptions -win $_nWave3 -fixedDelta on
wvSetCursor -win $_nWave3 -end
wvSetCursor -win $_nWave3 -end
wvSetCursor -win $_nWave3 -end
wvSetCursor -win $_nWave3 -end
wvSetOptions -win $_nWave3 -fixedDelta off
wvSetOptions -win $_nWave3 -fixedDelta on
wvSetCursor -win $_nWave3 1644364.157820 -snap {("u_syncfifo" 6)}
wvSetCursor -win $_nWave3 1627936.081758 -snap {("u_syncfifo" 7)}
wvSetOptions -win $_nWave3 -fixedDelta off
wvSetOptions -win $_nWave3 -fixedDelta on
wvSetCursor -win $_nWave3 1618278.364315 -snap {("u_syncfifo" 9)}
