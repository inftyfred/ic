
.PHONY:compile sim verdi clean cleanall

compile:
	echo "vcs编译中……"
	mkdir -p build/
	cd build/ && tclsh ../script/vcs_compile.tcl
sim:
	echo "正在产生fsdb文件……"
	mkdir -p sim/
	cd sim/ && tclsh ../script/sim.tcl
verdi:
	echo "启动verdi中……"
	mkdir -p sim/
	cd sim/ && verdi -f ../build/filelist.f -ssf dump.fsdb -nologo -2001 -sverilog &

verdireload:
	echo "加载波形中……"
	mkdir -p ./sim/verdiLog/  
	cd ./sim/verdiLog/ && verdi -nologo -ssr novas_autosave.ses

clean:
	echo "正在清理仿真文件（sim/）……"
	rm -rf sim/

cleanall:
	echo "正在清理生成文件(build/、sim/)……"
	rm -rf build/ sim/ 
