 
****************************************
Report : resources
Design : pipeline
Version: O-2018.06
Date   : Sun Apr 21 18:52:17 2019
****************************************

Resource Sharing Report for design pipeline in file ../../verilog/pipeline.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r338     | DW01_cmp6    | width=64   |               | eq_619 eq_622        |
| r342     | DW01_sub     | width=64   |               | sub_1693             |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r338               | DW01_cmp6        | rpl                |                |
| sub_1693           | DW01_sub         | rpl                |                |
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
| r873     | DW01_cmp6    | width=4    |               | eq_102 eq_153 eq_159 |
|          |              |            |               | eq_160               |
| r874     | DW01_cmp6    | width=4    |               | eq_102_2 eq_155      |
| r875     | DW01_cmp6    | width=4    |               | eq_102_G2 eq_153_I2  |
|          |              |            |               | eq_159_I2 eq_160_I2  |
| r876     | DW01_cmp6    | width=4    |               | eq_102_2_G2          |
|          |              |            |               | eq_155_I2            |
| r877     | DW01_cmp6    | width=4    |               | eq_102_G3 eq_153_I3  |
|          |              |            |               | eq_159_I3 eq_160_I3  |
| r878     | DW01_cmp6    | width=4    |               | eq_102_2_G3          |
|          |              |            |               | eq_155_I3            |
| r879     | DW01_cmp6    | width=4    |               | eq_102_G4 eq_153_I4  |
|          |              |            |               | eq_159_I4 eq_160_I4  |
| r880     | DW01_cmp6    | width=4    |               | eq_102_2_G4          |
|          |              |            |               | eq_155_I4            |
| r881     | DW01_cmp6    | width=4    |               | eq_102_G5 eq_153_I5  |
|          |              |            |               | eq_159_I5 eq_160_I5  |
| r882     | DW01_cmp6    | width=4    |               | eq_102_2_G5          |
|          |              |            |               | eq_155_I5            |
| r883     | DW01_cmp6    | width=4    |               | eq_102_G6 eq_153_I6  |
|          |              |            |               | eq_159_I6 eq_160_I6  |
| r884     | DW01_cmp6    | width=4    |               | eq_102_2_G6          |
|          |              |            |               | eq_155_I6            |
| r885     | DW01_cmp6    | width=4    |               | eq_102_G7 eq_153_I7  |
|          |              |            |               | eq_159_I7 eq_160_I7  |
| r886     | DW01_cmp6    | width=4    |               | eq_102_2_G7          |
|          |              |            |               | eq_155_I7            |
| r887     | DW01_cmp6    | width=4    |               | eq_102_G8 eq_153_I8  |
|          |              |            |               | eq_159_I8 eq_160_I8  |
| r888     | DW01_cmp6    | width=4    |               | eq_102_2_G8          |
|          |              |            |               | eq_155_I8            |
| r889     | DW01_cmp6    | width=4    |               | eq_102_G9 eq_153_I9  |
|          |              |            |               | eq_159_I9 eq_160_I9  |
| r890     | DW01_cmp6    | width=4    |               | eq_102_2_G9          |
|          |              |            |               | eq_155_I9            |
| r891     | DW01_cmp6    | width=4    |               | eq_102_G10           |
|          |              |            |               | eq_153_I10           |
|          |              |            |               | eq_159_I10           |
|          |              |            |               | eq_160_I10           |
| r892     | DW01_cmp6    | width=4    |               | eq_102_2_G10         |
|          |              |            |               | eq_155_I10           |
| r893     | DW01_cmp6    | width=4    |               | eq_102_G11           |
|          |              |            |               | eq_153_I11           |
|          |              |            |               | eq_159_I11           |
|          |              |            |               | eq_160_I11           |
| r894     | DW01_cmp6    | width=4    |               | eq_102_2_G11         |
|          |              |            |               | eq_155_I11           |
| r895     | DW01_cmp6    | width=4    |               | eq_102_G12           |
|          |              |            |               | eq_153_I12           |
|          |              |            |               | eq_159_I12           |
|          |              |            |               | eq_160_I12           |
| r896     | DW01_cmp6    | width=4    |               | eq_102_2_G12         |
|          |              |            |               | eq_155_I12           |
| r897     | DW01_cmp6    | width=4    |               | eq_102_G13           |
|          |              |            |               | eq_153_I13           |
|          |              |            |               | eq_159_I13           |
|          |              |            |               | eq_160_I13           |
| r898     | DW01_cmp6    | width=4    |               | eq_102_2_G13         |
|          |              |            |               | eq_155_I13           |
| r899     | DW01_cmp6    | width=4    |               | eq_102_G14           |
|          |              |            |               | eq_153_I14           |
|          |              |            |               | eq_159_I14           |
|          |              |            |               | eq_160_I14           |
| r900     | DW01_cmp6    | width=4    |               | eq_102_2_G14         |
|          |              |            |               | eq_155_I14           |
| r901     | DW01_cmp6    | width=4    |               | eq_102_G15           |
|          |              |            |               | eq_153_I15           |
|          |              |            |               | eq_159_I15           |
|          |              |            |               | eq_160_I15           |
| r902     | DW01_cmp6    | width=4    |               | eq_102_2_G15         |
|          |              |            |               | eq_155_I15           |
| r903     | DW01_cmp6    | width=4    |               | eq_102_G16           |
|          |              |            |               | eq_153_I16           |
|          |              |            |               | eq_159_I16           |
|          |              |            |               | eq_160_I16           |
| r904     | DW01_cmp6    | width=4    |               | eq_102_2_G16         |
|          |              |            |               | eq_155_I16           |
| r906     | DW01_cmp2    | width=5    |               | gte_116_2 lt_116     |
| r908     | DW01_cmp2    | width=5    |               | gte_116 gte_116_3    |
| r915     | DW01_cmp6    | width=5    |               | eq_224_2 ne_224      |
| r916     | DW01_cmp6    | width=5    |               | eq_247 gt_247        |
| r968     | DW01_add     | width=5    |               | add_114              |
| r970     | DW01_cmp2    | width=5    |               | lte_116              |
| r972     | DW01_cmp6    | width=5    |               | eq_211_2             |
| r974     | DW01_dec     | width=5    |               | sub_211_7            |
| r976     | DW01_sub     | width=6    |               | sub_219_2            |
| r978     | DW01_sub     | width=5    |               | sub_219_4            |
| r984     | DW01_sub     | width=5    |               | sub_247              |
| r992     | DW01_sub     | width=5    |               | sub_1_root_sub_247_5 |
| r994     | DW01_cmp6    | width=6    |               | robcam/eq_18         |
| r996     | DW01_cmp6    | width=6    |               | robcam/eq_18_G2      |
| r998     | DW01_cmp6    | width=6    |               | robcam/eq_18_G3      |
| r1000    | DW01_cmp6    | width=6    |               | robcam/eq_18_G4      |
| r1002    | DW01_cmp6    | width=6    |               | robcam/eq_18_G5      |
| r1004    | DW01_cmp6    | width=6    |               | robcam/eq_18_G6      |
| r1006    | DW01_cmp6    | width=6    |               | robcam/eq_18_G7      |
| r1008    | DW01_cmp6    | width=6    |               | robcam/eq_18_G8      |
| r1010    | DW01_cmp6    | width=6    |               | robcam/eq_18_G9      |
| r1012    | DW01_cmp6    | width=6    |               | robcam/eq_18_G10     |
| r1014    | DW01_cmp6    | width=6    |               | robcam/eq_18_G11     |
| r1016    | DW01_cmp6    | width=6    |               | robcam/eq_18_G12     |
| r1018    | DW01_cmp6    | width=6    |               | robcam/eq_18_G13     |
| r1020    | DW01_cmp6    | width=6    |               | robcam/eq_18_G14     |
| r1022    | DW01_cmp6    | width=6    |               | robcam/eq_18_G15     |
| r1024    | DW01_cmp6    | width=6    |               | robcam/eq_18_G16     |
| r1132    | DW01_add     | width=5    |               | add_1_root_sub_0_root_sub_219_6 |
| r1134    | DW01_sub     | width=5    |               | sub_0_root_sub_0_root_sub_219_6 |
| r1245    | DW01_sub     | width=5    |               | sub_1_root_add_247   |
| r1247    | DW01_inc     | width=5    |               | add_0_root_add_247   |
| r1249    | DW01_sub     | width=5    |               | sub_247_3            |
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
| r172     | DW01_cmp2    | width=4    |               | rb0/gte_37           |
| r174     | DW01_cmp2    | width=4    |               | rb0/lt_39            |
| r178     | DW01_cmp2    | width=4    |               | rb0/gt_60            |
| r180     | DW01_sub     | width=4    |               | rb0/sub_61_aco       |
| r298     | DW01_add     | width=4    |               | add_1_root_add_1_root_rb0/add_73_I3_aco |
| r300     | DW01_sub     | width=4    |               | sub_2_root_add_1_root_rb0/add_73_I3_aco |
| r302     | DW01_add     | width=4    |               | add_0_root_add_1_root_rb0/add_73_I3_aco |
===============================================================================


