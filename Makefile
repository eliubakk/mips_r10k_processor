# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be
# similar to the information in those scripts but that seems hard to avoid.
#

# added "SW_VCS=2011.03 and "-full64" option -- awdeorio fall 2011
# added "-sverilog" and "SW_VCS=2012.09" option,
#	and removed deprecated Virsim references -- jbbeau fall 2013
# updated library path name -- jbbeau fall 2013

VCS = SW_VCS=2017.12-SP2-1 vcs +v2k -sverilog +vc -Mupdate -line -full64
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

# testing commit

all:    simv
	./simv | tee program.out
##### 
# Modify starting here
#####
TEST_DIR = testbench
VERILOG_DIR = verilog
SYN_DIR = synth

TEST_SRC = $(wildcard $(TEST_DIR)/*.v)
VERILOG_SRC = $(wildcard $(VERILOG_DIR)/*.v)
MODULES = $(patsubst $(VERILOG_DIR)/%.v, %, $(VERILOG_SRC))
SYN_SIMV = $(patsubst $(VERILOG_DIR)/%.v, syn_simv_%, $(VERILOG_SRC))
SIMV = $(patsubst $(VERILOG_DIR)/%.v, simv_%, $(VERILOG_SRC))

%.vg: $(SYN_DIR)/%.tcl $(VERILOG_DIR)/%.v
	cd $(SYN_DIR) && \
	dc_shell-t -f $*.tcl | tee $*_synth.out

$(SYN_SIMV): syn_simv_% : %.vg $(TEST_DIR)/%_test.v
	$(VCS) $(SYN_DIR)/$^ $(LIB) -o $(SYN_DIR)/$@

%: syn_simv_%
	cd $(SYN_DIR) && \
	./syn_simv_$* | tee $@_program.out

$(SIMV): simv_%: $(TEST_DIR)/%_test.v $(VERILOG_DIR)/%.v
	$(VCS) $^ -o $@

#####
# Should be no need to modify after here
#####
sim:	simv $(ASSEMBLED)
	./simv | tee sim_program.out

simv:	$(HEADERS) $(SIMFILES) $(TESTBENCH)
	$(VCS) $^ -o simv

.PHONY: sim

# updated interactive debugger "DVE", using the latest version of VCS
# awdeorio fall 2011
dve:	$(SIMFILES) $(TESTBENCH)
	$(VCS) +memcbk $(TESTBENCH) $(SIMFILES) -o dve -R -gui

syn_simv:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o syn_simv

syn:	syn_simv
	./syn_simv | tee syn_program.out

clean:
	rm -rvf simv *.daidir csrc vcs.key program.out \
	  syn_simv* syn_simv.daidir syn_program.out \
          dve *.vpd *.vcd *.dump ucli.key

nuke:	clean
	rm -rvf *.vg *.rep *.db *.chk *.log *.out *.ddc *.svf DVEfiles/
	
.PHONY: dve clean nuke	

syn_dve:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o dve -R -gui
