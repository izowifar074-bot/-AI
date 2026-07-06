# ============================================================
# smartz:ai/build/pillar — 垫方块爬高（executor = 僵尸，由 stuck 触发）
# 职责：
#   1. 前置：目标在上方 >= 2 格、sz.cool = 0、自身脚下是实体方块、头顶 2 格是空气
#   2. 执行：tp @s ~ ~1 ~ 后在新位置脚下 setblock ~ ~-1 ~ cobblestone
#   3. 播放放置音效 + 设置短冷却（约 0.5~1 秒，模拟玩家搭柱节奏）
#   4. 安全检查：目标位置必须原本是空气才放置，绝不覆盖已有方块
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
execute if block ~ ~-1 ~ minecraft:air run return 0
execute if block ~ ~-1 ~ minecraft:cave_air run return 0
execute unless block ~ ~2 ~ minecraft:air run return 0
execute unless block ~ ~ ~ minecraft:air run return 0
tp @s ~ ~1 ~
setblock ~ ~ ~ minecraft:cobblestone
playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1
scoreboard players set @s sz.cool 2