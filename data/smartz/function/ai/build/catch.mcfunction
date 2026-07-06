# ============================================================
# smartz:ai/build/catch — 坠落拦截（executor = 僵尸，每 4gt 由 core 调用）
# "攀爬执着"机制：目标在上方时，僵尸一旦下坠就在脚下垫砖接住，
# 已获得的高度绝不白白摔掉。配合原版寻路的水平移动，垂直塔会
# 自然演化成朝玩家方向的斜向阶梯/空中走道。
# 触发条件（全部满足）：脚下悬空、正在下坠（vy <= -0.12）、
# 有攻击目标且目标在自己上方至少 1 格。
# ============================================================
execute unless block ~ ~-1 ~ #minecraft:replaceable run return 0
execute store result score #my sz.stuck run data get entity @s Motion[1] 100
execute if score #my sz.stuck matches -11.. run return 0
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run return 0
execute store result score #zy2 sz.stuck run data get entity @s Pos[1]
execute on target store result score #ty2 sz.stuck run data get entity @s Pos[1]
scoreboard players operation #ty2 sz.stuck -= #zy2 sz.stuck
execute if score #ty2 sz.stuck matches ..0 run return 0
execute align xyz if block ~ ~-1 ~ #minecraft:replaceable run setblock ~ ~-1 ~ minecraft:cobblestone
execute align xyz if block ~ ~-1 ~ minecraft:cobblestone run playsound minecraft:block.stone.place block @a ~ ~ ~ 1 1.2
