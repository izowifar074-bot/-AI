# ============================================================
# smartz:ai/dodge — 对弓走位（executor = 尸壳，每 4gt 由 core 调用）
# 24 格内有持弓/弩玩家 → 横向蛇形拉扯（时钟+编号 对 16 取模定向，
# 相位错开）。近战圈（目标 4.5 内）让位给控距步法防两套位移打架。
# ============================================================
execute on target if entity @s[distance=..4.5] run return 0
execute unless entity @a[distance=..24,predicate=smartz:aiming_player] run return 0
scoreboard players operation #par sz.ai = #tick sz.ai
scoreboard players operation #par sz.ai += @s sz.id
scoreboard players operation #par sz.ai %= #c16 sz.ai
execute if score #par sz.ai matches 0..7 positioned ^0.7 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^0.7 ^ ^
execute if score #par sz.ai matches 8..15 positioned ^-0.7 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^-0.7 ^ ^
