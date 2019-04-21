# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sun Apr 21 10:25:07 2019
# Designs open: 1
#   Sim: dve
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: _vcs_unit__1703597509
#   Wave.1: 968 signals
#   Group count = 87
#   Group R0 signal count = 47
#   Group ROB signal count = 47
#   Group Free_List signal count = 22
#   Group Map_Table signal count = 22
#   Group Arch_Map signal count = 18
#   Group icache_mem signal count = 44
#   Group icache signal count = 13
#   Group IQ signal count = 19
#   Group BP2 signal count = 48
#   Group if_stage signal count = 24
#   Group id_stage signal count = 22
#   Group RS signal count = 49
#   Group ex_stage signal count = 15
#   Group LQ signal count = 10
#   Group SQ signal count = 16
#   Group mem_stage signal count = 7
#   Group memory signal count = 8
#   Group Phys_reg_file signal count = 9
#   Group dcache0 signal count = 15
#   Group retire_buffer signal count = 9
#   Group Group1 signal count = 30
#   Group pipeline if signals signal count = 30
#   Group pipeline id signals signal count = 57
#   Group pipeline di signals signal count = 20
#   Group pipeline is signals signal count = 30
#   Group pipeline ex signals signal count = 35
#   Group pipeline mem signals signal count = 45
#   Group pipeline co signals signal count = 77
#   Group pipeline ret signals signal count = 27
# End_DVE_Session_Save_Info

# DVE version: N-2017.12-SP2-1_Full64
# DVE build date: Jul 14 2018 20:58:30


#<Session mode="Full" path="/home/eliubakk/eecs470/projects/4/synth/dve_sessions/Erik.inter.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{65 24} {1919 1014}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 247]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 247
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 246} {height 727} {dock_state left} {dock_on_new_line true} {child_hier_colhier 149} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 484]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 484
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 935
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 483} {height 727} {dock_state left} {dock_on_new_line true} {child_data_colvariable 212} {child_data_colvalue 153} {child_data_coltype 144} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 157]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1860
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 157
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1854} {height 156} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state maximized -rect {{65 24} {1919 1014}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 538} {child_wave_right 1311} {child_wave_colname 267} {child_wave_colvalue 267} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_load_child_values {testbench.pipeline_0.regf_0}
gui_load_child_values {testbench.pipeline_0.load_queue}
gui_load_child_values {testbench.pipeline_0.bp0}
gui_load_child_values {testbench.pipeline_0.ex_stage_0}
gui_load_child_values {testbench.pipeline_0.if_stage_0}
gui_load_child_values {testbench.pipeline_0.mem_stage_0.dcache0}
gui_load_child_values {testbench.pipeline_0}
gui_load_child_values {testbench.pipeline_0.f0}
gui_load_child_values {testbench.pipeline_0.R0}
gui_load_child_values {testbench.pipeline_0.iq0}
gui_load_child_values {testbench.pipeline_0.a0}
gui_load_child_values {testbench.pipeline_0.m1}
gui_load_child_values {testbench.pipeline_0.inst_memory.memory}


set _session_group_381 R0
gui_sg_create "$_session_group_381"
set R0 "$_session_group_381"

gui_sg_addsignal -group "$_session_group_381" { testbench.pipeline_0.R0.cam_tags_in testbench.pipeline_0.R0.retire_idx_valid testbench.pipeline_0.R0.ROB_table testbench.pipeline_0.R0.tail_out testbench.pipeline_0.R0.clock testbench.pipeline_0.R0.cam_hits testbench.pipeline_0.R0.head testbench.pipeline_0.R0.reset testbench.pipeline_0.R0.retired testbench.pipeline_0.R0.enable testbench.pipeline_0.R0.ROB_table_next testbench.pipeline_0.R0.wr_idx testbench.pipeline_0.R0.ready_to_retire_out testbench.pipeline_0.R0.CDB_br_valid testbench.pipeline_0.R0.T_new_in testbench.pipeline_0.R0.head_next_out testbench.pipeline_0.R0.npc testbench.pipeline_0.R0.CDB_tag_in testbench.pipeline_0.R0.retire_idx_out testbench.pipeline_0.R0.ROB_table_out testbench.pipeline_0.R0.co_alu_result testbench.pipeline_0.R0.branch_not_taken testbench.pipeline_0.R0.head_next_busy testbench.pipeline_0.R0.tail_next_out testbench.pipeline_0.R0.free_rows_next testbench.pipeline_0.R0.retire_out testbench.pipeline_0.R0.take_branch testbench.pipeline_0.R0.head_next testbench.pipeline_0.R0.tail testbench.pipeline_0.R0.ready_to_retire testbench.pipeline_0.R0.T_old_in testbench.pipeline_0.R0.full testbench.pipeline_0.R0.dispatch_idx testbench.pipeline_0.R0.halt_in testbench.pipeline_0.R0.cam_table_in testbench.pipeline_0.R0.tail_next testbench.pipeline_0.R0.retire_idx_valid_out testbench.pipeline_0.R0.head_out {testbench.pipeline_0.R0.$unit} testbench.pipeline_0.R0.dispatched testbench.pipeline_0.R0.CDB_br_idx testbench.pipeline_0.R0.dispatch_idx_out testbench.pipeline_0.R0.retire_idx testbench.pipeline_0.R0.id_branch_inst testbench.pipeline_0.R0.opcode testbench.pipeline_0.R0.dispatch_en testbench.pipeline_0.R0.CAM_en }

set _session_group_382 ROB
gui_sg_create "$_session_group_382"
set ROB "$_session_group_382"

gui_sg_addsignal -group "$_session_group_382" { testbench.pipeline_0.R0.cam_tags_in testbench.pipeline_0.R0.retire_idx_valid testbench.pipeline_0.R0.ROB_table testbench.pipeline_0.R0.tail_out testbench.pipeline_0.R0.clock testbench.pipeline_0.R0.cam_hits testbench.pipeline_0.R0.head testbench.pipeline_0.R0.reset testbench.pipeline_0.R0.retired testbench.pipeline_0.R0.enable testbench.pipeline_0.R0.ROB_table_next testbench.pipeline_0.R0.wr_idx testbench.pipeline_0.R0.ready_to_retire_out testbench.pipeline_0.R0.CDB_br_valid testbench.pipeline_0.R0.T_new_in testbench.pipeline_0.R0.head_next_out testbench.pipeline_0.R0.npc testbench.pipeline_0.R0.CDB_tag_in testbench.pipeline_0.R0.retire_idx_out testbench.pipeline_0.R0.ROB_table_out testbench.pipeline_0.R0.co_alu_result testbench.pipeline_0.R0.branch_not_taken testbench.pipeline_0.R0.head_next_busy testbench.pipeline_0.R0.tail_next_out testbench.pipeline_0.R0.free_rows_next testbench.pipeline_0.R0.retire_out testbench.pipeline_0.R0.take_branch testbench.pipeline_0.R0.head_next testbench.pipeline_0.R0.tail testbench.pipeline_0.R0.ready_to_retire testbench.pipeline_0.R0.T_old_in testbench.pipeline_0.R0.full testbench.pipeline_0.R0.dispatch_idx testbench.pipeline_0.R0.halt_in testbench.pipeline_0.R0.cam_table_in testbench.pipeline_0.R0.tail_next testbench.pipeline_0.R0.retire_idx_valid_out testbench.pipeline_0.R0.head_out {testbench.pipeline_0.R0.$unit} testbench.pipeline_0.R0.dispatched testbench.pipeline_0.R0.CDB_br_idx testbench.pipeline_0.R0.dispatch_idx_out testbench.pipeline_0.R0.retire_idx testbench.pipeline_0.R0.id_branch_inst testbench.pipeline_0.R0.opcode testbench.pipeline_0.R0.dispatch_en testbench.pipeline_0.R0.CAM_en }

set _session_group_383 Free_List
gui_sg_create "$_session_group_383"
set Free_List "$_session_group_383"

gui_sg_addsignal -group "$_session_group_383" { testbench.pipeline_0.f0.free_list testbench.pipeline_0.f0.free_reg testbench.pipeline_0.f0.tail_out testbench.pipeline_0.f0.clock testbench.pipeline_0.f0.reset testbench.pipeline_0.f0.id_no_dest_reg testbench.pipeline_0.f0.enable testbench.pipeline_0.f0.next_free_list testbench.pipeline_0.f0.next_tail_check_point testbench.pipeline_0.f0.tail_check_point testbench.pipeline_0.f0.empty testbench.pipeline_0.f0.free_list_out testbench.pipeline_0.f0.free_check_point testbench.pipeline_0.f0.tail testbench.pipeline_0.f0.branch_incorrect testbench.pipeline_0.f0.T_old testbench.pipeline_0.f0.num_free_entries testbench.pipeline_0.f0.next_free_check_point {testbench.pipeline_0.f0.$unit} testbench.pipeline_0.f0.T_new testbench.pipeline_0.f0.next_tail testbench.pipeline_0.f0.dispatch_en }

set _session_group_384 Map_Table
gui_sg_create "$_session_group_384"
set Map_Table "$_session_group_384"

gui_sg_addsignal -group "$_session_group_384" { testbench.pipeline_0.m1.cam_tags_in testbench.pipeline_0.m1.map_table_out testbench.pipeline_0.m1.T1 testbench.pipeline_0.m1.T2 testbench.pipeline_0.m1.free_reg testbench.pipeline_0.m1.clock testbench.pipeline_0.m1.cam_hits testbench.pipeline_0.m1.reset testbench.pipeline_0.m1.enable testbench.pipeline_0.m1.CDB_tag_in testbench.pipeline_0.m1.map_table testbench.pipeline_0.m1.reg_a testbench.pipeline_0.m1.map_check_point testbench.pipeline_0.m1.reg_b testbench.pipeline_0.m1.next_map_table testbench.pipeline_0.m1.CDB_en testbench.pipeline_0.m1.branch_incorrect testbench.pipeline_0.m1.T_old testbench.pipeline_0.m1.cam_table_in {testbench.pipeline_0.m1.$unit} testbench.pipeline_0.m1.cam_hits_out testbench.pipeline_0.m1.reg_dest }

set _session_group_385 Arch_Map
gui_sg_create "$_session_group_385"
set Arch_Map "$_session_group_385"

gui_sg_addsignal -group "$_session_group_385" { testbench.pipeline_0.a0.T_idx1_over_idx2 testbench.pipeline_0.a0.cam_tags_in testbench.pipeline_0.a0.clock testbench.pipeline_0.a0.cam_hits testbench.pipeline_0.a0.reset testbench.pipeline_0.a0.enable testbench.pipeline_0.a0.T_new_in testbench.pipeline_0.a0.arch_map_table testbench.pipeline_0.a0.T_new_forwarded testbench.pipeline_0.a0.T_old_forwarded testbench.pipeline_0.a0.enable_forwarded testbench.pipeline_0.a0.T_old_in testbench.pipeline_0.a0.arch_map_table_next testbench.pipeline_0.a0.cam_table_in {testbench.pipeline_0.a0.$unit} testbench.pipeline_0.a0.T_idx0_over_idx1 testbench.pipeline_0.a0.T_idx0_over_idx2 testbench.pipeline_0.a0.retire_idx }

set _session_group_386 icache_mem
gui_sg_create "$_session_group_386"
set icache_mem "$_session_group_386"

