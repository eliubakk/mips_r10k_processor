# To compile additional files, add them to the TESTBENCH or SIMFILES as needed
# Every .vg file will need its own rule and one or more synthesis scripts
# The information contained here (in the rules for those vg files) will be
# similar to the information in those scripts but that seems hard to avoid.
#

# added "SW_VCS=2011.03 and "-full64" option -- awdeorio fall 2011
# added "-sverilog" and "SW_VCS=2012.09" option,
#	and removed deprecated Virsim references -- jbbeau fall 2013
# updated library path name -- jbbeau fall 2013
#VCS_BASE = SW_VCS=2017.12-SP2-1 vcs +v2k -sverilog +vc -Mupdate -line -full64 -timescale=1ns/100ps 

VCS_BASE = vcs -sverilog +v2k +vc -Mupdate -line -full64 -timescale=1ns/100ps 
VCS = $(VCS_BASE)
VCS_PIPE = $(VCS_BASE) +define+PIPELINE=1
LIB = /afs/umich.edu/class/eecs470/lib/verilog/lec25dscc25.v

# testing commit

# pipeline synthesis defines
PIPE_HEADERS = $(wildcard *.vh)
PIPE_TESTBENCH = $(wildcard testbench/*.v)
PIPE_TESTBENCH += $(wildcard testbench/*.c)
PIPE_FILES = $(wildcard verilog/*.v)
PIPE_SIMFILES = $(PIPE_FILES)

all:    simv
	./simv | tee program.out
##### 
# Modify starting here
#####
TEST_DIR = testbench
VERILOG_DIR = verilog
SYN_DIR = synth
PIPELINE_NAME = pipeline
PIPELINE = $(VERILOG_DIR)/$(PIPELINE_NAME).v 
MISC_SRC = $(wildcard $(VERILOG_DIR)/misc/*.v)

TEST_SRC = $(wildcard $(TEST_DIR)/*.v)
VERILOG_SRC = $(filter-out $(PIPELINE),$(wildcard $(VERILOG_DIR)/*.v))
MODULES = $(patsubst $(VERILOG_DIR)/%.v, %, $(VERILOG_SRC))
MODULES_SYN_FILES = $(patsubst %, %.vg, $(MODULES))
MISC_MODULES = $(patsubst $(VERILOG_DIR)/misc/%.v, %, $(MISC_SRC))
MISC_MODULES_SYN_FILES = $(patsubst %, %.vg, $(MISC_MODULES))
SYN_SIMV = $(patsubst %,syn_simv_%,$(MODULES))
SYN_SIMV += $(patsubst %,syn_simv_%,$(MISC_MODULES))
SIMV = $(patsubst $(VERILOG_DIR)/%.v,simv_%,$(VERILOG_SRC))
MISC_SIMV = $(patsubst $(VERILOG_DIR)/misc/%.v,simv_%,$(MISC_SRC))
DVE = $(patsubst $(VERILOG_DIR)/%.v,dve_%,$(VERILOG_SRC))

MODULES_VG = $(foreach module,$(MODULES),$(SYN_DIR)/$(module)/%.vg)
MISC_MODULES_VG = $(foreach module,$(MISC_MODULES),$(SYN_DIR)/$(module)/%.vg)

$(MODULES_SYN_FILES): %.vg: $(SYN_DIR)/%.tcl $(VERILOG_DIR)/%.v sys_defs.vh
	cd $(SYN_DIR) && \
	mkdir -p $* && cd $* && \
	dc_shell-t -f ../$*.tcl | tee $*_synth.out

$(MISC_MODULES_SYN_FILES): %.vg: $(SYN_DIR)/%.tcl $(VERILOG_DIR)/misc/%.v sys_defs.vh
	cd $(SYN_DIR) && \
	mkdir -p $* && cd $* && \
	dc_shell-t -f ../$*.tcl | tee $*_synth.out

$(MODULES_VG): $(SYN_DIR)/%.tcl $(VERILOG_DIR)/%.v sys_defs.vh
	make $*.vg

$(MISC_MODULES_VG): $(SYN_DIR)/%.tcl $(VERILOG_DIR)/misc/%.v sys_defs.vh
	make $*.vg

.PHONY: $(MODULES_VG)
.PHONY: $(MISC_MODULES_VG)

$(SYN_SIMV): syn_simv_%: $(TEST_DIR)/%_test.v
	make $(SYN_DIR)/$*/$*.vg && \
	cd $(SYN_DIR)/$* && \
	$(VCS) $*.vg ../../$(TEST_DIR)/$*_test.v $(LIB) -o $@

%: syn_simv_%
	cd $(SYN_DIR) && \
	mkdir -p $* && cd $* && \
	./syn_simv_$* | tee $@_syn_program.out

$(SIMV): simv_%: $(VERILOG_DIR)/%.v $(MISC_SRC) $(TEST_DIR)/%_test.v
	cd $(SYN_DIR) && \
	mkdir -p $* && cd $* && \
	$(VCS)+define+SIMV=1 $(patsubst %.v,../../%.v,$^) -o $@ &&\
	./$@ | tee $*_simv_program.out

$(MISC_SIMV): simv_%: $(MISC_SRC) $(TEST_DIR)/%_test.v
	cd $(SYN_DIR) && \
	mkdir -p $* && cd $* && \
	$(VCS) $(patsubst %.v,../../%.v,$^) -o $@ &&\
	./$@ | tee $*_simv_program.out

simv_$(PIPELINE_NAME): $(PIPELINE) $(MISC_SRC) $(VERILOG_SRC) $(TEST_DIR)/pipe_print.c $(TEST_DIR)/mem.v $(TEST_DIR)/$(PIPELINE_NAME)_test.v
	cd $(SYN_DIR) && \
	mkdir -p $(PIPELINE_NAME) && cd $(PIPELINE_NAME) && \
	$(VCS_PIPE) $(patsubst %,../../%,$^) -o $@ &&\
	./$@ | tee $(PIPELINE_NAME)_simv_program.out

$(PIPELINE_NAME).vg: %.vg: $(SYN_DIR)/%.tcl $(MODULES_VG) $(MISC_MODULES_VG)
	cd $(SYN_DIR) && rm -rf $(PIPELINE_NAME) &&\
	mkdir -p $(PIPELINE_NAME) && cd $(PIPELINE_NAME) && \
	$(VCS) $*.vg ../../$(TEST_DIR)/$*_test.v $(LIB) -o $@
	mv * ../../. && cd ../..	

$(DVE): dve_%: $(VERILOG_DIR)/%.v $(MISC_SRC) $(TEST_DIR)/%_test.v
	cd $(SYN_DIR) && \
	mkdir -p $* && cd $* && \
	$(VCS) +memcbk $(patsubst %.v,../../%.v,$^) -o dve -R -gui 

clean_%:
	cd $(SYN_DIR) && \
	rm -rf $(subst clean_,,$@) 
#####
# Should be no need to modify after here
#####
sim:	simv $(ASSEMBLED)
	./simv | tee sim_program.out

# simv:	$(HEADERS) $(SIMFILES) $(TESTBENCH)
# 	$(VCS) $^ -o simv

simv: $(PIPELINE) $(MISC_SRC) $(VERILOG_SRC) $(TEST_DIR)/pipe_print.c $(TEST_DIR)/mem.v $(TEST_DIR)/$(PIPELINE_NAME)_test.v
	cd $(SYN_DIR) && rm -rf $(PIPELINE_NAME) &&\
	mkdir -p $(PIPELINE_NAME) && cd $(PIPELINE_NAME) && \
	$(VCS_PIPE) $(patsubst %,../../%,$^) -o simv &&\
	mv * ../../. && cd ../.. 

.PHONY: sim

dve_pipe: $(PIPELINE) $(MISC_SRC) $(VERILOG_SRC) $(TEST_DIR)/pipe_print.c $(TEST_DIR)/mem.v $(TEST_DIR)/$(PIPELINE_NAME)_test.v
	cd $(SYN_DIR) && \
	mkdir -p $(PIPELINE_NAME) && cd $(PIPELINE_NAME) && \
	$(VCS_PIPE) +memcbk $(patsubst %,../../%,$^) -o dve -R -gui
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
          dve *.vpd *.vcd *.dump ucli.key *.out

nuke:	clean
	cd $(SYN_DIR) && \
	rm -rvf *.vg *.rep *.db *.chk *.log *.out *.ddc *.svf *.sv DVEfiles/
	
.PHONY: dve clean nuke	

syn_dve:	$(SYNFILES) $(TESTBENCH)
	$(VCS) $(TESTBENCH) $(SYNFILES) $(LIB) -o dve -R -gui
