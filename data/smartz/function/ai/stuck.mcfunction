# ============================================================
# smartz:ai/stuck — 卡住检测（executor = 僵尸，每 8gt 一次）
# 这是"挖/搭/垫"三大地形交互的唯一触发器
# 职责：
#   1. 用 execute store 将当前方块坐标存入临时分数，与 sz.posx/y/z 比较
#   2. 相同 → sz.stuck += 1；不同 → sz.stuck = 0 并更新 sz.posx/y/z
#   3. 当 sz.stuck >= 5（约2秒未动）且有攻击目标(execute on target)
#      且与目标距离 > 2 格时，进入决策：
#      - 目标在上方 >= 2 格 且 #build 开 → ai/build/pillar
#      - 前方(视线方向1格)是实体方块 且 #dig 开 → ai/dig/decide
#      - 前方悬空(前下方是空气) 且 #build 开 → ai/build/bridge
#   4. 触发任一行为后 sz.stuck 归零
# ============================================================
execute if score @s sz.mine matches 1.. run return 0
execute store result score #curx sz.posx run data get entity @s Pos[0]
execute store result score #cury sz.posy run data get entity @s Pos[1]
execute store result score #curz sz.posz run data get entity @s Pos[2]
scoreboard players set #same sz.stuck 1
execute unless score #curx sz.posx = @s sz.posx run scoreboard players set #same sz.stuck 0
execute unless score #cury sz.posy = @s sz.posy run scoreboard players set #same sz.stuck 0
execute unless score #curz sz.posz = @s sz.posz run scoreboard players set #same sz.stuck 0
execute if score #same sz.stuck matches 1 run scoreboard players add @s sz.stuck 1
execute if score #same sz.stuck matches 0 run scoreboard players set @s sz.stuck 0
scoreboard players operation @s sz.posx = #curx sz.posx
scoreboard players operation @s sz.posy = #cury sz.posy
scoreboard players operation @s sz.posz = #curz sz.posz
scoreboard players set #go sz.stuck 0
execute on target if entity @s[distance=2.5..] run scoreboard players set #go sz.stuck 1
execute if score @s sz.stuck matches 5.. if score #go sz.stuck matches 1 if score #dig sz.config matches 1 run function smartz:ai/dig/decide
execute if score @s sz.stuck matches 5.. run scoreboard players set @s sz.stuck 0