gui_sg_addsignal -group "$_session_group_386" { testbench.pipeline_0.inst_memory.memory.wr_cam_table_in testbench.pipeline_0.inst_memory.memory.acc testbench.pipeline_0.inst_memory.memory.rd_idx testbench.pipeline_0.inst_memory.memory.bst_next testbench.pipeline_0.inst_memory.memory.sets_out testbench.pipeline_0.inst_memory.memory.rd_tag_hits testbench.pipeline_0.inst_memory.memory.clock testbench.pipeline_0.inst_memory.memory.wr_cam_hits_out testbench.pipeline_0.inst_memory.memory.reset testbench.pipeline_0.inst_memory.memory.next_bst_idx testbench.pipeline_0.inst_memory.memory.wr_miss_tag testbench.pipeline_0.inst_memory.memory.rd_tag_idx testbench.pipeline_0.inst_memory.memory.rd_miss_idx testbench.pipeline_0.inst_memory.memory.bst_out testbench.pipeline_0.inst_memory.memory.wr_idx testbench.pipeline_0.inst_memory.memory.wr_tag_idx testbench.pipeline_0.inst_memory.memory.wr_data testbench.pipeline_0.inst_memory.memory.rd_miss_valid testbench.pipeline_0.inst_memory.memory.wr_new_tag_idx testbench.pipeline_0.inst_memory.memory.rd_tag testbench.pipeline_0.inst_memory.memory.wr_miss_valid testbench.pipeline_0.inst_memory.memory.WR_PORTS testbench.pipeline_0.inst_memory.memory.rd_valid testbench.pipeline_0.inst_memory.memory.wr_en testbench.pipeline_0.inst_memory.memory.rd_en testbench.pipeline_0.inst_memory.memory.victim_valid testbench.pipeline_0.inst_memory.memory.sets testbench.pipeline_0.inst_memory.memory.rd_miss_tag testbench.pipeline_0.inst_memory.memory.wr_tag testbench.pipeline_0.inst_memory.memory.temp_idx testbench.pipeline_0.inst_memory.memory.wr_tag_hits testbench.pipeline_0.inst_memory.memory.NUM_WAYS testbench.pipeline_0.inst_memory.memory.vic_idx testbench.pipeline_0.inst_memory.memory.rd_cam_table_in testbench.pipeline_0.inst_memory.memory.rd_data testbench.pipeline_0.inst_memory.memory.RD_PORTS testbench.pipeline_0.inst_memory.memory.sets_next testbench.pipeline_0.inst_memory.memory.bst testbench.pipeline_0.inst_memory.memory.victim {testbench.pipeline_0.inst_memory.memory.$unit} testbench.pipeline_0.inst_memory.memory.wr_miss_idx testbench.pipeline_0.inst_memory.memory.rd_cam_hits_out testbench.pipeline_0.inst_memory.memory.wr_forward_to_rd testbench.pipeline_0.inst_memory.memory.wr_dirty }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.WR_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.WR_PORTS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.NUM_WAYS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.memory.RD_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.memory.RD_PORTS}

set _session_group_387 icache
gui_sg_create "$_session_group_387"
set icache "$_session_group_387"

gui_sg_addsignal -group "$_session_group_387" { testbench.pipeline_0.inst_memory.clock testbench.pipeline_0.inst_memory.reset testbench.pipeline_0.inst_memory.PC_in testbench.pipeline_0.inst_memory.PC_in_Plus testbench.pipeline_0.inst_memory.last_PC_in testbench.pipeline_0.inst_memory.changed_addr testbench.pipeline_0.inst_memory.NUM_WAYS testbench.pipeline_0.inst_memory.RD_PORTS {testbench.pipeline_0.inst_memory.$unit} }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.NUM_WAYS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.inst_memory.RD_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.inst_memory.RD_PORTS}

set _session_group_388 $_session_group_387|
append _session_group_388 CAM
gui_sg_create "$_session_group_388"
set icache|CAM "$_session_group_388"

gui_sg_addsignal -group "$_session_group_388" { testbench.pipeline_0.inst_memory.cam_table_in testbench.pipeline_0.inst_memory.cam_tags_in testbench.pipeline_0.inst_memory.PC_cam_hits testbench.pipeline_0.inst_memory.PC_in_hits testbench.pipeline_0.inst_memory.PC_in_Plus_hits }

gui_sg_move "$_session_group_388" -after "$_session_group_387" -pos 6 

set _session_group_389 $_session_group_387|
append _session_group_389 Queue
gui_sg_create "$_session_group_389"
set icache|Queue "$_session_group_389"

gui_sg_addsignal -group "$_session_group_389" { testbench.pipeline_0.inst_memory.send_request testbench.pipeline_0.inst_memory.unanswered_miss testbench.pipeline_0.inst_memory.mem_done testbench.pipeline_0.inst_memory.update_mem_tag }

gui_sg_move "$_session_group_389" -after "$_session_group_387" -pos 7 

set _session_group_390 $_session_group_389|
append _session_group_390 curr
gui_sg_create "$_session_group_390"
set icache|Queue|curr "$_session_group_390"

gui_sg_addsignal -group "$_session_group_390" { testbench.pipeline_0.inst_memory.PC_queue testbench.pipeline_0.inst_memory.PC_queue_tail testbench.pipeline_0.inst_memory.send_req_ptr testbench.pipeline_0.inst_memory.mem_waiting_ptr }

gui_sg_move "$_session_group_390" -after "$_session_group_389" -pos 4 

set _session_group_391 $_session_group_389|
append _session_group_391 next
gui_sg_create "$_session_group_391"
set icache|Queue|next "$_session_group_391"

gui_sg_addsignal -group "$_session_group_391" { testbench.pipeline_0.inst_memory.PC_queue_next testbench.pipeline_0.inst_memory.PC_queue_tail_next testbench.pipeline_0.inst_memory.send_req_ptr_next testbench.pipeline_0.inst_memory.mem_waiting_ptr_next }

gui_sg_move "$_session_group_391" -after "$_session_group_389" -pos 5 

set _session_group_392 $_session_group_387|
append _session_group_392 Cache
gui_sg_create "$_session_group_392"
set icache|Cache "$_session_group_392"

gui_sg_addsignal -group "$_session_group_392" { }

gui_sg_move "$_session_group_392" -after "$_session_group_387" -pos 8 

set _session_group_393 $_session_group_392|
append _session_group_393 rd
gui_sg_create "$_session_group_393"
set icache|Cache|rd "$_session_group_393"

gui_sg_addsignal -group "$_session_group_393" { testbench.pipeline_0.inst_memory.cache_rd_en testbench.pipeline_0.inst_memory.cache_rd_idx testbench.pipeline_0.inst_memory.cache_rd_tag testbench.pipeline_0.inst_memory.cache_rd_data testbench.pipeline_0.inst_memory.cache_rd_valid testbench.pipeline_0.inst_memory.cache_rd_miss_idx testbench.pipeline_0.inst_memory.cache_rd_miss_tag testbench.pipeline_0.inst_memory.cache_rd_miss_valid }

set _session_group_394 $_session_group_392|
append _session_group_394 wr
gui_sg_create "$_session_group_394"
set icache|Cache|wr "$_session_group_394"

gui_sg_addsignal -group "$_session_group_394" { testbench.pipeline_0.inst_memory.cache_wr_en testbench.pipeline_0.inst_memory.cache_wr_idx testbench.pipeline_0.inst_memory.cache_wr_tag testbench.pipeline_0.inst_memory.cache_wr_data testbench.pipeline_0.inst_memory.cache_wr_miss_idx testbench.pipeline_0.inst_memory.cache_wr_miss_tag testbench.pipeline_0.inst_memory.cache_wr_miss_valid }

gui_sg_move "$_session_group_394" -after "$_session_group_392" -pos 1 

set _session_group_395 $_session_group_387|
append _session_group_395 {Memory signals}
gui_sg_create "$_session_group_395"
set {icache|Memory signals} "$_session_group_395"

gui_sg_addsignal -group "$_session_group_395" { }

gui_sg_move "$_session_group_395" -after "$_session_group_387" -pos 9 

set _session_group_396 $_session_group_395|
append _session_group_396 Icache
gui_sg_create "$_session_group_396"
set {icache|Memory signals|Icache} "$_session_group_396"

gui_sg_addsignal -group "$_session_group_396" { testbench.pipeline_0.inst_memory.proc2Icache_addr testbench.pipeline_0.inst_memory.Icache_data_out testbench.pipeline_0.inst_memory.Icache_valid_out }

set _session_group_397 $_session_group_395|
append _session_group_397 Imem
gui_sg_create "$_session_group_397"
set {icache|Memory signals|Imem} "$_session_group_397"

gui_sg_addsignal -group "$_session_group_397" { testbench.pipeline_0.inst_memory.proc2Imem_addr testbench.pipeline_0.inst_memory.proc2Imem_command testbench.pipeline_0.inst_memory.Imem2proc_response testbench.pipeline_0.inst_memory.Imem2proc_data testbench.pipeline_0.inst_memory.Imem2proc_tag }

gui_sg_move "$_session_group_397" -after "$_session_group_395" -pos 1 

set _session_group_398 IQ
gui_sg_create "$_session_group_398"
set IQ "$_session_group_398"

gui_sg_addsignal -group "$_session_group_398" { testbench.pipeline_0.iq0.fetch_valid testbench.pipeline_0.iq0.clock testbench.pipeline_0.iq0.inst_queue_out testbench.pipeline_0.iq0.reset testbench.pipeline_0.iq0.next_inst_queue testbench.pipeline_0.iq0.duplicate_fetch testbench.pipeline_0.iq0.inst_queue_full testbench.pipeline_0.iq0.inst_queue_full_out testbench.pipeline_0.iq0.inst_queue_entry testbench.pipeline_0.iq0.if_inst_out testbench.pipeline_0.iq0.tail testbench.pipeline_0.iq0.fetch_en testbench.pipeline_0.iq0.branch_incorrect testbench.pipeline_0.iq0.if_inst_in testbench.pipeline_0.iq0.inst_queue testbench.pipeline_0.iq0.dispatch_no_hazard testbench.pipeline_0.iq0.next_inst_queue_full {testbench.pipeline_0.iq0.$unit} testbench.pipeline_0.iq0.next_tail }

set _session_group_399 BP2
gui_sg_create "$_session_group_399"
set BP2 "$_session_group_399"

