# ============================================================
# smartz:tick — 每游戏刻执行（由 minecraft:tick 触发）
# 职责（性能核心，分频调度）：
#   1. #tick sz.clock += 1
#   2. 若总开关 #master sz.config = 0 则直接 return
#   3. 对未初始化僵尸执行 init（每刻都查，选择器带 tag=!sz.init 限制）
#   4. 每 4gt：对玩家 48 格内的已初始化僵尸执行 ai/core
#   5. 每 8gt：执行 ai/stuck（卡住检测）
#   6. 每 20gt：执行 ai/sense（穿墙嗅探索敌）、ai/swarm/alert（警报广播）
#   分频用 scoreboard players operation 取模实现
# ============================================================
scoreboard players add #tick sz.clock 1
execute if score #master sz.config matches 0 run return 0
execute as @e[type=minecraft:zombie,tag=!sz.init] at @s run function smartz:init
execute if score #pvp sz.config matches 1 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..8,gamemode=!creative,gamemode=!spectator] run function smartz:ai/pvp/attack
scoreboard players operation #mod4 sz.clock = #tick sz.clock
scoreboard players operation #mod4 sz.clock %= #c4 sz.clock
execute if score #mod4 sz.clock matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/core
scoreboard players operation #mod8 sz.clock = #tick sz.clock
scoreboard players operation #mod8 sz.clock %= #c8 sz.clock
execute if score #mod8 sz.clock matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/stuck
scoreboard players operation #mod20 sz.clock = #tick sz.clock
scoreboard players operation #mod20 sz.clock %= #c20 sz.clock
execute if score #mod20 sz.clock matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/sense
execute if score #mod20 sz.clock matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/swarm/alert
execute if score #mod20 sz.clock matches 0 as @e[type=minecraft:marker,tag=sz.target] at @s unless entity @e[type=minecraft:zombie,tag=sz.mining,distance=..8] run kill @s