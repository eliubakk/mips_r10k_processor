# Begin_DVE_Session_Save_Info
# DVE full session
# Saved on Sat Apr 13 18:52:34 2019
# Designs open: 1
#   Sim: dve
# Toplevel windows open: 2
# 	TopLevel.1
# 	TopLevel.2
#   Source.1: _vcs_unit__802112715
#   Wave.1: 119 signals
#   Group count = 12
#   Group Group1 signal count = 5
#   Group Group9 signal count = 3
#   Group Group3 signal count = 8
#   Group Group4 signal count = 2
#   Group RS0 signal count = 49
#   Group Group5 signal count = 5
#   Group Group6 signal count = 18
#   Group Group7 signal count = 8
#   Group Group8 signal count = 12
#   Group Group2 signal count = 9
#   Group Group10 signal count = 0
#   Group Group11 signal count = 0
# End_DVE_Session_Save_Info

# DVE version: N-2017.12-SP2-1_Full64
# DVE build date: Jul 14 2018 20:58:30


#<Session mode="Full" path="/afs/umich.edu/user/a/s/ashvarma/470/final/group10w19/synth/ash.inter.vpd.tcl" type="Debug">

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
gui_show_window -window ${TopLevel.1} -show_state maximized -rect {{1 38} {2560 1378}}

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
set HSPane.1 [gui_create_window -type HSPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 192]
catch { set Hier.1 [gui_share_window -id ${HSPane.1} -type Hier] }
gui_set_window_pref_key -window ${HSPane.1} -key dock_width -value_type integer -value 192
gui_set_window_pref_key -window ${HSPane.1} -key dock_height -value_type integer -value -1
gui_set_window_pref_key -window ${HSPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${HSPane.1} {{left 0} {top 0} {width 191} {height 1095} {dock_state left} {dock_on_new_line true} {child_hier_colhier 140} {child_hier_coltype 100} {child_hier_colpd 0} {child_hier_col1 0} {child_hier_col2 1} {child_hier_col3 -1}}
set DLPane.1 [gui_create_window -type DLPane -parent ${TopLevel.1} -dock_state left -dock_on_new_line true -dock_extent 498]
catch { set Data.1 [gui_share_window -id ${DLPane.1} -type Data] }
gui_set_window_pref_key -window ${DLPane.1} -key dock_width -value_type integer -value 498
gui_set_window_pref_key -window ${DLPane.1} -key dock_height -value_type integer -value 1094
gui_set_window_pref_key -window ${DLPane.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${DLPane.1} {{left 0} {top 0} {width 497} {height 1095} {dock_state left} {dock_on_new_line true} {child_data_colvariable 212} {child_data_colvalue 153} {child_data_coltype 144} {child_data_col1 0} {child_data_col2 1} {child_data_col3 2}}
set Console.1 [gui_create_window -type Console -parent ${TopLevel.1} -dock_state bottom -dock_on_new_line true -dock_extent 171]
gui_set_window_pref_key -window ${Console.1} -key dock_width -value_type integer -value 2559
gui_set_window_pref_key -window ${Console.1} -key dock_height -value_type integer -value 171
gui_set_window_pref_key -window ${Console.1} -key dock_offset -value_type integer -value 0
gui_update_layout -id ${Console.1} {{left 0} {top 0} {width 2559} {height 170} {dock_state bottom} {dock_on_new_line true}}
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
gui_set_env SIMSETUP::SIMARGS {{-ucligui +v2k +vc +define+PIPELINE=1 +memcbk}}
gui_set_env SIMSETUP::SIMEXE {dve}
gui_set_env SIMSETUP::ALLOW_POLL {0}
if { ![gui_is_db_opened -db {dve}] } {
gui_sim_run Ucli -exe dve -args {-ucligui +v2k +vc +define+PIPELINE=1 +memcbk} -dir ../pipeline -nosource
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
gui_load_child_values {testbench}
gui_load_child_values {testbench.pipeline_0}


set _session_group_13 Group1
gui_sg_create "$_session_group_13"
set Group1 "$_session_group_13"

gui_sg_addsignal -group "$_session_group_13" { testbench.pipeline_0.if_id_IR testbench.pipeline_0.if_id_NPC testbench.pipeline_0.if_id_branch_inst testbench.pipeline_0.if_id_enable testbench.pipeline_0.if_id_valid_inst }

set _session_group_14 Group9
gui_sg_create "$_session_group_14"
set Group9 "$_session_group_14"

gui_sg_addsignal -group "$_session_group_14" { testbench.clock_count testbench.clock testbench.reset }

set _session_group_15 Group3
gui_sg_create "$_session_group_15"
set Group3 "$_session_group_15"

gui_sg_addsignal -group "$_session_group_15" { testbench.pipeline_0.id_di_IR testbench.pipeline_0.id_di_NPC testbench.pipeline_0.id_di_branch_inst testbench.pipeline_0.id_di_enable testbench.pipeline_0.id_di_inst_in testbench.pipeline_0.id_di_rega testbench.pipeline_0.id_di_regb testbench.pipeline_0.id_di_valid_inst }

set _session_group_16 Group4
gui_sg_create "$_session_group_16"
set Group4 "$_session_group_16"

gui_sg_addsignal -group "$_session_group_16" { testbench.pipeline_0.di_branch_inst testbench.pipeline_0.di_is_branch_inst }

set _session_group_17 RS0
gui_sg_create "$_session_group_17"
set RS0 "$_session_group_17"

gui_sg_addsignal -group "$_session_group_17" { testbench.pipeline_0.RS0.rs_table {testbench.pipeline_0.RS0.$unit} testbench.pipeline_0.RS0.CAM_en testbench.pipeline_0.RS0.CDB_in testbench.pipeline_0.RS0.FU_BASE_IDX testbench.pipeline_0.RS0.FU_NAME_VAL testbench.pipeline_0.RS0.NUM_OF_FU_TYPE testbench.pipeline_0.RS0.branch_not_taken testbench.pipeline_0.RS0.busy_bits testbench.pipeline_0.RS0.cam_hits testbench.pipeline_0.RS0.cam_table_in testbench.pipeline_0.RS0.cam_tags_in testbench.pipeline_0.RS0.clock testbench.pipeline_0.RS0.di_branch_inst_idx testbench.pipeline_0.RS0.dispatch_gnt testbench.pipeline_0.RS0.dispatch_gnt_bus testbench.pipeline_0.RS0.dispatch_idx testbench.pipeline_0.RS0.dispatch_idx_valid testbench.pipeline_0.RS0.dispatch_reqs testbench.pipeline_0.RS0.dispatch_valid testbench.pipeline_0.RS0.enable testbench.pipeline_0.RS0.free_rows_next {testbench.pipeline_0.RS0.genblk4[0].end_idx} {testbench.pipeline_0.RS0.genblk4[1].end_idx} {testbench.pipeline_0.RS0.genblk4[2].end_idx} {testbench.pipeline_0.RS0.genblk4[3].end_idx} {testbench.pipeline_0.RS0.genblk4[4].end_idx} {testbench.pipeline_0.RS0.genblk5[0].end_idx} {testbench.pipeline_0.RS0.genblk5[1].end_idx} {testbench.pipeline_0.RS0.genblk5[2].end_idx} {testbench.pipeline_0.RS0.genblk5[3].end_idx} {testbench.pipeline_0.RS0.genblk5[4].end_idx} testbench.pipeline_0.RS0.i testbench.pipeline_0.RS0.inst_in testbench.pipeline_0.RS0.issue_gnt_bus testbench.pipeline_0.RS0.issue_gnts testbench.pipeline_0.RS0.issue_idx testbench.pipeline_0.RS0.issue_idx_shifted testbench.pipeline_0.RS0.issue_idx_valid testbench.pipeline_0.RS0.issue_idx_valid_shifted testbench.pipeline_0.RS0.issue_out testbench.pipeline_0.RS0.issue_reqs testbench.pipeline_0.RS0.issue_stall testbench.pipeline_0.RS0.j testbench.pipeline_0.RS0.reset testbench.pipeline_0.RS0.rs_full testbench.pipeline_0.RS0.rs_table_next testbench.pipeline_0.RS0.rs_table_next_out testbench.pipeline_0.RS0.rs_table_out }
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.RS0.FU_BASE_IDX}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.pipeline_0.RS0.FU_BASE_IDX}
gui_set_radix -radix {decimal} -signals {Sim:testbench.pipeline_0.RS0.FU_NAME_VAL}
gui_set_radix -radix {unsigned} -signals {Sim:testbench.pipeline_0.RS0.FU_NAME_VAL}
gui_set_radix -radix {binary} -signals {Sim:testbench.pipeline_0.RS0.NUM_OF_FU_TYPE}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[0].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[0].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[1].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[1].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[2].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[2].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[3].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[3].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[4].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk4[4].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[0].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[0].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[1].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[1].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[2].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[2].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[3].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[3].end_idx}}
gui_set_radix -radix {decimal} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[4].end_idx}}
gui_set_radix -radix {unsigned} -signals {{Sim:testbench.pipeline_0.RS0.genblk5[4].end_idx}}

