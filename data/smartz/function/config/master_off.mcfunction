# smartz:config/master_off — 关闭 master 功能
# 职责：#master sz.config 设为 0，并 tellraw 提示已关闭
scoreboard players set #master sz.config 0
tellraw @a {"text":"[智能僵尸] 总开关已关闭","color":"red"}