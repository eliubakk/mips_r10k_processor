# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Tue Apr 16 02:16:04 2019
# Designs open: 1
#   Sim: dve
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: _vcs_unit__3321579943
#   Wave.1: 105 signals
#   Group count = 3
#   Group Fetch signal count = 35
# End_DVE_Session_Save_Info

# DVE version: N-2017.12-SP2-1_Full64
# DVE build date: Jul 14 2018 20:58:30


#<Session mode="Full" path="/home/heewoo/Desktop/eecs470/FINAL/group10w19/synth/heewoo.inter.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state normal -rect {{8 31} {1870 1042}}

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
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 251} {height 591} {dock_state left} {dock_on_new_line true} {child_hier_colhier 149} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 489]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 489
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 418
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 488} {height 591} {dock_state left} {dock_on_new_line true} {child_data_colvariable 212} {child_data_colvalue 153} {child_data_coltype 144} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 322]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 1535
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 322
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 1862} {height 321} {dock_state bottom} {dock_on_new_line true}}
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
gui_show_window -window ${TopLevel.2} -show_state normal -rect {{7 23} {1926 1039}}

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
gui_update_layout -id ${Wave.1} {{show_state maximized} {dock_state undocked} {dock_on_new_line false} {child_wave_left 558} {child_wave_right 1356} {child_wave_colname 214} {child_wave_colvalue 340} {child_wave_col1 0} {child_wave_col2 1}}

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
gui_set_env SIMSETUP::SIMARGS {{ +v2k +vc +define+PIPELINE=1 +memcbk -ucligui}}
gui_set_env SIMSETUP::SIMEXE {dve}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {dve}] } {
gui_sim_run Ucli -exe dve -args { +v2k +vc +define+PIPELINE=1 +memcbk -ucligui} -dir ../pipeline -nosource
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
gui_load_child_values {testbench.pipeline_0.bp0}
gui_load_child_values {testbench.pipeline_0.if_stage_0}


set _session_group_7 Fetch
gui_sg_create "$_session_group_7"
set Fetch "$_session_group_7"

gui_sg_addsignal -group "$_session_group_7" { testbench.clock_count testbench.pipeline_0.if_NPC_out testbench.pipeline_0.if_IR_out testbench.pipeline_0.if_valid_inst_out testbench.pipeline_0.if1_fetch_NPC_out testbench.pipeline_0.if1_IR_out testbench.pipeline_0.if1_PC_reg testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.if1_branch_inst testbench.pipeline_0.if12_fetch_NPC_out testbench.pipeline_0.if12_IR_out testbench.pipeline_0.if12_PC_reg testbench.pipeline_0.if12_valid_inst_out testbench.pipeline_0.if12_branch_inst testbench.pipeline_0.if2_fetch_NPC_out testbench.pipeline_0.if2_IR_out testbench.pipeline_0.if2_PC_reg testbench.pipeline_0.if2_valid_inst_out testbench.pipeline_0.if2_branch_inst testbench.pipeline_0.if_branch_inst testbench.pipeline_0.branch_not_taken testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if1_valid_inst_out testbench.pipeline_0.rob_retire_out testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_valid_inst testbench.pipeline_0.if_id_inst_out testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.if2_bp_NPC_valid testbench.pipeline_0.if2_bp_NPC testbench.pipeline_0.if_bp_NPC_valid testbench.pipeline_0.if_bp_NPC }
gui_set_radix -radix {decimal} -signals {Sim:testbench.clock_count}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.clock_count}

set _session_group_8 $_session_group_7|
append _session_group_8 if_stage_0
gui_sg_create "$_session_group_8"
set Fetch|if_stage_0 "$_session_group_8"

gui_sg_addsignal -group "$_session_group_8" { testbench.pipeline_0.if_stage_0.Imem_valid testbench.pipeline_0.if_stage_0.next_ready_for_valid testbench.pipeline_0.if_stage_0.if_IR_out testbench.pipeline_0.if_stage_0.clock testbench.pipeline_0.if_stage_0.reset testbench.pipeline_0.if_stage_0.next_PC testbench.pipeline_0.if_stage_0.PC_reg testbench.pipeline_0.if_stage_0.PC_plus_4 testbench.pipeline_0.if_stage_0.if_bp_NPC testbench.pipeline_0.if_stage_0.co_ret_take_branch testbench.pipeline_0.if_stage_0.co_ret_valid_inst testbench.pipeline_0.if_stage_0.if_valid_inst_out testbench.pipeline_0.if_stage_0.if_valid_inst testbench.pipeline_0.if_stage_0.if_PC_reg testbench.pipeline_0.if_stage_0.if_NPC_out testbench.pipeline_0.if_stage_0.co_ret_branch_valid testbench.pipeline_0.if_stage_0.Imem2proc_data testbench.pipeline_0.if_stage_0.proc2Imem_addr testbench.pipeline_0.if_stage_0.if_bp_NPC_valid {testbench.pipeline_0.if_stage_0.$unit} testbench.pipeline_0.if_stage_0.ready_for_valid testbench.pipeline_0.if_stage_0.PC_enable testbench.pipeline_0.if_stage_0.dispatch_en testbench.pipeline_0.if_stage_0.co_ret_target_pc }

