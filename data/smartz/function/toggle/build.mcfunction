# smartz:toggle/build — 翻转「建造」功能（开↔关）
scoreboard players add #build sz.ai 1
scoreboard players operation #build sz.ai %= #c2 sz.ai
execute if score #build sz.ai matches 1 run tellraw @a {"text":"[智能僵尸] 建造：开","color":"green"}
execute if score #build sz.ai matches 0 run tellraw @a {"text":"[智能僵尸] 建造：关","color":"red"}