gui_sg_addsignal -group "$_session_group_399" { testbench.pipeline_0.bp0.ras_stack_out testbench.pipeline_0.bp0.next_pc_calc testbench.pipeline_0.bp0.ras_next_pc testbench.pipeline_0.bp0.rt_return_branch testbench.pipeline_0.bp0.next_pc_index_calc testbench.pipeline_0.bp0.btb_write_en testbench.pipeline_0.bp0.bp_read_en testbench.pipeline_0.bp0.btb_valid_out testbench.pipeline_0.bp0.if_cond_branch testbench.pipeline_0.bp0.clock testbench.pipeline_0.bp0.ras_write_en testbench.pipeline_0.bp0.rt_calculated_pc testbench.pipeline_0.bp0.if_pc_in testbench.pipeline_0.bp0.roll_back testbench.pipeline_0.bp0.reset testbench.pipeline_0.bp0.next_pc testbench.pipeline_0.bp0.rt_direct_branch testbench.pipeline_0.bp0.btb_next_pc_valid testbench.pipeline_0.bp0.if_prediction testbench.pipeline_0.bp0.enable testbench.pipeline_0.bp0.rt_pc testbench.pipeline_0.bp0.next_pc_prediction_calc testbench.pipeline_0.bp0.bp_write_en testbench.pipeline_0.bp0.br_idx testbench.pipeline_0.bp0.ras_head_out testbench.pipeline_0.bp0.next_pc_valid_calc testbench.pipeline_0.bp0.if_return_branch testbench.pipeline_0.bp0.rt_branch_taken testbench.pipeline_0.bp0.btb_tag_out testbench.pipeline_0.bp0.pht_out testbench.pipeline_0.bp0.rt_cond_branch testbench.pipeline_0.bp0.if_direct_branch testbench.pipeline_0.bp0.next_br_idx testbench.pipeline_0.bp0.next_pc_valid testbench.pipeline_0.bp0.ras_tail_out testbench.pipeline_0.bp0.btb_target_address_out testbench.pipeline_0.bp0.if_en_branch testbench.pipeline_0.bp0.next_pc_prediction testbench.pipeline_0.bp0.if_prediction_valid testbench.pipeline_0.bp0.btb_read_en testbench.pipeline_0.bp0.rt_branch_index testbench.pipeline_0.bp0.next_pc_index {testbench.pipeline_0.bp0.$unit} testbench.pipeline_0.bp0.btb_next_pc testbench.pipeline_0.bp0.ras_read_en testbench.pipeline_0.bp0.rt_en_branch testbench.pipeline_0.bp0.rt_prediction_correct testbench.pipeline_0.bp0.ras_next_pc_valid }

set _session_group_400 if_stage
gui_sg_create "$_session_group_400"
set if_stage "$_session_group_400"

gui_sg_addsignal -group "$_session_group_400" { testbench.pipeline_0.if_stage_0.clock testbench.pipeline_0.if_stage_0.reset testbench.pipeline_0.if_stage_0.proc2Imem_addr testbench.pipeline_0.if_stage_0.Imem2proc_data testbench.pipeline_0.if_stage_0.Imem_valid testbench.pipeline_0.if_stage_0.PC_enable testbench.pipeline_0.if_stage_0.dispatch_en testbench.pipeline_0.if_stage_0.PC_reg testbench.pipeline_0.if_stage_0.PC_plus_4 testbench.pipeline_0.if_stage_0.next_PC testbench.pipeline_0.if_stage_0.ready_for_valid testbench.pipeline_0.if_stage_0.next_ready_for_valid testbench.pipeline_0.if_stage_0.co_ret_valid_inst testbench.pipeline_0.if_stage_0.co_ret_take_branch testbench.pipeline_0.if_stage_0.co_ret_branch_valid testbench.pipeline_0.if_stage_0.co_ret_target_pc testbench.pipeline_0.if_stage_0.if_bp_NPC testbench.pipeline_0.if_stage_0.if_bp_NPC_valid testbench.pipeline_0.if_stage_0.if_PC_reg testbench.pipeline_0.if_stage_0.if_valid_inst testbench.pipeline_0.if_stage_0.if_IR_out testbench.pipeline_0.if_stage_0.if_valid_inst_out testbench.pipeline_0.if_stage_0.if_NPC_out {testbench.pipeline_0.if_stage_0.$unit} }

set _session_group_401 id_stage
gui_sg_create "$_session_group_401"
set id_stage "$_session_group_401"

gui_sg_addsignal -group "$_session_group_401" { testbench.pipeline_0.id_stage_0.clock testbench.pipeline_0.id_stage_0.reset testbench.pipeline_0.id_stage_0.if_id_IR testbench.pipeline_0.id_stage_0.if_id_valid_inst testbench.pipeline_0.id_stage_0.ra_idx testbench.pipeline_0.id_stage_0.rb_idx testbench.pipeline_0.id_stage_0.rdest_idx testbench.pipeline_0.id_stage_0.id_opa_select_out testbench.pipeline_0.id_stage_0.id_opb_select_out testbench.pipeline_0.id_stage_0.id_fu_name_out testbench.pipeline_0.id_stage_0.id_alu_func_out testbench.pipeline_0.id_stage_0.id_rd_mem_out testbench.pipeline_0.id_stage_0.id_wr_mem_out testbench.pipeline_0.id_stage_0.id_ldl_mem_out testbench.pipeline_0.id_stage_0.id_stc_mem_out testbench.pipeline_0.id_stage_0.id_uncond_branch_out testbench.pipeline_0.id_stage_0.id_cond_branch_out testbench.pipeline_0.id_stage_0.id_illegal_out testbench.pipeline_0.id_stage_0.id_valid_inst_out testbench.pipeline_0.id_stage_0.id_halt_out testbench.pipeline_0.id_stage_0.id_cpuid_out {testbench.pipeline_0.id_stage_0.$unit} }

set _session_group_402 RS
gui_sg_create "$_session_group_402"
set RS "$_session_group_402"

gui_sg_addsignal -group "$_session_group_402" { testbench.pipeline_0.RS0.dispatch_reqs testbench.pipeline_0.RS0.cam_tags_in {testbench.pipeline_0.RS0.genblk5[3].end_idx} testbench.pipeline_0.RS0.rs_full testbench.pipeline_0.RS0.CDB_in testbench.pipeline_0.RS0.issue_gnts testbench.pipeline_0.RS0.dispatch_valid testbench.pipeline_0.RS0.dispatch_gnt_bus testbench.pipeline_0.RS0.clock {testbench.pipeline_0.RS0.genblk4[2].end_idx} testbench.pipeline_0.RS0.busy_bits testbench.pipeline_0.RS0.issue_idx_valid_shifted testbench.pipeline_0.RS0.issue_reqs testbench.pipeline_0.RS0.cam_hits testbench.pipeline_0.RS0.rs_table testbench.pipeline_0.RS0.issue_idx_shifted testbench.pipeline_0.RS0.reset testbench.pipeline_0.RS0.issue_idx_valid testbench.pipeline_0.RS0.dispatch_gnt testbench.pipeline_0.RS0.rs_table_next_out testbench.pipeline_0.RS0.enable {testbench.pipeline_0.RS0.genblk5[1].end_idx} testbench.pipeline_0.RS0.inst_in testbench.pipeline_0.RS0.i {testbench.pipeline_0.RS0.genblk5[4].end_idx} testbench.pipeline_0.RS0.j testbench.pipeline_0.RS0.issue_stall {testbench.pipeline_0.RS0.genblk4[0].end_idx} testbench.pipeline_0.RS0.FU_BASE_IDX testbench.pipeline_0.RS0.di_branch_inst_idx testbench.pipeline_0.RS0.issue_out {testbench.pipeline_0.RS0.genblk4[3].end_idx} testbench.pipeline_0.RS0.branch_not_taken testbench.pipeline_0.RS0.dispatch_idx_valid testbench.pipeline_0.RS0.free_rows_next {testbench.pipeline_0.RS0.genblk5[2].end_idx} testbench.pipeline_0.RS0.FU_NAME_VAL testbench.pipeline_0.RS0.issue_gnt_bus testbench.pipeline_0.RS0.dispatch_idx testbench.pipeline_0.RS0.rs_table_next {testbench.pipeline_0.RS0.genblk4[1].end_idx} testbench.pipeline_0.RS0.cam_table_in testbench.pipeline_0.RS0.issue_idx testbench.pipeline_0.RS0.NUM_OF_FU_TYPE testbench.pipeline_0.RS0.rs_table_out {testbench.pipeline_0.RS0.$unit} {testbench.pipeline_0.RS0.genblk4[4].end_idx} {testbench.pipeline_0.RS0.genblk5[0].end_idx} testbench.pipeline_0.RS0.CAM_en }
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

set _session_group_403 ex_stage
gui_sg_create "$_session_group_403"
set ex_stage "$_session_group_403"

gui_sg_addsignal -group "$_session_group_403" { testbench.pipeline_0.ex_stage_0.clock testbench.pipeline_0.ex_stage_0.reset testbench.pipeline_0.ex_stage_0.issue_reg testbench.pipeline_0.ex_stage_0.opa_mux_out testbench.pipeline_0.ex_stage_0.opb_mux_out testbench.pipeline_0.ex_stage_0.br_disp testbench.pipeline_0.ex_stage_0.mem_disp testbench.pipeline_0.ex_stage_0.alu_imm testbench.pipeline_0.ex_stage_0.T1_value testbench.pipeline_0.ex_stage_0.T2_value testbench.pipeline_0.ex_stage_0.brcond_result testbench.pipeline_0.ex_stage_0.ex_take_branch_out testbench.pipeline_0.ex_stage_0.ex_alu_result_out testbench.pipeline_0.ex_stage_0.done {testbench.pipeline_0.ex_stage_0.$unit} }

set _session_group_404 LQ
gui_sg_create "$_session_group_404"
set LQ "$_session_group_404"

gui_sg_addsignal -group "$_session_group_404" { testbench.pipeline_0.load_queue.clock testbench.pipeline_0.load_queue.reset testbench.pipeline_0.load_queue.write_en testbench.pipeline_0.load_queue.pop_en testbench.pipeline_0.load_queue.lq_miss_valid testbench.pipeline_0.load_queue.load_out testbench.pipeline_0.load_queue.load_in {testbench.pipeline_0.load_queue.$unit} }

set _session_group_405 $_session_group_404|
append _session_group_405 {load in}
gui_sg_create "$_session_group_405"
set {LQ|load in} "$_session_group_405"

gui_sg_addsignal -group "$_session_group_405" { testbench.pipeline_0.load_queue.load_in testbench.pipeline_0.load_queue.lq_miss_data testbench.pipeline_0.load_queue.lq_miss_addr testbench.pipeline_0.load_queue.addr_hits }

gui_sg_move "$_session_group_405" -after "$_session_group_404" -pos 5 

set _session_group_406 $_session_group_404|
append _session_group_406 {load out}
gui_sg_create "$_session_group_406"
set {LQ|load out} "$_session_group_406"

gui_sg_addsignal -group "$_session_group_406" { testbench.pipeline_0.load_queue.load_out testbench.pipeline_0.load_queue.read_valid testbench.pipeline_0.load_queue.full }

gui_sg_move "$_session_group_406" -after "$_session_group_404" -pos 6 

set _session_group_407 $_session_group_404|
append _session_group_407 queue
gui_sg_create "$_session_group_407"
set LQ|queue "$_session_group_407"

gui_sg_addsignal -group "$_session_group_407" { }

set _session_group_408 $_session_group_407|
append _session_group_408 curr
gui_sg_create "$_session_group_408"
set LQ|queue|curr "$_session_group_408"

gui_sg_addsignal -group "$_session_group_408" { testbench.pipeline_0.load_queue.load_queue testbench.pipeline_0.load_queue.head testbench.pipeline_0.load_queue.tail }

set _session_group_409 $_session_group_407|
append _session_group_409 next
gui_sg_create "$_session_group_409"
set LQ|queue|next "$_session_group_409"

gui_sg_addsignal -group "$_session_group_409" { testbench.pipeline_0.load_queue.load_queue_next testbench.pipeline_0.load_queue.head_next testbench.pipeline_0.load_queue.tail_next }

gui_sg_move "$_session_group_409" -after "$_session_group_407" -pos 1 

set _session_group_410 SQ
gui_sg_create "$_session_group_410"
set SQ "$_session_group_410"

