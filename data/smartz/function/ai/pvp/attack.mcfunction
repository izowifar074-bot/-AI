# ============================================================
# smartz:ai/pvp/attack — 出手层 + 控距步法（executor = 僵尸，每 1gt 由 tick 驱动）
#
# 控距步法：目标进入 4.5 格后，移动由每刻一次的微小 tp 全面接管，
# 三段距离带模拟职业 PVP 走位（一切位移由 <=0.22 格/刻 的连续
# 微步组成，观感是走位而非瞬移；步速均不超过玩家对应动作）：
#   < 2.0    后撤步 0.11/刻（=玩家后退 2.2 格/秒），拉开输出空间
#   2.0~3.4  环绕步 0.12/刻，绕着目标转圈找角度
#   > 3.4    进步   0.20/刻（=4 格/秒 < 玩家疾跑），贴回刀距
# 每一微步的安全约束：自己踩地、落点脚下有支撑、落点两格可通行
# ——绝不悬空滑行；离地（跳跃/击退中）交还物理引擎。
# 每步附带 facing 修正，准星始终咬住目标。
#
# 出手：攻击距离 3.0 格（=玩家出刀距离），每 2gt 一次判定（引擎
# 上限攻速，配合无敌帧即"无敌帧一结束立刻补刀"）。正面锥判定
# 保证目标在躯干背后时打不到（无杀戮光环）。
# ============================================================
execute if score @s sz.atk matches 1.. run scoreboard players remove @s sz.atk 1
scoreboard players set #go sz.stuck 0
execute on target if entity @s[distance=..4.5] run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run return 0
execute on target run tag @s add sz.aim
# ---- 控距步法 ----
scoreboard players set #fw sz.stuck 0
execute unless block ~ ~-1 ~ #minecraft:replaceable run scoreboard players set #fw sz.stuck 1
execute if score #fw sz.stuck matches 1 on target if entity @s[distance=3.4..] run scoreboard players set #fw sz.stuck 4
execute if score #fw sz.stuck matches 1 on target if entity @s[distance=2..3.4] run scoreboard players set #fw sz.stuck 3
execute if score #fw sz.stuck matches 1 on target if entity @s[distance=..2] run scoreboard players set #fw sz.stuck 2
scoreboard players operation #par sz.clock = #tick sz.clock
scoreboard players operation #par sz.clock += @s sz.id
scoreboard players operation #par sz.clock %= #c20 sz.clock
execute if score #fw sz.stuck matches 2 at @s rotated ~ 0 positioned ^ ^ ^-0.11 unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
execute if score #fw sz.stuck matches 3 if score #par sz.clock matches 0..9 at @s rotated ~ 0 positioned ^0.12 ^ ^ unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
execute if score #fw sz.stuck matches 3 if score #par sz.clock matches 10..19 at @s rotated ~ 0 positioned ^-0.12 ^ ^ unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
execute if score #fw sz.stuck matches 4 at @s rotated ~ 0 positioned ^ ^ ^0.2 unless block ~ ~-1 ~ #minecraft:replaceable if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
# ---- 出手 ----
execute if score @s sz.atk matches 1.. run tag @a remove sz.aim
execute if score @s sz.atk matches 1.. run return 0
scoreboard players set #go sz.stuck 0
execute on target if entity @s[distance=..3.4] run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run tag @a remove sz.aim
execute if score #go sz.stuck matches 0 run return 0
# 正面锥（约±60°）：目标在躯干背后 → 先转身（0.1 秒前摇），本轮不出刀
scoreboard players set #front sz.stuck 0
execute positioned ^ ^ ^3 if entity @p[tag=sz.aim,distance=..3.2,gamemode=!spectator] run scoreboard players set #front sz.stuck 1
execute if score #front sz.stuck matches 0 at @s run tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
execute if score #front sz.stuck matches 0 run scoreboard players set @s sz.atk 2
execute if score #front sz.stuck matches 0 run tag @a remove sz.aim
execute if score #front sz.stuck matches 0 run return 0
# 眼对眼确定性瞄准射线（3.0 格 = 玩家出刀距离）
scoreboard players set #ray sz.stuck 12
execute at @s anchored eyes facing entity @p[tag=sz.aim,gamemode=!spectator] eyes positioned ^ ^ ^0.25 anchored feet run function smartz:ai/pvp/ray
tag @a remove sz.aim
