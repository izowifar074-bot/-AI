# smartz:config/dodge_on — 开启 dodge 功能
# 职责：#dodge sz.config 设为 1，并 tellraw 提示已开启
scoreboard players set #dodge sz.config 1
tellraw @a {"text":"[智能僵尸] 闪避功能已开启","color":"green"}