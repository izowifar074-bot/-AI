# ============================================================
# smartz:tick — 每游戏刻执行（由 minecraft:tick 触发）
# 分频调度（取模实现）：
#   1gt   pvp/attack（控距步法+出手）
#   4gt   ai/core（各尸壳主循环）
#   8gt   ai/stuck（受阻检测与地形决策）
#   20gt  ai/sense（穿墙嗅探）、swarm/alert（警报）、孤儿锚点清理
# 仇恨对象 = 存活模式玩家 ∪ 带 sz.enemy 标签的实体。每刻先把它们
# 打上瞬时 sz.tgtable，各调度以"附近有 sz.tgtable"为门控——只有
# 值得追击的目标在范围内时才运行 AI。无 sz.enemy 标签时该集合
# 恰为有效玩家，行为与旧版完全一致。
# 初始化判定用"sz.dmin 未设置"而非标签：带旧版标签但缺新记分板
# 状态的尸壳（升级场景）也会被重新初始化，否则其 AI 残废。
# ============================================================
scoreboard players add #tick sz.ai 1
execute if score #master sz.ai matches 0 run return 0
tag @a[gamemode=!creative,gamemode=!spectator] add sz.tgtable
tag @e[tag=sz.enemy] add sz.tgtable
execute as @e[type=minecraft:husk] at @s unless score @s sz.dmin = @s sz.dmin run function smartz:init
execute if score #pvp sz.ai matches 1 as @e[type=minecraft:husk,tag=sz.init] at @s if entity @e[tag=sz.tgtable,distance=..8] run function smartz:ai/pvp/attack
scoreboard players operation #mod4 sz.ai = #tick sz.ai
scoreboard players operation #mod4 sz.ai %= #c4 sz.ai
execute if score #mod4 sz.ai matches 0 as @e[type=minecraft:husk,tag=sz.init] at @s if entity @e[tag=sz.tgtable,distance=..48] run function smartz:ai/core
scoreboard players operation #mod8 sz.ai = #tick sz.ai
scoreboard players operation #mod8 sz.ai %= #c8 sz.ai
execute if score #mod8 sz.ai matches 0 as @e[type=minecraft:husk,tag=sz.init] at @s if entity @e[tag=sz.tgtable,distance=..48] run function smartz:ai/stuck
scoreboard players operation #mod20 sz.ai = #tick sz.ai
scoreboard players operation #mod20 sz.ai %= #c20 sz.ai
execute if score #mod20 sz.ai matches 0 as @e[type=minecraft:husk,tag=sz.init] at @s if entity @e[tag=sz.tgtable,distance=..48] run function smartz:ai/sense
execute if score #mod20 sz.ai matches 0 as @e[type=minecraft:husk,tag=sz.init] at @s if entity @e[tag=sz.tgtable,distance=..48] run function smartz:ai/swarm/alert
execute if score #mod20 sz.ai matches 0 as @e[type=minecraft:marker,tag=sz.target] at @s unless entity @e[type=minecraft:husk,tag=sz.mining,distance=..8] run kill @s
tag @e[tag=sz.tgtable] remove sz.tgtable
