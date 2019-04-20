 
****************************************
Report : resources
Design : pipeline
Version: O-2018.06
Date   : Fri Apr 19 18:58:11 2019
****************************************

Resource Sharing Report for design pipeline in file ../../verilog/pipeline.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r346     | DW01_cmp6    | width=64   |               | eq_563 eq_566        |
| r350     | DW01_sub     | width=64   |               | sub_1618             |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| sub_1618           | DW01_sub         | cla                |                |
| r346               | DW01_cmp6        | rpl                |                |
===============================================================================

 
****************************************
Design : Arch_Map_Table
****************************************

Resource Sharing Report for design Arch_Map_Table in file
        ../../verilog/Arch_Map_Table.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r178     | DW01_cmp6    | width=6    |               | map_cam/eq_18        |
| r180     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G2     |
| r182     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G3     |
| r184     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G4     |
| r186     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G5     |
| r188     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G6     |
| r190     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G7     |
| r192     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G8     |
| r194     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G9     |
| r196     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G10    |
| r198     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G11    |
| r200     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G12    |
| r202     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G13    |
| r204     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G14    |
| r206     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G15    |
| r208     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G16    |
| r210     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G17    |
| r212     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G18    |
| r214     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G19    |
| r216     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G20    |
| r218     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G21    |
| r220     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G22    |
| r222     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G23    |
| r224     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G24    |
| r226     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G25    |
| r228     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G26    |
| r230     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G27    |
| r232     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G28    |
| r234     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G29    |
| r236     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G30    |
| r238     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G31    |
| r240     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G32    |
===============================================================================


No implementations to report
 
****************************************
Design : ROB
****************************************

Resource Sharing Report for design ROB in file ../../verilog/ROB.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r697     | DW01_cmp6    | width=4    |               | eq_147 eq_151 eq_152 |
|          |              |            |               | eq_98                |
| r698     | DW01_cmp6    | width=4    |               | eq_147_I2 eq_151_I2  |
|          |              |            |               | eq_152_I2 eq_98_G2   |
| r699     | DW01_cmp6    | width=4    |               | eq_147_I3 eq_151_I3  |
|          |              |            |               | eq_152_I3 eq_98_G3   |
| r700     | DW01_cmp6    | width=4    |               | eq_147_I4 eq_151_I4  |
|          |              |            |               | eq_152_I4 eq_98_G4   |
| r701     | DW01_cmp6    | width=4    |               | eq_147_I5 eq_151_I5  |
|          |              |            |               | eq_152_I5 eq_98_G5   |
| r702     | DW01_cmp6    | width=4    |               | eq_147_I6 eq_151_I6  |
|          |              |            |               | eq_152_I6 eq_98_G6   |
| r703     | DW01_cmp6    | width=4    |               | eq_147_I7 eq_151_I7  |
|          |              |            |               | eq_152_I7 eq_98_G7   |
| r704     | DW01_cmp6    | width=4    |               | eq_147_I8 eq_151_I8  |
|          |              |            |               | eq_152_I8 eq_98_G8   |
| r705     | DW01_cmp6    | width=4    |               | eq_147_I9 eq_151_I9  |
|          |              |            |               | eq_152_I9 eq_98_G9   |
| r706     | DW01_cmp6    | width=4    |               | eq_147_I10           |
|          |              |            |               | eq_151_I10           |
|          |              |            |               | eq_152_I10 eq_98_G10 |
| r707     | DW01_cmp6    | width=4    |               | eq_147_I11           |
|          |              |            |               | eq_151_I11           |
|          |              |            |               | eq_152_I11 eq_98_G11 |
| r708     | DW01_cmp6    | width=4    |               | eq_147_I12           |
|          |              |            |               | eq_151_I12           |
|          |              |            |               | eq_152_I12 eq_98_G12 |
| r709     | DW01_cmp6    | width=4    |               | eq_147_I13           |
|          |              |            |               | eq_151_I13           |
|          |              |            |               | eq_152_I13 eq_98_G13 |
| r710     | DW01_cmp6    | width=4    |               | eq_147_I14           |
|          |              |            |               | eq_151_I14           |
|          |              |            |               | eq_152_I14 eq_98_G14 |
| r711     | DW01_cmp6    | width=4    |               | eq_147_I15           |
|          |              |            |               | eq_151_I15           |
|          |              |            |               | eq_152_I15 eq_98_G15 |
| r712     | DW01_cmp6    | width=4    |               | eq_147_I16           |
|          |              |            |               | eq_151_I16           |
|          |              |            |               | eq_152_I16 eq_98_G16 |
| r714     | DW01_cmp2    | width=5    |               | gte_111_2 lt_111     |
| r716     | DW01_cmp2    | width=5    |               | gte_111 gte_111_3    |
| r723     | DW01_cmp6    | width=5    |               | eq_219_2 ne_219      |
| r724     | DW01_cmp6    | width=5    |               | eq_240 gt_240        |
| r776     | DW01_add     | width=5    |               | add_109              |
| r778     | DW01_cmp2    | width=5    |               | lte_111              |
| r780     | DW01_cmp6    | width=5    |               | eq_206_2             |
| r782     | DW01_dec     | width=5    |               | sub_206_7            |
| r784     | DW01_sub     | width=6    |               | sub_214_2            |
| r786     | DW01_sub     | width=5    |               | sub_214_4            |
| r792     | DW01_sub     | width=5    |               | sub_240              |
| r800     | DW01_sub     | width=5    |               | sub_1_root_sub_240_5 |
| r802     | DW01_cmp6    | width=6    |               | robcam/eq_18         |
| r804     | DW01_cmp6    | width=6    |               | robcam/eq_18_G2      |
| r806     | DW01_cmp6    | width=6    |               | robcam/eq_18_G3      |
| r808     | DW01_cmp6    | width=6    |               | robcam/eq_18_G4      |
| r810     | DW01_cmp6    | width=6    |               | robcam/eq_18_G5      |
| r812     | DW01_cmp6    | width=6    |               | robcam/eq_18_G6      |
| r814     | DW01_cmp6    | width=6    |               | robcam/eq_18_G7      |
| r816     | DW01_cmp6    | width=6    |               | robcam/eq_18_G8      |
| r818     | DW01_cmp6    | width=6    |               | robcam/eq_18_G9      |
| r820     | DW01_cmp6    | width=6    |               | robcam/eq_18_G10     |
| r822     | DW01_cmp6    | width=6    |               | robcam/eq_18_G11     |
| r824     | DW01_cmp6    | width=6    |               | robcam/eq_18_G12     |
| r826     | DW01_cmp6    | width=6    |               | robcam/eq_18_G13     |
| r828     | DW01_cmp6    | width=6    |               | robcam/eq_18_G14     |
| r830     | DW01_cmp6    | width=6    |               | robcam/eq_18_G15     |
| r832     | DW01_cmp6    | width=6    |               | robcam/eq_18_G16     |
| r940     | DW01_add     | width=5    |               | add_1_root_sub_0_root_sub_214_6 |
| r942     | DW01_sub     | width=5    |               | sub_0_root_sub_0_root_sub_214_6 |
| r1053    | DW01_sub     | width=5    |               | sub_1_root_add_240   |
| r1055    | DW01_inc     | width=5    |               | add_0_root_add_240   |
| r1057    | DW01_sub     | width=5    |               | sub_240_3            |
===============================================================================


