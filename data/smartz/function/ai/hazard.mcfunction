# ============================================================
# smartz:ai/hazard — 危险规避（executor = 僵尸）
# 职责：
#   1. 检查脚前 1 格（朝向目标方向）是否为：岩浆/火/灵魂火/仙人掌/细雪/甜浆果丛
#   2. 是 → 施加反向 Motion 后退，并短冷却防止来回抽搐
#   3. 用局部坐标 ^ ^ ^1 配合 execute if block 检查
# ============================================================
scoreboard players set #haz sz.stuck 0
execute positioned ^ ^ ^0.8 if block ~ ~ ~ #smartz:danger run scoreboard players set #haz sz.stuck 1
execute positioned ^ ^ ^0.8 if block ~ ~-1 ~ #smartz:danger run scoreboard players set #haz sz.stuck 1
execute if score #haz sz.stuck matches 1 run tp @s ^ ^ ^-0.5