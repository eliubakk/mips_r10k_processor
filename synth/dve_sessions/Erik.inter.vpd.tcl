# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sat Apr 20 14:17:04 2019
# Designs open: 1
#   Sim: dve
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: testbench.unnamed$$_1
#   Wave.1: 1109 signals
#   Group count = 33
#   Group CDB signal count = 9
#   Group R0 signal count = 47
#   Group ROB signal count = 47
#   Group RS signal count = 49
#   Group Arch_Map signal count = 18
#   Group BP2 signal count = 48
#   Group ex_stage signal count = 15
#   Group Free_List signal count = 22
#   Group id_stage signal count = 22
#   Group if_stage signal count = 24
#   Group icache signal count = 51
#   Group icache_mem signal count = 44
#   Group IQ signal count = 19
#   Group LQ signal count = 19
#   Group Map_Table signal count = 22
#   Group mem_stage signal count = 31
#   Group memory signal count = 34
#   Group Phys_reg_file signal count = 9
#   Group SQ signal count = 47
#   Group dcache_mem signal count = 44
#   Group dcache signal count = 96
#   Group retire_buffer signal count = 22
#   Group Group1 signal count = 30
#   Group pipeline if signals signal count = 30
#   Group pipeline id signals signal count = 57
#   Group pipeline di signals signal count = 20
#   Group pipeline is signals signal count = 30
#   Group pipeline ex signals signal count = 35
#   Group pipeline mem signals signal count = 45
#   Group pipeline co signals signal count = 77
#   Group pipeline ret signals signal count = 27
#   Group ex_stage_0 signal count = 16
#   Group Group2 signal count = 80
# End_DVE_Session_Save_Info

# DVE version: N-2017.12-SP2-1_Full64
# DVE build date: Jul 14 2018 20:58:30


#<Session mode="Full" path="/afs/umich.edu/user/e/l/eliubakk/eecs470/projects/4/synth/dve_sessions/Erik.inter.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{0 65} {1919 1045}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 252]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 252
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 251} {height 720} {dock_state left} {dock_on_new_line true} {child_hier_colhier 149} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 489]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 489
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 935
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 488} {height 720} {dock_state left} {dock_on_new_line true} {child_data_colvariable 212} {child_data_colvalue 153} {child_data_coltype 144} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 162]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1860
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 162
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1919} {height 161} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{419 150} {2272 1083}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 538} {child_wave_right 1310} {child_wave_colname 267} {child_wave_colvalue 267} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {testbench.pipeline_0.RS0}
gui_load_child_values {testbench.pipeline_0.mem_stage_0.rb0}
gui_load_child_values {testbench.pipeline_0.regf_0}
gui_load_child_values {testbench.pipeline_0.inst_memory}
gui_load_child_values {testbench.pipeline_0.load_queue}
gui_load_child_values {testbench.pipeline_0.bp0}
gui_load_child_values {testbench.pipeline_0.if_stage_0}
gui_load_child_values {testbench.pipeline_0.ex_stage_0}
gui_load_child_values {testbench.pipeline_0.mem_stage_0.dcache0}
gui_load_child_values {testbench.pipeline_0.CDB_0}
gui_load_child_values {testbench.pipeline_0.store_queue}
gui_load_child_values {testbench.pipeline_0.mem_stage_0}
gui_load_child_values {testbench.pipeline_0.f0}
gui_load_child_values {testbench.pipeline_0.R0}
gui_load_child_values {testbench.pipeline_0.iq0}
gui_load_child_values {testbench.pipeline_0.a0}
gui_load_child_values {testbench.pipeline_0.m1}
gui_load_child_values {testbench.pipeline_0.inst_memory.memory}


set _session_group_1 CDB
gui_sg_create "$_session_group_1"
set CDB "$_session_group_1"

gui_sg_addsignal -group "$_session_group_1" { testbench.pipeline_0.CDB_0.clock testbench.pipeline_0.CDB_0.reset testbench.pipeline_0.CDB_0.enable testbench.pipeline_0.CDB_0.busy testbench.pipeline_0.CDB_0.CDB_en_out testbench.pipeline_0.CDB_0.ex_valid {testbench.pipeline_0.CDB_0.$unit} testbench.pipeline_0.CDB_0.CDB_tag_out testbench.pipeline_0.CDB_0.tag_in }

set _session_group_2 R0
gui_sg_create "$_session_group_2"
set R0 "$_session_group_2"

gui_sg_addsignal -group "$_session_group_2" { testbench.pipeline_0.R0.cam_tags_in testbench.pipeline_0.R0.retire_idx_valid testbench.pipeline_0.R0.ROB_table testbench.pipeline_0.R0.tail_out testbench.pipeline_0.R0.clock testbench.pipeline_0.R0.cam_hits testbench.pipeline_0.R0.head testbench.pipeline_0.R0.reset testbench.pipeline_0.R0.retired testbench.pipeline_0.R0.enable testbench.pipeline_0.R0.ROB_table_next testbench.pipeline_0.R0.wr_idx testbench.pipeline_0.R0.ready_to_retire_out testbench.pipeline_0.R0.CDB_br_valid testbench.pipeline_0.R0.T_new_in testbench.pipeline_0.R0.head_next_out testbench.pipeline_0.R0.npc testbench.pipeline_0.R0.CDB_tag_in testbench.pipeline_0.R0.retire_idx_out testbench.pipeline_0.R0.ROB_table_out testbench.pipeline_0.R0.co_alu_result testbench.pipeline_0.R0.branch_not_taken testbench.pipeline_0.R0.head_next_busy testbench.pipeline_0.R0.tail_next_out testbench.pipeline_0.R0.free_rows_next testbench.pipeline_0.R0.retire_out testbench.pipeline_0.R0.take_branch testbench.pipeline_0.R0.head_next testbench.pipeline_0.R0.tail testbench.pipeline_0.R0.ready_to_retire testbench.pipeline_0.R0.T_old_in testbench.pipeline_0.R0.full testbench.pipeline_0.R0.dispatch_idx testbench.pipeline_0.R0.halt_in testbench.pipeline_0.R0.cam_table_in testbench.pipeline_0.R0.tail_next testbench.pipeline_0.R0.retire_idx_valid_out testbench.pipeline_0.R0.head_out {testbench.pipeline_0.R0.$unit} testbench.pipeline_0.R0.dispatched testbench.pipeline_0.R0.CDB_br_idx testbench.pipeline_0.R0.dispatch_idx_out testbench.pipeline_0.R0.retire_idx testbench.pipeline_0.R0.id_branch_inst testbench.pipeline_0.R0.opcode testbench.pipeline_0.R0.dispatch_en testbench.pipeline_0.R0.CAM_en }

set _session_group_3 ROB
gui_sg_create "$_session_group_3"
set ROB "$_session_group_3"

gui_sg_addsignal -group "$_session_group_3" { testbench.pipeline_0.R0.cam_tags_in testbench.pipeline_0.R0.retire_idx_valid testbench.pipeline_0.R0.ROB_table testbench.pipeline_0.R0.tail_out testbench.pipeline_0.R0.clock testbench.pipeline_0.R0.cam_hits testbench.pipeline_0.R0.head testbench.pipeline_0.R0.reset testbench.pipeline_0.R0.retired testbench.pipeline_0.R0.enable testbench.pipeline_0.R0.ROB_table_next testbench.pipeline_0.R0.wr_idx testbench.pipeline_0.R0.ready_to_retire_out testbench.pipeline_0.R0.CDB_br_valid testbench.pipeline_0.R0.T_new_in testbench.pipeline_0.R0.head_next_out testbench.pipeline_0.R0.npc testbench.pipeline_0.R0.CDB_tag_in testbench.pipeline_0.R0.retire_idx_out testbench.pipeline_0.R0.ROB_table_out testbench.pipeline_0.R0.co_alu_result testbench.pipeline_0.R0.branch_not_taken testbench.pipeline_0.R0.head_next_busy testbench.pipeline_0.R0.tail_next_out testbench.pipeline_0.R0.free_rows_next testbench.pipeline_0.R0.retire_out testbench.pipeline_0.R0.take_branch testbench.pipeline_0.R0.head_next testbench.pipeline_0.R0.tail testbench.pipeline_0.R0.ready_to_retire testbench.pipeline_0.R0.T_old_in testbench.pipeline_0.R0.full testbench.pipeline_0.R0.dispatch_idx testbench.pipeline_0.R0.halt_in testbench.pipeline_0.R0.cam_table_in testbench.pipeline_0.R0.tail_next testbench.pipeline_0.R0.retire_idx_valid_out testbench.pipeline_0.R0.head_out {testbench.pipeline_0.R0.$unit} testbench.pipeline_0.R0.dispatched testbench.pipeline_0.R0.CDB_br_idx testbench.pipeline_0.R0.dispatch_idx_out testbench.pipeline_0.R0.retire_idx testbench.pipeline_0.R0.id_branch_inst testbench.pipeline_0.R0.opcode testbench.pipeline_0.R0.dispatch_en testbench.pipeline_0.R0.CAM_en }

set _session_group_4 RS
gui_sg_create "$_session_group_4"
set RS "$_session_group_4"

