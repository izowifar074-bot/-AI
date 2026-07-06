# ============================================================
# smartz:ai/swarm/respond — 响应警报（executor = 被召集的僵尸）
# 1. 集体提速加入围攻（警报每 20gt 重复，追击期间等效持续）
# 2. 目标传染：自己还没有目标时，对警报者的目标（tag=sz.vip
#    的玩家）建立穿墙仇恨——协同索敌，而非增加数量
# ============================================================
effect give @s minecraft:speed 5 1 true
scoreboard players set #go sz.stuck 0
execute on target run scoreboard players set #go sz.stuck 1
execute if score #go sz.stuck matches 0 run damage @s 0.0001 minecraft:generic by @p[tag=sz.vip,distance=..64,gamemode=!creative,gamemode=!spectator]
