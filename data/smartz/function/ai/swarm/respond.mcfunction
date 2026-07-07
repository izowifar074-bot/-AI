# ============================================================
# smartz:ai/swarm/respond — 响应警报（executor = 被召集的僵尸）
# 集体提速；无目标者对警报者的目标（tag=sz.vip）建立穿墙仇恨。
# ============================================================
effect give @s minecraft:speed 5 1 true
scoreboard players set #go sz.ai 0
execute on target run scoreboard players set #go sz.ai 1
execute if score #go sz.ai matches 0 run damage @s 0.0001 minecraft:generic by @p[tag=sz.vip,distance=..64,gamemode=!creative,gamemode=!spectator]
