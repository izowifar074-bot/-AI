# smartz:toggle/swarm — 翻转「群体协作」功能（开↔关）
scoreboard players add #swarm sz.ai 1
scoreboard players operation #swarm sz.ai %= #c2 sz.ai
execute if score #swarm sz.ai matches 1 run tellraw @a {"text":"[智能尸壳] 群体协作：开","color":"green"}
execute if score #swarm sz.ai matches 0 run tellraw @a {"text":"[智能尸壳] 群体协作：关","color":"red"}
