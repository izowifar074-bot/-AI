# smartz:config/pvp_on — 开启 pvp 功能
# 职责：#pvp sz.config 设为 1，并 tellraw 提示已开启
scoreboard players set #pvp sz.config 1
tellraw @a {"text":"[智能僵尸] PVP 功能已开启","color":"green"}