No implementations to report

No resource sharing information to report.
 
****************************************
Design : CDB
****************************************

No implementations to report

No resource sharing information to report.
 
****************************************
Design : psel_generic
****************************************

No implementations to report
 
****************************************
Design : mem_stage
****************************************

Resource Sharing Report for design mem_stage in file ../../verilog/mem_stage.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r55      | DW01_cmp6    | width=4    |               | eq_53_2 ne_50        |
===============================================================================


No implementations to report
 
****************************************
Design : ex_stage
****************************************

Resource Sharing Report for design ex_stage in file ../../verilog/ex_stage.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r231     | DW_rash      | A_width=64 |               | alu_0/srl_51         |
|          |              | SH_width=6 |               | alu_0/srl_53         |
| r235     | DW01_cmp6    | width=64   |               | alu_0/eq_57          |
|          |              |            |               | alu_0/lt_36_C59      |
|          |              |            |               | alu_0/lt_36_C60      |
|          |              |            |               | alu_0/lt_56          |
|          |              |            |               | alu_0/lte_58         |
| r239     | DW_rash      | A_width=64 |               | alu_1/srl_51         |
|          |              | SH_width=6 |               | alu_1/srl_53         |
| r243     | DW01_cmp6    | width=64   |               | alu_1/eq_57          |
|          |              |            |               | alu_1/lt_36_C59      |
|          |              |            |               | alu_1/lt_36_C60      |
|          |              |            |               | alu_1/lt_56          |
|          |              |            |               | alu_1/lte_58         |
| r247     | DW_rash      | A_width=64 |               | alu_ls/srl_51        |
|          |              | SH_width=6 |               | alu_ls/srl_53        |
| r251     | DW01_cmp6    | width=64   |               | alu_ls/eq_57         |
|          |              |            |               | alu_ls/lt_36_C59     |
|          |              |            |               | alu_ls/lt_36_C60     |
|          |              |            |               | alu_ls/lt_56         |
|          |              |            |               | alu_ls/lte_58        |
| r255     | DW_rash      | A_width=64 |               | alu_st/srl_51        |
|          |              | SH_width=6 |               | alu_st/srl_53        |
| r259     | DW01_cmp6    | width=64   |               | alu_st/eq_57         |
|          |              |            |               | alu_st/lt_36_C59     |
|          |              |            |               | alu_st/lt_36_C60     |
|          |              |            |               | alu_st/lt_56         |
|          |              |            |               | alu_st/lte_58        |
| r271     | DW_rash      | A_width=64 |               | alu_branch/srl_51    |
|          |              | SH_width=6 |               | alu_branch/srl_53    |
| r275     | DW01_cmp6    | width=64   |               | alu_branch/eq_57     |
|          |              |            |               | alu_branch/lt_36_C59 |
|          |              |            |               | alu_branch/lt_36_C60 |
|          |              |            |               | alu_branch/lt_56     |
|          |              |            |               | alu_branch/lte_58    |
| r316     | DW01_add     | width=64   |               | alu_0/add_43         |
| r318     | DW01_sub     | width=64   |               | alu_0/sub_44         |
| r320     | DW01_ash     | A_width=64 |               | alu_0/sll_52         |
|          |              | SH_width=6 |               |                      |
| r322     | DW01_sub     | width=8    |               | alu_0/sub_53         |
| r324     | DW01_ash     | A_width=64 |               | alu_0/sll_53         |
|          |              | SH_width=32 |              |                      |
| r326     | DW01_cmp6    | width=64   |               | alu_0/eq_60          |
| r328     | DW01_add     | width=64   |               | alu_1/add_43         |
| r330     | DW01_sub     | width=64   |               | alu_1/sub_44         |
| r332     | DW01_ash     | A_width=64 |               | alu_1/sll_52         |
|          |              | SH_width=6 |               |                      |
| r334     | DW01_sub     | width=8    |               | alu_1/sub_53         |
| r336     | DW01_ash     | A_width=64 |               | alu_1/sll_53         |
|          |              | SH_width=32 |              |                      |
| r338     | DW01_cmp6    | width=64   |               | alu_1/eq_60          |
| r340     | DW01_add     | width=64   |               | alu_ls/add_43        |
| r342     | DW01_sub     | width=64   |               | alu_ls/sub_44        |
| r344     | DW01_ash     | A_width=64 |               | alu_ls/sll_52        |
|          |              | SH_width=6 |               |                      |
| r346     | DW01_sub     | width=8    |               | alu_ls/sub_53        |
| r348     | DW01_ash     | A_width=64 |               | alu_ls/sll_53        |
|          |              | SH_width=32 |              |                      |
| r350     | DW01_cmp6    | width=64   |               | alu_ls/eq_60         |
| r352     | DW01_add     | width=64   |               | alu_st/add_43        |
| r354     | DW01_sub     | width=64   |               | alu_st/sub_44        |
| r356     | DW01_ash     | A_width=64 |               | alu_st/sll_52        |
|          |              | SH_width=6 |               |                      |
| r358     | DW01_sub     | width=8    |               | alu_st/sub_53        |
| r360     | DW01_ash     | A_width=64 |               | alu_st/sll_53        |
|          |              | SH_width=32 |              |                      |
| r362     | DW01_cmp6    | width=64   |               | alu_st/eq_60         |
| r364     | DW01_add     | width=64   |               | mult0/mstage[0]/add_20 |
| r368     | DW01_add     | width=64   |               | mult0/mstage[1]/add_20 |
| r372     | DW01_add     | width=64   |               | mult0/mstage[2]/add_20 |
| r376     | DW01_add     | width=64   |               | mult0/mstage[3]/add_20 |
| r380     | DW01_add     | width=64   |               | alu_branch/add_43    |
| r382     | DW01_sub     | width=64   |               | alu_branch/sub_44    |
| r384     | DW01_ash     | A_width=64 |               | alu_branch/sll_52    |
|          |              | SH_width=6 |               |                      |
| r386     | DW01_sub     | width=8    |               | alu_branch/sub_53    |
| r388     | DW01_ash     | A_width=64 |               | alu_branch/sll_53    |
|          |              | SH_width=32 |              |                      |
| r390     | DW01_cmp6    | width=64   |               | alu_branch/eq_60     |
| r492     | DW02_mult    | A_width=16 |               | mult0/mstage[3]/mult_22 |
        |              | B_width=64 |               |                      |
