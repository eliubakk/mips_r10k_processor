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
## Testing for CDB.v
TESTBENCH = testbench/free_list_test.v
SIMFILES = verilog/free_list.v
SYNFILES = Free_List.vg 

PSELSINFILES = verilog/psel_single.v
PSELSINSYN = psel_single.vg

PSELGENFILES = verilog/psel_generic.v
PSELGENSYN = psel_generic.vg
PSELGENTEST= testbench/psel_generic_test.v

# RS files
RSFILES = verilog/RS.v
RSSYN = RS.vg
RSTEST = testbench/RS_test.v

# free list files
FREELISTFILES = verilog/free_list.v
FREELISTSYN = Free_List.vg
FREELISTTEST = testbench/free_list_test.v

# map table files
MAPTABLEFILES = verilog/map_table.v
MAPTABLESYN = Map_Table.vg
MAPTABLETEST = testbench/map_table_test.v

# CDB files
CDBFILES = verilog/cdb.v
CDBSYN = CDB.vg
CDBTEST = testbench/CDB_test.v

# Arch Map Table files
ARCHFILES = verilog/arch_map.v
ARCHSYN = Arch_Map_Table.vg
ARCHTEST = testbench/Arch_test.v

psel_single.vg: $(PSELSINFILES) synth/psel_single.tcl
	dc_shell-t -f synth/psel_single.tcl | tee psel_single_synth.out

psel_generic.vg: $(PSELGENFILES) synth/psel_generic.tcl
	dc_shell-t -f synth/psel_generic.tcl | tee psel_generic_synth.out

RS.vg: $(RSFILES) synth/RS.tcl
	dc_shell-t -f synth/RS.tcl | tee RS_synth.out

Arch_Map_Table.vg: $(ARCHFILES) synth/arch_map.tcl
	 dc_shell-t -f synth/arch_map.tcl | tee arch_map_synth.out

CDB.vg: $(CDBFILES) synth/cdb.tcl
	 dc_shell-t -f synth/cdb.tcl | tee cdb_synth.out

Free_List.vg: $(FREELISTFILES) synth/free_list.tcl
	dc_shell-t -f synth/free_list.tcl | tee free_list_synth.out

Map_Table.vg: $(MAPTABLEFILES) synth/map_table.tcl
	dc_shell-t -f synth/map_table.tcl | tee map_table_synth.out

## Testing for arch_map.v
#TESTBENCH = testbench/Arch_test.v
#SIMFILES = verilog/arch_map.v
#SYNFILES = Arch_Map_Table.vg 

#Arch_Map_Table.vg: $(SIMFILES) synth/arch_map.tcl
#	 dc_shell-t -f synth/arch_map.tcl | tee arch_map_synth.out

syn_simv_psel_generic: $(PSELGENSYN) $(PSELGENTEST)
	$(VCS) $(PSELGENTEST) $(PSELGENSYN) $(LIB) -o syn_simv_psel_generic

psel_generic: syn_simv_psel_generic
	./syn_simv_psel_generic | tee syn_psel_generic_program.out

syn_simv_RS: $(RSSYN) $(RSTEST)
	$(VCS) $(RSTEST) $(RSSYN) $(LIB) -o syn_simv_RS

RS: syn_simv_RS
	./syn_simv_RS | tee syn_RS_program.out

syn_simv_arch: $(ARCHSYN) $(ARCHTEST)
	$(VCS) $(ARCHTEST) $(ARCHSYN) $(LIB) -o syn_simv_arch

arch_map: syn_simv_arch
	./syn_simv_arch | tee syn_arch_program.out

syn_simv_cdb: $(CDBSYN) $(CDBTEST)
	$(VCS) $(CDBTEST) $(CDBSYN) $(LIB) -o syn_simv_cdb

cdb: syn_simv_cdb
	./syn_simv_cdb | tee syn_cdb_program.out

syn_simv_free_list: $(FREELISTSYN) $(FREELISTTEST)
	$(VCS) $(FREELISTTEST) $(FREELISTSYN) $(LIB) -o syn_simv_free_list

free_list: syn_simv_free_list
	./syn_simv_free_list | tee syn_free_list_program.out

syn_simv_map_table: $(MAPTABLESYN) $(MAPTABLETEST)
	$(VCS) $(MAPTABLETEST) $(MAPTABLESYN) $(LIB) -o syn_simv_map_table

map_table: syn_simv_map_table
	./syn_simv_map_table | tee syn_map_table_program.out

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
