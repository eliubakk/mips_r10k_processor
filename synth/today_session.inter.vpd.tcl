# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Thu Apr 18 01:21:01 2019
# Designs open: 1
#   Sim: dve
# Toplevel windows open: 3
# 	TopLevel.1
# 	TopLevel.2
# 	TopLevel.3
#   Source.1: _vcs_unit__4062623735
#   Wave.1: 19 signals
#   Wave.2: 21 signals
#   Group count = 7
#   Group Group1 signal count = 4
#   Group Group2 signal count = 9
#   Group Group3 signal count = 11
#   Group mem_stage_0 signal count = 19
#   Group memory signal count = 21
# End_DVE_Session_Save_Info

# DVE version: N-2017.12-SP2-1_Full64
# DVE build date: Jul 14 2018 20:58:30


#<Session mode="Full" path="/afs/umich.edu/user/s/u/surajrs/470/group10w19/synth/today_session.inter.vpd.tcl" type="Debug">

gui_set_loading_session_type Post
gui_continuetime_set

# Close design
if { [gui_sim_state -check active] } {
    gui_sim_terminate
}
gui_close_db -all
gui_expr_clear_all

# Close all windows
gui_close_window -type Console
gui_close_window -type Wave
gui_close_window -type Source
gui_close_window -type Schematic
gui_close_window -type Data
gui_close_window -type DriverLoad
gui_close_window -type List
gui_close_window -type Memory
gui_close_window -type HSPane
gui_close_window -type DLPane
gui_close_window -type Assertion
gui_close_window -type CovHier
gui_close_window -type CoverageTable
gui_close_window -type CoverageMap
gui_close_window -type CovDetail
gui_close_window -type Local
gui_close_window -type Stack
gui_close_window -type Watch
gui_close_window -type Group
gui_close_window -type Transaction



# Application preferences
gui_set_pref_value -key app_default_font -value {Helvetica,10,-1,5,50,0,0,0,0,0}
gui_src_preferences -tabstop 8 -maxbits 24 -windownumber 1
#<WindowLayout>

# DVE top-level session


# Create and position top-level window: TopLevel.1

if {![gui_exist_window -window TopLevel.1]} {
    set TopLevel.1 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.1 TopLevel.1
}
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{0 65} {2559 1405}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 249]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 249
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 248} {height 1107} {dock_state left} {dock_on_new_line true} {child_hier_colhier 149} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 486]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 486
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 905
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 485} {height 1107} {dock_state left} {dock_on_new_line true} {child_data_colvariable 212} {child_data_colvalue 153} {child_data_coltype 144} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 159]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1860
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 159
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 2559} {height 158} {dock_state bottom} {dock_on_new_line true}}
#### Start - Readjusting docked view's offset / size
set dockAreaList { top left right bottom }
foreach dockArea $dockAreaList {
  set viewList [gui_ekki_get_window_ids -active_parent -dock_area $dockArea]
  foreach view $viewList {
      if {[lsearch -exact [gui_get_window_pref_keys -window $view] dock_width] != -1} {
        set dockWidth [gui_get_window_pref_value -window $view -key dock_width]
        set dockHeight [gui_get_window_pref_value -window $view -key dock_height]
        set offset [gui_get_window_pref_value -window $view -key dock_offset]
        if { [string equal "top" $dockArea] || [string equal "bottom" $dockArea]} {
          gui_set_window_attributes -window $view -dock_offset $offset -width $dockWidth
        } else {
          gui_set_window_attributes -window $view -dock_offset $offset -height $dockHeight
        }
      }
  }
}
#### End - Readjusting docked view's offset / size
gui_sync_global -id ${TopLevel.1} -option true

# MDI window settings
set Source.1 [gui_create_window -type {Source}  -parent ${TopLevel.1}]
gui_show_window -window ${Source.1} -show_state maximized
gui_update_layout -id ${Source.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false}}

# End MDI window settings


# Create and position top-level window: TopLevel.2

if {![gui_exist_window -window TopLevel.2]} {
    set TopLevel.2 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.2 TopLevel.2
}
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{1 66} {2560 1406}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.2} -option true

