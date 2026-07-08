# ============================================================
# smartz:ai/descend — 跳崖下追（executor = 尸壳，目标低 >=2 时由 stuck 调用）
# 四邻找开放落沿（只考虑不背向目标的方向）：可进入且下方悬空 →
# drop_probe 向下扫描落点（允许深度 = |dh|+3 上限 16，危险/深渊
# 否决，水面/地面通过）→ 一步横移出沿，重力接管。
# 成功置 #jump=1；全部否决则由 stuck 的迂回路线兜底。
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
scoreboard players operation #drop sz.ai = #dh sz.ai
scoreboard players operation #drop sz.ai *= #cm1 sz.ai
scoreboard players add #drop sz.ai 3
execute if score #drop sz.ai matches 17.. run scoreboard players set #drop sz.ai 16
scoreboard players operation #sdx sz.ai = #tx sz.ai
scoreboard players operation #sdx sz.ai -= #zx sz.ai
scoreboard players operation #sdz sz.ai = #tz sz.ai
scoreboard players operation #sdz sz.ai -= #zz sz.ai
scoreboard players set #land sz.ai 0
scoreboard players operation #dropw sz.ai = #drop sz.ai
execute if score #jump sz.ai matches 0 if score #sdx sz.ai matches 0.. align xyz positioned ~1.5 ~ ~0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.ai matches 0 if score #land sz.ai matches 1 align xyz run tp @s ~1.5 ~ ~0.5
execute if score #land sz.ai matches 1 run scoreboard players set #jump sz.ai 1
scoreboard players set #land sz.ai 0
scoreboard players operation #dropw sz.ai = #drop sz.ai
execute if score #jump sz.ai matches 0 if score #sdx sz.ai matches ..0 align xyz positioned ~-0.5 ~ ~0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.ai matches 0 if score #land sz.ai matches 1 align xyz run tp @s ~-0.5 ~ ~0.5
execute if score #land sz.ai matches 1 run scoreboard players set #jump sz.ai 1
scoreboard players set #land sz.ai 0
scoreboard players operation #dropw sz.ai = #drop sz.ai
execute if score #jump sz.ai matches 0 if score #sdz sz.ai matches 0.. align xyz positioned ~0.5 ~ ~1.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.ai matches 0 if score #land sz.ai matches 1 align xyz run tp @s ~0.5 ~ ~1.5
execute if score #land sz.ai matches 1 run scoreboard players set #jump sz.ai 1
scoreboard players set #land sz.ai 0
scoreboard players operation #dropw sz.ai = #drop sz.ai
execute if score #jump sz.ai matches 0 if score #sdz sz.ai matches ..0 align xyz positioned ~0.5 ~ ~-0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.ai matches 0 if score #land sz.ai matches 1 align xyz run tp @s ~0.5 ~ ~-0.5
execute if score #land sz.ai matches 1 run scoreboard players set #jump sz.ai 1
execute if score #jump sz.ai matches 1 run function smartz:ai/climb_off
execute if score #jump sz.ai matches 1 run tag @s remove sz.pave
execute if score #jump sz.ai matches 1 run scoreboard players set @s sz.cool 4
