# ============================================================
# smartz:ai/pvp/main — 近战 PVP 主逻辑（executor = 僵尸，每 4gt 由 core 调用）
# 流程：
#   1. 攻击冷却 sz.atk 递减（无论是否在战斗中都要走冷却）
#   2. 目标不在 4 格内 → 退出；疾跑逃离 4~9 格 → 冲刺追击
#   3. 目标持盾 → 攻击间隙环绕走位（找侧后角度，盾只挡正面）
#   4. 冷却结束 → 发起准星射线攻击（见 ray.mcfunction）
# 反杀戮光环保证：伤害只可能由射线命中结算，射线沿僵尸自己的
# 视线方向推进且会被方块阻挡——没面对玩家就绝不可能造成伤害。
# ============================================================
execute if score @s sz.atk matches 1.. run scoreboard players remove @s sz.atk 1
# 行为识别：目标疾跑逃离（4~9格）→ 冲刺追击
scoreboard players set #run sz.stuck 0
execute on target if entity @s[distance=4..9,predicate=smartz:sprinting] run scoreboard players set #run sz.stuck 1
execute if score #run sz.stuck matches 1 run effect give @s minecraft:speed 2 2 true
# 近战范围判定：目标在 4 格内才继续
scoreboard players set #go sz.stuck 0
execute on target if entity @s[distance=..4] run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run return 0
# 行为识别：目标持盾（主手或副手）→ 环绕走位找侧后角度
scoreboard players set #shield sz.stuck 0
execute on target if items entity @s weapon.offhand minecraft:shield run scoreboard players set #shield sz.stuck 1
execute on target if items entity @s weapon.mainhand minecraft:shield run scoreboard players set #shield sz.stuck 1
scoreboard players operation #par sz.clock = #tick sz.clock
scoreboard players operation #par sz.clock += @s sz.id
scoreboard players operation #par sz.clock %= #c16 sz.clock
execute if score #shield sz.stuck matches 1 if score #par sz.clock matches 0..7 positioned ^0.9 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^0.9 ^ ^
execute if score #shield sz.stuck matches 1 if score #par sz.clock matches 8..15 positioned ^-0.9 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^-0.9 ^ ^
# 攻击冷却未结束 → 本轮不出手
execute if score @s sz.atk matches 1.. run return 0
# 主动瞄准：出手前把躯干转向目标。
# 原因：execute at 取的是实体躯干朝向，而原版视线控制只转头——
# 僵尸站定不动（如柱顶对峙）时躯干永远不再对齐，射线一直斜着打，
# 贴脸也永远脱靶。转身等价于玩家甩鼠标瞄准，是公平动作；命中仍
# 完全由射线判定，隔方块/无视线依旧打不到，无杀戮光环的保证不变。
execute on target run tag @s add sz.aim
tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
tag @a remove sz.aim
# 准星射线攻击：从眼睛沿视线方向逐 0.25 格推进，最多 14 步（3.5 格）
# at @s 重新采样转身后的旋转；anchored feet 防止递归中重复叠加眼高
scoreboard players set #ray sz.stuck 14
execute at @s anchored eyes positioned ^ ^ ^0.25 anchored feet run function smartz:ai/pvp/ray