No implementations to report
 
****************************************
Design : dcache
****************************************

Resource Sharing Report for design dcache in file ../../verilog/dcache.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r845     | DW01_dec     | width=4    |               | sub_423 sub_429      |
| r865     | DW01_inc     | width=3    |               | add_575 add_576      |
|          |              |            |               | add_577              |
| r1051    | DW01_cmp2    | width=5    |               | lt_321               |
| r1053    | DW01_cmp2    | width=5    |               | lt_410               |
| r1055    | DW01_cmp6    | width=4    |               | eq_419               |
| r1057    | DW01_dec     | width=3    |               | sub_455              |
| r1059    | DW01_inc     | width=5    |               | add_463              |
| r1061    | DW01_inc     | width=5    |               | add_468              |
| r1063    | DW01_inc     | width=3    |               | add_478              |
| r1065    | DW01_dec     | width=5    |               | sub_481              |
| r1067    | DW01_cmp2    | width=5    |               | gt_482               |
| r1069    | DW01_sub     | width=5    |               | sub_483_aco          |
| r1071    | DW01_cmp2    | width=5    |               | gt_485               |
| r1073    | DW01_sub     | width=5    |               | sub_486_aco          |
| r1083    | DW01_cmp2    | width=5    |               | lt_523               |
| r1085    | DW01_inc     | width=5    |               | add_530              |
| r1087    | DW01_inc     | width=2    |               | add_542_I2_I1        |
| r1089    | DW01_add     | width=64   |               | add_552              |
| r1097    | DW_rash      | A_width=316 |              | srl_575              |
|          |              | SH_width=10 |              |                      |
| r1099    | DW01_sub     | width=3    |               | sub_576              |
| r1101    | DW01_sub     | width=3    |               | sub_577              |
| r1103    | DW01_cmp2    | width=5    |               | lt_583_2             |
| r1105    | DW01_inc     | width=5    |               | add_597              |
| r1107    | DW01_inc     | width=3    |               | add_599              |
| r1109    | DW01_add     | width=64   |               | add_601              |
| r1119    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18       |
| r1121    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G1_G1 |
| r1123    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G1 |
| r1125    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G2_G1 |
| r1127    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G3_G1 |
| r1129    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G3_G1 |
| r1131    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G4_G1 |
| r1133    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G4_G1 |
| r1135    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2    |
| r1137    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G1_G2 |
| r1139    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G2 |
| r1141    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G2_G2 |
| r1143    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G3_G2 |
| r1145    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G3_G2 |
| r1147    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G4_G2 |
| r1149    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G4_G2 |
| r1151    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G3    |
| r1153    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G1_G3 |
| r1155    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G3 |
| r1157    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G2_G3 |
| r1159    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G3_G3 |
| r1161    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G3_G3 |
| r1163    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G4_G3 |
| r1165    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G4_G3 |
| r1167    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G4    |
| r1169    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G1_G4 |
| r1171    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G4 |
| r1173    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G2_G4 |
| r1175    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G3_G4 |
| r1177    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G3_G4 |
| r1179    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G4_G4 |
| r1181    | DW01_cmp6    | width=13   |               | fifo_cam/eq_18_G2_G4_G4 |
| r1183    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18  |
| r1185    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G2 |
| r1187    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G3 |
| r1189    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G4 |
| r1191    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G5 |
| r1193    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G6 |
| r1195    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G7 |
| r1197    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G8 |
| r1199    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G9 |
| r1201    | DW01_cmp6    | width=64   |               | mem_queue_cam/eq_18_G10 |
| r1203    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18 |
| r1205    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18_G2_G1_G1 |
| r1207    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18_G2 |
| r1209    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18_G2_G1_G2 |
| r1211    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18_G3 |
| r1213    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18_G2_G1_G3 |
| r1215    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18_G4 |
| r1217    | DW01_cmp6    | width=64   |               | fetch_addr_cam/eq_18_G2_G1_G4 |
| r1219    | DW01_sub     | width=2    |               | fifo_psel/sub_26     |
| r1221    | DW01_cmp2    | width=2    |               | fifo_psel/gte_29     |
| r1223    | DW01_cmp2    | width=2    |               | fifo_psel/gte_31     |
| r1225    | DW01_cmp2    | width=2    |               | fifo_psel/gte_29_G2  |
| r1227    | DW01_cmp2    | width=2    |               | fifo_psel/gte_31_G2  |
| r1229    | DW01_cmp2    | width=2    |               | fifo_psel/gte_29_G3  |
| r1231    | DW01_cmp2    | width=2    |               | fifo_psel/gte_31_G3  |
| r1233    | DW01_cmp2    | width=2    |               | fifo_psel/gte_29_G4  |
| r1235    | DW01_sub     | width=2    |               | fifo_psel/sub_29_G4  |
| r1237    | DW01_cmp2    | width=2    |               | fifo_psel/gte_31_G4  |
| r1239    | DW01_inc     | width=2    |               | fifo_psel/add_53     |
| r1241    | DW01_dec     | width=4    |               | fifo_sel_enc/sub_9   |
| r1243    | DW01_dec     | width=4    |               | genblk5[0].fifo_num_enc/sub_9 |
| r1245    | DW01_dec     | width=4    |               | genblk5[0].fifo_idx_enc/sub_9 |
| r1247    | DW01_dec     | width=4    |               | genblk5[0].fetch_addr_enc/sub_9 |
| r1249    | DW01_dec     | width=4    |               | genblk5[1].fifo_num_enc/sub_9 |
| r1251    | DW01_dec     | width=4    |               | genblk5[1].fifo_idx_enc/sub_9 |
| r1253    | DW01_dec     | width=4    |               | genblk5[1].fetch_addr_enc/sub_9 |
| r1255    | DW01_dec     | width=10   |               | genblk6[0].mem_queue_num_enc/sub_9 |
| r1361    | DW02_mult    | A_width=6  |               | mult_add_514_aco     |
|          |              | B_width=1  |               |                      |
| r1363    | DW01_add     | width=64   |               | add_514_aco          |
| r1469    | DW02_mult    | A_width=6  |               | mult_add_514_I4_aco  |
|          |              | B_width=1  |               |                      |
| r1471    | DW01_add     | width=64   |               | add_514_I4_aco       |
| r1577    | DW02_mult    | A_width=6  |               | mult_add_514_I3_aco  |
|          |              | B_width=1  |               |                      |
| r1579    | DW01_add     | width=64   |               | add_514_I3_aco       |
| r1685    | DW02_mult    | A_width=6  |               | mult_add_514_I2_aco  |
|          |              | B_width=1  |               |                      |
| r1687    | DW01_add     | width=64   |               | add_514_I2_aco       |
| r1789    | DW02_mult    | A_width=3  |               | mult_575             |
|          |              | B_width=7  |               |                      |
| r1895    | DW02_mult    | A_width=2  |               | mult_574             |
|          |              | B_width=3  |               |                      |
| r1897    | DW01_add     | width=3    |               | add_574              |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_601            | DW01_add         | cla                |                |
| add_552            | DW01_add         | cla                |                |
| fetch_addr_cam/eq_18_G2               |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| fetch_addr_cam/eq_18_G3               |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| fetch_addr_cam/eq_18_G4               |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| fetch_addr_cam/eq_18                  |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| fetch_addr_cam/eq_18_G2_G1_G2         |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| fetch_addr_cam/eq_18_G2_G1_G3         |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| fetch_addr_cam/eq_18_G2_G1_G4         |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| fetch_addr_cam/eq_18_G2_G1_G1         |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| add_514_aco        | DW01_add         | cla                |                |
| add_514_I2_aco     | DW01_add         | cla                |                |
| add_514_I3_aco     | DW01_add         | cla                |                |
| add_514_I4_aco     | DW01_add         | cla                |                |
| mult_575           | DW02_mult        | csa                |                |
| mem_queue_cam/eq_18_G10               |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G9                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G8                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G7                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G6                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G5                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G4                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G3                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18_G2                |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| mem_queue_cam/eq_18                   |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| srl_575            | DW_rash          | mx2                |                |
===============================================================================

 
****************************************
Design : dcache_DW02_mult_4
****************************************

