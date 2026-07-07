# smartz:toggle/master — 翻转「总开关」功能（开↔关）
scoreboard players add #master sz.ai 1
scoreboard players operation #master sz.ai %= #c2 sz.ai
execute if score #master sz.ai matches 1 run tellraw @a {"text":"[智能僵尸] 总开关：开","color":"green"}
execute if score #master sz.ai matches 0 run tellraw @a {"text":"[智能僵尸] 总开关：关","color":"red"}
