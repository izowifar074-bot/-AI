# ============================================================
# smartz:ai/descend — 跳崖下追（executor = 僵尸，由 stuck 在目标
# 低于自己 >=2 格时优先调用）
# 玩家式下法：与其搭路绕到头顶再拆方块，不如找个边直接跳下去。
# 四邻格逐一探测（只考虑不背向目标的方向）：
#   可进入（脚部+头部两格通透）且是开放落沿（其下方也是空气）
#   → drop_probe 向下扫描落点：允许坠落深度 = |高度差|+3（上限
#     16，可承受些许摔落伤害但不自杀），途中岩浆/火/深渊否决，
#     水面或实体地面通过
# 找到即横移出沿（一步 tp 到该格中心，重力接管，观感就是跳崖）。
# 成功置 #jump = 1，stuck 据此跳过"搭路到头顶+拆脚下"的迂回路线；
# 全部否决则 #jump = 0，由原有的高空压制流程兜底。
# ============================================================
execute if score @s sz.cool matches 1.. run return 0
# 允许坠落深度 = |dh| + 3，上限 16
scoreboard players operation #drop sz.stuck = #dh sz.posy
scoreboard players operation #drop sz.stuck *= #cm1 sz.clock
scoreboard players add #drop sz.stuck 3
execute if score #drop sz.stuck matches 17.. run scoreboard players set #drop sz.stuck 16
# 目标方向符号（不许背向玩家跳）
scoreboard players operation #sdx sz.posx = #tx sz.posx
scoreboard players operation #sdx sz.posx -= #zx sz.posx
scoreboard players operation #sdz sz.posz = #tz sz.posz
scoreboard players operation #sdz sz.posz -= #zz sz.posz
# +x 方向
scoreboard players set #land sz.stuck 0
scoreboard players operation #dropw sz.stuck = #drop sz.stuck
execute if score #jump sz.stuck matches 0 if score #sdx sz.posx matches 0.. align xyz positioned ~1.5 ~ ~0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.stuck matches 0 if score #land sz.stuck matches 1 align xyz run tp @s ~1.5 ~ ~0.5
execute if score #land sz.stuck matches 1 run scoreboard players set #jump sz.stuck 1
# -x 方向
scoreboard players set #land sz.stuck 0
scoreboard players operation #dropw sz.stuck = #drop sz.stuck
execute if score #jump sz.stuck matches 0 if score #sdx sz.posx matches ..0 align xyz positioned ~-0.5 ~ ~0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.stuck matches 0 if score #land sz.stuck matches 1 align xyz run tp @s ~-0.5 ~ ~0.5
execute if score #land sz.stuck matches 1 run scoreboard players set #jump sz.stuck 1
# +z 方向
scoreboard players set #land sz.stuck 0
scoreboard players operation #dropw sz.stuck = #drop sz.stuck
execute if score #jump sz.stuck matches 0 if score #sdz sz.posz matches 0.. align xyz positioned ~0.5 ~ ~1.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.stuck matches 0 if score #land sz.stuck matches 1 align xyz run tp @s ~0.5 ~ ~1.5
execute if score #land sz.stuck matches 1 run scoreboard players set #jump sz.stuck 1
# -z 方向
scoreboard players set #land sz.stuck 0
scoreboard players operation #dropw sz.stuck = #drop sz.stuck
execute if score #jump sz.stuck matches 0 if score #sdz sz.posz matches ..0 align xyz positioned ~0.5 ~ ~-0.5 if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable if block ~ ~-1 ~ #minecraft:replaceable positioned ~ ~-2 ~ run function smartz:ai/drop_probe
execute if score #jump sz.stuck matches 0 if score #land sz.stuck matches 1 align xyz run tp @s ~0.5 ~ ~-0.5
execute if score #land sz.stuck matches 1 run scoreboard players set #jump sz.stuck 1
# 起跳收尾：解除攀爬/搭路状态，短冷却防止空中重复决策
execute if score #jump sz.stuck matches 1 run function smartz:ai/climb_off
execute if score #jump sz.stuck matches 1 run tag @s remove sz.pave
execute if score #jump sz.stuck matches 1 run scoreboard players set @s sz.cool 4
