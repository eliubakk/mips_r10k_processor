 
****************************************
Report : resources
Design : pipeline
Version: O-2018.06
Date   : Tue Apr 23 23:19:33 2019
****************************************

Resource Sharing Report for design pipeline in file ../../verilog/pipeline.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r338     | DW01_cmp6    | width=64   |               | eq_629 eq_632        |
| r342     | DW01_sub     | width=64   |               | sub_1710             |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r338               | DW01_cmp6        | rpl                |                |
| sub_1710           | DW01_sub         | rpl                |                |
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
| r177     | DW01_cmp6    | width=6    |               | map_cam/eq_18        |
| r179     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G2     |
| r181     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G3     |
| r183     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G4     |
| r185     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G5     |
| r187     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G6     |
| r189     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G7     |
| r191     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G8     |
| r193     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G9     |
| r195     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G10    |
| r197     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G11    |
| r199     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G12    |
| r201     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G13    |
| r203     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G14    |
| r205     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G15    |
| r207     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G16    |
| r209     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G17    |
| r211     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G18    |
| r213     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G19    |
| r215     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G20    |
| r217     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G21    |
| r219     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G22    |
| r221     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G23    |
| r223     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G24    |
| r225     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G25    |
| r227     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G26    |
| r229     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G27    |
| r231     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G28    |
| r233     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G29    |
| r235     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G30    |
| r237     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G31    |
| r239     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G32    |
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
| r2671    | DW01_cmp2    | width=5    |               | dcache0/gt_424       |
|          |              |            |               | dcache0/gt_430       |
|          |              |            |               | dcache0/gt_486       |
| r2672    | DW01_dec     | width=4    |               | dcache0/sub_424      |
|          |              |            |               | dcache0/sub_430      |
| r2691    | DW01_inc     | width=3    |               | dcache0/add_576      |
|          |              |            |               | dcache0/add_577      |
|          |              |            |               | dcache0/add_578      |
| r2749    | DW01_sub     | width=4    |               | dcache0/victim_memory/sub_116 |
  |              |            |               | dcache0/victim_memory/sub_116_2 |
