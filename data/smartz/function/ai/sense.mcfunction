# ============================================================
# smartz:ai/sense — 穿墙嗅探（executor = 尸壳，每 20gt 由 tick 调度）
# 原版尸壳索敌需要视线。用 0.0001 归因伤害触发 HurtByTarget，
# 对最近的可仇恨目标建立穿墙仇恨。
# 候选集 = 可探测玩家（未潜行 32 格 / 潜行 12 格）∪ 带 sz.enemy
# 标签的实体（32 格，排除自己）。取其中最近者。
# ============================================================
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 1 run return 0
tag @a[distance=..32,gamemode=!creative,gamemode=!spectator,predicate=!smartz:sneaking] add sz.cand
tag @a[distance=..12,gamemode=!creative,gamemode=!spectator,predicate=smartz:sneaking] add sz.cand
tag @e[tag=sz.enemy,distance=0.1..32] add sz.cand
execute if entity @e[tag=sz.cand] run damage @s 0.0001 minecraft:generic by @e[tag=sz.cand,sort=nearest,limit=1]
tag @e[tag=sz.cand] remove sz.cand