gui_sg_addsignal -group "$_session_group_4" { testbench.pipeline_0.RS0.dispatch_reqs testbench.pipeline_0.RS0.cam_tags_in {testbench.pipeline_0.RS0.genblk5[3].end_idx} testbench.pipeline_0.RS0.rs_full testbench.pipeline_0.RS0.CDB_in testbench.pipeline_0.RS0.issue_gnts testbench.pipeline_0.RS0.dispatch_valid testbench.pipeline_0.RS0.dispatch_gnt_bus testbench.pipeline_0.RS0.clock {testbench.pipeline_0.RS0.genblk4[2].end_idx} testbench.pipeline_0.RS0.busy_bits testbench.pipeline_0.RS0.issue_idx_valid_shifted testbench.pipeline_0.RS0.issue_reqs testbench.pipeline_0.RS0.cam_hits testbench.pipeline_0.RS0.rs_table testbench.pipeline_0.RS0.issue_idx_shifted testbench.pipeline_0.RS0.reset testbench.pipeline_0.RS0.issue_idx_valid testbench.pipeline_0.RS0.dispatch_gnt testbench.pipeline_0.RS0.rs_table_next_out testbench.pipeline_0.RS0.enable {testbench.pipeline_0.RS0.genblk5[1].end_idx} testbench.pipeline_0.RS0.inst_in testbench.pipeline_0.RS0.i {testbench.pipeline_0.RS0.genblk5[4].end_idx} testbench.pipeline_0.RS0.j testbench.pipeline_0.RS0.issue_stall {testbench.pipeline_0.RS0.genblk4[0].end_idx} testbench.pipeline_0.RS0.FU_BASE_IDX testbench.pipeline_0.RS0.di_branch_inst_idx testbench.pipeline_0.RS0.issue_out {testbench.pipeline_0.RS0.genblk4[3].end_idx} testbench.pipeline_0.RS0.branch_not_taken testbench.pipeline_0.RS0.dispatch_idx_valid testbench.pipeline_0.RS0.free_rows_next {testbench.pipeline_0.RS0.genblk5[2].end_idx} testbench.pipeline_0.RS0.FU_NAME_VAL testbench.pipeline_0.RS0.issue_gnt_bus testbench.pipeline_0.RS0.dispatch_idx testbench.pipeline_0.RS0.rs_table_next {testbench.pipeline_0.RS0.genblk4[1].end_idx} testbench.pipeline_0.RS0.cam_table_in testbench.pipeline_0.RS0.issue_idx testbench.pipeline_0.RS0.NUM_OF_FU_TYPE testbench.pipeline_0.RS0.rs_table_out {testbench.pipeline_0.RS0.$unit} {testbench.pipeline_0.RS0.genblk4[4].end_idx} {testbench.pipeline_0.RS0.genblk5[0].end_idx} testbench.pipeline_0.RS0.CAM_en }
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[3].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[3].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[2].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[2].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[1].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[1].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[4].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[4].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[0].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[0].end_idx}}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.RS0.FU_BASE_IDX}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.pipeline_0.RS0.FU_BASE_IDX}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[3].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[3].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[2].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[2].end_idx}}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.RS0.FU_NAME_VAL}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.pipeline_0.RS0.FU_NAME_VAL}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[1].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[1].end_idx}}
gui_set_radix -radix {binary} -signals {Sim:testbench.pipeline_0.RS0.NUM_OF_FU_TYPE}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[4].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[4].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[0].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[0].end_idx}}

set _session_group_5 Arch_Map
gui_sg_create "$_session_group_5"
set Arch_Map "$_session_group_5"

gui_sg_addsignal -group "$_session_group_5" { testbench.pipeline_0.a0.T_idx1_over_idx2 testbench.pipeline_0.a0.cam_tags_in testbench.pipeline_0.a0.clock testbench.pipeline_0.a0.cam_hits testbench.pipeline_0.a0.reset testbench.pipeline_0.a0.enable testbench.pipeline_0.a0.T_new_in testbench.pipeline_0.a0.arch_map_table testbench.pipeline_0.a0.T_new_forwarded testbench.pipeline_0.a0.T_old_forwarded testbench.pipeline_0.a0.enable_forwarded testbench.pipeline_0.a0.T_old_in testbench.pipeline_0.a0.arch_map_table_next testbench.pipeline_0.a0.cam_table_in {testbench.pipeline_0.a0.$unit} testbench.pipeline_0.a0.T_idx0_over_idx1 testbench.pipeline_0.a0.T_idx0_over_idx2 testbench.pipeline_0.a0.retire_idx }

set _session_group_6 BP2
gui_sg_create "$_session_group_6"
set BP2 "$_session_group_6"

gui_sg_addsignal -group "$_session_group_6" { testbench.pipeline_0.bp0.ras_stack_out testbench.pipeline_0.bp0.next_pc_calc testbench.pipeline_0.bp0.ras_next_pc testbench.pipeline_0.bp0.rt_return_branch testbench.pipeline_0.bp0.next_pc_index_calc testbench.pipeline_0.bp0.btb_write_en testbench.pipeline_0.bp0.bp_read_en testbench.pipeline_0.bp0.btb_valid_out testbench.pipeline_0.bp0.if_cond_branch testbench.pipeline_0.bp0.clock testbench.pipeline_0.bp0.ras_write_en testbench.pipeline_0.bp0.rt_calculated_pc testbench.pipeline_0.bp0.if_pc_in testbench.pipeline_0.bp0.roll_back testbench.pipeline_0.bp0.reset testbench.pipeline_0.bp0.next_pc testbench.pipeline_0.bp0.rt_direct_branch testbench.pipeline_0.bp0.btb_next_pc_valid testbench.pipeline_0.bp0.if_prediction testbench.pipeline_0.bp0.enable testbench.pipeline_0.bp0.rt_pc testbench.pipeline_0.bp0.next_pc_prediction_calc testbench.pipeline_0.bp0.bp_write_en testbench.pipeline_0.bp0.br_idx testbench.pipeline_0.bp0.ras_head_out testbench.pipeline_0.bp0.next_pc_valid_calc testbench.pipeline_0.bp0.if_return_branch testbench.pipeline_0.bp0.rt_branch_taken testbench.pipeline_0.bp0.btb_tag_out testbench.pipeline_0.bp0.pht_out testbench.pipeline_0.bp0.rt_cond_branch testbench.pipeline_0.bp0.if_direct_branch testbench.pipeline_0.bp0.next_br_idx testbench.pipeline_0.bp0.next_pc_valid testbench.pipeline_0.bp0.ras_tail_out testbench.pipeline_0.bp0.btb_target_address_out testbench.pipeline_0.bp0.if_en_branch testbench.pipeline_0.bp0.next_pc_prediction testbench.pipeline_0.bp0.if_prediction_valid testbench.pipeline_0.bp0.btb_read_en testbench.pipeline_0.bp0.rt_branch_index testbench.pipeline_0.bp0.next_pc_index {testbench.pipeline_0.bp0.$unit} testbench.pipeline_0.bp0.btb_next_pc testbench.pipeline_0.bp0.ras_read_en testbench.pipeline_0.bp0.rt_en_branch testbench.pipeline_0.bp0.rt_prediction_correct testbench.pipeline_0.bp0.ras_next_pc_valid }

set _session_group_7 ex_stage
gui_sg_create "$_session_group_7"
set ex_stage "$_session_group_7"

gui_sg_addsignal -group "$_session_group_7" { testbench.pipeline_0.ex_stage_0.brcond_result testbench.pipeline_0.ex_stage_0.clock testbench.pipeline_0.ex_stage_0.opb_mux_out testbench.pipeline_0.ex_stage_0.br_disp testbench.pipeline_0.ex_stage_0.reset testbench.pipeline_0.ex_stage_0.mem_disp testbench.pipeline_0.ex_stage_0.issue_reg testbench.pipeline_0.ex_stage_0.T2_value testbench.pipeline_0.ex_stage_0.ex_take_branch_out testbench.pipeline_0.ex_stage_0.alu_imm testbench.pipeline_0.ex_stage_0.done testbench.pipeline_0.ex_stage_0.T1_value {testbench.pipeline_0.ex_stage_0.$unit} testbench.pipeline_0.ex_stage_0.opa_mux_out testbench.pipeline_0.ex_stage_0.ex_alu_result_out }

set _session_group_8 Free_List
gui_sg_create "$_session_group_8"
set Free_List "$_session_group_8"

gui_sg_addsignal -group "$_session_group_8" { testbench.pipeline_0.f0.free_list testbench.pipeline_0.f0.free_reg testbench.pipeline_0.f0.tail_out testbench.pipeline_0.f0.clock testbench.pipeline_0.f0.reset testbench.pipeline_0.f0.id_no_dest_reg testbench.pipeline_0.f0.enable testbench.pipeline_0.f0.next_free_list testbench.pipeline_0.f0.next_tail_check_point testbench.pipeline_0.f0.tail_check_point testbench.pipeline_0.f0.empty testbench.pipeline_0.f0.free_list_out testbench.pipeline_0.f0.free_check_point testbench.pipeline_0.f0.tail testbench.pipeline_0.f0.branch_incorrect testbench.pipeline_0.f0.T_old testbench.pipeline_0.f0.num_free_entries testbench.pipeline_0.f0.next_free_check_point {testbench.pipeline_0.f0.$unit} testbench.pipeline_0.f0.T_new testbench.pipeline_0.f0.next_tail testbench.pipeline_0.f0.dispatch_en }

set _session_group_9 id_stage
gui_sg_create "$_session_group_9"
set id_stage "$_session_group_9"

