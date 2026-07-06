# ============================================================
# smartz:ai/pvp/attack — 出手层（executor = 僵尸，每 1gt 由 tick 驱动）
# 攻速为引擎上限：每 2gt 一次出手判定，配合玩家受击无敌帧即
# "无敌帧一结束立刻补刀"。
#
# 瞄准与公平性设计（重要，勿回退）：
#   - 正面锥判定：目标必须在躯干前方约 ±60° 锥内（前方 3 格点
#     的 3.2 格半径近似）才允许出刀——绕背贴脸打不到，无杀戮光环
#   - 躯干背对目标时：tp 转身一次 + 0.1 秒前摇后再出刀。
#     严禁每次出手都 tp：tp 会重置寻路导航，每秒 10 次会把僵尸
#     钉在原地（旧版近身迟缓的根因）；tp facing 的仰角还会从脚部
#     算向目标眼睛，近距离把躯干掰成仰视，射线全部从头顶飞过
#     （旧版"望着头顶半天不砍"的根因）
#   - 攻击射线用 execute facing 显式取眼对眼方向，确定性命中；
#     被方块阻挡依旧无效（ray 内部检查）
# ============================================================
execute if score @s sz.atk matches 1.. run scoreboard players remove @s sz.atk 1
execute if score @s sz.atk matches 1.. run return 0
scoreboard players set #go sz.stuck 0
execute on target if entity @s[distance=..4] run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run return 0
execute on target run tag @s add sz.aim
# 正面锥判定
scoreboard players set #front sz.stuck 0
execute positioned ^ ^ ^3 if entity @p[tag=sz.aim,distance=..3.2,gamemode=!spectator] run scoreboard players set #front sz.stuck 1
# 背对目标 → 转身（一次性），带 0.1 秒前摇，本轮不出刀
execute if score #front sz.stuck matches 0 at @s run tp @s ~ ~ ~ facing entity @p[tag=sz.aim,gamemode=!spectator] eyes
execute if score #front sz.stuck matches 0 run scoreboard players set @s sz.atk 2
execute if score #front sz.stuck matches 0 run tag @a remove sz.aim
execute if score #front sz.stuck matches 0 run return 0
# 眼对眼确定性瞄准射线
scoreboard players set #ray sz.stuck 14
execute at @s anchored eyes facing entity @p[tag=sz.aim,gamemode=!spectator] eyes positioned ^ ^ ^0.25 anchored feet run function smartz:ai/pvp/ray
tag @a remove sz.aim
