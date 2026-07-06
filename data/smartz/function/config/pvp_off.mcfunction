# smartz:config/pvp_off — 关闭 pvp 功能
# 职责：#pvp sz.config 设为 0，并 tellraw 提示已关闭
scoreboard players set #pvp sz.config 0
tellraw @a {"text":"[智能僵尸] PVP 功能已关闭","color":"red"}
