# ============================================================
# smartz:ai/sense — 穿墙嗅探（executor = 僵尸，每 20gt 由 tick 调度）
# 原版僵尸索敌需要视线。用 0.0001 归因伤害触发 HurtByTarget，
# 建立穿墙仇恨并惊动同类。未潜行 32 格，潜行 12 格。
# ============================================================
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 1 run return 0
damage @s 0.0001 minecraft:generic by @p[distance=..32,gamemode=!creative,gamemode=!spectator,predicate=!smartz:sneaking]
damage @s 0.0001 minecraft:generic by @p[distance=..12,gamemode=!creative,gamemode=!spectator,predicate=smartz:sneaking]
