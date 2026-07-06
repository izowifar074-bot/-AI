# ============================================================
# smartz:ai/swarm/alert — 警报广播（executor = 僵尸，每 20gt 由 tick 调度）
# 真正的 AI 协同（不刷新怪）：
#   1. 检测自己是否锁定了攻击目标（execute on target）
#   2. 首次发现 → 咆哮示警
#   3. 目标传染：给自己的目标玩家打上临时标记 sz.vip，
#      广播给 40 格内同类；respond 中无目标的僵尸会对该玩家
#      建立穿墙仇恨——一只僵尸看到你 = 整群知道你在哪
# ============================================================
execute if score #swarm sz.config matches 0 run return 0
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run tag @s remove sz.alerted
execute if score #go sz.stuck matches 0 run return 0
execute unless entity @s[tag=sz.alerted] run playsound minecraft:entity.zombie.ambient hostile @a ~ ~ ~ 2 0.7
tag @s add sz.alerted
execute on target run tag @s add sz.vip
execute as @e[type=minecraft:zombie,tag=sz.init,distance=0.1..40] at @s run function smartz:ai/swarm/respond
tag @a remove sz.vip
