# smartz:config/swarm_off — 关闭 swarm 功能
# 职责：#swarm sz.config 设为 0，并 tellraw 提示已关闭
scoreboard players set #swarm sz.config 0
tellraw @a {"text":"[智能僵尸] 群体协作功能已关闭","color":"red"}