set _session_group_18 Group5
gui_sg_create "$_session_group_18"
set Group5 "$_session_group_18"

gui_sg_addsignal -group "$_session_group_18" { testbench.pipeline_0.issue_reg testbench.pipeline_0.issue_reg_inst_opcode testbench.pipeline_0.issue_reg_inst_valid_inst testbench.pipeline_0.issue_reg_npc testbench.pipeline_0.issue_reg_tags }

set _session_group_19 Group6
gui_sg_create "$_session_group_19"
set Group6 "$_session_group_19"

gui_sg_addsignal -group "$_session_group_19" { testbench.pipeline_0.ex_co_IR testbench.pipeline_0.ex_co_NPC testbench.pipeline_0.ex_co_alu_result testbench.pipeline_0.ex_co_branch_index testbench.pipeline_0.ex_co_branch_inst testbench.pipeline_0.ex_co_branch_target testbench.pipeline_0.ex_co_dest_reg_idx testbench.pipeline_0.ex_co_done testbench.pipeline_0.ex_co_enable testbench.pipeline_0.ex_co_halt testbench.pipeline_0.ex_co_illegal testbench.pipeline_0.ex_co_rd_mem testbench.pipeline_0.ex_co_rega testbench.pipeline_0.ex_co_rega_st testbench.pipeline_0.ex_co_sq_idx testbench.pipeline_0.ex_co_take_branch testbench.pipeline_0.ex_co_valid_inst testbench.pipeline_0.ex_co_wr_mem }

