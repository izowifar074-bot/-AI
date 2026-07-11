# ============================================================
# smartz:ai/rescue_lay — 铺逃生路（executor = 尸壳，位置 = 路径当前格，
# 已 align + rotated 到命中方向）
# 在 feet-1 放圆石（催化落桥），前进一格递归，直到 #rbest 步数用尽。
# 第 0 格（尸壳脚下）也铺，先把下坠中的尸壳接住。
# ============================================================
execute if block ~ ~-1 ~ #minecraft:replaceable run setblock ~ ~-1 ~ minecraft:cobblestone
execute if score #rbest sz.ai matches ..0 run return 0
scoreboard players remove #rbest sz.ai 1
execute positioned ^ ^ ^1 run function smartz:ai/rescue_lay