Resource Sharing Report for design DW02_mult_A_width3_B_width7

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r67      | DW01_add     | width=9    |               | FS_4                 |
| r69      | DW01_absval  | width=3    |               | A2_1                 |
| r71      | DW01_absval  | width=7    |               | A2_2                 |
| r73      | DW01_inc     | width=10   |               | A3                   |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| FS_4               | DW01_add         | cla                | cla            |
===============================================================================

 
****************************************
Design : vic_cache
****************************************

Resource Sharing Report for design vic_cache in file ../../verilog/vic_cache.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r181     | DW01_cmp2    | width=2    |               | gt_121 gt_135 lt_126 |
| r182     | DW01_cmp2    | width=2    |               | gt_121_I2 lt_126_I2  |
| r183     | DW01_cmp2    | width=2    |               | gt_121_I3 lt_126_I3  |
| r223     | DW01_sub     | width=3    |               | sub_102              |
| r225     | DW01_sub     | width=3    |               | sub_107              |
| r227     | DW01_cmp2    | width=3    |               | gte_109              |
| r229     | DW01_sub     | width=3    |               | sub_107_I2           |
| r231     | DW01_cmp2    | width=3    |               | gte_109_I2           |
| r233     | DW01_sub     | width=3    |               | sub_107_I3           |
| r235     | DW01_cmp2    | width=3    |               | gte_109_I3           |
| r237     | DW01_cmp2    | width=3    |               | gte_109_I4           |
| r239     | DW01_sub     | width=4    |               | sub_115              |
| r241     | DW01_cmp2    | width=32   |               | gt_115               |
| r247     | DW01_inc     | width=4    |               | add_131_I2           |
| r249     | DW01_add     | width=4    |               | add_131_I3           |
| r251     | DW01_add     | width=3    |               | add_135              |
| r253     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18     |
| r255     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18_G2_G1_G1 |
| r257     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18_G2  |
| r259     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18_G2_G1_G2 |
| r261     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18_G3  |
| r263     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18_G2_G1_G3 |
| r265     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18_G4  |
| r267     | DW01_cmp6    | width=13   |               | rd_vic_cam/eq_18_G2_G1_G4 |
| r269     | DW01_dec     | width=4    |               | genblk3[0].enc0/sub_9 |
| r271     | DW01_dec     | width=4    |               | genblk3[1].enc0/sub_9 |
| r378     | DW01_sub     | width=2    |               | sub_115_2            |
| r380     | DW01_sub     | width=2    |               | sub_115_3            |
===============================================================================