gui_sg_addsignal -group "$_session_group_410" { testbench.pipeline_0.store_queue.clock testbench.pipeline_0.store_queue.reset testbench.pipeline_0.store_queue.rd_en testbench.pipeline_0.store_queue.dispatch_en testbench.pipeline_0.store_queue.ex_en testbench.pipeline_0.store_queue.rt_en testbench.pipeline_0.store_queue.store_head_data testbench.pipeline_0.store_queue.store_head_addr testbench.pipeline_0.store_queue.store_data_stall testbench.pipeline_0.store_queue.full testbench.pipeline_0.store_queue.reset testbench.pipeline_0.store_queue.store_data_stall testbench.pipeline_0.store_queue.data_rd_idx {testbench.pipeline_0.store_queue.$unit} }

set _session_group_411 $_session_group_410|
append _session_group_411 rd
gui_sg_create "$_session_group_411"
set SQ|rd "$_session_group_411"

gui_sg_addsignal -group "$_session_group_411" { testbench.pipeline_0.store_queue.addr_rd testbench.pipeline_0.store_queue.ld_pos testbench.pipeline_0.store_queue.rd_valid testbench.pipeline_0.store_queue.data_rd }

gui_sg_move "$_session_group_411" -after "$_session_group_410" -pos 10 

set _session_group_412 $_session_group_410|
append _session_group_412 dis
gui_sg_create "$_session_group_412"
set SQ|dis "$_session_group_412"

gui_sg_addsignal -group "$_session_group_412" { testbench.pipeline_0.store_queue.dispatch_addr testbench.pipeline_0.store_queue.dispatch_addr_ready testbench.pipeline_0.store_queue.dispatch_data testbench.pipeline_0.store_queue.dispatch_data_ready }

set _session_group_413 $_session_group_410|
append _session_group_413 ex
gui_sg_create "$_session_group_413"
set SQ|ex "$_session_group_413"

gui_sg_addsignal -group "$_session_group_413" { testbench.pipeline_0.store_queue.ex_index testbench.pipeline_0.store_queue.ex_addr_en testbench.pipeline_0.store_queue.ex_addr testbench.pipeline_0.store_queue.ex_data_en testbench.pipeline_0.store_queue.ex_data }

set _session_group_414 $_session_group_410|
append _session_group_414 {internals out}
gui_sg_create "$_session_group_414"
set {SQ|internals out} "$_session_group_414"

gui_sg_addsignal -group "$_session_group_414" { testbench.pipeline_0.store_queue.addr_out testbench.pipeline_0.store_queue.addr_ready_out testbench.pipeline_0.store_queue.data_out testbench.pipeline_0.store_queue.data_ready_out testbench.pipeline_0.store_queue.head_out testbench.pipeline_0.store_queue.tail_out }

gui_sg_move "$_session_group_414" -after "$_session_group_410" -pos 12 

set _session_group_415 $_session_group_410|
append _session_group_415 encoder
gui_sg_create "$_session_group_415"
set SQ|encoder "$_session_group_415"

gui_sg_addsignal -group "$_session_group_415" { testbench.pipeline_0.store_queue.load_req testbench.pipeline_0.store_queue.load_gnt testbench.pipeline_0.store_queue.data_rd_idx testbench.pipeline_0.store_queue.stall_req }

set _session_group_416 $_session_group_410|
append _session_group_416 {interal data}
gui_sg_create "$_session_group_416"
set {SQ|interal data} "$_session_group_416"

gui_sg_addsignal -group "$_session_group_416" { }

set _session_group_417 $_session_group_416|
append _session_group_417 curr
gui_sg_create "$_session_group_417"
set {SQ|interal data|curr} "$_session_group_417"

gui_sg_addsignal -group "$_session_group_417" { testbench.pipeline_0.store_queue.addr testbench.pipeline_0.store_queue.addr_ready testbench.pipeline_0.store_queue.data testbench.pipeline_0.store_queue.data_ready testbench.pipeline_0.store_queue.head testbench.pipeline_0.store_queue.tail }

set _session_group_418 $_session_group_416|
append _session_group_418 next
gui_sg_create "$_session_group_418"
set {SQ|interal data|next} "$_session_group_418"

gui_sg_addsignal -group "$_session_group_418" { testbench.pipeline_0.store_queue.addr_next testbench.pipeline_0.store_queue.addr_ready_next testbench.pipeline_0.store_queue.data_next testbench.pipeline_0.store_queue.data_ready_next testbench.pipeline_0.store_queue.head_next testbench.pipeline_0.store_queue.tail_next }

gui_sg_move "$_session_group_418" -after "$_session_group_416" -pos 1 

set _session_group_419 mem_stage
gui_sg_create "$_session_group_419"
set mem_stage "$_session_group_419"

gui_sg_addsignal -group "$_session_group_419" { testbench.pipeline_0.mem_stage_0.clock testbench.pipeline_0.mem_stage_0.reset {testbench.pipeline_0.mem_stage_0.$unit} }

set _session_group_420 $_session_group_419|
append _session_group_420 {evicted/control signals}
gui_sg_create "$_session_group_420"
set {mem_stage|evicted/control signals} "$_session_group_420"

gui_sg_addsignal -group "$_session_group_420" { testbench.pipeline_0.mem_stage_0.mem_rd_stall testbench.pipeline_0.mem_stage_0.sq_data_valid testbench.pipeline_0.mem_stage_0.sq_data_not_found testbench.pipeline_0.mem_stage_0.ret_buf_full testbench.pipeline_0.mem_stage_0.mem_stall_out testbench.pipeline_0.mem_stage_0.evicted_valid testbench.pipeline_0.mem_stage_0.evicted }

gui_sg_move "$_session_group_420" -after "$_session_group_419" -pos 5 

set _session_group_421 $_session_group_419|
append _session_group_421 {memory signals}
gui_sg_create "$_session_group_421"
set {mem_stage|memory signals} "$_session_group_421"

gui_sg_addsignal -group "$_session_group_421" { testbench.pipeline_0.mem_stage_0.proc2Dmem_data testbench.pipeline_0.mem_stage_0.proc2Dmem_addr testbench.pipeline_0.mem_stage_0.proc2Dmem_command testbench.pipeline_0.mem_stage_0.Dmem2proc_data testbench.pipeline_0.mem_stage_0.Dmem2proc_response testbench.pipeline_0.mem_stage_0.Dmem2proc_tag testbench.pipeline_0.mem_stage_0.proc2Rmem_data testbench.pipeline_0.mem_stage_0.proc2Rmem_addr testbench.pipeline_0.mem_stage_0.proc2Rmem_command testbench.pipeline_0.mem_stage_0.Rmem2proc_response }

gui_sg_move "$_session_group_421" -after "$_session_group_419" -pos 4 

set _session_group_422 $_session_group_419|
append _session_group_422 {rd signals}
gui_sg_create "$_session_group_422"
set {mem_stage|rd signals} "$_session_group_422"

gui_sg_addsignal -group "$_session_group_422" { testbench.pipeline_0.mem_stage_0.rd_mem testbench.pipeline_0.mem_stage_0.rd_addr testbench.pipeline_0.mem_stage_0.Dcache_data_out testbench.pipeline_0.mem_stage_0.Dcache_valid_out testbench.pipeline_0.mem_stage_0.mem_rd_miss_addr_out testbench.pipeline_0.mem_stage_0.mem_rd_miss_data_out testbench.pipeline_0.mem_stage_0.mem_rd_miss_valid_out testbench.pipeline_0.mem_stage_0.mem_result_out }

gui_sg_move "$_session_group_422" -after "$_session_group_419" -pos 3 

set _session_group_423 $_session_group_419|
append _session_group_423 {wr signals}
gui_sg_create "$_session_group_423"
set {mem_stage|wr signals} "$_session_group_423"

gui_sg_addsignal -group "$_session_group_423" { testbench.pipeline_0.mem_stage_0.wr_mem testbench.pipeline_0.mem_stage_0.wr_addr testbench.pipeline_0.mem_stage_0.wr_data }

gui_sg_move "$_session_group_423" -after "$_session_group_419" -pos 2 

set _session_group_424 memory
gui_sg_create "$_session_group_424"
set memory "$_session_group_424"

gui_sg_addsignal -group "$_session_group_424" { testbench.pipeline_0.memory.clock testbench.pipeline_0.memory.reset {testbench.pipeline_0.memory.$unit} }

set _session_group_425 $_session_group_424|
append _session_group_425 {Main mem}
gui_sg_create "$_session_group_425"
set {memory|Main mem} "$_session_group_425"

gui_sg_addsignal -group "$_session_group_425" { testbench.pipeline_0.memory.proc2mem_command testbench.pipeline_0.memory.proc2mem_addr testbench.pipeline_0.memory.proc2mem_data testbench.pipeline_0.memory.mem2proc_data testbench.pipeline_0.memory.mem2proc_response testbench.pipeline_0.memory.mem2proc_tag }

gui_sg_move "$_session_group_425" -after "$_session_group_424" -pos 6 

set _session_group_426 $_session_group_424|
append _session_group_426 Rmem
gui_sg_create "$_session_group_426"
set memory|Rmem "$_session_group_426"

gui_sg_addsignal -group "$_session_group_426" { testbench.pipeline_0.memory.proc2Rmem_command testbench.pipeline_0.memory.proc2Rmem_addr testbench.pipeline_0.memory.proc2Rmem_data testbench.pipeline_0.memory.Rmem2proc_response testbench.pipeline_0.memory.Rmem2proc_response_next }

gui_sg_move "$_session_group_426" -after "$_session_group_424" -pos 5 

set _session_group_427 $_session_group_424|
append _session_group_427 Dmem
gui_sg_create "$_session_group_427"
set memory|Dmem "$_session_group_427"

gui_sg_addsignal -group "$_session_group_427" { testbench.pipeline_0.memory.proc2Dmem_command testbench.pipeline_0.memory.proc2Dmem_addr testbench.pipeline_0.memory.proc2Dmem_data testbench.pipeline_0.memory.Dmem2proc_data testbench.pipeline_0.memory.Dmem2proc_data_next testbench.pipeline_0.memory.Dmem2proc_response testbench.pipeline_0.memory.Dmem2proc_response_next testbench.pipeline_0.memory.Dmem2proc_tag testbench.pipeline_0.memory.Dmem2proc_tag_next }

gui_sg_move "$_session_group_427" -after "$_session_group_424" -pos 4 

set _session_group_428 $_session_group_424|
append _session_group_428 Imem
gui_sg_create "$_session_group_428"
set memory|Imem "$_session_group_428"

gui_sg_addsignal -group "$_session_group_428" { testbench.pipeline_0.memory.proc2Imem_command testbench.pipeline_0.memory.proc2Imem_addr testbench.pipeline_0.memory.proc2Imem_data testbench.pipeline_0.memory.Imem2proc_data testbench.pipeline_0.memory.Imem2proc_data_next testbench.pipeline_0.memory.Imem2proc_response testbench.pipeline_0.memory.Imem2proc_response_next testbench.pipeline_0.memory.Imem2proc_tag_next testbench.pipeline_0.memory.Imem2proc_tag }

gui_sg_move "$_session_group_428" -after "$_session_group_424" -pos 3 

set _session_group_429 $_session_group_424|
append _session_group_429 State
gui_sg_create "$_session_group_429"
set memory|State "$_session_group_429"

gui_sg_addsignal -group "$_session_group_429" { testbench.pipeline_0.memory.state testbench.pipeline_0.memory.next_state }

