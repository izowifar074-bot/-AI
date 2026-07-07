# ============================================================
# smartz:ai/drop_probe — 落点向下扫描（executor = 僵尸，位置 = 扫描点）
# 由 descend 发起，逐格向下探测：
#   - 危险方块（岩浆/火/岩浆块等 #smartz:danger）→ #land = -1 否决
#   - 水 → #land = 1（水面缓冲，最理想落点）
#   - 实体方块 → #land = 1（普通地面）
#   - 预算 #dropw 用尽仍未见地 → 深渊，保持 #land = 0 否决
# ============================================================
execute if block ~ ~ ~ #smartz:danger run scoreboard players set #land sz.stuck -1
execute if score #land sz.stuck matches -1 run return 0
execute if block ~ ~ ~ minecraft:water run scoreboard players set #land sz.stuck 1
execute unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set #land sz.stuck 1
execute if score #land sz.stuck matches 1 run return 0
scoreboard players remove #dropw sz.stuck 1
execute if score #dropw sz.stuck matches ..0 run return 0
execute positioned ~ ~-1 ~ run function smartz:ai/drop_probe