No implementations to report
 
****************************************
Design : cachemem
****************************************

Resource Sharing Report for design cachemem in file ../../verilog/cachemem.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r818     | DW01_cmp6    | width=3    |               | eq_176               |
| r820     | DW01_cmp6    | width=10   |               | eq_176_2             |
| r822     | DW01_cmp6    | width=3    |               | eq_176_I2_I1         |
| r824     | DW01_cmp6    | width=10   |               | eq_176_2_I2_I1       |
| r826     | DW01_cmp6    | width=3    |               | eq_176_I3_I1         |
| r828     | DW01_cmp6    | width=10   |               | eq_176_2_I3_I1       |
| r830     | DW01_cmp2    | width=2    |               | gte_217              |
| r832     | DW01_cmp2    | width=2    |               | gte_217_I2_I1        |
| r834     | DW01_inc     | width=2    |               | add_238_I2_I1        |
| r836     | DW01_cmp2    | width=2    |               | gte_217_I2           |
| r838     | DW01_cmp2    | width=2    |               | gte_217_I2_I2        |
| r840     | DW01_inc     | width=2    |               | add_238_I2_I2        |
| r842     | DW01_cmp2    | width=2    |               | gte_217_I3           |
| r844     | DW01_cmp2    | width=2    |               | gte_217_I2_I3        |
| r846     | DW01_inc     | width=2    |               | add_238_I2_I3        |
| r848     | DW01_cmp2    | width=2    |               | gte_268              |
| r850     | DW01_cmp2    | width=2    |               | gte_268_I2_I1        |
| r852     | DW01_cmp6    | width=10   |               | genblk1[0].rd_cam/eq_18 |
| r854     | DW01_cmp6    | width=10   |               | genblk1[0].rd_cam/eq_18_G2 |
| r856     | DW01_cmp6    | width=10   |               | genblk1[0].rd_cam/eq_18_G3 |
| r858     | DW01_cmp6    | width=10   |               | genblk1[0].rd_cam/eq_18_G4 |
| r860     | DW01_dec     | width=4    |               | genblk1[0].rd_enc/sub_9 |
| r862     | DW01_cmp6    | width=10   |               | genblk2[0].wr_cam/eq_18 |
| r864     | DW01_cmp6    | width=10   |               | genblk2[0].wr_cam/eq_18_G2 |
| r866     | DW01_cmp6    | width=10   |               | genblk2[0].wr_cam/eq_18_G3 |
| r868     | DW01_cmp6    | width=10   |               | genblk2[0].wr_cam/eq_18_G4 |
| r870     | DW01_dec     | width=4    |               | genblk2[0].wr_enc/sub_9 |
| r872     | DW01_cmp6    | width=10   |               | genblk2[1].wr_cam/eq_18 |
| r874     | DW01_cmp6    | width=10   |               | genblk2[1].wr_cam/eq_18_G2 |
| r876     | DW01_cmp6    | width=10   |               | genblk2[1].wr_cam/eq_18_G3 |
| r878     | DW01_cmp6    | width=10   |               | genblk2[1].wr_cam/eq_18_G4 |
| r880     | DW01_dec     | width=4    |               | genblk2[1].wr_enc/sub_9 |
| r882     | DW01_cmp6    | width=10   |               | genblk2[2].wr_cam/eq_18 |
| r884     | DW01_cmp6    | width=10   |               | genblk2[2].wr_cam/eq_18_G2 |
| r886     | DW01_cmp6    | width=10   |               | genblk2[2].wr_cam/eq_18_G3 |
| r888     | DW01_cmp6    | width=10   |               | genblk2[2].wr_cam/eq_18_G4 |
| r890     | DW01_dec     | width=4    |               | genblk2[2].wr_enc/sub_9 |
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
| r153     | DW01_inc     | width=4    |               | add_42 add_54        |
| r174     | DW01_cmp6    | width=64   |               | eq_36                |
| r176     | DW01_cmp6    | width=64   |               | eq_36_G2             |
| r178     | DW01_cmp6    | width=64   |               | eq_36_G3             |
| r180     | DW01_cmp6    | width=64   |               | eq_36_G4             |
| r182     | DW01_cmp6    | width=64   |               | eq_36_G5             |
| r184     | DW01_cmp6    | width=64   |               | eq_36_G6             |
| r186     | DW01_cmp6    | width=64   |               | eq_36_G7             |
| r188     | DW01_cmp6    | width=64   |               | eq_36_G8             |
| r190     | DW01_cmp6    | width=64   |               | eq_36_G9             |
| r192     | DW01_cmp6    | width=64   |               | eq_36_G10            |
| r194     | DW01_cmp6    | width=64   |               | eq_36_G11            |
| r196     | DW01_cmp6    | width=64   |               | eq_36_G12            |
| r198     | DW01_cmp6    | width=64   |               | eq_36_G13            |
| r200     | DW01_cmp6    | width=64   |               | eq_36_G14            |
| r202     | DW01_cmp6    | width=64   |               | eq_36_G15            |
| r204     | DW01_cmp6    | width=4    |               | eq_42                |
| r206     | DW01_inc     | width=4    |               | add_66               |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| eq_36              | DW01_cmp6        | rpl                |                |
| eq_36_G2           | DW01_cmp6        | rpl                |                |
| eq_36_G3           | DW01_cmp6        | rpl                |                |
| eq_36_G4           | DW01_cmp6        | rpl                |                |
| eq_36_G5           | DW01_cmp6        | rpl                |                |
| eq_36_G6           | DW01_cmp6        | rpl                |                |
| eq_36_G7           | DW01_cmp6        | rpl                |                |
| eq_36_G8           | DW01_cmp6        | rpl                |                |
| eq_36_G9           | DW01_cmp6        | rpl                |                |
| eq_36_G10          | DW01_cmp6        | rpl                |                |
| eq_36_G11          | DW01_cmp6        | rpl                |                |
| eq_36_G12          | DW01_cmp6        | rpl                |                |
| eq_36_G13          | DW01_cmp6        | rpl                |                |
| eq_36_G14          | DW01_cmp6        | rpl                |                |
| eq_36_G15          | DW01_cmp6        | rpl                |                |
===============================================================================

 
****************************************
Design : SQ
****************************************

