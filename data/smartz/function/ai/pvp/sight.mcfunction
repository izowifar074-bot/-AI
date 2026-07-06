# ============================================================
# smartz:ai/pvp/sight — 视线检查射线（executor = 僵尸，位置 = 步进点）
# 由 bow 发起：从僵尸眼睛朝目标（tag=sz.tgt 的玩家）逐 1 格推进，
# 撞到实体方块 = 无视线终止；步进点进入目标 1.5 格内 = #los 置 1。
# 步数预算 #sray 由入口设置（34 步覆盖 32 格射程）。
# ============================================================
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
execute if entity @p[tag=sz.tgt,distance=..1.5] run scoreboard players set #los sz.stuck 1
execute if score #los sz.stuck matches 1 run return 0
scoreboard players remove #sray sz.stuck 1
execute if score #sray sz.stuck matches ..0 run return 0
execute positioned ^ ^ ^1 run function smartz:ai/pvp/sight
