# ============================================================
# smartz:ai/build/bridge — 定向搭路（executor = 僵尸，由 stuck 触发）
# 网格化步进算法：不依赖僵尸的头部朝向（旧版用视线射线，僵尸
# 在沟边踱步时射线方向随机，横搭几乎不触发，已废弃）。
# 直接用"僵尸→目标"的坐标差取主轴方向（|dx|>=|dz| 走 x 轴，
# 否则走 z 轴），逐格朝玩家方向铺路，天然走出折线路径。
# 放置条件：脚边该方向的支撑位是可替换方块（有洞），且脚部一格
# 可通行——只查这两格（不再要求头顶一格也是空气），这样在逼近
# 玩家高台/结构、头顶有方块时也能封上最后的缺口。顺便填平壕沟。
# 依赖：stuck 已算好 #tx/#zx/#tz/#zz（自身与目标的整数坐标）。
# 成功放置时置 #built sz.stuck = 1（stuck 用它跳过挖掘分支）。
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
# 四方向放置：支撑位有洞 + 脚部一格可通行 → 放置并记录成功
execute align xyz if score #stepx sz.posx matches 1 if block ~1 ~-1 ~ #minecraft:replaceable if block ~1 ~ ~ #minecraft:replaceable store success score #built sz.stuck run setblock ~1 ~-1 ~ minecraft:cobblestone
execute align xyz if score #stepx sz.posx matches -1 if block ~-1 ~-1 ~ #minecraft:replaceable if block ~-1 ~ ~ #minecraft:replaceable store success score #built sz.stuck run setblock ~-1 ~-1 ~ minecraft:cobblestone
execute align xyz if score #stepz sz.posz matches 1 if block ~ ~-1 ~1 #minecraft:replaceable if block ~ ~ ~1 #minecraft:replaceable store success score #built sz.stuck run setblock ~ ~-1 ~1 minecraft:cobblestone
execute align xyz if score #stepz sz.posz matches -1 if block ~ ~-1 ~-1 #minecraft:replaceable if block ~ ~ ~-1 #minecraft:replaceable store success score #built sz.stuck run setblock ~ ~-1 ~-1 minecraft:cobblestone
# 成功后：音效 + 冷却
execute if score #built sz.stuck matches 1 run playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1
execute if score #built sz.stuck matches 1 run scoreboard players set @s sz.cool 2