Resource Sharing Report for design SQ in file ../../verilog/SQ.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r715     | DW01_inc     | width=4    |               | add_103 add_155      |
| r717     | DW01_cmp2    | width=4    |               | lte_115 lte_115_G10  |
|          |              |            |               | lte_115_G11          |
|          |              |            |               | lte_115_G12          |
|          |              |            |               | lte_115_G13          |
|          |              |            |               | lte_115_G14          |
|          |              |            |               | lte_115_G15          |
|          |              |            |               | lte_115_G16          |
|          |              |            |               | lte_115_G2           |
|          |              |            |               | lte_115_G3           |
|          |              |            |               | lte_115_G4           |
|          |              |            |               | lte_115_G5           |
|          |              |            |               | lte_115_G6           |
|          |              |            |               | lte_115_G7           |
|          |              |            |               | lte_115_G8           |
|          |              |            |               | lte_115_G9 lte_168   |
|          |              |            |               | lte_168_I10          |
|          |              |            |               | lte_168_I11          |
|          |              |            |               | lte_168_I12          |
|          |              |            |               | lte_168_I13          |
|          |              |            |               | lte_168_I14          |
|          |              |            |               | lte_168_I15          |
|          |              |            |               | lte_168_I16          |
|          |              |            |               | lte_168_I2           |
|          |              |            |               | lte_168_I3           |
|          |              |            |               | lte_168_I4           |
|          |              |            |               | lte_168_I5           |
|          |              |            |               | lte_168_I6           |
|          |              |            |               | lte_168_I7           |
|          |              |            |               | lte_168_I8           |
|          |              |            |               | lte_168_I9           |
| r718     | DW01_cmp2    | width=4    |               | lte_115_2 lte_115_3  |
|          |              |            |               | lte_168_2 lte_168_3  |
| r719     | DW01_cmp2    | width=4    |               | lt_115_2 lt_115_3    |
|          |              |            |               | lt_168_2 lt_168_3    |
| r720     | DW01_cmp2    | width=4    |               | lt_115 lt_168        |
| r721     | DW01_cmp2    | width=4    |               | lte_115_2_G2         |
|          |              |            |               | lte_115_3_G2         |
|          |              |            |               | lte_168_2_I2         |
|          |              |            |               | lte_168_3_I2         |
| r722     | DW01_cmp2    | width=4    |               | lt_115_2_G2          |
|          |              |            |               | lt_115_3_G2          |
|          |              |            |               | lt_168_2_I2          |
|          |              |            |               | lt_168_3_I2          |
| r723     | DW01_cmp2    | width=4    |               | lt_115_G2 lt_168_I2  |
| r724     | DW01_cmp2    | width=4    |               | lte_115_2_G3         |
|          |              |            |               | lte_115_3_G3         |
|          |              |            |               | lte_168_2_I3         |
|          |              |            |               | lte_168_3_I3         |
| r725     | DW01_cmp2    | width=4    |               | lt_115_2_G3          |
|          |              |            |               | lt_115_3_G3          |
|          |              |            |               | lt_168_2_I3          |
|          |              |            |               | lt_168_3_I3          |
| r726     | DW01_cmp2    | width=4    |               | lt_115_G3 lt_168_I3  |
| r727     | DW01_cmp2    | width=4    |               | lte_115_2_G4         |
|          |              |            |               | lte_115_3_G4         |
|          |              |            |               | lte_168_2_I4         |
|          |              |            |               | lte_168_3_I4         |
| r728     | DW01_cmp2    | width=4    |               | lt_115_2_G4          |
|          |              |            |               | lt_115_3_G4          |
|          |              |            |               | lt_168_2_I4          |
|          |              |            |               | lt_168_3_I4          |
| r729     | DW01_cmp2    | width=4    |               | lt_115_G4 lt_168_I4  |
| r730     | DW01_cmp2    | width=4    |               | lte_115_2_G5         |
|          |              |            |               | lte_115_3_G5         |
|          |              |            |               | lte_168_2_I5         |
|          |              |            |               | lte_168_3_I5         |
| r731     | DW01_cmp2    | width=4    |               | lt_115_2_G5          |
|          |              |            |               | lt_115_3_G5          |
|          |              |            |               | lt_168_2_I5          |
|          |              |            |               | lt_168_3_I5          |
| r732     | DW01_cmp2    | width=4    |               | lt_115_G5 lt_168_I5  |
| r733     | DW01_cmp2    | width=4    |               | lte_115_2_G6         |
|          |              |            |               | lte_115_3_G6         |
|          |              |            |               | lte_168_2_I6         |
|          |              |            |               | lte_168_3_I6         |
| r734     | DW01_cmp2    | width=4    |               | lt_115_2_G6          |
|          |              |            |               | lt_115_3_G6          |
|          |              |            |               | lt_168_2_I6          |
|          |              |            |               | lt_168_3_I6          |
| r735     | DW01_cmp2    | width=4    |               | lt_115_G6 lt_168_I6  |
| r736     | DW01_cmp2    | width=4    |               | lte_115_2_G7         |
|          |              |            |               | lte_115_3_G7         |
|          |              |            |               | lte_168_2_I7         |
|          |              |            |               | lte_168_3_I7         |
| r737     | DW01_cmp2    | width=4    |               | lt_115_2_G7          |
|          |              |            |               | lt_115_3_G7          |
|          |              |            |               | lt_168_2_I7          |
|          |              |            |               | lt_168_3_I7          |
| r738     | DW01_cmp2    | width=4    |               | lt_115_G7 lt_168_I7  |
| r739     | DW01_cmp2    | width=4    |               | lte_115_2_G8         |
|          |              |            |               | lte_115_3_G8         |
|          |              |            |               | lte_168_2_I8         |
|          |              |            |               | lte_168_3_I8         |
| r740     | DW01_cmp2    | width=4    |               | lt_115_2_G8          |
|          |              |            |               | lt_115_3_G8          |
|          |              |            |               | lt_168_2_I8          |
|          |              |            |               | lt_168_3_I8          |
| r741     | DW01_cmp2    | width=4    |               | lt_115_G8 lt_168_I8  |
| r742     | DW01_cmp2    | width=4    |               | lte_115_2_G9         |
|          |              |            |               | lte_115_3_G9         |
|          |              |            |               | lte_168_2_I9         |
|          |              |            |               | lte_168_3_I9         |
| r743     | DW01_cmp2    | width=4    |               | lt_115_2_G9          |
|          |              |            |               | lt_115_3_G9          |
|          |              |            |               | lt_168_2_I9          |
|          |              |            |               | lt_168_3_I9          |
| r744     | DW01_cmp2    | width=4    |               | lt_115_G9 lt_168_I9  |
| r745     | DW01_cmp2    | width=4    |               | lte_115_2_G10        |
|          |              |            |               | lte_115_3_G10        |
|          |              |            |               | lte_168_2_I10        |
|          |              |            |               | lte_168_3_I10        |
| r746     | DW01_cmp2    | width=4    |               | lt_115_2_G10         |
|          |              |            |               | lt_115_3_G10         |
|          |              |            |               | lt_168_2_I10         |
|          |              |            |               | lt_168_3_I10         |
| r747     | DW01_cmp2    | width=4    |               | lt_115_G10           |
|          |              |            |               | lt_168_I10           |
| r748     | DW01_cmp2    | width=4    |               | lte_115_2_G11        |
|          |              |            |               | lte_115_3_G11        |
|          |              |            |               | lte_168_2_I11        |
|          |              |            |               | lte_168_3_I11        |
| r749     | DW01_cmp2    | width=4    |               | lt_115_2_G11         |
|          |              |            |               | lt_115_3_G11         |
|          |              |            |               | lt_168_2_I11         |
|          |              |            |               | lt_168_3_I11         |
| r750     | DW01_cmp2    | width=4    |               | lt_115_G11           |
|          |              |            |               | lt_168_I11           |
| r751     | DW01_cmp2    | width=4    |               | lte_115_2_G12        |
|          |              |            |               | lte_115_3_G12        |
|          |              |            |               | lte_168_2_I12        |
|          |              |            |               | lte_168_3_I12        |
| r752     | DW01_cmp2    | width=4    |               | lt_115_2_G12         |
|          |              |            |               | lt_115_3_G12         |
|          |              |            |               | lt_168_2_I12         |
|          |              |            |               | lt_168_3_I12         |
| r753     | DW01_cmp2    | width=4    |               | lt_115_G12           |
|          |              |            |               | lt_168_I12           |
| r754     | DW01_cmp2    | width=4    |               | lte_115_2_G13        |
|          |              |            |               | lte_115_3_G13        |
|          |              |            |               | lte_168_2_I13        |
|          |              |            |               | lte_168_3_I13        |
| r755     | DW01_cmp2    | width=4    |               | lt_115_2_G13         |
|          |              |            |               | lt_115_3_G13         |
|          |              |            |               | lt_168_2_I13         |
|          |              |            |               | lt_168_3_I13         |
| r756     | DW01_cmp2    | width=4    |               | lt_115_G13           |
|          |              |            |               | lt_168_I13           |
| r757     | DW01_cmp2    | width=4    |               | lte_115_2_G14        |
|          |              |            |               | lte_115_3_G14        |
|          |              |            |               | lte_168_2_I14        |
|          |              |            |               | lte_168_3_I14        |
| r758     | DW01_cmp2    | width=4    |               | lt_115_2_G14         |
|          |              |            |               | lt_115_3_G14         |
|          |              |            |               | lt_168_2_I14         |
|          |              |            |               | lt_168_3_I14         |
| r759     | DW01_cmp2    | width=4    |               | lt_115_G14           |
|          |              |            |               | lt_168_I14           |
| r760     | DW01_cmp2    | width=4    |               | lte_115_2_G15        |
|          |              |            |               | lte_115_3_G15        |
|          |              |            |               | lte_168_2_I15        |
|          |              |            |               | lte_168_3_I15        |
| r761     | DW01_cmp2    | width=4    |               | lt_115_2_G15         |
|          |              |            |               | lt_115_3_G15         |
|          |              |            |               | lt_168_2_I15         |
|          |              |            |               | lt_168_3_I15         |
| r762     | DW01_cmp2    | width=4    |               | lt_115_G15           |
|          |              |            |               | lt_168_I15           |
| r763     | DW01_cmp2    | width=4    |               | lte_115_2_G16        |
|          |              |            |               | lte_115_3_G16        |
|          |              |            |               | lte_168_2_I16        |
|          |              |            |               | lte_168_3_I16        |
| r764     | DW01_cmp2    | width=4    |               | lt_115_2_G16         |
|          |              |            |               | lt_115_3_G16         |
|          |              |            |               | lt_168_2_I16         |
|          |              |            |               | lt_168_3_I16         |
| r765     | DW01_cmp2    | width=4    |               | lt_115_G16           |
|          |              |            |               | lt_168_I16           |
| r808     | DW01_cmp6    | width=4    |               | eq_103               |
| r810     | DW01_inc     | width=4    |               | add_137              |
| r812     | DW01_cmp6    | width=4    |               | ne_155               |
| r814     | DW01_inc     | width=4    |               | add_160              |
| r816     | DW01_cmp6    | width=32   |               | eq_168               |
| r818     | DW01_cmp6    | width=32   |               | eq_168_I2            |
| r820     | DW01_cmp6    | width=32   |               | eq_168_I3            |
| r822     | DW01_cmp6    | width=32   |               | eq_168_I4            |
| r824     | DW01_cmp6    | width=32   |               | eq_168_I5            |
| r826     | DW01_cmp6    | width=32   |               | eq_168_I6            |
| r828     | DW01_cmp6    | width=32   |               | eq_168_I7            |
| r830     | DW01_cmp6    | width=32   |               | eq_168_I8            |
| r832     | DW01_cmp6    | width=32   |               | eq_168_I9            |
| r834     | DW01_cmp6    | width=32   |               | eq_168_I10           |
| r836     | DW01_cmp6    | width=32   |               | eq_168_I11           |
| r838     | DW01_cmp6    | width=32   |               | eq_168_I12           |
| r840     | DW01_cmp6    | width=32   |               | eq_168_I13           |
| r842     | DW01_cmp6    | width=32   |               | eq_168_I14           |
| r844     | DW01_cmp6    | width=32   |               | eq_168_I15           |
| r846     | DW01_cmp6    | width=32   |               | eq_168_I16           |
| r848     | DW01_dec     | width=16   |               | enc/sub_9            |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| eq_168_I11         | DW01_cmp6        | rpl                |                |
| eq_168_I5          | DW01_cmp6        | rpl                |                |
| eq_168_I10         | DW01_cmp6        | rpl                |                |
| eq_168_I12         | DW01_cmp6        | rpl                |                |
| eq_168_I9          | DW01_cmp6        | rpl                |                |
| eq_168_I13         | DW01_cmp6        | rpl                |                |
| eq_168_I14         | DW01_cmp6        | rpl                |                |
| eq_168_I15         | DW01_cmp6        | rpl                |                |
| eq_168             | DW01_cmp6        | rpl                |                |
| eq_168_I2          | DW01_cmp6        | rpl                |                |
| eq_168_I3          | DW01_cmp6        | rpl                |                |
| eq_168_I4          | DW01_cmp6        | rpl                |                |
| eq_168_I6          | DW01_cmp6        | rpl                |                |
| eq_168_I7          | DW01_cmp6        | rpl                |                |
| eq_168_I8          | DW01_cmp6        | rpl                |                |
===============================================================================

 
****************************************
Design : icache
****************************************

