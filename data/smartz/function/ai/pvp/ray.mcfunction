# ============================================================
# smartz:ai/pvp/ray — 准星射线步进（executor = 尸壳，位置 = 射线当前点）
# 每步 0.25 格：撞实体方块终止；射线点进入【当前目标】碰撞箱
# （tag=sz.aim + dx/dy/dz 点碰撞）→ hit 结算。只认目标本体，
# 不误伤路径上的旁观实体。预算 #ray 由 attack 设 12 步 = 3.0 格。
# ============================================================
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
execute if entity @e[tag=sz.aim,dx=0,dy=0,dz=0] run function smartz:ai/pvp/hit
execute if entity @e[tag=sz.aim,dx=0,dy=0,dz=0] run return 0
scoreboard players remove #ray sz.ai 1
execute if score #ray sz.ai matches ..0 run return 0
execute positioned ^ ^ ^0.25 run function smartz:ai/pvp/ray