| r594     | DW02_mult    | A_width=16 |               | mult0/mstage[2]/mult_22 |
        |              | B_width=64 |               |                      |
| r696     | DW02_mult    | A_width=16 |               | mult0/mstage[1]/mult_22 |
        |              | B_width=64 |               |                      |
| r798     | DW02_mult    | A_width=16 |               | mult0/mstage[0]/mult_22 |
        |              | B_width=64 |               |                      |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r243               | DW01_cmp6        | rpl                |                |
| r251               | DW01_cmp6        | rpl                |                |
| r259               | DW01_cmp6        | rpl                |                |
| r275               | DW01_cmp6        | rpl                |                |
| r235               | DW01_cmp6        | rpl                |                |
| mult0/mstage[1]/add_20                |                    |                |
|                    | DW01_add         | cla                |                |
| mult0/mstage[2]/add_20                |                    |                |
|                    | DW01_add         | cla                |                |
| mult0/mstage[3]/add_20                |                    |                |
|                    | DW01_add         | cla                |                |
| alu_1/add_43       | DW01_add         | cla                |                |
| alu_ls/add_43      | DW01_add         | cla                |                |
| alu_st/add_43      | DW01_add         | cla                |                |
| alu_branch/add_43  | DW01_add         | cla                |                |
| alu_1/sub_44       | DW01_sub         | cla                |                |
| alu_ls/sub_44      | DW01_sub         | cla                |                |
| alu_st/sub_44      | DW01_sub         | cla                |                |
| alu_branch/sub_44  | DW01_sub         | cla                |                |
| alu_0/add_43       | DW01_add         | cla                |                |
| alu_0/sub_44       | DW01_sub         | cla                |                |
| mult0/mstage[3]/mult_22               |                    |                |
|                    | DW02_mult        | csa                |                |
| mult0/mstage[2]/mult_22               |                    |                |
|                    | DW02_mult        | csa                |                |
| mult0/mstage[1]/mult_22               |                    |                |
|                    | DW02_mult        | csa                |                |
| mult0/mstage[0]/mult_22               |                    |                |
|                    | DW02_mult        | csa                |                |
| r231               | DW_rash          | mx2                |                |
| r239               | DW_rash          | mx2                |                |
| r247               | DW_rash          | mx2                |                |
| r255               | DW_rash          | mx2                |                |
| r271               | DW_rash          | mx2                |                |
| alu_0/sll_52       | DW01_ash         | mx2                |                |
| alu_0/eq_60        | DW01_cmp6        | rpl                |                |
| alu_1/sll_52       | DW01_ash         | mx2                |                |
| alu_1/eq_60        | DW01_cmp6        | rpl                |                |
| alu_ls/sll_52      | DW01_ash         | mx2                |                |
| alu_ls/eq_60       | DW01_cmp6        | rpl                |                |
| alu_st/sll_52      | DW01_ash         | mx2                |                |
| alu_st/eq_60       | DW01_cmp6        | rpl                |                |
| alu_branch/sll_52  | DW01_ash         | mx2                |                |
| alu_branch/eq_60   | DW01_cmp6        | rpl                |                |
===============================================================================

 
****************************************
Design : ex_stage_DW02_mult_0
****************************************

Resource Sharing Report for design DW02_mult_A_width16_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=78   |               | FS_1                 |
===============================================================================

 
****************************************
Design : ex_stage_DW02_mult_1
****************************************

Resource Sharing Report for design DW02_mult_A_width16_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=78   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : ex_stage_DW02_mult_2
****************************************

Resource Sharing Report for design DW02_mult_A_width16_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=78   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : ex_stage_DW02_mult_3
****************************************

Resource Sharing Report for design DW02_mult_A_width16_B_width64

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r58      | DW01_add     | width=78   |               | FS_1                 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_1               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : phys_regfile
****************************************