gui_sg_move "$_session_group_429" -after "$_session_group_424" -pos 2 

set _session_group_430 Phys_reg_file
gui_sg_create "$_session_group_430"
set Phys_reg_file "$_session_group_430"

gui_sg_addsignal -group "$_session_group_430" { testbench.pipeline_0.regf_0.wr_clk testbench.pipeline_0.regf_0.rd_idx testbench.pipeline_0.regf_0.rd_out testbench.pipeline_0.regf_0.wr_en testbench.pipeline_0.regf_0.wr_idx testbench.pipeline_0.regf_0.wr_data testbench.pipeline_0.regf_0.phys_registers testbench.pipeline_0.regf_0.phys_registers_out {testbench.pipeline_0.regf_0.$unit} }

set _session_group_431 dcache0
gui_sg_create "$_session_group_431"
set dcache0 "$_session_group_431"

gui_sg_addsignal -group "$_session_group_431" { testbench.pipeline_0.mem_stage_0.dcache0.clock testbench.pipeline_0.mem_stage_0.dcache0.reset testbench.pipeline_0.mem_stage_0.dcache0.rd_en testbench.pipeline_0.mem_stage_0.dcache0.wr_en testbench.pipeline_0.mem_stage_0.dcache0.NUM_WAYS testbench.pipeline_0.mem_stage_0.dcache0.WR_PORTS testbench.pipeline_0.mem_stage_0.dcache0.RD_PORTS {testbench.pipeline_0.mem_stage_0.dcache0.$unit} }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.NUM_WAYS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.WR_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.WR_PORTS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.RD_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.dcache0.RD_PORTS}

set _session_group_432 $_session_group_431|
append _session_group_432 {memory signals}
gui_sg_create "$_session_group_432"
set {dcache0|memory signals} "$_session_group_432"

gui_sg_addsignal -group "$_session_group_432" { }

gui_sg_move "$_session_group_432" -after "$_session_group_431" -pos 10 

set _session_group_433 $_session_group_432|
append _session_group_433 proc/Dmem
gui_sg_create "$_session_group_433"
set {dcache0|memory signals|proc/Dmem} "$_session_group_433"

gui_sg_addsignal -group "$_session_group_433" { testbench.pipeline_0.mem_stage_0.dcache0.proc2Dmem_addr testbench.pipeline_0.mem_stage_0.dcache0.proc2Dmem_data testbench.pipeline_0.mem_stage_0.dcache0.proc2Dmem_command testbench.pipeline_0.mem_stage_0.dcache0.Dmem2proc_response testbench.pipeline_0.mem_stage_0.dcache0.Dmem2proc_data testbench.pipeline_0.mem_stage_0.dcache0.Dmem2proc_tag }

gui_sg_move "$_session_group_433" -after "$_session_group_432" -pos 1 

set _session_group_434 $_session_group_432|
append _session_group_434 proc/Dcache
gui_sg_create "$_session_group_434"
set {dcache0|memory signals|proc/Dcache} "$_session_group_434"

gui_sg_addsignal -group "$_session_group_434" { testbench.pipeline_0.mem_stage_0.dcache0.proc2Dcache_rd_addr testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_data_out testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_valid_out testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_miss_addr_out testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_miss_data_out testbench.pipeline_0.mem_stage_0.dcache0.Dcache_rd_miss_valid_out testbench.pipeline_0.mem_stage_0.dcache0.proc2Dcache_wr_addr testbench.pipeline_0.mem_stage_0.dcache0.proc2Dcache_wr_data }

set _session_group_435 $_session_group_431|
append _session_group_435 {Vic cache}
gui_sg_create "$_session_group_435"
set {dcache0|Vic cache} "$_session_group_435"

gui_sg_addsignal -group "$_session_group_435" { }

gui_sg_move "$_session_group_435" -after "$_session_group_431" -pos 9 

set _session_group_436 $_session_group_435|
append _session_group_436 wr/evicted
gui_sg_create "$_session_group_436"
set {dcache0|Vic cache|wr/evicted} "$_session_group_436"

gui_sg_addsignal -group "$_session_group_436" { testbench.pipeline_0.mem_stage_0.dcache0.victim testbench.pipeline_0.mem_stage_0.dcache0.victim_valid testbench.pipeline_0.mem_stage_0.dcache0.victim_idx testbench.pipeline_0.mem_stage_0.dcache0.evicted testbench.pipeline_0.mem_stage_0.dcache0.evicted_valid }

gui_sg_move "$_session_group_436" -after "$_session_group_435" -pos 1 

set _session_group_437 $_session_group_435|
append _session_group_437 vic_rd
gui_sg_create "$_session_group_437"
set {dcache0|Vic cache|vic_rd} "$_session_group_437"

gui_sg_addsignal -group "$_session_group_437" { testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_en testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_idx testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_tag testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_out testbench.pipeline_0.mem_stage_0.dcache0.vic_rd_valid }

set _session_group_438 $_session_group_431|
append _session_group_438 Cache
gui_sg_create "$_session_group_438"
set dcache0|Cache "$_session_group_438"

gui_sg_addsignal -group "$_session_group_438" { testbench.pipeline_0.mem_stage_0.dcache0.sets_out }

gui_sg_move "$_session_group_438" -after "$_session_group_431" -pos 8 

set _session_group_439 $_session_group_438|
append _session_group_439 Wr
gui_sg_create "$_session_group_439"
set dcache0|Cache|Wr "$_session_group_439"

gui_sg_addsignal -group "$_session_group_439" { testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_en testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_idx testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_tag testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_data testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_dirty testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_miss_idx testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_miss_tag testbench.pipeline_0.mem_stage_0.dcache0.cache_wr_miss_valid }

gui_sg_move "$_session_group_439" -after "$_session_group_438" -pos 2 

set _session_group_440 $_session_group_438|
append _session_group_440 Rd
gui_sg_create "$_session_group_440"
set dcache0|Cache|Rd "$_session_group_440"

gui_sg_addsignal -group "$_session_group_440" { testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_en testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_idx testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_tag testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_data testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_valid testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_miss_idx testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_miss_tag testbench.pipeline_0.mem_stage_0.dcache0.cache_rd_miss_valid }

gui_sg_move "$_session_group_440" -after "$_session_group_438" -pos 1 

set _session_group_441 $_session_group_431|
append _session_group_441 {Mem Queue}
gui_sg_create "$_session_group_441"
set {dcache0|Mem Queue} "$_session_group_441"

gui_sg_addsignal -group "$_session_group_441" { testbench.pipeline_0.mem_stage_0.dcache0.send_request testbench.pipeline_0.mem_stage_0.dcache0.mem_done testbench.pipeline_0.mem_stage_0.dcache0.update_mem_tag testbench.pipeline_0.mem_stage_0.dcache0.mem_rd_data testbench.pipeline_0.mem_stage_0.dcache0.add_rd_to_queue testbench.pipeline_0.mem_stage_0.dcache0.unanswered_miss }

gui_sg_move "$_session_group_441" -after "$_session_group_431" -pos 7 

set _session_group_442 $_session_group_441|
append _session_group_442 Next
gui_sg_create "$_session_group_442"
set {dcache0|Mem Queue|Next} "$_session_group_442"

gui_sg_addsignal -group "$_session_group_442" { testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue_next testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue_tail_next testbench.pipeline_0.mem_stage_0.dcache0.send_req_ptr_next testbench.pipeline_0.mem_stage_0.dcache0.mem_waiting_ptr_next }

gui_sg_move "$_session_group_442" -after "$_session_group_441" -pos 7 

set _session_group_443 $_session_group_441|
append _session_group_443 Current
gui_sg_create "$_session_group_443"
set {dcache0|Mem Queue|Current} "$_session_group_443"

gui_sg_addsignal -group "$_session_group_443" { testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue testbench.pipeline_0.mem_stage_0.dcache0.mem_req_queue_tail testbench.pipeline_0.mem_stage_0.dcache0.send_req_ptr testbench.pipeline_0.mem_stage_0.dcache0.mem_waiting_ptr }

gui_sg_move "$_session_group_443" -after "$_session_group_441" -pos 6 

set _session_group_444 $_session_group_431|
append _session_group_444 Encoders
gui_sg_create "$_session_group_444"
set dcache0|Encoders "$_session_group_444"

gui_sg_addsignal -group "$_session_group_444" { }

gui_sg_move "$_session_group_444" -after "$_session_group_431" -pos 6 

set _session_group_445 $_session_group_444|
append _session_group_445 Outputs
gui_sg_create "$_session_group_445"
set dcache0|Encoders|Outputs "$_session_group_445"

gui_sg_addsignal -group "$_session_group_445" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_num testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_num_valid testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_idx testbench.pipeline_0.mem_stage_0.dcache0.fifo_hit_idx_valid testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_num testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_num_valid testbench.pipeline_0.mem_stage_0.dcache0.fetch_addr_hit_num testbench.pipeline_0.mem_stage_0.dcache0.fetch_addr_hit_num_valid testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_hit_num testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_hit_num_valid }

gui_sg_move "$_session_group_445" -after "$_session_group_444" -pos 1 

set _session_group_446 $_session_group_444|
append _session_group_446 Inputs
gui_sg_create "$_session_group_446"
set dcache0|Encoders|Inputs "$_session_group_446"

gui_sg_addsignal -group "$_session_group_446" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_num_hits testbench.pipeline_0.mem_stage_0.dcache0.fifo_idx_hits testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_req testbench.pipeline_0.mem_stage_0.dcache0.fifo_sel_gnt testbench.pipeline_0.mem_stage_0.dcache0.fetch_addr_hits testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_hits }

set _session_group_447 $_session_group_431|
append _session_group_447 CAM
gui_sg_create "$_session_group_447"
set dcache0|CAM "$_session_group_447"

gui_sg_addsignal -group "$_session_group_447" { }

gui_sg_move "$_session_group_447" -after "$_session_group_431" -pos 5 

set _session_group_448 $_session_group_447|
append _session_group_448 Outputs
gui_sg_create "$_session_group_448"
set dcache0|CAM|Outputs "$_session_group_448"

gui_sg_addsignal -group "$_session_group_448" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_cam_hits testbench.pipeline_0.mem_stage_0.dcache0.fetch_addr_cam_hits testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_cam_hits }

gui_sg_move "$_session_group_448" -after "$_session_group_447" -pos 1 

set _session_group_449 $_session_group_447|
append _session_group_449 Inputs
gui_sg_create "$_session_group_449"
set dcache0|CAM|Inputs "$_session_group_449"

gui_sg_addsignal -group "$_session_group_449" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_addr_table_in testbench.pipeline_0.mem_stage_0.dcache0.fifo_cam_tags testbench.pipeline_0.mem_stage_0.dcache0.fetch_addr_cam_table_in testbench.pipeline_0.mem_stage_0.dcache0.fetch_addr_cam_tags testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_cam_table_in testbench.pipeline_0.mem_stage_0.dcache0.mem_queue_cam_tags }

set _session_group_450 $_session_group_431|
append _session_group_450 FIFO
gui_sg_create "$_session_group_450"
set dcache0|FIFO "$_session_group_450"

gui_sg_addsignal -group "$_session_group_450" { testbench.pipeline_0.mem_stage_0.dcache0.update_fifo_fetch_addr testbench.pipeline_0.mem_stage_0.dcache0.update_fifo_lru }