gui_sg_addsignal -group "$_session_group_9" { testbench.pipeline_0.id_stage_0.id_uncond_branch_out testbench.pipeline_0.id_stage_0.rdest_idx testbench.pipeline_0.id_stage_0.clock testbench.pipeline_0.id_stage_0.id_alu_func_out testbench.pipeline_0.id_stage_0.rb_idx testbench.pipeline_0.id_stage_0.id_fu_name_out testbench.pipeline_0.id_stage_0.reset testbench.pipeline_0.id_stage_0.id_stc_mem_out testbench.pipeline_0.id_stage_0.id_rd_mem_out testbench.pipeline_0.id_stage_0.id_wr_mem_out testbench.pipeline_0.id_stage_0.ra_idx testbench.pipeline_0.id_stage_0.id_opa_select_out testbench.pipeline_0.id_stage_0.id_halt_out testbench.pipeline_0.id_stage_0.if_id_valid_inst testbench.pipeline_0.id_stage_0.id_illegal_out testbench.pipeline_0.id_stage_0.id_ldl_mem_out testbench.pipeline_0.id_stage_0.id_valid_inst_out testbench.pipeline_0.id_stage_0.id_cond_branch_out testbench.pipeline_0.id_stage_0.id_cpuid_out testbench.pipeline_0.id_stage_0.id_opb_select_out {testbench.pipeline_0.id_stage_0.$unit} testbench.pipeline_0.id_stage_0.if_id_IR }

set _session_group_10 if_stage
gui_sg_create "$_session_group_10"
set if_stage "$_session_group_10"

gui_sg_addsignal -group "$_session_group_10" { testbench.pipeline_0.if_stage_0.Imem_valid testbench.pipeline_0.if_stage_0.next_ready_for_valid testbench.pipeline_0.if_stage_0.if_IR_out testbench.pipeline_0.if_stage_0.clock testbench.pipeline_0.if_stage_0.reset testbench.pipeline_0.if_stage_0.next_PC testbench.pipeline_0.if_stage_0.PC_reg testbench.pipeline_0.if_stage_0.PC_plus_4 testbench.pipeline_0.if_stage_0.if_bp_NPC testbench.pipeline_0.if_stage_0.co_ret_take_branch testbench.pipeline_0.if_stage_0.co_ret_valid_inst testbench.pipeline_0.if_stage_0.if_valid_inst_out testbench.pipeline_0.if_stage_0.if_valid_inst testbench.pipeline_0.if_stage_0.if_PC_reg testbench.pipeline_0.if_stage_0.if_NPC_out testbench.pipeline_0.if_stage_0.co_ret_branch_valid testbench.pipeline_0.if_stage_0.Imem2proc_data testbench.pipeline_0.if_stage_0.proc2Imem_addr testbench.pipeline_0.if_stage_0.if_bp_NPC_valid {testbench.pipeline_0.if_stage_0.$unit} testbench.pipeline_0.if_stage_0.ready_for_valid testbench.pipeline_0.if_stage_0.PC_enable testbench.pipeline_0.if_stage_0.dispatch_en testbench.pipeline_0.if_stage_0.co_ret_target_pc }

set _session_group_11 icache
gui_sg_create "$_session_group_11"
set icache "$_session_group_11"

gui_sg_addsignal -group "$_session_group_11" { testbench.pipeline_0.inst_memory.current_tag testbench.pipeline_0.inst_memory.PC_in testbench.pipeline_0.inst_memory.cam_tags_in testbench.pipeline_0.inst_memory.changed_addr testbench.pipeline_0.inst_memory.cache_wr_miss_tag testbench.pipeline_0.inst_memory.Icache_valid_out testbench.pipeline_0.inst_memory.send_req_ptr testbench.pipeline_0.inst_memory.cache_rd_idx testbench.pipeline_0.inst_memory.cache_rd_miss_idx testbench.pipeline_0.inst_memory.current_index testbench.pipeline_0.inst_memory.PC_queue_next testbench.pipeline_0.inst_memory.send_request testbench.pipeline_0.inst_memory.clock testbench.pipeline_0.inst_memory.PC_queue testbench.pipeline_0.inst_memory.PC_in_Plus_hits testbench.pipeline_0.inst_memory.PC_queue_tail testbench.pipeline_0.inst_memory.reset testbench.pipeline_0.inst_memory.update_mem_tag testbench.pipeline_0.inst_memory.cache_wr_idx testbench.pipeline_0.inst_memory.cache_wr_data testbench.pipeline_0.inst_memory.cache_rd_tag testbench.pipeline_0.inst_memory.cache_rd_miss_tag testbench.pipeline_0.inst_memory.Imem2proc_response testbench.pipeline_0.inst_memory.proc2Imem_command testbench.pipeline_0.inst_memory.unanswered_miss testbench.pipeline_0.inst_memory.cache_wr_miss_valid testbench.pipeline_0.inst_memory.mem_waiting_ptr_next testbench.pipeline_0.inst_memory.Icache_data_out testbench.pipeline_0.inst_memory.cache_wr_miss_idx testbench.pipeline_0.inst_memory.PC_in_Plus testbench.pipeline_0.inst_memory.cache_wr_tag testbench.pipeline_0.inst_memory.PC_queue_tail_next testbench.pipeline_0.inst_memory.cache_rd_miss_valid testbench.pipeline_0.inst_memory.Imem2proc_data testbench.pipeline_0.inst_memory.NUM_WAYS testbench.pipeline_0.inst_memory.Imem2proc_tag testbench.pipeline_0.inst_memory.cache_wr_en testbench.pipeline_0.inst_memory.proc2Icache_addr testbench.pipeline_0.inst_memory.cache_rd_data testbench.pipeline_0.inst_memory.RD_PORTS testbench.pipeline_0.inst_memory.cam_table_in testbench.pipeline_0.inst_memory.proc2Imem_addr testbench.pipeline_0.inst_memory.cache_rd_en {testbench.pipeline_0.inst_memory.$unit} testbench.pipeline_0.inst_memory.last_PC_in testbench.pipeline_0.inst_memory.cache_rd_valid testbench.pipeline_0.inst_memory.mem_done testbench.pipeline_0.inst_memory.PC_cam_hits testbench.pipeline_0.inst_memory.mem_waiting_ptr testbench.pipeline_0.inst_memory.PC_in_hits testbench.pipeline_0.inst_memory.send_req_ptr_next }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.NUM_WAYS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.RD_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.RD_PORTS}

set _session_group_12 icache_mem
gui_sg_create "$_session_group_12"
set icache_mem "$_session_group_12"

gui_sg_addsignal -group "$_session_group_12" { testbench.pipeline_0.inst_memory.memory.wr_cam_table_in testbench.pipeline_0.inst_memory.memory.acc testbench.pipeline_0.inst_memory.memory.rd_idx testbench.pipeline_0.inst_memory.memory.bst_next testbench.pipeline_0.inst_memory.memory.sets_out testbench.pipeline_0.inst_memory.memory.rd_tag_hits testbench.pipeline_0.inst_memory.memory.clock testbench.pipeline_0.inst_memory.memory.wr_cam_hits_out testbench.pipeline_0.inst_memory.memory.reset testbench.pipeline_0.inst_memory.memory.next_bst_idx testbench.pipeline_0.inst_memory.memory.wr_miss_tag testbench.pipeline_0.inst_memory.memory.rd_tag_idx testbench.pipeline_0.inst_memory.memory.rd_miss_idx testbench.pipeline_0.inst_memory.memory.bst_out testbench.pipeline_0.inst_memory.memory.wr_idx testbench.pipeline_0.inst_memory.memory.wr_tag_idx testbench.pipeline_0.inst_memory.memory.wr_data testbench.pipeline_0.inst_memory.memory.rd_miss_valid testbench.pipeline_0.inst_memory.memory.wr_new_tag_idx testbench.pipeline_0.inst_memory.memory.rd_tag testbench.pipeline_0.inst_memory.memory.wr_miss_valid testbench.pipeline_0.inst_memory.memory.WR_PORTS testbench.pipeline_0.inst_memory.memory.rd_valid testbench.pipeline_0.inst_memory.memory.wr_en testbench.pipeline_0.inst_memory.memory.rd_en testbench.pipeline_0.inst_memory.memory.victim_valid testbench.pipeline_0.inst_memory.memory.sets testbench.pipeline_0.inst_memory.memory.rd_miss_tag testbench.pipeline_0.inst_memory.memory.wr_tag testbench.pipeline_0.inst_memory.memory.temp_idx testbench.pipeline_0.inst_memory.memory.wr_tag_hits testbench.pipeline_0.inst_memory.memory.NUM_WAYS testbench.pipeline_0.inst_memory.memory.vic_idx testbench.pipeline_0.inst_memory.memory.rd_cam_table_in testbench.pipeline_0.inst_memory.memory.rd_data testbench.pipeline_0.inst_memory.memory.RD_PORTS testbench.pipeline_0.inst_memory.memory.sets_next testbench.pipeline_0.inst_memory.memory.bst testbench.pipeline_0.inst_memory.memory.victim {testbench.pipeline_0.inst_memory.memory.$unit} testbench.pipeline_0.inst_memory.memory.wr_miss_idx testbench.pipeline_0.inst_memory.memory.rd_cam_hits_out testbench.pipeline_0.inst_memory.memory.wr_forward_to_rd testbench.pipeline_0.inst_memory.memory.wr_dirty }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.WR_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.WR_PORTS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.NUM_WAYS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.RD_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.RD_PORTS}

set _session_group_13 IQ
gui_sg_create "$_session_group_13"
set IQ "$_session_group_13"

