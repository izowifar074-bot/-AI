# ============================================================
# smartz:uninstall — 完全卸载：记分板/标签/修饰符/锚点实体
# 执行后移除数据包文件并 /reload 即彻底干净
# ============================================================
scoreboard objectives remove sz.ai
scoreboard objectives remove sz.id
scoreboard objectives remove sz.mine
scoreboard objectives remove sz.cool
scoreboard objectives remove sz.atk
scoreboard objectives remove sz.hurt
scoreboard objectives remove sz.hp
scoreboard objectives remove sz.pearl
scoreboard objectives remove sz.dmin
scoreboard objectives remove sz.dprev
execute as @e[type=minecraft:husk,tag=sz.climb] run attribute @s minecraft:movement_speed modifier remove smartz:freeze
tag @e remove sz.init
tag @e remove sz.alerted
tag @e remove sz.mining
tag @e remove sz.climb
tag @e remove sz.pave
tag @e remove sz.aim
tag @e remove sz.vip
tag @e remove sz.tpme
tag @e remove sz.tgtable
tag @e remove sz.cand
kill @e[type=minecraft:marker,tag=sz.target]
tellraw @a {"text":"[智能尸壳] 卸载完成","color":"red"}
