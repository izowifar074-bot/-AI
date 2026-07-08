# ============================================================
# smartz:init — 每只新尸壳初始化一次（executor = 该尸壳）
# 属性强化 / 开门 / 装备（剑盾不掉落，方块为虚拟库存）/
# 编号分配 / 距离基线 / 珍珠 10 秒出生预热
# ============================================================
attribute @s minecraft:follow_range base set 64
attribute @s minecraft:movement_speed base set 0.28
attribute @s minecraft:knockback_resistance base set 0.3
attribute @s minecraft:step_height base set 1.0
attribute @s minecraft:spawn_reinforcements base set 0
attribute @s minecraft:attack_damage base set 2
data merge entity @s {CanBreakDoors:1b}
item replace entity @s weapon.mainhand with minecraft:iron_sword
item replace entity @s weapon.offhand with minecraft:shield
data merge entity @s {drop_chances:{mainhand:0.0f,offhand:0.0f}}
scoreboard players operation @s sz.id = #next_id sz.ai
scoreboard players add #next_id sz.ai 1
scoreboard players set @s sz.dmin 999999999
scoreboard players set @s sz.pearl -150
tag @s add sz.init
