# ============================================================
# smartz:ai/swarm/alert — 警报广播（executor = 僵尸，每 20gt 由 tick 调度）
# 职责：
#   1. 用 execute on target 检测自己是否已锁定攻击目标（成功 = 已发现玩家）
#   2. 已锁定且无 sz.alerted 标签 → 打上 sz.alerted，播放僵尸咆哮音效
#   3. 以自己为中心，让 40 格内其他僵尸执行 ai/swarm/respond
# ============================================================
execute if score #swarm sz.config matches 0 run return 0
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run tag @s remove sz.alerted
execute if score #go sz.stuck matches 0 run return 0
execute unless entity @s[tag=sz.alerted] run playsound minecraft:entity.zombie.ambient hostile @a ~ ~ ~ 2 0.7
execute unless entity @s[tag=sz.alerted] store result score #cnt sz.stuck if entity @e[type=minecraft:zombie,distance=..32]
execute unless entity @s[tag=sz.alerted] if score #cnt sz.stuck matches ..7 run summon minecraft:zombie ~ ~ ~
tag @s add sz.alerted
execute as @e[type=minecraft:zombie,tag=sz.init,distance=0.1..40] at @s run function smartz:ai/swarm/respond