gui_sg_addsignal -group "$_session_group_13" { testbench.pipeline_0.iq0.fetch_valid testbench.pipeline_0.iq0.clock testbench.pipeline_0.iq0.inst_queue_out testbench.pipeline_0.iq0.reset testbench.pipeline_0.iq0.next_inst_queue testbench.pipeline_0.iq0.duplicate_fetch testbench.pipeline_0.iq0.inst_queue_full testbench.pipeline_0.iq0.inst_queue_full_out testbench.pipeline_0.iq0.inst_queue_entry testbench.pipeline_0.iq0.if_inst_out testbench.pipeline_0.iq0.tail testbench.pipeline_0.iq0.fetch_en testbench.pipeline_0.iq0.branch_incorrect testbench.pipeline_0.iq0.if_inst_in testbench.pipeline_0.iq0.inst_queue testbench.pipeline_0.iq0.dispatch_no_hazard testbench.pipeline_0.iq0.next_inst_queue_full {testbench.pipeline_0.iq0.$unit} testbench.pipeline_0.iq0.next_tail }

set _session_group_14 LQ
gui_sg_create "$_session_group_14"
set LQ "$_session_group_14"

gui_sg_addsignal -group "$_session_group_14" { testbench.pipeline_0.load_queue.load_out testbench.pipeline_0.load_queue.addr_hits testbench.pipeline_0.load_queue.clock testbench.pipeline_0.load_queue.read_valid testbench.pipeline_0.load_queue.head testbench.pipeline_0.load_queue.reset testbench.pipeline_0.load_queue.load_in testbench.pipeline_0.load_queue.lq_miss_valid testbench.pipeline_0.load_queue.load_queue testbench.pipeline_0.load_queue.write_en testbench.pipeline_0.load_queue.head_next testbench.pipeline_0.load_queue.tail testbench.pipeline_0.load_queue.full testbench.pipeline_0.load_queue.lq_miss_data testbench.pipeline_0.load_queue.pop_en testbench.pipeline_0.load_queue.tail_next testbench.pipeline_0.load_queue.load_queue_next testbench.pipeline_0.load_queue.lq_miss_addr {testbench.pipeline_0.load_queue.$unit} }

set _session_group_15 Map_Table
gui_sg_create "$_session_group_15"
set Map_Table "$_session_group_15"

gui_sg_addsignal -group "$_session_group_15" { testbench.pipeline_0.m1.cam_tags_in testbench.pipeline_0.m1.map_table_out testbench.pipeline_0.m1.T1 testbench.pipeline_0.m1.T2 testbench.pipeline_0.m1.free_reg testbench.pipeline_0.m1.clock testbench.pipeline_0.m1.cam_hits testbench.pipeline_0.m1.reset testbench.pipeline_0.m1.enable testbench.pipeline_0.m1.CDB_tag_in testbench.pipeline_0.m1.map_table testbench.pipeline_0.m1.reg_a testbench.pipeline_0.m1.map_check_point testbench.pipeline_0.m1.reg_b testbench.pipeline_0.m1.next_map_table testbench.pipeline_0.m1.CDB_en testbench.pipeline_0.m1.branch_incorrect testbench.pipeline_0.m1.T_old testbench.pipeline_0.m1.cam_table_in {testbench.pipeline_0.m1.$unit} testbench.pipeline_0.m1.cam_hits_out testbench.pipeline_0.m1.reg_dest }

set _session_group_16 mem_stage
gui_sg_create "$_session_group_16"
set mem_stage "$_session_group_16"

gui_sg_addsignal -group "$_session_group_16" { testbench.pipeline_0.mem_stage_0.Rmem2proc_response testbench.pipeline_0.mem_stage_0.sq_data_not_found testbench.pipeline_0.mem_stage_0.clock testbench.pipeline_0.mem_stage_0.wr_mem testbench.pipeline_0.mem_stage_0.Dcache_data_out testbench.pipeline_0.mem_stage_0.proc2Dmem_data testbench.pipeline_0.mem_stage_0.reset testbench.pipeline_0.mem_stage_0.mem_rd_miss_valid_out testbench.pipeline_0.mem_stage_0.mem_stall_out testbench.pipeline_0.mem_stage_0.proc2Dmem_addr testbench.pipeline_0.mem_stage_0.sq_data_valid testbench.pipeline_0.mem_stage_0.mem_rd_stall testbench.pipeline_0.mem_stage_0.ret_buf_full testbench.pipeline_0.mem_stage_0.mem_result_out testbench.pipeline_0.mem_stage_0.wr_data testbench.pipeline_0.mem_stage_0.proc2Rmem_data testbench.pipeline_0.mem_stage_0.wr_addr testbench.pipeline_0.mem_stage_0.Dcache_valid_out testbench.pipeline_0.mem_stage_0.proc2Rmem_addr testbench.pipeline_0.mem_stage_0.mem_rd_miss_addr_out testbench.pipeline_0.mem_stage_0.evicted_valid testbench.pipeline_0.mem_stage_0.proc2Rmem_command testbench.pipeline_0.mem_stage_0.Dmem2proc_tag testbench.pipeline_0.mem_stage_0.mem_rd_miss_data_out testbench.pipeline_0.mem_stage_0.rd_addr {testbench.pipeline_0.mem_stage_0.$unit} testbench.pipeline_0.mem_stage_0.evicted testbench.pipeline_0.mem_stage_0.Dmem2proc_data testbench.pipeline_0.mem_stage_0.proc2Dmem_command testbench.pipeline_0.mem_stage_0.Dmem2proc_response testbench.pipeline_0.mem_stage_0.rd_mem }

set _session_group_17 memory
gui_sg_create "$_session_group_17"
set memory "$_session_group_17"

gui_sg_addsignal -group "$_session_group_17" { testbench.pipeline_0.memory.Imem2proc_data_next testbench.pipeline_0.memory.mem2proc_response testbench.pipeline_0.memory.Rmem2proc_response testbench.pipeline_0.memory.clock testbench.pipeline_0.memory.Dmem2proc_tag_next testbench.pipeline_0.memory.proc2Dmem_data testbench.pipeline_0.memory.reset testbench.pipeline_0.memory.Dmem2proc_data_next testbench.pipeline_0.memory.proc2Dmem_addr testbench.pipeline_0.memory.Dmem2proc_response_next testbench.pipeline_0.memory.proc2Rmem_data testbench.pipeline_0.memory.Imem2proc_response testbench.pipeline_0.memory.proc2Imem_command testbench.pipeline_0.memory.Imem2proc_response_next testbench.pipeline_0.memory.proc2Rmem_addr testbench.pipeline_0.memory.Rmem2proc_response_next testbench.pipeline_0.memory.next_state testbench.pipeline_0.memory.state testbench.pipeline_0.memory.Imem2proc_tag_next testbench.pipeline_0.memory.Imem2proc_data testbench.pipeline_0.memory.proc2Imem_data testbench.pipeline_0.memory.Imem2proc_tag testbench.pipeline_0.memory.mem2proc_tag testbench.pipeline_0.memory.Dmem2proc_tag testbench.pipeline_0.memory.proc2Rmem_command testbench.pipeline_0.memory.proc2Imem_addr testbench.pipeline_0.memory.mem2proc_data {testbench.pipeline_0.memory.$unit} testbench.pipeline_0.memory.Dmem2proc_data testbench.pipeline_0.memory.proc2mem_data testbench.pipeline_0.memory.proc2mem_command testbench.pipeline_0.memory.Dmem2proc_response testbench.pipeline_0.memory.proc2Dmem_command testbench.pipeline_0.memory.proc2mem_addr }

set _session_group_18 Phys_reg_file
gui_sg_create "$_session_group_18"
set Phys_reg_file "$_session_group_18"

gui_sg_addsignal -group "$_session_group_18" { testbench.pipeline_0.regf_0.phys_registers testbench.pipeline_0.regf_0.rd_idx testbench.pipeline_0.regf_0.wr_idx testbench.pipeline_0.regf_0.wr_data testbench.pipeline_0.regf_0.wr_en testbench.pipeline_0.regf_0.phys_registers_out testbench.pipeline_0.regf_0.rd_out {testbench.pipeline_0.regf_0.$unit} testbench.pipeline_0.regf_0.wr_clk }

set _session_group_19 SQ
gui_sg_create "$_session_group_19"
set SQ "$_session_group_19"

