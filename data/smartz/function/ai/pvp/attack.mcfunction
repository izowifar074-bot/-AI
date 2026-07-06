# ============================================================
# smartz:ai/pvp/attack — 出手层（executor = 僵尸，每 1gt 由 tick 驱动）
# "CPS 50" 按引擎物理上限落地：每 2gt 一次出手判定（约10次/秒），
# 玩家受击无敌帧(0.5s)决定有效命中率——无敌帧一结束立刻补刀。
# 命中仍完全由准星射线判定，无杀戮光环。
# ============================================================
execute if score @s sz.atk matches 1.. run scoreboard players remove @s sz.atk 1
execute if score @s sz.atk matches 1.. run return 0
scoreboard players set #go sz.stuck 0
execute on target if entity @s[distance=..4] run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run return 0
# 主动瞄准：躯干转向目标（原版只转头，站定时躯干不对齐会永久脱靶）
execute on target run tag @s add sz.aim
tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
tag @a remove sz.aim
# 准星射线：0.25 格步进 ×14（3.5 格），at @s 重采样转身后的旋转
scoreboard players set #ray sz.stuck 14
execute at @s anchored eyes positioned ^ ^ ^0.25 anchored feet run function smartz:ai/pvp/ray
