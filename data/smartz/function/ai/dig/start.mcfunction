# ============================================================
# smartz:ai/dig/start — 挖掘启动（executor = 僵尸）
# 由 decide / down 在放置了 tag=sz.new 的目标 marker 后调用：
# 配对 sz.id、打 sz.mining 标签、按软硬方块设定挖掘时长。
# ============================================================
execute if entity @e[type=minecraft:marker,tag=sz.new] run scoreboard players operation @e[type=minecraft:marker,tag=sz.new,limit=1] sz.id = @s sz.id
execute if entity @e[type=minecraft:marker,tag=sz.new] run tag @s add sz.mining
execute if entity @e[type=minecraft:marker,tag=sz.new] run scoreboard players set @s sz.mine 10
execute if entity @e[type=minecraft:marker,tag=sz.new] at @e[type=minecraft:marker,tag=sz.new,limit=1] if block ~ ~ ~ #smartz:soft run scoreboard players set @s sz.mine 5
execute if entity @e[type=minecraft:marker,tag=sz.new] run tag @e[type=minecraft:marker,tag=sz.new] remove sz.new