| r3031    | DW01_cmp2    | width=5    |               | dcache0/lt_322       |
| r3033    | DW01_cmp2    | width=5    |               | dcache0/lt_411       |
| r3035    | DW01_cmp6    | width=4    |               | dcache0/eq_420       |
| r3037    | DW01_dec     | width=3    |               | dcache0/sub_456      |
| r3039    | DW01_inc     | width=5    |               | dcache0/add_464      |
| r3041    | DW01_inc     | width=5    |               | dcache0/add_469      |
| r3043    | DW01_inc     | width=3    |               | dcache0/add_479      |
| r3045    | DW01_dec     | width=5    |               | dcache0/sub_482      |
| r3047    | DW01_cmp2    | width=5    |               | dcache0/gt_483       |
| r3049    | DW01_sub     | width=5    |               | dcache0/sub_484_aco  |
| r3051    | DW01_sub     | width=5    |               | dcache0/sub_487_aco  |
| r3061    | DW01_cmp2    | width=5    |               | dcache0/lt_524       |
| r3063    | DW01_inc     | width=5    |               | dcache0/add_531      |
| r3065    | DW01_inc     | width=2    |               | dcache0/add_543_I2_I1 |
| r3067    | DW01_add     | width=64   |               | dcache0/add_553      |
| r3075    | DW_rash      | A_width=316 |              | dcache0/srl_576      |
|          |              | SH_width=10 |              |                      |
| r3077    | DW01_sub     | width=3    |               | dcache0/sub_577      |
| r3079    | DW01_sub     | width=3    |               | dcache0/sub_578      |
| r3081    | DW01_cmp2    | width=5    |               | dcache0/lt_584_2     |
| r3083    | DW01_inc     | width=5    |               | dcache0/add_598      |
| r3085    | DW01_inc     | width=3    |               | dcache0/add_600      |
| r3087    | DW01_add     | width=64   |               | dcache0/add_602      |
| r3097    | DW01_cmp6    | width=3    |               | dcache0/memory/eq_194 |
| r3099    | DW01_cmp6    | width=10   |               | dcache0/memory/eq_194_2 |
| r3101    | DW01_cmp6    | width=3    |               | dcache0/memory/eq_194_I2_I1 |
| r3103    | DW01_cmp6    | width=10   |               | dcache0/memory/eq_194_2_I2_I1 |
| r3105    | DW01_cmp6    | width=3    |               | dcache0/memory/eq_194_I3_I1 |
| r3107    | DW01_cmp6    | width=10   |               | dcache0/memory/eq_194_2_I3_I1 |
| r3109    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_235 |
| r3111    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_235_I2_I1 |
| r3113    | DW01_inc     | width=2    |               | dcache0/memory/add_256_I2_I1 |
| r3115    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_235_I2 |
| r3117    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_235_I2_I2 |
| r3119    | DW01_inc     | width=2    |               | dcache0/memory/add_256_I2_I2 |
| r3121    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_235_I3 |
| r3123    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_235_I2_I3 |
| r3125    | DW01_inc     | width=2    |               | dcache0/memory/add_256_I2_I3 |
| r3127    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_286 |
| r3129    | DW01_cmp2    | width=2    |               | dcache0/memory/gte_286_I2_I1 |
| r3131    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk1[0].rd_cam/eq_18 |
| r3133    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk1[0].rd_cam/eq_18_G2 |
| r3135    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk1[0].rd_cam/eq_18_G3 |
| r3137    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk1[0].rd_cam/eq_18_G4 |
| r3139    | DW01_dec     | width=4    |               | dcache0/memory/genblk1[0].rd_enc/sub_9 |
| r3141    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[0].wr_cam/eq_18 |
| r3143    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[0].wr_cam/eq_18_G2 |
| r3145    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[0].wr_cam/eq_18_G3 |
| r3147    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[0].wr_cam/eq_18_G4 |
| r3149    | DW01_dec     | width=4    |               | dcache0/memory/genblk2[0].wr_enc/sub_9 |
| r3151    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[1].wr_cam/eq_18 |
| r3153    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[1].wr_cam/eq_18_G2 |
| r3155    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[1].wr_cam/eq_18_G3 |
| r3157    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[1].wr_cam/eq_18_G4 |
| r3159    | DW01_dec     | width=4    |               | dcache0/memory/genblk2[1].wr_enc/sub_9 |
| r3161    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[2].wr_cam/eq_18 |
| r3163    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[2].wr_cam/eq_18_G2 |
| r3165    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[2].wr_cam/eq_18_G3 |
| r3167    | DW01_cmp6    | width=10   |               | dcache0/memory/genblk2[2].wr_cam/eq_18_G4 |
| r3169    | DW01_dec     | width=4    |               | dcache0/memory/genblk2[2].wr_enc/sub_9 |
| r3171    | DW01_sub     | width=3    |               | dcache0/victim_memory/sub_103 |
| r3173    | DW01_sub     | width=3    |               | dcache0/victim_memory/sub_108 |
| r3175    | DW01_cmp2    | width=3    |               | dcache0/victim_memory/gte_110 |
| r3177    | DW01_sub     | width=3    |               | dcache0/victim_memory/sub_108_I2 |
| r3179    | DW01_cmp2    | width=3    |               | dcache0/victim_memory/gte_110_I2 |
| r3181    | DW01_sub     | width=3    |               | dcache0/victim_memory/sub_108_I3 |
| r3183    | DW01_cmp2    | width=3    |               | dcache0/victim_memory/gte_110_I3 |
| r3185    | DW01_cmp2    | width=3    |               | dcache0/victim_memory/gte_110_I4 |
| r3187    | DW01_cmp2    | width=32   |               | dcache0/victim_memory/gt_116 |
| r3189    | DW01_sub     | width=3    |               | dcache0/victim_memory/sub_116_3 |
| r3191    | DW01_cmp2    | width=3    |               | dcache0/victim_memory/gt_122 |
| r3193    | DW01_cmp2    | width=3    |               | dcache0/victim_memory/gt_122_I2 |
| r3195    | DW01_cmp2    | width=3    |               | dcache0/victim_memory/gt_122_I3 |
| r3197    | DW01_inc     | width=4    |               | dcache0/victim_memory/add_126_I2 |
| r3199    | DW01_add     | width=4    |               | dcache0/victim_memory/add_126_I3 |
| r3201    | DW01_add     | width=4    |               | dcache0/victim_memory/add_126_I4 |
| r3203    | DW01_sub     | width=3    |               | dcache0/victim_memory/sub_132 |
| r3205    | DW01_inc     | width=3    |               | dcache0/victim_memory/add_147 |
| r3207    | DW01_inc     | width=3    |               | dcache0/victim_memory/add_147_I2 |
| r3209    | DW01_inc     | width=3    |               | dcache0/victim_memory/add_147_I3 |
| r3211    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18 |
| r3213    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18_G2_G1_G1 |
| r3215    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18_G2 |
| r3217    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18_G2_G1_G2 |
| r3219    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18_G3 |
| r3221    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18_G2_G1_G3 |
| r3223    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18_G4 |
| r3225    | DW01_cmp6    | width=13   |               | dcache0/victim_memory/rd_vic_cam/eq_18_G2_G1_G4 |
| r3227    | DW01_dec     | width=4    |               | dcache0/victim_memory/genblk3[0].enc0/sub_9 |
| r3229    | DW01_dec     | width=4    |               | dcache0/victim_memory/genblk3[1].enc0/sub_9 |
| r3231    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18 |
| r3233    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G1_G1 |
| r3235    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G1 |
| r3237    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G2_G1 |
| r3239    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G3_G1 |
| r3241    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G3_G1 |
| r3243    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G4_G1 |
| r3245    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G4_G1 |
| r3247    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2 |
| r3249    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G1_G2 |
| r3251    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G2 |
| r3253    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G2_G2 |
| r3255    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G3_G2 |
| r3257    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G3_G2 |
| r3259    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G4_G2 |
| r3261    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G4_G2 |
| r3263    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G3 |
| r3265    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G1_G3 |
| r3267    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G3 |
| r3269    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G2_G3 |
| r3271    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G3_G3 |
| r3273    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G3_G3 |
| r3275    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G4_G3 |
| r3277    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G4_G3 |
| r3279    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G4 |
| r3281    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G1_G4 |
| r3283    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G4 |
| r3285    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G2_G4 |
| r3287    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G3_G4 |
| r3289    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G3_G4 |
| r3291    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G4_G4 |
| r3293    | DW01_cmp6    | width=13   |               | dcache0/fifo_cam/eq_18_G2_G4_G4 |
| r3295    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18 |
| r3297    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G2 |
| r3299    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G3 |
| r3301    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G4 |
| r3303    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G5 |
| r3305    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G6 |
| r3307    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G7 |
| r3309    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G8 |
| r3311    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G9 |
| r3313    | DW01_cmp6    | width=64   |               | dcache0/mem_queue_cam/eq_18_G10 |
| r3315    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18 |
| r3317    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18_G2_G1_G1 |
| r3319    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18_G2 |
| r3321    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18_G2_G1_G2 |
| r3323    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18_G3 |
| r3325    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18_G2_G1_G3 |
| r3327    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18_G4 |
| r3329    | DW01_cmp6    | width=64   |               | dcache0/fetch_addr_cam/eq_18_G2_G1_G4 |
| r3331    | DW01_sub     | width=3    |               | dcache0/fifo_psel/sub_26 |
| r3333    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_29 |
| r3335    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_31 |
| r3337    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_29_G2 |
| r3339    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_31_G2 |
| r3341    | DW01_sub     | width=2    |               | dcache0/fifo_psel/sub_31_G2 |
| r3343    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_29_G3 |
| r3345    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_31_G3 |
| r3347    | DW01_sub     | width=2    |               | dcache0/fifo_psel/sub_31_G3 |
| r3349    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_29_G4 |
| r3351    | DW01_sub     | width=2    |               | dcache0/fifo_psel/sub_29_G4 |
| r3353    | DW01_cmp2    | width=3    |               | dcache0/fifo_psel/gte_31_G4 |
| r3355    | DW01_dec     | width=2    |               | dcache0/fifo_psel/sub_31_G4 |
| r3357    | DW01_inc     | width=3    |               | dcache0/fifo_psel/add_53 |
| r3359    | DW01_dec     | width=4    |               | dcache0/fifo_sel_enc/sub_9 |
| r3361    | DW01_dec     | width=4    |               | dcache0/genblk5[0].fifo_num_enc/sub_9 |
| r3363    | DW01_dec     | width=4    |               | dcache0/genblk5[0].fifo_idx_enc/sub_9 |
| r3365    | DW01_dec     | width=4    |               | dcache0/genblk5[0].fetch_addr_enc/sub_9 |
| r3367    | DW01_dec     | width=4    |               | dcache0/genblk5[1].fifo_num_enc/sub_9 |
| r3369    | DW01_dec     | width=4    |               | dcache0/genblk5[1].fifo_idx_enc/sub_9 |
| r3371    | DW01_dec     | width=4    |               | dcache0/genblk5[1].fetch_addr_enc/sub_9 |
| r3373    | DW01_dec     | width=10   |               | dcache0/genblk6[0].mem_queue_num_enc/sub_9 |
| r3375    | DW01_cmp2    | width=7    |               | rb0/gte_37           |
| r3377    | DW01_cmp2    | width=7    |               | rb0/lt_39            |
| r3381    | DW01_cmp2    | width=7    |               | rb0/gt_60            |
| r3383    | DW01_sub     | width=7    |               | rb0/sub_61_aco       |
| r3493    | DW02_mult    | A_width=6  |               | dcache0/mult_add_515_I2_aco |
    |              | B_width=1  |               |                      |
