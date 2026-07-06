# ============================================================
# smartz:ai/stuck — 追击受阻检测（executor = 僵尸，每 8gt 一次）
# 这是"挖/搭/垫"三大地形交互的唯一触发器。
# 判定标准：与攻击目标的距离²不再创新低 = 没有进展。
# （旧版按"坐标完全不动"判定，僵尸在障碍下踱步会不停清零计数，
#   导致永不触发，已废弃。）
# @s sz.posx 存储该僵尸的历史最近距离²（init 时置为极大值）。
# 无进展计数累到 3（约1.2秒）触发决策，之后回落到 1 保持
# 每 16gt 重新决策的节奏。
# ============================================================
execute if score @s sz.mine matches 1.. run return 0
# 无目标 → 清零退出
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run scoreboard players set @s sz.stuck 0
execute if score #go sz.stuck matches 0 run return 0
# 自身与目标的整数坐标
execute store result score #zx sz.posx run data get entity @s Pos[0]
execute store result score #zy sz.posy run data get entity @s Pos[1]
execute store result score #zz sz.posz run data get entity @s Pos[2]
execute on target store result score #tx sz.posx run data get entity @s Pos[0]
execute on target store result score #ty sz.posy run data get entity @s Pos[1]
execute on target store result score #tz sz.posz run data get entity @s Pos[2]
# 高度差（带符号，决策用）
scoreboard players operation #dh sz.posy = #ty sz.posy
scoreboard players operation #dh sz.posy -= #zy sz.posy
# 距离² = dx² + dy² + dz²
scoreboard players operation #dx sz.posx = #tx sz.posx
scoreboard players operation #dx sz.posx -= #zx sz.posx
scoreboard players operation #dz sz.posz = #tz sz.posz
scoreboard players operation #dz sz.posz -= #zz sz.posz
scoreboard players operation #dy sz.posy = #dh sz.posy
scoreboard players operation #dx sz.posx *= #dx sz.posx
scoreboard players operation #dy sz.posy *= #dy sz.posy
scoreboard players operation #dz sz.posz *= #dz sz.posz
scoreboard players operation #dsq sz.stuck = #dx sz.posx
scoreboard players operation #dsq sz.stuck += #dy sz.posy
scoreboard players operation #dsq sz.stuck += #dz sz.posz
# 已经贴近目标（距离²<=2）→ 不算受阻
execute if score #dsq sz.stuck matches ..2 run scoreboard players set @s sz.stuck 0
execute if score #dsq sz.stuck matches ..2 run return 0
# 与历史最近距离比较：变近 = 有进展
scoreboard players operation #delta sz.stuck = @s sz.posx
scoreboard players operation #delta sz.stuck -= #dsq sz.stuck
execute if score #delta sz.stuck matches 1.. run scoreboard players set @s sz.stuck 0
execute if score #delta sz.stuck matches 1.. run scoreboard players operation @s sz.posx = #dsq sz.stuck
execute if score #delta sz.stuck matches ..0 run scoreboard players add @s sz.stuck 1
# 被击退等导致基线失真：长期无进展就以当前距离重设基线
execute if score @s sz.stuck matches 12.. run scoreboard players operation @s sz.posx = #dsq sz.stuck
execute if score @s sz.stuck matches 12.. run scoreboard players set @s sz.stuck 3
# 决策：垫高 → 搭路 → 挖掘。#built 标记本轮是否已放置方块，
# 放了方块就不再触发挖掘，防止转头把自己刚放的方块啃掉
scoreboard players set #built sz.stuck 0
execute if score @s sz.stuck matches 3.. if score #dh sz.posy matches 2.. if score #build sz.config matches 1 run function smartz:ai/build/pillar
execute if score @s sz.stuck matches 3.. if score #dh sz.posy matches -1..1 if score #build sz.config matches 1 run function smartz:ai/build/bridge
execute if score @s sz.stuck matches 3.. if score #built sz.stuck matches 0 if score #dig sz.config matches 1 run function smartz:ai/dig/decide
execute if score @s sz.stuck matches 3.. run scoreboard players set @s sz.stuck 1
