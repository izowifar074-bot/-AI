# ============================================================
# smartz:ai/build/pillar — 垫方块爬高（executor = 僵尸）
# 前置：冷却就绪、脚下踩实、头顶净空、脚位可替换。
# tp 到方块中心上方 1 格（居中防滑落），再在原脚坐标放方块
# （tp 不改变位置上下文）。成功置 #built=1。
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
execute if block ~ ~-1 ~ #minecraft:replaceable run return 0
execute unless block ~ ~2 ~ #minecraft:replaceable run return 0
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
execute align xyz run tp @s ~0.5 ~1 ~0.5
execute align xyz run setblock ~ ~ ~ minecraft:cobblestone
playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1
scoreboard players set @s sz.cool 1
scoreboard players set #built sz.ai 1