| r3495    | DW01_add     | width=64   |               | dcache0/add_515_I2_aco |
| r3601    | DW02_mult    | A_width=6  |               | dcache0/mult_add_515_I3_aco |
    |              | B_width=1  |               |                      |
| r3603    | DW01_add     | width=64   |               | dcache0/add_515_I3_aco |
| r3709    | DW02_mult    | A_width=6  |               | dcache0/mult_add_515_I4_aco |
    |              | B_width=1  |               |                      |
| r3711    | DW01_add     | width=64   |               | dcache0/add_515_I4_aco |
| r3817    | DW02_mult    | A_width=6  |               | dcache0/mult_add_515_aco |
       |              | B_width=1  |               |                      |
| r3819    | DW01_add     | width=64   |               | dcache0/add_515_aco  |
| r3921    | DW02_mult    | A_width=3  |               | dcache0/mult_576     |
|          |              | B_width=7  |               |                      |
| r4027    | DW02_mult    | A_width=3  |               | dcache0/mult_575     |
|          |              | B_width=2  |               |                      |
| r4029    | DW01_add     | width=3    |               | dcache0/add_575      |
| r4143    | DW01_add     | width=7    |               | add_1_root_add_1_root_rb0/add_73_I3_aco |
| r4145    | DW01_add     | width=7    |               | add_2_root_add_1_root_rb0/add_73_I3_aco |
| r4147    | DW01_sub     | width=7    |               | sub_0_root_add_1_root_rb0/add_73_I3_aco |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| dcache0/add_602    | DW01_add         | cla                |                |
| dcache0/add_515_aco                   |                    |                |
|                    | DW01_add         | rpl                |                |
| dcache0/add_515_I2_aco                |                    |                |
|                    | DW01_add         | rpl                |                |
| dcache0/add_515_I3_aco                |                    |                |
|                    | DW01_add         | rpl                |                |
| dcache0/add_515_I4_aco                |                    |                |
|                    | DW01_add         | rpl                |                |
| dcache0/mult_576   | DW02_mult        | csa                |                |
| dcache0/mem_queue_cam/eq_18           |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G2        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G3        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G4        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G5        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G6        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G7        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G8        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G9        |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/mem_queue_cam/eq_18_G10       |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18_G2_G1_G1 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18          |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18_G2_G1_G2 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18_G2       |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18_G2_G1_G3 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18_G3       |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18_G2_G1_G4 |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/fetch_addr_cam/eq_18_G4       |                    |                |
|                    | DW01_cmp6        | rpl                |                |
| dcache0/add_553    | DW01_add         | rpl                |                |
| dcache0/srl_576    | DW_rash          | mx2                |                |
===============================================================================

 
****************************************
Design : mem_stage_DW02_mult_4
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
| r1357    | DW01_cmp6    | width=6    |               | eq_32_2              |
| r1359    | DW01_cmp6    | width=6    |               | eq_32_2_G2_G1        |
| r1361    | DW01_cmp6    | width=6    |               | eq_32_2_G2           |
| r1363    | DW01_cmp6    | width=6    |               | eq_32_2_G2_G2        |
| r1365    | DW01_cmp6    | width=6    |               | eq_32_2_G3           |
| r1367    | DW01_cmp6    | width=6    |               | eq_32_2_G2_G3        |
| r1369    | DW01_cmp6    | width=6    |               | eq_32_2_G4           |
| r1371    | DW01_cmp6    | width=6    |               | eq_32_2_G2_G4        |
| r1373    | DW01_cmp6    | width=6    |               | eq_32_2_G5           |
| r1375    | DW01_cmp6    | width=6    |               | eq_32_2_G2_G5        |
| r1377    | DW01_cmp6    | width=6    |               | eq_32_2_G6           |
| r1379    | DW01_cmp6    | width=6    |               | eq_32_2_G2_G6        |
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
| genblk5[1].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk5[3].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk5[4].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk5[0].genblk1[0].encode_issue/sub_9                   |                |
|                    | DW01_dec         | cla                |                |
| genblk7[0].encode_dispatch/sub_9      |                    |                |
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
| r258     | DW01_inc     | width=7    |               | add_101 add_127      |
| r265     | DW01_dec     | width=8    |               | sub_71               |
| r267     | DW01_dec     | width=8    |               | sub_115              |
| r269     | DW01_sub     | width=7    |               | sub_139_aco          |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r258               | DW01_inc         | rpl                |                |
===============================================================================

 
****************************************
Design : Map_Table
****************************************