gui_sg_move "$_session_group_450" -after "$_session_group_431" -pos 4 

set _session_group_451 $_session_group_450|
append _session_group_451 LRU
gui_sg_create "$_session_group_451"
set dcache0|FIFO|LRU "$_session_group_451"

gui_sg_addsignal -group "$_session_group_451" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_lru testbench.pipeline_0.mem_stage_0.dcache0.fifo_lru_next testbench.pipeline_0.mem_stage_0.dcache0.next_lru_idx testbench.pipeline_0.mem_stage_0.dcache0.acc testbench.pipeline_0.mem_stage_0.dcache0.temp_lru_idx testbench.pipeline_0.mem_stage_0.dcache0.fill_fifo_idx }

gui_sg_move "$_session_group_451" -after "$_session_group_450" -pos 4 

set _session_group_452 $_session_group_450|
append _session_group_452 Next
gui_sg_create "$_session_group_452"
set dcache0|FIFO|Next "$_session_group_452"

gui_sg_addsignal -group "$_session_group_452" { testbench.pipeline_0.mem_stage_0.dcache0.fifo_next testbench.pipeline_0.mem_stage_0.dcache0.fifo_tail_next testbench.pipeline_0.mem_stage_0.dcache0.fifo_filled_next testbench.pipeline_0.mem_stage_0.dcache0.fifo_busy_next testbench.pipeline_0.mem_stage_0.dcache0.fifo_fetch_addr_next testbench.pipeline_0.mem_stage_0.dcache0.fetch_stride_next }

gui_sg_move "$_session_group_452" -after "$_session_group_450" -pos 3 

set _session_group_453 $_session_group_450|
append _session_group_453 Current
gui_sg_create "$_session_group_453"
set dcache0|FIFO|Current "$_session_group_453"

gui_sg_addsignal -group "$_session_group_453" { testbench.pipeline_0.mem_stage_0.dcache0.fifo testbench.pipeline_0.mem_stage_0.dcache0.fifo_tail testbench.pipeline_0.mem_stage_0.dcache0.fifo_filled testbench.pipeline_0.mem_stage_0.dcache0.fifo_busy testbench.pipeline_0.mem_stage_0.dcache0.fifo_fetch_addr testbench.pipeline_0.mem_stage_0.dcache0.fetch_stride }

gui_sg_move "$_session_group_453" -after "$_session_group_450" -pos 2 

set _session_group_454 retire_buffer
gui_sg_create "$_session_group_454"
set retire_buffer "$_session_group_454"

gui_sg_addsignal -group "$_session_group_454" { testbench.pipeline_0.mem_stage_0.rb0.clock testbench.pipeline_0.mem_stage_0.rb0.reset testbench.pipeline_0.mem_stage_0.rb0.WR_PORTS testbench.pipeline_0.mem_stage_0.rb0.NUM_WAYS {testbench.pipeline_0.mem_stage_0.rb0.$unit} }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.WR_PORTS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.WR_PORTS}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.NUM_WAYS}
gui_set_radix -radix {twosComplement} -signals {Sim:testbench.pipeline_0.mem_stage_0.rb0.NUM_WAYS}

set _session_group_455 $_session_group_454|
append _session_group_455 {Memory Signals}
gui_sg_create "$_session_group_455"
set {retire_buffer|Memory Signals} "$_session_group_455"

gui_sg_addsignal -group "$_session_group_455" { testbench.pipeline_0.mem_stage_0.rb0.proc2Rmem_addr testbench.pipeline_0.mem_stage_0.rb0.proc2Rmem_data testbench.pipeline_0.mem_stage_0.rb0.proc2Rmem_command testbench.pipeline_0.mem_stage_0.rb0.Rmem2proc_response }

gui_sg_move "$_session_group_455" -after "$_session_group_454" -pos 5 

set _session_group_456 $_session_group_454|
append _session_group_456 retire_queue_next
gui_sg_create "$_session_group_456"
set retire_buffer|retire_queue_next "$_session_group_456"

gui_sg_addsignal -group "$_session_group_456" { testbench.pipeline_0.mem_stage_0.rb0.retire_queue_next testbench.pipeline_0.mem_stage_0.rb0.retire_queue_tail_next testbench.pipeline_0.mem_stage_0.rb0.send_req_ptr_next testbench.pipeline_0.mem_stage_0.rb0.request_not_accepted testbench.pipeline_0.mem_stage_0.rb0.update_queue }

gui_sg_move "$_session_group_456" -after "$_session_group_454" -pos 4 

set _session_group_457 $_session_group_454|
append _session_group_457 retire_queue
gui_sg_create "$_session_group_457"
set retire_buffer|retire_queue "$_session_group_457"

gui_sg_addsignal -group "$_session_group_457" { testbench.pipeline_0.mem_stage_0.rb0.retire_queue testbench.pipeline_0.mem_stage_0.rb0.retire_queue_tail testbench.pipeline_0.mem_stage_0.rb0.send_req_ptr testbench.pipeline_0.mem_stage_0.rb0.send_request }

gui_sg_move "$_session_group_457" -after "$_session_group_454" -pos 3 

set _session_group_458 $_session_group_454|
append _session_group_458 In/Out
gui_sg_create "$_session_group_458"
set retire_buffer|In/Out "$_session_group_458"

gui_sg_addsignal -group "$_session_group_458" { testbench.pipeline_0.mem_stage_0.rb0.evicted testbench.pipeline_0.mem_stage_0.rb0.evicted_valid testbench.pipeline_0.mem_stage_0.rb0.full }

gui_sg_move "$_session_group_458" -after "$_session_group_454" -pos 2 

set _session_group_459 Group1
gui_sg_create "$_session_group_459"
set Group1 "$_session_group_459"

gui_sg_addsignal -group "$_session_group_459" { testbench.pipeline_0.if_NPC_out testbench.pipeline_0.if_IR_out testbench.pipeline_0.if_valid_inst_out testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_valid_inst testbench.pipeline_0.if_id_enable testbench.pipeline_0.if_inst_in testbench.pipeline_0.if_id_inst_out testbench.pipeline_0.if1_fetch_NPC_out testbench.pipeline_0.if1_IR_out testbench.pipeline_0.if1_PC_reg testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.if1_branch_inst testbench.pipeline_0.if12_fetch_NPC_out testbench.pipeline_0.if12_IR_out testbench.pipeline_0.if12_PC_reg testbench.pipeline_0.if12_valid_inst_out testbench.pipeline_0.if12_branch_inst testbench.pipeline_0.if2_branch_inst testbench.pipeline_0.if2_bp_NPC_valid testbench.pipeline_0.if2_bp_NPC testbench.pipeline_0.if_branch_inst testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.if_PC_reg testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if_bp_NPC testbench.pipeline_0.if_fetch_NPC_out testbench.pipeline_0.if_fetch_valid_inst_out testbench.pipeline_0.if_stage_dispatch_en }

set _session_group_460 {pipeline if signals}
gui_sg_create "$_session_group_460"
set {pipeline if signals} "$_session_group_460"

gui_sg_addsignal -group "$_session_group_460" { testbench.pipeline_0.if_NPC_out testbench.pipeline_0.if_IR_out testbench.pipeline_0.if_valid_inst_out testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_valid_inst testbench.pipeline_0.if_id_enable testbench.pipeline_0.if_inst_in testbench.pipeline_0.if_id_inst_out testbench.pipeline_0.if1_fetch_NPC_out testbench.pipeline_0.if1_IR_out testbench.pipeline_0.if1_PC_reg testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.if1_branch_inst testbench.pipeline_0.if12_fetch_NPC_out testbench.pipeline_0.if12_IR_out testbench.pipeline_0.if12_PC_reg testbench.pipeline_0.if12_valid_inst_out testbench.pipeline_0.if12_branch_inst testbench.pipeline_0.if2_branch_inst testbench.pipeline_0.if2_bp_NPC_valid testbench.pipeline_0.if2_bp_NPC testbench.pipeline_0.if_branch_inst testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.if_PC_reg testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if_bp_NPC testbench.pipeline_0.if_fetch_NPC_out testbench.pipeline_0.if_fetch_valid_inst_out testbench.pipeline_0.if_stage_dispatch_en }

set _session_group_461 {pipeline id signals}
gui_sg_create "$_session_group_461"
set {pipeline id signals} "$_session_group_461"

gui_sg_addsignal -group "$_session_group_461" { testbench.pipeline_0.pipeline_commit_wr_idx testbench.pipeline_0.if_valid_inst_out testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_valid_inst testbench.pipeline_0.id_di_NPC testbench.pipeline_0.id_di_IR testbench.pipeline_0.id_di_valid_inst testbench.pipeline_0.rs_table_out_inst_valid_inst testbench.pipeline_0.issue_reg_inst_valid_inst testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.if_id_enable testbench.pipeline_0.btb_valid_out testbench.pipeline_0.if_id_inst_out testbench.pipeline_0.id_rega_out testbench.pipeline_0.id_regb_out testbench.pipeline_0.id_inst_out testbench.pipeline_0.id_ra_idx testbench.pipeline_0.id_rb_idx testbench.pipeline_0.id_rdest_idx testbench.pipeline_0.id_di_inst_in testbench.pipeline_0.id_di_rega testbench.pipeline_0.id_di_regb testbench.pipeline_0.ex_reg_valid testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.co_reg_wr_idx_out testbench.pipeline_0.co_valid_inst_selected testbench.pipeline_0.co_branch_valid testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.branch_valid_disp testbench.pipeline_0.retire_reg_wr_idx testbench.pipeline_0.Icache_valid_out testbench.pipeline_0.ex_store_addr_valid testbench.pipeline_0.ex_store_data_valid testbench.pipeline_0.sq_data_valid testbench.pipeline_0.lq_miss_valid testbench.pipeline_0.lq_read_valid testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.if12_valid_inst_out testbench.pipeline_0.if2_bp_NPC_valid testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.id_branch_inst testbench.pipeline_0.id_di_branch_inst testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if_fetch_valid_inst_out testbench.pipeline_0.id_no_dest_reg testbench.pipeline_0.id_di_enable testbench.pipeline_0.mem_dest_reg_idx_out testbench.pipeline_0.mem_valid_inst_out testbench.pipeline_0.FU_BASE_IDX }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.FU_BASE_IDX}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.pipeline_0.FU_BASE_IDX}

set _session_group_462 {pipeline di signals}
gui_sg_create "$_session_group_462"
set {pipeline di signals} "$_session_group_462"

gui_sg_addsignal -group "$_session_group_462" { testbench.pipeline_0.id_di_NPC testbench.pipeline_0.id_di_IR testbench.pipeline_0.id_di_valid_inst testbench.pipeline_0.dispatch_en testbench.pipeline_0.id_di_inst_in testbench.pipeline_0.id_di_rega testbench.pipeline_0.id_di_regb testbench.pipeline_0.dispatch_no_hazard testbench.pipeline_0.co_branch_prediction testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.branch_valid_disp testbench.pipeline_0.dispatch_is_store testbench.pipeline_0.dispatch_store_addr testbench.pipeline_0.dispatch_store_addr_ready testbench.pipeline_0.dispatch_store_data testbench.pipeline_0.dispatch_store_data_ready testbench.pipeline_0.id_di_branch_inst testbench.pipeline_0.if_stage_dispatch_en testbench.pipeline_0.dispatch_no_hazard_comb testbench.pipeline_0.id_di_enable }

