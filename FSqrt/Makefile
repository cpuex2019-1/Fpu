fadd:
	xvlog --sv fadd_testbench.sv fadd.v
	xelab -debug typical fadd_testbench -s fadd_testbench.sim
	xsim --runall fadd_testbench.sim

fmul:
	xvlog --sv fmul_testbench.sv fmul_testbench.v
	xelab -debug typical fmul_testbench -s fmul_testbench.sim
	xsim --runall fmul_testbench.sim

# fdiv:
# 	xvlog --sv fdiv_testbench.sv fdiv_first.v
# 	xelab -debug typical fdiv_testbench -s fdiv_testbench.sim
# 	xsim --runall fdiv_testbench.sim

finv:
	xvlog --sv finv_testbench.sv finv.v
	xelab -debug typical finv_testbench -s finv_testbench.sim
	xsim --runall finv_testbench.sim

fsqrt:
	xvlog --sv fsqrt_testbench.sv fsqrt.v
	xelab -debug typical fsqrt_testbench -s fsqrt_testbench.sim
	xsim --runall fsqrt_testbench.sim

debug:
	xvlog --sv debug_testbench.sv debug.v
	xelab -debug typical fsqrt_testbench -s fsqrt_testbench.sim
	xsim --runall fsqrt_testbench.sim

ftoi:
	xvlog --sv ftoi_testbench.sv ftoi.v
	xelab -debug typical ftoi_testbench -s ftoi_testbench.sim
	xsim --runall ftoi_testbench.sim

itof:
	xvlog --sv itof_testbench.sv itof.v
	xelab -debug typical itof_testbench -s itof_testbench.sim
	xsim --runall itof_testbench.sim

floor:
	xvlog --sv floor_testbench.sv floor.v
	xelab -debug typical floor_testbench -s floor_testbench.sim
	xsim --runall floor_testbench.sim

clean:
	rm -rf xsim.dir *.jou *.log *.pb *.sim.wdb