Resource Sharing Report for design Map_Table in file ../../verilog/Map_Table.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r189     | DW01_cmp6    | width=6    |               | map_cam/eq_18        |
| r191     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G2     |
| r193     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G3     |
| r195     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G4     |
| r197     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G5     |
| r199     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G6     |
| r201     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G7     |
| r203     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G8     |
| r205     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G9     |
| r207     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G10    |
| r209     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G11    |
| r211     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G12    |
| r213     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G13    |
| r215     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G14    |
| r217     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G15    |
| r219     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G16    |
| r221     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G17    |
| r223     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G18    |
| r225     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G19    |
| r227     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G20    |
| r229     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G21    |
| r231     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G22    |
| r233     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G23    |
| r235     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G24    |
| r237     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G25    |
| r239     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G26    |
| r241     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G27    |
| r243     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G28    |
| r245     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G29    |
| r247     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G30    |
| r249     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G31    |
| r251     | DW01_cmp6    | width=6    |               | map_cam/eq_18_G32    |
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
| r82      | DW01_inc     | width=5    |               | add_75               |
| r84      | DW01_sub     | width=5    |               | sub_134_aco          |
| r86      | DW01_cmp2    | width=5    |               | gte_135              |
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
| r302     | DW01_add     | width=32   |               | add_257 add_281      |
|          |              |            |               | add_300 add_320      |
|          |              |            |               | add_334 ras0/add_57  |
|          |              |            |               | ras0/add_60          |
| r303     | DW01_inc     | width=4    |               | add_274 add_280      |
|          |              |            |               | add_293 add_299      |
|          |              |            |               | add_313 add_319      |
|          |              |            |               | add_327 add_333      |
| r305     | DW01_cmp6    | width=6    |               | ras0/ne_36           |
|          |              |            |               | ras0/ne_67           |
| r318     | DW01_cmp6    | width=10   |               | btb0/eq_86           |
| r320     | DW01_dec     | width=7    |               | ras0/sub_57          |
| r322     | DW01_inc     | width=6    |               | ras0/add_61          |
| r324     | DW01_cmp6    | width=6    |               | ras0/eq_62           |
| r326     | DW01_inc     | width=6    |               | ras0/add_63          |
| r328     | DW01_sub     | width=6    |               | ras0/sub_68_aco      |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| r302               | DW01_add         | cla                |                |
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
| r172     | DW01_inc     | width=4    |               | add_42 add_54        |
| r193     | DW01_cmp6    | width=64   |               | eq_36                |
| r195     | DW01_cmp6    | width=64   |               | eq_36_G2             |
| r197     | DW01_cmp6    | width=64   |               | eq_36_G3             |
| r199     | DW01_cmp6    | width=64   |               | eq_36_G4             |
| r201     | DW01_cmp6    | width=64   |               | eq_36_G5             |
| r203     | DW01_cmp6    | width=64   |               | eq_36_G6             |
| r205     | DW01_cmp6    | width=64   |               | eq_36_G7             |
| r207     | DW01_cmp6    | width=64   |               | eq_36_G8             |
| r209     | DW01_cmp6    | width=64   |               | eq_36_G9             |
| r211     | DW01_cmp6    | width=64   |               | eq_36_G10            |
| r213     | DW01_cmp6    | width=64   |               | eq_36_G11            |
| r215     | DW01_cmp6    | width=64   |               | eq_36_G12            |
| r217     | DW01_cmp6    | width=64   |               | eq_36_G13            |
| r219     | DW01_cmp6    | width=64   |               | eq_36_G14            |
| r221     | DW01_cmp6    | width=64   |               | eq_36_G15            |
| r223     | DW01_cmp6    | width=4    |               | eq_42                |
| r225     | DW01_inc     | width=4    |               | add_66               |
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
| r736     | DW01_inc     | width=4    |               | add_103 add_155      |
| r738     | DW01_cmp2    | width=4    |               | lte_115 lte_115_G10  |
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
| r739     | DW01_cmp2    | width=4    |               | lte_115_2 lte_115_3  |
|          |              |            |               | lte_168_2 lte_168_3  |
| r740     | DW01_cmp2    | width=4    |               | lt_115_2 lt_115_3    |
|          |              |            |               | lt_168_2 lt_168_3    |
| r741     | DW01_cmp2    | width=4    |               | lt_115 lt_168        |
| r742     | DW01_cmp2    | width=4    |               | lte_115_2_G2         |
|          |              |            |               | lte_115_3_G2         |
|          |              |            |               | lte_168_2_I2         |
|          |              |            |               | lte_168_3_I2         |
| r743     | DW01_cmp2    | width=4    |               | lt_115_2_G2          |
|          |              |            |               | lt_115_3_G2          |
|          |              |            |               | lt_168_2_I2          |
|          |              |            |               | lt_168_3_I2          |
| r744     | DW01_cmp2    | width=4    |               | lt_115_G2 lt_168_I2  |
| r745     | DW01_cmp2    | width=4    |               | lte_115_2_G3         |
|          |              |            |               | lte_115_3_G3         |
|          |              |            |               | lte_168_2_I3         |
|          |              |            |               | lte_168_3_I3         |
| r746     | DW01_cmp2    | width=4    |               | lt_115_2_G3          |
|          |              |            |               | lt_115_3_G3          |
|          |              |            |               | lt_168_2_I3          |
|          |              |            |               | lt_168_3_I3          |
| r747     | DW01_cmp2    | width=4    |               | lt_115_G3 lt_168_I3  |
| r748     | DW01_cmp2    | width=4    |               | lte_115_2_G4         |
|          |              |            |               | lte_115_3_G4         |
|          |              |            |               | lte_168_2_I4         |
|          |              |            |               | lte_168_3_I4         |
| r749     | DW01_cmp2    | width=4    |               | lt_115_2_G4          |
|          |              |            |               | lt_115_3_G4          |
|          |              |            |               | lt_168_2_I4          |
|          |              |            |               | lt_168_3_I4          |
| r750     | DW01_cmp2    | width=4    |               | lt_115_G4 lt_168_I4  |
| r751     | DW01_cmp2    | width=4    |               | lte_115_2_G5         |
|          |              |            |               | lte_115_3_G5         |
|          |              |            |               | lte_168_2_I5         |
|          |              |            |               | lte_168_3_I5         |
| r752     | DW01_cmp2    | width=4    |               | lt_115_2_G5          |
|          |              |            |               | lt_115_3_G5          |
|          |              |            |               | lt_168_2_I5          |
|          |              |            |               | lt_168_3_I5          |
| r753     | DW01_cmp2    | width=4    |               | lt_115_G5 lt_168_I5  |
| r754     | DW01_cmp2    | width=4    |               | lte_115_2_G6         |
|          |              |            |               | lte_115_3_G6         |
|          |              |            |               | lte_168_2_I6         |
|          |              |            |               | lte_168_3_I6         |
| r755     | DW01_cmp2    | width=4    |               | lt_115_2_G6          |
|          |              |            |               | lt_115_3_G6          |
|          |              |            |               | lt_168_2_I6          |
|          |              |            |               | lt_168_3_I6          |
| r756     | DW01_cmp2    | width=4    |               | lt_115_G6 lt_168_I6  |
| r757     | DW01_cmp2    | width=4    |               | lte_115_2_G7         |
|          |              |            |               | lte_115_3_G7         |
|          |              |            |               | lte_168_2_I7         |
|          |              |            |               | lte_168_3_I7         |
| r758     | DW01_cmp2    | width=4    |               | lt_115_2_G7          |
|          |              |            |               | lt_115_3_G7          |
|          |              |            |               | lt_168_2_I7          |
|          |              |            |               | lt_168_3_I7          |
| r759     | DW01_cmp2    | width=4    |               | lt_115_G7 lt_168_I7  |
| r760     | DW01_cmp2    | width=4    |               | lte_115_2_G8         |
|          |              |            |               | lte_115_3_G8         |
|          |              |            |               | lte_168_2_I8         |
|          |              |            |               | lte_168_3_I8         |
| r761     | DW01_cmp2    | width=4    |               | lt_115_2_G8          |
|          |              |            |               | lt_115_3_G8          |
|          |              |            |               | lt_168_2_I8          |
|          |              |            |               | lt_168_3_I8          |
| r762     | DW01_cmp2    | width=4    |               | lt_115_G8 lt_168_I8  |
| r763     | DW01_cmp2    | width=4    |               | lte_115_2_G9         |
|          |              |            |               | lte_115_3_G9         |
|          |              |            |               | lte_168_2_I9         |
|          |              |            |               | lte_168_3_I9         |
| r764     | DW01_cmp2    | width=4    |               | lt_115_2_G9          |
|          |              |            |               | lt_115_3_G9          |
|          |              |            |               | lt_168_2_I9          |
|          |              |            |               | lt_168_3_I9          |
| r765     | DW01_cmp2    | width=4    |               | lt_115_G9 lt_168_I9  |
| r766     | DW01_cmp2    | width=4    |               | lte_115_2_G10        |
|          |              |            |               | lte_115_3_G10        |
|          |              |            |               | lte_168_2_I10        |
|          |              |            |               | lte_168_3_I10        |
| r767     | DW01_cmp2    | width=4    |               | lt_115_2_G10         |
|          |              |            |               | lt_115_3_G10         |
|          |              |            |               | lt_168_2_I10         |
|          |              |            |               | lt_168_3_I10         |
| r768     | DW01_cmp2    | width=4    |               | lt_115_G10           |
|          |              |            |               | lt_168_I10           |
| r769     | DW01_cmp2    | width=4    |               | lte_115_2_G11        |
|          |              |            |               | lte_115_3_G11        |
|          |              |            |               | lte_168_2_I11        |
|          |              |            |               | lte_168_3_I11        |
| r770     | DW01_cmp2    | width=4    |               | lt_115_2_G11         |
|          |              |            |               | lt_115_3_G11         |
|          |              |            |               | lt_168_2_I11         |
|          |              |            |               | lt_168_3_I11         |
| r771     | DW01_cmp2    | width=4    |               | lt_115_G11           |
|          |              |            |               | lt_168_I11           |
| r772     | DW01_cmp2    | width=4    |               | lte_115_2_G12        |
|          |              |            |               | lte_115_3_G12        |
|          |              |            |               | lte_168_2_I12        |
|          |              |            |               | lte_168_3_I12        |
| r773     | DW01_cmp2    | width=4    |               | lt_115_2_G12         |
|          |              |            |               | lt_115_3_G12         |
|          |              |            |               | lt_168_2_I12         |
|          |              |            |               | lt_168_3_I12         |
| r774     | DW01_cmp2    | width=4    |               | lt_115_G12           |
|          |              |            |               | lt_168_I12           |
| r775     | DW01_cmp2    | width=4    |               | lte_115_2_G13        |
|          |              |            |               | lte_115_3_G13        |
|          |              |            |               | lte_168_2_I13        |
|          |              |            |               | lte_168_3_I13        |
| r776     | DW01_cmp2    | width=4    |               | lt_115_2_G13         |
|          |              |            |               | lt_115_3_G13         |
|          |              |            |               | lt_168_2_I13         |
|          |              |            |               | lt_168_3_I13         |
| r777     | DW01_cmp2    | width=4    |               | lt_115_G13           |
|          |              |            |               | lt_168_I13           |
| r778     | DW01_cmp2    | width=4    |               | lte_115_2_G14        |
|          |              |            |               | lte_115_3_G14        |
|          |              |            |               | lte_168_2_I14        |
|          |              |            |               | lte_168_3_I14        |
| r779     | DW01_cmp2    | width=4    |               | lt_115_2_G14         |
|          |              |            |               | lt_115_3_G14         |
|          |              |            |               | lt_168_2_I14         |
|          |              |            |               | lt_168_3_I14         |
| r780     | DW01_cmp2    | width=4    |               | lt_115_G14           |
|          |              |            |               | lt_168_I14           |
| r781     | DW01_cmp2    | width=4    |               | lte_115_2_G15        |
|          |              |            |               | lte_115_3_G15        |
|          |              |            |               | lte_168_2_I15        |
|          |              |            |               | lte_168_3_I15        |
| r782     | DW01_cmp2    | width=4    |               | lt_115_2_G15         |
|          |              |            |               | lt_115_3_G15         |
|          |              |            |               | lt_168_2_I15         |
|          |              |            |               | lt_168_3_I15         |
| r783     | DW01_cmp2    | width=4    |               | lt_115_G15           |
|          |              |            |               | lt_168_I15           |
| r784     | DW01_cmp2    | width=4    |               | lte_115_2_G16        |
|          |              |            |               | lte_115_3_G16        |
|          |              |            |               | lte_168_2_I16        |
|          |              |            |               | lte_168_3_I16        |
| r785     | DW01_cmp2    | width=4    |               | lt_115_2_G16         |
|          |              |            |               | lt_115_3_G16         |
|          |              |            |               | lt_168_2_I16         |
|          |              |            |               | lt_168_3_I16         |
| r786     | DW01_cmp2    | width=4    |               | lt_115_G16           |
|          |              |            |               | lt_168_I16           |
| r829     | DW01_cmp6    | width=4    |               | eq_103               |
| r831     | DW01_inc     | width=4    |               | add_137              |
| r833     | DW01_cmp6    | width=4    |               | ne_155               |
| r835     | DW01_inc     | width=4    |               | add_160              |
| r837     | DW01_cmp6    | width=32   |               | eq_168               |
| r839     | DW01_cmp6    | width=32   |               | eq_168_I2            |
| r841     | DW01_cmp6    | width=32   |               | eq_168_I3            |
| r843     | DW01_cmp6    | width=32   |               | eq_168_I4            |
| r845     | DW01_cmp6    | width=32   |               | eq_168_I5            |
| r847     | DW01_cmp6    | width=32   |               | eq_168_I6            |
| r849     | DW01_cmp6    | width=32   |               | eq_168_I7            |
| r851     | DW01_cmp6    | width=32   |               | eq_168_I8            |
| r853     | DW01_cmp6    | width=32   |               | eq_168_I9            |
| r855     | DW01_cmp6    | width=32   |               | eq_168_I10           |
| r857     | DW01_cmp6    | width=32   |               | eq_168_I11           |
| r859     | DW01_cmp6    | width=32   |               | eq_168_I12           |
| r861     | DW01_cmp6    | width=32   |               | eq_168_I13           |
| r863     | DW01_cmp6    | width=32   |               | eq_168_I14           |
| r865     | DW01_cmp6    | width=32   |               | eq_168_I15           |
| r867     | DW01_cmp6    | width=32   |               | eq_168_I16           |
| r869     | DW01_dec     | width=16   |               | enc/sub_9            |
===============================================================================


