# ============================================================
# smartz:ai/pvp/attack — 出手层+控距步法（executor = 尸壳，tick 每刻驱动）
# 控距步法（目标 4.5 格内，每刻 <=0.22 格微 tp，观感为走位）：
#   <2 后撤步 0.11/刻(=玩家后退) / 2~3.4 环绕步 0.12 / >3.4 进步 0.20
#   约束：自己踩地+落点有支撑+两格可通行——不悬空滑行；每步带
#   facing 修正，准星咬住目标。
# 出手：3.0 格（=玩家刀距），每 2gt 判定（引擎上限攻速）。
# 公平性：正面锥(±60°)不过 → 先转身(0.1s 前摇)；射线被方块阻挡
# 无效——无杀戮光环。严禁每次出手都 tp（重置寻路导致近身迟缓，
# 且 tp facing 仰角从脚算会掰歪躯干，射线全部脱靶，历史教训）。
# ============================================================
execute if score @s sz.atk matches 1.. run scoreboard players remove @s sz.atk 1
scoreboard players set #go sz.ai 0
execute on target if entity @s[distance=..4.5] run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run return 0
execute on target run tag @s add sz.aim
# ---- 控距步法 ----
scoreboard players set #fw sz.ai 0
execute unless block ~ ~-1 ~ #minecraft:replaceable run scoreboard players set #fw sz.ai 1
execute if score #fw sz.ai matches 1 on target if entity @s[distance=3.4..] run scoreboard players set #fw sz.ai 4
execute if score #fw sz.ai matches 1 on target if entity @s[distance=2..3.4] run scoreboard players set #fw sz.ai 3
execute if score #fw sz.ai matches 1 on target if entity @s[distance=..2] run scoreboard players set #fw sz.ai 2
scoreboard players operation #par sz.ai = #tick sz.ai
scoreboard players operation #par sz.ai += @s sz.id
scoreboard players operation #par sz.ai %= #c20 sz.ai
execute if score #fw sz.ai matches 2 at @s rotated ~ 0 positioned ^ ^ ^-0.11 unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @e[tag=sz.aim,limit=1] eyes
execute if score #fw sz.ai matches 3 if score #par sz.ai matches 0..9 at @s rotated ~ 0 positioned ^0.12 ^ ^ unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @e[tag=sz.aim,limit=1] eyes
execute if score #fw sz.ai matches 3 if score #par sz.ai matches 10..19 at @s rotated ~ 0 positioned ^-0.12 ^ ^ unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @e[tag=sz.aim,limit=1] eyes
execute if score #fw sz.ai matches 4 at @s rotated ~ 0 positioned ^ ^ ^0.2 unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @e[tag=sz.aim,limit=1] eyes
# ---- 出手 ----
execute if score @s sz.atk matches 1.. run tag @e remove sz.aim
execute if score @s sz.atk matches 1.. run return 0
scoreboard players set #go sz.ai 0
execute on target if entity @s[distance=..3.4] run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run tag @e remove sz.aim
execute if score #go sz.ai matches 0 run return 0
scoreboard players set #front sz.ai 0
execute positioned ^ ^ ^3 if entity @e[tag=sz.aim,distance=..3.2,limit=1] run scoreboard players set #front sz.ai 1
execute if score #front sz.ai matches 0 at @s run tp @s ~ ~ ~ facing entity @e[tag=sz.aim,limit=1] eyes
execute if score #front sz.ai matches 0 run scoreboard players set @s sz.atk 2
execute if score #front sz.ai matches 0 run tag @e remove sz.aim
execute if score #front sz.ai matches 0 run return 0
scoreboard players set #ray sz.ai 12
execute at @s anchored eyes facing entity @e[tag=sz.aim,limit=1] eyes positioned ^ ^ ^0.25 anchored feet run function smartz:ai/pvp/ray
tag @e remove sz.aim
