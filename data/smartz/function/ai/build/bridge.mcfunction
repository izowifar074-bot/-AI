# ============================================================
# smartz:ai/build/bridge — 定向搭路（executor = 僵尸，由 stuck 触发）
# 网格步进：按"僵尸→目标"坐标差取主轴（|dx|>=|dz| 走 x 否则走 z），
# 逐格朝玩家铺路。放置条件：支撑位有洞【且洞深>=2】+ 脚部可通行
# （1 格坎原版自己能走，深度条件防止起伏地形沿途乱铺）。
# 踏步跟进：放置成功且落点两格无阻挡 → tp 到新方块中心，
# "放一块走一步"，原版寻路无机会把僵尸带歪。
# #bplaced 为本函数私有成功标记；成功同步置 #built 与 tag sz.pave。
# 依赖 stuck 算好的 #tx/#zx/#tz/#zz。
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
scoreboard players operation #sdx sz.ai = #tx sz.ai
scoreboard players operation #sdx sz.ai -= #zx sz.ai
scoreboard players operation #sdz sz.ai = #tz sz.ai
scoreboard players operation #sdz sz.ai -= #zz sz.ai
scoreboard players set #stepx sz.ai 0
scoreboard players set #stepz sz.ai 0
execute if score #sdx sz.ai matches 1.. run scoreboard players set #stepx sz.ai 1
execute if score #sdx sz.ai matches ..-1 run scoreboard players set #stepx sz.ai -1
execute if score #sdz sz.ai matches 1.. run scoreboard players set #stepz sz.ai 1
execute if score #sdz sz.ai matches ..-1 run scoreboard players set #stepz sz.ai -1
scoreboard players operation #adx sz.ai = #sdx sz.ai
execute if score #adx sz.ai matches ..-1 run scoreboard players operation #adx sz.ai *= #cm1 sz.ai
scoreboard players operation #adz sz.ai = #sdz sz.ai
execute if score #adz sz.ai matches ..-1 run scoreboard players operation #adz sz.ai *= #cm1 sz.ai
execute if score #adx sz.ai < #adz sz.ai run scoreboard players set #stepx sz.ai 0
execute unless score #adx sz.ai < #adz sz.ai run scoreboard players set #stepz sz.ai 0
scoreboard players set #bplaced sz.ai 0
execute align xyz if score #stepx sz.ai matches 1 if block ~1 ~-1 ~ #minecraft:replaceable if block ~1 ~-2 ~ #minecraft:replaceable if block ~1 ~ ~ #minecraft:replaceable store success score #bplaced sz.ai run setblock ~1 ~-1 ~ minecraft:cobblestone
execute align xyz if score #stepx sz.ai matches -1 if block ~-1 ~-1 ~ #minecraft:replaceable if block ~-1 ~-2 ~ #minecraft:replaceable if block ~-1 ~ ~ #minecraft:replaceable store success score #bplaced sz.ai run setblock ~-1 ~-1 ~ minecraft:cobblestone
execute align xyz if score #stepz sz.ai matches 1 if block ~ ~-1 ~1 #minecraft:replaceable if block ~ ~-2 ~1 #minecraft:replaceable if block ~ ~ ~1 #minecraft:replaceable store success score #bplaced sz.ai run setblock ~ ~-1 ~1 minecraft:cobblestone
execute align xyz if score #stepz sz.ai matches -1 if block ~ ~-1 ~-1 #minecraft:replaceable if block ~ ~-2 ~-1 #minecraft:replaceable if block ~ ~ ~-1 #minecraft:replaceable store success score #bplaced sz.ai run setblock ~ ~-1 ~-1 minecraft:cobblestone
execute if score #bplaced sz.ai matches 0 run tag @s remove sz.pave
execute if score #bplaced sz.ai matches 0 run return 0
scoreboard players set #built sz.ai 1
tag @s add sz.pave
execute if score #stepx sz.ai matches 1 align xyz if block ~1 ~ ~ #minecraft:replaceable if block ~1 ~1 ~ #minecraft:replaceable run tp @s ~1.5 ~ ~0.5
execute if score #stepx sz.ai matches -1 align xyz if block ~-1 ~ ~ #minecraft:replaceable if block ~-1 ~1 ~ #minecraft:replaceable run tp @s ~-0.5 ~ ~0.5
execute if score #stepz sz.ai matches 1 align xyz if block ~ ~ ~1 #minecraft:replaceable if block ~ ~1 ~1 #minecraft:replaceable run tp @s ~0.5 ~ ~1.5
execute if score #stepz sz.ai matches -1 align xyz if block ~ ~ ~-1 #minecraft:replaceable if block ~ ~1 ~-1 #minecraft:replaceable run tp @s ~0.5 ~ ~-0.5
playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1
scoreboard players set @s sz.cool 2
