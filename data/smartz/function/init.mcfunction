# ============================================================
# smartz:init — 以每只【新僵尸】身份执行一次（executor = 该僵尸）
# 职责：
#   1. 属性强化（attribute 命令）：
#      - follow_range = 64（隔墙远距离索敌）
#      - movement_speed = 0.28（略快于玩家步行）
#      - knockback_resistance = 0.3
#      - step_height = 1.0（自动走上 1 格台阶）
#      - spawn_reinforcements = 0（协同靠情报共享，不靠刷怪量）
#      - attack_damage = 2（原版碰撞攻击弱化为推搡，真伤害走 PVP 射线）
#   2. data merge 开启 CanBreakDoors
#   2b. 装备物品栏：主手铁剑 + 副手盾牌，均不掉落（方块为虚拟库存）
#   3. 分配唯一编号：从 #next_id sz.id 取值并自增
#   4. sz.posx 置为极大值（受阻检测的"历史最近距离²"基线）
#   5. 打上 tag sz.init 防止重复初始化
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
scoreboard players operation @s sz.id = #next_id sz.id
scoreboard players add #next_id sz.id 1
scoreboard players set @s sz.posx 999999999
tag @s add sz.init