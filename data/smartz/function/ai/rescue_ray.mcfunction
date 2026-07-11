# ============================================================
# smartz:ai/rescue_ray — 气球单向外扩射线（executor = 尸壳，
# 位置 = 当前扩张格，rotation 由 rescue 按方向设定）
# 命中判定只认 feet-1（脚下同层）为实体方块——因为 rescue_lay 在
# feet-1 铺桥，只有同层落点才能面对面连上，避免建向低台/高墙导致
# 桥悬空凭空。命中且半径更近 → 记录 #rbest/#rdir，停止本向。
# feet 级被实体方块挡住（且 feet-1 却空）→ 停止本向但不作落点，
# 既防射线穿墙、又不建向浮空目标。否则前进一格（^ ^ ^1，pitch 0
# 保持水平），半径上限 6。#rstep=当前半径（由 rescue 每向重置 0）。
# ============================================================
scoreboard players set #hit sz.ai 0
execute unless block ~ ~-1 ~ #minecraft:replaceable run scoreboard players set #hit sz.ai 1
execute if score #hit sz.ai matches 1 if score #rstep sz.ai < #rbest sz.ai run scoreboard players operation #rbest sz.ai = #rstep sz.ai
execute if score #hit sz.ai matches 1 if score #rstep sz.ai = #rbest sz.ai run scoreboard players operation #rdir sz.ai = #rcur sz.ai
execute if score #hit sz.ai matches 1 run return 0
execute unless block ~ ~ ~ #minecraft:replaceable run return 0
execute if score #rstep sz.ai matches 6.. run return 0
scoreboard players add #rstep sz.ai 1
execute positioned ^ ^ ^1 run function smartz:ai/rescue_ray