Resource Sharing Report for design phys_regfile in file
        ../../verilog/phys_regfile.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r1357    | DW01_cmp6    | width=6    |               | eq_33_2              |
| r1359    | DW01_cmp6    | width=6    |               | eq_33_2_G2_G1        |
| r1361    | DW01_cmp6    | width=6    |               | eq_33_2_G2           |
| r1363    | DW01_cmp6    | width=6    |               | eq_33_2_G2_G2        |
| r1365    | DW01_cmp6    | width=6    |               | eq_33_2_G3           |
| r1367    | DW01_cmp6    | width=6    |               | eq_33_2_G2_G3        |
| r1369    | DW01_cmp6    | width=6    |               | eq_33_2_G4           |
| r1371    | DW01_cmp6    | width=6    |               | eq_33_2_G2_G4        |
| r1373    | DW01_cmp6    | width=6    |               | eq_33_2_G5           |
| r1375    | DW01_cmp6    | width=6    |               | eq_33_2_G2_G5        |
| r1377    | DW01_cmp6    | width=6    |               | eq_33_2_G6           |
| r1379    | DW01_cmp6    | width=6    |               | eq_33_2_G2_G6        |
===============================================================================


No implementations to report
 
****************************************
Design : RS
****************************************

Resource Sharing Report for design RS in file ../../verilog/RS.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r587     | DW01_cmp6    | width=7    |               | eq_215               |
| r589     | DW01_cmp6    | width=7    |               | eq_217               |
| r597     | DW01_dec     | width=16   |               | genblk5[0].genblk1[0].encode_issue/sub_9 |
| r599     | DW01_dec     | width=16   |               | genblk5[0].genblk1[1].encode_issue/sub_9 |
| r601     | DW01_dec     | width=16   |               | genblk5[1].genblk1[0].encode_issue/sub_9 |
| r603     | DW01_dec     | width=16   |               | genblk5[2].genblk1[0].encode_issue/sub_9 |
| r605     | DW01_dec     | width=16   |               | genblk5[3].genblk1[0].encode_issue/sub_9 |
| r607     | DW01_dec     | width=16   |               | genblk5[4].genblk1[0].encode_issue/sub_9 |
| r609     | DW01_dec     | width=16   |               | genblk7[0].encode_dispatch/sub_9 |
| r611     | DW01_cmp6    | width=6    |               | rscam/eq_18          |
| r613     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G1    |
| r615     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2       |
| r617     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G2    |
| r619     | DW01_cmp6    | width=6    |               | rscam/eq_18_G3       |
| r621     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G3    |
| r623     | DW01_cmp6    | width=6    |               | rscam/eq_18_G4       |
| r625     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G4    |
| r627     | DW01_cmp6    | width=6    |               | rscam/eq_18_G5       |
| r629     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G5    |
| r631     | DW01_cmp6    | width=6    |               | rscam/eq_18_G6       |
| r633     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G6    |
| r635     | DW01_cmp6    | width=6    |               | rscam/eq_18_G7       |
| r637     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G7    |
| r639     | DW01_cmp6    | width=6    |               | rscam/eq_18_G8       |
| r641     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G8    |
| r643     | DW01_cmp6    | width=6    |               | rscam/eq_18_G9       |
| r645     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G9    |
| r647     | DW01_cmp6    | width=6    |               | rscam/eq_18_G10      |
| r649     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G10   |
| r651     | DW01_cmp6    | width=6    |               | rscam/eq_18_G11      |
| r653     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G11   |
| r655     | DW01_cmp6    | width=6    |               | rscam/eq_18_G12      |
| r657     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G12   |
| r659     | DW01_cmp6    | width=6    |               | rscam/eq_18_G13      |
| r661     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G13   |
| r663     | DW01_cmp6    | width=6    |               | rscam/eq_18_G14      |
| r665     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G14   |
| r667     | DW01_cmp6    | width=6    |               | rscam/eq_18_G15      |
| r669     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G15   |
| r671     | DW01_cmp6    | width=6    |               | rscam/eq_18_G16      |
| r673     | DW01_cmp6    | width=6    |               | rscam/eq_18_G2_G16   |
| r788     | DW01_add     | width=5    |               | add_2_root_add_0_root_add_237_3 |
| r790     | DW01_add     | width=5    |               | add_1_root_add_0_root_add_237_3 |
| r792     | DW01_add     | width=5    |               | add_0_root_add_0_root_add_237_3 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| genblk5[3].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk5[4].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk5[1].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk7[0].encode_dispatch/sub_9      |                    |                |
|                    | DW01_dec         | cla                |                |
| genblk5[0].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk5[0].genblk1[1].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk5[2].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
===============================================================================

 
****************************************
Design : Free_List
****************************************

Resource Sharing Report for design Free_List in file ../../verilog/Free_List.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r261     | DW01_inc     | width=7    |               | add_101 add_127      |
| r268     | DW01_dec     | width=8    |               | sub_71               |
| r270     | DW01_dec     | width=8    |               | sub_115              |
| r272     | DW01_sub     | width=7    |               | sub_139_aco          |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r261               | DW01_inc         | rpl                |                |
===============================================================================

 
****************************************
Design : Map_Table
****************************************

Resource Sharing Report for design Map_Table in file ../../verilog/Map_Table.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r190     | DW01_cmp6    | width=6    |               | map_cam/eq_18        |
| r192     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G2     |
| r194     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G3     |
| r196     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G4     |
| r198     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G5     |
| r200     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G6     |
| r202     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G7     |
| r204     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G8     |
| r206     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G9     |
| r208     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G10    |
| r210     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G11    |
| r212     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G12    |
| r214     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G13    |
| r216     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G14    |
| r218     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G15    |
| r220     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G16    |
| r222     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G17    |
| r224     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G18    |
| r226     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G19    |
| r228     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G20    |
| r230     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G21    |
| r232     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G22    |
| r234     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G23    |
| r236     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G24    |
| r238     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G25    |
| r240     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G26    |
| r242     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G27    |
| r244     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G28    |
| r246     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G29    |
| r248     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G30    |
| r250     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G31    |
| r252     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G32    |
===============================================================================