Implementation Report
===============================================================================
|                    |                  | Current            | Set            |
| Cell               | Module           | Implementation     | Implementation |
===============================================================================
| eq_168_I12         | DW01_cmp6        | rpl                |                |
| eq_168_I13         | DW01_cmp6        | rpl                |                |
| eq_168_I14         | DW01_cmp6        | rpl                |                |
| eq_168_I15         | DW01_cmp6        | rpl                |                |
| eq_168             | DW01_cmp6        | rpl                |                |
| eq_168_I2          | DW01_cmp6        | rpl                |                |
| eq_168_I3          | DW01_cmp6        | rpl                |                |
| eq_168_I4          | DW01_cmp6        | rpl                |                |
| eq_168_I5          | DW01_cmp6        | rpl                |                |
| eq_168_I6          | DW01_cmp6        | rpl                |                |
| eq_168_I7          | DW01_cmp6        | rpl                |                |
| eq_168_I8          | DW01_cmp6        | rpl                |                |
| eq_168_I9          | DW01_cmp6        | rpl                |                |
| eq_168_I10         | DW01_cmp6        | rpl                |                |
| eq_168_I11         | DW01_cmp6        | rpl                |                |
===============================================================================

 
****************************************
Design : icache
****************************************

Resource Sharing Report for design icache in file ../../verilog/icache.v

