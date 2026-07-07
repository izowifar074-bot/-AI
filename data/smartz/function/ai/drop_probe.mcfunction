# ============================================================
# smartz:ai/drop_probe — 落点向下扫描（executor = 僵尸，位置 = 扫描点）
# 危险方块(#smartz:danger) → #land=-1 否决；水/实体地面 → #land=1；
# 预算 #dropw 用尽未见地 → 深渊，保持 0 否决。
# ============================================================
execute if block ~ ~ ~ #smartz:danger run scoreboard players set #land sz.ai -1
execute if score #land sz.ai matches -1 run return 0
execute if block ~ ~ ~ minecraft:water run scoreboard players set #land sz.ai 1
execute unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set #land sz.ai 1
execute if score #land sz.ai matches 1 run return 0
scoreboard players remove #dropw sz.ai 1
execute if score #dropw sz.ai matches ..0 run return 0
execute positioned ~ ~-1 ~ run function smartz:ai/drop_probe
