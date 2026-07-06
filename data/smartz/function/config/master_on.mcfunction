# smartz:config/master_on — 开启 master 功能
# 职责：#master sz.config 设为 1，并 tellraw 提示已开启
scoreboard players set #master sz.config 1
tellraw @a {"text":"[智能僵尸] 总开关已开启","color":"green"}