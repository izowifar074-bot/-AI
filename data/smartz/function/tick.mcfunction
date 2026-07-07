# ============================================================
# smartz:tick — 每游戏刻执行（由 minecraft:tick 触发）
# 分频调度（取模实现）：
#   1gt   pvp/attack（控距步法+出手，8 格内有存活模式玩家才派发）
#   4gt   ai/core（各僵尸主循环）
#   8gt   ai/stuck（受阻检测与地形决策）
#   20gt  ai/sense（穿墙嗅探）、swarm/alert（警报）、孤儿锚点清理
# 所有僵尸选择器均带 48 格玩家距离限制。
# 初始化判定用"sz.dmin 未设置"而非标签：带旧版标签但缺新记分板
# 状态的僵尸（升级场景）也会被重新初始化，否则其 AI 残废。
# ============================================================
scoreboard players add #tick sz.ai 1
execute if score #master sz.ai matches 0 run return 0
execute as @e[type=minecraft:zombie] at @s unless score @s sz.dmin = @s sz.dmin run function smartz:init
execute if score #pvp sz.ai matches 1 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..8,gamemode=!creative,gamemode=!spectator] run function smartz:ai/pvp/attack
scoreboard players operation #mod4 sz.ai = #tick sz.ai
scoreboard players operation #mod4 sz.ai %= #c4 sz.ai
execute if score #mod4 sz.ai matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/core
scoreboard players operation #mod8 sz.ai = #tick sz.ai
scoreboard players operation #mod8 sz.ai %= #c8 sz.ai
execute if score #mod8 sz.ai matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/stuck
scoreboard players operation #mod20 sz.ai = #tick sz.ai
scoreboard players operation #mod20 sz.ai %= #c20 sz.ai
execute if score #mod20 sz.ai matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/sense
execute if score #mod20 sz.ai matches 0 as @e[type=minecraft:zombie,tag=sz.init] at @s if entity @a[distance=..48] run function smartz:ai/swarm/alert
execute if score #mod20 sz.ai matches 0 as @e[type=minecraft:marker,tag=sz.target] at @s unless entity @e[type=minecraft:zombie,tag=sz.mining,distance=..8] run kill @s
