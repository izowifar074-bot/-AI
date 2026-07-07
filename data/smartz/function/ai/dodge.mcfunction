# ============================================================
# smartz:ai/dodge — 对弓走位（executor = 僵尸，每 4gt 由 core 调用）
# 24 格内有持弓/弩玩家时横向蛇形拉扯（方向由 时钟+编号 对 16
# 取模决定，不同僵尸相位错开）。每步检查落点两格可通行。
# 近战圈（目标 4.5 格内）让位给 pvp/attack 的控距步法，避免
# 两套位移系统互相拉扯造成抖动。
# ============================================================
execute on target if entity @s[distance=..4.5] run return 0
execute unless entity @a[distance=..24,predicate=smartz:aiming_player] run return 0
scoreboard players operation #par sz.clock = #tick sz.clock
scoreboard players operation #par sz.clock += @s sz.id
scoreboard players operation #par sz.clock %= #c16 sz.clock
execute if score #par sz.clock matches 0..7 positioned ^0.7 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^0.7 ^ ^
execute if score #par sz.clock matches 8..15 positioned ^-0.7 ^ ^ if block ~ ~ ~ #minecraft:replaceable if block ~ ~1 ~ #minecraft:replaceable run tp @s ^-0.7 ^ ^
