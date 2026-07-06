# ============================================================
# smartz:ai/sense — 穿墙嗅探（executor = 僵尸，每 20gt 由 tick 调度）
# 原版僵尸锁定玩家需要视线，隔墙永远不会有攻击目标。
# 本函数用"微量伤害归因于玩家"制造仇恨：伤害 0.0001 不掉血，
# 但会触发 HurtByTarget，让僵尸穿墙锁定玩家，并惊动周围同类。
# 潜行的玩家只在 12 格内会暴露，未潜行 32 格。
# ============================================================
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 1 run return 0
damage @s 0.0001 minecraft:generic by @p[distance=..32,gamemode=!creative,gamemode=!spectator,predicate=!smartz:sneaking]
damage @s 0.0001 minecraft:generic by @p[distance=..12,gamemode=!creative,gamemode=!spectator,predicate=smartz:sneaking]
