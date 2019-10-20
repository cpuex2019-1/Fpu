fadd:
	xvlog --sv fadd_testbench.sv fadd_second.v
	xelab -debug typical fadd_testbench -s fadd_testbench.sim
	xsim --runall fadd_testbench.sim

fmul:
	xvlog --sv fmul_testbench.sv fmul_second.v
	xelab -debug typical fmul_testbench -s fmul_testbench.sim
	xsim --runall fmul_testbench.sim

fdiv:
	xvlog --sv fdiv_testbench.sv fdiv_first.v
	xelab -debug typical fdiv_testbench -s fdiv_testbench.sim
	xsim --runall fdiv_testbench.sim

finv:
	xvlog --sv finv_testbench.sv finv_first.v debug.v fadd_second.v
	xelab -debug typical finv_testbench -s finv_testbench.sim
	xsim --runall finv_testbench.sim

clean:
	rm -rf xsim.dir *.jou *.log *.pb *.sim.wdb