gui_sg_addsignal -group "$_session_group_19" { testbench.pipeline_0.store_queue.store_data_stall testbench.pipeline_0.store_queue.ex_addr_en testbench.pipeline_0.store_queue.load_req testbench.pipeline_0.store_queue.data_ready testbench.pipeline_0.store_queue.ex_index testbench.pipeline_0.store_queue.rt_en testbench.pipeline_0.store_queue.tail_out testbench.pipeline_0.store_queue.stall_req testbench.pipeline_0.store_queue.dispatch_addr_ready testbench.pipeline_0.store_queue.clock testbench.pipeline_0.store_queue.head testbench.pipeline_0.store_queue.reset testbench.pipeline_0.store_queue.data_ready_next testbench.pipeline_0.store_queue.addr_ready_next testbench.pipeline_0.store_queue.data_out testbench.pipeline_0.store_queue.dispatch_data_ready testbench.pipeline_0.store_queue.data testbench.pipeline_0.store_queue.ld_pos testbench.pipeline_0.store_queue.addr testbench.pipeline_0.store_queue.store_head_data testbench.pipeline_0.store_queue.data_ready_out testbench.pipeline_0.store_queue.ex_en testbench.pipeline_0.store_queue.store_head_addr testbench.pipeline_0.store_queue.rd_valid testbench.pipeline_0.store_queue.addr_next testbench.pipeline_0.store_queue.dispatch_data testbench.pipeline_0.store_queue.addr_rd_ready testbench.pipeline_0.store_queue.data_rd testbench.pipeline_0.store_queue.rd_en testbench.pipeline_0.store_queue.head_next testbench.pipeline_0.store_queue.ex_data_en testbench.pipeline_0.store_queue.tail testbench.pipeline_0.store_queue.dispatch_addr testbench.pipeline_0.store_queue.data_rd_idx testbench.pipeline_0.store_queue.full testbench.pipeline_0.store_queue.addr_ready_out testbench.pipeline_0.store_queue.tail_next testbench.pipeline_0.store_queue.ex_data testbench.pipeline_0.store_queue.head_out {testbench.pipeline_0.store_queue.$unit} testbench.pipeline_0.store_queue.data_next testbench.pipeline_0.store_queue.load_gnt testbench.pipeline_0.store_queue.ex_addr testbench.pipeline_0.store_queue.addr_ready testbench.pipeline_0.store_queue.addr_out testbench.pipeline_0.store_queue.addr_rd testbench.pipeline_0.store_queue.dispatch_en }

set _session_group_20 dcache_mem
gui_sg_create "$_session_group_20"
set dcache_mem "$_session_group_20"

gui_sg_addsignal -group "$_session_group_20" { testbench.pipeline_0.inst_memory.memory.wr_cam_table_in testbench.pipeline_0.inst_memory.memory.acc testbench.pipeline_0.inst_memory.memory.rd_idx testbench.pipeline_0.inst_memory.memory.bst_next testbench.pipeline_0.inst_memory.memory.sets_out testbench.pipeline_0.inst_memory.memory.rd_tag_hits testbench.pipeline_0.inst_memory.memory.clock testbench.pipeline_0.inst_memory.memory.wr_cam_hits_out testbench.pipeline_0.inst_memory.memory.reset testbench.pipeline_0.inst_memory.memory.next_bst_idx testbench.pipeline_0.inst_memory.memory.wr_miss_tag testbench.pipeline_0.inst_memory.memory.rd_tag_idx testbench.pipeline_0.inst_memory.memory.rd_miss_idx testbench.pipeline_0.inst_memory.memory.bst_out testbench.pipeline_0.inst_memory.memory.wr_idx testbench.pipeline_0.inst_memory.memory.wr_tag_idx testbench.pipeline_0.inst_memory.memory.wr_data testbench.pipeline_0.inst_memory.memory.rd_miss_valid testbench.pipeline_0.inst_memory.memory.wr_new_tag_idx testbench.pipeline_0.inst_memory.memory.rd_tag testbench.pipeline_0.inst_memory.memory.wr_miss_valid testbench.pipeline_0.inst_memory.memory.WR_PORTS testbench.pipeline_0.inst_memory.memory.rd_valid testbench.pipeline_0.inst_memory.memory.wr_en testbench.pipeline_0.inst_memory.memory.rd_en testbench.pipeline_0.inst_memory.memory.victim_valid testbench.pipeline_0.inst_memory.memory.sets testbench.pipeline_0.inst_memory.memory.rd_miss_tag testbench.pipeline_0.inst_memory.memory.wr_tag testbench.pipeline_0.inst_memory.memory.temp_idx testbench.pipeline_0.inst_memory.memory.wr_tag_hits testbench.pipeline_0.inst_memory.memory.NUM_WAYS testbench.pipeline_0.inst_memory.memory.vic_idx testbench.pipeline_0.inst_memory.memory.rd_cam_table_in testbench.pipeline_0.inst_memory.memory.rd_data testbench.pipeline_0.inst_memory.memory.RD_PORTS testbench.pipeline_0.inst_memory.memory.sets_next testbench.pipeline_0.inst_memory.memory.bst testbench.pipeline_0.inst_memory.memory.victim {testbench.pipeline_0.inst_memory.memory.$unit} testbench.pipeline_0.inst_memory.memory.wr_miss_idx testbench.pipeline_0.inst_memory.memory.rd_cam_hits_out testbench.pipeline_0.inst_memory.memory.wr_forward_to_rd testbench.pipeline_0.inst_memory.memory.wr_dirty }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.WR_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.WR_PORTS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.NUM_WAYS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.RD_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.RD_PORTS}

set _session_group_21 dcache
gui_sg_create "$_session_group_21"
set dcache "$_session_group_21"

gui_sg_addsignal -group "$_session_group_21" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_addr_table_in testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue_tail_next testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_idx testbench.pipeline_0.mem_stage_0.dcache0.wr_en testbench.pipeline_0.mem_stage_0.dcache0.fifo_busy_next testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_idx testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_idx testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_cam_tags testbench.pipeline_0.mem_stage_0.dcache0.fetch_stride_next testbench.pipeline_0.mem_stage_0.dcache0.fetch_stride testbench.pipeline_0.mem_stage_0.dcache0.fifo_cam_hits testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_data_out testbench.pipeline_0.mem_stage_0.dcache0.fifo_next testbench.pipeline_0.mem_stage_0.dcache0.unanswered_miss testbench.pipeline_0.mem_stage_0.dcache0.victim_valid testbench.pipeline_0.mem_stage_0.dcache0.fifo testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue testbench.pipeline_0.mem_stage_0.dcache0.EMPTY_DCACHE testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_en testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_valid testbench.pipeline_0.mem_stage_0.dcache0.proc2Dcache_wr_data testbench.pipeline_0.mem_stage_0.dcache0.NUM_WAYS testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_tag testbench.pipeline_0.mem_stage_0.dcache0.clock testbench.pipeline_0.mem_stage_0.dcache0.reset testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_tag testbench.pipeline_0.mem_stage_0.dcache0.EMPTY_VIC_CACHE testbench.pipeline_0.mem_stage_0.dcache0.update_mem_tag testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_tag testbench.pipeline_0.mem_stage_0.dcache0.fifo_idx_to_encode testbench.pipeline_0.mem_stage_0.dcache0.proc2Dcache_rd_addr testbench.pipeline_0.mem_stage_0.dcache0.victim_idx testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_en testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_miss_data_out testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_miss_idx testbench.pipeline_0.mem_stage_0.dcache0.evicted_valid testbench.pipeline_0.mem_stage_0.dcache0.send_req_ptr testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_idx_valid testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_data testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue_tail testbench.pipeline_0.mem_stage_0.dcache0.Dmem2proc_response testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_num testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_idx testbench.pipeline_0.mem_stage_0.dcache0.mem_waiting_ptr testbench.pipeline_0.mem_stage_0.dcache0.victim testbench.pipeline_0.mem_stage_0.dcache0.fifo_lru_next testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_gnt testbench.pipeline_0.mem_stage_0.dcache0.mem_waiting_ptr_next testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_valid testbench.pipeline_0.mem_stage_0.dcache0.fifo_tail_next testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_hits testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_miss_addr_out testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_miss_idx testbench.pipeline_0.mem_stage_0.dcache0.next_lru_idx testbench.pipeline_0.mem_stage_0.dcache0.mem_rd_data testbench.pipeline_0.mem_stage_0.dcache0.send_req_ptr_next testbench.pipeline_0.mem_stage_0.dcache0.fifo_cam_tags testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_dirty testbench.pipeline_0.mem_stage_0.dcache0.proc2Dmem_data testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_miss_tag testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_cam_table_in testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue_next testbench.pipeline_0.mem_stage_0.dcache0.Dmem2proc_tag testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_miss_valid_out testbench.pipeline_0.mem_stage_0.dcache0.EMPTY_CACHE_LINE testbench.pipeline_0.mem_stage_0.dcache0.proc2Dcache_wr_addr testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_out testbench.pipeline_0.mem_stage_0.dcache0.rd_en testbench.pipeline_0.mem_stage_0.dcache0.fifo_lru testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_miss_tag testbench.pipeline_0.mem_stage_0.dcache0.fifo_num_to_encode testbench.pipeline_0.mem_stage_0.dcache0.next_rd_addr }
gui_sg_addsignal -group "$_session_group_21" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_num_valid testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_data testbench.pipeline_0.mem_stage_0.dcache0.Dmem2proc_data testbench.pipeline_0.mem_stage_0.dcache0.WR_PORTS testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_cam_hits testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_req testbench.pipeline_0.mem_stage_0.dcache0.fifo_busy testbench.pipeline_0.mem_stage_0.dcache0.RD_PORTS testbench.pipeline_0.mem_stage_0.dcache0.acc testbench.pipeline_0.mem_stage_0.dcache0.fill_fifo_idx testbench.pipeline_0.mem_stage_0.dcache0.send_request testbench.pipeline_0.mem_stage_0.dcache0.evicted testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_valid_out testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_num_valid testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_en testbench.pipeline_0.mem_stage_0.dcache0.mem_done testbench.pipeline_0.mem_stage_0.dcache0.proc2Dmem_addr {testbench.pipeline_0.mem_stage_0.dcache0.$unit} testbench.pipeline_0.mem_stage_0.dcache0.fifo_tail testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_num testbench.pipeline_0.mem_stage_0.dcache0.proc2Dmem_command testbench.pipeline_0.mem_stage_0.dcache0.temp_lru_idx testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_miss_valid testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_miss_valid }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.NUM_WAYS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.WR_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.WR_PORTS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.RD_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.RD_PORTS}

