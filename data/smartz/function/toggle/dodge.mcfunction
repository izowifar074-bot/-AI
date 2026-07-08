# smartz:toggle/dodge — 翻转「闪避走位」功能（开↔关）
scoreboard players add #dodge sz.ai 1
scoreboard players operation #dodge sz.ai %= #c2 sz.ai
execute if score #dodge sz.ai matches 1 run tellraw @a {"text":"[智能尸壳] 闪避走位：开","color":"green"}
execute if score #dodge sz.ai matches 0 run tellraw @a {"text":"[智能尸壳] 闪避走位：关","color":"red"}
