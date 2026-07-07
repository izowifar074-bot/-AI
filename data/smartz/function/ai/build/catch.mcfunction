# ============================================================
# smartz:ai/build/catch — 坠落拦截（executor = 僵尸，每 4gt 由 core 调用）
# "攀爬执着"机制：目标在上方时，僵尸下坠就在脚下垫砖接住，
# 已获得的高度不白白摔掉，自然演化成朝玩家的斜向阶梯/空中走道。
# 触发条件（全部满足）：
#   1. 脚下悬空（block ~-1 为可替换）
#   2. 正在下坠（Motion[1] <= -0.06）
#   3. 有攻击目标且目标在自己上方至少 2 格（>=2 才是真攀爬；
#      上坡追击的普通小跳不触发，避免沿途乱垫）
#   4. 身边有可依附的实体方块（#sup=1）——防止在开阔地凭空垒
#      浮空方块：单纯原地跳跃/被击飞时四周皆空，则不接住，
#      任其自然落地（修复"下落中凭空放置方块"）。
# ============================================================
execute unless block ~ ~-1 ~ #minecraft:replaceable run return 0
execute store result score #my sz.stuck run data get entity @s Motion[1] 100
execute if score #my sz.stuck matches -5.. run return 0
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run return 0
execute store result score #zy2 sz.stuck run data get entity @s Pos[1]
execute on target store result score #ty2 sz.stuck run data get entity @s Pos[1]
scoreboard players operation #ty2 sz.stuck -= #zy2 sz.stuck
execute if score #ty2 sz.stuck matches ..1 run return 0
# 依附检测：脚部四邻 + 下层四邻，任一为实体方块即视为贴着结构
scoreboard players set #sup sz.stuck 0
execute unless block ~1 ~ ~ #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute unless block ~-1 ~ ~ #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute unless block ~ ~ ~1 #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute unless block ~ ~ ~-1 #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute unless block ~1 ~-1 ~ #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute unless block ~-1 ~-1 ~ #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute unless block ~ ~-1 ~1 #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute unless block ~ ~-1 ~-1 #minecraft:replaceable run scoreboard players set #sup sz.stuck 1
execute if score #sup sz.stuck matches 0 run return 0
execute align xyz if block ~ ~-1 ~ #minecraft:replaceable run setblock ~ ~-1 ~ minecraft:cobblestone
execute align xyz if block ~ ~-1 ~ minecraft:cobblestone run playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1.2
