# smartz:config/dig_off — 关闭 dig 功能
# 职责：#dig sz.config 设为 0，并 tellraw 提示已关闭
scoreboard players set #dig sz.config 0
tellraw @a {"text":"[智能僵尸] 挖掘功能已关闭","color":"red"}