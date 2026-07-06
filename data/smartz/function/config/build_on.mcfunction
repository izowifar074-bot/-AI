# smartz:config/build_on — 开启 build 功能
# 职责：#build sz.config 设为 1，并 tellraw 提示已开启
scoreboard players set #build sz.config 1
tellraw @a {"text":"[智能僵尸] 建造功能已开启","color":"green"}