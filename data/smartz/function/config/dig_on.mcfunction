# smartz:config/dig_on — 开启 dig 功能
# 职责：#dig sz.config 设为 1，并 tellraw 提示已开启
scoreboard players set #dig sz.config 1
tellraw @a {"text":"[智能僵尸] 挖掘功能已开启","color":"green"}