set _session_group_22 retire_buffer
gui_sg_create "$_session_group_22"
set retire_buffer "$_session_group_22"

gui_sg_addsignal -group "$_session_group_22" { testbench.pipeline_0.mem_stage_0.rb0.EMPTY_RETIRE_BUF testbench.pipeline_0.mem_stage_0.rb0.send_req_ptr testbench.pipeline_0.mem_stage_0.rb0.Rmem2proc_response testbench.pipeline_0.mem_stage_0.rb0.retire_queue testbench.pipeline_0.mem_stage_0.rb0.send_request testbench.pipeline_0.mem_stage_0.rb0.clock testbench.pipeline_0.mem_stage_0.rb0.reset testbench.pipeline_0.mem_stage_0.rb0.retire_queue_next testbench.pipeline_0.mem_stage_0.rb0.request_not_accepted testbench.pipeline_0.mem_stage_0.rb0.retire_queue_tail testbench.pipeline_0.mem_stage_0.rb0.proc2Rmem_data testbench.pipeline_0.mem_stage_0.rb0.WR_PORTS testbench.pipeline_0.mem_stage_0.rb0.proc2Rmem_addr testbench.pipeline_0.mem_stage_0.rb0.full testbench.pipeline_0.mem_stage_0.rb0.evicted_valid testbench.pipeline_0.mem_stage_0.rb0.NUM_WAYS testbench.pipeline_0.mem_stage_0.rb0.proc2Rmem_command testbench.pipeline_0.mem_stage_0.rb0.retire_queue_tail_next {testbench.pipeline_0.mem_stage_0.rb0.$unit} testbench.pipeline_0.mem_stage_0.rb0.evicted testbench.pipeline_0.mem_stage_0.rb0.update_queue testbench.pipeline_0.mem_stage_0.rb0.send_req_ptr_next }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.WR_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.WR_PORTS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.NUM_WAYS}

set _session_group_23 Group1
gui_sg_create "$_session_group_23"
set Group1 "$_session_group_23"

gui_sg_addsignal -group "$_session_group_23" { testbench.pipeline_0.if_NPC_out testbench.pipeline_0.if_IR_out testbench.pipeline_0.if_valid_inst_out testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_valid_inst testbench.pipeline_0.if_id_enable testbench.pipeline_0.if_inst_in testbench.pipeline_0.if_id_inst_out testbench.pipeline_0.if1_fetch_NPC_out testbench.pipeline_0.if1_IR_out testbench.pipeline_0.if1_PC_reg testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.if1_branch_inst testbench.pipeline_0.if12_fetch_NPC_out testbench.pipeline_0.if12_IR_out testbench.pipeline_0.if12_PC_reg testbench.pipeline_0.if12_valid_inst_out testbench.pipeline_0.if12_branch_inst testbench.pipeline_0.if2_branch_inst testbench.pipeline_0.if2_bp_NPC_valid testbench.pipeline_0.if2_bp_NPC testbench.pipeline_0.if_branch_inst testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.if_PC_reg testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if_bp_NPC testbench.pipeline_0.if_fetch_NPC_out testbench.pipeline_0.if_fetch_valid_inst_out testbench.pipeline_0.if_stage_dispatch_en }

set _session_group_24 {pipeline if signals}
gui_sg_create "$_session_group_24"
set {pipeline if signals} "$_session_group_24"

gui_sg_addsignal -group "$_session_group_24" { testbench.pipeline_0.if_NPC_out testbench.pipeline_0.if_IR_out testbench.pipeline_0.if_valid_inst_out testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_valid_inst testbench.pipeline_0.if_id_enable testbench.pipeline_0.if_inst_in testbench.pipeline_0.if_id_inst_out testbench.pipeline_0.if1_fetch_NPC_out testbench.pipeline_0.if1_IR_out testbench.pipeline_0.if1_PC_reg testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.if1_branch_inst testbench.pipeline_0.if12_fetch_NPC_out testbench.pipeline_0.if12_IR_out testbench.pipeline_0.if12_PC_reg testbench.pipeline_0.if12_valid_inst_out testbench.pipeline_0.if12_branch_inst testbench.pipeline_0.if2_branch_inst testbench.pipeline_0.if2_bp_NPC_valid testbench.pipeline_0.if2_bp_NPC testbench.pipeline_0.if_branch_inst testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.if_PC_reg testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if_bp_NPC testbench.pipeline_0.if_fetch_NPC_out testbench.pipeline_0.if_fetch_valid_inst_out testbench.pipeline_0.if_stage_dispatch_en }

set _session_group_25 {pipeline id signals}
gui_sg_create "$_session_group_25"
set {pipeline id signals} "$_session_group_25"

gui_sg_addsignal -group "$_session_group_25" { testbench.pipeline_0.pipeline_commit_wr_idx testbench.pipeline_0.if_valid_inst_out testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_valid_inst testbench.pipeline_0.id_di_NPC testbench.pipeline_0.id_di_IR testbench.pipeline_0.id_di_valid_inst testbench.pipeline_0.rs_table_out_inst_valid_inst testbench.pipeline_0.issue_reg_inst_valid_inst testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.if_id_enable testbench.pipeline_0.btb_valid_out testbench.pipeline_0.if_id_inst_out testbench.pipeline_0.id_rega_out testbench.pipeline_0.id_regb_out testbench.pipeline_0.id_inst_out testbench.pipeline_0.id_ra_idx testbench.pipeline_0.id_rb_idx testbench.pipeline_0.id_rdest_idx testbench.pipeline_0.id_di_inst_in testbench.pipeline_0.id_di_rega testbench.pipeline_0.id_di_regb testbench.pipeline_0.ex_reg_valid testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.co_reg_wr_idx_out testbench.pipeline_0.co_valid_inst_selected testbench.pipeline_0.co_branch_valid testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.branch_valid_disp testbench.pipeline_0.retire_reg_wr_idx testbench.pipeline_0.Icache_valid_out testbench.pipeline_0.ex_store_addr_valid testbench.pipeline_0.ex_store_data_valid testbench.pipeline_0.sq_data_valid testbench.pipeline_0.lq_miss_valid testbench.pipeline_0.lq_read_valid testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.if12_valid_inst_out testbench.pipeline_0.if2_bp_NPC_valid testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.id_branch_inst testbench.pipeline_0.id_di_branch_inst testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if_fetch_valid_inst_out testbench.pipeline_0.id_no_dest_reg testbench.pipeline_0.id_di_enable testbench.pipeline_0.mem_dest_reg_idx_out testbench.pipeline_0.mem_valid_inst_out testbench.pipeline_0.FU_BASE_IDX }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.FU_BASE_IDX}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.pipeline_0.FU_BASE_IDX}

set _session_group_26 {pipeline di signals}
gui_sg_create "$_session_group_26"
set {pipeline di signals} "$_session_group_26"

gui_sg_addsignal -group "$_session_group_26" { testbench.pipeline_0.id_di_NPC testbench.pipeline_0.id_di_IR testbench.pipeline_0.id_di_valid_inst testbench.pipeline_0.dispatch_en testbench.pipeline_0.id_di_inst_in testbench.pipeline_0.id_di_rega testbench.pipeline_0.id_di_regb testbench.pipeline_0.dispatch_no_hazard testbench.pipeline_0.co_branch_prediction testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.branch_valid_disp testbench.pipeline_0.dispatch_is_store testbench.pipeline_0.dispatch_store_addr testbench.pipeline_0.dispatch_store_addr_ready testbench.pipeline_0.dispatch_store_data testbench.pipeline_0.dispatch_store_data_ready testbench.pipeline_0.id_di_branch_inst testbench.pipeline_0.if_stage_dispatch_en testbench.pipeline_0.dispatch_no_hazard_comb testbench.pipeline_0.id_di_enable }

set _session_group_27 {pipeline is signals}
gui_sg_create "$_session_group_27"
set {pipeline is signals} "$_session_group_27"

gui_sg_addsignal -group "$_session_group_27" { testbench.pipeline_0.issue_reg_npc testbench.pipeline_0.issue_reg_inst_opcode testbench.pipeline_0.issue_reg_inst_valid_inst testbench.pipeline_0.issue_next testbench.pipeline_0.free_list_out testbench.pipeline_0.is_pr_enable testbench.pipeline_0.dispatch_en testbench.pipeline_0.is_ex_enable testbench.pipeline_0.dispatch_no_hazard testbench.pipeline_0.issue_stall testbench.pipeline_0.issue_reg testbench.pipeline_0.is_ex_T1_value testbench.pipeline_0.is_ex_T2_value testbench.pipeline_0.issue_reg_tags testbench.pipeline_0.branch_valid_disp testbench.pipeline_0.free_list_in testbench.pipeline_0.free_list_check testbench.pipeline_0.dispatch_is_store testbench.pipeline_0.dispatch_store_addr testbench.pipeline_0.dispatch_store_addr_ready testbench.pipeline_0.dispatch_store_data testbench.pipeline_0.dispatch_store_data_ready testbench.pipeline_0.execute_is_store testbench.pipeline_0.retire_is_store testbench.pipeline_0.retire_is_store_next testbench.pipeline_0.lq_miss_data testbench.pipeline_0.lq_miss_addr testbench.pipeline_0.lq_miss_valid testbench.pipeline_0.if_stage_dispatch_en testbench.pipeline_0.dispatch_no_hazard_comb }

