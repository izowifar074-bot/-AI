# smartz:config/swarm_on — 开启 swarm 功能
# 职责：#swarm sz.config 设为 1，并 tellraw 提示已开启
scoreboard players set #swarm sz.config 1
tellraw @a {"text":"[智能僵尸] 群体协作功能已开启","color":"green"}