===============================================================================
|          |              |            | Contained     |                      |
| Resource | Module       | Parameters | Resources     | Contained Operations |
===============================================================================
| r751     | DW01_cmp2    | width=3    |               | lt_135 lt_138        |
|          |              |            |               | lt_138_G2_G1         |
|          |              |            |               | lt_138_G3_G1         |
|          |              |            |               | lt_138_G4_G1         |
| r752     | DW01_cmp2    | width=3    |               | lt_138_G2            |
|          |              |            |               | lt_138_G2_G2         |
|          |              |            |               | lt_138_G3_G2         |
|          |              |            |               | lt_138_G4_G2         |
| r753     | DW01_cmp2    | width=3    |               | lt_138_G2_G3         |
|          |              |            |               | lt_138_G3            |
|          |              |            |               | lt_138_G3_G3         |
|          |              |            |               | lt_138_G4_G3         |
| r754     | DW01_cmp2    | width=3    |               | lt_138_G2_G4         |
|          |              |            |               | lt_138_G3_G4         |
|          |              |            |               | lt_138_G4            |
|          |              |            |               | lt_138_G4_G4         |
| r755     | DW01_cmp2    | width=3    |               | lt_138_G2_G5         |
|          |              |            |               | lt_138_G3_G5         |
|          |              |            |               | lt_138_G4_G5         |
|          |              |            |               | lt_138_G5            |
| r756     | DW01_cmp2    | width=3    |               | lt_138_G2_G6         |
|          |              |            |               | lt_138_G3_G6         |
|          |              |            |               | lt_138_G4_G6         |
|          |              |            |               | lt_138_G6            |
| r932     | DW01_add     | width=64   |               | add_154              |
| r934     | DW01_add     | width=64   |               | add_154_G2           |
| r936     | DW01_add     | width=64   |               | add_154_G3           |
| r938     | DW01_add     | width=64   |               | add_154_G4           |
| r940     | DW01_cmp6    | width=64   |               | ne_157               |
| r942     | DW01_cmp2    | width=3    |               | lt_172               |
| r944     | DW01_cmp6    | width=4    |               | eq_184               |
| r946     | DW01_inc     | width=3    |               | add_198              |
| r948     | DW01_sub     | width=3    |               | sub_203_aco          |
| r950     | DW01_cmp2    | width=3    |               | gt_204               |
| r952     | DW01_sub     | width=3    |               | sub_205_aco          |
| r954     | DW01_cmp2    | width=3    |               | gt_207               |
| r956     | DW01_sub     | width=3    |               | sub_208_aco          |
| r958     | DW01_inc     | width=3    |               | add_214              |
| r960     | DW01_cmp2    | width=3    |               | lt_229               |
| r962     | DW01_inc     | width=3    |               | add_233              |
| r964     | DW01_cmp2    | width=3    |               | lt_229_I2            |
| r966     | DW01_inc     | width=3    |               | add_233_I2           |
| r968     | DW01_cmp2    | width=3    |               | lt_229_I3            |
| r970     | DW01_inc     | width=3    |               | add_233_I3           |
| r972     | DW01_cmp2    | width=3    |               | lt_229_I4            |
| r974     | DW01_inc     | width=3    |               | add_233_I4           |
| r976     | DW01_cmp6    | width=3    |               | memory/eq_195        |
| r978     | DW01_cmp6    | width=10   |               | memory/eq_195_2      |
| r980     | DW01_cmp6    | width=3    |               | memory/eq_195_I2     |
| r982     | DW01_cmp6    | width=10   |               | memory/eq_195_2_I2   |
| r984     | DW01_cmp6    | width=3    |               | memory/eq_195_I3     |
| r986     | DW01_cmp6    | width=10   |               | memory/eq_195_2_I3   |
| r988     | DW01_cmp2    | width=2    |               | memory/gte_236       |
| r990     | DW01_cmp2    | width=2    |               | memory/gte_236_I2_I1 |
| r992     | DW01_inc     | width=2    |               | memory/add_257_I2_I1 |
| r994     | DW01_cmp2    | width=2    |               | memory/gte_287       |
| r996     | DW01_cmp2    | width=2    |               | memory/gte_287_I2_I1 |
| r998     | DW01_cmp2    | width=2    |               | memory/gte_287_I2    |
| r1000    | DW01_cmp2    | width=2    |               | memory/gte_287_I2_I2 |
| r1002    | DW01_cmp2    | width=2    |               | memory/gte_287_I3    |
| r1004    | DW01_cmp2    | width=2    |               | memory/gte_287_I2_I3 |
| r1006    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18 |
| r1008    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G2 |
| r1010    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G3 |
| r1012    | DW01_cmp6    | width=10   |               | memory/genblk1[0].rd_cam/eq_18_G4 |
| r1014    | DW01_dec     | width=4    |               | memory/genblk1[0].rd_enc/sub_9 |
| r1016    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18 |
| r1018    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G2 |
| r1020    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G3 |
| r1022    | DW01_cmp6    | width=10   |               | memory/genblk1[1].rd_cam/eq_18_G4 |
| r1024    | DW01_dec     | width=4    |               | memory/genblk1[1].rd_enc/sub_9 |
| r1026    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18 |
| r1028    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G2 |
| r1030    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G3 |
| r1032    | DW01_cmp6    | width=10   |               | memory/genblk1[2].rd_cam/eq_18_G4 |
| r1034    | DW01_dec     | width=4    |               | memory/genblk1[2].rd_enc/sub_9 |
| r1036    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18 |
| r1038    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G2 |
| r1040    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G3 |
| r1042    | DW01_cmp6    | width=10   |               | memory/genblk2[0].wr_cam/eq_18_G4 |
| r1044    | DW01_dec     | width=4    |               | memory/genblk2[0].wr_enc/sub_9 |
| r1046    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18   |
| r1048    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G1 |
| r1050    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G1 |
| r1052    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G1 |
| r1054    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G1 |
| r1056    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2 |
| r1058    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G2 |
| r1060    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G2 |
| r1062    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G2 |
| r1064    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G2 |
| r1066    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3 |
| r1068    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G3 |
| r1070    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G3 |
| r1072    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G3 |
| r1074    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G3 |
| r1076    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4 |
| r1078    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G4 |
| r1080    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G4 |
| r1082    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G4 |
| r1084    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G4 |
| r1086    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5 |
| r1088    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G5 |
| r1090    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G5 |
| r1092    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G5 |
| r1094    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G5 |
| r1096    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G6 |
| r1098    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G2_G1_G6 |
| r1100    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G3_G1_G6 |
| r1102    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G4_G1_G6 |
| r1104    | DW01_cmp6    | width=64   |               | PC_queue_cam/eq_18_G5_G1_G6 |
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
| add_154_G4         | DW01_add         | cla                |                |
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
| add_154_G3         | DW01_add         | cla                |                |
| add_154_G2         | DW01_add         | cla                |                |
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
| add_154            | DW01_add         | cla                |                |
| ne_157             | DW01_cmp6        | rpl                |                |
| PC_queue_cam/eq_18 | DW01_cmp6        | rpl                |                |
===============================================================================


No resource sharing information to report.
 
****************************************
Design : mem_controller
****************************************

No implementations to report
1