set _session_group_28 {pipeline ex signals}
gui_sg_create "$_session_group_28"
set {pipeline ex signals} "$_session_group_28"

gui_sg_addsignal -group "$_session_group_28" { testbench.pipeline_0.issue_next testbench.pipeline_0.ex_co_NPC testbench.pipeline_0.ex_co_IR testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.is_ex_enable testbench.pipeline_0.ex_co_enable testbench.pipeline_0.rs_free_rows_next_out testbench.pipeline_0.is_ex_T1_value testbench.pipeline_0.is_ex_T2_value testbench.pipeline_0.ex_alu_result_out testbench.pipeline_0.ex_take_branch_out testbench.pipeline_0.ex_reg_tags testbench.pipeline_0.ex_reg_valid testbench.pipeline_0.ex_mult_reg testbench.pipeline_0.ex_co_halt testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_done testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.ex_co_rega testbench.pipeline_0.ex_co_rega_st testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.rob_free_rows_next_out testbench.pipeline_0.execute_is_store testbench.pipeline_0.ex_store_addr testbench.pipeline_0.ex_store_addr_valid testbench.pipeline_0.ex_store_data testbench.pipeline_0.ex_store_data_valid testbench.pipeline_0.retire_is_store_next testbench.pipeline_0.ex_co_branch_index testbench.pipeline_0.co_branch_index testbench.pipeline_0.ex_co_branch_target }

set _session_group_29 {pipeline mem signals}
gui_sg_create "$_session_group_29"
set {pipeline mem signals} "$_session_group_29"

gui_sg_addsignal -group "$_session_group_29" { testbench.pipeline_0.mem2proc_response testbench.pipeline_0.mem2proc_data testbench.pipeline_0.mem2proc_tag testbench.pipeline_0.proc2mem_command testbench.pipeline_0.proc2mem_addr testbench.pipeline_0.proc2mem_data testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.mem_co_NPC testbench.pipeline_0.mem_co_IR testbench.pipeline_0.mem_co_enable testbench.pipeline_0.mem_result_out testbench.pipeline_0.mem_stall_out testbench.pipeline_0.mem_rd_stall testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.mem_co_halt_comb testbench.pipeline_0.mem_co_illegal_comb testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.mem_co_alu_result_comb testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.mem_co_NPC_comb testbench.pipeline_0.mem_co_IR_comb testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.proc2Dmem_addr testbench.pipeline_0.proc2Imem_addr testbench.pipeline_0.proc2Rmem_addr testbench.pipeline_0.proc2Rmem_data testbench.pipeline_0.proc2Dmem_command testbench.pipeline_0.proc2Imem_command testbench.pipeline_0.proc2Rmem_command testbench.pipeline_0.Dmem2proc_response testbench.pipeline_0.Imem2proc_response testbench.pipeline_0.Rmem2proc_response testbench.pipeline_0.Dmem2proc_data testbench.pipeline_0.Imem2proc_data testbench.pipeline_0.Dmem2proc_tag testbench.pipeline_0.Imem2proc_tag testbench.pipeline_0.mem_co_stall testbench.pipeline_0.mem_co_comb testbench.pipeline_0.proc2Dmem_data testbench.pipeline_0.mem_dest_reg_idx_out testbench.pipeline_0.mem_valid_inst_out }

set _session_group_30 {pipeline co signals}
gui_sg_create "$_session_group_30"
set {pipeline co signals} "$_session_group_30"

gui_sg_addsignal -group "$_session_group_30" { testbench.pipeline_0.proc2mem_command testbench.pipeline_0.pipeline_completed_insts testbench.pipeline_0.pipeline_commit_wr_idx testbench.pipeline_0.pipeline_commit_wr_data testbench.pipeline_0.pipeline_commit_wr_en testbench.pipeline_0.pipeline_commit_NPC testbench.pipeline_0.pipeline_commit_phys_reg testbench.pipeline_0.pipeline_commit_phys_from_arch testbench.pipeline_0.pipeline_branch_pred_correct testbench.pipeline_0.rs_table_out_inst_opcode testbench.pipeline_0.issue_reg_inst_opcode testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.mem_co_NPC testbench.pipeline_0.mem_co_IR testbench.pipeline_0.ex_co_NPC testbench.pipeline_0.ex_co_IR testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.co_ret_NPC testbench.pipeline_0.co_ret_IR testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.mem_co_enable testbench.pipeline_0.co_ret_enable testbench.pipeline_0.ex_co_enable testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.mem_co_halt_comb testbench.pipeline_0.mem_co_illegal_comb testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.mem_co_alu_result_comb testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.mem_co_NPC_comb testbench.pipeline_0.mem_co_IR_comb testbench.pipeline_0.ex_co_halt testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_done testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.ex_co_rega testbench.pipeline_0.ex_co_rega_st testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.co_halt_selected testbench.pipeline_0.co_illegal_selected testbench.pipeline_0.co_reg_wr_idx_out testbench.pipeline_0.co_reg_wr_data_out testbench.pipeline_0.co_reg_wr_en_out testbench.pipeline_0.co_take_branch_selected testbench.pipeline_0.co_NPC_selected testbench.pipeline_0.co_valid_inst_selected testbench.pipeline_0.co_selected testbench.pipeline_0.co_branch_valid testbench.pipeline_0.co_branch_prediction testbench.pipeline_0.co_IR_selected testbench.pipeline_0.co_alu_result_selected testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.co_ret_halt testbench.pipeline_0.co_ret_illegal testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.co_ret_result testbench.pipeline_0.co_ret_take_branch testbench.pipeline_0.rob_retire_opcode testbench.pipeline_0.proc2Dmem_command testbench.pipeline_0.proc2Imem_command testbench.pipeline_0.proc2Rmem_command testbench.pipeline_0.ret_pred_correct testbench.pipeline_0.ex_co_branch_index testbench.pipeline_0.co_branch_index testbench.pipeline_0.ex_co_branch_target testbench.pipeline_0.co_branch_target testbench.pipeline_0.mem_co_stall testbench.pipeline_0.mem_co_comb testbench.pipeline_0.dispatch_no_hazard_comb }

set _session_group_31 {pipeline ret signals}
gui_sg_create "$_session_group_31"
set {pipeline ret signals} "$_session_group_31"

gui_sg_addsignal -group "$_session_group_31" { testbench.pipeline_0.retire_inst_busy testbench.pipeline_0.retire_reg_NPC testbench.pipeline_0.co_ret_NPC testbench.pipeline_0.co_ret_IR testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.co_ret_enable testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.co_ret_halt testbench.pipeline_0.co_ret_illegal testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.co_ret_result testbench.pipeline_0.co_ret_take_branch testbench.pipeline_0.rob_retire_out testbench.pipeline_0.retire_reg_wr_data testbench.pipeline_0.retire_reg_wr_idx testbench.pipeline_0.retire_reg_wr_en testbench.pipeline_0.retire_reg_phys testbench.pipeline_0.rob_retire_out_halt testbench.pipeline_0.rob_retire_out_take_branch testbench.pipeline_0.rob_retire_out_T_new testbench.pipeline_0.rob_retire_out_T_old testbench.pipeline_0.rob_retire_opcode testbench.pipeline_0.retire_is_store testbench.pipeline_0.retire_is_store_next testbench.pipeline_0.ret_branch_inst testbench.pipeline_0.ret_pred_correct }

set _session_group_32 ex_stage_0
gui_sg_create "$_session_group_32"
set ex_stage_0 "$_session_group_32"

gui_sg_addsignal -group "$_session_group_32" { testbench.pipeline_0.ex_stage_0.ex_br_disp_out testbench.pipeline_0.ex_stage_0.clock testbench.pipeline_0.ex_stage_0.brcond_result testbench.pipeline_0.ex_stage_0.opb_mux_out testbench.pipeline_0.ex_stage_0.reset testbench.pipeline_0.ex_stage_0.br_disp testbench.pipeline_0.ex_stage_0.issue_reg testbench.pipeline_0.ex_stage_0.mem_disp testbench.pipeline_0.ex_stage_0.T2_value testbench.pipeline_0.ex_stage_0.ex_take_branch_out testbench.pipeline_0.ex_stage_0.alu_imm testbench.pipeline_0.ex_stage_0.done testbench.pipeline_0.ex_stage_0.T1_value {testbench.pipeline_0.ex_stage_0.$unit} testbench.pipeline_0.ex_stage_0.opa_mux_out testbench.pipeline_0.ex_stage_0.ex_alu_result_out }

set _session_group_33 Group2
gui_sg_create "$_session_group_33"
set Group2 "$_session_group_33"

