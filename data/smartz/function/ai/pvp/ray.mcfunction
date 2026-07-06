# ============================================================
# smartz:ai/pvp/ray — 准星射线步进（executor = 僵尸，位置 = 射线当前点）
# 每步 0.25 格：撞到实体方块终止（准星被挡）；射线点进入玩家
# 碰撞箱（dx=0,dy=0,dz=0 点碰撞检测）→ 结算命中；步数用尽终止。
# ============================================================
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
execute if entity @a[dx=0,dy=0,dz=0,gamemode=!creative,gamemode=!spectator] run function smartz:ai/pvp/hit
execute if entity @a[dx=0,dy=0,dz=0,gamemode=!creative,gamemode=!spectator] run return 0
scoreboard players remove #ray sz.stuck 1
execute if score #ray sz.stuck matches ..0 run return 0
execute positioned ^ ^ ^0.25 run function smartz:ai/pvp/ray
