# ============================================================
# smartz:ai/swarm/alert — 警报广播（executor = 僵尸，每 20gt 由 tick 调度）
# 首次锁定目标 → 咆哮；目标传染：给目标打瞬时标记 sz.vip，
# 40 格内同类通过 respond 建立穿墙仇恨——共享情报，不刷数量。
# ============================================================
execute if score #swarm sz.ai matches 0 run return 0
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run tag @s remove sz.alerted
execute if score #go sz.ai matches 0 run return 0
execute unless entity @s[tag=sz.alerted] run playsound minecraft:entity.zombie.ambient hostile @a ~ ~ ~ 2 0.7
tag @s add sz.alerted
execute on target run tag @s add sz.vip
execute as @e[type=minecraft:zombie,tag=sz.init,distance=0.1..40] at @s run function smartz:ai/swarm/respond
tag @a remove sz.vip