gui_sg_addsignal -group "$_session_group_33" { testbench.pipeline_0.ex_co_branch_target testbench.pipeline_0.co_ret_halt testbench.pipeline_0.co_reg_wr_idx_out testbench.pipeline_0.ex_co_IR testbench.pipeline_0.proc2Imem_command testbench.pipeline_0.mem_co_alu_result_comb testbench.pipeline_0.co_reg_wr_data_out testbench.pipeline_0.issue_reg_inst_opcode testbench.pipeline_0.co_valid_inst_selected testbench.pipeline_0.dispatch_no_hazard_comb testbench.pipeline_0.rs_table_out_inst_opcode testbench.pipeline_0.proc2Rmem_command testbench.pipeline_0.pipeline_commit_phys_from_arch testbench.pipeline_0.co_selected testbench.pipeline_0.pipeline_commit_NPC testbench.pipeline_0.co_halt_selected testbench.pipeline_0.mem_co_IR_comb testbench.pipeline_0.pipeline_branch_pred_correct testbench.pipeline_0.co_IR_selected testbench.pipeline_0.ex_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.co_reg_wr_en_out testbench.pipeline_0.mem_co_comb testbench.pipeline_0.co_branch_target testbench.pipeline_0.pipeline_commit_phys_reg testbench.pipeline_0.rob_retire_opcode testbench.pipeline_0.mem_co_enable testbench.pipeline_0.mem_co_stall testbench.pipeline_0.co_branch_index testbench.pipeline_0.pipeline_commit_wr_data testbench.pipeline_0.co_ret_IR testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.mem_co_IR testbench.pipeline_0.co_ret_result testbench.pipeline_0.co_ret_illegal testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.pipeline_commit_wr_en testbench.pipeline_0.ex_co_NPC testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.co_ret_enable testbench.pipeline_0.ex_co_rega_st testbench.pipeline_0.ex_co_branch_index testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_rega testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.co_ret_NPC testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_NPC_comb testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.ex_co_done testbench.pipeline_0.proc2mem_command testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.mem_co_NPC testbench.pipeline_0.ret_pred_correct testbench.pipeline_0.co_branch_prediction testbench.pipeline_0.co_ret_take_branch testbench.pipeline_0.co_NPC_selected testbench.pipeline_0.proc2Dmem_command testbench.pipeline_0.co_take_branch_selected testbench.pipeline_0.pipeline_completed_insts testbench.pipeline_0.co_illegal_selected testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.pipeline_commit_wr_idx testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.mem_co_illegal_comb testbench.pipeline_0.mem_co_halt_comb testbench.pipeline_0.co_alu_result_selected testbench.pipeline_0.ex_co_enable testbench.pipeline_0.co_branch_valid testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.ex_co_br_disp testbench.pipeline_0.ex_co_br_wr_data testbench.pipeline_0.ex_co_unconditional_branch }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 77829420



# Save global setting...

# Wave/List view global setting
gui_list_create_group_when_add -wave -enable
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
gui_view_scroll -id ${Hier.1} -vertical -set 10
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*co*}
gui_list_show_data -id ${Data.1} {testbench.pipeline_0}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {testbench.pipeline_0.ex_co_branch_target testbench.pipeline_0.co_ret_halt testbench.pipeline_0.co_reg_wr_idx_out testbench.pipeline_0.ex_co_IR testbench.pipeline_0.proc2Imem_command testbench.pipeline_0.mem_co_alu_result_comb testbench.pipeline_0.co_reg_wr_data_out testbench.pipeline_0.issue_reg_inst_opcode testbench.pipeline_0.co_valid_inst_selected testbench.pipeline_0.dispatch_no_hazard_comb testbench.pipeline_0.rs_table_out_inst_opcode testbench.pipeline_0.proc2Rmem_command testbench.pipeline_0.pipeline_commit_phys_from_arch testbench.pipeline_0.co_selected testbench.pipeline_0.pipeline_commit_NPC testbench.pipeline_0.co_halt_selected testbench.pipeline_0.mem_co_IR_comb testbench.pipeline_0.pipeline_branch_pred_correct testbench.pipeline_0.co_IR_selected testbench.pipeline_0.ex_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.co_reg_wr_en_out testbench.pipeline_0.mem_co_comb testbench.pipeline_0.co_branch_target testbench.pipeline_0.pipeline_commit_phys_reg testbench.pipeline_0.rob_retire_opcode testbench.pipeline_0.mem_co_enable testbench.pipeline_0.mem_co_stall testbench.pipeline_0.co_branch_index testbench.pipeline_0.pipeline_commit_wr_data testbench.pipeline_0.co_ret_IR testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.mem_co_IR testbench.pipeline_0.co_ret_result testbench.pipeline_0.co_ret_illegal testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.pipeline_commit_wr_en testbench.pipeline_0.ex_co_NPC testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.co_ret_enable testbench.pipeline_0.ex_co_rega_st testbench.pipeline_0.ex_co_branch_index testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_rega testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.co_ret_NPC testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_NPC_comb testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.ex_co_done testbench.pipeline_0.proc2mem_command testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.mem_co_NPC testbench.pipeline_0.ret_pred_correct testbench.pipeline_0.co_branch_prediction testbench.pipeline_0.co_ret_take_branch testbench.pipeline_0.co_NPC_selected testbench.pipeline_0.proc2Dmem_command testbench.pipeline_0.co_take_branch_selected testbench.pipeline_0.pipeline_completed_insts testbench.pipeline_0.co_illegal_selected testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.pipeline_commit_wr_idx testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.mem_co_illegal_comb testbench.pipeline_0.mem_co_halt_comb testbench.pipeline_0.co_alu_result_selected testbench.pipeline_0.ex_co_enable testbench.pipeline_0.co_branch_valid testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.ex_co_br_disp testbench.pipeline_0.ex_co_br_wr_data testbench.pipeline_0.ex_co_unconditional_branch }}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 10
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active {testbench.unnamed$$_1} /afs/umich.edu/user/e/l/eliubakk/eecs470/projects/4/testbench/pipeline_test.v
gui_src_value_annotate -id ${Source.1} -switch true
gui_set_env TOGGLE::VALUEANNOTATE 1
gui_view_scroll -id ${Source.1} -vertical -set 6900
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
gui_wv_zoom_timerange -id ${Wave.1} 58341899 136171320
gui_list_add_group -id ${Wave.1} -after {New Group} {CDB}
gui_list_add_group -id ${Wave.1} -after {New Group} {ROB}
gui_list_add_group -id ${Wave.1} -after {New Group} {RS}
gui_list_add_group -id ${Wave.1} -after {New Group} {Arch_Map}
gui_list_add_group -id ${Wave.1} -after {New Group} {BP2}
gui_list_add_group -id ${Wave.1} -after {New Group} {ex_stage}
gui_list_add_group -id ${Wave.1} -after {New Group} {Free_List}
gui_list_add_group -id ${Wave.1} -after {New Group} {id_stage}
gui_list_add_group -id ${Wave.1} -after {New Group} {if_stage}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {IQ}
gui_list_add_group -id ${Wave.1} -after {New Group} {LQ}
gui_list_add_group -id ${Wave.1} -after {New Group} {Map_Table}
gui_list_add_group -id ${Wave.1} -after {New Group} {mem_stage}
gui_list_add_group -id ${Wave.1} -after {New Group} {memory}
gui_list_add_group -id ${Wave.1} -after {New Group} {Phys_reg_file}
gui_list_add_group -id ${Wave.1} -after {New Group} {SQ}
gui_list_add_group -id ${Wave.1} -after {New Group} {dcache_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {dcache}
gui_list_add_group -id ${Wave.1} -after {New Group} {retire_buffer}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline if signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline id signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline di signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline is signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline ex signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline mem signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline co signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline ret signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {ex_stage_0}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group2}
gui_list_collapse -id ${Wave.1} CDB
gui_list_collapse -id ${Wave.1} ROB
gui_list_collapse -id ${Wave.1} RS
gui_list_collapse -id ${Wave.1} Arch_Map
gui_list_collapse -id ${Wave.1} BP2
gui_list_collapse -id ${Wave.1} Free_List
gui_list_collapse -id ${Wave.1} id_stage
gui_list_collapse -id ${Wave.1} if_stage
gui_list_collapse -id ${Wave.1} icache
gui_list_collapse -id ${Wave.1} icache_mem
gui_list_collapse -id ${Wave.1} IQ
gui_list_collapse -id ${Wave.1} LQ
gui_list_collapse -id ${Wave.1} Map_Table
gui_list_collapse -id ${Wave.1} mem_stage
gui_list_collapse -id ${Wave.1} memory
gui_list_collapse -id ${Wave.1} Phys_reg_file
gui_list_collapse -id ${Wave.1} SQ
gui_list_collapse -id ${Wave.1} dcache_mem
gui_list_collapse -id ${Wave.1} dcache
gui_list_collapse -id ${Wave.1} retire_buffer
gui_list_collapse -id ${Wave.1} {pipeline if signals}
gui_list_collapse -id ${Wave.1} {pipeline id signals}
gui_list_collapse -id ${Wave.1} {pipeline di signals}
gui_list_collapse -id ${Wave.1} {pipeline is signals}
gui_list_collapse -id ${Wave.1} {pipeline ex signals}
gui_list_collapse -id ${Wave.1} {pipeline mem signals}
gui_list_collapse -id ${Wave.1} {pipeline co signals}
gui_list_collapse -id ${Wave.1} {pipeline ret signals}
gui_list_collapse -id ${Wave.1} ex_stage_0
gui_list_expand -id ${Wave.1} testbench.pipeline_0.ex_stage_0.br_disp
gui_list_expand -id ${Wave.1} testbench.pipeline_0.ex_co_br_wr_data
gui_list_select -id ${Wave.1} {testbench.pipeline_0.ex_co_br_wr_data }
gui_seek_criteria -id ${Wave.1} {Any Edge}



gui_set_env TOGGLE::DEFAULT_WAVE_WINDOW ${Wave.1}
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
gui_list_set_insertion_bar  -id ${Wave.1} -group Group2  -position in

gui_marker_move -id ${Wave.1} {C1} 77829420
gui_view_scroll -id ${Wave.1} -vertical -set 2875
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${DLPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>
