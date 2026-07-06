# ============================================================
# smartz:ai/build/bridge — 搭桥过沟（executor = 僵尸，由 stuck 触发）
# 职责：
#   1. 前置：面向目标方向前方 1 格空气、前下方 1 格也是空气（悬空）、sz.cool = 0
#   2. 执行：在前下方（局部坐标 ^ ^-1 ^1 对应位置）setblock cobblestone
#   3. 播放放置音效 + 短冷却
#   4. 仅在与目标大致同高度时搭桥（高度差 <= 1），否则应走 pillar 逻辑
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
execute anchored eyes positioned ^ ^ ^1 align xyz if block ~ ~ ~ minecraft:air if block ~ ~-1 ~ minecraft:air if block ~ ~-2 ~ minecraft:air run playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1
execute anchored eyes positioned ^ ^ ^1 align xyz if block ~ ~ ~ minecraft:air if block ~ ~-1 ~ minecraft:air if block ~ ~-2 ~ minecraft:air run scoreboard players set @s sz.cool 2
execute anchored eyes positioned ^ ^ ^1 align xyz if block ~ ~ ~ minecraft:air if block ~ ~-1 ~ minecraft:air if block ~ ~-2 ~ minecraft:air run setblock ~ ~-2 ~ minecraft:cobblestone