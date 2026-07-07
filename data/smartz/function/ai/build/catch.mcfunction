# ============================================================
# smartz:ai/build/catch — 坠落拦截（executor = 僵尸，每 4gt 由 core 调用）
# 目标高 >=2（真攀爬）且自己贴着结构下坠时脚下垫砖接住，攀爬
# 高度不白摔。四邻依附检测防止开阔地跳跃时凭空垒浮空方块。
# ============================================================
execute unless block ~ ~-1 ~ #minecraft:replaceable run return 0
execute store result score #my sz.ai run data get entity @s Motion[1] 100
execute if score #my sz.ai matches -5.. run return 0
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run return 0
execute store result score #zy2 sz.ai run data get entity @s Pos[1]
execute on target store result score #ty2 sz.ai run data get entity @s Pos[1]
scoreboard players operation #ty2 sz.ai -= #zy2 sz.ai
execute if score #ty2 sz.ai matches ..1 run return 0
scoreboard players set #sup sz.ai 0
execute unless block ~1 ~ ~ #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute unless block ~-1 ~ ~ #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute unless block ~ ~ ~1 #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute unless block ~ ~ ~-1 #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute unless block ~1 ~-1 ~ #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute unless block ~-1 ~-1 ~ #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute unless block ~ ~-1 ~1 #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute unless block ~ ~-1 ~-1 #minecraft:replaceable run scoreboard players set #sup sz.ai 1
execute if score #sup sz.ai matches 0 run return 0
execute align xyz if block ~ ~-1 ~ #minecraft:replaceable run setblock ~ ~-1 ~ minecraft:cobblestone
execute align xyz if block ~ ~-1 ~ minecraft:cobblestone run playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1.2
