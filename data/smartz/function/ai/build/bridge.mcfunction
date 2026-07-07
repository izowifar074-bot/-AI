# ============================================================
# smartz:ai/build/bridge — 定向搭路（executor = 僵尸，由 stuck 触发）
# 网格化步进：用"僵尸→目标"的坐标差取主轴方向（|dx|>=|dz| 走
# x 轴，否则走 z 轴），逐格朝玩家方向铺路，天然走出折线路径。
# 放置条件：支撑位是可替换方块（有洞）+ 脚部一格可通行。
# 踏步跟进：放置成功后把僵尸挪到新方块中心（目的地脚部与头部
# 无阻挡才挪）——搭路变成确定性的"放一块走一步"，原版寻路没有
# 机会把僵尸带歪或带下桥。
# 依赖：stuck 已算好 #tx/#zx/#tz/#zz（自身与目标的整数坐标）。
# #bplaced 为本函数私有成功标记（不与 pillar 的 #built 混用，
# 防止升级档中 pillar 的成功误触发这里的踏步）；成功时同步置
# #built = 1 供 stuck 跳过挖掘分支。
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
# 目标方向的水平分量
scoreboard players operation #sdx sz.posx = #tx sz.posx
scoreboard players operation #sdx sz.posx -= #zx sz.posx
scoreboard players operation #sdz sz.posz = #tz sz.posz
scoreboard players operation #sdz sz.posz -= #zz sz.posz
# 各轴步进符号
scoreboard players set #stepx sz.posx 0
scoreboard players set #stepz sz.posz 0
execute if score #sdx sz.posx matches 1.. run scoreboard players set #stepx sz.posx 1
execute if score #sdx sz.posx matches ..-1 run scoreboard players set #stepx sz.posx -1
execute if score #sdz sz.posz matches 1.. run scoreboard players set #stepz sz.posz 1
execute if score #sdz sz.posz matches ..-1 run scoreboard players set #stepz sz.posz -1
# 主轴判定：|dx| < |dz| 时走 z 轴，否则走 x 轴
scoreboard players operation #adx sz.posx = #sdx sz.posx
execute if score #adx sz.posx matches ..-1 run scoreboard players operation #adx sz.posx *= #cm1 sz.clock
scoreboard players operation #adz sz.posz = #sdz sz.posz
execute if score #adz sz.posz matches ..-1 run scoreboard players operation #adz sz.posz *= #cm1 sz.clock
execute if score #adx sz.posx < #adz sz.posz run scoreboard players set #stepx sz.posx 0
execute unless score #adx sz.posx < #adz sz.posz run scoreboard players set #stepz sz.posz 0
# 四方向放置：支撑位有洞【且洞深 >=2 格】+ 脚部一格可通行 → 放置。
# 深度条件很关键：1 格深的坎原版寻路自己能走下去，若不加此条件，
# 追击起伏地形（下坡/浅沟）时会沿途乱铺方块
scoreboard players set #bplaced sz.stuck 0
execute align xyz if score #stepx sz.posx matches 1 if block ~1 ~-1 ~ #minecraft:replaceable if block ~1 ~-2 ~ #minecraft:replaceable if block ~1 ~ ~ #minecraft:replaceable store success score #bplaced sz.stuck run setblock ~1 ~-1 ~ minecraft:cobblestone
execute align xyz if score #stepx sz.posx matches -1 if block ~-1 ~-1 ~ #minecraft:replaceable if block ~-1 ~-2 ~ #minecraft:replaceable if block ~-1 ~ ~ #minecraft:replaceable store success score #bplaced sz.stuck run setblock ~-1 ~-1 ~ minecraft:cobblestone
execute align xyz if score #stepz sz.posz matches 1 if block ~ ~-1 ~1 #minecraft:replaceable if block ~ ~-2 ~1 #minecraft:replaceable if block ~ ~ ~1 #minecraft:replaceable store success score #bplaced sz.stuck run setblock ~ ~-1 ~1 minecraft:cobblestone
execute align xyz if score #stepz sz.posz matches -1 if block ~ ~-1 ~-1 #minecraft:replaceable if block ~ ~-2 ~-1 #minecraft:replaceable if block ~ ~ ~-1 #minecraft:replaceable store success score #bplaced sz.stuck run setblock ~ ~-1 ~-1 minecraft:cobblestone
execute if score #bplaced sz.stuck matches 0 run tag @s remove sz.pave
execute if score #bplaced sz.stuck matches 0 run return 0
scoreboard players set #built sz.stuck 1
tag @s add sz.pave
# 踏步跟进：目的地脚部与头部两格无阻挡才挪，防止窒息
execute if score #stepx sz.posx matches 1 align xyz if block ~1 ~ ~ #minecraft:replaceable if block ~1 ~1 ~ #minecraft:replaceable run tp @s ~1.5 ~ ~0.5
execute if score #stepx sz.posx matches -1 align xyz if block ~-1 ~ ~ #minecraft:replaceable if block ~-1 ~1 ~ #minecraft:replaceable run tp @s ~-0.5 ~ ~0.5
execute if score #stepz sz.posz matches 1 align xyz if block ~ ~ ~1 #minecraft:replaceable if block ~ ~1 ~1 #minecraft:replaceable run tp @s ~0.5 ~ ~1.5
execute if score #stepz sz.posz matches -1 align xyz if block ~ ~ ~-1 #minecraft:replaceable if block ~ ~1 ~-1 #minecraft:replaceable run tp @s ~0.5 ~ ~-0.5
playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1
scoreboard players set @s sz.cool 2