# MDI window settings
set Wave.1 [gui_create_window -type {Wave}  -parent ${TopLevel.2}]
gui_show_window -window ${Wave.1} -show_state maximized
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 743} {child_wave_right 1811} {child_wave_colname 369} {child_wave_colvalue 370} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings


# Create and position top-level window: TopLevel.3

if {![gui_exist_window -window TopLevel.3]} {
    set TopLevel.3 [ gui_create_window -type TopLevel \
       -icon $::env(DVE)/auxx/gui/images/toolbars/dvewin.xpm] 
} else { 
    set TopLevel.3 TopLevel.3
}
gui_show_window -window ${TopLevel.3} -show_state maximized -rect {{21 66} {2580 1406}}

# ToolBar settings
gui_set_toolbar_attributes -toolbar {TimeOperations} -dock_state top
gui_set_toolbar_attributes -toolbar {TimeOperations} -offset 0
gui_show_toolbar -toolbar {TimeOperations}
gui_hide_toolbar -toolbar {&File}
gui_set_toolbar_attributes -toolbar {&Edit} -dock_state top
gui_set_toolbar_attributes -toolbar {&Edit} -offset 0
gui_show_toolbar -toolbar {&Edit}
gui_hide_toolbar -toolbar {CopyPaste}
gui_set_toolbar_attributes -toolbar {&Trace} -dock_state top
gui_set_toolbar_attributes -toolbar {&Trace} -offset 0
gui_show_toolbar -toolbar {&Trace}
gui_hide_toolbar -toolbar {TraceInstance}
gui_hide_toolbar -toolbar {BackTrace}
gui_set_toolbar_attributes -toolbar {&Scope} -dock_state top
gui_set_toolbar_attributes -toolbar {&Scope} -offset 0
gui_show_toolbar -toolbar {&Scope}
gui_set_toolbar_attributes -toolbar {&Window} -dock_state top
gui_set_toolbar_attributes -toolbar {&Window} -offset 0
gui_show_toolbar -toolbar {&Window}
gui_set_toolbar_attributes -toolbar {Signal} -dock_state top
gui_set_toolbar_attributes -toolbar {Signal} -offset 0
gui_show_toolbar -toolbar {Signal}
gui_set_toolbar_attributes -toolbar {Zoom} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom} -offset 0
gui_show_toolbar -toolbar {Zoom}
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -dock_state top
gui_set_toolbar_attributes -toolbar {Zoom And Pan History} -offset 0
gui_show_toolbar -toolbar {Zoom And Pan History}
gui_set_toolbar_attributes -toolbar {Grid} -dock_state top
gui_set_toolbar_attributes -toolbar {Grid} -offset 0
gui_show_toolbar -toolbar {Grid}
gui_set_toolbar_attributes -toolbar {Simulator} -dock_state top
gui_set_toolbar_attributes -toolbar {Simulator} -offset 0
gui_show_toolbar -toolbar {Simulator}
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -dock_state top
gui_set_toolbar_attributes -toolbar {Interactive Rewind} -offset 0
gui_show_toolbar -toolbar {Interactive Rewind}
gui_set_toolbar_attributes -toolbar {Testbench} -dock_state top
gui_set_toolbar_attributes -toolbar {Testbench} -offset 0
gui_show_toolbar -toolbar {Testbench}

# End ToolBar settings

# Docked window settings
gui_sync_global -id ${TopLevel.3} -option true

# MDI window settings
set Wave.2 [gui_create_window -type {Wave}  -parent ${TopLevel.3}]
gui_show_window -window ${Wave.2} -show_state maximized
gui_update_layout -id ${Wave.2} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 743} {child_wave_right 1811} {child_wave_colname 369} {child_wave_colvalue 370} {child_wave_col1 0} {child_wave_col2 1}}

# End MDI window settings

gui_set_env TOPLEVELS::TARGET_FRAME(Source) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Schematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(PathSchematic) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(Wave) none
gui_set_env TOPLEVELS::TARGET_FRAME(List) none
gui_set_env TOPLEVELS::TARGET_FRAME(Memory) ${TopLevel.1}
gui_set_env TOPLEVELS::TARGET_FRAME(DriverLoad) none
gui_update_statusbar_target_frame ${TopLevel.1}
gui_update_statusbar_target_frame ${TopLevel.2}
gui_update_statusbar_target_frame ${TopLevel.3}

#</WindowLayout>