set _session_group_20 Group7
gui_sg_create "$_session_group_20"
set Group7 "$_session_group_20"

gui_sg_addsignal -group "$_session_group_20" { testbench.pipeline_0.mem_co_IR testbench.pipeline_0.mem_co_NPC testbench.pipeline_0.mem_co_alu_result testbench.pipeline_0.mem_co_dest_reg_idx testbench.pipeline_0.mem_co_enable testbench.pipeline_0.mem_co_halt testbench.pipeline_0.mem_co_illegal testbench.pipeline_0.mem_co_valid_inst }

set _session_group_21 Group8
gui_sg_create "$_session_group_21"
set Group8 "$_session_group_21"

gui_sg_addsignal -group "$_session_group_21" { testbench.pipeline_0.co_ret_IR testbench.pipeline_0.co_ret_NPC testbench.pipeline_0.co_ret_branch_inst testbench.pipeline_0.co_ret_branch_prediction testbench.pipeline_0.co_ret_branch_valid testbench.pipeline_0.co_ret_dest_reg_idx testbench.pipeline_0.co_ret_enable testbench.pipeline_0.co_ret_halt testbench.pipeline_0.co_ret_illegal testbench.pipeline_0.co_ret_result testbench.pipeline_0.co_ret_take_branch testbench.pipeline_0.co_ret_valid_inst }

