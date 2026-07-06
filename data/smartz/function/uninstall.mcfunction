# ============================================================
# smartz:uninstall — 玩家手动执行，完全卸载
# 职责：
#   1. 删除所有 sz.* 记分板
#   2. 移除所有僵尸身上的 sz.* 标签
#   3. 输出卸载完成提示，提醒玩家移除数据包文件后 /reload
# ============================================================
scoreboard objectives remove sz.clock
scoreboard objectives remove sz.id
scoreboard objectives remove sz.config
scoreboard objectives remove sz.posx
scoreboard objectives remove sz.posy
scoreboard objectives remove sz.posz
scoreboard objectives remove sz.stuck
scoreboard objectives remove sz.mine
scoreboard objectives remove sz.cool
scoreboard objectives remove sz.atk
tag @e remove sz.init
tag @e remove sz.vip
tag @e remove sz.alerted
tag @e remove sz.mining
execute as @e[type=minecraft:zombie,tag=sz.climb] run attribute @s minecraft:movement_speed modifier remove smartz:freeze
tag @e remove sz.climb
kill @e[type=minecraft:marker,tag=sz.target]
tellraw @a {"text":"[智能僵尸] 卸载完成","color":"red"}