No implementations to report

No resource sharing information to report.
 
****************************************
Design : id_stage
****************************************

No implementations to report
 
****************************************
Design : IQ
****************************************

Resource Sharing Report for design IQ in file ../../verilog/IQ.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r82      | DW01_inc     | width=5    |               | add_74               |
| r84      | DW01_sub     | width=5    |               | sub_132_aco          |
| r86      | DW01_cmp2    | width=5    |               | gte_133              |
===============================================================================


No implementations to report
 
****************************************
Design : BP2
****************************************

Resource Sharing Report for design BP2 in file ../../verilog/BP2.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r310     | DW01_add     | width=32   |               | add_257 add_281      |
|          |              |            |               | add_300 add_320      |
|          |              |            |               | add_334 ras0/add_57  |
|          |              |            |               | ras0/add_60          |
| r311     | DW01_inc     | width=4    |               | add_274 add_280      |
|          |              |            |               | add_293 add_299      |
|          |              |            |               | add_313 add_319      |
|          |              |            |               | add_327 add_333      |
| r313     | DW01_cmp6    | width=6    |               | ras0/ne_36           |
|          |              |            |               | ras0/ne_67           |
| r326     | DW01_cmp6    | width=10   |               | btb0/eq_86           |
| r328     | DW01_dec     | width=7    |               | ras0/sub_57          |
| r330     | DW01_inc     | width=6    |               | ras0/add_61          |
| r332     | DW01_cmp6    | width=6    |               | ras0/eq_62           |
| r334     | DW01_inc     | width=6    |               | ras0/add_63          |
| r336     | DW01_sub     | width=6    |               | ras0/sub_68_aco      |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r310               | DW01_add         | cla                |                |
===============================================================================

 
****************************************
Design : if_stage
****************************************

Resource Sharing Report for design if_stage in file ../../verilog/if_stage.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r56      | DW01_add     | width=64   |               | add_56               |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_56             | DW01_add         | cla                |                |
===============================================================================

 
****************************************
Design : LQ
****************************************

Resource Sharing Report for design LQ in file ../../verilog/LQ.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r122     | DW01_inc     | width=4    |               | add_29 add_46        |
| r158     | DW01_cmp6    | width=4    |               | eq_29                |
| r160     | DW01_cmp6    | width=4    |               | eq_33                |
| r162     | DW01_cmp6    | width=4    |               | eq_33_G2             |
| r164     | DW01_cmp6    | width=4    |               | eq_33_G3             |
| r166     | DW01_cmp6    | width=4    |               | eq_33_G4             |
| r168     | DW01_cmp6    | width=4    |               | eq_33_G5             |
| r170     | DW01_cmp6    | width=4    |               | eq_33_G6             |
| r172     | DW01_cmp6    | width=4    |               | eq_33_G7             |
| r174     | DW01_cmp6    | width=4    |               | eq_33_G8             |
| r176     | DW01_cmp6    | width=4    |               | eq_33_G9             |
| r178     | DW01_cmp6    | width=4    |               | eq_33_G10            |
| r180     | DW01_cmp6    | width=4    |               | eq_33_G11            |
| r182     | DW01_cmp6    | width=4    |               | eq_33_G12            |
| r184     | DW01_cmp6    | width=4    |               | eq_33_G13            |
| r186     | DW01_cmp6    | width=4    |               | eq_33_G14            |
| r188     | DW01_cmp6    | width=4    |               | eq_33_G15            |
| r190     | DW01_inc     | width=4    |               | add_51               |
===============================================================================


No implementations to report
 
****************************************
Design : SQ
****************************************