#<Database>

# DVE Open design session: 

if { [llength [lindex [gui_get_db -design Sim] 0]] == 0 } {
gui_set_env SIMSETUP::SIMARGS {{ +v2k +vc +define+SIMV=1 +memcbk -ucligui}}
gui_set_env SIMSETUP::SIMEXE {dve}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {dve}] } {
gui_sim_run Ucli -exe dve -args { +v2k +vc +define+SIMV=1 +memcbk -ucligui} -dir ../pipeline -nosource
}
}
if { ![gui_sim_state -check active] } {error "Simulator did not start correctly" error}
gui_set_precision 100ps
gui_set_time_units 100ps
#</Database>

# DVE Global setting session: 


# Global: Breakpoints

# Global: Bus

# Global: Expressions

# Global: Signal Time Shift

# Global: Signal Compare

# Global: Signal Groups
gui_load_child_values {testbench}
gui_load_child_values {testbench.pipeline_0.store_queue}
gui_load_child_values {testbench.pipeline_0.mem_stage_0}
gui_load_child_values {testbench.pipeline_0.iq0}


set _session_group_22 Group1
gui_sg_create "$_session_group_22"
set Group1 "$_session_group_22"

gui_sg_addsignal -group "$_session_group_22" { testbench.clock_count testbench.pipeline_0.rob_retire_out }
gui_set_radix -radix {decimal} -signals {Sim:testbench.clock_count}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.clock_count}

set _session_group_23 $_session_group_22|
append _session_group_23 store_queue
gui_sg_create "$_session_group_23"
set Group1|store_queue "$_session_group_23"

gui_sg_addsignal -group "$_session_group_23" { testbench.pipeline_0.store_queue.store_data_stall testbench.pipeline_0.store_queue.ex_addr_en testbench.pipeline_0.store_queue.load_req testbench.pipeline_0.store_queue.data_ready testbench.pipeline_0.store_queue.ex_index testbench.pipeline_0.store_queue.rt_en testbench.pipeline_0.store_queue.tail_out testbench.pipeline_0.store_queue.stall_req testbench.pipeline_0.store_queue.dispatch_addr_ready testbench.pipeline_0.store_queue.clock testbench.pipeline_0.store_queue.head testbench.pipeline_0.store_queue.reset testbench.pipeline_0.store_queue.data_ready_next testbench.pipeline_0.store_queue.addr_ready_next testbench.pipeline_0.store_queue.data_out testbench.pipeline_0.store_queue.dispatch_data_ready testbench.pipeline_0.store_queue.data testbench.pipeline_0.store_queue.ld_pos testbench.pipeline_0.store_queue.addr testbench.pipeline_0.store_queue.store_head_data testbench.pipeline_0.store_queue.data_ready_out testbench.pipeline_0.store_queue.ex_en testbench.pipeline_0.store_queue.store_head_addr testbench.pipeline_0.store_queue.rd_valid testbench.pipeline_0.store_queue.addr_next testbench.pipeline_0.store_queue.dispatch_data testbench.pipeline_0.store_queue.addr_rd_ready testbench.pipeline_0.store_queue.data_rd testbench.pipeline_0.store_queue.rd_en testbench.pipeline_0.store_queue.head_next testbench.pipeline_0.store_queue.ex_data_en testbench.pipeline_0.store_queue.tail testbench.pipeline_0.store_queue.dispatch_addr testbench.pipeline_0.store_queue.data_rd_idx testbench.pipeline_0.store_queue.full testbench.pipeline_0.store_queue.addr_ready_out testbench.pipeline_0.store_queue.tail_next testbench.pipeline_0.store_queue.ex_data testbench.pipeline_0.store_queue.head_out {testbench.pipeline_0.store_queue.$unit} testbench.pipeline_0.store_queue.data_next testbench.pipeline_0.store_queue.load_gnt testbench.pipeline_0.store_queue.ex_addr testbench.pipeline_0.store_queue.addr_ready testbench.pipeline_0.store_queue.addr_out testbench.pipeline_0.store_queue.addr_rd testbench.pipeline_0.store_queue.dispatch_en }

gui_sg_move "$_session_group_23" -after "$_session_group_22" -pos 2 