set _session_group_463 {pipeline is signals}
gui_sg_create "$_session_group_463"
set {pipeline is signals} "$_session_group_463"

gui_sg_addsignal -group "$_session_group_463" { testbench.pipeline_0.issue_reg_npc testbench.pipeline_0.issue_reg_inst_opcode testbench.pipeline_0.issue_reg_inst_valid_inst testbench.pipeline_0.issue_next testbench.pipeline_0.free_list_out testbench.pipeline_0.is_pr_enable testbench.pipeline_0.dispatch_en testbench.pipeline_0.is_ex_enable testbench.pipeline_0.dispatch_no_hazard testbench.pipeline_0.issue_stall testbench.pipeline_0.issue_reg testbench.pipeline_0.is_ex_T1_value testbench.pipeline_0.is_ex_T2_value testbench.pipeline_0.issue_reg_tags testbench.pipeline_0.branch_valid_disp testbench.pipeline_0.free_list_in testbench.pipeline_0.free_list_check testbench.pipeline_0.dispatch_is_store testbench.pipeline_0.dispatch_store_addr testbench.pipeline_0.dispatch_store_addr_ready testbench.pipeline_0.dispatch_store_data testbench.pipeline_0.dispatch_store_data_ready testbench.pipeline_0.execute_is_store testbench.pipeline_0.retire_is_store testbench.pipeline_0.retire_is_store_next testbench.pipeline_0.lq_miss_data testbench.pipeline_0.lq_miss_addr testbench.pipeline_0.lq_miss_valid testbench.pipeline_0.if_stage_dispatch_en testbench.pipeline_0.dispatch_no_hazard_comb }

set _session_group_464 {pipeline ex signals}
gui_sg_create "$_session_group_464"
set {pipeline ex signals} "$_session_group_464"

gui_sg_addsignal -group "$_session_group_464" { testbench.pipeline_0.issue_next testbench.pipeline_0.ex_co_NPC testbench.pipeline_0.ex_co_IR testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.is_ex_enable testbench.pipeline_0.ex_co_enable testbench.pipeline_0.rs_free_rows_next_out testbench.pipeline_0.is_ex_T1_value testbench.pipeline_0.is_ex_T2_value testbench.pipeline_0.ex_alu_result_out testbench.pipeline_0.ex_take_branch_out testbench.pipeline_0.ex_reg_tags testbench.pipeline_0.ex_reg_valid testbench.pipeline_0.ex_mult_reg testbench.pipeline_0.ex_co_halt testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_done testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.ex_co_rega testbench.pipeline_0.ex_co_rega_st testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.rob_free_rows_next_out testbench.pipeline_0.execute_is_store testbench.pipeline_0.ex_store_addr testbench.pipeline_0.ex_store_addr_valid testbench.pipeline_0.ex_store_data testbench.pipeline_0.ex_store_data_valid testbench.pipeline_0.retire_is_store_next testbench.pipeline_0.ex_co_branch_index testbench.pipeline_0.co_branch_index testbench.pipeline_0.ex_co_branch_target }

set _session_group_465 {pipeline mem signals}
gui_sg_create "$_session_group_465"
set {pipeline mem signals} "$_session_group_465"

gui_sg_addsignal -group "$_session_group_465" { testbench.pipeline_0.mem2proc_response testbench.pipeline_0.mem2proc_data testbench.pipeline_0.mem2proc_tag testbench.pipeline_0.proc2mem_command testbench.pipeline_0.proc2mem_addr testbench.pipeline_0.proc2mem_data testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.mem_co_NPC testbench.pipeline_0.mem_co_IR testbench.pipeline_0.mem_co_enable testbench.pipeline_0.mem_result_out testbench.pipeline_0.mem_stall_out testbench.pipeline_0.mem_rd_stall testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.mem_co_halt_comb testbench.pipeline_0.mem_co_illegal_comb testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.mem_co_alu_result_comb testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.mem_co_NPC_comb testbench.pipeline_0.mem_co_IR_comb testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.proc2Dmem_addr testbench.pipeline_0.proc2Imem_addr testbench.pipeline_0.proc2Rmem_addr testbench.pipeline_0.proc2Rmem_data testbench.pipeline_0.proc2Dmem_command testbench.pipeline_0.proc2Imem_command testbench.pipeline_0.proc2Rmem_command testbench.pipeline_0.Dmem2proc_response testbench.pipeline_0.Imem2proc_response testbench.pipeline_0.Rmem2proc_response testbench.pipeline_0.Dmem2proc_data testbench.pipeline_0.Imem2proc_data testbench.pipeline_0.Dmem2proc_tag testbench.pipeline_0.Imem2proc_tag testbench.pipeline_0.mem_co_stall testbench.pipeline_0.mem_co_comb testbench.pipeline_0.proc2Dmem_data testbench.pipeline_0.mem_dest_reg_idx_out testbench.pipeline_0.mem_valid_inst_out }

set _session_group_466 {pipeline co signals}
gui_sg_create "$_session_group_466"
set {pipeline co signals} "$_session_group_466"

gui_sg_addsignal -group "$_session_group_466" { testbench.pipeline_0.proc2mem_command testbench.pipeline_0.pipeline_completed_insts testbench.pipeline_0.pipeline_commit_wr_idx testbench.pipeline_0.pipeline_commit_wr_data testbench.pipeline_0.pipeline_commit_wr_en testbench.pipeline_0.pipeline_commit_NPC testbench.pipeline_0.pipeline_commit_phys_reg testbench.pipeline_0.pipeline_commit_phys_from_arch testbench.pipeline_0.pipeline_branch_pred_correct testbench.pipeline_0.rs_table_out_inst_opcode testbench.pipeline_0.issue_reg_inst_opcode testbench.pipeline_0.mem_co_valid_inst testbench.pipeline_0.mem_co_NPC testbench.pipeline_0.mem_co_IR testbench.pipeline_0.ex_co_NPC testbench.pipeline_0.ex_co_IR testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.co_ret_NPC testbench.pipeline_0.co_ret_IR testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.mem_co_enable testbench.pipeline_0.co_ret_enable testbench.pipeline_0.ex_co_enable testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.mem_co_halt_comb testbench.pipeline_0.mem_co_illegal_comb testbench.pipeline_0.mem_co_dest_reg_idx_comb testbench.pipeline_0.mem_co_alu_result_comb testbench.pipeline_0.mem_co_valid_inst_comb testbench.pipeline_0.mem_co_NPC_comb testbench.pipeline_0.mem_co_IR_comb testbench.pipeline_0.ex_co_halt testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_done testbench.pipeline_0.ex_co_wr_mem testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.ex_co_rega testbench.pipeline_0.ex_co_rega_st testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.co_halt_selected testbench.pipeline_0.co_illegal_selected testbench.pipeline_0.co_reg_wr_idx_out testbench.pipeline_0.co_reg_wr_data_out testbench.pipeline_0.co_reg_wr_en_out testbench.pipeline_0.co_take_branch_selected testbench.pipeline_0.co_NPC_selected testbench.pipeline_0.co_valid_inst_selected testbench.pipeline_0.co_selected testbench.pipeline_0.co_branch_valid testbench.pipeline_0.co_branch_prediction testbench.pipeline_0.co_IR_selected testbench.pipeline_0.co_alu_result_selected testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.co_ret_halt testbench.pipeline_0.co_ret_illegal testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.co_ret_result testbench.pipeline_0.co_ret_take_branch testbench.pipeline_0.rob_retire_opcode testbench.pipeline_0.proc2Dmem_command testbench.pipeline_0.proc2Imem_command testbench.pipeline_0.proc2Rmem_command testbench.pipeline_0.ret_pred_correct testbench.pipeline_0.ex_co_branch_index testbench.pipeline_0.co_branch_index testbench.pipeline_0.ex_co_branch_target testbench.pipeline_0.co_branch_target testbench.pipeline_0.mem_co_stall testbench.pipeline_0.mem_co_comb testbench.pipeline_0.dispatch_no_hazard_comb }

set _session_group_467 {pipeline ret signals}
gui_sg_create "$_session_group_467"
set {pipeline ret signals} "$_session_group_467"

