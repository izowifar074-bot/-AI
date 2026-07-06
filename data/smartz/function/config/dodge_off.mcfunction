# smartz:config/dodge_off — 关闭 dodge 功能
# 职责：#dodge sz.config 设为 0，并 tellraw 提示已关闭
scoreboard players set #dodge sz.config 0
tellraw @a {"text":"[智能僵尸] 闪避功能已关闭","color":"red"}