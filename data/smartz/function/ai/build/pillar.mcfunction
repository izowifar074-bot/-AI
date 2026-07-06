# ============================================================
# smartz:ai/build/pillar — 垫方块爬高（executor = 僵尸，由 stuck 触发）
# 职责：
#   1. 前置：目标在上方 >= 2 格、sz.cool = 0、脚下踩着实体方块、头顶有净空
#   2. 执行：tp @s ~ ~1 ~ 后在原脚坐标 setblock cobblestone（tp 不改变位置上下文）
#   3. 播放放置音效 + 设置短冷却，模拟玩家搭柱节奏
#   4. 方块条件用 #minecraft:replaceable 判定：草丛/积雪/水等可被替换的
#      方块不会否决垫高（旧版要求纯 air，站在草上就会失效）
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
execute if block ~ ~-1 ~ #minecraft:replaceable run return 0
execute unless block ~ ~2 ~ #minecraft:replaceable run return 0
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
tp @s ~ ~1 ~
setblock ~ ~ ~ minecraft:cobblestone
playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1
scoreboard players set @s sz.cool 2