gui_sg_addsignal -group "$_session_group_467" { testbench.pipeline_0.retire_inst_busy testbench.pipeline_0.retire_reg_NPC testbench.pipeline_0.co_ret_NPC testbench.pipeline_0.co_ret_IR testbench.pipeline_0.co_ret_valid_inst testbench.pipeline_0.co_ret_enable testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.co_ret_halt testbench.pipeline_0.co_ret_illegal testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.co_ret_result testbench.pipeline_0.co_ret_take_branch testbench.pipeline_0.rob_retire_out testbench.pipeline_0.retire_reg_wr_data testbench.pipeline_0.retire_reg_wr_idx testbench.pipeline_0.retire_reg_wr_en testbench.pipeline_0.retire_reg_phys testbench.pipeline_0.rob_retire_out_halt testbench.pipeline_0.rob_retire_out_take_branch testbench.pipeline_0.rob_retire_out_T_new testbench.pipeline_0.rob_retire_out_T_old testbench.pipeline_0.rob_retire_opcode testbench.pipeline_0.retire_is_store testbench.pipeline_0.retire_is_store_next testbench.pipeline_0.ret_branch_inst testbench.pipeline_0.ret_pred_correct }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 589



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
catch {gui_list_expand -id ${Hier.1} testbench.pipeline_0}
catch {gui_list_expand -id ${Hier.1} testbench.pipeline_0.mem_stage_0}
catch {gui_list_select -id ${Hier.1} {testbench.pipeline_0.mem_stage_0.rb0}}
gui_view_scroll -id ${Hier.1} -vertical -set 13
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {*}
gui_list_show_data -id ${Data.1} {testbench.pipeline_0.mem_stage_0.rb0}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {testbench.pipeline_0.mem_stage_0.rb0.proc2Rmem_command }}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 13
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active _vcs_unit__1703597509 /home/eliubakk/eecs470/projects/4/verilog/pipeline.v
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
gui_wv_zoom_timerange -id ${Wave.1} 432 1885
gui_list_add_group -id ${Wave.1} -after {New Group} {ROB}
gui_list_add_group -id ${Wave.1} -after {New Group} {Free_List}
gui_list_add_group -id ${Wave.1} -after {New Group} {Map_Table}
gui_list_add_group -id ${Wave.1} -after {New Group} {Arch_Map}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache_mem}
gui_list_add_group -id ${Wave.1} -after {New Group} {icache}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.inst_memory.changed_addr {icache|CAM}
gui_list_add_group -id ${Wave.1} -after icache|CAM {icache|Queue}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.inst_memory.update_mem_tag {icache|Queue|curr}
gui_list_add_group -id ${Wave.1} -after icache|Queue|curr {icache|Queue|next}
gui_list_add_group -id ${Wave.1} -after icache|Queue {icache|Cache}
gui_list_add_group -id ${Wave.1}  -after icache|Cache {icache|Cache|rd}
gui_list_add_group -id ${Wave.1} -after icache|Cache|rd {icache|Cache|wr}
gui_list_add_group -id ${Wave.1} -after icache|Cache {{icache|Memory signals}}
gui_list_add_group -id ${Wave.1}  -after {icache|Memory signals} {{icache|Memory signals|Icache}}
gui_list_add_group -id ${Wave.1} -after {icache|Memory signals|Icache} {{icache|Memory signals|Imem}}
gui_list_add_group -id ${Wave.1} -after {New Group} {IQ}
gui_list_add_group -id ${Wave.1} -after {New Group} {BP2}
gui_list_add_group -id ${Wave.1} -after {New Group} {if_stage}
gui_list_add_group -id ${Wave.1} -after {New Group} {id_stage}
gui_list_add_group -id ${Wave.1} -after {New Group} {RS}
gui_list_add_group -id ${Wave.1} -after {New Group} {ex_stage}
gui_list_add_group -id ${Wave.1} -after {New Group} {LQ}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.load_queue.lq_miss_valid {{LQ|load in}}
gui_list_add_group -id ${Wave.1} -after {LQ|load in} {{LQ|load out}}
gui_list_add_group -id ${Wave.1} -after {LQ|load out} {LQ|queue}
gui_list_add_group -id ${Wave.1}  -after LQ|queue {LQ|queue|curr}
gui_list_add_group -id ${Wave.1} -after LQ|queue|curr {LQ|queue|next}
gui_list_add_group -id ${Wave.1} -after {New Group} {SQ}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.store_queue.full {SQ|rd}
gui_list_add_group -id ${Wave.1} -after SQ|rd {SQ|dis}
gui_list_add_group -id ${Wave.1} -after SQ|dis {SQ|ex}
gui_list_add_group -id ${Wave.1} -after SQ|ex {SQ|encoder}
gui_list_add_group -id ${Wave.1} -after SQ|encoder {{SQ|interal data}}
gui_list_add_group -id ${Wave.1}  -after {SQ|interal data} {{SQ|interal data|curr}}
gui_list_add_group -id ${Wave.1} -after {SQ|interal data|curr} {{SQ|interal data|next}}
gui_list_add_group -id ${Wave.1} -after {SQ|interal data} {{SQ|internals out}}
gui_list_add_group -id ${Wave.1} -after {New Group} {mem_stage}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.mem_stage_0.reset {{mem_stage|wr signals}}
gui_list_add_group -id ${Wave.1} -after {mem_stage|wr signals} {{mem_stage|rd signals}}
gui_list_add_group -id ${Wave.1} -after {mem_stage|rd signals} {{mem_stage|memory signals}}
gui_list_add_group -id ${Wave.1} -after {mem_stage|memory signals} {{mem_stage|evicted/control signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {memory}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.memory.reset {memory|State}
gui_list_add_group -id ${Wave.1} -after memory|State {memory|Imem}
gui_list_add_group -id ${Wave.1} -after memory|Imem {memory|Dmem}
gui_list_add_group -id ${Wave.1} -after memory|Dmem {memory|Rmem}
gui_list_add_group -id ${Wave.1} -after memory|Rmem {{memory|Main mem}}
gui_list_add_group -id ${Wave.1} -after {New Group} {Phys_reg_file}
gui_list_add_group -id ${Wave.1} -after {New Group} {dcache0}
gui_list_add_group -id ${Wave.1}  -after {testbench.pipeline_0.mem_stage_0.dcache0.wr_en[0:0]} {dcache0|FIFO}
gui_list_add_group -id ${Wave.1}  -after {testbench.pipeline_0.mem_stage_0.dcache0.update_fifo_lru[3:0]} {dcache0|FIFO|Current}
gui_list_add_group -id ${Wave.1} -after dcache0|FIFO|Current {dcache0|FIFO|Next}
gui_list_add_group -id ${Wave.1} -after dcache0|FIFO|Next {dcache0|FIFO|LRU}
gui_list_add_group -id ${Wave.1} -after dcache0|FIFO {dcache0|CAM}
gui_list_add_group -id ${Wave.1}  -after dcache0|CAM {dcache0|CAM|Inputs}
gui_list_add_group -id ${Wave.1} -after dcache0|CAM|Inputs {dcache0|CAM|Outputs}
gui_list_add_group -id ${Wave.1} -after dcache0|CAM {dcache0|Encoders}
gui_list_add_group -id ${Wave.1}  -after dcache0|Encoders {dcache0|Encoders|Inputs}
gui_list_add_group -id ${Wave.1} -after dcache0|Encoders|Inputs {dcache0|Encoders|Outputs}
gui_list_add_group -id ${Wave.1} -after dcache0|Encoders {{dcache0|Mem Queue}}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.mem_stage_0.dcache0.unanswered_miss {{dcache0|Mem Queue|Current}}
gui_list_add_group -id ${Wave.1} -after {dcache0|Mem Queue|Current} {{dcache0|Mem Queue|Next}}
gui_list_add_group -id ${Wave.1} -after {dcache0|Mem Queue} {dcache0|Cache}
gui_list_add_group -id ${Wave.1}  -after {testbench.pipeline_0.mem_stage_0.dcache0.sets_out[7:0]} {dcache0|Cache|Rd}
gui_list_add_group -id ${Wave.1} -after dcache0|Cache|Rd {dcache0|Cache|Wr}
gui_list_add_group -id ${Wave.1} -after dcache0|Cache {{dcache0|Vic cache}}
gui_list_add_group -id ${Wave.1}  -after {dcache0|Vic cache} {{dcache0|Vic cache|vic_rd}}
gui_list_add_group -id ${Wave.1} -after {dcache0|Vic cache|vic_rd} {{dcache0|Vic cache|wr/evicted}}
gui_list_add_group -id ${Wave.1} -after {dcache0|Vic cache} {{dcache0|memory signals}}
gui_list_add_group -id ${Wave.1}  -after {dcache0|memory signals} {{dcache0|memory signals|proc/Dcache}}
gui_list_add_group -id ${Wave.1} -after {dcache0|memory signals|proc/Dcache} {{dcache0|memory signals|proc/Dmem}}
gui_list_add_group -id ${Wave.1} -after {New Group} {retire_buffer}
gui_list_add_group -id ${Wave.1}  -after testbench.pipeline_0.mem_stage_0.rb0.reset {retire_buffer|In/Out}
gui_list_add_group -id ${Wave.1} -after retire_buffer|In/Out {retire_buffer|retire_queue}
gui_list_add_group -id ${Wave.1} -after retire_buffer|retire_queue {retire_buffer|retire_queue_next}
gui_list_add_group -id ${Wave.1} -after retire_buffer|retire_queue_next {{retire_buffer|Memory Signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline if signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline id signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline di signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline is signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline ex signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline mem signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline co signals}}
gui_list_add_group -id ${Wave.1} -after {New Group} {{pipeline ret signals}}
gui_list_collapse -id ${Wave.1} ROB
gui_list_collapse -id ${Wave.1} Free_List
gui_list_collapse -id ${Wave.1} Map_Table
gui_list_collapse -id ${Wave.1} Arch_Map
gui_list_collapse -id ${Wave.1} icache_mem
gui_list_collapse -id ${Wave.1} icache
gui_list_collapse -id ${Wave.1} icache|CAM
gui_list_collapse -id ${Wave.1} icache|Queue
gui_list_collapse -id ${Wave.1} icache|Queue|curr
gui_list_collapse -id ${Wave.1} icache|Queue|next
gui_list_collapse -id ${Wave.1} icache|Cache
gui_list_collapse -id ${Wave.1} icache|Cache|rd
gui_list_collapse -id ${Wave.1} icache|Cache|wr
gui_list_collapse -id ${Wave.1} {icache|Memory signals}
gui_list_collapse -id ${Wave.1} {icache|Memory signals|Icache}
gui_list_collapse -id ${Wave.1} {icache|Memory signals|Imem}
gui_list_collapse -id ${Wave.1} IQ
gui_list_collapse -id ${Wave.1} BP2
gui_list_collapse -id ${Wave.1} if_stage
gui_list_collapse -id ${Wave.1} id_stage
gui_list_collapse -id ${Wave.1} RS
gui_list_collapse -id ${Wave.1} ex_stage
gui_list_collapse -id ${Wave.1} LQ
gui_list_collapse -id ${Wave.1} {LQ|load in}
gui_list_collapse -id ${Wave.1} {LQ|load out}
gui_list_collapse -id ${Wave.1} LQ|queue
gui_list_collapse -id ${Wave.1} LQ|queue|curr
gui_list_collapse -id ${Wave.1} LQ|queue|next
gui_list_collapse -id ${Wave.1} SQ
gui_list_collapse -id ${Wave.1} SQ|rd
gui_list_collapse -id ${Wave.1} SQ|dis
gui_list_collapse -id ${Wave.1} SQ|ex
gui_list_collapse -id ${Wave.1} SQ|encoder
gui_list_collapse -id ${Wave.1} {SQ|interal data}
gui_list_collapse -id ${Wave.1} {SQ|interal data|curr}
gui_list_collapse -id ${Wave.1} {SQ|interal data|next}
gui_list_collapse -id ${Wave.1} {SQ|internals out}
gui_list_collapse -id ${Wave.1} mem_stage
gui_list_collapse -id ${Wave.1} {mem_stage|wr signals}
gui_list_collapse -id ${Wave.1} {mem_stage|rd signals}
gui_list_collapse -id ${Wave.1} {mem_stage|memory signals}
gui_list_collapse -id ${Wave.1} {mem_stage|evicted/control signals}
gui_list_collapse -id ${Wave.1} memory
gui_list_collapse -id ${Wave.1} Phys_reg_file
gui_list_collapse -id ${Wave.1} dcache0
gui_list_collapse -id ${Wave.1} dcache0|FIFO
gui_list_collapse -id ${Wave.1} dcache0|FIFO|Current
gui_list_collapse -id ${Wave.1} dcache0|FIFO|Next
gui_list_collapse -id ${Wave.1} dcache0|FIFO|LRU
gui_list_collapse -id ${Wave.1} dcache0|CAM
gui_list_collapse -id ${Wave.1} dcache0|Encoders
gui_list_collapse -id ${Wave.1} {dcache0|Mem Queue}
gui_list_collapse -id ${Wave.1} {dcache0|Mem Queue|Current}
gui_list_collapse -id ${Wave.1} {dcache0|Mem Queue|Next}
gui_list_collapse -id ${Wave.1} dcache0|Cache
gui_list_collapse -id ${Wave.1} {dcache0|Vic cache}
gui_list_collapse -id ${Wave.1} {dcache0|memory signals}
gui_list_collapse -id ${Wave.1} retire_buffer
gui_list_collapse -id ${Wave.1} retire_buffer|In/Out
gui_list_collapse -id ${Wave.1} retire_buffer|retire_queue
gui_list_collapse -id ${Wave.1} retire_buffer|retire_queue_next
gui_list_collapse -id ${Wave.1} {retire_buffer|Memory Signals}
gui_list_collapse -id ${Wave.1} {pipeline if signals}
gui_list_collapse -id ${Wave.1} {pipeline id signals}
gui_list_collapse -id ${Wave.1} {pipeline di signals}
gui_list_collapse -id ${Wave.1} {pipeline is signals}
gui_list_collapse -id ${Wave.1} {pipeline ex signals}
gui_list_collapse -id ${Wave.1} {pipeline mem signals}
gui_list_collapse -id ${Wave.1} {pipeline co signals}
gui_list_collapse -id ${Wave.1} {pipeline ret signals}
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
gui_list_set_insertion_bar  -id ${Wave.1} -group {dcache0|Mem Queue}  -position in

gui_marker_move -id ${Wave.1} {C1} 589
gui_view_scroll -id ${Wave.1} -vertical -set 0
gui_show_grid -id ${Wave.1} -enable false
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
#</Session>

