# ============================================================
# smartz:ai/dodge — 蛇皮走位（executor = 僵尸）
# 职责：
#   1. 检测 24 格内是否有主手持弓或弩的玩家（predicate smartz:aiming_player）
#   2. 有 → 每约 10gt 施加一次横向 Motion（data merge entity ... Motion）
#      左右方向由 sz.id 奇偶 + 当前 tick 决定，产生不可预测的蛇形路线
#   3. 近战贴身（距离 < 3）时施加小幅侧向拉扯
#   4. 用 sz.cool 冷却防止每刻都推，导致原地抖动
# ============================================================
execute unless entity @a[distance=..24,predicate=smartz:aiming_player] run return 0
scoreboard players operation #par sz.clock = #tick sz.clock
scoreboard players operation #par sz.clock += @s sz.id
scoreboard players operation #par sz.clock %= #c16 sz.clock
execute if score #par sz.clock matches 0..7 positioned ^0.7 ^ ^ if block ~ ~ ~ minecraft:air if block ~ ~1 ~ minecraft:air run tp @s ^0.7 ^ ^
execute if score #par sz.clock matches 8..15 positioned ^-0.7 ^ ^ if block ~ ~ ~ minecraft:air if block ~ ~1 ~ minecraft:air run tp @s ^-0.7 ^ ^