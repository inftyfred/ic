debImport "-2001" "-sverilog" "/home/infty/ic/verilog/dp_ram/tb/tb_syncfifo.v" \
          "/home/infty/ic/verilog/dp_ram/src/dp_ram.v" \
          "/home/infty/ic/verilog/dp_ram/src/syncfifo.v"
debLoadSimResult /home/infty/ic/verilog/dp_ram/build/syncfifo.fsdb
wvCreateWindow
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
srcHBSelect "tb_syncfifo.empty_fifo_test" -win $_nTrace1
srcHBSelect "tb_syncfifo" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
srcHBSelect "tb_syncfifo" -win $_nTrace1
srcHBAddObjectToWave -clipboard
wvDrop -win $_nWave2
debExit