set _session_group_24 $_session_group_22|
append _session_group_24 iq0
gui_sg_create "$_session_group_24"
set Group1|iq0 "$_session_group_24"

gui_sg_addsignal -group "$_session_group_24" { testbench.pipeline_0.iq0.fetch_valid testbench.pipeline_0.iq0.clock testbench.pipeline_0.iq0.inst_queue_out testbench.pipeline_0.iq0.reset testbench.pipeline_0.iq0.next_inst_queue testbench.pipeline_0.iq0.duplicate_fetch testbench.pipeline_0.iq0.inst_queue_full testbench.pipeline_0.iq0.inst_queue_entry testbench.pipeline_0.iq0.if_inst_out testbench.pipeline_0.iq0.tail testbench.pipeline_0.iq0.fetch_en testbench.pipeline_0.iq0.branch_incorrect testbench.pipeline_0.iq0.if_inst_in testbench.pipeline_0.iq0.inst_queue testbench.pipeline_0.iq0.dispatch_no_hazard testbench.pipeline_0.iq0.if_inst {testbench.pipeline_0.iq0.$unit} testbench.pipeline_0.iq0.next_tail }

gui_sg_move "$_session_group_24" -after "$_session_group_22" -pos 3 

set _session_group_25 Group2
gui_sg_create "$_session_group_25"
set Group2 "$_session_group_25"

gui_sg_addsignal -group "$_session_group_25" { testbench.pipeline_0.ex_alu_result_out testbench.pipeline_0.ex_take_branch_out testbench.pipeline_0.ex_co_halt testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_done testbench.pipeline_0.ex_co_wr_mem }

set _session_group_26 Group3
gui_sg_create "$_session_group_26"
set Group3 "$_session_group_26"

gui_sg_addsignal -group "$_session_group_26" { testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.mem_co_halt_comb testbench.pipeline_0.mem_co_illegal_comb testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.mem_co_alu_result_comb testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.mem_co_NPC_comb testbench.pipeline_0.mem_co_IR_comb }

set _session_group_27 mem_stage_0
gui_sg_create "$_session_group_27"
set mem_stage_0 "$_session_group_27"

gui_sg_addsignal -group "$_session_group_27" { testbench.pipeline_0.mem_stage_0.ex_mem_alu_result testbench.pipeline_0.mem_stage_0.mem_waiting_tag testbench.pipeline_0.mem_stage_0.sq_data_not_found testbench.pipeline_0.mem_stage_0.clock testbench.pipeline_0.mem_stage_0.write_enable testbench.pipeline_0.mem_stage_0.proc2Dmem_data testbench.pipeline_0.mem_stage_0.reset testbench.pipeline_0.mem_stage_0.mem_stall_out testbench.pipeline_0.mem_stage_0.proc2Dmem_addr testbench.pipeline_0.mem_stage_0.sq_data_valid testbench.pipeline_0.mem_stage_0.mem_result_out testbench.pipeline_0.mem_stage_0.ex_mem_rd_mem testbench.pipeline_0.mem_stage_0.Dmem2proc_tag testbench.pipeline_0.mem_stage_0.ex_mem_wr_mem testbench.pipeline_0.mem_stage_0.ex_mem_rega {testbench.pipeline_0.mem_stage_0.$unit} testbench.pipeline_0.mem_stage_0.Dmem2proc_data testbench.pipeline_0.mem_stage_0.proc2Dmem_command testbench.pipeline_0.mem_stage_0.Dmem2proc_response }

set _session_group_28 memory
gui_sg_create "$_session_group_28"
set memory "$_session_group_28"

gui_sg_addsignal -group "$_session_group_28" { testbench.memory.cycles_left testbench.memory.mem2proc_response testbench.memory.mem2proc_tag testbench.pipeline_0.proc2Dmem_command testbench.pipeline_0.proc2Imem_command testbench.pipeline_0.Dmem2proc_response testbench.pipeline_0.Imem2proc_response testbench.memory.next_mem2proc_tag testbench.memory.waiting_for_bus testbench.memory.valid_address testbench.memory.bus_filled testbench.memory.loaded_data testbench.memory.acquire_tag testbench.memory.next_mem2proc_data testbench.memory.next_mem2proc_response testbench.memory.clk testbench.memory.mem2proc_data {testbench.memory.$unit} testbench.memory.proc2mem_data testbench.memory.proc2mem_command testbench.memory.proc2mem_addr }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 4410



