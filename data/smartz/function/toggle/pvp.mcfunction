# smartz:toggle/pvp — 翻转「PVP」功能（开↔关）
scoreboard players add #pvp sz.ai 1
scoreboard players operation #pvp sz.ai %= #c2 sz.ai
execute if score #pvp sz.ai matches 1 run tellraw @a {"text":"[智能尸壳] PVP：开","color":"green"}
execute if score #pvp sz.ai matches 0 run tellraw @a {"text":"[智能尸壳] PVP：关","color":"red"}
