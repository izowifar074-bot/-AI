# ============================================================
# smartz:test_pvp — PVP 快速测试（玩家手动执行：/function smartz:test_pvp）
# 在玩家上空生成两座 5x5 悬空小岛（相距约 24 格，落在珍珠射程内），
# 各站一只尸壳，二者互相敌对（sz.enemy + 开局交叉建立仇恨），立即
# 开打（珍珠起手 → 搭桥/闪现接近 → 近战）。用于观战 PVP。
# 重要：请用【旁观/创造模式】观战——否则它俩会把你当仇恨对象。
# 可重复执行（先清上批）；清场：/kill @e[tag=sz.test]
# ============================================================
kill @e[type=minecraft:husk,tag=sz.test]
# 两座 5x5 平台（玩家上方 7 格，东西各偏 12，相距约 24 格）
fill ~-14 ~7 ~-2 ~-10 ~7 ~2 minecraft:cobblestone
fill ~10 ~7 ~-2 ~14 ~7 ~2 minecraft:cobblestone
# 各生成一只尸壳（sz.enemy 使其互为仇恨对象；sz.test 便于清场）
summon minecraft:husk ~-12 ~8 ~ {Tags:["sz.enemy","sz.test","sz.testa"],PersistenceRequired:1b}
summon minecraft:husk ~12 ~8 ~ {Tags:["sz.enemy","sz.test","sz.testb"],PersistenceRequired:1b}
# 开局交叉建立仇恨，保证立刻互殴（之后由 sense 维持锁定最近敌对）
execute as @e[tag=sz.testa,limit=1] at @s run damage @s 0.0001 minecraft:generic by @e[tag=sz.testb,limit=1]
execute as @e[tag=sz.testb,limit=1] at @s run damage @s 0.0001 minecraft:generic by @e[tag=sz.testa,limit=1]
tag @e remove sz.testa
tag @e remove sz.testb
tellraw @a {"text":"[智能尸壳] 上空生成两只互敌尸壳（相距24格）。请用旁观/创造模式观战，否则它俩会来打你（/kill @e[tag=sz.test] 清场）","color":"aqua"}