Resource Sharing Report for design icache in file ../../verilog/icache.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r763     | DW01_cmp2    | width=3    |               | lt_134 lt_137        |
|          |              |            |               | lt_137_G2_G1         |
|          |              |            |               | lt_137_G3_G1         |
|          |              |            |               | lt_137_G4_G1         |
| r764     | DW01_cmp2    | width=3    |               | lt_134_G2 lt_137_G2  |
|          |              |            |               | lt_137_G2_G2         |
|          |              |            |               | lt_137_G3_G2         |
|          |              |            |               | lt_137_G4_G2         |
| r765     | DW01_cmp2    | width=3    |               | lt_134_G3            |
|          |              |            |               | lt_137_G2_G3         |
|          |              |            |               | lt_137_G3            |
|          |              |            |               | lt_137_G3_G3         |
|          |              |            |               | lt_137_G4_G3         |
| r766     | DW01_cmp2    | width=3    |               | lt_134_G4            |
|          |              |            |               | lt_137_G2_G4         |
|          |              |            |               | lt_137_G3_G4         |
|          |              |            |               | lt_137_G4            |
|          |              |            |               | lt_137_G4_G4         |
| r767     | DW01_cmp2    | width=3    |               | lt_134_G5            |
|          |              |            |               | lt_137_G2_G5         |
|          |              |            |               | lt_137_G3_G5         |
|          |              |            |               | lt_137_G4_G5         |
|          |              |            |               | lt_137_G5            |
| r768     | DW01_cmp2    | width=3    |               | lt_134_G6            |
|          |              |            |               | lt_137_G2_G6         |
|          |              |            |               | lt_137_G3_G6         |
|          |              |            |               | lt_137_G4_G6         |
|          |              |            |               | lt_137_G6            |
| r944     | DW01_add     | width=64   |               | add_153              |
| r946     | DW01_add     | width=64   |               | add_153_G2           |
| r948     | DW01_add     | width=64   |               | add_153_G3           |
| r950     | DW01_add     | width=64   |               | add_153_G4           |
| r952     | DW01_cmp6    | width=64   |               | ne_156               |
| r954     | DW01_cmp2    | width=3    |               | lt_171               |
| r956     | DW01_cmp6    | width=4    |               | eq_183               |
| r958     | DW01_inc     | width=3    |               | add_197              |
| r960     | DW01_sub     | width=3    |               | sub_202_aco          |
| r962     | DW01_cmp2    | width=3    |               | gt_203               |
| r964     | DW01_sub     | width=3    |               | sub_204_aco          |
| r966     | DW01_cmp2    | width=3    |               | gt_206               |
| r968     | DW01_sub     | width=3    |               | sub_207_aco          |
| r970     | DW01_inc     | width=3    |               | add_213              |
| r972     | DW01_cmp2    | width=3    |               | lt_228               |
| r974     | DW01_inc     | width=3    |               | add_232              |
| r976     | DW01_cmp2    | width=3    |               | lt_228_I2            |
| r978     | DW01_inc     | width=3    |               | add_232_I2           |
| r980     | DW01_cmp2    | width=3    |               | lt_228_I3            |
| r982     | DW01_inc     | width=3    |               | add_232_I3           |
| r984     | DW01_cmp2    | width=3    |               | lt_228_I4            |
| r986     | DW01_inc     | width=3    |               | add_232_I4           |
| r988     | DW01_cmp6    | width=3    |               | memory/eq_176        |
| r990     | DW01_cmp6    | width=10   |               | memory/eq_176_2      |
| r992     | DW01_cmp6    | width=3    |               | memory/eq_176_I2     |
| r994     | DW01_cmp6    | width=10   |               | memory/eq_176_2_I2   |
| r996     | DW01_cmp6    | width=3    |               | memory/eq_176_I3     |
| r998     | DW01_cmp6    | width=10   |               | memory/eq_176_2_I3   |
| r1000    | DW01_cmp2    | width=2    |               | memory/gte_217       |
| r1002    | DW01_cmp2    | width=2    |               | memory/gte_217_I2_I1 |
| r1004    | DW01_inc     | width=2    |               | memory/add_238_I2_I1 |
| r1006    | DW01_cmp2    | width=2    |               | memory/gte_268       |
| r1008    | DW01_cmp2    | width=2    |               | memory/gte_268_I2_I1 |
| r1010    | DW01_cmp2    | width=2    |               | memory/gte_268_I2    |
| r1012    | DW01_cmp2    | width=2    |               | memory/gte_268_I2_I2 |
| r1014    | DW01_cmp2    | width=2    |               | memory/gte_268_I3    |
| r1016    | DW01_cmp2    | width=2    |               | memory/gte_268_I2_I3 |
| r1018    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18 |
| r1020    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G2 |
| r1022    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G3 |
| r1024    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G4 |
| r1026    | DW01_dec     | width=4    |               | memory/genblk1[0].rd_enc/sub_9 |
| r1028    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18 |
| r1030    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G2 |
| r1032    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G3 |
| r1034    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G4 |
| r1036    | DW01_dec     | width=4    |               | memory/genblk1[1].rd_enc/sub_9 |
| r1038    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18 |
| r1040    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G2 |
| r1042    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G3 |
| r1044    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G4 |
| r1046    | DW01_dec     | width=4    |               | memory/genblk1[2].rd_enc/sub_9 |
| r1048    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18 |
| r1050    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G2 |
| r1052    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G3 |
| r1054    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G4 |
| r1056    | DW01_dec     | width=4    |               | memory/genblk2[0].wr_enc/sub_9 |
| r1058    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18   |
| r1060    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G1 |
| r1062    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G1 |
| r1064    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G1 |
| r1066    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G1 |
| r1068    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2 |
| r1070    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G2 |
| r1072    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G2 |
| r1074    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G2 |
| r1076    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G2 |
| r1078    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3 |
| r1080    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G3 |
| r1082    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G3 |
| r1084    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G3 |
| r1086    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G3 |
| r1088    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4 |
| r1090    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G4 |
| r1092    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G4 |
| r1094    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G4 |
| r1096    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G4 |
| r1098    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5 |
| r1100    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G5 |
| r1102    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G5 |
| r1104    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G5 |
| r1106    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G5 |
| r1108    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G6 |
| r1110    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G6 |
| r1112    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G6 |
| r1114    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G6 |
| r1116    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G6 |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| add_153            | DW01_add         | cla                |                |
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
| add_153_G4         | DW01_add         | cla                |                |
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
| add_153_G3         | DW01_add         | cla                |                |
| add_153_G2         | DW01_add         | cla                |                |
| ne_156             | DW01_cmp6        | rpl                |                |
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


No resource sharing information to report.
 
****************************************
Design : mem_controller
****************************************

No implementations to report
1