# Save global setting...

# Wave/List view global setting
gui_cov_show_value -switch false

# Close all empty TopLevel windows
foreach __top [gui_ekki_get_window_ids -type TopLevel] {
    if { [llength [gui_ekki_get_window_ids -parent $__top]] == 0} {
        gui_close_window -window $__top
    }
}
gui_set_loading_session_type noSession
# DVE View/pane content session: 


# Hier 'Hier.1'
gui_show_window -window ${Hier.1}
gui_list_set_filter -id ${Hier.1} -list { {Package 1} {All 0} {Process 1} {VirtPowSwitch 0} {UnnamedProcess 1} {UDP 0} {Function 1} {Block 1} {SrsnAndSpaCell 0} {OVA Unit 1} {LeafScCell 1} {LeafVlgCell 1} {Interface 1} {LeafVhdCell 1} {$unit 1} {NamedBlock 1} {Task 1} {VlgPackage 1} {ClassDef 1} {VirtIsoCell 0} }
gui_list_set_filter -id ${Hier.1} -text {*}
gui_hier_list_init -id ${Hier.1}
gui_change_design -id ${Hier.1} -design Sim
catch {gui_list_expand -id ${Hier.1} testbench}
catch {gui_list_select -id ${Hier.1} {testbench.pipeline_0}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*Imem2proc*}
gui_list_show_data -id ${Data.1} {testbench.pipeline_0}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {testbench.pipeline_0.Imem2proc_response }}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active _vcs_unit__4062623735 /afs/umich.edu/user/s/u/surajrs/470/group10w19/verilog/pipeline.v
gui_src_value_annotate -id ${Source.1} -switch true
gui_set_env TOGGLE::VALUEANNOTATE 1
gui_view_scroll -id ${Source.1} -vertical -set 0
gui_src_set_reusable -id ${Source.1}

# View 'Wave.1'
gui_wv_sync -id ${Wave.1} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.1}  C1
gui_wv_zoom_timerange -id ${Wave.1} 2504 7514
gui_list_add_group -id ${Wave.1} -after {New Group} {mem_stage_0}
gui_list_select -id ${Wave.1} {testbench.pipeline_0.mem_stage_0.proc2Dmem_command }
gui_seek_criteria -id ${Wave.1} {Any Edge}


gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.1} -text {*}
gui_list_set_insertion_bar  -id ${Wave.1} -group mem_stage_0  -position in

gui_marker_move -id ${Wave.1} {C1} 4410
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false

# View 'Wave.2'
gui_wv_sync -id ${Wave.2} -switch false
set groupExD [gui_get_pref_value -category Wave -key exclusiveSG]
gui_set_pref_value -category Wave -key exclusiveSG -value {false}
set origWaveHeight [gui_get_pref_value -category Wave -key waveRowHeight]
gui_list_set_height -id Wave -height 25
set origGroupCreationState [gui_list_create_group_when_add -wave]
gui_list_create_group_when_add -wave -disable
gui_marker_set_ref -id ${Wave.2}  C1
gui_wv_zoom_timerange -id ${Wave.2} 0 5010
gui_list_add_group -id ${Wave.2} -after {New Group} {memory}
gui_list_select -id ${Wave.2} {testbench.memory.clk }
gui_seek_criteria -id ${Wave.2} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.2}
gui_set_pref_value -category Wave -key exclusiveSG -value $groupExD
gui_list_set_height -id Wave -height $origWaveHeight
if {$origGroupCreationState} {
	gui_list_create_group_when_add -wave -enable
}
if { $groupExD } {
 gui_msg_report -code DVWW028
}
gui_list_set_filter -id ${Wave.2} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Wave.2} -text {*}
gui_list_set_insertion_bar  -id ${Wave.2} -group memory  -item {testbench.pipeline_0.Imem2proc_response[3:0]} -position below

gui_marker_move -id ${Wave.2} {C1} 4410
gui_view_scroll -id ${Wave.2} -vertical -set 0
gui_show_grid -id ${Wave.2} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.3}]} {
	gui_set_active_window -window ${TopLevel.3}
	gui_set_active_window -window ${Wave.2}
}
#</Session>

