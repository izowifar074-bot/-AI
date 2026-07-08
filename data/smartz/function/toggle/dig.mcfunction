# smartz:toggle/dig — 翻转「挖掘」功能（开↔关）
scoreboard players add #dig sz.ai 1
scoreboard players operation #dig sz.ai %= #c2 sz.ai
execute if score #dig sz.ai matches 1 run tellraw @a {"text":"[智能尸壳] 挖掘：开","color":"green"}
execute if score #dig sz.ai matches 0 run tellraw @a {"text":"[智能尸壳] 挖掘：关","color":"red"}