gui_sg_move "$_session_group_8" -after "$_session_group_7" -pos 1 

set _session_group_9 $_session_group_7|
append _session_group_9 bp0
gui_sg_create "$_session_group_9"
set Fetch|bp0 "$_session_group_9"

gui_sg_addsignal -group "$_session_group_9" { testbench.pipeline_0.bp0.ras_stack_out testbench.pipeline_0.bp0.next_pc_calc testbench.pipeline_0.bp0.ras_next_pc testbench.pipeline_0.bp0.rt_return_branch testbench.pipeline_0.bp0.next_pc_index_calc testbench.pipeline_0.bp0.btb_write_en testbench.pipeline_0.bp0.bp_read_en testbench.pipeline_0.bp0.btb_valid_out testbench.pipeline_0.bp0.if_cond_branch testbench.pipeline_0.bp0.clock testbench.pipeline_0.bp0.ras_write_en testbench.pipeline_0.bp0.rt_calculated_pc testbench.pipeline_0.bp0.if_pc_in testbench.pipeline_0.bp0.roll_back testbench.pipeline_0.bp0.reset testbench.pipeline_0.bp0.next_pc testbench.pipeline_0.bp0.rt_direct_branch testbench.pipeline_0.bp0.btb_next_pc_valid testbench.pipeline_0.bp0.if_prediction testbench.pipeline_0.bp0.enable testbench.pipeline_0.bp0.rt_pc testbench.pipeline_0.bp0.next_pc_prediction_calc testbench.pipeline_0.bp0.bp_write_en testbench.pipeline_0.bp0.br_idx testbench.pipeline_0.bp0.ras_head_out testbench.pipeline_0.bp0.next_pc_valid_calc testbench.pipeline_0.bp0.if_return_branch testbench.pipeline_0.bp0.rt_branch_taken testbench.pipeline_0.bp0.btb_tag_out testbench.pipeline_0.bp0.pht_out testbench.pipeline_0.bp0.rt_cond_branch testbench.pipeline_0.bp0.if_direct_branch testbench.pipeline_0.bp0.next_br_idx testbench.pipeline_0.bp0.next_pc_valid testbench.pipeline_0.bp0.ras_tail_out testbench.pipeline_0.bp0.btb_target_address_out testbench.pipeline_0.bp0.if_en_branch testbench.pipeline_0.bp0.next_pc_prediction testbench.pipeline_0.bp0.if_prediction_valid testbench.pipeline_0.bp0.btb_read_en testbench.pipeline_0.bp0.rt_branch_index testbench.pipeline_0.bp0.next_pc_index {testbench.pipeline_0.bp0.$unit} testbench.pipeline_0.bp0.btb_next_pc testbench.pipeline_0.bp0.ras_read_en testbench.pipeline_0.bp0.rt_en_branch testbench.pipeline_0.bp0.rt_prediction_correct testbench.pipeline_0.bp0.ras_next_pc_valid }

# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 35628



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
gui_view_scroll -id ${Hier.1} -vertical -set 259
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {if_bp_*}
gui_list_show_data -id ${Data.1} {testbench.pipeline_0}
gui_show_window -window ${Data.1}
catch { gui_list_select -id ${Data.1} {testbench.pipeline_0.if_bp_NPC testbench.pipeline_0.if_bp_NPC_valid }}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 259
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active _vcs_unit__3321579943 /home/heewoo/Desktop/eecs470/FINAL/group10w19/verilog/pipeline.v
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
gui_wv_zoom_timerange -id ${Wave.1} 34992 37429
gui_list_add_group -id ${Wave.1} -after {New Group} {Fetch}
gui_list_add_group -id ${Wave.1}  -after Fetch {Fetch|bp0}
gui_list_add_group -id ${Wave.1} -after Fetch|bp0 {Fetch|if_stage_0}
gui_list_collapse -id ${Wave.1} Fetch|if_stage_0
gui_list_expand -id ${Wave.1} testbench.pipeline_0.if_branch_inst
gui_list_select -id ${Wave.1} {testbench.pipeline_0.bp0.next_pc_calc testbench.pipeline_0.bp0.next_pc_prediction_calc testbench.pipeline_0.bp0.next_pc_valid_calc }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group Fetch  -position in

gui_marker_move -id ${Wave.1} {C1} 35628
gui_view_scroll -id ${Wave.1} -vertical -set 842
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
