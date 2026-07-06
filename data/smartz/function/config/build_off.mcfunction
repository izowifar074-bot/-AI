# smartz:config/build_off — 关闭 build 功能
# 职责：#build sz.config 设为 0，并 tellraw 提示已关闭
scoreboard players set #build sz.config 0
tellraw @a {"text":"[智能僵尸] 建造功能已关闭","color":"red"}