set _session_group_22 Group2
gui_sg_create "$_session_group_22"
set Group2 "$_session_group_22"

gui_sg_addsignal -group "$_session_group_22" { testbench.pipeline_0.ret_branch_inst testbench.pipeline_0.ret_pred_correct testbench.pipeline_0.retire_inst_busy testbench.pipeline_0.retire_is_store testbench.pipeline_0.retire_reg_NPC testbench.pipeline_0.retire_reg_phys testbench.pipeline_0.retire_reg_wr_data testbench.pipeline_0.retire_reg_wr_en testbench.pipeline_0.retire_reg_wr_idx }

set _session_group_23 Group10
gui_sg_create "$_session_group_23"
set Group10 "$_session_group_23"


set _session_group_24 Group11
gui_sg_create "$_session_group_24"
set Group11 "$_session_group_24"


# Global: Highlighting

# Global: Stack
gui_change_stack_mode -mode list

# Post database loading setting...

# Restore C1 time
gui_set_time -C1_only 3768



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
catch {gui_list_select -id ${Hier.1} {testbench.pipeline_0.RS0}}
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Data 'Data.1'
gui_list_set_filter -id ${Data.1} -list { {Buffer 1} {Input 1} {Others 1} {Linkage 1} {Output 1} {LowPower 1} {Parameter 1} {All 1} {Aggregate 1} {LibBaseMember 1} {Event 1} {Assertion 1} {Constant 1} {Interface 1} {BaseMembers 1} {Signal 1} {$unit 1} {Inout 1} {Variable 1} }
gui_list_set_filter -id ${Data.1} -text {clock}
gui_list_show_data -id ${Data.1} {testbench.pipeline_0.RS0}
gui_view_scroll -id ${Data.1} -vertical -set 0
gui_view_scroll -id ${Data.1} -horizontal -set 0
gui_view_scroll -id ${Hier.1} -vertical -set 0
gui_view_scroll -id ${Hier.1} -horizontal -set 0

# Source 'Source.1'
gui_src_value_annotate -id ${Source.1} -switch false
gui_set_env TOGGLE::VALUEANNOTATE 0
gui_open_source -id ${Source.1}  -replace -active _vcs_unit__802112715 /afs/umich.edu/user/a/s/ashvarma/470/final/group10w19/verilog/pipeline.v
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
gui_wv_zoom_timerange -id ${Wave.1} 3496 4093
gui_list_add_group -id ${Wave.1} -after {New Group} {Group9}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group1}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group3}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group4}
gui_list_add_group -id ${Wave.1} -after {New Group} {RS0}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group5}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group6}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group7}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group8}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group2}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group10}
gui_list_add_group -id ${Wave.1} -after {New Group} {Group11}
gui_list_collapse -id ${Wave.1} RS0
gui_list_expand -id ${Wave.1} testbench.pipeline_0.issue_reg_inst_opcode
gui_list_expand -id ${Wave.1} testbench.pipeline_0.ex_co_IR
gui_list_expand -id ${Wave.1} testbench.pipeline_0.ex_co_enable
gui_list_select -id ${Wave.1} {{testbench.pipeline_0.issue_reg_inst_opcode[5]} }
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
gui_list_set_insertion_bar  -id ${Wave.1} -group RS0  -position in

gui_marker_move -id ${Wave.1} {C1} 3768
gui_view_scroll -id ${Wave.1} -vertical -set 375
gui_show_grid -id ${Wave.1} -enable false
# Restore toplevel window zorder
# The toplevel window could be closed if it has no view/pane
if {[gui_exist_window -window ${TopLevel.1}]} {
	gui_set_active_window -window ${TopLevel.1}
	gui_set_active_window -window ${Source.1}
	gui_set_active_window -window ${HSPane.1}
}
if {[gui_exist_window -window ${TopLevel.2}]} {
	gui_set_active_window -window ${TopLevel.2}
	gui_set_active_window -window ${Wave.1}
}
#</Session>

