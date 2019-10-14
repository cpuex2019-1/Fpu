fadd:
	xvlog --sv test_fadd.sv fadder.v
	xelab -debug typical test_fadd -s fadd_testbench.sim
	xsim --runall fadd_testbench.sim

fmul:
	xvlog --sv fmul_testbench.sv fmul.v
	xelab -debug typical fmul_testbench -s fmul_testbench.sim
	xsim --runall fmul_testbench.sim

fdiv:
	xvlog --sv fdiv_testbench.sv fdiv.v
	xelab -debug typical fdiv_testbench -s fdiv_testbench.sim
	xsim --runall fdiv_testbench.sim

clean:
	rm -rf xsim.dir