Resource Sharing Report for design SQ in file ../../verilog/SQ.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r715     | DW01_inc     | width=4    |               | add_104 add_156      |
| r717     | DW01_cmp2    | width=4    |               | lte_116 lte_116_G10  |
|          |              |            |               | lte_116_G11          |
|          |              |            |               | lte_116_G12          |
|          |              |            |               | lte_116_G13          |
|          |              |            |               | lte_116_G14          |
|          |              |            |               | lte_116_G15          |
|          |              |            |               | lte_116_G16          |
|          |              |            |               | lte_116_G2           |
|          |              |            |               | lte_116_G3           |
|          |              |            |               | lte_116_G4           |
|          |              |            |               | lte_116_G5           |
|          |              |            |               | lte_116_G6           |
|          |              |            |               | lte_116_G7           |
|          |              |            |               | lte_116_G8           |
|          |              |            |               | lte_116_G9 lte_169   |
|          |              |            |               | lte_169_I10          |
|          |              |            |               | lte_169_I11          |
|          |              |            |               | lte_169_I12          |
|          |              |            |               | lte_169_I13          |
|          |              |            |               | lte_169_I14          |
|          |              |            |               | lte_169_I15          |
|          |              |            |               | lte_169_I16          |
|          |              |            |               | lte_169_I2           |
|          |              |            |               | lte_169_I3           |
|          |              |            |               | lte_169_I4           |
|          |              |            |               | lte_169_I5           |
|          |              |            |               | lte_169_I6           |
|          |              |            |               | lte_169_I7           |
|          |              |            |               | lte_169_I8           |
|          |              |            |               | lte_169_I9           |
| r718     | DW01_cmp2    | width=4    |               | lte_116_2 lte_116_3  |
|          |              |            |               | lte_169_2 lte_169_3  |
| r719     | DW01_cmp2    | width=4    |               | lt_116_2 lt_116_3    |
|          |              |            |               | lt_169_2 lt_169_3    |
| r720     | DW01_cmp2    | width=4    |               | lt_116 lt_169        |
| r721     | DW01_cmp2    | width=4    |               | lte_116_2_G2         |
|          |              |            |               | lte_116_3_G2         |
|          |              |            |               | lte_169_2_I2         |
|          |              |            |               | lte_169_3_I2         |
| r722     | DW01_cmp2    | width=4    |               | lt_116_2_G2          |
|          |              |            |               | lt_116_3_G2          |
|          |              |            |               | lt_169_2_I2          |
|          |              |            |               | lt_169_3_I2          |
| r723     | DW01_cmp2    | width=4    |               | lt_116_G2 lt_169_I2  |
| r724     | DW01_cmp2    | width=4    |               | lte_116_2_G3         |
|          |              |            |               | lte_116_3_G3         |
|          |              |            |               | lte_169_2_I3         |
|          |              |            |               | lte_169_3_I3         |
| r725     | DW01_cmp2    | width=4    |               | lt_116_2_G3          |
|          |              |            |               | lt_116_3_G3          |
|          |              |            |               | lt_169_2_I3          |
|          |              |            |               | lt_169_3_I3          |
| r726     | DW01_cmp2    | width=4    |               | lt_116_G3 lt_169_I3  |
| r727     | DW01_cmp2    | width=4    |               | lte_116_2_G4         |
|          |              |            |               | lte_116_3_G4         |
|          |              |            |               | lte_169_2_I4         |
|          |              |            |               | lte_169_3_I4         |
| r728     | DW01_cmp2    | width=4    |               | lt_116_2_G4          |
|          |              |            |               | lt_116_3_G4          |
|          |              |            |               | lt_169_2_I4          |
|          |              |            |               | lt_169_3_I4          |
| r729     | DW01_cmp2    | width=4    |               | lt_116_G4 lt_169_I4  |
| r730     | DW01_cmp2    | width=4    |               | lte_116_2_G5         |
|          |              |            |               | lte_116_3_G5         |
|          |              |            |               | lte_169_2_I5         |
|          |              |            |               | lte_169_3_I5         |
| r731     | DW01_cmp2    | width=4    |               | lt_116_2_G5          |
|          |              |            |               | lt_116_3_G5          |
|          |              |            |               | lt_169_2_I5          |
|          |              |            |               | lt_169_3_I5          |
| r732     | DW01_cmp2    | width=4    |               | lt_116_G5 lt_169_I5  |
| r733     | DW01_cmp2    | width=4    |               | lte_116_2_G6         |
|          |              |            |               | lte_116_3_G6         |
|          |              |            |               | lte_169_2_I6         |
|          |              |            |               | lte_169_3_I6         |
| r734     | DW01_cmp2    | width=4    |               | lt_116_2_G6          |
|          |              |            |               | lt_116_3_G6          |
|          |              |            |               | lt_169_2_I6          |
|          |              |            |               | lt_169_3_I6          |
| r735     | DW01_cmp2    | width=4    |               | lt_116_G6 lt_169_I6  |
| r736     | DW01_cmp2    | width=4    |               | lte_116_2_G7         |
|          |              |            |               | lte_116_3_G7         |
|          |              |            |               | lte_169_2_I7         |
|          |              |            |               | lte_169_3_I7         |
| r737     | DW01_cmp2    | width=4    |               | lt_116_2_G7          |
|          |              |            |               | lt_116_3_G7          |
|          |              |            |               | lt_169_2_I7          |
|          |              |            |               | lt_169_3_I7          |
| r738     | DW01_cmp2    | width=4    |               | lt_116_G7 lt_169_I7  |
| r739     | DW01_cmp2    | width=4    |               | lte_116_2_G8         |
|          |              |            |               | lte_116_3_G8         |
|          |              |            |               | lte_169_2_I8         |
|          |              |            |               | lte_169_3_I8         |
| r740     | DW01_cmp2    | width=4    |               | lt_116_2_G8          |
|          |              |            |               | lt_116_3_G8          |
|          |              |            |               | lt_169_2_I8          |
|          |              |            |               | lt_169_3_I8          |
| r741     | DW01_cmp2    | width=4    |               | lt_116_G8 lt_169_I8  |
| r742     | DW01_cmp2    | width=4    |               | lte_116_2_G9         |
|          |              |            |               | lte_116_3_G9         |
|          |              |            |               | lte_169_2_I9         |
|          |              |            |               | lte_169_3_I9         |
| r743     | DW01_cmp2    | width=4    |               | lt_116_2_G9          |
|          |              |            |               | lt_116_3_G9          |
|          |              |            |               | lt_169_2_I9          |
|          |              |            |               | lt_169_3_I9          |
| r744     | DW01_cmp2    | width=4    |               | lt_116_G9 lt_169_I9  |
| r745     | DW01_cmp2    | width=4    |               | lte_116_2_G10        |
|          |              |            |               | lte_116_3_G10        |
|          |              |            |               | lte_169_2_I10        |
|          |              |            |               | lte_169_3_I10        |
| r746     | DW01_cmp2    | width=4    |               | lt_116_2_G10         |
|          |              |            |               | lt_116_3_G10         |
|          |              |            |               | lt_169_2_I10         |
|          |              |            |               | lt_169_3_I10         |
| r747     | DW01_cmp2    | width=4    |               | lt_116_G10           |
|          |              |            |               | lt_169_I10           |
| r748     | DW01_cmp2    | width=4    |               | lte_116_2_G11        |
|          |              |            |               | lte_116_3_G11        |
|          |              |            |               | lte_169_2_I11        |
|          |              |            |               | lte_169_3_I11        |
| r749     | DW01_cmp2    | width=4    |               | lt_116_2_G11         |
|          |              |            |               | lt_116_3_G11         |
|          |              |            |               | lt_169_2_I11         |
|          |              |            |               | lt_169_3_I11         |
| r750     | DW01_cmp2    | width=4    |               | lt_116_G11           |
|          |              |            |               | lt_169_I11           |
| r751     | DW01_cmp2    | width=4    |               | lte_116_2_G12        |
|          |              |            |               | lte_116_3_G12        |
|          |              |            |               | lte_169_2_I12        |
|          |              |            |               | lte_169_3_I12        |
| r752     | DW01_cmp2    | width=4    |               | lt_116_2_G12         |
|          |              |            |               | lt_116_3_G12         |
|          |              |            |               | lt_169_2_I12         |
|          |              |            |               | lt_169_3_I12         |
| r753     | DW01_cmp2    | width=4    |               | lt_116_G12           |
|          |              |            |               | lt_169_I12           |
| r754     | DW01_cmp2    | width=4    |               | lte_116_2_G13        |
|          |              |            |               | lte_116_3_G13        |
|          |              |            |               | lte_169_2_I13        |
|          |              |            |               | lte_169_3_I13        |
| r755     | DW01_cmp2    | width=4    |               | lt_116_2_G13         |
|          |              |            |               | lt_116_3_G13         |
|          |              |            |               | lt_169_2_I13         |
|          |              |            |               | lt_169_3_I13         |
| r756     | DW01_cmp2    | width=4    |               | lt_116_G13           |
|          |              |            |               | lt_169_I13           |
| r757     | DW01_cmp2    | width=4    |               | lte_116_2_G14        |
|          |              |            |               | lte_116_3_G14        |
|          |              |            |               | lte_169_2_I14        |
|          |              |            |               | lte_169_3_I14        |
| r758     | DW01_cmp2    | width=4    |               | lt_116_2_G14         |
|          |              |            |               | lt_116_3_G14         |
|          |              |            |               | lt_169_2_I14         |
|          |              |            |               | lt_169_3_I14         |
| r759     | DW01_cmp2    | width=4    |               | lt_116_G14           |
|          |              |            |               | lt_169_I14           |
| r760     | DW01_cmp2    | width=4    |               | lte_116_2_G15        |
|          |              |            |               | lte_116_3_G15        |
|          |              |            |               | lte_169_2_I15        |
|          |              |            |               | lte_169_3_I15        |
| r761     | DW01_cmp2    | width=4    |               | lt_116_2_G15         |
|          |              |            |               | lt_116_3_G15         |
|          |              |            |               | lt_169_2_I15         |
|          |              |            |               | lt_169_3_I15         |
| r762     | DW01_cmp2    | width=4    |               | lt_116_G15           |
|          |              |            |               | lt_169_I15           |
| r763     | DW01_cmp2    | width=4    |               | lte_116_2_G16        |
|          |              |            |               | lte_116_3_G16        |
|          |              |            |               | lte_169_2_I16        |
|          |              |            |               | lte_169_3_I16        |
| r764     | DW01_cmp2    | width=4    |               | lt_116_2_G16         |
|          |              |            |               | lt_116_3_G16         |
|          |              |            |               | lt_169_2_I16         |
|          |              |            |               | lt_169_3_I16         |
| r765     | DW01_cmp2    | width=4    |               | lt_116_G16           |
|          |              |            |               | lt_169_I16           |
| r808     | DW01_cmp6    | width=4    |               | eq_104               |
| r810     | DW01_inc     | width=4    |               | add_138              |
| r812     | DW01_cmp6    | width=4    |               | ne_156               |
| r814     | DW01_inc     | width=4    |               | add_161              |
| r816     | DW01_cmp6    | width=32   |               | eq_169               |
| r818     | DW01_cmp6    | width=32   |               | eq_169_I2            |
| r820     | DW01_cmp6    | width=32   |               | eq_169_I3            |
| r822     | DW01_cmp6    | width=32   |               | eq_169_I4            |
| r824     | DW01_cmp6    | width=32   |               | eq_169_I5            |
| r826     | DW01_cmp6    | width=32   |               | eq_169_I6            |
| r828     | DW01_cmp6    | width=32   |               | eq_169_I7            |
| r830     | DW01_cmp6    | width=32   |               | eq_169_I8            |
| r832     | DW01_cmp6    | width=32   |               | eq_169_I9            |
| r834     | DW01_cmp6    | width=32   |               | eq_169_I10           |
| r836     | DW01_cmp6    | width=32   |               | eq_169_I11           |
| r838     | DW01_cmp6    | width=32   |               | eq_169_I12           |
| r840     | DW01_cmp6    | width=32   |               | eq_169_I13           |
| r842     | DW01_cmp6    | width=32   |               | eq_169_I14           |
| r844     | DW01_cmp6    | width=32   |               | eq_169_I15           |
| r846     | DW01_cmp6    | width=32   |               | eq_169_I16           |
| r848     | DW01_dec     | width=16   |               | enc/sub_9            |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| eq_169_I11         | DW01_cmp6        | rpl                |                |
| eq_169_I5          | DW01_cmp6        | rpl                |                |
| eq_169_I10         | DW01_cmp6        | rpl                |                |
| eq_169_I12         | DW01_cmp6        | rpl                |                |
| eq_169_I9          | DW01_cmp6        | rpl                |                |
| eq_169_I13         | DW01_cmp6        | rpl                |                |
| eq_169_I14         | DW01_cmp6        | rpl                |                |
| eq_169_I15         | DW01_cmp6        | rpl                |                |
| eq_169             | DW01_cmp6        | rpl                |                |
| eq_169_I2          | DW01_cmp6        | rpl                |                |
| eq_169_I3          | DW01_cmp6        | rpl                |                |
| eq_169_I4          | DW01_cmp6        | rpl                |                |
| eq_169_I6          | DW01_cmp6        | rpl                |                |
| eq_169_I7          | DW01_cmp6        | rpl                |                |
| eq_169_I8          | DW01_cmp6        | rpl                |                |
===============================================================================

 
****************************************
Design : icache
****************************************

