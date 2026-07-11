# ============================================================
# smartz:ai/rescue_ray — 气球单向外扩射线（executor = 尸壳，
# 位置 = 当前扩张格，rotation 由 rescue 按方向设定）
# 在当前格判定命中：feet 级为实体方块(撞墙) 或 feet-1/-2/-3 有
# 实体方块(落点)。命中且半径更近 → 记录 #rbest/#rdir，停止本向；
# 否则前进一格（^ ^ ^1，pitch 0 保持水平），半径上限 6。
# #rstep=当前半径（由 rescue 每向重置为 0）。
# ============================================================
scoreboard players set #hit sz.ai 0
execute unless block ~ ~ ~ #minecraft:replaceable run scoreboard players set #hit sz.ai 1
execute unless block ~ ~-1 ~ #minecraft:replaceable run scoreboard players set #hit sz.ai 1
execute unless block ~ ~-2 ~ #minecraft:replaceable run scoreboard players set #hit sz.ai 1
execute unless block ~ ~-3 ~ #minecraft:replaceable run scoreboard players set #hit sz.ai 1
execute if score #hit sz.ai matches 1 if score #rstep sz.ai < #rbest sz.ai run scoreboard players operation #rbest sz.ai = #rstep sz.ai
execute if score #hit sz.ai matches 1 if score #rstep sz.ai = #rbest sz.ai run scoreboard players operation #rdir sz.ai = #rcur sz.ai
execute if score #hit sz.ai matches 1 run return 0
execute if score #rstep sz.ai matches 6.. run return 0
scoreboard players add #rstep sz.ai 1
execute positioned ^ ^ ^1 run function smartz:ai/rescue_ray
