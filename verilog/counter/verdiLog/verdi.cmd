debImport "-2001" "-sverilog" "/home/infty/ic/verilog/counter/tb/tb_counter.v" \
          "/home/infty/ic/verilog/counter/src/counter.v" \
          "/home/infty/ic/verilog/counter/src/timescale.v"
debLoadSimResult /home/infty/ic/verilog/counter/build/tb_counter.fsdb
wvCreateWindow
wvSelectGroup -win $_nWave2 {G1}
srcHBSelect "tb_counter.u1" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
wvSetCursor -win $_nWave2 2.732271 -snap {("u1" 3)}
wvZoomAll -win $_nWave2
wvSetCursor -win $_nWave2 24.331171 -snap {("u1" 3)}
wvSetCursor -win $_nWave2 33.804372 -snap {("u1" 3)}
wvSetCursor -win $_nWave2 45.072496 -snap {("u1" 3)}
wvSetCursor -win $_nWave2 53.548519 -snap {("u1" 3)}
debExit