Resource Sharing Report for design icache in file ../../verilog/icache.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r822     | DW01_add     | width=64   |               | add_164              |
| r824     | DW01_add     | width=64   |               | add_164_G2           |
| r826     | DW01_add     | width=64   |               | add_164_G3           |
| r828     | DW01_add     | width=64   |               | add_164_G4           |
| r830     | DW01_cmp6    | width=64   |               | ne_167               |
| r832     | DW01_cmp2    | width=3    |               | lt_182               |
| r834     | DW01_cmp6    | width=4    |               | eq_194               |
| r836     | DW01_dec     | width=3    |               | sub_197              |
| r838     | DW01_inc     | width=3    |               | add_208              |
| r840     | DW01_dec     | width=3    |               | sub_213              |
| r842     | DW01_cmp2    | width=3    |               | gt_214               |
| r844     | DW01_sub     | width=3    |               | sub_215_aco          |
| r846     | DW01_cmp2    | width=3    |               | gt_217               |
| r848     | DW01_sub     | width=3    |               | sub_218_aco          |
| r850     | DW01_inc     | width=3    |               | add_224              |
| r852     | DW01_cmp2    | width=3    |               | lt_228               |
| r854     | DW01_inc     | width=3    |               | add_231              |
| r856     | DW01_cmp2    | width=3    |               | lt_235               |
| r858     | DW01_inc     | width=3    |               | add_238              |
| r860     | DW01_cmp2    | width=3    |               | lt_235_I2            |
| r862     | DW01_inc     | width=3    |               | add_238_I2           |
| r864     | DW01_cmp2    | width=3    |               | lt_235_I3            |
| r866     | DW01_inc     | width=3    |               | add_238_I3           |
| r868     | DW01_cmp2    | width=3    |               | lt_235_I4            |
| r870     | DW01_inc     | width=3    |               | add_238_I4           |
| r872     | DW01_cmp6    | width=3    |               | memory/eq_169        |
| r874     | DW01_cmp6    | width=10   |               | memory/eq_169_2      |
| r876     | DW01_cmp6    | width=3    |               | memory/eq_169_I2     |
| r878     | DW01_cmp6    | width=10   |               | memory/eq_169_2_I2   |
| r880     | DW01_cmp6    | width=3    |               | memory/eq_169_I3     |
| r882     | DW01_cmp6    | width=10   |               | memory/eq_169_2_I3   |
| r884     | DW01_cmp2    | width=2    |               | memory/gte_210       |
| r886     | DW01_cmp2    | width=2    |               | memory/gte_210_I2_I1 |
| r888     | DW01_inc     | width=2    |               | memory/add_231_I2_I1 |
| r890     | DW01_cmp2    | width=2    |               | memory/gte_261       |
| r892     | DW01_cmp2    | width=2    |               | memory/gte_261_I2_I1 |
| r894     | DW01_cmp2    | width=2    |               | memory/gte_261_I2    |
| r896     | DW01_cmp2    | width=2    |               | memory/gte_261_I2_I2 |
| r898     | DW01_cmp2    | width=2    |               | memory/gte_261_I3    |
| r900     | DW01_cmp2    | width=2    |               | memory/gte_261_I2_I3 |
| r902     | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18 |
| r904     | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G2 |
| r906     | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G3 |
| r908     | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G4 |
| r910     | DW01_dec     | width=4    |               | memory/genblk1[0].rd_enc/sub_9 |
| r912     | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18 |
| r914     | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G2 |
| r916     | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G3 |
| r918     | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G4 |
| r920     | DW01_dec     | width=4    |               | memory/genblk1[1].rd_enc/sub_9 |
| r922     | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18 |
| r924     | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G2 |
| r926     | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G3 |
| r928     | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G4 |
| r930     | DW01_dec     | width=4    |               | memory/genblk1[2].rd_enc/sub_9 |
| r932     | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18 |
| r934     | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G2 |
| r936     | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G3 |
| r938     | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G4 |
| r940     | DW01_dec     | width=4    |               | memory/genblk2[0].wr_enc/sub_9 |
| r942     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18   |
| r944     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G1 |
| r946     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G1 |
| r948     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G1 |
| r950     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G1 |
| r952     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2 |
| r954     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G2 |
| r956     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G2 |
| r958     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G2 |
| r960     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G2 |
| r962     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3 |
| r964     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G3 |
| r966     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G3 |
| r968     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G3 |
| r970     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G3 |
| r972     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4 |
| r974     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G4 |
| r976     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G4 |
| r978     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G4 |
| r980     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G4 |
| r982     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5 |
| r984     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G5 |
| r986     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G5 |
| r988     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G5 |
| r990     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G5 |
| r992     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G6 |
| r994     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G6 |
| r996     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G6 |
| r998     | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G6 |
| r1000    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G6 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| PC_queue_cam/eq_18_G5_G1_G6           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G5_G1_G5           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G5_G1_G4           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G5_G1_G3           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G5_G1_G2           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G5_G1_G1           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| add_164_G4         | DW01_add         | cla                |                |
| PC_queue_cam/eq_18_G2_G1_G6           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G2_G1_G5           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G2_G1_G4           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G2_G1_G3           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G2_G1_G2           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G2_G1_G1           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G3_G1_G6           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G3_G1_G5           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G3_G1_G4           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G3_G1_G3           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G3_G1_G2           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G3_G1_G1           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G4_G1_G6           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G4_G1_G5           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G4_G1_G4           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G4_G1_G3           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G4_G1_G2           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G4_G1_G1           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| add_164_G3         | DW01_add         | cla                |                |
| add_164_G2         | DW01_add         | cla                |                |
| add_164            | DW01_add         | cla                |                |
| ne_167             | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G6                 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G5                 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G4                 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G3                 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18_G2                 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18 | DW01_cmp6        | rpl                |                |
===============================================================================

1
